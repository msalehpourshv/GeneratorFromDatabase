USE TS_ShirinVatanKarkhaneh_1_1404
GO
SET ANSI_NULLS, QUOTED_IDENTIFIER ON
GO
-- =========== TS-QC:UPDATED ====================
-- Author		 : TakroSystem\Hadi Sadeghi
-- Create date   : 1400/10/11
-- Viewed By	 : 
-- Last Modified : 
-- Last Modifier : 
-- Description   : 
-- =================================================================
Create PROCEDURE [prd].[SPCreateAutoGroupProduce]
	@FiscalYear			INT = 97,
	@SerialNo		INT = 97
	
WITH ENCRYPTION
AS
declare	@StrSelect			NVarChar(2000),
		@StrFrom			NVarChar(2000),
		@DefaultStoreID		varchar(20),
		@FormulaNo2			INT,
		@PrdQuantity		float,
		@ProductID			varchar(20),
		@AcntCode			varchar(20),
		@StoreID1			varchar(20),
		@StoreID2			varchar(20),
		@ProductDate		char(10) = null,
		@FormulaNo			int = 0

BEGIN
	SET NOCOUNT ON;

DECLARE @Prd_GroupProduceCreateRetUseForNoQty Bit;
SELECT @Prd_GroupProduceCreateRetUseForNoQty = SettingValue from pub.tblSettings where SettingKey = 'Prd_GroupProduceCreateRetUseForNoQty'			

IF (SELECT COUNt(*)
   from prd.tblGroupProduceDtl
   where ProcessID =67 AND ProcessNo=1 AND FiscalYear= @FiscalYear AND SerialNo = @SerialNo and ProductID<>'' and Quantity<>'')=0
   BEGIN
		raiserror ('.موردی برای تولید وجود ندارد ', 16, 1)
		RETURN
   END

   	create table #TTest
			(
				RowNo		int,
				GoodsID		varchar(20) collate Arabic_CS_AS  Not Null, 
				GoodsName	nvarchar(200) collate Arabic_CS_AS  Not Null, 
				Quantity	nVarchar(100),
			);

			-- select section ---------------------------------------------------------
			create table #TT
			(
				ProductID	varchar(20) collate Arabic_CS_AS  Not Null, 
				GoodsID		varchar(20) collate Arabic_CS_AS  Not Null, 
				[level]		varchar(50) Not Null,
				PrdCnt		float,
				Quantity	float,
				L2			Varchar(100),
				DefaultStoreID		varchar(20) collate Arabic_CS_AS  Not Null,
				FmlNo		int
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
		declare @StrWhere0  NVARCHAR(200)
		
		DECLARE @PrdProductManyStores Bit
		SET @PrdProductManyStores  = 0

		SELECT @PrdProductManyStores = SettingValue from pub.tblSettings where SettingKey = 'PrdProductManyStores'

		INSERT INTO #TFD
		SELECT ProductID,SerialNo,GoodsID,ROW_NUMBER()over(order by ProductID,SerialNo,GoodsID) DocRowNo 	,SUM(GoodsQuantity) GoodsQuantity,DefaultStoreID
		FROM prd.tblFormulasDtl 
		where GoodsQuantity>0
		GROUP BY ProductID,SerialNo,GoodsID,DefaultStoreID
							
	BEGIN TRY
		
	BEGIN TRAN
	Declare	curGroupProduce CURSOR For
		 
	SELECT AcntCode,ProductID,Quantity,StoreID1,StoreID2,ProductDate,FormulaNo 
	FROM prd.tblGroupProduceDtl 
	WHERE ProcessID =67 AND ProcessNo=1 AND FiscalYear= @FiscalYear AND SerialNo = @SerialNo

	Open curGroupProduce;
	Fetch NEXT From curGroupProduce Into @AcntCode,@ProductID,@PrdQuantity,@StoreID1,@StoreID2,@ProductDate,@FormulaNo
		While (@@Fetch_Status = 0)
	BEGIN
		if (@FormulaNo <> 0) 
			set @StrWhere0 = '(H.SerialNo = ' + LTrim(Str(@FormulaNo)) + ')'
		else
			set @StrWhere0 = '(H.IsDefault = 1)' 

		delete from #TT
			-- fill ---------------------------------------------------------------------
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
		---- استفاده از انبار معرفی شده
		if @PrdProductManyStores=0
			update   #TT 	set DefaultStoreID=@StoreID1

		 --select * from #TT
		Declare	curStore1 CURSOR For
			 
		SELECT ProductID,GoodsID,pub.funGetGoodsUnitID(GoodsID) UnitID,PrdCnt-Remain PrdCnt ,(PrdCnt-Remain) * Quantity /PrdCnt Quantity ,R,L2--,[level]
		,DefaultStoreID
		from (
		select	R.*,ROW_NUMBER()over(partition by ProductID,SUBSTRING([level],1,LEN([level])-1) order by LEN(L2) desc,ProductID,L2) R,
		Case when ProductID=@ProductID then  0 else   ISNULL((SELECT SUM(GoodsQuantity*EnterKind) from inv.tblStorageDocsDtl a WHERE StoreID=@StoreID1 AND a.GoodsID=R.ProductID AND DocDate<=@ProductDate),0) end Remain
		from	#TT R ) a
	--	WHERE Remain - PrdCnt <0
		order by len([level]) ,[level] 


		Open curStore1;
			
		Fetch NEXT From curStore1 Into @ProductID1,@GoodsID,@UnitID,@PrdCnt,@Quantity,@R,@L,@DefaultStoreID
		
		While (@@Fetch_Status = 0)
		BEGIN
				--DELETE FROM  #TT
				declare @GRemain float
				SELECT @GRemain = ISNULL(SUM(GoodsQuantity*EnterKind),0) from inv.tblStorageDocsDtl a 
						   WHERE StoreID=@DefaultStoreID  AND a.GoodsID=@GoodsID AND DocDate<=@ProductDate
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
			SELECT @mxSendPrdSerial =ISNULL(MAX(SerialNo),0) FROM inv.tblStorageDocsHdr WHERE ProcessID = 70 and ProcessNo=1 AND FiscalYear = @FiscalYear
			SELECT @mxResPrdSerial =ISNULL(MAX(SerialNo),0) FROM inv.tblStorageDocsHdr WHERE ProcessID = 80 and ProcessNo=1 AND FiscalYear = @FiscalYear
			
 			SET @TmpStoreID70 = ''
			SET @ProductIDTmp = ''
			Declare	curStore CURSOR For
				 
			SELECT ProductID,GoodsID,pub.funGetGoodsUnitID(GoodsID) UnitID,PrdCnt-Remain PrdCnt ,(PrdCnt-Remain) * Quantity /PrdCnt Quantity ,R--,L2,[level]
			,DefaultStoreID,FmlNo
			from (
			select	R.*,ROW_NUMBER()over(partition by ProductID,SUBSTRING([level],1,LEN([level])-1) order by LEN(L2) desc,ProductID,L2) R,
			Case when ProductID=@ProductID then  0 else   ISNULL((SELECT SUM(GoodsQuantity*EnterKind) from inv.tblStorageDocsDtl a WHERE StoreID=@StoreID1 AND a.GoodsID=R.ProductID AND DocDate<=@ProductDate),0) end Remain
			from	#TT R ) a
			WHERE Remain - PrdCnt <0
			order by len([level]) desc,L2 desc,ProductID,[level] desc


			Open curStore;
				
			Fetch NEXT From curStore Into @ProductID1,@GoodsID,@UnitID,@PrdCnt,@Quantity,@R,@DefaultStoreID,@FormulaNo
			
			While (@@Fetch_Status = 0)
			BEGIN
			 

			if ISNULL((SELECT SUM(GoodsQuantity*EnterKind) from inv.tblStorageDocsDtl a 
				WHERE StoreID=@StoreID1  AND a.GoodsID=@GoodsID AND DocDate<=@ProductDate),0) >=@Quantity
			 
				SET @TmpStoreID70  = @StoreID1
				else
				SET @TmpStoreID70  = @DefaultStoreID
				
				SET @TmpStoreID80  = @StoreID1
				
					IF @ProductID1 = @ProductID
						SET @TmpStoreID80  = @StoreID2
		 
		 
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
					(ProcessID,ProcessNo,FiscalYear,SerialNo,DocDate,StoreID,ProductID,FormulaNo,ProductCount,AgreeNo,WageRate,AcntCode,DocStep)
					SELECT 70,1,@FiscalYear,@mxSendPrdSerial,@ProductDate,@TmpStoreID70,@ProductID1,@FormulaNo2,@PrdCnt,'67-' + LTRIM(RTRIM(STR(@SerialNo))),100,@AcntCode,1

					SET @mxResPrdSerial = @mxResPrdSerial +1
					
					INSERT INTO inv.tblStorageDocsHdr 
					(ProcessID,ProcessNo,FiscalYear,SerialNo,DocDate,StoreID,BaseProcessID,BaseProcessNo,BaseFiscalYear,BaseSerialNo,BaseDocType,AgreeNo,AcntCode,DocStep,ProductID)
					SELECT 80,1,@FiscalYear,@mxResPrdSerial,@ProductDate,@TmpStoreID80,70,1,@FiscalYear,@mxSendPrdSerial,70,'67-' + LTRIM(RTRIM(STR(@SerialNo))),@AcntCode,1,@ProductID1
				END	
				if @Prd_GroupProduceCreateRetUseForNoQty='True'
				begin
					Declare @Qty as float = [inv].[funGetGoodsQuantityFromSubUnit](@GoodsID,@UnitID,@Quantity)						
					exec prd.SPInsertUse_RetForAutoGroupProduce @GoodsID,@Qty,@FiscalYear,@SerialNo,@TmpStoreID70,@ProductDate
				end

				SET @RowNo=@RowNo+1				
				if @Quantity>0.000001				  
				INSERT INTO inv.tblStorageDocsDtl	
				(ProcessID, ProcessNo, FiscalYear, SerialNo, RowNo, DocRowNo, DocDate, StoreID, PhysicallyEffected, EnterKind, GoodsID, SubUnitID, SubUnitQuantity, GoodsQuantity, AgreeNo,AcntCode,DocStep)
				SELECT 70,1,@FiscalYear,@mxSendPrdSerial,@RowNo,@RowNo,@ProductDate,@TmpStoreID70,1,-1,@GoodsID,@UnitID,@Quantity,@Quantity,'67-' + LTRIM(RTRIM(STR(@SerialNo))),@AcntCode,1

				IF @R=1 
				BEGIN
					--if @FormulaNo=0
						select @FormulaNo2=SerialNo FROM prd.tblFormulasHdr where ProductID=@ProductID1 and IsDefault=1
					--else
					--	set @FormulaNo2=@FormulaNo
					
					SET @RowNo=@RowNo+1

					SELECT @UnitID = pub.funGetGoodsUnitID(@ProductID1)
				 if @PrdCnt>0.000001				  

					INSERT INTO inv.tblStorageDocsDtl	
					(ProcessID, ProcessNo, FiscalYear, SerialNo, RowNo, DocRowNo, DocDate, StoreID, PhysicallyEffected, EnterKind, GoodsID, SubUnitID, SubUnitQuantity, GoodsQuantity, BaseProcessID, BaseProcessNo, BaseFiscalYear, BaseSerialNo, BaseDocRowNo, BaseDocType, AgreeNo, FormulaNo,WageRate,AcntCode,DocStep)
					SELECT 80,1,@FiscalYear,@mxResPrdSerial,@RowNo,@RowNo,@ProductDate,@TmpStoreID80,1,1,@ProductID1,@UnitID,@PrdCnt,@PrdCnt,70,1,@FiscalYear,@mxSendPrdSerial,0,70,'67-' + LTRIM(RTRIM(STR(@SerialNo))),@FormulaNo2,100,@AcntCode,1

				END
				  
					Fetch NEXT From curStore Into @ProductID1,@GoodsID,@UnitID,@PrdCnt,@Quantity,@R,@DefaultStoreID,@FormulaNo
			END -- curStore
			Close curStore;
			Deallocate curStore; 
			

		Fetch NEXT From curGroupProduce Into @AcntCode,@ProductID,@PrdQuantity,@StoreID1,@StoreID2,@ProductDate,@FormulaNo
	END -- curGroupProduce
	Close curGroupProduce;
	Deallocate curGroupProduce; 	
	
	COMMIT TRAN
			
	END TRY
	  	
	BEGIN CATCH
		ROLLBACK TRAN
		Close curStore;
		Deallocate curStore; 
		Close curGroupProduce;
		Deallocate curGroupProduce; 

		Declare @StrErrorMessage As Nvarchar(1024)
		Set @StrErrorMessage = ERROR_MESSAGE() 
		raiserror (@StrErrorMessage, 16, 1)
		 
	END CATCH
END
GO
