USE TS_ShirinVatanKarkhaneh_1_1404
GO
SET ANSI_NULLS, QUOTED_IDENTIFIER ON
GO
-- =========== TS-QC:NOTOK ========================
-- Author        : Hadi Sadeghi
-- Create date   : 1403/05/15
-- Viewed By	 : 
-- Last Modified : 
-- Description   : 
-- =============================================
Create PROCEDURE sal.spCheckPreSaleToSaleOrder 
	 @PresaleProcessNo	as int,
	 @PresaleFiscalYear as int,
	 @PresaleSerialNo	as bigint,
	 @SaleOrderProcessNo as int,
	 @SaleOrderFiscalYear as int,
	 @SaleOrderSerialNo	as bigint

WITH ENCRYPTION
AS
BEGIN
SET NOCOUNT ON;
---------------------------------------------

		
	Select	Cnf.ProcessID , Cnf.ProcessNo , Cnf.FiscalYear , Cnf.SerialNo , Cnf.DocRowNo 
			,Cnf.ConfirmQuantity - ISNULL(Rtn.ConfirmQuantity,0)  AS GoodsQuantity ,DocDate,AcntCode,Cnf.GoodsID
	From 
		(
			Select ProcessID , ProcessNo , FiscalYear , SerialNo , DocRowNo ,GoodsQuantity ConfirmQuantity  ,DocDate,AcntCode,GoodsID
			From inv.tblPreSaleDtl
			Where ProcessID=240   AND ProcessNo=@PresaleProcessNo AND 
					FiscalYear=@PresaleFiscalYear AND SerialNo=@PresaleSerialNo 


		) Cnf
		LEFT JOIN 
		(
			Select	BaseProcessID , BaseProcessNo , BaseFiscalYear , BaseSerialNo 
					, BaseDocRowNo , SUM(GoodsQuantity) ConfirmQuantity,GoodsID
			From sal.tblSaleOrderDtl 
			Where BaseProcessID = 240 AND BaseProcessNo=@PresaleProcessNo AND 
					BaseFiscalYear=@PresaleFiscalYear AND BaseSerialNo=@PresaleSerialNo AND
					not( ProcessNo=@SaleOrderProcessNo AND 
					FiscalYear=@SaleOrderFiscalYear AND SerialNo=@SaleOrderSerialNo)
			Group BY BaseProcessID , BaseProcessNo , BaseFiscalYear , BaseSerialNo , BaseDocRowNo,GoodsID
		) Rtn
		ON	Cnf.ProcessID = Rtn.BaseProcessID AND Cnf.ProcessNo = Rtn.BaseProcessNo AND 
			Cnf.FiscalYear = Rtn.BaseFiscalYear AND Cnf.SerialNo = Rtn.BaseSerialNo AND 
			Cnf.DocRowNo = Rtn.BaseDocRowNo AND Cnf.GoodsID = Rtn.GoodsID
	where Cnf.ConfirmQuantity - ISNULL(Rtn.ConfirmQuantity,0)>0
END
GO
