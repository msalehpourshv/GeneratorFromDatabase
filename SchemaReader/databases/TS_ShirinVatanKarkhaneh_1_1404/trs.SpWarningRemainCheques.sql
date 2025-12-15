USE TS_ShirinVatanKarkhaneh_1_1404
GO
SET ANSI_NULLS, QUOTED_IDENTIFIER ON
GO
-- =========== TS-QC:NOTOK ====================
-- Author		 : Sadeghi
-- Create date   : 87/04/10
-- Viewed By	 : 
-- Last Modified : 1392/05/21
-- Last Modifier : ZiA
-- Description	 : 
-- ==============================================
CREATE PROCEDURE [trs].[SpWarningRemainCheques] 
WITH ENCRYPTION
AS 

Create Table #tblList
(
	BankCode		VarChar(20) COLLATE Arabic_CS_AS,
	FiscalYear		SmallInt,
	ChequeBookID	SmallInt,
	ChequeNo		BigInt
)
Declare @BankCode			VarChar(20)
Declare @FiscalYear			SmallInt
Declare @ChequeBookID		SmallInt
Declare @ChequeNoStart		bigint
Declare @ChequeNoFinish		bigint

Begin   -----------------  B E G I N   T O   C O D E  ------------------------

	Declare	Cursor_OurBanks  CURSOR For
		SELECT BankCode 
		FROM trs.tblOurBanks 
		WHERE BankState = 3

	-- Read First Record --
	Open  Cursor_OurBanks; 
	Fetch NEXT From Cursor_OurBanks Into @BankCode
	
	While (@@Fetch_Status = 0)
	Begin
	
		-- Insert UnSerialized Cheques to Result --
		Insert	Into #tblList
		Select	BankCode, FiscalYear, ChequeBookID, FromChequeNo
		From	trs.tblBankChequesDtl
		Where	BankCode = @BankCode AND FromChequeNo = ToChequeNo
		
		------- Declare Cursor To Read and UnPack Serialized Cheques --------------
		Declare	Cursor_Cheques CURSOR For
			Select	FiscalYear, ChequeBookID, FromChequeNo, ToChequeNo
			From	trs.tblBankChequesDtl
			Where	BankCode = @BankCode AND FromChequeNo <> ToChequeNo
			Order By FiscalYear, ChequeBookID, FromChequeNo, ToChequeNo
		
		-- Read First Record --
		Open  Cursor_Cheques; 
		Fetch NEXT From Cursor_Cheques Into @FiscalYear, @ChequeBookID, @ChequeNoStart, @ChequeNoFinish;

		While (@@Fetch_Status = 0)
		Begin
			 --+ @ChequeBookID + @ChequeNoStart + @ChequeNoFinish
			While (@ChequeNoStart <= @ChequeNoFinish)
			Begin
				-- Print @ChequeNoStart + ' - '  + @ChequeNoFinish

				Insert Into #tblList
				Values (@BankCode,@FiscalYear, @ChequeBookID, @ChequeNoStart)

				Set @ChequeNoStart = @ChequeNoStart + 1
			End

			Fetch NEXT From Cursor_Cheques Into @FiscalYear, @ChequeBookID, @ChequeNoStart, @ChequeNoFinish;
		End

		Close Cursor_Cheques;
		Deallocate Cursor_Cheques;
	
		Fetch NEXT From Cursor_OurBanks Into @BankCode
	
	End
	
	Close Cursor_OurBanks;
	Deallocate Cursor_OurBanks ;

	-----------------------------------------------
	SELECT B.BankCode, ChequeCount, BankName
	FROM trs.tblOurBanks B, trs.tblOurBanksDtl D, (
		SELECT BankCode,Count(ChequeNo) AS ChequeCount
		FROM 
		(
			Select	BankCode, FiscalYear, ChequeBookID, ChequeNo		-- کل چکها
			From	#tblList
			
			Except				-- چکهای پرداختی
			Select @BankCode as BankCode, ChequeBookFiscalYear, ChequeBookID, ChequeNo
			From   trs.tblPayDtl
			Where  ChequeBookID IN (Select Distinct ChequeBookID From #tblList)
			
			Except				-- چکهای باطله
			Select @BankCode as BankCode, FiscalYear, ChequeBookID, ChequeNo
			From   trs.tblBankVoidChequesDtl
			Where  ChequeBookID In (Select Distinct ChequeBookID From #tblList)
						
		) A
	GROUP BY BankCode) C
	WHERE B.BankCode=C.BankCode AND D.BankCode=C.BankCode AND D.BankCode=B.BankCode AND 
		  ChequeWarningCount >0 AND ChequeCount<=ChequeWarningCount
	  
End
GO
