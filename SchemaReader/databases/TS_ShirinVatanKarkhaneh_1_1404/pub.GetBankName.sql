USE TS_ShirinVatanKarkhaneh_1_1404
GO
SET ANSI_NULLS, QUOTED_IDENTIFIER ON
GO
CREATE FUNCTION [pub].[GetBankName]
(
	@Code VarChar(20), 
	@LanguageID As TinyInt
)
RETURNS NVarChar(200)
WITH ENCRYPTION
AS
Begin -- === S T A R T ===========================================

	--SET @LanguageID = pub.funGetCurrentLanguageID();

	Declare @Result AS NVarChar(200)
	SET @Result = ''

	SELECT  @Result = BankName
	FROM    trs.tblOurBanksDtl
	WHERE   BankCode = @Code AND LanguageID = @LanguageID
 
	Return @Result
	
End   -- === E N D ===============================================















GO
