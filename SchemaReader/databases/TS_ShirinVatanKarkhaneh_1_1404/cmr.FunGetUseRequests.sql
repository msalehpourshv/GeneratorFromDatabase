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
CREATE FUNCTION [cmr].[FunGetUseRequests]
(
@AcntCode Varchar(20),
@DocDate  char(10)
)
RETURNS TABLE 
WITH ENCRYPTION
AS
RETURN 
(
	Select	Cnf.ProcessID , Cnf.ProcessNo , Cnf.FiscalYear , Cnf.SerialNo , Cnf.DocRowNo ,
			Cnf.BaseProcessID , Cnf.BaseProcessNo , Cnf.BaseFiscalYear , Cnf.BaseSerialNo , Cnf.BaseDocRowNo ,
			Cnf.ConfirmQuantity - ISNULL(Rtn.ConfirmQuantity,0) AS ConfirmQuantity ,DocDate,AcntCode
	From
		(
			Select	TOD.ProcessID , TOD.ProcessNo , TOD.FiscalYear , TOD.SerialNo ,TOD.DocRowNo , 
					RG.ConfirmQuantity,TOD.BaseProcessID , TOD.BaseProcessNo , 
					TOD.BaseFiscalYear , TOD.BaseSerialNo , TOD.BaseDocRowNo,DocDate,AcntCode
			FROM (
					Select BaseProcessID , BaseProcessNo , BaseFiscalYear , BaseSerialNo , BaseDocRowNo,Sum(GoodsQuantity) ConfirmQuantity
					From inv.tblStoresRequestsDtl
					Where ProcessID = 230 AND  BaseProcessID > 0 AND
					 (@AcntCode IS NULL   OR AcntCode = @AcntCode) AND  DocDate <= @DocDate 
					Group BY BaseProcessID , BaseProcessNo , BaseFiscalYear , BaseSerialNo , 
							 BaseDocRowNo
				 ) RG
			INNER JOIN  
				inv.tblStoresRequestsDtl TOD
			ON	TOD.BaseProcessID =RG.BaseProcessID AND TOD.BaseProcessNo =RG.BaseProcessNo AND TOD.BaseFiscalYear=RG.BaseFiscalYear AND 
				TOD.BaseSerialNo=RG.BaseSerialNo AND TOD.BaseDocRowNo=RG.BaseDocRowNo
			WHERE (@AcntCode IS NULL   OR TOD.AcntCode = @AcntCode) AND  TOD.DocDate <= @DocDate
		UNION
			Select	ProcessID , ProcessNo , FiscalYear , SerialNo ,DocRowNo , 
					ConfirmQuantity,BaseProcessID , BaseProcessNo , 
					BaseFiscalYear , BaseSerialNo , BaseDocRowNo,DocDate,AcntCode
			FROM inv.tblStoresRequestsDtl
			Where ProcessID = 230 AND BaseProcessID = 0 AND
				 (@AcntCode IS NULL   OR AcntCode = @AcntCode) AND  DocDate <= @DocDate 
		) Cnf
	LEFT JOIN 
	(
		Select	BaseProcessID , BaseProcessNo , BaseFiscalYear , BaseSerialNo , BaseDocRowNo , 
				Sum(GoodsQuantity) ConfirmQuantity
		From inv.tblStoresRequestsDtl 
		Where BaseProcessID = 230 AND (@AcntCode IS NULL   OR AcntCode = @AcntCode)
		Group BY BaseProcessID , BaseProcessNo , BaseFiscalYear , BaseSerialNo , 
				BaseDocRowNo
	) Rtn
	ON	Cnf.ProcessID = Rtn.BaseProcessID AND Cnf.ProcessNo = Rtn.BaseProcessNo AND 
		Cnf.FiscalYear = Rtn.BaseFiscalYear AND Cnf.SerialNo = Rtn.BaseSerialNo AND 
		Cnf.DocRowNo = Rtn.BaseDocRowNo
WHERE Cnf.ConfirmQuantity - ISNULL(Rtn.ConfirmQuantity,0)  > 0
)





GO
