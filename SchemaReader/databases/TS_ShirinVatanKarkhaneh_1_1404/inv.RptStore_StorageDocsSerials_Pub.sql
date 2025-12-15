USE TS_ShirinVatanKarkhaneh_1_1404
GO
SET ANSI_NULLS, QUOTED_IDENTIFIER ON
GO
-- =========== TS-QC:UPDATED ====================
-- Author		 : TakroSystem/Mahdi Mostafavi	
-- Create date   : 1403/07/26
-- Viewed By	 : 
-- Last Modified : 
-- Last Modifier : 
-- Description   : 
-- =============================================
Create PROCEDURE [inv].[RptStore_StorageDocsSerials_Pub]
	@ProcessID			Int = 90,  -- Default Is Sale
	@ProcessNo			Int = 1,
	@FiscalYear			Int = 93,
	@SerialNo			Int = 1,
	@DocRowNo			Int = 1
WITH ENCRYPTION
AS 
DECLARE @LanguageID TinyInt;
DECLARE @StrSelect	NVarChar(Max);
DECLARE @HasSerial  Bit;

DECLARE @Count		Int;

Begin --============== S T A R T  C O D E ===================================================

	SET @LanguageID = pub.funGetCurrentLanguageID();

	Set @StrSelect = ''

	Set NoCount On;

	-- I N I T ----------------------------------------------------------------
	IF (@LanguageID Is Null)	SET @LanguageID = 1
	
	-- W H E R E --------------------------------------------------------------
		
	-- =============================================================
	SELECT @Count = COUNT(*)
	FROM inv.tblStorageDocsSerials SS
	LEFT JOIN pln.tblProductSerials P ON P.ProductSerialID = SS.ProductSerialID
	WHERE SS.ProcessID = @ProcessID AND 
		  SS.ProcessNo = @ProcessNo AND 
		  SS.FiscalYear = @FiscalYear AND 
		  SS.SerialNo = @SerialNo AND
		  SS.DocRowNo = @DocRowNo AND
		  (SS.ContainerID <> '' Or
		  SS.ContainerStoresID <> '')
		  

	IF 	@Count > 0	  	
		Set @StrSelect = '
			SELECT SS.ProcessID, 
				   SS.ProcessNo, 
				   SS.FiscalYear, 
				   SS.SerialNo, 
				   ISNULL(P.ProductID,'''') As GoodsID,
				   ISNULL(SS.ProductSerialID, 0) ProductSerialID, 
				   ISNULL(SS.ExpireDate,'''') ExpireDate, 
				   ISNULL(SS.ContainerID,'''') ContainerID,
				   inv.funGetContainerName(SS.ContainerID,' + LTRIM(RTrim(@LanguageID)) + ') ContainerName, 
				   ISNULL(SS.ContainerID2,'''') ContainerID2,
				   inv.funGetContainerName(SS.ContainerID2,' + LTRIM(RTrim(@LanguageID)) + ') ContainerName2, 
				   ISNULL(SS.ContainerStoresID,'''') ContainerStoresID, 
				   [inv].[funGetContainerStoresName](SS.ContainerStoresID,' + LTRIM(RTrim(@LanguageID)) + ') ContainerStoresName,
				   ISNULL(SS.ContainerStoresID2,'''') ContainerStoresID2, 
				   [inv].[funGetContainerStoresName](SS.ContainerStoresID2,' + LTRIM(RTrim(@LanguageID)) + ') ContainerStoresName2,
				   ISNULL([pub].[funChangeDate_PersianToGergorian](SS.ExpireDate),'''') As GExpireDate, 
				   ISNULL(P.SerialPrefix,''0'') SerialPrefix, 
				   ISNULL(Cast(SS.PSerialNo As NVarchar(50)),'''') ProductSerialNo,
				   SS.NumberPerContainer,
				   SS.StoreID,
				   SS.SubUnitNumberPerContainer,
				   SS.ProductionDate,
				   ISNULL([pub].[funChangeDate_PersianToGergorian](SS.ProductionDate),'''') As GProductionDate
			FROM inv.tblStorageDocsSerials SS
			LEFT JOIN pln.tblProductSerials P ON P.ProductSerialID = SS.ProductSerialID
			WHERE SS.ProcessID  = ' + LTrim(RTrim(Str(@ProcessID))) + ' And 
				  SS.ProcessNo = ' + LTrim(RTrim(Str(@ProcessNo))) + ' And 
				  SS.FiscalYear = ' + LTrim(RTrim(Str(@FiscalYear))) + ' And 
				  SS.SerialNo = ' + LTrim(RTrim(Str(@SerialNo))) + ' And 
				  SS.DocRowNo   = ' + LTrim(RTrim(Str(@DocRowNo)))
	Else
		Set @StrSelect = '
			SELECT 0 ProcessID, 
				   0 ProcessNo, 
				   0 FiscalYear, 
				   0 SerialNo, 
				   Cast('''' As NVarchar(20)) As GoodsID,
				   Cast('''' As NVarchar(20)) ProductSerialID, 
				   Cast('''' As NVarchar(10)) ExpireDate, 
				   Cast('''' As NVarchar(20)) ContainerID,
				   Cast('''' As NVarchar(50)) ContainerName, 
				   Cast('''' As NVarchar(20)) ContainerID2,
				   Cast('''' As NVarchar(50)) ContainerName2, 
				   Cast('''' As NVarchar(20)) ContainerStoresID, 
				   Cast('''' As NVarchar(50)) ContainerStoresName,
				   Cast('''' As NVarchar(20)) ContainerStoresID2, 
				   Cast('''' As NVarchar(50)) ContainerStoresName2,
				   Cast('''' As NVarchar(10)) As GExpireDate, 
				   ''0'' SerialPrefix, 
				   Cast('''' As NVarchar(50)) ProductSerialNo,
				   0 NumberPerContainer,
				   Cast('''' As NVarchar(20)) StoreID,
				   0 SubUnitNumberPerContainer,
				   Cast('''' As NVarchar(10)) ProductionDate,
				   Cast('''' As NVarchar(10)) GProductionDate
			FROM inv.tblStorageDocsSerials SS
			WHERE SS.ProcessID  = ' + LTrim(RTrim(Str(@ProcessID))) + ' And 
				  SS.ProcessNo = ' + LTrim(RTrim(Str(@ProcessNo))) + ' And 
				  SS.FiscalYear = ' + LTrim(RTrim(Str(@FiscalYear))) + ' And 
				  SS.SerialNo = ' + LTrim(RTrim(Str(@SerialNo))) + ' And 
				  SS.DocRowNo   = ' + LTrim(RTrim(Str(@DocRowNo)))
			  
	-- =============================================================
	Print @StrSelect;
	Exec sp_executesql @StrSelect;
				  
END
GO
