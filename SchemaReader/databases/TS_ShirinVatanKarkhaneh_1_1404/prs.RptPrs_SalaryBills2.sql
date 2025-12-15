USE TS_ShirinVatanKarkhaneh_1_1404
GO
SET ANSI_NULLS, QUOTED_IDENTIFIER ON
GO
-- =========== TS-QC:UPDATED ====================
-- Author		 : TakroSystem\Ahmadnejad
-- Create Date   : 1390/12/09
-- Viewed By	 : 
-- Last Modified : 
-- Last Modifier : 
-- Description	 : فیش عیدی/پایانکار پرسنل
-- ==============================================
Create  PROCEDURE [prs].[RptPrs_SalaryBills2]
	@ProcessID		Int,
	@MonthCode		Int,
	@SelectedPrs	Int = 0,
	@DecreeTypeID	VarChar(20) = Null,
	@DepartmentID	VarChar(20) = Null,
	@WorkShopID		VarChar(20) = Null,
	@JobID			VarChar(20) = Null,
	@RepOptions		VarChar(10) = '00',  -- bit array options
	@RepInfo		NVarChar(100) = '1@1@1'
WITH ENCRYPTION
AS 
DECLARE @StrSelect		NVarChar(4000);
DECLARE @StrWhere		NVarChar(4000);
DECLARE @ShowRemain		Bit;
DECLARE @ExternalCall	Bit;

DECLARE	@LangID			Char(1);
DECLARE	@SessionNo		Int; 
DECLARE	@ReportID		Int; 
DECLARE @StrTemp		Char(5);
DECLARE	@MonthCodeTo	Int

Begin 
	--============== S T A R T  C O D E =======================================

	SET NOCOUNT ON;
	
	--	سقف عیدی  ----
	declare @CelebrationCeiling  int;
	--تعداد روزهای مبنای محاسبه سنوات--
	declare @HistoryCalcDaysBase  int;

	select @CelebrationCeiling=SettingValue from pub.tblSettings where SettingKey='CelebrationCeiling'
	select @HistoryCalcDaysBase=SettingValue from pub.tblSettings where SettingKey='HistoryCalcDaysBase'
	
	---- Init ------------------------------------------
	IF (@RepInfo		Is Null)	SET @RepInfo = '1@1@1'
	IF (@SelectedPrs	Is Null)	SET @SelectedPrs = 0

	SET @LangID		= pub.funSplitString(@RepInfo, '@', 1);
	SET @SessionNo	= pub.funSplitString(@RepInfo, '@', 2);
	SET @ReportID	= pub.funSplitString(@RepInfo, '@', 3);
	SET @MonthCodeTo= pub.funSplitString(@RepInfo, '@', 6);

	----------------------------------------------------
	set @StrWhere = '(C.ProcessID=' + ltrim(str(@ProcessID)) + ') and (C.MonthCode>=' + ltrim(str(@MonthCode)) + ') and (C.MonthCode<=' + ltrim(str(@MonthCodeTo)) + ')'
	
	IF (@SelectedPrs > 0)
		SET @StrWhere = @StrWhere + ' AND ' + pub.funGetFilterString(@SessionNo, @ReportID, @SelectedPrs, 'C.PersonnelID')

	If (@DecreeTypeID Is Not Null)
		SET @StrWhere = @StrWhere + ' AND D.DecreeTypeID = ''' + @DecreeTypeID + ''''
	If (@DepartmentID Is Not Null)
		SET @StrWhere = @StrWhere + ' AND D.DepartmentID LIKE ''' + @DepartmentID + '%'''
	If (@WorkShopID	Is Not Null)
		SET @StrWhere = @StrWhere + ' AND D.WorkShopID = ''' + @WorkShopID + ''''
	If (@JobID Is Not Null)
		SET @StrWhere = @StrWhere + ' AND D.JobID = ''' + @JobID + ''''

SET @StrSelect = '
SELECT	(	select Tax+(SumCostEnd-FromSalary)*TaxPercent/100 
			FROM prs.tblTaxCalculationDtl 
			where FromSalary <=SumCostEnd and SumCostEnd<= ToSalary)Tax ,
	S2.* , case when ' + ltrim(str(@ProcessID)) + '= 320 then   TaxAmountCelebration else 0 end TaxAmountCelebration  from (
			SELECT	 Case when SumCost>CelebrationCeiling  then CelebrationCeiling  else SumCost end  SumCostEnd ,
			* from (	
					SELECT	
						(Select Sum(Cost )  FROM	prs.tblCelebrationDtl cd 
						where PersonnelID=C.PersonnelID and MonthCode<=' + ltrim(str(@MonthCodeTo)) + ' and ProcessID=' + ltrim(str(@ProcessID)) + ' )SumCost
							,'+ str(@CelebrationCeiling)+' CelebrationCeiling ,C.Basepay*'+ str(@HistoryCalcDaysBase)+' HistoryCalcDaysBase,C.*
							, P.FirstName + '' '' + P.LastName As PersonnelName
							,FirstName	,LastName,	FatherName	,D.DepartmentID,DT.DepartmentName
							,A.AccountNo,D.EmploymentType,T.TypeText,EmployeeTaxIsBenefit,EmployeeTaxCeleIsBenefit
						,pub.funGetTypeText(10, cast(C.MonthCode as int), 1) as MonthName ,PS.NationalIDNumber
						FROM	prs.tblCelebrationDtl C
						INNER JOIN prs.tblDecreeHdr D ON D.PersonnelID = C.PersonnelID AND D.SerialNo = C.DecreeSerialNo
						LEFT Join pub.tblTypeValues T ON D.EmploymentType=T.TypeValue AND T.TypeID =38
						LEFT Join prs.tblDepartmentsDtl DT ON DT.DepartmentID=D.DepartmentID AND DT.LanguageID =' + str(@LangID) +'
						INNER JOIN prs.tblPersonnelsDtl P ON P.PersonnelID = C.PersonnelID  AND P.LanguageID =' + str(@LangID) +'
						INNER JOIN prs.tblPersonnels  PS ON P.PersonnelID = PS.PersonnelID 
						LEFT Join prs.tblPersonnelAccountsDtl A ON P.PersonnelID = A.PersonnelID  and A.IsDefault=1
						WHERE	' + @StrWhere +' 
			) S1
		) S2
		inner join prs.tblSalaryCalculation a on a.PersonnelID=S2.PersonnelID and a.MonthCode=S2.MonthCode'

	PRINT @StrSelect;
	EXEC sp_executesql @StrSelect;
End	
GO
