USE TS_ShirinVatanKarkhaneh_1_1404
GO
SET ANSI_NULLS, QUOTED_IDENTIFIER ON
GO
CREATE FUNCTION [prs].[funGetBenefitName] 
(
	@BenefitID		Char(20),
	@BenefitType	Smallint,
	@LanguageID		TinyInt
)
RETURNS NVarChar(50)
WITH ENCRYPTION
AS

BEGIN

	-- Declare the return variable here
	DECLARE @BenefitName NVarChar(50)

	Set @BenefitName = N'-'

IF @BenefitType = 1
	BEGIN
		SELECT @BenefitName = BenefitName 
		From  prs.tblBenefits1Dtl
		Where LanguageID = @LanguageID AND BenefitID = @BenefitID
	END
ELSE
	BEGIN
		SELECT @BenefitName = BenefitName 
		From  prs.tblDeduction1Dtl
		Where LanguageID = @LanguageID AND BenefitID = @BenefitID
	END
	-- Return the result of the function
	RETURN @BenefitName 

END













GO
