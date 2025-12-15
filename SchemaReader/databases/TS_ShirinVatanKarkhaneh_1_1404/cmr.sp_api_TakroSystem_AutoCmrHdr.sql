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
Create PROCEDURE [cmr].[sp_api_TakroSystem_AutoCmrHdr]
@ProcessNo as Int,
@FiscalYear as Int,
@DocStep as tinyint,
@DocDate as CHAR(10),
@AcntCode AS VARCHAR(20),
@DocDesc as NVARCHAR(500),
@SessionNo as int,
@TransferSerialNo as nvarchar(50)

WITH ENCRYPTION
 AS
BEGIN
	DECLARE @maxSerialNo INT
	Declare @StrErrorMessage As Nvarchar(1024)
BEGIN TRY

	IF @AcntCode=''
	BEGIN
		Set @StrErrorMessage = N'کد مشتری را پر کنید'
		raiserror (@StrErrorMessage, 16, 1)
	END
	


	SELECT @maxSerialNo = isnull(MAX(SerialNo),0)
	FROM cmr.tblCMRHdr
	WHERE ProcessID=150
	  AND ProcessNo=@ProcessNo
	  AND FiscalYear=@FiscalYear
			 
	SET @maxSerialNo = @maxSerialNo +1

	INSERT INTO cmr.tblCMRHdr
	(AutoOrder,ProcessID, ProcessNo, FiscalYear, SerialNo, DocStep, DocDate, AcntCode,DocDesc,SessionNo,TransferSerialNo)
	
	SELECT 'True',150, @ProcessNo, @FiscalYear, @maxSerialNo, @DocStep, @DocDate, @AcntCode,@DocDesc,@SessionNo,@TransferSerialNo

         	-----------------

	SELECT 150 ProcessID ,@ProcessNo ProcessNo, @FiscalYear FiscalYear,@DocDate DocDate, @maxSerialNo SerialNo,@AcntCode AcntCode,'0' as StoreID

END TRY
BEGIN CATCH


	Set @StrErrorMessage = ERROR_MESSAGE() 
	raiserror (@StrErrorMessage, 16, 1)

END CATCH

END	
GO
