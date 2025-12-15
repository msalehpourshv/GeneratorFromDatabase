USE TS_ShirinVatanKarkhaneh_1_1404
GO
SET ANSI_NULLS, QUOTED_IDENTIFIER ON
GO
-- =========== TS-QC:UPDATED ====================
-- Author		 : Ahmadnejad
-- Create date   : 1386/03/16
-- Viewed By	 : 
-- Last Modified : 1392/01/07
-- Description	 : <Cheque Progress>
-- ----------------------------------------------
-- آمار چکهای دریافتی از اشخاص
-- ==============================================
Create PROCEDURE [trs].[RptTrs_ReceivableDocs_Stats]
	@ProcessNo	int = 1,
	@State		int = 2,
	/* 0 = کلیه چکها    */
	/* 1 = چکهای موجود  */
	/* 2 = چکهای برگشتی */
	@RepOptions	VarChar(10) = '1111', -- bit array options
	@RepInfo	NVarChar(100) = '1@1@1'
WITH ENCRYPTION
AS
Declare @ProcessID	NVarChar(50);
Declare @StrQuery	NVarChar(max);
DECLARE @StrAcntWhere	NVarChar(4000);
Declare @StrWhere		NVarChar(4000);
DECLARE @CampaignID				int;
DECLARE @VisitPathID1			int;
DECLARE @VisitPathID2			int;
DECLARE @VisitPathID3			int;
DECLARE @VisitPathID4			int;
DECLARE @SalesRoomClass			int;
DECLARE @ChequeIsDigital		int;
DECLARE	@LangID			Int;
DECLARE	@SessionNo		Int; 
DECLARE	@ReportID		Int; 
Begin  -----------------  B E G I N   T O   C O D E  --------------------------

	Set NoCount On;
	
	SET @LangID		= pub.funSplitString(@RepInfo, '@', 1);
	SET @SessionNo	= pub.funSplitString(@RepInfo, '@', 2);
	SET @ReportID	= pub.funSplitString(@RepInfo, '@', 3);

	-- Init --
	SET @CampaignID		  = pub.funSplitString(@RepInfo, '@', 6);
	SET @VisitPathID1	  = pub.funSplitString(@RepInfo, '@', 7);
	SET @VisitPathID2	  = pub.funSplitString(@RepInfo, '@', 8);
	SET @VisitPathID3	  = pub.funSplitString(@RepInfo, '@', 9);
	SET @VisitPathID4	  = pub.funSplitString(@RepInfo, '@', 10);
	SET @SalesRoomClass	  = pub.funSplitString(@RepInfo, '@', 11);
	Set @ChequeIsDigital  = pub.funSplitString(@RepInfo, '@', 12);

	--=========================

	Declare @CustomerPartNo			int;
	DECLARE @CustomerPartStart		int;
	DECLARE @CustomerPartLayerLen	int;

		
	select @CustomerPartNo=[acc].[FunGetAcntInfoForRemain](1)
	select @CustomerPartStart=[acc].[FunGetAcntInfoForRemain](2)
	select @CustomerPartLayerLen= [acc].[FunGetAcntInfoForRemain](3)


	set @StrAcntWhere=' '
	set @StrWhere=' '

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
		SET @StrWhere = @StrWhere + ' AND PD.ChequeIsDigital = 1' 
	If @ChequeIsDigital = 0
		SET @StrWhere = @StrWhere + ' '
		
	If  @StrAcntWhere <> ''
		SET @StrAcntWhere = '
		INNER JOIN (Select AcntCode AcntC From acc.tblAcnt Where PartNumber = ' + LTrim(RTrim(Str(@CustomerPartNo))) + ' 
		'+  @StrAcntWhere +'
		) a 
		ON Cast(Substring(PD.CreditCode , ' + Str(@CustomerPartStart) + ', ' + Str(@CustomerPartLayerLen) + ') AS VarChar(20)) = a.AcntC 
		or Cast(Substring(PD.DebitCode , ' + Str(@CustomerPartStart) + ', ' + Str(@CustomerPartLayerLen) + ') AS VarChar(20)) = a.AcntC '
			

	--=========================
	
	If (@State = 0)      /* All Cheques */
		Set @ProcessID = '10, 1, 40'
	Else If (@State = 1) /* Available Cheques */
		Set @ProcessID = '10, 1, 17, 23, 40'
	Else If (@State = 2) /* Returned Cheques */
		Set @ProcessID = '13, 18, 24'
	
	If (@State = 0)		/* All Cheques */
		Set @StrQuery = '
			SELECT CreditCode AS OwnerAcntCode, pub.GetCodeName(CreditCode, 1) AS OwnerAcntName, 
					SUM(Amount) AmountSum, COUNT(*) ChequeCount
			FROM	trs.tblPayDtl PD
			'+@StrAcntWhere+'
			WHERE	PayTypeID IN (6, 26) 
						AND ProcessNo = ' + LTrim(str(@ProcessNo)) + '
						AND ProcessID IN (' + LTrim(@ProcessID) + ')
						'+@StrWhere+'
			GROUP  BY CreditCode '
	Else	/* Limited Cheques */
		Set @StrQuery = '
			SELECT Credit AS OwnerAcntCode, pub.GetCodeName(Credit, 1) AS OwnerAcntName, 
					 SUM(Amount) AS AmountSum, COUNT(*) ChequeCount
			FROM
			(
				SELECT	Amount,
						(
							SELECT Top 1 CreditCode
							FROM	trs.tblPayDtl
							WHERE	ProcessID IN (1,10) 
									AND ProcessNo = (' + LTrim(str(@ProcessNo)) + ')							
									AND PayTypeID IN (6,26) 
									AND VolumeFiscalYear = PD.VolumeFiscalYear 
									AND VolumeRowNo = PD.VolumeRowNo
							ORDER By EventNo ASC
						) AS Credit
				FROM	 trs.tblPayDtl PD
				'+@StrAcntWhere+'
						 INNER JOIN
						 (
					 		SELECT	VolumeFiscalYear, VolumeRowNo, Max(EventNo) AS EventNo 
					 		FROM	trs.tblPayDtl
					 		WHERE	PayTypeID IN (6, 26)
										AND ProcessNo = ' + LTrim(str(@ProcessNo)) + '
					 		GROUP  BY VolumeFiscalYear, VolumeRowNo
						 ) VOL ON PD.VolumeFiscalYear = VOL.VolumeFiscalYear AND PD.VolumeRowNo = VOL.VolumeRowNo AND PD.EventNo = VOL.EventNo
				WHERE	PayTypeID IN (6, 26) 
							AND PD.ProcessNo = ' + LTrim(str(@ProcessNo)) + '
							AND PD.ProcessID IN(' + LTrim(@ProcessID) + ')
							'+@StrWhere+'
			) T
			GROUP BY Credit '
	Print @StrQuery;
	Exec sp_executesql @StrQuery;
End
GO
