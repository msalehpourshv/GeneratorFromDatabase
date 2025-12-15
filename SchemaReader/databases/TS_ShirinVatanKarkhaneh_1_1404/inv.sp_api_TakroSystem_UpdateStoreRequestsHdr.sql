USE TS_ShirinVatanKarkhaneh_1_1404
GO
SET ANSI_NULLS, QUOTED_IDENTIFIER ON
GO
-- =========== TS-QC:NOTOK ========================
-- Author        : Alian Pour
-- Create date   : 1400/08/30
-- Viewed By	 : 
-- Last Modified : 
-- Description   : 
-- =============================================
Create PROCEDURE [inv].[sp_api_TakroSystem_UpdateStoreRequestsHdr]
@ProcessNo as Int,
@FiscalYear as Int,
@SerialNo as int,
@DocStep as tinyint,
@DocDate as CHAR(10),
@AcntCode AS VARCHAR(20),
@DocDesc as NVARCHAR(500),
@SessionNo as int,
@TransferSerialNo as nvarchar(50),
@StoreID  as NVARCHAR(500),
@StoreID2  as NVARCHAR(500)

WITH ENCRYPTION
 AS
BEGIN

	Declare @StrErrorMessage As Nvarchar(1024)
	DECLARE @IsNoEdit AS bit

BEGIN TRY

	--VALIDATIONS
	IF @AcntCode=''
	BEGIN
		Set @StrErrorMessage = N'کد مشتری را پر کنید'
		raiserror (@StrErrorMessage, 16, 1)
	END

			
	
	
	--UPDATE
	update inv.tblStoresRequestsHdr
	set DocDate=@DocDate,StoreID=@StoreID, AcntCode=@AcntCode,DocDesc=@DocDesc,SessionNo=@SessionNo,TransferSerialNo=@TransferSerialNo,StoreID2=@StoreID2
	where 
	 ProcessID=127 and ProcessNo=@ProcessNo and  FiscalYear=@FiscalYear and SerialNo=@SerialNo 

         	-----------------

	SELECT @SerialNo SerialNo,@StoreID StoreID

END TRY
BEGIN CATCH


	Set @StrErrorMessage = ERROR_MESSAGE() 
	raiserror (@StrErrorMessage, 16, 1)

END CATCH

END	
GO
