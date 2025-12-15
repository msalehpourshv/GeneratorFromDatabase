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
create PROCEDURE inv.sp_api_TakroSystem_GetConfirmedPayment
@ProcessId as int,
@ProcessNo as int,
@SerialNo as int,
@FiscalYear as int

WITH ENCRYPTION
 AS
BEGIN
	DECLARE @StrErrorMessage NVARCHAR(MAX)
	DECLARE @CompanyEconimicCode NVARCHAR(MAX)
	DECLARE @CompanyNationalCode NVARCHAR(MAX)
	DECLARE @CompanyNationalIdentity NVARCHAR(MAX)
	DECLARE @CompanyPersonalityType NVARCHAR(MAX)
	DECLARE @TaxBranchId NVARCHAR(MAX)

BEGIN TRY

	IF (SELECT COUNT(*) FROM  pub.tblSettings WHERE  SettingKey =  'CompanyEconimicCode' )>0
		SELECT @CompanyEconimicCode=SettingValue FROM pub.tblSettings
		where SettingKey = 'CompanyEconimicCode'

	IF (SELECT COUNT(*) FROM  pub.tblSettings WHERE  SettingKey =  'CompanyNationalCode' )>0
		SELECT @CompanyNationalCode=SettingValue FROM pub.tblSettings
		where SettingKey ='CompanyNationalCode'

	IF (SELECT COUNT(*) FROM  pub.tblSettings WHERE  SettingKey =  'CompanyNationalIdentity' )>0
		SELECT @CompanyNationalIdentity= SettingValue FROM pub.tblSettings
		where SettingKey ='CompanyNationalIdentity'

---------------------------------------------------------------------------------------------------------------------------------------
	SELECT 	
		ChequeNo,ISNULL(BankCardNo,'') AS BankCardNo,
		CASE 
			WHEN A.PersonType =1 or A.PersonType is null or A.PersonType =0
			THEN
				CASE 
					WHEN @CompanyNationalIdentity='' or @CompanyNationalIdentity is null
					THEN @CompanyNationalCode
					WHEN @CompanyNationalIdentity<>'' or @CompanyNationalIdentity is not null
					THEN @CompanyNationalIdentity
				END
			WHEN A.PersonType=2 THEN @CompanyEconimicCode
		END Pid
	FROM trs.tblPayDtl PD
		INNER JOIN trs.tblPayHdr PH ON PH.SerialNo=PD.SerialNo AND PH.ProcessID=PD.ProcessID AND PH.ProcessNo=PD.ProcessNo AND PD.FiscalYear=PH.FiscalYear
		INNER JOIN inv.tblStorageDocsHdr H 	ON  PD.BaseSerialNo=H.SerialNo AND PD.BaseFiscalYear=H.FiscalYear AND  PD.ProcessID=1 AND H.ProcessID=90 AND H.ProcessNo=PH.BaseProcessNo
		LEFT JOIN acc.tblAcnt A ON H.AcntCode=A.AcntCode 
		LEFT JOIN trs.tblOurBanks B ON B.BankCode=PD.CreditCode
	WHERE PD.BaseSerialNo=@SerialNo AND PD.BaseFiscalYear=@FiscalYear AND PD.ProcessID=1
	

END TRY
BEGIN CATCH


	Set @StrErrorMessage = ERROR_MESSAGE() 
	raiserror (@StrErrorMessage, 16, 1)

END CATCH

END	


GO
