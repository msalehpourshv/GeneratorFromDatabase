USE TS_ShirinVatanKarkhaneh_1_1404
GO
SET ANSI_NULLS, QUOTED_IDENTIFIER ON
GO
-- =========== TS-QC:UPDATED ====================
-- Author		 : TakroSystem\Zia
-- Create date   : ??
-- Viewed By	 : 
-- Last Modified : 1389/10/13
-- Last Modifier : TakroSystem\Zia
-- Description	 : 
-- ===============================================
CREATE FUNCTION [pub].[funCompanyInfo]
(
	@ChrDelimiter NChar(1)
)
RETURNS NVarChar(1024)
WITH ENCRYPTION
AS

BEGIN
	Declare	@res	NVarChar(1024);
	
	set @res = '';
	----  در تغییرات با تابع funGetCompanyInfo یکسان سازی شود
	select @res = 
	isnull((select SettingValue	from pub.tblSettings where SettingKey = 'CompanyCompanyName'), '-') + @ChrDelimiter +	-- 1
	isnull((select SettingValue	from pub.tblSettings where SettingKey = 'CompanyEconimicCode'), '-') + @ChrDelimiter +  -- 2
	isnull((select SettingValue	from pub.tblSettings where SettingKey = 'CompanyRegisterNo'), '-') + @ChrDelimiter +	-- 3
	isnull((select SettingValue	from pub.tblSettings where SettingKey = 'CompanyNationalCode'), '-') + @ChrDelimiter +	-- 4 
	isnull((select SettingValue	from pub.tblSettings where SettingKey = 'CompanyCity'), '-') + @ChrDelimiter +			-- 5
	isnull((select SettingValue	from pub.tblSettings where SettingKey = 'CompanyZipCode'), '-') + @ChrDelimiter +		-- 6
	isnull((select SettingValue	from pub.tblSettings where SettingKey = 'CompanyAddress'), '-') + @ChrDelimiter +		-- 7
	isnull((select SettingValue	from pub.tblSettings where SettingKey = 'CompanyTel'), '-') + @ChrDelimiter +			-- 8
	isnull((select SettingValue	from pub.tblSettings where SettingKey = 'CompanyFax'), '-') + @ChrDelimiter +			-- 9
	isnull((select SettingValue	from pub.tblSettings where SettingKey = 'CompanyNationalIdentity'), '-')+ @ChrDelimiter +-- 10
	isnull((select SettingValue	from pub.tblSettings where SettingKey = 'CompanyBranchName'), '-')+ @ChrDelimiter +		-- 11
	isnull((select SettingValue	from pub.tblSettings where SettingKey = 'CompanyBranchID'), '-')+ @ChrDelimiter +		-- 12
	isnull((select SettingValue	from pub.tblSettings where SettingKey = 'CompanyEmail'), '-')							-- 13

	Return @res;

END
GO
