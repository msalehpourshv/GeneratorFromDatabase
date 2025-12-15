USE TS_ShirinVatanKarkhaneh_1_1404
GO
SET ANSI_NULLS, QUOTED_IDENTIFIER ON
GO
CREATE FUNCTION [trs].[GetOurBankName]
(
	@BankCode VarChar(20), 
	@LanguageID AS TinyInt
)
	RETURNS NVarChar(50) 
WITH ENCRYPTION
AS

Begin -- ====================================================

	Declare @BankName AS NVarChar(50)
	set @BankName = ''
	
	Select @BankName = BankName
	From   trs.tblOurBanksDtl
	Where  BankCode = @BankCode AND LanguageID = @LanguageID

	Return @BankName

END -- ======================================================
GO
