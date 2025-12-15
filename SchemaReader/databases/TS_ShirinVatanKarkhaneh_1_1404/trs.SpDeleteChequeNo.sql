USE TS_ShirinVatanKarkhaneh_1_1404
GO
SET ANSI_NULLS, QUOTED_IDENTIFIER ON
GO
-- =========== TS-QC:OK ========================
-- Author        : Hadi Sadeghi
-- Create date   : 91/10/30
-- Viewed By	 : 
-- Last Modified : 
-- Description   : 
-- =============================================
CREATE PROCEDURE [trs].[SpDeleteChequeNo]
	@intProcessID		TinyInt,
	@intProcessNo		TinyInt,
	@intFiscalYear	SmallInt,
	@intSerialNo		Int
	WITH ENCRYPTION
AS

BEGIN
	DECLARE @DebitCode	VARCHAR(30),
			@ChequeNo	BIGINT,
			@ChequeBookID SMALLINT,
			@ChequeBookFiscalYear SMALLINT
	
	Declare	Cursor_PayDtl CURSOR For 
	SELECT	DebitCode,ChequeNo,ChequeBookID,ChequeBookFiscalYear
	FROM trs.tblPayDtl 
	WHERE ProcessID=@intProcessID AND
		  ProcessNo=@intProcessNo AND
		  FiscalYear=@intFiscalYear AND
		  SerialNo=@intSerialNo 

	Open  Cursor_PayDtl; 

	Fetch NEXT From Cursor_PayDtl Into @DebitCode,@ChequeNo,@ChequeBookID,@ChequeBookFiscalYear

	While (@@Fetch_Status = 0)
		BEGIN

			IF (SELECT	COUNT(*)
				FROM trs.tblPayDtl 
				WHERE NOT(ProcessID=@intProcessID AND
						  ProcessNo=@intProcessNo AND
						  FiscalYear=@intFiscalYear AND
						  SerialNo=@intSerialNo) AND
						CreditCode=@DebitCode AND 
						FiscalYear=@ChequeBookFiscalYear AND 
						ChequeBookID=@ChequeBookID AND 
						ChequeNo=@ChequeNo )=0
									
			DELETE FROM trs.tblBankChequesDtl
			WHERE BankCode=@DebitCode AND FiscalYear=@ChequeBookFiscalYear AND ChequeBookID=@ChequeBookID AND 
				  FromChequeNo=@ChequeNo AND ToChequeNo=@ChequeNo

			FETCH NEXT From Cursor_PayDtl Into @DebitCode,@ChequeNo,@ChequeBookID,@ChequeBookFiscalYear
			
		END
	Close Cursor_PayDtl;
	Deallocate Cursor_PayDtl; 
END  				 
GO
