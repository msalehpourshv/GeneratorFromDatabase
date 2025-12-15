USE TS_ShirinVatanKarkhaneh_1_1404
GO
SET ANSI_NULLS, QUOTED_IDENTIFIER ON
GO
-- =============================================
-- Author:		<TAKRO SYSTEM, Jafari>
-- Create date: <1397/01/19>
-- Description:	بروز رسانی مبدا ها در یک فیلد
-- =============================================
Create   TRIGGER [trs].[trgUpdatePayHdrBase]
   ON  trs.tblPayHdr
   WITH ENCRYPTION
   After Insert,
    Update
AS 
BEGIN
	SET NOCOUNT ON;
  
   Update trs.tblPayHdr  
					Set
					 PayID= lTrim(str(a.ProcessID))+'@'+lTrim(str(a.ProcessNo))+'@'+lTrim(str(a.FiscalYear))+'@'+lTrim(str(a.SerialNo))
					, BaseID= lTrim(str(a.BaseProcessID))+'@'+lTrim(str(a.BaseProcessNo))+'@'+lTrim(str(a.BaseFiscalYear))+'@'+lTrim(str(a.BaseSerialNo))
					, SettlementID=lTrim(str(a.SettlementProcessID))+'@'+lTrim(str(a.SettlementProcessNo))+'@'+lTrim(str(a.SettlementFiscalYear))+'@'+lTrim(str(a.SettlementSerialNo))
					
	from 	trs.tblPayHdr  a 
	inner join 	inserted  b 
	on a.ProcessID=b.ProcessID and a.ProcessNo=b.ProcessNo and a.FiscalYear=b.FiscalYear and a.SerialNo=b.SerialNo
	
END

GO
