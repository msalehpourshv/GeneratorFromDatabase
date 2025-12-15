USE TS_ShirinVatanKarkhaneh_1_1404
GO
SET ANSI_NULLS, QUOTED_IDENTIFIER ON
GO
-- =========== TS-QC:UPDATED ====================
-- Author		 : TakroSystem\Zia
-- Creation date : 1392/02/23
-- Viewed By	 : 
-- Last Modified : 1393/04/03
-- Last Modifier : TakroSystem\Hamid
-- Description	 : 
-- ==============================================
Create PROCEDURE [prs].[RptPrs_Personnel_WorkEnd]
	@PersonnelID	VarChar(20),
	@DecreeSerialNo	Int,
	@RepOptions		VarChar(10) = '',
	@RepInfo		NVarChar(100) = '1@1@1',
	@ExtraParams		NVarChar(200) = Null
WITH ENCRYPTION
AS 
DECLARE @StrSelect	NVarChar(max);
DECLARE @StrFrom	NVarChar(max);
DECLARE @StrWhere	NVarChar(max);

DECLARE	@LangID		Char(1);
DECLARE	@SessionNo	Int; 
DECLARE	@ReportID	Int;

DECLARE	@BenefitID	 varchar(20);
DECLARE	@BenefitName nvarchar(50);
DECLARE	@MonthCode	 nvarchar(50);

Begin 
	--============== S T A R T  C O D E =======================================

	SET NOCOUNT ON;

	---- Init ------------------------------------------
	IF (@RepInfo Is Null)	SET @RepInfo = '1@1@1'

	SET @LangID		= pub.funSplitString(@RepInfo, '@', 1);
	SET @SessionNo	= pub.funSplitString(@RepInfo, '@', 2);
	SET @ReportID	= pub.funSplitString(@RepInfo, '@', 3);
	
    SET @MonthCode = LTrim(pub.funSplitString(@ExtraParams, '@', 1)); 
    
	create table #tbl_Prs_Contract_Benefits
	(
		BenefitOrder	int not null,
		BenefitName		nvarchar(500) not null,
		BenefitAmount	float not null
	)
	
	DECLARE curBenefits CURSOR FOR 
		select H.BenefitID, D.BenefitName
		from prs.tblBenefits1Dtl D inner join prs.tblBenefits1 H on H.BenefitID=D.BenefitID
		where (H.CodeClosed = 0) and (H.BenefitID <> '')
	
	OPEN curBenefits;
	
	FETCH NEXT FROM curBenefits INTO @BenefitID, @BenefitName
	
	WHILE (@@FETCH_STATUS = 0)
	BEGIN
		set @StrSelect = '
		insert into #tbl_Prs_Contract_Benefits(BenefitOrder, BenefitAmount, BenefitName)
		select 2, isnull(Benefit' + LTrim(@BenefitID) + ',0), ''' + @BenefitName + '''
		from prs.tblDecreeHdr
		where (Benefit' + LTrim(@BenefitID) + ' > 0) and (PersonnelID=''' + LTrim(@PersonnelID) + ''') and (SerialNo=' + LTrim(STR(@DecreeSerialNo)) + ')'
		
		print @StrSelect;
		exec sp_executesql @StrSelect;
		
		FETCH NEXT FROM curBenefits INTO @BenefitID, @BenefitName
	END

	CLOSE curBenefits;
	DEALLOCATE curBenefits;

	insert into #tbl_Prs_Contract_Benefits(BenefitOrder, BenefitAmount, BenefitName)
	select 1, DH.Basepay*30, 'حقوق پایه'
	from prs.tblDecreeHdr DH
	where PersonnelID=@PersonnelID and SerialNo=@DecreeSerialNo

	select *
	from #tbl_Prs_Contract_Benefits B
		cross join
		(
		select 	PH.*, PD.Address, SD.StudyName,PD.FirstName, PD.LastName, PD.FatherName, 
				LD.LocationName IssuancePlaceName, JB.JobName, WD.WorkShopName, DH.DepartmentID,
				DH.Basepay, DD.DepartmentName, 
				IsNull((Select distinct sum(DebitFromLoan) From prs.tblLoanInstallmentsDtl
				 Where PersonnelID = DH.PersonnelID),'') As DebitFromLoan,
				 case when  PH.QuitJobDate='' AND DH.QuitJobDate='' then pub.funFarsiDateDiff('Day',PH.HireDate,left(pub.funFarsiDate(GETDATE()),10)) else pub.funFarsiDateDiff('Day',PH.HireDate,(CASE WHEN DH.QuitJobDate<>'' THEN DH.QuitJobDate ELSE  PH.QuitJobDate END)) end as WorkedDays,
				IsNull((Select Cost From prs.tblCelebrationDtl 
				Where ProcessID = 325 And MonthCode = @MonthCode And PersonnelID = @PersonnelID)
				 +IsNull(( case when @MonthCode =12 then 
				(select Cost FROM prs.tblCelebrationDtl CD where CD.ProcessID=325 and CD.PersonnelID = @PersonnelID and CD.MonthCode=13)
				else 0 end) ,''),'') As WorkEnd,
			    IsNull((Select Cost From prs.tblCelebrationDtl 
			    Where ProcessID = 320 And MonthCode = @MonthCode And PersonnelID = @PersonnelID)
			    +IsNull(( case when @MonthCode =12 then 
				(select Cost FROM prs.tblCelebrationDtl CD where CD.ProcessID=320 and CD.PersonnelID = @PersonnelID and CD.MonthCode=13)
				else 0 end),''),'') As Celebration,
			    SC.PayableAmount As LastMonthSalary, IsNull((SELECT S.RedeemedVacationAmount
	FROM prs.tblSalaryCalculation S 
	INNER JOIN prs.tblFunctionsDtl F ON F.PersonnelID = S.PersonnelID AND F.MonthCode = S.MonthCode
	WHERE (S.RedeemedVacationAmount <> 0) AND (S.MonthCode = @MonthCode)
	and  S.PersonnelID = @PersonnelID),'') As LeaveRemain,@MonthCode as MonthCode

		from	[prs].[tblDecreeHdr] DH
					left join prs.tblPersonnelsDtl PD on PD.PersonnelID=DH.PersonnelID
					left join prs.tblPersonnels PH on PH.PersonnelID=DH.PersonnelID
					left join prs.tblStudiesDtl SD on SD.StudyID=PH.StudyID
					left join pub.tblLocationsDtl LD on LD.LocationID=PH.IssuancePlace
					left join prs.tblWorkShopsDtl WD on WD.WorkShopID=DH.WorkShopID 
					left join prs.tblJobsDtl JB on JB.JobID=DH.JobID 
					left join prs.tblDepartmentsDtl DD on DD.DepartmentID = DH.DepartmentID
					left join prs.tblSalaryCalculation SC on SC.PersonnelID = DH.PersonnelID and MonthCode=@MonthCode
					left join prs.tblLoanInstallmentsDtl LO on LO.PersonnelID = DH.PersonnelID
		where	DH.PersonnelID=@PersonnelID and DH.SerialNo=@DecreeSerialNo
		) X
	order by BenefitOrder
	
End
GO
