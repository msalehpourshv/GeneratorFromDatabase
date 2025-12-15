USE TS_ShirinVatanKarkhaneh_1_1404
GO
SET ANSI_NULLS, QUOTED_IDENTIFIER ON
GO
-- =========== TS-QC:NOTOK ========================
-- Author        : Jafari
-- Create date   : 94/04/25
-- Viewed By	 : 
-- Last Modified : 
-- Description   : 
-- ================================================
Create PROCEDURE [prs].[SpInsuranceTest]
	@Date	CHAR(10)
WITH ENCRYPTION
AS
BEGIN 

SELECT D.InsuranceTypeID,p.*  FROM   prs.tblDecreeHdr D 
INNER JOIN prs.tblPersonnels p ON p.PersonnelID = D.PersonnelID 
WHERE SerialNo in( SELECT Top 1 SerialNo from prs.tblDecreeHdr WHERE SerialNo >0 
 AND ExecutionDate <> '' AND ExecutionDate <=@Date
  and PersonnelID = D.PersonnelID ORDER BY PersonnelID,ExecutionDate desc,SerialNo desc)
 and InsuranceID = '' 
 and  InsuranceTypeID   in( select InsuranceTypeID FROM      
    prs.tblInsuranceTypes where EmployerPercent<>0 or  EmployeePercent<>0 or   Dole <>0 ) 
 
 and p.PersonnelID in (Select PersonnelID FROM         prs.tblFunctionsDtl where MonthCode=substring(@Date,6,2) )
end
	
	
GO
