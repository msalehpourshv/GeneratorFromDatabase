USE TS_ShirinVatanKarkhaneh_1_1404
GO
SET ANSI_NULLS, QUOTED_IDENTIFIER ON
GO
-- =========== TS-QC:NOTOK ========================
-- Author        : mr.moayed
-- Create date   : 1403/09/11
-- Viewed By	 : 
-- Last Modified : 
-- Description   : 
-- =============================================
CREATE PROCEDURE inv.sp_api_TakroSystem_CreateOrUpdateOrDeleteStoresNumerationDtl

@SerialNo as Int,
@DocDate as CHAR(10),
@StoreID AS VARCHAR(20),
@GoodsID AS VARCHAR(20),
@DescDtl as NVARCHAR(500),
@DocRowNo as Int,
@SubUnitID as varchar(20),
@GoodsQuantity as FLOAT,
@SubUnitQuantity as FLOAT

WITH ENCRYPTION
 AS
BEGIN

Declare @StrErrorMessage As Nvarchar(1024)
Declare @MaxDocRowNo as Int

BEGIN TRY

	IF (SELECT Count(*) FROM inv.tblGoods
		where GoodsID=@GoodsID )<>1
	BEGIN
		Set @StrErrorMessage = N'کد کالا صحيح نيست'
		raiserror (@StrErrorMessage, 16, 1)
	END	
	
	if(@DocRowNo>0)
		
		BEGIN
			-- Update:
			if(@SubUnitQuantity>0)
						
				BEGIN

					print 'update'
					update [inv].[tblStoresNumerationDtl]
					set  StoreID=@StoreID,
					GoodsID=@GoodsID, SubUnitQuantity=@SubUnitQuantity,GoodsQuantity=@GoodsQuantity,DescDtl=@DescDtl
					where
					SerialNo=@SerialNo and DocRowNo=@DocRowNo

					Select 'Update' As ActionName,@DocRowNo

				END

			ELSE if @GoodsQuantity=0

			--Delete
			BEGIN

				print 'DELETE [tblStoresNumerationDtl]'
				DELETE FROM  [inv].[tblStoresNumerationDtl]
				where DocRowNo=@MaxDocRowNo AND 
					  SerialNo=@SerialNo

				Select 'Delete' As ActionName,@DocRowNo

			END
		END

	ELSE
		--Insert
		BEGIN

	 		print 'INSERT [tblStoresNumerationDtl]'
			SELECT @MaxDocRowNo = isnull(MAX(DocRowNo),0)
			FROM [inv].[tblStoresNumerationDtl]
			WHERE SerialNo=@SerialNo
			 
			SET @MaxDocRowNo = @MaxDocRowNo + 1

			INSERT INTO [inv].[tblStoresNumerationDtl]
					   ([SerialNo],[RowNo],[DocDate],[StoreID],[GoodsID],[DescDtl],[DocRowNo],[SubUnitID],[GoodsQuantity],[SubUnitQuantity])
				 VALUES
					   ( @SerialNo,@MaxDocRowNo,@DocDate,@StoreID,@GoodsID,@DescDtl,@MaxDocRowNo,@SubUnitID,@GoodsQuantity,@SubUnitQuantity)
           
			Select 'Create' As ActionName,@MaxDocRowNo

		END	
    
END TRY
BEGIN CATCH

	Set @StrErrorMessage = ERROR_MESSAGE() 
	raiserror (@StrErrorMessage, 16, 1)

END CATCH

END	

GO
