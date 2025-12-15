USE TS_ShirinVatanKarkhaneh_1_1404
GO
SET ANSI_NULLS, QUOTED_IDENTIFIER ON
GO
-- =========== TS-QC:UPDATED ====================
-- Author		 : TakroSystem\Ahmadnejad
-- Create date   : 1388/01/10
-- Viewed By	 : 
-- Last Modified : 
-- Last Modifier : 
-- Description   : لیست سفارشات خریداری نشده جهت انتقال
-- ==============================================
Create PROCEDURE [cmr].[SpTransferOrders]
WITH ENCRYPTION
AS 
BEGIN --============== S T A R T  C O D E ===================================================

	SET NOCOUNT ON;

select *,ConfirmQuantity SubUnitQuantity,[inv].[funGetGoodsQuantityFromSubUnit](GoodsID, SubUnitID,ConfirmQuantity ) GoodsQuantity,ConfirmQuantity RemainQuantity  from
(
	SELECT     r.ProcessID, r.ProcessNo, r.FiscalYear, r.SerialNo, r.RowNo, r.DocRowNo, r.DocStep, r.DocDate, r.AcntCode, r.GoodsID, r.SubUnitID
	,r.ConfirmQuantity
--    اضافه کردن رسید موقت هایی که مرجع سفارش  دارند و به خرید تبدیل تشده است
		+(select  isnull(sum(ConfirmQuantity),0) 
			from cmr.FunCmrGoodsQtyRemain(170,0,0,0,0,160,0,0,0,0) k  where  r.ProcessID =k.BaseProcessID and r.ProcessNo=k.BaseProcessNo and  r.FiscalYear=k.BaseFiscalYear and  r.SerialNo=k.BaseSerialNo and r.DocRowNo=k.BaseDocRowNo ) ConfirmQuantity
	, r.GoodsPrice, r.DescDtl, r.OrderDate, BaseDocType, 
	r.BaseProcessID, r.BaseProcessNo, r.BaseFiscalYear, r.BaseSerialNo, r.BaseDocRowNo, d.AgreeNo, 
	BaseDocDate, DescDtl2, RolQty, r.StoreID, InOutWithServiceType                                               
	FROM  cmr.tblOrderDtl  d
	inner join cmr.FunCmrGoodsQtyRemain(160,0,0,0,0,0,0,0,0,0) r
	on r.ProcessID=d.ProcessID
	and r.ProcessNo=d.ProcessNo
	and r.FiscalYear=d.FiscalYear
	and r.SerialNo=d.SerialNo
	and r.DocRowNo=d.DocRowNo
	and r.ConfirmQuantity>0
) ord
ORDER BY ord.ProcessID, ord.ProcessNo, ord.FiscalYear, ord.SerialNo, ord.DocRowNo

End
GO
