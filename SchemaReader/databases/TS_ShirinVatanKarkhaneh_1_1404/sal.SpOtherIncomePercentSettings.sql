USE TS_ShirinVatanKarkhaneh_1_1404
GO
SET ANSI_NULLS, QUOTED_IDENTIFIER ON
GO
-- =========== TS-QC:NOTOK ========================
-- Author        : H.Sadeghi
-- Create date   : 1400/07/19
-- Viewed By	 : 
-- Last Modified : 
-- Description   : 
-- ================================================
Create PROCEDURE [sal].[SpOtherIncomePercentSettings]
	@intProcessID		TinyInt,
	@intProcessNo		TinyInt,
	@intFiscalYear		SmallInt,
	@intSerialNo		Int

WITH ENCRYPTION
AS

BEGIN 
IF @intProcessID = 180 OR @intProcessID=185
	SELECT SUM(D.OtherIncomePerentDtl+OtherIncomeDtl) OtherIncomePerentD,CASE WHEN H.ProcessID=90 THEN H.OtherIncome ELSE H.OtherCost END OtherIncome
	from sal.tblSaleOrderHdr H
	inner join  sal.tblSaleOrderDtl D
	on H.ProcessID=D.ProcessID and H.ProcessNo=D.ProcessNo and H.FiscalYear=D.FiscalYear and H.SerialNo=D.SerialNo
	where H.ProcessID=@intProcessID  AND H.ProcessNo=@intProcessNo AND H.FiscalYear=@intFiscalYear AND H.SerialNo=@intSerialNo
	group by H.OtherIncome,H.OtherCost,H.ProcessID

ELSE
	SELECT SUM(D.OtherIncomePerentDtl+OtherIncomeDtl) OtherIncomePerentD,CASE WHEN H.ProcessID=90 THEN H.OtherIncome ELSE H.OtherCost END OtherIncome
	from inv.tblStorageDocsHdr H
	inner join  inv.tblStorageDocsDtl D
	on H.ProcessID=D.ProcessID and H.ProcessNo=D.ProcessNo and H.FiscalYear=D.FiscalYear and H.SerialNo=D.SerialNo
	where H.ProcessID=@intProcessID  AND H.ProcessNo=@intProcessNo AND H.FiscalYear=@intFiscalYear AND H.SerialNo=@intSerialNo
	group by H.OtherIncome,H.OtherCost,H.ProcessID
END
GO
