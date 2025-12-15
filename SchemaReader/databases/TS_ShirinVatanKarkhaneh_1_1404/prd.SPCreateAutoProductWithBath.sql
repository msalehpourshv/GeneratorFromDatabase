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
CREATE PROCEDURE [prd].[SPCreateAutoProductWithBath]
	@ProductID			varchar(20),
	@AcntCode			varchar(20),
	@StoreID1			varchar(20),
	@DocDate			char(10) = null,
	@ProductQuantity	float = 1,
	@FormulaNo			INT,
	@FiscalYear			INT = 97,
	@BatchNo            NVARCHAR(50) ,
	@TransferSerialNo NVARCHAR(50) ,
	@EnterKind int
WITH ENCRYPTION
AS
declare	@StrSelect	NVarChar(2000)
declare	@StrFrom	NVarChar(2000)
declare	@StrWhere0	NVarChar(2000)
declare	@DefaultStoreID			varchar(20)
declare	@FormulaNo2				INT

BEGIN
	SET NOCOUNT ON;


	-- where section ----------------------------------------------------------
	if (@FormulaNo <> 0) 
		set @StrWhere0 = '(H.SerialNo = ' + Str(@FormulaNo) + ')'
	else
		set @StrWhere0 = '(H.IsDefault = 1)' 

DECLARE @PrdProductManyStores Bit
	SET @PrdProductManyStores  = 0

	SELECT @PrdProductManyStores = SettingValue from pub.tblSettings where SettingKey = 'PrdProductManyStores'
		
	-- select section ---------------------------------------------------------
	create table #TT
	(
		ProductID	varchar(20) collate Arabic_CS_AS  Not Null, 
		GoodsID		varchar(20) collate Arabic_CS_AS  Not Null, 
		[level]		varchar(50) Not Null,
		PrdCnt		float,
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


	declare @ProductID1 VARCHAR(20)
	declare @GoodsID VARCHAR(20)
	declare @UnitID VARCHAR(20)
	declare @ProductIDTmp VARCHAR(20)
	declare @GoodsIDTmp VARCHAR(20)
	declare @PrdCnt Float
	declare @Quantity Float
	declare @mxSendPrdSerial int
	declare @mxResPrdSerial int
	declare @R int
	declare @RowNo int
	declare @TmpStoreID70 VARCHAR(20)
	declare @TmpStoreID80 VARCHAR(20)
	declare @L  NVARCHAR(200)
		
	-----------------------------------------------------------------------------
	-- fill ---------------------------------------------------------------------
INSERT INTO #TFD
SELECT ProductID,SerialNo,GoodsID,ROW_NUMBER()over(order by ProductID,SerialNo,GoodsID) DocRowNo 	,SUM(GoodsQuantity) GoodsQuantity,DefaultStoreID
FROM prd.tblFormulasDtl 
where GoodsQuantity>0
GROUP BY ProductID,SerialNo,GoodsID,DefaultStoreID


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

	print @StrSelect;
	exec sp_executesql @StrSelect;
	---- استفاده از انبار معرفی شده
	if @PrdProductManyStores=0
		update   #TT 	set DefaultStoreID=''

	--------------------------------------------------------------------
 
	 --select * from #TT
	Declare	curStore1 CURSOR For
		 
	SELECT ProductID,GoodsID,pub.funGetGoodsUnitID(GoodsID) UnitID,PrdCnt-Remain PrdCnt ,(PrdCnt-Remain) * Quantity /PrdCnt Quantity ,R,L2--,[level]
	,DefaultStoreID
	from (
	select	R.*,ROW_NUMBER()over(partition by ProductID,SUBSTRING([level],1,LEN([level])-1) order by LEN(L2) desc,ProductID,L2) R,
	Case when ProductID=@ProductID or (select  COUNT(*) from inv.tblGoods where GoodsID=R.ProductID AND HasBatchNo=1)=1 then  0 else   ISNULL((SELECT SUM(GoodsQuantity*EnterKind) from inv.tblStorageDocsDtl a WHERE StoreID=@StoreID1 AND a.GoodsID=R.ProductID AND DocDate<=@DocDate),0) end Remain
	from	#TT R ) a
--	WHERE Remain - PrdCnt <0
	order by len([level]) ,[level] 


	Open curStore1;
		
	Fetch NEXT From curStore1 Into @ProductID1,@GoodsID,@UnitID,@PrdCnt,@Quantity,@R,@L,@DefaultStoreID
	
	While (@@Fetch_Status = 0)
	BEGIN
			--DELETE FROM  #TT
			declare @GRemain float
			if (select  COUNT(*) from inv.tblGoods where GoodsID=@GoodsID AND HasBatchNo=1)=1
				SET @GRemain=0
			ELSE
				SELECT @GRemain = ISNULL(SUM(GoodsQuantity*EnterKind),0) from inv.tblStorageDocsDtl a 
					   WHERE StoreID=@DefaultStoreID  AND a.GoodsID=@GoodsID AND DocDate<=@DocDate
			if @GRemain >=@Quantity
			BEGIN
				delete from #TT
				where L2 like (@L+'-%')
			END
		
			Fetch NEXT From curStore1 Into @ProductID1,@GoodsID,@UnitID,@PrdCnt,@Quantity,@R,@L,@DefaultStoreID
	END -- curStore
	Close curStore1;
	Deallocate curStore1; 
	 
	 
	 --select * from #TT
	 --return 
   BEGIN TRY
		
	BEGIN TRAN



	SELECT @mxSendPrdSerial =ISNULL(MAX(SerialNo),0) FROM inv.tblStorageDocsHdr WHERE ProcessID = 70 and ProcessNo=1 AND FiscalYear = @FiscalYear
	SELECT @mxResPrdSerial =ISNULL(MAX(SerialNo),0) FROM inv.tblStorageDocsHdr WHERE ProcessID = 80 and ProcessNo=1 AND FiscalYear = @FiscalYear
	
 	SET @TmpStoreID70 = ''
	SET @ProductIDTmp = ''

	Declare	curStore CURSOR For
		 
	SELECT ProductID,GoodsID,pub.funGetGoodsUnitID(GoodsID) UnitID,PrdCnt-Remain PrdCnt ,(PrdCnt-Remain) * Quantity /PrdCnt Quantity ,R--,L2,[level]
	,DefaultStoreID
	from (
	select	R.*,ROW_NUMBER()over(partition by ProductID,SUBSTRING([level],1,LEN([level])-1) order by LEN(L2) desc,ProductID,L2) R,
	Case when ProductID=@ProductID OR  (select  COUNT(*) from inv.tblGoods where GoodsID=R.ProductID AND HasBatchNo=1)=1 then  0 else   ISNULL((SELECT SUM(GoodsQuantity*EnterKind) from inv.tblStorageDocsDtl a WHERE StoreID=@StoreID1 AND a.GoodsID=R.ProductID AND DocDate<=@DocDate),0) end Remain
	from	#TT R ) a
	WHERE Remain - PrdCnt <0
	order by len([level]) desc,L2 desc,ProductID,[level] desc


	Open curStore;
		
	Fetch NEXT From curStore Into @ProductID1,@GoodsID,@UnitID,@PrdCnt,@Quantity,@R,@DefaultStoreID
	
	While (@@Fetch_Status = 0)
	BEGIN
	 

	if ISNULL((SELECT SUM(GoodsQuantity*EnterKind) from inv.tblStorageDocsDtl a 
		WHERE StoreID=@StoreID1  AND a.GoodsID=@GoodsID AND DocDate<=@DocDate),0) >=@Quantity
	 
		SET @TmpStoreID70  = @StoreID1
		else
		SET @TmpStoreID70  = @DefaultStoreID
		
		SET @TmpStoreID80  = @StoreID1
		
			IF @ProductID1 = @ProductID
				SET @TmpStoreID80  = @StoreID1
 
 
		IF (@ProductIDTmp <> @ProductID1 ) 
		BEGIN
 
			SET @RowNo=0
			SET @ProductIDTmp=@ProductID1
			SET @GoodsIDTmp=@GoodsID
			
			SET @mxSendPrdSerial = @mxSendPrdSerial +1
			if @FormulaNo=0
				select @FormulaNo2=SerialNo FROM prd.tblFormulasHdr where ProductID=@ProductID1 and IsDefault=1
			else
				set @FormulaNo2=@FormulaNo				

			INSERT INTO inv.tblStorageDocsHdr 
			(ProcessID,ProcessNo,FiscalYear,SerialNo,DocDate,StoreID,ProductID,FormulaNo,ProductCount,WageRate,AcntCode,DocStep,BatchNo,TransferSerialNo)
			SELECT 70,1,@FiscalYear,@mxSendPrdSerial,@DocDate,@TmpStoreID70,@ProductID1,@FormulaNo2,@PrdCnt,100,@AcntCode,1,CASE
			WHEN G.HasBatchNo=1 THEN @BatchNo
			WHEN G.HasBatchNo=0 THEN ''
			END,@TransferSerialNo
			FROM inv.tblGoods G
			WHERE G.GoodsID=@ProductID1---------------------------------------------------------------------------------------------------------------------
			SET @mxResPrdSerial = @mxResPrdSerial +1
			
			INSERT INTO inv.tblStorageDocsHdr 
			(ProcessID,ProcessNo,FiscalYear,SerialNo,DocDate,StoreID,BaseProcessID,BaseProcessNo,BaseFiscalYear,BaseSerialNo,BaseDocType,AcntCode,DocStep,BatchNo,TransferSerialNo)
			SELECT 80,1,@FiscalYear,@mxResPrdSerial,@DocDate,@TmpStoreID80,70,1,@FiscalYear,@mxSendPrdSerial,70,@AcntCode,1,CASE
			WHEN G.HasBatchNo=1 THEN @BatchNo
			WHEN G.HasBatchNo=0 THEN ''
			END,@TransferSerialNo
			FROM inv.tblGoods G
			WHERE G.GoodsID=@ProductID1--------------------------------------------------------------------------------------------------------------------------
		END	
		
		SET @RowNo=@RowNo+1
		

		INSERT INTO inv.tblStorageDocsDtl	
		(ProcessID, ProcessNo, FiscalYear, SerialNo, RowNo, DocRowNo, DocDate, StoreID, PhysicallyEffected, EnterKind, GoodsID, SubUnitID, SubUnitQuantity, GoodsQuantity,AcntCode,DocStep,BatchNo)
		SELECT 70,1,@FiscalYear,@mxSendPrdSerial,@RowNo,@RowNo,@DocDate,@TmpStoreID70,1,case when @EnterKind=0 then 0 when @EnterKind<>0 then -1 end,@GoodsID,@UnitID,@Quantity,@Quantity,@AcntCode,1,CASE
			WHEN G.HasBatchNo=1 THEN @BatchNo
			WHEN G.HasBatchNo=0 THEN ''
			END
			FROM inv.tblGoods G
			WHERE G.GoodsID=@GoodsID---------------------------------------------------------------------------------------------------------------------------------
		
		IF @R=1 
		BEGIN
			if @FormulaNo=0
				select @FormulaNo2=SerialNo FROM prd.tblFormulasHdr where ProductID=@ProductID1 and IsDefault=1
			else
				set @FormulaNo2=@FormulaNo

			SELECT @UnitID = pub.funGetGoodsUnitID(@ProductID1)
			INSERT INTO inv.tblStorageDocsDtl	
			(ProcessID, ProcessNo, FiscalYear, SerialNo, RowNo, DocRowNo, DocDate, StoreID, PhysicallyEffected, EnterKind, GoodsID, SubUnitID, SubUnitQuantity, GoodsQuantity,
			 BaseProcessID, BaseProcessNo, BaseFiscalYear, BaseSerialNo, BaseDocRowNo, BaseDocType, FormulaNo,WageRate,AcntCode,DocStep,BatchNo)
			SELECT 80,1,@FiscalYear,@mxResPrdSerial,1,1,@DocDate,@TmpStoreID80,1,case when @EnterKind=0 then 0 when @EnterKind<>0 then 1 end,@ProductID1,@UnitID,@PrdCnt,@PrdCnt,70,1,@FiscalYear,@mxSendPrdSerial,0,70,@FormulaNo2,100,@AcntCode,1,CASE
			WHEN G.HasBatchNo=1 THEN @BatchNo
			WHEN G.HasBatchNo=0 THEN ''
			END
			FROM inv.tblGoods G
			WHERE G.GoodsID=@ProductID1--------------------------------------------------------------------------------------------------------------------------------------

		END
		  
			Fetch NEXT From curStore Into @ProductID1,@GoodsID,@UnitID,@PrdCnt,@Quantity,@R,@DefaultStoreID
	END -- curStore
	Close curStore;
	Deallocate curStore; 

	
	COMMIT TRAN
	
 END TRY
	  	
	BEGIN CATCH
	    ROLLBACK TRAN
	   	Close curStore;
		Deallocate curStore; 

		Declare @StrErrorMessage As Nvarchar(1024)
		Set @StrErrorMessage = ERROR_MESSAGE() 
		raiserror (@StrErrorMessage, 16, 1)
		 
	END CATCH
end	
GO
