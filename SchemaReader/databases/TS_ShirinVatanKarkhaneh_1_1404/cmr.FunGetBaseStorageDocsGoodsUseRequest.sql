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
CREATE FUNCTION [cmr].[FunGetBaseStorageDocsGoodsUseRequest]
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
Select	Cnf.BaseProcessID , Cnf.BaseProcessNo , Cnf.BaseFiscalYear , Cnf.BaseSerialNo , Cnf.BaseDocRowNo ,
		Cnf.ConfirmQuantity - ISNULL(Rtn.ConfirmQuantity,0) AS ConfirmQuantity 
From
	(
		Select BaseProcessID , BaseProcessNo , BaseFiscalYear , BaseSerialNo , BaseDocRowNo,Sum(GoodsQuantity) ConfirmQuantity
		From inv.tblStorageDocsDtl
		Where ProcessID = 230 AND BaseProcessID > 0 AND
			 (@AcntCode IS NULL   OR AcntCode = @AcntCode) AND  DocDate <= @DocDate AND
			 (DocStep = @DocStep1 OR DocStep  = @DocStep2)
		Group BY BaseProcessID , BaseProcessNo , BaseFiscalYear , BaseSerialNo , 
				 BaseDocRowNo
 	UNION
		Select BaseProcessID , BaseProcessNo , BaseFiscalYear , BaseSerialNo , BaseDocRowNo, GoodsQuantity AS ConfirmQuantity
		From inv.tblStorageDocsDtl
		Where ProcessID = 230 AND BaseProcessID = 0 AND
			 (@AcntCode IS NULL   OR AcntCode = @AcntCode) AND  DocDate <= @DocDate AND
			 (DocStep = @DocStep1 OR DocStep  = @DocStep2)

	) Cnf
LEFT JOIN 
(
	Select	BaseProcessID , BaseProcessNo , BaseFiscalYear , BaseSerialNo , BaseDocRowNo , 
			Sum(GoodsQuantity) ConfirmQuantity
	From inv.tblStorageDocsDtl 
	Where BaseProcessID = 230 AND (@AcntCode IS NULL   OR AcntCode = @AcntCode)
	Group BY BaseProcessID , BaseProcessNo , BaseFiscalYear , BaseSerialNo , 
			BaseDocRowNo
) Rtn
ON	Cnf.BaseProcessID = Rtn.BaseProcessID AND Cnf.BaseProcessNo = Rtn.BaseProcessNo AND 
	Cnf.BaseFiscalYear = Rtn.BaseFiscalYear AND Cnf.BaseSerialNo = Rtn.BaseSerialNo AND 
	Cnf.BaseDocRowNo = Rtn.BaseDocRowNo	
WHERE Cnf.ConfirmQuantity - ISNULL(Rtn.ConfirmQuantity,0) > 0
)











GO
