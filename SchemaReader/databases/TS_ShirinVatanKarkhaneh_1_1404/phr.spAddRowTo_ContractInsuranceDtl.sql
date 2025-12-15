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
CREATE PROCEDURE [phr].[spAddRowTo_ContractInsuranceDtl]

	@InsuranceID VarChar(20),
	@InsuranceTypeID VarChar(20),
	@InsuranceIDNew VarChar(20),
	@InsuranceTypeIDNew VarChar(20)
	
WITH ENCRYPTION
AS 
---- Declarations ---------------
Declare @StrSelect	NVarChar(4000);
DECLARE	@ReportID	Int;
DECLARE	@RowNo		Int;
DECLARE	@DocRowNo	Int;

SELECT @RowNo = IsNull(Max(RowNo),0)
FROM   phr.tblContractInsuranceDtl

SELECT @DocRowNo = IsNull(Max(DocRowNo),0)
FROM   phr.tblContractInsuranceDtl

Begin -- ============== S T A R T  C O D E ====================================

	SET NOCOUNT ON;
	
	INSERT INTO  phr.tblContractInsuranceDtl
	(InsuranceID, InsuranceTypeID, RowNo, DocRowNo, ProficiencyTypeID, MaxAmount)
	SELECT @InsuranceIDNew ,@InsuranceTypeIDNew ,ROW_NUMBER()OVER(ORDER BY R.DocRowNo) + @RowNo, ROW_NUMBER()OVER(ORDER BY R.DocRowNo) + @DocRowNo, R.ProficiencyTypeID, R.MaxAmount
	FROM
	(SELECT InsuranceID, InsuranceTypeID, RowNo, DocRowNo, ProficiencyTypeID, MaxAmount
	 FROM phr.tblContractInsuranceDtl
	 WHERE InsuranceID = @InsuranceID AND InsuranceTypeID = @InsuranceTypeID) R
	 
END
GO
