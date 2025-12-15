USE TS_ShirinVatanKarkhaneh_1_1404
GO
SET ANSI_NULLS, QUOTED_IDENTIFIER ON
GO
-- =========== TS-QC:NOTOK ========================
-- Author        : Hadi Sadeghi
-- Create date   : 87/01/08
-- Viewed By	 : 
-- Last Modified : 
-- Description   : 
-- =============================================
Create PROCEDURE [prs].[SpGetPersonnelBasPay]
    @strDocDate		Char(10),
	@BankTypeID		nvarchar(20) 

WITH ENCRYPTION
AS
BEGIN
	
	IF @BankTypeID<>''
	begin
		SELECT D.PersonnelID,Basepay
		FROM prs.tblDecreeHdr D
		INNER JOIN 
			(
				SELECT PersonnelID,Max(ExecutionDate) ExecutionDate
				FROM prs.tblDecreeHdr 
				WHERE ExecutionDate <> '' AND ExecutionDate <= @strDocDate
				GROUP BY PersonnelID
			) G ON D.PersonnelID = G.PersonnelID AND D.ExecutionDate = G.ExecutionDate
		INNER JOIN (SELECT * from prs.tblPersonnelAccountsDtl where  BankTypeID = '''' + @BankTypeID + '''' )  c ON c.PersonnelID = D.PersonnelID 
	end
	else
	begin
		SELECT D.PersonnelID,Basepay
		FROM prs.tblDecreeHdr D
		INNER JOIN 
			(
				SELECT PersonnelID,Max(ExecutionDate) ExecutionDate
				FROM prs.tblDecreeHdr 
				WHERE ExecutionDate <> '' AND ExecutionDate <= @strDocDate
				GROUP BY PersonnelID
			) G ON D.PersonnelID = G.PersonnelID AND D.ExecutionDate = G.ExecutionDate
	end
END
GO
