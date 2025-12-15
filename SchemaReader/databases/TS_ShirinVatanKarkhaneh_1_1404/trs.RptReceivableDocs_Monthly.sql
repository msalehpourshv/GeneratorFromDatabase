USE TS_ShirinVatanKarkhaneh_1_1404
GO
SET ANSI_NULLS, QUOTED_IDENTIFIER ON
GO
-- =========== TS-QC:UPDATED ====================
-- Author		 : TakroSystem\Hamid	
-- Create date   : 1393/06/15
-- Viewed By	 : 
-- Last Modified : 
-- Last Modifier : 
-- Description	 : <Receivable Documents Report>
-- ----------------------------------------------
-- گزارش اسناد دریافتنی - کلیه چکها
-- ==============================================
Create PROCEDURE [trs].[RptReceivableDocs_Monthly]
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
	@DocDateFr			VarChar(10) = Null,
	@DocDateTo			VarChar(10) = Null,
	@UsanceDateFr		VarChar(10) = Null, -- تاریخ سررسید از
	@UsanceDateTo		VarChar(10) = Null, -- تاریخ سررسید تا
	@VolumeYearFr		Int = Null,			-- شماره ردیف دفتر از
	@VolumeRowFr		Int = Null,			-- شماره ردیف دفتر از
	@VolumeYearTo		Int = Null,			-- شماره ردیف دفتر تا
	@VolumeRowTo		Int = Null,			-- شماره ردیف دفتر تا
	@ChequeNoFr			VarChar(20) = Null, -- شماره چک از
	@ChequeNoTo			VarChar(20) = Null, -- شماره چک تا
	@AmountFr			VarChar(20) = Null, -- مبلغ از // dont use bigint
	@AmountTo			VarChar(20) = Null, -- مبلغ تا // dont use bigint
	@VchNoFr			int = Null, -- شماره عطف
	@VchNoTo			int = Null,
	@CityName			NVarChar(50) = Null,
	@BankName			NVarChar(50) = Null,
	@BranchCode			NVarChar(20) = Null,
	@BranchName			NVarChar(20) = '0', -- Not Used -- تجاری یا غیر تجاری
	@AccountNo			NVarChar(20) = Null, -- شماره حساب بانکی
	@AccountOwnerName	NVarChar(50) = Null,
	@AccountOwnerType	Bit = Null,  -- نوع صاحب حساب
	@SortFields			NVarChar(100) = Null, -- لیست فیلدها برای مرتب سازی
	@RepInfo			NVarChar(100) = '1@1@1'
WITH ENCRYPTION
As
DECLARE @StrWhere		NVarChar(4000);
DECLARE @StrSelect		NVarChar(4000);

DECLARE @StrPayTypeID	Varchar(10)
DECLARE @BaseDate		NVarChar(10)
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
DECLARE @CurrentFiscalYear		smallint;

BEGIN   

	SET NOCOUNT ON;

	-- Init Variables -----------------------------------------------
	If (@RepInfo	Is Null)	SET @RepInfo    = '1@1@1'
	If (@ProcessNo  Is Null)	SET @ProcessNo  = 1
	If (@SortFields Is Null)	SET @SortFields = 'FiscalYear, SerialNo'

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

	SET	@LangID		= pub.funSplitString(@RepInfo, '@', 1);
	SET @SessionNo	= pub.funSplitString(@RepInfo, '@', 2);
	SET @ReportID	= pub.funSplitString(@RepInfo, '@', 3);
	
	SET @CampaignID		   = pub.funSplitString(@RepInfo, '@', 6);
	SET @VisitPathID1	   = pub.funSplitString(@RepInfo, '@', 7);
	SET @VisitPathID2	   = pub.funSplitString(@RepInfo, '@', 8);
	SET @VisitPathID3	   = pub.funSplitString(@RepInfo, '@', 9);
	SET @VisitPathID4	   = pub.funSplitString(@RepInfo, '@', 10);
	SET @SalesRoomClass	   = pub.funSplitString(@RepInfo, '@', 11);
	SET @CurrentFiscalYear = pub.funSplitString(@RepInfo, '@', 12);


	set @BranchName = '0'
	
	if @BranchName='1'
		SET @StrPayTypeID = '6'  -- اسناد دریافتنی تجاری
	else if @BranchName='2'
		SET @StrPayTypeID = '26' -- اسناد دریافتنی غیرتجاری  
	
	if @BranchName='0'
		SET @StrPayTypeID = '6,26'  -- اسناد دریافتنی 
		
	SELECT @BaseDate = LEFT([pub].[funFarsiDate](GetDate()), 10)
	
	select @TrsCalcAvgByDocDate = isnull(SettingValue, 0)
	from pub.tblSettings
	where SettingKey = 'TrsCalcAvgByDocDate'

	if (@TrsCalcAvgByDocDate = 1)
		set @StrBaseDate = 'D.DocDate'
	else
		set @StrBaseDate = '''' + @BaseDate + ''''

	-- WHERE Section -------------------------------------------------------------------------------------------

	SELECT @StrWhere = '(D.ProcessNo = ' + LTRim(Str(@ProcessNo)) + ') 
	AND (D.PayTypeID IN (' + @StrPayTypeID + ')) 
	AND (D.VolumeRowNo > 0) 
	AND (D.EventNo = 1) '

	IF @CurrentFiscalYear <> 0 and @CurrentFiscalYear is not null
		SET @StrWhere = @StrWhere + ' AND D.FiscalYear = ' + Str(@CurrentFiscalYear)

	IF (@AccountOwnerType IS Not Null)
		SET @StrWhere = @StrWhere + ' AND D.AccountOwnerType = ' + Str(@AccountOwnerType)
	IF (@AccountOwnerName IS Not Null)
		SET @StrWhere = @StrWhere + ' AND D.AccOwnerName like N''%' + @AccountOwnerName + '%''' 

	IF (@FiscalYearFr Is Not Null)
		SET @StrWhere = @StrWhere + ' AND (D.FiscalYear > ' + LTrim(Str(@FiscalYearFr)) + ' OR (D.FiscalYear = ' + LTrim(Str(@FiscalYearFr)) + ' AND D.SerialNo >= ' + LTrim(Str(@SerialNoFr)) + ')) '
	IF (@FiscalYearTo Is Not Null)
		SET @StrWhere = @StrWhere + ' AND (D.FiscalYear < ' + LTrim(Str(@FiscalYearTo)) + ' OR (D.FiscalYear = ' + LTrim(Str(@FiscalYearTo)) + ' AND D.SerialNo <= ' + LTrim(Str(@SerialNoTo)) + ')) '

	IF (@VolumeYearFr Is Not Null)
		SET @StrWhere = @StrWhere + ' AND (D.VolumeFiscalYear > ' + LTrim(Str(@VolumeYearFr)) + ' OR (D.VolumeFiscalYear = ' + LTrim(Str(@VolumeYearFr)) + ' AND D.VolumeRowNo >= ' + LTrim(Str(@VolumeRowFr)) + ')) '
	IF (@VolumeYearTo Is Not Null)
		SET @StrWhere = @StrWhere + ' AND (D.VolumeFiscalYear < ' + LTrim(Str(@VolumeYearTo)) + ' OR (D.VolumeFiscalYear = ' + LTrim(Str(@VolumeYearTo)) + ' AND D.VolumeRowNo <= ' + LTrim(Str(@VolumeRowTo)) + ')) '

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

	IF (@DocDateFr Is Not Null)
		SET @StrWhere = @StrWhere + ' AND (D.DocDate >= ''' + @DocDateFr + ''')'
	IF (@DocDateTo Is Not Null)
		SET @StrWhere = @StrWhere + ' AND (D.DocDate <= ''' + @DocDateTo + ''')'

	IF (@UsanceDateFr Is Not Null)
		SET @StrWhere = @StrWhere + ' AND (D.ChequeDate >= ''' + @UsanceDateFr + ''')'
	IF (@UsanceDateTo Is Not Null)
		SET @StrWhere = @StrWhere + ' AND (D.ChequeDate <= ''' + @UsanceDateTo + ''')'

	IF (@ChequeNoFr Is Not Null)
		SET @StrWhere = @StrWhere + ' AND (D.ChequeNo >= ''' + @ChequeNoFr + ''')'
	IF (@ChequeNoTo Is Not Null)
		SET @StrWhere = @StrWhere + ' AND (D.ChequeNo <= ''' + @ChequeNoTo + ''')'

	IF (@AmountFr Is Not Null)
		SET @StrWhere = @StrWhere + ' AND D.Amount >= ' + @AmountFr
	IF (@AmountTo Is Not Null)
		SET @StrWhere = @StrWhere + ' AND D.Amount <= ' + @AmountTo

	If	(@VchNoFr Is Not Null)
		SET @StrWhere = @StrWhere + ' AND (H.VchNo >= ' + LTrim(Str(@VchNoFr)) + ')'
	If	(@VchNoTo Is Not Null)
		SET @StrWhere = @StrWhere + ' AND (H.VchNo <= ' + LTrim(Str(@VchNoTo)) + ')'

	IF (@CityName Is Not Null)
		SET @StrWhere = @StrWhere + ' AND RTrim(LTrim(LD.LocationName)) Like N''%' + LTrim(@CityName) + '%'''
	IF (@BankName Is Not Null)
		SET @StrWhere = @StrWhere + ' AND RTrim(LTrim(BT.BankTypeName)) Like N''%' + LTrim(@BankName) + '%'''
	IF (@BranchCode Is Not Null)
		SET @StrWhere = @StrWhere + ' AND RTrim(LTrim(D.BranchCode)) = ''' + LTrim(@BranchCode) + ''''
	IF (@AccountNo Is Not Null)
		SET @StrWhere = @StrWhere + ' AND RTrim(LTrim(D.AccountNo)) = ''' + LTrim(@AccountNo) + ''''
		
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
		ON Cast(Substring(D.CreditCode , ' + Str(@CustomerPartStart) + ', ' + Str(@CustomerPartLayerLen) + ') AS VarChar(20)) = a.AcntC '
			
	--=========================		
		 --------------------------------------------------------------------------------------------
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
	 
			Insert into  #tblOurBanks (CreditCode) SELECT  Distinct CreditCode	FROM       trs.tblPayDtl
			exec pub.SpFilterByPermission2 '#tblOurBanks', 'CreditCode', 'trs.tblOurBanks', @UserID; 
			Insert into  #tblAcntCode (AcntCode) SELECT  Distinct CreditCode	FROM       trs.tblPayDtl
			exec pub.SpFilterByPermission2 '#tblAcntCode', 'AcntCode', 'acc.tblAcnt', @UserID; 
			SET @StrWhere =  @StrWhere + '  and  ( D.CreditCode in (SELECT   CreditCode	FROM  #tblOurBanks    ) 
												or   D.CreditCode in (SELECT   AcntCode	FROM  #tblAcntCode    ) ) and  88=88'
	end 
	
Delete From  #tblAcntCode where AcntCode='' or AcntCode is null
Delete From  #tblOurBanks where CreditCode='' or CreditCode is null

end 
	-----------------------------------------------------------------
	SET @StrSelect = '
	Select T.CreditCode, T.CreditNameA, 
		   SUM(Case When SUBSTRING(T.ChequeDate,6,2) = ''01'' Then T.Amount Else 0 End) As Month01,
		   SUM(Case When SUBSTRING(T.ChequeDate,6,2) = ''02'' Then T.Amount Else 0 End) As Month02,
		   SUM(Case When SUBSTRING(T.ChequeDate,6,2) = ''03'' Then T.Amount Else 0 End) As Month03,
		   SUM(Case When SUBSTRING(T.ChequeDate,6,2) = ''04'' Then T.Amount Else 0 End) As Month04,
		   SUM(Case When SUBSTRING(T.ChequeDate,6,2) = ''05'' Then T.Amount Else 0 End) As Month05,
		   SUM(Case When SUBSTRING(T.ChequeDate,6,2) = ''06'' Then T.Amount Else 0 End) As Month06,
		   SUM(Case When SUBSTRING(T.ChequeDate,6,2) = ''07'' Then T.Amount Else 0 End) As Month07,
		   SUM(Case When SUBSTRING(T.ChequeDate,6,2) = ''08'' Then T.Amount Else 0 End) As Month08,
		   SUM(Case When SUBSTRING(T.ChequeDate,6,2) = ''09'' Then T.Amount Else 0 End) As Month09,
		   SUM(Case When SUBSTRING(T.ChequeDate,6,2) = ''10'' Then T.Amount Else 0 End) As Month10,
		   SUM(Case When SUBSTRING(T.ChequeDate,6,2) = ''11'' Then T.Amount Else 0 End) As Month11,
		   SUM(Case When SUBSTRING(T.ChequeDate,6,2) = ''12'' Then T.Amount Else 0 End) As Month12,
		   isnull((
				Select Sum(V.Debit - V.Credit)
				From acc.tblVoucherDtl V
				Where (V.VchKind <> 0) 
					And V.AcntCode = T.CreditCode
		   ),0) DebitRemain, T.NationalIDNumber
	From 
	(	
		SELECT	D.*, pub.GetCodeName(D.CreditCode,' + @LangID + ') AS CreditNameA
		FROM	trs.tblPayDtl AS D
					INNER JOIN trs.tblPayHdr H ON H.ProcessID = D.ProcessID AND H.ProcessNo = D.ProcessNo AND H.FiscalYear = D.FiscalYear AND H.SerialNo = D.SerialNo
					LEFT  JOIN pub.tblLocationsDtl AS LD ON	LD.LocationID = D.LocationID AND LD.LanguageID = ' + @LangID + '
					LEFT  JOIN trs.tblBankTypesDtl AS BT ON BT.BankTypeID = D.BankTypeID AND BT.LanguageID = ' + @LangID + '
					'+@StrAcntWhere+' 
		WHERE	' + @StrWhere + '
	 ) T
	 Group By T.CreditCode, T.CreditNameA ,T.NationalIDNumber'
		
 

 
------------------------------------------------------------------------

	Print @StrSelect;
	Exec sp_executesql @StrSelect;
End
GO
