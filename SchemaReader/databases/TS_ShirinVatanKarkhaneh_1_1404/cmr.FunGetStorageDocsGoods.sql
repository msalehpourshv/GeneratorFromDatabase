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
CREATE FUNCTION [cmr].[FunGetStorageDocsGoods]
(
@AcntCode Varchar(20),
@DocDate  Char(10),
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
		Cnf.ConfirmQuantity - ISNULL(Rtn.ConfirmQuantity,0) AS ConfirmQuantity 
From
	(
		Select	TOD.ProcessID , TOD.ProcessNo , TOD.FiscalYear , TOD.SerialNo ,TOD.DocRowNo , 
				RG.ConfirmQuantity,TOD.BaseProcessID , TOD.BaseProcessNo , 
				TOD.BaseFiscalYear , TOD.BaseSerialNo , TOD.BaseDocRowNo
		FROM (
				Select BaseProcessID , BaseProcessNo , BaseFiscalYear , BaseSerialNo , BaseDocRowNo,Sum(GoodsQuantity) ConfirmQuantity
				From inv.tblStorageDocsDtl
				Where ProcessID = 55 AND BaseProcessID > 0 AND
					 (@AcntCode IS NULL   OR AcntCode = @AcntCode) AND  DocDate <= @DocDate AND
					  (DocStep = @DocStep1 OR DocStep = @DocStep2)
				Group BY BaseProcessID , BaseProcessNo , BaseFiscalYear , BaseSerialNo , 
						 BaseDocRowNo
			 ) RG
		INNER JOIN  
			inv.tblStorageDocsDtl TOD
		ON	TOD.BaseProcessID =RG.BaseProcessID AND TOD.BaseProcessNo =RG.BaseProcessNo AND TOD.BaseFiscalYear=RG.BaseFiscalYear AND 
			TOD.BaseSerialNo=RG.BaseSerialNo AND TOD.BaseDocRowNo=RG.BaseDocRowNo
		WHERE (@AcntCode IS NULL   OR TOD.AcntCode = @AcntCode) AND  TOD.DocDate <= @DocDate 
	UNION
		Select	ProcessID , ProcessNo , FiscalYear , SerialNo ,DocRowNo , 
				GoodsQuantity AS ConfirmQuantity,BaseProcessID , BaseProcessNo , 
				BaseFiscalYear , BaseSerialNo , BaseDocRowNo
		FROM inv.tblStorageDocsDtl
		Where ProcessID = 55 AND BaseProcessID = 0 AND
			 (@AcntCode IS NULL   OR AcntCode = @AcntCode) AND  DocDate <= @DocDate AND
			 (DocStep = @DocStep1 OR DocStep = @DocStep2)
	) Cnf
LEFT JOIN 
(
	Select	BaseProcessID , BaseProcessNo , BaseFiscalYear , BaseSerialNo , BaseDocRowNo , 
			Sum(GoodsQuantity) ConfirmQuantity
	From inv.tblStorageDocsDtl 
	Where BaseProcessID = 55  AND (@AcntCode IS NULL   OR AcntCode = @AcntCode)
	Group BY BaseProcessID , BaseProcessNo , BaseFiscalYear , BaseSerialNo , 
			BaseDocRowNo
) Rtn
ON	Cnf.ProcessID = Rtn.BaseProcessID AND Cnf.ProcessNo = Rtn.BaseProcessNo AND 
	Cnf.FiscalYear = Rtn.BaseFiscalYear AND Cnf.SerialNo = Rtn.BaseSerialNo AND 
	Cnf.DocRowNo = Rtn.BaseDocRowNo	
WHERE Cnf.ConfirmQuantity - ISNULL(Rtn.ConfirmQuantity,0)  > 0
)











GO
