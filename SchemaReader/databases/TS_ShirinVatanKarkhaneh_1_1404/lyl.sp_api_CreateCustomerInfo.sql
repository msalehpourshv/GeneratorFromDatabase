USE TS_ShirinVatanKarkhaneh_1_1404
GO
SET ANSI_NULLS, QUOTED_IDENTIFIER ON
GO
-- =============================================
-- Author        : jafari
-- Create date   : 1402/06/11
-- Viewed By	 : 
-- Last Modified : 
-- Description   : 
-- =============================================
Create PROCEDURE lyl.sp_api_CreateCustomerInfo
	@CustomerInfoID	varchar(20), 
	@RecID			int,
	@CodeClosed		int,
	@SessionNo		int,
	@NationalNumber	varchar(20), 
	@IDNumber		varchar(20), 
	@BirthDate		char(10), 
	@RegisterDate	char(10), 
	@MobileNumber	varchar(20), 
	@PhoneNumber	varchar(20), 
	@Gender			int, 
	@LanguageID		int, 
	@FirstName		varchar(20), 
	@LastName		varchar(20), 
	@Adress			varchar(20) ,
	@ExtraParams	NVarChar(Max)
WITH ENCRYPTION
AS
BEGIN
	
	Declare @StrErrorMessage	Nvarchar(1024)

BEGIN TRY

	-- check ==============================================================================================================
	IF (SELECT Count(*) FROM lyl.tblCustomerInfo where CustomerInfoID=@CustomerInfoID) > 0
	BEGIN		
		SELECT b.*, a.* FROM lyl.tblCustomerInfo a 
			inner join  lyl.tblCustomerInfo b on a.CustomerInfoID=b.CustomerInfoID
			 where a.CustomerInfoID=@CustomerInfoID
		 
			return 
	end
	-- save ==============================================================================================================
	INSERT INTO lyl.tblCustomerInfo (CustomerInfoID	,RecID,CodeClosed,SessionNo,NationalNumber,IDNumber,BirthDate,RegisterDate,MobileNumber	,PhoneNumber,Gender	)
				SELECT @CustomerInfoID	,@RecID,@CodeClosed,@SessionNo,@NationalNumber,@IDNumber,@BirthDate,@RegisterDate,@MobileNumber	,@PhoneNumber,@Gender	

	INSERT INTO lyl.tblCustomerInfoDtl(CustomerInfoID,LanguageID,FirstName,LastName,Adress)
				SELECT @CustomerInfoID,@LanguageID,@FirstName,@LastName,@Adress

    ------------------------------------------------------------------------------------------------------------------------------------------
	SELECT b.*, a.* FROM lyl.tblCustomerInfo a 
			inner join  lyl.tblCustomerInfo b on a.CustomerInfoID=b.CustomerInfoID
			 where a.CustomerInfoID=@CustomerInfoID

END TRY
BEGIN CATCH

	Set @StrErrorMessage = ERROR_MESSAGE() 
	raiserror (@StrErrorMessage, 16, 1)

END CATCH

END	
 

GO
