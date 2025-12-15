USE TS_ShirinVatanKarkhaneh_1_1404
GO
SET ANSI_NULLS, QUOTED_IDENTIFIER ON
GO
-- =========== TS-QC:UPDATED ====================
-- Author		 : TakroSystem\Zia
-- Create date   : 1389/07/03
-- Viewed By	 : 
-- Last Modified : 1392/01/07
-- Last Modifier : TakroSystem\Zia
-- Description	 : آمار اسناد دریافتنی
-- ==============================================
Create PROCEDURE [trs].[RptTrs_ReceivableDocs_Stats_Grouped]
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
	@DocDateFr		Char(10) = Null,
	@DocDateTo		Char(10) = Null,
	@UsanceDateFr	Char(10) = Null,
	@UsanceDateTo	Char(10) = Null,
	@VolumeYearFr	Int = Null,
	@VolumeRowFr	Int = Null,
	@VolumeYearTo	Int = Null,
	@VolumeRowTo	Int = Null,
	@RepOptions		NVarChar(100) = '', -- آرایه بیتی
	@RepInfo		NVarChar(100) = '1@1@1'
WITH ENCRYPTION
As
DECLARE @StrWhere	NVarChar(2000);
DECLARE @StrSelect	NVarChar(2000);

DECLARE @LangID		Char(1);
DECLARE @SessionNo	VarChar(10);
DECLARE @ReportID	VarChar(10);

DECLARE @StrTmpl	AS NVarChar(4000);
DECLARE @StrDB		AS NVarChar(100);
DECLARE @StrPrevDB	AS NVarChar(100);
DECLARE @TempTable1	AS NVarChar(100);
DECLARE @TempTable2	AS NVarChar(100);
DECLARE @ThisYear	AS Char(4);
DECLARE @NextYear	AS Char(4);
DECLARE @StrAcntWhere	NVarChar(4000);
DECLARE @CampaignID				int;
DECLARE @VisitPathID1			int;
DECLARE @VisitPathID2			int;
DECLARE @VisitPathID3			int;
DECLARE @VisitPathID4			int;
DECLARE @SalesRoomClass			int;
DECLARE @ChequeIsDigital		int;
BEGIN   
	SET NOCOUNT ON;

	-- Init Variables -----------------------------------------------
	If (@RepInfo	  Is Null)	SET @RepInfo    = '1@1@1';
	IF (@FiscalYearFr Is Null)	SET @SerialNoFr	= Null;
	IF (@FiscalYearTo Is Null)	SET @SerialNoTo	= Null;

	IF (@SerialNoFr	Is Null)	SET @FiscalYearFr = Null;
	IF (@SerialNoTo	Is Null)	SET @FiscalYearTo = Null;

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
	Set @ChequeIsDigital  = pub.funSplitString(@RepInfo, '@', 13);


	-- WHERE -----------------------------------------------
	SET @StrWhere = '(D.PayTypeID IN (6,26)) 
		AND (D.ProcessNo = ' + LTRIM(STR(@ProcessNo)) + ')
		AND (D.ProcessID IN (1,10))';

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

	If @ChequeIsDigital = 1
		SET @StrWhere = @StrWhere + ' AND D.ChequeIsDigital = 1'
	If @ChequeIsDigital = 0
		SET @StrWhere = @StrWhere + ' '
	-----------------------------------------------------------------------------------------
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

	SET @TempTable1 = '##tbl_RptReceivableStats1'
	SET @TempTable2 = '##tbl_RptReceivableStats2'

	BEGIN TRY
		SET @StrSelect = N'DROP TABLE ' + @TempTable1
		EXEC sp_executesql @StrSelect
	END TRY
	BEGIN CATCH
	END CATCH

	BEGIN TRY
		SET @StrSelect = N'DROP TABLE ' + @TempTable2
		EXEC sp_executesql @StrSelect
	END TRY
	BEGIN CATCH
	END CATCH

	-- اسناد دریافتنی موجود در صندوق و موجود در بانک ------------------------------
	SET @StrSelect = '
	SELECT	D.CreditCode, D.AmountU, D.AmountR,
			Substring(D.ChequeDate, 1, 4) Year, Substring(D.ChequeDate, 6, 2) Mon
	INTO ' + @TempTable1 + '
	FROM trs.tblPayDtl DL
			INNER JOIN 
			(
				SELECT	D.VolumeFiscalYear, D.VolumeRowNo, D.CreditCode, D.ChequeDate, D.Amount AmountU, cast(0 as float) AmountR,
						(
							SELECT	Max(EventNo) AS MaxEventNo
							FROM	trs.tblPayDtl DI
							WHERE   (DI.VolumeFiscalYear = D.VolumeFiscalYear) AND (DI.VolumeRowNo = D.VolumeRowNo) AND  (DI.PayTypeID IN (6,26))
						) AS MaxEventNo
				FROM	trs.tblPayDtl D
				'+@StrAcntWhere+'
				WHERE ' + @StrWhere + '
			) D	ON (D.VolumeFiscalYear = DL.VolumeFiscalYear) AND (D.VolumeRowNo = DL.VolumeRowNo) AND (D.MaxEventNo = DL.EventNo)
	WHERE (DL.PayTypeID IN (6,26)) AND (DL.ProcessID IN (1, 10, 17, 20, 21, 23, 40))'

	PRINT @StrSelect;
	EXEC sp_executesql @StrSelect;

	----------------------------------------------------------------------------
	-- اسناد دریافتنی واگذار شده به اشخاص --------------------------------------
	SET @StrTmpl = '
	INSERT	INTO ' + @TempTable1 + '
	SELECT	D.CreditCode, D.AmountU, D.AmountR,
			Substring(D.ChequeDate, 1, 4) Year, Substring(D.ChequeDate, 6, 2) Mon
	FROM [@DBNAME].[trs].[tblPayDtl] DL
			INNER JOIN 
			(
				SELECT	D.VolumeFiscalYear, D.VolumeRowNo, D.CreditCode, D.ChequeDate, 0 AmountU, D.Amount AmountR,
						(
							SELECT	Max(EventNo) AS MaxEventNo
							FROM	[@DBNAME].[trs].[tblPayDtl] DI
							WHERE   (DI.VolumeFiscalYear = D.VolumeFiscalYear) AND (DI.VolumeRowNo = D.VolumeRowNo) AND  (DI.PayTypeID IN (6,26))
						) AS MaxEventNo
				FROM	[@DBNAME].[trs].[tblPayDtl] D
				WHERE ' + @StrWhere + '
			) D	ON (D.VolumeFiscalYear = DL.VolumeFiscalYear) AND (D.VolumeRowNo = DL.VolumeRowNo) AND (D.MaxEventNo = DL.EventNo)
	WHERE (DL.PayTypeID IN (6,26)) AND (DL.ProcessID IN (2))'

	-- Cheques paid to people in last years is not transfered to new year 
	-- so we shoud check the last years.

	------- Current Year -----------------------------------
	SET @StrSelect = Replace(@StrTmpl, '@DBNAME', db_name())
	PRINT @StrSelect;
	EXEC sp_executesql @StrSelect;

	------- 1 Year Before ----------------------------------
	SET @StrDB = db_name()

	EXEC [pub].[SpGetPrevDBName] @StrDB, @StrPrevDB OUTPUT

	If (@StrPrevDB = '') 
		GOTO _CONTINUE

	SET @StrSelect = Replace(@StrTmpl, '@DBNAME', @StrPrevDB)
	PRINT @StrSelect;
	EXEC sp_executesql @StrSelect;

	------- 2 Years Before ----------------------------------
	SET @StrDB = @StrPrevDB

	Exec [pub].[SpGetPrevDBName] @StrDB, @StrPrevDB OUTPUT 

	If (@StrPrevDB = '') 
		GOTO _CONTINUE

	SET @StrSelect = Replace(@StrTmpl, '@DBNAME', @StrPrevDB)
	PRINT @StrSelect;
	EXEC sp_executesql @StrSelect;
 	--------------------------------------------------------
_CONTINUE:

	set @ThisYear = Substring(db_name(), len(db_name()) -3 ,4);
	set @NextYear = cast(cast(@ThisYear as int) + 1 as char(4));

	SET @StrSelect = '
	SELECT	Year, CreditCode, 
			case when (Mon=''01'') then AmountU else 0 end as AmountU01,
			case when (Mon=''02'') then AmountU else 0 end as AmountU02,
			case when (Mon=''03'') then AmountU else 0 end as AmountU03,
			case when (Mon=''04'') then AmountU else 0 end as AmountU04,
			case when (Mon=''05'') then AmountU else 0 end as AmountU05,
			case when (Mon=''06'') then AmountU else 0 end as AmountU06,
			case when (Mon=''07'') then AmountU else 0 end as AmountU07,
			case when (Mon=''08'') then AmountU else 0 end as AmountU08,
			case when (Mon=''09'') then AmountU else 0 end as AmountU09,
			case when (Mon=''10'') then AmountU else 0 end as AmountU10,
			case when (Mon=''11'') then AmountU else 0 end as AmountU11,
			case when (Mon=''12'') then AmountU else 0 end as AmountU12,
			case when (Mon=''01'') then AmountR else 0 end as AmountR01,
			case when (Mon=''02'') then AmountR else 0 end as AmountR02,
			case when (Mon=''03'') then AmountR else 0 end as AmountR03,
			case when (Mon=''04'') then AmountR else 0 end as AmountR04,
			case when (Mon=''05'') then AmountR else 0 end as AmountR05,
			case when (Mon=''06'') then AmountR else 0 end as AmountR06,
			case when (Mon=''07'') then AmountR else 0 end as AmountR07,
			case when (Mon=''08'') then AmountR else 0 end as AmountR08,
			case when (Mon=''09'') then AmountR else 0 end as AmountR09,
			case when (Mon=''10'') then AmountR else 0 end as AmountR10,
			case when (Mon=''11'') then AmountR else 0 end as AmountR11,
			case when (Mon=''12'') then AmountR else 0 end as AmountR12
	INTO ' + @TempTable2 + '
	FROM ' + @TempTable1 + '
	WHERE (Year >= ' + @ThisYear + ') and (Year <= ' + @NextYear + ')'

	PRINT @StrSelect;
	EXEC sp_executesql @StrSelect;

	--------------------------------------------------------
	SET @StrSelect = '
	SELECT CreditCode, Year,
		sum(AmountU01) AmountU01, sum(AmountU02) AmountU02, sum(AmountU03) AmountU03,
		sum(AmountU04) AmountU04, sum(AmountU05) AmountU05,	sum(AmountU06) AmountU06,
		sum(AmountU07) AmountU07, sum(AmountU08) AmountU08,	sum(AmountU09) AmountU09,
		sum(AmountU10) AmountU10, sum(AmountU11) AmountU11,	sum(AmountU12) AmountU12,
		sum(AmountR01) AmountR01, sum(AmountR02) AmountR02,	sum(AmountR03) AmountR03,
		sum(AmountR04) AmountR04, sum(AmountR05) AmountR05,	sum(AmountR06) AmountR06,
		sum(AmountR07) AmountR07, sum(AmountR08) AmountR08,	sum(AmountR09) AmountR09,
		sum(AmountR10) AmountR10, sum(AmountR11) AmountR11,	sum(AmountR12) AmountR12,
		pub.GetCodeName(CreditCode, 1) CreditName
	FROM ' + @TempTable2 + '
	GROUP BY CreditCode, Year 
	ORDER BY CreditCode, Year '

	PRINT @StrSelect;
	EXEC sp_executesql @StrSelect;
	--------------------------------------------------------
	-- finalize --------------------------------------------
	BEGIN TRY
		SET @StrSelect = N'DROP TABLE ' + @TempTable1
		EXEC sp_executesql @StrSelect
	END TRY
	BEGIN CATCH
	END CATCH

	BEGIN TRY
		SET @StrSelect = N'DROP TABLE ' + @TempTable2
		EXEC sp_executesql @StrSelect
	END TRY
	BEGIN CATCH
	END CATCH

	--------------------------------------------------------
End
GO
