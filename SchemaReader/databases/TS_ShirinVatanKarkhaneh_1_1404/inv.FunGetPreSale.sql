USE TS_ShirinVatanKarkhaneh_1_1404
GO
SET ANSI_NULLS, QUOTED_IDENTIFIER ON
GO
-- =========== TS-QC:NOTOK ========================
-- Author        : Hadi Sadeghi
-- Create date   : 87/6/07
-- Viewed By	 : 
-- Last Modified : 
-- Description   : 
-- =============================================
Create FUNCTION [inv].[FunGetPreSale]
(
	@AcntCode Varchar(20),
	@DocDate  char(10),
	@DocStep  Tinyint
)
RETURNS TABLE 
WITH ENCRYPTION
AS
RETURN 
(
	SELECT D.ProcessID, 
		   D.ProcessNo, 
		   D.FiscalYear, 
		   D.SerialNo, 
		   D.DocRowNo, 
		   Sum(D.GoodsQuantity) ConfirmQuantity,
		   D.DocDate, 
		   D.AcntCode, 
		   PH.DocStep, 
		   PH.ConfirmState, 
		   PH.VisitorAcntCode, 
		   PH.VisitorAcntCode2, 
		   PH.StoreID,
	       PH.LocationID
	FROM inv.tblPreSaleDtl D
	INNER JOIN inv.tblPreSaleHdr PH ON D.ProcessID = PH.ProcessID 
								   AND D.ProcessNo = PH.ProcessNo 
								   AND D.FiscalYear = PH.FiscalYear 
								   AND D.SerialNo = PH.SerialNo
	WHERE D.ProcessID = 240 
	  AND D.DocStep =@DocStep 
	  AND (@AcntCode IS NULL OR D.AcntCode = @AcntCode) 
	  AND D.DocDate <= @DocDate 
	  AND PH.ConfirmState <> 2
	GROUP BY D.ProcessID, D.ProcessNo, D.FiscalYear, D.SerialNo, 
			 D.DocRowNo, D.DocDate, D.AcntCode, PH.DocStep, 
			 PH.ConfirmState, PH.VisitorAcntCode, PH.VisitorAcntCode2, 
			 PH.StoreID, PH.LocationID
)
GO
