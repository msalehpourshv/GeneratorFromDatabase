USE TS_ShirinVatanKarkhaneh_1_1404
GO
SET ANSI_NULLS, QUOTED_IDENTIFIER ON
GO
-- =========== TS-QC:UPDATED ====================
-- Author		 : TakroSystem\Ahmadnejad
-- Create date   : 1387/06/25
-- Viewed By	 : 
-- Last Modified : 1387/07/03
-- Last Modifier : TakroSystem\Ahmadnejad
-- Description	 : برگ احکام پرسنل
-- ==============================================
Create PROCEDURE [prs].[RptPrs_Decrees]
	@PersonnelID	VarChar(20),
	@SerialNo		Int
WITH ENCRYPTION
AS 
DECLARE @LanguageID TinyInt;
Begin 
	--============== S T A R T  C O D E =======================================

	SET NOCOUNT ON;

	---- Init ------------------------------------------
	SET @LanguageID = pub.funGetCurrentLanguageID();
	----------------------------------------------------

	---- SELECT Clause ----------------------------------------
	SELECT	H.*, P.FirstName + ' ' + P.LastName AS PersonnelName, I.PersonnelImage,	DT.DecreeTypeName, WS.WorkShopName, DP.DepartmentName, J.JobName, IT.InsuranceTypeName,
			PH.NationalIDNumber, PH.IDNumber, PH.BirthDate, PH.BirthPlace, pub.funGetLocationName(BirthPlace,@LanguageID) AS BirthPlaceName, P.FatherName, PH.MaritalStatus, 
			PH.Sons, PH.Daughters, PH.Sons + PH.Daughters as ChildCount, PH.MilitaryStatus, PH.HireDate, PH.StudyID, prs.funGetStudyName(StudyID,@LanguageID) AS StudyName,
			PH.FieldID, prs.funGetFieldName(FieldID,@LanguageID) AS FieldName
	FROM	prs.tblDecreeHdr H 
			LEFT JOIN prs.tblPersonnels PH on PH.PersonnelID = H.PersonnelID
			LEFT JOIN prs.tblPersonnelsDtl P ON P.PersonnelID = H.PersonnelID
			Left Join prs.tblPersonnelsImages I On I.PersonnelID = H.PersonnelID
			LEFT JOIN prs.tblDecreeTypesDtl DT ON DT.DecreeTypeID = H.DecreeTypeID AND DT.LanguageID = @LanguageID
			LEFT JOIN prs.tblWorkShopsDtl WS ON WS.WorkShopID = H.WorkShopID AND WS.LanguageID = @LanguageID
			LEFT JOIN prs.tblDepartmentsDtl DP ON DP.DepartmentID = H.DepartmentID AND DP.LanguageID = @LanguageID
			LEFT JOIN prs.tblJobsDtl J ON J.JobID = H.JobID AND J.LanguageID = @LanguageID
			LEFT JOIN prs.tblInsuranceTypesDtl IT ON IT.InsuranceTypeID = H.InsuranceTypeID AND IT.LanguageID = @LanguageID
	WHERE 	(H.PersonnelID = @PersonnelID) AND (H.SerialNo = @SerialNo)
	------------------------------------------------------------
End
GO
