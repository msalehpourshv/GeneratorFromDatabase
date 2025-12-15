USE TS_ShirinVatanKarkhaneh_1_1404
GO
SET ANSI_NULLS, QUOTED_IDENTIFIER ON
GO
-- =========== TS-QC:UPDATED ====================
-- Author		 : TakroSystem\Ahmadnejad
-- Create date   : 1387/07/08
-- Viewed By	 : 
-- Last ModIFied : 1393/05/30
-- Last ModIFier : TakroSystem\Hamid
-- Description	 : گزارش آخرین فروش برای مشتریان
-- ==============================================
Create  PROCEDURE [sal].[RptSale_LastSale]
	@ProcessID			SmallInt = 90, -- 90 = Sale
	@ProcessNo			TinyInt = 1,
	@Duration			Char(10) = '',
	@SelectedAcnt1		int = 0,
	@SelectedAcnt2		int = 0,
	@SelectedAcnt3		int = 0,
	@SelectedAcnt4		int = 0,
	@SelectedVist1		int = 0,
	@SelectedVist2		int = 0,
	@SelectedVist3		int = 0,
	@SelectedVist4		int = 0,
	@VisitPathID1		VarChar(20) = Null,
	@VisitPathID2		VarChar(20) = Null,
	@VisitPathID3		VarChar(20) = Null,
	@VisitPathID4		VarChar(20) = Null,
	@RepOptions			VarChar(20) = '22',  -- bit array options
	@RepInfo			VarChar(100) = '1@1@1'

WITH ENCRYPTION
AS
---- Declarations ---------------
DECLARE @StrSelect	NVarChar(max)
DECLARE @StrWhereH	NVarChar(max)
DECLARE @StrWhere	NVarChar(max)
DECLARE @StrWhere2	NVarChar(max)
DECLARE @StrFrom	NVarChar(max)

DECLARE @Today		Char(10);
DECLARE @LanguageID TinyInt;
DECLARE	@SessionNo	Int; 
DECLARE	@ReportID	Int; 
Declare @MaxCount   int;

DECLARE	@FilterByDuration bit;

Begin -- ============== S T A R T  C O D E ====================================

	SET NOCOUNT ON;
	SET @Today = pub.funFarsiDate(GetDate())

	IF (@RepInfo	Is Null)	SET @RepInfo = '1@1@1';
	IF (@RepOptions	Is Null)	SET @RepOptions	= '11';
	
	IF (@SelectedAcnt1	Is Null)	SET @SelectedAcnt1 = 0;
	IF (@SelectedAcnt2	Is Null)	SET @SelectedAcnt2 = 0;
	IF (@SelectedAcnt3	Is Null)	SET @SelectedAcnt3 = 0;
	IF (@SelectedAcnt4	Is Null)	SET @SelectedAcnt4 = 0;
	IF (@SelectedVist1	Is Null)	SET @SelectedVist1 = 0;
	IF (@SelectedVist2	Is Null)	SET @SelectedVist2 = 0;
	IF (@SelectedVist3	Is Null)	SET @SelectedVist3 = 0;
	IF (@SelectedVist4	Is Null)	SET @SelectedVist4 = 0;
	
	SET @LanguageID	= pub.funSplitString(@RepInfo, '@', 1);
	SET @SessionNo	= pub.funSplitString(@RepInfo, '@', 2);
	SET @ReportID	= pub.funSplitString(@RepInfo, '@', 3);
	SET @MaxCount	= pub.funSplitString(@RepInfo, '@', 6);
 
	
	SET @FilterByDuration	= Substring(@RepOptions, 1, 1)

	-- Init Variables ---------------------------------------
--	SET @LanguageID = pub.funGetCurrentLanguageID();
	
	-- Where ------------------------------------------------------
	SET @StrWhere = '1 = 1'
	SET @StrWhere2 = '1 = 1'
	SET @StrWhereH = '(H.ProcessID = ' + LTrim(Str(@ProcessID)) + ') and (H.ProcessNo = ' + LTrim(Str(@ProcessNo)) + ')'

	IF (@SelectedAcnt1 > 0)
		SET @StrWhereH = @StrWhereH + ' AND ' + pub.funGetFilterString(@SessionNo, @ReportID, @SelectedAcnt1, 'H.AcntCode')
	IF (@SelectedAcnt2 > 0)
		SET @StrWhereH = @StrWhereH + ' AND ' + pub.funGetFilterString(@SessionNo, @ReportID, @SelectedAcnt2, 'H.AcntCode')
	IF (@SelectedAcnt3 > 0)
		SET @StrWhereH = @StrWhereH + ' AND ' + pub.funGetFilterString(@SessionNo, @ReportID, @SelectedAcnt3, 'H.AcntCode')
	IF (@SelectedAcnt4 > 0)
		SET @StrWhereH = @StrWhereH + ' AND ' + pub.funGetFilterString(@SessionNo, @ReportID, @SelectedAcnt4, 'H.AcntCode')

	IF (@SelectedVist1 > 0)
		SET @StrWhereH = @StrWhereH + ' AND ' + pub.funGetFilterString(@SessionNo, @ReportID, @SelectedVist1, 'H.VisitorAcntCode')
	IF (@SelectedVist2 > 0)
		SET @StrWhereH = @StrWhereH + ' AND ' + pub.funGetFilterString(@SessionNo, @ReportID, @SelectedVist2, 'H.VisitorAcntCode')
	IF (@SelectedVist3 > 0)
		SET @StrWhereH = @StrWhereH + ' AND ' + pub.funGetFilterString(@SessionNo, @ReportID, @SelectedVist3, 'H.VisitorAcntCode')
	IF (@SelectedVist4 > 0)
		SET @StrWhereH = @StrWhereH + ' AND ' + pub.funGetFilterString(@SessionNo, @ReportID, @SelectedVist4, 'H.VisitorAcntCode')

	IF (@VisitPathID1 <> 0)
		SET @StrWhere = @StrWhere + ' AND ' + pub.funGetFilterString(@SessionNo, @ReportID, @VisitPathID1, 'A.VisitPathID1')
	IF (@VisitPathID2 <> 0)
		SET @StrWhere = @StrWhere + ' AND ' + pub.funGetFilterString(@SessionNo, @ReportID, @VisitPathID2, 'A.VisitPathID2')
	IF (@VisitPathID3 <> 0)
		SET @StrWhere = @StrWhere + ' AND ' + pub.funGetFilterString(@SessionNo, @ReportID, @VisitPathID3, 'A.VisitPathID3')
	IF (@VisitPathID4 <> 0)
		SET @StrWhere = @StrWhere + ' AND ' + pub.funGetFilterString(@SessionNo, @ReportID, @VisitPathID4, 'A.VisitPathID4')

	IF @FilterByDuration = 1
		SET @StrWhere2 = @StrWhere2 + ' AND Duration >= ''' + LTrim(RTrim(Str(@Duration))) + ''''
	ELSE IF @Duration > 0 OR @MaxCount>0
		SET @StrWhere2 = @StrWhere2 + ' AND RCount >= ' + LTrim(RTrim(Str(@Duration))) + ' AND (RCount <= ' + LTrim(RTrim(Str(@MaxCount))) +' OR '+ LTrim(RTrim(Str(@MaxCount)))+'=0 )'
	
	--=====
	Declare @NamePartNo AS Tinyint
	SET @NamePartNo = 0
	
	Declare @StartLen AS Tinyint
	SET @StartLen = 0
	
	SELECT @NamePartNo = SettingValue
	FROM pub.tblSettings
	WHERE SettingKey = 'AcntPartNumberForRemainCalculation'

	IF @NamePartNo = 1
		SET @NamePartNo = 1
	Else IF @NamePartNo > 1
		SET @NamePartNo = @NamePartNo - 1
			
	--=====
	Declare @NamePartNoLen1 AS Tinyint
	SET @NamePartNoLen1 = 0

	SELECT @NamePartNoLen1 = Layer1 + Layer2 + Layer3 + Layer4 + Layer5 + Layer6 + Layer7 + Layer8 + Layer9 + 1
	FROM pub.tblCodeLayer
	Where TableName = 'acc.tblAcnt' And PartNumber = @NamePartNo
	
	--=====
	SELECT @NamePartNo = SettingValue
	FROM pub.tblSettings
	WHERE SettingKey = 'AcntPartNumberForRemainCalculation'
		
	IF @NamePartNo = 1
		SET @StartLen = 1
	Else IF @NamePartNo > 1
		SET @StartLen = @NamePartNoLen1 + 1
	
	--=====
	Declare @NamePartNoLen2 AS Tinyint
	SET @NamePartNoLen2 = 0

	SELECT @NamePartNoLen2 = Layer1 + Layer2 + Layer3 + Layer4 + Layer5 + Layer6 + Layer7 + Layer8 + Layer9 + 1
	FROM pub.tblCodeLayer
	Where TableName = 'acc.tblAcnt' And PartNumber = @NamePartNo
		
	------------------------------------------------------------
	
	--SELECT T.*, pub.GetCodeName(AcntCode, @LanguageID) AcntName
	--FROM
	--(
	--	SELECT AcntCode, Abs(pub.funFarsiDateDiff('Day', @Today, DocDate)) Duration, DocDate
	--	FROM inv.tblStorageDocsHdr H	
	--	WHERE (ProcessID = @ProcessID) AND (ProcessNo = @ProcessNo)
	--) T
	--WHERE Duration >= @Duration
	
	SET @StrSelect = '
	SELECT T.*, pub.GetCodeName(AcntCode,1) AcntName
	FROM
	(
		SELECT H.AcntCode, F.Tel, F.Fax, F.Mobile, F.SMSMobile, IsNull(F.Address1,'''') As Address1, IsNull(F.Address2,'''') As Address2, 
			   Abs(pub.funFarsiDateDiff(''Day'',''' + @Today + ''', H.DocDate)) Duration, RCount,
			   H.DocDate, IsNull(A.VisitPathID1,'''') As Branch_Code, 
			   IsNull(VD1.VisitPathName,'''') As Branch, 
			   IsNull(A.VisitPathID2,'''') As SuperVisor_Code, 
			   IsNull(VD2.VisitPathName,'''') As SuperVisor, 
			   IsNull(A.VisitPathID3,'''') As VisitArea_Code, 
			   IsNull(VD3.VisitPathName,'''') As VisitArea,	
			   IsNull(A.VisitPathID4,'''') As VisitRout_Code, 
			   IsNull(VD4.VisitPathName,'''') As VisitRout
		FROM (
			  SELECT H.AcntCode, MAX(H.DocDate) DocDate, 
					 Abs(pub.funFarsiDateDiff(''Day'',''' + @Today + ''', MAX(H.DocDate))) Duration,
					 Count(H.AcntCode) RCount
			  FROM inv.tblStorageDocsHdr H	
			  WHERE ' + @StrWhereH + '
			  GROUP BY  H.AcntCode
			) H	
		LEFT  JOIN acc.tblAcnt A ON A.AcntCode = SubString(H.AcntCode, ' + LTrim(RTrim(@StartLen)) + ', ' + LTrim(RTrim(@NamePartNoLen2)) + ')
		LEFT  JOIN acc.tblAcntDtl AD ON AD.AcntCode = SubString(H.AcntCode, ' + LTrim(RTrim(@StartLen)) + ', ' + LTrim(RTrim(@NamePartNoLen2)) + ')
		LEFT  JOIN acc.tblVisitPathDtl VD1 ON VD1.VisitPathID = A.VisitPathID1 AND VD1.PartNumber=1
		LEFT  JOIN acc.tblVisitPathDtl VD2 ON VD2.VisitPathID = A.VisitPathID2 AND VD2.PartNumber=2
		LEFT  JOIN acc.tblVisitPathDtl VD3 ON VD3.VisitPathID = A.VisitPathID3 AND VD3.PartNumber=3
		LEFT  JOIN acc.tblVisitPathDtl VD4 ON VD4.VisitPathID = A.VisitPathID4 AND VD4.PartNumber=4
		Outer Apply acc.funGetCodeInfo(H.AcntCode) F
		WHERE ' + @StrWhere + '
	) T
	WHERE ' + @StrWhere2
	
	--------------------------------
	PRINT @StrSelect;
	EXEC sp_executesql @StrSelect;
	--------------------------------
END
GO
