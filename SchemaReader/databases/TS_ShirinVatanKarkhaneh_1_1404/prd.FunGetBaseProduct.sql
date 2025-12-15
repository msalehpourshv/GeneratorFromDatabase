USE TS_ShirinVatanKarkhaneh_1_1404
GO
SET ANSI_NULLS, QUOTED_IDENTIFIER ON
GO
-- =========== TS-QC:NOTOK ========================
-- Author        : Hadi Sadeghi
-- Create date   : 86/02/07
-- Viewed By	 : 
-- Last Modified : 
-- Description   : 
-- =============================================
CREATE FUNCTION [prd].[FunGetBaseProduct]
(
@AcntCode Varchar(20),
@DocDate  char(10),
@DocStep1 Tinyint,
@DocStep2 Tinyint,
@ProcessNo as TINYINT
)
RETURNS TABLE 
WITH ENCRYPTION
AS
RETURN 
(
Select	Cnf.BaseProcessID , Cnf.BaseProcessNo , Cnf.BaseFiscalYear , Cnf.BaseSerialNo , Cnf.BaseDocRowNo ,
		Cnf.ConfirmQuantity - ISNULL(Rtn.ConfirmQuantity,0) AS ConfirmQuantity ,AcntCode
From
	(
		Select	TOD.BaseProcessID , TOD.BaseProcessNo , TOD.BaseFiscalYear , TOD.BaseSerialNo ,TOD.BaseDocRowNo , 
			RG.ConfirmQuantity,AcntCode
		FROM (
				Select BaseProcessID , BaseProcessNo , BaseFiscalYear , BaseSerialNo , BaseDocRowNo,Sum(GoodsQuantity) ConfirmQuantity
				From inv.tblStorageDocsDtl
				Where ProcessID = 80 AND ProcessNo=@ProcessNo AND BaseProcessID > 0 AND 
					 (@AcntCode IS NULL   OR AcntCode = @AcntCode) AND  --DocDate <= @DocDate AND
					 (DocStep = 0 OR DocStep = @DocStep1 OR DocStep  = @DocStep2)
				Group BY BaseProcessID , BaseProcessNo , BaseFiscalYear , BaseSerialNo , 
						 BaseDocRowNo
			) RG
		INNER JOIN  
			inv.tblStorageDocsDtl TOD
		ON	TOD.BaseProcessID =RG.BaseProcessID AND TOD.BaseProcessNo =RG.BaseProcessNo AND TOD.BaseFiscalYear=RG.BaseFiscalYear AND 
			TOD.BaseSerialNo=RG.BaseSerialNo AND TOD.BaseDocRowNo=RG.BaseDocRowNo
		WHERE (@AcntCode IS NULL   OR TOD.AcntCode = @AcntCode) --AND  TOD.DocDate <= @DocDate

	UNION
		Select BaseProcessID , BaseProcessNo , BaseFiscalYear , BaseSerialNo , BaseDocRowNo,GoodsQuantity AS ConfirmQuantity,AcntCode
		From inv.tblStorageDocsDtl
		Where ProcessID = 80 AND ProcessNo=@ProcessNo AND BaseProcessID = 0 AND
			 (@AcntCode IS NULL   OR AcntCode = @AcntCode) AND  --DocDate <= @DocDate AND
			 (DocStep = 0 OR DocStep = @DocStep1 OR DocStep  = @DocStep2)
	) Cnf
LEFT JOIN 
(
	Select	BaseProcessID , BaseProcessNo , BaseFiscalYear , BaseSerialNo , BaseDocRowNo , 
			Sum(GoodsQuantity) ConfirmQuantity
	From inv.tblStorageDocsDtl 
	Where BaseProcessID = 85 AND ProcessNo=@ProcessNo AND (@AcntCode IS NULL   OR AcntCode = @AcntCode)
	Group BY BaseProcessID , BaseProcessNo , BaseFiscalYear , BaseSerialNo , 
			BaseDocRowNo
) Rtn
ON	Cnf.BaseProcessID = Rtn.BaseProcessID AND Cnf.BaseProcessNo = Rtn.BaseProcessNo AND 
	Cnf.BaseFiscalYear = Rtn.BaseFiscalYear AND Cnf.BaseSerialNo = Rtn.BaseSerialNo AND 
	Cnf.BaseDocRowNo = Rtn.BaseDocRowNo	
WHERE Cnf.ConfirmQuantity - ISNULL(Rtn.ConfirmQuantity,0) > 0
)
GO
