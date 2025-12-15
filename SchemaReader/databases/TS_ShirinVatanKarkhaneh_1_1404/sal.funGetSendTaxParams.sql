USE TS_ShirinVatanKarkhaneh_1_1404
GO
SET ANSI_NULLS, QUOTED_IDENTIFIER ON
GO
-- =========== TS-QC:NOTOK ========================
-- Author        : jafari	
-- Create date   : 1401/12/23
-- Viewed By	 : 
-- Last Modified : 
-- Description   : 
-- =============================================
Create FUNCTION sal.funGetSendTaxParams
(
@ConnStr NVarChar(2000),
@ExtraParam  NVarChar(2000)
)
RETURNS NVarChar(2000)
WITH ENCRYPTION
AS
BEGIN
	DECLARE @Result AS NVarChar(2000)

	DECLARE @TaxTollSendFullPath AS NVarChar(2000)
	DECLARE @TaxTollSendMemID AS NVarChar(2000)
	DECLARE @TaxTollSendPrivateKey AS NVarChar(2000)
	DECLARE @TaxTollSendClientID AS NVarChar(2000)
	DECLARE @TaxTollSendPublicKey AS NVarChar(2000)


	SELECT @TaxTollSendFullPath 		= LTrim(pub.funSplitString(@ExtraParam, '@', 1)); 
	SELECT @TaxTollSendMemID = SettingValue FROM pub.tblSettings WHERE SettingKey = 'TaxTollSendMemID'	
	SELECT @TaxTollSendPrivateKey = SettingValue FROM pub.tblSettings WHERE SettingKey = 'TaxTollSendPrivateKey'	
	SELECT @TaxTollSendClientID = SettingValue FROM pub.tblSettings WHERE SettingKey = 'TaxTollSendClientID'	
	SELECT @TaxTollSendPublicKey = SettingValue FROM pub.tblSettings WHERE SettingKey = 'TaxTollSendPublicKey'	
		
	--set @Result=isnull(@TaxTollSendFullPath,' ')+' '+isnull(@TaxTollSendMemID,' ') +' '+isnull(@TaxTollSendPrivateKey,' ') +' '+isnull(@TaxTollSendClientID,' ') +' '+isnull(@TaxTollSendPublicKey,' ')  +' ' +isnull(@ConnStr, '')
	 
	select @ConnStr=REPLACE(isnull(@ConnStr, ' '), ' ' , '*&*')

	set @Result=isnull(@TaxTollSendFullPath,' ')+'  ' +isnull(@ConnStr, ' ')

	RETURN isnull(@Result,'')
END
GO
