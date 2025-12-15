USE TS_ShirinVatanKarkhaneh_1_1404
GO
SET ANSI_NULLS, QUOTED_IDENTIFIER ON
GO
CREATE PROCEDURE acc.sp_api_AsmanRasa_AutoAcntCode
@FirstName		as NVARCHAR(50),
@LastName		as NVARCHAR(50),
@MemberCode as NVARCHAR(50),
@Email			as VARCHAR(50)

WITH ENCRYPTION
 AS
BEGIN

Declare @StrErrorMessage As Nvarchar(1024)
DECLARE @MaxAcntCode as Varchar(50)

BEGIN TRY


	IF(SELECT count(*) from acc.tblAcnt where VerifyCode=@MemberCode)=0
	BEGIN

		SELECT @MaxAcntCode= isnull(MAX(AcntCode),0)
		From acc.tblAcnt 
		WHERE PartNumber=2 and SUBSTRING(AcntCode,1,2)='03'


		if @MaxAcntCode=''
			
			SET @MaxAcntCode='500001'
		else
		begin
			SET @MaxAcntCode= cast(@MaxAcntCode as int)+1
			set @MaxAcntCode='0'+@MaxAcntCode
		end
		--print @MaxAcntCode
		INSERT INTO acc.tblAcnt 
			(AcntCode,PartNumber,Email,VerifyCode,MemberCode)
		VALUES
			(@MaxAcntCode,2,@Email,@MemberCode,@MemberCode)
		 
			INSERT INTO acc.tblAcntDtl 
			(AcntCode,PartNumber,LanguageID,AcntName,FirstName,LastName,AcntComment)
		VALUES	 
			(@MaxAcntCode,2,1,@FirstName+ ' '+ @LastName,@FirstName,@LastName,'Api-'+@MemberCode)

		select @MaxAcntCode as AcntCode
	END
	

END TRY
BEGIN CATCH

	Set @StrErrorMessage = ERROR_MESSAGE() 
	raiserror (@StrErrorMessage, 16, 1)

END CATCH

END	
GO
