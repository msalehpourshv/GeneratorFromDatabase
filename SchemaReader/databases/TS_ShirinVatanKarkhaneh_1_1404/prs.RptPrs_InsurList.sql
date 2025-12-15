USE TS_ShirinVatanKarkhaneh_1_1404
GO
SET ANSI_NULLS, QUOTED_IDENTIFIER ON
GO
-- =========== TS-QC:UPDATED ====================
-- Author		 : TakroSystem\Ahmadnejad
-- Creation date : 1387/11/07
-- Viewed By	 : 
-- Last Modified : 1390/05/23
-- Last Modifier : TakroSystem\Zia
-- Description	 : لیست بیمه
-- ==============================================
--[prs].[RptPrs_InsurList] '08'
Create PROCEDURE prs.RptPrs_InsurList
	@MonthCode		Int,
	@WorkShopID		VarChar(20) = Null,
	@SelectedInsur	Int = Null,
	@InsurList		NVarChar(100) = Null,
	@RepInfo		NVarChar(100) = '1@1@1'
WITH ENCRYPTION
AS 
DECLARE @StrSelect			NVarChar(max);
DECLARE @StrSelect2			NVarChar(max);
DECLARE @StrSelect3			NVarChar(max);
DECLARE @StrFrom			NVarChar(max);
DECLARE @StrWhere			NVarChar(max);
DECLARE @StrFuncDays		NVarChar(500);
DECLARE @Ins				nvarchar(max);
DECLARE @View				nvarchar(max);
DECLARE @Notv				nvarchar(max);
DECLARE @BenefitID			nvarchar(max);
DECLARE @PeriodWorkID		nvarchar(max);
DECLARE @MyRepOptions		VarChar(10)
declare @CompanyPayerName1	varchar(50)
declare @CompanyPayerName2	varchar(50)
declare @StrMonthCode		varchar(100)
DECLARE	@LangID				Char(1);
DECLARE	@SessionNo			Int; 
DECLARE	@ReportID			Int;
declare @OrderBy			int
declare @SelectedPrs		Int;
DECLARE @MonthCodeTo		Int
DECLARE	@decAbs				bit;
DECLARE	@decAbs2			bit;
DECLARE	@decLWP				bit;
DECLARE	@PeriodWorkInsur	bit;
declare @ShowOverTime		bit =0
declare @ShowLeaveAmount	bit=0
DECLARE @Insurable			bit
DECLARE @NotInsurableForView				bit
declare @BenefitFunctionMonth				bit
declare @CalcByInsureFunction				bit -- 0:RealFunction  -  1:InsurFunction
declare @FunctionMinusAbsenceWithoutPay		bit 
DECLARE	@FiscalYear			varchar(4); 
DECLARE	@prs_ZeroBasePay	bit;

Begin 
	--============== S T A R T  C O D E =======================================

	SET NOCOUNT ON;

	---- Init ------------------------------------------
	IF (@RepInfo Is Null)	SET @RepInfo = '1@1@1'

	SET @LangID				= pub.funSplitString(@RepInfo, '@', 1);
	SET @SessionNo			= pub.funSplitString(@RepInfo, '@', 2);
	SET @ReportID			= pub.funSplitString(@RepInfo, '@', 3);
	
	SET @ShowOverTime		= pub.funSplitString(@RepInfo, '@', 6);
	SET @ShowLeaveAmount	= pub.funSplitString(@RepInfo, '@', 7);
	SET @OrderBy			= pub.funSplitString(@RepInfo, '@', 8);
	SET @SelectedPrs		= pub.funSplitString(@RepInfo, '@', 9);
	SET @MonthCodeTo		= pub.funSplitString(@RepInfo, '@', 10);

	if @MonthCodeTo<@MonthCode
		set @MonthCodeTo=@MonthCode			

	CREATE TABLE #tbl_RptPrs_SalaryList_DTL
	(
		PersonnelID		VarChar(20) COLLATE ARABIC_CS_AS,
		BenefitName		VarChar(50) COLLATE ARABIC_CS_AS,
		BenefitAmount	Float,
		BenefitTime		varchar(50),
		BenefitUnit		nvarchar(30),		
		BenefitType		Int
	);
	
		SET @MyRepOptions = '0100010'
		SET @RepInfo	= pub.funSplitString(@RepInfo, '@', 1)	
		+'@'+ pub.funSplitString(@RepInfo, '@', 2)	
		+'@'+ pub.funSplitString(@RepInfo, '@', 3)	
		+'@'+ pub.funSplitString(@RepInfo, '@', 4)	
		+'@'+ pub.funSplitString(@RepInfo, '@', 5);
	
	SET @StrSelect = '  
	EXEC [prs].[RptPrs_SalaryBillsDtl]  @MonthCode='+ STR(@MonthCode)+',@SelectedPrs=Null, @DecreeTypeID=NULL, 
	@DepartmentID=NULL, @WorkShopID='''+ ISNULL(@WorkShopID,'NULL')+''', @JobID=NULL, @RemainDate =NULL,
	@LoanDate =NULL,	@RepOptions ='''+ ISNULL(@MyRepOptions,'NULL')+''',@RepInfo='''+ ISNULL(@RepInfo,'NULL')+'''	'

	Print @StrSelect;
	--EXEC sp_executesql @StrSelect;
			
	
	set @StrMonthCode=		ltrim(rtrim(@MonthCode))

	if @MonthCodeTo=@MonthCode
			
	INSERT INTO #tbl_RptPrs_SalaryList_DTL
	EXEC [prs].[RptPrs_SalaryBillsDtl] @MonthCode, 0, null, null, @WorkShopID, null, null, null, @MyRepOptions, @RepInfo
else
	begin
	
	while @MonthCode<=@MonthCodeTo
	begin
	set @StrMonthCode=@StrMonthCode+ ',' +	ltrim(rtrim(str(@MonthCode)))
		INSERT INTO #tbl_RptPrs_SalaryList_DTL
		EXEC [prs].[RptPrs_SalaryBillsDtl] @MonthCode, 0, null, null, @WorkShopID, null, null, null, @MyRepOptions, @RepInfo
		set @MonthCode=@MonthCode+1
	end 
	end 
	
	---------------------------------------------------		
	set @decAbs = ISNULL((select SettingValue from pub.tblSettings where SettingKey = 'DeductAbsenceFromTaxAndInsur'), 0)
	set @BenefitFunctionMonth = ISNULL((select SettingValue	from pub.tblSettings where SettingKey = 'BenefitFunctionMonth'), 0)
	set @decAbs2 = ISNULL((select SettingValue from pub.tblSettings where SettingKey = 'DeductAbsenceFromInsur'), 0)
	set @decLWP = ISNULL((select SettingValue from pub.tblSettings where SettingKey = 'FunctionMinusLeaveWithoutPayInsurTax'), 0)		
	set @StrFuncDays = 'F.InsuranceFunction-F.SickLeave'
	set @CalcByInsureFunction= ISNULL((select SettingValue	from pub.tblSettings where SettingKey = 'prsCalcInsureSumWithInsuranceFunction'), 0)
	set @FunctionMinusAbsenceWithoutPay= ISNULL((select SettingValue from pub.tblSettings where SettingKey = 'FunctionMinusAbsenceWithoutPay'), 0)
	set @CompanyPayerName1 = ISNULL((select SettingValue from pub.tblSettings where SettingKey = 'CompanyPayerName1'), 0)
	set @CompanyPayerName2 = ISNULL((select SettingValue from pub.tblSettings where SettingKey = 'CompanyPayerName2'), 0)
	select @PeriodWorkInsur=SettingValue	from pub.tblSettings 	where SettingKey = 'PeriodWorkInsur'
	select @prs_ZeroBasePay=SettingValue	from pub.tblSettings 	where SettingKey = 'prs_ZeroBasePayInCreateInsureDiskForZeroDays'
	set @prs_ZeroBasePay=isnull(@prs_ZeroBasePay,0)

	if (@decAbs=1 or @decAbs2=1)
		set @StrFuncDays = @StrFuncDays + '-F.Absence'
		
	if (@decLWP=1)
		set @StrFuncDays = @StrFuncDays + '-LeaveWithoutPay'

	SET @StrWhere = '  ( DH.InsuranceBasepay > 0 ) and  (InsuranceID <> '''') and (S.MonthCode in ( ' + @StrMonthCode + ') )'

	IF (@WorkShopID	Is Not Null)	
		SET @StrWhere = @StrWhere + ' AND (DH.WorkShopID = ''' + @WorkShopID + ''')'

	IF (@SelectedInsur <> 0)
		SET @StrWhere = @StrWhere + ' AND ' + pub.funGetFilterString(@SessionNo, @ReportID, @SelectedInsur, 'DH.InsuranceTypeID') 

	IF (@InsurList Is Not Null) and (@InsurList<>'0')
		SET @StrWhere = @StrWhere + ' AND DH.InsuranceTypeID IN (' + @InsurList + ')'

set @View = '0'
set @Notv = '0'

DECLARE CSR_B1 CURSOR FOR
		SELECT	D.BenefitID,Insurable,NotInsurableForView
		FROM	prs.tblBenefits1 D
		where BenefitID<>''
	OPEN CSR_B1
	FETCH NEXT FROM CSR_B1 INTO @BenefitID,@Insurable,@NotInsurableForView
		
	WHILE @@fetch_status = 0
	BEGIN
		--if @NotInsurableForView = '0' and @Insurable='0'
		--		SET @Notv = @Notv + '+S.Benefit' + @BenefitID
		
	if @NotInsurableForView = '1' and @Insurable='0'	
				SET @View = @View + '+S.Benefit' + @BenefitID
		
		FETCH NEXT FROM CSR_B1 INTO  @BenefitID,@Insurable,@NotInsurableForView
	END
	CLOSE CSR_B1
	DEALLOCATE CSR_B1

if @PeriodWorkInsur=0
begin


DECLARE CSR_PeriodWorkInsur CURSOR FOR
SELECT     PeriodWorkID,  InsurablePeriodWorks
FROM         emp.tblPeriodWorks
		where PeriodWorkID<>''

	OPEN CSR_PeriodWorkInsur
	FETCH NEXT FROM CSR_PeriodWorkInsur INTO @PeriodWorkID,@NotInsurableForView
		
	WHILE @@fetch_status = 0
	BEGIN
		
	if @NotInsurableForView = '1' 
				SET @View = @View + '+S.PeriodWorkAmount' + @PeriodWorkID
			
		FETCH NEXT FROM CSR_PeriodWorkInsur INTO  @PeriodWorkID,@NotInsurableForView
	END
	CLOSE CSR_PeriodWorkInsur
	DEALLOCATE CSR_PeriodWorkInsur

end
IF (@SelectedPrs > 0)
		SET @StrWhere  = @StrWhere  + ' AND ' + pub.funGetFilterString(@SessionNo, @ReportID, @SelectedPrs, 'PH.PersonnelID')
		
set @FiscalYear=right(DB_NAME(),2)

	SET @StrSelect = '
	select PersonnelID,IDNumber,IssuancePlace,NationalIDNumber,BirthDate,BirthPlace,Gender,Nationality,MaritalStatus,MilitaryStatus
,Tel,Mobile,Email,ZipCode,HabitatCity,HireDate,CASE WHEN  InsuranceHireDateD<>'''' THEN InsuranceHireDateD ELSE InsuranceHireDate END InsuranceHireDate,InsuranceID
,CASE WHEN QuitJobDateD<>'''' THEN Case when  SubString(QuitJobDateD ,6,2) <='+ str(@MonthCodeTo )+' then QuitJobDateD else '''' end ELSE  Case when  SubString(QuitJobDate ,6,2) <='+ str(@MonthCodeTo )+' then QuitJobDate else '''' end END QuitJobDate
,EmployeeNumber,CodeClosed,RecID,SessionNo,FieldID,StudyID,Sons,Daughters,BeforeFiscalYearRoundAmount,ExemptionID,CardNumber,IsStudent
,case when YearTaxableAmount=RIGHT(DB_NAME(),4) then IncomeTaxableAmount else 0 end IncomeTaxableAmount
,case when YearTaxableAmount=RIGHT(DB_NAME(),4) then PayedTaxAmount else 0 end PayedTaxAmount
,case when YearTaxableAmount=RIGHT(DB_NAME(),4) then IncomeTaxableAmountCelebration else 0 end IncomeTaxableAmountCelebration
,case when YearTaxableAmount=RIGHT(DB_NAME(),4) then PayedTaxAmountCelebration else 0 end PayedTaxAmountCelebration
,case when YearTaxableAmount=RIGHT(DB_NAME(),4) then MonthTaxableAmount else 0 end MonthTaxableAmount
,SumFunction,FirstName,LastName,FatherName,Address,Description,CountryName
,PersonnelName,Basepay,JobID,JobName,WorkShopID,WorkShopNumber,WorkShopName,EmployerName,WorkShopAddress
,Absence, sum(MonthlyFunction)MonthlyFunction,sum(EmployeeInsur)EmployeeInsur,sum(EmployerInsur)EmployerInsur,sum(DoleAmount)DoleAmount,sum(InsurableAmount)InsurableAmount
,sum(TaxableAmount)TaxableAmount,sum(TaxAmount)TaxAmount,Case when sum(InsurableAmount)=0 and ' + str(@prs_ZeroBasePay) + '=1 then 0 else InsuranceBasepay end InsuranceBasepay ,sum(SickLeave)SickLeave,sum(LeaveWithoutPay)LeaveWithoutPay,LocationName,sum(RealFunctionDays)RealFunctionDays,sum(BenefitSum)BenefitSum,sum(DeductionSum)DeductionSum,sum(LeaveAmount)LeaveAmount
,sum(OverTime)OverTime,QuitJobDateEx,sum(InsuranceFunction)InsuranceFunction,sum(Insurable)Insurable,sum(ViewAble)ViewAble,sum(NotViewAble)NotViewAble
,sum(CalcByInsureFunction)CalcByInsureFunction,sum(FunctionMinusAbsenceWithoutPay)FunctionMinusAbsenceWithoutPay
,CompanyPayerName1,CompanyPayerName2,sum(BenefitFunctionMonth)BenefitFunctionMonth,ShowOverTime,ShowLeaveAmount,
case when sum(InsurableAmountBenefit)=0 then Case when sum(InsurableAmount)<(sum(RealFunctionDays)* InsuranceBasepay) then 0 else  sum(InsurableAmount)-(sum(RealFunctionDays)* InsuranceBasepay) end else  sum(InsurableAmountBenefit) end InsurableAmountBenefit
,sum(NotInsurableAmountBenefitForView)NotInsurableAmountBenefitForView,sum(NotTaxableAmountBenefitForView)NotTaxableAmountBenefitForView
,sum(InsureInc) InsureInc,isnull(sum(InsureDec) ,0 )InsureDec,sum(TaxInc) TaxInc,sum(TaxDnc) TaxDnc
,'''+ @FiscalYear +''' FiscalYear,RowPact, '''' DSW_IDATE  
,Case when sum(InsurableAmount)=0 and ' + str(@prs_ZeroBasePay) + '=1 then 0 else JobCategoryPayInsure end JobCategoryPayInsure 
,Case when sum(InsurableAmount)=0 and ' + str(@prs_ZeroBasePay) + '=1 then 0 else DailyInferiorPayInsure end DailyInferiorPayInsure 
,Case when sum(InsurableAmount)=0 and ' + str(@prs_ZeroBasePay) + '=1 then 0 else DailyInferiorPayRemainInsure end DailyInferiorPayRemainInsure 
,Case when sum(InsurableAmount)=0 and ' + str(@prs_ZeroBasePay) + '=1 then 0 else PastWagesDailyPayInsure end PastWagesDailyPayInsure ,IsSpouse '
set @StrSelect2='
 from (SELECT PH.*, FirstName,LastName,FatherName,Address,Description,CountryName, PD.FirstName + '' '' + PD.LastName AS PersonnelName,DH.QuitJobDate QuitJobDateD,DH.InsuranceHireDate InsuranceHireDateD, DH.Basepay, DH.JobID, J.JobName, DH.WorkShopID, WH.WorkShopNumber, WD.WorkShopName, WD.EmployerName, WD.WorkShopAddress, F.Absence,
F.MonthlyFunction, S.EmployeeInsur, S.EmployerInsur, S.DoleAmount,S.InsurableAmount, S.TaxableAmount+TaxableAmountCelebration TaxableAmount, S.TaxAmount+TaxAmountCelebration TaxAmount, DH.InsuranceBasepay ,--case when ' + @StrFuncDays + ' =0 then 0 else   DH.InsuranceBasepay end InsuranceBasepay,
F.SickLeave, F.LeaveWithoutPay, Isnull(LD.LocationName,'''') AS LocationName,' + @StrFuncDays + ' RealFunctionDays, ISNULL(M1.BenefitAmount, 0) BenefitSum,ISNULL(M2.BenefitAmount, 0) DeductionSum,ISNULL(M11.BenefitAmount, 0) LeaveAmount
,case when DH.InsurableOvertime=0 then ISNULL(M22.BenefitAmount, 0) else 0 end OverTime
,case when ((CASE WHEN DH.QuitJobDate<>'''' THEN DH.QuitJobDate ELSE  PH.QuitJobDate END)<>'''') and cast(substring((CASE WHEN DH.QuitJobDate<>'''' THEN DH.QuitJobDate ELSE  PH.QuitJobDate END),6,2) as int) <= ' + Str(@MonthCodeTo) + ' then (CASE WHEN DH.QuitJobDate<>'''' THEN DH.QuitJobDate ELSE  PH.QuitJobDate END) else '''' end QuitJobDateEx
,F.InsuranceFunction,
--case when S.InsurableAmount-(DH.InsuranceBasepay*(' + @StrFuncDays + '))  <0 then 0 else S.InsurableAmount-(DH.InsuranceBasepay*(' + @StrFuncDays + '))end  as Insurable
S.InsurableAmountBenefit as Insurable
,' + @View + ' as ViewAble ,' + @Notv + '  as NotViewAble ,'+ str(@CalcByInsureFunction) +' AS CalcByInsureFunction
,'+ str(@FunctionMinusAbsenceWithoutPay) +' AS FunctionMinusAbsenceWithoutPay ,'''+  @CompanyPayerName1  +''' AS CompanyPayerName1 ,'''+  @CompanyPayerName2  +''' AS CompanyPayerName2 ,'+STR( @BenefitFunctionMonth )+' as BenefitFunctionMonth,'+STR( @ShowOverTime)+' as ShowOverTime,'+STR( @ShowLeaveAmount)+' as ShowLeaveAmount
,S.InsurableAmountBenefit,S.NotInsurableAmountBenefitForView ,S.NotTaxableAmountBenefitForView ,
(select Sum(BenefitAmount) from prs.tblSalaryCalcInsureTax  it where it.PersonnelID =S.PersonnelID and it.MonthCode=S.MonthCode and it.BenefitType=1 and  BenefitAmount>0) InsureInc,
(select Sum(BenefitAmount) from prs.tblSalaryCalcInsureTax  it where it.PersonnelID =S.PersonnelID and it.MonthCode=S.MonthCode and it.BenefitType=1 and  BenefitAmount<0)  InsureDec ,
(select Sum(BenefitAmount) from prs.tblSalaryCalcInsureTax  it where it.PersonnelID =S.PersonnelID and it.MonthCode=S.MonthCode and it.BenefitType=2 and  BenefitAmount>0) TaxInc,
(select Sum(BenefitAmount) from prs.tblSalaryCalcInsureTax  it where it.PersonnelID =S.PersonnelID and it.MonthCode=S.MonthCode and it.BenefitType=2 and  BenefitAmount<0) TaxDnc,
WH.RowPact ,JobCategoryPayInsure, DailyInferiorPayInsure,DailyInferiorPayRemainInsure,PastWagesDailyPayInsure '

set @StrSelect3	=', InsurableAmountIsSpouse  IsSpouse   FROM  prs.tblFunctionsDtl F  
INNER JOIN prs.tblSalaryCalculation S ON S.PersonnelID = F.PersonnelID AND S.MonthCode = F.MonthCode
INNER JOIN prs.tblDecreeHdr DH ON DH.SerialNo = S.DecreeSerialNo AND DH.PersonnelID = S.PersonnelID
INNER JOIN prs.tblPersonnels PH ON S.PersonnelID = PH.PersonnelID 
INNER JOIN prs.tblPersonnelsDtl PD ON PH.PersonnelID = PD.PersonnelID AND PD.LanguageID = ' + @LangID + '
INNER JOIN prs.tblJobsDtl J ON J.JobID = DH.JobID AND J.LanguageID = ' + @LangID + '
INNER JOIN prs.tblWorkShops WH ON WH.WorkShopID = DH.WorkShopID 
INNER JOIN prs.tblWorkShopsDtl WD ON WD.WorkShopID = DH.WorkShopID AND WD.LanguageID = ' + @LangID + '
LEFT  JOIN pub.tblLocationsDtl LD ON PH.IssuancePlace = LD.LocationID AND LD.LanguageID = ' + @LangID + '
left  JOIN (select PersonnelID, SUM(BenefitAmount)BenefitAmount from #tbl_RptPrs_SalaryList_DTL where BenefitType >0 group by PersonnelID) M1 ON M1.PersonnelID = S.PersonnelID 
left  JOIN (select PersonnelID, SUM(BenefitAmount)BenefitAmount from #tbl_RptPrs_SalaryList_DTL	where BenefitType <0 group by PersonnelID)  M2 ON M2.PersonnelID = S.PersonnelID 
left  JOIN (select PersonnelID, SUM(BenefitAmount)BenefitAmount from #tbl_RptPrs_SalaryList_DTL	where BenefitName=''مبلغ بازخرید مرخصی'' and BenefitType>0 group by PersonnelID) M11 ON M11.PersonnelID = S.PersonnelID 
left  JOIN (select PersonnelID, SUM(BenefitAmount)BenefitAmount from #tbl_RptPrs_SalaryList_DTL where BenefitName like ''اضافه کار%'' group by PersonnelID)  M22 ON M22.PersonnelID = S.PersonnelID 
 WHERE   S.InsurableAmount> -1 and ' + @StrWhere  +'  ) a 
group by PersonnelID,IDNumber,IssuancePlace,NationalIDNumber,BirthDate,BirthPlace,Gender,Nationality,MaritalStatus,MilitaryStatus
,Tel,Mobile,Email,ZipCode,HabitatCity,HireDate,InsuranceHireDate,InsuranceHireDateD,InsuranceID,QuitJobDate,QuitJobDateD,EmployeeNumber,CodeClosed
,RecID,SessionNo,FieldID,StudyID,Sons,Daughters,BeforeFiscalYearRoundAmount,ExemptionID,CardNumber,IsStudent
,IncomeTaxableAmount,PayedTaxAmount,IncomeTaxableAmountCelebration,PayedTaxAmountCelebration,MonthTaxableAmount,YearTaxableAmount
,SumFunction,FirstName,LastName,FatherName,Address,Description,CountryName
,PersonnelName,Basepay,JobID,JobName,WorkShopID,WorkShopNumber,WorkShopName,EmployerName,WorkShopAddress
,Absence,LocationName,CompanyPayerName1,CompanyPayerName2,ShowOverTime,ShowLeaveAmount,QuitJobDateEx,InsuranceBasepay,RowPact ,JobCategoryPayInsure,DailyInferiorPayInsure,DailyInferiorPayRemainInsure, PastWagesDailyPayInsure ,IsSpouse '

	if @OrderBy =1
		set @StrSelect3=@StrSelect3 +'ORDER BY LastName,FirstName,PersonnelID'
	if @OrderBy =2
		set @StrSelect3=@StrSelect3 +'ORDER BY FirstName,LastName,PersonnelID'
	if @OrderBy =3
		set @StrSelect3=@StrSelect3 +'ORDER BY PersonnelID,LastName,FirstName'
		
	Print @StrSelect;
	Print @StrSelect2;
	Print @StrSelect3;
	
	SET @StrSelect = @StrSelect + @StrSelect2+ @StrSelect3;
			--===================================
	EXEC sp_executesql @StrSelect;	
	--===================================
End
GO
