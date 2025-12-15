USE TS_ShirinVatanKarkhaneh_1_1404
GO
SET ANSI_NULLS, QUOTED_IDENTIFIER ON
GO
CREATE FUNCTION [trs].[GetPayName]
(
	@BankCode VarChar(20), 
	@LanguageID AS TinyInt
)
	RETURNS NVarChar(50) 
WITH ENCRYPTION
AS

Begin -- ====================================================

	Declare @BankName AS NVarChar(500)
	set @BankName = ''
	
IF (select COUNT(*) from [TS_ShirinVatanKarkhaneh_1_1402].trs.tblPayDtl
where LTRIM(RTRIM(@BankCode)) like '% %' ) = 0
	Select @BankName = BankName
	From   trs.tblOurBanksDtl
	Where  BankCode = @BankCode AND LanguageID = @LanguageID
ELSE
BEGIN
SELECT @BankName = [pub].[GetCodeName](@BankCode,@LanguageID)
END
	Return @BankName

END -- ======================================================
GO
