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
Create PROCEDURE [inv].[sp_api_TakroSystem_AutoStoreRequestsHdr]
@ProcessNo as Int,
@FiscalYear as Int,
@DocStep as tinyint,
@DocDate as CHAR(10),
@StoreID AS VARCHAR(20),
@AcntCode AS VARCHAR(20),
@DocDesc as NVARCHAR(500),
@SessionNo as int,
@TransferSerialNo as nvarchar(50),
@StoreID2 AS VARCHAR(20)

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
	
	IF (SELECT Count(*) FROM inv.tblStores
		where StoreID=@StoreID )=0
	BEGIN
		Set @StrErrorMessage = N'کد انبار نامعتبر است'
		raiserror (@StrErrorMessage, 16, 1)
	END	
	
	

	SELECT @maxSerialNo = isnull(MAX(SerialNo),0)
	FROM inv.tblStoresRequestsHdr
	WHERE ProcessID=127
	  AND ProcessNo=@ProcessNo
	  AND FiscalYear=@FiscalYear
			 
	SET @maxSerialNo = @maxSerialNo +1


	INSERT INTO inv.tblStoresRequestsHdr
	(AutoOrder,ProcessID, ProcessNo, FiscalYear, SerialNo, DocStep, DocDate,StoreID,StoreID2,AcntCode,DocDesc,SessionNo,TransferSerialNo)
	
	SELECT 'True',127, @ProcessNo, @FiscalYear, @maxSerialNo, @DocStep, @DocDate, @StoreID,@StoreID2, @AcntCode,@DocDesc,@SessionNo,@TransferSerialNo

         	-----------------

	SELECT 127 ProcessID ,@ProcessNo ProcessNo, @FiscalYear FiscalYear,@DocDate DocDate, @maxSerialNo SerialNo,@AcntCode AcntCode,@StoreID StoreID

END TRY
BEGIN CATCH


	Set @StrErrorMessage = ERROR_MESSAGE() 
	raiserror (@StrErrorMessage, 16, 1)

END CATCH

END	
GO
