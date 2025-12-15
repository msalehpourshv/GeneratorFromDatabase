USE TS_ShirinVatanKarkhaneh_1_1404
GO
SET ANSI_NULLS, QUOTED_IDENTIFIER ON
GO
-- =========== TS-QC:UPDATED ====================
-- Author        : Takrosystem\Ahmadnejad
-- Create date   : 1386/03/21
-- Viewed By	 : 
-- Last Modified : 1392/04/02
-- Last Modifier : Takrosystem\Zia
-- Description   : < دفتر حسابداری >
-- =============================================
Create PROCEDURE [acc].[RptAccountingBook_Detailed]
	@PartNumber		Int = 1,
	@LayerLen		Int = 1,  -- on this part
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
	@RepOptions		VarChar(50) = '000010101000000011101',  -- bit array options
	@RepInfo		NVarChar(100) = '1@1@1'
WITH ENCRYPTION
AS
DECLARE	@LangID			Char(1);
DECLARE	@SessionNo		Int; 
DECLARE	@ReportID		Int;

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
DECLARE	@UseCurrencyPage	Bit; -- 1 = با واحد ارزی جدا سازی  شود
DECLARE	@Auto				Bit; 
DECLARE	@Manu				Bit; 
DECLARE	@GroupByPayRec		Bit; -- دریافت و پرداخت تجمیعی
DECLARE	@GroupByProcess		Bit; -- تجمیعی کلی
DECLARE	@SortBySerial		bit;
DECLARE	@ShowEntezami		bit;
DECLARE @ShowNoteVchKind	bit;
DECLARE @SumSimilarGoods	bit;
DECLARE	@ShowFullName		char(1);
DECLARE	@SourceProcessNo	VARCHAR(30);

DECLARE @StrSerialNo	NVarChar(50);
DECLARE @StrSelect		NVarChar(max);
DECLARE @StrSelect2		NVarChar(max);
DECLARE @StrSelect3		NVarChar(max);
DECLARE @StrFrom		NVarChar(1000);
DECLARE @StrMainFeilds	NVarChar(max);
DECLARE @StrSelectR		NVarChar(max);
DECLARE @StrSelectR2		NVarChar(max);
DECLARE @StrSelectR3		NVarChar(max);
DECLARE @StrWhere		NVarChar(max);
DECLARE @StrWhereR		NVarChar(max);
DECLARE @StrAcntWhere	NVarChar(max);
DECLARE @LimitState1	SmallInt;
DECLARE @LimitState2	SmallInt;
DECLARE @LimitState3	SmallInt;
DECLARE @LimitState4	SmallInt;
DECLARE @Part1Len		TinyInt;
DECLARE @Part2Len		TinyInt;
DECLARE @Part3Len		TinyInt;
DECLARE @Part4Len		TinyInt;

DECLARE @Group1Code		NVarChar(500);
DECLARE @Group2Code		NVarChar(500);
DECLARE @Group3Code		NVarChar(500);
DECLARE @Group4Code		NVarChar(500);

DECLARE @Group1Desc		NVarChar(1000);
DECLARE @Group2Desc		NVarChar(1000);
DECLARE @Group3Desc		NVarChar(1000);
DECLARE @Group4Desc		NVarChar(1000);

DECLARE @Group1Part		Char(1);
DECLARE @Group2Part		Char(1);
DECLARE @Group3Part		Char(1);
DECLARE @Group4Part		Char(1);

DECLARE @GroupByList	NVarChar(2000);
DECLARE @ExtraFilter	NVarChar(2000);

DECLARE @StrDescField		NVarChar(200);
DECLARE @StrDebitField		NVarChar(500);
DECLARE @StrCreditField		NVarChar(500);

DECLARE @CampaignID				int;
DECLARE @VisitPathID1			int;
DECLARE @VisitPathID2			int;
DECLARE @VisitPathID3			int;
DECLARE @VisitPathID4			int;
DECLARE @SalesRoomClass			int;
DECLARE @CustomerPartStart		VarChar(20);
DECLARE @CustomerPartLayerLen	VarChar(20);
DECLARE @OldSerialNoFr		Int = Null;
DECLARE @OldSerialNoTo		Int = Null;

BEGIN

	SET NOCOUNT ON;

	IF (@RepInfo Is Null)		SET @RepInfo = '1@1@1'
	IF (@RepOptions Is Null)	SET @RepOptions = '000010101000000011101'

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
		
	if LEN(@RepOptions) > 19
		SET @SortBySerial	= Substring(@RepOptions, 20, 1)
	else
		SET @SortBySerial	= 0	

	if LEN(@RepOptions) > 20
		SET @ShowEntezami	= Substring(@RepOptions, 21, 1)
	else
		SET @ShowEntezami	= 1
	
	if LEN(@RepOptions) > 21
		SET @ShowFullName	= Substring(@RepOptions, 22, 1)
	else
		SET @ShowFullName	= '0'
			
	if LEN(@RepOptions) > 23
		SET @SourceProcessNo= Substring(@RepOptions, 24, 1)
	else
		SET @SourceProcessNo= '0'
	SET @UseCurrencyPage	= Substring(@RepOptions, 27, 1)

	SET @ShowNoteVchKind	= Substring(@RepOptions, 29, 1)
	--SubDetail2
	SET @SumSimilarGoods	= Substring(@RepOptions, 31, 1)
	
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
	set @OldSerialNoTo	= pub.funSplitString(@RepInfo, '@', 13);


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

	--begin try
	--	--drop table ##RptAccountingBook_Detailed_tblResult1
	--	drop table ##RptAccountingBook_Detailed_tblResult2
	--end try
	--begin catch
	--end catch
	
	--------------------------------------------------------------------
	Declare @CustomerPartNo AS Tinyint
	
	SET @CustomerPartNo = 0
	
	SELECT @CustomerPartNo = SettingValue
	FROM pub.tblSettings
	WHERE SettingKey = 'AcntPartNumberForRemainCalculation'
		
	/* ========== Set WHERE Clause ================ */
	if (@GroupByProcess = 1)
		set @StrFrom = 'acc.vwVoucherDtl_ProcessSum'

	else if (@GroupByPayRec = 1)
	begin
		if (@UseCurrency = 1) 
			set @StrFrom = 'acc.vwVoucherDtl_PayRecSum2'
		else
			set @StrFrom = 'acc.vwVoucherDtl_PayRecSum'
	end
	else 
		if (@UseCurrency = 1) 
			set @StrFrom = 'acc.vwVoucherDtl2'
		else
			set @StrFrom = 'acc.tblVoucherDtl'

	if (@UseCurrency = 1) 
			set @StrMainFeilds = ' ,MainDebit, MainCredit'
		else
			set @StrMainFeilds = ' ,ABS(CurrencyAmount) CurrencyAmount
				,CASE WHEN Debit > 0 and CurrencyAmount>0 THEN ABS(CurrencyAmount) ELSE CASE WHEN Credit> 0 and CurrencyAmount<0 THEN ABS(CurrencyAmount) ELSE 0 END END AS MainDebit
				,CASE WHEN Credit> 0 and CurrencyAmount>0 THEN ABS(CurrencyAmount) ELSE CASE WHEN Debit > 0 and CurrencyAmount<0 THEN ABS(CurrencyAmount) ELSE 0 END END AS MainCredit'

	-- Voucher Kind <> 'Note'
	if @ShowNoteVchKind = 'False'
		Set @StrWhere = '(VchKind > 0)'
	ELSE
		Set @StrWhere = '(1=1)'

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
	
	If (@SourceProcessNo <> '0')
	begin
		Declare @DistributionSourceProcessNo AS varchar(2)
		SET @DistributionSourceProcessNo = '0'
	
		SELECT @DistributionSourceProcessNo = SettingValue
		FROM pub.tblSettings
		WHERE SettingKey = 'DistributionSourceProcessNo'

		IF @DistributionSourceProcessNo<>'0' AND @DistributionSourceProcessNo=@SourceProcessNo
			SET @SourceProcessNo = @SourceProcessNo + ',10' 
		--If (@Manu = 1) 
		--	SET @StrWhere = @StrWhere  + ' AND ((IsAutoDoc = 0) OR SourceProcessNo = ' + LTrim(STR(@SourceProcessNo)) + ')'
		--Else
			SET @StrWhere = @StrWhere  + ' AND (SourceProcessNo IN (' + @SourceProcessNo + '))'
	end
	
	If (@Auto = 0) 
		SET @StrWhere = @StrWhere + ' AND (IsAutoDoc <> 1)' 
	If (@Manu = 0) 
		SET @StrWhere = @StrWhere + ' AND (IsAutoDoc <> 0)' 
		
	If (@RecDesc is not null and @RecDesc <>'')
		SET @StrWhere = @StrWhere + ' AND (RecDesc like N''%' + @RecDesc + '%'') '
	If (@RecDesc2 is not null and @RecDesc2 <>'')
		SET @StrWhere = @StrWhere + ' AND (RecDesc2 like N''%' + @RecDesc2 + '%'') '

	-- Filter Starting Doc Rows
	If (@IncludePrimary = 0)
		SET @StrWhere = @StrWhere + ' AND (VchKind <> 2) '

	-- Filter Finish Doc Rows
	If (@IncludeFinish = 0)
		SET @StrWhere = @StrWhere + ' AND (VchKind <> 3) '

	-- Filter Closing Doc Rows
	If (@IncludeClosed = 0)
		SET @StrWhere = @StrWhere  + ' AND (VchKind <> 4) '

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
		SET @StrWhere = @StrWhere + ' AND (SELECT	IsNull(COUNT(*), 0) FROM	acc.tblAcntRng WHERE	(UserID = ' + LTRim(Str(@UserID)) + ') AND (PartNumber = 1) AND (AllowCodeView = 1) AND	(LEFT(Substring(AcntCode, ' + LTrim(Str(@Part1Start)) + ', ' + LTrim(Str(@Part1Len)) + '), LEN(ToCode)) >= FromCode) AND 	(LEFT(Substring(AcntCode, ' + LTrim(Str(@Part1Start)) + ', ' + LTrim(Str(@Part1Len)) + '), LEN(ToCode)) <= ToCode) )>0 '
		--SET @StrWhere = @StrWhere + ' AND acc.funPermitted(' + LTRim(Str(@UserID)) + ', Substring(AcntCode, ' + LTrim(Str(@Part1Start)) + ', ' + LTrim(Str(@Part1Len)) + '), 1)= 1 '

	If (@LimitState2 = -1)
		SET @StrWhere = @StrWhere + ' AND LTrim(Substring(AcntCode, ' + LTrim(Str(@Part2Start)) + ', ' + LTrim(Str(@Part2Len)) + ')) = '''' '
	If (@LimitState2 = 0 AND @Part2Start>0 ) 
		SET @StrWhere = @StrWhere + ' AND (Substring(AcntCode, ' + LTrim(Str(@Part2Start)) + ', ' + LTrim(Str(@Part2Len)) + ')='''' OR LEN(AcntCode) < ' + LTrim(Str(@Part2Start)) + ' OR (SELECT	IsNull(COUNT(*), 0) FROM	acc.tblAcntRng WHERE	(UserID = ' + LTRim(Str(@UserID)) + ') AND (PartNumber = 2) AND (AllowCodeView = 1) AND	(LEFT(Substring(AcntCode, ' + LTrim(Str(@Part2Start)) + ', ' + LTrim(Str(@Part2Len)) + '), LEN(ToCode)) >= FromCode) AND 	(LEFT(Substring(AcntCode, ' + LTrim(Str(@Part2Start)) + ', ' + LTrim(Str(@Part2Len)) + '), LEN(ToCode)) <= ToCode) )>0) '
		--SET @StrWhere = @StrWhere + ' AND acc.funPermitted(' + LTRim(Str(@UserID)) + ', Substring(AcntCode, ' + LTrim(Str(@Part2Start)) + ', ' + LTrim(Str(@Part2Len)) + '), 2)= 1 '

	If (@LimitState3 = -1)
		SET @StrWhere = @StrWhere + ' AND LTrim(Substring(AcntCode, ' + LTrim(Str(@Part3Start)) + ', ' + LTrim(Str(@Part3Len)) + ')) = '''' '
	If (@LimitState3 = 0 AND @Part3Start>0) 
		SET @StrWhere = @StrWhere + ' AND (Substring(AcntCode, ' + LTrim(Str(@Part3Start)) + ', ' + LTrim(Str(@Part3Len)) + ')='''' OR LEN(AcntCode) < ' + LTrim(Str(@Part3Start)) + ' OR (SELECT	IsNull(COUNT(*), 0) FROM	acc.tblAcntRng WHERE	(UserID = ' + LTRim(Str(@UserID)) + ') AND (PartNumber = 3) AND (AllowCodeView = 1) AND	(LEFT(Substring(AcntCode, ' + LTrim(Str(@Part3Start)) + ', ' + LTrim(Str(@Part3Len)) + '), LEN(ToCode)) >= FromCode) AND 	(LEFT(Substring(AcntCode, ' + LTrim(Str(@Part3Start)) + ', ' + LTrim(Str(@Part3Len)) + '), LEN(ToCode)) <= ToCode) )>0) '
		--SET @StrWhere = @StrWhere + ' AND acc.funPermitted(' + LTRim(Str(@UserID)) + ', Substring(AcntCode, ' + LTrim(Str(@Part3Start)) + ', ' + LTrim(Str(@Part3Len)) + '), 3)= 1 '

 	If (@LimitState4 = -1)
		SET @StrWhere = @StrWhere + ' AND LTrim(Substring(AcntCode, ' + LTrim(Str(@Part4Start)) + ', ' + LTrim(Str(@Part4Len)) + ')) = '''' '
	If (@LimitState4 = 0 AND @Part4Start>0 ) 
		SET @StrWhere = @StrWhere + ' AND (Substring(AcntCode, ' + LTrim(Str(@Part4Start)) + ', ' + LTrim(Str(@Part4Len)) + ')='''' OR LEN(AcntCode) < ' + LTrim(Str(@Part4Start)) + ' OR (SELECT	IsNull(COUNT(*), 0) FROM	acc.tblAcntRng WHERE	(UserID = ' + LTRim(Str(@UserID)) + ') AND (PartNumber = 4) AND (AllowCodeView = 1) AND	(LEFT(Substring(AcntCode, ' + LTrim(Str(@Part4Start)) + ', ' + LTrim(Str(@Part4Len)) + '), LEN(ToCode)) >= FromCode) AND 	(LEFT(Substring(AcntCode, ' + LTrim(Str(@Part4Start)) + ', ' + LTrim(Str(@Part4Len)) + '), LEN(ToCode)) <= ToCode) )>0) '
		--SET @StrWhere = @StrWhere + ' AND acc.funPermitted(' + LTRim(Str(@UserID)) + ', Substring(AcntCode, ' + LTrim(Str(@Part4Start)) + ', ' + LTrim(Str(@Part4Len)) + '), 4)= 1 '

	If (@UserIsAdmin <> 1)
	begin
		SET @StrWhere = @StrWhere + ' AND (SELECT	IsNull(COUNT(*), 0) FROM	acc.tblAcntRng WHERE	((UserID = ' + LTRim(Str(@UserID)) + ') OR UserID=-1 ) AND (PartNumber = 1) AND (AllowCodeView = 0) AND	(LEFT(Substring(AcntCode, ' + LTrim(Str(@Part1Start)) + ', ' + LTrim(Str(@Part1Len)) + '), LEN(ToCode)) >= FromCode) AND 	(LEFT(Substring(AcntCode, ' + LTrim(Str(@Part1Start)) + ', ' + LTrim(Str(@Part1Len)) + '), LEN(ToCode)) <= ToCode) )=0 '
		SET @StrWhere = @StrWhere + ' AND (SELECT	IsNull(COUNT(*), 0) FROM	acc.tblAcntRng WHERE	((UserID = ' + LTRim(Str(@UserID)) + ') OR UserID=-1 ) AND (PartNumber = 2) AND (AllowCodeView = 0) AND	(LEFT(Substring(AcntCode, ' + LTrim(Str(@Part2Start)) + ', ' + LTrim(Str(@Part2Len)) + '), LEN(ToCode)) >= FromCode) AND 	(LEFT(Substring(AcntCode, ' + LTrim(Str(@Part2Start)) + ', ' + LTrim(Str(@Part2Len)) + '), LEN(ToCode)) <= ToCode) )=0 '
		SET @StrWhere = @StrWhere + ' AND (SELECT	IsNull(COUNT(*), 0) FROM	acc.tblAcntRng WHERE	((UserID = ' + LTRim(Str(@UserID)) + ') OR UserID=-1 ) AND (PartNumber = 3) AND (AllowCodeView = 0) AND	(LEFT(Substring(AcntCode, ' + LTrim(Str(@Part3Start)) + ', ' + LTrim(Str(@Part3Len)) + '), LEN(ToCode)) >= FromCode) AND 	(LEFT(Substring(AcntCode, ' + LTrim(Str(@Part3Start)) + ', ' + LTrim(Str(@Part3Len)) + '), LEN(ToCode)) <= ToCode) )=0 '
		SET @StrWhere = @StrWhere + ' AND (SELECT	IsNull(COUNT(*), 0) FROM	acc.tblAcntRng WHERE	((UserID = ' + LTRim(Str(@UserID)) + ') OR UserID=-1 ) AND (PartNumber = 4) AND (AllowCodeView = 0) AND	(LEFT(Substring(AcntCode, ' + LTrim(Str(@Part4Start)) + ', ' + LTrim(Str(@Part4Len)) + '), LEN(ToCode)) >= FromCode) AND 	(LEFT(Substring(AcntCode, ' + LTrim(Str(@Part4Start)) + ', ' + LTrim(Str(@Part4Len)) + '), LEN(ToCode)) <= ToCode) )=0 '
			--AND acc.funPermitted2(' + LTRim(Str(@UserID)) + ', Substring(AcntCode, ' + LTrim(Str(@Part1Start)) + ', ' + LTrim(Str(@Part1Len)) + '), 1)= 1 '
		--Set @StrWhere = @StrWhere + '
		--	AND acc.funPermitted2(' + LTRim(Str(@UserID)) + ', Substring(AcntCode, ' + LTrim(Str(@Part2Start)) + ', ' + LTrim(Str(@Part2Len)) + '), 2)= 1 '
		--Set @StrWhere = @StrWhere + '
		--	AND acc.funPermitted2(' + LTRim(Str(@UserID)) + ', Substring(AcntCode, ' + LTrim(Str(@Part3Start)) + ', ' + LTrim(Str(@Part3Len)) + '), 3)= 1 '
		--Set @StrWhere = @StrWhere + '
		--	AND acc.funPermitted2(' + LTRim(Str(@UserID)) + ', Substring(AcntCode, ' + LTrim(Str(@Part4Start)) + ', ' + LTrim(Str(@Part4Len)) + '), 4)= 1 '
	end;

	/*** ======= Remain WHERE Clause ======= ***/

	SET @StrWhereR = @StrWhere

	if (@SerialNoFr is null) and ((@DocDateFr is null) or (@DocDateFr = '')) --3
		set @RemainMode = 0
	if (@SerialNoFr is null) and (@RemainMode = 2) --2
		set @RemainMode = 0
	if ((@DocDateFr is null) or (@DocDateFr = '')) and (@RemainMode = 1) --1
		set @RemainMode = 0

	If (@RemainMode = 0) -- no remain
	Begin
		/* nothing */
		SET @StrWhereR = @StrWhereR + ' and (1<>1)'
	End
	Else If (@RemainMode = 1) -- only by date 
	Begin
		If (@DocDateFr Is Not Null)
			SET @StrWhereR = @StrWhereR + ' AND (DocDate < ''' + @DocDateFr + ''')'
	End
	Else If	(@RemainMode = 2) -- only by serial
	Begin
		If (@SerialNoFr Is Not Null)
			SET @StrWhereR = @StrWhereR + '	AND (SerialNo < ' + LTrim(Str(@SerialNoFr)) + ')'
	End
	Else If	(@RemainMode = 3) -- both date and serial
	Begin
		If (@DocDateFr Is Not Null) AND (@SerialNoFr Is Not Null)
			SET @StrWhereR = @StrWhereR + '	AND (DocDate < ''' + @DocDateFr + ''') AND (SerialNo < ' + LTrim(Str(@SerialNoFr)) + ')'
	End
	Else If	(@RemainMode = 4) -- date or serial
	Begin
		If (@DocDateFr Is Not Null) AND (@SerialNoFr Is Not Null)
			SET @StrWhereR = @StrWhereR + '	AND ((DocDate < ''' + @DocDateFr + ''') OR (SerialNo < ' + LTrim(Str(@SerialNoFr)) + '))'
	End
	--Else If	(@RemainMode = 5) -- only by OldSerial

	/*** ====== End Remain WHERE ======== ***/

	If (@DocDateFr Is Not Null)
		SET @StrWhere = @StrWhere + ' AND (DocDate >= ''' + @DocDateFr + ''')'
	If (@DocDateTo Is Not Null)
		SET @StrWhere = @StrWhere + ' AND (DocDate <= ''' + @DocDateTo + ''')'

	If (@SerialNoFr Is Not Null)
		SET @StrWhere = @StrWhere + ' AND (SerialNo >= ' + LTrim(Str(@SerialNoFr)) + ')'
	If (@SerialNoTo Is Not Null)
		SET @StrWhere = @StrWhere + ' AND (SerialNo <= ' + LTrim(Str(@SerialNoTo)) + ')'

	If (@DebtorsOnly = 1)
		SET @StrWhere = @StrWhere + ' AND (Debit > 0) '
	If (@DebtorsOnly = 0)
		SET @StrWhere = @StrWhere + ' AND (Credit > 0) '
		
	/** ====== End Main WHERE Clause ============== ***/
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

		SET @Group1Code = 'Cast(Substring(AcntCode, ' + LTrim(Str(@Part1Start)) + ', ' + LTrim(Str(@LayerLen)) + ') AS VarChar(20))'

		If @Group2Exist = 1 
			SET @Group2Code = 'Cast(Substring(AcntCode, ' + LTrim(Str(@Part2Start)) + ', ' + LTrim(Str(@Part2Len)) + ') AS VarChar(20))'
		Else
			SET @Group2Code = 'Cast(''0'' AS VarChar(20))'
	
		If @Group3Exist = 1 
			SET @Group3Code = 'Cast(Substring(AcntCode, ' + LTrim(Str(@Part3Start)) + ', ' + LTrim(Str(@Part3Len)) + ') AS VarChar(20))'
		Else
			SET @Group3Code = 'Cast(''0'' AS VarChar(20))'

		If @Group4Exist = 1 
			SET @Group4Code = 'Cast(Substring(AcntCode, ' + LTrim(Str(@Part4Start)) + ', ' + LTrim(Str(@Part4Len)) + ') AS VarChar(20))'
		Else
			SET @Group4Code = 'Cast(''0'' AS VarChar(20))'
	End

	If @PartNumber = 2
	Begin
		SET @Group1Part = '2'
		SET @Group2Part = '1'
		SET @Group3Part = '3'
		SET @Group4Part = '4'

		SET @Group1Code = 'Cast(Substring(AcntCode, ' + LTrim(Str(@Part2Start)) + ', ' + LTrim(Str(@LayerLen)) + ') AS VarChar(20))'

		If @Group2Exist = 1 
			SET @Group2Code = 'Cast(Substring(AcntCode, ' + LTrim(Str(@Part1Start)) + ', ' + LTrim(Str(@Part1Len)) + ') AS VarChar(20))'
		Else
			SET @Group2Code = 'Cast(''0'' AS VarChar(20))'
	
		If @Group3Exist = 1 
			SET @Group3Code = 'Cast(Substring(AcntCode, ' + LTrim(Str(@Part3Start)) + ', ' + LTrim(Str(@Part3Len)) + ') AS VarChar(20))'
		Else
			SET @Group3Code = 'Cast(''0'' AS VarChar(20))'

		If @Group4Exist = 1 
			SET @Group4Code = 'Cast(Substring(AcntCode, ' + LTrim(Str(@Part4Start)) + ', ' + LTrim(Str(@Part4Len)) + ') AS VarChar(20))'
		Else
			SET @Group4Code = 'Cast(''0'' AS VarChar(20))'
	End

	If @PartNumber = 3
	Begin
		SET @Group1Part = '3'
		SET @Group2Part = '1'
		SET @Group3Part = '2'
		SET @Group4Part = '4'

		SET @Group1Code = 'Cast(Substring(AcntCode, ' + LTrim(Str(@Part3Start)) + ', ' + LTrim(Str(@LayerLen)) + ') AS VarChar(20))'

		If @Group2Exist = 1 
			SET @Group2Code = 'Cast(Substring(AcntCode, ' + LTrim(Str(@Part1Start)) + ', ' + LTrim(Str(@Part1Len)) + ') AS VarChar(20))'
		Else
			SET @Group2Code = 'Cast(''0'' AS VarChar(20))'
	
		If @Group3Exist = 1 
			SET @Group3Code = 'Cast(Substring(AcntCode, ' + LTrim(Str(@Part2Start)) + ', ' + LTrim(Str(@Part2Len)) + ') AS VarChar(20))'
		Else
			SET @Group3Code = 'Cast(''0'' AS VarChar(20))'

		If @Group4Exist = 1 
			SET @Group4Code = 'Cast(Substring(AcntCode, ' + LTrim(Str(@Part4Start)) + ', ' + LTrim(Str(@Part4Len)) + ') AS VarChar(20))'
		Else
			SET @Group4Code = 'Cast(''0'' AS VarChar(20))'
	End

	If @PartNumber = 4
	Begin
		SET @Group1Part = '4'
		SET @Group2Part = '1'
		SET @Group3Part = '2'
		SET @Group4Part = '3'

		SET @Group1Code = 'Cast(Substring(AcntCode, ' + LTrim(Str(@Part4Start)) + ', ' + LTrim(Str(@LayerLen)) + ') AS VarChar(20))'

		If @Group2Exist = 1 
			SET @Group2Code = 'Cast(Substring(AcntCode, ' + LTrim(Str(@Part1Start)) + ', ' + LTrim(Str(@Part1Len)) + ') AS VarChar(20))'
		Else
			SET @Group2Code = 'Cast(''0'' AS VarChar(20))'
	
		If @Group3Exist = 1 
			SET @Group3Code = 'Cast(Substring(AcntCode, ' + LTrim(Str(@Part2Start)) + ', ' + LTrim(Str(@Part2Len)) + ') AS VarChar(20))'
		Else
			SET @Group3Code = 'Cast(''0'' AS VarChar(20))'

		If @Group4Exist = 1 
			SET @Group4Code = 'Cast(Substring(AcntCode, ' + LTrim(Str(@Part3Start)) + ', ' + LTrim(Str(@Part3Len)) + ') AS VarChar(20))'
		Else
			SET @Group4Code = 'Cast(''0'' AS VarChar(20))'
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
	
	
	Declare @FullName as Nvarchar(500)
	IF @ShowFullName = '1'
		SET @FullName = 
			'acc.funPartAcntFullName(Group1 , ' + @Group1Part + ') Group1FullName,
			 acc.funPartAcntFullName(Group2 , ' + @Group2Part + ') Group2FullName,
			 acc.funPartAcntFullName(Group3 , ' + @Group3Part + ') Group3FullName,
			 acc.funPartAcntFullName(Group4 , ' + @Group4Part + ') Group4FullName,'
	ELSE
		SET @FullName = 
			'CAST('''' as nvarchar(300)) Group1FullName,
			 CAST('''' as nvarchar(300)) Group2FullName,
			 CAST('''' as nvarchar(300)) Group3FullName,
			 CAST('''' as nvarchar(300)) Group4FullName,'					
	--=========================
	SET @GroupByList = @Group1Code

	If @Group2Exist = 1 
		SET @GroupByList = @GroupByList + ', ' + @Group2Code

	If @Group3Exist = 1 
		SET @GroupByList = @GroupByList + ', ' + @Group3Code

	If @Group4Exist = 1 
		SET @GroupByList = @GroupByList + ', ' + @Group4Code

	-- Prepare Remain section Select
	Set @StrSelectR = N'
		SELECT	0 SerialNo, DocDate, Debit, Credit' + @StrMainFeilds + ', RecDesc1, RecDesc2, 
				-1 AS DocTypeCode, Group1, Group2, Group3, Group4,
				0 AS SourceProcessID, 0 AS SourceProcessNo, 0 AS SourceFiscalYear, 0 AS SourceSerialNo, 
				''0'' AS SaleTypeID, 1 AS DocRowNo,1 as RowNo, Cast(0 AS Bit) AS IsShowDetail, 0 SessionNo, 
				0 Emphasize, 0 Emphasize2, 0 Emphasize3,1 VchKind,'''' as CurrencyTypeID,
				0 AS ForeColor , -1 AS BackColor,
				ISNULL((SELECT	FirstName FROM	acc.tblAcntDtl WHERE AcntCode=Group1 AND PartNumber=' + @Group1Part + ' AND LanguageID=' + @LangID + '),'''') FirstName ,
				ISNULL((SELECT	LastName FROM	acc.tblAcntDtl WHERE AcntCode=Group1 AND PartNumber=' + @Group1Part + ' AND LanguageID=' + @LangID + '),'''') LastName ,
				ISNULL((SELECT	OrganzationName FROM	acc.tblAcntDtl WHERE AcntCode=Group1 AND PartNumber=' + @Group1Part + ' AND LanguageID=' + @LangID + '),'''') OrganzationName ,
				ISNULL((SELECT	AcntName FROM	acc.tblAcntDtl WHERE AcntCode=Group1 AND PartNumber=' + @Group1Part + ' AND LanguageID=' + @LangID + '),'''') Group1Name ,
				ISNULL((SELECT	AcntName FROM	acc.tblAcntDtl WHERE AcntCode=Group2 AND PartNumber=' + @Group2Part + ' AND LanguageID=' + @LangID + '),'''') Group2Name ,
				ISNULL((SELECT	AcntName FROM	acc.tblAcntDtl WHERE AcntCode=Group3 AND PartNumber=' + @Group3Part + ' AND LanguageID=' + @LangID + '),'''') Group3Name ,
				ISNULL((SELECT	AcntName FROM	acc.tblAcntDtl WHERE AcntCode=Group4 AND PartNumber=' + @Group4Part + ' AND LanguageID=' + @LangID + '),'''') Group4Name ,
				'''' UserName, '
				+ @FullName + '
				(
					SELECT	AcntComment
					FROM	acc.tblAcntDtl
					WHERE	(AcntCode = Group1) AND (PartNumber = ' + @Group1Part + ') AND LanguageID = ' + @LangID + '
				) As Group1Desc,
				(
					SELECT	AcntComment
					FROM	acc.tblAcntDtl
					WHERE	(AcntCode = Group2) AND (PartNumber = ' + @Group2Part + ') AND LanguageID = ' + @LangID + '
				) As Group2Desc,
				(
					SELECT	AcntComment
					FROM	acc.tblAcntDtl
					WHERE	(AcntCode = Group3) AND (PartNumber = ' + @Group3Part + ') AND LanguageID = ' + @LangID + '
				) As Group3Desc,
				(
					SELECT	AcntComment
					FROM	acc.tblAcntDtl
					WHERE	(AcntCode = Group4) AND (PartNumber = ' + @Group4Part + ') AND LanguageID = ' + @LangID + '
				) As Group4Desc,
				(
					SELECT	Address1
					FROM	acc.tblAcntDtl
					WHERE	(AcntCode = Group1) AND (PartNumber = ' + @Group1Part + ') AND LanguageID = ' + @LangID + '
				) As Group1Address,
				(
					SELECT	Address2
					FROM	acc.tblAcntDtl
					WHERE	(AcntCode = Group1) AND (PartNumber = ' + @Group1Part + ') AND LanguageID = ' + @LangID + '
				) As Group1Address2,
				(
					SELECT	Address1
					FROM	acc.tblAcntDtl
					WHERE	(AcntCode = Group2) AND (PartNumber = ' + @Group2Part + ') AND LanguageID = ' + @LangID + '
				) As Group2Address,
				(
					SELECT	Address2
					FROM	acc.tblAcntDtl
					WHERE	(AcntCode = Group2) AND (PartNumber = ' + @Group2Part + ') AND LanguageID = ' + @LangID + '
				) As Group2Address2,
				(
					SELECT	Address1
					FROM	acc.tblAcntDtl
					WHERE	(AcntCode = Group3) AND (PartNumber = ' + @Group3Part + ') AND LanguageID = ' + @LangID + '
				) As Group3Address,
				(
					SELECT	Address2
					FROM	acc.tblAcntDtl
					WHERE	(AcntCode = Group3) AND (PartNumber = ' + @Group3Part + ') AND LanguageID = ' + @LangID + '
				) As Group3Address2,
				(
					SELECT	Address1
					FROM	acc.tblAcntDtl
					WHERE	(AcntCode = Group4) AND (PartNumber = ' + @Group4Part + ') AND LanguageID = ' + @LangID + '
				) As Group4Address,
				(
					SELECT	Address2
					FROM	acc.tblAcntDtl
					WHERE	(AcntCode = Group4) AND (PartNumber = ' + @Group4Part + ') AND LanguageID = ' + @LangID + '
				) As Group4Address2, 0 OldSerialNo
				,'''' as DocDesc2				
				,0 as CurrencyRate										
				,''ریال'' as CurrencyTypeName'

	Set @StrSelectR2 = N'	FROM
		(
			SELECT	Cast(''-'' AS VarChar(10)) DocDate, IsNull(SUM(Debit), 0) Debit, IsNull(Sum(Credit), 0) Credit,IsNull(SUM(CASE WHEN Debit>0 THEN CurrencyAmount ELSE -1 * CurrencyAmount END), 0) CurrencyAmount, IsNull(SUM(Debit), 0) MainDebit, IsNull(Sum(Credit), 0) MainCredit,
					Cast(''نقل مانده کد  '' AS NVarChar(4000)) AS RecDesc1, Cast('''' AS NVarChar(4000)) AS RecDesc2,
					' + @Group1Code + ' As Group1,
					' + @Group2Code + ' As Group2,
					' + @Group3Code + ' As Group3,
					' + @Group4Code + ' As Group4
			FROM	' + @StrFrom 			
		Set @StrSelectR3 = N' ' + @StrAcntWhere + '
			WHERE	' + @StrWhereR + '
			GROUP BY ' + @GroupByList + '
		) R 
		WHERE (R.Debit <> 0) OR (R.Credit <> 0) '

	If (@IncludeDetail = 1)
		Set @StrDescField = 'RecDesc2'
	Else
		Set @StrDescField = 'Cast('''' AS NVarChar(4000))'

	If (@GroupByDate = 1)
		SET @StrSerialNo = '0 AS SerialNo'
	Else
		SET @StrSerialNo = 'SerialNo'


	SET @StrSelect = N'
		SELECT	M.*,IsNull(ST.AccReportFontColor,0) AS ForeColor, IsNull(ST.AccReportBackColor,-1) AS BackColor,
				ISNULL((SELECT	FirstName FROM	acc.tblAcntDtl WHERE AcntCode=Group1 AND PartNumber=' + @Group1Part + ' AND LanguageID=' + @LangID + '),'''') FirstName ,
				ISNULL((SELECT	LastName FROM	acc.tblAcntDtl WHERE AcntCode=Group1 AND PartNumber=' + @Group1Part + ' AND LanguageID=' + @LangID + '),'''') LastName ,
				ISNULL((SELECT	OrganzationName FROM	acc.tblAcntDtl WHERE AcntCode=Group1 AND PartNumber=' + @Group1Part + ' AND LanguageID=' + @LangID + '),'''') OrganzationName ,
				ISNULL((SELECT	AcntName FROM	acc.tblAcntDtl WHERE AcntCode=Group1 AND PartNumber=' + @Group1Part + ' AND LanguageID=' + @LangID + '),'''') Group1Name ,
				ISNULL((SELECT	AcntName FROM	acc.tblAcntDtl WHERE AcntCode=Group2 AND PartNumber=' + @Group2Part + ' AND LanguageID=' + @LangID + '),'''') Group2Name ,
				ISNULL((SELECT	AcntName FROM	acc.tblAcntDtl WHERE AcntCode=Group3 AND PartNumber=' + @Group3Part + ' AND LanguageID=' + @LangID + '),'''') Group3Name ,
				ISNULL((SELECT	AcntName FROM	acc.tblAcntDtl WHERE AcntCode=Group4 AND PartNumber=' + @Group4Part + ' AND LanguageID=' + @LangID + '),'''') Group4Name ,
				pub.GetUserName(M.SessionNo) AS UserName, '
				+ @FullName + '
				(	SELECT	AcntComment
					FROM	acc.tblAcntDtl
					WHERE	(AcntCode=Group1) AND (PartNumber=' + @Group1Part + ') AND LanguageID=' + @LangID + '
				) As Group1Desc,
				(	SELECT	AcntComment
					FROM	acc.tblAcntDtl
					WHERE	(AcntCode=Group2) AND (PartNumber=' + @Group2Part + ') AND LanguageID=' + @LangID + '
				) As Group2Desc,
				(	SELECT	AcntComment
					FROM	acc.tblAcntDtl
					WHERE	(AcntCode=Group3) AND (PartNumber=' + @Group3Part + ') AND LanguageID=' + @LangID + '
				) As Group3Desc,
				(	SELECT	AcntComment
					FROM	acc.tblAcntDtl
					WHERE	(AcntCode=Group4) AND (PartNumber=' + @Group4Part + ') AND LanguageID=' + @LangID + '
				) As Group4Desc,
				(	SELECT	Address1
					FROM	acc.tblAcntDtl
					WHERE	(AcntCode=Group1) AND (PartNumber=' + @Group1Part + ') AND LanguageID=' + @LangID + '
				) As Group1Address,
				(	SELECT	Address1
					FROM	acc.tblAcntDtl
					WHERE	(AcntCode=Group2) AND (PartNumber=' + @Group2Part + ') AND LanguageID=' + @LangID + '
				) As Group2Address,
				(	SELECT	Address1
					FROM	acc.tblAcntDtl
					WHERE	(AcntCode=Group3) AND (PartNumber=' + @Group3Part + ') AND LanguageID=' + @LangID + '
				) As Group3Address,
				(	SELECT	Address1
					FROM	acc.tblAcntDtl
					WHERE	(AcntCode=Group4) AND (PartNumber=' + @Group4Part + ') AND LanguageID=' + @LangID + '
				) As Group4Address,
				(	SELECT	Address2
					FROM	acc.tblAcntDtl
					WHERE	(AcntCode=Group1) AND (PartNumber=' + @Group1Part + ') AND LanguageID=' + @LangID + '
				) As Group1Address2,
				(	SELECT	Address2
					FROM	acc.tblAcntDtl
					WHERE	(AcntCode=Group2) AND (PartNumber=' + @Group2Part + ') AND LanguageID=' + @LangID + '
				) As Group2Address2,
				(	SELECT	Address2
					FROM	acc.tblAcntDtl
					WHERE	(AcntCode=Group3) AND (PartNumber=' + @Group3Part + ') AND LanguageID=' + @LangID + '
				) As Group3Address2,
				(	SELECT	Address2
					FROM	acc.tblAcntDtl
					WHERE	(AcntCode=Group4) AND (PartNumber=' + @Group4Part + ') AND LanguageID=' + @LangID + '
				) As Group4Address2,(select OldSerialNo from acc.tblVoucherHdr H where H.SerialNo = M.SerialNo) as OldSerialNo
				,(select DocDesc2 from acc.tblVoucherHdr H where H.SerialNo = M.SerialNo) as DocDesc2				
				'
				if (@UseCurrency = 1 And @UseCurrencyPage=1) 
				SET @StrSelect = @StrSelect  + N'
					,(select Case when  CurrencyAmount >0 THEN Case When Credit=0 Then ABS(Debit / CurrencyAmount) ELSE ABS(Credit/ CurrencyAmount) END ELSE 0 END CurrencyRate from acc.tblVoucherDtl H WHERE H.SerialNo = M.SerialNo AND H.RowNo=M.RowNo) as CurrencyRate				
					,isnull((SELECT top 1 C.CurrencyTypeName From  pub.tblCurrencyTypesDtl AS C Where M.CurrencyTypeID = C.CurrencyTypeID),''ریال'') as CurrencyTypeName '
				else
				SET @StrSelect = @StrSelect  + N'
					,0 as CurrencyRate	,''ریال'' as CurrencyTypeName 
				'
				SET @StrSelect2 = N'		
		FROM
		(	SELECT	SerialNo,DocDate,Debit,Credit ' + @StrMainFeilds + ',
					RecDesc RecDesc1,' + RTrim(@StrDescField) + ' RecDesc2,
					(Case When Credit=0 Then 0 Else 1 End) DocTypeCode,
					' + @Group1Code + ' As Group1,
					' + @Group2Code + ' As Group2,
					' + @Group3Code + ' As Group3,
					' + @Group4Code + ' As Group4,
					SourceProcessID,SourceProcessNo,SourceFiscalYear,SourceSerialNo, 
					ISNULL((SELECT	top 1  SaleTypeID FROM	inv.tblStorageDocsHdr
					        WHERE ProcessID = V.SourceProcessID AND ProcessNo = V.SourceProcessNo AND 
					              SerialNo  = V.SourceSerialNo AND  FiscalYear= V.SourceFiscalYear),'''') AS SaleTypeID,
					DocRowNo,RowNo,IsShowDetail,SessionNo, Emphasize, Emphasize2, Emphasize3,VchKind,CurrencyTypeID
			FROM	' + @StrFrom + ' V '  + @StrAcntWhere + '
			WHERE	'
		--	 + LTrim(RTrim(@StrWhere)) + '
		--) M
		--LEFT JOIN [sal].[tblSaleTypes] ST ON ST.SaleTypeID=M.SaleTypeID '

	-- Create Select String 
	-- If include remain then attach remain & union it	
	--Print @StrSelect ;
	--Print @StrWhere ;
	--Print  '
	--	) M
	--	LEFT JOIN [sal].[tblSaleTypes] ST ON ST.SaleTypeID=M.SaleTypeID ' ;
		
	--SET @StrSelect = @StrSelect + LTrim(RTrim(@StrWhere)) + '
	--	) M
	--	LEFT JOIN [sal].[tblSaleTypes] ST ON ST.SaleTypeID=M.SaleTypeID '
	
	--exec sp_executesql @StrSelect
	
	--if (@RemainMode <> 0)
	--begin
	--	Print @StrSelectR;
	--	exec sp_executesql @StrSelectR;
	--end
	
	Declare @ExtraParmsSubReport	nvarchar(10) 
	Set @ExtraParmsSubReport=@SumSimilarGoods

	if (@RemainMode <> 0)
	begin
		PRINT ' 
			select *  from (
			SELECT * FROM (' 
			PRINT  @StrSelect 
			PRINT  @StrSelect2 
			PRINT LTrim(RTrim(@StrWhere)) 
			PRINT ') M
		     LEFT JOIN [sal].[tblSaleTypes] ST ON ST.SaleTypeID=M.SaleTypeID ' + ') R1
			union all '
			PRINT @StrSelectR
			PRINT @StrSelectR2
			PRINT @StrSelectR3
			PRINT' ) a 
			inner join  acc.tblAcnt b on b.PartNumber=' + @Group1Part + ' and a.Group1=b.AcntCode '
			
		Set @StrSelect = ' 
			select *   ,'''+@ExtraParmsSubReport+''' as ExtraParmsSubReport from (
			SELECT * FROM (' +  @StrSelect +@StrSelect2 + LTrim(RTrim(@StrWhere)) + ') M
		     LEFT JOIN [sal].[tblSaleTypes] ST ON ST.SaleTypeID=M.SaleTypeID ' + ') R1
			union all
			' + @StrSelectR+ @StrSelectR2+ @StrSelectR3+ ' ) a 
			inner join  acc.tblAcnt b on b.PartNumber=' + @Group1Part + ' and a.Group1=b.AcntCode
			LEFT JOIN acc.tblSalesRoomClassDtl SRC ON SRC.SalesRoomClassID = b.SalesRoomClass  AND SRC.LanguageID = ' + LTrim(RTrim(@LangID)) + ' ' 
	END	
	else
	begin
	
		PRINT ' 
			select *   from (
			' 
			PRINT  @StrSelect 
			PRINT  @StrSelect2 
			PRINT LTrim(RTrim(@StrWhere)) 
			PRINT ') M
		     LEFT JOIN [sal].[tblSaleTypes] ST ON ST.SaleTypeID=M.SaleTypeID ' + ' ) a 
			inner join  acc.tblAcnt b on b.PartNumber=' + @Group1Part + ' and a.Group1=b.AcntCode '
			
		Set @StrSelect = ' 
			select *  ,'''+@ExtraParmsSubReport+''' as ExtraParmsSubReport  from (
			' +  @StrSelect +@StrSelect2 + LTrim(RTrim(@StrWhere)) + ') M
		     LEFT JOIN [sal].[tblSaleTypes] ST ON ST.SaleTypeID=M.SaleTypeID ' + ' ) a 
			inner join  acc.tblAcnt b on b.PartNumber=' + @Group1Part + ' and a.Group1=b.AcntCode 
			LEFT JOIN acc.tblSalesRoomClassDtl SRC ON SRC.SalesRoomClassID = b.SalesRoomClass  AND SRC.LanguageID = ' + LTrim(RTrim(@LangID)) + ' ' 
	END	
	-- Set Order By Clause

	SET @StrSelect = @StrSelect + ' Where 1=1 '
	
	If (@OldSerialNoFr Is Not Null and @OldSerialNoFr >0)
		SET @StrSelect = @StrSelect + ' AND  (OldSerialNo >= ' + Str(@OldSerialNoFr) + ')'
	If (@OldSerialNoTo Is Not Null  and @OldSerialNoTo >0)
		SET @StrSelect = @StrSelect + ' AND (OldSerialNo <= ' + Str(@OldSerialNoTo) + ')'

	If (@GroupByDate = 1)
	begin
		Set @StrSelect = @StrSelect + '
		ORDER BY DocDate,SerialNo,DocRowNo'
	end
	Else
	begin
		if (@SortBySerial = 1)

			Set @StrSelect = @StrSelect + '
			ORDER BY a.OldSerialNo,a.DocRowNo'
		else
			Set @StrSelect = @StrSelect + '
			ORDER BY a.SerialNo,a.DocRowNo'
	end;

	--Print @StrSelect;
	Exec sp_executesql @StrSelect;
END
GO
