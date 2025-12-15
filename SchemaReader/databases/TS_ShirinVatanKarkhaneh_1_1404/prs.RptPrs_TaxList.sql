USE TS_ShirinVatanKarkhaneh_1_1404
GO
SET ANSI_NULLS, QUOTED_IDENTIFIER ON
GO
-- =========== TS-QC:UPDATED ====================
-- Author		 : TakroSystem\Zia
-- Creation date : 1390/05/23
-- Viewed By	 : 
-- Last Modified : 
-- Last Modifier : 
-- Description	 : لیست دارائی
-- ==============================================
Create PROCEDURE prs.RptPrs_TaxList 
	@MonthCode		Int,
	@WorkShopID		VarChar(20) = Null,
	@SelectedInsur	Int = 0,
	@InsurList		NVarChar(100) = Null,
	@RepOptions		VarChar(20) = '0',
	@RepInfo		NVarChar(100) = '1@1@1'
WITH ENCRYPTION
AS 
DECLARE @StrSelect		NVarChar(4000);
DECLARE @StrFrom		NVarChar(4000);
DECLARE @StrWhere		NVarChar(4000);
DECLARE	@LangID			Char(1);
DECLARE	@SessionNo		Int; 
DECLARE	@ReportID		Int; 
DECLARE @ShowZT			Bit;
DECLARE @StrFuncDays	NVarChar(500);
DECLARE	@decAbs			bit;
DECLARE	@decLWP			bit;
declare @OrderBy		int;
declare @SelectedPrs	Int;
declare @ShowOverTime		bit =0
declare @ShowLeaveAmount	bit=0

Begin 
	--============== S T A R T  C O D E =======================================

	SET NOCOUNT ON;

	---- Init ------------------------------------------
	IF (@RepInfo	Is Null)	SET @RepInfo = '1@1@1'

	SET @LangID			= pub.funSplitString(@RepInfo, '@', 1);
	SET @SessionNo		= pub.funSplitString(@RepInfo, '@', 2);
	SET @ReportID		= pub.funSplitString(@RepInfo, '@', 3);
	--------------------------------------------------------
	SET @OrderBy		= pub.funSplitString(@RepInfo, '@', 6);
	SET @SelectedPrs	= pub.funSplitString(@RepInfo, '@', 7);
	SET @ShowOverTime		= pub.funSplitString(@RepInfo, '@', 8);
	SET @ShowLeaveAmount	= pub.funSplitString(@RepInfo, '@', 9);
	
	----------------------------------------------------
	if (len(@RepOptions) > 0)
		SET @ShowZT	= Substring(@RepOptions, 1, 1)
	else
		SET @ShowZT	= 0
	----------------------------------------------------
	Update prs.tblSalaryCalculation 	
	set TaxableAmountNoAdjust=TaxableAmount
	where TaxableAmountNoAdjust=0
	

	SET @StrWhere = '(S.MonthCode = ' + Str(@MonthCode) + ')'
	
	-- نوع مالیات مخالف کسر نشود
	SET @StrWhere = @StrWhere + ' and (DH.TaxType <> 1)' 

	if (@ShowZT = 0)
		SET @StrWhere = @StrWhere + ' and (S.TaxAmount+TaxAmountCelebration > 0)'

	IF (@WorkShopID	Is Not Null)	
		SET @StrWhere = @StrWhere + ' AND (DH.WorkShopID = ''' + @WorkShopID + ''')'

	--IF (@SelectedInsur <> 0)
	--	SET @StrWhere = @StrWhere + ' AND ' + pub.funGetFilterString(@SessionNo, @ReportID, @SelectedInsur, 'DH.InsuranceTypeID') 

	--IF (@InsurList Is Not Null)
	--	SET @StrWhere = @StrWhere + ' AND DH.InsuranceTypeID IN (' + @InsurList + ')'
	
	set @decAbs = ISNULL((
		select SettingValue
		from pub.tblSettings
		where SettingKey = 'DeductAbsenceFromTaxAndInsur'), 0)
	set @decLWP = ISNULL((
		select SettingValue
		from pub.tblSettings
		where SettingKey = 'FunctionMinusLeaveWithoutPayInsurTax'), 0)

	set @StrFuncDays = 'F.InsuranceFunction-F.SickLeave'
	
	if (@decAbs=1)
		set @StrFuncDays = @StrFuncDays + '-F.Absence'
		
	if (@decLWP=1)
		set @StrFuncDays = @StrFuncDays + '-LeaveWithoutPay'
	
	IF (@SelectedPrs > 0)
		SET @StrWhere  = @StrWhere  + ' AND ' + pub.funGetFilterString(@SessionNo, @ReportID, @SelectedPrs, 'PH.PersonnelID')
		
	SET @StrSelect = '
	SELECT	PH.*,PD.*,PD.FirstName + '' '' + PD.LastName AS PersonnelName, 
			DH.Basepay, DH.JobID, J.JobName, DH.WorkShopID, WH.WorkShopNumber, WD.WorkShopName, WD.EmployerName, WD.WorkShopAddress,
			F.MonthlyFunction, S.EmployeeInsur, S.EmployerInsur, S.DoleAmount, S.InsurableAmount, S.TaxAmount,S.TaxAmountCelebration , 
			case when (S.TaxableAmount < 0) then 0 else S.TaxableAmount end TaxableAmount, TaxableAmountCelebration, DH.InsuranceBasepay,
			F.SickLeave, Isnull(LD.LocationName,'''') AS LocationName, ' + @StrFuncDays + ' RealFunctionDays, F.InsuranceFunction
			,S.TaxableAmountNoAdjust,S.SumTaxableAmount,S.SumTaxAmount,S.SumTaxAmountCelebration,SumTaxableAmountCelebration ,S.TaxSumFreeYear,S.TaxSumFreeMonths
			,D325.Cost +( case when S.MonthCode =12 then 
				(select Cost FROM prs.tblCelebrationDtl CD where CD.ProcessID=325 and CD.PersonnelID = S.PersonnelID and CD.MonthCode=13)
				else 0 end) CelebrationCost325
			,D320.Cost +( case when S.MonthCode =12 then 
				(select Cost FROM prs.tblCelebrationDtl CD where CD.ProcessID=320 and CD.PersonnelID = S.PersonnelID and CD.MonthCode=13)
				else 0 end)  CelebrationCost320
			,Case when DH.InsuranceHireDate<>'''' OR PH.InsuranceHireDate<>'''' then (CASE WHEN DH.InsuranceHireDate<>'''' THEN DH.InsuranceHireDate ELSE  PH.InsuranceHireDate END ) else HireDate end HireDateNew 
			,'+STR( @ShowOverTime)+' as ShowOverTime,'+STR( @ShowLeaveAmount)+' as ShowLeaveAmount
			, S.OvertimeAmount,S.RedeemedVacationAmount,S.NotInsurableAmountBenefitForView ,S.NotTaxableAmountBenefitForView ,
			(select Sum(BenefitAmount) from prs.tblSalaryCalcInsureTax  it where it.PersonnelID =S.PersonnelID and it.MonthCode=S.MonthCode and it.BenefitType=1 and  BenefitAmount>0) InsureInc,
			(select Sum(BenefitAmount) from prs.tblSalaryCalcInsureTax  it where it.PersonnelID =S.PersonnelID and it.MonthCode=S.MonthCode and it.BenefitType=1 and  BenefitAmount<0)  InsureDec ,
			(select Sum(BenefitAmount) from prs.tblSalaryCalcInsureTax  it where it.PersonnelID =S.PersonnelID and it.MonthCode=S.MonthCode and it.BenefitType=2 and  BenefitAmount>0) TaxInc,
			(select Sum(BenefitAmount) from prs.tblSalaryCalcInsureTax  it where it.PersonnelID =S.PersonnelID and it.MonthCode=S.MonthCode and it.BenefitType=2 and  BenefitAmount<0) TaxDnc

	FROM	prs.tblFunctionsDtl F 
				INNER JOIN prs.tblSalaryCalculation S ON S.PersonnelID = F.PersonnelID AND S.MonthCode = F.MonthCode
				INNER JOIN prs.tblDecreeHdr DH ON DH.SerialNo = S.DecreeSerialNo AND DH.PersonnelID = S.PersonnelID
				INNER JOIN prs.tblPersonnels PH ON S.PersonnelID = PH.PersonnelID 
				INNER JOIN prs.tblPersonnelsDtl PD ON PH.PersonnelID = PD.PersonnelID AND PD.LanguageID = ' + @LangID + '
				INNER JOIN prs.tblJobsDtl J ON J.JobID = DH.JobID AND J.LanguageID = ' + @LangID + '
				INNER JOIN prs.tblWorkShops WH ON WH.WorkShopID = DH.WorkShopID 
				INNER JOIN prs.tblWorkShopsDtl WD ON WD.WorkShopID = DH.WorkShopID AND WD.LanguageID = ' + @LangID + '
				LEFT JOIN pub.tblLocationsDtl LD ON PH.IssuancePlace = LD.LocationID AND LD.LanguageID = ' + @LangID + '
				LEFT JOIN (select * FROM prs.tblCelebrationDtl  where ProcessID=325) D325 ON D325.PersonnelID = S.PersonnelID  and D325.MonthCode = S.MonthCode 
				LEFT JOIN (select * FROM prs.tblCelebrationDtl  where ProcessID=320) D320 ON D320.PersonnelID = S.PersonnelID  and D320.MonthCode = S.MonthCode 
				
	WHERE ' + @StrWhere 
	
	if @OrderBy =1
		set @StrSelect=@StrSelect +'ORDER BY PD.LastName,PD.FirstName,PD.PersonnelID'
	if @OrderBy =2
		set @StrSelect=@StrSelect +'ORDER BY PD.FirstName,PD.LastName,PD.PersonnelID'
	if @OrderBy =3
		set @StrSelect=@StrSelect +'ORDER BY PD.PersonnelID,PD.LastName,PD.FirstName'
	
	Print @StrSelect;
	EXEC sp_executesql @StrSelect;
End
GO
