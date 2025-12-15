USE TS_ShirinVatanKarkhaneh_1_1404
GO
SET ANSI_NULLS, QUOTED_IDENTIFIER ON
GO
-- =========== TS-PHR:NOTOK ========================
-- Author        : Reza Nogrepasand
-- Create date   : 92/11/03
-- Viewed By	 : 
-- Last Modified : 
-- Description   : 
-- =============================================
CREATE PROCEDURE [sal].[SPSalePriceCalc]

WITH ENCRYPTION
AS
BEGIN
	 
	DECLARE @RowNo AS INT
	DECLARE @DocRowNo AS INT
	DECLARE @RecordCount AS INT
	
	SET @RecordCount = 0
	
	-- ===================================== Update SalePrice
	Update sal.tblGoodsPricesDtl SET SalePrice = T.LastPrice 
	From sal.tblGoodsPricesDtl G1 
	Inner Join 
		(
		 Select *, PriceSum * IncDecPercent / 100 As IncDecPrice, PriceSum + (PriceSum * IncDecPercent / 100) As LastPrice 
		 From (
				Select SP.GoodsID, IsNull(GP.SaleTypeID,0) SaleTypeID, IsNull(GP.SalePrice,0) SalePrice, 
					   SP.Price1+SP.Price2+SP.Price3+SP.Price4+SP.Price5+SP.Price6+SP.Price7+SP.Price8+SP.Price9+SP.Price10 AS PriceSum, 
					   S.IncDecPercent 
				From sal.tblSalePriceAnalysisDtl SP 
				Inner Join sal.tblGoodsPricesDtl GP ON GP.GoodsID = SP.GoodsID 
				Inner Join sal.tblSaleTypes S ON GP.SaleTypeID = S.SaleTypeID 
			   ) A 
		) T ON T.GoodsID = G1.GoodsID And T.SaleTypeID = G1.SaleTypeID And T.SalePrice = G1.SalePrice	
	
	-- ===================================== Insert SalePrice
	SELECT M.GoodsID, ROW_NUMBER()OVER(ORDER BY M.RowNo) RowNo, ROW_NUMBER()OVER(ORDER BY M.RowNo) DocRowNo, 1 SalePriceTypeID, 
		   0 DefaultSalePriceTypeID, M.SaleTypeID, M.LastPrice, 0 BasePriceTypeID, 0 AddendAmountToPrice, 0 AddendPercentToPrice, 
		   0 RoundableDigitsInPrice, '' CurrencyTypeID, 0 CurrencyPrice, 0 Coefficient, 0 IsGroupCode, 0 MinSalePrice, 0 UserPrice
	INTO #tblSalePrices
	FROM 
	(
		Select A.SaleTypeID, A.SaleTypeName, A.GoodsID, A.PriceSum, A.RowNo,
		Round(Case When A.IncDecPercent > 0 Then A.PriceSum + (A.PriceSum * A.IncDecPercent / 100) Else A.PriceSum End,0) As LastPrice
		From 
		(
			Select S.SaleTypeID, SD.SaleTypeName, T.GoodsID, S.IncDecPercent, T.RowNo,
				   T.Price1+T.Price2+T.Price3+T.Price4+T.Price5+T.Price6+T.Price7+T.Price8+T.Price9+T.Price10 AS PriceSum
			From (
					Select a.* From sal.tblSalePriceAnalysisDtl a 
					Inner Join (Select GoodsID,Max(SerialNo) SerialNo 
								From sal.tblSalePriceAnalysisDtl
								Group By GoodsID) b ON a.GoodsID=b.GoodsID and a.SerialNo=b.SerialNo
				  ) T, sal.tblSaleTypes S
			Inner Join sal.tblSaleTypesDtl SD ON SD.SaleTypeID = S.SaleTypeID 
			Where S.SaleTypeID <> '' And S.SaleTypeID NOT IN (Select SaleTypeID 
															  From sal.tblGoodsPricesDtl 
															  Where SaleTypeID = S.SaleTypeID And GoodsID = T.GoodsID And 
																	SalePrice <> 0) And 
				  T.GoodsID NOT IN (Select GoodsID 
									From sal.tblGoodsPricesDtl 
									Where SaleTypeID = S.SaleTypeID And GoodsID = T.GoodsID)																
		) A
		Group By A.SaleTypeID, A.SaleTypeName, A.GoodsID, A.PriceSum, A.IncDecPercent, A.RowNo
	) M	
	
	-- ==========
	Select @RecordCount = Count(*) From #tblSalePrices
	
	IF @RecordCount > 0
	Begin
		-- === Hdr
		INSERT INTO sal.tblGoodsPricesHdr (GoodsID, IsGroupCode)
		SELECT DISTINCT GoodsID, IsGroupCode FROM #tblSalePrices

		-- === Dtl
		INSERT INTO sal.tblGoodsPricesDtl (GoodsID, RowNo, DocRowNo, SalePriceTypeID, DefaultSalePriceTypeID, SaleTypeID, 
										   SalePrice, BasePriceTypeID, AddendAmountToPrice, AddendPercentToPrice, RoundableDigitsInPrice,
										   CurrencyTypeID, CurrencyPrice, Coefficient, IsGroupCode, MinSalePrice, UserPrice)
		SELECT * FROM #tblSalePrices
	End
	
	DROP TABLE #tblSalePrices
	
END
GO
