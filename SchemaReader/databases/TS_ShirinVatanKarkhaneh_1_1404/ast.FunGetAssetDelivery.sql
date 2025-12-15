USE TS_ShirinVatanKarkhaneh_1_1404
GO
SET ANSI_NULLS, QUOTED_IDENTIFIER ON
GO
-- =========== TS-QC:NOTOK ========================
-- Author        : Hadi Sadeghi
-- Create date   : 87/09/29
-- Viewed By	 : 
-- Last Modified : 
-- Description   : 
-- =============================================
Create FUNCTION [ast].[FunGetAssetDelivery]
(
@AcntCode Varchar(20),
@DocDate  char(10),
@SerialNo Int,
@FiscalYear SmallInt
)
RETURNS TABLE 
WITH ENCRYPTION
AS
RETURN 
(
	Select	Cnf.ProcessID , Cnf.ProcessNo , Cnf.FiscalYear , Cnf.SerialNo,Cnf.DocRowNo,
			Cnf.GoodsQuantity - ISNULL(Rtn.GoodsQuantity,0) ConfirmQuantity,Cnf.GoodsID
	From
		(
			Select	ProcessID ,ProcessNo , FiscalYear , SerialNo , 
					DocRowNo , GoodsQuantity,GoodsID
			From inv.tblStorageDocsDtl 
			Where ProcessID = 250 AND (@AcntCode IS NULL OR AcntCode = @AcntCode) AND 
				  DocDate <= @DocDate AND DocStep in (0,2,3) AND 
				 (@SerialNo IS NULL OR (SerialNo=@SerialNo AND FiscalYear =@FiscalYear))
		) Cnf
	LEFT JOIN 
	(
		Select	BaseProcessID , BaseProcessNo , BaseFiscalYear , BaseSerialNo , 
				BaseDocRowNo , Sum(GoodsQuantity) GoodsQuantity,GoodsID
		From inv.tblStorageDocsDtl 
		Where BaseProcessID = 250 AND (@AcntCode IS NULL OR AcntCode = @AcntCode) AND 
			 (@SerialNo IS NULL OR (SerialNo=@SerialNo AND FiscalYear =@FiscalYear))
		Group BY BaseProcessID , BaseProcessNo , BaseFiscalYear , 
				 BaseSerialNo , BaseDocRowNo,GoodsID
	) Rtn
	ON	Cnf.ProcessID = Rtn.BaseProcessID AND Cnf.ProcessNo = Rtn.BaseProcessNo AND 
		Cnf.FiscalYear = Rtn.BaseFiscalYear AND Cnf.SerialNo = Rtn.BaseSerialNo AND 
		Cnf.DocRowNo = Rtn.BaseDocRowNo
)


GO
