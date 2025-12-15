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
Create FUNCTION [cmr].[FunGetBaseInvTempReceiptGoods]
(
@AcntCode Varchar(20),
@DocDate char(20),
@DocStep1 Tinyint,
@DocStep2 Tinyint,
@SerialNo int=NULL,
@FiscalYear SmallInt=NULL
)
RETURNS TABLE 
WITH ENCRYPTION
AS
RETURN 
(
Select	DISTINCT Cnf.BaseProcessID , Cnf.BaseProcessNo , Cnf.BaseFiscalYear , Cnf.BaseSerialNo , Cnf.BaseDocRowNo ,
		Cnf.ConfirmQuantity - ISNULL(Rtn.ConfirmQuantity,0) AS ConfirmQuantity 
		, GoodsID,SubUnitID
		, [inv].[funGetGoodsQuantityFromSubUnit](GoodsID,SubUnitID,Cnf.ConfirmQuantity - ISNULL(Rtn.ConfirmQuantity,0) ) MainConfirmQuantity 
From
	(
		Select BaseProcessID , BaseProcessNo , BaseFiscalYear , BaseSerialNo , BaseDocRowNo,Sum(ConfirmQuantity) ConfirmQuantity
		, GoodsID,SubUnitID
		From inv.tblInvTempReceiptDtl
		Where ProcessID = 170 AND
			 (@AcntCode IS NULL   OR AcntCode = @AcntCode) AND DocDate <= @DocDate AND
			 (DocStep = @DocStep1 OR DocStep  = @DocStep2) AND (@SerialNo IS NULL OR (SerialNo=@SerialNo AND FiscalYear =@FiscalYear))
		Group BY BaseProcessID , BaseProcessNo , BaseFiscalYear , BaseSerialNo , 
				 BaseDocRowNo, GoodsID,SubUnitID

				 
	) Cnf
LEFT JOIN 
(
	Select	BaseProcessID , BaseProcessNo , BaseFiscalYear , BaseSerialNo , BaseDocRowNo , 
			Sum(ConfirmQuantity) ConfirmQuantity
	From inv.tblInvTempReceiptDtl 
	Where BaseProcessID = 170 AND (@AcntCode IS NULL   OR AcntCode = @AcntCode)
	Group BY BaseProcessID , BaseProcessNo , BaseFiscalYear , BaseSerialNo , 
			BaseDocRowNo
) Rtn
ON	Cnf.BaseProcessID = Rtn.BaseProcessID AND Cnf.BaseProcessNo = Rtn.BaseProcessNo AND 
	Cnf.BaseFiscalYear = Rtn.BaseFiscalYear AND Cnf.BaseSerialNo = Rtn.BaseSerialNo AND 
	Cnf.BaseDocRowNo = Rtn.BaseDocRowNo	
WHERE Cnf.ConfirmQuantity - ISNULL(Rtn.ConfirmQuantity,0) > 0
)















GO
