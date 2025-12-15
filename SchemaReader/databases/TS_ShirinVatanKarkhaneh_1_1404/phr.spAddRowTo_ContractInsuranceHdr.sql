USE TS_ShirinVatanKarkhaneh_1_1404
GO
SET ANSI_NULLS, QUOTED_IDENTIFIER ON
GO
-- =========== TS-QC:UPDATED ====================
-- Author		 : TakroSystem\Hamid
-- Create date   : 1392/07/29
-- Viewed By	 : 
-- Last Modified : 
-- Last Modifier : 
-- Description	 : 
-- ==============================================
CREATE PROCEDURE [phr].[spAddRowTo_ContractInsuranceHdr]

	@InsuranceID VarChar(20),
	@InsuranceTypeID VarChar(20),
	@InsuranceIDNew VarChar(20),
	@InsuranceTypeIDNew VarChar(20)
	
WITH ENCRYPTION
AS 
---- Declarations ---------------
Declare @StrSelect	NVarChar(4000);
DECLARE	@ReportID	Int;

Begin -- ============== S T A R T  C O D E ====================================

	SET NOCOUNT ON;
	
	INSERT INTO  phr.tblContractInsuranceHdr
	(InsuranceID, InsuranceTypeID, RecID, SessionNo, MaxPrescripionAmount, MaxPrescripionQtyInMonth, 
	MaxCreditAmount, InsuranceTypeConditions, InsuranceFileName, HasPeriority, AcceptProficiencyCost, 
	HasInsuranceBookletNo, CompanyIsActive, AcntBookName, AcntCode, ComputerCode, AcntDesc, PrimaryAcntStatus, 
	PrimaryAcntStatusAmount, ProficiencyCurrentAmount, ProficiencyBeforeAmount, ApplyDate)
	SELECT @InsuranceIDNew ,@InsuranceTypeIDNew ,R.RecID ,R.SessionNo ,
		   R.MaxPrescripionAmount, R.MaxPrescripionQtyInMonth, R.MaxCreditAmount,
		   R.InsuranceTypeConditions, R.InsuranceFileName ,
		   R.HasPeriority, R.AcceptProficiencyCost, R.HasInsuranceBookletNo,
		   R.CompanyIsActive, R.AcntBookName, R.AcntCode, R.ComputerCode ,R.AcntDesc,
		   R.PrimaryAcntStatus, R.PrimaryAcntStatusAmount, R.ProficiencyCurrentAmount,
		   R.ProficiencyBeforeAmount, R.ApplyDate
	FROM
	(SELECT InsuranceID ,InsuranceTypeID, RecID, SessionNo , MaxPrescripionAmount, MaxPrescripionQtyInMonth, 
	MaxCreditAmount, InsuranceTypeConditions, InsuranceFileName, HasPeriority, AcceptProficiencyCost, 
	HasInsuranceBookletNo, CompanyIsActive, AcntBookName, AcntCode, ComputerCode, AcntDesc, PrimaryAcntStatus, 
	PrimaryAcntStatusAmount, ProficiencyCurrentAmount, ProficiencyBeforeAmount, ApplyDate
	 FROM phr.tblContractInsuranceHdr
	 WHERE InsuranceID = @InsuranceID AND InsuranceTypeID = @InsuranceTypeID) R

End
GO
