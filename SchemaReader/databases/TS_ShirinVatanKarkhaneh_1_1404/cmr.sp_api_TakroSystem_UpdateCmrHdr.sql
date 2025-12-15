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
Create PROCEDURE [cmr].[sp_api_TakroSystem_UpdateCmrHdr]
@ProcessNo as Int,
@FiscalYear as Int,
@SerialNo as int,
@DocStep as tinyint,
@DocDate as CHAR(10),
@AcntCode AS VARCHAR(20),
@DocDesc as NVARCHAR(500),
@SessionNo as int,
@TransferSerialNo as nvarchar(50)

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
	update cmr.tblCMRHdr
	set DocDate=@DocDate, AcntCode=@AcntCode,DocDesc=@DocDesc,SessionNo=@SessionNo,TransferSerialNo=@TransferSerialNo
	where 
	 ProcessID=150 and ProcessNo=@ProcessNo and  FiscalYear=@FiscalYear and SerialNo=@SerialNo 

         	-----------------

	SELECT @SerialNo SerialNo,'0'  as StoreID

END TRY
BEGIN CATCH


	Set @StrErrorMessage = ERROR_MESSAGE() 
	raiserror (@StrErrorMessage, 16, 1)

END CATCH

END	
GO
