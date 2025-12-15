USE TS_ShirinVatanKarkhaneh_1_1404
GO
SET ANSI_NULLS, QUOTED_IDENTIFIER ON
GO
-- =========== TS-QC:UPDATED ====================
-- Author		 : TakroSystem\Ahmadnejad
-- Creation Date : 1387/06/30
-- Viewed By	 : 
-- Last Modifier : 
-- Last Modified : 
-- Description   : <کسر و اضافه تولید پرسنل>
-- =================================================================
CREATE PROCEDURE [prs].[RptPrs_ProdIncDec]
	@MonthCode	TinyInt
WITH ENCRYPTION
AS
DECLARE @LanguageID TinyInt
BEGIN

	SET NOCOUNT ON;
	SET @LanguageID = pub.funGetCurrentLanguageID();
	
	-- WHERE SECTION --------------------------------
	SELECT	D.*, P.FirstName + ' ' + P.LastName As PersonnelName
	FROM	prs.tblProductionBenefitsDtl D 
				LEFT JOIN prs.tblPersonnelsDtl P ON P.PersonnelID = D.PersonnelID
	WHERE	D.MonthCode = @MonthCode
	ORDER BY DocRowNo
END
GO
