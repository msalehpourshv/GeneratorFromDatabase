USE TS_ShirinVatanKarkhaneh_1_1404
GO
SET ANSI_NULLS, QUOTED_IDENTIFIER ON
GO
-- =========== TS-QC:UPDATED ====================
-- Author		 : TakroSystem\Ahmadnejad
-- Creation Date : 1388/04/30
-- Viewed By	 : 
-- Last Modified : 1392/01/07
-- Last Modifier : TakroSystem\Zia
-- Description   : گزارش نقدینگی
-- ==============================================
Create PROCEDURE [trs].[RptTrs_BudgetStats]
	@ProcessNo		Int = 1,
	@Date1F			Char(10) = Null,
	@Date2F			Char(10) = Null,
	@Date3F			Char(10) = Null,
	@Date1			Char(10) = Null,
	@Date2			Char(10) = Null,
	@Date3			Char(10) = Null,
	@Days			Int = 5,
	@MyRecAmount	float = 0,
	@MyPayAmount	float = 0,
	@RepOptions		NVarChar(100) = '', -- bit array options
	@RepInfo		NVarChar(100) = '1@1@1' -- bit array options
WITH ENCRYPTION
AS 
---- Declarations ---------------
DECLARE @StrSelect	NVarChar(4000);
DECLARE @StrWhere	NVarChar(2000);

DECLARE	@LangID		Char(1);
DECLARE	@SessionNo	Int; 
DECLARE	@ReportID	Int; 

DECLARE @RecAmountBank1	float;
DECLARE @RecAmountBank2	float;
DECLARE @RecAmountBank3	float;
DECLARE @RecAmountCash1	float;
DECLARE @RecAmountCash2	float;
DECLARE @RecAmountCash3	float;
DECLARE @PayAmount1		float;
DECLARE @PayAmount2		float;
DECLARE @PayAmount3		float;
DECLARE @CashAmount1	float;
DECLARE @CashAmount2	float;
DECLARE @CashAmount3	float;
DECLARE @LoanAmount1	float;
DECLARE @LoanAmount2	float;
DECLARE @LoanAmount3	float;
Begin --============== S T A R T  C O D E ===================================================

	SET NOCOUNT ON;

	-- Init Variables --------
	--IF (@Date1F Is Null)		SET @Date1F = '0000/01/01'
	--IF (@Date2F Is Null)		SET @Date2F = '0000/01/01'
	--IF (@Date3F Is Null)		SET @Date3F = '0000/01/01'
	IF (@Date1 Is Null)			SET @Date1 = '3000/01/01'
	IF (@Date2 Is Null)			SET @Date2 = '3000/01/01'
	IF (@Date3 Is Null)			SET @Date3 = '3000/01/01'
	IF (@RepInfo Is Null)		SET @RepInfo = '1@1@1';
	IF (@RepOptions Is Null)	SET @RepOptions = '';

	SET @LangID		= pub.funSplitString(@RepInfo, '@', 1);
	SET @SessionNo	= pub.funSplitString(@RepInfo, '@', 2);
	SET @ReportID	= pub.funSplitString(@RepInfo, '@', 3);
	-- ------------------------------------------------------------------------
	-- Select Clause ----------------------------------------
	BEGIN TRY
		DROP TABLE #tbl_RptTrs_BudgetStats
	END TRY
	BEGIN CATCH
	END CATCH

	-- 1- Bank Accounts Remain --
	SELECT [Order], AcntCode, AcntName, Amount1, Amount1 AS Amount2, Amount1 AS Amount3, Cast(0 AS Bit) AS IsSummary
	INTO #tbl_RptTrs_BudgetStats
	FROM
	(
		SELECT	D.BankCode AS AcntCode, D.BankName AS AcntName, 
				(
					SELECT IsNull(Sum(Debit - Credit), 0)
					FROM   acc.tblVoucherDtl
					WHERE  (AcntCode = H.AcntCode1) --AND (DocDate <= @Date1)
				) Amount1, CASE WHEN (H.BankState = 1) THEN 0 ELSE 1 END AS [Order]
		FROM	trs.tblOurBanksDtl D 
				INNER JOIN trs.tblOurBanks H ON H.BankCode = D.BankCode
		WHERE (H.BankState IN (1, 3)) AND (D.BankCode <> '')
	) T
	ORDER BY AcntCode
	
	-- 2- Summary ----------------------------------------------------------
	SELECT @CashAmount1 = Sum(Amount1), @CashAmount2 = Sum(Amount2), @CashAmount3 = Sum(Amount3)
	FROM #tbl_RptTrs_BudgetStats

	INSERT INTO #tbl_RptTrs_BudgetStats
	SELECT 2, 0, 'کل موجودی نقد', @CashAmount1, @CashAmount2, @CashAmount3, 1 AS IsSummary

	-- 3- Receivable Docs Bank ----------------------------------------------
	SELECT	@RecAmountBank1 = IsNull(Sum(D.Amount), 0)
	FROM	trs.tblPayDtl AS D
			INNER JOIN
			(
				SELECT	D2.VolumeFiscalYear, D2.VolumeRowNo, Max(D2.EventNo) AS EventNo
				FROM	trs.tblPayDtl AS D2
				WHERE	D2.PayTypeID IN (6, 26) AND D2.ProcessNo = @ProcessNo
				GROUP BY D2.VolumeFiscalYear, D2.VolumeRowNo
			 ) VOL ON D.VolumeFiscalYear = VOL.VolumeFiscalYear AND D.VolumeRowNo = VOL.VolumeRowNo AND D.EventNo = VOL.EventNo
	WHERE	 (D.ProcessID IN (21,20)) AND (D.ProcessNo = 1) AND (D.PayTypeID IN (6, 26))
	 --AND (D.ChequeDate >= pub.funFarsiDateAddDays('Day', @Date1F, 0-@Days)) 
	 AND (D.ChequeDate <= pub.funFarsiDateAddDays('Day', @Date1, 0-@Days))

	SELECT	@RecAmountBank2 = IsNull(Sum(D.Amount), 0)
	FROM	trs.tblPayDtl AS D
			INNER JOIN
			(
				SELECT	D2.VolumeFiscalYear, D2.VolumeRowNo, Max(D2.EventNo) AS EventNo
				FROM	trs.tblPayDtl AS D2
				WHERE	D2.PayTypeID IN (6, 26) AND D2.ProcessNo = @ProcessNo
				GROUP BY D2.VolumeFiscalYear, D2.VolumeRowNo
			 ) VOL ON D.VolumeFiscalYear = VOL.VolumeFiscalYear AND D.VolumeRowNo = VOL.VolumeRowNo AND D.EventNo = VOL.EventNo
	WHERE	 (D.ProcessID IN (21,20)) AND (D.ProcessNo = 1) AND (D.PayTypeID IN (6, 26)) 
	--AND (D.ChequeDate >= pub.funFarsiDateAddDays('Day', @Date2F, 0-@Days)) 
	AND (D.ChequeDate <= pub.funFarsiDateAddDays('Day', @Date2, 0-@Days))

	SELECT	@RecAmountBank3 = IsNull(Sum(D.Amount), 0)
	FROM	trs.tblPayDtl AS D
			INNER JOIN
			(
				SELECT	D2.VolumeFiscalYear, D2.VolumeRowNo, Max(D2.EventNo) AS EventNo
				FROM	trs.tblPayDtl AS D2
				WHERE	D2.PayTypeID IN (6, 26) AND D2.ProcessNo = @ProcessNo
				GROUP BY D2.VolumeFiscalYear, D2.VolumeRowNo
			 ) VOL ON D.VolumeFiscalYear = VOL.VolumeFiscalYear AND D.VolumeRowNo = VOL.VolumeRowNo AND D.EventNo = VOL.EventNo
	WHERE	 (D.ProcessID IN (21,20)) AND (D.ProcessNo = 1) AND (D.PayTypeID IN (6, 26))
	-- AND (D.ChequeDate >= pub.funFarsiDateAddDays('Day', @Date3F, 0-@Days))
	 AND (D.ChequeDate <= pub.funFarsiDateAddDays('Day', @Date3, 0-@Days))

	INSERT INTO #tbl_RptTrs_BudgetStats
	SELECT 3, 0, 'اسناد دریافتنی واگذار شده به بانکها', @RecAmountBank1, @RecAmountBank2, @RecAmountBank3, 0 AS IsSummary

	-- 4- Receivable Docs Cash ----------------------------------------------
	SELECT	@RecAmountCash1 = IsNull(Sum(D.Amount), 0)
	FROM	trs.tblPayDtl AS D
			INNER JOIN
			(
				SELECT	D2.VolumeFiscalYear, D2.VolumeRowNo, Max(D2.EventNo) AS EventNo
				FROM	trs.tblPayDtl AS D2
				WHERE	D2.PayTypeID IN (6, 26) AND D2.ProcessNo = @ProcessNo
				GROUP BY D2.VolumeFiscalYear, D2.VolumeRowNo
			 ) VOL ON D.VolumeFiscalYear = VOL.VolumeFiscalYear AND D.VolumeRowNo = VOL.VolumeRowNo AND D.EventNo = VOL.EventNo
	WHERE	 (D.ProcessID IN (10,1,40)) AND (D.ProcessNo = 1) AND (D.PayTypeID IN (6, 26))
	 --AND (D.ChequeDate >= pub.funFarsiDateAddDays('Day', @Date1F, 0-@Days)) 
	 AND (D.ChequeDate <= pub.funFarsiDateAddDays('Day', @Date1, 0-@Days))

	SELECT	@RecAmountCash2 = IsNull(Sum(D.Amount), 0)
	FROM	trs.tblPayDtl AS D
			INNER JOIN
			(
				SELECT	D2.VolumeFiscalYear, D2.VolumeRowNo, Max(D2.EventNo) AS EventNo
				FROM	trs.tblPayDtl AS D2
				WHERE	D2.PayTypeID IN (6, 26) AND D2.ProcessNo = @ProcessNo
				GROUP BY D2.VolumeFiscalYear, D2.VolumeRowNo
			 ) VOL ON D.VolumeFiscalYear = VOL.VolumeFiscalYear AND D.VolumeRowNo = VOL.VolumeRowNo AND D.EventNo = VOL.EventNo
	WHERE	 (D.ProcessID IN (10,1,40)) AND (D.ProcessNo = 1) AND (D.PayTypeID IN (6, 26)) 
	--AND (D.ChequeDate >= pub.funFarsiDateAddDays('Day', @Date2F, 0-@Days)) 
	AND (D.ChequeDate <= pub.funFarsiDateAddDays('Day', @Date2, 0-@Days))

	SELECT	@RecAmountCash3 = IsNull(Sum(D.Amount), 0)
	FROM	trs.tblPayDtl AS D
			INNER JOIN
			(
				SELECT	D2.VolumeFiscalYear, D2.VolumeRowNo, Max(D2.EventNo) AS EventNo
				FROM	trs.tblPayDtl AS D2
				WHERE	D2.PayTypeID IN (6, 26) AND D2.ProcessNo = @ProcessNo
				GROUP BY D2.VolumeFiscalYear, D2.VolumeRowNo
			 ) VOL ON D.VolumeFiscalYear = VOL.VolumeFiscalYear AND D.VolumeRowNo = VOL.VolumeRowNo AND D.EventNo = VOL.EventNo
	WHERE	 (D.ProcessID IN (10,1,40)) AND (D.ProcessNo = 1) AND (D.PayTypeID IN (6, 26)) 
	--AND (D.ChequeDate >= pub.funFarsiDateAddDays('Day', @Date3F, 0-@Days)) 
	AND (D.ChequeDate <= pub.funFarsiDateAddDays('Day', @Date3, 0-@Days))

	INSERT INTO #tbl_RptTrs_BudgetStats
	SELECT 4, 0, 'اسناد دریافتنی پاس نشده', @RecAmountCash1, @RecAmountCash2, @RecAmountCash3, 0 AS IsSummary
	
	-- 5- Receivable Docs Future --------------------------------------------
	INSERT INTO #tbl_RptTrs_BudgetStats
	SELECT 5, 0, 'پیش بینی حسابهای دریافتنی - واریزی', @MyRecAmount, @MyRecAmount, @MyRecAmount, 0 AS IsSummary

	-- 6- Summary -----------------------------------------------------------
	INSERT INTO #tbl_RptTrs_BudgetStats
	SELECT 6, 0, 'جمع منابع', @RecAmountBank1 + @RecAmountCash1 + @MyRecAmount, 
							 @RecAmountBank2 + @RecAmountCash2 + @MyRecAmount, 
							 @RecAmountBank3 + @RecAmountCash3 + @MyRecAmount, 1 AS IsSummary

	-- 7- Payable Docs Bank ----------------------------------------------
	SELECT	@PayAmount1 = IsNull(Sum(D.Amount), 0)
	FROM	trs.tblPayDtl AS D
			INNER JOIN
			(
				SELECT	VolumeFiscalYear, VolumeRowNo
				FROM	trs.tblPayDtl
				WHERE	PayTypeID IN(8, 28) AND ProcessNo = @ProcessNo AND ProcessID IN (2, 25)
				EXCEPT  
				SELECT	VolumeFiscalYear, VolumeRowNo
				FROM	trs.tblPayDtl
				WHERE	PayTypeID IN(8, 28) AND ProcessNo = @ProcessNo AND ProcessID = 27
				EXCEPT  
				SELECT	VolumeFiscalYear, VolumeRowNo
				FROM	trs.tblPayDtl
				WHERE	PayTypeID IN(8, 28) AND ProcessNo = @ProcessNo AND ProcessID = 28
			) AS V ON V.VolumeFiscalYear = D.VolumeFiscalYear AND V.VolumeRowNo = D.VolumeRowNo 
	WHERE	(D.ProcessID IN (2,25)) AND (D.ProcessNo = 1) AND (D.PayTypeID IN (8, 28)) 
	--AND (D.ChequeDate >= @Date1F)
	 AND (D.ChequeDate <= @Date1)

	SELECT	@PayAmount2 = IsNull(Sum(D.Amount), 0)
	FROM	trs.tblPayDtl AS D
			INNER JOIN
			(
				SELECT	VolumeFiscalYear, VolumeRowNo
				FROM	trs.tblPayDtl
				WHERE	PayTypeID IN(8, 28) AND ProcessNo = @ProcessNo AND ProcessID IN (2, 25)
				EXCEPT  
				SELECT	VolumeFiscalYear, VolumeRowNo
				FROM	trs.tblPayDtl
				WHERE	PayTypeID IN(8, 28) AND ProcessNo = @ProcessNo AND ProcessID = 27
				EXCEPT  
				SELECT	VolumeFiscalYear, VolumeRowNo
				FROM	trs.tblPayDtl
				WHERE	PayTypeID IN(8, 28) AND ProcessNo = @ProcessNo AND ProcessID = 28
			) AS V ON V.VolumeFiscalYear = D.VolumeFiscalYear AND V.VolumeRowNo = D.VolumeRowNo 
	WHERE	(D.ProcessID IN (2,25)) AND (D.ProcessNo = 1) AND (D.PayTypeID IN (8, 28)) 
	--AND (D.ChequeDate >= @Date2F) 
	AND (D.ChequeDate <= @Date2)

	SELECT	@PayAmount3 = IsNull(Sum(D.Amount), 0)
	FROM	trs.tblPayDtl AS D
			INNER JOIN
			(
				SELECT	VolumeFiscalYear, VolumeRowNo
				FROM	trs.tblPayDtl
				WHERE	PayTypeID IN(8, 28) AND ProcessNo = @ProcessNo AND ProcessID IN (2, 25)
				EXCEPT  
				SELECT	VolumeFiscalYear, VolumeRowNo
				FROM	trs.tblPayDtl
				WHERE	PayTypeID IN(8, 28) AND ProcessNo = @ProcessNo AND ProcessID = 27
				EXCEPT  
				SELECT	VolumeFiscalYear, VolumeRowNo
				FROM	trs.tblPayDtl
				WHERE	PayTypeID IN(8, 28) AND ProcessNo = @ProcessNo AND ProcessID = 28
			) AS V ON V.VolumeFiscalYear = D.VolumeFiscalYear AND V.VolumeRowNo = D.VolumeRowNo 
	WHERE	(D.ProcessID IN (2,25)) AND (D.ProcessNo = 1) AND (D.PayTypeID IN (8, 28))
	 --AND (D.ChequeDate >= @Date3F) 
	 AND (D.ChequeDate <= @Date3)

	INSERT INTO #tbl_RptTrs_BudgetStats
	SELECT 7, 0, 'اسناد پرداختنی پاس نشده', @PayAmount1, @PayAmount2, @PayAmount3, 0 AS IsSummary
	-- 7.5 Payable loans -------------------------------------------------
	SELECT	@LoanAmount1 = IsNull(Sum(D.InstallmentAmount+D.InstallmentCost), 0)
	FROM	trs.tblLoanDtl AS D
			INNER JOIN
			(
				SELECT	D.ProcessNo, D.FiscalYear, D.SerialNo, D.InstallmentNo 
				FROM	trs.tblLoanDtl D 
				WHERE	(D.ProcessID = 7) 
					AND (D.ProcessNo = @ProcessNo) 
					--AND (D.InstallmentDate >= @Date1F) 
					AND (D.InstallmentDate <= @Date1)
				EXCEPT
				SELECT	D.BaseProcessNo, D.BaseFiscalYear, D.BaseSerialNo, D.InstallmentNo 
				FROM	trs.tblLoanDtl D  
				WHERE	(D.ProcessID = 8) AND (D.ProcessNo = @ProcessNo) 
			) AS T ON   D.ProcessID = 7 AND D.ProcessNo = T.ProcessNo AND D.FiscalYear = T.FiscalYear AND D.SerialNo = T.SerialNo AND D.InstallmentNo = T.InstallmentNo 
	WHERE	(D.ProcessID =7) 
		AND (D.ProcessNo = @ProcessNo)
		--AND (D.InstallmentDate >= @Date1F) 
		AND (D.InstallmentDate <= @Date1)

	SELECT	@LoanAmount2 = IsNull(Sum(D.InstallmentAmount+D.InstallmentCost), 0)
	FROM	trs.tblLoanDtl AS D
			INNER JOIN
			(
				SELECT	D.ProcessNo, D.FiscalYear, D.SerialNo, D.InstallmentNo 
				FROM	trs.tblLoanDtl D 
				WHERE	(D.ProcessID = 7) 
					AND (D.ProcessNo = @ProcessNo)
					--AND (D.InstallmentDate >= @Date2F) 
					AND (D.InstallmentDate <= @Date2)
				EXCEPT
				SELECT	D.BaseProcessNo, D.BaseFiscalYear, D.BaseSerialNo, D.InstallmentNo 
				FROM	trs.tblLoanDtl D  
				WHERE	(D.ProcessID = 8) and (D.ProcessNo = @ProcessNo)
			) AS T ON   D.ProcessID = 7 AND D.ProcessNo = T.ProcessNo AND D.FiscalYear = T.FiscalYear AND D.SerialNo = T.SerialNo AND D.InstallmentNo = T.InstallmentNo 
	WHERE	(D.ProcessID =7) 
		AND (D.ProcessNo = @ProcessNo)
		--AND (D.InstallmentDate >= @Date2F) 
		AND (D.InstallmentDate <= @Date2)

	SELECT	@LoanAmount3 = IsNull(Sum(D.InstallmentAmount+D.InstallmentCost), 0)
	FROM	trs.tblLoanDtl AS D
			INNER JOIN
			(
				SELECT	D.ProcessNo, D.FiscalYear, D.SerialNo, D.InstallmentNo 
				FROM	trs.tblLoanDtl D 
				WHERE	(D.ProcessID = 7) 
					AND (D.ProcessNo = @ProcessNo)
					--AND (D.InstallmentDate >= @Date3F) 
					AND (D.InstallmentDate <= @Date3)
				EXCEPT
				SELECT	D.BaseProcessNo, D.BaseFiscalYear, D.BaseSerialNo, D.InstallmentNo 
				FROM	trs.tblLoanDtl D  
				WHERE	(D.ProcessID = 8) and (D.ProcessNo = @ProcessNo)
			) AS T ON   D.ProcessID = 7 AND D.ProcessNo = T.ProcessNo AND D.FiscalYear = T.FiscalYear AND D.SerialNo = T.SerialNo AND D.InstallmentNo = T.InstallmentNo 
	WHERE	(D.ProcessID =7) 
		AND (D.ProcessNo = @ProcessNo)
		--AND (D.InstallmentDate >= @Date3F) 
		AND (D.InstallmentDate <= @Date3)

	INSERT INTO #tbl_RptTrs_BudgetStats
	SELECT 7.5, 0, 'اقساط مانده وامهای پرداختنی', @LoanAmount1, @LoanAmount2, @LoanAmount3, 0 AS IsSummary
	-- 8- Payable Docs Future --------------------------------------------
	INSERT INTO #tbl_RptTrs_BudgetStats
	SELECT 8, 0, 'پیش بینی حسابهای پرداختنی', @MyPayAmount, @MyPayAmount, @MyPayAmount, 0 AS IsSummary

	-- 9- Total Summary --------------------------------------------------
	INSERT INTO #tbl_RptTrs_BudgetStats
	SELECT 9, 0, 'بودجه',	@CashAmount1 + @RecAmountBank1 + @RecAmountCash1 + @MyRecAmount - @PayAmount1 - @MyPayAmount - @LoanAmount1,
							@CashAmount2 + @RecAmountBank2 + @RecAmountCash2 + @MyRecAmount - @PayAmount2 - @MyPayAmount - @LoanAmount2,
							@CashAmount3 + @RecAmountBank3 + @RecAmountCash3 + @MyRecAmount - @PayAmount3 - @MyPayAmount - @LoanAmount3, 1 AS IsSummary
	-- Result ---------------------------------------------------------------
	SELECT *
	FROM #tbl_RptTrs_BudgetStats
	ORDER BY [Order], AcntCode

	---------------------------------------------------------

	-- Run -----------------------------------------------------
	------------------------------------------------------------
End
GO
