USE TS_ShirinVatanKarkhaneh_1_1404
GO
SET ANSI_NULLS, QUOTED_IDENTIFIER ON
GO
-- =========== TS-QC:UPDATED ====================
-- Author		 : TakroSystem\Ahmadnejad
-- Creation date : 1387/11/07
-- Viewed By	 : 
-- Last Modified : 1387/11/10
-- Last Modifier : TakroSystem\Ahmadnejad
-- Description	 : لیست کسورات غیرمستمر
-- ==============================================
CREATE PROCEDURE [prs].[RptPrs_Deductions2] 
	@MonthCodeFr	TinyInt = Null,
	@MonthCodeTo	TinyInt = Null,
	@PersonnelIDFr	VarChar(20) = Null,
	@PersonnelIDTo	VarChar(20) = Null,
	@DeductionID	VarChar(20) = Null ,
	@RepOptions		VarChar(50) = '00110',  -- bit array options
	@RepInfo		NVarChar(100) = '1@1@1'
WITH ENCRYPTION
AS 
DECLARE	@LangID				Char(1);
DECLARE	@SessionNo			Int; 
DECLARE	@ReportID			Int; 
DECLARE	@UserID				Int;
DECLARE	@UserIsAdmin		bit;
DECLARE @StrSelect	NVarChar(4000);
DECLARE @StrFrom	NVarChar(4000);
DECLARE @StrWhere	NVarChar(4000);
DECLARE @StrFieldsSum1	NVarChar(4000);
Begin 
	--============== S T A R T  C O D E =======================================

	SET NOCOUNT ON;
	SET @LangID				= pub.funSplitString(@RepInfo, '@', 1);
	SET @SessionNo			= pub.funSplitString(@RepInfo, '@', 2);
	SET @ReportID			= pub.funSplitString(@RepInfo, '@', 3);
	SET @UserID				= pub.funSplitString(@RepInfo, '@', 4);
	SET @UserIsAdmin		= pub.funSplitString(@RepInfo, '@', 5); 

	---- Init ------------------------------------------
	SET @LangID = Str(LTrim(pub.funGetCurrentLanguageID()));
	IF @LangID = '' SET @LangID = '1'
	---------------------------------------------------

	SET @StrWhere = '(1 = 1)'

	IF (@MonthCodeFr Is Not Null)
		SET	@StrWhere = @StrWhere + ' AND S.MonthCode >= ' + Str(LTrim(@MonthCodeFr))

	IF (@MonthCodeTo Is Not Null)
		SET	@StrWhere = @StrWhere + ' AND S.MonthCode <= ' + Str(LTrim(@MonthCodeTo))
	
	IF (@PersonnelIDFr Is Not Null)
		SET	@StrWhere = @StrWhere + ' AND S.PersonnelID >= ''' + @PersonnelIDFr + ''''

	IF (@PersonnelIDTo Is Not Null)
		SET	@StrWhere = @StrWhere + ' AND S.PersonnelID <= ''' + @PersonnelIDTo + ''''

	IF (@DeductionID Is Not Null)
		SET @StrFieldsSum1 = 'DeductionU' + LTrim(@DeductionID)
	Else
		EXEC [pub].[SpConcatSimilarCols] 'prs', 'tblUnContinuumDeductionsDtl', 'DeductionU', '+', @StrFieldsSum1 OUTPUT

	IF @StrFieldsSum1 = ''
		SET @StrFieldsSum1 = '0'

---------------------------------------
	if @UserIsAdmin=0 and (select count(*) from prs.tblPersonnelsRng) >0
	begin
		--If (@ExternalCall = 0) 
		begin
			BEGIN TRY
				DROP TABLE #Personnel
			END TRY
			BEGIN CATCH
			END CATCH
		END
		CREATE TABLE #Personnel
		(
			PersonnelID 			Varchar(20)collate arabic_cs_as null
		)
	
		Insert into  #Personnel (PersonnelID)	SELECT Distinct PersonnelID from prs.tblPersonnels
	 
		exec pub.SpFilterByPermission2 '#Personnel@1', 'PersonnelID', 'prs.tblPersonnels', @UserID;
		
		SET @StrWhere =   @StrWhere +' and S.PersonnelID in (SELECT PersonnelID FROM  #Personnel ) '

	END

	-----------------------------------------

	SET @StrSelect = '
	SELECT	PH.PersonnelID, PD.FirstName + '' '' + PD.LastName AS PersonnelName, SUM(' + @StrFieldsSum1 + ') As Amount
	FROM 	prs.tblSalaryCalculation S 
				INNER JOIN prs.tblPersonnels    PH ON S.PersonnelID = PH.PersonnelID 
				INNER JOIN prs.tblPersonnelsDtl PD ON S.PersonnelID = PD.PersonnelID AND PD.LanguageID = ' + Str(@LangID) + '
				INNER JOIN prs.tblUnContinuumDeductionsDtl U ON U.MonthCode = S.MonthCode AND U.PersonnelID = S.PersonnelID
	WHERE	' + @StrWhere + '
	GROUP BY PH.PersonnelID, PD.FirstName, PD.LastName
	ORDER BY PH.PersonnelID '
	
	Print @StrSelect;
	EXEC sp_executesql @StrSelect;
End
GO
