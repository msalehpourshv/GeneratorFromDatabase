USE TS_ShirinVatanKarkhaneh_1_1404
GO
SET ANSI_NULLS, QUOTED_IDENTIFIER ON
GO
-- =========== TS-QC:UPDATED ====================
-- Author		 : TakroSystem\Ahmadnejad
-- Create date   : 1387/06/26
-- Viewed By	 : 
-- Last Modified : 1390/09/21
-- Last Modifier : TakroSystem\Zia
-- Description	 : مساعده پرسنل
-- ==============================================
CREATE PROCEDURE [prs].[RptPrs_Advances]
	@ProcessID		Int = 90,
	@ProcessNo		Int = 1,
	@FiscalYear		Int = Null,
	@SerialNo		Int = Null,
	@FiscalYearTo	Int = Null,
	@SerialNoTo		Int = Null
WITH ENCRYPTION
AS

DECLARE @StrSelect	NVarChar(Max);
DECLARE @StrFrom	NVarChar(Max);
DECLARE @StrWhere	NVarChar(Max);

Begin --============== S T A R T  C O D E =======================================

	SET NOCOUNT ON;

	-- Init ------------------------------------------
	IF (@ProcessNo Is Null)		SET @ProcessNo = 1;
	IF (@SerialNoTo Is Null)	SET @SerialNoTo = @SerialNo;
	IF (@FiscalYearTo Is Null)	SET @FiscalYearTo = @FiscalYear;
	
	SET @StrWhere = '1 = 1'
	
	-------------------------------------------------- From
	--Set @ProcessID = 311
	IF @ProcessID = 310
			SET @StrFrom = 'prs.tblAdvancesHdr H
		LEFT JOIN prs.tblAdvancesDtl D ON D.SerialNo = H.SerialNo
		'
	ELSE IF @ProcessID = 311
			SET @StrFrom = 'prs.tblAdvancesRequestHdr H
		LEFT JOIN prs.tblAdvancesRequestDtl D ON D.SerialNo = H.SerialNo
		'	
	
	-------------------------------------------------- Where
	IF (@SerialNo Is Not Null) And (@SerialNo > 0)
		SET @StrWhere = @StrWhere + ' AND H.SerialNo = ' + LTrim(RTrim(Str(@SerialNo)))
		
	-- SELECT Clause ----------------------------------------
	SET @StrSelect = '
		SELECT	D.*,H.DocDesc, H.DocDate, H.MonthCode, H.AcntCode, H.VchNo, F.AcntName, P.FirstName + '' '' + P.LastName AS PersonnelName
		FROM	' + @StrFrom + '
		LEFT JOIN prs.tblPersonnelsDtl P ON P.PersonnelID = D.PersonnelID 
		OUTER APPLY acc.funGetCodeInfo(H.AcntCode) F
		WHERE 	' + @StrWhere 
	------------------------------------------------------------
	Print @StrSelect;
	EXEC sp_executesql @StrSelect;
	
END
GO
