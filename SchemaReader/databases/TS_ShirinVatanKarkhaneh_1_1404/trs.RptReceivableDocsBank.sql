USE TS_ShirinVatanKarkhaneh_1_1404
GO
SET ANSI_NULLS, QUOTED_IDENTIFIER ON
GO
-- =========== TS-QC:UPDATED ====================
-- Author		 : Ahmadnejad
-- Create date   : 1386/03/15
-- Viewed By	 : 
-- Last Modified : 1392/01/21
-- Last Modifier : TakroSystem\ZiA
-- Description	 : <Receivable Documents Paid To Banks Report>
-- ----------------------------------------------
-- گزارش اسناد دریافتنی واگذار شده به بانکها
-- ==============================================
Create PROCEDURE [trs].[RptReceivableDocsBank]
	@ProcessID			Int = 21, -- 20 = All Cheques / 21 = Not Receipt / 22 = Receipt / 23 = Ret2Cash / 24 = Ret2Owner / 30 = All Ret
	@ProcessNo			Int = 1,
	@FiscalYearFr		Int = Null,
	@SerialNoFr			Int = Null,
	@FiscalYearTo		Int = Null,
	@SerialNoTo			Int = Null,
	@DebitCode1			Int = 0, -- بدهکار
	@DebitCode2			Int = 0,-- بستانکار
	@DebitCode3			Int = 0,
	@DebitCode4			Int = 0,
	@CreditCode1		Int = 0, -- صاحب چک
	@CreditCode2		Int = 0, -- صاحب چک
	@CreditCode3		Int = 0, -- صاحب چک
	@CreditCode4		Int = 0, -- صاحب چک
	@DocDateFr			Char(10) = Null,
	@DocDateTo			Char(10) = Null,
	@UsanceDateFr		Char(10) = Null, -- تاریخ سررسید از
	@UsanceDateTo		Char(10) = Null, -- تاریخ سررسید تا
	@VolumeYearFr		Int = Null,		 -- شماره ردیف دفتر از
	@VolumeRowFr		Int = Null,		 -- شماره ردیف دفتر از
	@VolumeYearTo		Int = Null,		 -- شماره ردیف دفتر تا
	@VolumeRowTo		Int = Null,		 -- شماره ردیف دفتر تا
	@ChequeNoFr			VarChar(20) = Null, -- شماره چک از
	@ChequeNoTo			VarChar(20) = Null, -- شماره چک تا
	@AmountFr			VarChar(20) = Null, -- مبلغ از
	@AmountTo			VarChar(20) = Null, -- مبلغ تا
	@CityName			NVarChar(50) = Null,
	@BankName			NVarChar(50) = Null,
	@BranchCode			NVarChar(20) = Null,
	@BranchName			NVarChar(50) = Null,
	@AccountNo			NVarChar(20) = Null,  -- شماره حساب بانکی
	@AccountOwnerType	Bit = Null,  -- last event
	@SortFields			NVarChar(100) = Null, -- لیست فیلدها برای مرتب سازی
	@RepInfo			NVarChar(100) = '1@1@1'
WITH ENCRYPTION
As
DECLARE @StrSelect	NVarChar(max);
DECLARE @StrWhere	NVarChar(max);
DECLARE @StrWhereOwner	NVarChar(max);

DECLARE @StrPID		NVarChar(20);

DECLARE @BaseDate		NVarChar(10);
DECLARE @StrBaseDate	nVarchar(20);

DECLARE	@TrsCalcAvgByDocDate bit;

DECLARE @LangID			Char(1);
DECLARE @SessionNo		VarChar(10);
DECLARE @ReportID		VarChar(10);
DECLARE @StrAcntWhere	NVarChar(4000);
DECLARE @CampaignID		   INT;
DECLARE @VisitPathID1	   INT;
DECLARE @VisitPathID2	   INT;
DECLARE @VisitPathID3	   INT;
DECLARE @VisitPathID4	   INT;
DECLARE @SalesRoomClass	   INT;
DECLARE @ChequeIsDigital   INT;
DECLARE @BaseProcessID	   INT;

BEGIN   

	SET NOCOUNT ON;
	
	-- Init Variables -----------------------------------------------
	IF (@RepInfo	Is Null)	SET @RepInfo    = '1@1@1'
	IF (@ProcessNo  Is Null)	SET @ProcessNo  = 1
	IF (@SortFields Is Null)	SET @SortFields = 'FiscalYear, SerialNo'

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

	SET @CampaignID		  = pub.funSplitString(@RepInfo, '@', 6);
	SET @VisitPathID1	  = pub.funSplitString(@RepInfo, '@', 7);
	SET @VisitPathID2	  = pub.funSplitString(@RepInfo, '@', 8);
	SET @VisitPathID3	  = pub.funSplitString(@RepInfo, '@', 9);
	SET @VisitPathID4	  = pub.funSplitString(@RepInfo, '@', 10);
	SET @SalesRoomClass	  = pub.funSplitString(@RepInfo, '@', 11);
	SET @ChequeIsDigital  = pub.funSplitString(@RepInfo, '@', 12);
	SET @BaseProcessID	  = pub.funSplitString(@RepInfo, '@', 13);

	SELECT @BaseDate = LEFT([pub].[funFarsiDate](GetDate()), 10)
	
	SELECT @TrsCalcAvgByDocDate = isnull(SettingValue, 0)
	FROM pub.tblSettings
	WHERE SettingKey = 'TrsCalcAvgByDocDate'

	IF (@TrsCalcAvgByDocDate = 1)
		SET @StrBaseDate = 'D.DocDate'
	ELSE
		SET @StrBaseDate = '''' + @BaseDate + ''''

	-- Where Section ---------------------------------------------
	SELECT V.*,(SELECT TOP 1 ProcessID
				FROM trs.tblPayDtl I 
				WHERE I.PayTypeID in (6, 26) 
				  AND I.ProcessNo = @ProcessNo
				  AND I.VolumeFiscalYear = V.VolumeFiscalYear 
				  AND I.VolumeRowNo = V.VolumeRowNo 
				  AND I.EventNo = V.EventNo) ProcessID
	INTO #tbl_Rec_Last
	FROM
	(
		SELECT VolumeFiscalYear, 
			   VolumeRowNo, 
			   Max(EventNo) AS EventNo
		FROM trs.tblPayDtl D
		WHERE D.PayTypeID in (6, 26) 
		  AND (D.ProcessNo = @ProcessNo)
		GROUP BY VolumeFiscalYear, VolumeRowNo
	) V	
	
	IF (@ProcessID = 20) OR (@ProcessID = 21)
		SET @StrPID = '20,21'
	Else IF (@ProcessID = 17)
		SET @StrPID = '17,23'
	Else IF (@ProcessID = 18)
		SET @StrPID = '18,24'
	Else IF (@ProcessID = 30)
		SET @StrPID = '17,18,23,24'
	ELSE
		SET @StrPID = LTrim(Str(@ProcessID))

	--IF 
	SET @StrWhere = ' D.ProcessID IN (' + @StrPID + ') AND D.PayTypeID in (6, 26) AND D.ProcessNo = ' + LTrim(Str(@ProcessNo))

	SET @StrWhereOwner= '1 = 1'
	DECLARE @strExept as NVarChar(1000) = ''
	
	IF @ProcessID = 21
	BEGIN
		SET @strExept = '
						 EXCEPT
						 SELECT ChequeNo FROM trs.tblPayDtl D WHERE D.ProcessID in (12,22) 
																AND D.ProcessNo = ' +  + LTrim(RTrim(Str(@ProcessNo))) +'
																AND D.VolumeFiscalYear = T.VolumeFiscalYear
																AND D.VolumeRowNo = T.VolumeRowNo'
	END
	ELSE
	BEGIN
		SET @strExept = ''
	END

	DECLARE @strState as NVarChar(1000) = ' 
	AND ChequeNo IN (SELECT ChequeNo 
					 From trs.tblPayDtl D 
					 WHERE D.ProcessID = ' + LTrim(RTrim(Str(@BaseProcessID))) + '
					   AND D.ProcessNo = ' + LTrim(RTrim(Str(@ProcessNo))) + '
					   AND D.VolumeFiscalYear = T.VolumeFiscalYear
					   AND D.VolumeRowNo = T.VolumeRowNo'
	DECLARE @bolHasState as bit = 'False'

	IF @SerialNoFr <> '' or @SerialNoTo <> ''
	BEGIN
		Set @bolHasState = 'True'

		IF (@FiscalYearFr Is Not Null)
		SET @strState = @strState + ' 
				AND (D.FiscalYear > ' + LTrim(Str(@FiscalYearFr)) + ' OR (D.FiscalYear = ' + LTrim(Str(@FiscalYearFr)) + ' AND D.SerialNo >= ' + LTrim(Str(@SerialNoFr)) + ')) '

		IF (@FiscalYearTo Is Not Null)
		SET @strState = @strState + ' 
				AND (D.FiscalYear < ' + LTrim(Str(@FiscalYearTo)) + ' OR (D.FiscalYear = ' + LTrim(Str(@FiscalYearTo)) + ' AND D.SerialNo <= ' + LTrim(Str(@SerialNoTo)) + ')) '
	END

	IF @UsanceDateFr <> '' OR @UsanceDateTo <> ''
	BEGIN
		Set @bolHasState = 'True'

		IF (@UsanceDateFr Is Not Null) 
		SET @StrWhere = @StrWhere + ' AND (D.ChequeDate >= ''' + @UsanceDateFr + ''')'

		IF (@UsanceDateTo Is Not Null) 
		SET @StrWhere = @StrWhere + ' AND (D.ChequeDate <= ''' + @UsanceDateTo + ''')'
	END

	SET @strState = @strState  + @strExept + ')'

	--If (@ProcessID <> 20)
	--SET @StrWhere = @StrWhere + ' 
	--		 AND LAST.ProcessID IN (' + @StrPID + ')'

	IF @ProcessID = @BaseProcessID and @BaseProcessID <> 0
	BEGIN
		IF (@FiscalYearFr Is Not Null)
		SET @StrWhere = @StrWhere + ' 
				 AND (D.FiscalYear > ' + LTrim(Str(@FiscalYearFr)) + ' OR (D.FiscalYear = ' + LTrim(Str(@FiscalYearFr)) + ' AND D.SerialNo >= ' + LTrim(Str(@SerialNoFr)) + ')) '

		IF (@FiscalYearTo Is Not Null)
		SET @StrWhere = @StrWhere + ' 
				 AND (D.FiscalYear < ' + LTrim(Str(@FiscalYearTo)) + ' OR (D.FiscalYear = ' + LTrim(Str(@FiscalYearTo)) + ' AND D.SerialNo <= ' + LTrim(Str(@SerialNoTo)) + ')) '
	END

	IF (@VolumeYearFr Is Not Null)
	SET @StrWhere = @StrWhere + ' 
			 AND (D.VolumeFiscalYear > ' + LTrim(Str(@VolumeYearFr)) + ' OR (D.VolumeFiscalYear = ' + LTrim(Str(@VolumeYearFr)) + ' AND D.VolumeRowNo >= ' + LTrim(Str(@VolumeRowFr)) + ')) '

	IF (@VolumeYearTo Is Not Null)
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


	IF	(@DebitCode1 > 0) SET @StrWhere = @StrWhere + ' AND ' + pub.funGetFilterString(@SessionNo, @ReportID, @DebitCode1, 'D.DebitCode') 
	IF	(@DebitCode2 > 0) SET @StrWhere = @StrWhere + ' AND ' + pub.funGetFilterString(@SessionNo, @ReportID, @DebitCode2, 'D.CreditCode') 
	--IF	(@DebitCode3 > 0) SET @StrWhere = @StrWhere + ' AND ' + pub.funGetFilterString(@SessionNo, @ReportID, @DebitCode3, 'D.DebitCode') 
	--IF	(@DebitCode4 > 0) SET @StrWhere = @StrWhere + ' AND ' + pub.funGetFilterString(@SessionNo, @ReportID, @DebitCode4, 'D.DebitCode') 

	IF (@CreditCode1 > 0) SET @StrWhereOwner = @StrWhereOwner + ' AND ' + pub.funGetFilterString(@SessionNo, @ReportID, @CreditCode1, 'T.ChequeOwnerCode') 
	IF (@CreditCode2 > 0) SET @StrWhereOwner = @StrWhereOwner + ' AND ' + pub.funGetFilterString(@SessionNo, @ReportID, @CreditCode2, 'T.ChequeOwnerCode') 
	IF (@CreditCode3 > 0) SET @StrWhereOwner = @StrWhereOwner + ' AND ' + pub.funGetFilterString(@SessionNo, @ReportID, @CreditCode3, 'T.ChequeOwnerCode') 
	IF (@CreditCode4 > 0) SET @StrWhereOwner = @StrWhereOwner + ' AND ' + pub.funGetFilterString(@SessionNo, @ReportID, @CreditCode4, 'T.ChequeOwnerCode') 

	IF (@ChequeNoFr Is Not Null) SET @StrWhere = @StrWhere + ' AND (D.ChequeNo >= ''' + LTrim(@ChequeNoFr) + ''')'
	IF (@ChequeNoTo Is Not Null) SET @StrWhere = @StrWhere + ' AND (D.ChequeNo <= ''' + LTrim(@ChequeNoTo) + ''')'

	IF (@AmountFr Is Not Null) SET @StrWhere = @StrWhere + ' AND D.Amount >= ' + LTrim(@AmountFr)
	IF (@AmountTo Is Not Null) SET @StrWhere = @StrWhere + ' AND D.Amount <= ' + LTrim(@AmountTo)

	IF (@CityName Is Not Null)	 SET @StrWhere = @StrWhere + ' AND RTrim(LTrim(LD.LocationName)) Like N''%' + LTrim(@CityName) + '%'''
	IF (@BankName Is Not Null)	 SET @StrWhere = @StrWhere + ' AND RTrim(LTrim(BT.BankTypeName)) Like N''%' + LTrim(@BankName) + '%'''
	IF (@BranchCode Is Not Null) SET @StrWhere = @StrWhere + ' AND RTrim(LTrim(D.BranchCode)) = ''' + LTrim(@BranchCode) + ''''
	IF (@BranchName Is Not Null) SET @StrWhere = @StrWhere + ' AND RTrim(LTrim(D.BranchName)) Like N''%' + LTrim(@BranchName) + '%'''
	IF (@AccountNo Is Not Null)	 SET @StrWhere = @StrWhere + ' AND RTrim(LTrim(D.AccountNo)) = ''' + LTrim(@AccountNo) + ''''

--=========================

	DECLARE @CustomerPartNo			int;
	DECLARE @CustomerPartStart		int;
	DECLARE @CustomerPartLayerLen	int;

		
	SELECT @CustomerPartNo = [acc].[FunGetAcntInfoForRemain](1)
	SELECT @CustomerPartStart = [acc].[FunGetAcntInfoForRemain](2)
	SELECT @CustomerPartLayerLen = [acc].[FunGetAcntInfoForRemain](3)


	SET @StrAcntWhere=' '

	IF  @CampaignID > 0 
		SET @StrAcntWhere = @StrAcntWhere + ' AND ' + pub.funGetFilterString(@SessionNo, @ReportID, @CampaignID, 'CampaignID') 

	IF  @VisitPathID1 > 0 
		SET @StrAcntWhere = @StrAcntWhere + ' AND ' + pub.funGetFilterString(@SessionNo, @ReportID, @VisitPathID1, 'VisitPathID1') 
		
	IF  @VisitPathID2 > 0 
		SET @StrAcntWhere = @StrAcntWhere + ' AND ' + pub.funGetFilterString(@SessionNo, @ReportID, @VisitPathID2, 'VisitPathID2') 
		
	IF  @VisitPathID3 > 0 
		SET @StrAcntWhere = @StrAcntWhere + ' AND ' + pub.funGetFilterString(@SessionNo, @ReportID, @VisitPathID3, 'VisitPathID3') 
		
	IF  @VisitPathID4 > 0 
		SET @StrAcntWhere = @StrAcntWhere + ' AND ' + pub.funGetFilterString(@SessionNo, @ReportID, @VisitPathID4, 'VisitPathID4') 
		
	IF @SalesRoomClass > 0 
		SET @StrAcntWhere = @StrAcntWhere + ' AND ' + pub.funGetFilterString(@SessionNo, @ReportID, @SalesRoomClass, 'SalesRoomClass')

	IF @ChequeIsDigital = 1
		SET @StrWhere = @StrWhere + ' AND ChequeIsDigital = 1'
	IF @ChequeIsDigital = 0
		SET @StrWhere = @StrWhere + ' '

	IF  @StrAcntWhere <> ''
		SET @StrAcntWhere = '
		INNER JOIN (SELECT AcntCode AcntC FROM acc.tblAcnt WHERE PartNumber = ' + LTrim(RTrim(Str(@CustomerPartNo))) + ' 
		'+  @StrAcntWhere +'
		) a 
		ON Cast(Substring(D.CreditCode , ' + Str(@CustomerPartStart) + ', ' + Str(@CustomerPartLayerLen) + ') AS VarChar(20)) = a.AcntC 
		OR Cast(Substring(D.DebitCode , ' + Str(@CustomerPartStart) + ', ' + Str(@CustomerPartLayerLen) + ') AS VarChar(20)) = a.AcntC '
			
---------------------------------------------------------------------------------------------------
	Declare @DonotFilterAcc2Trs AS bit
	SET @DonotFilterAcc2Trs = 0

	SELECT @DonotFilterAcc2Trs = SettingValue
	FROM pub.tblSettings
	WHERE SettingKey = 'DonotFilterAcc2Trs'
		
IF @DonotFilterAcc2Trs=0 	
BEGIN

	DECLARE	@UserID		Int;
	DECLARE	@UserIsAdmin bit;

	SET @UserID			= pub.funSplitString(@RepInfo, '@', 4);
	SET @UserIsAdmin	= pub.funSplitString(@RepInfo, '@', 5);


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
	IF (@UserIsAdmin = 0)
	BEGIN
		INSERT INTO #tblOurBanks (CreditCode) 
		SELECT Distinct CreditCode	
		FROM trs.tblPayDtl
		
		EXEC pub.SpFilterByPermission2 '#tblOurBanks', 'CreditCode', 'trs.tblOurBanks', @UserID; 
			
		INSERT INTO #tblAcntCode (AcntCode) 
		SELECT Distinct CreditCode	
		FROM trs.tblPayDtl
		
		EXEC pub.SpFilterByPermission2 '#tblAcntCode', 'AcntCode', 'acc.tblAcnt', @UserID; 
		SET @StrWhere =  @StrWhere + ' AND (D.CreditCode in (SELECT CreditCode	
															 FROM #tblOurBanks) 
										   OR D.CreditCode in (SELECT AcntCode	
															   FROM #tblAcntCode))'
	end 
	
DELETE FROM #tblAcntCode WHERE AcntCode = '' OR AcntCode IS NULL
DELETE FROM #tblOurBanks WHERE CreditCode = '' OR CreditCode IS NULL

END
------------------------------------------------------------------------------------------------------

	--=========================
	
	DECLARE @StrLast nvarchar(1024);
	
	IF (@AccountOwnerType = 1)
		SET @StrLast = 'INNER JOIN #tbl_Rec_Last LAST ON LAST.VolumeFiscalYear = D.VolumeFiscalYear 
													 AND LAST.VolumeRowNo = D.VolumeRowNo 
													 AND LAST.EventNo = D.EventNo'
	ELSE
		SET @StrLast = 'LEFT JOIN #tbl_Rec_Last LAST ON LAST.VolumeFiscalYear = D.VolumeFiscalYear 
													AND LAST.VolumeRowNo = D.VolumeRowNo'
	
	SET @StrSelect = '
	SELECT D.*, 
		   LAST.ProcessID ChequeState, 
		   LD.LocationName, 
		   BT.BankTypeName, 
		   pub.GetBankName(D.DebitCode, ' + @LangID + ') DebitName, 
		   H.VchNo,
		   pub.GetBankName(D.CreditCode, ' + @LangID + ') CreditName, 
		   ( SELECT Top 1 CreditCode
			 FROM trs.tblPayDtl
			 WHERE PayTypeID IN (6,26) 
			   AND ProcessID IN (1,10) 
			   AND ProcessNo = ' + LTrim(Str(@ProcessNo)) + ' 
			   AND VolumeFiscalYear = D.VolumeFiscalYear 
			   AND VolumeRowNo = D.VolumeRowNo
			 ORDER By EventNo ASC) AS ChequeOwnerCode, 
		   CASE WHEN (D.ChequeDate = '''') THEN 0 ELSE [pub].funFarsiDateDiff(''Day'', ' + @StrBaseDate + ', D.ChequeDate) end AS DateDuration
	FROM trs.tblPayDtl AS D
	' + @StrLast + '
	INNER JOIN trs.tblPayHdr H ON H.ProcessID = D.ProcessID 
							  AND H.ProcessNo = D.ProcessNo 
							  AND H.FiscalYear = D.FiscalYear 
							  AND H.SerialNo = D.SerialNo
	LEFT JOIN trs.tblBankTypesDtl AS BT ON BT.BankTypeID = D.BankTypeID 
									   AND BT.LanguageID = ' + @LangID + '
	LEFT JOIN pub.tblLocationsDtl AS LD ON LD.LocationID = D.LocationID 
									   AND LD.LanguageID = ' + @LangID + '
	'+@StrAcntWhere+'
	WHERE ' + @StrWhere

	SET @StrSelect = '
	SELECT T.*, 
		   pub.GetCodeName(T.ChequeOwnerCode, ' + @LangID + ') AS ChequeOwnerName
	FROM ( ' + @StrSelect + ' ) AS T 
	WHERE ' + @StrWhereOwner +'
	  AND LTrim(RTrim(Str(VolumeFiscalYear)))+''@''+ LTrim(RTrim(str(VolumeRowNo))) in (SELECT DISTINCT LTrim(RTrim(Str(VolumeFiscalYear)))+''@''+ LTrim(RTrim(Str(VolumeRowNo))) 
																						FROM trs.tblPayDtl
																						WHERE ProcessID = 21 
																						  AND ProcessNo = '+str(@ProcessNo)+') '
	  + CASE WHEN @bolHasState =  'TRUE' and @BaseProcessID <> 0 THEN @strState ELSE '' END

	IF (@SortFields Is Not Null)
	SET @StrSelect = @StrSelect + ' 
	ORDER BY ' + @SortFields

	PRINT @StrSelect;
	EXEC sp_executesql @StrSelect;
END
GO
