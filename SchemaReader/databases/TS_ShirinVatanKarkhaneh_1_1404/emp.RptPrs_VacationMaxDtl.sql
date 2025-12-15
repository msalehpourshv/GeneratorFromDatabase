USE TS_ShirinVatanKarkhaneh_1_1404
GO
SET ANSI_NULLS, QUOTED_IDENTIFIER ON
GO
-- =========== TS-QC:UPDATED ====================
-- Author		 : TakroSystem\H SR
-- Create date   : 1399/03/10
-- Viewed By	 : 
-- Last Modified : 
-- Last Modifier : 
-- Description	 : سقف مرخصی  پرسنل
-- ==============================================
--[emp].[RptPrs_VacationMaxDtl] 1
CREATE  PROCEDURE [emp].[RptPrs_VacationMaxDtl]
	@SerialNo		INT
 WITH ENCRYPTION
AS 
 DECLARE @LanguageID TinyInt;
Begin --============== S T A R T  C O D E =======================================

	SET NOCOUNT ON;

	-- Init ------------------------------------------
	SET @LanguageID = pub.funGetCurrentLanguageID();
	--------------------------------------------------

	-- SELECT Clause ----------------------------------------
	SELECT	D.*,ISNULL(VacationTypeName,'') VacationTypeName
		,P.FirstName + ' ' + P.LastName AS PersonnelName
	FROM	emp.tblVacationMaxDtl D
	LEFT JOIN prs.tblPersonnelsDtl P ON P.PersonnelID = D.PersonnelID AND P.LanguageID = @LanguageID
	LEFT JOIN emp.tblVacationTypesDtl V ON V.VacationTypeID = D.VacationTypeID AND V.LanguageID = @LanguageID
	WHERE 	SerialNo = @SerialNo
	------------------------------------------------------------
End
GO
