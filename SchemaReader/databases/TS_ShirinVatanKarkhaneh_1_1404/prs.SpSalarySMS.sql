USE TS_ShirinVatanKarkhaneh_1_1404
GO
SET ANSI_NULLS, QUOTED_IDENTIFIER ON
GO
-- =========== TS-QC:UPDATED ====================
-- Author		 : TakroSystem\Jafari
-- Create date   : 1401/03/28
-- Viewed By	 : 
-- Last Modified : 
-- Last Modifier : 
-- ----------------------------------------------
-- Description	 : < ����� sms  ����>
-- ==============================================
Create PROCEDURE prs.SpSalarySMS
	@ExtraParams		NVarChar(Max) = '',
	@RepOptions			VarChar(20) = '111' ,
	@RepInfo			NVarChar(100) = '1@1@1'	
WITH ENCRYPTION
AS
BEGIN

DECLARE
	@MonthCode		Int,
	@SelectedPrs	Int = 0,
	@DecreeTypeID	VarChar(20) = Null,
	@DepartmentID	VarChar(20) = Null,
	@WorkShopID		VarChar(20) = Null,
	@JobID			VarChar(20) = Null,
	@RemainDate		Char(10) = Null,
	@LoanDate		Char(10) = Null 

	SET @MonthCode		= LTrim(pub.funSplitString(@ExtraParams, '@', 1)); 
	SET @SelectedPrs	= LTrim(pub.funSplitString(@ExtraParams, '@', 2)); 
	SET @DecreeTypeID	= LTrim(pub.funSplitString(@ExtraParams, '@', 3));
	SET @DepartmentID	= LTrim(pub.funSplitString(@ExtraParams, '@', 4));
	SET @WorkShopID		= LTrim(pub.funSplitString(@ExtraParams, '@', 5));
	SET @JobID		    = LTrim(pub.funSplitString(@ExtraParams, '@', 6));
	SET @RemainDate		= LTrim(pub.funSplitString(@ExtraParams, '@', 7));
	SET @LoanDate		= LTrim(pub.funSplitString(@ExtraParams, '@', 8));

	
	CREATE TABLE #tblBills1
	(
		PersonnelID		VarChar(20) COLLATE ARABIC_CS_AS,
		BenefitName		VarChar(50)  COLLATE ARABIC_CS_AS,
		BenefitAmount	Float,
		BenefitTime		nvarchar(30) COLLATE ARABIC_CS_AS,
		BenefitUnit		nvarchar(30) COLLATE ARABIC_CS_AS,
		BenefitType		Int,
		MonthCode		Int,
		DepartmentID	VarChar(50) 
	);
 
 

		INSERT INTO #tblBills1(PersonnelID,BenefitName,BenefitAmount,BenefitTime,BenefitUnit,BenefitType)
		EXEC [prs].[RptPrs_SalaryBillsDtl] @MonthCode, @SelectedPrs, null, null, null, null, @RemainDate, @LoanDate, @RepOptions, @RepInfo


		select  Distinct PersonnelID, 0 Benefit,0 Deduction,0 LoanAmount,0 BuyAmount
		into #tblBills2
		 FROM #tblBills1
		
		 update #tblBills2
		 set Benefit=Amount
		 from #tblBills2 a 
		 inner join (
		select  Sum(BenefitAmount) Amount,PersonnelID,BenefitType FROM #tblBills1
		where BenefitType>0
		group by PersonnelID,BenefitType
		) b on a.PersonnelID=b.PersonnelID

		 update #tblBills2
		 set Deduction=Amount
		 from #tblBills2 a 
		 inner join (
		select  Sum(BenefitAmount) Amount,PersonnelID,BenefitType FROM #tblBills1
		where BenefitType<0
		group by PersonnelID,BenefitType
		) b on a.PersonnelID=b.PersonnelID
		 

		 
		  update #tblBills2
		 set LoanAmount=ThisMonthInstallment
		 from #tblBills2 a 
		 inner join (
		select sum(ThisMonthInstallment) ThisMonthInstallment,MonthCode,PersonnelID from prs.tblInstallmentDeductionsDtl
		where MonthCode=@MonthCode
		group by PersonnelID,MonthCode
		) b on a.PersonnelID=b.PersonnelID

		
		select a.PersonnelID, [prs].[funGetPersonnelName] (a.PersonnelID,1 ) PersonnelName ,Benefit,Deduction,LoanAmount,BuyAmount , Mobile, '' AcntCode
		from #tblBills2 a
		left Join prs.tblPersonnels b on a.PersonnelID=b.PersonnelID
		ORDER BY PersonnelID

END
GO
