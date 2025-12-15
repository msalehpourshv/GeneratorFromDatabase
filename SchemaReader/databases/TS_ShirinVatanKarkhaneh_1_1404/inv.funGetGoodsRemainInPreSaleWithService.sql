USE TS_ShirinVatanKarkhaneh_1_1404
GO
SET ANSI_NULLS, QUOTED_IDENTIFIER ON
GO
-- =========== TS-QC:NOTOK =====================
-- Author        : Jafari
-- Create date   : 97/02/30
-- Viewed By	 : 
-- Last Modified : 
-- Description   : 
-- =============================================
Create FUNCTION [inv].[funGetGoodsRemainInPreSaleWithService]
(	
	@GoodsID		Varchar(20),
	@StoreID		Varchar(20),
	@DocDate		Char(10)
	
)
RETURNS decimal(38,5)
WITH ENCRYPTION
AS
BEGIN
		
	DECLARE @QtyRemain decimal(38,5)
	SET @QtyRemain = 0
	
	SELECT @QtyRemain = ISNULL(Sum(GoodsQuantity) ,0)-- ISNULL(Sum(SoldQty),0)
								 
	FROM inv.tblPreSaleDtl D
	INNER JOIN inv.tblPreSaleHdr H ON H.ProcessID = D.ProcessID AND H.ProcessNo = D.ProcessNo AND 
									 H.FiscalYear = D.FiscalYear AND H.SerialNo = D.SerialNo
	WHERE H.ProcessID = 240 AND D.GoodsID2 = @GoodsID AND 
	      D.DocDate <= @DocDate AND (@StoreID = '' OR D.StoreID = @StoreID) AND 
		  ConfirmState in(0,1)	AND
		  (Select COUNT(*)
		   From inv.tblStorageDocsDtl S 
		   Where (S.ProcessID = 90) AND (S.BaseProcessID = D.ProcessID) AND (S.BaseProcessNo = D.ProcessNo) AND 
			     (S.BaseFiscalYear = D.FiscalYear) AND (S.BaseSerialNo = D.SerialNo) AND (S.BaseDocRowNo = D.DocRowNo)
			        )=0	
	
	RETURN @QtyRemain
END
GO
