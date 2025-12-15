USE TS_ShirinVatanKarkhaneh_1_1404
GO
SET ANSI_NULLS, QUOTED_IDENTIFIER ON
GO
-- =========== TS-QC:UPDATED ====================
-- Author		 : TakroSystem\Ahmadnejad
-- Create date   : 1388/02/13
-- Viewed By	 : 
-- Last Modified : 1388/07/13
-- Last Modifier : TakroSystem\Ahmadnejad
-- Description	 : <Receivable Documents Report>
-- ----------------------------------------------
-- گزارش اسناد دریافتنی - پاس شده
-- ==============================================
Create  PROCEDURE [trs].[RptReceivableDocs_Receipt] 
	@ProcessID			Int = 1,  -- Not Used 
	@ProcessNo			Int = 1,
	@FiscalYearFr		Int = Null,
	@SerialNoFr			Int = Null,
	@FiscalYearTo		Int = Null,
	@SerialNoTo			Int = Null,
	@DebitCode1			Int = 0, -- بدهکار
	@DebitCode2			Int = 0,
	@DebitCode3			Int = 0,
	@DebitCode4			Int = 0,
	@CreditCode1		Int = 0, -- بستانکار
	@CreditCode2		Int = 0,
	@CreditCode3		Int = 0,
	@CreditCode4		Int = 0,
	@DocDateFr			Char(10) = Null,
	@DocDateTo			Char(10) = Null,
	@UsanceDateFr		Char(10) = Null, -- تاریخ سررسید از
	@UsanceDateTo		Char(10) = Null, --تاریخ سررسید تا
	@VolumeYearFr		Int = Null,		 -- شماره ردیف دفتر از
	@VolumeRowFr		Int = Null,		 -- شماره ردیف دفتر از
	@VolumeYearTo		Int = Null,		 -- شماره ردیف دفتر تا
	@VolumeRowTo		Int = Null,		 -- شماره ردیف دفتر تا
	@ChequeNoFr			VarChar(20) = Null, -- شماره چک از
	@ChequeNoTo			VarChar(20) = Null, -- شماره چک تا
	@AmountFr			VarChar(20) = Null, -- مبلغ از // dont use bigint
	@AmountTo			VarChar(20) = Null, -- مبلغ تا // dont use bigint
	@CityName			NVarChar(50) = Null,
	@BankName			NVarChar(50) = Null,
	@BranchCode			NVarChar(20) = Null,
	@BranchName			NVarChar(20) = Null, -- Not Used
	@AccountNo			NVarChar(20) = Null,  -- شماره حساب بانکی
	@AccountOwnerName	NVarChar(50) = Null,
	@AccountOwnerType	Bit = Null,  -- نوع صاحب حساب
	@SortFields			NVarChar(100) = Null, -- لیست فیلدها برای مرتب سازی
	@RepOptions			NVarChar(100) = 100, -- < 100: Receipt In Cash > < 010: Receipt In Bank > < 001: PaidToPerson >
	@RepInfo			NVarChar(100) = '1@1@1'
WITH ENCRYPTION
As
DECLARE @StrSelect	NVarChar(max);
DECLARE @StrWhere	NVarChar(max);

DECLARE	@StrPID		NVarChar(20);
DECLARE @BaseDate	Char(10)

DECLARE @IncludeCash		Bit;  -- مربوط به صندوق 
DECLARE @IncludeBank		Bit;  -- مربوط به بانکها 
DECLARE @ChequeIsDigital	Bit;  -- مربوط به چک  دیجیتال

DECLARE @StrBaseDate	nVarchar(20)
DECLARE	@TrsCalcAvgByDocDate bit;

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

BEGIN   

--	SET @LanguageID = pub.funGetCurrentLanguageID();

	SET NOCOUNT ON;

	-- Init Variables -----------------------------------------------
	If (@RepInfo	Is Null)	SET @RepInfo    = '1@1@1'
	If (@ProcessNo  Is Null)	SET @ProcessNo  = 1
	If (@SortFields Is Null)	SET @SortFields = 'FiscalYear, SerialNo'
	If (@RepOptions Is Null)	SET @RepOptions = '100'

	IF (@FiscalYearFr Is Null)	SET @SerialNoFr	= Null;
	IF (@FiscalYearTo Is Null)	SET @SerialNoTo	= Null;

	IF (@SerialNoFr	Is Null)	SET @FiscalYearFr = Null;
	IF (@SerialNoTo	Is Null)	SET @FiscalYearTo = Null;

	IF (@VolumeYearFr Is Null)	SET @VolumeRowFr = Null;
	IF (@VolumeYearTo Is Null)	SET @VolumeRowTo = Null;

	IF (@VolumeRowFr Is Null)	SET @VolumeYearFr = Null;
	IF (@VolumeRowTo Is Null)	SET @VolumeYearTo = Null;

	IF (@DebitCode1 Is Null)	SET @DebitCode1 = 0;
	IF (@DebitCode2 Is Null)	SET @DebitCode2 = 0;
	IF (@DebitCode3 Is Null)	SET @DebitCode3 = 0;
	IF (@DebitCode4 Is Null)	SET @DebitCode4 = 0;

	IF (@CreditCode1 Is Null)	SET @CreditCode1 = 0;
	IF (@CreditCode2 Is Null)	SET @CreditCode2 = 0;
	IF (@CreditCode3 Is Null)	SET @CreditCode3 = 0;
	IF (@CreditCode4 Is Null)	SET @CreditCode4 = 0;

	SET @IncludeCash = Cast(Cast(SubString(@RepOptions, 1, 1) As Int) As Bit)
	SET @IncludeBank = Cast(Cast(SubString(@RepOptions, 2, 1) As Int) As Bit)
	Set @ChequeIsDigital = Cast(Cast(SubString(@RepOptions,3,1) As Int) As Bit)

	IF (@IncludeCash = 0) AND (@IncludeBank = 0) 
		SET @IncludeCash = 1

	SET	@LangID		= pub.funSplitString(@RepInfo, '@', 1);
	SET @SessionNo	= pub.funSplitString(@RepInfo, '@', 2);
	SET @ReportID	= pub.funSplitString(@RepInfo, '@', 3);

	SET @CampaignID		  = pub.funSplitString(@RepInfo, '@', 6);
	SET @VisitPathID1	  = pub.funSplitString(@RepInfo, '@', 7);
	SET @VisitPathID2	  = pub.funSplitString(@RepInfo, '@', 8);
	SET @VisitPathID3	  = pub.funSplitString(@RepInfo, '@', 9);
	SET @VisitPathID4	  = pub.funSplitString(@RepInfo, '@', 10);
	SET @SalesRoomClass	  = pub.funSplitString(@RepInfo, '@', 11);

	SELECT @BaseDate = LEFT([pub].[funFarsiDate](GetDate()), 10)

	select @TrsCalcAvgByDocDate = isnull(SettingValue, 0)
	from pub.tblSettings
	where SettingKey = 'TrsCalcAvgByDocDate'

	if (@TrsCalcAvgByDocDate = 1)
		set @StrBaseDate = 'D.DocDate'
	else
		set @StrBaseDate = '''' + @BaseDate + ''''
		
	--------------------------------------------------------------------

	-- WHERE Clause ----------------------------------------------------
	SET @StrPID = '0'

	if (@IncludeCash = 1)
		SET @StrPID = @StrPID + ',12'
	if (@IncludeBank = 1)
		SET @StrPID = @StrPID + ',22'

	SELECT @StrWhere = ' D.PayTypeID IN (6, 26) 
		AND D.ProcessID IN (' + @StrPID + ')
		AND (D.ProcessNo = ' + LTRim(Str(@ProcessNo)) + ')'
		
	If (@FiscalYearFr Is Not Null)
	SET @StrWhere = @StrWhere + ' 
		AND (D.FiscalYear > ' + LTrim(Str(@FiscalYearFr)) + ' OR (D.FiscalYear = ' + LTrim(Str(@FiscalYearFr)) + ' AND D.SerialNo >= ' + LTrim(Str(@SerialNoFr)) + ')) '

	If (@FiscalYearTo Is Not Null)
	SET @StrWhere = @StrWhere + ' 
		AND (D.FiscalYear < ' + LTrim(Str(@FiscalYearTo)) + ' OR (D.FiscalYear = ' + LTrim(Str(@FiscalYearTo)) + ' AND D.SerialNo <= ' + LTrim(Str(@SerialNoTo)) + ')) '

	If (@VolumeYearFr Is Not Null)
	SET @StrWhere = @StrWhere + ' 
		AND (D.VolumeFiscalYear > ' + LTrim(Str(@VolumeYearFr)) + ' OR (D.VolumeFiscalYear = ' + LTrim(Str(@VolumeYearFr)) + ' AND D.VolumeRowNo >= ' + LTrim(Str(@VolumeRowFr)) + ')) '

	If (@VolumeYearTo Is Not Null)
	SET @StrWhere = @StrWhere + ' 
		AND (D.VolumeFiscalYear < ' + LTrim(Str(@VolumeYearTo)) + ' OR (D.VolumeFiscalYear = ' + LTrim(Str(@VolumeYearTo)) + ' AND D.VolumeRowNo <= ' + LTrim(Str(@VolumeRowTo)) + ')) '

	IF	(@DocDateFr Is Not Null) SET @StrWhere = @StrWhere + ' 
		AND (D.DocDate >= ''' + @DocDateFr + ''')'
	IF	(@DocDateTo Is Not Null) SET @StrWhere = @StrWhere + ' 
		AND (D.DocDate <= ''' + @DocDateTo + ''')'

	IF	(@UsanceDateFr Is Not Null) SET @StrWhere = @StrWhere + ' 
		AND (D.ChequeDate >= ''' + @UsanceDateFr + ''')'
	IF	(@UsanceDateTo Is Not Null) SET @StrWhere = @StrWhere + ' 
		AND (D.ChequeDate <= ''' + @UsanceDateTo + ''')'

	IF	(@DebitCode1 > 0)
		SET @StrWhere = @StrWhere + ' AND ' + pub.funGetFilterString(@SessionNo, @ReportID, @DebitCode1, 'D.DebitCode') 
	IF	(@DebitCode2 > 0)
		SET @StrWhere = @StrWhere + ' AND ' + pub.funGetFilterString(@SessionNo, @ReportID, @DebitCode2, 'D.DebitCode') 
	IF	(@DebitCode3 > 0)
		SET @StrWhere = @StrWhere + ' AND ' + pub.funGetFilterString(@SessionNo, @ReportID, @DebitCode3, 'D.DebitCode') 
	IF	(@DebitCode4 > 0)
		SET @StrWhere = @StrWhere + ' AND ' + pub.funGetFilterString(@SessionNo, @ReportID, @DebitCode4, 'D.DebitCode') 

	IF	(@CreditCode1 > 0)
		SET @StrWhere = @StrWhere + ' AND ' + pub.funGetFilterString(@SessionNo, @ReportID, @CreditCode1, 'D.CreditCode') 
	IF	(@CreditCode2 > 0)
		SET @StrWhere = @StrWhere + ' AND ' + pub.funGetFilterString(@SessionNo, @ReportID, @CreditCode2, 'D.CreditCode') 
	IF	(@CreditCode3 > 0)
		SET @StrWhere = @StrWhere + ' AND ' + pub.funGetFilterString(@SessionNo, @ReportID, @CreditCode3, 'D.CreditCode') 
	IF	(@CreditCode4 > 0)
		SET @StrWhere = @StrWhere + ' AND ' + pub.funGetFilterString(@SessionNo, @ReportID, @CreditCode4, 'D.CreditCode') 

	IF	(@ChequeNoFr Is Not Null) SET @StrWhere = @StrWhere + ' AND (D.ChequeNo >= ''' + LTrim(@ChequeNoFr) + ''')'
	IF	(@ChequeNoTo Is Not Null) SET @StrWhere = @StrWhere + ' AND (D.ChequeNo <= ''' + LTrim(@ChequeNoTo) + ''')'

	If (@AmountFr Is Not Null) SET @StrWhere = @StrWhere + ' AND D.Amount >= ' + LTrim(@AmountFr)
	If (@AmountTo Is Not Null) SET @StrWhere = @StrWhere + ' AND D.Amount <= ' + LTrim(@AmountTo)

	IF (@CityName Is Not Null)	SET @StrWhere = @StrWhere + ' AND RTrim(LTrim(LD.LocationName)) Like N''%' + LTrim(@CityName) + '%'''
	IF (@BankName Is Not Null)	SET @StrWhere = @StrWhere + ' AND RTrim(LTrim(BT.BankTypeName)) Like N''%' + LTrim(@BankName) + '%'''
	IF (@BranchCode Is Not Null)SET @StrWhere = @StrWhere + ' AND RTrim(LTrim(D.BranchCode)) = ''' + LTrim(@BranchCode) + ''''
	If (@BranchName Is Not Null)SET @StrWhere = @StrWhere + ' AND RTrim(LTrim(D.BranchName)) Like N''%' + LTrim(@BranchName) + '%'''
	IF (@AccountNo Is Not Null)	SET @StrWhere = @StrWhere + ' AND RTrim(LTrim(D.AccountNo)) = ''' + LTrim(@AccountNo) + ''''

	IF (@AccountOwnerName IS Not Null)
		SET @StrWhere = @StrWhere + ' AND D.AccOwnerName like N''%' + @AccountOwnerName + '%''' 
	IF (@AccountOwnerType IS Not Null)
		SET @StrWhere = @StrWhere + ' AND D.AccountOwnerType = ' + Str(@AccountOwnerType)

	IF (@ChequeIsDigital = 1)
		SET @StrWhere = @StrWhere + ' AND D.ChequeIsDigital = 1' 
	IF (@ChequeIsDigital = 0)
		SET @StrWhere = @StrWhere + ' ' 
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
	
	

-------------------------------------------------------------------------
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
	
		if @ProcessID =2 
		 begin
			Insert into  #tblOurBanks (CreditCode) SELECT  Distinct CreditCode	FROM       trs.tblPayDtl
			exec pub.SpFilterByPermission2 '#tblOurBanks', 'CreditCode', 'trs.tblOurBanks', @UserID; 
			Insert into  #tblAcntCode (AcntCode) SELECT  Distinct CreditCode	FROM       trs.tblPayDtl
			exec pub.SpFilterByPermission2 '#tblAcntCode', 'AcntCode', 'acc.tblAcnt', @UserID; 
			SET @StrWhere =  @StrWhere + '  and  ( D.CreditCode in (SELECT   CreditCode	FROM  #tblOurBanks    ) 
												or   D.CreditCode in (SELECT   AcntCode	FROM  #tblAcntCode    ) )'
		end 
	 if @ProcessID =1 or  @ProcessID =0
		begin 
			Insert into  #tblOurBanks (CreditCode) SELECT  Distinct DebitCode	FROM       trs.tblPayDtl
			exec pub.SpFilterByPermission2 '#tblOurBanks', 'CreditCode', 'trs.tblOurBanks', @UserID; 
			Insert into  #tblAcntCode (AcntCode) SELECT  Distinct DebitCode	FROM       trs.tblPayDtl
			exec pub.SpFilterByPermission2 '#tblAcntCode', 'AcntCode', 'acc.tblAcnt', @UserID; 
			SET @StrWhere =  @StrWhere + '  and (  D.DebitCode in (SELECT   CreditCode	FROM  #tblOurBanks     ) 
												or   D.DebitCode in (SELECT   AcntCode	FROM  #tblAcntCode    ) )   '
		end 
		if @ProcessID =40
		begin 
			Insert into  #tblOurBanks (CreditCode) SELECT  Distinct CreditCode	FROM       trs.tblPayDtl
			Insert into  #tblOurBanks (CreditCode) SELECT  Distinct DebitCode	FROM       trs.tblPayDtl
			exec pub.SpFilterByPermission2 '#tblOurBanks', 'CreditCode', 'trs.tblOurBanks', @UserID; 
				Insert into  #tblAcntCode (AcntCode) SELECT  Distinct CreditCode	FROM       trs.tblPayDtl
				Insert into  #tblAcntCode (AcntCode) SELECT  Distinct DebitCode 	FROM       trs.tblPayDtl
			exec pub.SpFilterByPermission2 '#tblAcntCode', 'AcntCode', 'acc.tblAcnt', @UserID; 
		
			SET @StrWhere =  @StrWhere + '  and ( ( D.DebitCode in (SELECT   CreditCode	FROM  #tblOurBanks    ) or  D.CreditCode in (SELECT   CreditCode	FROM  #tblOurBanks    )  )
												  or  ( D.DebitCode in (SELECT   AcntCode		FROM  #tblAcntCode    ) or  D.CreditCode in (SELECT   AcntCode		FROM  #tblAcntCode    )  ) ) '
		end 

	end 
	
Delete From  #tblAcntCode where AcntCode='' or AcntCode is null
Delete From  #tblOurBanks where CreditCode='' or CreditCode is null

end
----------------------------------------------------------------------------




	-----------------------------------------------------------------
	SET @StrSelect = '
	SELECT	D.*, LD.LocationName, BT.BankTypeName, H.VchNo,
			[pub].GetCodeName(D.DebitCode, ' + @LangID + ') DebitNameA,
			[pub].GetBankName(D.DebitCode, ' + @LangID + ') DebitNameB,
			[pub].GetCodeName(D.CreditCode, ' + @LangID + ') AS CreditNameA,
			[pub].GetBankName(D.CreditCode, ' + @LangID + ') AS CreditNameB,
			(
				SELECT Top 1 CreditCode
				FROM	trs.tblPayDtl
				WHERE	ProcessID IN (1,10) AND
						PayTypeID IN (6,26) AND 
						VolumeFiscalYear = D.VolumeFiscalYear AND 
						VolumeRowNo = D.VolumeRowNo
				ORDER By EventNo ASC
			) FirstCreditCode,
			[pub].funFarsiDateDiff(''Day'', ' + @StrBaseDate + ', D.ChequeDate) AS DateDuration
	FROM	trs.tblPayDtl D
			INNER JOIN trs.tblPayHdr H ON H.ProcessID = D.ProcessID AND H.ProcessNo = D.ProcessNo AND H.FiscalYear = D.FiscalYear AND H.SerialNo = D.SerialNo
			LEFT  JOIN pub.tblLocationsDtl AS LD ON	LD.LocationID = D.LocationID AND LD.LanguageID = ' + @LangID + '
			LEFT  JOIN trs.tblBankTypesDtl AS BT ON BT.BankTypeID = D.BankTypeID AND BT.LanguageID = ' + @LangID + '
			'+@StrAcntWhere+'
	WHERE	' + @StrWhere

	/* ---------------------------------------------------------------------------- */
	SET @StrSelect = '
	SELECT T.*, pub.GetCodeName(T.FirstCreditCode, ' + @LangID + ') AS FirstCreditName
	FROM
	(' + @StrSelect + '
	) T '

	IF (@SortFields Is Not Null)
	SET @StrSelect = @StrSelect + ' 
	ORDER BY ' + @SortFields

	Print @StrSelect;	
	Exec sp_executesql @StrSelect;
End
GO
