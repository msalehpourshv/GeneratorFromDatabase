USE TS_ShirinVatanKarkhaneh_1_1404
GO
SET ANSI_NULLS, QUOTED_IDENTIFIER ON
GO
-- =============================================
-- Author:		MM
-- Create date: 86-02-28
-- Description:	قفل گذاري يا قفل برداري سند هنگام تغيير قفل آن در هدر سند
-- =============================================

CREATE TRIGGER [acc].[trgVoucherHdrUpdate]
   ON  [acc].[tblVoucherHdr]
   WITH ENCRYPTION
  AFTER UPDATE
AS 
BEGIN
	SET NOCOUNT ON;

	Update acc.tblVoucherSerials
    Set DocRegisterState = inserted.DocRegisterState
    From inserted
	Where VchNo = inserted.SerialNo

END






GO
