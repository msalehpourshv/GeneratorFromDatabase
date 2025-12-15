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
--[prd].[SPTestAutoGroupProduce] 1400,2
Create PROCEDURE [prd].[SPTestAutoGroupProduce]
	@FiscalYear			INT = 1400,
	@SerialNo		INT = 1
		
WITH ENCRYPTION
AS
declare	@StrSelect	NVarChar(2000)
declare	@StrFrom	NVarChar(2000),
		@PrdQuantity		float,
		@ProductID			varchar(20),
		@AcntCode			varchar(20),
		@StoreID1			varchar(20),
		@StoreID2			varchar(20),
		@ProductDate		char(10) = null,
		@FormulaNo			Int = null,
		@DocRowNo			Int = null
BEGIN
	SET NOCOUNT ON;
	declare @StrWhere0  NVARCHAR(200)

IF (SELECT COUNt(*)
   from prd.tblGroupProduceDtl
   where ProcessID =67 AND ProcessNo=1 AND FiscalYear= @FiscalYear AND SerialNo = @SerialNo and ProductID<>'' and Quantity<>'')=0
   BEGIN
		raiserror ('.موردی برای تست کمبود موجودی وجود ندارد ', 16, 1)
		RETURN
   END

	create table #Qty
	(
		DocRowNo		int,
		GoodsID		varchar(20) collate Arabic_CS_AS  Not Null, 
		GoodsName	nvarchar(200) Not Null,
		Qty		FLOAT,
		DocDate	char(10)		
	);
	
	-- select section ---------------------------------------------------------
	create table #TT
	(
		ProductID	varchar(20) collate Arabic_CS_AS  Not Null, 
		GoodsID		varchar(20) collate Arabic_CS_AS  Not Null,
		[level]		varchar(50) Not Null,
		PrdCnt		FLOAT,
		Quantity	FLOAT,
		L2			Varchar(100)
		,DefaultStoreID		varchar(20) collate Arabic_CS_AS  Not Null
		, DocRowNo  int
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
	FROM prd.tblFormulasDtl 
	where GoodsQuantity>0
	GROUP BY ProductID,SerialNo,GoodsID	,DefaultStoreID

	Declare	curGroupProduce CURSOR For
		 
	SELECT AcntCode,ProductID,Quantity,StoreID1,StoreID2,ProductDate,FormulaNo,DocRowNo 
	FROM prd.tblGroupProduceDtl 
	WHERE ProcessID =67 AND ProcessNo=1 AND FiscalYear= @FiscalYear AND SerialNo = @SerialNo
	order by DocRowNo
	Open curGroupProduce;
		
	Fetch NEXT From curGroupProduce Into @AcntCode,@ProductID,@PrdQuantity,@StoreID1,@StoreID2,@ProductDate,@FormulaNo,@DocRowNo
		While (@@Fetch_Status = 0)
	BEGIN
		if (@FormulaNo <> 0) 
			set @StrWhere0 = '(H.SerialNo = ' + LTrim(Str(@FormulaNo)) + ')'
		else
			set @StrWhere0 = '(H.IsDefault = 1)' 

		set @StrSelect = '
		WITH tblTemp(ProductID, GoodsID, [level],PrdCnt, Quantity, L2,DefaultStoreID,FmlNo) AS
		(
		SELECT CAST(''' + @ProductID + '''  as varchar(20))  ProductID , D.GoodsID, 
			cast(nchar(Row_Number() over (order by GoodsID)+64) as varchar(50)) as [level], 
			(' + LTrim(Str(@PrdQuantity,20,5)) + ' / (H.ProductCount/H.ProductCount)) As PrdCnt,
			(' + LTrim(Str(@PrdQuantity,20,5)) + ' / H.ProductCount) * D.GoodsQuantity As Quantity,
			cast(100+(Row_Number() over (order by DocRowNo)) as varchar(100)) as L2,
			case when D.DefaultStoreID <>'''' THEN D.DefaultStoreID ELSE ''' + @StoreID1 + ''' END As DefaultStoreID,
			H.SerialNo
		FROM  #TFD D
		INNER JOIN prd.tblFormulasHdr H ON D.SerialNo = H.SerialNo AND D.ProductID = H.ProductID 
		WHERE  (H.ProductID = SUBSTRING(''' + @ProductID + ''',1,LEN(H.ProductID))) AND ' + @StrWhere0 + '

		UNION All
			
		SELECT tblTemp.GoodsID ProductID, D.GoodsID, 
			cast(tblTemp.level + char(Row_Number() over (order by H.ProductID,D.GoodsID)+64) as varchar(50)) as [level], 
			(tblTemp.Quantity ) As PrdCnt,
			(tblTemp.Quantity / H.ProductCount) * D.GoodsQuantity As Quantity,
			cast( ltrim(tblTemp.L2)+''-''+ cast(100+(Row_Number() over (order by H.ProductID,D.DocRowNo)) as char(3)) as varchar(100)) as L2,
			case when D.DefaultStoreID <>'''' THEN D.DefaultStoreID ELSE ''' + @StoreID1 + ''' END As DefaultStoreID,
			H.SerialNo 
		FROM	#TFD D
		INNER JOIN prd.tblFormulasHdr H ON D.SerialNo = H.SerialNo AND D.ProductID = H.ProductID, tblTemp
		WHERE  (H.ProductID = SUBSTRING(tblTemp.GoodsID,1,LEN(H.ProductID))) AND ' + @StrWhere0 + '
		)
		INSERT INTO #TT
		select	*  
		from	tblTemp T 		'
		
		print @StrSelect;
		exec sp_executesql @StrSelect;
  
  	Fetch NEXT From curGroupProduce Into @AcntCode,@ProductID,@PrdQuantity,@StoreID1,@StoreID2,@ProductDate,@FormulaNo,@DocRowNo
	END -- curGroupProduce
	Close curGroupProduce;
	Deallocate curGroupProduce; 

	DECLARE @PrdProductManyStores Bit
	SET @PrdProductManyStores  = 0
	SELECT @PrdProductManyStores = SettingValue from pub.tblSettings where SettingKey = 'PrdProductManyStores'
	insert into #Qty  
	SELECT DocRowNo , a.GoodsID  ,pub.funGetGoodsName(GoodsID,1) GoodsName,CAST(a.Quantity-a.Remain as float) Qty
	,	@ProductDate DocDate
	 from (
		SELECT GoodsID ,SUM((PrdCnt- CASE WHEN IsMain =0 THEN  Remain ELSE 0 END) * Quantity /PrdCnt) Quantity
		 ,
			(
			ISNULL((SELECT SUM(GoodsQuantity*EnterKind) from inv.tblStorageDocsDtl b
			 WHERE  (StoreID=@StoreID1 or (@PrdProductManyStores  = 1 and StoreID=a.DefaultStoreID )
			 )  
			 AND b.GoodsID=a.GoodsID AND DocDate<=@ProductDate ),0)
			)Remain,DocRowNo
		from (
				select	R.*,
				ISNULL((SELECT SUM(GoodsQuantity*EnterKind) from inv.tblStorageDocsDtl a 
				WHERE  (StoreID=@StoreID1 or (@PrdProductManyStores  = 1 and StoreID=R.DefaultStoreID )
				)  
				AND a.GoodsID=R.ProductID AND DocDate<=@ProductDate),0) Remain
				,( SELECT COUNT(*)
				   from prd.tblGroupProduceDtl g
				   where ProcessID =67 AND ProcessNo=1 AND FiscalYear= @FiscalYear AND SerialNo = @SerialNo and ProductID<>'' and Quantity<>'' and g.ProductID=R.ProductID) IsMain
				from	#TT R
			 ) a
		WHERE ( IsMain>0 OR Remain - PrdCnt <0) AND GoodsID NOT IN (select ProductID from  prd.tblFormulasHdr where  IsDefault=1 )
		group by GoodsID,a.DefaultStoreID,DocRowNo
	) a 
	where a.Quantity>a.Remain
	
		
	select DocRowNo  [ردیف],GoodsID[کد کالا],GoodsName[نام کالا],Qty[مقدار],DocDate [تاریخ] 
	from #Qty
	Order by DocRowNo,GoodsID
 
END
GO
