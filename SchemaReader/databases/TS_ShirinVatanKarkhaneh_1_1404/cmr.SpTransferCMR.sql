USE TS_ShirinVatanKarkhaneh_1_1404
GO
SET ANSI_NULLS, QUOTED_IDENTIFIER ON
GO
-- =========== TS-QC:UPDATED ====================
-- Author		 : TakroSystem\Ahmadnejad
-- Create date   : 1388/01/10
-- Viewed By	 : 
-- Last Modified : 1388/01/15
-- Last Modifier : TakroSystem\Ahmadnejad
-- Description   : لیست درخواستهای خریداری نشده جهت انتقال
-- ==============================================
Create PROCEDURE [cmr].[SpTransferCMR]

WITH ENCRYPTION
AS 

BEGIN --============== S T A R T  C O D E ===================================================

	SET NOCOUNT ON;

select *,ConfirmQuantity SubUnitQuantity,[inv].[funGetGoodsQuantityFromSubUnit](GoodsID, SubUnitID,ConfirmQuantity ) GoodsQuantity,ConfirmQuantity RemainQuantity  from
(
SELECT     r.ProcessID, r.ProcessNo, r.FiscalYear, r.SerialNo, r.RowNo, r.DocRowNo, r.DocStep, r.DocDate, r.AcntCode, r.GoodsID, r.SubUnitID
, r.ConfirmQuantity 
--    اضافه کردن سفارش هایی که مرجع درخواست دارند و به خرید تبدیل تشده است
+ (select  isnull(sum(s.ConfirmQuantity),0) 
	from (
--    اضافه کردن رسید موقت هایی که مرجع سفارش  دارند و به خرید تبدیل تشده است
		select isnull(sum(s.ConfirmQuantity),0) 
					+(select  isnull(sum(ConfirmQuantity),0) 
						from cmr.FunCmrGoodsQtyRemain(170,0,0,0,0,160,0,0,0,0) k  where  s.ProcessID =k.BaseProcessID and s.ProcessNo=k.BaseProcessNo and  s.FiscalYear=k.BaseFiscalYear and  s.SerialNo=k.BaseSerialNo and s.DocRowNo=k.BaseDocRowNo ) ConfirmQuantity
								,ProcessID,ProcessNo,FiscalYear,SerialNo,DocRowNo,BaseProcessID,BaseProcessNo,BaseFiscalYear,BaseSerialNo,BaseDocRowNo
			from cmr.FunCmrGoodsQtyRemain(160,0,0,0,0,150,0,0,0,0) s   
			Group by ProcessID,ProcessNo,FiscalYear,SerialNo,DocRowNo,BaseProcessID,BaseProcessNo,BaseFiscalYear,BaseSerialNo,BaseDocRowNo
		)s
	where  r.ProcessID =s.BaseProcessID and r.ProcessNo=s.BaseProcessNo and  r.FiscalYear=s.BaseFiscalYear and  r.SerialNo=s.BaseSerialNo and r.DocRowNo=s.BaseDocRowNo 
	 ) 
--    اضافه کردن رسید موقت هایی که مرجع درخواست  دارند و به خرید تبدیل تشده است
	 +(select  isnull(sum(ConfirmQuantity),0) from cmr.FunCmrGoodsQtyRemain(170,0,0,0,0,150,0,0,0,0) k  where  r.ProcessID =k.BaseProcessID and r.ProcessNo=k.BaseProcessNo and  r.FiscalYear=k.BaseFiscalYear and  r.SerialNo=k.BaseSerialNo and r.DocRowNo=k.BaseDocRowNo ) ConfirmQuantity
,r.DescDtl,d.OrderDate, r.BaseProcessID, r.BaseProcessNo, r.BaseFiscalYear, r.BaseSerialNo, r.BaseDocRowNo, BaseDocDate, Priority, DescDtl2
FROM         cmr.tblCMRDtl d
inner join cmr.FunCmrGoodsQtyRemain(150,0,0,0,0,0,0,0,0,0) r
on r.ProcessID=d.ProcessID
and r.ProcessNo=d.ProcessNo
and r.FiscalYear=d.FiscalYear
and r.SerialNo=d.SerialNo
and r.DocRowNo=d.DocRowNo
and ROUND(r.ConfirmQuantity,3)>0
) cmr
ORDER BY cmr.ProcessID, cmr.ProcessNo, cmr.FiscalYear, cmr.SerialNo, cmr.DocRowNo

End
GO
