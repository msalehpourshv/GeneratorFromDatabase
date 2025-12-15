USE TS_ShirinVatanKarkhaneh_1_1404
GO
SET ANSI_NULLS, QUOTED_IDENTIFIER ON
GO
CREATE FUNCTION [lyl].[GetCustomerInfo]
(
	@CustomerInfoID VarChar(20), 
	@LanguageID AS TinyInt
)
	RETURNS NVarChar(50) 
WITH ENCRYPTION
AS

Begin -- ====================================================

	Declare @Name AS NVarChar(50)
	SET @Name = '' 
	Select @Name = FirstName + ' ' + LastName
	From   lyl.tblCustomerInfoDtl
	Where  CustomerInfoID = @CustomerInfoID AND LanguageID = @LanguageID

	Return @Name

END -- ======================================================

















GO
