USE TS_ShirinVatanKarkhaneh_1_1404
GO
SET ANSI_NULLS, QUOTED_IDENTIFIER ON
GO
-- =========== TS-QC:UPDATED ====================
-- Author		 : Takrosystem\Ahmadnejad
-- Create date   : 1386/06/04
-- Viewed By	 : 
-- Last Modified : 1387/10/22
-- Last Modifier : Takrosystem\Ahmadnejad
-- Description	 : گزارش سالیانه حسابها
-- =============================================
CREATE PROCEDURE [acc].[RptAccounts_Year_Statistics] 
	@AcntCodeFrom	VarChar(20),
	@AcntCodeTo		VarChar(20),
	@UserID			Int = Null, 
	@ReportID		Int = Null,
	@ObjectID		TinyInt = 1,
	@SelectedCodes	Bit = 0, -- If SelectedCodes Is Not Zero Then AcntCodes Will Select from SLC Tables
	@LanguageID		TinyInt	= 1
WITH ENCRYPTION
AS
	Declare @LayerLen  AS TinyInt
	Declare @StrSelect AS NVarChar(2000);
	Declare @StrAcnt   AS NVarChar(100);
	Declare @StrWhere  AS NVarChar(2000);
Begin --=============== S T A R T  C O D E ==============================================

	SET NOCOUNT ON;

	--SET @LanguageID = pub.funGetCurrentLanguageID();

	-- Init Variables -----------------
	If (@SelectedCodes Is Null) 
		Set @SelectedCodes = 0;

	Set @LayerLen = Len(@AcntCodeFrom);

	If (@LayerLen = 0) Or (@LayerLen Is Null)
		Select	@LayerLen = Layer1 + Layer2 + Layer3 + Layer4 + Layer5 + Layer6 + Layer7 + Layer8 + Layer9
		From	pub.tblCodeLayer 
		Where	PartNumber = 1 AND TableName = 'acc.tblAcnt'

	Set @StrAcnt  = 'LEFT(LTrim(RTrim(AcntCode)), ' + LTRim(STr(@LayerLen)) + ')'

	-- Where Clause -------------------
	Set @StrWhere = '(VchKind <> 0)'

	If (@AcntCodeFrom Is Not Null) And (Len(Ltrim(@AcntCodeFrom)) <> 0)
		Set @StrWhere = @StrWhere + ' AND ' + @StrAcnt + ' >= ''' + LTrim(RTrim(@AcntCodeFrom)) + ''''

	If (@AcntCodeTo Is Not Null) AND (Len(LTrim(@AcntCodeTo)) <> 0)
		Set @StrWhere = @StrWhere + ' AND ' + @StrAcnt + ' <= ''' + LTrim(RTrim(@AcntCodeTo)) + ''''

	--- SLC ----------------------------------------
	If (@SelectedCodes = 1)
		Set @StrWhere = @StrWhere + ' AND AcntCode IN (
			SELECT	DISTINCT A.AcntCode
			FROM	acc.tblVoucherDtl A, acc.tblAcntSlc S
			WHERE	LEFT(A.AcntCode, Len(S.AcntCode)) = S.AcntCode AND
					UserID = ' + LTrim(Str(@UserID)) + ' AND 
					ReportID = ' + LTrim(Str(@ReportID)) + ' AND 
					ObjectID = ' + LTrim(Str(@ObjectID)) + ') '
	-- --------------------------------
	-- Select Clause ------------------
	Set @StrSelect = '
	Declare @idx1 Int
	Create Table #tblMonths
	(
		Months Char(2) Collate Arabic_CS_AS
	)
	Set @idx1 = 1
	While (@idx1 <= 12)
	Begin
		INSERT INTO #tblMonths
		VALUES (CASE WHEN Len(LTrim(Str(@idx1))) < 2 Then ''0'' Else '''' End + LTrim(Str(@idx1)))

		Set @idx1 = @idx1 + 1
	End;

	SELECT T.AcntCode, T.MonthNo, SUM(T.Debit) AS Debit, SUM(T.Credit) AS Credit, pub.GetCodeName(AcntCode, ' + LTrim(Str(@LanguageID)) + ') AcntName
	FROM
	(
		SELECT	' + @StrAcnt + ' AS AcntCode, Substring(DocDate, 6, 2) MonthNo, Debit, Credit 
		FROM	acc.tblVoucherDtl
		WHERE	' + @StrWhere + '
		UNION all
		SELECT	M.AcntCode, Months, 0, 0
		FROM	#tblMonths
		CROSS JOIN
		(
			SELECT	DISTINCT ' + @StrAcnt + ' AS AcntCode
			FROM	acc.tblVoucherDtl
			WHERE	' + @StrWhere + '
		) M
	) T
	WHERE Len(' + @StrAcnt + ') = ' + LTrim(Str(@LayerLen)) + '
	GROUP BY T.AcntCode, T.MonthNo
	ORDER BY T.AcntCode, T.MonthNo '
	-- --------------------------------
--	Print @StrSelect;
	Exec sp_executesql @StrSelect;
End
GO
