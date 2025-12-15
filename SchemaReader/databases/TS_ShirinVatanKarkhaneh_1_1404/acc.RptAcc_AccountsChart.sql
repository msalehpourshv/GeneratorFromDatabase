USE TS_ShirinVatanKarkhaneh_1_1404
GO
SET ANSI_NULLS, QUOTED_IDENTIFIER ON
GO
-- =========== TS-QC:UPDATED ====================
-- Author        : TakroSystem\Ahmadnejad
-- Create date   : 1386/06/04
-- Viewed By	 : 
-- Last Modified : 1388/11/17
-- Last Modifier : Takrosystem\Ahmadnejad
-- Description   : نمودار مقایسه ای حسابها
-- =============================================
CREATE PROCEDURE [acc].[RptAcc_AccountsChart] 
	@SelectedAcnt1	Int = 0, 
	@SelectedAcnt2	Int = 0, 
	@SelectedAcnt3	Int = 0, 
	@SelectedAcnt4	Int = 0, 
	@DocDateFr		Char(10) = Null,
	@DocDateTo		Char(10) = Null,
	@RemainOnly		Bit = Null,
		-- 1 = Remain Only
		-- 0 = Debit & Credit Only
		-- Null = Both
	@ColCount		Int = 25, -- Columns Per Page
	@RepOptions		NVarChar(500) = '0',
	@RepInfo		NVarChar(100) = '1@1@1'
WITH ENCRYPTION
AS
DECLARE @StrSelect AS NVarChar(2000);
DECLARE @StrAcnt   AS VarChar(100);
DECLARE @StrWhere  AS NVarChar(2000);

DECLARE @AcntCode	VarChar(20);
Declare @LayerLen   TinyInt;

DECLARE	@LangID			Char(1);
DECLARE	@SessionNo		Int; -- برای حالت کدهای انتخابی
DECLARE	@ReportID		Int; -- برای حالت کدهای انتخابی
Begin --=============== S T A R T  C O D E ==============================================

	SET NOCOUNT ON;

	-- Init Variables -----------------
	IF (@RepInfo	Is Null)	SET @RepInfo = '1@1@1'
	IF (@SelectedAcnt1	Is Null)	SET @SelectedAcnt1 = 0
	IF (@SelectedAcnt2	Is Null)	SET @SelectedAcnt2 = 0
	IF (@SelectedAcnt3	Is Null)	SET @SelectedAcnt3 = 0
	IF (@SelectedAcnt4	Is Null)	SET @SelectedAcnt4 = 0

	SET @LangID		= pub.funSplitString(@RepInfo, '@', 1);
	SET @SessionNo	= pub.funSplitString(@RepInfo, '@', 2);
	SET @ReportID	= pub.funSplitString(@RepInfo, '@', 3);

	SELECT	@LayerLen = Layer1 + Layer2 + Layer3 + Layer4 + Layer5 + Layer6 + Layer7 + Layer8 + Layer9
	FROM	pub.tblCodeLayer 
	WHERE	(PartNumber = 1) AND (TableName = 'acc.tblAcnt')
		
	Set @StrAcnt  = 'LEFT(LTrim(RTrim(AcntCode)), ' + LTRim(STr(@LayerLen)) + ')'

	-- Set Where Clause ---------------
	Set @StrWhere = '(VchKind <> 0)'

	-- Acnt Filter 
	If (@SelectedAcnt1 > 0)
		SET @StrWhere = @StrWhere + ' AND ' + pub.funGetFilterString(@SessionNo, @ReportID, @SelectedAcnt1, 'AcntCode')
	If (@SelectedAcnt2 > 0)
		SET @StrWhere = @StrWhere + ' AND ' + pub.funGetFilterString(@SessionNo, @ReportID, @SelectedAcnt2, 'AcntCode')
	If (@SelectedAcnt3 > 0)
		SET @StrWhere = @StrWhere + ' AND ' + pub.funGetFilterString(@SessionNo, @ReportID, @SelectedAcnt3, 'AcntCode')
	If (@SelectedAcnt4 > 0)
		SET @StrWhere = @StrWhere + ' AND ' + pub.funGetFilterString(@SessionNo, @ReportID, @SelectedAcnt4, 'AcntCode')

	If (@DocDateFr Is Not Null)
		Set @StrWhere = @StrWhere + ' AND DocDate >= ''' + @DocDateFr + ''''
	If (@DocDateTo Is Not Null)
		Set @StrWhere = @StrWhere + ' AND DocDate <= ''' + @DocDateTo + ''''

	-- Select Clause ------------------
	Set @StrSelect = '
	DECLARE @MaxDebit  Float;
	DECLARE @MaxCredit Float;

	DECLARE @tblResult AS Table
	(
		AcntCode	VarChar(20),
		Debit		BigInt,
		Credit		BigInt,
		GroupID		Int
	);
	
	INSERT	INTO @tblResult
	SELECT	' + @StrAcnt + ' AS AcntCode, SUM(Debit) AS Debit, SUM(Credit) AS Credit,
			(Row_Number() Over ( ORDER BY ' + @StrAcnt + ')) / ' + LTrim(Str(@ColCount)) + ' GroupID
	FROM	acc.tblVoucherDtl
	WHERE	' + @StrWhere + '
	GROUP BY ' + @StrAcnt + '

	SELECT	@MaxDebit = Max(Debit), @MaxCredit = Max(Credit)
	FROM	@tblResult

	INSERT	INTO @tblResult
	SELECT	CHAR(9)+''ماکزیمم'', @MaxDebit, @MaxCredit, GroupID
	FROM	@tblResult
	GROUP BY GroupID

	SELECT	R.*, case when (R.AcntCode=CHAR(9)+''ماکزیمم'') then CHAR(9)+''ماکزیمم'' else pub.GetCodeName(R.AcntCode, 1) end AcntName
	FROM	@tblResult R
	ORDER BY GroupID, ' + @StrAcnt

	Print @StrSelect;
	Exec sp_executesql @StrSelect;
End
GO
