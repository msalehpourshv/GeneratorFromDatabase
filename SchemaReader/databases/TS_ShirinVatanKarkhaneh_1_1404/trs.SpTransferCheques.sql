USE TS_ShirinVatanKarkhaneh_1_1404
GO
SET ANSI_NULLS, QUOTED_IDENTIFIER ON
GO
-- =========== TS-QC:UPDATED ====================
-- Author        : TakroSystem\Ahmadnejad
-- Creation date : 1388/01/08
-- Viewed By	 : 
-- Last Modified : 
-- Last Modifier : 
-- Description   : لیست چکهای استفاده نشده جهت انتقال به سال مالی جدید
-- =============================================
CREATE PROCEDURE [trs].[SpTransferCheques]
WITH ENCRYPTION
AS

CREATE TABLE #SpTransferCheques_tblBC
(
	BankCode		VarChar(20),
	FiscalYear		SmallInt,
	ChequeBookID	SmallInt,
	ChequeDate		Char(10)
)
CREATE TABLE #SpTransferCheques_tblResult
(
	BankCode		VarChar(20),
	FiscalYear		SmallInt,
	ChequeBookID	SmallInt,
	ChequeCodeFr	BigInt Not Null,
	ChequeCodeTo	BigInt Null,
	ChequeDate		Char(10)
)
CREATE TABLE #SpTransferCheques_tblCheques
(
	FiscalYear		SmallInt,
	ChequeBookID	SmallInt,
	ChequeCodeFr	BigInt Not Null,
	ChequeCodeTo	BigInt Null,
	ChequeCount		Int
)
DECLARE @ChequeDate			Char(10)
DECLARE @BankCode			VarChar(20)
DECLARE @FiscalYear			SmallInt
DECLARE @ChequeBookID		SmallInt
DECLARE @ChequeCode			BigInt
DECLARE @TempCode			BigInt
BEGIN   ---------------------------  B E G I N ----------------------------------
	SET NOCOUNT ON;

	INSERT INTO #SpTransferCheques_tblBC
		SELECT DISTINCT BankCode, FiscalYear, ChequeBookID, ChequeDate
		FROM trs.tblBankChequesDtl

	DECLARE	MyCursor CURSOR FOR
		SELECT DISTINCT BankCode
		FROM trs.tblBankChequesDtl

	OPEN MyCursor
	FETCH NEXT FROM MyCursor INTO @BankCode

	WHILE (@@Fetch_Status = 0)
	BEGIN
		TRUNCATE TABLE #SpTransferCheques_tblCheques

		INSERT INTO #SpTransferCheques_tblCheques(FiscalYear, ChequeBookID, ChequeCodeFr, ChequeCodeTo, ChequeCount)
		EXEC [trs].[RptTrs_UnusedCheques] 1, @BankCode, '', '1@1@1@0@1'

		INSERT INTO #SpTransferCheques_tblResult(BankCode, FiscalYear, ChequeBookID, ChequeCodeFr, ChequeCodeTo, ChequeDate)
		SELECT BC.BankCode, C.FiscalYear, C.ChequeBookID, C.ChequeCodeFr, C.ChequeCodeTo, BC.ChequeDate
		FROM #SpTransferCheques_tblCheques C INNER JOIN #SpTransferCheques_tblBC BC ON C.FiscalYear = BC.FiscalYear AND C.ChequeBookID = BC.ChequeBookID AND BC.BankCode = @BankCode

		FETCH NEXT FROM MyCursor INTO @BankCode
	END

	CLOSE		MyCursor;
	DEALLOCATE	MyCursor;

	SELECT *
	FROM #SpTransferCheques_tblResult 
END
GO
