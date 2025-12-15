USE TS_ShirinVatanKarkhaneh_1_1404
GO
SET ANSI_NULLS, QUOTED_IDENTIFIER ON
GO
-- =========== TS-QC:UPDATED ====================
-- Author		 : jafari
-- Create Date   : 1402/03/12
-- Viewed By	 : 
-- Last Modified : 
-- Last Modifier : 
-- Description	 : محاسبه آیتم های ارسال دیسک مالیات
-- ==============================================
Create PROCEDURE prs.SpTaxItemsCalc
	@MonthCode		Int,
	@RepOptions		VarChar(50) = '00110',  -- bit array options
	@RepInfo		NVarChar(100) = '1@1@1'
WITH ENCRYPTION
AS 
Begin 
DECLARE	@LangID				Char(1);
DECLARE	@PersonnelID VarChar(20) 
DECLARE	@OvertimeAmount		int
DECLARE	@OverProductAmount	int
DECLARE	@MissionAmount		int
DECLARE	@MissionAmountTax	int;
DECLARE	@SalaryAmount		int
DECLARE	@EmployeeInsur		int
DECLARE	@PeriodWorkTax		bit
DECLARE	@WorkDeductionTax	bit
DECLARE	@DelayTax			bit
DECLARE @sql				NVarChar(max) 
DECLARE	@BenefitID			VarChar(20) 
DECLARE	@TitleTaxList		int
DECLARE	@FridayPeriodWork	bit

DECLARE	@FunctionMinusLeaveWithoutPayInsurTax	bit
DECLARE	@WorkDeductionAmount		float
DECLARE	@InsurPrcntExmptTax			float
DECLARE	@QCQWPersonnelFaultsAmount	float
DECLARE	@prs_PeriodWorkTaxPercent	bit
 
SET @MissionAmountTax	= LTrim(pub.funSplitString(@RepInfo, '@', 1)); 
set @LangID	=1
--drop table  #tblPrs
CREATE TABLE #tblPrs
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
	Item39		bigint,--' 39 حق السعی (به استثناء مزد - حقوق و پاداش		
)


DECLARE @StrFuncDays		NVarChar(500);
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


	set @decAbs = ISNULL((select SettingValue from pub.tblSettings where SettingKey = 'DeductAbsenceFromTaxAndInsur'), 0)
	set @decAbs2 = ISNULL((select SettingValue from pub.tblSettings where SettingKey = 'DeductAbsenceFromInsur'), 0)
	set @decLWP = ISNULL((select SettingValue from pub.tblSettings where SettingKey = 'FunctionMinusLeaveWithoutPayInsurTax'), 0)		
	set @StrFuncDays = 'F.InsuranceFunction-F.SickLeave'

	set @prs_ZeroBasePay=isnull(@prs_ZeroBasePay,0)

	if (@decAbs=1 or @decAbs2=1)
		set @StrFuncDays = @StrFuncDays + '-F.Absence'
		
	if (@decLWP=1)
		set @StrFuncDays = @StrFuncDays + '-LeaveWithoutPay'


	--insert into  #tblPrs
	--select PersonnelID,MonthCode,BenefitAmount,0,0,0,0,0  from prs.tblSalaryCalcInsureTax 
	--where  MonthCode=@MonthCode
	--and BenefitType in (0)

	
	insert into  #tblPrs
	select PersonnelID,MonthCode,0,0,0,0,0,0 ,0,0,0,0  from prs.tblSalaryCalcInsureTax 
	where  MonthCode=@MonthCode
	and BenefitType in (0)
	--BenefitAmount
		select PersonnelID,Item7 BenefitAmount into  #tblBenefitAmount  from #tblPrs where 1=0

	SET @sql = '
	insert into #tblBenefitAmount   
	SELECT  a.PersonnelID,InsuranceBasepay *(' + @StrFuncDays + ') from prs.tblFunctionsDtl F  
	   inner join prs.tblSalaryCalculation a ON a.PersonnelID = F.PersonnelID AND a.MonthCode = F.MonthCode
	   inner join  prs.tblDecreeHdr b
	   on a.DecreeSerialNo=b.SerialNo
	   and a.PersonnelID=b.PersonnelID
	   where a.MonthCode   =' +str(@MonthCode)		
	print @sql
	EXEC sp_executesql @sql;

 		
		update #tblPrs 
		set Item7=BenefitAmount 
		from #tblPrs a
		inner join #tblBenefitAmount b on a.PersonnelID=b.PersonnelID


DECLARE CSR_itm CURSOR FOR 
	select SC.PersonnelID,case when TaxableOvertime=1 then   isnull(OvertimeAmount,0)+isnull(VacationAmount,0) else 0 end OvertimeAmount,case when TaxablePrdOvertime=1 then   OverProductAmount else 0 end OverProductAmount
	,case when TaxableMission=1 or @MissionAmountTax=1 then   isnull(MissionDailyAmount,0)+isnull(MissionTimeAmount,0) else 0 end MissionAmount
	,SalaryAmount,EmployeeInsur
	from prs.tblSalaryCalculation SC	
		inner join prs.tblDecreeHdr     DH on SC.DecreeSerialNo = DH.SerialNo and SC.PersonnelID = DH.PersonnelID 
	where  MonthCode=@MonthCode
	--and SC.PersonnelID='002'

	OPEN CSR_itm
	FETCH NEXT FROM CSR_itm INTO @PersonnelID, @OvertimeAmount, @OverProductAmount,@MissionAmount,@SalaryAmount,@EmployeeInsur

	WHILE @@Fetch_Status = 0
	BEGIN
		--------------------------------------------------------------------------------------------------------------------
		--insert into  #tblPrs
		--select @PersonnelID,@MonthCode,@SalaryAmount,@OvertimeAmount+@OverProductAmount,0,@EmployeeInsur,0
		Update #tblPrs
		set Item17=@OvertimeAmount+@OverProductAmount ,Item19=@MissionAmount,Item33=@EmployeeInsur
		where PersonnelID=@PersonnelID

		--------------------------------------------------------------------------------------------------------------------

		DECLARE CSR_B1 CURSOR FOR 
			SELECT	H.BenefitID,TitleTaxList
			FROM	prs.tblBenefits1 H
			WHERE	(H.BenefitID <> '') and (H.Taxable=1 or H.Insurable=1 or  H.NotInsurableForView=1 or  H.NotTaxableForView=1) 

		OPEN CSR_B1
		FETCH NEXT FROM CSR_B1 INTO @BenefitID,@TitleTaxList

		WHILE @@Fetch_Status = 0
		BEGIN

			SET @sql = '
			Update #tblPrs
			Set Item7=Item7+BenefitAmount
			from #tblPrs a 			
			inner join prs.tblSalaryCalcInsureTax s
				on a.PersonnelID=s.PersonnelID and a.MonthCode=s.MonthCode 
				and BenefitName=''Benefit' + @BenefitID + ''' and BenefitType in (2,4)
			where a.PersonnelID='''+@PersonnelID +''''
		
			print @sql
			EXEC sp_executesql @sql;
			if @TitleTaxList>0
			begin				
				SET @sql = ' Update #tblPrs    Set Item34=Item34 '
				if @TitleTaxList=1
					SET @sql += ' ,Item36=Item36+BenefitAmount'
				if @TitleTaxList=2
					SET @sql += ' ,Item37=Item37+BenefitAmount'
				if @TitleTaxList=3
					SET @sql += ' , Item38=Item38+BenefitAmount'
				if @TitleTaxList=4
					SET @sql += ' ,Item39=Item39+BenefitAmount'
				if @TitleTaxList=5
					SET @sql += ' ,Item19=Item19+BenefitAmount'

				SET @sql += ' 
					from #tblPrs a 			
					inner join prs.tblSalaryCalcInsureTax s
						on a.PersonnelID=s.PersonnelID and a.MonthCode=s.MonthCode 
						and BenefitName=''Benefit' + @BenefitID + ''' and BenefitType in (2,4)
					where a.PersonnelID='''+@PersonnelID +''''					
				print @sql
				EXEC sp_executesql @sql;
			end 
			FETCH NEXT FROM CSR_B1 INTO  @BenefitID,@TitleTaxList
		END

		CLOSE CSR_B1
		DEALLOCATE CSR_B1		
		--------------------------------------------------------------------------------------------------------------------
		
		DECLARE CSR_B2 CURSOR FOR 
			SELECT	H.BenefitID,TitleTaxList
			FROM	prs.tblBenefits2 H
			WHERE	(H.BenefitID <> '') and (H.Taxable=1 or H.Insurable=1 or  H.NotInsurableForView=1 or  H.NotTaxableForView=1) 

		OPEN CSR_B2
		FETCH NEXT FROM CSR_B2 INTO @BenefitID,@TitleTaxList

		WHILE @@Fetch_Status = 0
		BEGIN

			SET @sql = '
			Update #tblPrs
			Set Item7=Item7+BenefitAmount
			from #tblPrs a 
			inner join prs.tblSalaryCalcInsureTax s
				on a.PersonnelID=s.PersonnelID and a.MonthCode=s.MonthCode 
				and BenefitName=''BenefitU' + @BenefitID + ''' and BenefitType in (2,4)
			where a.PersonnelID='''+@PersonnelID +''''
		
			print @sql
			EXEC sp_executesql @sql;
			if @TitleTaxList>0
			begin				
				SET @sql = ' Update #tblPrs Set Item34=Item34 '
				if @TitleTaxList=1
					SET @sql += ' ,Item36=Item36+BenefitAmount'
				if @TitleTaxList=2
					SET @sql += ' ,Item37=Item37+BenefitAmount'
				if @TitleTaxList=3
					SET @sql += ' , Item38=Item38+BenefitAmount'
				if @TitleTaxList=4
					SET @sql += ' ,Item39=Item39+BenefitAmount'
				if @TitleTaxList=5
					SET @sql += ' ,Item19=Item19+BenefitAmount'

				SET @sql += ' 
					from #tblPrs a 
					inner join prs.tblSalaryCalcInsureTax s
						on a.PersonnelID=s.PersonnelID and a.MonthCode=s.MonthCode 
						and BenefitName=''BenefitU' + @BenefitID + ''' and BenefitType in (2,4)
					where a.PersonnelID='''+@PersonnelID +''''				
				print @sql
				EXEC sp_executesql @sql;
			end 
		
			FETCH NEXT FROM CSR_B2 INTO  @BenefitID,@TitleTaxList
		END

		CLOSE CSR_B2
		DEALLOCATE CSR_B2
		--------------------------------------------------------------------------------------------------------------------
		
		DECLARE CSR_D1 CURSOR FOR 
			SELECT	H.BenefitID
			FROM	prs.tblDeduction1 H
			WHERE	(H.BenefitID <> '') and (H.MedicalCost=1 ) and (Taxable=1 or 	Insurable=1)

		OPEN CSR_D1
		FETCH NEXT FROM CSR_D1 INTO @BenefitID

		WHILE @@Fetch_Status = 0
		BEGIN

			SET @sql = '
			Update #tblPrs
			Set Item34=Item34+BenefitAmount*-1
			from #tblPrs a 			
			inner join prs.tblSalaryCalcInsureTax s
				on a.PersonnelID=s.PersonnelID and a.MonthCode=s.MonthCode 
				and BenefitName=''Deduction' + @BenefitID + ''' and BenefitType in (2)
			where a.PersonnelID='''+@PersonnelID +''''  
		
			print @sql
			EXEC sp_executesql @sql;

		
			FETCH NEXT FROM CSR_D1 INTO  @BenefitID
		END

		CLOSE CSR_D1
		DEALLOCATE CSR_D1

		--------------------------------------------------------------------------------------------------------------------
			 			
		SELECT @PeriodWorkTax=cast(isnull(SettingValue,0) as bit)	FROM pub.tblSettings WHERE SettingKey = 'PeriodWorkTax'	
		set @PeriodWorkTax=isnull(@PeriodWorkTax,0)
	 	SELECT @prs_PeriodWorkTaxPercent=cast(isnull(SettingValue,0) as bit)	FROM pub.tblSettings WHERE SettingKey = 'prs_PeriodWorkTaxPercent'	
		set @prs_PeriodWorkTaxPercent=isnull(@prs_PeriodWorkTaxPercent,0)
		
		if @PeriodWorkTax='True'
		begin
	 
			DECLARE CSR_P1 CURSOR FOR 
			SELECT PeriodWorkID,FridayPeriodWork
			FROM emp.tblPeriodWorks 
			where PeriodWorkID <> '' --and  NotInsurableForView=1

			OPEN CSR_P1
			FETCH NEXT FROM CSR_P1 INTO @BenefitID,@FridayPeriodWork

			WHILE @@Fetch_Status = 0
			BEGIN
				if @prs_PeriodWorkTaxPercent='True'					
				begin	
					if @FridayPeriodWork='True'
						SET @sql = '
						Update #tblPrs
							Set Item39=Item39+s.PeriodWorkAmount' + @BenefitID + ' 
							, Item7=Item7+s.PeriodWorkAmount' + @BenefitID + ' 
						from #tblPrs a 
						inner join prs.tblSalaryCalculation s
						on a.PersonnelID=s.PersonnelID and a.MonthCode=s.MonthCode
						where a.PersonnelID='''+@PersonnelID +''''
					else
						SET @sql = '
						Update #tblPrs
							Set Item37=Item37+s.PeriodWorkAmount' + @BenefitID + ' 
							, Item7=Item7+s.PeriodWorkAmount' + @BenefitID + ' 
						from #tblPrs a 
						inner join prs.tblSalaryCalculation s
						on a.PersonnelID=s.PersonnelID and a.MonthCode=s.MonthCode
						where a.PersonnelID='''+@PersonnelID +''''

				end 
				else
					SET @sql = '
					Update #tblPrs
						Set Item29=Item29+s.PeriodWorkAmount' + @BenefitID + ' 
					from #tblPrs a 
					inner join prs.tblSalaryCalculation s
					on a.PersonnelID=s.PersonnelID and a.MonthCode=s.MonthCode
					where a.PersonnelID='''+@PersonnelID +''''
		
				print @sql
				EXEC sp_executesql @sql;
		
				FETCH NEXT FROM CSR_P1 INTO  @BenefitID,@FridayPeriodWork
			END

			CLOSE CSR_P1
			DEALLOCATE CSR_P1
		END

	--------------------------------------------------------------------------------------------------------------------
	
		FETCH NEXT FROM CSR_itm INTO  @PersonnelID, @OvertimeAmount, @OverProductAmount,@MissionAmount,@SalaryAmount,@EmployeeInsur
	END

	CLOSE CSR_itm
	DEALLOCATE CSR_itm

	--------------------------------------------------------------------------------------------------------------------

	SELECT @InsurPrcntExmptTax=cast(isnull(SettingValue,0) as float)	FROM pub.tblSettings	WHERE SettingKey = 'InsurPrcntExmptTax'	
	set @InsurPrcntExmptTax=isnull(@InsurPrcntExmptTax,0)

	Update #tblPrs 		Set Item33= ROUND( Item33*@InsurPrcntExmptTax,0)

	--------------------------------------------------------------------------------------------------------------------
	SELECT @FunctionMinusLeaveWithoutPayInsurTax=cast(isnull(SettingValue,0) as bit)	FROM pub.tblSettings	WHERE SettingKey = 'FunctionMinusLeaveWithoutPayInsurTax'	
	set @FunctionMinusLeaveWithoutPayInsurTax=isnull(@FunctionMinusLeaveWithoutPayInsurTax,0)

	if @FunctionMinusLeaveWithoutPayInsurTax='True'
	begin
		Update #tblPrs
			Set Item7=Item7-LeaveWithoutPayAmountInsure
			from #tblPrs a 
			inner join prs.tblSalaryCalculation s
			on a.PersonnelID=s.PersonnelID and a.MonthCode=s.MonthCode 		
	end 

	SELECT @WorkDeductionTax=cast(isnull(SettingValue,0) as bit)	FROM pub.tblSettings	WHERE SettingKey = 'WorkDeductionTax'	
	set @WorkDeductionTax=isnull(@WorkDeductionTax,0)

	if @WorkDeductionTax='True'
	begin
		Update #tblPrs
			Set Item7=Item7-WorkDeductionAmount-QCQWPersonnelFaultsAmount
			from #tblPrs a 
			inner join prs.tblSalaryCalculation s
			on a.PersonnelID=s.PersonnelID and a.MonthCode=s.MonthCode 		
	end 
		--------------------------------------------------------------------------------------------------------------------
	SELECT @DelayTax=cast(isnull(SettingValue,0) as bit)	FROM pub.tblSettings	WHERE SettingKey = 'DelayTax'	
	set @DelayTax=isnull(@DelayTax,0)

	if @DelayTax='True'
	begin
		Update #tblPrs
			Set Item7=Item7-isnull(DelayAmount,0)
			from #tblPrs a 
			inner join prs.tblSalaryCalculation s
			on a.PersonnelID=s.PersonnelID and a.MonthCode=s.MonthCode 		
	end 
		--------------------------------------------------------------------------------------------------------------------
		
		select PersonnelID	,MonthCode	,Item7-Item19-Item36-Item37-Item38-Item39	Item7,Item17	,Item19	,Item29	,Item33	,Item34	,Item36	,Item37	,Item38	,Item39
		from #tblPrs 
	--	where PersonnelID='10016'
end 
GO
