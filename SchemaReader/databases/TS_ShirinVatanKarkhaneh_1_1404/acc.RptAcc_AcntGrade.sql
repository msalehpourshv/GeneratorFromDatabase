USE TS_ShirinVatanKarkhaneh_1_1404
GO
SET ANSI_NULLS, QUOTED_IDENTIFIER ON
GO
-- =========== TS-QC:UPDATED ====================
-- Author		 : TakroSystem\Ahmadnejad
-- Create date   : 1387/04/26
-- Viewed By	 : 
-- Last Modified : 1391/03/24
-- Description	 : گزارش امتیازدهی حسابها
-- =============================================
CREATE PROCEDURE [acc].[RptAcc_AcntGrade]
	@AcntCode1From	VarChar(20) = Null, -- Part 1
	@AcntCode1To	VarChar(20) = Null, -- Part 1
	@AcntCode2From	VarChar(20) = Null, -- Part 2
	@AcntCode2To	VarChar(20) = Null, -- Part 2
	@AcntCode3From	VarChar(20) = Null, -- Part 3
	@AcntCode3To	VarChar(20) = Null, -- Part 3
	@AcntCode4From	VarChar(20) = Null, -- Part 4
	@AcntCode4To	VarChar(20) = Null, -- Part 4
	@SerialNoFrom	Int = Null,
	@SerialNoTo		Int = Null,
	@BaseDate		Char(10) = Null, -- تاریخی که امتیازها باید تا آن روز حساب شود
	@BasePrice		BigInt = 50000000, -- مبلغ مبنای امتیاز بندی
	@SortFields		VarChar(100) = Null,
	@RepOptions		varchar(20) = '0001',
	@RepInfo		NVarChar(100) = Null
WITH ENCRYPTION
AS

DECLARE @StrSelect	NVarChar(max);
DECLARE @StrSelectR	NVarChar(max);
DECLARE @StrWhere	NVarChar(max);
DECLARE @StrWhereR	NVarChar(max);
DECLARE @StrWhereA	NVarChar(max);
DECLARE @StrWhereA1	NVarChar(max);
DECLARE @StrWhereA2	NVarChar(max);
DECLARE @StrWhereA3	NVarChar(max);
DECLARE @StrWhereA4	NVarChar(max);

declare	@ShowNoProgress	Bit; -- شامل کد حسابهائی که اصلاً گردشی در طول دوره ندارند باشد یا نه؟
declare	@ShowFinishDocs	Bit; -- شامل سند اختتامیه یا نه؟
declare	@UserID			Int; -- برای استفاده از کدهای انتخابی
declare	@ShowDesc		Bit; -- شامل ستون شرح باشد یا نه؟

DECLARE @Part1Start	TinyInt;
DECLARE @Part1Len	TinyInt;

DECLARE @Part2Start	TinyInt;
DECLARE @Part2Len	TinyInt;

DECLARE @Part3Start	TinyInt;
DECLARE @Part3Len	TinyInt;

DECLARE @Part4Start	TinyInt;
DECLARE @Part4Len	TinyInt;

DECLARE @PartStart	TinyInt;
DECLARE @PartLen	TinyInt;

DECLARE @LimitState1	SmallInt;
DECLARE @LimitState2	SmallInt;
DECLARE @LimitState3	SmallInt;
DECLARE @LimitState4	SmallInt;
Declare @PartNo			int;
Declare @AcntCode		varchar(512);
declare	@UserIsAdmin	Bit;     -- کاربر اعلام شده مدیر است یا نه؟
DECLARE	@LangID			Char(1);
DECLARE	@SessionNo		Int; -- برای حالت کدهای انتخابی
DECLARE	@ReportID		Int; -- برای حالت کدهای انتخابی

BEGIN 
-- ============================ S T A R T =====================================================

	SET NOCOUNT ON;

	SET @ShowNoProgress	= Substring(@RepOptions, 1, 1)
	SET @ShowFinishDocs	= Substring(@RepOptions, 2, 1)
	SET @ShowDesc		= Substring(@RepOptions, 3, 1)
	set @UserIsAdmin	= Substring(@RepOptions, 4, 1)
	
	SET @LangID		= pub.funSplitString(@RepInfo, '@', 1);
	SET @SessionNo	= pub.funSplitString(@RepInfo, '@', 2);
	SET @ReportID	= pub.funSplitString(@RepInfo, '@', 3);
	SET @UserID		= pub.funSplitString(@RepInfo, '@', 4);
	
	SET @PartNo = 0;
	SELECT @PartNo = SettingValue
	FROM pub.tblSettings
	WHERE SettingKey = 'AcntPartNumberForRemainCalculation'

	If (@BaseDate Is Null)
		SELECT @BaseDate = LEFT([pub].[funFarsiDate](GetDate()), 10)

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
	SET	@Part1Start = 1;
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
	
	if (@PartNo=0)
	begin
		set @PartNo = 1;
		
		if (@Part2Len > 0)
			set @PartNo = 2;
			
		if (@Part3Len > 0)
			set @PartNo = 3;
			
		if (@Part4Len > 0)
			set @PartNo = 4;
	end;
	
	if (@PartNo=1)
	begin
		set @PartStart = @Part1Start
		set @PartLen = @Part1Len
	end
	else if (@PartNo=2)
	begin
		set @PartStart = @Part2Start
		set @PartLen = @Part2Len
	end
	else if (@PartNo=3)
	begin
		set @PartStart = @Part3Start
		set @PartLen = @Part3Len
	end
	else 
	begin
		set @PartStart = @Part4Start
		set @PartLen = @Part4Len
	end

	set @AcntCode = 'Substring(AcntCode,' + ltrim(str(@PartStart)) + ',' + ltrim(str(@PartLen)) + ')'
	
	--==== WHERE CLAUSE ======================================================================
	SET @StrWhereA = '(AcntCode<>'''') AND Substring(AcntCode, 1, 2) not in (select AcntCode from acc.tblAcnt where (PartNumber=1) and (AcntType in (91,92)))'
	set @StrWhereR = @StrWhereA
	set @StrWhereA1 = ''
	set @StrWhereA2 = ''
	set @StrWhereA3 = ''
	set @StrWhereA4 = ''

	-- Acnt1 --
	IF (@AcntCode1From Is Not Null)
		SET @StrWhereA1 = @StrWhereA1 + ' AND AcntCode >= ''' + @AcntCode1From + ''''
	IF (@AcntCode1To Is Not Null)
		SET @StrWhereA1 = @StrWhereA1 + ' AND AcntCode <= ''' + @AcntCode1To + ''''

	-- Acnt2 --
	IF (@AcntCode2From Is Not Null)
		SET @StrWhereA2 = @StrWhereA2 + ' AND AcntCode >= ''' + @AcntCode2From + ''''
	IF (@AcntCode2To Is Not Null)
		SET @StrWhereA2 = @StrWhereA2 + ' AND AcntCode <= ''' + @AcntCode2To + ''''

	-- Acnt3 --
	IF (@AcntCode3From Is Not Null)
		SET @StrWhereA3 = @StrWhereA3 + ' AND AcntCode >= ''' + @AcntCode3From + ''''
	IF (@AcntCode3To Is Not Null)
		SET @StrWhereA3 = @StrWhereA3 + ' AND AcntCode <= ''' + @AcntCode3To + ''''

	-- Acnt4 --
	IF (@AcntCode4From Is Not Null)
		SET @StrWhereA4 = @StrWhereA4 + ' AND AcntCode >= ''' + @AcntCode4From + ''''
	If (@AcntCode4To Is Not Null)
		SET @StrWhereA4 = @StrWhereA4 + ' AND AcntCode <= ''' + @AcntCode4To + ''''

	-- Acnt1 --
	IF (@AcntCode1From Is Not Null)
		SET @StrWhereA = @StrWhereA + ' AND Substring(AcntCode,' + LTrim(Str(@Part1Start)) + ',' + LTrim(Str(@Part1Len)) + ') >= ''' + @AcntCode1From + ''''
	IF (@AcntCode1To Is Not Null)
		SET @StrWhereA = @StrWhereA + ' AND Substring(AcntCode,' + LTrim(Str(@Part1Start)) + ',' + LTrim(Str(@Part1Len)) + ') <= ''' + @AcntCode1To + ''''

	-- Acnt2 --
	IF (@AcntCode2From Is Not Null)
		SET @StrWhereA = @StrWhereA + ' AND Substring(AcntCode,' + LTrim(Str(@Part2Start)) + ',' + LTrim(Str(@Part2Len)) + ') >= ''' + @AcntCode2From + ''''
	IF (@AcntCode2To Is Not Null)
		SET @StrWhereA = @StrWhereA + ' AND Substring(AcntCode,' + LTrim(Str(@Part2Start)) + ',' + LTrim(Str(@Part2Len)) + ') <= ''' + @AcntCode2To + ''''

	-- Acnt3 --
	IF (@AcntCode3From Is Not Null)
		SET @StrWhereA = @StrWhereA + ' AND Substring(AcntCode,' + LTrim(Str(@Part3Start)) + ',' + LTrim(Str(@Part3Len)) + ') >= ''' + @AcntCode3From + ''''
	IF (@AcntCode3To Is Not Null)
		SET @StrWhereA = @StrWhereA + ' AND Substring(AcntCode,' + LTrim(Str(@Part3Start)) + ',' + LTrim(Str(@Part3Len)) + ') <= ''' + @AcntCode3To + ''''

	-- Acnt4 --
	IF (@AcntCode4From Is Not Null)
		SET @StrWhereA = @StrWhereA + ' AND Substring(AcntCode,' + LTrim(Str(@Part4Start)) + ',' + LTrim(Str(@Part4Len)) + ') >= ''' + @AcntCode4From + ''''
	If (@AcntCode4To Is Not Null)
		SET @StrWhereA = @StrWhereA + ' AND Substring(AcntCode,' + LTrim(Str(@Part4Start)) + ',' + LTrim(Str(@Part4Len)) + ') <= ''' + @AcntCode4To + ''''

	-- voucher --
	set @StrWhere = '(' + @AcntCode + '<>'''') and (DocDate <= ''' + @BaseDate + ''') and ' + @StrWhereA 
	
	If (@ShowFinishDocs = 1) 
		SET @StrWhere = @StrWhere + ' and (VchKind IN(1,2,3,4))'
	Else
		SET @StrWhere = @StrWhere + ' and (VchKind in(1,2))'

	-- Serial To --
	If (@SerialNoFrom Is Not Null)
		SET @StrWhere = @StrWhere + ' AND (SerialNo>=' + LTrim(Str(@SerialNoFrom)) + ')'
	If (@SerialNoTo Is Not Null)
		SET @StrWhere = @StrWhere + ' AND (SerialNo<=' + LTrim(Str(@SerialNoTo)) + ')'

	If (@LimitState1 = -1)
		SET @StrWhere = @StrWhere + ' AND LTrim(Substring(AcntCode, ' + LTrim(Str(@Part1Start)) + ', ' + LTrim(Str(@Part1Len)) + ')) = '''' '
	Else If (@LimitState1 = 0)
		SET @StrWhere = @StrWhere + ' AND acc.funPermitted(' + LTRim(Str(@UserID)) + ', Substring(AcntCode, ' + LTrim(Str(@Part1Start)) + ', ' + LTrim(Str(@Part1Len)) + '), 1)= 1 '

	If (@LimitState2 = -1)
		SET @StrWhere = @StrWhere + ' AND LTrim(Substring(AcntCode, ' + LTrim(Str(@Part2Start)) + ', ' + LTrim(Str(@Part2Len)) + ')) = '''' '
	If (@LimitState2 = 0) 
		SET @StrWhere = @StrWhere + ' AND acc.funPermitted(' + LTRim(Str(@UserID)) + ', Substring(AcntCode, ' + LTrim(Str(@Part2Start)) + ', ' + LTrim(Str(@Part2Len)) + '), 2)= 1 '

	If (@LimitState3 = -1)
		SET @StrWhere = @StrWhere + ' AND LTrim(Substring(AcntCode, ' + LTrim(Str(@Part3Start)) + ', ' + LTrim(Str(@Part3Len)) + ')) = '''' '
	If (@LimitState3 = 0) 
		SET @StrWhere = @StrWhere + ' AND acc.funPermitted(' + LTRim(Str(@UserID)) + ', Substring(AcntCode, ' + LTrim(Str(@Part3Start)) + ', ' + LTrim(Str(@Part3Len)) + '), 3)= 1 '

	If (@LimitState4 = -1)
		SET @StrWhere = @StrWhere + ' AND LTrim(Substring(AcntCode, ' + LTrim(Str(@Part4Start)) + ', ' + LTrim(Str(@Part4Len)) + ')) = '''' '
	If (@LimitState4 = 0) 
		SET @StrWhere = @StrWhere + ' AND acc.funPermitted(' + LTRim(Str(@UserID)) + ', Substring(AcntCode, ' + LTrim(Str(@Part4Start)) + ', ' + LTrim(Str(@Part4Len)) + '), 4)= 1 '

	If (@UserIsAdmin <> 1)
	begin
		Set @StrWhere = @StrWhere + ' AND acc.funPermitted2(' + LTRim(Str(@UserID)) + ', Substring(AcntCode, ' + LTrim(Str(@Part1Start)) + ', ' + LTrim(Str(@Part1Len)) + '), 1)= 1 '
		Set @StrWhere = @StrWhere + ' AND acc.funPermitted2(' + LTRim(Str(@UserID)) + ', Substring(AcntCode, ' + LTrim(Str(@Part2Start)) + ', ' + LTrim(Str(@Part2Len)) + '), 2)= 1 '
		Set @StrWhere = @StrWhere + ' AND acc.funPermitted2(' + LTRim(Str(@UserID)) + ', Substring(AcntCode, ' + LTrim(Str(@Part3Start)) + ', ' + LTrim(Str(@Part3Len)) + '), 3)= 1 '
		Set @StrWhere = @StrWhere + ' AND acc.funPermitted2(' + LTRim(Str(@UserID)) + ', Substring(AcntCode, ' + LTrim(Str(@Part4Start)) + ', ' + LTrim(Str(@Part4Len)) + '), 4)= 1 '
	end;
	
	if (@PartNo=1)
		set @StrWhereR = @StrWhereR + @StrWhereA1
	if (@PartNo=2)
		set @StrWhereR = @StrWhereR + @StrWhereA2
	if (@PartNo=3)
		set @StrWhereR = @StrWhereR + @StrWhereA3
	if (@PartNo=4)
		set @StrWhereR = @StrWhereR + @StrWhereA4

	--===== SELECT CLAUSE =======================================================
	SET @StrSelect = ''
	SET @StrSelectR = ''

	If (@ShowNoProgress = 1) 
	Begin
		SET @StrSelectR = ' 
			UNION ALL
			SELECT AcntCode, 0, 0, 0
			FROM   acc.tblAcnt
			WHERE  (PartNumber = ' + Str(@PartNo) + ') 
				--and (Len(AcntCode) = ' + LTrim(Str(@PartLen)) + ') 
				and ' + @StrWhereR
	End;

	SET @StrSelect = '
	SELECT	R.*, AD.AcntName, AD.AcntComment AcntDesc, PreAcntGrade + AllAcntGrade As FinalGrade
	from 
	(
		SELECT	AcntCode, 
				Round(Sum(InitGrade), 0) PreAcntGrade,
				Round(Sum(AcntGrade), 0) AllAcntGrade
		from
		(
			SELECT	AcntCode, Round(SUM(M.CreditDuration-M.DebitDuration), 0) AcntGrade, 0 InitGrade
			FROM
			(
				SELECT	AcntCode, 
						(T.Credit*T.AllDuration) / ' + LTRim(Str(@BasePrice)) + ' CreditDuration, 
						(T.Debit *T.AllDuration) / ' + LTRim(Str(@BasePrice)) + ' DebitDuration
				FROM 
				( 
					SELECT	' + @AcntCode + ' AcntCode, Debit, Credit, [pub].funFarsiDateDiff(''Day'', DocDate, ''' + @BaseDate + ''') AS AllDuration					
					FROM	acc.tblVoucherDtl D
					WHERE   ' + @StrWhere + @StrSelectR + '
				) T
			) M	
			GROUP By M.AcntCode
			union all 
			select AcntCode, 0, InitialGrad
			from acc.tblAcnt
			where (InitialGrad>0)
					and (PartNumber=' + Str(@PartNo) + ') 
					--and (Len(AcntCode)=' + LTrim(Str(@PartLen)) + ') 
					and ' + @StrWhereR + '
		) X
		GROUP By X.AcntCode
	) R	LEFT JOIN acc.tblAcntDtl AD on AD.AcntCode=R.AcntCode and AD.PartNumber=' + Str(@PartNo)

	----- HAVING CLAUSE ---------------------------------------------------------
	IF (@SortFields Is Null)
	SET @StrSelect = @StrSelect + '
	ORDER BY AllAcntGrade DESC, PreAcntGrade DESC'
	ELSE
	SET @StrSelect = @StrSelect + '
	ORDER BY ' + @SortFields

	PRINT @StrSelect;
	EXEC sp_executesql @StrSelect;
END
GO
