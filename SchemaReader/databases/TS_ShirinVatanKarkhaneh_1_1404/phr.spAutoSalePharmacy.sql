USE TS_ShirinVatanKarkhaneh_1_1404
GO
SET ANSI_NULLS, QUOTED_IDENTIFIER ON
GO
-- =========== TS-QC:NOTOK ========================
-- Author        : Reza Nogrepasand
-- Create date   : 92/07/28
-- Viewed By	 : 
-- Last Modified : 
-- Description   : 
-- =============================================
create PROCEDURE [phr].[spAutoSalePharmacy]

@ProcessID as INT,
@ProcessNo AS INT,
@FiscalYear as SMALLINT,
@SerialNo as INT,
@IsNew AS BIT,
@OldSerialNo AS INT,
@PayablePrice AS float,
@DocDate as char(10)

WITH ENCRYPTION
 AS
BEGIN

BEGIN TRAN
	 
 BEGIN TRY

	DECLARE @maxSerialNo INT
	DECLARE @AcntCode AS VARCHAR(20)
	DECLARE @StoreID AS VARCHAR(20)
	DECLARE @RowNo AS INT
	DECLARE @DocRowNo AS INT


	SET @maxSerialNo = 0

	SELECT @StoreID=StoreID FROM phr.tblReciptionHdr 
			 WHERE ProcessID=@ProcessID AND ProcessNo=@ProcessNo
			 AND FiscalYear=@FiscalYear AND SerialNo=@SerialNo
	
	
	SELECT @AcntCode=PhrSaleAcntCode FROM phr.tblReciptionHdr 
			 WHERE ProcessID=@ProcessID AND ProcessNo=@ProcessNo
			 AND FiscalYear=@FiscalYear AND SerialNo=@SerialNo
	
	SELECT @maxSerialNo = isnull(MAX(SerialNo),0)
	FROM inv.tblStorageDocsHdr 
	WHERE ProcessID=90 
	  AND ProcessNo=@ProcessNo
	  AND FiscalYear=@FiscalYear

	
IF @IsNew='True'
	BEGIN
		
		INSERT INTO inv.tblStorageDocsHdr
		(ProcessID, ProcessNo, FiscalYear, SerialNo, DocStep, DocDate, StoreID, AcntCode,
		Amount, BaseProcessID, BaseProcessNo, BaseFiscalYear, 
		BaseSerialNo, IsAutoDoc)
		VALUES
		(90,@ProcessNo,@FiscalYear,@maxSerialNo+1 ,1,@DocDate,@StoreID,@AcntCode,0,@ProcessID,@ProcessNo,
		@FiscalYear,@SerialNo,1)


		INSERT INTO inv.tblStorageDocsDtl
			(ProcessID, ProcessNo,FiscalYear,SerialNo, RowNo, DocRowNo, DocStep,
			DocDate, StoreID, EnterKind, AcntCode, GoodsID, SubUnitID, SubUnitQuantity,
			GoodsQuantity, GoodsAmount, GoodsPrice, BaseProcessID, BaseProcessNo,
			BaseFiscalYear, BaseSerialNo, BaseDocRowNo,[ExpireDate],PhysicallyEffected)
			
		SELECT 90, @ProcessNo, @FiscalYear, @maxSerialNo+1 , ROW_NUMBER()OVER (ORDER BY r.DocRowNo) RowNo,ROW_NUMBER() OVER (ORDER BY r.DocRowNo) DocRowNo, 
				   1, @DocDate,  @StoreID, -1,  @AcntCode, r.SimilarGoodsID,r.UnitID SubUnitID,r.SimilarQty  SubUnitQuantity,
				   r.SimilarQty GoodsQuantity,r.SimilarQty GoodsAmount,r.SalePrice GoodsPrice,
				   @ProcessID BaseProcessID,@ProcessNo BaseProcessNo,@FiscalYear
				    BaseFiscalYear,@SerialNo BaseSerialNo,
				   r.DocRowNo BaseDocRowNo,r.ExpDate,1 PhysicallyEffected
			
		FROM 
			(SELECT D.* FROM phr.tblReciptionDtl D
			 INNER JOIN inv.tblGoods G
			 ON D.GoodsID=G.GoodsID
			  WHERE D.ProcessID=@ProcessID AND D.ProcessNo=@ProcessNo
			 AND D.FiscalYear=@FiscalYear AND D.SerialNo=@SerialNo
			 AND G.IsNotInventoryCountDrug='False'    
			)r
		
		Update phr.tblReciptionHdr Set Deleted = 0
        Where SerialNo = @SerialNo
        And FiscalYear = @FiscalYear
        
        
        IF @PayablePrice>0
        BEGIN
        	Update phr.tblReciptionHdr Set PayablePrice =@PayablePrice
			Where SerialNo = @SerialNo
			And FiscalYear = @FiscalYear
        END


END -- end if (isnew=true)
		
IF @IsNew='False'
	BEGIN
		
		-- inv.tblStorageDocsDtl حذف اطلاعات از --------
		DELETE FROM inv.tblStorageDocsDtl
                 WHERE ProcessID=90 AND ProcessNo =@ProcessNo
                 AND SerialNo=@OldSerialNo 
                 AND BaseProcessID=@ProcessID
                 AND BaseProcessNo=@ProcessNo 
                 AND BaseFiscalYear=@FiscalYear
                 AND BaseSerialNo=@SerialNo
		-- --------------------------------------------
		
		 INSERT INTO inv.tblStorageDocsDtl
			(ProcessID, ProcessNo,FiscalYear,SerialNo, RowNo, DocRowNo, DocStep,
			DocDate, StoreID, EnterKind, AcntCode, GoodsID, SubUnitID, SubUnitQuantity,
			GoodsQuantity, GoodsAmount, GoodsPrice, BaseProcessID, BaseProcessNo,
			BaseFiscalYear, BaseSerialNo, BaseDocRowNo,[ExpireDate],PhysicallyEffected)
			
		SELECT 90, @ProcessNo, @FiscalYear, @OldSerialNo , ROW_NUMBER()OVER (ORDER BY r.DocRowNo) RowNo,ROW_NUMBER() OVER (ORDER BY r.DocRowNo) DocRowNo, 
				   1, @DocDate,  @StoreID, -1,  @AcntCode, r.SimilarGoodsID,r.UnitID SubUnitID,r.SimilarQty  SubUnitQuantity,
				   r.SimilarQty GoodsQuantity,r.SimilarQty GoodsAmount,r.SalePrice GoodsPrice,
				   @ProcessID BaseProcessID,@ProcessNo BaseProcessNo,@FiscalYear BaseFiscalYear
				   ,@SerialNo BaseSerialNo,
				   r.DocRowNo BaseDocRowNo,r.ExpDate,1 PhysicallyEffected
				
		FROM 
			(SELECT D.* FROM phr.tblReciptionDtl D
			 INNER JOIN inv.tblGoods G
			 ON D.GoodsID=G.GoodsID
			 WHERE D.ProcessID=@ProcessID AND D.ProcessNo=@ProcessNo
			 AND D.FiscalYear=@FiscalYear AND D.SerialNo=@SerialNo
			 AND G.IsNotInventoryCountDrug='False'  
			)r
			
			
			-- آپديت کردن فيلد ارسال به سازمان
			UPDATE 	inv.tblStorageDocsHdr
			SET IsSendInfo='False'
			WHERE BaseProcessID=@ProcessID
			AND BaseFiscalYear=@FiscalYear
			AND BaseProcessNo=@ProcessNo
			AND BaseSerialNo=@SerialNo
			
								
END --end if (isnew=false)
				
						
--############################################################################
 
 COMMIT TRAN

 END TRY
 
 BEGIN CATCH
	
	ROLLBACK TRAN

	Declare @StrErrorMessage As Nvarchar(1024)
	Set @StrErrorMessage = ERROR_MESSAGE() 
	raiserror (@StrErrorMessage,16,1)

 END CATCH

END
GO
