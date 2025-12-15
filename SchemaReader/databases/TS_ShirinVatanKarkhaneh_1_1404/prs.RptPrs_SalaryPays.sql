USE TS_ShirinVatanKarkhaneh_1_1404
GO
SET ANSI_NULLS, QUOTED_IDENTIFIER ON
GO
-- =========== TS-QC:UPDATED ====================
-- Author		 : TakroSystem\Zia
-- Create date   : 1387/06/26
-- Viewed By	 : 
-- Last Modified : 1389/09/15
-- Last Modifier : TakroSystem\Zia
-- Description	 : حقوق پرسنل
-- ==============================================
Create PROCEDURE [prs].[RptPrs_SalaryPays] 
	@ProcessID		Int = 300,
	@ProcessNo		Int = 1,
	@FiscalYear		Int = Null,
	@SerialNo		Int = Null,
	@FiscalYearTo	Int = Null,
	@SerialNoTo		Int = Null
WITH ENCRYPTION
AS 
Begin --============== S T A R T  C O D E =======================================

	SET NOCOUNT ON;
Declare @StrSelect	NVarChar(max)='';
Declare @StrSelectP	NVarChar(max)='';

DECLARE	@LangID		int;
DECLARE	@SessionNo	Int;
DECLARE	@ReportID	Int;

Declare @ExtraParams		NVarChar(Max);
	SELECT    @ExtraParams= Params  FROM         rpt.tblRptParams where SessionNo=@FiscalYearTo

Declare	@PersonnelIDs	Int ;

	SET @LangID		= pub.funSplitString(@ExtraParams, '@', 1);
	SET @SessionNo	= pub.funSplitString(@ExtraParams, '@', 2);
	SET @ReportID	= pub.funSplitString(@ExtraParams, '@', 3);
	SET @PersonnelIDs	= LTrim(pub.funSplitString(@ExtraParams, '@', 6));  
	SET @FiscalYearTo	= LTrim(pub.funSplitString(@ExtraParams, '@', 7));  

	IF (@PersonnelIDs > 0)
		SET @StrSelectP = @StrSelectP + ' AND ' + pub.funGetFilterString(@SessionNo, @ReportID, @PersonnelIDs, 'D.PersonnelID') 
	
	-- SELECT Clause ----------------------------------------
set @StrSelect='	SELECT	D.*,H.DocDesc, H.DocDate, H.MonthCode, H.AcntCode, H.VchNo,pr.NationalIDNumber, F.AcntName, P.FirstName + '' '' + P.LastName AS PersonnelName
	FROM	prs.tblSalaryPaysHdr H
				inner JOIN prs.tblSalaryPaysDtl D ON D.SerialNo = H.SerialNo and D.ProcessID = H.ProcessID
				LEFT JOIN prs.tblPersonnelsDtl P ON P.PersonnelID = D.PersonnelID And P.LanguageID = '+LTRIM(RTrim(str(@LangID)))+'
				INNER JOIN prs.tblPersonnels  pr on pr.PersonnelID= P.PersonnelID 
				OUTER APPLY acc.funGetCodeInfo(H.AcntCode) F 
	WHERE 	D.ProcessID = '+ str(@ProcessID )+' AND D.SerialNo >= '+ str(@SerialNo )+'  AND D.SerialNo <= '+ str(@SerialNoTo )+' 
	'+ @StrSelectP +'
	order by SerialNo,DocRowNo'
	------------------------------------------------------------
	-- RUN -----------------------------------------------------
	Print @StrSelect;
	Exec sp_executesql @StrSelect;
	
End
GO
