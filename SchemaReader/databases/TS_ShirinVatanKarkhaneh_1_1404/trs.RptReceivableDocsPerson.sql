USE TS_ShirinVatanKarkhaneh_1_1404
GO
SET ANSI_NULLS, QUOTED_IDENTIFIER ON
GO
-- =========== TS-QC:UATED ====================
-- Author		 : TakroSystem\Ahmadnejad
-- Create date   : 1386/03/15
-- Viewed By	 : 
-- Last Modified : 1391/11/30
-- Last Modifier : TakroSystem\Ahmadnejad
-- Description	 : <Receivable Documents Paid To Persons Report>
-- ----------------------------------------------
-- گزارش اسناد دریافتنی واگذار شده به اشخاص
-- ==============================================
Create PROCEDURE [trs].[RptReceivableDocsPerson] 
	@ProcessID		Int = 2, -- 2 = all / 17 = Ret2Cash / 18 = Ret2Owner / 30 = other
	@ProcessNo		Int = 1,
	@FiscalYearFr	Int = Null,
	@SerialNoFr		Int = Null,
	@FiscalYearTo	Int = Null,
	@SerialNoTo		Int = Null,
	@DebitCode1		Int = 0, -- بدهکار
	@DebitCode2		Int = 0,
	@DebitCode3		Int = 0,
	@DebitCode4		Int = 0,
	@CreditCode1	Int = 0, -- بستانکار
	@CreditCode2	Int = 0,
	@CreditCode3	Int = 0,
	@CreditCode4	Int = 0,
	@DocDateFr		VarChar(10) = Null,
	@DocDateTo		VarChar(10) = Null,
	@UsanceDateFr	VarChar(10) = Null, -- تاریخ سررسید از
	@UsanceDateTo	VarChar(10) = Null, -- تاریخ سررسید تا
	@VolumeYearFr	Int = Null,			-- شماره ردیف دفتر از
	@VolumeRowFr	Int = Null,			-- شماره ردیف دفتر از
	@VolumeYearTo	Int = Null,			-- شماره ردیف دفتر تا
	@VolumeRowTo	Int = Null,			-- شماره ردیف دفتر تا
	@ChequeNoFr		VarChar(20) = Null, -- شماره چک از
	@ChequeNoTo		VarChar(20) = Null, -- شماره چک تا
	@AmountFr		VarChar(20) = Null, -- مبلغ از
	@AmountTo		VarChar(20) = Null, -- مبلغ تا
	@CityName		NVarChar(50) = Null,
	@BankName		NVarChar(50) = Null,
	@BranchCode		NVarChar(20) = Null,
	@BranchName		NVarChar(50) = Null, -- Not Used
	@AccountNo		NVarChar(20) = Null,  -- شماره حساب بانکی
	@AccountOwnerType	Bit = Null,  -- Not Used
	@SortFields		NVarChar(100) = Null,-- لیست فیلدها برای مرتب سازی
	@RepInfo		NVarChar(100) = '1@1@1'
WITH ENCRYPTION
As
DECLARE @StrSelect	NVarChar(max);
DECLARE @StrWhere	NVarChar(max);
DECLARE @StrPID		NVarChar(20);

DECLARE @StrTemp		NVarChar(500);
DECLARE @BaseDate		Char(10);

DECLARE @StrBaseDate	nVarchar(20)
DECLARE	@TrsCalcAvgByDocDate bit;

DECLARE @LangID			Char(1);
DECLARE @SessionNo		VarChar(10);
DECLARE @ReportID		VarChar(10);
DECLARE @StrAcntWhere	NVarChar(4000);
DECLARE @CampaignID				int;
DECLARE @VisitPathID1			int;
DECLARE @VisitPathID2			int;
DECLARE @VisitPathID3			int;
DECLARE @VisitPathID4			int;
DECLARE @SalesRoomClass			int;
DECLARE @ChequeIsDigital		int;

BEGIN -- ============================ S T A R T  C O D E ========================================================

	SET NOCOUNT ON;

	--SET @LanguageID = pub.funGetCurrentLanguageID();

	-- Init Variables -----------------------------------------------
	If (@RepInfo	Is Null)	SET @RepInfo    = '1@1@1'
	If (@ProcessNo  Is Null)	SET @ProcessNo  = 1
	If (@SortFields Is Null)	SET @SortFields = 'FiscalYear, SerialNo'

	If (@FiscalYearFr Is Null)	SET @SerialNoFr	= Null;
	If (@FiscalYearTo Is Null)	SET @SerialNoTo	= Null;
	If (@SerialNoFr	Is Null)	SET @FiscalYearFr = Null;
	If (@SerialNoTo	Is Null)	SET @FiscalYearTo = Null;

	If (@VolumeYearFr Is Null)	SET @VolumeRowFr = Null;
	If (@VolumeYearTo Is Null)	SET @VolumeRowTo = Null;
	If (@VolumeRowFr Is Null)	SET @VolumeYearFr = Null;
	If (@VolumeRowTo Is Null)	SET @VolumeYearTo = Null;

	IF (@DebitCode1 Is Null)	SET @DebitCode1 = 0;
	IF (@DebitCode2 Is Null)	SET @DebitCode2 = 0;
	IF (@DebitCode3 Is Null)	SET @DebitCode3 = 0;
	IF (@DebitCode4 Is Null)	SET @DebitCode4 = 0;

	IF (@CreditCode1 Is Null)	SET @CreditCode1 = 0;
	IF (@CreditCode2 Is Null)	SET @CreditCode2 = 0;
	IF (@CreditCode3 Is Null)	SET @CreditCode3 = 0;
	IF (@CreditCode4 Is Null)	SET @CreditCode4 = 0;

	SET	@LangID		= pub.funSplitString(@RepInfo, '@', 1);
	SET @SessionNo	= pub.funSplitString(@RepInfo, '@', 2);
	SET @ReportID	= pub.funSplitString(@RepInfo, '@', 3);

	SET @CampaignID		  = pub.funSplitString(@RepInfo, '@', 6);
	SET @VisitPathID1	  = pub.funSplitString(@RepInfo, '@', 7);
	SET @VisitPathID2	  = pub.funSplitString(@RepInfo, '@', 8);
	SET @VisitPathID3	  = pub.funSplitString(@RepInfo, '@', 9);
	SET @VisitPathID4	  = pub.funSplitString(@RepInfo, '@', 10);
	SET @SalesRoomClass	  = pub.funSplitString(@RepInfo, '@', 11);
	Set @ChequeIsDigital  = pub.funSplitString(@RepInfo, '@',12);

	set @StrPID = '';
	SELECT @BaseDate = LEFT([pub].[funFarsiDate](GetDate()), 10);

	select @TrsCalcAvgByDocDate = isnull(SettingValue, 0)
	from pub.tblSettings
	where SettingKey = 'TrsCalcAvgByDocDate'

	if (@TrsCalcAvgByDocDate = 1)
		set @StrBaseDate = 'D.DocDate'
	else
		set @StrBaseDate = '''' + @BaseDate + ''''
	
	-- Where Section ---------------------------------------------
	select V.*,(
				select top 1 ProcessID
				from trs.tblPayDtl I 
				where I.PayTypeID in (6, 26) 
					and I.ProcessNo = @ProcessNo
					and I.VolumeFiscalYear = V.VolumeFiscalYear 
					and I.VolumeRowNo = V.VolumeRowNo 
					and I.EventNo = V.EventNo
				) ProcessID
	into #tbl_Rec_Last
	from
	(
		SELECT VolumeFiscalYear, VolumeRowNo, Max(EventNo) AS EventNo
		FROM   trs.tblPayDtl D
		WHERE  D.PayTypeID in (6, 26) and (D.ProcessNo = @ProcessNo)
		GROUP  BY VolumeFiscalYear, VolumeRowNo
	) V	

	if (@ProcessID = 17)
		SET @StrPID = '17,23'
	else if (@ProcessID = 18)
		SET @StrPID = '18,24'
	else if (@ProcessID = 30)
		SET @StrPID = '2,10,12,13,20,21,22'
	else if (@ProcessID <> 2)
		SET @StrPID = LTrim(Str(@ProcessID))

	SELECT @StrWhere = ' D.PayTypeID IN (6, 26) 
		AND (D.ProcessID = 2)
		AND (D.ProcessNo = ' + LTRim(Str(@ProcessNo)) + ')'
		
	If (@StrPID <> '')
	SET @StrWhere = @StrWhere + ' 
		AND LAST.ProcessID IN (' + @StrPID + ')'

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

	If @ChequeIsDigital = 1
		SET @StrWhere = @StrWhere + ' AND ChequeIsDigital = 1' 
	If @ChequeIsDigital = 0
		SET @StrWhere = @StrWhere + ' ' 
		
	If  @StrAcntWhere <> ''
		SET @StrAcntWhere = '
		INNER JOIN (Select AcntCode AcntC From acc.tblAcnt Where PartNumber = ' + LTrim(RTrim(Str(@CustomerPartNo))) + ' 
		'+  @StrAcntWhere +'
		) a 
		ON Cast(Substring(D.CreditCode , ' + Str(@CustomerPartStart) + ', ' + Str(@CustomerPartLayerLen) + ') AS VarChar(20)) = a.AcntC 
		or Cast(Substring(D.DebitCode , ' + Str(@CustomerPartStart) + ', ' + Str(@CustomerPartLayerLen) + ') AS VarChar(20)) = a.AcntC '
			

	--=========================

	declare @StrLast nvarchar(1024);
	
	if (@AccountOwnerType = 1)
		set @StrLast = 'INNER JOIN #tbl_Rec_Last LAST on LAST.VolumeFiscalYear = D.VolumeFiscalYear AND LAST.VolumeRowNo = D.VolumeRowNo AND LAST.EventNo = D.EventNo'
	else
		set @StrLast = 'LEFT  JOIN #tbl_Rec_Last LAST on LAST.VolumeFiscalYear = D.VolumeFiscalYear AND LAST.VolumeRowNo = D.VolumeRowNo'
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
	
		if @ProcessID =2 
		 begin
			Insert into  #tblOurBanks (CreditCode) SELECT  Distinct CreditCode	FROM       trs.tblPayDtl
			exec pub.SpFilterByPermission2 '#tblOurBanks', 'CreditCode', 'trs.tblOurBanks', @UserID; 
			Insert into  #tblAcntCode (AcntCode) SELECT  Distinct CreditCode	FROM       trs.tblPayDtl
			exec pub.SpFilterByPermission2 '#tblAcntCode', 'AcntCode', 'acc.tblAcnt', @UserID; 
			SET @StrWhere =  @StrWhere + '  and  ( D.CreditCode in (SELECT   CreditCode	FROM  #tblOurBanks    ) 
												or   D.CreditCode in (SELECT   AcntCode	FROM  #tblAcntCode    ) )'
		end 
	 if @ProcessID =1 
		begin 
			Insert into  #tblOurBanks (CreditCode) SELECT  Distinct DebitCode	FROM       trs.tblPayDtl
			exec pub.SpFilterByPermission2 '#tblOurBanks', 'CreditCode', 'trs.tblOurBanks', @UserID; 
			Insert into  #tblAcntCode (AcntCode) SELECT  Distinct DebitCode	FROM       trs.tblPayDtl
			exec pub.SpFilterByPermission2 '#tblAcntCode', 'AcntCode', 'acc.tblAcnt', @UserID; 
			SET @StrWhere =  @StrWhere + '  and (  D.DebitCode in (SELECT   CreditCode	FROM  #tblOurBanks     ) 
												or   D.DebitCode in (SELECT   AcntCode	FROM  #tblAcntCode    ) )'
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

------------------------------------------------------------------------------------------------------
	Set @StrSelect = '
	SELECT	D.*, BT.BankTypeName, LD.LocationName AS BankCity, 
			pub.GetCodeName(D.DebitCode, ' + @LangID + ') DebitName, 
			pub.GetBankName(D.CreditCode, ' + @LangID + ') CreditName,
			(
				SELECT Top 1 CreditCode
				FROM	trs.tblPayDtl
				WHERE	ProcessID IN (1,10) AND
						PayTypeID IN (6,26) AND 
						VolumeFiscalYear = D.VolumeFiscalYear AND 
						VolumeRowNo = D.VolumeRowNo
				ORDER By EventNo ASC
			) AS ChequeOwnerCode, PH.VchNo, LAST.ProcessID ChequeStateID,
			[pub].[funFarsiDateDiff](''Day'', ' + @StrBaseDate + ', D.ChequeDate) AS DateDuration
	FROM	trs.tblPayDtl AS D
			' + @StrLast + '
			INNER JOIN trs.tblPayHdr AS PH ON PH.ProcessID = D.ProcessID AND PH.ProcessNo = D.ProcessNo AND PH.FiscalYear = D.FiscalYear AND PH.SerialNo = D.SerialNo
			LEFT JOIN pub.tblLocationsDtl AS LD ON LD.LocationID = D.LocationID AND LD.LanguageID = ' + @LangID + '
			LEFT JOIN trs.tblBankTypesDtl AS BT ON	BT.BankTypeID = D.BankTypeID AND BT.LanguageID = ' + @LangID + '
			'+@StrAcntWhere+'
	WHERE	' + @StrWhere

	/* ---------------------------------------------------------------------------- */
	SET @StrSelect = '
	SELECT T.*, pub.GetCodeName(T.ChequeOwnerCode, ' + @LangID + ') AS ChequeOwnerName
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
