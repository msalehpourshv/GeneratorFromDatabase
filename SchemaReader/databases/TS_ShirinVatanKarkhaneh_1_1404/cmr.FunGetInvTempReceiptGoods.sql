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
Create FUNCTION [cmr].[FunGetInvTempReceiptGoods]
(
	@AcntCode Varchar(20),
	@DocDate  char(10),
	@DocStep1 Tinyint,
	@DocStep2 Tinyint
)
RETURNS TABLE 
WITH ENCRYPTION
AS
RETURN 
(
Select	Cnf.ProcessID , Cnf.ProcessNo , Cnf.FiscalYear , Cnf.SerialNo , Cnf.DocRowNo ,
		Cnf.BaseProcessID , Cnf.BaseProcessNo , Cnf.BaseFiscalYear , Cnf.BaseSerialNo , Cnf.BaseDocRowNo ,
		Cnf.ConfirmQuantity - ISNULL(Rtn.ConfirmQuantity,0) AS ConfirmQuantity ,DocDate,Recognition
		, GoodsID,SubUnitID
		, [inv].[funGetGoodsQuantityFromSubUnit](GoodsID,SubUnitID,Cnf.ConfirmQuantity - ISNULL(Rtn.ConfirmQuantity,0) ) MainConfirmQuantity 
From
	(		
		Select	ProcessID , ProcessNo , FiscalYear , SerialNo ,DocRowNo , 
				SubUnitQuantity AS ConfirmQuantity,BaseProcessID , BaseProcessNo , 
				BaseFiscalYear , BaseSerialNo , BaseDocRowNo,DocDate,Recognition	, GoodsID,SubUnitID
		FROM inv.tblInvTempReceiptDtl
		Where ProcessID = 170 AND 
			 (@AcntCode IS NULL   OR AcntCode = @AcntCode) AND  DocDate <= @DocDate AND
			 ( DocStep = @DocStep1 OR DocStep  = @DocStep2 )  AND Recognition NOT IN (0,4)
	) Cnf
LEFT JOIN 
(
	Select	BaseProcessID , BaseProcessNo , BaseFiscalYear , BaseSerialNo , BaseDocRowNo , 
			Sum(SubUnitQuantity) ConfirmQuantity
	From inv.tblInvTempReceiptDtl 
	Where BaseProcessID = 170 AND (@AcntCode IS NULL   OR AcntCode = @AcntCode)
	Group BY BaseProcessID , BaseProcessNo , BaseFiscalYear , BaseSerialNo , 
			BaseDocRowNo
) Rtn
ON	Cnf.ProcessID = Rtn.BaseProcessID AND Cnf.ProcessNo = Rtn.BaseProcessNo AND 
	Cnf.FiscalYear = Rtn.BaseFiscalYear AND Cnf.SerialNo = Rtn.BaseSerialNo AND 
	Cnf.DocRowNo = Rtn.BaseDocRowNo	
WHERE Cnf.ConfirmQuantity - ISNULL(Rtn.ConfirmQuantity,0)  > 0
)
GO
