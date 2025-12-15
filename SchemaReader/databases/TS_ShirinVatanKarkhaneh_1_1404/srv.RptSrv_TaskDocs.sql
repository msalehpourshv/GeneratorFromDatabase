USE TS_ShirinVatanKarkhaneh_1_1404
GO
SET ANSI_NULLS, QUOTED_IDENTIFIER ON
GO
-- =========== TS-QC:UPDATED ====================
-- Author		 : TakroSystem\Zia
-- Creation Date : 1391/09/25
-- Viewed By	 : 
-- Last Modified : 
-- Last Modifier : TakroSystem\Zia
-- Description	 : 
-- ==============================================
create  PROCEDURE [srv].[RptSrv_TaskDocs]
	@ProcessID			Int = 0,
	@ProcessNo			Int = 1,
	@FiscalYearFr		Int = NULL,
	@SerialNoFr			Int = NULL,
	@FiscalYearTo		Int = NULL,
	@SerialNoTo			Int = NULL,
	@DocDateFr			Char(10) = NULL,
	@DocDateTo			Char(10) = NULL,
	@SelectedAdmns		int = 0,
	@SelectedKinds		Int = 0,
	@SelectedPrsns		int = 0,
	@SelectedSrvc1		Int = 0,
	@SelectedSrvc2		Int = 0,
	@SelectedSrvc3		Int = 0,
	@SelectedSrvc4		Int = 0,
	@SelectedComp1		Int = 0,
	@SelectedComp2		Int = 0,
	@SelectedComp3		Int = 0,
	@SelectedComp4		Int = 0,
	@ConfirmStatus		int = null,
	@TaskStatus			int = null,
	@Priority			int = null,
	@TaskDtlDesc		NVARCHAR(200),
	@CompanyID			VarChar(20) = null,
	@SortFields			NVarChar(100) = Null,
	@RepOptions			NVarChar(100) = '111', 
	@RepInfo			NVarChar(100) = '1@1@1'
WITH ENCRYPTION
AS 
---- Declarations ---------------
Declare @StrSelect	NVarChar(max);
Declare @StrFrom	NVarChar(max);
Declare @StrWhere	NVarChar(max);
Declare @StrWhereX	NVarChar(max);
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
DECLARE	@LangID		Char(1);
DECLARE	@SessionNo	Int;
DECLARE	@ReportID	Int;
DECLARE	@SprintID	varchar(20);

--DECLARE @ConfirmY	bit;
--DECLARE @ConfirmN	bit;
Begin --============== S T A R T  C O D E ===================================================

	SET NOCOUNT ON;

	-- Init -------------------------------------------------
	IF (@RepInfo Is Null)			SET @RepInfo = '1@1@1'
	IF (@ProcessNo Is Null)			SET @ProcessNo = 1;
	IF (@RepOptions Is Null)		SET @RepOptions = '111';
	IF (@SortFields Is Null)		SET @SortFields = 'D.FiscalYear,D.SerialNo, D.DocRowNo';
	
	IF (@SelectedKinds Is Null)		SET @SelectedKinds = 0;
	IF (@SelectedAdmns Is Null)		SET @SelectedAdmns = 0
	IF (@SelectedPrsns Is Null)		SET @SelectedPrsns = 0
	IF (@SelectedComp1 Is Null)		SET @SelectedComp1 = 0;
	IF (@SelectedComp2 Is Null)		SET @SelectedComp2 = 0;
	IF (@SelectedComp3 Is Null)		SET @SelectedComp3 = 0;
	IF (@SelectedComp4 Is Null)		SET @SelectedComp4 = 0;
	IF (@SelectedSrvc1 Is Null)		SET @SelectedSrvc1 = 0;
	IF (@SelectedSrvc2 Is Null)		SET @SelectedSrvc2 = 0;
	IF (@SelectedSrvc3 Is Null)		SET @SelectedSrvc3 = 0;
	IF (@SelectedSrvc4 Is Null)		SET @SelectedSrvc4 = 0;

	IF (@FiscalYearFr Is Null)		SET @SerialNoFr = Null;
	IF (@FiscalYearTo Is Null)		SET @SerialNoTo = Null;
	IF (@SerialNoFr	Is Null)		SET @FiscalYearFr = Null;
	IF (@SerialNoTo	Is Null)		SET @FiscalYearTo = Null;

	SET @LangID		= pub.funSplitString(@RepInfo, '@', 1);
	SET @SessionNo	= pub.funSplitString(@RepInfo, '@', 2);
	SET @ReportID	= pub.funSplitString(@RepInfo, '@', 3);
	SET @UserID		= pub.funSplitString(@RepInfo, '@', 4);
	SET @IsAdmin	= pub.funSplitString(@RepInfo, '@', 5);	
	
	SET @SprintID	= pub.funSplitString(@RepOptions, '@', 1);
		SET @ServiceKindAdmin = pub.funSplitString(@RepOptions, '@', 2);
	SET	@Service1Admin	= pub.funSplitString(@RepOptions, '@', 3);
	SET	@Service2Admin	= pub.funSplitString(@RepOptions, '@', 4);
	SET	@Service3Admin	= pub.funSplitString(@RepOptions, '@', 5);
	SET	@Service4Admin	= pub.funSplitString(@RepOptions, '@', 6);
	SET	@Service1Len	= pub.funSplitString(@RepOptions, '@', 7);
	SET	@Service2Len	= pub.funSplitString(@RepOptions, '@', 8);
	SET	@Service3Len	= pub.funSplitString(@RepOptions, '@', 9);
	SET	@Service4Len	= pub.funSplitString(@RepOptions, '@', 10);

	--SET @ConfirmY	= Substring(@RepOptions, 2, 1);
	--SET @ConfirmN	= Substring(@RepOptions, 3, 1);
	---------------------------------------------------------

	-- Where Clause -----------------------------------------
	Set @StrWhere = '(1=1)'

	--if (@ConfirmY = 0)
	--	Set @StrWhere = @StrWhere + ' AND (D.Confirm <> 1)'
	--if (@ConfirmN = 0)
	--	Set @StrWhere = @StrWhere + ' AND (D.Confirm <> 0)'

	if (@Priority is not null)
		Set @StrWhere = @StrWhere + ' AND (D.Priority = ' + LTrim(Str(@Priority)) + ')'
			
	if (@TaskDtlDesc is not null)
		Set @StrWhere = @StrWhere + ' AND (D.TaskDtlDesc LIKE  N''%' + @TaskDtlDesc + '%'')'
				
	if (@TaskStatus is not null)
		Set @StrWhere = @StrWhere + ' AND (D.TaskStatus = ' + LTrim(Str(@TaskStatus)) + ')'
		
	if (@ConfirmStatus is not null)
		Set @StrWhere = @StrWhere + ' AND (D.ConfirmStatus = ' + LTrim(Str(@ConfirmStatus)) + ')'
		
	IF (@SerialNoFr Is Not Null)
		SET @StrWhere = @StrWhere + ' AND (D.FiscalYear > ' + LTrim(Str(@FiscalYearFr)) + ' OR (D.FiscalYear = ' + LTrim(Str(@FiscalYearFr)) + ' AND D.SerialNo >= ' + LTrim(Str(@SerialNoFr)) + '))' 
	IF (@SerialNoTo Is Not Null)
		SET @StrWhere = @StrWhere + ' AND (D.FiscalYear < ' + LTrim(Str(@FiscalYearTo)) + ' OR (D.FiscalYear = ' + LTrim(Str(@FiscalYearTo)) + ' AND D.SerialNo <= ' + LTrim(Str(@SerialNoTo)) + '))' 

	IF (@DocDateFr Is Not Null)
		SET @StrWhere = @StrWhere + ' AND (H.DocDate >= ''' + @DocDateFr + ''')'
	IF @DocDateTo Is Not Null
		SET @StrWhere = @StrWhere + ' AND (H.DocDate <= ''' + @DocDateTo + ''')'

	IF (@SelectedAdmns > 0)
		SET @StrWhere = @StrWhere + ' AND ' + pub.funGetFilterString(@SessionNo, @ReportID, @SelectedAdmns, 'H.AdminCode') 
		
	IF (@SprintID Is Not Null and @SprintID <>'')
		SET @StrWhere = @StrWhere + ' AND (H.SprintID = ''' + @SprintID + ''')'

    If @IsAdmin = 0 And @ServiceKindAdmin = 0 
        SET @StrWhere = @StrWhere + ' AND [srv].[funServiceKindPermitted] (' + LTrim(RTrim(str(@UserID))) + ',r.ServiceKindID)=1 ' 
            
    If @IsAdmin = 0 And @Service1Admin = 0 AND @Service1Len>0
        SET @StrWhere = @StrWhere + ' AND [acc].[funServiceCodingPermitted]  (' + LTrim(RTrim(str(@UserID))) + ',SUBSTRING(r.ServiceID,1,' +  LTrim(RTrim(str(@Service1Len)))  +'),1)=1 ' 
    If @IsAdmin = 0  And @Service2Admin = 0 AND @Service2Len>0
        SET @StrWhere = @StrWhere + ' AND [acc].[funServiceCodingPermitted]  (' + LTrim(RTrim(str(@UserID))) + ',SUBSTRING(r.ServiceID,'+ LTrim(RTrim(str(@Service1Len)))  +'+2,' +  LTrim(RTrim(str(@Service2Len)))  +'),2)=1 ' 
            
    If @IsAdmin = 0  And @Service3Admin = 0 AND @Service3Len>0
        SET @StrWhere = @StrWhere + ' AND [acc].[funServiceCodingPermitted]  (' + LTrim(RTrim(str(@UserID))) + ',SUBSTRING(r.ServiceID,'+ LTrim(RTrim(str(@Service1Len+@Service2Len)))  +'+3,' +  LTrim(RTrim(str(@Service3Len)))  +'),3)=1 ' 
            
    If @IsAdmin = 0  And @Service4Admin = 0 AND @Service4Len>0
        SET @StrWhere = @StrWhere + ' AND [acc].[funServiceCodingPermitted]  (' + LTrim(RTrim(str(@UserID))) + ',SUBSTRING(r.ServiceID,'+ LTrim(RTrim(str(@Service1Len+@Service2Len+@Service3Len)))  +'+4,' +  LTrim(RTrim(str(@Service4Len)))  +'),4)=1 ' 
	------------------------------------------------------------------------
	IF (@SelectedPrsns > 0)
	begin
		SET @StrWhereX = pub.funGetFilterString(@SessionNo, @ReportID, @SelectedPrsns, 'X.PersonnelID') 
		SET @StrWhere = @StrWhere + ' AND 
		(
			select COUNT(*)
			from srv.tblServiceTaskPersonnelDtl X
			where (X.ProcessID=H.ProcessID) 
				and (X.ProcessNo=H.ProcessNo) 
				and (X.FiscalYear=H.FiscalYear) 
				and (X.SerialNo=H.SerialNo) 
				and ' + @StrWhereX + '
		) > 0 '
	end		
	------------------------------------------------------------------------
	Set @StrWhereX = ''
	
	if (@CompanyID is not null)
		Set @StrWhereX = @StrWhereX + ' AND (H1.CompanyID = ''' + @CompanyID + ''')'

	IF (@SelectedComp1 > 0)
		SET @StrWhereX = @StrWhereX + ' AND ' + pub.funGetFilterString(@SessionNo, @ReportID, @SelectedComp1, 'H1.CompanyID')
	IF (@SelectedComp2 > 0)
		SET @StrWhereX = @StrWhereX + ' AND ' + pub.funGetFilterString(@SessionNo, @ReportID, @SelectedComp2, 'H1.CompanyID')
	IF (@SelectedComp3 > 0)
		SET @StrWhereX = @StrWhereX + ' AND ' + pub.funGetFilterString(@SessionNo, @ReportID, @SelectedComp3, 'H1.CompanyID')
	IF (@SelectedComp4 > 0)
		SET @StrWhereX = @StrWhereX + ' AND ' + pub.funGetFilterString(@SessionNo, @ReportID, @SelectedComp4, 'H1.CompanyID')
	IF (@SelectedKinds > 0)
		SET @StrWhereX = @StrWhereX + ' AND ' + pub.funGetFilterString(@SessionNo, @ReportID, @SelectedKinds, 'D1.ServiceKindID') 

	if (@StrWhereX <> '')
	begin
		SET @StrWhere = @StrWhere + ' AND 
		(
			select COUNT(*)
			from srv.tblServiceRequestHdr H1 
				inner join srv.tblServiceRequestDtl D1 on D1.ProcessID=H1.ProcessID and D1.ProcessNo=H1.ProcessNo and D1.FiscalYear=H1.FiscalYear and D1.SerialNo=H1.SerialNo 
				inner join srv.tblServiceTaskAtm1   A1 on A1.RequestCode = D1.SerialNo and A1.RequestRow = D1.DocRowNo
			where (A1.ProcessID=D.ProcessID) 
				and (A1.ProcessNo=D.ProcessNo) 
				and (A1.FiscalYear=D.FiscalYear) 
				and (A1.SerialNo=D.SerialNo) 
				and (A1.DocRowNo=D.DocRowNo) 
				' + @StrWhereX + '
		) > 0'
	end
	---------------------------------------------------------
	Set @StrWhereX = ''
	
	IF (@SelectedSrvc1 > 0)
		SET @StrWhereX = @StrWhereX + ' AND ' + pub.funGetFilterString(@SessionNo, @ReportID, @SelectedSrvc1, 'D1.ServiceID')
	IF (@SelectedSrvc2 > 0)
		SET @StrWhereX = @StrWhereX + ' AND ' + pub.funGetFilterString(@SessionNo, @ReportID, @SelectedSrvc2, 'D1.ServiceID')
	IF (@SelectedSrvc3 > 0)
		SET @StrWhereX = @StrWhereX + ' AND ' + pub.funGetFilterString(@SessionNo, @ReportID, @SelectedSrvc3, 'D1.ServiceID')
	IF (@SelectedSrvc4 > 0)
		SET @StrWhereX = @StrWhereX + ' AND ' + pub.funGetFilterString(@SessionNo, @ReportID, @SelectedSrvc4, 'D1.ServiceID')
		
	if (@StrWhereX <> '')
	begin
		SET @StrWhere = @StrWhere + ' AND 
		(
			select COUNT(*)
			from srv.tblServiceRequestDtl D1
					inner join srv.tblServiceTaskAtm1 A1 on A1.RequestCode = D1.SerialNo and A1.RequestRow = D1.DocRowNo
			where (A1.ProcessID=D.ProcessID) 
				and (A1.ProcessNo=D.ProcessNo) 
				and (A1.FiscalYear=D.FiscalYear) 
				and (A1.SerialNo=D.SerialNo) 
				and (A1.DocRowNo=D.DocRowNo) 
				' + @StrWhereX + '
		) > 0'
	end
	------------------------------------------------------------------------

	-- FROM Clause ------------------------------------------
	Set @StrFrom = ' '
	---------------------------------------------------------
	
	-- SELECT Clause ----------------------------------------
	Set @StrSelect = '
	SELECT	D.*, H.DocDate, H.AdminCode, H.RegDate, H.RegTime, TP.PersonnelID,
			P1.FirstName + '' '' + P1.LastName AdminName,
			P2.FirstName + '' '' + P2.LastName PersonnelName,
			r.SerialNo as RequestSerialNo,r.DocRowNo as RequestDocRowNo,r.FiscalYear as RequestFiscalYear,
		prs.funGetPersonnelName(rh.PersonnelID,'+  rtrim(ltrim(STR(@LangID))) +') AS RequestPersonellName,
			rh.DocDate AS RequestDocDate
		
FROM  srv.tblServiceTaskDtl D
			INNER JOIN srv.tblServiceTaskHdr H ON H.ProcessID = D.ProcessID AND H.ProcessNo = D.ProcessNo AND H.FiscalYear = D.FiscalYear AND H.SerialNo = D.SerialNo
			left JOIN srv.tblServiceTaskPersonnelDtl TP on TP.ProcessID = H.ProcessID AND TP.ProcessNo = H.ProcessNo AND TP.FiscalYear = H.FiscalYear AND TP.SerialNo = H.SerialNo
			left JOIN prs.tblPersonnelsDtl P1 on P1.PersonnelID = H.AdminCode
			left JOIN prs.tblPersonnelsDtl P2 on P2.PersonnelID = TP.PersonnelID
					
			left JOIN  srv.tblServiceTaskAtm1 a
			ON a.FiscalYear=D.FiscalYear AND a.SerialNo=D.SerialNo AND
			a.DocRowNo=D.DocRowNo
			left JOIN srv.tblServiceRequestDtl r
			ON a.RequestCode=r.SerialNo AND a.RequestRow=r.DocRowNo
			AND a.RequestFiscalYear=r.FiscalYear
			left JOIN srv.tblServiceRequestHdr rh
			ON r.ProcessID=rh.ProcessID AND r.ProcessNo=rh.ProcessNo AND 
			r.FiscalYear=rh.FiscalYear AND r.SerialNo=rh.SerialNo
			
			
	WHERE ' + @StrWhere
	------------------------------------------------------------

	-- SORT Clause ---------------------------------------------
	If (@SortFields Is Not Null)
		Set @StrSelect = @StrSelect + ' 
	ORDER BY ' + @SortFields
	------------------------------------------------------------

	-- RUN -----------------------------------------------------
	Print @StrSelect;
	Exec sp_executesql @StrSelect;
	------------------------------------------------------------
End
GO
