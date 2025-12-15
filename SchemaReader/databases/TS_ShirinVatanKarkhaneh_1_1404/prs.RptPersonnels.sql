USE TS_ShirinVatanKarkhaneh_1_1404
GO
SET ANSI_NULLS, QUOTED_IDENTIFIER ON
GO
-- =========== TS-QC:UPDATED ====================
-- Author		 : TakroSystem\Ahmadnejad
-- Create date   : 1387/06/09
-- Viewed By	 : 
-- Last Modified : 1388/04/20
-- Last Modifier : TakroSystem\Ahmadnejad
-- Description	 : مشخصات پرسنل
-- ===============================================
CREATE PROCEDURE [prs].[RptPersonnels]
	@SelectedPrs	Int = 0,
	@RepOptions		varchar(20) = '110',
	@RepInfo		NVarChar(100) = '1@1@1' -- bit array options
WITH ENCRYPTION
AS

DECLARE @StrSelect		NVarChar(4000);
DECLARE @StrWhere		NVarChar(2000);
DECLARE @SortByName		Bit;
DECLARE @InactivePrs	Bit;
DECLARE @ClosedPrs		Bit;

DECLARE	@LangID			Char(1);
DECLARE	@SessionNo		Int; -- برای حالت کدهای انتخابی
DECLARE	@ReportID		Int; -- برای حالت کدهای انتخابی

BEGIN 
	--============================ S T A R T ===============================================

	SET NOCOUNT ON;

	--=== INIT =========================================================================
	IF (@RepInfo		Is Null)	SET @RepInfo = '1@1@1';
	IF (@SelectedPrs	Is Null)	SET @SelectedPrs = 0;

	SET @LangID		= pub.funSplitString(@RepInfo, '@', 1);
	SET @SessionNo	= pub.funSplitString(@RepInfo, '@', 2);
	SET @ReportID	= pub.funSplitString(@RepInfo, '@', 3);

	SET @SortByName	= Substring(@RepOptions, 1, 1);
	SET @InactivePrs= Substring(@RepOptions, 2, 1);
	SET @ClosedPrs	= Substring(@RepOptions, 3, 1);
	--=== WHERE =========================================================================
	SET @StrWhere = '(H.PersonnelID <> '''')';

	if (@ClosedPrs = 0)
		SET @StrWhere = @StrWhere + ' AND (H.CodeClosed = 0)'
	if (@InactivePrs = 0)
		SET @StrWhere = @StrWhere + ' AND (H.QuitJobDate = '''')'
	If (@SelectedPrs > 0)
		SET @StrWhere = @StrWhere + ' AND ' + pub.funGetFilterString(@SessionNo, @ReportID, @SelectedPrs, 'H.PersonnelID') 

	--=== SELECT ================================================================

	SET @StrSelect = '
			SELECT	H.*, D.*, D.FirstName + '' '' + D.LastName AS Name, I.PersonnelImage AS PersonnelImage,S.StudyName
		, pub.funGetLocationName(BirthPlace,'+ @LangID +')BirthPlaceName
		FROM	prs.tblPersonnels H 
					INNER JOIN prs.tblPersonnelsDtl D ON H.PersonnelID = D.PersonnelID AND D.LanguageID = ' + @LangID + '
					LEFT JOIN prs.tblStudiesDtl S on H.StudyID = S.StudyID
					LEFT  JOIN prs.tblPersonnelsImages I ON I.PersonnelID = H.PersonnelID
		WHERE  ' + @StrWhere
		
	If (@SortByName = 1)
		SET @StrSelect = @StrSelect + '
		ORDER By Name '
	Else
		SET @StrSelect = @StrSelect + '
		ORDER By H.PersonnelID '

	Print @StrSelect;	
	Exec sp_executesql @StrSelect;
	
END
GO
