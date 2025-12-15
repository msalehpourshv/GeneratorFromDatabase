USE TS_ShirinVatanKarkhaneh_1_1404
GO
SET ANSI_NULLS, QUOTED_IDENTIFIER ON
GO
-- =========== TS-QC:UPDATED ====================
-- Author		 : Ahmadnejad
-- Create date   : 1386/04/19
-- Viewed By	 : 
-- Last Modified : 1392/01/07
-- Description	 : <Receivable Documents Chart>
-- ----------------------------------------------
-- نمودار اسناد دریافتنی
-- ==============================================
create PROCEDURE [trs].[RptReceivableDocs_Chart]
	@ProcessNo		int = 1,
	@CurrentYear	Char(4),    /* سال مالی چهار رقمی */
	@ResultCategory	int = 1, 
	/* ------ Description ------- */
	/*  1 = چکهای موجود در صندوق  */
	/*  2 = چکهای پاس شده         */
	/*  3 = چکهای برگشت خورده     */
	/*  4 = کلیه چکها             */
	/* -------------------------- */
	@IncludeReceive		Bit = 1,  /* ---        دریافت شده --- */
	@IncludePaidPerson	Bit = 1,  /* ---  واگذاری به اشخاص --- */
	@IncludePaidBank	Bit = 1,  /* --- واگذاری به بانکها --- */
	@DebitCode1			Int = 0, -- بدهکار
	@DebitCode2			Int = 0,
	@DebitCode3			Int = 0,
	@DebitCode4			Int = 0,
	@CreditCode1		Int = 0, -- بستانکار
	@CreditCode2		Int = 0,
	@CreditCode3		Int = 0,
	@CreditCode4		Int = 0,
	@RepOptions			varchar(20) = '',
	@RepInfo			NVarChar(100) = Null
WITH ENCRYPTION
As
Declare @StrSelect		NVarChar(2000);
Declare @StrWhere		NVarChar(1000);
Declare @StrProcessID	NVarChar(2000);
Declare @StrQueryPrim	NVarChar(2000);

Declare @ReceivePrimDoc		TinyInt
Declare @ReceiveDoc			TinyInt
Declare @ReceiveReceiptDoc	TinyInt
Declare @ReceiveReturnedDoc	TinyInt

Declare @PaidPersonDoc				TinyInt
Declare @PaidPersonReturnedCashDoc	TinyInt
Declare @PaidPersonReturnedOwnerDoc	TinyInt

Declare @PaidBankPrimDoc			TinyInt
Declare @PaidBankDoc				TinyInt
Declare @PaidBankReceiptDoc			TinyInt
Declare @PaidBankReturnedCashDoc	TinyInt
Declare @PaidBankReturnedOwnerDoc	TinyInt
DECLARE @LangID			Char(1)
DECLARE @SessionNo		VarChar(10)
DECLARE @ReportID		VarChar(10)
DECLARE @StrAcntWhere	NVarChar(4000);
DECLARE @CampaignID				int;
DECLARE @VisitPathID1			int;
DECLARE @VisitPathID2			int;
DECLARE @VisitPathID3			int;
DECLARE @VisitPathID4			int;
DECLARE @SalesRoomClass			int;
Begin   

	Set NoCount On;

	IF (@RepInfo	Is Null)		SET @RepInfo    = '1@1@1'

	IF (@DebitCode1 Is Null)		SET @DebitCode1 = 0
	IF (@DebitCode2 Is Null)		SET @DebitCode2 = 0
	IF (@DebitCode3 Is Null)		SET @DebitCode3 = 0
	IF (@DebitCode4 Is Null)		SET @DebitCode4 = 0

	IF (@CreditCode1 Is Null)		SET @CreditCode1 = 0
	IF (@CreditCode2 Is Null)		SET @CreditCode2 = 0
	IF (@CreditCode3 Is Null)		SET @CreditCode3 = 0
	IF (@CreditCode4 Is Null)		SET @CreditCode4 = 0

	Set @ReceivePrimDoc			= 10      /*  (دریافت چک (اول دوره  */
	Set @ReceiveDoc				= 1       /*             دریافت چک  */
	Set @ReceiveReceiptDoc		= 12      /*             وصول   چک  */
	Set @ReceiveReturnedDoc		= 13      /*             برگشت  چک  */

	Set @PaidPersonDoc				= 2   /*                      واگذاری به اشخاص  */
	Set @PaidPersonReturnedCashDoc	= 17  /*  برگشت چک واگذاری به اشخاص  به  صندوق  */
	Set @PaidPersonReturnedOwnerDoc	= 18  /*  برگشت چک واگذاری به اشخاص به صاحب چک  */

	Set @PaidBankPrimDoc			= 20  /*           (واگذاری به بانکها (اول دوره  */
	Set @PaidBankDoc				= 21  /*                      واگذاری به بانکها  */
	Set @PaidBankReceiptDoc			= 22  /*              وصول چک واگذاری به بانکها  */
	Set @PaidBankReturnedCashDoc	= 23  /*  برگشت چک واگذاری به بانکها  به  صندوق  */
	Set @PaidBankReturnedOwnerDoc	= 24  /*  برگشت چک واگذاری به بانکها به صاحب چک  */

	SET @LangID		= pub.funSplitString(@RepInfo, '@', 1);
	SET @SessionNo	= pub.funSplitString(@RepInfo, '@', 2);
	SET @ReportID	= pub.funSplitString(@RepInfo, '@', 3);

	SET @CampaignID		  = pub.funSplitString(@RepInfo, '@', 6);
	SET @VisitPathID1	  = pub.funSplitString(@RepInfo, '@', 7);
	SET @VisitPathID2	  = pub.funSplitString(@RepInfo, '@', 8);
	SET @VisitPathID3	  = pub.funSplitString(@RepInfo, '@', 9);
	SET @VisitPathID4	  = pub.funSplitString(@RepInfo, '@', 10);
	SET @SalesRoomClass	  = pub.funSplitString(@RepInfo, '@', 11);

	--=========================

	Declare @CustomerPartNo			int;
	DECLARE @CustomerPartStart		int;
	DECLARE @CustomerPartLayerLen	int;

		
	select @CustomerPartNo=[acc].[FunGetAcntInfoForRemain](1)
	select @CustomerPartStart=[acc].[FunGetAcntInfoForRemain](2)
	select @CustomerPartLayerLen= [acc].[FunGetAcntInfoForRemain](3)


	set @StrAcntWhere=' '

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
		ON Cast(Substring(D.CreditCode , ' + Str(@CustomerPartStart) + ', ' + Str(@CustomerPartLayerLen) + ') AS VarChar(20)) = a.AcntC 
		or Cast(Substring(D.DebitCode , ' + Str(@CustomerPartStart) + ', ' + Str(@CustomerPartLayerLen) + ') AS VarChar(20)) = a.AcntC '
			

	--=========================
	
	Set @StrProcessID = ''
	Set @StrWhere  = '(1=1)'

	-- Set Primary Query to Create Days --
	Set @StrQueryPrim = '
	Declare @idx1 Int
	Declare @idx2 Int
	Create Table #tblDays(Days Char(10) Collate Arabic_CS_AS)
	
	-- Fill Table Variale With Year Days --
	Set @idx1 = 0

	While @idx1 <= 12
	Begin
		Set @idx2 = 1

		While @idx2 <= 31
		Begin
			INSERT INTO #tblDays	
			VALUES (	Case When Len(LTrim(Str(@idx1))) < 2 Then ''0'' Else '''' End + Ltrim(Str(@idx1)) + ''/'' + 
						Case When Len(LTrim(Str(@idx2))) < 2 Then ''0'' Else '''' End + LTrim(Str(@idx2))) 
			Set @idx2 = @idx2 + 1
		End

		Set @idx1 = @idx1 + 1
	End;
	'
	
	If	@IncludeReceive = 0 AND	@IncludePaidPerson = 0 AND	@IncludePaidBank = 0
		Set @IncludeReceive = 1

	-- ============= C A T E G O R Y - C L A U S E =================================
	-- Category <1> (Available Cheques) --
	If @ResultCategory = 1 
	Begin
		-- موجود واگذار نشده --
		If @IncludeReceive = 1 
		Begin
			If @StrProcessID <> '' 
				Set @StrProcessID = @StrProcessID + ','
			Set @StrProcessID = @StrProcessID + LTRim(Str(@ReceivePrimDoc)) + ',' + LTRim(Str(@ReceiveDoc)) 
		End

		-- موجود مسترد از اشخاص --
		If @IncludePaidPerson = 1 
		Begin
			If @StrProcessID <> '' 
				Set @StrProcessID = @StrProcessID + ','
			Set @StrProcessID = @StrProcessID + LTRim(Str(@PaidPersonReturnedCashDoc)) 
		End

		-- موجود مسترد از بانک --
		If @IncludePaidBank = 1 
		Begin
			If @StrProcessID <> '' 
				Set @StrProcessID = @StrProcessID + ','
			Set @StrProcessID = @StrProcessID + LTRim(Str(@PaidBankReturnedCashDoc)) 
		End
	End 

	-- Category <2> (Not Available Cheques) --
	Else If @ResultCategory = 2 
	Begin

		-- واگذار شده به بانک --
		If (@IncludePaidBank = 1)
		Begin
			If @StrProcessID <> '' 
				Set @StrProcessID = @StrProcessID + ','
			Set @StrProcessID = @StrProcessID + LTRim(Str(@PaidBankDoc))
		End
		
		-- وصول شده --
		If (@IncludeReceive = 1)
		Begin
			If @StrProcessID <> ''
				Set @StrProcessID = @StrProcessID + ','
			Set @StrProcessID = @StrProcessID + LTRim(Str(@ReceiveReceiptDoc))
		End

		-- واگذار شده به اشخاص --
		If (@IncludePaidPerson = 1)
		Begin
			If @StrProcessID <> '' 
				Set @StrProcessID = @StrProcessID + ','
			Set @StrProcessID = @StrProcessID + LTRim(Str(@PaidPersonDoc))
		End
	End

	-- Category <3> (Returned to Owner Cheques) --
	Else If @ResultCategory = 3  
	Begin

		-- برگشتی در صندوق --
		If @IncludeReceive = 1
		Begin
			If @StrProcessID <> '' 
				Set @StrProcessID = @StrProcessID + ', '
			Set @StrProcessID = @StrProcessID + LTRim(Str(@ReceiveReturnedDoc))
		End

		-- برگشتی از اشخاص --
		If @IncludePaidPerson = 1
		Begin
			If @StrProcessID <> '' 
				Set @StrProcessID = @StrProcessID + ', '
			Set @StrProcessID = @StrProcessID + LTRim(Str(@PaidPersonReturnedOwnerDoc))
		End

		-- برگشتی در بانک --
		If @IncludePaidBank = 1
		Begin
			If @StrProcessID <> '' 
				Set @StrProcessID = @StrProcessID + ', '
			Set @StrProcessID = @StrProcessID + LTRim(Str(@PaidBankReturnedOwnerDoc))
		End
	End

	-- Category <4> (All Cheques) --
	Else If @ResultCategory = 4 
		Set @StrProcessID = LTRim(Str(@ReceivePrimDoc)) + ',' + LTRim(Str(@ReceiveDoc)) 
	-- ============= C A T E G O R Y - C L A U S E =================================

	-- ============= W H E R E - C L A U S E =======================================
	If	(@DebitCode1 > 0)
		SET @StrWhere = @StrWhere + ' AND ' + pub.funGetFilterString(@SessionNo, @ReportID, @DebitCode1, 'D.DebitCode') 
	If	(@DebitCode2 > 0)
		SET @StrWhere = @StrWhere + ' AND ' + pub.funGetFilterString(@SessionNo, @ReportID, @DebitCode2, 'D.DebitCode') 
	If	(@DebitCode3 > 0)
		SET @StrWhere = @StrWhere + ' AND ' + pub.funGetFilterString(@SessionNo, @ReportID, @DebitCode3, 'D.DebitCode') 
	If	(@DebitCode4 > 0)
		SET @StrWhere = @StrWhere + ' AND ' + pub.funGetFilterString(@SessionNo, @ReportID, @DebitCode4, 'D.DebitCode') 

	If	(@CreditCode1 > 0)
		SET @StrWhere = @StrWhere + ' AND ' + pub.funGetFilterString(@SessionNo, @ReportID, @CreditCode1, 'D.CreditCode') 
	If	(@CreditCode2 > 0)
		SET @StrWhere = @StrWhere + ' AND ' + pub.funGetFilterString(@SessionNo, @ReportID, @CreditCode2, 'D.CreditCode') 
	If	(@CreditCode3 > 0)
		SET @StrWhere = @StrWhere + ' AND ' + pub.funGetFilterString(@SessionNo, @ReportID, @CreditCode3, 'D.CreditCode') 
	If	(@CreditCode4 > 0)
		SET @StrWhere = @StrWhere + ' AND ' + pub.funGetFilterString(@SessionNo, @ReportID, @CreditCode4, 'D.CreditCode') 
	-- ============= W H E R E  -  C L A U S E =======================================


---------------------------------------------------------------------------------------------------
	Declare @DonotFilterAcc2Trs AS bit
	SET @DonotFilterAcc2Trs = 0
	SELECT @DonotFilterAcc2Trs = SettingValue
	FROM pub.tblSettings
	WHERE SettingKey = 'DonotFilterAcc2Trs'
		
if @DonotFilterAcc2Trs=0 	
begin

	
	DECLARE	@UserID		Int;
	DECLARE	@UserIsAdmin bit;

	SET @UserID				 = pub.funSplitString(@RepInfo, '@', 4);
	SET @UserIsAdmin		 = pub.funSplitString(@RepInfo, '@', 5);


	BEGIN TRY
		DROP TABLE #tblAcntCode
		DROP TABLE #tblOurBanks
	END TRY
	BEGIN CATCH
	END CATCH
	 CREATE TABLE #tblAcntCode
	(
	AcntCode 			Varchar(20)collate arabic_cs_as null
	)
	 CREATE TABLE #tblOurBanks
	(
		CreditCode 			Varchar(20)collate arabic_cs_as null
	)
	if (@UserIsAdmin = 0)
	begin
	
	 
			Insert into  #tblOurBanks (CreditCode) SELECT  Distinct DebitCode	FROM       trs.tblPayDtl
			exec pub.SpFilterByPermission2 '#tblOurBanks', 'CreditCode', 'trs.tblOurBanks', @UserID; 
			Insert into  #tblAcntCode (AcntCode) SELECT  Distinct DebitCode	FROM       trs.tblPayDtl
			exec pub.SpFilterByPermission2 '#tblAcntCode', 'AcntCode', 'acc.tblAcnt', @UserID; 
			SET @StrWhere =  @StrWhere + '  and (  D.DebitCode in (SELECT   CreditCode	FROM  #tblOurBanks     ) 
												or   D.DebitCode in (SELECT   AcntCode	FROM  #tblAcntCode    ) )'
 
	end 
	
Delete From  #tblAcntCode where AcntCode='' or AcntCode is null
Delete From  #tblOurBanks where CreditCode='' or CreditCode is null

end

------------------------------------------------------------------------------------------------------





	-- ============= S E L E C T - C L A U S E =======================================
	SET @StrSelect = '
		SELECT	Case When Left(D.ChequeDate, 4) < ''' + @CurrentYear + ''' Then ''00/01'' 
					 When Left(D.ChequeDate, 4) = ''' + @CurrentYear + ''' Then Right(D.ChequeDate, 5) 
					 When Left(D.ChequeDate, 4) > ''' + @CurrentYear + ''' Then ''13/01'' END ChequeDate, D.Amount Amount
		FROM	trs.tblPayDtl D 
					INNER JOIN 
					(
						SELECT	D2.VolumeFiscalYear, D2.VolumeRowNo, Max(D2.EventNo) AS EventNo
						FROM	trs.tblPayDtl D2
						WHERE	D2.PayTypeID IN (6, 26) 
								and (D2.ProcessNo = ' + LTRIM(STR(@ProcessNo)) + ')
						GROUP BY D2.VolumeFiscalYear, D2.VolumeRowNo
					 ) VOL ON D.VolumeFiscalYear = VOL.VolumeFiscalYear AND D.VolumeRowNo = VOL.VolumeRowNo AND D.EventNo = VOL.EventNo
		'+@StrAcntWhere+'
		WHERE  ProcessID IN (' + @StrProcessID + ') 
			and (PayTypeID IN (6,26))
			and (D.ProcessNo = ' + LTRIM(STR(@ProcessNo)) + ')
			and ' + @StrWhere

	SET @StrSelect = @StrQueryPrim + '
	SELECT  T.ChequeDate, Sum(T.Amount) Amount
	FROM	(' + @StrSelect + ' 
				UNION all
				Select Days, 0 Amount
				From   #tblDays 
			) T 
	GROUP BY T.ChequeDate; '
	-- ============= S E L E C T - C L A U S E =======================================
 
	PRINT @StrSelect;
	EXEC sp_executesql @StrSelect;
End
GO
