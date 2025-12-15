USE TS_ShirinVatanKarkhaneh_1_1404
GO
SET ANSI_NULLS, QUOTED_IDENTIFIER ON
GO
-- =========== TS-QC:NOTOK ========================
-- Author        : Alian Pour
-- Create date   : 1400/08/28
-- Viewed By	 : 
-- Last Modified : 
-- Description   : 
-- =============================================
CREATE PROCEDURE pub.sp_api_TakroSystem_GetErrors
@ProcessId as int,
@ProcessNo as int,
@SerialNo as int,
@FiscalYear as int


WITH ENCRYPTION
 AS
BEGIN
	DECLARE @StrErrorMessage NVARCHAR(MAX)
	DECLARE @MaxDate DATETIME
BEGIN TRY
	
	SELECT @MaxDate=MAX(SendDateTime) FROM pub.tblTPErrors
	WHERE ProcessID=@ProcessId AND ProcessNo=@ProcessNo AND SerialNo=@SerialNo AND FiscalYear=@FiscalYear

	SELECT * FROM pub.tblTPErrors
	WHERE  ProcessID=@ProcessId AND ProcessNo=@ProcessNo AND
	SerialNo=@SerialNo AND FiscalYear=@FiscalYear AND SendDateTime=@MaxDate
	order by SendDateTime

END TRY
BEGIN CATCH


	Set @StrErrorMessage = ERROR_MESSAGE() 
	raiserror (@StrErrorMessage, 16, 1)

END CATCH

END	
GO
