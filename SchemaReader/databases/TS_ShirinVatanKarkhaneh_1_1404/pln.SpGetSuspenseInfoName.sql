USE TS_ShirinVatanKarkhaneh_1_1404
GO
SET ANSI_NULLS, QUOTED_IDENTIFIER ON
GO
-- =========== TS-QC:UPDATED ====================
-- Author		 : Mostafavi
-- Create date   : 1404/07/03
-- Viewed By	 : 
-- Last Modified : 
-- Description	 : 
-- =============================================
Create PROCEDURE [pln].[SpGetSuspenseInfoName]
	@SuspensionID NVarChar(20),
	@SuspensionDescID NVarChar(20),
	@UnitSectionID NVarChar(20),
	@MachineryEquipmentID NVarChar(20),
	@dbName000 NVarChar(500),
	@LanguageID TinyInt
WITH ENCRYPTION
AS

BEGIN
SET NOCOUNT ON;

	DECLARE @strSelect as NVarChar(2000) = ''
	DECLARE @strParams as NVarChar(500) = ''
	DECLARE @SuspensionName as NVarChar(Max) = ''
	DECLARE @SuspensionDescName as NVarChar(Max) = ''
	DECLARE @UnitSectionName as NVarChar(Max) = ''
	DECLARE @MachineryEquipmentName as NVarChar(Max) = ''

	CREATE TABLE #SuspenseInfoName (
		SuspensionName NVarChar(Max),
		SuspensionDescName NVarChar(Max),
		UnitSectionName NVarChar(Max),
		MachineryEquipmentName NVarChar(Max)
	)
	
	INSERT INTO #SuspenseInfoName DEFAULT VALUES;

	SET @strSelect = ''
	SET @strParams = ''

	SET @strSelect = N'
		SELECT @SuspensionName = ISNULL(SuspensionName,'''')
		FROM pln.tblSuspensionsDtl 
		WHERE SuspensionID = @SuspensionID 
		  AND LanguageID = @LanguageID';
	SET @strParams = N'@SuspensionName NVarChar(MAX) OUTPUT, @SuspensionID NVarChar(20), @LanguageID INT';
	EXEC sp_executesql @strSelect, @strParams, @SuspensionName = @SuspensionName OUTPUT, @SuspensionID = @SuspensionID, @LanguageID = @LanguageID;
	
	UPDATE #SuspenseInfoName 
	   SET SuspensionName = ISNULL(@SuspensionName,'')

	SET @strSelect = ''
	SET @strParams = ''

	SET @strSelect = N'
		SELECT @SuspensionDescName = ISNULL(SuspensionDescName,'''')
		FROM pln.tblSuspensionsDescDtl 
		WHERE SuspensionDescID = @SuspensionDescID 
		  AND LanguageID = @LanguageID';
	SET @strParams = N'@SuspensionDescName NVarChar(MAX) OUTPUT, @SuspensionDescID NVarChar(20), @LanguageID INT';
	EXEC sp_executesql @strSelect, @strParams, @SuspensionDescName = @SuspensionDescName OUTPUT, @SuspensionDescID = @SuspensionDescID, @LanguageID = @LanguageID;
	
	UPDATE #SuspenseInfoName 
	   SET SuspensionDescName = ISNULL(@SuspensionDescName,'')

	SET @strSelect = ''
	SET @strParams = ''

	SET @strSelect = N'
		SELECT @UnitSectionName = ISNULL(UnitSectionName,'''')
		FROM pln.tblUnitSectionsDtl 
		WHERE UnitSectionID = @UnitSectionID 
		  AND LanguageID = @LanguageID';
	SET @strParams = N'@UnitSectionName NVarChar(MAX) OUTPUT, @UnitSectionID NVarChar(20), @LanguageID INT';
	EXEC sp_executesql @strSelect, @strParams, @UnitSectionName = @UnitSectionName OUTPUT, @UnitSectionID = @UnitSectionID, @LanguageID = @LanguageID;
	
	UPDATE #SuspenseInfoName 
	   SET UnitSectionName = ISNULL(@UnitSectionName,'')

	SET @strSelect = ''
	SET @strParams = ''

	SET @strSelect = N'
		SELECT @MachineryEquipmentName = ISNULL(MachineryEquipmentName,'''')
		FROM ' + @dbName000 + '.tpm.tblMachineryEquipmentDtl
		WHERE MachineryEquipmentID = @MachineryEquipmentID 
		  AND LanguageID = @LanguageID';
	SET @strParams = N'@MachineryEquipmentName NVarChar(MAX) OUTPUT, @MachineryEquipmentID NVarChar(20), @LanguageID INT';
	EXEC sp_executesql @strSelect, @strParams, @MachineryEquipmentName = @MachineryEquipmentName OUTPUT, @MachineryEquipmentID = @MachineryEquipmentID, @LanguageID = @LanguageID;
	
	UPDATE #SuspenseInfoName 
	   SET MachineryEquipmentName = ISNULL(@MachineryEquipmentName,'')

	SELECT * FROM #SuspenseInfoName

END
GO
