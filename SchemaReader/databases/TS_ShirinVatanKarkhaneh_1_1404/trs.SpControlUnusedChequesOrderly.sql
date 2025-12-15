USE TS_ShirinVatanKarkhaneh_1_1404
GO
SET ANSI_NULLS, QUOTED_IDENTIFIER ON
GO
-- ==============================================
-- Author:		Hadi Sadeghi
-- Create date: 1390/03/24
-- Description:	
-- ----------------------------------------------
-- کنترل برگه چکهای دسته چک به صورت منظم
-- ----------------------------------------------
-- ==============================================
CREATE PROCEDURE [trs].[SpControlUnusedChequesOrderly] 
	@BankCode		VarChar(20),
	@ChequeNo		BigInt
WITH ENCRYPTION
As

Create Table #tblList
(
	FiscalYear		SmallInt,
	ChequeBookID	SmallInt,
	ChequeNo		BigInt
)

Declare @FiscalYear			SmallInt
Declare @ChequeBookID		SmallInt
Declare @ChequeNoStart		BigInt
Declare @ChequeNoFinish		BigInt

Begin

	Declare	Cursor_Cheques CURSOR For
		Select	FiscalYear, ChequeBookID, FromChequeNo, ToChequeNo
		From	trs.tblBankChequesDtl
		Where	BankCode = @BankCode AND FromChequeNo <> ToChequeNo AND 
				FromChequeNo <= @ChequeNo AND ToChequeNo >= @ChequeNo
		Order By FiscalYear, ChequeBookID, FromChequeNo, ToChequeNo
	
	Open  Cursor_Cheques; 
	Fetch NEXT From Cursor_Cheques Into @FiscalYear, @ChequeBookID, @ChequeNoStart, @ChequeNoFinish;

	While (@@Fetch_Status = 0)
	Begin

		While @ChequeNoStart  <= @ChequeNoFinish
		Begin

			Insert Into #tblList
			Values (@FiscalYear, @ChequeBookID, @ChequeNoStart)

			Set @ChequeNoStart = @ChequeNoStart + 1
		End

		Fetch NEXT From Cursor_Cheques Into @FiscalYear, @ChequeBookID, @ChequeNoStart, @ChequeNoFinish;
	End

	Close Cursor_Cheques;
	Deallocate Cursor_Cheques;
	
	DECLARE @TopChequeNo BIGINT
	SET @TopChequeNo = 0
	
	SELECT TOP 1 @TopChequeNo = ChequeNo FROM (
	Select	FiscalYear, ChequeBookID, ChequeNo		-- کل چکها
	From	#tblList
	Except
	(
	SELECT	DISTINCT ChequeBookFiscalYear, ChequeBookID, ChequeNo  -- چکهای پرداختی
	FROM	trs.tblPayDtl
	WHERE	PayTypeID IN (7, 8, 18, 28) AND ChequeBookID IN (SELECT DISTINCT ChequeBookID FROM #tblList)
	EXCEPT  
	SELECT	DISTINCT ChequeBookFiscalYear, ChequeBookID, ChequeNo  -- چکهای پرداختی برگشتی
	FROM	trs.tblPayDtl
	WHERE	(PayTypeID IN (7, 8, 18, 28)) AND (ProcessID IN (28, 34)) AND ChequeBookID IN (SELECT DISTINCT ChequeBookID FROM #tblList)
	)
	Except	
	SELECT	DISTINCT FiscalYear, ChequeBookID, ChequeNo	-- چکهای باطله
	FROM	trs.tblBankVoidChequesDtl
	) A	WHERE	ChequeNo < @ChequeNo
	ORDER BY ChequeNo

	SELECT @TopChequeNo
	
End










GO
