USE TS_ShirinVatanKarkhaneh_1_1404
GO
SET ANSI_NULLS, QUOTED_IDENTIFIER ON
GO
-- =========== TS-QC:UPDATED ====================
-- Author		 : TakroSystem
-- Creation date : 1401/01/09
-- Viewed By	 : 
-- Last Modified : 
-- Last Modifier : 
-- Description	 : خلاصه لیست اقساط وام پرسنل بهمراه اصل وام  
-- ==============================================
Create PROCEDURE [prs].[RptPrs_LoanInstalmentsExSummary]                         
	@PersIDFr		varchar(20) = null,
	@PersIDTo		varchar(20) = null,
	@DocDateFr		char(10) = null,
	@DocDateTo		char(10) = null,
	@MonthCodeFr	tinyint = null,
	@MonthCodeTo	tinyint = null,
	@OrigAmountFr	bigint = null,
	@OrigAmountTo	bigint = null,
	@InstAmountFr	bigint = null,
	@InstAmountTo	bigint = null,
	@LoanTypeID		varchar(20) = null,
	@RepOptions		VarChar(20) = '',
	@RepInfo		NVarChar(100) = '1@1@1'
WITH ENCRYPTION
AS 
DECLARE @StrSelect	NVarChar(MAX);
DECLARE @StrSelect1 NVarChar(MAX);
DECLARE @StrSelect2 NVarChar(MAX);
DECLARE @StrSelect3 NVarChar(MAX);
DECLARE @StrFrom	NVarChar(MAX);
DECLARE @StrWhere	NVarChar(MAX);
DECLARE @StrWhere2	NVarChar(MAX);

DECLARE	@LangID		Char(1);
DECLARE	@SessionNo	Int; 
DECLARE	@ReportID	Int; 
DECLARE	@SettlementedType	Int; 
DECLARE @SelectedPrs Int;
Begin 
	--============== S T A R T  C O D E =======================================

	SET NOCOUNT ON;

	---- Init ------------------------------------------
	IF (@RepInfo	Is Null)	SET @RepInfo = '1@1@1'

	SET @LangID		= pub.funSplitString(@RepInfo, '@', 1);
	SET @SessionNo	= pub.funSplitString(@RepInfo, '@', 2);
	SET @ReportID	= pub.funSplitString(@RepInfo, '@', 3);
	SET @SettlementedType	= pub.funSplitString(@RepInfo, '@', 6);
	IF (@PersIDFr	Is Null)	SET @SelectedPrs = 0
	else SET @SelectedPrs=Cast(@PersIDFr as int)
	----------------------------------------------------
	

	SET @StrWhere = '(1=1)'
	SET @StrWhere2 = '(1=1)'

	   IF (@SelectedPrs > 0)
		SET @StrWhere = @StrWhere + ' AND ' + pub.funGetFilterString(@SessionNo, @ReportID, @SelectedPrs, 'D.PersonnelID')

	
	IF (@InstAmountFr Is Not Null)
		SET	@StrWhere = @StrWhere + ' AND (D.ThisMonthInstallment >= ' + Str(LTrim(@InstAmountFr)) + ')'
	IF (@InstAmountTo Is Not Null)
		SET	@StrWhere = @StrWhere + ' AND (D.ThisMonthInstallment <= ' + Str(LTrim(@InstAmountTo)) + ')'
		
	IF (@LoanTypeID Is Not Null)
		SET	@StrWhere = @StrWhere + ' AND (D.LoanTypeID = ' + Str(LTrim(@LoanTypeID)) + ')'
		

	IF (@DocDateFr Is Not Null)                
		SET	@StrWhere = @StrWhere + ' AND (D.ReceiptDate >= ''' + LTrim(@DocDateFr) + ''')'
	IF (@DocDateTo Is Not Null)
		SET	@StrWhere = @StrWhere + ' AND (D.ReceiptDate <= ''' + LTrim(@DocDateTo) + ''')'

	IF (@OrigAmountFr Is Not Null)
		SET	@StrWhere = @StrWhere + ' AND (D.LoanAmount >= ' + Str(LTrim(@OrigAmountFr)) + ')'
	IF (@OrigAmountTo Is Not Null)
		SET	@StrWhere = @StrWhere + ' AND (D.LoanAmount <= ' + Str(LTrim(@OrigAmountTo)) + ')'

	
	IF (@SettlementedType =2)
		SET	@StrWhere2 = @StrWhere2 + ' AND (Settlemented = 0 And SumRemain>0)'	
	
	IF (@SettlementedType =3)
		SET	@StrWhere2 = @StrWhere2 + ' AND (Settlemented = 1 or SumRemain<=0)'	

	 Declare @OldDbName1 Varchar(50)
	 Declare @OldDbName2 Varchar(50)
	 Declare @OldDbName3 Varchar(50)
	 Declare @OldTask NVarChar(Max)

	 set @OldDbName1=substring (DB_NAME(),1,len(DB_NAME())-4)+ltrim(str(RIGHT(DB_NAME(),4) -1)) 
	 set @OldDbName2=substring (DB_NAME(),1,len(DB_NAME())-4)+ltrim(str(RIGHT(DB_NAME(),4) -2)) 
	 set @OldDbName3=substring (DB_NAME(),1,len(DB_NAME())-4)+ltrim(str(RIGHT(DB_NAME(),4) -3)) 
	 set @OldTask=''
	
	set @StrSelect1=''
	set @StrSelect2=''
	set @StrSelect3=''
	--if (select Count(*) from sys.databases where name =@OldDbName1)>0
	--	set @StrSelect1=' 	
	--			SELECT    D.ID, D.PersonnelID, D.LoanTypeID,  D.OriginLoanAmount LoanAmount 
	--				,SUM(isnull(D2.ThisMonthInstallment,0))  AS SumPay, case when D.DebitFromLoan=0 then D.LoanAmount -  SUM(ISNULL(D2.ThisMonthInstallment ,0)) else D.DebitFromLoan-  SUM(ISNULL(D2.ThisMonthInstallment ,0)) end AS SumRemain
	--				,ceiling   ( D.DebitFromLoan/D.InstallmentAmount )InstallmentCount ,COUNT(D2.ThisMonthInstallment) as PaidInstallmentCount,ceiling   ( D.DebitFromLoan/D.InstallmentAmount )-COUNT(D2.ThisMonthInstallment) as RemainInstallmentCount
	--				, D.FiscalYear,D.SerialNo
	--			FROM        '+ @OldDbName1 +'.prs.tblLoanInstallmentsDtl AS D 
	--			Left JOIN    '+ @OldDbName1 +'.prs.tblInstallmentDeductionsDtl AS D2 ON D.PersonnelID = D2.PersonnelID AND D.LoanTypeID = D2.LoanTypeID  AND D.FiscalYear = D2.FiscalYear and D.SerialNo = D2.SerialNo
	--			where	' + @StrWhere + '			 	
	--			GROUP BY D.PersonnelID, D.LoanTypeID, D.OriginLoanAmount ,D.LoanAmount,D.ID,D.DebitFromLoan, D.InstallmentAmount, D.FiscalYear,D.SerialNo
	--					'
	--if (select Count(*) from sys.databases where name =@OldDbName2)>0
	--	set @StrSelect2=' 	
	--			SELECT    D.ID, D.PersonnelID, D.LoanTypeID,D.OriginLoanAmount LoanAmount
	--				,SUM(isnull(D2.ThisMonthInstallment,0))  AS SumPay, case when D.DebitFromLoan=0 then D.LoanAmount -  SUM(ISNULL(D2.ThisMonthInstallment ,0)) else D.DebitFromLoan-  SUM(ISNULL(D2.ThisMonthInstallment ,0)) end AS SumRemain
	--				, ceiling   ( D.DebitFromLoan/D.InstallmentAmount ) InstallmentCount ,COUNT(D2.ThisMonthInstallment) as PaidInstallmentCount,ceiling   ( D.DebitFromLoan/D.InstallmentAmount )-COUNT(D2.ThisMonthInstallment) as RemainInstallmentCount
	--				, D.FiscalYear,D.SerialNo
	--			FROM        '+ @OldDbName2 +'.prs.tblLoanInstallmentsDtl AS D 
	--			Left JOIN   '+ @OldDbName2 +'.prs.tblInstallmentDeductionsDtl AS D2 ON D.PersonnelID = D2.PersonnelID AND D.LoanTypeID = D2.LoanTypeID  AND D.FiscalYear = D2.FiscalYear and D.SerialNo = D2.SerialNo	
	--			where	' + @StrWhere + '			 	
	--			GROUP BY D.PersonnelID, D.LoanTypeID, D.OriginLoanAmount ,D.LoanAmount,D.ID,D.DebitFromLoan, D.InstallmentAmount, D.FiscalYear,D.SerialNo
	--					'
	--if (select Count(*) from sys.databases where name =@OldDbName3)>0
	--	set @StrSelect3=' 	
	--			SELECT    D.ID, D.PersonnelID, D.LoanTypeID, D.OriginLoanAmount LoanAmount
	--				,SUM(isnull(D2.ThisMonthInstallment,0))  AS SumPay, case when D.DebitFromLoan=0 then D.LoanAmount -  SUM(ISNULL(D2.ThisMonthInstallment ,0)) else D.DebitFromLoan-  SUM(ISNULL(D2.ThisMonthInstallment ,0)) end AS SumRemain
	--				,ceiling   ( D.DebitFromLoan/D.InstallmentAmount ) InstallmentCount ,COUNT(D2.ThisMonthInstallment) as PaidInstallmentCount,ceiling   ( D.DebitFromLoan/D.InstallmentAmount )-COUNT(D2.ThisMonthInstallment) as RemainInstallmentCount
	--				, D.FiscalYear,D.SerialNo
	--			FROM        '+ @OldDbName3 +'.prs.tblLoanInstallmentsDtl AS D 
	--			Left JOIN   '+ @OldDbName3 +'.prs.tblInstallmentDeductionsDtl AS D2 ON D.PersonnelID = D2.PersonnelID AND D.LoanTypeID = D2.LoanTypeID  AND D.FiscalYear = D2.FiscalYear and D.SerialNo = D2.SerialNo
	--			where	' + @StrWhere + '			 	
	--			GROUP BY D.PersonnelID, D.LoanTypeID, D.OriginLoanAmount,D.LoanAmount ,D.ID,D.DebitFromLoan,D.InstallmentAmount, D.FiscalYear,D.SerialNo
	--				'
	SET @StrSelect = '
			SELECT    D.ID, D.PersonnelID, D.LoanTypeID,  D.DebitFromLoan  LoanAmount
				,SUM(isnull(D2.ThisMonthInstallment,0))  AS SumPay, D.DebitFromLoan-  SUM(ISNULL(D2.ThisMonthInstallment ,0)) AS SumRemain
				,ceiling   ( D.DebitFromLoan/D.InstallmentAmount ) InstallmentCount ,COUNT(D2.ThisMonthInstallment) as PaidInstallmentCount,ceiling   ( D.DebitFromLoan/D.InstallmentAmount )-COUNT(D2.ThisMonthInstallment) as RemainInstallmentCount
				, D.FiscalYear,D.SerialNo,D.ReceiptDate,D.Settlemented, D.InstallmentAmount
			FROM    (select ID,PersonnelID,LoanTypeID,OriginLoanAmount,FiscalYear,SerialNo ,ReceiptDate,Settlemented,InstallmentAmount,  Case when DebitFromLoan >0 then DebitFromLoan  else LoanAmount end DebitFromLoan from   prs.tblLoanInstallmentsDtl ) AS D 
			Left JOIN  prs.tblInstallmentDeductionsDtl AS D2 ON D.PersonnelID = D2.PersonnelID AND D.LoanTypeID = D2.LoanTypeID AND D.FiscalYear = D2.FiscalYear and D.SerialNo = D2.SerialNo 	 and D.ReceiptDate = D2.ReceiptDate 		
			where	' + @StrWhere + '			 	
			GROUP BY D.PersonnelID, D.LoanTypeID, D.OriginLoanAmount ,D.ID,D.DebitFromLoan, D.InstallmentAmount,D.FiscalYear,D.SerialNo,D.ReceiptDate,D.Settlemented						
					'
	if @StrSelect1<>''
			SET @StrSelect += '	Union  all 	 '+@StrSelect1
	if @StrSelect2<>''
			SET @StrSelect += '	Union  all 	 '+@StrSelect2
	if @StrSelect3<>''
			SET @StrSelect += '	Union  all 	 '+@StrSelect3

	SET @StrSelect = 'select * from (
	select 0 ID,A.PersonnelID,A.LoanAmount,Sum(SumPay) SumPay,A.LoanAmount-Sum(SumPay) SumRemain
	,InstallmentCount,sum(PaidInstallmentCount) PaidInstallmentCount,InstallmentCount-sum(PaidInstallmentCount) RemainInstallmentCount
	,FiscalYear	,SerialNo	,PD.FirstName + '' '' + PD.LastName PersonnelName, LD.LoanTypeName ,Settlemented,InstallmentAmount
	 from (
	'+ @StrSelect +'
	) A
	left join prs.tblPersonnelsDtl PD ON PD.PersonnelID = A.PersonnelID 
	left join prs.tblLoanTypesDtl  LD ON LD.LoanTypeID = A.LoanTypeID	
	where	' + @StrWhere2 + '				
	Group by A.PersonnelID,A.LoanAmount	,InstallmentCount,InstallmentAmount,FiscalYear	,SerialNo	,PD.FirstName , PD.LastName , LD.LoanTypeName,Settlemented
	) A
	order by A.PersonnelID, FiscalYear	,SerialNo'
	
	Print @StrSelect;
	EXEC sp_executesql @StrSelect;
	
End
GO
