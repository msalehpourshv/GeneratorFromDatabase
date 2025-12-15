USE TS_ShirinVatanKarkhaneh_1_1404
GO
SET ANSI_NULLS, QUOTED_IDENTIFIER ON
GO
-- =========== TS-QC:UPDATED ====================
-- Author		 : TakroSystem\Zia
-- Creation date : 1390/09/12
-- Viewed By	 : 
-- Last Modified : 1390/09/12
-- Last Modifier : TakroSystem\Zia
-- Description	 : لیست اقساط وام پرسنل بهمراه اصل وام
-- ==============================================
Create PROCEDURE [prs].[RptPrs_LoanInstalmentsEx] 
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
DECLARE @StrSelect	NVarChar(4000);
DECLARE @StrSelect1	NVarChar(4000);
DECLARE @StrSelect2	NVarChar(4000);
DECLARE @StrSelect3	NVarChar(4000);
DECLARE @StrFrom	NVarChar(4000);
DECLARE @StrWhere	NVarChar(4000);
DECLARE @StrWhereL	NVarChar(4000);

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
	
	create table #tblRptPrs_LoanInstalments_Loan 
	(
		PersonnelID		varchar(20) collate arabic_cs_as null,
		LoanTypeID		varchar(20) collate arabic_cs_as null,
		LoanAmountSum	bigint null,
		InstAmount		bigint null,
		FiscalYear		int null,
		SerialNo		int null,
		ReceiptDate		char(10) collate arabic_cs_as null		
	);

	create table #tblRptPrs_LoanInstalments_Result
	(
		PersonnelID	varchar(20) collate arabic_cs_as null,
		LoanTypeID	varchar(20) collate arabic_cs_as null,
		LoanAmount	bigint null,
		InstAmount	bigint null,
		MonthCode	int null,
		RowNo		int null,
		SumPay		bigint null,
		SumRemain	bigint null,
		FiscalYear	int null,
		SerialNo	int null,
		ReceiptDate	char(10) collate arabic_cs_as null
	)

	SET @StrWhere = '(1=1)'


    IF (@SelectedPrs > 0)
		SET @StrWhere = @StrWhere + ' AND ' + pub.funGetFilterString(@SessionNo, @ReportID, @SelectedPrs, 'D.PersonnelID')
		
	IF (@MonthCodeFr Is Not Null)
		SET	@StrWhere = @StrWhere + ' AND (D.MonthCode >= ' + Str(LTrim(@MonthCodeFr)) + ')'
	IF (@MonthCodeTo Is Not Null)
		SET	@StrWhere = @StrWhere + ' AND (D.MonthCode <= ' + Str(LTrim(@MonthCodeTo)) + ')'

	IF (@InstAmountFr Is Not Null)
		SET	@StrWhere = @StrWhere + ' AND (D.ThisMonthInstallment >= ' + Str(LTrim(@InstAmountFr)) + ')'
	IF (@InstAmountTo Is Not Null)
		SET	@StrWhere = @StrWhere + ' AND (D.ThisMonthInstallment <= ' + Str(LTrim(@InstAmountTo)) + ')'
		
	IF (@LoanTypeID Is Not Null)
		SET	@StrWhere = @StrWhere + ' AND (D.LoanTypeID = ' + Str(LTrim(@LoanTypeID)) + ')'
	
	If (@LangID = '' or @LangID is null)
		Set @LangID = 1
		
	-- origin loan --

	set @StrWhereL = '(1=1)'
	
	 IF (@SelectedPrs > 0)
		SET @StrWhereL = @StrWhereL + ' AND ' + pub.funGetFilterString(@SessionNo, @ReportID, @SelectedPrs, 'D.PersonnelID')
			

	IF (@DocDateFr Is Not Null)                
		SET	@StrWhereL = @StrWhereL + ' AND (D.ReceiptDate >= ''' + LTrim(@DocDateFr) + ''')'
	IF (@DocDateTo Is Not Null)
		SET	@StrWhereL = @StrWhereL + ' AND (D.ReceiptDate <= ''' + LTrim(@DocDateTo) + ''')'

	IF (@OrigAmountFr Is Not Null)
		SET	@StrWhereL = @StrWhereL + ' AND (D.OriginLoanAmount >= ' + Str(LTrim(@OrigAmountFr)) + ')'
	IF (@OrigAmountTo Is Not Null)
		SET	@StrWhereL = @StrWhereL + ' AND (D.OriginLoanAmount <= ' + Str(LTrim(@OrigAmountTo)) + ')'
	IF (@LoanTypeID Is Not Null)
		SET	@StrWhereL = @StrWhereL + ' AND (D.LoanTypeID = ' + Str(LTrim(@LoanTypeID)) + ')'
			 			
	SET @StrSelect = '
	insert	into #tblRptPrs_LoanInstalments_Loan
	SELECT    D.PersonnelID, D.LoanTypeID,Case when DebitFromLoan>0 then DebitFromLoan else D.OriginLoanAmount  end OriginLoanAmount,D.InstallmentAmount, FiscalYear,SerialNo,ReceiptDate
	FROM         prs.tblLoanInstallmentsDtl AS D     
	where	' + @StrWhereL + ' 
	'
	Print @StrSelect;
	EXEC sp_executesql @StrSelect;
	
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
	if (select Count(*) from sys.databases where name =@OldDbName1)>0
		set @StrSelect1=' 	
			select	D.*, isnull(H.LoanAmountSum, 0) LoanAmountSum
			from	'+ @OldDbName1 +'.prs.tblInstallmentDeductionsDtl D
				inner join #tblRptPrs_LoanInstalments_Loan H on H.PersonnelID = D.PersonnelID and H.LoanTypeID = D.LoanTypeID  and H.FiscalYear = D.FiscalYear and H.SerialNo = D.SerialNo  and H.ReceiptDate = D.ReceiptDate 
			where	' + @StrWhere + ' '
	if (select Count(*) from sys.databases where name =@OldDbName2)>0
		set @StrSelect2=' 	
			select	D.*, isnull(H.LoanAmountSum, 0) LoanAmountSum
			from	'+ @OldDbName2 +'.prs.tblInstallmentDeductionsDtl D
				inner join #tblRptPrs_LoanInstalments_Loan H on H.PersonnelID = D.PersonnelID and H.LoanTypeID = D.LoanTypeID  and H.FiscalYear = D.FiscalYear and H.SerialNo = D.SerialNo  and H.ReceiptDate = D.ReceiptDate 
			where	' + @StrWhere + ' '
	if (select Count(*) from sys.databases where name =@OldDbName3)>0
		set @StrSelect3=' 	
			select	D.*, isnull(H.LoanAmountSum, 0) LoanAmountSum
			from	'+ @OldDbName3 +'.prs.tblInstallmentDeductionsDtl D
				inner join #tblRptPrs_LoanInstalments_Loan H on H.PersonnelID = D.PersonnelID and H.LoanTypeID = D.LoanTypeID  and H.FiscalYear = D.FiscalYear and H.SerialNo = D.SerialNo  and H.ReceiptDate = D.ReceiptDate 
			where	' + @StrWhere + ' '
	SET @StrSelect = '
				select	D.*, isnull(H.LoanAmountSum, 0) LoanAmountSum
			from	prs.tblInstallmentDeductionsDtl D
				inner join #tblRptPrs_LoanInstalments_Loan H on H.PersonnelID = D.PersonnelID and H.LoanTypeID = D.LoanTypeID  and H.FiscalYear = D.FiscalYear and H.SerialNo = D.SerialNo  and H.ReceiptDate = D.ReceiptDate 
			where	' + @StrWhere + ' '
	--if @StrSelect1<>''
	--		SET @StrSelect += '	Union  all 	 '+@StrSelect1
	--if @StrSelect2<>''
	--		SET @StrSelect += '	Union  all 	 '+@StrSelect2
	--if @StrSelect3<>''
	--		SET @StrSelect += '	Union  all 	 '+@StrSelect3

	SET @StrSelect = '
	insert into #tblRptPrs_LoanInstalments_Result(PersonnelID, LoanTypeID, LoanAmount, MonthCode, RowNo, InstAmount,SumPay	,SumRemain,FiscalYear,SerialNo,ReceiptDate)

	select T.PersonnelID, T.LoanTypeID, T.LoanAmountSum, T.MonthCode, T.RowNo, T.ThisMonthInstallment,0,0,FiscalYear,SerialNo,ReceiptDate
	from
	(	' + @StrSelect + '	) T	
	union all
	select PersonnelID, LoanTypeID, LoanAmountSum, 0, 0, 0,0 ,0 ,FiscalYear,SerialNo,ReceiptDate
	from #tblRptPrs_LoanInstalments_Loan D
	where (select count (*) from prs.tblInstallmentDeductionsDtl where PersonnelID = D.PersonnelID and FiscalYear = D.FiscalYear and SerialNo = D.SerialNo and ReceiptDate = D.ReceiptDate) = 0'

	Print @StrSelect;
	EXEC sp_executesql @StrSelect;
	
	SET @StrSelect = 'insert into  #tblRptPrs_LoanInstalments_Result
	select PersonnelID,LoanTypeID,LoanAmountSum,InstAmount,0,0,0,0,FiscalYear,SerialNo,ReceiptDate from #tblRptPrs_LoanInstalments_Loan
	where str(FiscalYear)+str(SerialNo)+ReceiptDate not in ( select str(FiscalYear)+str(SerialNo )+ReceiptDate From #tblRptPrs_LoanInstalments_Result)
	'
	
	Print @StrSelect;
	EXEC sp_executesql @StrSelect;

	update #tblRptPrs_LoanInstalments_Result
	set SumPay= sumInstAmount, SumRemain=LoanAmount-sumInstAmount

	from #tblRptPrs_LoanInstalments_Result a 
	inner join 
	(Select sum( InstAmount) sumInstAmount, FiscalYear,SerialNo,ReceiptDate, PersonnelID,LoanTypeID from #tblRptPrs_LoanInstalments_Result
	where MonthCode>0
	group by FiscalYear,SerialNo,ReceiptDate, PersonnelID,LoanTypeID)b
	on a.FiscalYear =b.FiscalYear and a.SerialNo=b.SerialNo and a.ReceiptDate=b.ReceiptDate and a.PersonnelID=b.PersonnelID and a.LoanTypeID=b.LoanTypeID

IF (@SettlementedType =2)
	begin
		SET @StrSelect =  'delete from  #tblRptPrs_LoanInstalments_Result
			where str(FiscalYear)+str(SerialNo )+ReceiptDate Not In (Select str(FiscalYear)+str(SerialNo )+ReceiptDate  from  prs.tblLoanInstallmentsDtl  where  Settlemented=0)  '	
		Print @StrSelect;
		EXEC sp_executesql @StrSelect;
	end
		
IF (@SettlementedType =3)
	begin
		SET @StrSelect =  'delete from  #tblRptPrs_LoanInstalments_Result
			where str(FiscalYear)+str(SerialNo )+ReceiptDate Not In (Select str(FiscalYear)+str(SerialNo )+ReceiptDate from   prs.tblLoanInstallmentsDtl  where  Settlemented=1)  '	
		Print @StrSelect;
		EXEC sp_executesql @StrSelect;
	end					

	SET @StrSelect = 'select	0 ID ,R.*, PD.FirstName + '' '' + PD.LastName PersonnelName, LD.LoanTypeName,isnull(T2.TypeText ,''پرداخت نشده'')as MonthName,LD.*
						from	#tblRptPrs_LoanInstalments_Result R
								left join prs.tblPersonnelsDtl PD ON PD.PersonnelID = R.PersonnelID AND PD.LanguageID = '+Str(LTrim(RTrim(@LangID)))+'
								left join prs.tblLoanTypesDtl  LD ON LD.LoanTypeID = R.LoanTypeID
								left join pub.tblTypeValues    T2 ON T2.TypeID = 10 and T2.TypeValue = R.MonthCode
						order by FiscalYear,SerialNo,R.PersonnelID, R.LoanTypeID, R.MonthCode, R.RowNo '
	
	Print @StrSelect;
	EXEC sp_executesql @StrSelect;
	
End
GO
