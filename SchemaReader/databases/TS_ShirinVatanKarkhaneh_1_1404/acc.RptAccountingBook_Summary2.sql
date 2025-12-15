USE TS_ShirinVatanKarkhaneh_1_1404
GO
SET ANSI_NULLS, QUOTED_IDENTIFIER ON
GO
-- =========== TS-QC:UPDATED ====================
-- Author        : Takrosystem\Zia
-- Create date   : 1390/07/30
-- Viewed By	 : 
-- Last Modified : 1392/02/10
-- Last Modifier : Takrosystem\Zia
-- Description	 : < دفتر حسابداری خلاصه >
-- =============================================
Create PROCEDURE [acc].[RptAccountingBook_Summary2]
	@PartNumber		TinyInt = 1,
	@LayerLen		TinyInt = 1,  -- on this part
	@AcntCode1Fr	VarChar(20) = Null,
	@AcntCode1To	VarChar(20) = Null,
	@AcntCode2Fr	VarChar(20) = Null,
	@AcntCode2To	VarChar(20) = Null,
	@AcntCode3Fr	VarChar(20) = Null,
	@AcntCode3To	VarChar(20) = Null,
	@AcntCode4Fr	VarChar(20) = Null,
	@AcntCode4To	VarChar(20) = Null,
	@Part1Start		Int = -1,
	@Part1End		Int = -1,
	@Part2Start		Int = -1,
	@Part2End		Int = -1,
	@Part3Start		Int = -1,
	@Part3End		Int = -1,
	@Part4Start		Int = -1,
	@Part4End		Int = -1,
	@DocDateFr		VarChar(10) = Null,
	@DocDateTo		VarChar(10) = Null,
	@SerialNoFr		Int = Null,
	@SerialNoTo		Int = Null,
	@DebtorsOnly	Bit = Null, -- 0 => Creditors Only, 1 => Debtors Only, Null => No Limit
	@UserID			Int = 0, 
	@RemainMode		Int = 1, -- 0 => No Remain, 1 => by Date, 2 => by Serial, 3 => by Date And Serial, 4 => by Date Or Serial
	@RecDesc		nVarChar(max) = null,
	@RecDesc2		nVarChar(max) = null,
	@RepOptions		VarChar(30) = '000010101000000011101',  -- bit array options
	@RepInfo		NVarChar(100) = '1@1@1'
WITH ENCRYPTION
AS
DECLARE	@LangID			Char(1);
DECLARE	@SessionNo		Int; 
DECLARE	@ReportID		Int;
DECLARE @OldSerialNoFr	Int; 
DECLARE @OldSerialNoTo	Int; 
DECLARE	@Group1Exist		Bit;
DECLARE	@Group2Exist		Bit;
DECLARE	@Group3Exist		Bit;
DECLARE	@Group4Exist		Bit;
DECLARE	@GroupByDate		Bit;
DECLARE	@IncludePrimary		Bit; -- شامل سند افتتاحیه باشد؟
DECLARE	@IncludeFinish		Bit; -- شامل سند اختتامیه باشد؟
DECLARE	@IncludeClosed		Bit; -- شامل سند بستن حساب باشد؟
DECLARE	@IncludeDetail		Bit; -- شامل شرح زیر برگه باشد؟
DECLARE	@IncludeSubDetail	Bit; -- شامل شرح هر سطر باشد؟
DECLARE	@IncludeGroupDesc	Bit; -- شامل شرح هر گروه باشد؟
DECLARE	@UserIsAdmin		Bit; -- کاربر اعلام شده مدیر است یا نه؟
DECLARE	@RemainSum			Bit; -- 0 = مانده بدهکار و بستانکار مجزا نشان داده شود 
DECLARE	@UseCurrency		Bit; -- 1 = از واحد ارزی استفاده شود
DECLARE	@Auto				Bit; 
DECLARE	@Manu				Bit; 
DECLARE	@GroupByPayRec		Bit; -- دریافت و پرداخت تجمیعی
DECLARE	@GroupByProcess		Bit; -- تجمیعی کلی
DECLARE	@ShowEntezami		bit;
DECLARE	@SourceProcessNo	varchar(20);

DECLARE @StrSerialNo	NVarChar(50);
DECLARE @StrSelect		NVarChar(4000);
DECLARE @StrFrom		NVarChar(1000);
DECLARE @StrMainFeilds	NVarChar(1000);
DECLARE @StrSelectR		NVarChar(4000);
DECLARE @StrWhere		NVarChar(4000);
DECLARE @StrWhereR		NVarChar(4000);
DECLARE @StrAcntWhere	NVarChar(max);
DECLARE @StrDebitR		NVarChar(500);
DECLARE @StrCreditR		NVarChar(500);
DECLARE @StrGroup		NVarChar(2000);
DECLARE @LimitState1	SmallInt;
DECLARE @LimitState2	SmallInt;
DECLARE @LimitState3	SmallInt;
DECLARE @LimitState4	SmallInt;
DECLARE @Part1Len		TinyInt;
DECLARE @Part2Len		TinyInt;
DECLARE @Part3Len		TinyInt;
DECLARE @Part4Len		TinyInt;

DECLARE @Group1		NVarChar(500);
DECLARE @Group2		NVarChar(500);
DECLARE @Group3		NVarChar(500);
DECLARE @Group4		NVarChar(500);

DECLARE @ExtraFilter	NVarChar(2000);

DECLARE @Group1Part		Char(1);
DECLARE @Group2Part		Char(1);
DECLARE @Group3Part		Char(1);
DECLARE @Group4Part		Char(1);

DECLARE @CampaignID				int;
DECLARE @VisitPathID1			int;
DECLARE @VisitPathID2			int;
DECLARE @VisitPathID3			int;
DECLARE @VisitPathID4			int;
DECLARE @SalesRoomClass			int;
DECLARE @CustomerPartStart		VarChar(20);
DECLARE @CustomerPartLayerLen	VarChar(20);

BEGIN

	SET NOCOUNT ON;

	--------------------------------------------------------------------
	Declare @CustomerPartNo AS Tinyint
	
	SET @CustomerPartNo = 0
	
	SELECT @CustomerPartNo = SettingValue
	FROM pub.tblSettings
	WHERE SettingKey = 'AcntPartNumberForRemainCalculation'
	
	--------------------------------------------------------------------
	-- init --------------------------------------------------
	IF (@RepInfo Is Null)		SET @RepInfo = '1@1@1'
	IF (@RepOptions Is Null)	SET @RepOptions = '110'

	If @Part1Start Is Null SET @Part1Start = 0
	If @Part2Start Is Null SET @Part2Start = 0
	If @Part3Start Is Null SET @Part3Start = 0
	If @Part4Start Is Null SET @Part4Start = 0

	If @Part1End Is Null SET @Part1End = 0
	If @Part2End Is Null SET @Part2End = 0
	If @Part3End Is Null SET @Part3End = 0
	If @Part4End Is Null SET @Part4End = 0

	SET @Group1Exist	= Substring(@RepOptions, 1, 1)
	SET @Group2Exist	= Substring(@RepOptions, 2, 1)
	SET @Group3Exist	= Substring(@RepOptions, 3, 1)
	SET @Group4Exist	= Substring(@RepOptions, 4, 1)
	SET @GroupByDate	= Substring(@RepOptions, 5, 1)
	SET @IncludePrimary	= Substring(@RepOptions, 6, 1)
	SET @IncludeFinish	= Substring(@RepOptions, 7, 1)
	SET @IncludeClosed	= Substring(@RepOptions, 8, 1)
	SET @IncludeDetail	= Substring(@RepOptions, 9, 1)
	SET @IncludeSubDetail = Substring(@RepOptions, 10, 1)
	SET @IncludeGroupDesc = Substring(@RepOptions, 11, 1)
	SET @UserIsAdmin	= Substring(@RepOptions, 12, 1)
	SET @RemainSum		= Substring(@RepOptions, 13, 1)
	SET @UseCurrency	= Substring(@RepOptions, 14, 1)
	SET @Auto			= Substring(@RepOptions, 15, 1)
	SET @Manu			= Substring(@RepOptions, 16, 1)
	-- 17 is used
	SET @GroupByPayRec	= Substring(@RepOptions, 18, 1)

	if LEN(@RepOptions) > 18
		SET @GroupByProcess	= Substring(@RepOptions, 19, 1)
	else
		SET @GroupByProcess	= 0
	-- 19 is used
	if LEN(@RepOptions) > 20
		SET @ShowEntezami	= Substring(@RepOptions, 21, 1)
	else
		SET @ShowEntezami	= 1

	if LEN(@RepOptions) > 23
		SET @SourceProcessNo= Substring(@RepOptions, 24, 1)
	else
		SET @SourceProcessNo= '0'

	SET @LangID		= pub.funSplitString(@RepInfo, '@', 1);
	SET @SessionNo	= pub.funSplitString(@RepInfo, '@', 2);
	SET @ReportID	= pub.funSplitString(@RepInfo, '@', 3);
	SET @CampaignID	= pub.funSplitString(@RepInfo, '@', 6);
	SET @VisitPathID1	= pub.funSplitString(@RepInfo, '@', 7);
	SET @VisitPathID2	= pub.funSplitString(@RepInfo, '@', 8);
	SET @VisitPathID3	= pub.funSplitString(@RepInfo, '@', 9);
	SET @VisitPathID4	= pub.funSplitString(@RepInfo, '@', 10);
	SET @SalesRoomClass	= pub.funSplitString(@RepInfo, '@', 11);
	SET @OldSerialNoFr	= pub.funSplitString(@RepInfo, '@', 12);
	SET @OldSerialNoTo	= pub.funSplitString(@RepInfo, '@', 13);

	SET	@Part1Len = @Part1End + 1 - @Part1Start
	SET	@Part2Len = @Part2End + 1 - @Part2Start;
	SET	@Part3Len = @Part3End + 1 - @Part3Start;
	SET	@Part4Len = @Part4End + 1 - @Part4Start;

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

	-- Voucher Kind <> 'Note'
	SET @StrWhere = ' (D.VchKind > 0) '
	Set @StrAcntWhere = ''

	if (@ShowEntezami <> 1)
	begin
		declare @P1L1	int;

		select	@P1L1 = Layer1
		from	pub.tblCodeLayer 
		where	(TableName = 'acc.tblAcnt') AND (PartNumber = 1)

		Set @StrWhere = @StrWhere  + ' AND Substring(AcntCode, 1, ' + LTrim(Str(@P1L1)) + ') not in (select AcntCode from acc.tblAcnt where (PartNumber = 1) and (AcntType in (91,92)))'
	end

	set @ExtraFilter = pub.funGetFilterString(@SessionNo, @ReportID, 90, 'CurrencyTypeID') 
	
	if (RTrim(LTrim(@ExtraFilter)) <> '') and (RTrim(LTrim(@ExtraFilter)) <> '()')
		SET @StrWhere = @StrWhere + ' AND ' + @ExtraFilter

	If (@RecDesc is not null)
		SET @StrWhere = @StrWhere + ' AND (RecDesc like N''%' + @RecDesc + '%'') '
	If (@RecDesc2 is not null)
		SET @StrWhere = @StrWhere + ' AND (RecDesc2 like N''%' + @RecDesc2 + '%'') '

	If (@SourceProcessNo <> '0')
	begin
		Declare @DistributionSourceProcessNo AS varchar(2)
		SET @DistributionSourceProcessNo = '0'
	
		SELECT @DistributionSourceProcessNo = SettingValue
		FROM pub.tblSettings
		WHERE SettingKey = 'DistributionSourceProcessNo'

		IF @DistributionSourceProcessNo<>'0' AND @DistributionSourceProcessNo=@SourceProcessNo
			SET @SourceProcessNo = @SourceProcessNo + ',10'

		If (@Manu = 1)
			SET @StrWhere = @StrWhere  + ' AND ((IsAutoDoc = 0) OR SourceProcessNo IN (' + @SourceProcessNo + '))'
		Else
			SET @StrWhere = @StrWhere  + ' AND (SourceProcessNo IN (' + @SourceProcessNo + '))'
	end

	If (@Auto = 0) 
		SET @StrWhere = @StrWhere + ' AND (IsAutoDoc <> 1)' 
	If (@Manu = 0) 
		SET @StrWhere = @StrWhere + ' AND (IsAutoDoc <> 0)' 

	-- Filter Starting Doc Rows
	If (@IncludePrimary = 0)
		SET @StrWhere = @StrWhere + ' AND (D.VchKind <> 2) '

	-- Filter Finish Doc Rows
	If (@IncludeFinish = 0)
		SET @StrWhere = @StrWhere + ' AND (D.VchKind <> 3) '

	-- Filter Closing Doc Rows
	If (@IncludeClosed = 0)
		SET @StrWhere = @StrWhere  + ' AND (D.VchKind <> 4) '

	If (@AcntCode1Fr Is Not Null)
		SET @StrWhere = @StrWhere + ' AND Substring(AcntCode, ' + LTrim(Str(@Part1Start)) + ', ' + LTrim(Str(Len(@AcntCode1Fr))) + ') >= ''' + @AcntCode1Fr + ''''

	If (@AcntCode1To Is Not Null)
		SET @StrWhere = @StrWhere + ' AND Substring(AcntCode, ' + LTrim(Str(@Part1Start)) + ', ' + LTrim(Str(Len(@AcntCode1To))) + ') <= ''' + @AcntCode1To + ''''

	If (@AcntCode2Fr Is Not Null)
		SET @StrWhere = @StrWhere + ' AND Substring(AcntCode, ' + LTrim(Str(@Part2Start)) + ', ' + LTrim(Str(Len(@AcntCode2Fr))) + ') >= ''' + @AcntCode2Fr + ''''

	If (@AcntCode2To Is Not Null)
		SET @StrWhere = @StrWhere + ' AND Substring(AcntCode, ' + LTrim(Str(@Part2Start)) + ', ' + LTrim(Str(Len(@AcntCode2To))) + ') <= ''' + @AcntCode2To + ''''

	If (@AcntCode3Fr Is Not Null)
		SET @StrWhere = @StrWhere + ' AND Substring(AcntCode, ' + LTrim(Str(@Part3Start)) + ', ' + LTrim(Str(Len(@AcntCode3Fr))) + ') >= ''' + @AcntCode3Fr + ''''

	If (@AcntCode3To Is Not Null)
		SET @StrWhere = @StrWhere + ' AND Substring(AcntCode, ' + LTrim(Str(@Part3Start)) + ', ' + LTrim(Str(Len(@AcntCode3To))) + ') <= ''' + @AcntCode3To + ''''

	If (@AcntCode4Fr Is Not Null)
		SET @StrWhere = @StrWhere + ' AND Substring(AcntCode, ' + LTrim(Str(@Part4Start)) + ', ' + LTrim(Str(Len(@AcntCode4Fr))) + ') >= ''' + @AcntCode4Fr + ''''

	If (@AcntCode4To Is Not Null)
		SET @StrWhere = @StrWhere + ' AND Substring(AcntCode, ' + LTrim(Str(@Part4Start)) + ', ' + LTrim(Str(Len(@AcntCode4To))) + ') <= ''' + @AcntCode4To + ''''

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
		Set @StrWhere = @StrWhere + '
			AND acc.funPermitted2(' + LTRim(Str(@UserID)) + ', Substring(AcntCode, ' + LTrim(Str(@Part1Start)) + ', ' + LTrim(Str(@Part1Len)) + '), 1)= 1 '
		Set @StrWhere = @StrWhere + '
			AND acc.funPermitted2(' + LTRim(Str(@UserID)) + ', Substring(AcntCode, ' + LTrim(Str(@Part2Start)) + ', ' + LTrim(Str(@Part2Len)) + '), 2)= 1 '
		Set @StrWhere = @StrWhere + '
			AND acc.funPermitted2(' + LTRim(Str(@UserID)) + ', Substring(AcntCode, ' + LTrim(Str(@Part3Start)) + ', ' + LTrim(Str(@Part3Len)) + '), 3)= 1 '
		Set @StrWhere = @StrWhere + '
			AND acc.funPermitted2(' + LTRim(Str(@UserID)) + ', Substring(AcntCode, ' + LTrim(Str(@Part4Start)) + ', ' + LTrim(Str(@Part4Len)) + '), 4)= 1 '
	end;
	/* ======= Remain Clause ======= */

	SET @StrWhereR = @StrWhere

	If (@RemainMode = 0) -- no remain
	Begin
		/* nothing */
		SET @StrWhereR = @StrWhereR
	End
	Else If (@RemainMode = 1) -- only by date 
	Begin
		If (@DocDateFr Is Not Null)
			SET @StrWhereR = @StrWhereR + ' AND (D.DocDate < ''' + @DocDateFr + ''')'
	End
	Else If	(@RemainMode = 2) -- only by serial
	Begin
		If (@SerialNoFr Is Not Null)
			SET @StrWhereR = @StrWhereR + '	AND (D.SerialNo < ' + LTrim(Str(@SerialNoFr)) + ')'
	End
	Else If	(@RemainMode = 3) -- both date and serial
	Begin
		If (@DocDateFr Is Not Null) AND (@SerialNoFr Is Not Null)
			SET @StrWhereR = @StrWhereR + '	AND (D.DocDate < ''' + @DocDateFr + ''') AND (D.SerialNo < ' + LTrim(Str(@SerialNoFr)) + ')'
	End
	Else If	(@RemainMode = 4) -- date or serial
	Begin
		If (@DocDateFr Is Not Null) AND (@SerialNoFr Is Not Null)
			SET @StrWhereR = @StrWhereR + '	AND ((D.DocDate < ''' + @DocDateFr + ''') OR (D.SerialNo < ' + LTrim(Str(@SerialNoFr)) + '))'
	End

	/* ====== End Remain Clause ======== */

	If (@DocDateFr Is Not Null)
		SET @StrWhere = @StrWhere + ' AND (D.DocDate >= ''' + @DocDateFr + ''')'
	If (@DocDateTo Is Not Null)
		SET @StrWhere = @StrWhere + ' AND (D.DocDate <= ''' + @DocDateTo + ''')'

	If (@SerialNoFr Is Not Null)
		SET @StrWhere = @StrWhere + ' AND (D.SerialNo >= ' + LTrim(Str(@SerialNoFr)) + ')'
	If (@SerialNoTo Is Not Null)
		SET @StrWhere = @StrWhere + ' AND (D.SerialNo <= ' + LTrim(Str(@SerialNoTo)) + ')'

	If (@OldSerialNoFr Is Not Null) AND @OldSerialNoFr>0
		SET @StrWhere = @StrWhere + ' AND (OldSerialNo >= ' + LTrim(Str(@OldSerialNoFr)) + ')'
	If (@OldSerialNoTo Is Not Null) AND @OldSerialNoTo>0
		SET @StrWhere = @StrWhere + ' AND (OldSerialNo <= ' + LTrim(Str(@OldSerialNoTo)) + ')'

	If (@DebtorsOnly = 1)
		SET @StrWhere = @StrWhere + ' AND (Debit > 0) '
	If (@DebtorsOnly = 0)
		SET @StrWhere = @StrWhere + ' AND (Credit > 0) '

	/** ====== Prepare SELECT Section ============= ***/
	if @CustomerPartNo = 1
	Begin
		Set @CustomerPartStart	  = @Part1Start
		Set @CustomerPartLayerLen = @LayerLen
	End
	Else if @CustomerPartNo = 2
	Begin
		Set @CustomerPartStart	  = @Part2Start
		Set @CustomerPartLayerLen = @Part2Len
	End
	Else if @CustomerPartNo = 3
	Begin
		Set @CustomerPartStart    = @Part3Start
		Set @CustomerPartLayerLen = @Part3Len
	End
	Else if @CustomerPartNo = 4
	Begin
		Set @CustomerPartStart    = @Part4Start
		Set @CustomerPartLayerLen = @Part4Len
	End
		
	--===============
	If @PartNumber = 1 
	Begin
		SET @Group1Part = '1'
		SET @Group2Part = '2'
		SET @Group3Part = '3'
		SET @Group4Part = '4'

		SET @Group1 = 'Cast(Substring(AcntCode, ' + LTrim(Str(@Part1Start)) + ', ' + LTrim(Str(@LayerLen)) + ') AS VarChar(20))'

		If @Group2Exist = 1 
			SET @Group2 = 'Cast(Substring(AcntCode, ' + LTrim(Str(@Part2Start)) + ', ' + LTrim(Str(@Part2Len)) + ') AS VarChar(20))'
		Else
			SET @Group2 = 'Cast(''0'' AS VarChar(20))'
	
		If @Group3Exist = 1 
			SET @Group3 = 'Cast(Substring(AcntCode, ' + LTrim(Str(@Part3Start)) + ', ' + LTrim(Str(@Part3Len)) + ') AS VarChar(20))'
		Else
			SET @Group3 = 'Cast(''0'' AS VarChar(20))'

		If @Group4Exist = 1 
			SET @Group4 = 'Cast(Substring(AcntCode, ' + LTrim(Str(@Part4Start)) + ', ' + LTrim(Str(@Part4Len)) + ') AS VarChar(20))'
		Else
			SET @Group4 = 'Cast(''0'' AS VarChar(20))'
	End

	If @PartNumber = 2
	Begin
		SET @Group1Part = '2'
		SET @Group2Part = '1'
		SET @Group3Part = '3'
		SET @Group4Part = '4'

		SET @Group1 = 'Cast(Substring(AcntCode, ' + LTrim(Str(@Part2Start)) + ', ' + LTrim(Str(@LayerLen)) + ') AS VarChar(20))'

		If @Group2Exist = 1 
			SET @Group2 = 'Cast(Substring(AcntCode, ' + LTrim(Str(@Part1Start)) + ', ' + LTrim(Str(@Part1Len)) + ') AS VarChar(20))'
		Else
			SET @Group2 = 'Cast(''0'' AS VarChar(20))'
	
		If @Group3Exist = 1 
			SET @Group3 = 'Cast(Substring(AcntCode, ' + LTrim(Str(@Part3Start)) + ', ' + LTrim(Str(@Part3Len)) + ') AS VarChar(20))'
		Else
			SET @Group3 = 'Cast(''0'' AS VarChar(20))'

		If @Group4Exist = 1 
			SET @Group4 = 'Cast(Substring(AcntCode, ' + LTrim(Str(@Part4Start)) + ', ' + LTrim(Str(@Part4Len)) + ') AS VarChar(20))'
		Else
			SET @Group4 = 'Cast(''0'' AS VarChar(20))'
	End

	If @PartNumber = 3
	Begin
		SET @Group1Part = '3'
		SET @Group2Part = '1'
		SET @Group3Part = '2'
		SET @Group4Part = '4'

		SET @Group1 = 'Cast(Substring(AcntCode, ' + LTrim(Str(@Part3Start)) + ', ' + LTrim(Str(@LayerLen)) + ') AS VarChar(20))'

		If @Group2Exist = 1 
			SET @Group2 = 'Cast(Substring(AcntCode, ' + LTrim(Str(@Part1Start)) + ', ' + LTrim(Str(@Part1Len)) + ') AS VarChar(20))'
		Else
			SET @Group2 = 'Cast(''0'' AS VarChar(20))'
	
		If @Group3Exist = 1 
			SET @Group3 = 'Cast(Substring(AcntCode, ' + LTrim(Str(@Part2Start)) + ', ' + LTrim(Str(@Part2Len)) + ') AS VarChar(20))'
		Else
			SET @Group3 = 'Cast(''0'' AS VarChar(20))'

		If @Group4Exist = 1 
			SET @Group4 = 'Cast(Substring(AcntCode, ' + LTrim(Str(@Part4Start)) + ', ' + LTrim(Str(@Part4Len)) + ') AS VarChar(20))'
		Else
			SET @Group4 = 'Cast(''0'' AS VarChar(20))'
	End

	If @PartNumber = 4
	Begin
		SET @Group1Part = '4'
		SET @Group2Part = '1'
		SET @Group3Part = '2'
		SET @Group4Part = '3'

		SET @Group1 = 'Cast(Substring(AcntCode, ' + LTrim(Str(@Part4Start)) + ', ' + LTrim(Str(@LayerLen)) + ') AS VarChar(20))'

		If @Group2Exist = 1 
			SET @Group2 = 'Cast(Substring(AcntCode, ' + LTrim(Str(@Part1Start)) + ', ' + LTrim(Str(@Part1Len)) + ') AS VarChar(20))'
		Else
			SET @Group2 = 'Cast(''0'' AS VarChar(20))'
	
		If @Group3Exist = 1 
			SET @Group3 = 'Cast(Substring(AcntCode, ' + LTrim(Str(@Part2Start)) + ', ' + LTrim(Str(@Part2Len)) + ') AS VarChar(20))'
		Else
			SET @Group3 = 'Cast(''0'' AS VarChar(20))'

		If @Group4Exist = 1 
			SET @Group4 = 'Cast(Substring(AcntCode, ' + LTrim(Str(@Part3Start)) + ', ' + LTrim(Str(@Part3Len)) + ') AS VarChar(20))'
		Else
			SET @Group4 = 'Cast(''0'' AS VarChar(20))'
	End

	
	--=========================
	
	If  @CampaignID > 0 
		SET @StrAcntWhere = @StrAcntWhere + ' AND ' + pub.funGetFilterString(@SessionNo, @ReportID, @CampaignID, 'CampaignID') 

	If  @VisitPathID1 > 0 
		SET @StrAcntWhere = @StrAcntWhere + ' AND ' + pub.funGetFilterString(@SessionNo, @ReportID, @VisitPathID1, 'VisitPathID1') 
		
	If  @VisitPathID2 > 0 
		SET @StrAcntWhere = @StrAcntWhere + ' AND ' + pub.funGetFilterString(@SessionNo, @ReportID, @VisitPathID2, 'VisitPathID2') 
		
	If  @VisitPathID3 > 0 
		SET @StrAcntWhere = @StrAcntWhere + ' AND ' + pub.funGetFilterString(@SessionNo, @ReportID, @VisitPathID3, 'VisitPathID3') 
		
	If  @VisitPathID4 > 0 
		SET @StrAcntWhere = @StrAcntWhere + ' AND ' + pub.funGetFilterString(@SessionNo, @ReportID, @VisitPathID4, 'VisitPathID4') 
		
	If @SalesRoomClass > 0 
		SET @StrAcntWhere = @StrAcntWhere + ' AND ' + pub.funGetFilterString(@SessionNo, @ReportID, @SalesRoomClass, 'SalesRoomClass') 
		
	If  @StrAcntWhere <> ''
		SET @StrAcntWhere = '
		INNER JOIN (Select AcntCode AcntC From acc.tblAcnt Where PartNumber = ' + LTrim(RTrim(Str(@CustomerPartNo))) + ' 
		'+  @StrAcntWhere +'
		) a 
		ON Cast(Substring(AcntCode, ' + LTrim(Str(@CustomerPartStart)) + ', ' + LTrim(Str(@CustomerPartLayerLen)) + ') AS VarChar(20)) = a.AcntC '
	--=========================
	
	
	-- Prepare Debit & Credit fields
	-- if Remain Requested then calc debit remain instead of debit value
	-- and credit remain instead of credit value
	-- else prepare Debit & Credit Fields
	If (@RemainMode <> 0) AND (@RemainSum = 0) -- Remain Mode
	Begin
		SET @StrDebitR  = 'CASE WHEN (Debit > Credit) THEN (Debit - Credit) ELSE Cast(0 AS BigInt) End'
		SET @StrCreditR = 'CASE WHEN (Credit > Debit) THEN (Credit - Debit) ELSE Cast(0 AS BigInt) End'
	End
	Else -- Normal Mode
	Begin
		SET @StrDebitR = 'Debit' 
		SET @StrCreditR = 'Credit'
	End

	set @StrGroup = @Group1 

	If @Group2Exist = 1
		SET @StrGroup = @StrGroup + ',' + @Group2
	If @Group3Exist = 1 
		SET @StrGroup = @StrGroup + ',' + @Group3
	If @Group4Exist = 1 
		SET @StrGroup = @StrGroup + ',' + @Group4

	if (@UseCurrency = 1) 
		set @StrFrom = 'acc.vwVoucherDtl2 D'
	else
		set @StrFrom = 'acc.tblVoucherDtl D'
	
	if (@UseCurrency = 1) 
			set @StrMainFeilds = ' ,MainDebit, MainCredit'
		else
			set @StrMainFeilds = '  ,Debit MainDebit, Credit MainCredit'

	create table #tbl_AccountingBookSummary2_Result
	(
		DocDate		char(10) collate arabic_cs_as not null,
		ProcessID	int null,
		ProcessNo	int null,
		ProcDesc	nvarchar(4000) null,
		Group1		varchar(20) collate arabic_cs_as null,
		Group2		varchar(20) collate arabic_cs_as null,
		Group3		varchar(20) collate arabic_cs_as null,
		Group4		varchar(20) collate arabic_cs_as null,
		Debit		float,
		Credit		float,
		MainDebit	float,
		MainCredit	float
	);

	-- Remain section 
	If (@RemainMode <> 0)
	SET @StrSelectR = N'
		insert into #tbl_AccountingBookSummary2_Result(DocDate, ProcessID, ProcessNo, ProcDesc, Group1, Group2, Group3, Group4, Debit, Credit,MainDebit, MainCredit)
		select	''0000/00/00'', 0, 0, ''نقل مانده'', Group1, Group2, Group3, Group4, Sum(Debit) Debit, Sum(Credit) Credit,Sum(MainDebit) MainDebit, Sum(MainCredit) MainCredit
		from 
		(
			select ' + @Group1 + ' As Group1, ' + @Group2 + ' As Group2, ' + @Group3 + ' As Group3, ' + @Group4 + ' As Group4, Debit, Credit' + @StrMainFeilds + '
			from ' + @StrFrom + ' INNER JOIN acc.tblVoucherHdr H on D.SerialNo=H.SerialNo ' + @StrAcntWhere + '
			where ' + @StrWhereR + '
		) T 
		group by group1, Group2, Group3, Group4
		having (Sum(Debit) <> 0) OR (Sum(Credit) <> 0) '

	print @StrSelect;
	exec sp_executesql @StrSelect;

	-- Main section 
	SET @StrSelect = '
		INSERT INTO #tbl_AccountingBookSummary2_Result(DocDate, ProcessID, ProcessNo, ProcDesc, Group1, Group2, Group3, Group4, Debit, Credit,MainDebit, MainCredit)
		SELECT	''1111/11/11'', SourceProcessID, SourceProcessNo, P.ProcessName, Group1, Group2, Group3, Group4,
				Sum(Debit) Debit, Sum(Credit) Credit,Sum(MainDebit) MainDebit, Sum(MainCredit) MainCredit
		FROM	
		(
			select SourceProcessID, SourceProcessNo, ' + @Group1 + ' As Group1, ' + @Group2 + ' As Group2, ' + @Group3 + ' As Group3, ' + @Group4 + ' As Group4,	Debit, Credit' + @StrMainFeilds + '
			from ' + @StrFrom + ' INNER JOIN acc.tblVoucherHdr H on D.SerialNo=H.SerialNo ' + @StrAcntWhere + '
			where (SourceProcessID <> 0) and ' + @StrWhere + '
		) D 
		left join pub.tblProcess P on P.ProcessID = D.SourceProcessID and P.ProcessNo = D.SourceProcessNo
		GROUP BY SourceProcessID, SourceProcessNo, ProcessName, Group1, Group2,	Group3, Group4
		UNION ALL
		SELECT	D.DocDate, 0 SourceProcessID, 0 SourceProcessNo, RecDesc,
				Group1, Group2, Group3, Group4,	Sum(Debit) Debit, Sum(Credit) Credit,Sum(MainDebit) MainDebit, Sum(MainCredit) MainCredit
		FROM	
		(
			select D.DocDate, RecDesc, ' + @Group1 + ' As Group1, ' + @Group2 + ' As Group2, ' + @Group3 + ' As Group3, ' + @Group4 + ' As Group4,	Debit, Credit' + @StrMainFeilds + '
			from ' + @StrFrom + ' INNER JOIN acc.tblVoucherHdr H on D.SerialNo=H.SerialNo ' + @StrAcntWhere + '
			where (SourceProcessID = 0) and ' + @StrWhere + '
		) D
		GROUP BY DocDate, RecDesc, Group1, Group2, Group3, Group4 '

	print @StrSelect;
	exec sp_executesql @StrSelect;

	SET @StrSelect = '
	select	T.*,
			acc.funGetAcntName(Group1, ' + @Group1Part + ', ' + @LangID + ') Group1Name,
			acc.funGetAcntName(Group2, ' + @Group2Part + ', ' + @LangID + ') Group2Name,
			acc.funGetAcntName(Group3, ' + @Group3Part + ', ' + @LangID + ') Group3Name,
			acc.funGetAcntName(Group4, ' + @Group4Part + ', ' + @LangID + ') Group4Name,
			acc.funPartAcntFullName(Group1 , ' + @Group1Part + ') Group1FullName,
			acc.funPartAcntFullName(Group2 , ' + @Group2Part + ') Group2FullName,
			acc.funPartAcntFullName(Group3 , ' + @Group3Part + ') Group3FullName,
			acc.funPartAcntFullName(Group4 , ' + @Group4Part + ') Group4FullName
	from #tbl_AccountingBookSummary2_Result T 
	order by Group1, Group2, Group3, Group4, DocDate, ProcessID, ProcessNo'

	Print @StrSelect;
	Exec sp_executesql @StrSelect;

END

GO
