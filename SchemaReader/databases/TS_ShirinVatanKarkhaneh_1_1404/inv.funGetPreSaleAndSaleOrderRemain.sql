USE TS_ShirinVatanKarkhaneh_1_1404
GO
SET ANSI_NULLS, QUOTED_IDENTIFIER ON
GO
-- =========== TS-QC:NOTOK =====================
-- Author        : Hadi Sadeghi
-- Create date   : 91/01/27
-- Viewed By	 : 
-- Last Modified : 
-- Description   : 
-- =============================================
--Select [inv].[funGetPreSaleAndSaleOrderRemain] ('501000550', '', '', 1)
--Select [inv].[funGetPreSaleAndSaleOrderRemain] ('501000550', '', '', 0)
--Select [inv].[funGetPreSaleAndSaleOrderRemain] ('501000150', '', '', 1)
--Select [inv].[funGetPreSaleAndSaleOrderRemain] ('501000150', '', '', 0)
CREATE FUNCTION [inv].[funGetPreSaleAndSaleOrderRemain]
(	
	@ProductID		Varchar(20),
	@GoodsID		Varchar(20),
	@GoodsID2		Varchar(20),
	@IsSaleOrder	Bit
)
RETURNS Decimal(38,5)
WITH ENCRYPTION
AS
BEGIN
	DECLARE @Result Decimal(38,5)
	SET @Result = 0;
	
	SET @ProductID = @ProductID + '%'
	
	Select @Result = Case When @IsSaleOrder = 'False' Then IsNull(Sum(PreSaleRemain),0) Else IsNull(Sum(SaleOrderRemain),0) End
	From (
			Select P1.ProductID, 
				   Case When P1.ProductID Like @ProductID Then IsNull(Sum(P1.ProductQty),0) Else IsNull(Sum(P1.GoodsQty),0) End PreSale,
				   Case When P1.ProductID Like @ProductID Then IsNull(Sum(P2.ProductQty),0) Else IsNull(Sum(P2.GoodsQty),0) End SaleOrder,
				   Case When P1.ProductID Like @ProductID Then IsNull(Sum(P3.ProductQty),0) + IsNull(Sum(P4.ProductQty),0) 
				   Else IsNull(Sum(P3.GoodsQty),0) + IsNull(Sum(P4.GoodsQty),0) End Sale,
				   Case When P1.ProductID Like @ProductID Then 
				   IsNull(Sum(P1.ProductQty),0) - IsNull(Sum(P2.ProductQty),0) - IsNull(Sum(P3.ProductQty),0) 
				   Else IsNull(Sum(P1.GoodsQty),0) - IsNull(Sum(P2.GoodsQty),0) - IsNull(Sum(P3.GoodsQty),0)
				   End PreSaleRemain,
				   Case When P1.ProductID Like @ProductID Then 
				   IsNull(Sum(P2.ProductQty),0) - IsNull(Sum(P4.ProductQty),0) 
				   Else IsNull(Sum(P2.GoodsQty),0) - IsNull(Sum(P4.GoodsQty),0) End SaleOrderRemain
			From prd.tblProductGoods P1 --PreSale

			--PreSale/SaleOrder
			Left Join prd.tblProductGoods P2 ON P1.ProcessID = P2.BaseProcessID And P1.ProcessNo = P2.BaseProcessNo And
												P1.FiscalYear = P2.BaseFiscalYear And P1.SerialNo = P2.BaseSerialNo And
												P1.ProductID = P2.ProductID And P1.GoodsID = P2.GoodsID And 
												P1.GoodsID2 = P2.GoodsID2 And P2.ProcessID = 180
			--PreSale/Sale
			Left Join prd.tblProductGoods P3 ON P1.ProcessID = P3.BaseProcessID And P1.ProcessNo = P3.BaseProcessNo And
												P1.FiscalYear = P3.BaseFiscalYear And P1.SerialNo = P3.BaseSerialNo And
												P1.ProductID = P3.ProductID And P1.GoodsID = P3.GoodsID And 
												P1.GoodsID2 = P3.GoodsID2 And P3.ProcessID = 90									
			--SaleOrder/Sale
			Left Join prd.tblProductGoods P4 ON P2.ProcessID = P4.BaseProcessID And P2.ProcessNo = P4.BaseProcessNo And
												P2.FiscalYear = P4.BaseFiscalYear And P2.SerialNo = P4.BaseSerialNo And
												P2.ProductID = P4.ProductID And P2.GoodsID = P4.GoodsID And 
												P2.GoodsID2 = P4.GoodsID2 And P4.ProcessID = 90
																					
			Where P1.ProcessID = 240 And (P1.ProductID Like @ProductID OR 
				  P1.GoodsID Like @ProductID And P1.GoodsID2 Like @ProductID) --And P1.SerialNo = 11 
			Group By P1.ProductID
			) A
			
	RETURN @Result
END
GO
