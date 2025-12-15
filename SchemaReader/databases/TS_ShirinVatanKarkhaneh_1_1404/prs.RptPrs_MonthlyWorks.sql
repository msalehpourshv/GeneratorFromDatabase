USE TS_ShirinVatanKarkhaneh_1_1404
GO
SET ANSI_NULLS, QUOTED_IDENTIFIER ON
GO
-- =========== TS-QC:UPDATED ====================
-- Author		 : TakroSystem\Ahmadnejad
-- Create date   : 1387/06/25
-- Viewed By	 : 
-- Last Modified : 1389/09/08
-- Last Modifier : TakroSystem\Soltani
-- Description	 : کارکرد ماهیانه پرسنل
-- ==============================================
Create  PROCEDURE [prs].[RptPrs_MonthlyWorks]
	@MonthCode		TinyInt,
	@RepOptions		VarChar(100) = '000',  -- bit array options
	@RepInfo		NVarChar(100) = '1@1@1'
 WITH ENCRYPTION
AS 
	DECLARE @LanguageID		TinyInt;
	DECLARE	@LangID			Char(1);
	DECLARE	@SessionNo		Int; 
	DECLARE	@ReportID		Int; 
	DECLARE	@UserID			Int;
	DECLARE	@UserIsAdmin	bit;
Begin --============== S T A R T  C O D E =======================================

	SET NOCOUNT ON;
	IF (@RepInfo		Is Null)	SET @RepInfo = '1@1@1'
	SET @LangID				= pub.funSplitString(@RepInfo, '@', 1);
	SET @SessionNo			= pub.funSplitString(@RepInfo, '@', 2);
	SET @ReportID			= pub.funSplitString(@RepInfo, '@', 3);
	SET @UserID				= pub.funSplitString(@RepInfo, '@', 4);
	SET @UserIsAdmin		= pub.funSplitString(@RepInfo, '@', 5);

		-- Init ------------------------------------------
	SET @LanguageID = pub.funGetCurrentLanguageID();
	--------------------------------------------------
	if @UserIsAdmin=0 and (select count(*) from prs.tblPersonnelsRng) >0
	begin
		BEGIN TRY
			DROP TABLE #Personnel
		END TRY
		BEGIN CATCH
		END CATCH
		CREATE TABLE #Personnel
		(
			PersonnelID 			Varchar(20)collate arabic_cs_as null
		)
	
		Insert into  #Personnel (PersonnelID)	SELECT Distinct PersonnelID from prs.tblPersonnels
	 
		exec pub.SpFilterByPermission2 '#Personnel@1', 'PersonnelID', 'prs.tblPersonnels', @UserID;
		
		SELECT	D.*			, P.FirstName + ' ' + P.LastName AS PersonnelName
		FROM	prs.tblFunctionsDtl D
					LEFT JOIN prs.tblPersonnelsDtl P ON P.PersonnelID = D.PersonnelID AND P.LanguageID = @LanguageID
		WHERE 	MonthCode = @MonthCode and D.PersonnelID in (SELECT PersonnelID FROM  #Personnel ) 

	END
	else
	-- SELECT Clause ----------------------------------------
	SELECT	D.*
		, P.FirstName + ' ' + P.LastName AS PersonnelName

	FROM	prs.tblFunctionsDtl D
				LEFT JOIN prs.tblPersonnelsDtl P ON P.PersonnelID = D.PersonnelID AND P.LanguageID = @LanguageID
	WHERE 	MonthCode = @MonthCode 
	------------------------------------------------------------
End
GO
