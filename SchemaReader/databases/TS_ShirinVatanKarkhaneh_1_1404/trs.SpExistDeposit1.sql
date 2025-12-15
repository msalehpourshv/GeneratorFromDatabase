USE TS_ShirinVatanKarkhaneh_1_1404
GO
SET ANSI_NULLS, QUOTED_IDENTIFIER ON
GO
-- ==============================================
-- Author: Sadeghi, Hadi
-- Create Date: (1391/07/15)
-- ==============================================
CREATE PROCEDURE [trs].[SpExistDeposit1]
	@BankTypeID	VarChar(20),
	@ChequeNo	bigint,
	@SerialNo	Int,
	@RowNo		Int
	
WITH ENCRYPTION
AS

BEGIN

	IF @BankTypeID = ''
		SELECT Top 1 * FROM  trs.tblPayDtl
		WHERE ChequeNo   = @ChequeNo AND
			  PayTypeID  IN (3) AND 
			  NOT (ProcessID IN (1,3) AND SerialNo = @SerialNo AND RowNo = @RowNo )
	ELSE
		SELECT Top 1 * FROM  trs.tblPayDtl
		WHERE ChequeNo   = @ChequeNo AND 
			  BankTypeID = @BankTypeID AND
			  PayTypeID  IN (3) AND 
			  NOT (ProcessID IN (1,3) AND SerialNo = @SerialNo AND RowNo = @RowNo )
   
END
GO
