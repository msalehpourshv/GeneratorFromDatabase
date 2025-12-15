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
Create PROCEDURE [prs].[RptPrs_Contract]
	@PersonnelID	VarChar(20),
	@DecreeSerialNo	Int,
	@RepOptions		VarChar(100) = '',
	@RepInfo		NVarChar(100) = '1@1@1'
WITH ENCRYPTION
AS 
DECLARE @StrSelect	NVarChar(max);
DECLARE @StrFrom	NVarChar(max);
DECLARE @StrWhere	NVarChar(max);

DECLARE	@LangID		Char(1);
DECLARE	@SessionNo	Int; 
DECLARE	@ReportID	Int;

DECLARE	@BenefitID	varchar(20);
DECLARE	@BenefitName	nvarchar(50);
DECLARE @SelectedPrs	Int ;
DECLARE @SelectedDpt	Int ;
DECLARE @LastSerialNo	Int ;
DECLARE @ControlQuitJobDate	Int ;
DECLARE @SerialNo	Int;
DECLARE @NoTaxInsureBenefit	Int;
DECLARE @InsureBenefit		Int;
DECLARE @TaxBenefit			Int;
DECLARE @ShowImage			bit;
declare @ShowDtlBasePay		int 

Begin 
	--============== S T A R T  C O D E =======================================

	SET NOCOUNT ON;

	---- Init ------------------------------------------
	IF (@RepInfo Is Null)	SET @RepInfo = '1@1@1'

	SET @LangID		= pub.funSplitString(@RepInfo, '@', 1);
	SET @SessionNo	= pub.funSplitString(@RepInfo, '@', 2);
	SET @ReportID	= pub.funSplitString(@RepInfo, '@', 3);
	
	SET @SelectedPrs		= pub.funSplitString(@RepOptions, '@', 1);	
	SET @LastSerialNo		= pub.funSplitString(@RepOptions, '@', 2);	
	SET @NoTaxInsureBenefit	= pub.funSplitString(@RepOptions, '@', 3);	
	SET @InsureBenefit		= pub.funSplitString(@RepOptions, '@', 4);	
	SET @TaxBenefit			= pub.funSplitString(@RepOptions, '@', 5);	
	SET @ControlQuitJobDate	= pub.funSplitString(@RepOptions, '@', 6);	
	SET @ShowImage			= pub.funSplitString(@RepOptions, '@', 7);	
	SET @SelectedDpt		= pub.funSplitString(@RepOptions, '@', 8);	
	SET @ShowDtlBasePay		= pub.funSplitString(@RepOptions, '@', 9);	
		
	--Drop table #tbl_Prs_Contract_Benefits
	
	CREATE TABLE #tbl_Prs
	(
		PersonnelID  VarChar(20) collate Arabic_CS_AS not null,
		SerialNo	 int not null
	)
	
	CREATE TABLE #tbl_Prs_Contract_Benefits
	(
		BenefitOrder	int not null,
		BenefitName		nvarchar(500) not null,
		BenefitAmount	float not null,
		PersonnelID		VarChar(20) collate Arabic_CS_AS not null,
		SerialNo		int not null
	)
	
	
	DECLARE @sqlWhere 	NVarChar(4000)
	DECLARE @sqlWhereFiltered 	NVarChar(4000)
	SET @sqlWhere  =' WHERE 1=1 '
	SET @sqlWhereFiltered  =' WHERE 1=1 '

	IF (@PersonnelID > 0)
		SET @sqlWhere = @sqlWhere  + ' AND D.PersonnelID='''+ ltrim(rtrim(@PersonnelID)) +''''
	ELSE
	BEGIN
		IF (@SelectedPrs > 0)
			SET @sqlWhere = @sqlWhere  + ' AND ' + pub.funGetFilterString(@SessionNo, @ReportID, @SelectedPrs, 'D.PersonnelID')
	END
	IF (@LastSerialNo = 0 and @DecreeSerialNo<>0 )
		SET @sqlWhere = @sqlWhere  + ' AND SerialNo='+STR(@DecreeSerialNo)

	IF (@SelectedDpt > 0)
			SET @sqlWhereFiltered = @sqlWhereFiltered  + ' AND ' + pub.funGetFilterString(@SessionNo, @ReportID, @SelectedDpt, 'DepartmentID')

	SET @StrSelect = ' INSERT INTO #tbl_Prs 
					   SELECT PersonnelID, 
							  ISNULL(MAX(SerialNo), 0) AS SerialNo
					   FROM prs.tblDecreeHdr D
					   ' +@sqlWhere+' 
					   GROUP BY PersonnelID '
	
	PRINT @StrSelect;
	EXEC sp_executesql @StrSelect;
	

	DECLARE curPersonnelID CURSOR FOR 
	
	SELECT * FROM #tbl_Prs
	
	OPEN curPersonnelID;
	
	FETCH NEXT FROM curPersonnelID INTO @PersonnelID,@SerialNo
	
	WHILE (@@FETCH_STATUS = 0)
	BEGIN	
	 
	DECLARE curBenefits CURSOR FOR 
		SELECT H.BenefitID, 
			   D.BenefitName
		FROM prs.tblBenefits1Dtl D 
		INNER JOIN prs.tblBenefits1 H on H.BenefitID=D.BenefitID
		WHERE (H.CodeClosed = 0) 
		  AND (isnull(H.ShowPrintContract ,'True')= 'True')
		  AND (H.BenefitID <> '')
		  AND ((@NoTaxInsureBenefit = 1 AND Insurable = 0 AND Taxable = 0) OR 
			  (@InsureBenefit = 1 AND Insurable = 1 ) OR 
			  (@TaxBenefit = 1 AND Taxable = 1))
	OPEN curBenefits;
	
	FETCH NEXT FROM curBenefits INTO @BenefitID, @BenefitName
	
	WHILE (@@FETCH_STATUS = 0)
	BEGIN
		set @StrSelect = '
		INSERT INTO #tbl_Prs_Contract_Benefits(BenefitOrder, 
											   BenefitAmount, 
											   BenefitName,
											   PersonnelID,
											   SerialNo)
		SELECT 2, 
			   ISNULL(Benefit' + LTrim(@BenefitID) + ',0), 
			   ''' + @BenefitName + ''',
			   PersonnelID,
			   SerialNo
		FROM prs.tblDecreeHdr
		WHERE (Benefit' + LTrim(@BenefitID) + ' > 0) 
		  AND (PersonnelID = ''' + LTrim(@PersonnelID) + ''') 
		  AND (SerialNo = ' + LTrim(STR(@SerialNo)) + ')'
		
	 	PRINT @StrSelect;
		EXEC sp_executesql @StrSelect;
		
		FETCH NEXT FROM curBenefits INTO @BenefitID, @BenefitName
	END

	CLOSE curBenefits;
	DEALLOCATE curBenefits;

	if @ShowDtlBasePay=1	
	INSERT INTO #tbl_Prs_Contract_Benefits(BenefitOrder, BenefitAmount, BenefitName,PersonnelID,SerialNo)
	SELECT 1,DH.JobCategoryPay * 30,'مزد گروه شغلی ',PersonnelID,SerialNo FROM prs.tblDecreeHdr DH
	WHERE PersonnelID = @PersonnelID AND SerialNo = @SerialNo and DH.JobCategoryPay>0
	union all
	SELECT 1,DH.PastWagesDailyPay * 30,'مزد سنوات',PersonnelID,SerialNo FROM prs.tblDecreeHdr DH
	WHERE PersonnelID = @PersonnelID AND SerialNo = @SerialNo and DH.PastWagesDailyPay>0
	union all
	SELECT 1,DH.DailyInferiorPay * 30,'حق پست',PersonnelID,SerialNo FROM prs.tblDecreeHdr DH
	WHERE PersonnelID = @PersonnelID AND SerialNo = @SerialNo and DH.DailyInferiorPay>0
	union all
	SELECT 1,DH.DailyInferiorPayRemain * 30,'حق ماندگاری پست',PersonnelID,SerialNo FROM prs.tblDecreeHdr DH
	WHERE PersonnelID = @PersonnelID AND SerialNo = @SerialNo and DH.DailyInferiorPayRemain>0

	else
	INSERT INTO #tbl_Prs_Contract_Benefits(BenefitOrder, BenefitAmount, BenefitName,PersonnelID,SerialNo)
	SELECT 1, 
		   DH.Basepay * 30,
		   'حقوق پایه',
		   PersonnelID,
		   SerialNo
	FROM prs.tblDecreeHdr DH
	WHERE PersonnelID = @PersonnelID 
	  AND SerialNo = @SerialNo

	FETCH NEXT FROM curPersonnelID INTO @PersonnelID,@SerialNo
	END

	CLOSE curPersonnelID;
	DEALLOCATE curPersonnelID;
	
	SET @StrSelect = '
	SELECT BenefitOrder, 
		   BenefitAmount, 
		   BenefitName,
		   X.*
	FROM #tbl_Prs_Contract_Benefits B
	INNER JOIN(SELECT DH.SerialNo,
					  PH.*,
					  PD.Address, 
					  SD.StudyName,
					  PD.FirstName, 
					  PD.LastName, 
					  PD.FatherName, 
					  LD.LocationName IssuancePlaceName, 
					  JB.JobName, 
					  WD.WorkShopName, 
					  DH.DepartmentID,
					  DD.DepartmentName,
					  DH.IssueDate, 
					  DH.ExecutionDate, 
					  DH.GroupNo, 
					  DH.BaseNo, 
					  DH.Basepay, 
					  DH.HourlyOvertimeBase, 
					  DH.VacationOvertimeBase, 
					  DH.HourlyOverProduct, 
					  DH.HourlyWorkDeductionBase, 
					  DH.TaxType, 
					  DH.TaxPercent, 
					  DH.ExemptPercent, 
					  DH.InsuranceTypeID, 
					  DH.InsuranceBasepay,
					  DH.TaxableOvertime, 
					  DH.InsurableOvertime,
					  DH.IOType,
					  DH.HdrDesc,
					  DH.LeavePay,
					  DH.InsurablePrdOvertime, 
					  DH.TaxablePrdOvertime, 
					  DH.AbsenceBase,
					  DH.HourlyDelayBase,
					  DH.InsurType, 
					  DH.InsurName, 
					  DH.WageAcntCode, 
					  DH.EmployeeInsurIsBenefit,
					  DH.EmployeeTaxIsBenefit,
					  DH.EmployeeTaxCeleIsBenefit, 
					  DH.ContractTypeID, 
					  DH.EmploymentType, 
					  DH.SavePriceType, 
					  DH.SavePriceOrPercent, 
					  DH.RegSumSalaryUnit, 
					  DH.MissionDaily, 
					  DH.MissionTime, 
					  DH.InsurableMission, 
					  DH.TaxableMission, 
					  DH.BasepayTime, 
					  DH.ContractEndDate,
					  PA.AccountNo,
					  SFD.FieldName,
					  CAST(CASE WHEN '''+LTRIM(RTRIM(Str(@ShowImage)))+''' = ''True'' THEN PersonnelImage ELSE '''' END AS IMAGE ) PersonnelImage,
					  JobCategoryPay,
					  PastWagesDailyPay,
					  DailyInferiorPay,
					  DailyInferiorPayRemain,
					  JobCategoryPayInsure,
					  PastWagesDailyPayInsure,					   
					  DailyInferiorPayInsure,
					  DailyInferiorPayRemainInsure
			FROM [prs].[tblDecreeHdr] DH
			LEFT JOIN prs.tblPersonnelsDtl PD ON PD.PersonnelID = DH.PersonnelID 
											 AND PD.LanguageID = ' + @LangID +'
			LEFT JOIN prs.tblPersonnels PH ON PH.PersonnelID = DH.PersonnelID 
			LEFT JOIN prs.tblStudiesDtl SD ON SD.StudyID = PH.StudyID 
										  AND SD.LanguageID = ' + @LangID +'
			LEFT JOIN prs.tblStudyFieldsDtl SFD ON SFD.FieldID = PH.FieldID 
											   AND SFD.LanguageID = ' + @LangID +'
			LEFT JOIN pub.tblLocationsDtl LD ON LD.LocationID = PH.IssuancePlace 
										    AND LD.LanguageID = ' + @LangID +'
			LEFT JOIN prs.tblWorkShopsDtl WD ON WD.WorkShopID = DH.WorkShopID 
										    AND WD.LanguageID = ' + @LangID +'
			LEFT JOIN prs.tblJobsDtl JB ON JB.JobID = DH.JobID 
									   AND JB.LanguageID = ' + @LangID +'
			LEFT JOIN prs.tblDepartmentsDtl DD ON DD.DepartmentID = DH.DepartmentID 
										      AND DD.LanguageID = ' + @LangID +'
			LEFT JOIN prs.tblPersonnelAccountsDtl PA ON PA.PersonnelID = DH.PersonnelID 
												    AND PA.IsDefault = 1
			LEFT JOIN prs.tblPersonnelsImages IM ON IM.PersonnelID = DH.PersonnelID 
			WHERE ('+LTRIM(RTRIM(STR(@ControlQuitJobDate)))+' = 0 OR ('+LTRIM(RTRIM(STR(@ControlQuitJobDate)))+' = 1  AND LTRIM(PH.QuitJobDate) = '''' AND LTRIM(DH.QuitJobDate) = ''''))
			--where	DH.PersonnelID=B.PersonnelID and DH.SerialNo=B.SerialNo
		) X
		ON X.PersonnelID = B.PersonnelID 
	   AND X.SerialNo = B.SerialNo
	'+ @sqlWhereFiltered +'
	ORDER BY BenefitOrder'
	
	PRINT @StrSelect;
	EXEC sp_executesql @StrSelect;
End
GO
