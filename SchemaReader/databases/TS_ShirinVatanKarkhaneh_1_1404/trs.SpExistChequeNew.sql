USE TS_ShirinVatanKarkhaneh_1_1404
GO
SET ANSI_NULLS, QUOTED_IDENTIFIER ON
GO
-- ==============================================
-- Author: Jafari
-- Create Date: (1400/08/15)
-- ==============================================
CREATE PROCEDURE trs.SpExistChequeNew
	@BankTypeID	VarChar(20),
	@ChequeNo	DECIMAL(28,9),
	@AccountNo	VarChar(20),
	@SerialNo	Int,
	@RowNo		Int
	
WITH ENCRYPTION
AS

BEGIN

	IF @BankTypeID = ''
		SELECT Top 1 * FROM  trs.tblPayDtl
		WHERE ChequeNoNew   = @ChequeNo AND
			  PayTypeID  IN (6,26) AND 
			  NOT (ProcessID IN (1,10) AND SerialNo = @SerialNo AND RowNo = @RowNo )
	ELSE
		SELECT Top 1 * FROM  trs.tblPayDtl
		WHERE ChequeNoNew   = @ChequeNo AND 
			  BankTypeID = @BankTypeID AND
			  AccountNo  = @AccountNo AND
			  PayTypeID  IN (6,26) AND 
			  NOT (ProcessID IN (1,10) AND SerialNo = @SerialNo AND RowNo = @RowNo )
   
END
GO
