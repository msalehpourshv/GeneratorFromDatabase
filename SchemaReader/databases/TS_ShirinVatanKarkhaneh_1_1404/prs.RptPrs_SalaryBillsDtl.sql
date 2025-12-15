USE TS_ShirinVatanKarkhaneh_1_1404
GO
SET ANSI_NULLS, QUOTED_IDENTIFIER ON
GO
-- =========== TS-QC:UPDATED ====================
-- Author		 : TakroSystem\ZiA
-- Create Date   : 1387/08/26
-- Viewed By	 : 
-- Last Modified : 1392/06/13
-- Last Modifier : TakroSystem\ZiA
-- Description	 : فیش حقوق پرسنل
-- ==============================================
 Create PROCEDURE [prs].[RptPrs_SalaryBillsDtl]
	@MonthCode		Int,
	@SelectedPrs	Int = 0,
	@DecreeTypeID	VarChar(20) = Null,
	@DepartmentID	VarChar(20) = Null,
	@WorkShopID		VarChar(20) = Null,
	@JobID			VarChar(20) = Null,
	@RemainDate		Char(10) = Null,
	@LoanDate		Char(10) = Null, -- don't remove this param
	@RepOptions		VarChar(50) = '00110',  -- bit array options
	@RepInfo		NVarChar(100) = '1@1@1'
WITH ENCRYPTION
AS 
DECLARE @StrSelect		NVarChar(MAX);
DECLARE @StrWhere		NVarChar(MAx);
DECLARE @ShowRemain		Bit;
DECLARE @ExternalCall	Bit; -- is called from another sp?
DECLARE @ShowCele01		Bit;
DECLARE @ShowCele02		Bit;
DECLARE @ShowCele03		Bit;-- نمایش عیدی و پایانکار ذخیره شده
DECLARE @InsuranceFunction		Bit;
DECLARE @RemainAmount	float;

DECLARE	@LangID				Char(1);
DECLARE	@SessionNo			Int; 
DECLARE	@ReportID			Int; 
DECLARE	@UserID				Int;
DECLARE	@UserIsAdmin		bit;
declare @CheckShowInBill	bit;
declare @ShowAllInBill		bit;
declare @BenefitTypeShow	int;
declare @BillType			int;
declare @DontShowSalary		bit;
declare @ShowAdvanceAmount  int =0
declare @ShowAdvanceAmount2 int =0
declare @ShowBuyAmount	    int =0
declare @ShowBuyAmount2     int =0
declare @PersonnelID		VarChar(20) 
declare @ShowTypeBenefit	bit
declare @ShowDtlBasePay		int 
	
Begin 
	--============== S T A R T  C O D E =======================================

	SET NOCOUNT ON;

	---- Init ------------------------------------------
	IF (@RepInfo		Is Null)	SET @RepInfo = '1@1@1'
	IF (@SelectedPrs	Is Null)	SET @SelectedPrs = 0
	IF (@RemainDate		Is Null)	SET @RemainDate	 = '9999/99/99'

	SET @ShowRemain			= Substring(@RepOptions, 1, 1)
	SET @ExternalCall		= Substring(@RepOptions, 2, 1)
	SET @ShowCele01			= Substring(@RepOptions, 3, 1)
	SET @ShowCele02			= Substring(@RepOptions, 4, 1)		
	SET @CheckShowInBill	= Substring(@RepOptions, 5, 1)
	SET @InsuranceFunction	= Substring(@RepOptions, 6, 1)
	SET @BenefitTypeShow	= Substring(@RepOptions, 7, 1)
	SET @BillType			= Substring(@RepOptions, 8, 1)
	SET @ShowAllInBill		= Substring(@RepOptions, 9, 1)
	SET @DontShowSalary		= Substring(@RepOptions,10, 1)
	SET @ShowCele03			= Substring(@RepOptions,11, 1)
	SET @ShowTypeBenefit	= Substring(@RepOptions,12, 1)
	SET @ShowAdvanceAmount2	= Substring(@RepOptions,13, 1)	
	SET @ShowBuyAmount		= Substring(@RepOptions,14, 1)	
	SET @ShowBuyAmount2		= Substring(@RepOptions,15, 1)	

 	SET @ShowRemain			= isnull(@ShowRemain,0)
	SET @ExternalCall		= isnull(@ExternalCall,0)
	SET @ShowCele01			= isnull(@ShowCele01,0)
	SET @ShowCele02			= isnull(@ShowCele02,0)		
	SET @CheckShowInBill	= isnull(@CheckShowInBill,0)
	SET @InsuranceFunction	= isnull(@InsuranceFunction,0)
	SET @BenefitTypeShow	= isnull(@BenefitTypeShow,0)
	SET @BillType			= isnull(@BillType,0)
	SET @ShowAllInBill		= isnull(@ShowAllInBill,0)
	SET @DontShowSalary		= isnull(@DontShowSalary,0)
	SET @ShowCele03			= isnull(@ShowCele03,0)

	SET @LangID				= pub.funSplitString(@RepInfo, '@', 1);
	SET @SessionNo			= pub.funSplitString(@RepInfo, '@', 2);
	SET @ReportID			= pub.funSplitString(@RepInfo, '@', 3);
	SET @UserID				= pub.funSplitString(@RepInfo, '@', 4);
	SET @UserIsAdmin		= pub.funSplitString(@RepInfo, '@', 5);
	SET @ShowAdvanceAmount	= pub.funSplitString(@RepInfo, '@', 6);
	SET @PersonnelID		= pub.funSplitString(@RepInfo, '@', 7);
	SET @ShowDtlBasePay		= pub.funSplitString(@RepInfo, '@', 8);
	
	----------------------------------------------------
	
	If (@ExternalCall = 0)  -- is not called from another sp
	Begin
		BEGIN TRY
			DROP TABLE #tblPrs
			DROP TABLE #tblPrs1
			DROP TABLE #tblPrs2
			DROP TABLE #tblBills
		END TRY
		BEGIN CATCH
		END CATCH
	End

	CREATE TABLE #tblPrs
	(
		PersonnelID VarChar(20) COLLATE ARABIC_CS_AS,
		EmployeeInsurIsBenefit BIT,
		EmployeeTaxIsBenefit BIT,
		EmployeeTaxCeleIsBenefit BIT,
		AcntSalary VarChar(20)
	)
	CREATE TABLE #tblPrs1
	(
		PersonnelID VarChar(20) COLLATE ARABIC_CS_AS,
		EmployeeInsurIsBenefit BIT,
		EmployeeTaxIsBenefit BIT,
		EmployeeTaxCeleIsBenefit BIT
	)
	CREATE TABLE #tblPrs2
	(
		PersonnelID VarChar(20) COLLATE ARABIC_CS_AS,
		EmployeeInsurIsBenefit BIT,
		EmployeeTaxIsBenefit BIT,
		EmployeeTaxCeleIsBenefit BIT

	)
	
	CREATE TABLE #tblBills1
	(
		PersonnelID		VarChar(20) COLLATE ARABIC_CS_AS,
		BenefitName		VarChar(50) COLLATE ARABIC_CS_AS,
		BenefitAmount	Float,
		BenefitTime		VarChar(50) COLLATE ARABIC_CS_AS,
		BenefitUnit		VarChar(50) COLLATE ARABIC_CS_AS,
		BenefitType		int,
		ShowType		int,
		BenefitState	int Null,		
		BenefitBaseAmount	Float
	)
	
	CREATE TABLE #tblBills2
	(
		PersonnelID		VarChar(20) COLLATE ARABIC_CS_AS,
		BenefitName		VarChar(50) COLLATE ARABIC_CS_AS,
		BenefitAmount	Float,
		BenefitTime		VarChar(50) COLLATE ARABIC_CS_AS,
		BenefitUnit  	VarChar(50) COLLATE ARABIC_CS_AS,
		BenefitType		int,
		ShowType		int,
		BenefitState	int Null,		
		BenefitBaseAmount	Float
	)

	DECLARE @ID		VarChar(20)
	DECLARE @Name	VarChar(50)
	Declare @BenefitType int
	DECLARE @SalaryAcntCode	VarChar(20)
	DECLARE @ShowSumInSalary	bit
	
	DECLARE @sql	NVarChar(4000)
	DECLARE @sqlWhere 	NVarChar(4000)

	SET @sqlWhere  =' '


	--select @ExternalCall
	---------------------------------------
	if @UserIsAdmin=0 and (select count(*) from prs.tblPersonnelsRng) >0
	begin
		If (@ExternalCall = 0) 
		begin
			BEGIN TRY
				DROP TABLE #Personnel
			END TRY
			BEGIN CATCH
			END CATCH
		END
		CREATE TABLE #Personnel
		(
			PersonnelID 			Varchar(20)collate arabic_cs_as null
		)
	
		Insert into  #Personnel (PersonnelID)	SELECT Distinct PersonnelID from prs.tblPersonnels
	 
		exec pub.SpFilterByPermission2 '#Personnel@1', 'PersonnelID', 'prs.tblPersonnels', @UserID;
		
		SET @sqlWhere =  ' and D.PersonnelID in (SELECT PersonnelID FROM  #Personnel ) '

	END

	-----------------------------------------
	IF (@SelectedPrs > 0)
		SET @sqlWhere  = @sqlWhere  + ' AND ' + pub.funGetFilterString(@SessionNo, @ReportID, @SelectedPrs, 'D.PersonnelID')

	If (@DecreeTypeID Is Not Null)
		SET @sqlWhere  = @sqlWhere  + ' AND (D.DecreeTypeID = ''' + @DecreeTypeID + ''')'
	If (@DepartmentID Is Not Null)
		SET @sqlWhere  = @sqlWhere  + ' AND (D.DepartmentID LIKE ''' + @DepartmentID + '%'')'
	If (@WorkShopID Is Not Null)
		SET @sqlWhere  = @sqlWhere  + ' AND (D.WorkShopID = ''' + @WorkShopID + ''')'
	If (@JobID Is Not Null)
		SET @sqlWhere  = @sqlWhere  + ' AND (D.JobID = ''' + @JobID + ''')'
	If (@PersonnelID Is Not Null and @PersonnelID<>'')
		SET @sqlWhere  = @sqlWhere  + ' AND (D.PersonnelID = ''' + @PersonnelID + ''')'

	SET @sql = '
	INSERT INTO #tblPrs
	SELECT  D.PersonnelID,D.EmployeeInsurIsBenefit,D.EmployeeTaxIsBenefit,D.EmployeeTaxCeleIsBenefit,D.AcntSalary
	FROM	prs.tblDecreeHdr D 
				INNER JOIN prs.tblSalaryCalculation S ON S.PersonnelID = D.PersonnelID AND S.DecreeSerialNo=D.SerialNo
	WHERE S.MonthCode = ' + Str(@MonthCode) + @sqlWhere

	print @sql
	EXEC sp_executesql @sql;

	SET @sql = '
	INSERT INTO #tblPrs1
	SELECT  D.PersonnelID,D.EmployeeInsurIsBenefit,D.EmployeeTaxIsBenefit,D.EmployeeTaxCeleIsBenefit
	FROM	prs.tblDecreeHdr D 
				INNER JOIN prs.tblSalaryCalculation S ON S.PersonnelID = D.PersonnelID AND S.DecreeSerialNo=D.SerialNo
	WHERE S.MonthCode = ' + Str(@MonthCode)+' ' + @sqlWhere

	print @sql
	EXEC sp_executesql @sql;
		
	------------------------------------------	
	declare @WorkDeductionInsure as bit
	declare @WorkDeductionTax as bit
	declare @DelayInsure as bit
	declare @DelayTax as bit
	declare @LeaveBasepay as bit
	declare @ViewLeaveBasepay as bit
	declare @DailyHours as char(7)
	declare @DailyMin as int
	declare @prs_SavePrice2InsureList as bit

	SELECT @prs_SavePrice2InsureList=SettingValue	FROM pub.tblSettings	WHERE SettingKey = 'prs_SavePrice2InsureList'	
	SELECT @WorkDeductionInsure=SettingValue	FROM pub.tblSettings	WHERE SettingKey = 'WorkDeductionInsure'
	SELECT @WorkDeductionTax=SettingValue	FROM pub.tblSettings	WHERE SettingKey = 'WorkDeductionTax'
	SELECT @DelayInsure=SettingValue	FROM pub.tblSettings	WHERE SettingKey = 'DelayInsure'
	SELECT @DelayTax=SettingValue	FROM pub.tblSettings	WHERE SettingKey = 'DelayTax'

	SELECT @LeaveBasepay=SettingValue			FROM pub.tblSettings	WHERE SettingKey = 'LeaveBasepay'
	SELECT @ViewLeaveBasepay=SettingValue		FROM pub.tblSettings	WHERE SettingKey = 'ViewLeaveBasepay'	
	SELECT @DailyHours=SettingValue				FROM pub.tblSettings	WHERE SettingKey = 'DailyHours'
	
	set @prs_SavePrice2InsureList =isnull(@prs_SavePrice2InsureList, 'False')
	set @DailyMin= prs.funGetMinutes(@DailyHours)	
	set @WorkDeductionInsure =isnull(@WorkDeductionInsure, 'False')
	set @WorkDeductionTax =isnull(@WorkDeductionTax, 'False')
	set @DelayInsure =isnull(@DelayInsure, 'False')
	set @DelayTax =isnull(@DelayTax, 'False')

----------------------------------
-- --------------------- برای اصلاح مبالغ فیش های قبلی    حقوق
update     prs.tblSalaryCalculation
set  BaseSalaryAmount=((F.MonthlyFunction-LeaveDay) * D.Basepay)-(prs.funGetMinutes(F.LeaveTime)*D.Basepay/@DailyMin)
FROM prs.tblSalaryCalculation S 
			INNER JOIN #tblPrs1 P ON S.PersonnelID = P.PersonnelID and S.MonthCode = @MonthCode
			INNER JOIN prs.tblDecreeHdr D ON D.PersonnelID = S.PersonnelID AND D.SerialNo = S.DecreeSerialNo
			INNER JOIN prs.tblFunctionsDtl F ON F.PersonnelID = S.PersonnelID AND F.MonthCode = S.MonthCode
where BaseSalaryAmount=0

	-- --------------------- برای اصلاح مبالغ فیش های قبلی    مرخصی روزانه
update     prs.tblSalaryCalculation
set  LeaveWithPayAmount=F.LeaveDay * case when @LeaveBasepay=1 then D.Basepay else  D.LeavePay end
FROM prs.tblSalaryCalculation S 
			INNER JOIN #tblPrs1 P ON S.PersonnelID = P.PersonnelID and S.MonthCode = @MonthCode
			INNER JOIN prs.tblDecreeHdr D ON D.PersonnelID = S.PersonnelID AND D.SerialNo = S.DecreeSerialNo
			INNER JOIN prs.tblFunctionsDtl F ON F.PersonnelID = S.PersonnelID AND F.MonthCode = S.MonthCode
where BaseSalaryAmount=0

	-- --------------------- برای اصلاح مبالغ فیش های قبلی   مرخصی ساعتی 
update     prs.tblSalaryCalculation
set  HourlyLeaveWithPayAmount= prs.funGetMinutes(F.LeaveTime) * case when @LeaveBasepay=1 then D.Basepay else D.LeavePay end /@DailyMin
FROM prs.tblSalaryCalculation S 
			INNER JOIN #tblPrs1 P ON S.PersonnelID = P.PersonnelID and S.MonthCode = @MonthCode
			INNER JOIN prs.tblDecreeHdr D ON D.PersonnelID = S.PersonnelID AND D.SerialNo = S.DecreeSerialNo
			INNER JOIN prs.tblFunctionsDtl F ON F.PersonnelID = S.PersonnelID AND F.MonthCode = S.MonthCode
where BaseSalaryAmount=0
-----------------------------
 
if (@ViewLeaveBasepay=1)
begin
	if @DontShowSalary = 0
	begin	
		if @ShowDtlBasePay=0
			INSERT INTO #tblBills1(PersonnelID, BenefitAmount, BenefitName,BenefitTime,BenefitUnit,BenefitBaseAmount)
			SELECT D.PersonnelID,BaseSalaryAmount-SalaryAmountTime- S.LeaveAmount, 'حقوق', F.MonthlyFunction-F.LeaveDay- F.SickLeave,'روز', D.Basepay
			FROM prs.tblSalaryCalculation S 
					INNER JOIN #tblPrs1 P ON S.PersonnelID = P.PersonnelID
					INNER JOIN prs.tblDecreeHdr D ON D.PersonnelID = S.PersonnelID AND D.SerialNo = S.DecreeSerialNo
					INNER JOIN prs.tblFunctionsDtl F ON F.PersonnelID = S.PersonnelID AND F.MonthCode = S.MonthCode
			WHERE (S.MonthCode = @MonthCode) 
			and F.MonthlyFunction-F.LeaveDay- F.SickLeave>0
			and BaseSalaryAmount-SalaryAmountTime - S.LeaveAmount>0
		else
			INSERT INTO #tblBills1(PersonnelID, BenefitAmount, BenefitName,BenefitTime,BenefitUnit,BenefitBaseAmount)
			SELECT D.PersonnelID,(BaseSalaryAmount-SalaryAmountTime- S.LeaveAmount-(PastWagesDailyPay+DailyInferiorPay+DailyInferiorPayRemain)*(F.MonthlyFunction-F.LeaveDay- F.SickLeave)), 'مزد گروه شغلی', F.MonthlyFunction-F.LeaveDay- F.SickLeave,'روز', JobCategoryPay
			FROM prs.tblSalaryCalculation S 
				INNER JOIN #tblPrs1 P ON S.PersonnelID = P.PersonnelID
				INNER JOIN prs.tblDecreeHdr D ON D.PersonnelID = S.PersonnelID AND D.SerialNo = S.DecreeSerialNo
				INNER JOIN prs.tblFunctionsDtl F ON F.PersonnelID = S.PersonnelID AND F.MonthCode = S.MonthCode
			WHERE (S.MonthCode = @MonthCode)  
			and F.MonthlyFunction-F.LeaveDay- F.SickLeave>0
			and BaseSalaryAmount-SalaryAmountTime - S.LeaveAmount>0 		
			union all
			SELECT D.PersonnelID,(PastWagesDailyPay*(F.MonthlyFunction-F.LeaveDay- F.SickLeave)), 'مزد سنوات', F.MonthlyFunction-F.LeaveDay- F.SickLeave,'روز', D.PastWagesDailyPay
			FROM prs.tblSalaryCalculation S 
				INNER JOIN #tblPrs1 P ON S.PersonnelID = P.PersonnelID
				INNER JOIN prs.tblDecreeHdr D ON D.PersonnelID = S.PersonnelID AND D.SerialNo = S.DecreeSerialNo
				INNER JOIN prs.tblFunctionsDtl F ON F.PersonnelID = S.PersonnelID AND F.MonthCode = S.MonthCode
			WHERE (S.MonthCode = @MonthCode)  
			and F.MonthlyFunction-F.LeaveDay- F.SickLeave>0
			and BaseSalaryAmount-SalaryAmountTime - S.LeaveAmount>0 
			and PastWagesDailyPay>0
			union all
			SELECT D.PersonnelID,(DailyInferiorPay*(F.MonthlyFunction-F.LeaveDay- F.SickLeave)), 'حق پست', F.MonthlyFunction-F.LeaveDay- F.SickLeave,'روز', DailyInferiorPay
			FROM prs.tblSalaryCalculation S 
				INNER JOIN #tblPrs1 P ON S.PersonnelID = P.PersonnelID
				INNER JOIN prs.tblDecreeHdr D ON D.PersonnelID = S.PersonnelID AND D.SerialNo = S.DecreeSerialNo
				INNER JOIN prs.tblFunctionsDtl F ON F.PersonnelID = S.PersonnelID AND F.MonthCode = S.MonthCode
			WHERE (S.MonthCode = @MonthCode)  
			and F.MonthlyFunction-F.LeaveDay- F.SickLeave>0
			and BaseSalaryAmount-SalaryAmountTime - S.LeaveAmount>0 
			and DailyInferiorPay>0
			union all
			SELECT D.PersonnelID,(DailyInferiorPayRemain*(F.MonthlyFunction-F.LeaveDay- F.SickLeave)), 'حق ماندگاری پست', F.MonthlyFunction-F.LeaveDay- F.SickLeave,'روز', DailyInferiorPayRemain
			FROM prs.tblSalaryCalculation S 
				INNER JOIN #tblPrs1 P ON S.PersonnelID = P.PersonnelID
				INNER JOIN prs.tblDecreeHdr D ON D.PersonnelID = S.PersonnelID AND D.SerialNo = S.DecreeSerialNo
				INNER JOIN prs.tblFunctionsDtl F ON F.PersonnelID = S.PersonnelID AND F.MonthCode = S.MonthCode
			WHERE (S.MonthCode = @MonthCode)  
			and F.MonthlyFunction-F.LeaveDay- F.SickLeave>0
			and BaseSalaryAmount-SalaryAmountTime - S.LeaveAmount>0 
			and DailyInferiorPayRemain>0
	
		INSERT INTO #tblBills1(PersonnelID, BenefitAmount, BenefitName,BenefitTime,BenefitUnit,BenefitBaseAmount)
		SELECT D.PersonnelID,SalaryAmountTime, 'حقوق ساعتی', F.MonthlyFunctionTime,'ساعت',D.BasepayTime
		FROM prs.tblSalaryCalculation S 
				INNER JOIN #tblPrs1 P ON S.PersonnelID = P.PersonnelID
				INNER JOIN prs.tblDecreeHdr D ON D.PersonnelID = S.PersonnelID AND D.SerialNo = S.DecreeSerialNo
				INNER JOIN prs.tblFunctionsDtl F ON F.PersonnelID = S.PersonnelID AND F.MonthCode = S.MonthCode
		WHERE (S.MonthCode = @MonthCode) 
		and SalaryAmountTime>0
	end 

	if (@BenefitTypeShow = 0)
	begin	
		INSERT INTO #tblBills1(PersonnelID, BenefitAmount, BenefitName,BenefitTime,BenefitUnit,BenefitBaseAmount)
		SELECT S.PersonnelID,LeaveWithPayAmount , ' مبلغ مرخصی روزانه ',  F.LeaveDay,'روز',D.LeavePay
		FROM prs.tblSalaryCalculation S 
		INNER JOIN #tblPrs1 P ON S.PersonnelID = P.PersonnelID
		INNER JOIN prs.tblDecreeHdr D ON D.PersonnelID = S.PersonnelID AND D.SerialNo = S.DecreeSerialNo
		INNER JOIN prs.tblFunctionsDtl F ON F.PersonnelID = S.PersonnelID AND F.MonthCode = S.MonthCode
		WHERE (LeaveWithPayAmount <> 0) AND (S.MonthCode = @MonthCode)
		
		INSERT INTO #tblBills1(PersonnelID, BenefitAmount, BenefitName,BenefitTime,BenefitUnit,BenefitBaseAmount)
		SELECT S.PersonnelID, HourlyLeaveWithPayAmount, ' مبلغ مرخصی ساعتی ', prs.funGetMinutes(F.LeaveTime),'دقیقه', D.LeavePay / @DailyMin * 60
		FROM prs.tblSalaryCalculation S 
		INNER JOIN #tblPrs1 P ON S.PersonnelID = P.PersonnelID
		INNER JOIN prs.tblDecreeHdr D ON D.PersonnelID = S.PersonnelID AND D.SerialNo = S.DecreeSerialNo
		INNER JOIN prs.tblFunctionsDtl F ON F.PersonnelID = S.PersonnelID AND F.MonthCode = S.MonthCode
		WHERE (HourlyLeaveWithPayAmount <> 0) AND (S.MonthCode = @MonthCode)
	end
	
	if (@BenefitTypeShow = 1)
	begin	
		INSERT INTO #tblBills1(PersonnelID, BenefitAmount, BenefitName,BenefitTime,BenefitUnit,BenefitBaseAmount)
		SELECT D.PersonnelID,LeaveWithPayAmount , ' مبلغ مرخصی روزانه ',  F.LeaveDay,'روز',D.LeavePay
		FROM prs.tblSalaryCalculation S 
		INNER JOIN #tblPrs1 P ON S.PersonnelID = P.PersonnelID
		INNER JOIN prs.tblFunctionsDtl F ON F.PersonnelID = S.PersonnelID AND F.MonthCode = S.MonthCode
		INNER JOIN prs.tblDecreeHdr D ON D.PersonnelID = S.PersonnelID AND D.SerialNo = S.DecreeSerialNo AND InsurableOvertime=0	
		WHERE (LeaveWithPayAmount <> 0) AND (S.MonthCode = @MonthCode)
		
		INSERT INTO #tblBills1(PersonnelID, BenefitAmount, BenefitName,BenefitTime,BenefitUnit,BenefitBaseAmount)
		SELECT D.PersonnelID, HourlyLeaveWithPayAmount, ' مبلغ مرخصی ساعتی ', prs.funGetMinutes(F.LeaveTime),'دقیقه', D.LeavePay / @DailyMin * 60
		FROM prs.tblSalaryCalculation S 
		INNER JOIN #tblPrs1 P ON S.PersonnelID = P.PersonnelID
		INNER JOIN prs.tblFunctionsDtl F ON F.PersonnelID = S.PersonnelID AND F.MonthCode = S.MonthCode
		INNER JOIN prs.tblDecreeHdr D ON D.PersonnelID = S.PersonnelID AND D.SerialNo = S.DecreeSerialNo AND InsurableOvertime=0	
		WHERE (HourlyLeaveWithPayAmount <> 0) AND (S.MonthCode = @MonthCode)
			
	end
	if (@BenefitTypeShow = 2)
	begin	
		INSERT INTO #tblBills1(PersonnelID, BenefitAmount, BenefitName,BenefitTime,BenefitUnit,BenefitBaseAmount)
		SELECT D.PersonnelID,LeaveWithPayAmount , ' مبلغ مرخصی روزانه ',  F.LeaveDay,'روز',D.LeavePay
		FROM prs.tblSalaryCalculation S 
		INNER JOIN #tblPrs1 P ON S.PersonnelID = P.PersonnelID
		INNER JOIN prs.tblFunctionsDtl F ON F.PersonnelID = S.PersonnelID AND F.MonthCode = S.MonthCode
		INNER JOIN prs.tblDecreeHdr D ON D.PersonnelID = S.PersonnelID AND D.SerialNo = S.DecreeSerialNo AND InsurableOvertime=1	
		WHERE (LeaveWithPayAmount <> 0) AND (S.MonthCode = @MonthCode)
		
		INSERT INTO #tblBills1(PersonnelID, BenefitAmount, BenefitName,BenefitTime,BenefitUnit,BenefitBaseAmount)
		SELECT D.PersonnelID, HourlyLeaveWithPayAmount, ' مبلغ مرخصی ساعتی ', prs.funGetMinutes(F.LeaveTime),'دقیقه', D.LeavePay / @DailyMin * 60
		FROM prs.tblSalaryCalculation S 
		INNER JOIN #tblPrs1 P ON S.PersonnelID = P.PersonnelID
		INNER JOIN prs.tblFunctionsDtl F ON F.PersonnelID = S.PersonnelID AND F.MonthCode = S.MonthCode
		INNER JOIN prs.tblDecreeHdr D ON D.PersonnelID = S.PersonnelID AND D.SerialNo = S.DecreeSerialNo AND InsurableOvertime=1	
		WHERE (HourlyLeaveWithPayAmount <> 0) AND (S.MonthCode = @MonthCode)		
	end

end 
else
begin
	if @DontShowSalary = 0
	begin
		if @ShowDtlBasePay=0
			INSERT INTO #tblBills1(PersonnelID, BenefitAmount, BenefitName,BenefitTime,BenefitUnit,BenefitBaseAmount)
			SELECT D.PersonnelID,BaseSalaryAmount +LeaveWithPayAmount+HourlyLeaveWithPayAmount-SalaryAmountTime - S.LeaveAmount, 'حقوق', (F.MonthlyFunction- F.SickLeave),'روز',D.Basepay
			FROM prs.tblSalaryCalculation S 
					INNER JOIN #tblPrs1 P ON S.PersonnelID = P.PersonnelID
					INNER JOIN prs.tblDecreeHdr D ON D.PersonnelID = S.PersonnelID AND D.SerialNo = S.DecreeSerialNo
					INNER JOIN prs.tblFunctionsDtl F ON F.PersonnelID = S.PersonnelID AND F.MonthCode = S.MonthCode
			WHERE (S.MonthCode = @MonthCode) and (F.MonthlyFunction- F.SickLeave)>0
			and BaseSalaryAmount +LeaveWithPayAmount+HourlyLeaveWithPayAmount-SalaryAmountTime - S.LeaveAmount>0
		else
			INSERT INTO #tblBills1(PersonnelID, BenefitAmount, BenefitName,BenefitTime,BenefitUnit,BenefitBaseAmount)	
			SELECT D.PersonnelID,(BaseSalaryAmount +LeaveWithPayAmount+HourlyLeaveWithPayAmount-SalaryAmountTime - S.LeaveAmount-(PastWagesDailyPay+DailyInferiorPay+DailyInferiorPayRemain)*(F.MonthlyFunction- F.SickLeave)), 'مزد گروه شغلی', (F.MonthlyFunction- F.SickLeave),'روز', JobCategoryPay
			FROM prs.tblSalaryCalculation S 
				INNER JOIN #tblPrs1 P ON S.PersonnelID = P.PersonnelID
				INNER JOIN prs.tblDecreeHdr D ON D.PersonnelID = S.PersonnelID AND D.SerialNo = S.DecreeSerialNo
				INNER JOIN prs.tblFunctionsDtl F ON F.PersonnelID = S.PersonnelID AND F.MonthCode = S.MonthCode
			WHERE (S.MonthCode = @MonthCode)  
			and (F.MonthlyFunction- F.SickLeave)>0
			and BaseSalaryAmount +LeaveWithPayAmount+HourlyLeaveWithPayAmount-SalaryAmountTime - S.LeaveAmount>0
			union all
			SELECT D.PersonnelID,(PastWagesDailyPay*(F.MonthlyFunction- F.SickLeave)), 'مزد سنوات', (F.MonthlyFunction- F.SickLeave),'روز', D.PastWagesDailyPay
			FROM prs.tblSalaryCalculation S 
				INNER JOIN #tblPrs1 P ON S.PersonnelID = P.PersonnelID
				INNER JOIN prs.tblDecreeHdr D ON D.PersonnelID = S.PersonnelID AND D.SerialNo = S.DecreeSerialNo
				INNER JOIN prs.tblFunctionsDtl F ON F.PersonnelID = S.PersonnelID AND F.MonthCode = S.MonthCode
			WHERE (S.MonthCode = @MonthCode)  
			and (F.MonthlyFunction- F.SickLeave)>0
			and BaseSalaryAmount +LeaveWithPayAmount+HourlyLeaveWithPayAmount-SalaryAmountTime - S.LeaveAmount>0
			and PastWagesDailyPay>0
			union all
			SELECT D.PersonnelID,(DailyInferiorPay*(F.MonthlyFunction- F.SickLeave)), 'حق پست', (F.MonthlyFunction- F.SickLeave),'روز', DailyInferiorPay
			FROM prs.tblSalaryCalculation S 
				INNER JOIN #tblPrs1 P ON S.PersonnelID = P.PersonnelID
				INNER JOIN prs.tblDecreeHdr D ON D.PersonnelID = S.PersonnelID AND D.SerialNo = S.DecreeSerialNo
				INNER JOIN prs.tblFunctionsDtl F ON F.PersonnelID = S.PersonnelID AND F.MonthCode = S.MonthCode
			WHERE (S.MonthCode = @MonthCode)  
			and (F.MonthlyFunction- F.SickLeave)>0
			and BaseSalaryAmount +LeaveWithPayAmount+HourlyLeaveWithPayAmount-SalaryAmountTime - S.LeaveAmount>0
			and DailyInferiorPay>0
			union all
			SELECT D.PersonnelID,(DailyInferiorPayRemain*(F.MonthlyFunction- F.SickLeave)), 'حق ماندگاری پست', (F.MonthlyFunction- F.SickLeave),'روز', DailyInferiorPayRemain
			FROM prs.tblSalaryCalculation S 
				INNER JOIN #tblPrs1 P ON S.PersonnelID = P.PersonnelID
				INNER JOIN prs.tblDecreeHdr D ON D.PersonnelID = S.PersonnelID AND D.SerialNo = S.DecreeSerialNo
				INNER JOIN prs.tblFunctionsDtl F ON F.PersonnelID = S.PersonnelID AND F.MonthCode = S.MonthCode
			WHERE (S.MonthCode = @MonthCode)  
			and (F.MonthlyFunction- F.SickLeave)>0
			and BaseSalaryAmount +LeaveWithPayAmount+HourlyLeaveWithPayAmount-SalaryAmountTime - S.LeaveAmount>0
			and DailyInferiorPayRemain>0

		INSERT INTO #tblBills1(PersonnelID, BenefitAmount, BenefitName,BenefitTime,BenefitUnit,BenefitBaseAmount)
		SELECT D.PersonnelID,SalaryAmountTime , 'حقوق ساعتی', F.MonthlyFunctionTime,'ساعت',D.BasepayTime
		FROM prs.tblSalaryCalculation S 
				INNER JOIN #tblPrs1 P ON S.PersonnelID = P.PersonnelID
				INNER JOIN prs.tblDecreeHdr D ON D.PersonnelID = S.PersonnelID AND D.SerialNo = S.DecreeSerialNo
				INNER JOIN prs.tblFunctionsDtl F ON F.PersonnelID = S.PersonnelID AND F.MonthCode = S.MonthCode
		WHERE (S.MonthCode = @MonthCode) 
		and SalaryAmountTime>0

	end 

end 

If (@ShowRemain = 1)
Begin
	insert into #tblBills2(PersonnelID, BenefitAmount, BenefitName)
	select R.PersonnelID, R.DebitRemain, 'مانده بدهکاری'
	from
	(
		SELECT S.PersonnelID,
				isnull((
					select SUM(V.Debit-V.Credit)
					from acc.tblVoucherDtl V
					where (V.AcntCode = D.AcntSalary)  AND (SerialNo<> S.VchNo OR (SerialNo=S.VchNo AND V.SourceDocType NOT IN(3) AND V.SourceProcessID NOT IN(310,315)) ) AND (V.VchKind not in ( 0,3)) AND ((V.DocDate < @RemainDate) OR (V.DocDate = @RemainDate AND V.SourceDocType NOT IN(3) AND V.SourceProcessID NOT IN(310,315)))   --(V.AcntCode = D.AcntSalary) AND (((V.VchKind <> 0) AND (V.DocDate < @RemainDate)) OR () )   
				),0) DebitRemain
		FROM prs.tblSalaryCalculation S 
				INNER JOIN #tblPrs P ON S.PersonnelID = P.PersonnelID
				INNER JOIN prs.tblDecreeHdr D ON D.PersonnelID = S.PersonnelID AND D.SerialNo = S.DecreeSerialNo
		WHERE (S.MonthCode = @MonthCode) 
	) R
	where R.DebitRemain >= 0
	
	insert into #tblBills1(PersonnelID, BenefitAmount, BenefitName)
	select R.PersonnelID, 0-R.DebitRemain, 'مانده بستانکاری'
	from
	(
		SELECT S.PersonnelID,
				isnull((
					select SUM(V.Debit-V.Credit)
					from acc.tblVoucherDtl V
					where (V.AcntCode = D.AcntSalary) AND (SerialNo<> S.VchNo OR (SerialNo=S.VchNo AND V.SourceDocType NOT IN(3) AND V.SourceProcessID NOT IN(310,315)) ) AND (V.VchKind not in ( 0,3)) AND ((V.DocDate < @RemainDate) OR (V.DocDate = @RemainDate AND V.SourceDocType NOT IN(3) AND V.SourceProcessID NOT IN(310,315)))   --(V.VchKind <> 0) and (V.DocDate <= @RemainDate) and (V.AcntCode = D.AcntSalary)
				),0) DebitRemain
		FROM prs.tblSalaryCalculation S 
				INNER JOIN #tblPrs P ON S.PersonnelID = P.PersonnelID
				INNER JOIN prs.tblDecreeHdr D ON D.PersonnelID = S.PersonnelID AND D.SerialNo = S.DecreeSerialNo
		WHERE (S.MonthCode = @MonthCode)
	) R
	where R.DebitRemain < 0
End

if (@BenefitTypeShow = 0)
begin	
	INSERT INTO #tblBills2(PersonnelID, BenefitAmount, BenefitName)
	SELECT S.PersonnelID, S.AdvanceAmount, 'مساعده'
	FROM prs.tblSalaryCalculation S 
	INNER JOIN #tblPrs P ON S.PersonnelID = P.PersonnelID
	WHERE (S.AdvanceAmount > 0) AND (S.MonthCode = @MonthCode)
	
	INSERT INTO #tblBills2(PersonnelID, BenefitAmount, BenefitName)
	SELECT S.PersonnelID, S.BuyAmount, 'خرید کارکنان'
	FROM prs.tblSalaryCalculation S 
	INNER JOIN #tblPrs P ON S.PersonnelID = P.PersonnelID
	WHERE (S.BuyAmount > 0) AND (S.MonthCode = @MonthCode)	
	
	INSERT INTO #tblBills2(PersonnelID, BenefitAmount, BenefitName)
	SELECT S.PersonnelID, S.EmployDebitAmount, 'جاری کارکنان'
	FROM prs.tblSalaryCalculation S 
	INNER JOIN #tblPrs P ON S.PersonnelID = P.PersonnelID
	WHERE (S.EmployDebitAmount > 0) AND (S.MonthCode = @MonthCode)	
	
	INSERT INTO #tblBills2(PersonnelID, BenefitAmount, BenefitName)
	SELECT S.PersonnelID, S.CommissionAmount, 'پورسانت کارکنان'
	FROM prs.tblSalaryCalculation S 
	INNER JOIN #tblPrs P ON S.PersonnelID = P.PersonnelID
	WHERE (S.CommissionAmount > 0) AND (S.MonthCode = @MonthCode)	
	
	INSERT INTO #tblBills2(PersonnelID, BenefitAmount, BenefitName)
	SELECT S.PersonnelID, S.DriverCommissionAmount, 'کمسیون راننده'
	FROM prs.tblSalaryCalculation S 
	INNER JOIN #tblPrs P ON S.PersonnelID = P.PersonnelID
	WHERE (S.DriverCommissionAmount > 0) AND (S.MonthCode = @MonthCode)		

	INSERT INTO #tblBills2(PersonnelID, BenefitAmount, BenefitName)
	SELECT S.PersonnelID, S.CostAmount, 'طلب هزینه  کارکنان'
	FROM prs.tblSalaryCalculation S 
	INNER JOIN #tblPrs P ON S.PersonnelID = P.PersonnelID
	WHERE (S.CostAmount > 0) AND (S.MonthCode = @MonthCode)	

end

if (@BenefitTypeShow = 1)
begin	
	INSERT INTO #tblBills2(PersonnelID, BenefitAmount, BenefitName)
	SELECT S.PersonnelID, S.AdvanceAmount, 'مساعده'
	FROM prs.tblSalaryCalculation S 
	INNER JOIN #tblPrs P ON S.PersonnelID = P.PersonnelID
	INNER JOIN prs.tblFunctionsDtl F ON F.PersonnelID = S.PersonnelID AND F.MonthCode = S.MonthCode
	INNER join prs.tblDecreeHdr D ON D.PersonnelID = S.PersonnelID and S.DecreeSerialNo=D.SerialNo AND (@ShowAdvanceAmount=1 )
	WHERE (S.AdvanceAmount > 0) AND (S.MonthCode = @MonthCode)	
	
	INSERT INTO #tblBills2(PersonnelID, BenefitAmount, BenefitName)
	SELECT S.PersonnelID, S.BuyAmount, 'خرید کارکنان'
	FROM prs.tblSalaryCalculation S 
	INNER JOIN #tblPrs P ON S.PersonnelID = P.PersonnelID
	WHERE (S.BuyAmount > 0) AND (S.MonthCode = @MonthCode)	AND (@ShowBuyAmount=1 )
end	

if (@BenefitTypeShow = 2)
begin	
	INSERT INTO #tblBills2(PersonnelID, BenefitAmount, BenefitName)
	SELECT S.PersonnelID, S.AdvanceAmount, 'مساعده'
	FROM prs.tblSalaryCalculation S 
	INNER JOIN #tblPrs P ON S.PersonnelID = P.PersonnelID
	INNER JOIN prs.tblFunctionsDtl F ON F.PersonnelID = S.PersonnelID AND F.MonthCode = S.MonthCode
	INNER join prs.tblDecreeHdr D ON D.PersonnelID = S.PersonnelID and S.DecreeSerialNo=D.SerialNo AND (@ShowAdvanceAmount2=1 )
	WHERE (S.AdvanceAmount > 0) AND (S.MonthCode = @MonthCode)		
end	
if (@BenefitTypeShow = 2)
begin	
	
	INSERT INTO #tblBills2(PersonnelID, BenefitAmount, BenefitName)
	SELECT S.PersonnelID, S.BuyAmount, 'خرید کارکنان'
	FROM prs.tblSalaryCalculation S 
	INNER JOIN #tblPrs P ON S.PersonnelID = P.PersonnelID
	WHERE (S.BuyAmount > 0) AND (S.MonthCode = @MonthCode)	AND (@ShowBuyAmount2=1 )	
	
	INSERT INTO #tblBills2(PersonnelID, BenefitAmount, BenefitName)
	SELECT S.PersonnelID, S.EmployDebitAmount, 'جاری کارکنان'
	FROM prs.tblSalaryCalculation S 
	INNER JOIN #tblPrs P ON S.PersonnelID = P.PersonnelID
	WHERE (S.EmployDebitAmount > 0) AND (S.MonthCode = @MonthCode)	
	
	INSERT INTO #tblBills2(PersonnelID, BenefitAmount, BenefitName)
	SELECT S.PersonnelID, S.CommissionAmount, 'پورسانت کارکنان'
	FROM prs.tblSalaryCalculation S 
	INNER JOIN #tblPrs P ON S.PersonnelID = P.PersonnelID
	WHERE (S.CommissionAmount > 0) AND (S.MonthCode = @MonthCode)	
		
	INSERT INTO #tblBills2(PersonnelID, BenefitAmount, BenefitName)
	SELECT S.PersonnelID, S.DriverCommissionAmount, 'کمسیون راننده'
	FROM prs.tblSalaryCalculation S 
	INNER JOIN #tblPrs P ON S.PersonnelID = P.PersonnelID
	WHERE (S.DriverCommissionAmount > 0) AND (S.MonthCode = @MonthCode)	
		
	INSERT INTO #tblBills2(PersonnelID, BenefitAmount, BenefitName)
	SELECT S.PersonnelID, S.CostAmount, 'طلب هزینه کارکنان'
	FROM prs.tblSalaryCalculation S 
	INNER JOIN #tblPrs P ON S.PersonnelID = P.PersonnelID
	WHERE (S.CostAmount > 0) AND (S.MonthCode = @MonthCode)	
end

	if (@ShowCele01 = 1)
		INSERT INTO #tblBills1(PersonnelID, BenefitAmount, BenefitName,BenefitTime,BenefitUnit)
		SELECT C.PersonnelID, isnull(sum(C.Cost),0), 'عیدی',C.ManualTotalDays,'روز'
		FROM prs.tblCelebrationDtl C INNER JOIN #tblPrs P ON C.PersonnelID = P.PersonnelID
		WHERE (C.MonthCode = @MonthCode) and (C.ProcessID = 320) and (Payable=1 or @ShowCele03=1)
		group by C.PersonnelID,ManualTotalDays
	
	if @MonthCode=12
		INSERT INTO #tblBills2(PersonnelID, BenefitAmount, BenefitName,BenefitTime,BenefitUnit)
		SELECT C.PersonnelID, isnull(sum(C.Cost*-1),0), 'تعدیل مبلغ عیدی',C.ManualTotalDays,'روز'
		FROM prs.tblCelebrationDtl C INNER JOIN #tblPrs P ON C.PersonnelID = P.PersonnelID
		WHERE (C.MonthCode = 13) and (C.ProcessID = 320) and (Payable=1 or @ShowCele03=1)
		group by C.PersonnelID	,ManualTotalDays
	if (@ShowCele02 = 1)
		INSERT INTO #tblBills1(PersonnelID, BenefitAmount, BenefitName,BenefitTime,BenefitUnit)
		SELECT C.PersonnelID, isnull(sum(C.Cost),0), 'پایانکار',C.ManualTotalDays,'روز'
		FROM prs.tblCelebrationDtl C INNER JOIN #tblPrs P ON C.PersonnelID = P.PersonnelID
		WHERE (C.MonthCode = @MonthCode) and (C.ProcessID = 325) and (Payable=1  or @ShowCele03=1)
		group by C.PersonnelID,ManualTotalDays
 if @MonthCode=12
		INSERT INTO #tblBills2(PersonnelID, BenefitAmount, BenefitName,BenefitTime,BenefitUnit)
		SELECT C.PersonnelID, isnull(sum(C.Cost*-1),0), 'تعدیل مبلغ پایانکار',C.ManualTotalDays,'روز'
		FROM prs.tblCelebrationDtl C INNER JOIN #tblPrs P ON C.PersonnelID = P.PersonnelID
		WHERE (C.MonthCode = 13) and (C.ProcessID = 325) and (Payable=1 or @ShowCele03=1)
		group by C.PersonnelID	,ManualTotalDays
	


	INSERT INTO #tblBills1(PersonnelID, BenefitAmount, BenefitName)
	SELECT S.PersonnelID, 0-S.AdvanceAmount, 'اضافه کسری مساعده'
	FROM prs.tblSalaryCalculation S INNER JOIN #tblPrs P ON S.PersonnelID = P.PersonnelID
	WHERE (S.AdvanceAmount < 0) AND (S.MonthCode = @MonthCode)

	INSERT INTO #tblBills1(PersonnelID, BenefitAmount, BenefitName)
	SELECT S.PersonnelID, 0-S.BuyAmount, 'اضافه کسری خرید کارکنان '
	FROM prs.tblSalaryCalculation S INNER JOIN #tblPrs P ON S.PersonnelID = P.PersonnelID
	WHERE (S.BuyAmount < 0) AND (S.MonthCode = @MonthCode)

	INSERT INTO #tblBills1(PersonnelID, BenefitAmount, BenefitName)
	SELECT S.PersonnelID, 0-S.EmployDebitAmount, 'اضافه کسری جاری کارکنان '
	FROM prs.tblSalaryCalculation S INNER JOIN #tblPrs P ON S.PersonnelID = P.PersonnelID
	WHERE (S.EmployDebitAmount < 0) AND (S.MonthCode = @MonthCode)
	
	INSERT INTO #tblBills1(PersonnelID, BenefitAmount, BenefitName)
	SELECT S.PersonnelID, 0-S.CommissionAmount, 'پورسانت کارکنان '
	FROM prs.tblSalaryCalculation S INNER JOIN #tblPrs P ON S.PersonnelID = P.PersonnelID
	WHERE (S.CommissionAmount < 0) AND (S.MonthCode = @MonthCode)

	INSERT INTO #tblBills1(PersonnelID, BenefitAmount, BenefitName)
	SELECT S.PersonnelID, 0-S.DriverCommissionAmount, 'کمسیون راننده'
	FROM prs.tblSalaryCalculation S INNER JOIN #tblPrs P ON S.PersonnelID = P.PersonnelID
	WHERE (S.DriverCommissionAmount < 0) AND (S.MonthCode = @MonthCode)

	
	INSERT INTO #tblBills1(PersonnelID, BenefitAmount, BenefitName)
	SELECT S.PersonnelID, 0-S.CostAmount, 'طلب هزینه کارکنان '
	FROM prs.tblSalaryCalculation S INNER JOIN #tblPrs P ON S.PersonnelID = P.PersonnelID
	WHERE (S.CostAmount < 0) AND (S.MonthCode = @MonthCode)

if (@BenefitTypeShow = 0)
begin	
	INSERT INTO #tblBills1(PersonnelID, BenefitAmount, BenefitName,BenefitTime,BenefitUnit,BenefitBaseAmount)
	SELECT S.PersonnelID, S.OvertimeAmount, 'اضافه کاری', F.HourlyOvertime,'ساعت',D.HourlyOvertimeBase
	FROM prs.tblSalaryCalculation S INNER JOIN #tblPrs P ON S.PersonnelID = P.PersonnelID
	INNER join prs.tblDecreeHdr D ON D.PersonnelID = S.PersonnelID and S.DecreeSerialNo=D.SerialNo
	INNER JOIN prs.tblFunctionsDtl F ON F.PersonnelID = S.PersonnelID AND F.MonthCode = S.MonthCode
	WHERE (S.OvertimeAmount <> 0) AND (S.MonthCode = @MonthCode)
end

if (@BenefitTypeShow = 1)
begin	
	INSERT INTO #tblBills1(PersonnelID, BenefitAmount, BenefitName,BenefitTime,BenefitUnit,BenefitBaseAmount)
	SELECT S.PersonnelID, S.OvertimeAmount, 'اضافه کاری', F.HourlyOvertime,'ساعت',D.HourlyOvertimeBase
	FROM prs.tblSalaryCalculation S INNER JOIN #tblPrs P ON S.PersonnelID = P.PersonnelID
	INNER JOIN prs.tblFunctionsDtl F ON F.PersonnelID = S.PersonnelID AND F.MonthCode = S.MonthCode
	INNER join prs.tblDecreeHdr D ON D.PersonnelID = S.PersonnelID and S.DecreeSerialNo=D.SerialNo
	and InsurableOvertime=1	
	WHERE (S.OvertimeAmount <> 0) AND (S.MonthCode = @MonthCode)
end

if (@BenefitTypeShow = 2)
begin	
	INSERT INTO #tblBills1(PersonnelID, BenefitAmount, BenefitName,BenefitTime,BenefitUnit,BenefitBaseAmount)
	SELECT S.PersonnelID, S.OvertimeAmount, 'اضافه کاری', F.HourlyOvertime,'ساعت',D.HourlyOvertimeBase
	FROM prs.tblSalaryCalculation S INNER JOIN #tblPrs P ON S.PersonnelID = P.PersonnelID
	INNER JOIN prs.tblFunctionsDtl F ON F.PersonnelID = S.PersonnelID AND F.MonthCode = S.MonthCode
	INNER join prs.tblDecreeHdr D ON D.PersonnelID = S.PersonnelID and S.DecreeSerialNo=D.SerialNo
	and InsurableOvertime=0
	WHERE (S.OvertimeAmount <> 0) AND (S.MonthCode = @MonthCode)
end


	DECLARE @PeriodWorkID			VARCHAR(20)
	DECLARE @PeriodWorkName			VARCHAR(50)
	DECLARE @InsurablePeriodWorks	Bit
	DECLARE @PeriodWorksTime		Bit
	DECLARE @StrTemp				NVARCHAR(2000)

	DECLARE csr CURSOR FOR 
		SELECT D.PeriodWorkID, D.PeriodWorkName, H.InsurablePeriodWorks, PeriodWorksTime 
		FROM emp.tblPeriodWorksDtl D
		INNER JOIN emp.tblPeriodWorks H ON H.PeriodWorkID = D.PeriodWorkID
		WHERE (LTrim(D.PeriodWorkID) <> '') AND (LTrim(Str(D.LanguageID)) = @LangID)

	OPEN csr
	FETCH NEXT FROM csr INTO @PeriodWorkID, @PeriodWorkName, @InsurablePeriodWorks,@PeriodWorksTime

	WHILE @@Fetch_Status = 0
	BEGIN

		--IF @InsurablePeriodWorks = 'True'
		--	SET @StrTemp = '
		--		INSERT INTO #tblBills1(PersonnelID, BenefitAmount, BenefitName)
		--		SELECT S.PersonnelID, S.PeriodWorkAmount' + LTRim(@PeriodWorkID) + ', ''' + @PeriodWorkName + '''
		--		FROM prs.tblSalaryCalculation S 
		--		INNER JOIN #tblPrs P ON S.PersonnelID = P.PersonnelID	
		--		WHERE (S.PeriodWorkAmount' + LTRim(@PeriodWorkID) + ' <> 0) AND (S.MonthCode = ' + LTrim(Str(@MonthCode)) + ') '
		--ELSE
		--Begin
			-- ======================================  
			if (@BenefitTypeShow = 0)
			begin	
				SET @StrTemp = '
					INSERT INTO #tblBills1(PersonnelID, BenefitAmount, BenefitName,BenefitType,BenefitTime,BenefitUnit)
					SELECT S.PersonnelID, S.PeriodWorkAmount' + LTRim(@PeriodWorkID) + ', ''' + @PeriodWorkName + ''',13 
					, case when ' + LTRim(@PeriodWorksTime) + '=1 then  F.PeriodWorkTime' + LTRim(@PeriodWorkID) + ' else str( F.PeriodWork' + LTRim(@PeriodWorkID) + ') end 
					, case when ' + LTRim(@PeriodWorksTime) + '=1 then  ''ساعت'' else ''روز'' end 
					FROM prs.tblSalaryCalculation S 
					INNER JOIN #tblPrs P ON S.PersonnelID = P.PersonnelID	
					INNER JOIN prs.tblFunctionsDtl F ON F.PersonnelID = S.PersonnelID AND F.MonthCode = S.MonthCode
					WHERE (S.PeriodWorkAmount' + LTRim(@PeriodWorkID) + ' <> 0) AND (S.MonthCode = ' + LTrim(Str(@MonthCode)) + ') '
			end
			if (@BenefitTypeShow = 1)
			begin	
				SET @StrTemp = '
					INSERT INTO #tblBills1(PersonnelID, BenefitAmount, BenefitName,BenefitType,BenefitTime,BenefitUnit)
					SELECT S.PersonnelID, S.PeriodWorkAmount' + LTRim(@PeriodWorkID) + ', ''' + @PeriodWorkName + ''',13
					, case when ' + LTRim(@PeriodWorksTime) + '=1 then  F.PeriodWorkTime' + LTRim(@PeriodWorkID) + ' else str( F.PeriodWork' + LTRim(@PeriodWorkID) + ') end 
					, case when ' + LTRim(@PeriodWorksTime) + '=1 then  ''ساعت'' else ''روز'' end 
					FROM prs.tblSalaryCalculation S 
					INNER JOIN #tblPrs P ON S.PersonnelID = P.PersonnelID	
					INNER JOIN prs.tblFunctionsDtl F ON F.PersonnelID = S.PersonnelID AND F.MonthCode = S.MonthCode
					INNER JOIN emp.tblPeriodWorks PW on PW.PeriodWorkID=''' + LTRim(@PeriodWorkID) + ''' and InsurablePeriodWorks=1
					WHERE (S.PeriodWorkAmount' + LTRim(@PeriodWorkID) + ' <> 0) AND 
						  (S.MonthCode = ' + LTrim(Str(@MonthCode)) + ') AND ' + LTrim(RTrim(Str(@InsurablePeriodWorks))) + ' = 1 '
									
			end
			if (@BenefitTypeShow = 2)
			begin	
				SET @StrTemp = '
					INSERT INTO #tblBills1(PersonnelID, BenefitAmount, BenefitName,BenefitType,BenefitTime,BenefitUnit)
					SELECT S.PersonnelID, S.PeriodWorkAmount' + LTRim(@PeriodWorkID) + ', ''' + @PeriodWorkName + ''',13
					, case when ' + LTRim(@PeriodWorksTime) + '=1 then  F.PeriodWorkTime' + LTRim(@PeriodWorkID) + ' else str( F.PeriodWork' + LTRim(@PeriodWorkID) + ') end 
					, case when ' + LTRim(@PeriodWorksTime) + '=1 then  ''ساعت'' else ''روز'' end 
					FROM prs.tblSalaryCalculation S 
					INNER JOIN #tblPrs P ON S.PersonnelID = P.PersonnelID	
					INNER JOIN prs.tblFunctionsDtl F ON F.PersonnelID = S.PersonnelID AND F.MonthCode = S.MonthCode
					INNER JOIN emp.tblPeriodWorks PW  on PW.PeriodWorkID=''' + LTRim(@PeriodWorkID) + ''' and InsurablePeriodWorks=0
					WHERE (S.PeriodWorkAmount' + LTRim(@PeriodWorkID) + ' <> 0) AND 
						  (S.MonthCode = ' + LTrim(Str(@MonthCode)) + ') AND ' + LTrim(RTrim(Str(@InsurablePeriodWorks))) + ' = 0 '
			end
		--End
			print @StrTemp
		Exec sp_executesql @StrTemp; 

		FETCH NEXT FROM csr INTO @PeriodWorkID, @PeriodWorkName, @InsurablePeriodWorks,@PeriodWorksTime
	END

	CLOSE csr
	DEALLOCATE csr

if (@BenefitTypeShow = 0)
begin	
	INSERT INTO #tblBills1(PersonnelID, BenefitAmount, BenefitName,BenefitTime,BenefitUnit,BenefitBaseAmount)
	SELECT S.PersonnelID, S.VacationAmount, 'اضافه کار تعطیلی', F.VacationOvertime,'ساعت', D.VacationOvertimeBase
	FROM prs.tblSalaryCalculation S INNER JOIN #tblPrs P ON S.PersonnelID = P.PersonnelID
		INNER JOIN prs.tblFunctionsDtl F ON F.PersonnelID = S.PersonnelID AND F.MonthCode = S.MonthCode
	INNER join prs.tblDecreeHdr D ON D.PersonnelID = S.PersonnelID and S.DecreeSerialNo=D.SerialNo
	WHERE (S.VacationAmount <> 0) AND (S.MonthCode = @MonthCode)
end
if (@BenefitTypeShow = 1)
begin	
	INSERT INTO #tblBills1(PersonnelID, BenefitAmount, BenefitName,BenefitTime,BenefitUnit,BenefitBaseAmount)
	SELECT S.PersonnelID, S.VacationAmount, 'اضافه کار تعطیلی', F.VacationOvertime,'ساعت', D.VacationOvertimeBase
	FROM prs.tblSalaryCalculation S INNER JOIN #tblPrs P ON S.PersonnelID = P.PersonnelID
		INNER JOIN prs.tblFunctionsDtl F ON F.PersonnelID = S.PersonnelID AND F.MonthCode = S.MonthCode
	INNER join prs.tblDecreeHdr D ON D.PersonnelID = S.PersonnelID and S.DecreeSerialNo=D.SerialNo
	and InsurableOvertime=1	
	WHERE (S.VacationAmount <> 0) AND (S.MonthCode = @MonthCode)
end
if (@BenefitTypeShow = 2)
begin	
	INSERT INTO #tblBills1(PersonnelID, BenefitAmount, BenefitName,BenefitTime,BenefitUnit,BenefitBaseAmount)
	SELECT S.PersonnelID, S.VacationAmount, 'اضافه کار تعطیلی', F.VacationOvertime,'ساعت', D.VacationOvertimeBase
	FROM prs.tblSalaryCalculation S INNER JOIN #tblPrs P ON S.PersonnelID = P.PersonnelID
		INNER JOIN prs.tblFunctionsDtl F ON F.PersonnelID = S.PersonnelID AND F.MonthCode = S.MonthCode
	INNER join prs.tblDecreeHdr D ON D.PersonnelID = S.PersonnelID and S.DecreeSerialNo=D.SerialNo
	and InsurableOvertime=0	
	WHERE (S.VacationAmount <> 0) AND (S.MonthCode = @MonthCode)
end

if (@BenefitTypeShow = 0)
begin	
	INSERT INTO #tblBills1(PersonnelID, BenefitAmount, BenefitName,BenefitTime,BenefitUnit,BenefitBaseAmount)
	SELECT S.PersonnelID, S.MissionTimeAmount, 'ماموریت ساعتی', F.MissionTime,'ساعت', D.MissionTime
	FROM prs.tblSalaryCalculation S INNER JOIN #tblPrs P ON S.PersonnelID = P.PersonnelID
		INNER JOIN prs.tblFunctionsDtl F ON F.PersonnelID = S.PersonnelID AND F.MonthCode = S.MonthCode
	INNER join prs.tblDecreeHdr D ON D.PersonnelID = S.PersonnelID and S.DecreeSerialNo=D.SerialNo
	WHERE (S.MissionTimeAmount <> 0) AND (S.MonthCode = @MonthCode)
end
if (@BenefitTypeShow = 1)
begin	
	INSERT INTO #tblBills1(PersonnelID, BenefitAmount, BenefitName,BenefitTime,BenefitUnit,BenefitBaseAmount)
	SELECT S.PersonnelID, S.MissionTimeAmount, 'ماموریت ساعتی', F.MissionTime,'ساعت', D.MissionTime
	FROM prs.tblSalaryCalculation S INNER JOIN #tblPrs P ON S.PersonnelID = P.PersonnelID
	INNER JOIN prs.tblFunctionsDtl F ON F.PersonnelID = S.PersonnelID AND F.MonthCode = S.MonthCode
	INNER join prs.tblDecreeHdr D ON D.PersonnelID = S.PersonnelID and S.DecreeSerialNo=D.SerialNo
	and InsurableOvertime=1	
	WHERE (S.MissionTimeAmount <> 0) AND (S.MonthCode = @MonthCode)
end
if (@BenefitTypeShow = 2)
begin	
	INSERT INTO #tblBills1(PersonnelID, BenefitAmount, BenefitName,BenefitTime,BenefitUnit,BenefitBaseAmount)
	SELECT S.PersonnelID, S.MissionTimeAmount, 'ماموریت ساعتی', F.MissionTime,'ساعت', D.MissionTime
	FROM prs.tblSalaryCalculation S INNER JOIN #tblPrs P ON S.PersonnelID = P.PersonnelID
	INNER JOIN prs.tblFunctionsDtl F ON F.PersonnelID = S.PersonnelID AND F.MonthCode = S.MonthCode
	INNER join prs.tblDecreeHdr D ON D.PersonnelID = S.PersonnelID and S.DecreeSerialNo=D.SerialNo
	and InsurableOvertime=0	
	WHERE (S.MissionTimeAmount <> 0) AND (S.MonthCode = @MonthCode)
end

if (@BenefitTypeShow = 0)
begin	
	INSERT INTO #tblBills1(PersonnelID, BenefitAmount, BenefitName,BenefitTime,BenefitUnit,BenefitBaseAmount)
	SELECT S.PersonnelID, S.MissionDailyAmount, 'ماموریت روزانه', F.MissionDaily,'روز', D.MissionDaily
	FROM prs.tblSalaryCalculation S INNER JOIN #tblPrs P ON S.PersonnelID = P.PersonnelID
	INNER JOIN prs.tblFunctionsDtl F ON F.PersonnelID = S.PersonnelID AND F.MonthCode = S.MonthCode
	INNER join prs.tblDecreeHdr D ON D.PersonnelID = S.PersonnelID and S.DecreeSerialNo=D.SerialNo
	WHERE (S.MissionDailyAmount <> 0) AND (S.MonthCode = @MonthCode)
end
if (@BenefitTypeShow = 1)
begin	
	INSERT INTO #tblBills1(PersonnelID, BenefitAmount, BenefitName,BenefitTime,BenefitUnit,BenefitBaseAmount)
	SELECT S.PersonnelID, S.MissionDailyAmount, 'ماموریت روزانه', F.MissionDaily,'روز', D.MissionDaily
	FROM prs.tblSalaryCalculation S INNER JOIN #tblPrs P ON S.PersonnelID = P.PersonnelID
	INNER JOIN prs.tblFunctionsDtl F ON F.PersonnelID = S.PersonnelID AND F.MonthCode = S.MonthCode
	INNER join prs.tblDecreeHdr D ON D.PersonnelID = S.PersonnelID and S.DecreeSerialNo=D.SerialNo
	and InsurableOvertime=1	
	WHERE (S.MissionDailyAmount <> 0) AND (S.MonthCode = @MonthCode)
end
if (@BenefitTypeShow = 2)
begin	
	INSERT INTO #tblBills1(PersonnelID, BenefitAmount, BenefitName,BenefitTime,BenefitUnit,BenefitBaseAmount)
	SELECT S.PersonnelID,S.MissionDailyAmount, 'ماموریت روزانه', F.MissionDaily,'روز', D.MissionDaily
	FROM prs.tblSalaryCalculation S INNER JOIN #tblPrs P ON S.PersonnelID = P.PersonnelID
	INNER JOIN prs.tblFunctionsDtl F ON F.PersonnelID = S.PersonnelID AND F.MonthCode = S.MonthCode
	INNER join prs.tblDecreeHdr D ON D.PersonnelID = S.PersonnelID and S.DecreeSerialNo=D.SerialNo
	and InsurableOvertime=0	
	WHERE (S.MissionDailyAmount <> 0) AND (S.MonthCode = @MonthCode)
end

if (@BenefitTypeShow = 0)
begin	
	INSERT INTO #tblBills2(PersonnelID, BenefitAmount, BenefitName,BenefitTime,BenefitUnit,BenefitBaseAmount)
	SELECT S.PersonnelID, S.WorkDeductionAmount, 'کسر کار',prs.funGetHourMinutesStandard(prs.funGetMinutes(F.WorkDeduction )+prs.funGetMinutes(F.WithoutContactWorkDeduction )),'ساعت', D.HourlyWorkDeductionBase
	FROM prs.tblSalaryCalculation S 
	INNER JOIN #tblPrs P ON S.PersonnelID = P.PersonnelID
	INNER join prs.tblDecreeHdr D ON D.PersonnelID = S.PersonnelID and S.DecreeSerialNo=D.SerialNo
	INNER JOIN prs.tblFunctionsDtl F ON F.PersonnelID = S.PersonnelID AND F.MonthCode = S.MonthCode
	WHERE (S.WorkDeductionAmount <> 0) AND (S.MonthCode = @MonthCode)

	INSERT INTO #tblBills2(PersonnelID, BenefitAmount, BenefitName,BenefitTime,BenefitUnit,BenefitBaseAmount)
	SELECT S.PersonnelID, S.QCQWPersonnelFaultsAmount, 'کسر کار کنترل کیفی',S.QCQWPersonnelFaultsCount,'خطا کنترل کیفی',S.QCQWPersonnelFaultsAmount
	FROM prs.tblSalaryCalculation S 
	INNER JOIN #tblPrs P ON S.PersonnelID = P.PersonnelID
	WHERE (S.QCQWPersonnelFaultsAmount <> 0) AND (S.MonthCode = @MonthCode)

	INSERT INTO #tblBills2(PersonnelID, BenefitAmount, BenefitName)
	SELECT S.PersonnelID, S.EmployeeInsur, 'بیمه'
	FROM prs.tblSalaryCalculation S 
	INNER JOIN #tblPrs P ON S.PersonnelID = P.PersonnelID
	INNER JOIN prs.tblFunctionsDtl F ON F.PersonnelID = S.PersonnelID AND F.MonthCode = S.MonthCode
	WHERE (S.EmployeeInsur <> 0) AND (S.MonthCode = @MonthCode)
	
	INSERT INTO #tblBills2(PersonnelID, BenefitAmount, BenefitName)
	SELECT S.PersonnelID, S.TaxAmount, 'مالیات'
	FROM prs.tblSalaryCalculation S 
	INNER JOIN #tblPrs P ON S.PersonnelID = P.PersonnelID
	INNER JOIN prs.tblFunctionsDtl F ON F.PersonnelID = S.PersonnelID AND F.MonthCode = S.MonthCode
	WHERE (S.TaxAmount <> 0) AND (S.MonthCode = @MonthCode)
	
	INSERT INTO #tblBills2(PersonnelID, BenefitAmount, BenefitName)
	SELECT S.PersonnelID, S.TaxAmountCelebration, 'مالیات برعیدی'
	FROM prs.tblSalaryCalculation S 
	INNER JOIN #tblPrs P ON S.PersonnelID = P.PersonnelID
	INNER JOIN prs.tblFunctionsDtl F ON F.PersonnelID = S.PersonnelID AND F.MonthCode = S.MonthCode
	WHERE (S.TaxAmountCelebration <> 0) AND (S.MonthCode = @MonthCode) and @ShowCele01=1
end
if (@BenefitTypeShow = 1)
begin	
	INSERT INTO #tblBills2(PersonnelID, BenefitAmount, BenefitName,BenefitTime,BenefitUnit,BenefitBaseAmount)
	SELECT S.PersonnelID, S.WorkDeductionAmount, 'کسر کار',prs.funGetHourMinutesStandard(prs.funGetMinutes(F.WorkDeduction )+prs.funGetMinutes(F.WithoutContactWorkDeduction )),'ساعت', D.HourlyWorkDeductionBase
	FROM prs.tblSalaryCalculation S 
	INNER JOIN #tblPrs P ON S.PersonnelID = P.PersonnelID
	INNER JOIN prs.tblFunctionsDtl F ON F.PersonnelID = S.PersonnelID AND F.MonthCode = S.MonthCode
	INNER join prs.tblDecreeHdr D ON D.PersonnelID = S.PersonnelID and S.DecreeSerialNo=D.SerialNo and (@WorkDeductionInsure='True'	or @WorkDeductionTax='True' )
	WHERE (S.WorkDeductionAmount <> 0) AND (S.MonthCode = @MonthCode)

	INSERT INTO #tblBills2(PersonnelID, BenefitAmount, BenefitName,BenefitTime,BenefitUnit,BenefitBaseAmount)
	SELECT S.PersonnelID, S.QCQWPersonnelFaultsAmount, 'کسر کار کنترل کیفی',S.QCQWPersonnelFaultsCount,'خطا کنترل کیفی',S.QCQWPersonnelFaultsAmount
	FROM prs.tblSalaryCalculation S 
	INNER JOIN #tblPrs P ON S.PersonnelID = P.PersonnelID
	INNER join prs.tblDecreeHdr D ON D.PersonnelID = S.PersonnelID and S.DecreeSerialNo=D.SerialNo and (@WorkDeductionInsure='True'	or @WorkDeductionTax='True' )
	WHERE (S.QCQWPersonnelFaultsAmount <> 0) AND (S.MonthCode = @MonthCode)

	INSERT INTO #tblBills2(PersonnelID, BenefitAmount, BenefitName)
	SELECT S.PersonnelID, S.EmployeeInsur, 'بیمه'
	FROM prs.tblSalaryCalculation S 
	INNER JOIN #tblPrs P ON S.PersonnelID = P.PersonnelID
	INNER JOIN prs.tblFunctionsDtl F ON F.PersonnelID = S.PersonnelID AND F.MonthCode = S.MonthCode
	WHERE (S.EmployeeInsur <> 0) AND (S.MonthCode = @MonthCode)
	
	INSERT INTO #tblBills2(PersonnelID, BenefitAmount, BenefitName)
		SELECT S.PersonnelID, S.TaxAmount, 'مالیات'
	FROM prs.tblSalaryCalculation S 
	INNER JOIN #tblPrs P ON S.PersonnelID = P.PersonnelID
	INNER JOIN prs.tblFunctionsDtl F ON F.PersonnelID = S.PersonnelID AND F.MonthCode = S.MonthCode
	WHERE (S.TaxAmount <> 0) AND (S.MonthCode = @MonthCode)		
	
	INSERT INTO #tblBills2(PersonnelID, BenefitAmount, BenefitName)
		SELECT S.PersonnelID, S.TaxAmountCelebration, 'مالیات برعیدی'
	FROM prs.tblSalaryCalculation S 
	INNER JOIN #tblPrs P ON S.PersonnelID = P.PersonnelID
	INNER JOIN prs.tblFunctionsDtl F ON F.PersonnelID = S.PersonnelID AND F.MonthCode = S.MonthCode
	WHERE (S.TaxAmountCelebration <> 0) AND (S.MonthCode = @MonthCode) and @ShowCele01=1
end
if (@BenefitTypeShow = 2)
begin	
	INSERT INTO #tblBills2(PersonnelID, BenefitAmount, BenefitName,BenefitTime,BenefitUnit,BenefitBaseAmount)
	SELECT S.PersonnelID, S.WorkDeductionAmount, 'کسر کار',prs.funGetHourMinutesStandard(prs.funGetMinutes(F.WorkDeduction )+prs.funGetMinutes(F.WithoutContactWorkDeduction )),'ساعت', D.HourlyWorkDeductionBase
	FROM prs.tblSalaryCalculation S 
	INNER JOIN #tblPrs P ON S.PersonnelID = P.PersonnelID
	INNER JOIN prs.tblFunctionsDtl F ON F.PersonnelID = S.PersonnelID AND F.MonthCode = S.MonthCode
	INNER join prs.tblDecreeHdr D ON D.PersonnelID = S.PersonnelID and S.DecreeSerialNo=D.SerialNo and (@WorkDeductionInsure='False' and @WorkDeductionTax='False' ) 
	WHERE (S.WorkDeductionAmount <> 0) AND (S.MonthCode = @MonthCode)	
	
	INSERT INTO #tblBills2(PersonnelID, BenefitAmount, BenefitName,BenefitTime,BenefitUnit,BenefitBaseAmount)
	SELECT S.PersonnelID, S.QCQWPersonnelFaultsAmount, 'کسر کار کنترل کیفی',S.QCQWPersonnelFaultsCount,'خطا کنترل کیفی',S.QCQWPersonnelFaultsAmount
	FROM prs.tblSalaryCalculation S 
	INNER JOIN #tblPrs P ON S.PersonnelID = P.PersonnelID
	INNER join prs.tblDecreeHdr D ON D.PersonnelID = S.PersonnelID and S.DecreeSerialNo=D.SerialNo and (@WorkDeductionInsure='False' and @WorkDeductionTax='False' ) 
	WHERE (S.QCQWPersonnelFaultsAmount <> 0) AND (S.MonthCode = @MonthCode)	
	
end
if (@BenefitTypeShow = 2) or (@BenefitTypeShow = 0)
begin	
	INSERT INTO #tblBills1(PersonnelID, BenefitAmount, BenefitName)
	SELECT S.PersonnelID, S.EmployeeInsur , 'بیمه بعنوان مزايا'
	FROM prs.tblSalaryCalculation S INNER JOIN #tblPrs P ON S.PersonnelID = P.PersonnelID
	WHERE (S.EmployeeInsur <> 0) AND (S.MonthCode = @MonthCode) AND EmployeeInsurIsBenefit='True'

	INSERT INTO #tblBills1(PersonnelID, BenefitAmount, BenefitName)
	SELECT S.PersonnelID, S.TaxAmount , 'مالیات حقوق بعنوان مزايا'
	FROM prs.tblSalaryCalculation S INNER JOIN #tblPrs P ON S.PersonnelID = P.PersonnelID
	WHERE (S.TaxAmount <> 0) AND (S.MonthCode = @MonthCode) AND EmployeeTaxIsBenefit='True'

	INSERT INTO #tblBills1(PersonnelID, BenefitAmount, BenefitName)
	SELECT S.PersonnelID, S.TaxAmountCelebration , 'مالیات عیدی بعنوان مزايا'
	FROM prs.tblSalaryCalculation S INNER JOIN #tblPrs P ON S.PersonnelID = P.PersonnelID
	WHERE (S.TaxAmountCelebration <> 0) AND (S.MonthCode = @MonthCode) AND EmployeeTaxCeleIsBenefit='True' and @ShowCele01=1

	INSERT INTO #tblBills1(PersonnelID, BenefitAmount, BenefitName)
	SELECT S.PersonnelID, S.RoundBefore, 'روند ماه قبل'
	FROM prs.tblSalaryCalculation S INNER JOIN #tblPrs P ON S.PersonnelID = P.PersonnelID
	WHERE (S.RoundBefore > 0) AND (S.MonthCode = @MonthCode)

	INSERT INTO #tblBills2(PersonnelID, BenefitAmount, BenefitName)
	SELECT S.PersonnelID, 0 - S.RoundBefore, 'روند ماه قبل'
	FROM prs.tblSalaryCalculation S INNER JOIN #tblPrs P ON S.PersonnelID = P.PersonnelID
	WHERE (S.RoundBefore < 0) AND (S.MonthCode = @MonthCode)
	

	INSERT INTO #tblBills1(PersonnelID, BenefitAmount, BenefitName)
	SELECT S.PersonnelID, 0 - S.RoundAfter, 'روند ماه بعد'
	FROM prs.tblSalaryCalculation S INNER JOIN #tblPrs P ON S.PersonnelID = P.PersonnelID
	WHERE (S.RoundAfter < 0) AND (S.MonthCode = @MonthCode)

	INSERT INTO #tblBills2(PersonnelID, BenefitAmount, BenefitName)
	SELECT S.PersonnelID, S.RoundAfter, 'روند ماه بعد'
	FROM prs.tblSalaryCalculation S INNER JOIN #tblPrs P ON S.PersonnelID = P.PersonnelID
	WHERE (S.RoundAfter > 0) AND (S.MonthCode = @MonthCode)

end

if (@BenefitTypeShow = 0) or (@BenefitTypeShow = 2 and @prs_SavePrice2InsureList='False') or (@BenefitTypeShow = 1 and @prs_SavePrice2InsureList='True')
begin		
	INSERT INTO #tblBills2(PersonnelID, BenefitAmount, BenefitName)
	SELECT S.PersonnelID,  S.SavePrice, 'ذخیره مبلغ'
	FROM prs.tblSalaryCalculation S INNER JOIN #tblPrs P ON S.PersonnelID = P.PersonnelID
	WHERE (S.SavePrice <> 0) AND (S.MonthCode = @MonthCode)
end	

if (@BenefitTypeShow = 0)
begin	
INSERT INTO #tblBills1(PersonnelID, BenefitAmount, BenefitName,BenefitTime,BenefitUnit,BenefitBaseAmount)
	SELECT S.PersonnelID, S.OverProductAmount, 'مبلغ اضافه تولید',F.OverProduct ,'ساعت', D.HourlyOverProduct
	FROM prs.tblSalaryCalculation S INNER JOIN #tblPrs P ON S.PersonnelID = P.PersonnelID
	INNER JOIN prs.tblFunctionsDtl F ON F.PersonnelID = S.PersonnelID AND F.MonthCode = S.MonthCode
	INNER join prs.tblDecreeHdr D ON D.PersonnelID = S.PersonnelID and S.DecreeSerialNo=D.SerialNo
	WHERE (S.OverProductAmount <> 0) AND (S.MonthCode = @MonthCode)
end
if (@BenefitTypeShow = 1)
begin	
INSERT INTO #tblBills1(PersonnelID, BenefitAmount, BenefitName,BenefitTime,BenefitUnit,BenefitBaseAmount)
	SELECT S.PersonnelID, S.OverProductAmount, 'مبلغ اضافه تولید',F.OverProduct ,'ساعت', D.HourlyOverProduct
	FROM prs.tblSalaryCalculation S INNER JOIN #tblPrs P ON S.PersonnelID = P.PersonnelID
	INNER JOIN prs.tblFunctionsDtl F ON F.PersonnelID = S.PersonnelID AND F.MonthCode = S.MonthCode
	INNER join prs.tblDecreeHdr D ON D.PersonnelID = S.PersonnelID and S.DecreeSerialNo=D.SerialNo
	and InsurablePrdOvertime=1	
	WHERE (S.OverProductAmount <> 0) AND (S.MonthCode = @MonthCode)
end
if (@BenefitTypeShow = 2)
begin	
INSERT INTO #tblBills1(PersonnelID, BenefitAmount, BenefitName,BenefitTime,BenefitUnit,BenefitBaseAmount)
	SELECT S.PersonnelID, S.OverProductAmount, 'مبلغ اضافه تولید',F.OverProduct ,'ساعت', D.HourlyOverProduct
	FROM prs.tblSalaryCalculation S INNER JOIN #tblPrs P ON S.PersonnelID = P.PersonnelID
	INNER JOIN prs.tblFunctionsDtl F ON F.PersonnelID = S.PersonnelID AND F.MonthCode = S.MonthCode
	INNER join prs.tblDecreeHdr  D ON D.PersonnelID = S.PersonnelID and S.DecreeSerialNo=D.SerialNo
	and InsurablePrdOvertime=0	
	WHERE (S.OverProductAmount <> 0) AND (S.MonthCode = @MonthCode)
end

-- ========================================== غیبت
--select @BenefitTypeShow
if (@BenefitTypeShow = 0)
begin	
	INSERT INTO #tblBills2(PersonnelID, BenefitAmount, BenefitName,BenefitTime,BenefitUnit,BenefitBaseAmount)
	SELECT S.PersonnelID, S.AbsenceAmount, 'غیبت',F.Absence ,'روز',D.AbsenceBase
	FROM prs.tblSalaryCalculation S INNER JOIN #tblPrs P ON S.PersonnelID = P.PersonnelID
	INNER join prs.tblDecreeHdr D ON D.PersonnelID = S.PersonnelID and S.DecreeSerialNo=D.SerialNo
	INNER JOIN prs.tblFunctionsDtl F ON F.PersonnelID = S.PersonnelID AND F.MonthCode = S.MonthCode
	WHERE (S.AbsenceAmount <> 0) AND (S.MonthCode = @MonthCode)
end
if (@BenefitTypeShow = 1)
begin	
	INSERT INTO #tblBills2(PersonnelID, BenefitAmount, BenefitName,BenefitTime,BenefitUnit,BenefitBaseAmount)
	SELECT S.PersonnelID, S.AbsenceAmount, 'غیبت',F.Absence ,'روز',D.AbsenceBase
	FROM prs.tblSalaryCalculation S INNER JOIN #tblPrs P ON S.PersonnelID = P.PersonnelID
	INNER JOIN prs.tblFunctionsDtl F ON F.PersonnelID = S.PersonnelID AND F.MonthCode = S.MonthCode
	INNER join prs.tblDecreeHdr D ON D.PersonnelID = S.PersonnelID and S.DecreeSerialNo=D.SerialNo --and InsurablePrdOvertime = 0
	WHERE (S.AbsenceAmount <> 0) AND (S.MonthCode = @MonthCode)
end
--if (@BenefitTypeShow = 2)
--begin	
----print 'غیبت  در لیست بیمه میباشد'
----غیبت  در لیست بیمه میباشد
--	--INSERT INTO #tblBills2(PersonnelID, BenefitAmount, BenefitName,BenefitTime,BenefitUnit)
--	--SELECT S.PersonnelID, S.AbsenceAmount, 'غیبت',F.Absence ,'روز'
--	--FROM prs.tblSalaryCalculation S INNER JOIN #tblPrs P ON S.PersonnelID = P.PersonnelID
--	--INNER JOIN prs.tblFunctionsDtl F ON F.PersonnelID = S.PersonnelID AND F.MonthCode = S.MonthCode
--	--INNER join prs.tblDecreeHdr D ON D.PersonnelID = S.PersonnelID and S.DecreeSerialNo=D.SerialNo and InsurablePrdOvertime = 1
--	--WHERE (S.AbsenceAmount <> 0) AND (S.MonthCode = @MonthCode)
--end

	--INSERT INTO #tblBills2(PersonnelID, BenefitAmount, BenefitName)
	--SELECT S.PersonnelID, S.RemedyAmount, 'حق بیمه درمان'
	--FROM prs.tblSalaryCalculation S INNER JOIN #tblPrs P ON S.PersonnelID = P.PersonnelID
	--WHERE (S.RemedyAmount <> 0) AND (S.MonthCode = @MonthCode)

	--INSERT INTO #tblBills2(PersonnelID, BenefitAmount, BenefitName)
	--SELECT I.PersonnelID, I.ThisMonthInstallment, LT.LoanTypeName
	--FROM prs.tblInstallmentDeductionsDtl I 
	--		INNER JOIN prs.tblLoanTypesDtl LT ON LT.LoanTypeID = I.LoanTypeID AND LTrim(Str(LT.LanguageID)) = @LangID
	--		INNER JOIN #tblPrs P ON I.PersonnelID = P.PersonnelID
	--WHERE (I.ThisMonthInstallment <> 0) AND (I.MonthCode = @MonthCode)

-- ===================================== وام
	
	INSERT INTO #tblBills2(PersonnelID, BenefitAmount, BenefitName,BenefitTime,BenefitUnit)
	SELECT I.PersonnelID, I.ThisMonthInstallment, LT.LoanTypeName, 
		   IsNull(LTrim(Str((SELECT (CASE WHEN DebitFromLoan = 0 THEN LoanAmount ELSE DebitFromLoan END)
	-- LoanAmount  
	- isnull((SELECT SUM(ThisMonthInstallment) AS Installment
			  FROM  prs.tblInstallmentDeductionsDtl AS ID
			  WHERE (MonthCode <= @MonthCode)and  (ID.PersonnelID = LD.PersonnelID ) AND (ID.FiscalYear = LD.FiscalYear ) AND (ID.SerialNo = LD.SerialNo ) AND (ID.ReceiptDate = LD.ReceiptDate ) AND (ID.LoanTypeID= LD.LoanTypeID )
			  GROUP BY PersonnelID, FiscalYear, SerialNo,ReceiptDate),0) AS Installment
	FROM       prs.tblLoanInstallmentsDtl AS LD
	WHERE     (I.PersonnelID = LD.PersonnelID ) AND(LD.Settlemented=0 ) AND (I.FiscalYear = LD.FiscalYear ) AND (I.SerialNo = LD.SerialNo ) AND (I.ReceiptDate = LD.ReceiptDate ) AND (I.LoanTypeID = LD.LoanTypeID ) 

	) )),0),'مانده'
	FROM prs.tblInstallmentDeductionsDtl I 
	INNER JOIN prs.tblLoanTypesDtl LT ON LT.LoanTypeID = I.LoanTypeID AND LTrim(Str(LT.LanguageID)) =  @LangID
	INNER JOIN #tblPrs P ON I.PersonnelID = P.PersonnelID
	INNER JOIN prs.tblLoanTypes L ON L.LoanTypeID = I.LoanTypeID
	WHERE (I.MonthCode = @MonthCode) 
	and (
	(@BenefitTypeShow = 0) or
	(@BenefitTypeShow = 1 and L.InsurablePeriodWorks=1) or
	(@BenefitTypeShow = 2 and L.InsurablePeriodWorks=0) 
	)
	 
	
-- ===================================== مبلغ بازخرید مرخصی
if (@BenefitTypeShow = 0)
begin	
	INSERT INTO #tblBills1(PersonnelID, BenefitAmount, BenefitName,BenefitTime,BenefitUnit)
	SELECT S.PersonnelID, S.RedeemedVacationAmount, 'مبلغ بازخرید مرخصی',RedeemedVacationDays,'روز'+RedeemedVacationTime+'ساعت'
	FROM prs.tblSalaryCalculation S 
	INNER JOIN #tblPrs P ON S.PersonnelID = P.PersonnelID
	INNER JOIN prs.tblFunctionsDtl F ON F.PersonnelID = S.PersonnelID AND F.MonthCode = S.MonthCode
	WHERE (S.RedeemedVacationAmount <> 0) AND (S.MonthCode = @MonthCode) AND S.RedeemedVacationAmount >= 0
	
	INSERT INTO #tblBills2(PersonnelID, BenefitAmount, BenefitName,BenefitTime,BenefitUnit)
	SELECT S.PersonnelID, S.RedeemedVacationAmount*-1, 'مبلغ بازخرید مرخصی',RedeemedVacationDays,'روز'+RedeemedVacationTime+'ساعت'
	FROM prs.tblSalaryCalculation S 
	INNER JOIN #tblPrs P ON S.PersonnelID = P.PersonnelID
	INNER JOIN prs.tblFunctionsDtl F ON F.PersonnelID = S.PersonnelID AND F.MonthCode = S.MonthCode
	WHERE (S.RedeemedVacationAmount <> 0) AND (S.MonthCode = @MonthCode) AND S.RedeemedVacationAmount < 0
	
	INSERT INTO #tblBills2(PersonnelID, BenefitAmount, BenefitName,BenefitTime,BenefitUnit)
	SELECT S.PersonnelID, S.InsuranceRedeemedVacationAmount*-1, ' ب خ م تعدیل 23% کارفرما ',RedeemedVacationDays,'روز'+RedeemedVacationTime+'ساعت'
	FROM prs.tblSalaryCalculation S 
	INNER JOIN #tblPrs P ON S.PersonnelID = P.PersonnelID
	INNER JOIN prs.tblFunctionsDtl F ON F.PersonnelID = S.PersonnelID AND F.MonthCode = S.MonthCode
	WHERE (S.InsuranceRedeemedVacationAmount <> 0) AND (S.MonthCode = @MonthCode) AND S.InsuranceRedeemedVacationAmount < 0
		
end
if (@BenefitTypeShow = 1)
begin	
	INSERT INTO #tblBills1(PersonnelID, BenefitAmount, BenefitName,BenefitTime,BenefitUnit)
	SELECT S.PersonnelID, S.RedeemedVacationAmount, 'مبلغ بازخرید مرخصی',RedeemedVacationDays,'روز'+RedeemedVacationTime+'ساعت'
	FROM prs.tblSalaryCalculation S 
	INNER JOIN #tblPrs P ON S.PersonnelID = P.PersonnelID
	INNER JOIN prs.tblFunctionsDtl F ON F.PersonnelID = S.PersonnelID AND F.MonthCode = S.MonthCode
	INNER JOIN prs.tblDecreeHdr D ON D.PersonnelID = S.PersonnelID and S.DecreeSerialNo = D.SerialNo and InsurablePrdOvertime = 0
	WHERE (S.RedeemedVacationAmount <> 0) AND (S.MonthCode = @MonthCode) AND S.RedeemedVacationAmount >= 0
	
	INSERT INTO #tblBills2(PersonnelID, BenefitAmount, BenefitName,BenefitTime,BenefitUnit)
	SELECT S.PersonnelID, S.RedeemedVacationAmount*-1, 'مبلغ بازخرید مرخصی',RedeemedVacationDays,'روز'+RedeemedVacationTime+'ساعت'
	FROM prs.tblSalaryCalculation S 
	INNER JOIN #tblPrs P ON S.PersonnelID = P.PersonnelID
	INNER JOIN prs.tblFunctionsDtl F ON F.PersonnelID = S.PersonnelID AND F.MonthCode = S.MonthCode
	INNER JOIN prs.tblDecreeHdr D ON D.PersonnelID = S.PersonnelID and S.DecreeSerialNo = D.SerialNo and InsurablePrdOvertime = 0
	WHERE (S.RedeemedVacationAmount <> 0) AND (S.MonthCode = @MonthCode) AND S.RedeemedVacationAmount < 0	
		
end
if (@BenefitTypeShow = 2)
begin	
	INSERT INTO #tblBills1(PersonnelID, BenefitAmount, BenefitName,BenefitTime,BenefitUnit)
	SELECT S.PersonnelID, S.RedeemedVacationAmount, 'مبلغ بازخرید مرخصی',RedeemedVacationDays,'روز'+RedeemedVacationTime+'ساعت'
	FROM prs.tblSalaryCalculation S 
	INNER JOIN #tblPrs P ON S.PersonnelID = P.PersonnelID
	INNER JOIN prs.tblFunctionsDtl F ON F.PersonnelID = S.PersonnelID AND F.MonthCode = S.MonthCode
	INNER JOIN prs.tblDecreeHdr D ON D.PersonnelID = S.PersonnelID and S.DecreeSerialNo = D.SerialNo and InsurablePrdOvertime = 1
	WHERE (S.RedeemedVacationAmount <> 0) AND (S.MonthCode = @MonthCode) AND S.RedeemedVacationAmount >= 0
	
	INSERT INTO #tblBills2(PersonnelID, BenefitAmount, BenefitName,BenefitTime,BenefitUnit)
	SELECT S.PersonnelID, S.RedeemedVacationAmount*-1, 'مبلغ بازخرید مرخصی',RedeemedVacationDays,'روز'+RedeemedVacationTime+'ساعت'
	FROM prs.tblSalaryCalculation S 
	INNER JOIN #tblPrs P ON S.PersonnelID = P.PersonnelID
	INNER JOIN prs.tblFunctionsDtl F ON F.PersonnelID = S.PersonnelID AND F.MonthCode = S.MonthCode
	INNER JOIN prs.tblDecreeHdr D ON D.PersonnelID = S.PersonnelID and S.DecreeSerialNo = D.SerialNo and InsurablePrdOvertime = 1
	WHERE (S.RedeemedVacationAmount <> 0) AND (S.MonthCode = @MonthCode) AND S.RedeemedVacationAmount < 0
end

-- ===================================== اضافه و کسر تولیدی
if (@BenefitTypeShow = 0)
begin	
	INSERT INTO #tblBills1(PersonnelID, BenefitAmount, BenefitName,BenefitBaseAmount)
	SELECT S.PersonnelID, F.OverProduct, 'اضافه تولیدی', D.HourlyOverProduct
	FROM prs.tblSalaryCalculation S 
			INNER JOIN #tblPrs P ON S.PersonnelID = P.PersonnelID
			INNER JOIN prs.tblProductionBenefitsDtl F ON F.PersonnelID = S.PersonnelID AND F.MonthCode = S.MonthCode
			INNER JOIN prs.tblDecreeHdr D ON D.PersonnelID = S.PersonnelID and S.DecreeSerialNo = D.SerialNo
	WHERE (S.MonthCode = @MonthCode) and F.OverProduct <> 0

	INSERT INTO #tblBills2(PersonnelID, BenefitAmount, BenefitName,BenefitBaseAmount)
	SELECT S.PersonnelID, F.ProductDeduction, 'کسر تولیدی', D.HourlyWorkDeductionBase
	FROM prs.tblSalaryCalculation S 
			INNER JOIN #tblPrs P ON S.PersonnelID = P.PersonnelID
			INNER JOIN prs.tblProductionBenefitsDtl F ON F.PersonnelID = S.PersonnelID AND F.MonthCode = S.MonthCode
			INNER JOIN prs.tblDecreeHdr D ON D.PersonnelID = S.PersonnelID and S.DecreeSerialNo = D.SerialNo
	WHERE (S.MonthCode = @MonthCode) and F.ProductDeduction <> 0
		
end
if (@BenefitTypeShow = 1)
begin	
	INSERT INTO #tblBills1(PersonnelID, BenefitAmount, BenefitName,BenefitBaseAmount)
	SELECT S.PersonnelID, F.OverProduct, 'اضافه تولیدی', D.HourlyOverProduct
	FROM prs.tblSalaryCalculation S 
	INNER JOIN #tblPrs P ON S.PersonnelID = P.PersonnelID
	INNER JOIN prs.tblProductionBenefitsDtl F ON F.PersonnelID = S.PersonnelID AND F.MonthCode = S.MonthCode
	INNER JOIN prs.tblDecreeHdr D ON D.PersonnelID = S.PersonnelID and S.DecreeSerialNo = D.SerialNo and InsurablePrdOvertime = 0
	WHERE (S.MonthCode = @MonthCode) and F.OverProduct <> 0

	INSERT INTO #tblBills2(PersonnelID, BenefitAmount, BenefitName,BenefitBaseAmount)
	SELECT S.PersonnelID, F.ProductDeduction, 'کسر تولیدی', D.HourlyWorkDeductionBase
	FROM prs.tblSalaryCalculation S 
	INNER JOIN #tblPrs P ON S.PersonnelID = P.PersonnelID
	INNER JOIN prs.tblProductionBenefitsDtl F ON F.PersonnelID = S.PersonnelID AND F.MonthCode = S.MonthCode
	INNER JOIN prs.tblDecreeHdr D ON D.PersonnelID = S.PersonnelID and S.DecreeSerialNo = D.SerialNo and InsurablePrdOvertime = 0
	WHERE (S.MonthCode = @MonthCode) and F.ProductDeduction <> 0
end
if (@BenefitTypeShow = 2)
begin	
	INSERT INTO #tblBills1(PersonnelID, BenefitAmount, BenefitName,BenefitBaseAmount)
	SELECT S.PersonnelID, F.OverProduct, 'اضافه تولیدی', D.HourlyOverProduct
	FROM prs.tblSalaryCalculation S 
	INNER JOIN #tblPrs P ON S.PersonnelID = P.PersonnelID
	INNER JOIN prs.tblProductionBenefitsDtl F ON F.PersonnelID = S.PersonnelID AND F.MonthCode = S.MonthCode
	INNER JOIN prs.tblDecreeHdr D ON D.PersonnelID = S.PersonnelID and S.DecreeSerialNo = D.SerialNo and InsurablePrdOvertime = 1
	WHERE (S.MonthCode = @MonthCode) and F.OverProduct <> 0

	INSERT INTO #tblBills2(PersonnelID, BenefitAmount, BenefitName,BenefitBaseAmount)
	SELECT S.PersonnelID, F.ProductDeduction, 'کسر تولیدی', D.HourlyWorkDeductionBase
	FROM prs.tblSalaryCalculation S 
	INNER JOIN #tblPrs P ON S.PersonnelID = P.PersonnelID
	INNER JOIN prs.tblProductionBenefitsDtl F ON F.PersonnelID = S.PersonnelID AND F.MonthCode = S.MonthCode
	INNER JOIN prs.tblDecreeHdr D ON D.PersonnelID = S.PersonnelID and S.DecreeSerialNo = D.SerialNo and InsurablePrdOvertime = 1
	WHERE (S.MonthCode = @MonthCode) and F.ProductDeduction <> 0
end
	
	--if (@BillType = 0)
	--begin
	--	INSERT INTO #tblBills2(PersonnelID, BenefitAmount, BenefitName,BenefitTime,BenefitUnit)
	--	SELECT S.PersonnelID, S.LeaveAmount, 'مرخصی استعلاجی',F.SickLeave ,'روز'
	--	FROM prs.tblSalaryCalculation S INNER JOIN #tblPrs P ON S.PersonnelID = P.PersonnelID
	--		INNER JOIN prs.tblFunctionsDtl F ON F.PersonnelID = S.PersonnelID AND F.MonthCode = S.MonthCode
	--	WHERE (S.LeaveAmount <> 0) AND (S.MonthCode = @MonthCode)
	--end
	--else
	--begin
	--	UPDATE #tblBills1
	--	SET BenefitAmount= BenefitAmount - S.LeaveAmount, BenefitTime = BenefitTime - F.SickLeave
	--	FROM #tblBills1 P INNER JOIN prs.tblSalaryCalculation S ON S.PersonnelID = P.PersonnelID
	--	INNER JOIN prs.tblFunctionsDtl F ON F.PersonnelID = S.PersonnelID AND F.MonthCode = S.MonthCode
	--	WHERE (S.LeaveAmount <> 0) AND (S.MonthCode = @MonthCode) AND BenefitName = N'حقوق'
	--end

-- ====================================== تاخیر
if (@BenefitTypeShow = 0)
begin	
	INSERT INTO #tblBills2(PersonnelID, BenefitAmount, BenefitName,BenefitTime,BenefitUnit,BenefitBaseAmount)
	SELECT S.PersonnelID, S.DelayAmount, 'تأخیر',F.Delay,'ساعت',D.HourlyDelayBase
	FROM prs.tblSalaryCalculation S 
	INNER JOIN #tblPrs P ON S.PersonnelID = P.PersonnelID
	INNER JOIN prs.tblFunctionsDtl F ON F.PersonnelID = S.PersonnelID AND F.MonthCode = S.MonthCode
	INNER JOIN prs.tblDecreeHdr D ON D.PersonnelID = S.PersonnelID and S.DecreeSerialNo = D.SerialNo 
	WHERE (S.DelayAmount <> 0) AND (S.MonthCode = @MonthCode)
end
if (@BenefitTypeShow = 1)
begin	
	INSERT INTO #tblBills2(PersonnelID, BenefitAmount, BenefitName,BenefitTime,BenefitUnit,BenefitBaseAmount)
	SELECT S.PersonnelID, S.DelayAmount, 'تأخیر',F.Delay,'ساعت',D.HourlyDelayBase
	FROM prs.tblSalaryCalculation S 
	INNER JOIN #tblPrs P ON S.PersonnelID = P.PersonnelID
	INNER JOIN prs.tblFunctionsDtl F ON F.PersonnelID = S.PersonnelID AND F.MonthCode = S.MonthCode
	INNER JOIN prs.tblDecreeHdr D ON D.PersonnelID = S.PersonnelID and S.DecreeSerialNo = D.SerialNo and (@DelayInsure='True' or @DelayTax='True')
	WHERE (S.DelayAmount <> 0) AND (S.MonthCode = @MonthCode)
end
if (@BenefitTypeShow = 2)
begin	
	INSERT INTO #tblBills2(PersonnelID, BenefitAmount, BenefitName,BenefitTime,BenefitUnit,BenefitBaseAmount)
	SELECT S.PersonnelID, S.DelayAmount, 'تأخیر',F.Delay,'ساعت',D.HourlyDelayBase
	FROM prs.tblSalaryCalculation S 
	INNER JOIN #tblPrs P ON S.PersonnelID = P.PersonnelID
	INNER JOIN prs.tblFunctionsDtl F ON F.PersonnelID = S.PersonnelID AND F.MonthCode = S.MonthCode
	INNER JOIN prs.tblDecreeHdr D ON D.PersonnelID = S.PersonnelID and S.DecreeSerialNo = D.SerialNo and (@DelayInsure='False' and @DelayTax='False')
	WHERE (S.DelayAmount <> 0) AND (S.MonthCode = @MonthCode)
end

-- ======================================
if (@BenefitTypeShow = 0)
begin	
	INSERT INTO #tblBills2(PersonnelID, BenefitAmount, BenefitName,BenefitTime,BenefitUnit,BenefitBaseAmount)
	SELECT S.PersonnelID, S.LeaveWithoutPayAmount, 'مرخصی بدون حقوق روزانه',F.LeaveWithoutPay,'روز',  D.LeavePay  
	FROM prs.tblSalaryCalculation S 
	INNER JOIN #tblPrs P ON S.PersonnelID = P.PersonnelID
	INNER JOIN prs.tblFunctionsDtl F ON F.PersonnelID = S.PersonnelID AND F.MonthCode = S.MonthCode
	INNER join prs.tblDecreeHdr D ON D.PersonnelID = S.PersonnelID and S.DecreeSerialNo=D.SerialNo
	WHERE (S.LeaveWithoutPayAmount <> 0) AND (S.MonthCode = @MonthCode)
	-----------------------------------------

	INSERT INTO #tblBills2(PersonnelID, BenefitAmount, BenefitName,BenefitTime,BenefitUnit, BenefitBaseAmount)
	SELECT S.PersonnelID,  S.HourlyLeaveWithoutPayAmount, 'مرخصی بدون حقوق ساعتی',F.HourlyLeaveWithoutPay,'ساعت',   D.LeavePay  / @DailyMin*60
	FROM prs.tblSalaryCalculation S 
	INNER JOIN #tblPrs P ON S.PersonnelID = P.PersonnelID
	INNER JOIN prs.tblFunctionsDtl F ON F.PersonnelID = S.PersonnelID AND F.MonthCode = S.MonthCode
	INNER join prs.tblDecreeHdr D ON D.PersonnelID = S.PersonnelID and S.DecreeSerialNo=D.SerialNo
	WHERE ( S.HourlyLeaveWithoutPayAmount <> 0) AND (S.MonthCode = @MonthCode)
		
	INSERT INTO #tblBills2(PersonnelID, BenefitAmount, BenefitName,BenefitTime,BenefitUnit)
	SELECT S.PersonnelID, S.InsuranceLeaveWithoutPayAmount*-1, ' م ب ح تعدیل 23% کارفرما ',LeaveWithoutPay,'روز'+HourlyLeaveWithoutPay+'ساعت' -----*************************************------
	FROM prs.tblSalaryCalculation S 
	INNER JOIN #tblPrs P ON S.PersonnelID = P.PersonnelID
	INNER JOIN prs.tblFunctionsDtl F ON F.PersonnelID = S.PersonnelID AND F.MonthCode = S.MonthCode
	WHERE (S.InsuranceLeaveWithoutPayAmount <> 0) AND (S.MonthCode = @MonthCode) 
end
if (@BenefitTypeShow = 1)
begin	
	INSERT INTO #tblBills2(PersonnelID, BenefitAmount, BenefitName,BenefitTime,BenefitUnit,BenefitBaseAmount)
	SELECT S.PersonnelID, S.LeaveWithoutPayAmount, 'مرخصی بدون حقوق روزانه',F.LeaveWithoutPay,'روز',  D.LeavePay  
	FROM prs.tblSalaryCalculation S 
	INNER JOIN #tblPrs P ON S.PersonnelID = P.PersonnelID
	INNER JOIN prs.tblFunctionsDtl F ON F.PersonnelID = S.PersonnelID AND F.MonthCode = S.MonthCode
	INNER join prs.tblDecreeHdr D ON D.PersonnelID = S.PersonnelID and S.DecreeSerialNo=D.SerialNo and InsurablePrdOvertime=0	
	WHERE (S.LeaveWithoutPayAmount  <> 0) AND (S.MonthCode = @MonthCode)
	-----------------------------------------

	INSERT INTO #tblBills2(PersonnelID, BenefitAmount, BenefitName,BenefitTime,BenefitUnit,BenefitBaseAmount)
	SELECT S.PersonnelID,  S.HourlyLeaveWithoutPayAmount, 'مرخصی بدون حقوق ساعتی',F.HourlyLeaveWithoutPay,'ساعت',   D.LeavePay  /  @DailyMin*60
	FROM prs.tblSalaryCalculation S 
	INNER JOIN #tblPrs P ON S.PersonnelID = P.PersonnelID
	INNER JOIN prs.tblFunctionsDtl F ON F.PersonnelID = S.PersonnelID AND F.MonthCode = S.MonthCode
	INNER join prs.tblDecreeHdr D ON D.PersonnelID = S.PersonnelID and S.DecreeSerialNo=D.SerialNo and InsurablePrdOvertime=0	
	WHERE ( S.HourlyLeaveWithoutPayAmount <> 0) AND (S.MonthCode = @MonthCode)
end
if (@BenefitTypeShow = 2)
begin	
	INSERT INTO #tblBills2(PersonnelID, BenefitAmount, BenefitName,BenefitTime,BenefitUnit,BenefitBaseAmount)
	SELECT S.PersonnelID, S.LeaveWithoutPayAmount, 'مرخصی بدون حقوق روزانه',F.LeaveWithoutPay,'روز', D.LeavePay  
	FROM prs.tblSalaryCalculation S 
	INNER JOIN #tblPrs P ON S.PersonnelID = P.PersonnelID
	INNER JOIN prs.tblFunctionsDtl F ON F.PersonnelID = S.PersonnelID AND F.MonthCode = S.MonthCode
	INNER join prs.tblDecreeHdr D ON D.PersonnelID = S.PersonnelID and S.DecreeSerialNo=D.SerialNo and InsurablePrdOvertime=1	
	WHERE (S.LeaveWithoutPayAmount  <> 0) AND (S.MonthCode = @MonthCode)
	-----------------------------------------

	INSERT INTO #tblBills2(PersonnelID, BenefitAmount, BenefitName,BenefitTime,BenefitUnit,BenefitBaseAmount)
	SELECT S.PersonnelID,  S.HourlyLeaveWithoutPayAmount, 'مرخصی بدون حقوق ساعتی',F.HourlyLeaveWithoutPay,'ساعت',  D.LeavePay  /  @DailyMin*60
	FROM prs.tblSalaryCalculation S 
	INNER JOIN #tblPrs P ON S.PersonnelID = P.PersonnelID
	INNER JOIN prs.tblFunctionsDtl F ON F.PersonnelID = S.PersonnelID AND F.MonthCode = S.MonthCode
	INNER join prs.tblDecreeHdr D ON D.PersonnelID = S.PersonnelID and S.DecreeSerialNo=D.SerialNo and InsurablePrdOvertime=1	
	WHERE ( S.HourlyLeaveWithoutPayAmount <> 0) AND (S.MonthCode = @MonthCode)
end

-----------------------------------------
	if (@BenefitTypeShow = 0)	
		set @sqlWhere='  and 1 = 1 '
	if (@BenefitTypeShow = 1)	
		set @sqlWhere='  and ((Taxable = 1) OR  (Insurable = 1)OR  (NotInsurableForView = 1)OR  (NotTaxableForView = 1)) '
	if (@BenefitTypeShow = 2)	
		set @sqlWhere='  and ((Taxable = 0) and (Insurable = 0)and (NotInsurableForView = 0)and (NotTaxableForView = 0)) '

		

	-----------------------------------------
	DECLARE CSR_B1 CURSOR FOR
		SELECT	D.BenefitID, D.BenefitName
		FROM	prs.tblBenefits1Dtl D
				inner join prs.tblBenefits1 H on H.BenefitID = D.BenefitID
		WHERE	(D.BenefitID <> '') 
			and (
				 (@BenefitTypeShow=2 and H.Taxable=0 And H.Insurable=0 and  H.NotInsurableForView=0 and  H.NotTaxableForView=0)
				 or 
				(@BenefitTypeShow=1 and (H.Taxable=1 or H.Insurable=1 or  H.NotInsurableForView=1 or  H.NotTaxableForView=1)) 
				 or 
				 (@BenefitTypeShow=0)
				 ) 
			and (LTrim(Str(D.LanguageID)) = @LangID)
			and  (@ShowAllInBill=1 or (@ShowAllInBill=0 and  H.CreditShowInBill=1))			

	OPEN CSR_B1
	FETCH NEXT FROM CSR_B1 INTO @ID, @Name

	WHILE @@fetch_status = 0
	BEGIN
		SET @sql = '
		INSERT	INTO #tblBills1(PersonnelID, BenefitAmount, BenefitName, BenefitState, BenefitBaseAmount)
		SELECT Distinct  S.PersonnelID, S.Benefit' + @ID + ', ''' + @Name + ''',1 BenefitState, D.Benefit' + @ID + '
		FROM	prs.tblSalaryCalculation S 
		INNER JOIN #tblPrs P ON S.PersonnelID = P.PersonnelID
		INNER join prs.tblDecreeHdr D ON S.PersonnelID = D.PersonnelID and S.DecreeSerialNo = D.SerialNo
		INNER JOIN prs.tblBenefits1 ON BenefitID = ' + @ID + @sqlWhere +' 
		WHERE	(S.Benefit' + @ID + ' <> 0) AND (S.MonthCode = ' + Str(@MonthCode) + ')'

		print @sql
		EXEC sp_executesql @sql;
		
		FETCH NEXT FROM CSR_B1 INTO @ID, @Name
	END

	CLOSE CSR_B1
	DEALLOCATE CSR_B1

	---------------------------------------- 2
	DECLARE CSR_B2 CURSOR FOR
		SELECT	D.BenefitID, D.BenefitName,H.BenefitType
		FROM	prs.tblBenefits2Dtl D
				inner join prs.tblBenefits2 H on H.BenefitID = D.BenefitID
		WHERE	(D.BenefitID <> '') 
			and (				
			 	 (@BenefitTypeShow=2 and H.Taxable=0 And H.Insurable=0 and  H.NotInsurableForView=0  and  H.NotTaxableForView=0)
				 or 
				(@BenefitTypeShow=1 and (H.Taxable=1 or H.Insurable=1 or  H.NotInsurableForView=1  or  H.NotTaxableForView=1)) 
				 or 
				 (@BenefitTypeShow=0)
				 ) 
			and (LTrim(Str(D.LanguageID)) = @LangID)
			and  (@ShowAllInBill=1 or (@ShowAllInBill=0 and  H.CreditShowInBill=1))

	OPEN CSR_B2
	FETCH NEXT FROM CSR_B2 INTO @ID, @Name,@BenefitType

	WHILE @@fetch_status = 0
	BEGIN
	--INSERT INTO #tblBills2(PersonnelID, BenefitAmount, BenefitName,BenefitTime,BenefitUnit)
	if @BenefitType=0
	
		SET @sql = '
		INSERT	INTO #tblBills1(PersonnelID, BenefitAmount, BenefitName, BenefitState, BenefitBaseAmount)
		SELECT Distinct  D.PersonnelID, D.BenefitU' + @ID + ', ''' + @Name + ''',2 BenefitState, D.BenefitU' + @ID + '
		FROM	prs.tblUnContinuumBenefitsDtl D 
		INNER JOIN #tblPrs P ON D.PersonnelID = P.PersonnelID
		WHERE	(D.BenefitU' + @ID + ' <> 0) AND (D.MonthCode = ' + Str(@MonthCode) + ')'
	else
		SET @sql = '
		INSERT	INTO #tblBills1(PersonnelID, BenefitAmount, BenefitName,BenefitTime,BenefitUnit, BenefitState, BenefitBaseAmount)
		SELECT Distinct  D.PersonnelID, D.BenefitU' + @ID + ', ''' + @Name + ''', D.CountU' + @ID + ',''بار'',2 BenefitState, D.BenefitU' + @ID + '
		FROM	prs.tblUnContinuumBenefitsDtl D 
		INNER JOIN #tblPrs P ON D.PersonnelID = P.PersonnelID
		WHERE	(D.BenefitU' + @ID + ' <> 0) AND (D.MonthCode = ' + Str(@MonthCode) + ')'
		
		print @sql
		EXEC sp_executesql @sql;
		
		FETCH NEXT FROM CSR_B2 INTO @ID, @Name,@BenefitType
	END

	CLOSE CSR_B2
	DEALLOCATE CSR_B2

 
	---------------------------------------- 3
	DECLARE CSR_D1 CURSOR FOR
	SELECT     d.BenefitID, d.BenefitName, H.ShowSumInSalary, H.AcntCost
		FROM         prs.tblDeduction1 AS H INNER JOIN
                      prs.tblDeduction1Dtl AS d ON H.BenefitID = d.BenefitID
                   
		WHERE	(d.BenefitID <> '') AND (LTrim(Str(d.LanguageID)) = @LangID)
			and (
				 (@BenefitTypeShow=2 and H.Taxable=0 And H.Insurable=0 and ForViewInInsuranceBill=0)
				 or 
				(@BenefitTypeShow=1 and (H.Taxable=1 or H.Insurable=1  or ForViewInInsuranceBill=1 )) 
				 or 
				 (@BenefitTypeShow=0)
				 ) 			

	OPEN CSR_D1
	FETCH NEXT FROM CSR_D1 INTO @ID, @Name,@ShowSumInSalary,@SalaryAcntCode

	WHILE @@fetch_status = 0
	BEGIN
	if (@ShowSumInSalary=1)
		SET @sql = '
		INSERT	INTO #tblBills2(PersonnelID, BenefitAmount, BenefitName,BenefitTime,BenefitUnit, BenefitState, BenefitBaseAmount)
		SELECT  Distinct S.PersonnelID, S.Deduction' + @ID + ', ''' + @Name + ''',cast( (select Sum(Debit-Credit ) as sums from acc.tblVoucherDtl where VchKind not in ( 0,3) AND AcntCode=[pub].[funMergCode]('''+@SalaryAcntCode+''',P.AcntSalary)) as int),''ریال'',3 BenefitState, D.Deduction' + @ID + '
		FROM	prs.tblSalaryCalculation S 
		INNER JOIN #tblPrs P ON S.PersonnelID = P.PersonnelID
		INNER join prs.tblDecreeHdr D ON S.PersonnelID = D.PersonnelID and S.DecreeSerialNo = D.SerialNo
		WHERE	(S.Deduction' + @ID + ' <> 0) AND (S.MonthCode = ' + Str(@MonthCode) + ')'
		else
		SET @sql = '
		INSERT	INTO #tblBills2(PersonnelID, BenefitAmount, BenefitName, BenefitState, BenefitBaseAmount)
		SELECT  Distinct S.PersonnelID, S.Deduction' + @ID + ', ''' + @Name + ''',3 BenefitState, D.Deduction' + @ID + '
		FROM	prs.tblSalaryCalculation S 
		INNER JOIN #tblPrs P ON S.PersonnelID = P.PersonnelID
		INNER join prs.tblDecreeHdr D ON S.PersonnelID = D.PersonnelID and S.DecreeSerialNo = D.SerialNo
		WHERE	(S.Deduction' + @ID + ' <> 0) AND (S.MonthCode = ' + Str(@MonthCode) + ')'

		print @sql
		EXEC sp_executesql @sql;

		FETCH NEXT FROM CSR_D1 INTO @ID, @Name,@ShowSumInSalary,@SalaryAcntCode
	END

	CLOSE CSR_D1
	DEALLOCATE CSR_D1
	
	
	---------------------------------------- 4
	DECLARE CSR_D2 CURSOR FOR
		SELECT     d.BenefitID, d.BenefitName 
		FROM    prs.tblDeduction2 AS H 
			INNER JOIN prs.tblDeduction2Dtl AS d ON H.BenefitID = d.BenefitID                   
		WHERE	(d.BenefitID <> '') AND (LTrim(Str(d.LanguageID)) = @LangID)
			and (
				 (@BenefitTypeShow=2 and H.Taxable=0 And H.Insurable=0 )
				 or 
				(@BenefitTypeShow=1 and (H.Taxable=1 or H.Insurable=1 )) 
				 or 
				 (@BenefitTypeShow=0)
				 ) 

	OPEN CSR_D2
	FETCH NEXT FROM CSR_D2 INTO @ID, @Name

	WHILE @@fetch_status = 0
	BEGIN

		SET @sql = '
		INSERT	INTO #tblBills2(PersonnelID, BenefitAmount, BenefitName, BenefitState, BenefitBaseAmount)
		SELECT  Distinct D.PersonnelID, D.DeductionU' + @ID + ', ''' + @Name + ''',4 BenefitState, D.DeductionU' + @ID + '
		FROM	prs.tblUnContinuumDeductionsDtl D 
		INNER JOIN #tblPrs P ON D.PersonnelID = P.PersonnelID 
		WHERE	(D.DeductionU' + @ID + ' <> 0) AND (D.MonthCode = ' + Str(@MonthCode) + ')'
		
		EXEC sp_executesql @sql;

		FETCH NEXT FROM CSR_D2 INTO @ID, @Name
	END

	CLOSE CSR_D2
	DEALLOCATE CSR_D2

	-----------------------------------------
	update  #tblBills1 set BenefitType=1  where BenefitType is null
	update  #tblBills2 set BenefitType=-1  where BenefitType is null
	
	update  #tblBills1 set BenefitType=11 where BenefitName ='اضافه کاری'
	update  #tblBills1 set BenefitType=12 where BenefitName ='مبلغ بازخرید مرخصی'

	update #tblBills1 Set BenefitState = 0 Where BenefitState is null
	update #tblBills2 Set BenefitState = 0 Where BenefitState is null
			
	IF  not EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'prs.tblBenefitOrder') AND type in (N'U'))
	begin
		select distinct  BenefitName, BenefitType BenefitOrder , 1 BenefitType  into prs.tblBenefitOrder From #tblBills1
			union 
		select distinct  BenefitName, BenefitType BenefitOrder , -1 BenefitType  From #tblBills2
	end
	else
	begin
	 insert into prs.tblBenefitOrder
		select distinct BenefitName, BenefitType BenefitOrder , 1 BenefitType  From #tblBills1
		where BenefitName not in ( select BenefitName From prs.tblBenefitOrder  where BenefitType>0)
	
	 insert into prs.tblBenefitOrder
		select distinct BenefitName, BenefitType BenefitOrder , -1 BenefitType  From #tblBills2
		where BenefitName not in ( select BenefitName From prs.tblBenefitOrder  where BenefitType<0)

	end
		
	delete From #tblBills2  where BenefitAmount =0 and isnull(BenefitUnit,'')=''
	delete From #tblBills1  where BenefitAmount =0
	
	if @ShowTypeBenefit = 0
	Begin
		select PersonnelID,	BenefitName,BenefitAmount,BenefitTime,BenefitUnit,BenefitOrder BenefitType-- ,	ShowType	--,BenefitOrder	
		from (SELECT D.PersonnelID,	D.BenefitName,D.BenefitAmount,D.BenefitTime,D.BenefitUnit,a.BenefitOrder--, +1 As BenefitType
		FROM #tblBills1 D inner join  prs.tblBenefitOrder a on a.BenefitName =D.BenefitName and a.BenefitType>0
		union All
		SELECT D.PersonnelID,	D.BenefitName,D.BenefitAmount,D.BenefitTime,D.BenefitUnit,a.BenefitOrder--, -1 As BenefitType 
		FROM #tblBills2 D  inner join  prs.tblBenefitOrder a on a.BenefitName =D.BenefitName  and a.BenefitType<0
		)a
		ORDER BY PersonnelID, BenefitOrder Desc , BenefitAmount DESC
	End
	else
	Begin
		select PersonnelID,	BenefitName,BenefitAmount,BenefitTime,BenefitUnit,BenefitOrder BenefitType, BenefitState,BenefitBaseAmount-- ,	ShowType	--,BenefitOrder	
		from (SELECT D.PersonnelID,	D.BenefitName,D.BenefitAmount,D.BenefitTime,D.BenefitUnit,a.BenefitOrder, D.BenefitState, D.BenefitBaseAmount--, +1 As BenefitType
		FROM #tblBills1 D inner join  prs.tblBenefitOrder a on a.BenefitName =D.BenefitName and a.BenefitType>0
		union All
		SELECT D.PersonnelID,	D.BenefitName,D.BenefitAmount,D.BenefitTime,D.BenefitUnit,a.BenefitOrder, D.BenefitState, D.BenefitBaseAmount--, -1 As BenefitType 
		FROM #tblBills2 D  inner join  prs.tblBenefitOrder a on a.BenefitName =D.BenefitName  and a.BenefitType<0
		)a
		ORDER BY PersonnelID, BenefitOrder Desc , BenefitAmount DESC
	End
		
END
GO
