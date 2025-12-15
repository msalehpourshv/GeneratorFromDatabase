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
CREATE PROCEDURE [acc].[spAutoAcntCode]
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
@NationalIdentity	as NVARCHAR(50)

WITH ENCRYPTION
 AS
BEGIN

Declare @StrErrorMessage As Nvarchar(1024)
Declare @CustomerPartNo AS Tinyint
BEGIN TRY
	SET @CustomerPartNo = 1
	
	SELECT @CustomerPartNo = SettingValue
	FROM pub.tblSettings
	WHERE SettingKey = 'AcntPartNumberForRemainCalculation'
	
	IF (SELECT COUNT(*) from acc.tblAcnt where PartNumber=@CustomerPartNo AND AcntCode=@AcntCode)=0
	BEGIN
		INSERT INTO acc.tblAcnt 
		(AcntCode,PartNumber,Tel,Mobile,Fax,EconomicalCode,NationalIDNumber,Email,
		 AccountNumber,ShabaAccountNumber,BirthDate,NationalIdentity)
		VALUES
		(@AcntCode,@CustomerPartNo,@Tel,@Mobile,@Fax,@EconomicalCode,@NationalIDNumber,@Email,
		 @AccountNumber,@ShabaAccountNumber,@BirthDate,@NationalIdentity)
		 
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
