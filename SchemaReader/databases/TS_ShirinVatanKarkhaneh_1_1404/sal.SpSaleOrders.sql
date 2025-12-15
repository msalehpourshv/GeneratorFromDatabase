USE TS_ShirinVatanKarkhaneh_1_1404
GO
SET ANSI_NULLS, QUOTED_IDENTIFIER ON
GO
-- =========== TS-QC:UPDATED ====================
-- Author		 : jafari
-- Create date   : 1402/04/11
-- Viewed By	 : 
-- Last Modified : 
-- Description	 : 
-- ==============================================
--sal.SpSaleOrders '180@1@1400@21@1400@21@@'
Create PROCEDURE sal.SpSaleOrders
	@ExtraParams		NVarChar(Max) = ''
WITH ENCRYPTION
AS
declare	@RetPID int
declare	@DateFr char(10)
declare	@DateTo char(10)
declare @MaxSmallDealAmount as bigint

Declare @ProcessID		int, -- 180
		@ProcessNo		int, --
		@FiscalYearFr	Int,
		@SerialNoFr		int,
		@FiscalYearTo	Int,
		@SerialNoTo		Int	
 Begin
 
 	SET @ProcessID			= LTrim(pub.funSplitString(@ExtraParams, '@', 1)); 
 	SET @ProcessNo			= LTrim(pub.funSplitString(@ExtraParams, '@', 2)); 
 	SET @FiscalYearFr		= LTrim(pub.funSplitString(@ExtraParams, '@', 3)); 
 	SET @SerialNoFr			= LTrim(pub.funSplitString(@ExtraParams, '@', 4)); 
 	SET @FiscalYearTo		= LTrim(pub.funSplitString(@ExtraParams, '@', 5)); 
 	SET @SerialNoTo			= LTrim(pub.funSplitString(@ExtraParams, '@', 6)); 
 	SET @DateFr			    = LTrim(pub.funSplitString(@ExtraParams, '@', 7)); 
 	SET @DateTo			    = LTrim(pub.funSplitString(@ExtraParams, '@', 8));  	
 	
	
	if @ProcessID = 180 set @RetPID = 185
	 
-------#SHdr-----------------------------------------------------------------

Select ProcessID,ProcessNo,FiscalYear,SerialNo,DocDate,'' VchDate,AcntCode,Discount,Discount2,TaxOverWorthCost,TollOverWorthCost,Discount+Discount2+ CASE WHEN DiscountTaxOverWorth=1 THEN TaxOverWorthCost+TollOverWorthCost else 0 end SumDiscountHdr
		,DiscountTaxOverWorth,CurrencyTypeID,CurrencyRate,Cast(Case When (ProcessID = @RetPID) Then 1 Else 0 End As Bit) IsReturn
       INTO #SHdr
FROM sal.tblSaleOrderHdr
where (ProcessID=@ProcessID or ProcessID=@RetPID ) 
and (@ProcessNo =0 or  ProcessNo = @ProcessNo)
and (@FiscalYearFr =0 or  FiscalYear >= @FiscalYearFr )
and (@SerialNoFr =0 or  SerialNo >= @SerialNoFr )
and (@FiscalYearTo =0 or  FiscalYear<= @FiscalYearTo )
and (@SerialNoTo =0 or  SerialNo<= @SerialNoTo )
and (@DateFr ='' or  DocDate >=@DateFr )
and (@DateTo ='' or  DocDate <=@DateTo)

----------#SDtl--------------------------------------------------------------

select H.ProcessID,H.ProcessNo,H.FiscalYear,H.SerialNo,D.RowNo,D.DocRowNo,D.DiscountDtl,D.TaxOverWorthCostDtl,D.TollOverWorthCostDtl,
       D.GoodsID,D.BatchNo,(D.GoodsQuantity* D.GoodsPrice -D.DiscountDtl+D.TaxOverWorthCostDtl+D.TollOverWorthCostDtl+
						  ISNULL((SELECT ROUND(SUM(AtomAmount* GoodsQuantity),3) 
							    FROM inv.tblStorageDocsAtom A 
							    WHERE A.ProcessID=D.ProcessID AND A.ProcessNo=D.ProcessNo AND 
									  A.FiscalYear=D.FiscalYear AND A.SerialNo=D.SerialNo AND
								      A.DocRowNo=D.DocRowNo AND HasVAT='True'),0)
						  ) SumPriceDtlWithTax,
			  (D.GoodsQuantity*D.GoodsPrice +
						  ISNULL((SELECT ROUND(SUM(AtomAmount* GoodsQuantity),3) 
							    FROM inv.tblStorageDocsAtom A 
							    WHERE A.ProcessID=D.ProcessID AND A.ProcessNo=D.ProcessNo AND 
									  A.FiscalYear=D.FiscalYear AND A.SerialNo=D.SerialNo AND
								      A.DocRowNo=D.DocRowNo AND HasVAT='True'),0)) SumPriceDtl,CurrencyAmount
	  INTO  #SDtl					   
FROM sal.tblSaleOrderDtl D
INNER JOIN sal.tblSaleOrderHdr H
ON H.ProcessID=D.ProcessID and H.ProcessNo=D.ProcessNo AND H.FiscalYear=D.FiscalYear and H.SerialNo=D.SerialNo
where (D.ProcessID=@ProcessID or D.ProcessID=@RetPID ) 
and (@ProcessNo =0 or  D.ProcessNo = @ProcessNo)
and (@FiscalYearFr =0 or  D.FiscalYear >= @FiscalYearFr )
and (@SerialNoFr =0 or  D.SerialNo >= @SerialNoFr )
and (@FiscalYearTo =0 or  D.FiscalYear<= @FiscalYearTo )
and (@SerialNoTo =0 or  D.SerialNo<= @SerialNoTo )
and (@DateFr ='' or  D.DocDate >=@DateFr )
and (@DateTo ='' or  D.DocDate <=@DateTo)
-------#SGroupDtl-----------------------------------------------------------------

SELECT H.ProcessID,H.ProcessNo,H.FiscalYear,H.SerialNo,
   SUM(D.GoodsQuantity*D.GoodsPrice  -D.DiscountDtl+D.TaxOverWorthCostDtl+D.TollOverWorthCostDtl) SumPrice,SUM(TaxOverWorthCostDtl+TollOverWorthCostDtl) SumTaxToll
	INTO #SGroupDtl	
FROM sal.tblSaleOrderDtl D
INNER JOIN sal.tblSaleOrderHdr H
ON H.ProcessID=D.ProcessID and H.ProcessNo=D.ProcessNo AND H.FiscalYear=D.FiscalYear and H.SerialNo=D.SerialNo
where (D.ProcessID=@ProcessID or D.ProcessID=@RetPID ) 
and (@ProcessNo =0 or  D.ProcessNo = @ProcessNo)
and (@FiscalYearFr =0 or  D.FiscalYear >= @FiscalYearFr )
and (@SerialNoFr =0 or  D.SerialNo >= @SerialNoFr )
and (@FiscalYearTo =0 or  D.FiscalYear<= @FiscalYearTo )
and (@SerialNoTo =0 or  D.SerialNo<= @SerialNoTo )
and (@DateFr ='' or  D.DocDate >=@DateFr )
and (@DateTo ='' or  D.DocDate <=@DateTo) 
group by H.ProcessID,H.ProcessNo,H.FiscalYear,H.SerialNo 

-------------------------------------------------------------------------------------
update #SGroupDtl
set SumPrice=SumPrice+A.GAtomAmount
from #SGroupDtl D
inner join ( SELECT isnull(SUM(AtomAmount* GoodsQuantity),0) GAtomAmount,ProcessID,ProcessNo,FiscalYear,SerialNo,HasVAT
FROM inv.tblStorageDocsAtom A 
Group by ProcessID,ProcessNo,FiscalYear,SerialNo,HasVAT) A 
on A.ProcessID=D.ProcessID AND A.ProcessNo=D.ProcessNo AND 
	A.FiscalYear=D.FiscalYear AND A.SerialNo=D.SerialNo AND A.HasVAT='True'

	
select *,SumPriceDtlWithTax-TaxOverWorthCostDtl-TollOverWorthCostDtl+ TaxDtl+TollDtl-DiscountHdr PurePrice, DiscountDtl+DiscountHdr TotalDiscount  
	Into #Main
FROM (
SELECT H.ProcessID,H.ProcessNo,H.FiscalYear,H.SerialNo,D.RowNo,D.DocRowNo,GoodsID,D.BatchNo,SumPriceDtl,H.AcntCode,H.DocDate,
	   H.VchDate,H.CurrencyTypeID,CurrencyRate,IsReturn,
       DiscountDtl ,TaxOverWorthCostDtl,TollOverWorthCostDtl,H.Discount,Discount2,CurrencyAmount,
	   DiscountTaxOverWorth,TaxOverWorthCost,TollOverWorthCost,SumDiscountHdr,SumPrice,SumPriceDtlWithTax,
	   case when SumPrice>0 THEN (SumDiscountHdr*SumPriceDtlWithTax)/SumPrice ELSE 0 END DiscountHdr,
	   case when SumTaxToll=0 AND SumPrice>0 then (TaxOverWorthCost*SumPriceDtlWithTax)/SumPrice else TaxOverWorthCostDtl END TaxDtl,
	   case when SumTaxToll=0 AND SumPrice>0 then (TollOverWorthCost*SumPriceDtlWithTax)/SumPrice else TollOverWorthCostDtl END TollDtl
	 
FROM #SDtl	D
inner join #SHdr H ON H.ProcessID=D.ProcessID and H.ProcessNo=D.ProcessNo AND H.FiscalYear=D.FiscalYear and H.SerialNo=D.SerialNo
INNER JOIN #SGroupDtl D2 ON H.ProcessID=D2.ProcessID and H.ProcessNo=D2.ProcessNo AND H.FiscalYear=D2.FiscalYear and H.SerialNo=D2.SerialNo
--where SumPrice>0
) a 
--where SerialNo=156
------------------------------------------------------------------------
SELECT *, TaxDtl + TollDtl TaxTollDtl	  		FROM #Main
order by 	ProcessID,ProcessNo,FiscalYear,SerialNo,DocRowNo

END----end
GO
