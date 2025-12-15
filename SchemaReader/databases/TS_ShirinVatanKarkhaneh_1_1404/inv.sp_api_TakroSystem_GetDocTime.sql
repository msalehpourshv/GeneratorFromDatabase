USE TS_ShirinVatanKarkhaneh_1_1404
GO
SET ANSI_NULLS, QUOTED_IDENTIFIER ON
GO
-- =========== TS-QC:NOTOK ========================
-- Author        : Alian Pour
-- Create date   : 1402/02/19
-- Viewed By	 : 
-- Last Modified : 
-- Description   : 
-- =============================================
create PROCEDURE inv.sp_api_TakroSystem_GetDocTime
@ProcessId as int,
@ProcessNo as int,
@SerialNo as int,
@FiscalYear as int,
@TPEdited as int,
@TPCanceled as int

WITH ENCRYPTION
 AS
BEGIN
	DECLARE @StrErrorMessage NVARCHAR(MAX)
	DECLARE @DocTime AS NVARCHAR(50)=''
BEGIN TRY

	------------------------------------------------------------------   یافتن تایم مرجع برای برگشت از فروش از برگشت از فروش  -------------------------------------------------------------------	
	IF(@ProcessId=100)
	BEGIN
	IF(SELECT COUNT(*)
	   FROM inv.tblStorageDocsHdr SH
	   JOIN inv.tblStorageDocsHdr SD 
	   ON SH.BaseSerialNo=SD.BaseSerialNo AND SH.BaseFiscalYear=SD.BaseFiscalYear AND 
			SH.BaseProcessID=SD.BaseProcessID AND SH.BaseProcessNo=SD.BaseProcessNo
	   WHERE SD.TaxID<>'' AND SD.DocDate<=SH.DocDate AND SH.SerialNo=@SerialNo AND 
			 SH.ProcessID=@ProcessId AND SH.ProcessNo=@ProcessNo AND SH.FiscalYear=@FiscalYear and  SD.SerialNo<SH.SerialNo)>0
	   BEGIN
			SELECT TOP 1 @DocTime=SD.DocTime 
			FROM inv.tblStorageDocsHdr SH
			JOIN inv.tblStorageDocsHdr SD ON SH.BaseSerialNo=SD.BaseSerialNo AND SH.BaseFiscalYear=SD.BaseFiscalYear AND
				  SH.BaseProcessID=SD.BaseProcessID AND SH.BaseProcessNo=SD.BaseProcessNo
			WHERE SD.TaxID<>'' AND SD.DocDate <= SH.DocDate AND SH.SerialNo = @SerialNo AND 
				  SH.ProcessID = @ProcessId AND SH.ProcessNo = @ProcessNo AND SH.FiscalYear = @FiscalYear and SD.SerialNo < SH.SerialNo
			ORDER BY SD.SerialNo DESC
	   END
	--------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
	------------------------------------------------------------------   یافتن تایم مرجع برای برگشت از فروش از فروش  ---------------------------------------------------------------------------	

	   ELSE
	   BEGIN
			SELECT TOP 1 @DocTime=SH2.DocTime FROM inv.tblStorageDocsHdr SH
			JOIN inv.tblStorageDocsHdr SH2 
			ON SH.BaseSerialNo=SH2.SerialNo AND SH.BaseFiscalYear=SH2.FiscalYear AND SH.BaseProcessID=SH2.ProcessID AND SH.BaseProcessNo=SH2.ProcessNo
			WHERE SH2.TaxID<>'' AND SH2.DocDate<=SH.DocDate AND SH.SerialNo=@SerialNo AND SH.ProcessID=@ProcessId AND SH.ProcessNo=@ProcessNo AND SH.FiscalYear=@FiscalYear	   
	   END 	
	END
	--------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
	------------------------------------------------------------------    یافتن تایم مرجع برای  فروش اصلاحی یا ابطالی ---------------------------------------------------------------------------	

	IF((@TPEdited=1 or @TPCanceled=1)AND @ProcessId=90)
	BEGIN
		SELECT TOP 1 @DocTime=DocTime FROM inv.tblStorageDocsHdr 
		WHERE TaxID<>'' AND  SerialNo=@SerialNo AND ProcessID=@ProcessId AND ProcessNo=@ProcessNo AND FiscalYear=@FiscalYear
	END

	--------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
	SELECT @DocTime AS DocTime


END TRY
BEGIN CATCH


	Set @StrErrorMessage = ERROR_MESSAGE() 
	raiserror (@StrErrorMessage, 16, 1)

END CATCH

END	
GO
