USE TS_ShirinVatanKarkhaneh_1_1404
GO
SET ANSI_NULLS, QUOTED_IDENTIFIER ON
GO
CREATE FUNCTION [inv].[funGetGoodsPriceForCurrentCustomer] 
(
	@GoodsID Varchar(20),
	@AcntCode Varchar(20),
	@DocDate Char(10)
)
RETURNS Float
WITH ENCRYPTION
AS

BEGIN

	DECLARE @GoodsPrice  FLOAT

	SET  @GoodsPrice = 0

	SELECT TOP 1 @GoodsPrice = GoodsPrice
	From inv.tblStorageDocsDtl
	Where	GoodsID  = @GoodsID  AND 
			AcntCode = @AcntCode AND
			DocDate < @DocDate  AND
			ProcessID = 90	
	ORDER BY DocDate Desc,VolumeRowNo Desc	

	RETURN @GoodsPrice
END
GO
