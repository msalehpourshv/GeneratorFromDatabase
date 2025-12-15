USE TS_ShirinVatanKarkhaneh_1_1404
GO
SET ANSI_NULLS, QUOTED_IDENTIFIER ON
GO
--===================================
--Aoutor: Hadi Sadeghi
--Date:1392/02/10
--===================================

CREATE FUNCTION [sal].[funGetGoodsPriceInCustomerKind]
 
(
	@GoodsID	Char(20),
	@UnitID	Char(20)
)
RETURNS  BIGINT
WITH ENCRYPTION
AS

BEGIN

	-- Declare the return variable here
	DECLARE @GoodsPrice BIGINT

	Set @GoodsPrice = 0

	SELECT TOP 1 @GoodsPrice = Amount 
	FROM sal.tblGoodsPriceForCustomerKindDtl CD 
	INNER JOIN sal.tblGoodsPriceForCustomerKindHdr C 
	ON C.SerialNo = CD.SerialNo 
	WHERE CD.GoodsID=@GoodsID  AND CD.SubUnitID = @UnitID AND CurrencyTypeID=''
	ORDER BY C.FromDate desc

	IF @GoodsPrice = 0
	BEGIN
		DECLARE @SubUnitID VARCHAR(20)
		
		SELECT TOP 1 @GoodsPrice = ROUND(Amount * S.UnitValue/S.MainUnitValue,0) 
		FROM sal.tblGoodsPriceForCustomerKindDtl CD 
		INNER JOIN sal.tblGoodsPriceForCustomerKindHdr C 
		ON C.SerialNo = CD.SerialNo
		LEFT JOIN inv.tblSubUnitsDtl S
		ON S.GoodsID=CD.GoodsID AND S.SubUnitID = CD.SubUnitID 
		WHERE CD.GoodsID=@GoodsID AND CurrencyTypeID=''
		ORDER BY C.FromDate desc
	END
	
	-- Return the result of the function
	RETURN @GoodsPrice 

END
GO
