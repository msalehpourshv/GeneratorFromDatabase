USE TS_ShirinVatanKarkhaneh_1_1404
GO
SET ANSI_NULLS, QUOTED_IDENTIFIER ON
GO
--use TS_DarbMotaghed_1_1402
-- =========== TS-QC:UPDATED ====================
-- Author		 : TakroSystem\Jafari
-- Create date   : 1399/03/17
-- Viewed By	 : 
-- Last Modified : 1403-02-24
-- Last Modifier : h.ahmadnejad
-- ----------------------------------------------
-- Description	 : < گردش فیش حقوقی برای CRM   >
-- ==============================================
Create PROCEDURE crm.SpSalaryForTSCRM
		@MonthCode		Int	, 
		@AcntCode		Varchar(20)
WITH ENCRYPTION
AS
BEGIN
IF @AcntCode='' or  @AcntCode is null
			BEGIN								
				Raiserror ('کد حسابداری خالی است',16,1)
				Return
			END

DECLARE @RemainDate VarChar(10)
DECLARE @MyRepOptions VarChar(50)
DECLARE @RepInfo VarChar(50)
DECLARE @PersonnelID  Varchar(20)

	declare @From as int 
	declare @Len as int 

	set @From =[acc].[FunGetAcntInfoForRemain](2)
	set @Len =[acc].[FunGetAcntInfoForRemain](3)

	
	select @RemainDate = right(DB_NAME(),4) + 
		'/' + case when @MonthCode < 10 then '0' + ltrim(str(@MonthCode)) else ltrim(str(@MonthCode)) end +
		'/' + ltrim(str(case when @MonthCode < 7 then 31 else case when @MonthCode = 12 then 29 else 30 end  end))

	print @RemainDate

	select @PersonnelID= D.PersonnelID 
	from prs.tblDecreeHdr D 
		inner join  prs.tblSalaryCalculation S on D.PersonnelID=S.PersonnelID and D.SerialNo=S.DecreeSerialNo
		and MonthCode=@MonthCode
		and substring(AcntSalary,@From,@Len) =@AcntCode

	IF @PersonnelID='' or  @PersonnelID is null
		BEGIN								
			Raiserror ('کد پرسنلی برای کد حسابداری ورودی پیدا نشد',16,1)
			Return
		END

	SET @MyRepOptions = '11110000001'
	SET @RepInfo = '1@201@200032@0@1@@'+@PersonnelID


	CREATE TABLE #SalaryForTSCRM
	(
		PersonnelID			VarChar(20) COLLATE ARABIC_CS_AS,
		BenefitName			VarChar(50)  COLLATE ARABIC_CS_AS,
		BenefitAmount		Float,
		BenefitTime			nvarchar(30) COLLATE ARABIC_CS_AS,
		BenefitUnit			nvarchar(30) COLLATE ARABIC_CS_AS,
		BenefitType			Int,
		MonthCode			Int,
		DepartmentID		VarChar(50)
	);
 
	declare @ShowBill bit = 0
	select @ShowBill = CanSeeSalaryReceipt from prs.tblFunctionsHdr where MonthCode=@MonthCode

	if (@ShowBill=1)
	begin
		INSERT INTO #SalaryForTSCRM(PersonnelID,BenefitName,BenefitAmount,BenefitTime,BenefitUnit,BenefitType)
		EXEC [prs].[RptPrs_SalaryBillsDtl] @MonthCode, NULL,  NULL, NULL, NULL,  NULL,  @RemainDate, null, @MyRepOptions, @RepInfo	     
	end

	select PersonnelID,	BenefitName,BenefitAmount,isnull(BenefitTime,'') BenefitTime,isnull(BenefitUnit,'') BenefitUnit,BenefitOrder BenefitType-- ,	ShowType	--,BenefitOrder	
	from (SELECT D.PersonnelID,	D.BenefitName,D.BenefitAmount,D.BenefitTime,D.BenefitUnit,a.BenefitOrder--, +1 As BenefitType
	FROM #SalaryForTSCRM D inner join  prs.tblBenefitOrder a on a.BenefitName =D.BenefitName and a.BenefitType>0
	union All
	SELECT D.PersonnelID,	D.BenefitName,D.BenefitAmount,D.BenefitTime,D.BenefitUnit,a.BenefitOrder--, -1 As BenefitType 
	FROM #SalaryForTSCRM D  inner join  prs.tblBenefitOrder a on a.BenefitName =D.BenefitName  and a.BenefitType<0
	)a
	where @PersonnelID='' Or PersonnelID=@PersonnelID
	ORDER BY PersonnelID, BenefitOrder Desc , BenefitAmount DESC
	
END
GO
