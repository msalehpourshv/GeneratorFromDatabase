USE TS_ShirinVatanKarkhaneh_1_1404
GO
SET ANSI_NULLS, QUOTED_IDENTIFIER ON
GO

CREATE PROCEDURE [sal].[SpSetSoldOrder]
WITH ENCRYPTION
AS 
BEGIN
	update sal.tblSaleOrderHdr
	set IsSold  = 'True'
	from sal.tblSaleOrderHdr a
	inner join inv.tblStorageDocsDtl b 
	on a.ProcessID=b.BaseProcessID
	and a.ProcessNo=b.BaseProcessNo
	and a.FiscalYear=b.BaseFiscalYear
	and a.SerialNo=b.BaseSerialNo
	WHERE a.ProcessID=180 and 
	      IsSold='False'


	update sal.tblSaleOrderHdr
	set IsSold  = 'False'
	FROM sal.tblSaleOrderHdr a
	Left join inv.tblStorageDocsDtl b 
	on a.ProcessID=b.BaseProcessID
	and a.ProcessNo=b.BaseProcessNo
	and a.FiscalYear=b.BaseFiscalYear
	and a.SerialNo=b.BaseSerialNo
	WHERE a.ProcessID=180 and 
		  IsSold='True' and 
		  b.SerialNo IS NULL 
END
GO
