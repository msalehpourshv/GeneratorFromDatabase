USE TS_ShirinVatanKarkhaneh_1_1404
GO
SET ANSI_NULLS, QUOTED_IDENTIFIER ON
GO
-- =========== TS-QC:NOTOK =====================
-- Author        : Hadi Sadeghi
-- Create date   : 97/02/28
-- Viewed By	 : 
-- Last Modified : 
-- Description   : 
-- =============================================
CREATE FUNCTION [inv].[funGetGoodsRemainVirtualQuantity]
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

	Select @QtyRemain = ISNULL(Sum(CASE when  GoodsQuantity >0 then GoodsQuantity else VirtualQuantity END ) ,0)
	From inv.tblStorageDocsDtl S
	Where (S.ProcessID = 90) AND DocDate<=@DocDate And StoreID = @StoreID AND GoodsID2 =@GoodsID AND GoodsQuantity <> 0
	and (
		select COUNT(*) from inv.tblStorageDocsDtl b 
		where S.ProcessID=b.BaseProcessID  AND
			  S.ProcessNo=b.BaseProcessNo  AND
			  S.BaseFiscalYear=b.BaseFiscalYear  AND
			  S.SerialNo=b.BaseSerialNo AND
			  S.DocRowNo=b.BaseDocRowNo  )=0

	RETURN @QtyRemain
END
GO
