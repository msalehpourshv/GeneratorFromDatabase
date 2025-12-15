USE TS_ShirinVatanKarkhaneh_1_1404
GO
SET ANSI_NULLS, QUOTED_IDENTIFIER ON
GO
-- =========== TS-QC:UPDATED ====================
-- Author		 : TakroSystem\Bayani
-- Create date   : 1389/01/11
-- Viewed By	 : 
-- Last Modified : 1390/01/30
-- Last Modifier : TakroSystem\Zia
-- ----------------------------------------------
-- Description	 : < مانده 3 گردش آخر هر حساب از تراز آزمایشی >
-- ==============================================
Create PROCEDURE [acc].[RptLevelBalance_Last]
	@PartNo			TinyInt, -- شماره بخش
	@PartLen		TinyInt, -- طول لایه - اگر بخش یک باشد یا بخش یک نباشد ولی کد بصورت کامل خواسته شود این پارامتر طول کامل کد والا طول کد در آن بخش را می پذیرد
	@ParentLen		TinyInt, -- طول لایه پدر - اگر بخش یک باشد یا بخش یک نباشد ولی کد بصورت کامل خواسته شود این پارامتر طول کامل کد والا طول کد در آن بخش را می پذیرد
	@AcntCode1From	VarChar(20) = Null,
	@AcntCode1To	VarChar(20) = Null,
	@AcntCode2From	VarChar(20) = Null,
	@AcntCode2To	VarChar(20) = Null,
	@AcntCode3From	VarChar(20) = Null,
	@AcntCode3To	VarChar(20) = Null,
	@AcntCode4From	VarChar(20) = Null,
	@AcntCode4To	VarChar(20) = Null,
	@SerialNoFrom	Int = Null,
	@SerialNoTo		Int = Null,
	@DateFrom		Char(10) = Null,
	@DateTo			Char(10) = Null,
	@DebitRemainFrom	BigInt = Null,
	@DebitRemainTo		BigInt = Null,
	@CreditRemainFrom	BigInt = Null,
	@CreditRemainTo		BigInt = Null,
	@DebitCycleFrom		BigInt = Null,
	@DebitCycleTo		BigInt = Null,
	@CreditCycleFrom	BigInt = Null,
	@CreditCycleTo		BigInt = Null,
	@IncludeZeroRemain	Bit = 0, -- شامل کد حسابهائی که مانده آنها صفر است باشد یا نه؟
	@IncludeNotProgress	Bit = 0, -- شامل کد حسابهائی که اصلاً گردشی در طول دوره ندارند باشد یا نه؟
	@IncludeLastDate	Bit = 0, -- شامل ستون آخرین تاریخ بدهکاری یا بستانکاری باشد یا نه؟
	@IncludeDescription	Bit = 0, -- شامل ستون شرح باشد یا نه؟
	@IncludeAddress		Bit = 0, -- شامل ستون آدرس کد باشد یا نه؟
	@SortByName			Bit = 0, -- مرتب بر اساس اسامی حسابها باشد یا کد حسابها؟
	@DistinctPart		Bit = 0, -- فقط کدهای آن بخش بیاید؟ اگر نه کد کامل خواهد آمد
	@SelectedCodes		Bit = 0, -- از کدهای انتخابی استفاده شود یا نه؟
	@UserID				Int = Null, -- برای استفاده از کدهای انتخابی
	@ReportID			Int = Null, -- برای استفاده از کدهای انتخابی
	@ObjectID			Int = Null, -- بخش قبلی علاوه بر بخش جاری آورده شود؟
	@UserIsAdmin		Bit = 0,    -- کاربر اعلام شده مدیر است یا نه؟
	@IncludePrimary		Bit = 1, -- شامل کدهای افتتاحیه باشد یا نه؟
	@IncludeFinish		Bit = 1, -- شامل کدهای اختتامیه باشد یا نه؟
	@IncludeClosed		Bit = 1, -- شامل کد بستن حساب باشد یا نه؟
	@PrimaryDocInRemain	Bit = 1, -- سند افتتاحیه جزو مانده حساب شود یا طی دوره؟
	@LanguageID			TinyInt = 1,
	@AcntGroup			VarChar(20) = Null,
	@AcntName			NVarChar(50) = Null
WITH ENCRYPTION
AS

Declare @StrSelect	NVarChar(max);
Declare @StrWhere	NVarChar(max);

Declare @iAcntStart	TinyInt;
Declare @iAcntLen	TinyInt;
Declare @iAcntLenW	TinyInt;

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

Declare @StrWhere2		NVarChar(max);
DECLARE @StrWhereSLC	NVarChar(max)

DECLARE @GroupProcess	BIT
DECLARE @ShowCreditDebit	BIT
DECLARE @_AcntName		NVarChar(50)
DECLARE	@SortType		int 
DECLARE	@SortMode		int 
DECLARE	@SortAscDesc	int 
BEGIN -- ============================ S T A R T =====================================================

	--SET @LanguageID = pub.funGetCurrentLanguageID();

	SET NOCOUNT ON;
	If (@ObjectID Is Null) SET @ObjectID = 1;

	SET @StrWhere = '';
	SET @StrWhere2 = '';

	IF (@_AcntName	Is Null)	 SET @_AcntName = '@0@0';

	SET @_AcntName			= pub.funSplitString(@AcntName, '@', 1);
	SET @GroupProcess		= pub.funSplitString(@AcntName, '@', 2);
	SET @ShowCreditDebit	= pub.funSplitString(@AcntName, '@', 3);
	SET @SortType			= pub.funSplitString(@AcntName, '@', 4); 
	SET @SortMode			= pub.funSplitString(@AcntName, '@', 5); 
	SET @SortAscDesc		= pub.funSplitString(@AcntName, '@', 6); 

	
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
	If @PartNo = 1
	Begin
		Set @iAcntStart = @Part1Start
		Set @iAcntLenW = 0
	End
	Else If @PartNo = 2
	Begin
		Set @iAcntStart = @Part2Start
		Set @iAcntLenW = @Part1Start + @Part1Len - 1
	End
	Else If @PartNo = 3
	Begin
		Set @iAcntStart = @Part3Start
		Set @iAcntLenW = @Part2Start + @Part2Len - 1
	End
	Else If @PartNo = 4
	Begin
		Set @iAcntStart = @Part4Start
		Set @iAcntLenW = @Part3Start + @Part3Len - 1
	End

	Set @iAcntLen = @PartLen

	-- Full Acnt Code Requested	
	If (@DistinctPart = 0) 
	Begin
		Set @iAcntLen = @iAcntStart + @PartLen - 1
		Set @iAcntStart = 1 
	End
	--------  LAYERS LEN END  ---------------------------------------------------

	-------- CASE WHEN CLAUSE ---------------------------------------------------
	Declare @StrDebit	NVarChar(100);
	Declare @StrCredit	NVarChar(100);

	If @DateFrom Is Null AND @SerialNoFrom Is Null 
	Begin                            --(Date = null & Serial = null)
		If (@PrimaryDocInRemain = 1)
		Begin
			SET @StrDebit  = 'CASE WHEN (VchKind <> 2) THEN Debit  Else 0 End '
			SET @StrCredit = 'CASE WHEN (VchKind <> 2) THEN Credit Else 0 End '
		End
		Else
		Begin	
			SET @StrDebit  = 'Debit '
			SET @StrCredit = 'Credit '
		End
	End
	Else If @DateFrom Is Not Null AND @SerialNoFrom Is Null 
	Begin                            --(Date <> null & Serial = null)
		Set @StrDebit   = 'CASE WHEN DocDate < ''' + @DateFrom + ''' THEN 0 Else Debit  End '
		Set @StrCredit  = 'CASE WHEN DocDate < ''' + @DateFrom + ''' THEN 0 Else Credit End '
	End
	Else If @DateFrom Is Null AND @SerialNoFrom Is Not Null 
	Begin                            --(Date = null & Serial <> null) 
		If (@PrimaryDocInRemain = 1)
		Begin
			SET @StrDebit   = 'CASE WHEN SerialNo >= ' + LTrim(Str(@SerialNoFrom)) + ' AND (VchKind <> 2) THEN Debit  Else 0 End '
			SET @StrCredit  = 'CASE WHEN SerialNo >= ' + LTrim(Str(@SerialNoFrom)) + ' AND (VchKind <> 2) THEN Credit Else 0 End '
		End
		Else
		Begin	
			SET @StrDebit   = 'CASE WHEN SerialNo >= ' + LTrim(Str(@SerialNoFrom)) + ' THEN Debit  Else 0 End '
			SET @StrCredit  = 'CASE WHEN SerialNo >= ' + LTrim(Str(@SerialNoFrom)) + ' THEN Credit Else 0 End '
		End
	End
	Else -- (DateFrom <> Null  &  SerialNoFrom <> null)
	Begin
		Set @StrDebit   = 'CASE WHEN DocDate >= ''' + @DateFrom + ''' AND SerialNo >= ' + LTrim(Str(@SerialNoFrom)) + ' THEN Debit  Else 0 End '
		Set @StrCredit  = 'CASE WHEN DocDate >= ''' + @DateFrom + ''' AND SerialNo >= ' + LTrim(Str(@SerialNoFrom)) + ' THEN Credit Else 0 End '
	End
	------ CASE WHEN END -----------------------------------------------------

	------ WHERE CLAUSE ------------------------------------------------------
	Set @StrWhere = ' VchKind <> 0 '

	If (@IncludePrimary = 0)
	Set @StrWhere = @StrWhere  + ' AND VchKind <> 2 '

	If (@IncludeFinish = 0)
	Set @StrWhere = @StrWhere  + ' AND VchKind <> 3 '

	If (@IncludeClosed = 0)
	Set @StrWhere = @StrWhere  + ' AND VchKind <> 4 '
	
	If (@PartNo <> 1)
		If (@ObjectID = 1) 
			Set @StrWhere = @StrWhere + ' AND Len(AcntCode) >= ' + LTrim(Str(@iAcntLenW))
		Else
			Set @StrWhere = @StrWhere + ' AND Len(AcntCode) > ' + LTrim(Str(@iAcntLenW))

	-- Acnt1 --
	If (@AcntCode1From Is Not Null) AND (@AcntCode1To Is Not Null) AND (@AcntCode1From = @AcntCode1To)
		Set @StrWhere = @StrWhere + ' AND Substring(AcntCode, ' + LTrim(Str(@Part1Start)) + ', ' + LTrim(Str(Len(@AcntCode1From))) + ') = ''' + @AcntCode1From + ''''
	Else
	Begin
		If @AcntCode1From Is Not Null
			Set @StrWhere = @StrWhere + ' AND Substring(AcntCode, ' + LTrim(Str(@Part1Start)) + ', ' + LTrim(Str(Len(@AcntCode1From))) + ') >= ''' + @AcntCode1From + ''''
		If @AcntCode1To Is Not Null
			Set @StrWhere = @StrWhere + ' AND Substring(AcntCode, ' + LTrim(Str(@Part1Start)) + ', ' + LTrim(Str(Len(@AcntCode1To))) + ') <= ''' + @AcntCode1To + ''''
	End

	-- Acnt2 --
	If @AcntCode2From Is Not Null AND @AcntCode2To Is Not Null AND @AcntCode2From = @AcntCode2To
		Set @StrWhere = @StrWhere + ' AND Substring(AcntCode, ' + LTrim(Str(@Part2Start)) + ', ' + LTrim(Str(Len(@AcntCode2From))) + ') = ''' + @AcntCode2From + ''''
	Else
	Begin
		If @AcntCode2From Is Not Null
			Set @StrWhere = @StrWhere + ' AND Substring(AcntCode, ' + LTrim(Str(@Part2Start)) + ', ' + LTrim(Str(Len(@AcntCode2From))) + ') >= ''' + @AcntCode2From + ''''
		If @AcntCode2To Is Not Null
			Set @StrWhere = @StrWhere + ' AND Substring(AcntCode, ' + LTrim(Str(@Part2Start)) + ', ' + LTrim(Str(Len(@AcntCode2To))) + ') <= ''' + @AcntCode2To + ''''	
	End

	-- Acnt3 --
	If @AcntCode3From Is Not Null AND @AcntCode3To Is Not Null AND	@AcntCode3From = @AcntCode3To
		Set @StrWhere = @StrWhere + ' AND Substring(AcntCode, ' + LTrim(Str(@Part3Start)) + ', ' + LTrim(Str(Len(@AcntCode3From))) + ') = ''' + @AcntCode3From + ''''
	Else
	Begin
		If @AcntCode3From Is Not Null
			Set @StrWhere = @StrWhere + ' AND Substring(AcntCode, ' + LTrim(Str(@Part3Start)) + ', ' + LTrim(Str(Len(@AcntCode3From))) + ') >= ''' + @AcntCode3From + ''''
		If @AcntCode3To Is Not Null
			Set @StrWhere = @StrWhere + ' AND Substring(AcntCode, ' + LTrim(Str(@Part3Start)) + ', ' + LTrim(Str(Len(@AcntCode3To))) + ') <= ''' + @AcntCode3To + ''''
	End

	-- Acnt4 --
	If @AcntCode4From Is Not Null AND @AcntCode4To Is Not Null AND	@AcntCode4From = @AcntCode4To
		Set @StrWhere = @StrWhere + ' AND Substring(AcntCode, ' + LTrim(Str(@Part4Start)) + ', ' + LTrim(Str(Len(@AcntCode4From))) + ') = ''' + @AcntCode4From + ''''
	Else
	Begin
		If @AcntCode4From Is Not Null
			Set @StrWhere = @StrWhere + ' AND Substring(AcntCode, ' + LTrim(Str(@Part4Start)) + ', ' + LTrim(Str(Len(@AcntCode4From))) + ') >= ''' + @AcntCode4From + ''''
		If @AcntCode4To Is Not Null
			Set @StrWhere = @StrWhere + ' AND Substring(AcntCode, ' + LTrim(Str(@Part4Start)) + ', ' + LTrim(Str(Len(@AcntCode4To))) + ') <= ''' + @AcntCode4To + ''''
	End

	-- A C N T   G R O U P --
	If (@AcntGroup Is Not Null)
		SET @StrWhere = @StrWhere + ' 
			AND Substring(AcntCode, ' + LTrim(Str(@iAcntStart)) + ', ' + LTrim(Str(@iAcntLen)) + ')
			IN (
				SELECT	AcntCode 
				FROM	acc.tblAcntGroupsDocDtl
				WHERE	AcntGroupID = ''' + @AcntGroup + '''
				)'

	-- S L C   M O D E --
	If (@SelectedCodes = 1)
	BEGIN
		SET @StrWhereSLC =''

		DECLARE @StrSlc		NVarChar(max)
		DECLARE @AcntCode	VarChar(20);
					
		IF (@PartNo >= 1) 
		BEGIN
			SET @StrSlc = ''

			DECLARE csr CURSOR FOR
				SELECT	AcntCode
				FROM	acc.tblAcntSlc 
				WHERE	(PartNumber = 1) AND 
						(UserID = @UserID) AND 
						(ReportID = @ReportID)

			OPEN csr
			FETCH NEXT FROM csr INTO @AcntCode

			WHILE (@@FETCH_STATUS = 0)
			BEGIN
				IF (@StrSlc <> '')
					SET @StrSlc = @StrSlc + ' OR ' 

				SET @StrSlc = @StrSlc + '(Substring(AcntCode, ' + LTrim(Str(@Part1Start)) + ', ' + LTrim(Str(Len(@AcntCode))) + ') = ''' + @AcntCode + ''')'

				FETCH NEXT FROM csr INTO @AcntCode
			END

			CLOSE csr
			DEALLOCATE csr

			IF (@StrSlc <> '')
				SET @StrWhereSLC = @StrWhereSLC + ' AND (' + @StrSlc + ')'
		END -- IF (@PartNo >= 1) 

		IF (@PartNo >= 2) 
		BEGIN
			SET @StrSlc = ''

			DECLARE csr CURSOR FOR
				SELECT	AcntCode
				FROM	acc.tblAcntSlc 
				WHERE	(PartNumber = 2) AND 
						(UserID = @UserID) AND 
						(ReportID = @ReportID)

			OPEN csr
			FETCH NEXT FROM csr INTO @AcntCode

			WHILE (@@FETCH_STATUS = 0)
			BEGIN
				IF (@StrSlc <> '')
					SET @StrSlc = @StrSlc + ' OR ' 

				SET @StrSlc = @StrSlc + '(Substring(AcntCode, ' + LTrim(Str(@Part2Start)) + ', ' + LTrim(Str(Len(@AcntCode))) + ') = ''' + @AcntCode + ''')'

				FETCH NEXT FROM csr INTO @AcntCode
			END

			CLOSE csr
			DEALLOCATE csr

			IF (@StrSlc <> '')
				SET @StrWhereSLC = @StrWhereSLC + ' AND (' + @StrSlc + ')'
		END -- (@PartNo >= 2)

		IF (@PartNo >= 3) 
		BEGIN
			SET @StrSlc = ''

			DECLARE csr CURSOR FOR
				SELECT	AcntCode
				FROM	acc.tblAcntSlc 
				WHERE	(PartNumber = 3) AND 
						(UserID = @UserID) AND 
						(ReportID = @ReportID)

			OPEN csr
			FETCH NEXT FROM csr INTO @AcntCode

			WHILE (@@FETCH_STATUS = 0)
			BEGIN
				IF (@StrSlc <> '')
					SET @StrSlc = @StrSlc + ' OR ' 

				SET @StrSlc = @StrSlc + '(Substring(AcntCode, ' + LTrim(Str(@Part3Start)) + ', ' + LTrim(Str(Len(@AcntCode))) + ') = ''' + @AcntCode + ''')'

				FETCH NEXT FROM csr INTO @AcntCode
			END

			CLOSE csr
			DEALLOCATE csr

			IF (@StrSlc <> '')
				SET @StrWhereSLC = @StrWhereSLC + ' AND (' + @StrSlc + ')'
		END -- (@PartNo >= 3) 

		IF (@PartNo >= 4)
		BEGIN
			SET @StrSlc = ''

			DECLARE csr CURSOR FOR
				SELECT	AcntCode
				FROM	acc.tblAcntSlc 
				WHERE	(PartNumber = 4) AND 
						(UserID = @UserID) AND 
						(ReportID = @ReportID)

			OPEN csr
			FETCH NEXT FROM csr INTO @AcntCode

			WHILE (@@FETCH_STATUS = 0)
			BEGIN
				IF (@StrSlc <> '')
					SET @StrSlc = @StrSlc + ' OR ' 

				SET @StrSlc = @StrSlc + '(Substring(AcntCode, ' + LTrim(Str(@Part4Start)) + ', ' + LTrim(Str(Len(@AcntCode))) + ') = ''' + @AcntCode + ''')'

				FETCH NEXT FROM csr INTO @AcntCode
			END

			CLOSE csr
			DEALLOCATE csr

			IF (@StrSlc <> '')
				SET @StrWhereSLC = @StrWhereSLC + ' AND (' + @StrSlc + ')'
		END -- (@PartNo >= 4)

		SET @StrWhere = @StrWhere + @StrWhereSLC
	END -- IF SLD MODE

	-- Date To --
	If @DateTo Is Not Null
		SET @StrWhere = @StrWhere + ' AND DocDate <= ''' + @DateTo + ''''
	
	-- Serial To --
	If @SerialNoTo Is Not Null
		SET @StrWhere = @StrWhere + ' AND SerialNo <= ' + LTrim(Str(@SerialNoTo))

	If (@LimitState1 = -1)
		Set @StrWhere2 = @StrWhere2 + '
			AND LTrim(Substring(AcntCode,' + LTrim(Str(@Part1Start)) + ',' + LTrim(Str(@Part1Len)) + '))='''' '
	Else If (@LimitState1 = 0)
		Set @StrWhere2 = @StrWhere2 + '
			AND acc.funPermitted(' + LTRim(Str(@UserID)) + ',Substring(AcntCode,' + LTrim(Str(@Part1Start)) + ',' + LTrim(Str(@Part1Len)) + '),1)=1 '
	If (@UserIsAdmin <> 1)
		Set @StrWhere2 = @StrWhere2 + '
			AND acc.funPermitted2(' + LTRim(Str(@UserID)) + ',Substring(AcntCode,' + LTrim(Str(@Part1Start)) + ',' + LTrim(Str(@Part1Len)) + '),1)=1 '

	If (@LimitState2 = -1)
		Set @StrWhere2 = @StrWhere2 + '
			AND LTrim(Substring(AcntCode,' + LTrim(Str(@Part2Start)) + ',' + LTrim(Str(@Part2Len)) + '))='''' '
	Else If (@LimitState2 = 0) 
		Set @StrWhere2 = @StrWhere2 + '
			AND acc.funPermitted(' + LTRim(Str(@UserID)) + ',Substring(AcntCode,' + LTrim(Str(@Part2Start)) + ',' + LTrim(Str(@Part2Len)) + '),2)=1 '
	If (@UserIsAdmin <> 1)
		Set @StrWhere2 = @StrWhere2 + '
			AND acc.funPermitted2(' + LTRim(Str(@UserID)) + ',Substring(AcntCode,' + LTrim(Str(@Part2Start)) + ',' + LTrim(Str(@Part2Len)) + '),2)=1 '

	If (@LimitState3 = -1)
		Set @StrWhere2 = @StrWhere2 + '
			AND LTrim(Substring(AcntCode,' + LTrim(Str(@Part3Start)) + ',' + LTrim(Str(@Part3Len)) + '))='''' '
	Else If (@LimitState3 = 0) 
		Set @StrWhere2 = @StrWhere2 + '
			AND acc.funPermitted(' + LTRim(Str(@UserID)) + ',Substring(AcntCode,' + LTrim(Str(@Part3Start)) + ',' + LTrim(Str(@Part3Len)) + '),3)=1 '
	If (@UserIsAdmin <> 1)
		Set @StrWhere2 = @StrWhere2 + '
			AND acc.funPermitted2(' + LTRim(Str(@UserID)) + ',Substring(AcntCode,' + LTrim(Str(@Part3Start)) + ',' + LTrim(Str(@Part3Len)) + '),3)=1 '

	If (@LimitState4 = -1)
		Set @StrWhere2 = @StrWhere2 + '
			AND LTrim(Substring(AcntCode,' + LTrim(Str(@Part4Start)) + ',' + LTrim(Str(@Part4Len)) + '))='''' '
	Else If (@LimitState4 = 0) 
		Set @StrWhere2 = @StrWhere2 +'
			AND acc.funPermitted(' + LTRim(Str(@UserID)) + ',Substring(AcntCode,' + LTrim(Str(@Part4Start)) + ',' + LTrim(Str(@Part4Len)) + '),4)=1 '
	If (@UserIsAdmin <> 1)
		Set @StrWhere2 = @StrWhere2 + '
			AND acc.funPermitted2(' + LTRim(Str(@UserID)) + ',Substring(AcntCode,' + LTrim(Str(@Part4Start)) + ',' + LTrim(Str(@Part4Len)) + '),4)=1 '

	Set @StrWhere = @StrWhere + @StrWhere2

	----- WHERE CLAUSE END ------------------------------------------------------

	----- HAVING CLAUSE ---------------------------------------------------------
	Declare @StrHaving	NVarChar(500);
	Set @StrHaving = ''

	-- Not Include Zero Remains
	If (@IncludeZeroRemain = 0) 
	Begin
		If @StrHaving <> '' Set @StrHaving = @StrHaving + ' AND '
		Set @StrHaving = @StrHaving + '
			Sum(DebitTotal) <> Sum(CreditTotal)'
	End

	-- Debit FROM
	If @DebitRemainFrom Is Not Null  
	Begin
		If @StrHaving <> '' Set @StrHaving = @StrHaving + ' AND '
		Set @StrHaving = @StrHaving + '
			Sum(DebitTotal) - Sum(CreditTotal) >= ' + LTrim(Str(@DebitRemainFrom))
	End

	-- Debit To
	If @DebitRemainTo Is Not Null  
	Begin
		If @StrHaving <> '' Set @StrHaving = @StrHaving + ' AND '
		Set @StrHaving = @StrHaving + '
			Sum(DebitTotal) - Sum(CreditTotal) <= ' + LTrim(Str(@DebitRemainTo))
	End

	-- Credit FROM
	If @CreditRemainFrom Is Not Null  
	Begin
		If @StrHaving <> '' Set @StrHaving = @StrHaving + ' AND '
		Set @StrHaving = @StrHaving + '
			Sum(CreditTotal) - Sum(DebitTotal) >= ' + LTrim(Str(@CreditRemainFrom))
	End

	-- Credit To
	If @CreditRemainTo Is Not Null  
	Begin
		If @StrHaving <> '' Set @StrHaving = @StrHaving + ' AND '
		Set @StrHaving = @StrHaving + '
			Sum(CreditTotal) - Sum(DebitTotal) <= ' + LTrim(Str(@CreditRemainTo))
	End
	
	-- Debit Cycle From
	If @DebitCycleFrom Is Not Null  
	Begin
		If @StrHaving <> '' Set @StrHaving = @StrHaving + ' AND '
		Set @StrHaving = @StrHaving + '
			Sum(Debit) >= ' + LTrim(Str(@DebitCycleFrom))
	End

	-- Debit Cycle To
	If @DebitCycleTo Is Not Null  
	Begin
		If @StrHaving <> '' Set @StrHaving = @StrHaving + ' AND '
		Set @StrHaving = @StrHaving + '
			Sum(Debit) <= ' + LTrim(Str(@DebitCycleTo))
	End

	-- Credit Cycle From
	If @CreditCycleFrom Is Not Null  
	Begin
		If @StrHaving <> '' Set @StrHaving = @StrHaving + ' AND '
		Set @StrHaving = @StrHaving + '
			Sum(Credit) >= ' + LTrim(Str(@CreditCycleFrom))
	End

	-- Credit Cycle To
	If @CreditCycleTo Is Not Null  
	Begin
		If @StrHaving <> '' Set @StrHaving = @StrHaving + ' AND '
		Set @StrHaving = @StrHaving + '
			Sum(Credit) <= ' + LTrim(Str(@CreditCycleTo))
	End

	IF (@_AcntName Is Not Null) AND @_AcntName <> ''
	Begin
		If @StrHaving <> '' Set @StrHaving = @StrHaving + ' AND '
		Set @StrHaving = @StrHaving + ' pub.GetCodeName(T.AcntCode, 1) LIKE N''%' + @_AcntName + '%'' '
	End
	----- HAVING CLAUSE END -----------------------------------------------------

	--===== SELECT CLAUSE =======================================================
	Declare @StrAcntCode AS	NVarChar(100) 
	Declare @StrDateGrp  AS NVarChar(100);
	Declare @StrDateSel  AS NVarChar(100);
	Declare @StrDateSelU As NVarChar(100);

	If (@IncludeLastDate = 1)
	Begin
		Set @StrDateSel = ', CASE WHEN Debit > Credit THEN DocDate END AS DD, CASE WHEN Debit < Credit THEN DocDate END AS DC '
		Set @StrDateGrp = ' Max(DD) AS LastDebitDate, Max(DC) AS LastCreditDate '
		Set @StrDateSelU = ', '''', '''' '
	End
	Else 
	Begin
		Set @StrDateSel = ''
		Set @StrDateGrp = 'Cast('''' AS Char(10)) AS LastDebitDate, Cast('''' AS Char(10)) AS LastCreditDate '
		Set @StrDateSelU = ' '
	End

	If (@DistinctPart = 1) AND (@PartNo > 1)
		Set @StrAcntCode = ' Space(' + LTrim(Str(@iAcntLenW + 1)) + ') + T.AcntCode'
	Else
		Set @StrAcntCode = 'T.AcntCode'

	Set @StrSelect = '
		SELECT	Cast(T.AcntCode AS VarChar(20)) AS AcntCode, 
				Cast(T.ParentCode AS VarChar(20)) AS ParentCode, 
				Sum(Debit) SumDebit, Sum(Credit) SumCredit, 
				Sum(DebitTotal) SumDebitTotal, Sum(CreditTotal) SumCreditTotal, 
				F.AcntName,	pub.GetCodeName(T.ParentCode, ' + LTrim(Str(@LanguageID)) + ') AS ParentName,
				F.AcntComment AS AcntDesc, F.Address1 + F.Address2 AS AcntAddr,
				' + @StrDateGrp + ' 
		FROM (
			SELECT	Substring(AcntCode, ' + LTrim(Str(@iAcntStart)) + ', ' + LTrim(Str(@iAcntLen)) + ') AS AcntCode, 
					Substring(AcntCode, ' + LTrim(Str(@iAcntStart)) + ', ' + LTrim(Str(@ParentLen)) + ') AS ParentCode, ' +
					@StrDebit + ' AS Debit, ' + @StrCredit + ' AS Credit, Debit AS DebitTotal, Credit AS CreditTotal ' + @StrDateSel + '
			FROM	acc.tblVoucherDtl '

	If (@StrWhere <> '')
		Set @StrSelect = @StrSelect + '
			WHERE ' + @StrWhere

	-- Zero Progress Included 
	If (@IncludeNotProgress = 1) AND (@PartNo = 1) AND (@IncludeZeroRemain = 1) 
	Begin
		SET @StrSelect = @StrSelect  + ' 
			UNION ALL
			SELECT AcntCode, Left(AcntCode, ' + LTrim(Str(@ParentLen)) + ') ParentCode, 0 ,0 ,0 ,0 ' + @StrDateSelU + '
			FROM   acc.tblAcnt 
			WHERE  PartNumber = 1 AND Len(AcntCode) = ' + LTrim(Str(@PartLen)) 

		If (@SelectedCodes = 1) AND (@StrWhereSLC <> '')
			SET @StrSelect = @StrSelect + @StrWhereSLC
			
		If (@AcntGroup Is Not Null)
		SET @StrSelect = @StrSelect + ' 
			AND Substring(AcntCode, ' + LTrim(Str(@iAcntStart)) + ', ' + LTrim(Str(@iAcntLen)) + ')
			IN (
				SELECT	AcntCode 
				FROM	acc.tblAcntGroupsDocDtl
				WHERE	AcntGroupID = ''' + @AcntGroup + '''
				)'

		-- Acnt1 --
		If @AcntCode1From Is Not Null AND @AcntCode1To Is Not Null AND @AcntCode1From = @AcntCode1To
			Set @StrSelect = @StrSelect + ' AND Substring(AcntCode, ' + LTrim(Str(@Part1Start)) + ', ' + LTrim(Str(Len(@AcntCode1From))) + ') = ''' + @AcntCode1From + ''''
		Else If @AcntCode1From Is Not Null
			Set @StrSelect = @StrSelect + ' AND Substring(AcntCode, ' + LTrim(Str(@Part1Start)) + ', ' + LTrim(Str(Len(@AcntCode1From))) + ') >= ''' + @AcntCode1From + ''''
		Else If @AcntCode1To Is Not Null
			Set @StrSelect = @StrSelect + ' AND Substring(AcntCode, ' + LTrim(Str(@Part1Start)) + ', ' + LTrim(Str(Len(@AcntCode1To))) + ') <= ''' + @AcntCode1To + ''''

		Set @StrSelect = @StrSelect + @StrWhere2
	End

	Set @StrSelect = @StrSelect + ') T
			OUTER APPLY acc.funGetCodeInfo(' + @StrAcntCode + ') AS F 
		GROUP By AcntCode, ParentCode, F.AcntName, F.AcntComment, F.Address1, F.Address2 '

	If @StrHaving <> '' 
		Set @StrSelect = @StrSelect + 'HAVING' + @StrHaving;
		
	If (@SortByName = 1)
		Set @StrSelect = @StrSelect + '
		ORDER By AcntName '
	Else
		Set @StrSelect = @StrSelect + '
		ORDER By AcntCode '

	Declare @CreditQ varchar(MAX),@DebitQ varchar(MAX),@CreditW varchar(MAX),@DebitW varchar(MAX)

	IF @ShowCreditDebit = '1'
	BEGIN
		SEt @CreditQ = '@Credit-@Debit'
		SEt @DebitQ = '@Credit-@Debit'
		If @DateTo Is Not Null
		BEGIN
			SET @CreditW =' DocDate <= ''' + @DateTo + ''' AND '
			SET @DebitW = ' DocDate <= ''' + @DateTo + ''' AND '
		END
		ELSE
		BEGIN
			SET @CreditW =' '
			SET @DebitW = ' '
		END
	END
	ELSE
	BEGIN
		SEt @CreditQ = '@Credit'
		SEt @DebitQ = '-@Debit'
		SET @CreditW =' Credit >0 AND DocDate <= @LastCreditDate AND '
		SET @DebitW = ' Debit >0 AND DocDate <= @LastCreditDate AND '
	END	

	DECLARE @CreditDebitGrp varchar(MAX),@CreditDebitGrpFld varchar(MAX)

	IF @GroupProcess = '1'
	BEGIN
		SET @CreditDebitGrp = 'GROUP BY DocDate,SourceProcessID,SourceProcessNo Order By DocDate Desc '
		SET @CreditDebitGrpFld = ',SUM(Debit) Debit,SUM(Credit) Credit'
	END
	ELSE
	BEGIN
		SET @CreditDebitGrp = ' Order By DocDate Desc,SerialNo DESC,DocRowNo DESC '
		SET @CreditDebitGrpFld = ',Debit,Credit'
	END

	Declare @StrLast Nvarchar(max);

	Set @StrLast = N'
	Declare @T TABLE(
	 AcntCode Varchar(20),ParentCode Varchar(20),SumDebit Float,SumCredit Float,SumDebitTotal Float,SumCreditTotal Float ,
	 AcntName Nvarchar(100),ParentName Nvarchar(100),AcntDesc Nvarchar(100),AcntAddr Nvarchar(2000),LastDebitDate Char(10) , LastCreditDate Char(10),
	 Date1 Char(10) DEFAULT '''' , Date2 Char(10) DEFAULT '''' , Date3 Char(10) DEFAULT '''' , Amount1 Float DEFAULT 0.0 , Amount2 Float DEFAULT 0.0 , Amount3 Float DEFAULT 0.0,
	 ProcessName1 Nvarchar(200) DEFAULT '''',ProcessName2 Nvarchar(200) DEFAULT '''',ProcessName3 Nvarchar(200) DEFAULT ''''); 

	INSERT INTO @T(AcntCode,ParentCode,SumDebit,SumCredit,SumDebitTotal,SumCreditTotal,AcntName,ParentName,AcntDesc,
	AcntAddr,LastDebitDate,LastCreditDate) ' + @StrSelect + 
	'Declare @Credit Float, @Debit Float, @Idx Tinyint,@SourceProcessID INT,@SourceProcessNo INT
	Declare @AcntCode Varchar(20),@LastDebitDate Char(10),@LastCreditDate Char(10),@DocDate Char(10)
	Declare curMain Cursor FOR
	Select AcntCode ,SumCredit,SumDebit,LastDebitDate,LastCreditDate From @T

	OPEN curMain
	Fetch Next from curMain INTO @AcntCode,@Credit,@Debit,@LastDebitDate,@LastCreditDate
	While @@FETCH_STATUS = 0
	Begin
	  IF @Credit = @Debit
	    Begin
			Fetch Next from curMain INTO @AcntCode,@Credit,@Debit,@LastDebitDate,@LastCreditDate
			Continue
	    END 
	  IF @Credit > @Debit
		Begin
			Declare curSub Cursor FORWARD_ONLY FOR Select TOP 3 DocDate,SourceProcessID,SourceProcessNo' + @CreditDebitGrpFld + '
			From acc.tblVoucherDtl
			Where ' + @CreditW + '
			SubString(AcntCode,' + LTrim(Str(@iAcntStart)) + ',' + LTrim(Str(@iAcntLen)) + ')=@AcntCode
			' + @CreditDebitGrp + '
						
			SET @Idx = 1;
			OPEN curSub
			Fetch Next From curSub INTO @DocDate,@SourceProcessID,@SourceProcessNo,@Debit,@Credit
			While @@FETCH_STATUS = 0
			  Begin
				IF @Idx = 1	UPDATE @T SET Date1=@DocDate ,Amount1=' + @CreditQ + ',ProcessName1 =ISNULL((select ProcessName from pub.tblProcess WHERE ProcessID=@SourceProcessID AND ProcessNo=@SourceProcessNo),'''') Where AcntCode=@AcntCode;	
				IF @Idx = 2	UPDATE @T SET Date2=@DocDate ,Amount2=' + @CreditQ + ',ProcessName2 =ISNULL((select ProcessName from pub.tblProcess WHERE ProcessID=@SourceProcessID AND ProcessNo=@SourceProcessNo),'''') Where AcntCode=@AcntCode;	
				IF @Idx = 3 UPDATE @T SET Date3=@DocDate ,Amount3=' + @CreditQ + ',ProcessName3 =ISNULL((select ProcessName from pub.tblProcess WHERE ProcessID=@SourceProcessID AND ProcessNo=@SourceProcessNo),'''') Where AcntCode=@AcntCode;	
				SET @Idx = @Idx + 1	
				Fetch Next From curSub INTO @DocDate,@SourceProcessID,@SourceProcessNo,@Debit,@Credit
			  End
			CLOSE curSub
			DEALLOCATE curSub
		End
	  ELSE
		Begin
			Declare curSub Cursor FORWARD_ONLY FOR Select TOP 3 DocDate,SourceProcessID,SourceProcessNo' + @CreditDebitGrpFld + '
			From acc.tblVoucherDtl
			Where ' + @DebitW + '
			SubString(AcntCode,' + LTrim(Str(@iAcntStart)) + ',' + LTrim(Str(@iAcntLen)) + ')=@AcntCode
			' + @CreditDebitGrp + '
			
			SET @Idx = 1;
			OPEN curSub
			Fetch Next From curSub INTO @DocDate,@SourceProcessID,@SourceProcessNo,@Debit,@Credit
			While @@FETCH_STATUS = 0
			  Begin
				IF @Idx = 1	UPDATE @T SET Date1=@DocDate ,Amount1= ' + @DebitQ + ',ProcessName1 =ISNULL((select ProcessName from pub.tblProcess WHERE ProcessID=@SourceProcessID AND ProcessNo=@SourceProcessNo),'''') Where AcntCode=@AcntCode;	
				IF @Idx = 2	UPDATE @T SET Date2=@DocDate ,Amount2= ' + @DebitQ + ',ProcessName2 =ISNULL((select ProcessName from pub.tblProcess WHERE ProcessID=@SourceProcessID AND ProcessNo=@SourceProcessNo),'''') Where AcntCode=@AcntCode;	
				IF @Idx = 3	UPDATE @T SET Date3=@DocDate ,Amount3= ' + @DebitQ + ',ProcessName3 =ISNULL((select ProcessName from pub.tblProcess WHERE ProcessID=@SourceProcessID AND ProcessNo=@SourceProcessNo),'''') Where AcntCode=@AcntCode;	
				SET @Idx = @Idx + 1	
				Fetch Next From curSub INTO @DocDate,@SourceProcessID,@SourceProcessNo,@Debit,@Credit
			  End
			CLOSE curSub
			DEALLOCATE curSub
		End
		Fetch Next from curMain INTO @AcntCode,@Credit,@Debit,@LastDebitDate,@LastCreditDate
	End
	CLOSE curMain
	DEALLOCATE curMain
	'
	
	 If (@DistinctPart = 1)
		 Set @StrLast = @StrLast + '	update  @T set ParentCode='''' ;'
	-------------------------------------------------------------------------------------------------
	if @SortType=1
		Set @StrLast = @StrLast + '	Select * From @T	ORDER By AcntCode '
	else if @SortType=2
		Set @StrLast = @StrLast + '	Select * From @T	ORDER By AcntName '
	else if @SortType=3
		Set @StrLast = @StrLast + '	Select * From @T	ORDER By  case when isnull(LastDebitDate,'''') < isnull(LastCreditDate,'''') then isnull(LastDebitDate,'''') else isnull(LastCreditDate,'''') end  '
	else if @SortType=4
			begin
				if @SortMode=1 and @SortAscDesc=1
					Set @StrLast = @StrLast + '	Select * From @T	ORDER By SumDebit-SumCredit  '
				if @SortMode=1 and @SortAscDesc=2
					Set @StrLast = @StrLast + '	Select * From @T	ORDER By SumDebit-SumCredit Desc '
				if @SortMode=2 and @SortAscDesc=1
					Set @StrLast = @StrLast + '	Select * From @T	ORDER By SumCredit-SumDebit  '
				if @SortMode=2 and @SortAscDesc=2
					Set @StrLast = @StrLast + '	Select * From @T	ORDER By SumCredit-SumDebit Desc '
			end 
	-------------------------------------------------------------------------------------------------
	-- select @StrLast return 

	Print @StrLast;	
	Exec sp_executesql @StrLast
	
END
GO
