USE TS_ShirinVatanKarkhaneh_1_1404
GO
SET ANSI_NULLS, QUOTED_IDENTIFIER ON
GO
-- =========== TS-QC:UPDATED ====================
-- Author		 : TakroSystem\Reza
-- Create date   : 1393/09/02
-- Viewed By	 : 
-- Last Modified :  
-- Last Modifier : 
-- Description	 : 
-- ==============================================
create PROCEDURE [srv].[Sp_srvRequestOrder]-- 93,3662

	@ServiceKindID		Varchar(20) = '0101',
	@DocDateFr			Char(10) = Null,
	@DocDateTo			Char(10) = Null,
	@PartNumber			tinyint = 2,
	@LangID				tinyint = 1,
	@Finish				tinyint = 1,
	@NotDone			tinyint = 2,
	@PersonnelID		Varchar(20) = Null,
	@CompanyID			Varchar(20) = Null,
	@Priority			tinyint = Null,
	@Importance			tinyint = Null,
	@ServicePartLen1	tinyint = 4,
	@ServicePartLen2	tinyint = 4,
	@ServiceID1			Varchar(20) = Null,
	@ServiceID2			Varchar(20) = Null,
	@TaskRegister		bit=0,
	@IsContract			bit=0,
	@CurrentDate		char(10)='1399/11/11',
	@UserID				Int=1,
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

	
WITH ENCRYPTION
AS 

---- Declarations ---------------

Declare @StrSelect	NVarChar(4000);
Declare @StrWhere	NVarChar(4000);



Begin -- ============== S T A R T  C O D E ====================================

	SET NOCOUNT ON;

	-- Init Variables -------------------------------------
 
	
	 Set @StrWhere =' AND 1=1 '
	-- Where Clause -----------------------------------------
	
	if @TaskRegister=0
		Set @StrWhere =@StrWhere + ' AND d.TaskRegister=' + ltrim(str(@TaskRegister) )

 
	IF (@DocDateFr Is Not Null)
		SET @StrWhere = @StrWhere + ' AND h.DocDate >= ''' + LTrim(RTrim(@DocDateFr)) + '''' 

	IF (@DocDateTo Is Not Null)
		SET @StrWhere = @StrWhere + ' AND h.DocDate <= ''' + LTrim(RTrim(@DocDateTo)) + ''''
			
	IF @ServiceKindID Is NOT NULL		
		SET @StrWhere = @StrWhere + ' AND d.ServiceKindID LIKE ''' + LTrim(RTrim(@ServiceKindID)) + '%'''
	
	IF @CompanyID Is NOT NULL		
		SET @StrWhere = @StrWhere + ' AND h.CompanyID = ''' + LTrim(RTrim(@CompanyID)) + ''''
	
	IF @PersonnelID Is NOT NULL		
		SET @StrWhere = @StrWhere + ' AND h.PersonnelID = ''' + LTrim(RTrim(@PersonnelID)) + ''''

	IF @ServiceID1 Is NOT NULL		
		SET @StrWhere = @StrWhere + ' AND substring(d.ServiceID,1,'+ ltrim(STR(@ServicePartLen1)) +') = ''' + LTrim(RTrim(@ServiceID1)) + ''''

	IF @ServiceID2 Is NOT NULL		
		SET @StrWhere = @StrWhere + ' AND substring(d.ServiceID,'+ ltrim(STR(@ServicePartLen1+2))+','+ltrim(STR(@ServicePartLen2))+') = ''' + @ServiceID2 + ''''
	
	IF @Priority Is NOT NULL		
		SET @StrWhere = @StrWhere + ' AND d.Priority = ' + LTrim(RTrim(str(@Priority))) 

	IF @Importance Is NOT NULL		
		SET @StrWhere = @StrWhere + ' AND d.Importance = ' + LTrim(RTrim(str(@Importance))) 


	IF @IsContract =1	
		SET @StrWhere = @StrWhere + ' AND( 
		select COUNT(*) from acc.tblContratctsHdr c
		where  pub.funSplitString(CustomerAcntCode,'' '',2)=h.CompanyID
		and c.EndDate>='''+ @CurrentDate +''')>0'   




        If @IsAdmin = 0 And @ServiceKindAdmin = 0 
            SET @StrWhere = @StrWhere + ' AND [srv].[funServiceKindPermitted] (' + LTrim(RTrim(str(@UserID))) + ',d.ServiceKindID)=1 ' 
            
        If @IsAdmin = 0 And @Service1Admin = 0 AND @Service1Len>0
            SET @StrWhere = @StrWhere + ' AND [acc].[funServiceCodingPermitted]  (' + LTrim(RTrim(str(@UserID))) + ',SUBSTRING(d.ServiceID,1,' +  LTrim(RTrim(str(@Service1Len)))  +'),1)=1 ' 

        If @IsAdmin = 0  And @Service2Admin = 0 AND @Service2Len>0
            SET @StrWhere = @StrWhere + ' AND [acc].[funServiceCodingPermitted]  (' + LTrim(RTrim(str(@UserID))) + ',SUBSTRING(d.ServiceID,'+ LTrim(RTrim(str(@Service1Len)))  +'+2,' +  LTrim(RTrim(str(@Service2Len)))  +'),2)=1 ' 
            
        If @IsAdmin = 0  And @Service3Admin = 0 AND @Service3Len>0
            SET @StrWhere = @StrWhere + ' AND [acc].[funServiceCodingPermitted]  (' + LTrim(RTrim(str(@UserID))) + ',SUBSTRING(d.ServiceID,'+ LTrim(RTrim(str(@Service1Len+@Service2Len)))  +'+3,' +  LTrim(RTrim(str(@Service3Len)))  +'),3)=1 ' 
            
        If @IsAdmin = 0  And @Service4Admin = 0 AND @Service4Len>0
            SET @StrWhere = @StrWhere + ' AND [acc].[funServiceCodingPermitted]  (' + LTrim(RTrim(str(@UserID))) + ',SUBSTRING(d.ServiceID,'+ LTrim(RTrim(str(@Service1Len+@Service2Len+@Service3Len)))  +'+4,' +  LTrim(RTrim(str(@Service4Len)))  +'),4)=1 ' 



	-- Select Clause -------------------------------------------
	

SET @StrSelect = '
	 SELECT h.*,d.*,A.InitialGrad,acc.funGetAcntName(h.CompanyID,'+ LTrim(STR(@PartNumber))+','+ LTrim(str(@LangID))+')AS CompanyName,
	 prs.funGetPersonnelName(h.PersonnelID, '+LTrim(str(@LangID)) +')AS PersonellName, 
	 acc.[funGetServiceNameFull2](d.ServiceID,'+ LTrim(str(@LangID))+') ServiceName 
	FROM srv.tblServiceRequestDtl d  
	 INNER JOIN srv.tblServiceRequestHdr  h
	 ON h.ProcessID = d.ProcessID AND h.ProcessNo = d.ProcessNo  
	 AND h.FiscalYear = d.FiscalYear AND h.SerialNo = d.SerialNo 
	 inner join acc.tblAcnt A on h.CompanyID=A.AcntCode  
	 WHERE  d.Priority <> 0 AND Confirm=1  
	 AND NOT TaskStatus in ('+ LTrim(str(@Finish))+','+ LTrim(STR(@NotDone))+')
	 '+ @StrWhere + '
	ORDER BY d.Priority desc,d.Importance desc,d.PriorityNo,d.ReqImportance desc
	,d.Value2 desc,A.InitialGrad desc  '

				 
	------------------------------------------------------------
	-- Run -----------------------------------------------------
	Print @StrSelect;
	Exec sp_executesql @StrSelect;
	------------------------------------------------------------
End
GO
