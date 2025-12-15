USE TS_ShirinVatanKarkhaneh_1_1404
GO
SET ANSI_NULLS, QUOTED_IDENTIFIER ON
GO
-- =========== TS-QC:NOTOK ========================
-- Author        : mr.moayed
-- Create date   : 1403/06/06
-- Viewed By	 : 
-- Last Modified : 
-- Description   : 
-- =============================================
CREATE PROCEDURE [inv].[sp_api_TakroSystem_CreateOrUpdateOrDeleteStoreRequestsDtl]
@ProcessNo as tinyint,
@FiscalYear as SMALLINT,
@SerialNo as Int,
@DocRowNo as Int,
@GoodsID AS VARCHAR(20),
@GoodsQuantity as FLOAT,
@SubUnitQuantity as FLOAT,
@SubUnitID as varchar(20),
@DocDesc as NVARCHAR(500),
@DocDate as CHAR(10),
@VisitorAcntCode as VARCHAR(20),
@StoreID2  As Nvarchar(20),
@StoreID AS VARCHAR(20)

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
					update inv.tblStoresRequestsDtl
					set  StoreID=@StoreID,StoreID2=@StoreID2,
					GoodsID=@GoodsID, SubUnitQuantity=@SubUnitQuantity,GoodsQuantity=@GoodsQuantity,DescDtl=@DocDesc
					where
					ProcessID=127 and ProcessNo=@ProcessNo and  FiscalYear=@FiscalYear and SerialNo=@SerialNo and DocRowNo=@DocRowNo

					Select 'Update' As ActionName,@DocRowNo

				END

			ELSE if @GoodsQuantity=0

			--Delete
			BEGIN

				print 'DELETE tblStoresRequestsDtl'
				DELETE FROM  inv.tblStoresRequestsDtl
				where DocRowNo=@DocRowNo AND 
					  ProcessID=127 AND 
					  ProcessNo=@ProcessNo AND 
					  FiscalYear=@FiscalYear AND 
					  SerialNo=@SerialNo

				Select 'Delete' As ActionName,@DocRowNo

			END
		END

	ELSE
		--Insert
		BEGIN

	 		print 'INSERT tblStoresRequestsDtl'
			SELECT @MaxDocRowNo = isnull(MAX(DocRowNo),0)
			FROM inv.tblStoresRequestsDtl
			WHERE ProcessID=127
			 AND ProcessNo=@ProcessNo
			 AND FiscalYear=@FiscalYear
			 AND SerialNo=@SerialNo
			 
			SET @MaxDocRowNo = @MaxDocRowNo + 1

			INSERT INTO inv.tblStoresRequestsDtl
				(ProcessID,ProcessNo,FiscalYear,SerialNo,RowNo,DocRowNo,DocDate,StoreID,StoreID2,
				GoodsID,SubUnitID,GoodsQuantity,DescDtl,SubUnitQuantity,VisitorAcntCode,DocStep)
			Values(127, @ProcessNo, @FiscalYear, @SerialNo, @MaxDocRowNo , @MaxDocRowNo , @DocDate, @StoreID, @StoreID2,
				@GoodsID, @SubUnitID, @GoodsQuantity, @DocDesc,@SubUnitQuantity,@VisitorAcntCode,1)

			Select 'Create' As ActionName,@MaxDocRowNo

		END	
    
END TRY
BEGIN CATCH

	Set @StrErrorMessage = ERROR_MESSAGE() 
	raiserror (@StrErrorMessage, 16, 1)

END CATCH

END	

GO
