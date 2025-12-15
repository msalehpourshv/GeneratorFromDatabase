USE TS_ShirinVatanKarkhaneh_1_1404
GO
SET ANSI_NULLS, QUOTED_IDENTIFIER ON
GO
-- =========== TS-QC:UPDATED ====================
-- Author		 : TakroSystem\Ahmadnejad
-- Create Date   : 1387/08/26
-- Viewed By	 : 
-- Last Modified : 1390/08/04
-- Last Modifier : TakroSystem\Ahmadnejad
-- Description	 : فیش حقوق پرسنل
-- ==============================================
Create PROCEDURE [prs].[RptPrs_SalaryBillsDtlEx]
	@MonthCodeFr	Int,
	@MonthCodeTo	Int,
	@SelectedPrs	Int = 0,
	@DecreeTypeID	VarChar(20) = Null,
	@DepartmentID	VarChar(20) = Null,
	@WorkShopID		VarChar(20) = Null,
	@JobID			VarChar(20) = Null,
	@RepOptions		VarChar(10) = '0011',  -- bit array options
	@RepInfo		NVarChar(100) = '1@1@1'
WITH ENCRYPTION
AS 
DECLARE @StrSelect		NVarChar(MAX);
DECLARE @StrWhere		NVarChar(MAX);
DECLARE @ShowRemain		Bit;
DECLARE @ExternalCall	Bit; -- is called from another sp?
DECLARE @ShowCele01		Bit;
DECLARE @ShowCele02		Bit;
DECLARE @ShowMonth		Bit;
DECLARE @ShowBasepay	Bit;

DECLARE	@LangID			Char(1);
DECLARE	@SessionNo		Int; 
DECLARE	@ReportID		Int; 
Begin 
	--============== S T A R T  C O D E =======================================

	SET NOCOUNT ON;

	---- Init ------------------------------------------
	IF (@RepInfo		Is Null)	SET @RepInfo = '1@1@1'
	IF (@SelectedPrs	Is Null)	SET @SelectedPrs = 0

	SET @ShowRemain		= Substring(@RepOptions, 1, 1)
	SET @ExternalCall	= Substring(@RepOptions, 2, 1)
	
	if (len(@RepOptions) > 2)
		SET @ShowCele01	= Substring(@RepOptions, 3, 1)
	else
		SET @ShowCele01	= 0
		
	if (len(@RepOptions) > 3)
		SET @ShowCele02	= Substring(@RepOptions, 4, 1)
	else
		SET @ShowCele02	= 0

	SET @LangID		= pub.funSplitString(@RepInfo, '@', 1);
	SET @SessionNo	= pub.funSplitString(@RepInfo, '@', 2);
	SET @ReportID	= pub.funSplitString(@RepInfo, '@', 3);
	SET @ShowMonth	= pub.funSplitString(@RepInfo, '@', 6);
	 
	----------------------------------------------------

	Declare @MyRepOptions as varchar(50)
	CREATE TABLE #tbl_RptPrs_SalaryList_M
	(
		PersonnelID		NVarChar(100) COLLATE ARABIC_CS_AS,
		BenefitName		NVarChar(50) COLLATE ARABIC_CS_AS,
		BenefitAmount	Float,
		BenefitTime		varchar(50),
		BenefitUnit		nvarchar(30),
		BenefitType		Int
	);
	select *, 12  MonthCode into #tbl_RptPrs_SalaryList_MNew from #tbl_RptPrs_SalaryList_M

IF (@ShowRemain = 1) 
		SET @MyRepOptions = '11'
	ELSE
		SET @MyRepOptions = '01'

IF (@ShowCele01= 1) 
SET @MyRepOptions = @MyRepOptions +'1'
else
SET @MyRepOptions = @MyRepOptions +'0'

IF (@ShowCele02= 1) 
SET @MyRepOptions = @MyRepOptions +'1'
else
SET @MyRepOptions = @MyRepOptions +'0'

--IF (@ShowAll= 1) 
IF (1= 1) 
SET @MyRepOptions = @MyRepOptions +'11001'
else
SET @MyRepOptions = @MyRepOptions +'11000'

--select @MonthCode, @SelectedPrs, @DecreeTypeID, @DepartmentID, @WorkShopID, @JobID, @RemainDate, null, @MyRepOptions, @RepInfo
--EXEC [prs].[RptPrs_SalaryBillsDtl] @MonthFr, @SelectedPrs, @DecreeTypeID, @DepartmentID, @WorkShopID, @JobID, @RemainDate, null, @MyRepOptions, @RepInfo
declare 	@MonthCode	Int
	
set @MonthCode  = @MonthCodeFr 
while @MonthCode <= @MonthCodeTo
begin
	Delete from #tbl_RptPrs_SalaryList_M

	INSERT INTO #tbl_RptPrs_SalaryList_M
	EXEC [prs].[RptPrs_SalaryBillsDtl] @MonthCode, @SelectedPrs, @DecreeTypeID, @DepartmentID, @WorkShopID, @JobID, '', null, @MyRepOptions, @RepInfo
		

	insert into #tbl_RptPrs_SalaryList_MNew	
	select *,case when @ShowMonth='True' then  @MonthCode else 0 end from #tbl_RptPrs_SalaryList_M
	set @MonthCode = @MonthCode +1

end
update #tbl_RptPrs_SalaryList_MNew set BenefitType=1 where BenefitType>0
update #tbl_RptPrs_SalaryList_MNew set BenefitType=-1 where BenefitType<0

	select a.PersonnelID,	a.BenefitName	Benefit1,a.BenefitAmount Amount1	
		,	BenefitName	Benefit2,BenefitAmount  Amount2,a.MonthCode , BenefitAmount ROWNUMBER
	into #tblTemp
	from #tbl_RptPrs_SalaryList_MNew a
	where 1=0

	insert into #tblTemp
	select a.PersonnelID,	a.Benefit1	 ,a.Amount1	,	''	Benefit2,0  Amount2,a.MonthCode 
		, ROW_NUMBER() OVER ( PARTITION BY PersonnelID,MonthCode ORDER BY PersonnelID,MonthCode) ROWNUMBER 
	from (
		Select PersonnelID,	BenefitName	Benefit1,Sum(BenefitAmount) Amount1	,MonthCode 
		from #tbl_RptPrs_SalaryList_MNew 
		where BenefitType=1
		group by PersonnelID,	BenefitName,MonthCode 
		)  a
	left Join prs.tblBenefitOrder c	on c.BenefitName=a.Benefit1 --or c.BenefitName=a.BenefitName2
	ORDER BY a.PersonnelID,a.MonthCode,BenefitOrder desc

	update  #tblTemp
		set Benefit2=BenefitName,Amount2=BenefitAmount
	from #tblTemp a
	inner join	
		(	select a.PersonnelID,a.BenefitName	,Sum(a.BenefitAmount) BenefitAmount,a.MonthCode 
				, ROW_NUMBER() OVER ( PARTITION BY PersonnelID,MonthCode ORDER BY PersonnelID,MonthCode) ROWNUMBER 
			from #tbl_RptPrs_SalaryList_MNew a
			where a.BenefitType<>1
			group by  a.PersonnelID,a.BenefitName,a.MonthCode 	
		) b
		on a.PersonnelID=b.PersonnelID	and a.MonthCode=b.MonthCode	and a.ROWNUMBER=b.ROWNUMBER

	select PersonnelID,	Benefit1	,Amount1,	Benefit2	,Amount2	,MonthCode	 
	 from #tblTemp

End
GO
