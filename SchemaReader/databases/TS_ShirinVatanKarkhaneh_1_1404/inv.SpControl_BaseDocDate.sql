USE TS_ShirinVatanKarkhaneh_1_1404
GO
SET ANSI_NULLS, QUOTED_IDENTIFIER ON
GO
-- =========== TS-QC:NotOK ========================
-- Author        : Hadi Sadeghi
-- Create date   : 91/07/10
-- Viewed By	 : 
-- Last Modified : 
-- Description   : 
-- =============================================
CREATE PROCEDURE [inv].[SpControl_BaseDocDate]
	@ProcessID	smallint,
	@ProcessNo	tinyint,
	@FiscalYear	smallint,
	@SerialNo	int
	
WITH ENCRYPTION
AS

BEGIN
	DECLARE @DocDate CHAR(10)
	SET @DocDate = ''	
		
	SELECT @DocDate = DocDate FROM inv.tblStorageDocsHdr 
	WHERE ProcessID = @ProcessID AND
		  ProcessNo = @ProcessNo AND
		  FiscalYear = @FiscalYear AND
		  SerialNo=@SerialNo
		
	SELECT @DocDate DocDate
	
END
GO
