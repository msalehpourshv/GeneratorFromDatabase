USE TS_ShirinVatanKarkhaneh_1_1404
GO
SET ANSI_NULLS, QUOTED_IDENTIFIER ON
GO
-- =========== TS-QC:UPDATED ====================
-- Author		 : TakroSystem\Jafari
-- Create date   : 1401/10/14
-- Viewed By	 : 
-- Last Modified : 
-- Last Modifier : 
-- ----------------------------------------------
-- Description	 : تهیه دیسک مالیات ریز
-- ==============================================
Create PROCEDURE prs.SpPrsTaxFile95
	@ExtraParams		NVarChar(Max) = ''	
WITH ENCRYPTION
AS
BEGIN
	DECLARE @StrSelect		NVarChar(Max);	
	DECLARE @Strfrom		NVarChar(Max);	
	DECLARE @StrWhere		NVarChar(Max);	
	DECLARE @StrTaxAmount	NVarChar(1000);	
	DECLARE	@LangID			Char(1);
	DECLARE	@SessionNo		Int; 
	DECLARE	@ReportID		Int;
	DECLARE	@UserID			Int;
	DECLARE	@UserIsAdmin	bit;
	DECLARE	@PayNagativeTax	bit;
	DECLARE	@TaxForCelebration	bit;
	DECLARE @StrTaxableAmount	NVarChar(1000);	
	DECLARE @StrCost320	NVarChar(1000);		
	DECLARE	@MonthCode	int ;
	DECLARE	@DeductAbsenceFromTaxAndInsur	bit;
	DECLARE	@AbsenceCoefficient	Float;
	DECLARE	@MissionAmountTax int;
	SET @LangID = pub.funGetCurrentLanguageID();
 	SELECT @AbsenceCoefficient=isnull(SettingValue,1)	FROM pub.tblSettings	WHERE SettingKey = 'AbsenceCoefficient'
 	SELECT @DeductAbsenceFromTaxAndInsur=SettingValue	FROM pub.tblSettings	WHERE SettingKey = 'DeductAbsenceFromTaxAndInsur'
 	SELECT @TaxForCelebration=SettingValue	FROM pub.tblSettings	WHERE SettingKey = 'TaxForCelebration'
	
	SET @PayNagativeTax		= LTrim(pub.funSplitString(@ExtraParams, '@', 1)); 
	SET @StrWhere			= LTrim(pub.funSplitString(@ExtraParams, '@', 2)); 
	SET @MonthCode			= LTrim(pub.funSplitString(@ExtraParams, '@', 3)); 
	SET @MissionAmountTax	= LTrim(pub.funSplitString(@ExtraParams, '@', 4)); 

	set @AbsenceCoefficient=isnull(@AbsenceCoefficient,1)
	--drop table #tblPrsTax
	CREATE TABLE #tblPrsTax
	(
		PersonnelID VarChar(20) COLLATE ARABIC_CS_AS,
		MonthCode	int,
		Item7		bigint,--' 7  مبلغ جمع ناخالص حقوق و مزایای مستمر نقدی ماه جاری - ریالی
		Item17		bigint,--' 17 اضافه کاری- ریالی
		Item19		bigint,--' 19 فوق العاده مسافرت )ماموریت( - ریالی
		Item29		bigint,--' 29 سایر حقوق و مزایای غیر مستمر نقدی ماه جاری- ریالی--------   نوبت کاری - شب کاری - جمعه کاری
		Item33		bigint,--' 33 حق بیمه های درمان موضوع ماده 137 ق.م.م
		Item34		bigint,--' 34 حق بیمه های عمر و زندگی موضوع ماده 137 ق.م.م		

		Item36		bigint,--' 36 حق التدریس / حق التحقیق / حق پژوهش
		Item37		bigint,--' 37 حق کشیک
		Item38		bigint,--' 38 رفاهی و انگیزشی و بهره وری
		Item39		bigint--' 39 حق السعی (به استثناء مزد - حقوق و پاداش		
	)


	insert into #tblPrsTax
	  exec prs.SpTaxItemsCalc @MonthCode,'',@MissionAmountTax
	-- select * from #tblPrsTax

	if @PayNagativeTax='True'
		set @StrTaxAmount='SC.TaxAmount , SC.TaxAmountCelebration'
	else
		set @StrTaxAmount='case when isnull(SC.TaxAmount, 0) < 0 then 0 else isnull(SC.TaxAmount, 0)  end TaxAmount
							,case when isnull(SC.TaxAmount, 0) < 0 then 0 else isnull(SC.TaxAmountCelebration, 0) end TaxAmountCelebration'
	
	Set @StrCost320=' prs.funCostPerson (SC.PersonnelID,'+str(@MonthCode)+' , 320)	'

	if @TaxForCelebration='True'
		set @StrTaxableAmount='  isnull(SC.TaxableAmount, 0) + isnull(SC.TaxableAmountCelebration, 0) +isnull(EmployeeInsur, 0) +isnull(MedicalCost, 0) +isnull(SC.NotTaxableAmountBenefitForView, 0)- isnull('+@StrCost320+',0)	'
	else
		set @StrTaxableAmount='  isnull(SC.TaxableAmount, 0) + isnull(SC.TaxableAmountCelebration, 0) +isnull(EmployeeInsur, 0) +isnull(MedicalCost, 0) +isnull(SC.NotTaxableAmountBenefitForView, 0)	'

	SET @StrSelect = '
	select 1 as DataType,EmployeeInsur,MedicalCost, PH.NationalIDNumber, '+@StrTaxAmount+',  substring(PD.FirstName, 1, 15) FirstName
		,substring(PD.LastName, 1, 50) LastName,  substring(PD.FatherName, 1, 15) FatherName,  DT.DecreeTypeID2, PH.ZipCode,  substring(isnull(JB.JobName, ''-''), 1, 30) JobName
		,CASE WHEN DH.InsuranceHireDate<>'''' THEN DH.InsuranceHireDate ELSE  PH.InsuranceHireDate END InsuranceHireDate,CASE WHEN DH.QuitJobDate<>'''' THEN DH.QuitJobDate ELSE  PH.QuitJobDate END QuitJobDate
		,ST.StudyID2, DP.DepartmentID2,  PH.ExemptionID, PH.Nationality,  substring(isnull(PD.CountryName, ''-''), 1, 20) CountryName,  DH.InsurType,  substring(isnull(DH.InsurName, ''''), 1, 15) InsurName
		,PH.InsuranceID, ' + @StrTaxableAmount + ' TaxableAmount, isnull(DH.TaxableOvertime, 0) TaxableOvertime,  isnull(SC.OvertimeAmount, 0) OvertimeAmount,  isnull(SC.VacationAmount, 0) VacationAmount
		,isnull(SC.ExemptionTaxAmount, 0) ExemptionTaxAmount, UD.*,  IsNull(WD.WorkShopID, '''') WorkShopID, IsNull(WD.WorkShopName, '''') WorkShopName,  WH.WorkShopStateID, IsNull(WD.EmployerName, '''') EmployerName
		,IsNull(WD.WorkShopAddress, '''') WorkShopAddress,  IsNull(WD.DossierNumber, '''') DossierNumber, IsNull(WD.PostalCode, '''') PostalCode, IsNull(WD.TelNumber, '''') TelNumber,  DH.DecreeTypeID ,PH.HireDate
		,DH.ContractTypeID ,(SELECT COUNT(*) from prs.tblSalaryCalculation a WHERE DecreeSerialNo in ( SELECT SerialNo from  prs.tblDecreeHdr dd  WHERE dd.PersonnelID=a.PersonnelID and dd.TaxType <> 1 ) AND a.PersonnelID= SC.PersonnelID AND a.MonthCode<=12 ) as MonthCount 
		,isnull( '+@StrCost320+',0) Cost320 ,isnull(prs.funCostPerson (SC.PersonnelID,'+str(@MonthCode)+' , 325),0) Cost325,DH.EmploymentType ,  isnull(SC.RedeemedVacationAmount, 0) RedeemedVacationAmount 
		,IsNull(CategoryID,0) CategoryID, Address,PH.StudyID,IDNumber,BirthDate,BirthPlace,[pub].[funGetLocationName] (BirthPlace,1) BirthPlaceName,isnull(SC.NotTaxableAmountBenefitForView, 0)  NotTaxableAmountBenefitForView   
		,Isnull( Item7,0) Item7 
		,Isnull(Item17,0)Item17,Isnull(Item19,0)Item19,Isnull(Item29,0)Item29,Isnull(Item33,0)Item33,Isnull(Item34,0)Item34
		,Isnull(Item7- Item33-Item34-TaxAmount-TaxAmountCelebration +Item29+Item17+Item19+Isnull(Item36,0)+Isnull(Item37,0)+Isnull(Item38,0)+Isnull(Item39,0)+isnull( '+@StrCost320+',0) - case when '+str( @DeductAbsenceFromTaxAndInsur)+'=1 then AbsenceAmount/'+str(@AbsenceCoefficient)+' else 0 end ,0)	Item35
		,Isnull(Item36,0)Item36,Isnull(Item37,0)Item37,Isnull(Item38,0)Item38,Isnull(Item39,0)Item39
	'
	SET @Strfrom = '
	from prs.tblSalaryCalculation SC  
		inner join prs.tblDecreeHdr     DH on SC.DecreeSerialNo = DH.SerialNo and SC.PersonnelID = DH.PersonnelID  
		left join #tblPrsTax Itm		on Itm.PersonnelID =SC.PersonnelID and  Itm.MonthCode =SC.MonthCode
		left  join prs.tblPersonnels    PH on PH.PersonnelID = SC.PersonnelID  
		left  join prs.tblPersonnelsDtl PD on PD.PersonnelID = PH.PersonnelID  and PD.LanguageID='''+@LangID+'''
		left  join prs.tblStudies       ST on ST.StudyID = PH.StudyID  
		left  join prs.tblDecreeTypes   DT on DT.DecreeTypeID = DH.DecreeTypeID  
		left  join prs.tblJobsDtl       JB on JB.JobID = DH.JobID  
		left  join prs.tblJobs		    JH on JH.JobID = DH.JobID  
		left  join prs.tblDepartments   DP on DP.DepartmentID = DH.DepartmentID  
		left  join prs.tblUnContinuumBenefitsDtl UD on UD.MonthCode = SC.MonthCode and UD.PersonnelID = SC.PersonnelID 
		left  join prs.tblWorkShopsDtl WD on WD.WorkShopID = DH.WorkShopID  
		left  join prs.tblWorkShops WH on WH.WorkShopID = DH.WorkShopID  
	where '
			
	PRINT @StrSelect;
	PRINT @Strfrom;
	PRINT @StrWhere;
	set @StrSelect+= @Strfrom
	set @StrSelect+= @StrWhere
	EXEC sp_executesql @StrSelect;
END
GO
