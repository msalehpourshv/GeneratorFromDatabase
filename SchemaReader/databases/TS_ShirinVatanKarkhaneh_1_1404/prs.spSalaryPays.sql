USE TS_ShirinVatanKarkhaneh_1_1404
GO
SET ANSI_NULLS, QUOTED_IDENTIFIER ON
GO
-- =========== TS-QC:UPDATED ====================
-- Author		 : TakroSystem\Jafari
-- Creation date : 1394/10/07
-- Viewed By	 : 
-- Last Modified : 
-- Last Modifier : TakroSystem\jafari
-- Description	 : پرداخت حقوق و مزایای پرسنل
-- ==============================================
Create PROCEDURE [prs].[spSalaryPays]
	@ProcessID		Int=0,
	@MonthCode		Int=1,
	@RemainDate		Char(10) = Null,
	@LoanDate		Char(10) = Null, -- don't remove this param
	@RepOptions		VarChar(20) = '00110',  -- bit array options
	@RepInfo		NVarChar(100) = '1@1@1',
	@BankTypeID		nvarchar(20)
WITH ENCRYPTION
AS 

begin	

	SET NOCOUNT ON;
	
	DECLARE @StrSelect			NVarChar(MAX);
	DECLARE @SelectedPrs		Int 
	DECLARE @DecreeTypeID		VarChar(20) 
	DECLARE @DepartmentID		VarChar(20) 
	DECLARE @WorkShopID			VarChar(20) 
	DECLARE @JobID				VarChar(20) 
	DECLARE	@LangID				Char(1);
	DECLARE	@RemainAll			bit;
	DECLARE	@ExternalCall		int;
	DECLARE	@OverTime			int;
	DECLARE	@InsurePrsn			bit;
	DECLARE	@notInsurePrsn		bit;	
	DECLARE @ShowAdvanceAmount  int =0
	DECLARE @ShowAdvanceAmount2 int =0
	DECLARE @ShowBuyAmount	    int =0
	DECLARE @ShowBuyAmount2     int =0


	SET @LangID				= pub.funSplitString(@RepInfo, '@', 1);
	--SET @SessionNo		= pub.funSplitString(@RepInfo, '@', 2);
	--SET @ReportID			= pub.funSplitString(@RepInfo, '@', 3);
	SET @ShowAdvanceAmount	= pub.funSplitString(@RepInfo, '@', 6);
	SET @RemainAll			= pub.funSplitString(@RepInfo, '@', 7);
	SET @InsurePrsn			= pub.funSplitString(@RepInfo, '@', 8);
	SET @notInsurePrsn		= pub.funSplitString(@RepInfo, '@', 9);
	SET @ShowAdvanceAmount2	= pub.funSplitString(@RepInfo, '@', 10);
	SET @ShowBuyAmount		= pub.funSplitString(@RepInfo, '@', 11);
	SET @ShowBuyAmount2		= pub.funSplitString(@RepInfo, '@', 12);
		
	set @SelectedPrs	= 0
	set @DecreeTypeID	= Null
	set @DepartmentID	= Null
	set @WorkShopID		= Null
	set @JobID			= Null
	
	SET @ExternalCall	= Substring(@RepOptions, 7, 1)
	SET @OverTime		= Substring(@RepOptions, 11, 1)
--	select @ExternalCall 
	if  @RemainAll=0
	begin
		
		BEGIN TRY
		DROP TABLE #tblM3
		DROP TABLE #tblM2
		DROP TABLE #tblM1
		END TRY
		BEGIN CATCH
		END CATCH
	
		CREATE TABLE #tblM1
		(
			PersonnelID		NVarChar(100) COLLATE ARABIC_CS_AS,
			BenefitName		VarChar(50) COLLATE ARABIC_CS_AS,
			BenefitAmount	Float,
			BenefitTime		varchar(10),
			BenefitUnit		nvarchar(30),
			BenefitType		Int
		);
	
	
		IF SUBSTRING(@RemainDate,6,5)='01/01' 
			SET @RepOptions = '0' + SUBSTRING(@RepOptions,2,LEN(@RepOptions)-1)
		ELSE
			SET @RepOptions = '1' + SUBSTRING(@RepOptions,2,LEN(@RepOptions)-1)
	
		SET @RepInfo	= pub.funSplitString(@RepInfo, '@', 1)	
			+'@'+ pub.funSplitString(@RepInfo, '@', 2)	
			+'@'+ pub.funSplitString(@RepInfo, '@', 3)	
			+'@'+ pub.funSplitString(@RepInfo, '@', 4)	
			+'@'+ pub.funSplitString(@RepInfo, '@', 5)
			+'@'+ pub.funSplitString(@RepInfo, '@', 6);
	
 	SET @RepOptions =@RepOptions+ '0' + ltrim(str(@ShowAdvanceAmount2))
 	SET @RepOptions =@RepOptions+  ltrim(str(@ShowBuyAmount))
 	SET @RepOptions =@RepOptions+  ltrim(str(@ShowBuyAmount2))
	--select @RepOptions, len(@RepOptions)
 
		SET @StrSelect = '  
		EXEC [prs].[RptPrs_SalaryBillsDtl]  @MonthCode='+ STR(@MonthCode)+',@SelectedPrs='+ STR(@SelectedPrs)+', @DecreeTypeID='''+ ISNULL(@DecreeTypeID,'NULL')+''', 
		@DepartmentID='''+ ISNULL(@DepartmentID,'NULL')+''', @WorkShopID='''+ ISNULL(@WorkShopID,'NULL')+''', @JobID='''+ ISNULL(@JobID,'NULL')+''', @RemainDate ='''+ ISNULL(@RemainDate,'NULL') +''',
		@LoanDate ='''+ ISNULL(@LoanDate,'NULL')+''',	@RepOptions ='''+ ISNULL(@RepOptions,'NULL')+''',@RepInfo='''+ ISNULL(@RepInfo,'NULL')+'''	'

		Print @StrSelect;
		--EXEC sp_executesql @StrSelect;
	

		INSERT INTO #tblM1
		EXEC [prs].[RptPrs_SalaryBillsDtl] @MonthCode,@SelectedPrs, @DecreeTypeID, @DepartmentID, @WorkShopID, @JobID, @RemainDate, @LoanDate, @RepOptions, @RepInfo
		--select  @MonthCode,@SelectedPrs, @DecreeTypeID, @DepartmentID, @WorkShopID, @JobID, @RemainDate, @LoanDate, @RepOptions, @RepInfo
	  --EXEC [prs].[RptPrs_SalaryBillsDtl]     8,        0,             NULL,             Null,           Null,  NULL,'1394/08/30', NULL, '00001101', '1@4145@200029@0@1'

		SET @StrSelect = '  
		EXEC [prs].[RptPrs_SalaryBillsDtl]  @MonthCode='+ STR(@MonthCode)+',@SelectedPrs='+ STR(@SelectedPrs)+', @DecreeTypeID='''+ @DecreeTypeID+''', 
		@DepartmentID='''+ @DepartmentID+''', @WorkShopID='''+ @WorkShopID+''', @JobID='''+ @JobID+''', @RemainDate ='''+ @RemainDate +''',
		@LoanDate ='''+ @LoanDate+''',	@RepOptions ='''+ @RepOptions+''',@RepInfo='''+ @RepInfo+'''	'

		Print @StrSelect;

		if @OverTime=3
			Delete From #tblM1 where BenefitName='اضافه کاري' or BenefitName='اضافه کار تعطیلی' or BenefitName='مبلغ اضافه تولید'
		if @OverTime=4
 			Delete From #tblM1 where BenefitName<>'اضافه کاري' and BenefitName<>'اضافه کار تعطیلی'  and BenefitName<> 'مبلغ اضافه تولید'

		SET @StrSelect = '  
		select a.PersonnelID,[prs].[funGetAccountNoWithBankType](a.PersonnelID,'''+ @BankTypeID +''') AS AccountNo,
			  [prs].[funGetBankCartNo](a.PersonnelID) AS BankCartNo,
			  [prs].[funGetShabaAccountNumber](a.PersonnelID,[prs].[funGetAccountNo](a.PersonnelID)) ShabaAccountNumber,
			  (isnull(a.BenefitAmount1 ,0 )- isnull(b.BenefitAmount2 ,0)) 
			--(SELECT isnull(Sum(Amount),0) FROM prs.tblSalaryPaysDtl D INNER JOIN prs.tblSalaryPaysHdr H ON D.SerialNo=H.SerialNo AND D.ProcessID=H.ProcessID WHERE D.ProcessID=' + Str(@ProcessID) + ' and MonthCode=' + Str(@MonthCode ) + ' and a.PersonnelID=D.PersonnelID)  
			  PayableAmount ,prs.funGetPersonnelName(a.PersonnelID,' + Str(@LangID) + ') AS PersonnelName  
		from (select PersonnelID,sum(BenefitAmount) as BenefitAmount1  from #tblM1 where BenefitType>0 group by PersonnelID) a
		LEFT OUTER JOIN
			(select PersonnelID,sum(BenefitAmount) as BenefitAmount2 from #tblM1 where BenefitType<0 group by PersonnelID) b
		on a.PersonnelID=b.PersonnelID
		inner join  prs.tblSalaryCalculation s on s.PersonnelID=a.PersonnelID and s.MonthCode=' + Str(@MonthCode ) + ' 
		INNER JOIN prs.tblDecreeHdr D 
					ON s.PersonnelID = D.PersonnelID AND s.DecreeSerialNo=D.SerialNo
		'
		IF @BankTypeID<>''
			SET @StrSelect = @StrSelect + 
				'INNER JOIN (SELECT * from prs.tblPersonnelAccountsDtl where  BankTypeID = ''' + @BankTypeID + ''' )  c
				ON c.PersonnelID = a.PersonnelID '
	
		SET @StrSelect = @StrSelect + '  where 1=1  '
		if @InsurePrsn='True' and  @notInsurePrsn='False' 
			SET @StrSelect = @StrSelect + '  and  InsuranceBasepay>0  and InsurType<>3 '
		if @notInsurePrsn='True' and @InsurePrsn='False'
			SET @StrSelect = @StrSelect + '  and  (InsuranceBasepay=0  or  InsurType=3) '

		Print @StrSelect;
		EXEC sp_executesql @StrSelect;
	
	end
	else
	begin
		IF @BankTypeID=''
			select PersonnelID
			,[prs].[funGetAccountNo](a.PersonnelID) AS AccountNo 
			, [prs].[funGetBankCartNo](a.PersonnelID) AS BankCartNo
			, [prs].[funGetShabaAccountNumber](a.PersonnelID,[prs].[funGetAccountNo](a.PersonnelID)) ShabaAccountNumber
			,DebitRemain PayableAmount
			,prs.funGetPersonnelName(a.PersonnelID,  Str(@LangID)  ) AS PersonnelName  
			 from (
			select distinct  PersonnelID,DebitRemain    from (select AcntCode,isnull(SUM(Credit-Debit),0)DebitRemain  
			 FROM acc.tblVoucherDtl 
			 where  AcntCode in(select AcntSalary  from prs.tblDecreeHdr  D)
			AND (VchKind <> 0)
			Group by AcntCode) V
			inner join (select a.* from prs.tblDecreeHdr a
							inner join 
							(select  PersonnelID,  Max(ExecutionDate) ExecutionDate from prs.tblDecreeHdr
							group by PersonnelID) b 
							on a.PersonnelID=b.PersonnelID and a.ExecutionDate=b.ExecutionDate) D 
			on V.AcntCode= D.AcntSalary			
				) a 
			where DebitRemain>0 and a.PersonnelID in (select PersonnelID from prs.tblPersonnels where CodeClosed=0)
		ELSE
			select a.PersonnelID
			,[prs].[funGetAccountNo](a.PersonnelID) AS AccountNo 
			, [prs].[funGetBankCartNo](a.PersonnelID) AS BankCartNo
			,[prs].[funGetShabaAccountNumber](a.PersonnelID,[prs].[funGetAccountNo](a.PersonnelID)) ShabaAccountNumber
			,DebitRemain PayableAmount
			,prs.funGetPersonnelName(a.PersonnelID,  Str(@LangID)  ) AS PersonnelName  
			 from (
			select distinct  PersonnelID,DebitRemain    from (select AcntCode,isnull(SUM(Credit-Debit),0)DebitRemain  
			 FROM acc.tblVoucherDtl 
			 where  AcntCode in(select AcntSalary  from prs.tblDecreeHdr  D)
			AND (VchKind <> 0)
			Group by AcntCode) V 
			inner join (select a.* from prs.tblDecreeHdr a
							inner join 
							(select  PersonnelID,  Max(ExecutionDate) ExecutionDate from prs.tblDecreeHdr
							group by PersonnelID) b 
							on a.PersonnelID=b.PersonnelID and a.ExecutionDate=b.ExecutionDate) D 
			 on V.AcntCode= D.AcntSalary
				) a 
			INNER JOIN (SELECT * from prs.tblPersonnelAccountsDtl where  BankTypeID = @BankTypeID )  c
			ON c.PersonnelID = a.PersonnelID
			where DebitRemain>0 and a.PersonnelID in (select PersonnelID from prs.tblPersonnels where CodeClosed=0)
	end
	
End
GO
