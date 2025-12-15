USE TS_ShirinVatanKarkhaneh_1_1404
GO
SET ANSI_NULLS, QUOTED_IDENTIFIER ON
GO
-- =========== TS-QC:NOTOK ========================
-- Author        :Elaheh AlianPour
-- Create date   : 1401/06/16
-- Viewed By	 : 
-- Last Modified : 
-- Description   : 
-- =============================================
CREATE  PROCEDURE prd.sp_api_AsmanRasa_IsCreateSendProduction

@TechnicalNo As Nvarchar(50),
@StoreId As varchar(50),
@GoodsQuantity As float,
@StateID as int ,
@OrderId as nvarchar(100)

WITH ENCRYPTION
 AS
BEGIN

DECLARE @StrErrorMessage As Nvarchar(1024)
DECLARE @ProductId As varchar(100)
DECLARE @GoodsClassificationID As Nvarchar(100)
DECLARE @HasBatchNo AS BIT
DECLARE @QtyQuantity AS float

BEGIN TRY

	SELECT @ProductId=ISNULL(GoodsID,'0'),@GoodsClassificationID =GoodsClassificationID ,@HasBatchNo=HasBatchNo FROM inv.tblGoods 
	WHERE TechnicalNo=@TechnicalNo 

	IF(@ProductId='0')
	BEGIN

		Set @StrErrorMessage = N'کد فنی  '+@TechnicalNo+'  تعریف نشده است'
		raiserror (@StrErrorMessage, 16, 1)
	END

	if(SELECT count(*) FROM inv.tblStorageDocsHdr
	   WHERE  
	   ProductID=@ProductId And
	   ProcessID=70 and pub.funSplitString (TransferSerialNo,'_' ,1)=@OrderId)>0 --and 
	   --pub.funSplitString (TransferSerialNo,'_' ,3)=@StateID )>0 
	BEGIN
		SELECT 0 AS IsCreateProduction
	end

	ELSE
	BEGIN

		IF(@HasBatchNo='FALSE')
		BEGIN
	
			SELECT @QtyQuantity=Sum(GoodsQuantity*EnterKind ) FROM inv.tblStorageDocsDtl
			WHERE GoodsID=@ProductId and StoreID=@StoreId

			IF(@GoodsQuantity<@QtyQuantity)
				SELECT 0 AS IsCreateProduction
			ELSE
				SELECT 1 AS IsCreateProduction
		END 
	
		ELSE
			SELECT 1 AS IsCreateProduction
	END
END TRY
BEGIN CATCH

	Set @StrErrorMessage = ERROR_MESSAGE() 
	raiserror (@StrErrorMessage, 16, 1)

END CATCH

END	

GO
