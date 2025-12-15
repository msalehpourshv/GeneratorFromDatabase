USE TS_ShirinVatanKarkhaneh_1_1404
GO
SET ANSI_NULLS, QUOTED_IDENTIFIER ON
GO
-- =========== TS-QC:UPDATED ====================
-- Author		 : TakroSystem\jafari
-- Create date   : 1388/01/05
-- Viewed By	 : 
-- Last Modified : 1392/01/16
-- Description	 : Pay Transfer Docs
-- ----------------------------------------------
--  ����� ����� ������ ��� ������
-- ==============================================
CREATE PROCEDURE trs.SpTransferPayDirection
WITH ENCRYPTION
AS


BEGIN

	SET NOCOUNT ON;

select a.*
from trs.tblPayDtl  a
inner join (
select ProcessID,ProcessNo,FiscalYear,SerialNo from trs.tblPayDtl where ProcessID=41 
except
select BaseProcessID,BaseProcessNo,BaseFiscalYear,BaseSerialNo from trs.tblPayHdr where BaseProcessID=41
) b 
on a.ProcessID=b.ProcessID and a.ProcessNo=b.ProcessNo and a.FiscalYear=b.FiscalYear and a.SerialNo=b.SerialNo

where a.ProcessID=41 
End
GO
