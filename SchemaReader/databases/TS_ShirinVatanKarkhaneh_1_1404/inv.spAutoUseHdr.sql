USE TS_ShirinVatanKarkhaneh_1_1404
GO
SET ANSI_NULLS, QUOTED_IDENTIFIER ON
GO
-- =========== TS-QC:NOTOK ========================
-- Author        : Hadi Sadeghi
-- Create date   : 1400/01/24
-- Viewed By	 : 
-- Last Modified : 
-- Description   : 
-- =============================================
Create PROCEDURE [inv].[spAutoUseHdr]
@ProcessNo as Int,
@FiscalYear as SMALLINT,
@DocStep as tinyint,
@DocDate as CHAR(10),
@StoreID AS VARCHAR(20),
@DocDesc as NVARCHAR(500)

WITH ENCRYPTION
 AS
BEGIN

	Declare @StrErrorMessage As Nvarchar(1024)
BEGIN TRY

	DECLARE @maxSerialNo INT

	IF (SELECT Count(*) FROM inv.tblStores
		where StoreID=@StoreID )=0
	BEGIN
		Set @StrErrorMessage = N'�� ����� ������� ���'
		raiserror (@StrErrorMessage, 16, 1)
	END	
	
	SELECT @maxSerialNo = isnull(MAX(SerialNo),0)
	FROM inv.tblStorageDocsHdr 
	WHERE ProcessID=110
	  AND ProcessNo=@ProcessNo
	  AND FiscalYear=@FiscalYear
			 
	SET @maxSerialNo = @maxSerialNo +1

	INSERT INTO inv.tblStorageDocsHdr
	(ProcessID, ProcessNo, FiscalYear, SerialNo, DocStep, DocDate,	StoreID, DocDesc,DocDate2, IsAutoDoc)
	
	SELECT 110, @ProcessNo, @FiscalYear, @maxSerialNo, @DocStep, @DocDate, @StoreID,@DocDesc,@DocDate DocDate2,'True' IsAutoDoc

         	-----------------

	SELECT @maxSerialNo SerialNo
END TRY
BEGIN CATCH


	Set @StrErrorMessage = ERROR_MESSAGE() 
	raiserror (@StrErrorMessage, 16, 1)

END CATCH

END	
GO
