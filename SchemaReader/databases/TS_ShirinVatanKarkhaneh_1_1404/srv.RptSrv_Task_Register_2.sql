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
create PROCEDURE [srv].[RptSrv_Task_Register_2] 
	
	@PerssonelID		VarChar(20)=null,
	@FromDate			CHAR(10)='1394/03/26',
	@ToDate				CHAR(10)='1394/03/26',
	@CompanyID			VarChar(20)=null,
	@ReqStatus			INT=null,
	@AcntPart			INT =2,
	@ServiceType		VARCHAR(20)=null,
	@FiscalYearReqFr	Int = 92,
	@SerialNoReqFr		Int = 1,
	@FiscalYearReqTo	Int = 94,
	@SerialNoReqTo		Int = 1000,
	@ServiceID1			VARCHAR(20)=null,
	@ServiceID2			VARCHAR(20)=null,
	@ServiceLen1		tinyint=2,
	@ServiceLen2		tinyint=2,
	@ChangeSet			NVarChar(100)=null,
	@RepOptions			NVarChar(100) = '1@1@1'
	 

WITH ENCRYPTION
AS

DECLARE @StrSelect		NVarChar(MAX);
DECLARE @StrWhere		NVarChar(2000);
DECLARE @StrWhere1		NVarChar(2000);
DECLARE @StrWhere2		NVarChar(2000);
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
declare @db_0000	nvarchar(50);

BEGIN 
	-- ============================ S T A R T =====================================================
set @StrSelect='';
	-- Init --------------------------
	SET NOCOUNT ON;
	
	set @db_0000 = Substring(db_name(), 1, Len(db_name()) - 4) + '0000'
	
	

	IF (@RepOptions Is Null)		SET @RepOptions = '1111111@1@1';

--
	SET @UserID		= pub.funSplitString(@RepOptions, '@', 1);
	SET @IsAdmin	= pub.funSplitString(@RepOptions, '@', 2);
	SET @ServiceKindAdmin = pub.funSplitString(@RepOptions, '@', 3);
	SET	@Service1Admin	= pub.funSplitString(@RepOptions, '@', 4);
	SET	@Service2Admin	= pub.funSplitString(@RepOptions, '@', 5);
	SET	@Service3Admin	= pub.funSplitString(@RepOptions, '@', 6);
	SET	@Service4Admin	= pub.funSplitString(@RepOptions, '@', 7);
	SET	@Service1Len	= pub.funSplitString(@RepOptions, '@', 8);
	SET	@Service2Len	= pub.funSplitString(@RepOptions, '@', 9);
	SET	@Service3Len	= pub.funSplitString(@RepOptions, '@', 10);
	SET	@Service4Len	= pub.funSplitString(@RepOptions, '@', 11);

	set @StrWhere = ' 1=1 '	
	set @StrWhere1= ' 1=1 '
	set @StrWhere2= ' 1=1 '
	
	 IF (@PerssonelID IS NOT null)
	 	SET @StrWhere = @StrWhere + ' AND  
	( SELECT  count(*) from  srv.tblServiceTaskAtm1 a
		inner join srv.tblServiceTaskPersonnelDtl tp
		on tp.ProcessID=a.ProcessID and tp.ProcessNo=a.ProcessNo
		and tp.FiscalYear=a.FiscalYear and tp.SerialNo=a.SerialNo
	where  a.RequestFiscalYear=rd.FiscalYear AND
		a.RequestCode=rd.SerialNo AND a.RequestRow=rd.DocRowNo
	AND PersonnelID='''+@PerssonelID+''')>0'
	
	 IF (@PerssonelID IS NOT null)
	 	SET @StrWhere1 = @StrWhere1 + ' AND tp.PersonnelID=''' + @PerssonelID + ''''
	 
	 IF (@PerssonelID IS NOT null)
	 	SET @StrWhere2 = @StrWhere2 + ' AND a2.PersonelID=''' + @PerssonelID + ''''
	 		
	 		
	IF (@CompanyID IS NOT null)
		SET @StrWhere = @StrWhere + ' AND r.CompanyID=''' + @CompanyID + '''' 
			
	IF (@SerialNoReqFr Is Not Null)
		SET @StrWhere = @StrWhere + ' AND (rd.FiscalYear > ' + LTrim(Str(@FiscalYearReqFr)) + ' OR (rd.FiscalYear = ' + LTrim(Str(@FiscalYearReqFr)) + ' AND rd.SerialNo >= ' + LTrim(Str(@SerialNoReqFr)) + '))' 
	
	IF (@SerialNoReqTo Is Not Null)
		SET @StrWhere = @StrWhere + ' AND (rd.FiscalYear < ' + LTrim(Str(@FiscalYearReqTo)) + ' OR (rd.FiscalYear = ' + LTrim(Str(@FiscalYearReqTo)) + ' AND rd.SerialNo <= ' + LTrim(Str(@SerialNoReqTo)) + '))' 
		
	 If @ServiceID1  Is Not Null  
         SET @StrWhere = @StrWhere + ' AND substring(rd.ServiceID,1,'+ ltrim(STR(@ServiceLen1)) +')='''+@ServiceID1+''''
       
	If @ServiceID2  Is Not Null  
         SET @StrWhere = @StrWhere + ' AND substring(rd.ServiceID,'+ltrim(STR(@ServiceLen1+2))+','+ ltrim(STR(@ServiceLen2)) +')='''+@ServiceID2+''''
	
	 IF (@FromDate IS NOT null)
	 	SET @StrWhere = @StrWhere + ' AND  
	( SELECT   count(*) from  srv.tblServiceTaskAtm1 a
		inner join srv.tblServiceTaskAtm2 a2
		on a2.ProcessID=a.ProcessID and a2.ProcessNo=a.ProcessNo
		and a2.FiscalYear=a.FiscalYear and a2.SerialNo=a.SerialNo
		and a2.DocRowNo=a.DocRowNo
		where  a.RequestFiscalYear=rd.FiscalYear AND
		a.RequestCode=rd.SerialNo AND a.RequestRow=rd.DocRowNo
	 AND EventDate >='''+@FromDate+''')>0'

 IF (@FromDate IS NOT null)
	 	SET @StrWhere1 = @StrWhere1 + ' AND th.DocDate >='''+ @FromDate + ''''
  
  IF (@FromDate IS NOT null)
	 	SET @StrWhere2 = @StrWhere2 + ' AND a2.EventDate >='''+ @FromDate + ''''
	 	
	 	
 IF (@ToDate IS NOT null)
	 	SET @StrWhere = @StrWhere + ' AND  
	( SELECT   count(*) from  srv.tblServiceTaskAtm1 a
		inner join srv.tblServiceTaskAtm2 a2
		on a2.ProcessID=a.ProcessID and a2.ProcessNo=a.ProcessNo
		and a2.FiscalYear=a.FiscalYear and a2.SerialNo=a.SerialNo
		and a2.DocRowNo=a.DocRowNo
		where  a.RequestFiscalYear=rd.FiscalYear AND
		a.RequestCode=rd.SerialNo AND a.RequestRow=rd.DocRowNo
	AND EventDate <='''+@ToDate+''')>0'
		
 IF (@ToDate IS NOT null)
 	SET @StrWhere1 = @StrWhere1 + ' AND  th.DocDate <='''+ @ToDate + ''''

IF (@ToDate IS NOT null)
 	SET @StrWhere2 = @StrWhere2 + ' AND  a2.EventDate <='''+ @ToDate + '''' 	

IF (@ReqStatus IS NOT null)
		SET @StrWhere = @StrWhere + ' AND rd.TaskStatus =' + ltrim(str(@ReqStatus))  	
	
	 
    IF (@ChangeSet IS NOT null)
	 	SET @StrWhere = @StrWhere + ' AND  
	( SELECT count(*)  from  srv.tblServiceTaskAtm1 a
		inner join srv.tblServiceTaskAtm2 a2
		on a2.ProcessID=a.ProcessID and a2.ProcessNo=a.ProcessNo
		and a2.FiscalYear=a.FiscalYear and a2.SerialNo=a.SerialNo
		and a2.DocRowNo=a.DocRowNo
		where  a.RequestFiscalYear=rd.FiscalYear AND
		a.RequestCode=rd.SerialNo AND a.RequestRow=rd.DocRowNo
	AND ChangeSet LIKE  N''%'+@ChangeSet+'%'')>0'
					

	IF (@ServiceType IS NOT null)
			SET @StrWhere = @StrWhere + ' AND rd.ServiceKindID =''' + @ServiceType + '''' 		

     If @IsAdmin = 0 And @ServiceKindAdmin = 0 
        SET @StrWhere = @StrWhere + ' AND [srv].[funServiceKindPermitted] (' + LTrim(RTrim(str(@UserID))) + ',rd.ServiceKindID)=1 ' 
            
    If @IsAdmin = 0 And @Service1Admin = 0 AND @Service1Len>0
        SET @StrWhere = @StrWhere + ' AND [acc].[funServiceCodingPermitted]  (' + LTrim(RTrim(str(@UserID))) + ',SUBSTRING(rd.ServiceID,1,' +  LTrim(RTrim(str(@Service1Len)))  +'),1)=1 ' 
    If @IsAdmin = 0  And @Service2Admin = 0 AND @Service2Len>0
        SET @StrWhere = @StrWhere + ' AND [acc].[funServiceCodingPermitted]  (' + LTrim(RTrim(str(@UserID))) + ',SUBSTRING(rd.ServiceID,'+ LTrim(RTrim(str(@Service1Len)))  +'+2,' +  LTrim(RTrim(str(@Service2Len)))  +'),2)=1 ' 
            
    If @IsAdmin = 0  And @Service3Admin = 0 AND @Service3Len>0
        SET @StrWhere = @StrWhere + ' AND [acc].[funServiceCodingPermitted]  (' + LTrim(RTrim(str(@UserID))) + ',SUBSTRING(rd.ServiceID,'+ LTrim(RTrim(str(@Service1Len+@Service2Len)))  +'+3,' +  LTrim(RTrim(str(@Service3Len)))  +'),3)=1 ' 
            
    If @IsAdmin = 0  And @Service4Admin = 0 AND @Service4Len>0
        SET @StrWhere = @StrWhere + ' AND [acc].[funServiceCodingPermitted]  (' + LTrim(RTrim(str(@UserID))) + ',SUBSTRING(rd.ServiceID,'+ LTrim(RTrim(str(@Service1Len+@Service2Len+@Service3Len)))  +'+4,' +  LTrim(RTrim(str(@Service4Len)))  +'),4)=1 ' 
	-- ================ SELECT ===========================
		 			 
SET @StrSelect=' SELECT DISTINCT  rd.*, r.DocDate,r.CompanyID,
		acc.funGetAcntName(r.CompanyID,2,1)AS  AcntName, 
		acc.funGetServiceNameFull(rd.ServiceID,1)AS ServiceName,
		
	( SELECT count(*) from  srv.tblServiceTaskAtm1 a
		where  a.RequestFiscalYear=rd.FiscalYear AND
		a.RequestCode=rd.SerialNo AND a.RequestRow=rd.DocRowNo
	) TaskCount,
		
	( SELECT isnull(SUM(td.Duration),0) from  srv.tblServiceTaskAtm1 a
		inner join srv.tblServiceTaskDtl td
		on td.ProcessID=a.ProcessID and td.ProcessNo=a.ProcessNo
		and td.FiscalYear=a.FiscalYear and td.SerialNo=a.SerialNo
		and td.DocRowNo=a.DocRowNo
		INNER JOIN srv.tblServiceTaskHdr th
		ON td.ProcessID=th.ProcessID and td.ProcessNo=th.ProcessNo
		and td.FiscalYear=th.FiscalYear and td.SerialNo=th.SerialNo
		INNER JOIN srv.tblServiceTaskPersonnelDtl tp
		ON td.ProcessID=tp.ProcessID and td.ProcessNo=tp.ProcessNo
		and td.FiscalYear=tp.FiscalYear and td.SerialNo=tp.SerialNo
		WHERE  a.RequestFiscalYear=rd.FiscalYear AND
		a.RequestCode=rd.SerialNo AND a.RequestRow=rd.DocRowNo AND '+ @StrWhere1 + '
	) SumDuration,

	( SELECT isnull(SUM(a2.Duration),0) from  srv.tblServiceTaskAtm1 a
		inner join srv.tblServiceTaskAtm2 a2
		on a2.ProcessID=a.ProcessID and a2.ProcessNo=a.ProcessNo
		and a2.FiscalYear=a.FiscalYear and a2.SerialNo=a.SerialNo
		and a2.DocRowNo=a.DocRowNo
		where  a.RequestFiscalYear=rd.FiscalYear AND
		a.RequestCode=rd.SerialNo AND a.RequestRow=rd.DocRowNo AND ' + @StrWhere2 + '
	) SumDoingTime,

	( SELECT count(*) from  srv.tblServiceTaskAtm1 a
		inner join srv.tblServiceTaskAtm2 a2
		on a2.ProcessID=a.ProcessID and a2.ProcessNo=a.ProcessNo
		and a2.FiscalYear=a.FiscalYear and a2.SerialNo=a.SerialNo
		and a2.DocRowNo=a.DocRowNo
		where  a.RequestFiscalYear=rd.FiscalYear AND
		a.RequestCode=rd.SerialNo AND a.RequestRow=rd.DocRowNo
		and a2.FaultDesc<>''''
	) FaultCount

	FROM     srv.tblServiceRequestDtl rd

	inner JOIN srv.tblServiceRequestHdr r
	 ON r.ProcessID = rd.ProcessID AND r.ProcessNo = rd.ProcessNo
	 AND r.FiscalYear = rd.FiscalYear AND r.SerialNo = rd.SerialNo

	WHERE ' +  @StrWhere 
		 
		 
	 
-- ================ SELECT ===========================

	-- Exeute --------------------------
	PRINT @StrSelect;
	EXEC sp_executesql @StrSelect;

	--=========================================================================================
END
GO
