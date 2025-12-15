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
-- Select [inv].[funGetGoodsRemainInPreSale2] ('0101001', '01', '1394/12/10', 0, 2, 0, 3)
CREATE FUNCTION [inv].[funGetGoodsRemainInPreSale2]
(	
	@GoodsID		Varchar(20),
	@StoreID		Varchar(20),
	@DocDate		Char(10),
	@ReturnZero		Bit = 'False',
	@DocStep		Tinyint,
	@ConfirmState1	Tinyint,
	@ConfirmState2	Tinyint
)
RETURNS decimal(38,5)
WITH ENCRYPTION
AS
BEGIN
	IF @ReturnZero = 'True'
		RETURN 0
		
	DECLARE @QtyRemain decimal(38,5)
	SET @QtyRemain = 0
	
	SELECT @QtyRemain = ISNULL(Sum(GoodsQuantity) ,0)- ISNULL(Sum(SoldQty),0)
	FROM (
	SELECT D.*, 
			IsNull((
				Select Sum(GoodsQuantity) 
				From inv.tblStorageDocsDtl S 
				Where (S.ProcessID = 90) AND (S.BaseProcessID = D.ProcessID) AND (S.BaseProcessNo = D.ProcessNo) AND 
					  (S.BaseFiscalYear = D.FiscalYear) AND (S.BaseSerialNo = D.SerialNo) AND (S.BaseDocRowNo = D.DocRowNo)
			),0) SoldQty						 
	FROM inv.tblPreSaleDtl D
	INNER JOIN inv.tblPreSaleHdr H ON H.ProcessID = D.ProcessID AND H.ProcessNo = D.ProcessNo AND 
									 H.FiscalYear = D.FiscalYear AND H.SerialNo = D.SerialNo
	WHERE H.ProcessID = 240 AND D.GoodsID2 = @GoodsID AND D.DocDate <= @DocDate AND 
		                (@StoreID = '' OR D.StoreID = @StoreID) AND
		                 ((H.DocStep >= 2 AND H.ConfirmState >= @ConfirmState1 And H.ConfirmState <= @ConfirmState2) or
						  (H.DocStep <= 1 AND ((ValidDate = '' Or ValidDate Is Null) Or @DocDate <= ValidDate)))
	) T

	RETURN @QtyRemain
END
GO
