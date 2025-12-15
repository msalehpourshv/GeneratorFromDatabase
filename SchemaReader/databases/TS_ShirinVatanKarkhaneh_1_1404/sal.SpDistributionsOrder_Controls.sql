USE TS_ShirinVatanKarkhaneh_1_1404
GO
SET ANSI_NULLS, QUOTED_IDENTIFIER ON
GO
-- =========== TS-QC:UPDATED ====================
-- Author		 : H.S.R Sadeghi
-- Create date   : 1396/02/28
-- Viewed By	 : 
-- Last Modified : 
-- Description	 : 
-- ==============================================
CREATE PROCEDURE [sal].[SpDistributionsOrder_Controls]
	@ProcessID	Int = 210,
	@SerialNo	Int
WITH ENCRYPTION
As
BEGIN
	Select DISTINCT  BaseDistributionSerialNo,a.BaseProcessID,a.BaseProcessNo,a.BaseFiscalYear,a.BaseSerialNo 
	From inv.tblStorageDocsDtl a 
	INNER JOIN (SELECT * from inv.tblStorageDocsHdr WHERE BaseDistributionProcessID=@ProcessID and BaseDistributionSerialNo<>@SerialNo) b 
	ON a.ProcessID = b.ProcessID and a.FiscalYear = b.FiscalYear and a.ProcessNo = b.ProcessNo and a.SerialNo = b.SerialNo 
	inner join (select * from sal.tblDistributionsDtl WHERE ProcessID = @ProcessID AND SerialNo=@SerialNo) c
	on a.BaseProcessID=c.BaseOrderProcessID and a.BaseProcessNo=c.BaseOrderProcessNo and a.BaseFiscalYear=c.BaseOrderFiscalYear and a.BaseSerialNo=c.BaseOrderSerialNo

 END
GO
