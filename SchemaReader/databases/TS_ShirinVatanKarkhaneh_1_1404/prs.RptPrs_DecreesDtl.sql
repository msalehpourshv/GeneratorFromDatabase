USE TS_ShirinVatanKarkhaneh_1_1404
GO
SET ANSI_NULLS, QUOTED_IDENTIFIER ON
GO
-- =========== TS-QC:UPDATED ====================
-- Author		 : TakroSystem\Ahmadnejad
-- Creation Date : 87/07/03
-- Viewed By	 : 
-- Last Modified : 
-- Last Modifier : 
-- Description	 : �ѐ �͘�� �����2
-- ==============================================
CREATE PROCEDURE [prs].[RptPrs_DecreesDtl]
	@PersonnelID	VarChar(20),
	@SerialNo		Int
WITH ENCRYPTION
AS 

DECLARE @LanguageID TinyInt;
DECLARE @StrSQL		NVarChar(4000);
DECLARE @BenefitID	VarChar(20);
DECLARE @Amount		BigInt;

CREATE TABLE #tbl
(
	BenefitID	VarChar(20) Null,
	BenefitName NVarChar(200) Null,
	Amount	BigInt Null,
	TypeID	SmallInt Null
);
Begin --============== S T A R T  C O D E =======================================

	SET NOCOUNT ON;

	---- Init ------------------------------------------
	SET @LanguageID = pub.funGetCurrentLanguageID();
	----------------------------------------------------

	INSERT INTO #tbl
	SELECT BenefitID, BenefitName, 0, +1
	FROM prs.tblBenefits1Dtl
	WHERE (BenefitID <> '')

	INSERT INTO #tbl
	SELECT BenefitID, BenefitName, 0, -1
	FROM prs.tblDeduction1Dtl
	WHERE (BenefitID <> '')

	DECLARE csr_Bnf CURSOR FOR
		SELECT BenefitID 
		FROM prs.tblBenefits1
		WHERE (BenefitID <> '')

	OPEN csr_Bnf
	FETCH NEXT FROM csr_Bnf INTO @BenefitID

	WHILE @@FETCH_STATUS = 0
	BEGIN

		SET @StrSQL = '
		UPDATE #tbl 
		SET Amount = 
			IsNull((
				SELECT Benefit' + @BenefitID + ' 
				FROM prs.tblDecreeHdr
				WHERE (PersonnelID = ''' + @PersonnelID + ''') AND (SerialNo = ' + LTRim(Str(@SerialNo)) + ') 
			), 0)
		WHERE (BenefitID = ''' + @BenefitID + ''') AND (TypeID = +1)'

		EXEC sp_executesql @StrSQL;

		FETCH NEXT FROM csr_Bnf INTO @BenefitID
	END

	CLOSE		csr_Bnf
	DEALLOCATE	csr_Bnf

	DECLARE csr_Bnf CURSOR FOR
		SELECT BenefitID
		FROM prs.tblDeduction1
		WHERE (BenefitID <> '')

	OPEN csr_Bnf
	FETCH NEXT FROM csr_Bnf INTO @BenefitID

	WHILE @@FETCH_STATUS = 0
	BEGIN

		SET @StrSQL = '
		UPDATE #tbl 
		SET Amount = 
			IsNull((
				SELECT Deduction' + @BenefitID + ' 
				FROM prs.tblDecreeHdr
				WHERE (PersonnelID = ''' + @PersonnelID + ''') AND (SerialNo = ' + LTRim(Str(@SerialNo)) + ') 
			), 0)
		WHERE (BenefitID = ''' + @BenefitID + ''') AND (TypeID = -1)'

		EXEC sp_executesql @StrSQL;

		FETCH NEXT FROM csr_Bnf INTO @BenefitID
	END

	CLOSE		csr_Bnf
	DEALLOCATE	csr_Bnf

	SELECT *
	FROM #tbl
End

GO
