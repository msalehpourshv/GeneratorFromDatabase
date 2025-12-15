USE TS_ShirinVatanKarkhaneh_1_1404
GO
SET ANSI_NULLS, QUOTED_IDENTIFIER ON
GO
-- =========== TS-QC:NOTOK ========================
-- Author        : Hadi Sadeghi
-- Create date   : 87/09/25
-- Viewed By	 : 
-- Last Modified : 
-- Description   : 
-- =============================================
CREATE FUNCTION [ast].[FunGetBaseStorageDocsGoodsAssetDelivery]
(
@AcntCode Varchar(20),
@DocDate  char(10)
)
RETURNS TABLE 
WITH ENCRYPTION
AS
RETURN 
(
Select	Cnf.BaseProcessID , Cnf.BaseProcessNo , Cnf.BaseFiscalYear , Cnf.BaseSerialNo , Cnf.BaseDocRowNo ,
		Cnf.ConfirmQuantity - ISNULL(Rtn.ConfirmQuantity,0) AS ConfirmQuantity 
From
	(
		Select BaseProcessID , BaseProcessNo , BaseFiscalYear , BaseSerialNo , BaseDocRowNo,Sum(GoodsQuantity) ConfirmQuantity
		From inv.tblStorageDocsDtl
		Where ProcessID = 250 AND BaseProcessID > 0 AND
			 (@AcntCode IS NULL   OR AcntCode = @AcntCode) AND  DocDate <= @DocDate
		Group BY BaseProcessID , BaseProcessNo , BaseFiscalYear , BaseSerialNo , 
				 BaseDocRowNo
	UNION
		Select BaseProcessID , BaseProcessNo , BaseFiscalYear , BaseSerialNo , BaseDocRowNo, GoodsQuantity AS ConfirmQuantity
		From inv.tblStorageDocsDtl
		Where ProcessID = 250 AND BaseProcessID = 0 AND
			 (@AcntCode IS NULL   OR AcntCode = @AcntCode) AND  DocDate <= @DocDate
	) Cnf
LEFT JOIN 
(
	Select	BaseProcessID , BaseProcessNo , BaseFiscalYear , BaseSerialNo , BaseDocRowNo , 
			Sum(GoodsQuantity) ConfirmQuantity
	From inv.tblStorageDocsDtl 
	Where BaseProcessID = 250 AND (@AcntCode IS NULL   OR AcntCode = @AcntCode)
	Group BY BaseProcessID , BaseProcessNo , BaseFiscalYear , BaseSerialNo , 
			BaseDocRowNo
) Rtn
ON	Cnf.BaseProcessID = Rtn.BaseProcessID AND Cnf.BaseProcessNo = Rtn.BaseProcessNo AND 
	Cnf.BaseFiscalYear = Rtn.BaseFiscalYear AND Cnf.BaseSerialNo = Rtn.BaseSerialNo AND 
	Cnf.BaseDocRowNo = Rtn.BaseDocRowNo	
WHERE Cnf.ConfirmQuantity - ISNULL(Rtn.ConfirmQuantity,0) > 0
)













GO
