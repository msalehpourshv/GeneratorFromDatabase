USE TS_ShirinVatanKarkhaneh_1_1404
GO
SET ANSI_NULLS, QUOTED_IDENTIFIER ON
GO
-- =========== TS-QC:UPDATED ====================
-- Author		 : Ahmadnejad
-- Create date   : 1386/02/11
-- Viewed By	 : 
-- Last Modified : 1392/01/07
-- Description	 : <Unused Cheques list>
-- ----------------------------------------------
-- لیست برگ چکهای استفاده نشده دسته چکهای یک بانک
-- ==============================================
Create PROCEDURE [trs].[RptTrs_UnusedCheques]
	@ProcessNo	int = 1,
	@BankCode	VarChar(20),
	@RepOptions	VarChar(10) = '1111', -- bit array options
	@RepInfo	NVarChar(100) = '1@1@1'
WITH ENCRYPTION
As
CREATE TABLE #tblResult
(
	FiscalYear		SmallInt,
	ChequeBookID	SmallInt,
	ChequeCodeFrom	BigInt Not Null,
	ChequeCodeTo	BigInt Null,
	ChequeCount		BigInt
)
DECLARE @FiscalYear			SmallInt
DECLARE @ChequeBookID		SmallInt
DECLARE @ChequeCode			BigInt
DECLARE @TempCode			BigInt

Declare @ChequeIsDigital	bit

Set @ChequeIsDigital	= pub.funSplitString(@RepInfo, '@', 6);

BEGIN   ---------------------------  B E G I N ----------------------------------
	SET NOCOUNT ON;


	INSERT INTO #tblResult
		SELECT	FiscalYear, ChequeBookID, FromChequeNo, ToChequeNo, ToChequeNo - FromChequeNo + 1
		FROM	trs.tblBankChequesDtl
		WHERE	BankCode = @BankCode And (@ChequeIsDigital = 0 or (@ChequeIsDigital = 1 and ChequeIsDigital = 1))

	-- DECLARE Cursor for Paid Cheques or Void Cheques -------------
	DECLARE	Cursor_PaidCheques CURSOR FOR
		SELECT	DISTINCT ChequeBookFiscalYear, ChequeBookID, ChequeNo  -- چکهای پرداختی
		FROM	trs.tblPayDtl 
		WHERE	PayTypeID IN (7, 8, 18, 28) 
			--and (ProcessNo = @ProcessNo)
			AND ChequeBookID IN (SELECT DISTINCT ChequeBookID FROM #tblResult)
			

		EXCEPT  
		SELECT	DISTINCT ChequeBookFiscalYear, ChequeBookID, ChequeNo  -- چکهای پرداختی برگشتی
		FROM	trs.tblPayDtl a
		WHERE	(PayTypeID IN (7, 8, 18, 28)) 
			AND (ProcessID IN (28, 34)) 
			--and (ProcessNo = @ProcessNo)
			AND ChequeBookID IN (SELECT DISTINCT ChequeBookID FROM #tblResult)
			AND ( (SELECT COUNT(*) from  trs.tblPayDtl b WHERE a.ChequeNo= a.ChequeNo AND  a.ChequeBookID= a.ChequeBookID AND  a.ChequeBookFiscalYear= a.ChequeBookFiscalYear )=1 OR
			 ((SELECT COUNT(*) from  trs.tblPayDtl b WHERE a.ChequeNo= a.ChequeNo AND  a.ChequeBookID= a.ChequeBookID AND  a.ChequeBookFiscalYear= a.ChequeBookFiscalYear AND ProcessID=27 ) =0  AND
				 (SELECT COUNT(*) from  trs.tblPayDtl b WHERE a.ChequeNo= a.ChequeNo AND  a.ChequeBookID= a.ChequeBookID AND  a.ChequeBookFiscalYear= a.ChequeBookFiscalYear )%2 =1 
				)) 

		UNION all	
		SELECT	DISTINCT FiscalYear, ChequeBookID, ChequeNo	-- چکهای باطله
		FROM	trs.tblBankVoidChequesDtl
		WHERE	ChequeBookID IN (SELECT DISTINCT ChequeBookID FROM #tblResult)
	--------------------------------------------------------------------------

	OPEN Cursor_PaidCheques
	FETCH NEXT FROM Cursor_PaidCheques INTO @FiscalYear, @ChequeBookID, @ChequeCode

	WHILE (@@Fetch_Status = 0)
	BEGIN

		-- Delete solo ChequeNo
		DELETE 
		FROM  #tblResult
		WHERE (FiscalYear = @FiscalYear) AND (ChequeBookID = @ChequeBookID) AND
			  (ChequeCodeFrom = @ChequeCode) AND (ChequeCodeTo = @ChequeCode)
		IF @@RowCount > 0 GOTO Next

		-- Delete from begining of the FromTo list
		UPDATE	#tblResult
		SET		ChequeCodeFrom = ChequeCodeFrom + 1, ChequeCount = ChequeCount - 1
		WHERE	(FiscalYear = @FiscalYear) AND (ChequeBookID = @ChequeBookID) AND (ChequeCodeFrom = @ChequeCode) 
		IF @@RowCount > 0 GOTO Next 
	
		-- Delete from end of the FromTo list
		UPDATE	#tblResult
		SET		ChequeCodeTo = ChequeCodeTo - 1, ChequeCount = ChequeCount - 1
		WHERE	(FiscalYear = @FiscalYear) AND (ChequeBookID = @ChequeBookID) AND (ChequeCodeTo = @ChequeCode)
		IF @@RowCount > 0 GOTO Next

		-- Delete from mean of FromTo List and Split Code to 2 Segments
		-- phase 1 (update <To> part of list)
		UPDATE	#tblResult
		SET		@TempCode = ChequeCodeTo, 
				ChequeCodeTo = @ChequeCode - 1, 
				ChequeCount = @ChequeCode - ChequeCodeFrom
		WHERE	(FiscalYear = @FiscalYear) AND (ChequeBookID = @ChequeBookID) AND (ChequeCodeFrom < @ChequeCode) AND (@ChequeCode < ChequeCodeTo)

		IF @@RowCount = 0 GOTO Next

		-- phase 2 (Insert remain part)
		IF (@TempCode Is Not Null)
		BEGIN
			INSERT INTO #tblResult
			VALUES (@FiscalYear, @ChequeBookID, @ChequeCode + 1, @TempCode, @TempCode - @ChequeCode )
		END

	Next:
		FETCH NEXT FROM Cursor_PaidCheques INTO @FiscalYear, @ChequeBookID, @ChequeCode
	END 

	CLOSE Cursor_PaidCheques;
	DEALLOCATE Cursor_PaidCheques;

	SELECT *
	FROM #tblResult
	ORDER BY FiscalYear, ChequeBookID, ChequeCodeFrom, ChequeCodeTo
END
GO
