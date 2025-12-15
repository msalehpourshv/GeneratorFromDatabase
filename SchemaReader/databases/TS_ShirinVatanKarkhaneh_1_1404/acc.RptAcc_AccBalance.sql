USE TS_ShirinVatanKarkhaneh_1_1404
GO
SET ANSI_NULLS, QUOTED_IDENTIFIER ON
GO
-- =========== TS-QC:UPDATED ====================
-- Author		 : TakroSystem\Ahmadnejad
-- Creation Date : 1391/02/23
-- Viewed By	 : 
-- Last Modified : 1391/02/23
-- Last Modifier : TakroSystem\Zia
-- Description   : 
-- ==============================================
CREATE PROCEDURE [acc].[RptAcc_AccBalance]
	@PartNo			TinyInt, -- شماره بخش
	@LevelNo		TinyInt, -- طول لایه - اگر بخش یک باشد یا بخش یک نباشد ولی کد بصورت کامل خواسته شود این پارامتر طول کامل کد والا طول کد در آن بخش را می پذیرد
	@AcntCode1		varchar(20) = null,
	@AcntCode2		varchar(20) = null,
	@AcntCode3		varchar(20) = null,
	@AcntCode4		varchar(20) = null,
	@SelectedAcnt1	int = 0,
	@SelectedAcnt2	int = 0,
	@SelectedAcnt3	int = 0,
	@SelectedAcnt4	int = 0,
	@SerialNoFr		int = Null,
	@SerialNoTo		int = Null,
	@DocDateFr		Char(10) = Null,
	@DocDateTo		Char(10) = Null,
	@DebitRemainFr	float = Null,
	@DebitRemainTo	float = Null,
	@CreditRemainFr	float = Null,
	@CreditRemainTo	float = Null,
	@DebitCycleFr	float = Null,
	@DebitCycleTo	float = Null,
	@CreditCycleFr	float = Null,
	@CreditCycleTo	float = Null,
	@SortFields		NVarChar(100) = Null,
	@RepOptions		varchar(20) = '0011101',
	@RepInfo		NVarChar(100) = '1@1@1'
WITH ENCRYPTION
AS
Declare @ZeroRemain		Bit;
Declare @ZeroCycles		Bit;
Declare @ShowPrimar		Bit;
Declare @ShowFinish		Bit;
Declare @ShowClosed		Bit;
Declare @ExtraCodes		Bit;
Declare @UserIsAdmin	Bit;

DECLARE	@LangID			Char(1);
DECLARE	@SessionNo		Int; 
DECLARE	@ReportID		Int; 
DECLARE	@UserID			Int;

Declare @StrSelect	NVarChar(max);
Declare @StrSelectZ	NVarChar(max);
Declare @StrFrom	NVarChar(max);
Declare @StrWhere	NVarChar(max);
Declare @StrWhereP	NVarChar(max);
Declare @StrWhereA	NVarChar(max);
Declare @StrHaving	NVarChar(max);
Declare @StrPartAcntCode	VarChar(20);

Declare @iAcntStart	TinyInt;
Declare @iAcntLen	TinyInt;
Declare @iTempLen	TinyInt;
Declare @pPartLen	TinyInt;
Declare @pAcntStart	TinyInt;
Declare @pAcntLen	TinyInt;

Declare @Part1Start	TinyInt;
Declare @Part1Len	TinyInt;

Declare @Part2Start	TinyInt;
Declare @Part2Len	TinyInt;

Declare @Part3Start	TinyInt;
Declare @Part3Len	TinyInt;

Declare @Part4Start	TinyInt;
Declare @Part4Len	TinyInt;

Declare @LimitState1	SmallInt;
Declare @LimitState2	SmallInt;
Declare @LimitState3	SmallInt;
Declare @LimitState4	SmallInt;

BEGIN -- ============================ S T A R T =====================================================

	SET NOCOUNT ON;
	
	-- Init -------------------------------------------------
	IF (@RepInfo Is Null)		SET @RepInfo = '1@1@1';
	If (@SortFields is null)	SET @SortFields = 'AcntCode';
	IF (@RepOptions Is Null)	SET @RepOptions = '0011101';

	IF (@SelectedAcnt1 Is Null)	SET @SelectedAcnt1 = 0;
	IF (@SelectedAcnt2 Is Null)	SET @SelectedAcnt2 = 0;
	IF (@SelectedAcnt3 Is Null)	SET @SelectedAcnt3 = 0;
	IF (@SelectedAcnt4 Is Null)	SET @SelectedAcnt4 = 0;

	SET @LangID		= pub.funSplitString(@RepInfo, '@', 1);
	SET @SessionNo	= pub.funSplitString(@RepInfo, '@', 2);
	SET @ReportID	= pub.funSplitString(@RepInfo, '@', 3);
	SET @UserID		= pub.funSplitString(@RepInfo, '@', 4);

	SET @ZeroRemain	= Substring(@RepOptions, 1, 1)
	SET @ZeroCycles	= Substring(@RepOptions, 2, 1)
	SET @ShowPrimar = Substring(@RepOptions, 3, 1)
	SET @ShowFinish	= Substring(@RepOptions, 4, 1)
	SET @ShowClosed	= Substring(@RepOptions, 5, 1)
	SET @ExtraCodes	= Substring(@RepOptions, 6, 1)
	SET @UserIsAdmin= Substring(@RepOptions, 7, 1)

	If @UserIsAdmin = 1
	Begin
		SET	@LimitState1 = 1
		SET	@LimitState2 = 1
		SET	@LimitState3 = 1
		SET	@LimitState4 = 1
	End
	Else
	Begin
		SELECT	TOP 1 @LimitState1 = AccessAllCode
		FROM	acc.tblAcntRng
		WHERE	(UserID = @UserID) AND (PartNumber = 1)

		SET @LimitState1 = IsNull(@LimitState1, -1);

		SELECT	TOP 1 @LimitState2 = AccessAllCode
		FROM	acc.tblAcntRng
		WHERE	(UserID = @UserID) AND (PartNumber = 2)

		SET @LimitState2 = IsNull(@LimitState2, -1);

		SELECT	TOP 1 @LimitState3 = AccessAllCode
		FROM	acc.tblAcntRng
		WHERE	(UserID = @UserID) AND (PartNumber = 3)

		SET @LimitState3 = IsNull(@LimitState3, -1);

		SELECT	TOP 1 @LimitState4 = AccessAllCode
		FROM	acc.tblAcntRng
		WHERE	(UserID = @UserID) AND (PartNumber = 4)

		SET @LimitState4 = IsNull(@LimitState4, -1);
	End

	-------- LAYERS LEN CLAUSE -----------------------------------------------------------------------
	SELECT	@Part1Start = 1;
	SELECT	@Part1Len = Layer1 + Layer2 + Layer3 + Layer4 + Layer5 + Layer6 + Layer7 + Layer8 + Layer9 
	FROM	pub.tblCodeLayer 
	WHERE	(TableName = 'acc.tblAcnt') AND (PartNumber = 1)

	SELECT	@Part2Start = @Part1Start + @Part1Len + 1;
	SELECT	@Part2Len = Layer1 + Layer2 + Layer3 + Layer4 + Layer5 + Layer6 + Layer7 + Layer8 + Layer9 
	FROM	pub.tblCodeLayer 
	WHERE	(TableName = 'acc.tblAcnt') AND (PartNumber = 2)

	SELECT	@Part3Start = @Part2Start + @Part2Len + 1;
	SELECT	@Part3Len = Layer1 + Layer2 + Layer3 + Layer4 + Layer5 + Layer6 + Layer7 + Layer8 + Layer9 
	FROM	pub.tblCodeLayer 
	WHERE	(TableName = 'acc.tblAcnt') AND (PartNumber = 3)

	SELECT	@Part4Start = @Part3Start + @Part3Len + 1;
	SELECT	@Part4Len = Layer1 + Layer2 + Layer3 + Layer4 + Layer5 + Layer6 + Layer7 + Layer8 + Layer9 
	FROM	pub.tblCodeLayer 
	WHERE	(TableName = 'acc.tblAcnt') AND (PartNumber = 4)

	---- CALC LEN ----
	If (@PartNo=1)
	begin
		set @iTempLen = 0
		set @pAcntStart = @Part1Start
	end
		
	Else If (@PartNo=2)
	begin
		set @iTempLen = @Part1Start + @Part1Len
		set @pAcntStart = @Part2Start
	end

	Else If (@PartNo=3)
	begin
		set @iTempLen = @Part2Start + @Part2Len
		set @pAcntStart = @Part3Start
	end

	Else If (@PartNo=4)
	begin
		set @iTempLen = @Part3Start + @Part3Len
		set @pAcntStart = @Part4Start
	end

	set @pAcntLen = pub.funLayerSum('acc.tblAcnt', @PartNo, @LevelNo)
	Set @iAcntLen = @iTempLen + @pAcntLen
	Set @iAcntStart = 1
	
	print @pAcntStart
	print @pAcntLen

	--------  LAYERS LEN END  ---------------------------------------------------
	-------- CASE WHEN CLAUSE ---------------------------------------------------
	Declare @StrDebit	NVarChar(100);
	Declare @StrCredit	NVarChar(100);

	If (@DocDateFr Is Null) AND (@SerialNoFr Is Null)
	Begin                            --(Date = null & Serial = null)
		SET @StrDebit  = 'Debit '
		SET @StrCredit = 'Credit '
	End
	Else If (@DocDateFr Is Not Null) AND (@SerialNoFr Is Null)
	Begin                            --(Date <> null & Serial = null)
		Set @StrDebit   = 'CASE WHEN DocDate < ''' + @DocDateFr + ''' THEN 0 Else Debit  End '
		Set @StrCredit  = 'CASE WHEN DocDate < ''' + @DocDateFr + ''' THEN 0 Else Credit End '
	End
	Else If (@DocDateFr Is Null) AND (@SerialNoFr Is Not Null)
	Begin                            --(Date = null & Serial <> null) 
		SET @StrDebit   = 'CASE WHEN SerialNo >= ' + LTrim(Str(@SerialNoFr)) + ' THEN Debit  Else 0 End '
		SET @StrCredit  = 'CASE WHEN SerialNo >= ' + LTrim(Str(@SerialNoFr)) + ' THEN Credit Else 0 End '
	End
	Else -- (DateFrom <> Null  &  SerialNoFrom <> null)
	Begin
		Set @StrDebit   = 'CASE WHEN DocDate >= ''' + @DocDateFr + ''' AND SerialNo >= ' + LTrim(Str(@SerialNoFr)) + ' THEN Debit  Else 0 End '
		Set @StrCredit  = 'CASE WHEN DocDate >= ''' + @DocDateFr + ''' AND SerialNo >= ' + LTrim(Str(@SerialNoFr)) + ' THEN Credit Else 0 End '
	End
	------ CASE WHEN END -----------------------------------------------------

	------ WHERE CLAUSE ------------------------------------------------------
	SET @StrWhereA = '(1=1)';
	SET @StrWhereP = '';
	Set @StrWhere = ' (VchKind<>0) AND Len(AcntCode) >= ' + LTrim(Str(@iTempLen))

	If (@ShowPrimar = 0)
		Set @StrWhere = @StrWhere + ' AND (VchKind<>2)'

	If (@ShowFinish = 0)
		Set @StrWhere = @StrWhere + ' AND (VchKind<>3)'

	If (@ShowClosed = 0)
		Set @StrWhere = @StrWhere + ' AND (VchKind<>4)'
	
	if (@ExtraCodes <> 1)
	begin
		declare @P1L1	int;
		select	@P1L1 = [pub].[funLayerSum]('acc.tblAcnt', 1, 1)

		Set @StrWhere = @StrWhere  + ' AND Substring(AcntCode, 1, ' + LTrim(Str(@P1L1)) + ') not in (select AcntCode from acc.tblAcnt where (PartNumber=1) and (AcntType in (91,92)))'
	end

	-- Date To --
	If (@DocDateTo Is Not Null)
		SET @StrWhere = @StrWhere + ' AND (DocDate <= ''' + @DocDateTo + ''')'

	If (@SerialNoTo Is Not Null)
		SET @StrWhere = @StrWhere + ' AND (SerialNo <= ' + LTrim(Str(@SerialNoTo)) + ')'

	If (@SelectedAcnt1 > 0)
		SET @StrWhereA = @StrWhereA + ' AND ' + pub.funGetFilterString(@SessionNo, @ReportID, @SelectedAcnt1, 'D.AcntCode')
	If (@SelectedAcnt2 > 0)
		SET @StrWhereA = @StrWhereA + ' AND ' + pub.funGetFilterString(@SessionNo, @ReportID, @SelectedAcnt2, 'D.AcntCode')
	If (@SelectedAcnt3 > 0)
		SET @StrWhereA = @StrWhereA + ' AND ' + pub.funGetFilterString(@SessionNo, @ReportID, @SelectedAcnt3, 'D.AcntCode')
	If (@SelectedAcnt4 > 0)
		SET @StrWhereA = @StrWhereA + ' AND ' + pub.funGetFilterString(@SessionNo, @ReportID, @SelectedAcnt4, 'D.AcntCode')

	if (@AcntCode1 is not null)
		Set @StrWhereA = @StrWhereA + ' AND Substring(AcntCode, ' + LTrim(Str(@Part1Start)) + ', ' + LTrim(Str(Len(@AcntCode1))) + ') = ''' + LTrim(@AcntCode1) + ''' '
	if (@AcntCode2 is not null)
		Set @StrWhereA = @StrWhereA + ' AND Substring(AcntCode, ' + LTrim(Str(@Part2Start)) + ', ' + LTrim(Str(Len(@AcntCode2))) + ') = ''' + LTrim(@AcntCode2) + ''' '
	if (@AcntCode3 is not null)
		Set @StrWhereA = @StrWhereA + ' AND Substring(AcntCode, ' + LTrim(Str(@Part3Start)) + ', ' + LTrim(Str(Len(@AcntCode3))) + ') = ''' + LTrim(@AcntCode3) + ''' '
	if (@AcntCode4 is not null)
		Set @StrWhereA = @StrWhereA + ' AND Substring(AcntCode, ' + LTrim(Str(@Part4Start)) + ', ' + LTrim(Str(Len(@AcntCode4))) + ') = ''' + LTrim(@AcntCode4) + ''' '

	If (@LimitState1 = -1)
		Set @StrWhereP = @StrWhereP + ' AND LTrim(Substring(AcntCode, ' + LTrim(Str(@Part1Start)) + ', ' + LTrim(Str(@Part1Len)) + ')) = '''' '
	Else If (@LimitState1 = 0)
		Set @StrWhereP = @StrWhereP + '	AND acc.funPermitted(' + LTRim(Str(@UserID)) + ', Substring(AcntCode, ' + LTrim(Str(@Part1Start)) + ', ' + LTrim(Str(@Part1Len)) + '), 1)= 1 '
	If (@UserIsAdmin <> 1)
		Set @StrWhereP = @StrWhereP + '	AND acc.funPermitted2(' + LTRim(Str(@UserID)) + ', Substring(AcntCode, ' + LTrim(Str(@Part1Start)) + ', ' + LTrim(Str(@Part1Len)) + '), 1)= 1 '

	If (@LimitState2 = -1)
		Set @StrWhereP = @StrWhereP + '	AND LTrim(Substring(AcntCode, ' + LTrim(Str(@Part2Start)) + ', ' + LTrim(Str(@Part2Len)) + ')) = '''' '
	Else If (@LimitState2 = 0) 
		Set @StrWhereP = @StrWhereP + '	AND acc.funPermitted(' + LTRim(Str(@UserID)) + ', Substring(AcntCode, ' + LTrim(Str(@Part2Start)) + ', ' + LTrim(Str(@Part2Len)) + '), 2)= 1 '
	If (@UserIsAdmin <> 1)
		Set @StrWhereP = @StrWhereP + '	AND acc.funPermitted2(' + LTRim(Str(@UserID)) + ', Substring(AcntCode, ' + LTrim(Str(@Part2Start)) + ', ' + LTrim(Str(@Part2Len)) + '), 2)= 1 '

	If (@LimitState3 = -1)
		Set @StrWhereP = @StrWhereP + '	AND LTrim(Substring(AcntCode, ' + LTrim(Str(@Part3Start)) + ', ' + LTrim(Str(@Part3Len)) + ')) = '''' '
	Else If (@LimitState3 = 0) 
		Set @StrWhereP = @StrWhereP + '	AND acc.funPermitted(' + LTRim(Str(@UserID)) + ', Substring(AcntCode, ' + LTrim(Str(@Part3Start)) + ', ' + LTrim(Str(@Part3Len)) + '), 3)= 1 '
	If (@UserIsAdmin <> 1)
		Set @StrWhereP = @StrWhereP + '	AND acc.funPermitted2(' + LTRim(Str(@UserID)) + ', Substring(AcntCode, ' + LTrim(Str(@Part3Start)) + ', ' + LTrim(Str(@Part3Len)) + '), 3)= 1 '

	If (@LimitState4 = -1)
		Set @StrWhereP = @StrWhereP + '	AND LTrim(Substring(AcntCode, ' + LTrim(Str(@Part4Start)) + ', ' + LTrim(Str(@Part4Len)) + ')) = '''' '
	Else If (@LimitState4 = 0) 
		Set @StrWhereP = @StrWhereP + ' AND acc.funPermitted(' + LTRim(Str(@UserID)) + ', Substring(AcntCode, ' + LTrim(Str(@Part4Start)) + ', ' + LTrim(Str(@Part4Len)) + '), 4)= 1 '
	If (@UserIsAdmin <> 1)
		Set @StrWhereP = @StrWhereP + '	AND acc.funPermitted2(' + LTRim(Str(@UserID)) + ', Substring(AcntCode, ' + LTrim(Str(@Part4Start)) + ', ' + LTrim(Str(@Part4Len)) + '), 4)= 1 '

	Set @StrWhere = @StrWhere + ' and ' + @StrWhereA + @StrWhereP

	----- WHERE CLAUSE END ------------------------------------------------------

	----- HAVING CLAUSE ---------------------------------------------------------
	Set @StrHaving = '(1=1)'

	If (@ZeroRemain = 0) 
	Set @StrHaving = @StrHaving + ' and	Sum(Debit)<>Sum(Credit)'

	If (@DebitRemainFr Is Not Null)
	Set @StrHaving = @StrHaving + ' and Sum(Debit)-Sum(Credit) >= ' + LTrim(Str(@DebitRemainFr))

	If (@DebitRemainTo Is Not Null)
	Set @StrHaving = @StrHaving + ' and Sum(Debit)-Sum(Credit) <= ' + LTrim(Str(@DebitRemainTo))

	If (@CreditRemainFr Is Not Null)
	Set @StrHaving = @StrHaving + ' and	Sum(Credit)-Sum(Debit) >= ' + LTrim(Str(@CreditRemainFr))

	If (@CreditRemainTo Is Not Null)
	Set @StrHaving = @StrHaving + ' and Sum(Credit)-Sum(Debit) <= ' + LTrim(Str(@CreditRemainTo))
	
	If (@DebitCycleFr Is Not Null)
	Set @StrHaving = @StrHaving + ' and Sum(Debit) >= ' + LTrim(Str(@DebitCycleFr))

	If (@DebitCycleTo Is Not Null)
	Set @StrHaving = @StrHaving + ' and Sum(Debit) <= ' + LTrim(Str(@DebitCycleTo))

	If (@CreditCycleFr Is Not Null)
	Set @StrHaving = @StrHaving + ' and Sum(Credit) >= ' + LTrim(Str(@CreditCycleFr))

	-- Credit Cycle To
	If (@CreditCycleTo Is Not Null)
	Set @StrHaving = @StrHaving + ' and Sum(Credit) <= ' + LTrim(Str(@CreditCycleTo))

	--===== SELECT CLAUSE =======================================================

	set @StrSelectZ = ''
	
	If (@ZeroCycles = 1) AND (@ZeroRemain = 1) AND (@PartNo = 1) 
		set @StrSelectZ = '
		UNION ALL
		SELECT Substring(AcntCode, ' + LTrim(Str(@iAcntStart)) + ', ' + LTrim(Str(@iAcntLen)) + ') AS AcntCode,
				Substring(AcntCode, ' + LTrim(Str(@pAcntStart)) + ', ' + LTrim(Str(@pAcntLen)) + ') AS PartCode, 0, 0, 0, 0 
		FROM   acc.tblAcnt 
		WHERE  (PartNumber=1) and (Len(AcntCode)>=' + LTrim(Str(@iAcntStart+@iAcntLen-1)) + ') and ' + @StrWhereA + @StrWhereP
	
	Set @StrSelect = '
	SELECT	Cast(T.AcntCode AS VarChar(20)) AS AcntCode, 
			Cast(T.PartCode AS VarChar(20)) AS PartCode, A.AcntName,
			Sum(T.Debit) SumDebit, Sum(T.Credit) SumCredit, 
			Sum(T.DebitTotal) SumDebitTotal, Sum(T.CreditTotal) SumCreditTotal,
			case when Sum(T.Debit) > Sum(T.Credit) then Sum(T.Debit) - Sum(T.Credit) else 0 end RemainDebit,
			case when Sum(T.Debit) < Sum(T.Credit) then Sum(T.Credit) - Sum(T.Debit) else 0 end RemainCredit
			,  cast( 0 as float ) as SumDebitCredit
	FROM 
	(
		SELECT	Substring(AcntCode, ' + LTrim(Str(@iAcntStart)) + ', ' + LTrim(Str(@iAcntLen)) + ') AS AcntCode,
				Substring(AcntCode, ' + LTrim(Str(@pAcntStart)) + ', ' + LTrim(Str(@pAcntLen)) + ') AS PartCode, ' +
				@StrDebit + ' Debit, ' + @StrCredit + ' Credit, Debit DebitTotal, Credit CreditTotal
		FROM acc.tblVoucherDtl D
		WHERE ' + @StrWhere + @StrSelectZ + '
	) T	left join acc.tblAcntDtl A on A.AcntCode = T.PartCode and A.PartNumber = ' + LTrim(Str(@PartNo)) + '
	GROUP BY T.AcntCode, T.PartCode, A.AcntName
	HAVING ' + @StrHaving + '
	ORDER BY ' + @SortFields

	print @StrSelect;	
	exec sp_executesql @StrSelect;
END
GO
