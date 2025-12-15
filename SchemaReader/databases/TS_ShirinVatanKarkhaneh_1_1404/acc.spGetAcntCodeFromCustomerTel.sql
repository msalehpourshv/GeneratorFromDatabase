USE TS_ShirinVatanKarkhaneh_1_1404
GO
SET ANSI_NULLS, QUOTED_IDENTIFIER ON
GO
-- =========== TS-QC:NOTOK =====================
-- Author        : Hadi Sadeghi
-- Create date   : 1402/05/21
-- Viewed By	 : 
-- Last Modified : 
-- Description   : 
-- =============================================
--[acc].[spGetAcntCodeFromCustomerTel] ''
Create PROCEDURE [acc].[spGetAcntCodeFromCustomerTel] 
	@Mobile as varchar(30)
WITH ENCRYPTION
 AS
BEGIN
SET NOCOUNT ON;

	declare @AcntCode as varchar(20) = ''
	declare @BuyerAcntCodeInSale as varchar(20) = ''
	declare @PosAcntCode as varchar(20) = ''
	declare @Start as Int
	declare @Len as Int
	declare @CustomerPart as tinyint

	SELECT @CustomerPart =SettingValue  from pub.tblSettings where SettingKey='AcntPartNumberForRemainCalculation'
	SELECT @AcntCode=AcntCode from acc.tblAcnt where Mobile = @Mobile AND PartNumber=@CustomerPart
	SELECT @Start=[acc].[funGetAcntLayerStartandLen](@CustomerPart,1)
	SELECT @Len=[acc].[funGetAcntLayerStartandLen](@CustomerPart,2)
	SELECT @BuyerAcntCodeInSale = SettingValue FROM pub.tblSettings where SettingKey='BuyerAcntCodeInSale'
	SELECT @PosAcntCode = SettingValue FROM pub.tblSettings where SettingKey='PosAcntCode'
	

	IF @AcntCode = ''
	BEGIN
		decLare @MaxAcntCode as VARCHAR(30) = ''
		SELECT @MaxAcntCode = MAX(AcntCode) FROM acc.tblAcnt where PartNumber=@CustomerPart AND AcntCode like SUBSTRING(@BuyerAcntCodeInSale,@Start,@Len)+'%' --AND LEN(AcntCode)=@Len

		IF  @MaxAcntCode IS NULL OR LEN(@MaxAcntCode) < @Len
			SET @MaxAcntCode = @MaxAcntCode +pub.funPadLeft('1','0',@Len - 1 - LEN(@MaxAcntCode))
		ELSE
			SET @MaxAcntCode = @MaxAcntCode + 1

		IF 	(SELECT COUNT(*) from lyl.tblCustomerInfo WHERE CustomerInfoID = @Mobile)>0
		BEGIN
			INSERT INTO acc.tblAcnt 
					(AcntCode, PartNumber, CodeClosed, Tel, SessionNo, Mobile, NationalIDNumber, SMSMobile, BirthDate, NationalIdentity,  Gender)
			SELECT @MaxAcntCode ,@CustomerPart,'False',PhoneNumber,SessionNo,CustomerInfoID,NationalNumber,CustomerInfoID,BirthDate,NationalNumber,Gender
			from lyl.tblCustomerInfo
			WHERE CustomerInfoID = @Mobile

			INSERT INTO acc.tblAcntDtl 
					(AcntCode, LanguageID, PartNumber, AcntName, FirstName, LastName, Address1 )
			SELECT @MaxAcntCode ,1,@CustomerPart,FirstName + ' ' + LastName ,FirstName,LastName,Adress
			from lyl.tblCustomerInfoDtl
			WHERE CustomerInfoID = @Mobile
					
			SET @AcntCode= SUBSTRING(@BuyerAcntCodeInSale,1,@Start-1) + @MaxAcntCode + SUBSTRING(@PosAcntCode,@Start + @Len ,20)
		END

	END
	ELSE
	BEGIN
		SET @AcntCode= SUBSTRING(@BuyerAcntCodeInSale,1,@Start-1) + @AcntCode  + SUBSTRING(@PosAcntCode,@Start + @Len ,20)
	END

	SELECT @AcntCode

END
GO
