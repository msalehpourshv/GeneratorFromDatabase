USE TS_ShirinVatanKarkhaneh_1_1404
GO
SET ANSI_NULLS, QUOTED_IDENTIFIER ON
GO
-- =========== TS-QC:NOTOK ========================
-- Author        : H.Sadeghi
-- Create date   : 1400/06/28
-- Viewed By	 : 
-- Last Modified : 
-- Description   : 
-- ================================================
Create PROCEDURE [sal].[SpVisitorPercentSettings]
	@intProcessID		TinyInt,
	@intProcessNo		TinyInt,
	@intFiscalYear		SmallInt,
	@intSerialNo		Int

WITH ENCRYPTION
AS

BEGIN 
	SELECT SUM(D.VisitorPercent) VisitorPercentD,SUM(D.VisitorPercent2) VisitorPercent2D,H.VisitorPercent,H.VisitorPercent2,H.VisitorCost
	from inv.tblStorageDocsHdr H
	inner join  inv.tblStorageDocsDtl D
	on H.ProcessID=D.ProcessID and H.ProcessNo=D.ProcessNo and H.FiscalYear=D.FiscalYear and H.SerialNo=D.SerialNo
	where H.ProcessID=@intProcessID  AND H.ProcessNo=@intProcessNo AND H.FiscalYear=@intFiscalYear AND H.SerialNo=@intSerialNo
	group by H.VisitorPercent,H.VisitorPercent2,H.VisitorCost
END
GO
