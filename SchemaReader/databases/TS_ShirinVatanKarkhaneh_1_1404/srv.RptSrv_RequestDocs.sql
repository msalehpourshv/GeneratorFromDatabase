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
Create PROCEDURE [srv].[RptSrv_RequestDocs]
	@ProcessID			Int = 0,
	@ProcessNo			Int = 1,
	@FiscalYearFr		Int = NULL,
	@SerialNoFr			Int = NULL,
	@FiscalYearTo		Int = NULL,
	@SerialNoTo			Int = NULL,
	@DocDateFr			Char(10) = NULL,
	@DocDateTo			Char(10) = NULL,
	@SelectedKinds		Int = 0,
	@SelectedPrsns		Int = 0,
	@SelectedSrvc1		Int = 0,
	@SelectedSrvc2		Int = 0,
	@SelectedSrvc3		Int = 0,
	@SelectedSrvc4		Int = 0,
	@SelectedComp1		Int = 0,
	@SelectedComp2		Int = 0,
	@SelectedComp3		Int = 0,
	@SelectedComp4		Int = 0,
	@ConfirmStatus		Int = Null,
	@Priority			Int = Null,
	@RequestDesc		NVARCHAR(200)= Null,
	@CompanyID			VarChar(20) = Null,
	@ContractNo			int = Null,
	@ContractDate		char(10) = Null,
	@PhonerNameMask		NVarChar(50) = Null,
	@SortFields			NVarChar(100) = Null,
	@RepOptions			NVarChar(100) = '1111111@1@1', 
	@RepInfo			NVarChar(100) = '1@1@1'
WITH ENCRYPTION
AS 
---- Declarations ---------------
Declare @StrSelect	NVarChar(max);
Declare @StrFrom	NVarChar(max);
Declare @StrWhere	NVarChar(max);
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
DECLARE	@DoneDateFr	varChar(10); 
DECLARE	@DoneDateTo	varChar(10); 
DECLARE @AcntPart	tinyint;
DECLARE @DocStep	tinyint;
DECLARE @ConfirmY	bit;
DECLARE @ConfirmN	bit;
DECLARE @NotCheck	bit;
DECLARE @HasTaskY	bit;
DECLARE @HasTaskN	bit;
DECLARE @ReqStatus char(1);
DECLARE @SprintID varchar(20);
DECLARE @Serials  varchar(50);
DECLARE @PhonerName  Nvarchar(50);

Begin --============== S T A R T  C O D E ===================================================

	SET NOCOUNT ON;

	-- Init -------------------------------------------------
	IF (@RepInfo Is Null)			SET @RepInfo = '1@1@1'
	IF (@ProcessNo Is Null)			SET @ProcessNo = 1;
	IF (@RepOptions Is Null)		SET @RepOptions = '1111111@1@1';
	
	IF (@SortFields Is Null)		SET @SortFields = 'H.DocDate,H.SerialNo,D.DocRowNo';
	

	IF (@SelectedKinds Is Null)		SET @SelectedKinds = 0;
	IF (@SelectedPrsns Is Null)		SET @SelectedPrsns = 0
	IF (@SelectedComp1 Is Null)		SET @SelectedComp1 = 0;
	IF (@SelectedComp2 Is Null)		SET @SelectedComp2 = 0;
	IF (@SelectedComp3 Is Null)		SET @SelectedComp3 = 0;
	IF (@SelectedComp4 Is Null)		SET @SelectedComp4 = 0;

	IF (@FiscalYearFr Is Null)		SET @SerialNoFr = Null;
	IF (@FiscalYearTo Is Null)		SET @SerialNoTo = Null;
	IF (@SerialNoFr	Is Null)		SET @FiscalYearFr = Null;
	IF (@SerialNoTo	Is Null)		SET @FiscalYearTo = Null;

	SET @LangID		= pub.funSplitString(@RepInfo, '@', 1);
	SET @SessionNo	= pub.funSplitString(@RepInfo, '@', 2);
	SET @ReportID	= pub.funSplitString(@RepInfo, '@', 3);

	SET @SprintID	= pub.funSplitString(@RepOptions, '@', 2);
	SET @Serials	= pub.funSplitString(@RepOptions, '@', 3);

	SET @DocStep	= Substring(@RepOptions, 1, 1);
	SET @AcntPart	= Substring(@RepOptions, 2, 1);
	SET @ConfirmY	= Substring(@RepOptions, 3, 1);
	SET @ConfirmN	= Substring(@RepOptions, 4, 1);
	SET @HasTaskY	= Substring(@RepOptions, 5, 1);
	SET @HasTaskN	= Substring(@RepOptions, 6, 1);
	SET @ReqStatus	= Substring(@RepOptions, 7, 1);

	SET @UserID		= pub.funSplitString(@RepInfo, '@', 4);
	SET @IsAdmin	= pub.funSplitString(@RepInfo, '@', 5);
	SET @ServiceKindAdmin = pub.funSplitString(@RepOptions, '@', 4);
	SET	@Service1Admin	= pub.funSplitString(@RepOptions, '@', 5);
	SET	@Service2Admin	= pub.funSplitString(@RepOptions, '@', 6);
	SET	@Service3Admin	= pub.funSplitString(@RepOptions, '@', 7);
	SET	@Service4Admin	= pub.funSplitString(@RepOptions, '@', 8);
	SET	@Service1Len	= pub.funSplitString(@RepOptions, '@', 9);
	SET	@Service2Len	= pub.funSplitString(@RepOptions, '@', 10);
	SET	@Service3Len	= pub.funSplitString(@RepOptions, '@', 11);
	SET	@Service4Len	= pub.funSplitString(@RepOptions, '@', 12);
	SET	@NotCheck		= pub.funSplitString(@RepOptions, '@', 13);
	SET	@PhonerName		= pub.funSplitString(@RepOptions, '@', 14);
	SET	@DoneDateFr		= pub.funSplitString(@RepOptions, '@', 15);
	SET	@DoneDateTo		= pub.funSplitString(@RepOptions, '@', 16);
	---------------------------------------------------------

	-- Where Clause -----------------------------------------
	Set @StrWhere = '(1=1)'

	if (@DocStep <> 9)
		Set @StrWhere = @StrWhere + ' AND (D.DocStep = ' + LTRIM(Str(@DocStep)) + ')'
		
	if (@ConfirmY = 1 And @ConfirmN = 0 And @NotCheck = 0)
		Set @StrWhere = @StrWhere + ' AND (D.Confirm = 1)'
		
	if (@ConfirmY = 1 And @ConfirmN = 1 And @NotCheck = 0)
		Set @StrWhere = @StrWhere + ' AND (D.Confirm <> 2)'
		
	if (@ConfirmY = 1 And @ConfirmN = 0 And @NotCheck = 1)
		Set @StrWhere = @StrWhere + ' AND (D.Confirm <> 0)'		
		
	if (@ConfirmY = 0 And @ConfirmN = 1 And @NotCheck = 1)
		Set @StrWhere = @StrWhere + ' AND (D.Confirm <> 1)'
			
	if (@ConfirmY = 0 And @ConfirmN = 1 And @NotCheck = 0)
		Set @StrWhere = @StrWhere + ' AND (D.Confirm = 0)'
				
	if (@ConfirmY = 0 And @ConfirmN = 0 And @NotCheck = 1)
		Set @StrWhere = @StrWhere + ' AND (D.Confirm = 2)'	
					
	if (@HasTaskY = 0)
		Set @StrWhere = @StrWhere + ' AND (D.TaskRegister <> 1)'
	if (@HasTaskN = 0)
		Set @StrWhere = @StrWhere + ' AND (D.TaskRegister <> 0)'

	IF (@ReqStatus = '0' and @ReqStatus Is Not Null and @ReqStatus <>'')
		Set @StrWhere = @StrWhere + ' AND (D.TaskStatus = ' + rtrim(LTrim(@ReqStatus)) + ' AND D.TaskRegister=0)'

	IF (@ReqStatus = '5' and @ReqStatus Is Not Null and @ReqStatus <>'')
		Set @StrWhere = @StrWhere + ' AND (D.TaskStatus =0  AND D.TaskRegister=1)'

	IF (@ReqStatus <> '4' and @ReqStatus <> '5' and @ReqStatus <> '0' and @ReqStatus Is Not Null and @ReqStatus <>'')
		Set @StrWhere = @StrWhere + ' AND (D.TaskStatus = ' + rtrim(LTrim(@ReqStatus)) + ')'

	if (@ConfirmStatus Is Not Null)
		Set @StrWhere = @StrWhere + ' AND (D.ConfirmStatus = ' + LTrim(Str(@ConfirmStatus)) + ')'
	
	if (@Priority Is Not Null)
		Set @StrWhere = @StrWhere + ' AND (D.Priority = ' + LTrim(Str(@Priority)) + ')'
	
	if (@RequestDesc Is Not Null)
		Set @StrWhere = @StrWhere + ' AND (D.RequestDesc LIKE  N''%' + @RequestDesc + '%'')'
		
	if (@CompanyID Is Not Null)
		Set @StrWhere = @StrWhere + ' AND (H.CompanyID = ''' + @CompanyID + ''')'
			
	if (@ContractNo Is Not Null)
		Set @StrWhere = @StrWhere + ' AND (D.ContractNo = ' + LTrim(Str(@ContractNo)) + ')'
	if (@ContractDate Is Not Null)
		Set @StrWhere = @StrWhere + ' AND (D.ContractDate = ''' + @ContractDate + ''')'

	IF (@SerialNoFr Is Not Null)
		SET @StrWhere = @StrWhere + ' AND (D.FiscalYear > ' + LTrim(Str(@FiscalYearFr)) + ' OR (D.FiscalYear = ' + LTrim(Str(@FiscalYearFr)) + ' AND D.SerialNo >= ' + LTrim(Str(@SerialNoFr)) + '))' 
	IF (@SerialNoTo Is Not Null)
		SET @StrWhere = @StrWhere + ' AND (D.FiscalYear < ' + LTrim(Str(@FiscalYearTo)) + ' OR (D.FiscalYear = ' + LTrim(Str(@FiscalYearTo)) + ' AND D.SerialNo <= ' + LTrim(Str(@SerialNoTo)) + '))' 

	IF (@DocDateFr Is Not Null)
		SET @StrWhere = @StrWhere + ' AND (H.DocDate >= ''' + @DocDateFr + ''')'
	IF @DocDateTo Is Not Null
		SET @StrWhere = @StrWhere + ' AND (H.DocDate <= ''' + @DocDateTo + ''')'

	IF (@DoneDateFr Is Not Null) AND @DoneDateFr <> ''
		SET @StrWhere = @StrWhere + ' AND (D.DoneDate >= ''' + @DoneDateFr + ''')'
	IF @DoneDateTo Is Not Null AND @DoneDateTo <> ''
		SET @StrWhere = @StrWhere + ' AND (D.DoneDate <= ''' + @DoneDateTo + ''')'

	if (@PhonerName Is Not Null) AND @PhonerName <> ''
		Set @StrWhere = @StrWhere + ' AND (H.PhonerName LIKE  N''%' + @PhonerName + '%'')'

	IF (@SelectedKinds > 0)
		SET @StrWhere = @StrWhere + ' AND ' + pub.funGetFilterString(@SessionNo, @ReportID, @SelectedKinds, 'D.ServiceKindID') 
	IF (@SelectedPrsns > 0)
		SET @StrWhere = @StrWhere + ' AND ' + pub.funGetFilterString(@SessionNo, @ReportID, @SelectedPrsns, 'H.PersonnelID') 

	IF (@SelectedComp1 > 0)
		SET @StrWhere = @StrWhere + ' AND ' + pub.funGetFilterString(@SessionNo, @ReportID, @SelectedComp1, 'H.CompanyID')
	IF (@SelectedComp2 > 0)
		SET @StrWhere = @StrWhere + ' AND ' + pub.funGetFilterString(@SessionNo, @ReportID, @SelectedComp2, 'H.CompanyID')
	IF (@SelectedComp3 > 0)
		SET @StrWhere = @StrWhere + ' AND ' + pub.funGetFilterString(@SessionNo, @ReportID, @SelectedComp3, 'H.CompanyID')
	IF (@SelectedComp4 > 0)
		SET @StrWhere = @StrWhere + ' AND ' + pub.funGetFilterString(@SessionNo, @ReportID, @SelectedComp4, 'H.CompanyID')

	IF (@SelectedSrvc1 > 0)
		SET @StrWhere = @StrWhere + ' AND ' + pub.funGetFilterString(@SessionNo, @ReportID, @SelectedSrvc1, 'D.ServiceID')
	IF (@SelectedSrvc2 > 0)
		SET @StrWhere = @StrWhere + ' AND ' + pub.funGetFilterString(@SessionNo, @ReportID, @SelectedSrvc2, 'D.ServiceID')
	IF (@SelectedSrvc3 > 0)
		SET @StrWhere = @StrWhere + ' AND ' + pub.funGetFilterString(@SessionNo, @ReportID, @SelectedSrvc3, 'D.ServiceID')
	IF (@SelectedSrvc4 > 0)
		SET @StrWhere = @StrWhere + ' AND ' + pub.funGetFilterString(@SessionNo, @ReportID, @SelectedSrvc4, 'D.ServiceID')
	
	
	IF (@SprintID Is Not Null and @SprintID<>'-')
		SET @StrWhere = @StrWhere + ' AND (th.SprintID = ''' + @SprintID + ''')'

	IF (@Serials Is Not Null and @Serials<>'-')
		SET @StrWhere = @StrWhere + ' AND (H.SerialNo in ( ' + @Serials + ') )'
	
    If @IsAdmin = 0 And @ServiceKindAdmin = 0 
        SET @StrWhere = @StrWhere + ' AND [srv].[funServiceKindPermitted] (' + LTrim(RTrim(str(@UserID))) + ',D.ServiceKindID)=1 ' 
            
    If @IsAdmin = 0 And @Service1Admin = 0 AND @Service1Len>0
        SET @StrWhere = @StrWhere + ' AND [acc].[funServiceCodingPermitted]  (' + LTrim(RTrim(str(@UserID))) + ',SUBSTRING(D.ServiceID,1,' +  LTrim(RTrim(str(@Service1Len)))  +'),1)=1 ' 
    If @IsAdmin = 0  And @Service2Admin = 0 AND @Service2Len>0
        SET @StrWhere = @StrWhere + ' AND [acc].[funServiceCodingPermitted]  (' + LTrim(RTrim(str(@UserID))) + ',SUBSTRING(D.ServiceID,'+ LTrim(RTrim(str(@Service1Len)))  +'+2,' +  LTrim(RTrim(str(@Service2Len)))  +'),2)=1 ' 
            
    If @IsAdmin = 0  And @Service3Admin = 0 AND @Service3Len>0
        SET @StrWhere = @StrWhere + ' AND [acc].[funServiceCodingPermitted]  (' + LTrim(RTrim(str(@UserID))) + ',SUBSTRING(D.ServiceID,'+ LTrim(RTrim(str(@Service1Len+@Service2Len)))  +'+3,' +  LTrim(RTrim(str(@Service3Len)))  +'),3)=1 ' 
            
    If @IsAdmin = 0  And @Service4Admin = 0 AND @Service4Len>0
        SET @StrWhere = @StrWhere + ' AND [acc].[funServiceCodingPermitted]  (' + LTrim(RTrim(str(@UserID))) + ',SUBSTRING(D.ServiceID,'+ LTrim(RTrim(str(@Service1Len+@Service2Len+@Service3Len)))  +'+4,' +  LTrim(RTrim(str(@Service4Len)))  +'),4)=1 ' 
	---------------------------------------------------------

	-- FROM Clause ------------------------------------------
	Set @StrFrom = ' '
	---------------------------------------------------------

	-- SELECT Clause ----------------------------------------
	Set @StrSelect = '
	SELECT	th.SprintID,D.*, H.DocDate, H.PersonnelID, H.CompanyID, H.PhonerName, H.ContactDate, H.ContactTime, H.PhonerName,
			AH.InitialGrad,A.AcntName CompanyName, P.FirstName + '' '' + P.LastName PersonnelName,A.Address1,A.Address2,
			acc.funGetServiceNameFull(D.ServiceID, ' + @LangID + ') ServiceName, K.ServiceKindName,AH.Tel,AH.Fax,AH.Mobile,
			 isnull(aa.SerialNo,0) AS  TaskSerialNo,isnull(aa.DocRowNo,0) AS TaskRowNo,A.FirstName,A.LastName,
			 isnull(aa.FiscalYear,0) AS TaskFiscalYear
			 ,prs.funGetPersonnelName(SP.PersonnelID,1) as PersonnelName2
			  ,isnull((SELECT TOP 1 PerformDesc FROM srv.tblServiceTaskAtm2 a2 
					   WHERE aa.FiscalYear=a2.FiscalYear	
					   AND aa.SerialNo=a2.SerialNo and 	aa.DocRowNo	=a2.DocRowNo 
					   ORDER BY EventDate  Desc,EndTime Desc ,AtomRowNo Desc  ),'''')PerformDesc
	FROM  srv.tblServiceRequestDtl D
			INNER JOIN srv.tblServiceRequestHdr H ON H.ProcessID = D.ProcessID AND H.ProcessNo = D.ProcessNo AND H.FiscalYear = D.FiscalYear AND H.SerialNo = D.SerialNo
			left JOIN prs.tblPersonnelsDtl P on P.PersonnelID = H.PersonnelID
			left JOIN srv.tblServiceKindDtl K on K.ServiceKindID = D.ServiceKindID
			left JOIN acc.tblAcntDtl A on A.AcntCode = H.CompanyID and A.PartNumber = ' + LTrim(Str(@AcntPart)) + '
			left JOIN srv.tblServiceTaskAtm1 aa
			ON aa.RequestCode=D.SerialNo and aa.RequestRow=D.DocRowNo
			AND aa.RequestFiscalYear=D.FiscalYear
			left join srv.tblServiceTaskHdr th
			on th.SerialNo=aa.SerialNo and th.FiscalYear=aa.FiscalYear
			left join srv.tblServiceTaskPersonnelDtl SP
			on th.SerialNo=SP.SerialNo and th.FiscalYear=SP.FiscalYear
			LEFT JOIN acc.tblAcnt AH on  AH.AcntCode = H.CompanyID
			
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
