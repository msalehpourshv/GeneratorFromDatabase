USE TS_ShirinVatanKarkhaneh_1_1404
GO
SET ANSI_NULLS, QUOTED_IDENTIFIER ON
GO
CREATE FUNCTION [pub].[funGetBankTypeName] 
(
	@BankTypeID varchar(20),
	@LanguageID TinyInt
)
RETURNS NVarChar(50)
WITH ENCRYPTION
AS

BEGIN

	DECLARE @BankTypeName NVarChar(50)

	Set @BankTypeName = N''

	SELECT @BankTypeName = BankTypeName 
	From trs.tblBankTypesDtl 
	Where LanguageID = @LanguageID AND BankTypeID = @BankTypeID

	RETURN @BankTypeName 

END














GO
