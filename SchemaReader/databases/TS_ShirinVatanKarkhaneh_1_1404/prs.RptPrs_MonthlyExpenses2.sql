USE TS_ShirinVatanKarkhaneh_1_1404
GO
SET ANSI_NULLS, QUOTED_IDENTIFIER ON
GO
-- =========== TS-QC:UPDATED ====================
-- Author		 : TakroSystem\ZiA
-- Create date   : 1387/08/26
-- Viewed By	 : 
-- Last Modified : 1392/07/11
-- Last Modifier : TakroSystem\ZiA
-- Description	 : هزينه هاي يک ماه
-- ==============================================
--EXEC [prs].[RptPrs_MonthlyExpenses2] @MonthCodeFr = 1,@MonthCodeTo = 1,@SelectedPrs = 0, @RepOptions = '0000', @RepInfo = '1@201@200032@0@1'
Create PROCEDURE [prs].[RptPrs_MonthlyExpenses2] 
	@MonthCodeFr	Int = 0,
	@MonthCodeTo	Int = 0,
	@SelectedPrs	Int = 0,
	@DepartmentID	VarChar(100) = '',
	@WorkShopID		VarChar(100) = '',
	@RepOptions		VarChar(10) = '00',  -- bit array options
	@RepInfo		NVarChar(100) = '1@1@1'
WITH ENCRYPTION
AS 
DECLARE @StrSelect	NVarChar(max);
DECLARE @StrWhere	NVarChar(max);
DECLARE @StrWhereMon	NVarChar(max);
DECLARE @StrFrom	NVarChar(max);
DECLARE @ShowDebit	Bit;
DECLARE @IsSummary	Bit;
DECLARE @GroupDepartment	Bit;
DECLARE @ShowCele01	char(1);
DECLARE @ShowCele02	char(1); 

DECLARE	@LangID			Char(1);
DECLARE	@SessionNo		Int; 
DECLARE	@ReportID		Int; 
DECLARE @SelectedInsur	Int ;
DECLARE @MyRepOptions VarChar(50)
DECLARE @MonthCode	  TinyInt;
DECLARE @WorkShopID2  VarChar(100);
DECLARE @State		  int;

BEGIN --============== S T A R T  C O D E =======================================

	SET NOCOUNT ON;

	---- Init ------------------------------------------
	IF @SelectedPrs  IS NULL	SET @SelectedPrs = 0;
	IF @WorkShopID   IS NULL 	SET @WorkShopID = '';
	IF @WorkShopID2  IS NULL 	SET @WorkShopID2 = '';
	IF @DepartmentID IS NULL	SET @DepartmentID = 0;
	IF @RepInfo		 IS NULL	SET @RepInfo = '1@1@1'

	SET @LangID			= pub.funSplitString(@RepInfo, '@', 1);
	SET @SessionNo		= pub.funSplitString(@RepInfo, '@', 2);
	SET @ReportID		= pub.funSplitString(@RepInfo, '@', 3);
	SET @SelectedInsur	= pub.funSplitString(@RepInfo, '@', 6);
	SET @ShowDebit		= Substring(@RepOptions, 1, 1);
	SET @IsSummary		= Substring(@RepOptions, 2, 1);
	SET @State			= Substring(@RepOptions, 5, 1);
	
	SET @RepInfo = pub.funSplitString(@RepInfo, '@', 1)	
			 +'@'+ pub.funSplitString(@RepInfo, '@', 2)	
			 +'@'+ pub.funSplitString(@RepInfo, '@', 3)	
			 +'@'+ pub.funSplitString(@RepInfo, '@', 4)	
			 +'@'+ pub.funSplitString(@RepInfo, '@', 5);

	IF (len(@RepOptions) > 2)
		SET @ShowCele01	= Substring(@RepOptions, 3, 1)
	ELSE
		SET @ShowCele01	= '0'
		
	IF (len(@RepOptions) > 3)
		SET @ShowCele02	= Substring(@RepOptions, 4, 1)
	ELSE
		SET @ShowCele02	= '0'
	
	SET @GroupDepartment	= Substring(@RepOptions, 5, 1); 
	----------------------------------------------------
	begin try
		drop table #tbl_MEX2_1
		drop table #tbl_MEX2_2
		drop table #tbl_MEX3
	end try
	begin catch
	end catch
	
	CREATE TABLE #tbl_MEX2_1
	(
		MonthCode		int,
		BenefitName		NVarChar(50),
		BenefitAmount	Float,
		BenefitOrder	Int
	)
	
	CREATE TABLE #tbl_MEX2_2
	(
		MonthCode		int,
		BenefitName		NVarChar(50),
		BenefitAmount	Float,
		BenefitOrder	Int
	)

	DECLARE @ID		VarChar(20)
	DECLARE @Name	nVarChar(50)
	DECLARE @sql	NVarChar(max)
	----------------------------------------------------
	IF @State = 1
		IF @WorkShopID <> 0
			Set @WorkShopID2 = @WorkShopID

	--select @WorkShopID,@WorkShopID2
	SET @StrWhere = '(1=1)'
	
	IF (@SelectedPrs > 0)
		SET @StrWhere = @StrWhere + ' AND ' + pub.funGetFilterString(@SessionNo, @ReportID, @SelectedPrs, 'S.PersonnelID')
	If (@DepartmentID > 0)
		set @StrWhere = @StrWhere + ' AND ' + pub.funGetFilterString(@SessionNo, @ReportID, @DepartmentID, 'D.DepartmentID')
	If (@WorkShopID	> 0 )
		SET @StrWhere = @StrWhere + ' AND ' + pub.funGetFilterString(@SessionNo, @ReportID, @WorkShopID, 'D.WorkShopID')
	If (@WorkShopID2 <> '')
		SET @StrWhere = @StrWhere + ' AND (D.WorkShopID = ''' + @WorkShopID2 + ''')'
	IF (@SelectedInsur <> 0)
		SET @StrWhere = @StrWhere + ' AND ' + pub.funGetFilterString(@SessionNo, @ReportID, @SelectedInsur, 'D.InsuranceTypeID') 
	
	SET @StrWhereMon=@StrWhere

	if (@MonthCodeFr is not null) SET @StrWhere = @StrWhere + ' and (S.MonthCode>=' + Str(@MonthCodeFr) + ')'
	if (@MonthCodeTo is not null) SET @StrWhere = @StrWhere + ' and (S.MonthCode<=' + Str(@MonthCodeTo) + ')'

	BEGIN TRY
		DROP TABLE #tblMonthlyExpensesB
		DROP TABLE #tblMonthlyExpensesM
		DROP TABLE #tblMonthlyExpensesM2
	END TRY
	BEGIN CATCH
	END CATCH
	
	CREATE TABLE #tblMonthlyExpensesB
	(
		PersonnelID		VarChar(20) COLLATE ARABIC_CS_AS
	);

	CREATE TABLE #tblMonthlyExpensesM
	(
		PersonnelID		VarChar(20) COLLATE ARABIC_CS_AS,
		BenefitName		VarChar(50)  COLLATE ARABIC_CS_AS,
		BenefitAmount	Float,
		BenefitTime		nvarchar(30) COLLATE ARABIC_CS_AS,
		BenefitUnit		nvarchar(30) COLLATE ARABIC_CS_AS,
		BenefitType		Int,
		MonthCode		Int,
		DepartmentID	VarChar(50), 
		ExtraAmount	Float
	);
			
	CREATE TABLE #tblMonthlyExpensesM2
	(
		BenefitName		VarChar(50) COLLATE ARABIC_CS_AS,
		BenefitAmount	Float,	
		BenefitUnit		nvarchar(30) COLLATE ARABIC_CS_AS,
		BenefitType		Int,
		BenefitOrder 	Int,
		Amount3			Float,
		Amount4			Float,
		Amount5	 		Float,
		Amount6			Float,
		MonthCode		Int,
		MaleCount		Int,
		FemaleCount		Int,
		DepartmentID	VarChar(20) COLLATE ARABIC_CS_AS, 
		ExtraAmount	Float
	);
			
INSERT INTO #tblMonthlyExpensesB(PersonnelID)
	SELECT distinct S.PersonnelID
	FROM  prs.tblFunctionsDtl F 
		INNER JOIN prs.tblSalaryCalculation S ON F.PersonnelID = S.PersonnelID AND F.MonthCode = S.MonthCode
		INNER JOIN prs.tblDecreeHdr D ON S.DecreeSerialNo = D.SerialNo AND S.PersonnelID = D.PersonnelID AND F.PersonnelID = D.PersonnelID
	WHERE S.MonthCode >= @MonthCodeFr  and S.MonthCode <= @MonthCodeTo  
	ORDER BY S.PersonnelID


	--IF (@ShowRemain = 1) 
	--	SET @MyRepOptions = '11'
	--ELSE
	--	SET @MyRepOptions = '01'
	SET @MyRepOptions = '01' + @ShowCele01 + @ShowCele02+'0000001'
	
	set @MonthCode  = @MonthCodeFr 

	select * into #tblMonthly from #tblMonthlyExpensesM where 1=0

	while @MonthCode <= @MonthCodeTo
	begin

		delete  from #tblMonthly

		INSERT INTO #tblMonthly(PersonnelID,BenefitName,BenefitAmount,BenefitTime,BenefitUnit,BenefitType)
		---EXEC [prs].[RptPrs_SalaryBillsDtl] @MonthCode, @SelectedPrs, NULL, @DepartmentID, @WorkShopID, NULL, NULL, null, @MyRepOptions, @RepInfo
		EXEC [prs].[RptPrs_SalaryBillsDtl] @MonthCode, @SelectedPrs,  NULL, NULL, NULL,  NULL,  NULL, null, @MyRepOptions, @RepInfo
		update #tblMonthlyExpensesM
		set MonthCode=@MonthCode where MonthCode=0 or MonthCode Is Null
		
		set @sql=' delete from  #tblMonthly
					where PersonnelID not in (
						SELECT  Distinct S.PersonnelID
							FROM prs.tblSalaryCalculation S 
							INNER JOIN prs.tblDecreeHdr D ON D.PersonnelID = S.PersonnelID AND D.SerialNo = S.DecreeSerialNo
							WHERE ' + @StrWhereMon + '  and S.MonthCode =' + Str(@MonthCode) + ')'
	
		print @sql;
		EXEC sp_executesql @sql;

		---Update ---------------------------------------------------------------------
		
		update #tblMonthly
			set MonthCode= @MonthCode

		INSERT INTO #tblMonthlyExpensesM
				select * from #tblMonthly

		update #tblMonthlyExpensesM
			set ExtraAmount= 0

	update #tblMonthlyExpensesM
		set ExtraAmount= OldCost
		from #tblMonthlyExpensesM a
		inner join  prs.tblCelebrationDtl b on a.PersonnelID=b.PersonnelID and a.MonthCode=b.MonthCode and a.BenefitName='پايانکار' and b.ProcessID=325
		
	update #tblMonthlyExpensesM
		set BenefitTime=0 ,BenefitUnit=''
		where  BenefitTime is null
	
	update #tblMonthlyExpensesM 
		set DepartmentID=c.DepartmentID
		from #tblMonthlyExpensesM a
		inner join   prs.tblSalaryCalculation  b on a.PersonnelID = b.PersonnelID and a.MonthCode=b.MonthCode
		inner join   prs.tblDecreeHdr  c on c.PersonnelID = b.PersonnelID and c.SerialNo=b.DecreeSerialNo
		---Update ---------------------------------------------------------------------
 
	set @MonthCode = @MonthCode +1
	end			
	
 	if (@IsSummary = 1 and @GroupDepartment=1)
	begin
		insert into  #tblMonthlyExpensesM2(BenefitName,BenefitAmount,MonthCode,BenefitType,DepartmentID,ExtraAmount)
		select BenefitName,SUM(BenefitAmount) as BenefitAmount,MonthCode,BenefitType,DepartmentID ,Sum(ExtraAmount) from #tblMonthlyExpensesM
		group by BenefitName,MonthCode,BenefitType,DepartmentID
	end
	if (@IsSummary = 1 and @GroupDepartment=0)
	begin
		insert into  #tblMonthlyExpensesM2(BenefitName,BenefitAmount,MonthCode,BenefitType,ExtraAmount)
		select BenefitName,SUM(BenefitAmount) as BenefitAmount,MonthCode,BenefitType,Sum(ExtraAmount)  from #tblMonthlyExpensesM
		group by BenefitName,MonthCode,BenefitType
	end
	if (@IsSummary = 0 and @GroupDepartment=1)
	begin
		insert into  #tblMonthlyExpensesM2(BenefitName,BenefitAmount,BenefitType,DepartmentID,ExtraAmount)
		select BenefitName,SUM(BenefitAmount) as BenefitAmount,BenefitType,DepartmentID ,Sum(ExtraAmount) from #tblMonthlyExpensesM
		group by BenefitName,BenefitType,DepartmentID
	end
	if (@IsSummary = 0 and @GroupDepartment=0)
	begin
		insert into  #tblMonthlyExpensesM2(BenefitName,BenefitAmount,BenefitType,ExtraAmount)
		select BenefitName,SUM(BenefitAmount) as BenefitAmount,BenefitType,Sum(ExtraAmount) from #tblMonthlyExpensesM
		group by BenefitName,BenefitType
	end

	update #tblMonthlyExpensesM2  	set DepartmentID=''	where DepartmentID is null
	update #tblMonthlyExpensesM2  	set MonthCode=0	where MonthCode is null

	update #tblMonthlyExpensesM2  
	set BenefitUnit=M.BenefitUnit 
	from #tblMonthlyExpensesM2  M2 inner join #tblMonthlyExpensesM M
	on  M2.BenefitName=M.BenefitName  --And M.BenefitUnit<>'' 
	and  M2.BenefitType=M.BenefitType
					
update #tblMonthlyExpensesM2 set BenefitOrder=0
update #tblMonthlyExpensesM2 set BenefitOrder=1 where BenefitName='دستمزد ماهانه'
update #tblMonthlyExpensesM2 set BenefitOrder=2 where BenefitName='اضافه کاري'
update #tblMonthlyExpensesM2 set BenefitOrder=3 where BenefitName='اضافه کار تعطيلي'
update #tblMonthlyExpensesM2 set BenefitOrder=10 where BenefitName='اياب و ذهاب و سرويس'
update #tblMonthlyExpensesM2 set BenefitOrder=10 where BenefitName='پاداش و بهره وري'
update #tblMonthlyExpensesM2 set BenefitOrder=10 where BenefitName='حق اولاد'
update #tblMonthlyExpensesM2 set BenefitOrder=10 where BenefitName='حق بن کارگري'
update #tblMonthlyExpensesM2 set BenefitOrder=10 where BenefitName='حق مسکن و خواربار'
update #tblMonthlyExpensesM2 set BenefitOrder=10 where BenefitName='حقوق ثابت'
update #tblMonthlyExpensesM2 set BenefitOrder=10 where BenefitName='مابه التفاوت بيمه'
update #tblMonthlyExpensesM2 set BenefitOrder=11 where BenefitName='پاداش متفرقه'
update #tblMonthlyExpensesM2 set BenefitOrder=11 where BenefitName='حق فني'
update #tblMonthlyExpensesM2 set BenefitOrder=11 where BenefitName='نگهبان روز'
update #tblMonthlyExpensesM2 set BenefitOrder=11 where BenefitName='نگهبان شب'
update #tblMonthlyExpensesM2 set BenefitOrder=11 where BenefitName='کارگري متفرقه'
update #tblMonthlyExpensesM2 set BenefitOrder=11 where BenefitName='کارکرد ساعتي'
update #tblMonthlyExpensesM2 set BenefitOrder=22 where BenefitName='ماموریت روزانه برون شهری'
update #tblMonthlyExpensesM2 set BenefitOrder=31 where BenefitName='بستانکاری از قبل'
update #tblMonthlyExpensesM2 set BenefitOrder=35 where BenefitName='عیدی'
update #tblMonthlyExpensesM2 set BenefitOrder=36 where BenefitName='پایانکار'
update #tblMonthlyExpensesM2 set BenefitOrder=101 where BenefitName='مساعده'
update #tblMonthlyExpensesM2 set BenefitOrder=102 where BenefitName='غيبت'
update #tblMonthlyExpensesM2 set BenefitOrder=103 where BenefitName='کسر کار'
update #tblMonthlyExpensesM2 set BenefitOrder=105 where BenefitName='ماليات'
update #tblMonthlyExpensesM2 set BenefitOrder=110 where BenefitName='مابه التفاوت بيمه'
update #tblMonthlyExpensesM2 set BenefitOrder=111 where BenefitName='نگهبان شب'
update #tblMonthlyExpensesM2 set BenefitOrder=120 where BenefitName='مانده بدهکاری'
update #tblMonthlyExpensesM2 set BenefitOrder=121 where BenefitName='مبلغ خرده پول مانده از ماه قبل'
update #tblMonthlyExpensesM2 set BenefitOrder=122 where BenefitName='مبلغ خرده پول مانده به ماه بعد'
update #tblMonthlyExpensesM2 set BenefitOrder=123 where BenefitName='بیمه درمان'
update #tblMonthlyExpensesM2 set BenefitOrder=125 where BenefitName='بيمه سهم کارکنان'
update #tblMonthlyExpensesM2 set BenefitOrder=126 where BenefitName='وام ضروری کارکنان'
update #tblMonthlyExpensesM2 set BenefitOrder=127 where BenefitName='مرخصی بدون حقوق'

set @sql='
	Update #tblMonthlyExpensesM2
	set Amount3= ISNULL((
			SELECT  IsNull(SUM(S.EmployerInsur ), 0)
			FROM prs.tblSalaryCalculation S 
					INNER JOIN prs.tblDecreeHdr D ON D.PersonnelID = S.PersonnelID AND D.SerialNo = S.DecreeSerialNo
					INNER JOIN prs.tblPersonnels p ON p.PersonnelID = S.PersonnelID 
			WHERE  D.InsuranceTypeID <> '''' AND (InsuranceID <> '''') and InsuranceBasepay > 0  and  ' + @StrWhere + '
					),0)	
	Update #tblMonthlyExpensesM2
	set Amount4= ISNULL((
			SELECT  IsNull(SUM(S.DoleAmount ), 0)
			FROM prs.tblSalaryCalculation S 
			INNER JOIN prs.tblDecreeHdr D ON D.PersonnelID = S.PersonnelID AND D.SerialNo = S.DecreeSerialNo
			INNER JOIN prs.tblPersonnels p ON p.PersonnelID = S.PersonnelID 
			WHERE  D.InsuranceTypeID <> '''' AND (InsuranceID <> '''') and InsuranceBasepay > 0 and  ' + @StrWhere + '
					),0)	
	Update #tblMonthlyExpensesM2
	set Amount5= ISNULL((
			SELECT IsNull(SUM(S.RemedyAmount), 0)
			FROM prs.tblSalaryCalculation S 
			INNER JOIN prs.tblDecreeHdr D ON D.PersonnelID = S.PersonnelID AND D.SerialNo = S.DecreeSerialNo
			INNER JOIN prs.tblPersonnels p ON p.PersonnelID = S.PersonnelID 
			WHERE D.InsuranceTypeID <> '''' AND (InsuranceID <> '''') and InsuranceBasepay > 0 and  ' + @StrWhere + '
					),0)	
	Update #tblMonthlyExpensesM2
	set Amount6 = ISNULL((	
			SELECT IsNull(SUM(S.EmployeeInsur), 0)
			FROM prs.tblSalaryCalculation S 
			INNER JOIN prs.tblDecreeHdr D ON D.PersonnelID = S.PersonnelID AND D.SerialNo = S.DecreeSerialNo
			INNER JOIN prs.tblPersonnels p ON p.PersonnelID = S.PersonnelID 
			WHERE D.InsuranceTypeID <> '''' AND (InsuranceID <> '''') and InsuranceBasepay > 0  and ' + @StrWhere + '
					),0)
	Update #tblMonthlyExpensesM2
	set MaleCount = ISNULL((	
			SELECT IsNull(COUNT(p.PersonnelID ), 0)
			FROM prs.tblSalaryCalculation S 
			INNER JOIN prs.tblDecreeHdr D ON D.PersonnelID = S.PersonnelID AND D.SerialNo = S.DecreeSerialNo
			INNER JOIN prs.tblPersonnels p ON p.PersonnelID = S.PersonnelID 
			WHERE D.InsuranceTypeID <> '''' AND (InsuranceID <> '''') and InsuranceBasepay > 0  AND Gender = 1 and ' + @StrWhere + '
					),0)
	Update #tblMonthlyExpensesM2
	set FemaleCount = ISNULL((	
			SELECT IsNull(COUNT(p.PersonnelID ), 0)
			FROM prs.tblSalaryCalculation S 
			INNER JOIN prs.tblDecreeHdr D ON D.PersonnelID = S.PersonnelID AND D.SerialNo = S.DecreeSerialNo
			INNER JOIN prs.tblPersonnels p ON p.PersonnelID = S.PersonnelID 
			WHERE D.InsuranceTypeID <> '''' AND (InsuranceID <> '''') and InsuranceBasepay > 0  AND Gender = 2 and ' + @StrWhere + '
					),0)
	'
		print @sql;
		EXEC sp_executesql @sql;

	if 	(SELECT sum(ExtraAmount) FROM #tblMonthlyExpensesM2 M2 )>0
		insert into #tblMonthlyExpensesM2(BenefitName,BenefitAmount,BenefitUnit,BenefitType,BenefitOrder,Amount3,Amount4,Amount5,Amount6,MonthCode,MaleCount,FemaleCount,DepartmentID,ExtraAmount)
			select 'ذخیره پایانکار' , ExtraAmount,'' , BenefitType,-1,Amount3,Amount4,Amount5,Amount6,MonthCode,MaleCount,FemaleCount,DepartmentID,0
			from  #tblMonthlyExpensesM2
			where BenefitName='پايانکار'
	if 	(SELECT sum(ExtraAmount) FROM #tblMonthlyExpensesM2 M2 )<0
		insert into #tblMonthlyExpensesM2(BenefitName,BenefitAmount,BenefitUnit,BenefitType,BenefitOrder,Amount3,Amount4,Amount5,Amount6,MonthCode,MaleCount,FemaleCount,DepartmentID,ExtraAmount)
			select 'ذخیره پایانکار' , ExtraAmount*-1,'', BenefitType*-1,-1,Amount3,Amount4,Amount5,Amount6,MonthCode,MaleCount,FemaleCount,DepartmentID,0
			from  #tblMonthlyExpensesM2
			where BenefitName='پايانکار'

		SELECT M2.*,isnull(M.DepartmentName,'') DepartmentName FROM #tblMonthlyExpensesM2 M2 
		left  join prs.tblDepartmentsDtl M
		on  M2.DepartmentID=M.DepartmentID  
		and  M.LanguageID	=@LangID
	
END
GO
