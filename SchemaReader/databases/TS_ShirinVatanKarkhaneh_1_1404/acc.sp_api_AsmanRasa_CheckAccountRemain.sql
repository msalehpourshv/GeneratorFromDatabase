USE TS_ShirinVatanKarkhaneh_1_1404
GO
SET ANSI_NULLS, QUOTED_IDENTIFIER ON
GO
-- =========== TS-QC:NOTOK ========================
-- Author        : Alianpour
-- Create date   : 1400/11/25
-- Viewed By	 : 
-- Last Modified : 
-- Description   : 
-- =============================================
CREATE  PROCEDURE acc.sp_api_AsmanRasa_CheckAccountRemain

@Amount AS float,
@AcntCode as nvarchar(50),
@DocDate as nvarchar(50)

WITH ENCRYPTION
 AS
BEGIN

DECLARE @StrErrorMessage As Nvarchar(1024)
DECLARE @Remain as float
DECLARE @PartNumber as int
DECLARE @Len as int
BEGIN TRY

	select @PartNumber=SettingValue from pub.tblSettings
	where SettingKey like'AcntPartNumberForRemainCalculation'

	select @Len=Layer1+Layer2+Layer3+Layer4+Layer5+Layer6+Layer7+1 from pub.tblCodeLayer
	where PartNumber<@PartNumber and TableName='acc.tblAcnt'

	select @Remain=ISNULL(sum(Credit-Debit),0) from acc.tblVoucherDtl
	where SUBSTRING(AcntCode,@Len+1,len(@AcntCode)+1)=@AcntCode
	and DocDate<=@DocDate

	 IF(@Remain<=0 or @Remain<@Amount)
	begin
		--Set @StrErrorMessage = ' برای  مشتری ' +@AcntCode+' مانده حسابی تعریف نشده است'
		--raiserror (@StrErrorMessage, 16, 1)
		SELECT 1 AS IsRemain
	end
	ELSE
		SELECT 1 AS IsRemain

END TRY
BEGIN CATCH


	Set @StrErrorMessage = ERROR_MESSAGE() 
	raiserror (@StrErrorMessage, 16, 1)

END CATCH

END	

GO
