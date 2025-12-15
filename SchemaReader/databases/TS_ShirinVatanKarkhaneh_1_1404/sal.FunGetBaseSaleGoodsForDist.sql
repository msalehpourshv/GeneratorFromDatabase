USE TS_ShirinVatanKarkhaneh_1_1404
GO
SET ANSI_NULLS, QUOTED_IDENTIFIER ON
GO
CREATE FUNCTION [sal].[FunGetBaseSaleGoodsForDist]
(
@AcntCodeFrom Varchar(20),
@AcntCodeTo Varchar(20),
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
			Where ProcessID = 90 AND BaseProcessID > 0 AND
				 LEFT(AcntCode,LEN(@AcntCodeFrom)) >= @AcntCodeFrom AND LEFT(AcntCode,LEN(@AcntCodeFrom)) <= @AcntCodeTo --AND DocDate <= @DocDate 
			Group BY BaseProcessID , BaseProcessNo , BaseFiscalYear , BaseSerialNo , 
					 BaseDocRowNo
		UNION
			Select BaseProcessID , BaseProcessNo , BaseFiscalYear , BaseSerialNo , BaseDocRowNo,GoodsQuantity AS ConfirmQuantity
			From inv.tblStorageDocsDtl
			Where ProcessID = 90 AND BaseProcessID = 0 AND
				 LEFT(AcntCode,LEN(@AcntCodeFrom)) >= @AcntCodeFrom AND LEFT(AcntCode,LEN(@AcntCodeFrom)) <= @AcntCodeTo --AND  DocDate <= @DocDate 		 
		) Cnf
	LEFT JOIN 
	(
		Select	BaseProcessID , BaseProcessNo , BaseFiscalYear , BaseSerialNo , BaseDocRowNo , 
				Sum(GoodsQuantity) ConfirmQuantity
		From inv.tblStorageDocsDtl 
		Where BaseProcessID = 90 AND  LEFT(AcntCode,LEN(@AcntCodeFrom)) >= @AcntCodeFrom AND LEFT(AcntCode,LEN(@AcntCodeFrom)) <= @AcntCodeTo
		Group BY BaseProcessID , BaseProcessNo , BaseFiscalYear , BaseSerialNo , 
				BaseDocRowNo
	) Rtn
	ON	Cnf.BaseProcessID = Rtn.BaseProcessID AND Cnf.BaseProcessNo = Rtn.BaseProcessNo AND 
		Cnf.BaseFiscalYear = Rtn.BaseFiscalYear AND Cnf.BaseSerialNo = Rtn.BaseSerialNo AND 
		Cnf.BaseDocRowNo = Rtn.BaseDocRowNo	
	WHERE Cnf.ConfirmQuantity - ISNULL(Rtn.ConfirmQuantity,0) > 0
	)
GO
