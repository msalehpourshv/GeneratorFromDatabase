USE TS_ShirinVatanKarkhaneh_1_1404
GO
SET ANSI_NULLS, QUOTED_IDENTIFIER ON
GO
-- =========== TS-QC:UPDATED ====================
-- Author		 : Reza Nogrehpasand
-- Create date   : 1392/03/18
-- Viewed By	 : 
-- Last Modified : 
-- Last Modifier : 93/09/25
-- Description	 : گزارش فرم انجام كار
-- =============================================
CREATE PROCEDURE [srv].[RptSrv_Task_RegisterCRM] 
	
	@FiscalYear			INT=94,
	@PerssonelID		VarChar(20)=null,
	@FromDate			CHAR(10)='1392/01/01',
	@ToDate				CHAR(10)='1394/12/01',
	@FiscalYearFr		Int = 92,
	@SerialNoFr			Int = 1,
	@FiscalYearTo		Int = 94,
	@SerialNoTo			Int = 1000,
	@CompanyID			VarChar(20)=null,
	@Priority			INT=null,
	@TaskStatus			INT=null,
	@IsTelService		BIT='True',
	@AcntPart			INT =2,
	@ServiceType		VARCHAR(20)=null,
	@SprintID			VARCHAR(20)=null,
	@FiscalYearReqFr	Int = 92,
	@SerialNoReqFr		Int = 1,
	@FiscalYearReqTo	Int = 94,
	@SerialNoReqTo		Int = 1000,
	@ServiceID1			VARCHAR(20)=null,
	@ServiceID2			VARCHAR(20)=null,
	@ServiceLen1		tinyint=2,
	@ServiceLen2		tinyint=2,
	@ChangeSet			NVarChar(100)=null,
	@RepInfo			NVarChar(200) = '1@1@1'

WITH ENCRYPTION
AS

DECLARE @StrSelect		NVarChar(MAX);
DECLARE @StrSelect2		NVarChar(MAX);
DECLARE @StrSelect3		NVarChar(MAX);
DECLARE @StrWhere		NVarChar(MAX);
DECLARE @StrWhere2		NVarChar(MAX);
DECLARE	@UserID				Int=1,
		@IsAdmin			bit=1,
		@ServiceKindAdmin	bit=1,
		@Service1Admin		bit=1,
		@Service2Admin		bit=1,
		@Service3Admin		bit=1,
		@Service4Admin		bit=1,
		@Service1Len		tinyint=0,
		@Service2Len		tinyint=0,
		@Service3Len		tinyint=0,
		@Service4Len		tinyint=0

DECLARE	@LangID			Char(1);
DECLARE	@SessionNo		Int; -- برای حالت کدهای انتخابی
DECLARE	@ReportID		Int; -- برای حالت کدهای انتخابی
declare @db_0000		nvarchar(50);

BEGIN 
	-- ============================ S T A R T =====================================================

	-- Init --------------------------
	SET NOCOUNT ON;
	
	--========================
	DECLARE @UnitPart TINYINT
	SET @UnitPart  = 1
	SEt @StrSelect3 = ''

	SELECT @UnitPart = SettingValue from pub.tblSettings where SettingKey = 'UnitPart'

	IF @UnitPart IS NULL or @UnitPart = 0
		SET @UnitPart = 1

	DECLARE @str_Goods  tinyint,
			@str_GoodsSum tinyint

	select @str_Goods = ISNULL(SUM (Layer1+Layer2+Layer3+Layer4+Layer5+Layer6+Layer7+Layer8+Layer9),0)
	from pub.tblCodeLayer 
	where TableName='inv.tblGoods' AND PartNumber<@UnitPart

	select @str_GoodsSum = Layer1+Layer2+Layer3+Layer4+Layer5+Layer6+Layer7+Layer8+Layer9
	from pub.tblCodeLayer 
	where TableName= 'inv.tblGoods' AND PartNumber=@UnitPart
		
	SET @db_0000 = Substring(db_name(), 1, Len(db_name()) - 4) + '0000'
	
	SET @LangID		= pub.funSplitString(@RepInfo, '@', 1);
	SET @SessionNo	= pub.funSplitString(@RepInfo, '@', 2);
	SET @ReportID	= pub.funSplitString(@RepInfo, '@', 3);

	SET @UserID		= pub.funSplitString(@RepInfo, '@', 4);
	SET @IsAdmin	= pub.funSplitString(@RepInfo, '@', 5);
	SET @ServiceKindAdmin = pub.funSplitString(@RepInfo, '@', 6);
	SET	@Service1Admin	= pub.funSplitString(@RepInfo, '@', 7);
	SET	@Service2Admin	= pub.funSplitString(@RepInfo, '@', 8);
	SET	@Service3Admin	= pub.funSplitString(@RepInfo, '@', 9);
	SET	@Service4Admin	= pub.funSplitString(@RepInfo, '@', 10);
	SET	@Service1Len	= pub.funSplitString(@RepInfo, '@', 11);
	SET	@Service2Len	= pub.funSplitString(@RepInfo, '@', 12);
	SET	@Service3Len	= pub.funSplitString(@RepInfo, '@', 13);
	SET	@Service4Len	= pub.funSplitString(@RepInfo, '@', 14);
	--==========	
	set @StrWhere = '1=1'	
	set @StrWhere2 = '1=1'	
		
	IF (@FiscalYear IS NOT null)
		SET @StrWhere = @StrWhere + ' AND d.FiscalYear=' + ltrim(STR(@FiscalYear))
		
	IF (@PerssonelID IS NOT null)
		SET @StrWhere = @StrWhere + ' AND p.PersonnelID=''' + @PerssonelID + '''' 
		
	IF (@CompanyID IS NOT null)
		SET @StrWhere = @StrWhere + ' AND r.CompanyID=''' + @CompanyID + '''' 
			
	IF (@SerialNoFr Is Not Null)
		SET @StrWhere = @StrWhere + ' AND (d.FiscalYear > ' + LTrim(Str(@FiscalYearFr)) + ' OR (d.FiscalYear = ' + LTrim(Str(@FiscalYearFr)) + ' AND d.SerialNo >= ' + LTrim(Str(@SerialNoFr)) + '))' 
	
	IF (@SerialNoTo Is Not Null)
		SET @StrWhere = @StrWhere + ' AND (d.FiscalYear < ' + LTrim(Str(@FiscalYearTo)) + ' OR (d.FiscalYear = ' + LTrim(Str(@FiscalYearTo)) + ' AND d.SerialNo <= ' + LTrim(Str(@SerialNoTo)) + '))' 
	
	IF (@SerialNoReqFr Is Not Null)
		SET @StrWhere = @StrWhere + ' AND (rd.FiscalYear > ' + LTrim(Str(@FiscalYearReqFr)) + ' OR (rd.FiscalYear = ' + LTrim(Str(@FiscalYearReqFr)) + ' AND rd.SerialNo >= ' + LTrim(Str(@SerialNoReqFr)) + '))' 
	
	IF (@SerialNoReqTo Is Not Null)
		SET @StrWhere = @StrWhere + ' AND (rd.FiscalYear < ' + LTrim(Str(@FiscalYearReqTo)) + ' OR (rd.FiscalYear = ' + LTrim(Str(@FiscalYearReqTo)) + ' AND rd.SerialNo <= ' + LTrim(Str(@SerialNoReqTo)) + '))' 
		
	 If @ServiceID1  Is Not Null  
         SET @StrWhere = @StrWhere + ' AND substring(rd.ServiceID,1,'+ ltrim(STR(@ServiceLen1)) +')='''+@ServiceID1+''''
       
	If @ServiceID2  Is Not Null  
         SET @StrWhere = @StrWhere + ' AND substring(rd.ServiceID,'+ltrim(STR(@ServiceLen1+2))+','+ ltrim(STR(@ServiceLen2)) +')='''+@ServiceID2+''''

    If @IsAdmin = 0 And @ServiceKindAdmin = 0 
        SET @StrWhere = @StrWhere + ' AND [srv].[funServiceKindPermitted] (' + LTrim(RTrim(str(@UserID))) + ',rd.ServiceKindID)=1 ' 
            
    If @IsAdmin = 0 And @Service1Admin = 0 AND @Service1Len>0
	BEGIN
        SET @StrWhere = @StrWhere + ' AND [acc].[funServiceCodingPermitted]  (' + LTrim(RTrim(str(@UserID))) + ',SUBSTRING(rd.ServiceID,1,' +  LTrim(RTrim(str(@Service1Len)))  +'),1)=1 ' 
        SET @StrWhere2 = @StrWhere2 + ' AND [acc].[funServiceCodingPermitted]  (' + LTrim(RTrim(str(@UserID))) + ',SUBSTRING(t.ServiceID,1,' +  LTrim(RTrim(str(@Service1Len)))  +'),1)=1 ' 
	END
    If @IsAdmin = 0  And @Service2Admin = 0 AND @Service2Len>0
	BEGIN
        SET @StrWhere = @StrWhere + ' AND [acc].[funServiceCodingPermitted]  (' + LTrim(RTrim(str(@UserID))) + ',SUBSTRING(rd.ServiceID,'+ LTrim(RTrim(str(@Service1Len)))  +'+2,' +  LTrim(RTrim(str(@Service2Len)))  +'),2)=1 ' 
        SET @StrWhere2 = @StrWhere2 + ' AND [acc].[funServiceCodingPermitted]  (' + LTrim(RTrim(str(@UserID))) + ',SUBSTRING(t.ServiceID,'+ LTrim(RTrim(str(@Service1Len)))  +'+2,' +  LTrim(RTrim(str(@Service2Len)))  +'),2)=1 ' 
	END
            
    If @IsAdmin = 0  And @Service3Admin = 0 AND @Service3Len>0
	BEGIN
        SET @StrWhere = @StrWhere + ' AND [acc].[funServiceCodingPermitted]  (' + LTrim(RTrim(str(@UserID))) + ',SUBSTRING(rd.ServiceID,'+ LTrim(RTrim(str(@Service1Len+@Service2Len)))  +'+3,' +  LTrim(RTrim(str(@Service3Len)))  +'),3)=1 ' 
        SET @StrWhere2 = @StrWhere2 + ' AND [acc].[funServiceCodingPermitted]  (' + LTrim(RTrim(str(@UserID))) + ',SUBSTRING(t.ServiceID,'+ LTrim(RTrim(str(@Service1Len+@Service2Len)))  +'+3,' +  LTrim(RTrim(str(@Service3Len)))  +'),3)=1 ' 
	END
            
    If @IsAdmin = 0  And @Service4Admin = 0 AND @Service4Len>0
	BEGIN
        SET @StrWhere = @StrWhere + ' AND [acc].[funServiceCodingPermitted]  (' + LTrim(RTrim(str(@UserID))) + ',SUBSTRING(rd.ServiceID,'+ LTrim(RTrim(str(@Service1Len+@Service2Len+@Service3Len)))  +'+4,' +  LTrim(RTrim(str(@Service4Len)))  +'),4)=1 ' 
        SET @StrWhere2 = @StrWhere2 + ' AND [acc].[funServiceCodingPermitted]  (' + LTrim(RTrim(str(@UserID))) + ',SUBSTRING(t.ServiceID,'+ LTrim(RTrim(str(@Service1Len+@Service2Len+@Service3Len)))  +'+4,' +  LTrim(RTrim(str(@Service4Len)))  +'),4)=1 ' 
	END

	
	--IF (@FromDate IS NOT null)
	--	SET @StrWhere = @StrWhere + ' AND ((SELECT MIN(EventDate) FROM srv.tblServiceTaskAtm2 a
	--			WHERE a.ProcessID=d.ProcessID AND a.ProcessNo=d.ProcessNo
	--			AND a.FiscalYear=d.FiscalYear AND a.SerialNo=d.SerialNo 
	--			AND a.DocRowNo=d.DocRowNo) >=''' + @FromDate + ''' OR 
	--			(SELECT MAX(EventDate) FROM srv.tblServiceTaskAtm2 a
	--			WHERE a.ProcessID=d.ProcessID AND a.ProcessNo=d.ProcessNo
	--			AND a.FiscalYear=d.FiscalYear AND a.SerialNo=d.SerialNo 
	--			AND a.DocRowNo=d.DocRowNo) >=''' + @FromDate + ''')'
		
	--IF (@ToDate IS NOT null)
	--	SET @StrWhere = @StrWhere + ' AND ((SELECT MIN(EventDate) FROM srv.tblServiceTaskAtm2 a
	--			WHERE a.ProcessID=d.ProcessID AND a.ProcessNo=d.ProcessNo
	--			AND a.FiscalYear=d.FiscalYear AND a.SerialNo=d.SerialNo 
	--			AND a.DocRowNo=d.DocRowNo) <=''' + @ToDate + ''' OR  
	--			(SELECT MAX(EventDate) FROM srv.tblServiceTaskAtm2 a
	--			WHERE a.ProcessID=d.ProcessID AND a.ProcessNo=d.ProcessNo
	--			AND a.FiscalYear=d.FiscalYear AND a.SerialNo=d.SerialNo 
	--			AND a.DocRowNo=d.DocRowNo) <=''' + @ToDate + ''')'
		
	IF (@FromDate IS NOT null)
		SET @StrWhere = @StrWhere + ' AND (EventDate >=''' + @FromDate + ''')'
	
	IF (@ToDate IS NOT null)
		SET @StrWhere = @StrWhere + ' AND (EventDate <=''' + @ToDate + ''')'
		
	IF (@Priority IS NOT null)
		SET @StrWhere = @StrWhere + ' AND d.Priority =' + ltrim(str(@Priority))  	
			
	IF (@TaskStatus IS NOT null)
		SET @StrWhere = @StrWhere + ' AND d.TaskStatus =' + ltrim(str(@TaskStatus))  	
	
	IF (@ChangeSet IS NOT null)
		SET @StrWhere = @StrWhere + ' AND a.ChangeSet like ''%' + @ChangeSet + '%''' 
					
	--IF (@ServiceType IS NOT null)
	--	SET @StrWhere = @StrWhere + ' AND (SELECT TOP 1 rd.ServiceKindID
	--		 FROM srv.tblServiceTaskAtm1 a
	--			INNER JOIN srv.tblServiceRequestDtl rd 
	--			ON rd.ProcessID=a.ProcessID AND rd.ProcessNo=a.ProcessNo
	--			AND rd.FiscalYear=a.RequestFiscalYear 
	--			AND rd.SerialNo=a.RequestCode AND rd.DocRowNo=a.RequestRow 
	--		WHERE a.ProcessID=d.ProcessID AND a.ProcessNo=d.ProcessNo 
	--			AND a.FiscalYear=d.FiscalYear
	--			AND a.SerialNo=d.SerialNo AND a.DocRowNo=d.DocRowNo) =''' + @ServiceType + '''' 		
	IF (@ServiceType IS NOT null)
			SET @StrWhere = @StrWhere + ' AND rd.ServiceKindID =''' + @ServiceType + '''' 		
		
	IF (@SprintID IS NOT null)
			SET @StrWhere = @StrWhere + ' AND h.SprintID=''' + @SprintID + '''' 
			
	IF (@SprintID IS NOT null)
			SET @StrWhere2 = @StrWhere2 + ' AND t.SprintID=''' + @SprintID + '''' 
			
	 	 
	IF (@PerssonelID IS NOT null)
			SET @StrWhere2 = @StrWhere2 + ' AND t.PersonnelID=''' + @PerssonelID + '''' 
		
	IF (@FromDate IS NOT null)
		SET @StrWhere2 = @StrWhere2 + ' AND t.DocDate >=''' + @FromDate + ''''
		
	IF (@ToDate IS NOT null)
		SET @StrWhere2 = @StrWhere2 + ' AND t.DocDate <=''' + @ToDate + ''''	 	
		
	IF (@CompanyID IS NOT null)
		SET @StrWhere2 = @StrWhere2 + ' AND t.CompanyID=''' + @CompanyID + '''' 
			
    If @ServiceID1  Is Not Null  
         SET @StrWhere2 = @StrWhere2 + ' AND substring(t.ServiceID,1,'+ ltrim(STR(@ServiceLen1)) +')='''+@ServiceID1+''''
       
	If @ServiceID2  Is Not Null  
         SET @StrWhere2 = @StrWhere2 + ' AND substring(t.ServiceID,'+ltrim(STR(@ServiceLen1+2))+','+ ltrim(STR(@ServiceLen2)) +')='''+@ServiceID2+''''
		
-- ================ SELECT ===========================
	IF @IsTelService = 'True'
	BEGIN
		SET @StrSelect2 = '
		SELECT DISTINCT 
		  0 AS ID, '''' As OperatorName, h.DocDate, d.ProcessID, d.ProcessNo, d.FiscalYear, d.SerialNo, d.RowNo, d.DocRowNo, d.TaskDtlDesc, d.Priority, d.AgreeDate, d.AgreeTime, 
		  '''' As GoodsID, '''' As GoodsName, '''' As UnitID, '''' As UnitName, d.TaskStatus, 
		  d.Duration, d.ConfirmStatus, d.ConfirmDate, d.ConfirmTime, d.DoneDate, d.IsAsap, d.ConfirmPersonelID, a.ProcessID AS EXPR1, a.ProcessNo AS EXPR2, 
		  a.FiscalYear AS EXPR3, a.SerialNo AS EXPR4, a.DocRowNo AS EXPR5, a.AtomRowNo, a.DocAtomRowNo, a.EventDate, a.ExitTime, a.EventStatus, 
		  a.Duration AS EXPR6, a.StartTime, a.EndTime, a.EnterTime, a.PerformDesc, a.ServiceID, a.Qty, a.FaultID, a.PersonelID, a.ChangeSet, a.FaultDesc, 
		  a2.ProcessID AS EXPR7, a2.ProcessNo AS EXPR8, a2.FiscalYear AS EXPR9, a2.SerialNo AS EXPR10, a2.DocRowNo AS EXPR11, a2.AtomRowNo AS EXPR12, 
		  a2.DocAtomRowNo AS EXPR13, a2.RequestCode, a2.RequestRow, a2.RequestFiscalYear, r.CompanyID,
		  p.PersonnelID,

		 acc.funGetAcntName(r.CompanyID,'+ ltrim(STR(@AcntPart)) +','+ LTRIM(str(@LangID)) +')AS  AcntName,
		 prs.funGetPersonnelName(p.PersonnelID,1)as PersonelName,
		 acc.funGetServiceNameFull(a.ServiceID,'+ LTRIM(str(@LangID)) +')AS ServiceName,
		 acc.funGetServiceFaultName(a.FaultID,'+ LTRIM(str(@LangID)) +') AS FaultName,
		 d.IsAsap AS EXPR14
		
		 FROM srv.tblServiceTaskDtl  d
		
		 LEFT JOIN srv.tblServiceTaskHdr h ON d.ProcessID=h.ProcessID AND d.ProcessNo=h.ProcessNo AND 
											  d.FiscalYear=h.FiscalYear AND d.SerialNo=h.SerialNo
		 LEFT JOIN srv.tblServiceTaskPersonnelDtl p ON p.ProcessID = d.ProcessID AND p.ProcessNo = d.ProcessNo AND 
													   p.FiscalYear = d.FiscalYear AND p.SerialNo = d.SerialNo  
		 LEFT JOIN srv.tblServiceTaskAtm2 a ON a.ProcessID = d.ProcessID AND a.ProcessNo = d.ProcessNo AND 
												a.FiscalYear = d.FiscalYear AND a.SerialNo = d.SerialNo AND a.DocRowNo = d.DocRowNo 
		 LEFT JOIN srv.tblServiceTaskAtm1 a2 ON a2.ProcessID = d.ProcessID AND a2.ProcessNo = d.ProcessNo AND
												a2.FiscalYear = d.FiscalYear AND a2.SerialNo = d.SerialNo AND a2.DocRowNo = d.DocRowNo
		 LEFT JOIN srv.tblServiceRequestHdr r ON r.ProcessID = a2.ProcessID AND r.ProcessNo = a2.ProcessNo AND 
												 r.FiscalYear = a2.RequestFiscalYear AND r.SerialNo = a2.RequestCode
		 LEFT JOIN srv.tblServiceRequestDtl rd ON rd.ProcessID = r.ProcessID AND rd.ProcessNo = r.ProcessNo AND 
												  rd.FiscalYear = r.FiscalYear AND rd.SerialNo = r.SerialNo
		WHERE ' +  @StrWhere + ' '
		
		Print @StrSelect2
		
		SET @StrSelect3 = '
		UNION 
		SELECT  t.ID ID,t.OperatorName,t.DocDate DocDate,0 ProcessID,0 ProcessID, cast(SUBSTRING(DocDate,1,4)AS INT)as FiscalYear ,0 SerialNo,
		0 RowNo,0 DocRowNo,'''' TaskDtlDesc,1 Priority,'''' AgreeDate,'''' AgreeTime, t.GoodsID, [pub].[funGetGoodsName](t.GoodsID,' + LTrim(RTrim(@LangID)) + ') GoodsName, S.UnitID, U.UnitName,
		0 TaskStatus,0 Duration,0 ConfirmStatus,'''' ConfirmDate,'''' ConfirmTime,'''' DoneDate, 1 as IsAsap,'''' ConfirmPersonelID,
		0 ProcessID,0 ProcessID, cast(SUBSTRING(DocDate,1,4)AS INT) as FiscalYear,0 SerialNo,1 RowNo,1 DocRowNo,
		1 DocAtomRowNo,t.DocDate EventDate,'''' ExitTime,0 EventStatus,t.Duration Duration, t.StartTime StartTime,t.FinishTime EndTime,'''' EnterTime,t.ResultDesc PerformDesc,
		t.ServiceID ServicID,1 Qty,'''' FaultID,t.PersonnelID PersonelID,'''' ChangeSet,'''' FaultDesc,0 ProcessID,
		cast(SUBSTRING(DocDate,1,4)AS INT)as FiscalYear ,0 SerialNo,1 RowNo,1 DocRowNo,1 AtomRowNo,1 DocAtomRowNo,
		0 RequestCode,0 RequestRow,0 RequestFiscalYear,t.CompanyID CompanyID,
		t.PersonnelID PersonnelID,acc.funGetAcntName(t.CompanyID,'+ LTRIM(STR(@AcntPart)) + ',' + LTRIM(str(@LangID)) + ')  AcntName,
		prs.funGetPersonnelName(t.PersonnelID,' + LTRIM(str(@LangID))+ ')  PersonelName,
		acc.funGetServiceNameFull(t.ServiceID,' + LTRIM(str(@LangID)) + ') ServiceName,'''' FaultName,0 IsAsap
		
		FROM srv.tblTelService t
		LEFT JOIN inv.tblGoods S ON S.GoodsID=SUBSTRING(t.GoodsID,' + ltrim(rtrim(STR(@str_Goods+1))) + ',' + ltrim(rtrim(STR( @str_GoodsSum))) + ') AND S.PartNumber=' + ltrim(rtrim(STR(@UnitPart)))+ '
		LEFT JOIN inv.tblUnitsDtl U ON U.UnitID = S.UnitID AND U.LanguageID = ' + LTRIM(str(@LangID)) + '

		WHERE ' + @StrWhere2 --+ ' order by DocDate,ID '
		
		Print @StrSelect3
		
	 END
	 
	 IF @IsTelService='False'
	 BEGIN
			SET @StrWhere2 = '
			SELECT  DISTINCT 
                  0 AS ID, h.DocDate, d.ProcessID, d.ProcessNo, d.FiscalYear, d.SerialNo, d.RowNo, d.DocRowNo, d.TaskDtlDesc, d.Priority, d.AgreeDate, d.AgreeTime,
				  '''' As GoodsID, '''' As GoodsName, '''' As UnitID, '''' As UnitName, d.TaskStatus, 
                  d.Duration, d.ConfirmStatus, d.ConfirmDate, d.ConfirmTime, d.DoneDate, d.IsAsap, d.ConfirmPersonelID, a.ProcessID AS EXPR1, a.ProcessNo AS EXPR2, 
                  a.FiscalYear AS EXPR3, a.SerialNo AS EXPR4, a.DocRowNo AS EXPR5, a.AtomRowNo, a.DocAtomRowNo, a.EventDate, a.ExitTime, a.EventStatus, 
                  a.Duration AS EXPR6, a.StartTime, a.EndTime, a.EnterTime, a.PerformDesc, a.ServiceID, a.Qty, a.FaultID, a.PersonelID, a.ChangeSet, a.FaultDesc, 
                  a2.ProcessID AS EXPR7, a2.ProcessNo AS EXPR8, a2.FiscalYear AS EXPR9, a2.SerialNo AS EXPR10, a2.DocRowNo AS EXPR11, a2.AtomRowNo AS EXPR12, 
                  a2.DocAtomRowNo AS EXPR13, a2.RequestCode, a2.RequestRow, a2.RequestFiscalYear, r.CompanyID,
                  p.PersonnelID
			 acc.funGetAcntName(r.CompanyID,'+ ltrim(STR(@AcntPart)) +','+ LTRIM(str(@LangID)) +')AS  AcntName,
			 prs.funGetPersonnelName(p.PersonnelID,1)as PersonelName,
			 acc.funGetServiceNameFull(a.ServiceID,'+ LTRIM(str(@LangID)) +')AS ServiceName,
			 acc.funGetServiceFaultName(a.FaultID,'+ LTRIM(str(@LangID)) +') AS FaultName,
			 d.IsAsap AS EXPR14
			 FROM srv.tblServiceTaskDtl  d
			 LEFT JOIN srv.tblServiceTaskHdr h ON d.ProcessID=h.ProcessID AND d.ProcessNo=h.ProcessNo AND 
												  d.FiscalYear=h.FiscalYear AND d.SerialNo=h.SerialNo
			 LEFT JOIN srv.tblServiceTaskPersonnelDtl p ON p.ProcessID = d.ProcessID AND p.ProcessNo = d.ProcessNo AND 
														   p.FiscalYear = d.FiscalYear AND p.SerialNo = d.SerialNo 
			 LEFT JOIN srv.tblServiceTaskAtm2 a ON a.ProcessID = d.ProcessID AND a.ProcessNo = d.ProcessNo AND 
													a.FiscalYear = d.FiscalYear AND a.SerialNo = d.SerialNo AND a.DocRowNo = d.DocRowNo 
			 LEFT JOIN srv.tblServiceTaskAtm1 a2 ON a2.ProcessID = d.ProcessID AND a2.ProcessNo = d.ProcessNo AND 
													a2.FiscalYear = d.FiscalYear AND a2.SerialNo = d.SerialNo AND a2.DocRowNo = d.DocRowNo 
			 LEFT JOIN srv.tblServiceRequestHdr r ON r.ProcessID = a2.ProcessID AND r.ProcessNo = a2.ProcessNo AND 
													 r.FiscalYear = a2.RequestFiscalYear AND r.SerialNo = a2.RequestCode
			 LEFT JOIN srv.tblServiceRequestDtl rd on rd.ProcessID = r.ProcessID AND rd.ProcessNo = r.ProcessNo AND 
													  rd.FiscalYear = r.FiscalYear AND rd.SerialNo = r.SerialNo
			 WHERE ' +  @StrWhere 
		 
		 END
	 
-- ================ SELECT ===========================
	BEGIN TRY
		DROP TABLE  ##tblServiceTaskDtl
	END TRY
	BEGIN CATCH
	END CATCH
	
	SET @StrSelect = 'SELECT RoW_Number()OVER (PARTITION BY CompanyID order by CompanyID,EventDate desc,SerialNo desc,
					        DocRowNo desc) RowNumber, * INTO ##tblServiceTaskDtl from ( ' + @StrSelect2 + ' ' + @StrSelect3 + ') a'

	-- Exeute --------------------------
	--PRINT @StrSelect;
	EXEC sp_executesql @StrSelect;

	Select  *, sal.funGetCustomerKindName(CustomerKindID,@LangID) as CustomerKindName,
			(SELECT VisitPathName 
			 FROM acc.tblVisitPathDtl
			 WHERE VisitPathID= A.VisitPathID3 AND PartNumber = 3  ) as VisitPathName3,
			(SELECT  CampaignName FROM         acc.tblCampaignDtl WHERE     (CampaignID = A.CampaignID)) as CampaignName
		
	 FROM (Select * From ##tblServiceTaskDtl Where RowNumber=1
	)S
	inner join   acc.tblAcnt A
	ON A.AcntCode = S.CompanyID

	INNER JOIN acc.tblAcntDtl D ON D.AcntCode = A.AcntCode AND D.PartNumber = A.PartNumber 

--	--=========================================================================================
END
GO
