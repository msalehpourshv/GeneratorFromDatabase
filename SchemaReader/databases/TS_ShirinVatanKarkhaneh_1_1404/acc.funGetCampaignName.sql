USE TS_ShirinVatanKarkhaneh_1_1404
GO
SET ANSI_NULLS, QUOTED_IDENTIFIER ON
GO
-- =========== TS-QC:NOTOK =====================
-- Author        : jafari
-- Create date   : 1404/02/17
-- Viewed By	 : 
-- Last Modified : 
-- Last Modifier : 
-- Description   : 
-- =============================================
Create FUNCTION acc.funGetCampaignName
(
	@CampaignID AS VarChar(20),
	@LanguageID TinyInt 
)
RETURNS NVarChar(250)
WITH ENCRYPTION
AS
BEGIN
	DECLARE @Result AS NVarChar(250)

	SELECT	@Result = CampaignName
	FROM	acc.tblCampaignDtl
	WHERE	CampaignID = @CampaignID AND 
			LanguageID = @LanguageID

	RETURN isnull(@Result,'')
END
GO
