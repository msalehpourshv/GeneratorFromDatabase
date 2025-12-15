USE TS_ShirinVatanKarkhaneh_1_1404
GO
SET ANSI_NULLS, QUOTED_IDENTIFIER ON
GO
-- =========== TS-QC:UPDATED ====================
-- Author		 : TakroSystem\Jafari
-- Creation date : 1394/10/07
-- Viewed By	 : 
-- Last Modified : 
-- Last Modifier : TakroSystem\jafari
-- Description	 : پرداخت  عیدی پرسنل
-- ==============================================
Create PROCEDURE prs.spCelebrationPays
	@ExtraParams		NVarChar(Max) = '',
	@RepOptions			VarChar(20) = '111',
	@RepInfo			NVarChar(100) = '1@1@1'
WITH ENCRYPTION
AS 
begin

	DECLARE @StrSelect		NVarChar(Max);
	
	DECLARE	@ProcessID		INT 
	DECLARE	@MonthCode		INT 
	DECLARE	@BankTypeID  	Varchar(20)
	DECLARE	@RemainDate  	char(10)
	
	SET @ProcessID			    = LTrim(pub.funSplitString(@ExtraParams, '@', 1)); 
	SET @MonthCode			    = LTrim(pub.funSplitString(@ExtraParams, '@', 2)); 
	SET @BankTypeID			    = LTrim(pub.funSplitString(@ExtraParams, '@', 3)); 
	SET @RemainDate			    = LTrim(pub.funSplitString(@ExtraParams, '@', 4)); 
	
	-- ==============================================
SELECT D.PersonnelID,[prs].[funGetAccountNo](D.PersonnelID) AS AccountNo
		,[prs].[funGetBankCartNo](D.PersonnelID) AS BankCartNo,
		[prs].[funGetShabaAccountNumber](D.PersonnelID,[prs].[funGetAccountNo](D.PersonnelID)) ShabaAccountNumber,
		prs.funGetPersonnelName(D.PersonnelID,1) AS PersonnelName,  
		Cost ,PersonnelID AcntSalary,PersonnelID DepartmentID,PersonnelID AcntCelebration
into #CelebrationPays
FROM prs.tblCelebrationDtl D
WHERE 1=0

set @StrSelect =''

if @BankTypeID<>''
	set @StrSelect =' INNER JOIN (SELECT * from prs.tblPersonnelAccountsDtl where  BankTypeID = ''' + @BankTypeID + ''' )  c ON c.PersonnelID = D.PersonnelID'

	SET @StrSelect = ' insert into #CelebrationPays	
			SELECT D.PersonnelID,[prs].[funGetAccountNoWithBankType](D.PersonnelID,'''+@BankTypeID+''') AS AccountNo
			,[prs].[funGetBankCartNo](D.PersonnelID) AS BankCartNo,
			[prs].[funGetShabaAccountNumber](D.PersonnelID,[prs].[funGetAccountNo](D.PersonnelID)) ShabaAccountNumber,
			prs.funGetPersonnelName(D.PersonnelID,1) AS PersonnelName,  
			0 Cost 
			,D.PersonnelID AcntSalary
			,D.PersonnelID DepartmentID
			,D.PersonnelID AcntCelebration
			FROM prs.tblPersonnels D
			'+ @StrSelect +'
			Where QuitJobDate='''' or QuitJobDate>='''+@RemainDate+'''
			group by D.PersonnelID 
	'
	PRINT @StrSelect;
	EXEC sp_executesql @StrSelect;
					
update #CelebrationPays 
	set DepartmentID=isnull((SELECT top 1  DepartmentID  FROM prs.tblDecreeHdr h WHERE PersonnelID = #CelebrationPays.PersonnelID ORDER BY SerialNo Desc ),'')
		, AcntSalary=isnull((SELECT top 1  AcntSalary  FROM prs.tblDecreeHdr h WHERE PersonnelID = #CelebrationPays.PersonnelID ORDER BY SerialNo Desc ),'')

delete  from #CelebrationPays where DepartmentID=''
delete  from #CelebrationPays where AcntSalary=''
		
if @ProcessID=320			
	update #CelebrationPays 
		set AcntCelebration=isnull((SELECT AcntCelebrationPayable FROM prs.tblDepartments WHERE DepartmentID= #CelebrationPays.DepartmentID ),'')
else
	update #CelebrationPays 
		set AcntCelebration=isnull((SELECT AcntHistoryCalcDaysPayable FROM prs.tblDepartments WHERE DepartmentID= #CelebrationPays.DepartmentID ),'')

delete  from #CelebrationPays where AcntCelebration=''

update #CelebrationPays 
	set AcntCelebration=pub.funMergCode(AcntCelebration,AcntSalary)

update #CelebrationPays 
	set Cost= (select isnull(SUM(Credit-Debit),0)   from acc.tblVoucherDtl b where  #CelebrationPays.AcntCelebration=b.AcntCode and b.DocDate<=@RemainDate)
 
select  * from #CelebrationPays
where Cost>0 and PersonnelID in (select PersonnelID from prs.tblPersonnels where CodeClosed=0)
order by PersonnelID

END
GO
