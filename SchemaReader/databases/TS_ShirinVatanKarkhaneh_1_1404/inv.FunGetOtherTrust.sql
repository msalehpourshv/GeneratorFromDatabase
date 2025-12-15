USE TS_ShirinVatanKarkhaneh_1_1404
GO
SET ANSI_NULLS, QUOTED_IDENTIFIER ON
GO
-- =========== TS-QC:NOTOK ========================
-- Author        : Hadi Sadeghi
-- Create date   : 87/11/24
-- Viewed By	 : 
-- Last Modified : 
-- Description   : 
-- =============================================
Create FUNCTION [inv].[FunGetOtherTrust]
(
@AcntCode Varchar(20),
@DocDate  char(10)
)
RETURNS TABLE 
WITH ENCRYPTION
AS
RETURN 
(
	Select	Cnf.ProcessID , Cnf.ProcessNo , Cnf.FiscalYear , Cnf.SerialNo,Cnf.DocRowNo,
			Cnf.GoodsQuantity - ISNULL(Rtn.GoodsQuantity,0) ConfirmQuantity
	From
		(
			Select	ProcessID ,ProcessNo , FiscalYear , SerialNo , 
					DocRowNo , GoodsQuantity, GoodsID
			From inv.tblStorageDocsDtl 
			Where ProcessID = 136 AND (@AcntCode IS NULL OR AcntCode = @AcntCode) AND 
				  DocDate <= @DocDate AND (DocStep in ( 2,3) OR EnterKind = 0)
				  --EnterKind = 0 برای انتقالی های سال گذشته
				  --DocStep in ( 2,3)   برای اسنادی که تعدادی یا ریالی ثبت شده است
		) Cnf
	LEFT JOIN 
	(
		Select	BaseProcessID , BaseProcessNo , BaseFiscalYear , BaseSerialNo , 
				BaseDocRowNo , Sum(GoodsQuantity) GoodsQuantity, GoodsID
		From inv.tblStorageDocsDtl 
		Where BaseProcessID = 136 AND (@AcntCode IS NULL OR AcntCode = @AcntCode)
		Group BY BaseProcessID , BaseProcessNo , BaseFiscalYear , 
				 BaseSerialNo , BaseDocRowNo, GoodsID
	) Rtn
	ON	Cnf.ProcessID = Rtn.BaseProcessID AND Cnf.ProcessNo = Rtn.BaseProcessNo AND 
		Cnf.FiscalYear = Rtn.BaseFiscalYear AND Cnf.SerialNo = Rtn.BaseSerialNo AND 
		Cnf.DocRowNo = Rtn.BaseDocRowNo AND Cnf.GoodsID = Rtn.GoodsID	
) 
GO
