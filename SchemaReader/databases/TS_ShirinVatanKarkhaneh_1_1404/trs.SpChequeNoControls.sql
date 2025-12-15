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
CREATE PROCEDURE [trs].[SpChequeNoControls]
	@intProcessID		TinyInt,
	@intProcessNo		TinyInt,
	@intFiscalYear	SmallInt,
	@intSerialNo		Int
	WITH ENCRYPTION
AS

BEGIN
	DECLARE @DebitCode	VARCHAR(30),
			@DocDate	CHAR(10),
			@ChequeNo	BIGINT,
			@ChequeBookID SMALLINT,
			@ChequeBookFiscalYear SMALLINT
	
	Declare	Cursor_PayDtl CURSOR For 
	SELECT	DebitCode,ChequeNo,ChequeBookID,ChequeBookFiscalYear,DocDate
	FROM trs.tblPayDtl 
	WHERE ProcessID=@intProcessID AND
		  ProcessNo=@intProcessNo AND
		  FiscalYear=@intFiscalYear AND
		  SerialNo=@intSerialNo 

	Open  Cursor_PayDtl; 

	Fetch NEXT From Cursor_PayDtl Into @DebitCode,@ChequeNo,@ChequeBookID,@ChequeBookFiscalYear,@DocDate

	While (@@Fetch_Status = 0)
		BEGIN
						
			IF (SELECT COUNT(*) FROM trs.tblBankChequesDtl
				WHERE BankCode=@DebitCode AND FiscalYear=@ChequeBookFiscalYear AND ChequeBookID=@ChequeBookID AND 
					  FromChequeNo>=@ChequeNo AND ToChequeNo<=@ChequeNo) = 0
				BEGIN
					
					DECLARE @RN int
					SELECT @RN = ISNULL(MAX(RowNo),0)+1 FROM trs.tblBankChequesDtl
					
					DECLARE @CB int
					SELECT @CB = ISNULL(MAX(ChequeBookID),0)+1 FROM trs.tblBankChequesDtl

					INSERT INTO trs.tblBankChequesDtl
						(BankCode, RowNo, FiscalYear, ChequeBookID,FromChequeNo, ToChequeNo, ChequeDate, DocRowNo)
					VALUES
						(@DebitCode, @RN, @intFiscalYear, @CB, @ChequeNo, @ChequeNo, @DocDate, @RN)
  					 
					UPDATE 	trs.tblPayDtl
					SET  ChequeBookID=B.ChequeBookID  , ChequeBookFiscalYear=B.FiscalYear 
					FROM trs.tblPayDtl P
					INNER JOIN trs.tblBankChequesDtl B
					ON P.ChequeNo=B.FromChequeNo AND P.ChequeNo=B.ToChequeNo AND P.DebitCode=B.BankCode
					WHERE P.ProcessID=@intProcessID AND
						  P.ProcessNo=@intProcessNo AND
						  P.FiscalYear=@intFiscalYear AND
						  P.SerialNo=@intSerialNo AND 
						  P.ChequeNo=@ChequeNo
						  					 
  				END 
			FETCH NEXT From Cursor_PayDtl Into @DebitCode,@ChequeNo,@ChequeBookID,@ChequeBookFiscalYear,@DocDate
			
		END
	Close Cursor_PayDtl;
	Deallocate Cursor_PayDtl; 
END  				 
GO
