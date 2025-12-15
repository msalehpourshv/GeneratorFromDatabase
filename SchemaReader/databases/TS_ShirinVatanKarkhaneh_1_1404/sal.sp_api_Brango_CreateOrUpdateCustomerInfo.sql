USE TS_ShirinVatanKarkhaneh_1_1404
GO
SET ANSI_NULLS, QUOTED_IDENTIFIER ON
GO
-- =========== TS-QC:NOTOK ========================
-- Author        : Alian Pour
-- Create date   : 1400/10/13
-- Viewed By	 : 
-- Last Modified : 
-- Description   : 
-- =============================================
CREATE PROCEDURE [sal].[sp_api_Brango_CreateOrUpdateCustomerInfo]

@CustomerInfoID As NVARCHAR(50),
@BirthDate As NVARCHAR(10),
@MobileNumber As NVARCHAR(13),
@PhoneNumber As NVARCHAR(13),
@FirstName As NVARCHAR(200),
@LastName As NVARCHAR(200)

WITH ENCRYPTION
 AS
BEGIN
	DECLARE @strSelect  NVARCHAR(MAX)
	DECLARE @StrErrorMessage NVARCHAR(MAX)

BEGIN TRY

	IF(select count(*) from lyl.tblCustomerInfo where CustomerInfoID=@CustomerInfoID)>0
	Begin

		update lyl.tblCustomerInfo
		set BirthDate=@BirthDate , MobileNumber=@MobileNumber , PhoneNumber=@PhoneNumber 
		where CustomerInfoID=@CustomerInfoID

		Update lyl.tblCustomerInfoDtl
		set LastName=@LastName ,FirstName= @FirstName
		where CustomerInfoID=@CustomerInfoID

	END
	
	ELSE
	BEGIN

		INSERT INTO lyl.tblCustomerInfo
			(BirthDate, MobileNumber , PhoneNumber ,CustomerInfoID)
		VALUES
			(@BirthDate , @MobileNumber , @PhoneNumber ,@CustomerInfoID)

		INSERT INTO lyl.tblCustomerInfoDtl
			(FirstName, LastName , CustomerInfoID)
		VALUES
			(@FirstName , @LastName, @CustomerInfoID )
	END
	
     

END TRY
BEGIN CATCH


	Set @StrErrorMessage = ERROR_MESSAGE() 
	raiserror (@StrErrorMessage, 16, 1)

END CATCH

END	
GO
