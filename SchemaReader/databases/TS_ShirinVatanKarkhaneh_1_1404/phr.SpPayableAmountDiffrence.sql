USE TS_ShirinVatanKarkhaneh_1_1404
GO
SET ANSI_NULLS, QUOTED_IDENTIFIER ON
GO
-- =========== TS-QC:NOTOK =====================
-- Author        : Reza NP
-- Create date   : 1392/07/21
-- Viewed By	 : 
-- Last Modified : 
-- Description   : 
-- =============================================
CREATE  PROCEDURE [phr].[SpPayableAmountDiffrence]
	@SerialNo	int,
	@FiscalYear	int,
	@IsReturn BIT
	
WITH ENCRYPTION

AS

BEGIN
	
	DECLARE @Amount AS FLOAT
	SET @Amount =0

	SELECT @Amount=isnull(SUM(A.PayedAmount + A.DiscountAmount),0)
			 FROM   phr.tblCashBoxAtm A
				WHERE A.ReciptionSerialNo=@SerialNo 
				AND A.ReciptionFiscalYear=@FiscalYear
	
		--SELECT @Amount=isnull(SUM(A.PayedAmount + A.DiscountAmount),0)
		--	 FROM   phr.tblCashBoxAtm A
		--	WHERE A.ReciptionSerialNo=@SerialNo 
		--	AND A.ReciptionFiscalYear=@FiscalYear
		

		UPDATE phr.tblReciptionHdr
		  SET PayableAmountDiffrence=@Amount
		  WHERE ProcessID=93 AND ProcessNo=1 
		  AND FiscalYear=@FiscalYear AND SerialNo=@SerialNo
		


END
GO
