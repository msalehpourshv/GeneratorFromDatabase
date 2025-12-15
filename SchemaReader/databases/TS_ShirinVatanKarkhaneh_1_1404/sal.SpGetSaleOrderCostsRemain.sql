USE TS_ShirinVatanKarkhaneh_1_1404
GO
SET ANSI_NULLS, QUOTED_IDENTIFIER ON
GO
-- =========== TS-QC:NOTOK =====================
-- Author        : Hamid
-- Create date   : 1393/09/03 - Hamid
-- Viewed By	 : 
-- Last Modified : 1393/09/03 - Hamid
-- Description   : 
-- =============================================
CREATE PROCEDURE [sal].[SpGetSaleOrderCostsRemain]
	@ProcessID		Int = 180, -- Sale Order Process ID
	@ProcessNo		Int = 1,
	@FiscalYear		Int = 93,
	@SerialNo		Int

WITH ENCRYPTION
 AS
BEGIN
SET NOCOUNT ON;

DECLARE @StrSelect1	NVarChar(Max);
	
	-- ================================================
	
	Select SH.ProcessID, SH.ProcessNo, SH.FiscalYear, SH.SerialNo, 
		   Case When SH.Discount2 > 0 Then SH.Discount2 - IsNull(AllSales.Discount2,0) Else SH.Discount2 End As Discount2, 
		   Case When SH.Discount > 0 Then SH.Discount - IsNull(AllSales.Discount,0) Else SH.Discount End As Discount, 
		   Case When SH.TransportationCost > 0 Then SH.TransportationCost - IsNull(AllSales.TransportationCost,0) Else SH.TransportationCost End As TransportationCost, 
		   Case When SH.TransportationIncome > 0 Then SH.TransportationIncome - IsNull(AllSales.TransportationIncome,0) Else SH.TransportationIncome End As TransportationIncome, 
		   SH.VisitorCost - IsNull(AllSales.VisitorCost,0) As VisitorCost, SH.VisitorCost2 - IsNull(AllSales.VisitorCost2,0) As VisitorCost2, 
		   SH.PackingCost - IsNull(AllSales.PackingCost,0) As PackingCost, SH.TaxCost - IsNull(AllSales.TaxCost,0) As TaxCost, 
		   SH.PackingCostPercent - ISNULL(AllSales.PackingCostPercent,0) as PackingCostPercent,
		   SH.TaxOverWorthCost - IsNull(AllSales.TaxOverWorthCost,0) As TaxOverWorthCost, 
		   SH.TollOverWorthCost - IsNull(AllSales.TollOverWorthCost,0) As TollOverWorthCost,
		   SH.EarnestMoneyPercent - IsNull(AllSales.EarnestMoneyPercent,0) As EarnestMoneyPercent,
		   SH.EarnestMoney - IsNull(AllSales.EarnestMoney,0) As EarnestMoney,SH.HasNoReward,SH.HasNoDiscountDtl,
		   SH.OtherCost - IsNull(AllSales.OtherCost,0) As OtherCost, SH.OtherIncome - IsNull(AllSales.OtherIncome,0) As OtherIncome 
		   
	From sal.tblSaleOrderHdr SH 
	Inner Join(
			   Select S.BaseProcessID, S.BaseProcessNo, S.BaseFiscalYear, S.BaseSerialNo, 
					  IsNull(Sum(S.EarnestMoneyPercent),0) As EarnestMoneyPercent,
					  IsNull(Sum(S.EarnestMoney),0) As EarnestMoney,
					  IsNull(Sum(S.Discount),0) As Discount, IsNull(Sum(S.Discount2),0) As Discount2, 
					  IsNull(Sum(S.TransportationCost),0) As TransportationCost, IsNull(Sum(S.TransportationIncome),0) As TransportationIncome, 
					  IsNull(Sum(S.VisitorCost),0) As VisitorCost, IsNull(Sum(S.VisitorCost2),0) As VisitorCost2, 
					  IsNull(Sum(S.PackingCost),0) As PackingCost, IsNull(Sum(S.TaxCost),0) As TaxCost, 
					  IsNull(Sum(S.PackingCostPercent),0) As PackingCostPercent,
					  IsNull(Sum(S.TaxOverWorthCost),0) As TaxOverWorthCost, IsNull(Sum(S.TollOverWorthCost),0) As TollOverWorthCost, 
					  IsNull(Sum(S.OtherCost),0) As OtherCost, IsNull(Sum(S.OtherIncome),0) As OtherIncome 
			   From inv.tblStorageDocsHdr S 
			   Where S.BaseProcessID = @ProcessID And S.BaseProcessNo = @ProcessNo And S.BaseFiscalYear = @FiscalYear And 
				     S.BaseSerialNo = @SerialNo
			   Group By S.BaseProcessID, S.BaseProcessNo, S.BaseFiscalYear, S.BaseSerialNo 
			   ) As AllSales ON AllSales.BaseProcessID = SH.ProcessID And AllSales.BaseProcessNo = 1 And 
								AllSales.BaseFiscalYear = SH.FiscalYear And AllSales.BaseSerialNo = SH.SerialNo 
	Where SH.ProcessID = @ProcessID And SH.ProcessNo = @ProcessNo And SH.FiscalYear = @FiscalYear And SH.SerialNo = @SerialNo
	
	-- ============================
END
GO
