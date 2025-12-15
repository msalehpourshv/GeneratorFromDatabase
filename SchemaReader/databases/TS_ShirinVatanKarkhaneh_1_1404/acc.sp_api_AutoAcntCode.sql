USE TS_ShirinVatanKarkhaneh_1_1404
GO
SET ANSI_NULLS, QUOTED_IDENTIFIER ON
GO
CREATE PROCEDURE [acc].[sp_api_AutoAcntCode]
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
@NationalIdentity	as NVARCHAR(50),
@CompanyRegisterNo	as NVARCHAR(50)


WITH ENCRYPTION
 AS
BEGIN

Declare @StrErrorMessage As Nvarchar(1024)
DECLARE @MaxAcntCode as Varchar(50)

BEGIN TRY


	IF(SELECT count(* ) from acc.tblAcnt where VerifyCode=@AcntCode)=0
	BEGIN

		SELECT @MaxAcntCode= isnull(MAX(AcntCode),0)
		From acc.tblAcnt 
		WHERE PartNumber=2 and SUBSTRING(AcntCode,1,1)='5'


			if @MaxAcntCode='50'
			
			SET @MaxAcntCode='500001'
		else
			SET @MaxAcntCode= cast(@MaxAcntCode as int)+1

			INSERT INTO acc.tblAcnt 
			(AcntCode,PartNumber,Tel,Mobile,Fax,EconomicalCode,NationalIDNumber,Email,CompanyRegisterNo,
			AccountNumber,ShabaAccountNumber,BirthDate,NationalIdentity,VerifyCode,MemberCode)
		VALUES
			(@MaxAcntCode,2,@Tel,@Mobile,@Fax,@EconomicalCode,@NationalIDNumber,@Email,@CompanyRegisterNo,
			@AccountNumber,@ShabaAccountNumber,@BirthDate,@NationalIdentity,@AcntCode,@AcntCode)
		 
			INSERT INTO acc.tblAcntDtl 
			(AcntCode,PartNumber,LanguageID,AcntName,FirstName,LastName,OrganzationName,Address1,Address2,AcntComment)
		VALUES	 
			(@MaxAcntCode,2,1,@AcntName,@FirstName,@LastName,@OrganzationName,@Address1,@Address2,@AcntComment+@AcntCode)

			select @MaxAcntCode as AcntCode
		END



	--END

	ELSE
	BEGIN
		select @MaxAcntCode =AcntCode from acc.tblAcnt where VerifyCode=@AcntCode
		select @MaxAcntCode as AcntCode
	END
	

END TRY
BEGIN CATCH

	Set @StrErrorMessage = ERROR_MESSAGE() 
	raiserror (@StrErrorMessage, 16, 1)

END CATCH

END	
GO
