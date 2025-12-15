USE TS_ShirinVatanKarkhaneh_1_1404
GO
SET ANSI_NULLS, QUOTED_IDENTIFIER ON
GO
-- =========== TS-QC:UPDATED ====================
-- Author		 : Jafari	
-- Creation Date : 1402/01/28
-- Viewed By	 : 
-- Last Modified : 
-- Last Modifier : 
-- Description   : 
-- ==============================================
Create PROCEDURE prs.RptPrs_TaxNew
	@SelectedPrs	Int = 0,
	@MonthCode		Int = 0,
	@RepOptions		VarChar(10) = '110', -- bit array options
	@RepInfo		NVarChar(100) = '1@1@1@0@0' -- bit array options
WITH ENCRYPTION
AS 
---- Declarations ---------------
DECLARE @StrSelect		NVarChar(max);
DECLARE @StrWhere		NVarChar(max);
DECLARE @PersID			varchar(20);
DECLARE @BA				float;
DECLARE @CA				float;
DECLARE	@LangID			Char(1);
DECLARE	@SessionNo		Int; -- برای حالت کدهای انتخابی
DECLARE	@ReportID		Int; -- برای حالت کدهای انتخابی
Declare @YearExpertTax  int
Declare @MonthExpertTax int
DECLARE	@FiscalYear		Int
Begin --============== S T A R T  C O D E ===================================================

	SET NOCOUNT ON;

	---- Init -----------------------------------------------------------------
	IF (@RepInfo	Is Null)	SET @RepInfo = '1@1@1';
	IF (@RepOptions	Is Null)	SET @RepOptions = '0';
	IF (@SelectedPrs Is Null)	SET @SelectedPrs = 0;

	SET @LangID		= pub.funSplitString(@RepInfo, '@', 1);
	SET @SessionNo	= pub.funSplitString(@RepInfo, '@', 2);
	SET @ReportID	= pub.funSplitString(@RepInfo, '@', 3);
	-- ------------------------------------------------------------------------
	
	set @FiscalYear	=Right( DB_NAME(),4)

	select @YearExpertTax=SettingValue from pub.tblSettings where SettingKey='YearExpertTax'
	select @MonthExpertTax=SettingValue from pub.tblSettings where SettingKey='MonthExpertTax'
	
	set @YearExpertTax=isnull(@YearExpertTax,0)
	set @MonthExpertTax=isnull(@MonthExpertTax,0)

	-- Where Clause -----------------------------------------------------------
	SET @StrWhere = '(D.MonthCode <=' + str(@MonthCode) + ')'

	IF (@SelectedPrs > 0)
		SET @StrWhere = @StrWhere + ' AND ' + pub.funGetFilterString(@SessionNo, @ReportID, @SelectedPrs, 'D.PersonnelID')	
	---------------------------------------------------------------------------
	-- Select Clause ----------------------------------------------------------
	declare @var_f1 float;
	declare @var_f2 float;
	
	select top 1 @var_f1 = FromSalary
	from prs.tblTaxCalculationDtl T
	where (T.Tax <> 0) or (T.TaxPercent <> 0)
	order by FromSalary
	
	create table #tbl_Tax_Result
	(
		PersonnelID	varchar(20) collate arabic_cs_as,
		Taxable01	float,Taxable011 float,Taxable012	float,
		Taxable02	float,Taxable021 float,Taxable022	float,
		Taxable03	float,Taxable031 float,Taxable032	float,
		Taxable04	float,Taxable041 float,Taxable042	float,
		Taxable05	float,Taxable051 float,Taxable052	float,
		Taxable06	float,Taxable061 float,Taxable062	float,
		Taxable07	float,Taxable071 float,Taxable072	float,
		Taxable08	float,Taxable081 float,Taxable082	float,
		Taxable09	float,Taxable091 float,Taxable092	float,
		Taxable10	float,Taxable101 float,Taxable102	float,
		Taxable11	float,Taxable111 float,Taxable112	float,
		Taxable12	float,Taxable121 float,Taxable122	float,
		BAmount		float, -- عیدی/پاداش
		PAmount		float, -- سنوات پايانکار
		CAmount		float, -- جمع درآمد سالانه
		DAmount		float, -- معافیت
		DAmountCe	float, -- معافیت
		EAmount		float, -- مانده درآمد مشمول مالیات
		EAmountCe	float, -- مانده درآمد مشمول مالیات
		FAmount		float, --مالیات متعلقه
		FAmountCe	float, --مالیات متعلقه
		G1Amount	float, -- مالیات پرداختی تا ماه قبل
		G1AmountCe	float, -- مالیات پرداختی تا ماه قبل
		GAmount		float, -- مالیات پرداختی
		GAmountCe	float, -- مالیات پرداختی
		TEAmount	float, -- معافیت مالیات 
		Cnt			float,
		CntCe		float,
		TaxCoefficient float
	);
	
	SET @StrSelect = '
	insert into #tbl_Tax_Result
	SELECT distinct D.PersonnelID,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0
	,0
	,0
	FROM   prs.tblSalaryCalculation D 
	WHERE  ' + @StrWhere
	
	print @StrSelect;
	Exec sp_executesql @StrSelect;

	-- درآمد هر ماه
	update #tbl_Tax_Result
	set Taxable01 =  
	isnull((
		select SUM(SC.TaxableAmount)
		from prs.tblSalaryCalculation SC
				INNER JOIN prs.tblDecreeHdr DH ON DH.SerialNo = SC.DecreeSerialNo AND DH.PersonnelID = SC.PersonnelID
		where (SC.MonthCode <= @MonthCode) and (DH.TaxType <> 1) and (#tbl_Tax_Result.PersonnelID = SC.PersonnelID) and (SC.MonthCode = 1)
		and  ( @MonthExpertTax =0 or @FiscalYear<>@YearExpertTax or  (@MonthExpertTax >0 and  @FiscalYear=@YearExpertTax  and SC.MonthCode> @MonthExpertTax) ) 	 
	),0)
	,Taxable011 =  
	isnull((
		select SUM(SC.TaxableAmount-SC.TaxableAmountBenefit)
		from prs.tblSalaryCalculation SC
				INNER JOIN prs.tblDecreeHdr DH ON DH.SerialNo = SC.DecreeSerialNo AND DH.PersonnelID = SC.PersonnelID
		where (SC.MonthCode <= @MonthCode) and (DH.TaxType <> 1) and (#tbl_Tax_Result.PersonnelID = SC.PersonnelID) and (SC.MonthCode = 1)
		and  ( @MonthExpertTax =0 or @FiscalYear<>@YearExpertTax or  (@MonthExpertTax >0 and  @FiscalYear=@YearExpertTax  and SC.MonthCode> @MonthExpertTax) ) 	 
	),0)
	,Taxable012 =  
	isnull((
		select SUM(SC.TaxableAmountBenefit)
		from prs.tblSalaryCalculation SC
				INNER JOIN prs.tblDecreeHdr DH ON DH.SerialNo = SC.DecreeSerialNo AND DH.PersonnelID = SC.PersonnelID
		where (SC.MonthCode <= @MonthCode) and (DH.TaxType <> 1) and (#tbl_Tax_Result.PersonnelID = SC.PersonnelID) and (SC.MonthCode = 1)
		and  ( @MonthExpertTax =0 or @FiscalYear<>@YearExpertTax or  (@MonthExpertTax >0 and  @FiscalYear=@YearExpertTax  and SC.MonthCode> @MonthExpertTax) ) 	 
	),0)
	update #tbl_Tax_Result
	set Taxable02 =  
	isnull((
		select SUM(SC.TaxableAmount)
		from prs.tblSalaryCalculation SC
				INNER JOIN prs.tblDecreeHdr DH ON DH.SerialNo = SC.DecreeSerialNo AND DH.PersonnelID = SC.PersonnelID
		where (SC.MonthCode <= @MonthCode) and (DH.TaxType <> 1) and (#tbl_Tax_Result.PersonnelID = SC.PersonnelID) and (SC.MonthCode = 2)
		and  ( @MonthExpertTax =0 or @FiscalYear<>@YearExpertTax or  (@MonthExpertTax >0 and  @FiscalYear=@YearExpertTax  and SC.MonthCode> @MonthExpertTax) ) 	 
	),0)
	,Taxable021 =  
	isnull((
		select SUM(SC.TaxableAmount-SC.TaxableAmountBenefit)
		from prs.tblSalaryCalculation SC
				INNER JOIN prs.tblDecreeHdr DH ON DH.SerialNo = SC.DecreeSerialNo AND DH.PersonnelID = SC.PersonnelID
		where (SC.MonthCode <= @MonthCode) and (DH.TaxType <> 1) and (#tbl_Tax_Result.PersonnelID = SC.PersonnelID) and (SC.MonthCode = 2)
		and  ( @MonthExpertTax =0 or @FiscalYear<>@YearExpertTax or  (@MonthExpertTax >0 and  @FiscalYear=@YearExpertTax  and SC.MonthCode> @MonthExpertTax) ) 	 
	),0)
	,Taxable022 =  
	isnull((
		select SUM(SC.TaxableAmountBenefit)
		from prs.tblSalaryCalculation SC
				INNER JOIN prs.tblDecreeHdr DH ON DH.SerialNo = SC.DecreeSerialNo AND DH.PersonnelID = SC.PersonnelID
		where (SC.MonthCode <= @MonthCode) and (DH.TaxType <> 1) and (#tbl_Tax_Result.PersonnelID = SC.PersonnelID) and (SC.MonthCode = 2)
		and  ( @MonthExpertTax =0 or @FiscalYear<>@YearExpertTax or  (@MonthExpertTax >0 and  @FiscalYear=@YearExpertTax  and SC.MonthCode> @MonthExpertTax) ) 	 
	),0)

	update #tbl_Tax_Result
	set Taxable03 =  
	isnull((
		select SUM(SC.TaxableAmount)
		from prs.tblSalaryCalculation SC
				INNER JOIN prs.tblDecreeHdr DH ON DH.SerialNo = SC.DecreeSerialNo AND DH.PersonnelID = SC.PersonnelID
		where (SC.MonthCode <= @MonthCode) and (DH.TaxType <> 1) and (#tbl_Tax_Result.PersonnelID = SC.PersonnelID) and (SC.MonthCode = 3)
		and  ( @MonthExpertTax =0 or @FiscalYear<>@YearExpertTax or  (@MonthExpertTax >0 and  @FiscalYear=@YearExpertTax  and SC.MonthCode> @MonthExpertTax) ) 	 
	),0)
	,Taxable031 =  
	isnull((
		select SUM(SC.TaxableAmount-SC.TaxableAmountBenefit)
		from prs.tblSalaryCalculation SC
				INNER JOIN prs.tblDecreeHdr DH ON DH.SerialNo = SC.DecreeSerialNo AND DH.PersonnelID = SC.PersonnelID
		where (SC.MonthCode <= @MonthCode) and (DH.TaxType <> 1) and (#tbl_Tax_Result.PersonnelID = SC.PersonnelID) and (SC.MonthCode = 3)
		and  ( @MonthExpertTax =0 or @FiscalYear<>@YearExpertTax or  (@MonthExpertTax >0 and  @FiscalYear=@YearExpertTax  and SC.MonthCode> @MonthExpertTax) ) 	 
	),0)
	,Taxable032 =  
	isnull((
		select SUM(SC.TaxableAmountBenefit)
		from prs.tblSalaryCalculation SC
				INNER JOIN prs.tblDecreeHdr DH ON DH.SerialNo = SC.DecreeSerialNo AND DH.PersonnelID = SC.PersonnelID
		where (SC.MonthCode <= @MonthCode) and (DH.TaxType <> 1) and (#tbl_Tax_Result.PersonnelID = SC.PersonnelID) and (SC.MonthCode = 3)
		and  ( @MonthExpertTax =0 or @FiscalYear<>@YearExpertTax or  (@MonthExpertTax >0 and  @FiscalYear=@YearExpertTax  and SC.MonthCode> @MonthExpertTax) ) 	 
	),0)
	update #tbl_Tax_Result
	set Taxable04 =  
	isnull((
		select SUM(SC.TaxableAmount)
		from prs.tblSalaryCalculation SC
				INNER JOIN prs.tblDecreeHdr DH ON DH.SerialNo = SC.DecreeSerialNo AND DH.PersonnelID = SC.PersonnelID
		where (SC.MonthCode <= @MonthCode) and (DH.TaxType <> 1) and (#tbl_Tax_Result.PersonnelID = SC.PersonnelID) and (SC.MonthCode = 4)
		and  ( @MonthExpertTax =0 or @FiscalYear<>@YearExpertTax or  (@MonthExpertTax >0 and  @FiscalYear=@YearExpertTax  and SC.MonthCode> @MonthExpertTax) ) 	 
	),0)
	,Taxable041 =  
	isnull((
		select SUM(SC.TaxableAmount-SC.TaxableAmountBenefit)
		from prs.tblSalaryCalculation SC
				INNER JOIN prs.tblDecreeHdr DH ON DH.SerialNo = SC.DecreeSerialNo AND DH.PersonnelID = SC.PersonnelID
		where (SC.MonthCode <= @MonthCode) and (DH.TaxType <> 1) and (#tbl_Tax_Result.PersonnelID = SC.PersonnelID) and (SC.MonthCode = 4)
		and  ( @MonthExpertTax =0 or @FiscalYear<>@YearExpertTax or  (@MonthExpertTax >0 and  @FiscalYear=@YearExpertTax  and SC.MonthCode> @MonthExpertTax) ) 	 
	),0)
	,Taxable042 =  
	isnull((
		select SUM(SC.TaxableAmountBenefit)
		from prs.tblSalaryCalculation SC
				INNER JOIN prs.tblDecreeHdr DH ON DH.SerialNo = SC.DecreeSerialNo AND DH.PersonnelID = SC.PersonnelID
		where (SC.MonthCode <= @MonthCode) and (DH.TaxType <> 1) and (#tbl_Tax_Result.PersonnelID = SC.PersonnelID) and (SC.MonthCode = 4)
		and  ( @MonthExpertTax =0 or @FiscalYear<>@YearExpertTax or  (@MonthExpertTax >0 and  @FiscalYear=@YearExpertTax  and SC.MonthCode> @MonthExpertTax) ) 	 
	),0)

	update #tbl_Tax_Result
	set Taxable05 =  
	isnull((
		select SUM(SC.TaxableAmount)
		from prs.tblSalaryCalculation SC
				INNER JOIN prs.tblDecreeHdr DH ON DH.SerialNo = SC.DecreeSerialNo AND DH.PersonnelID = SC.PersonnelID
		where (SC.MonthCode <= @MonthCode) and (DH.TaxType <> 1) and (#tbl_Tax_Result.PersonnelID = SC.PersonnelID) and (SC.MonthCode = 5)
		and  ( @MonthExpertTax =0 or @FiscalYear<>@YearExpertTax or  (@MonthExpertTax >0 and  @FiscalYear=@YearExpertTax  and SC.MonthCode> @MonthExpertTax) ) 	 
	),0)
	,Taxable051 =  
	isnull((
		select SUM(SC.TaxableAmount-SC.TaxableAmountBenefit)
		from prs.tblSalaryCalculation SC
				INNER JOIN prs.tblDecreeHdr DH ON DH.SerialNo = SC.DecreeSerialNo AND DH.PersonnelID = SC.PersonnelID
		where (SC.MonthCode <= @MonthCode) and (DH.TaxType <> 1) and (#tbl_Tax_Result.PersonnelID = SC.PersonnelID) and (SC.MonthCode = 5)
		and  ( @MonthExpertTax =0 or @FiscalYear<>@YearExpertTax or  (@MonthExpertTax >0 and  @FiscalYear=@YearExpertTax  and SC.MonthCode> @MonthExpertTax) ) 	 
	),0)
	,Taxable052 =  
	isnull((
		select SUM(SC.TaxableAmountBenefit)
		from prs.tblSalaryCalculation SC
				INNER JOIN prs.tblDecreeHdr DH ON DH.SerialNo = SC.DecreeSerialNo AND DH.PersonnelID = SC.PersonnelID
		where (SC.MonthCode <= @MonthCode) and (DH.TaxType <> 1) and (#tbl_Tax_Result.PersonnelID = SC.PersonnelID) and (SC.MonthCode = 5)
		and  ( @MonthExpertTax =0 or @FiscalYear<>@YearExpertTax or  (@MonthExpertTax >0 and  @FiscalYear=@YearExpertTax  and SC.MonthCode> @MonthExpertTax) ) 	 
	),0)

	update #tbl_Tax_Result
	set Taxable06 =  
	isnull((
		select SUM(SC.TaxableAmount)
		from prs.tblSalaryCalculation SC
				INNER JOIN prs.tblDecreeHdr DH ON DH.SerialNo = SC.DecreeSerialNo AND DH.PersonnelID = SC.PersonnelID
		where (SC.MonthCode <= @MonthCode) and (DH.TaxType <> 1) and (#tbl_Tax_Result.PersonnelID = SC.PersonnelID) and (SC.MonthCode = 6)
		and  ( @MonthExpertTax =0 or @FiscalYear<>@YearExpertTax or  (@MonthExpertTax >0 and  @FiscalYear=@YearExpertTax  and SC.MonthCode> @MonthExpertTax) ) 	 
	),0)
	,Taxable061 =  
	isnull((
		select SUM(SC.TaxableAmount-SC.TaxableAmountBenefit)
		from prs.tblSalaryCalculation SC
				INNER JOIN prs.tblDecreeHdr DH ON DH.SerialNo = SC.DecreeSerialNo AND DH.PersonnelID = SC.PersonnelID
		where (SC.MonthCode <= @MonthCode) and (DH.TaxType <> 1) and (#tbl_Tax_Result.PersonnelID = SC.PersonnelID) and (SC.MonthCode = 6)
		and  ( @MonthExpertTax =0 or @FiscalYear<>@YearExpertTax or  (@MonthExpertTax >0 and  @FiscalYear=@YearExpertTax  and SC.MonthCode> @MonthExpertTax) ) 	 
	),0)
	,Taxable062 =  
	isnull((
		select SUM(SC.TaxableAmountBenefit)
		from prs.tblSalaryCalculation SC
				INNER JOIN prs.tblDecreeHdr DH ON DH.SerialNo = SC.DecreeSerialNo AND DH.PersonnelID = SC.PersonnelID
		where (SC.MonthCode <= @MonthCode) and (DH.TaxType <> 1) and (#tbl_Tax_Result.PersonnelID = SC.PersonnelID) and (SC.MonthCode = 6)
		and  ( @MonthExpertTax =0 or @FiscalYear<>@YearExpertTax or  (@MonthExpertTax >0 and  @FiscalYear=@YearExpertTax  and SC.MonthCode> @MonthExpertTax) ) 	 
	),0)

	update #tbl_Tax_Result
	set Taxable07 =  
	isnull((
		select SUM(SC.TaxableAmount)
		from prs.tblSalaryCalculation SC
				INNER JOIN prs.tblDecreeHdr DH ON DH.SerialNo = SC.DecreeSerialNo AND DH.PersonnelID = SC.PersonnelID
		where (SC.MonthCode <= @MonthCode) and (DH.TaxType <> 1) and (#tbl_Tax_Result.PersonnelID = SC.PersonnelID) and (SC.MonthCode = 7)
		and  ( @MonthExpertTax =0 or @FiscalYear<>@YearExpertTax or  (@MonthExpertTax >0 and  @FiscalYear=@YearExpertTax  and SC.MonthCode> @MonthExpertTax) ) 	 
	),0)
	,Taxable071 =  
	isnull((
		select SUM(SC.TaxableAmount-SC.TaxableAmountBenefit)
		from prs.tblSalaryCalculation SC
				INNER JOIN prs.tblDecreeHdr DH ON DH.SerialNo = SC.DecreeSerialNo AND DH.PersonnelID = SC.PersonnelID
		where (SC.MonthCode <= @MonthCode) and (DH.TaxType <> 1) and (#tbl_Tax_Result.PersonnelID = SC.PersonnelID) and (SC.MonthCode = 7)
		and  ( @MonthExpertTax =0 or @FiscalYear<>@YearExpertTax or  (@MonthExpertTax >0 and  @FiscalYear=@YearExpertTax  and SC.MonthCode> @MonthExpertTax) ) 	 
	),0)
	,Taxable072 =  
	isnull((
		select SUM(SC.TaxableAmountBenefit)
		from prs.tblSalaryCalculation SC
				INNER JOIN prs.tblDecreeHdr DH ON DH.SerialNo = SC.DecreeSerialNo AND DH.PersonnelID = SC.PersonnelID
		where (SC.MonthCode <= @MonthCode) and (DH.TaxType <> 1) and (#tbl_Tax_Result.PersonnelID = SC.PersonnelID) and (SC.MonthCode = 7)
		and  ( @MonthExpertTax =0 or @FiscalYear<>@YearExpertTax or  (@MonthExpertTax >0 and  @FiscalYear=@YearExpertTax  and SC.MonthCode> @MonthExpertTax) ) 	 
	),0)
	update #tbl_Tax_Result
	set Taxable08 =  
	isnull((
		select SUM(SC.TaxableAmount)
		from prs.tblSalaryCalculation SC
				INNER JOIN prs.tblDecreeHdr DH ON DH.SerialNo = SC.DecreeSerialNo AND DH.PersonnelID = SC.PersonnelID
		where (SC.MonthCode <= @MonthCode) and (DH.TaxType <> 1) and (#tbl_Tax_Result.PersonnelID = SC.PersonnelID) and (SC.MonthCode = 8)
		and  ( @MonthExpertTax =0 or @FiscalYear<>@YearExpertTax or  (@MonthExpertTax >0 and  @FiscalYear=@YearExpertTax  and SC.MonthCode> @MonthExpertTax) ) 	 
	),0)
	,Taxable081 =  
	isnull((
		select SUM(SC.TaxableAmount-SC.TaxableAmountBenefit)
		from prs.tblSalaryCalculation SC
				INNER JOIN prs.tblDecreeHdr DH ON DH.SerialNo = SC.DecreeSerialNo AND DH.PersonnelID = SC.PersonnelID
		where (SC.MonthCode <= @MonthCode) and (DH.TaxType <> 1) and (#tbl_Tax_Result.PersonnelID = SC.PersonnelID) and (SC.MonthCode = 8)
		and  ( @MonthExpertTax =0 or @FiscalYear<>@YearExpertTax or  (@MonthExpertTax >0 and  @FiscalYear=@YearExpertTax  and SC.MonthCode> @MonthExpertTax) ) 	 
	),0)
	,Taxable082 =  
	isnull((
		select SUM(SC.TaxableAmountBenefit)
		from prs.tblSalaryCalculation SC
				INNER JOIN prs.tblDecreeHdr DH ON DH.SerialNo = SC.DecreeSerialNo AND DH.PersonnelID = SC.PersonnelID
		where (SC.MonthCode <= @MonthCode) and (DH.TaxType <> 1) and (#tbl_Tax_Result.PersonnelID = SC.PersonnelID) and (SC.MonthCode = 8)
		and  ( @MonthExpertTax =0 or @FiscalYear<>@YearExpertTax or  (@MonthExpertTax >0 and  @FiscalYear=@YearExpertTax  and SC.MonthCode> @MonthExpertTax) ) 	 
	),0)

	update #tbl_Tax_Result
	set Taxable09 =  
	isnull((
		select SUM(SC.TaxableAmount)
		from prs.tblSalaryCalculation SC
				INNER JOIN prs.tblDecreeHdr DH ON DH.SerialNo = SC.DecreeSerialNo AND DH.PersonnelID = SC.PersonnelID
		where (SC.MonthCode <= @MonthCode) and (DH.TaxType <> 1) and (#tbl_Tax_Result.PersonnelID = SC.PersonnelID) and (SC.MonthCode = 9)
		and  ( @MonthExpertTax =0 or @FiscalYear<>@YearExpertTax or  (@MonthExpertTax >0 and  @FiscalYear=@YearExpertTax  and SC.MonthCode> @MonthExpertTax) ) 	 
	),0)
	,Taxable091 =  
	isnull((
		select SUM(SC.TaxableAmount-SC.TaxableAmountBenefit)
		from prs.tblSalaryCalculation SC
				INNER JOIN prs.tblDecreeHdr DH ON DH.SerialNo = SC.DecreeSerialNo AND DH.PersonnelID = SC.PersonnelID
		where (SC.MonthCode <= @MonthCode) and (DH.TaxType <> 1) and (#tbl_Tax_Result.PersonnelID = SC.PersonnelID) and (SC.MonthCode = 9)
		and  ( @MonthExpertTax =0 or @FiscalYear<>@YearExpertTax or  (@MonthExpertTax >0 and  @FiscalYear=@YearExpertTax  and SC.MonthCode> @MonthExpertTax) ) 	 
	),0)
	,Taxable092 =  
	isnull((
		select SUM(SC.TaxableAmountBenefit)
		from prs.tblSalaryCalculation SC
				INNER JOIN prs.tblDecreeHdr DH ON DH.SerialNo = SC.DecreeSerialNo AND DH.PersonnelID = SC.PersonnelID
		where (SC.MonthCode <= @MonthCode) and (DH.TaxType <> 1) and (#tbl_Tax_Result.PersonnelID = SC.PersonnelID) and (SC.MonthCode = 9)
		and  ( @MonthExpertTax =0 or @FiscalYear<>@YearExpertTax or  (@MonthExpertTax >0 and  @FiscalYear=@YearExpertTax  and SC.MonthCode> @MonthExpertTax) ) 	 
	),0)
	update #tbl_Tax_Result
	set Taxable10 =  
	isnull((
		select SUM(SC.TaxableAmount)
		from prs.tblSalaryCalculation SC
				INNER JOIN prs.tblDecreeHdr DH ON DH.SerialNo = SC.DecreeSerialNo AND DH.PersonnelID = SC.PersonnelID
		where (SC.MonthCode <= @MonthCode) and (DH.TaxType <> 1) and (#tbl_Tax_Result.PersonnelID = SC.PersonnelID) and (SC.MonthCode = 10)
		and  ( @MonthExpertTax =0 or @FiscalYear<>@YearExpertTax or  (@MonthExpertTax >0 and  @FiscalYear=@YearExpertTax  and SC.MonthCode> @MonthExpertTax) ) 	 
	),0)
	, Taxable101 =  
	isnull((
		select SUM(SC.TaxableAmount-SC.TaxableAmountBenefit)
		from prs.tblSalaryCalculation SC
				INNER JOIN prs.tblDecreeHdr DH ON DH.SerialNo = SC.DecreeSerialNo AND DH.PersonnelID = SC.PersonnelID
		where (SC.MonthCode <= @MonthCode) and (DH.TaxType <> 1) and (#tbl_Tax_Result.PersonnelID = SC.PersonnelID) and (SC.MonthCode = 10)
		and  ( @MonthExpertTax =0 or @FiscalYear<>@YearExpertTax or  (@MonthExpertTax >0 and  @FiscalYear=@YearExpertTax  and SC.MonthCode> @MonthExpertTax) ) 	 
	),0)
	, Taxable102 =  
	isnull((
		select SUM(SC.TaxableAmountBenefit)
		from prs.tblSalaryCalculation SC
				INNER JOIN prs.tblDecreeHdr DH ON DH.SerialNo = SC.DecreeSerialNo AND DH.PersonnelID = SC.PersonnelID
		where (SC.MonthCode <= @MonthCode) and (DH.TaxType <> 1) and (#tbl_Tax_Result.PersonnelID = SC.PersonnelID) and (SC.MonthCode = 10)
		and  ( @MonthExpertTax =0 or @FiscalYear<>@YearExpertTax or  (@MonthExpertTax >0 and  @FiscalYear=@YearExpertTax  and SC.MonthCode> @MonthExpertTax) ) 	 
	),0)

	update #tbl_Tax_Result
	set Taxable11 = 
	isnull((
		select SUM(SC.TaxableAmount)
		from prs.tblSalaryCalculation SC
				INNER JOIN prs.tblDecreeHdr DH ON DH.SerialNo = SC.DecreeSerialNo AND DH.PersonnelID = SC.PersonnelID
		where (SC.MonthCode <= @MonthCode) and (DH.TaxType <> 1) and (#tbl_Tax_Result.PersonnelID = SC.PersonnelID) and (SC.MonthCode = 11)
		and  ( @MonthExpertTax =0 or @FiscalYear<>@YearExpertTax or  (@MonthExpertTax >0 and  @FiscalYear=@YearExpertTax  and SC.MonthCode> @MonthExpertTax) ) 	 
	),0)
	,Taxable111 = 
	isnull((
		select SUM(SC.TaxableAmount-SC.TaxableAmountBenefit)
		from prs.tblSalaryCalculation SC
				INNER JOIN prs.tblDecreeHdr DH ON DH.SerialNo = SC.DecreeSerialNo AND DH.PersonnelID = SC.PersonnelID
		where (SC.MonthCode <= @MonthCode) and (DH.TaxType <> 1) and (#tbl_Tax_Result.PersonnelID = SC.PersonnelID) and (SC.MonthCode = 11)
		and  ( @MonthExpertTax =0 or @FiscalYear<>@YearExpertTax or  (@MonthExpertTax >0 and  @FiscalYear=@YearExpertTax  and SC.MonthCode> @MonthExpertTax) ) 	 
	),0)
	,Taxable112 = 
	isnull((
		select SUM(SC.TaxableAmountBenefit)
		from prs.tblSalaryCalculation SC
				INNER JOIN prs.tblDecreeHdr DH ON DH.SerialNo = SC.DecreeSerialNo AND DH.PersonnelID = SC.PersonnelID
		where (SC.MonthCode <= @MonthCode) and (DH.TaxType <> 1) and (#tbl_Tax_Result.PersonnelID = SC.PersonnelID) and (SC.MonthCode = 11)
		and  ( @MonthExpertTax =0 or @FiscalYear<>@YearExpertTax or  (@MonthExpertTax >0 and  @FiscalYear=@YearExpertTax  and SC.MonthCode> @MonthExpertTax) ) 	 
	),0)

	update #tbl_Tax_Result
	set Taxable12 = 
	isnull((
		select SUM(SC.TaxableAmount)
		from prs.tblSalaryCalculation SC
				INNER JOIN prs.tblDecreeHdr DH ON DH.SerialNo = SC.DecreeSerialNo AND DH.PersonnelID = SC.PersonnelID
		where (SC.MonthCode <= @MonthCode) and (DH.TaxType <> 1) and (#tbl_Tax_Result.PersonnelID = SC.PersonnelID) and (SC.MonthCode = 12)
		and  ( @MonthExpertTax =0 or @FiscalYear<>@YearExpertTax or  (@MonthExpertTax >0 and  @FiscalYear=@YearExpertTax  and SC.MonthCode> @MonthExpertTax) ) 	 
	),0)
	,Taxable121 = 
	isnull((
		select SUM(SC.TaxableAmount-SC.TaxableAmountBenefit)
		from prs.tblSalaryCalculation SC
				INNER JOIN prs.tblDecreeHdr DH ON DH.SerialNo = SC.DecreeSerialNo AND DH.PersonnelID = SC.PersonnelID
		where (SC.MonthCode <= @MonthCode) and (DH.TaxType <> 1) and (#tbl_Tax_Result.PersonnelID = SC.PersonnelID) and (SC.MonthCode = 12)
		and  ( @MonthExpertTax =0 or @FiscalYear<>@YearExpertTax or  (@MonthExpertTax >0 and  @FiscalYear=@YearExpertTax  and SC.MonthCode> @MonthExpertTax) ) 	 
	),0)
	,Taxable122 = 
	isnull((
		select SUM(SC.TaxableAmountBenefit)
		from prs.tblSalaryCalculation SC
				INNER JOIN prs.tblDecreeHdr DH ON DH.SerialNo = SC.DecreeSerialNo AND DH.PersonnelID = SC.PersonnelID
		where (SC.MonthCode <= @MonthCode) and (DH.TaxType <> 1) and (#tbl_Tax_Result.PersonnelID = SC.PersonnelID) and (SC.MonthCode = 12)
		and  ( @MonthExpertTax =0 or @FiscalYear<>@YearExpertTax or  (@MonthExpertTax >0 and  @FiscalYear=@YearExpertTax  and SC.MonthCode> @MonthExpertTax) ) 	 
	),0)
	
	--B عیدی و پاداش
	update #tbl_Tax_Result
	set BAmount =  
	isnull((
		select SUM(C.Cost)
		from prs.tblCelebrationDtl C
		where (C.MonthCode <= @MonthCode) and (#tbl_Tax_Result.PersonnelID = C.PersonnelID) and (C.ProcessID = 320)
	),0)

	if @MonthCode=12
		update #tbl_Tax_Result
		set BAmount = BAmount+
		isnull((
			select SUM(C.Cost)
			from prs.tblCelebrationDtl C
			where (C.MonthCode = 13) and (#tbl_Tax_Result.PersonnelID = C.PersonnelID) and (C.ProcessID = 320)
		),0)
	
	--P سنوات و پايانکار
	update #tbl_Tax_Result
	set PAmount = 
	isnull((
		select SUM(C.Cost)
		from prs.tblCelebrationDtl C
		where (C.MonthCode <= @MonthCode) and (#tbl_Tax_Result.PersonnelID = C.PersonnelID) and (C.ProcessID = 325)
	),0)
	if @MonthCode=12
		update #tbl_Tax_Result
		set PAmount = PAmount+
		isnull((
			select SUM(C.Cost)
			from prs.tblCelebrationDtl C
			where (C.MonthCode = 13) and (#tbl_Tax_Result.PersonnelID = C.PersonnelID) and (C.ProcessID = 325)
		),0)	

	update #tbl_Tax_Result
	set TaxCoefficient = 
	isnull((
		select top 1 TaxCoefficient
		from prs.tblSalaryCalculation SC
		--				INNER JOIN prs.tblDecreeHdr DH ON DH.SerialNo = SC.DecreeSerialNo AND DH.PersonnelID = SC.PersonnelID
		where (SC.MonthCode <= @MonthCode) and (#tbl_Tax_Result.PersonnelID = SC.PersonnelID) --and (SC.MonthCode = 1)
		order by MonthCode Desc 
		
	),0)

Declare @TaxForCelebration as bit
Declare @TaxForHistoryCalcDaysBase as bit

select @TaxForCelebration=SettingValue from pub.tblSettings where SettingKey='TaxForCelebration'
select @TaxForHistoryCalcDaysBase=SettingValue from pub.tblSettings where SettingKey='TaxForHistoryCalcDaysBase'

	--C جمع درآمد سالانه
	update #tbl_Tax_Result
	set CAmount = Taxable01 + Taxable02 + Taxable03 + Taxable04 + Taxable05 + Taxable06 + Taxable07 + Taxable08 + Taxable09 + Taxable10 + Taxable11 + Taxable12
	from #tbl_Tax_Result t
	 left Join prs.tblPersonnels  p 
	 on p.PersonnelID=t.PersonnelID	


	Declare @TaxCoefficient float
			
	--D معافیت
	DECLARE csr_Tax1 CURSOR FOR
		select PersonnelID, BAmount, CAmount,TaxCoefficient
		from #tbl_Tax_Result
		order by PersonnelID
	
	OPEN csr_Tax1

	FETCH NEXT FROM csr_Tax1 INTO @PersID, @BA, @CA,@TaxCoefficient

	WHILE (@@Fetch_Status = 0)
	BEGIN
		select @var_f2 = MAX(S.MonthCode) - MIN(S.MonthCode) + 1
		from prs.tblSalaryCalculation S
		where (S.MonthCode <= @MonthCode) and (S.PersonnelID = @PersID)
		
		if (@var_f2 is null)
			set @var_f2 = 0;
			
		if (@BA > 0)
			set @CA = @CA - (@var_f2 / 12) * @var_f1
			--set @var_f2 = @var_f2 + (@var_f2 / 12);
			
		DECLARE @prs_UseInsuranceHireDateForCalcAdjust bit
		SET @prs_UseInsuranceHireDateForCalcAdjust  = 'False'	
		
		SELECT @prs_UseInsuranceHireDateForCalcAdjust = SettingValue	FROM pub.tblSettings	WHERE SettingKey = 'prs_UseInsuranceHireDateForCalcAdjust'


		Declare @HireDate				char(10)
		Declare @MonthCount				float
		Declare @MonthCountCe			float
		Declare @MonthCount2			float
		Declare @IncomeTaxableAmount	int
		Declare @IncomeTaxableAmountCelebration	int
		Declare @MonthTaxableAmount		int
		DECLARE	@ManualTotalDays		float		
	
		set @MonthCount =12
		set @MonthCountCe =1
		set @IncomeTaxableAmount =0
		set @ManualTotalDays =0
				
		SELECT @ManualTotalDays=sum(ManualTotalDays)
		FROM  prs.tblCelebrationDtl 
		WHERE ProcessID=320		AND MonthCode<=@MonthCount        and   PersonnelID = @PersID
		and  ( @MonthExpertTax =0 or @FiscalYear<>@YearExpertTax or  (@MonthExpertTax >0 and  @FiscalYear=@YearExpertTax  and MonthCode> @MonthExpertTax) ) 	        		
		
		SELECT @HireDate= case when @prs_UseInsuranceHireDateForCalcAdjust  = 'True'	then InsuranceHireDate  else  HireDate end ,@IncomeTaxableAmount=case when YearTaxableAmount=RIGHT(DB_NAME(),4) then IncomeTaxableAmount else 0 end ,@IncomeTaxableAmountCelebration=case when YearTaxableAmount=RIGHT(DB_NAME(),4) then IncomeTaxableAmountCelebration else 0 end 
									,@MonthTaxableAmount=case when YearTaxableAmount=RIGHT(DB_NAME(),4) then MonthTaxableAmount else 0 end 
		FROM prs.tblPersonnels 
        WHERE  PersonnelID = @PersID
 
    If substring(@HireDate, 1, 4) = @FiscalYear And  substring(@HireDate, 6, 2) >1  and  ( @MonthExpertTax =0 or @FiscalYear<>@YearExpertTax or  (@MonthExpertTax >0 and  @FiscalYear=@YearExpertTax  and substring(@HireDate, 6, 2)> @MonthExpertTax) ) 	 
			set @MonthCount = @MonthCount - substring(@HireDate, 6, 2) + 1+@MonthTaxableAmount-(@MonthCount-@MonthCode)
	else if @RepOptions='1'
		begin	 
		set @MonthCount2=0
		select  @MonthCount2=@MonthCount2+1 from #tbl_Tax_Result where Taxable01=0	and (#tbl_Tax_Result.PersonnelID = @PersID)
		select  @MonthCount2=@MonthCount2+1 from #tbl_Tax_Result where Taxable02=0	and (#tbl_Tax_Result.PersonnelID = @PersID)
		select  @MonthCount2=@MonthCount2+1 from #tbl_Tax_Result where Taxable03=0	and (#tbl_Tax_Result.PersonnelID = @PersID)
		select  @MonthCount2=@MonthCount2+1 from #tbl_Tax_Result where Taxable04=0	and (#tbl_Tax_Result.PersonnelID = @PersID)
		select  @MonthCount2=@MonthCount2+1 from #tbl_Tax_Result where Taxable05=0	and (#tbl_Tax_Result.PersonnelID = @PersID)
		select  @MonthCount2=@MonthCount2+1 from #tbl_Tax_Result where Taxable06=0	and (#tbl_Tax_Result.PersonnelID = @PersID)
		select  @MonthCount2=@MonthCount2+1 from #tbl_Tax_Result where Taxable07=0	and (#tbl_Tax_Result.PersonnelID = @PersID)
		select  @MonthCount2=@MonthCount2+1 from #tbl_Tax_Result where Taxable08=0	and (#tbl_Tax_Result.PersonnelID = @PersID)
		select  @MonthCount2=@MonthCount2+1 from #tbl_Tax_Result where Taxable09=0	and (#tbl_Tax_Result.PersonnelID = @PersID)
		select  @MonthCount2=@MonthCount2+1 from #tbl_Tax_Result where Taxable10=0	and (#tbl_Tax_Result.PersonnelID = @PersID)
		select  @MonthCount2=@MonthCount2+1 from #tbl_Tax_Result where Taxable11=0	and (#tbl_Tax_Result.PersonnelID = @PersID)
		select  @MonthCount2=@MonthCount2+1 from #tbl_Tax_Result where Taxable12=0	and (#tbl_Tax_Result.PersonnelID = @PersID)
			
		set @MonthCount = @MonthCount - @MonthCount2
	
	end			
	 else if @MonthExpertTax >0 and  @FiscalYear=@YearExpertTax  
		 set @MonthCount -=@MonthExpertTax

	set @ManualTotalDays=isnull(@ManualTotalDays,0)
	
 	if (@TaxForCelebration=1)
		begin
			if @TaxCoefficient=0
				set @MonthCount =@MonthCount+ (isnull(@ManualTotalDays,0) / case when [pub].[FunGetMonthDays](ltrim(rtrim(str(@FiscalYear)))+'/12/01' ) =30 then 366 else  365 end )			
			else
				set @MonthCount =@MonthCount+ @TaxCoefficient

			if @ManualTotalDays=0 and @TaxCoefficient=0
			begin	
				Declare @days float=0
				Declare @Yeardays int=[pub].[FunGetMonthDay](@FiscalYear,12)
				if @Yeardays=30
					set @Yeardays=366
						else
					set @Yeardays=365
				if @MonthCount<=6
					set @days =@MonthCount*31
				else
				begin
					set @days =6*31
					if @MonthCount<12
						set @days =@days + (@MonthCount-6)*30
					else
						set @days =@Yeardays
				end	
				set @MonthCount=@MonthCount+(@days/@Yeardays)
			end 
		end 	
		
		set @MonthCountCe=@MonthCount-floor(@MonthCount)
		set @MonthCount=@MonthCount-@MonthCountCe
		
		if @MonthCount= 13 and @MonthCountCe=0
		begin
			 set @MonthCountCe=1
			 set @MonthCount-=1
		end 

		update #tbl_Tax_Result
		set Cnt = @MonthCount
		where (#tbl_Tax_Result.PersonnelID = @PersID)

		update #tbl_Tax_Result
		set CntCe = isnull(
		(
			select	TaxCoefficientCel
			from prs.tblSalaryCalculation S
			where S.PersonnelID = #tbl_Tax_Result.PersonnelID and (S.MonthCode = @MonthCode)		
		),0)
		
		update #tbl_Tax_Result
		set DAmount = ((@var_f1-1) * @MonthCount) 
		where (#tbl_Tax_Result.PersonnelID = @PersID)
					
		update #tbl_Tax_Result
		set DAmountCe = (@var_f1-1)  
		where (#tbl_Tax_Result.PersonnelID = @PersID)
					
		
		--F مالیات متعلقه
	update #tbl_Tax_Result
	set FAmount = isnull(
	(
		select	sum(S.TaxAmount) 
		from prs.tblSalaryCalculation S
		where S.PersonnelID = @PersID and (S.MonthCode <= @MonthCode)
		and  ( @MonthExpertTax =0 or @FiscalYear<>@YearExpertTax or  (@MonthExpertTax >0 and  @FiscalYear=@YearExpertTax  and S.MonthCode> @MonthExpertTax) ) 	 
	),0)
	where PersonnelID = @PersID 

			--F مالیات متعلقه
	update #tbl_Tax_Result
	set FAmountCe = isnull(
	(
		select	 	sum(S.TaxAmountCelebration)
		from prs.tblSalaryCalculation S
		where S.PersonnelID = @PersID and (S.MonthCode <= @MonthCode)
		and  ( @MonthExpertTax =0 or @FiscalYear<>@YearExpertTax or  (@MonthExpertTax >0 and  @FiscalYear=@YearExpertTax  and S.MonthCode> @MonthExpertTax) ) 	 
	),0)
	where PersonnelID = @PersID 

	--G مالیات پرداختی
	update #tbl_Tax_Result
	set G1Amount = isnull(
	(
		select	sum(S.TaxAmount) 
		from prs.tblSalaryCalculation S
		where S.PersonnelID = @PersID and (S.MonthCode < @MonthCode)
		and  ( @MonthExpertTax =0 or @FiscalYear<>@YearExpertTax or  (@MonthExpertTax >0 and  @FiscalYear=@YearExpertTax  and S.MonthCode> @MonthExpertTax) ) 
	),0)
	where PersonnelID = @PersID 

		--G مالیات پرداختی
	update #tbl_Tax_Result
	set G1AmountCe = isnull(
	(
		select	 sum(S.TaxAmountCelebration)
		from prs.tblSalaryCalculation S
		where S.PersonnelID = @PersID and (S.MonthCode < @MonthCode)
		and  ( @MonthExpertTax =0 or @FiscalYear<>@YearExpertTax or  (@MonthExpertTax >0 and  @FiscalYear=@YearExpertTax  and S.MonthCode> @MonthExpertTax) ) 
	),0)
	where PersonnelID = @PersID 


	--G مالیات پرداختی
	update #tbl_Tax_Result
	set GAmount = isnull(
	(
		select	sum(S.TaxAmount) 
		from prs.tblSalaryCalculation S
		where S.PersonnelID = @PersID and (S.MonthCode <= @MonthCode)
		and  ( @MonthExpertTax =0 or @FiscalYear<>@YearExpertTax or  (@MonthExpertTax >0 and  @FiscalYear=@YearExpertTax  and S.MonthCode> @MonthExpertTax) ) 
	),0)
	where PersonnelID = @PersID 
	 
	 -- معافیت مالیات  
	update #tbl_Tax_Result
	set TEAmount = 
	(
		select	sum(S.taxExemptAmount)+sum(S.taxCelebrationExemptAmount)
		from prs.tblSalaryCalculation S
		where S.PersonnelID = @PersID and (S.MonthCode <= @MonthCode)
		and  ( @MonthExpertTax =0 or @FiscalYear<>@YearExpertTax or  (@MonthExpertTax >0 and  @FiscalYear=@YearExpertTax  and S.MonthCode> @MonthExpertTax) ) 
	)
	where PersonnelID = @PersID  

	--G مالیات پرداختی
	update #tbl_Tax_Result
	set GAmountCe = isnull(
	(
		select	 sum(S.TaxAmountCelebration)
		from prs.tblSalaryCalculation S
		where S.PersonnelID = @PersID and (S.MonthCode <= @MonthCode)
		and  ( @MonthExpertTax =0 or @FiscalYear<>@YearExpertTax or  (@MonthExpertTax >0 and  @FiscalYear=@YearExpertTax  and S.MonthCode> @MonthExpertTax) ) 
	),0)
	where PersonnelID = @PersID 
	 

				--C جمع درآمد سالانه
				update #tbl_Tax_Result
				set CAmount =CAmount 	+   isnull(case when p.YearTaxableAmount=RIGHT(DB_NAME(),4) then p.IncomeTaxableAmount else 0 end ,0) +   isnull(case when p.YearTaxableAmount=RIGHT(DB_NAME(),4) then p.IncomeTaxableAmountCelebration else 0 end ,0) 
				from #tbl_Tax_Result t
				left Join prs.tblPersonnels  p 
				on p.PersonnelID=t.PersonnelID
				where t.PersonnelID=@PersID
				
				--F مالیات متعلقه
				update #tbl_Tax_Result
				set FAmount = FAmount	+  isnull(case when p.YearTaxableAmount=RIGHT(DB_NAME(),4) then p.PayedTaxAmount else 0 end ,0)
				from #tbl_Tax_Result t
				left Join prs.tblPersonnels  p 
				on p.PersonnelID=t.PersonnelID
				where t.PersonnelID=@PersID		
				
				--F مالیات متعلقه
				update #tbl_Tax_Result
				set FAmountCe = FAmountCe	+  isnull(case when p.YearTaxableAmount=RIGHT(DB_NAME(),4) then p.PayedTaxAmountCelebration else 0 end ,0)
				from #tbl_Tax_Result t
				left Join prs.tblPersonnels  p 
				on p.PersonnelID=t.PersonnelID
				where t.PersonnelID=@PersID		
				
				--G مالیات پرداختی
				update #tbl_Tax_Result
				set G1Amount = G1Amount	+ isnull(case when p.YearTaxableAmount=RIGHT(DB_NAME(),4) then p.PayedTaxAmount else 0 end ,0)	
				from #tbl_Tax_Result t
				left Join prs.tblPersonnels  p 
				on p.PersonnelID=t.PersonnelID
				where t.PersonnelID=@PersID
				
				update #tbl_Tax_Result
				set G1AmountCe = G1AmountCe	+ isnull(case when p.YearTaxableAmount=RIGHT(DB_NAME(),4) then p.PayedTaxAmountCelebration else 0 end ,0)	
				from #tbl_Tax_Result t
				left Join prs.tblPersonnels  p 
				on p.PersonnelID=t.PersonnelID
				where t.PersonnelID=@PersID
				

				--G مالیات ماه آخر
				update #tbl_Tax_Result
				set GAmount = GAmount	+ isnull(case when p.YearTaxableAmount=RIGHT(DB_NAME(),4) then p.PayedTaxAmount else 0 end ,0)	
				from #tbl_Tax_Result t
				left Join prs.tblPersonnels  p 
				on p.PersonnelID=t.PersonnelID
				where t.PersonnelID=@PersID	 

				update #tbl_Tax_Result
				set GAmountCe = GAmountCe	+ isnull(case when p.YearTaxableAmount=RIGHT(DB_NAME(),4) then p.PayedTaxAmountCelebration else 0 end ,0)
				from #tbl_Tax_Result t
				left Join prs.tblPersonnels  p 
				on p.PersonnelID=t.PersonnelID
				where t.PersonnelID=@PersID	 
	
	 
			----E مانده درآمد مشمول
		update #tbl_Tax_Result
		set EAmount = case when (CAmount - DAmount) > 0 then (CAmount - DAmount) else 0 end
		where (#tbl_Tax_Result.PersonnelID = @PersID)

		update #tbl_Tax_Result
		set EAmountCe = case when (BAmount - DAmountCe) > 0 then (BAmount - DAmountCe) else 0 end
		where (#tbl_Tax_Result.PersonnelID = @PersID)

	 

		FETCH NEXT FROM csr_Tax1 INTO @PersID, @BA, @CA,@TaxCoefficient
	END

	CLOSE		csr_Tax1
	DEALLOCATE	csr_Tax1
	----- در مشخصات اگر تعداد مهاههای کارکرد قیل استخدام درست نباشد تعداد ماه بیشتر از 13 میشود	
		update #tbl_Tax_Result	set Cnt=13 where Cnt>13		 

	select	
			R.GAmountCe as 'مالیات پرداختی عیدی',
			R.GAmountCe - R.G1AmountCe as 'مالیات ماه آخرعیدی ',
			R.G1AmountCe as 'مالیات پرداختی قبلی عیدی ',
			R.FAmountCe as 'مالیات متعلقه عیدی',
			R.EAmountCe as 'مانده درآمد مشمول مالیات عیدی',
			R.DAmountCe as 'معافیت سالانه عیدی',
			R.BAmount as ' جمع درآمد عیدی و پاداش',
			R.CntCe as ' تعداد ماه عیدی',
			R.GAmount as 'مالیات پرداختی',
			R.TEAmount as 'معافیت مالیات ',
			R.GAmount - R.G1Amount as 'مالیات ماه آخر',
			R.G1Amount as 'مالیات پرداختی قبلی ',
			R.FAmount as 'مالیات متعلقه',
			R.EAmount as 'مانده درآمد مشمول مالیات',
			R.DAmount as 'معافیت سالانه',
			R.CAmount as 'جمع درآمد سالانه',
			R.Cnt as 'تعداد ماه',
			R.PAmount as 'سنوات و پايانکار',
			R.Taxable12 as 'درآمد اسفند',
			R.Taxable121 as 'جدولی اسفند',
			R.Taxable122 as 'درصدی اسفند',
			R.Taxable11 as 'درآمد بهمن',
			R.Taxable111 as 'جدولی بهمن',
			R.Taxable112 as 'درصدی بهمن',
			R.Taxable10 as 'درآمد دی',
			R.Taxable101 as 'جدولی دی',
			R.Taxable102 as 'درصدی دی',
			R.Taxable09 as 'درآمد آذر',
			R.Taxable091 as 'جدولی آذر',
			R.Taxable092 as 'درصدی آذر',
			R.Taxable08 as 'درآمد آبان',
			R.Taxable081 as 'جدولی آبان',
			R.Taxable082 as 'درصدی آبان',
			R.Taxable07 as 'درآمد مهر',
			R.Taxable071 as 'جدولی مهر',
			R.Taxable072 as 'درصدی مهر',
			R.Taxable06 as 'درآمد شهریور',
			R.Taxable061 as 'جدولی شهریور',
			R.Taxable062 as 'درصدی شهریور',
			R.Taxable05 as 'درآمد مرداد',
			R.Taxable051 as 'جدولی مرداد',
			R.Taxable052 as 'درصدی مرداد',
			R.Taxable04 as 'درآمد تیر',
			R.Taxable041 as 'جدولی تیر',
			R.Taxable042 as 'درصدی تیر',
			R.Taxable03 as 'درآمد خرداد',
			R.Taxable031 as 'جدولی خرداد',
			R.Taxable032 as 'درصدی خرداد',
			R.Taxable02 as 'درآمد اردیبهشت',
			R.Taxable021 as 'جدولی اردیبهشت',
			R.Taxable022 as 'درصدی اردیبهشت',
			R.Taxable01 as 'درآمد فروردین',
			R.Taxable011 as 'جدولی فروردین',
			R.Taxable012 as 'درصدی فروردین',
			P.FirstName + ' ' + P.LastName as 'نام پرسنل',
			R.PersonnelID as 'کد پرسنل'
			
	from #tbl_Tax_Result R
		inner join prs.tblPersonnelsDtl P on P.PersonnelID = R.PersonnelID
	order by GAmount
	
	---------------------------------------------------------------------------
End
GO
