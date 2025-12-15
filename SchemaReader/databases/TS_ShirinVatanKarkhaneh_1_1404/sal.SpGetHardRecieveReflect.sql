USE TS_ShirinVatanKarkhaneh_1_1404
GO
SET ANSI_NULLS, QUOTED_IDENTIFIER ON
GO
-- =========== TS-QC:UPDATED ====================
-- Author		 : TakroSystem\Alireza
-- Create Date   : 1388/04/30
-- Viewed By	 : 
-- Last Modified : 
-- Last Modifier : 
-- Description	 : 
-- ==============================================
CREATE Procedure [sal].[SpGetHardRecieveReflect]
	@AcntCode	VARCHAR(20),
	@StartTargetLayer tinyint,
	@LenTargetLayer tinyint
WITH ENCRYPTION
AS
BEGIN
	DECLARE @StrTmpl	AS NVarChar(4000)
	DECLARE @StrSelect	AS NVarChar(4000)
	DECLARE @StrDB		AS NVarChar(100)
	DECLARE @StrPrevDB	AS NVarChar(100)
	Declare @ParmDefinition NVarChar(200)

	SET @ParmDefinition = N'@ResaultOUT Bit OUTPUT';
	
	DECLARE @StrResult bit
	SET @StrResult = 'True'
	PRINT @ParmDefinition
	
	SET @StrSelect = N'
		SELECT TOP 1 @ResaultOUT =''False'' 
		FROM [@DBNAME].[inv].[tblStorageDocsHdr]
		WHERE SUBSTRING(AcntCode,' + LTRIM(STR(@StartTargetLayer)) + ',' + LTRIM(STR(@LenTargetLayer)) + ') <> '''' AND  SUBSTRING(AcntCode,' + LTRIM(STR(@StartTargetLayer)) + ',' + LTRIM(STR(@LenTargetLayer)) + ')=SUBSTRING(''' + @AcntCode + ''',' + LTRIM(STR(@StartTargetLayer)) + ',' + LTRIM(STR(@LenTargetLayer)) + ') AND 
			  HardRecivable = ''True'' AND 
			  IsConfirmed = ''False'';' 
	
	SET @StrDB = db_name()
	SET @StrTmpl = @StrSelect

	SET @StrTmpl = Replace(@StrTmpl, '@DBNAME', @StrDB)
	
	Exec sp_executesql @StrTmpl,@ParmDefinition, @ResaultOUT = @StrResult OUTPUT;
	
	IF @StrResult = 'True'
		BEGIN
	
			Exec [pub].[SpGetPrevDBName] @StrDB, @StrPrevDB OUTPUT

			If (@StrPrevDB <> '') 
				BEGIN
					SET @StrTmpl = @StrSelect
					SET @StrTmpl =Replace(@StrTmpl, '@DBNAME', @StrPrevDB)
	
					Exec sp_executesql @StrTmpl,@ParmDefinition, @ResaultOUT = @StrResult OUTPUT;
				END
		End


	SELECT @StrResult
END

GO
