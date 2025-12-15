USE TS_ShirinVatanKarkhaneh_1_1404
GO
SET ANSI_NULLS, QUOTED_IDENTIFIER ON
GO
-- ==============================================
-- Author:		Ahmadnejad, Hossein
-- Create date: 04-24-2007 (1386/02/04)
-- Description:	<Unused Cheques list>
-- ----------------------------------------------
-- لیست برگ چکهای استفاده نشده دسته چکهای یک بانک
-- ----------------------------------------------
-- Last Nodified Date: 05-23-2007 (1386/03/02)
-- Modified By: Ahmadnejad, Hossein
-- ==============================================
Create PROCEDURE [trs].[SpUnusedCheques] 
	@BankCode	VarChar(20),
	@ProcessNo	Int
WITH ENCRYPTION
As

Create Table #tblList
(
	FiscalYear		SmallInt,
	ChequeBookID	SmallInt,
	ChequeNo		BigInt,
	ChequeIsDigital Bit,
	ChequeCryptNo	Varchar(10) collate arabic_cs_as null
)

Declare @FiscalYear			SmallInt
Declare @ChequeBookID		SmallInt
Declare @ChequeNoStart		NVarChar(20)
Declare @ChequeNoFinish		NVarChar(20)
Declare @ChequeIsDigital	Bit
Declare @ChequeCryptNo		NVarChar(20)


Begin   -----------------  B E G I N   T O   C O D E  ------------------------

	-- Insert UnSerialized Cheques to Result --
	Insert	Into #tblList
	Select	FiscalYear, ChequeBookID, FromChequeNo, ChequeIsDigital, ChequeCryptNo
	From	trs.tblBankChequesDtl
	Where	BankCode = @BankCode AND FromChequeNo = ToChequeNo
	
	------- Declare Cursor To Read and UnPack Serialized Cheques --------------
	Declare	Cursor_Cheques CURSOR For
		Select	FiscalYear, ChequeBookID, FromChequeNo, ToChequeNo, ChequeIsDigital, ChequeCryptNo
		From	trs.tblBankChequesDtl
		Where	BankCode = @BankCode AND FromChequeNo <> ToChequeNo
		Order By FiscalYear, ChequeBookID, FromChequeNo, ToChequeNo
	
	-- Read First Record --
	Open  Cursor_Cheques; 
	Fetch NEXT From Cursor_Cheques Into @FiscalYear, @ChequeBookID, @ChequeNoStart, @ChequeNoFinish, @ChequeIsDigital, @ChequeCryptNo;

	While (@@Fetch_Status = 0)
	Begin
		 --+ @ChequeBookID + @ChequeNoStart + @ChequeNoFinish
		While Cast(@ChequeNoStart As BigInt)  <= Cast(@ChequeNoFinish As BigInt)
		Begin
			-- Print @ChequeNoStart + ' - '  + @ChequeNoFinish

			Insert Into #tblList
			Values (@FiscalYear, @ChequeBookID, @ChequeNoStart, @ChequeIsDigital, @ChequeCryptNo)

			Set @ChequeNoStart = Cast(@ChequeNoStart As BigInt) + 1
		End

		Fetch NEXT From Cursor_Cheques Into @FiscalYear, @ChequeBookID, @ChequeNoStart, @ChequeNoFinish, @ChequeIsDigital, @ChequeCryptNo;
	End

	Close Cursor_Cheques;
	Deallocate Cursor_Cheques;
	
	Select	FiscalYear, ChequeBookID, ChequeNo, ChequeIsDigital, ChequeCryptNo	into #tblList2	-- کل چکها
	From	#tblList
	
	--Except				-- چکهای پرداختی
	--Select ChequeBookFiscalYear, ChequeBookID, ChequeNo
	--From	trs.tblPayDtl
	--Where	 ProcessID IN () AND ChequeBookID IN (Select Distinct ChequeBookID From #tblList)
	--Except				-- چکهای باطله
	--Select  FiscalYear, ChequeBookID, ChequeNo
	--From	trs.tblBankVoidChequesDtl
	--Where	ChequeBookID In (Select Distinct ChequeBookID From #tblList)
	--Order By FiscalYear, ChequeBookID, ChequeNo
	
	Except
	(
	SELECT	DISTINCT ChequeBookFiscalYear, ChequeBookID, ChequeNo, ChequeIsDigital, ChequeCryptNo  -- چکهای پرداختی
	FROM	trs.tblPayDtl
	WHERE	PayTypeID IN (7, 8, 18, 28) AND ProcessNo = @ProcessNo AND ChequeBookID IN (SELECT DISTINCT ChequeBookID FROM #tblList)

	EXCEPT  
	SELECT	DISTINCT ChequeBookFiscalYear, ChequeBookID, ChequeNo, ChequeIsDigital, ChequeCryptNo -- چکهای پرداختی برگشتی
	FROM	trs.tblPayDtl P
	WHERE	(PayTypeID IN (7, 8, 18, 28)) AND (ProcessID IN (28, 34))  AND ProcessNo = @ProcessNo AND ChequeBookID IN (SELECT DISTINCT ChequeBookID FROM #tblList)
	AND EventNo = (SELECT TOP 1 EventNo FROM	trs.tblPayDtl WHERE ChequeBookFiscalYear=P.ChequeBookFiscalYear AND ChequeBookID=P.ChequeBookID AND ChequeNo=P.ChequeNo ORDER BY  DocDate DESC,EventNo DESC)
	)
	Except	
	SELECT	DISTINCT FiscalYear, ChequeBookID, ChequeNo, ChequeIsDigital, ChequeCryptNo	-- چکهای باطله
	FROM	trs.tblBankVoidChequesDtl
	--WHERE	ChequeBookID IN (SELECT DISTINCT ChequeBookID FROM #tblList)

	Select	* 	
	from (
	Select	* 	
	, isnull(( select Top 1  ProcessID 
	FROM trs.tblPayDtl
	WHERE 
		  trs.tblPayDtl.ChequeBookID = #tblList2.ChequeBookID AND
		  trs.tblPayDtl.ChequeNo = #tblList2.ChequeNo AND
		  trs.tblPayDtl.FiscalYear = #tblList2.FiscalYear
		  order by DocDate Desc 
	),0) ProcessID
	From	#tblList2 ) a
	where ProcessID in (0,28,34)
	 -- AND ProcessNo = @ProcessNo 
	order by ChequeNo
End

--[trs].[SpUnusedCheques] 3
GO
