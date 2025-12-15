USE TS_ShirinVatanKarkhaneh_1_1404
GO
SET ANSI_NULLS, QUOTED_IDENTIFIER ON
GO
-- =========== TS-QC:NOTOK ========================
-- Author        : Hadi Sadeghi
-- Create date   : 99/07/08
-- Viewed By	 : 
-- Last Modified : 
-- Description   : 
-- ================================================
Create PROCEDURE [sal].[SpOpenCustomerSaleOrder]
	@GoodsID	varchar(20),
	@AcntCode	varchar(20)

WITH ENCRYPTION
AS

BEGIN
	SELECT SerialNo,ProcessID,ProcessNo,FiscalYear,DocRowNo,a.GoodsQuantity-ISNULL(b.GoodsQuantity,0) GoodsQuantity 
	FROM (
			select SerialNo,ProcessID,ProcessNo,FiscalYear,DocRowNo,GoodsQuantity
			from sal.tblSaleOrderDtl 
			where ProcessID=180 and GoodsID = @GoodsID and AcntCode=@AcntCode
		)a 
	Left join(
			select BaseSerialNo,BaseProcessID,BaseProcessNo,BaseFiscalYear,BaseDocRowNo,SUM(GoodsQuantity)GoodsQuantity
			from sal.tblSaleOrderDtl 
			where ProcessID=185 and GoodsID = @GoodsID and AcntCode=@AcntCode
			group by BaseSerialNo,BaseProcessID,BaseProcessNo,BaseFiscalYear,BaseDocRowNo
		) b
	on a.ProcessID=b.BaseProcessID and a.ProcessNo=b.BaseProcessNo and a.FiscalYear=b.BaseFiscalYear and a.SerialNo=b.BaseSerialNo and a.DocRowNo=b.BaseDocRowNo
	LEFT JOIN (
		select BaseSerialNo,BaseProcessID,BaseProcessNo,BaseFiscalYear,BaseDocRowNo,GoodsID 
		from inv.tblStorageDocsDtl 
		where ProcessID=90 AND GoodsID = @GoodsID and AcntCode=@AcntCode
		) c
	on a.ProcessID=c.BaseProcessID and a.ProcessNo=c.BaseProcessNo and a.FiscalYear=c.BaseFiscalYear and a.SerialNo=c.BaseSerialNo and a.DocRowNo=c.BaseDocRowNo
	where a.GoodsQuantity-ISNULL(b.GoodsQuantity,0) >0 and c.GoodsID IS NULL
	
END
GO
