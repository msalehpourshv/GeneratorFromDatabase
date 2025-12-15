USE TS_ShirinVatanKarkhaneh_1_1404
GO
SET ANSI_NULLS, QUOTED_IDENTIFIER ON
GO
-- =========== TS-QC:UPDATED ====================
-- Author		 : TakroSystem\Ahmadnejad
-- Creation Date : 1389/03/26
-- Viewed By	 : 
-- Last Modified : 1389/08/30
-- Last Modifier : 
-- Description	 :
-- =============================================
CREATE PROCEDURE [rpt].[SpRpt_FilterText]
	@RepInfo	NVarChar(100) = '1@1@1'
WITH ENCRYPTION
AS
DECLARE	@LangID		Char(1);
DECLARE	@SessionNo	Int; 
DECLARE	@ReportID	Int; 
BEGIN

	SET @LangID		= pub.funSplitString(@RepInfo, '@', 1);
	SET @SessionNo	= pub.funSplitString(@RepInfo, '@', 2);
	SET @ReportID	= pub.funSplitString(@RepInfo, '@', 3);

	SELECT FilterType, AppendType, CodeFrom, CodeTo, ObjectID, FieldText, NameFrom, NameTo
	FROM rpt.tblFilters
	WHERE SessionNo = @SessionNo and ReportID = @ReportID and FilterType = 1
	UNION
	SELECT FilterType, AppendType, CodeFrom, CodeTo, ObjectID, FieldText + ' - قسمت آخر کد', NameFrom, NameTo
	FROM rpt.tblFilters
	WHERE SessionNo = @SessionNo and ReportID = @ReportID and FilterType = 2
	UNION
	SELECT FilterType, AppendType, CodeFrom, CodeTo, ObjectID, FieldText + ' - کد مشابه با', NameFrom, NameTo
	FROM rpt.tblFilters
	WHERE SessionNo = @SessionNo and ReportID = @ReportID and FilterType = 3
	UNION
	SELECT FilterType, AppendType, CodeFrom, CodeTo, ObjectID, FieldText + ' - بخشی از کد', NameFrom, NameTo
	FROM rpt.tblFilters
	WHERE SessionNo = @SessionNo and ReportID = @ReportID and FilterType = 4
	UNION
	SELECT FilterType, AppendType, CodeFrom, CodeTo, ObjectID, FieldText + ' - قسمت اول کد', NameFrom, NameTo
	FROM rpt.tblFilters
	WHERE SessionNo = @SessionNo and ReportID = @ReportID and FilterType = 8
	ORDER BY ObjectID
END
GO
