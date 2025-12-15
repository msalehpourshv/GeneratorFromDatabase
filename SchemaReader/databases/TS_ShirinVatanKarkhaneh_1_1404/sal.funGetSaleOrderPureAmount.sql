USE TS_ShirinVatanKarkhaneh_1_1404
GO
SET ANSI_NULLS, QUOTED_IDENTIFIER ON
GO
-- =========== TS-QC:NOTOK ========================
-- Author        : Hadi Sadeghi
-- Create date   : 86/12/24
-- Viewed By	 : 
-- Last Modified : 
-- Description   : 
-- =============================================
Create FUNCTION [sal].[funGetSaleOrderPureAmount] 
(
	@SerialNo int,
	@ProcessNo int,
	@FiscalYear int	
)
RETURNS Float
WITH ENCRYPTION
AS

BEGIN

RETURN ISNULL( (  SELECT 

	(SELECT SUM(GoodsPrice * SubUnitQuantity ) FROM sal.tblSaleOrderDtl WHERE   SerialNo =H.SerialNo and  ProcessID =H.ProcessID 
	and H.ProcessNo= ProcessNo and H.FiscalYear = FiscalYear ) -
	H.TransportationCost +
	H.TransportationIncome -
	H.OtherCost +
	H.OtherIncome +
	H.PackingCost +
	TaxCost+
	TaxOverWorthCost +
	TollOverWorthCost -
	Discount -
	(SELECT SUM(DiscountDtl) FROM sal.tblSaleOrderDtl WHERE   SerialNo =H.SerialNo and  ProcessID =H.ProcessID 
	and H.ProcessNo= ProcessNo and H.FiscalYear = FiscalYear ) -
	H.Discount2 -
	H.EarnestMoney
FROM sal.tblSaleOrderHdr H
	WHERE H.SerialNo =@SerialNo And ProcessNo = @ProcessNo  And FiscalYear  = @FiscalYear and ProcessID = 180 ),0)
 
	 

END
GO
