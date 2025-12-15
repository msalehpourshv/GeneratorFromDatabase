USE TS_ShirinVatanKarkhaneh_1_1404
GO
SET ANSI_NULLS, QUOTED_IDENTIFIER ON
GO
-- =========== TS-QC:UPDATED ====================
-- Author		 : TakroSystem\Jafari
-- Create date   : 1399/03/17
-- Viewed By	 : 
-- Last Modified : 
-- Last Modifier : 
-- ----------------------------------------------
-- Description	 : < گردش فیش حقوقی برای CRM  رز>
-- ==============================================
Create PROCEDURE crm.SpSalaryForRozCRM
		@MonthCode		Int	, 
		@PersonnelID  Varchar(20)
WITH ENCRYPTION
AS
BEGIN

DECLARE @MyRepOptions VarChar(50)
DECLARE @RepInfo VarChar(50)

SET @MyRepOptions = '01110000001'
SET @RepInfo = '1@201@200032@0@1'
	CREATE TABLE #SalaryForRozCRM
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
 
		INSERT INTO #SalaryForRozCRM(PersonnelID,BenefitName,BenefitAmount,BenefitTime,BenefitUnit,BenefitType)
		EXEC [prs].[RptPrs_SalaryBillsDtl] @MonthCode, NULL,  NULL, NULL, NULL,  NULL,  NULL, null, @MyRepOptions, @RepInfo	

  	select PersonnelID,	BenefitName,BenefitAmount,isnull(BenefitTime,'') BenefitTime,isnull(BenefitUnit,'') BenefitUnit,BenefitOrder BenefitType-- ,	ShowType	--,BenefitOrder	
	from (SELECT D.PersonnelID,	D.BenefitName,D.BenefitAmount,D.BenefitTime,D.BenefitUnit,a.BenefitOrder--, +1 As BenefitType
	FROM #SalaryForRozCRM D inner join  prs.tblBenefitOrder a on a.BenefitName =D.BenefitName and a.BenefitType>0
	union All
	SELECT D.PersonnelID,	D.BenefitName,D.BenefitAmount,D.BenefitTime,D.BenefitUnit,a.BenefitOrder--, -1 As BenefitType 
	FROM #SalaryForRozCRM D  inner join  prs.tblBenefitOrder a on a.BenefitName =D.BenefitName  and a.BenefitType<0
	)a
	where @PersonnelID='' Or PersonnelID=@PersonnelID
	ORDER BY PersonnelID, BenefitOrder Desc , BenefitAmount DESC
	
END
GO
