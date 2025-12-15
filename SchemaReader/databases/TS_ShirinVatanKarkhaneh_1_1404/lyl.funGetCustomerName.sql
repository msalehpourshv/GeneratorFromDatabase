USE TS_ShirinVatanKarkhaneh_1_1404
GO
SET ANSI_NULLS, QUOTED_IDENTIFIER ON
GO
CREATE FUNCTION [lyl].[funGetCustomerName] 
(
	@CustomerCardNo	Char(20) ,
	@LanguageID	TinyInt
)
RETURNS NVarChar(50)
WITH ENCRYPTION
AS

BEGIN

	-- Declare the return variable here
	DECLARE @CustomerName NVarChar(50)

	Set @CustomerName = N'-'

	SELECT @CustomerName = RTRIM(d.FirstName) + '  ' + RTRIM(d.LastName)
	From  lyl.tblLoyalCardDtl l 
	INNER JOIN lyl.tblCustomerInfoDtl d
	on l.CustomerInfoID=d.CustomerInfoID
	Where LanguageID = @LanguageID AND l.LoyalCardNo = @CustomerCardNo 

	-- Return the result of the function
	RETURN @CustomerName 

END
GO
