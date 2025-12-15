USE TS_ShirinVatanKarkhaneh_1_1404
GO
SET ANSI_NULLS, QUOTED_IDENTIFIER ON
GO
-- =========== TS-QC:UPDATED ====================
-- Author		 : Ahmadnejad
-- Create date   : 1386/03/15
-- Viewed By	 : 
-- Last Modified : 1392/01/11
-- Last Modifier : TakroSystem\ZiA
-- Description	 : <Receivable Documents Paid To Banks Report>
-- ----------------------------------------------
-- گزارش اسناد دریافتنی واگذار شده به بانکها
-- ==============================================
create PROCEDURE [trs].[SpTrs_ReceivableDocs_Warn_Bank]
	@ProcessID		Int = 21, -- 20 = All Cheques / 21 = Not Receipt / 22 = Receipt / 23 = Ret2Cash / 24 = Ret2Owner / 30 = All Ret
	@ProcessNo		Int = 0,
	@UsanceDateTo	Char(10) = Null, -- تاریخ سررسید تا
	@SortFields		NVarChar(100) = Null, -- لیست فیلدها برای مرتب سازی
	@RepOptions		NVarChar(100) = '', -- آرایه بیتی
	@RepInfo		VarChar(100) = '1@1@1'
WITH ENCRYPTION
As
DECLARE @StrSelect	NVarChar(max);
DECLARE @StrWhere	NVarChar(max);

DECLARE @StrPID		NVarChar(20);

DECLARE @BaseDate		NVarChar(10);
DECLARE @StrBaseDate	nVarchar(20);

DECLARE	@TrsCalcAvgByDocDate bit;

DECLARE @LangID			Char(1);
DECLARE @SessionNo		VarChar(10);
DECLARE @ReportID		VarChar(10);
declare @UserIsAdmin   bit  
declare @CurrentUserID as varchar(10) = ''
BEGIN   

	SET NOCOUNT ON;
	
	-- Init Variables -----------------------------------------------
	If (@RepInfo	Is Null)	SET @RepInfo    = '1@1@1'
	If (@ProcessNo  Is Null)	SET @ProcessNo  = 0
	If (@SortFields Is Null)	SET @SortFields = 'FiscalYear, SerialNo'

	SET	@LangID		= pub.funSplitString(@RepInfo, '@', 1);
	SET @SessionNo	= pub.funSplitString(@RepInfo, '@', 2);
	SET @ReportID	= pub.funSplitString(@RepInfo, '@', 3);
	set @CurrentUserID = pub.funSplitString(@RepInfo, '@', 4);
	set @UserIsAdmin = pub.funSplitString(@RepInfo, '@', 5);

	Select @BaseDate = LEFT([pub].[funFarsiDate](GetDate()), 10)
	
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
					and (@ProcessNo=0 or (@ProcessNo<>0 and I.ProcessNo = @ProcessNo))
					and I.VolumeFiscalYear = V.VolumeFiscalYear 
					and I.VolumeRowNo = V.VolumeRowNo 
					and I.EventNo = V.EventNo
				) ProcessID
	into #tbl_Rec_Last
	from
	(
		SELECT VolumeFiscalYear, VolumeRowNo, Max(EventNo) AS EventNo
		FROM   trs.tblPayDtl D
		WHERE  D.PayTypeID in (6, 26) and (@ProcessNo=0 or (@ProcessNo<>0 and D.ProcessNo = @ProcessNo))
		GROUP  BY VolumeFiscalYear, VolumeRowNo
	) V	
	
	If (@ProcessID = 21)
		SET @StrPID = '20,21'
	Else IF (@ProcessID = 17)
		SET @StrPID = '17,23'
	Else IF (@ProcessID = 18)
		SET @StrPID = '18,24'
	Else IF (@ProcessID = 30)
		SET @StrPID = '17,18,23,24'
	ELSE
		SET @StrPID = LTrim(Str(@ProcessID))

	SET @StrWhere = ' D.PayTypeID in (6,26) AND D.ProcessID IN (20,21)'
	
	if (@ProcessNo <> 0)
		set @StrWhere = @StrWhere + ' and D.ProcessNo = ' + LTrim(Str(@ProcessNo))
	
	If (@ProcessID <> 20)
	SET @StrWhere = @StrWhere + ' 
		AND (LAST.ProcessID IN (' + @StrPID + '))'

	IF	(@UsanceDateTo Is Not Null) 
	SET @StrWhere = @StrWhere + ' 
		AND (D.ChequeDate <= ''' + @UsanceDateTo + ''')'

------Check user Acess In Acc Codes----------------------------------------------------------
	
	
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
			Insert into  #tblOurBanks (CreditCode) SELECT  Distinct CreditCode	FROM       trs.tblPayDtl
			exec pub.SpFilterByPermission2 '#tblOurBanks', 'CreditCode', 'trs.tblOurBanks', @CurrentUserID; 
			Insert into  #tblAcntCode (AcntCode) SELECT  Distinct CreditCode	FROM       trs.tblPayDtl
			exec pub.SpFilterByPermission2 '#tblAcntCode', 'AcntCode', 'acc.tblAcnt', @CurrentUserID; 
			SET @StrWhere =  @StrWhere + '  ANd   ( D.CreditCode in (SELECT   CreditCode	FROM  #tblOurBanks    ) 
												or   D.CreditCode in (SELECT   AcntCode	FROM  #tblAcntCode    ) )'
	END 

	-----------------------------------------------------------------


	SET @StrSelect = '
	SELECT	D.*, LAST.ProcessID ChequeState, LD.LocationName, BT.BankTypeName, 
			pub.GetBankName(D.DebitCode, ' + @LangID + ') DebitName, H.VchNo,
			pub.GetBankName(D.CreditCode, ' + @LangID + ') CreditName, 
			(
				SELECT Top 1 CreditCode
				FROM	trs.tblPayDtl
				WHERE	PayTypeID IN (6,26) 
						AND ProcessID IN (1,10) 
						AND ProcessNo = D.ProcessNo 
						AND VolumeFiscalYear = D.VolumeFiscalYear 
						AND VolumeRowNo = D.VolumeRowNo 
				ORDER By EventNo ASC
			) AS ChequeOwnerCode
	FROM	trs.tblPayDtl AS D
				LEFT  JOIN #tbl_Rec_Last LAST on LAST.VolumeFiscalYear = D.VolumeFiscalYear AND LAST.VolumeRowNo = D.VolumeRowNo and LAST.EventNo=D.EventNo
				INNER JOIN trs.tblPayHdr H ON H.ProcessID = D.ProcessID AND H.ProcessNo = D.ProcessNo AND H.FiscalYear = D.FiscalYear AND H.SerialNo = D.SerialNo
				LEFT  JOIN trs.tblBankTypesDtl AS BT ON BT.BankTypeID = D.BankTypeID AND BT.LanguageID = 1
				LEFT  JOIN pub.tblLocationsDtl AS LD ON LD.LocationID = D.LocationID AND LD.LanguageID = 1
	WHERE	' + @StrWhere

	IF (@SortFields Is Not Null)
	SET @StrSelect = @StrSelect + ' 
	ORDER BY ' + @SortFields

	PRINT @StrSelect;
	EXEC sp_executesql @StrSelect;
End
GO
