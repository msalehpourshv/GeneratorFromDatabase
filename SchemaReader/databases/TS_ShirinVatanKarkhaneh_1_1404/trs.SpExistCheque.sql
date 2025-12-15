USE TS_ShirinVatanKarkhaneh_1_1404
GO
SET ANSI_NULLS, QUOTED_IDENTIFIER ON
GO
-- ==============================================
-- Author: Sadeghi, Hadi
-- Create Date: (1388/02/1)
-- ==============================================
CREATE PROCEDURE [trs].[SpExistCheque]
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
		WHERE ChequeNo   = @ChequeNo AND
			  PayTypeID  IN (6,26) AND 
			  NOT (ProcessID IN (1,10) AND SerialNo = @SerialNo AND RowNo = @RowNo )
	ELSE
		SELECT Top 1 * FROM  trs.tblPayDtl
		WHERE ChequeNo   = @ChequeNo AND 
			  BankTypeID = @BankTypeID AND
			  AccountNo  = @AccountNo AND
			  PayTypeID  IN (6,26) AND 
			  NOT (ProcessID IN (1,10) AND SerialNo = @SerialNo AND RowNo = @RowNo )
   
END
GO
