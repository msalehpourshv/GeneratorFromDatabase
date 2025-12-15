USE TS_ShirinVatanKarkhaneh_1_1404
GO
SET ANSI_NULLS, QUOTED_IDENTIFIER ON
GO
-- =========== TS-QC:NOTOK ========================
-- Author        : Alian Pour
-- Create date   : 1400/11/06
-- Viewed By	 : 
-- Last Modified : 
-- Description   : 
-- =============================================
create PROCEDURE inv.sp_api_AppService_TransferFromWerehouseToWerehouseHdr
@StoreID as int,
@StoreID2 as int,
@ProcessNo as int,
@FiscalYear as int,
@DocDate as NVARCHAR(50),
@DocStep AS INT 

WITH ENCRYPTION
 AS
BEGIN
	DECLARE @StrErrorMessage NVARCHAR(MAX)
	DECLARE @maxSerialNo AS INT
BEGIN TRY
	
	SELECT @maxSerialNo = isnull(MAX(SerialNo),0)
	FROM inv.tblStorageDocsHdr 
	WHERE ProcessID=120
	AND ProcessNo=@ProcessNo
	AND FiscalYear=@FiscalYear
			 
	SET @maxSerialNo = @maxSerialNo +1


	INSERT INTO inv.tblStorageDocsHdr
		(ProcessID, ProcessNo, FiscalYear, SerialNo, DocStep, DocDate,	StoreID, StoreID2,
		DocDesc)
	
		SELECT 120, @ProcessNo, @FiscalYear, @maxSerialNo, @DocStep, @DocDate, @StoreID, @StoreID2, 
		'Api'
		
	SELECT  CAST(1 AS INT )AS Success,@maxSerialNo as SerialNo
	
END TRY
BEGIN CATCH


	Set @StrErrorMessage = ERROR_MESSAGE() 
	raiserror (@StrErrorMessage, 16, 1)

END CATCH

END	
GO
