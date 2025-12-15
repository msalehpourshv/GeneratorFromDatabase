USE TS_ShirinVatanKarkhaneh_1_1404
GO
SET ANSI_NULLS, QUOTED_IDENTIFIER ON
GO
CREATE FUNCTION [inv].[funGetGoodsRemainActiveDoc]
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

	Select @QtyRemain = ISNULL(Sum(VirtualQuantity ) ,0)
	From inv.tblStorageDocsDtl S
	Where (S.ProcessID = 90) AND DocDate<=@DocDate And StoreID = @StoreID AND GoodsID2 =@GoodsID AND SubUnitQuantity = 0

	RETURN @QtyRemain
END
GO
