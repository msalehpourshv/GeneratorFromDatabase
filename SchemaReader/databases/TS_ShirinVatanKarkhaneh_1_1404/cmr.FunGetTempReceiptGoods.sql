USE TS_ShirinVatanKarkhaneh_1_1404
GO
SET ANSI_NULLS, QUOTED_IDENTIFIER ON
GO
-- =========== TS-QC:NOTOK ========================
-- Author        : Hadi Sadeghi
-- Create date   : 86/12/04
-- Viewed By	 : 
-- Last Modified : 
-- Description   : 
-- =============================================
CREATE FUNCTION [cmr].[FunGetTempReceiptGoods]
(
	@AcntCode Varchar(20),
	@DocDate  char(10)
)
RETURNS TABLE 
WITH ENCRYPTION
AS
RETURN 
(
SELECT a.*,b.ConfirmQuantity ConfirmQuantity11 from inv.tblInvTempReceiptDtl a
inner join (
Select	Cnf.ProcessID , Cnf.ProcessNo , Cnf.FiscalYear , Cnf.SerialNo , Cnf.DocRowNo 
		,Cnf.ConfirmQuantity - ISNULL(Rtn.ConfirmQuantity,0) AS ConfirmQuantity ,DocDate,AcntCode
From 
	(
		Select ProcessID , ProcessNo , FiscalYear , SerialNo , DocRowNo , ConfirmQuantity ,DocDate,AcntCode
		From inv.tblInvTempReceiptDtl
		Where ProcessID = 170 AND  
			 (@AcntCode IS NULL OR AcntCode = @AcntCode) AND 
			  DocDate <= @DocDate AND DocStep = 2
	) Cnf
	LEFT JOIN 
	(
		Select	BaseProcessID , BaseProcessNo , BaseFiscalYear , BaseSerialNo 
				, BaseDocRowNo , SUM(ConfirmQuantity) ConfirmQuantity
		From inv.tblInvTempReceiptDtl 
		Where BaseProcessID = 170 AND (@AcntCode IS NULL OR AcntCode = @AcntCode)
		Group BY BaseProcessID , BaseProcessNo , BaseFiscalYear , BaseSerialNo , 
				BaseDocRowNo
	) Rtn
	ON	Cnf.ProcessID = Rtn.BaseProcessID AND Cnf.ProcessNo = Rtn.BaseProcessNo AND 
		Cnf.FiscalYear = Rtn.BaseFiscalYear AND Cnf.SerialNo = Rtn.BaseSerialNo AND 
		Cnf.DocRowNo = Rtn.BaseDocRowNo
WHERE Cnf.ConfirmQuantity - ISNULL(Rtn.ConfirmQuantity,0)  > 0) b

	ON	a.ProcessID = b.ProcessID AND a.ProcessNo = b.ProcessNo AND 
		a.FiscalYear = b.FiscalYear AND a.SerialNo = b.SerialNo AND 
		a.DocRowNo = b.DocRowNo
)
GO
