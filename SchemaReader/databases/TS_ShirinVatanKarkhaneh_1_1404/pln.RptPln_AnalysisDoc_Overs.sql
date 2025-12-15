USE TS_ShirinVatanKarkhaneh_1_1404
GO
SET ANSI_NULLS, QUOTED_IDENTIFIER ON
GO
-- =========== TS-QC:UPDATED ====================
-- Author		 : Ahmadnejad
-- Create date   : 1388/11/03
-- Viewed By	 : 
-- Last Modified : 
-- Description	 : 
-- =============================================
CREATE PROCEDURE [pln].[RptPln_AnalysisDoc_Overs]
	@ProcessID		int,
	@ProcessNo		int,
	@FiscalYearFr	int,
	@SerialNoFr		int,
	@FiscalYearTo	int,
	@SerialNoTo		int,
	@RepInfo		varchar(10) = '1@1@1'
WITH ENCRYPTION
AS
DECLARE	@LangID		Int;
DECLARE	@SessionNo	Int; 
DECLARE	@ReportID	Int; 
Begin

	IF (@RepInfo Is Null)	SET @RepInfo = '1@1@1';

	SET @LangID		= pub.funSplitString(@RepInfo, '@', 1);
	SET @SessionNo	= pub.funSplitString(@RepInfo, '@', 2);
	SET @ReportID	= pub.funSplitString(@RepInfo, '@', 3);

	SELECT	D.*, pub.GetCodeName(D.AcntCode, 1) AcntName
	FROM	pln.tblProduceAnalysisOvers D 
	WHERE 	D.ProcessID = @ProcessID AND D.ProcessNo = @ProcessNo AND
			D.FiscalYear >= @FiscalYearFr AND D.SerialNo >= @SerialNoFr AND
			D.FiscalYear <= @FiscalYearTo AND D.SerialNo <= @SerialNoTo
End
GO
