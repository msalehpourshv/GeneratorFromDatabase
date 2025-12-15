USE TS_ShirinVatanKarkhaneh_1_1404
GO
SET ANSI_NULLS, QUOTED_IDENTIFIER ON
GO
-- =========== TS-QC:NOTOK ========================
-- Author        : H.Sadeghi
-- Create date   : 1403-12-28
-- Viewed By	 : 
-- Last Modified : 
-- Description   : 
-- =============================================
--exec [sal].[SpResturanDividHdrDiscountToDtlDiscount] 92,0,1403,4051,'1'
Create PROCEDURE [sal].[SpResturanDividHdrDiscountToDtlDiscount]
@ProcessID AS Int,
@ProcessNo AS Int,
@FiscalYear AS Int,
@SerialNo AS Int,
@BranchID AS NVARCHAR(20)

WITH ENCRYPTION
 AS
BEGIN

	SELECT CASE WHEN MaxRow=R THEN DistributedDiscount+(DiscountAmount-TotalDistributedDiscount) ELSE DistributedDiscount  END PureDistributedDiscount ,* INTO #T 
	from (	
		SELECT SUM(DistributedDiscount)over(partition by ProcessID,ProcessNo,FiscalYear,SerialNo,BranchID order by ProcessID,ProcessNo,FiscalYear,SerialNo,BranchID) TotalDistributedDiscount,
			   MAX(R)over(partition by ProcessID,ProcessNo,FiscalYear,SerialNo,BranchID order by ProcessID,ProcessNo,FiscalYear,SerialNo,BranchID) MaxRow,* 
		FROM (
			SELECT d.ProcessID,d.ProcessNo,d.FiscalYear,d.SerialNo,d.BranchID,h.DocDate,d.RowNo,d.DiscountDtl,Price,Qty , 
				ROW_NUMBER()over (partition by d.ProcessID,d.ProcessNo,d.FiscalYear,d.SerialNo,d.BranchID order by d.ProcessID,d.ProcessNo,d.FiscalYear,d.SerialNo,d.BranchID,RowNo ) R,
				Price*Qty Amount,
				h.DiscountAmount,
				ed.TotalAmount,
				TaxOverWorthCostDtl,
				ROUND(TaxOverWorthCostDtl*100/((Price*Qty)-DiscountDtl),2) TaxOverWorthCostPercent ,
				ROUND( ((Price*Qty-DiscountDtl) / ed.TotalAmount) * h.DiscountAmount,0) AS DistributedDiscount, -- سرشکن به نسبت Amount
				(Price*Qty)-DiscountDtl-ROUND( ((Price*Qty-DiscountDtl) / ed.TotalAmount) * h.DiscountAmount,0) TotalPure
			FROM sal.tblRestaurantSaleDtl d
			INNER JOIN sal.tblRestaurantSaleHdr h 
			ON d.ProcessID =h.ProcessID  AND d.ProcessNo=h.ProcessNo AND d.FiscalYear=h.FiscalYear and d.SerialNo=h.SerialNo and d.BranchID=h.BranchID
			INNER JOIN 
				(SELECT a.ProcessID,a.ProcessNo,a.FiscalYear,a.SerialNo,a.BranchID,SUM(Price*Qty-DiscountDtl) AS TotalAmount
					FROM sal.tblRestaurantSaleDtl a
					INNER JOIN inv.tblGoods b  ON a.GoodsID=b.GoodsID
					INNER JOIN sal.tblRestaurantSaleHdr m 
					ON a.ProcessID =m.ProcessID  AND a.ProcessNo=m.ProcessNo AND a.FiscalYear=m.FiscalYear and a.SerialNo=m.SerialNo and a.BranchID=m.BranchID
					WHERE m.DiscountAmount> 0 and  NotDiscount = 0 and Price*Qty-DiscountDtl<>0-- فقط رکوردهایی که شامل سرشکن می‌شوند
					GROUP BY a.ProcessID,a.ProcessNo,a.FiscalYear,a.SerialNo,a.BranchID
				 ) ed ON d.ProcessID =ed.ProcessID  AND d.ProcessNo=ed.ProcessNo AND d.FiscalYear=ed.FiscalYear and d.SerialNo=ed.SerialNo and d.BranchID=ed.BranchID
			INNER JOIN inv.tblGoods b on d.GoodsID=b.GoodsID
			WHERE h.DiscountAmount> 0 and  NotDiscount =0 and Price*Qty-DiscountDtl<>0 -- فقط رکوردهایی که شامل سرشکن می‌شوند
			and h.ProcessID = @ProcessID and h.ProcessNo=@ProcessNo and h.FiscalYear=@FiscalYear and h.SerialNo=@SerialNo  and h.BranchID=@BranchID
			)a
		)a

	UPDATE sal.tblRestaurantSaleDtl
	SET DiscountDtl = a.DiscountDtl + PureDistributedDiscount,
		TaxOverWorthCostDtl =FLOOR(((a.Price*a.Qty) - (a.DiscountDtl + PureDistributedDiscount)) * TaxOverWorthCostPercent /100)
	from sal.tblRestaurantSaleDtl a
	inner join #T b 
	ON a.ProcessID =b.ProcessID  AND a.ProcessNo=b.ProcessNo AND a.FiscalYear=b.FiscalYear and a.SerialNo=b.SerialNo and a.BranchID=b.BranchID and a.RowNo=b.RowNo

	update sal.tblRestaurantSaleHdr
	SET DiscountAmount = 0
	from sal.tblRestaurantSaleHdr a
	inner join #T b 
	ON a.ProcessID =b.ProcessID  AND a.ProcessNo=b.ProcessNo AND a.FiscalYear=b.FiscalYear and a.SerialNo=b.SerialNo and a.BranchID=b.BranchID 

END
GO
