USE TS_ShirinVatanKarkhaneh_1_1404
GO
SET ANSI_NULLS, QUOTED_IDENTIFIER ON
GO
-- =========== TS-QC:UPDATED ====================
-- Author		 : TakroSystem\Hadi Sadeghi
-- Create date   : 1397/02/29
-- Viewed By	 : 
-- Last Modified : 
-- Last Modifier : 
-- Description   : <ایجاد اتوماتیک ارسال و دریافت تولید بر اساس BOM کالا>
-- =================================================================
Create PROCEDURE prd.SPTestAutoProduct
	@ProductID			varchar(20),
	@StoreID1			varchar(20),
	@DocDate			char(10) = null,
	@ProductQuantity	float = 1,
	@FormulaNo			INT, 
	@ExtraParams		nvarchar(200)
	
WITH ENCRYPTION
AS
declare	@StrSelect	NVarChar(2000)
declare	@StrFrom	NVarChar(2000)
declare	@StrWhere0	NVarChar(2000)
declare	@NoFlowFormula	bit

BEGIN
	SET NOCOUNT ON;

	
	SET @NoFlowFormula				= pub.funSplitString(@ExtraParams, '@', 1);

	-- where section ----------------------------------------------------------
	if (@FormulaNo <> 0) 
		set @StrWhere0 = '(H.SerialNo = ' + Str(@FormulaNo) + ')'
	else
		set @StrWhere0 = '(H.IsDefault = 1)' 
	
	-- select section ---------------------------------------------------------
	create table #TT
	(
		ProductID	varchar(20) collate Arabic_CS_AS  Not Null, 
		GoodsID		varchar(20) collate Arabic_CS_AS  Not Null, 
		[level]		varchar(50) Not Null,
		PrdCnt		FLOAT,
		Quantity	nVarchar(100),
		L2			Varchar(100)
		,DefaultStoreID		varchar(20) collate Arabic_CS_AS  Not Null
	);
	
--drop table #TFD
	create table #TFD
	(
		ProductID	varchar(20) collate Arabic_CS_AS  Not Null, 
		SerialNo	INT Not Null,
		GoodsID		varchar(20) collate Arabic_CS_AS  Not Null, 
		DocRowNo	varchar(100) Not Null,
		GoodsQuantity FLOAT
		,DefaultStoreID		varchar(20) collate Arabic_CS_AS  Not Null
	);
		
	-----------------------------------------------------------------------------
	-- fill ---------------------------------------------------------------------
	INSERT INTO #TFD
	SELECT ProductID,SerialNo,GoodsID,ROW_NUMBER()over(order by ProductID,SerialNo,GoodsID) DocRowNo 	,SUM(GoodsQuantity) GoodsQuantity	,DefaultStoreID
	FROM prd.tblFormulasDtl GROUP BY ProductID,SerialNo,GoodsID	,DefaultStoreID

if @NoFlowFormula='False'
		set @StrSelect = '
			WITH tblTemp(ProductID, GoodsID, [level],PrdCnt, Quantity, L2,DefaultStoreID) AS
		(
		SELECT	H.ProductID, D.GoodsID, 
				cast(nchar(Row_Number() over (order by GoodsID)+64) as varchar(50)) as [level], 
				(' + LTrim(Str(@ProductQuantity)) + ' / H.ProductCount) As PrdCnt,
				(' + LTrim(Str(@ProductQuantity)) + ' / H.ProductCount) * D.GoodsQuantity As Quantity,
				cast(100+(Row_Number() over (order by DocRowNo)) as varchar(100)) as L2,D.DefaultStoreID
			FROM  #TFD D
						INNER JOIN prd.tblFormulasHdr H ON D.SerialNo = H.SerialNo AND D.ProductID = H.ProductID 
			WHERE  (H.ProductID = ''' + @ProductID + ''') AND ' + @StrWhere0+ '

			UNION All
			
			SELECT	H.ProductID, D.GoodsID, 
				cast(tblTemp.level + char(Row_Number() over (order by H.ProductID,D.GoodsID)+64) as varchar(50)) as [level], 
				(tblTemp.Quantity ) As PrdCnt,
				(tblTemp.Quantity / H.ProductCount) * D.GoodsQuantity As Quantity,
				cast( ltrim(tblTemp.L2)+''-''+ cast(100+(Row_Number() over (order by H.ProductID,D.DocRowNo)) as char(3)) as varchar(100)) as L2,D.DefaultStoreID
			FROM	#TFD D
						INNER JOIN prd.tblFormulasHdr H ON D.SerialNo = H.SerialNo AND D.ProductID = H.ProductID, tblTemp
			WHERE  (H.ProductID = tblTemp.GoodsID) AND ' + @StrWhere0+ '
		)
		INSERT INTO #TT
		select	*  
		from	tblTemp T '
else
	set @StrSelect = '
		INSERT INTO #TT
		SELECT	H.ProductID, D.GoodsID, 
				cast(nchar(Row_Number() over (order by GoodsID)+64) as varchar(50)) as [level], 
				(' + LTrim(Str(@ProductQuantity)) + ' / H.ProductCount) As PrdCnt,
				(' + LTrim(Str(@ProductQuantity)) + ' / H.ProductCount) * D.GoodsQuantity As Quantity,
				cast(100+(Row_Number() over (order by DocRowNo)) as varchar(100)) as L2,D.DefaultStoreID
			FROM  #TFD D
						INNER JOIN prd.tblFormulasHdr H ON D.SerialNo = H.SerialNo AND D.ProductID = H.ProductID 
			WHERE  (H.ProductID = ''' + @ProductID + ''') AND ' + @StrWhere0+ ' '

	print @StrSelect;
	exec sp_executesql @StrSelect;
 
 
 DECLARE @PrdProductManyStores Bit
	SET @PrdProductManyStores  = 0
	SELECT @PrdProductManyStores = SettingValue from pub.tblSettings where SettingKey = 'PrdProductManyStores'
	 
	SELECT Row_Number()over(order by GoodsID) ردیف , a.GoodsID کالا,pub.funGetGoodsName(GoodsID,1) نام,CAST(a.Quantity-a.Remain as float) [موردنیاز]
	 from (
		SELECT GoodsID ,SUM((PrdCnt-CASE WHEN ProductID=@ProductID THEN 0 ELSE Remain END) * Quantity /PrdCnt) Quantity
		 ,
			(
			ISNULL((SELECT SUM(GoodsQuantity*EnterKind) from inv.tblStorageDocsDtl b
			 WHERE  (StoreID=@StoreID1 or (@PrdProductManyStores  = 1 and StoreID=a.DefaultStoreID )
			 )  
			 AND b.GoodsID=a.GoodsID AND DocDate<=@DocDate),0)
			)Remain
		from (
				select	R.*,
				ISNULL((SELECT SUM(GoodsQuantity*EnterKind) from inv.tblStorageDocsDtl a 
				WHERE  (StoreID=@StoreID1 or (@PrdProductManyStores  = 1 and StoreID=R.DefaultStoreID )
				)  
				AND a.GoodsID=R.ProductID AND DocDate<=@DocDate),0) Remain
				from	#TT R
			 ) a
		WHERE ( ProductID=@ProductID OR Remain - PrdCnt <0) AND (@NoFlowFormula='True' OR(@NoFlowFormula='False' AND GoodsID NOT IN (select ProductID from  prd.tblFormulasHdr 		where (@FormulaNo=0 and IsDefault=1 ) or (@FormulaNo<>0 and  SerialNo=@FormulaNo))))
		group by GoodsID,a.DefaultStoreID
	) a 
	where a.Quantity>a.Remain
	
END
GO
