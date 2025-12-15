USE TS_ShirinVatanKarkhaneh_1_1404
GO
SET ANSI_NULLS, QUOTED_IDENTIFIER ON
GO
-- =========== TS-QC:NOTOK ========================
-- Author        : Hadi Sadeghi
-- Create date   : 1400/02/20
-- Viewed By	 : 
-- Last Modified : 
-- Description   : 
-- =============================================
Create PROCEDURE [acc].[sp_api_saymandigital_AutoAcntCode]
@AcntCode		as VARCHAR(20),
@AcntName		as NVARCHAR(200),
@FirstName		as NVARCHAR(50),
@LastName		as NVARCHAR(50),
@AcntComment	as NVARCHAR(100),
@OrganzationName	as NVARCHAR(50),
@Address1	as NVARCHAR(2000),
@Address2	as NVARCHAR(2000),
@Tel			as VARCHAR(50),
@Mobile			as VARCHAR(50),
@Fax			as VARCHAR(50),
@EconomicalCode as VARCHAR(30),
@NationalIDNumber	as VARCHAR(50),
@Email			as VARCHAR(50),
@AccountNumber  as VARCHAR(50),
@ShabaAccountNumber	as VARCHAR(50),
@BirthDate	as CHAR(10),
@ZipCode as NVARCHAR(50),
@NationalIdentity	as NVARCHAR(50)

WITH ENCRYPTION
 AS
BEGIN

Declare @StrErrorMessage As Nvarchar(1024)
Declare @CustomerPartNo AS Tinyint
DECLARE @PartXLen	Int;
DECLARE @AcntCustomerCode as Varchar(10)='3'

BEGIN TRY
	SET @CustomerPartNo = 1
	
	SELECT @CustomerPartNo = SettingValue
	FROM pub.tblSettings
	WHERE SettingKey = 'AcntPartNumberForRemainCalculation'
	 
	

	SELECT	@PartXLen = Layer1 + Layer2 + Layer3 + Layer4 + Layer5 + Layer6 + Layer7 + Layer8 + Layer9 
	FROM	pub.tblCodeLayer 
	WHERE	(TableName = 'acc.tblAcnt') AND (PartNumber = @CustomerPartNo)

	SELECT @AcntCode = @AcntCustomerCode + pub.funPadLeft(@AcntCode,'0',@PartXLen-LEN(@AcntCustomerCode))
	
	IF (SELECT COUNT(*) from acc.tblAcnt where PartNumber=@CustomerPartNo AND AcntCode=@AcntCode)=0
	BEGIN
		INSERT INTO acc.tblAcnt 
		(AcntCode,PartNumber,Tel,Mobile,Fax,EconomicalCode,NationalIDNumber,Email,
		 AccountNumber,ShabaAccountNumber,BirthDate,NationalIdentity,ZipCode)
		VALUES
		(@AcntCode,@CustomerPartNo,@Tel,@Mobile,@Fax,@EconomicalCode,@NationalIDNumber,@Email,
		 @AccountNumber,@ShabaAccountNumber,@BirthDate,@NationalIdentity,@ZipCode)
		 
		INSERT INTO acc.tblAcntDtl 
        (AcntCode,PartNumber,LanguageID,AcntName,FirstName,LastName,OrganzationName,Address1,Address2,AcntComment)
		VALUES	 
        (@AcntCode,@CustomerPartNo,1,@AcntName,@FirstName,@LastName,@OrganzationName,@Address1,@Address2,@AcntComment)
	END
	ELSE
	BEGIN
		UPDATE acc.tblAcnt
		SET Tel=@Tel,Mobile=@Mobile,Fax=@Fax,EconomicalCode=@EconomicalCode,NationalIDNumber=@NationalIDNumber,Email=@Email,
		AccountNumber=@AccountNumber,ShabaAccountNumber=@ShabaAccountNumber,BirthDate=@BirthDate,NationalIdentity=@NationalIdentity
		WHERE AcntCode=@AcntCode and PartNumber=@CustomerPartNo
		
		UPDATE acc.tblAcntDtl
		SET AcntName=@AcntName,FirstName=@FirstName,LastName=@LastName,OrganzationName=@OrganzationName,Address1=@Address1,Address2=@Address2,AcntComment=@AcntComment
		WHERE AcntCode=@AcntCode and PartNumber=@CustomerPartNo
	END
	
END TRY
BEGIN CATCH

	Set @StrErrorMessage = ERROR_MESSAGE() 
	raiserror (@StrErrorMessage, 16, 1)

END CATCH

END	

GO
