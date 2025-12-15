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
CREATE FUNCTION [sal].[funGetUserPriceSaleType] 
(
	@GoodsID Varchar(20),
	@SaleTypeID Varchar(20)
)
RETURNS FLOAT
WITH ENCRYPTION
AS

BEGIN

	DECLARE @SalePrice Float
	DECLARE @UserPrice Float

	Set @UserPrice = 0

	SELECT Top 1 @UserPrice = UserPrice 
	From sal.tblGoodsPricesDtl 
	Where	LEN(GoodsID) > 0 AND GoodsID = SUBSTRING(@GoodsID, 1, LEN(GoodsID)) AND
			SaleTypeID = @SaleTypeID --AND IsGroupCode = 0 
	order by LEN(GoodsID) desc	
										
	RETURN @UserPrice	

END
GO
