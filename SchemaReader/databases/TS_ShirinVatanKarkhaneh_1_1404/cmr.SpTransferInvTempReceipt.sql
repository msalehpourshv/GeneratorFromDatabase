USE TS_ShirinVatanKarkhaneh_1_1404
GO
SET ANSI_NULLS, QUOTED_IDENTIFIER ON
GO
-- =========== TS-QC:UPDATED ====================
-- Author		 : TakroSystem\Jafari
-- Create date   : 1388/01/10
-- Viewed By	 : 
-- Last Modified : 
-- Last Modifier : 
-- Description   : لیست سفارشات خریداری نشده جهت انتقال
-- ==============================================
Create PROCEDURE cmr.SpTransferInvTempReceipt
WITH ENCRYPTION
AS 
BEGIN --============== S T A R T  C O D E ===================================================

	SET NOCOUNT ON;

select r.ProcessID, r.ProcessNo, r.FiscalYear, r.SerialNo, r.RowNo, r.DocRowNo, r.DocStep, r.DocDate, r.StoreID, r.AcntCode, r.GoodsID, r.SubUnitID
,r.ConfirmQuantity SubUnitQuantity, r.ConfirmQuantity, [inv].[funGetGoodsQuantityFromSubUnit](r.GoodsID, r.SubUnitID,r.ConfirmQuantity) GoodsQuantity, r.DescDtl, BaseDocType, r.BaseProcessID, r.BaseProcessNo, r.BaseFiscalYear, r.BaseSerialNo, r.BaseDocRowNo
, d.BatchNo, r.Recognition, BaseDocDate, OKCardNo, ConstText1, ConstText2, ConstText3, ConstText4, r.PenaltyPercent
, r.ConfirmQuantity RemainQuantity                        
                                              
FROM     inv.tblInvTempReceiptDtl  d
inner join cmr.FunCmrGoodsQtyRemain(170,0,0,0,0,0,0,0,0,0) r
on r.ProcessID=d.ProcessID
and r.ProcessNo=d.ProcessNo
and r.FiscalYear=d.FiscalYear
and r.SerialNo=d.SerialNo
and r.DocRowNo=d.DocRowNo
and r.ConfirmQuantity>0
ORDER BY r.ProcessID, r.ProcessNo, r.FiscalYear, r.SerialNo, r.DocRowNo


	

End
GO
