USE TS_ShirinVatanKarkhaneh_1_1404
GO
SET ANSI_NULLS, QUOTED_IDENTIFIER ON
GO
-- =========== TS-QC:NOTOK =====================
-- Author        : Reza NP
-- Create date   : 1392/09/13
-- Viewed By	 : 
-- Last Modified : 1393/05/04
-- Description   : 
-- =============================================
create PROCEDURE  [inv].[Spinv_GoodsListForUpload] 
		
WITH ENCRYPTION
AS

BEGIN

SELECT  distinct G.GoodsID,G.UnitID,G.GoodsPrice,D.GoodsName,
		G.SaleTypeID,isnull(ST.DaysNo,0)DaysNo,
		ISNULL((SELECT SUM(GoodsQuantity*EnterKind)  Quantity 
	FROM inv.tblStorageDocsDtl SD 
		WHERE SD.GoodsID=D.GoodsID),0) Quantity,
		 ISNULL(S.SubUnitID,0) UnitID2,G.HasSerial,G.HasExpireDate,
		 [sal].[funGetGoodsPriceInCustomerKind](G.GoodsID,G.UnitID) GoodsPrice1, 
		 [sal].[funGetGoodsPriceInCustomerKind](G.GoodsID,S.SubUnitID) GoodsPrice2, 
		 ISNULL(S.MainUnitValue,0) UnitValue1,ISNULL(S.UnitValue,0) UnitValue2 ,BarCode,
		  SalePrice,BuyPrice,NotShowInTablet,UserPrice,ActiveUserPrice
		FROM inv.tblGoods G 
		INNER JOIN inv.tblGoodsDtl D 
		ON D.GoodsID = G.GoodsID 
		LEFT JOIN inv.tblSubUnitsDtl S 
		ON G.GoodsID=S.GoodsID 
		LEFT JOIN sal.tblSaleTypes ST 
		ON G.SaleTypeID=ST.SaleTypeID
	
	WHERE D.LanguageID = 1  and (S.ShowInInvoice=1 or S.ShowInInvoice is null) AND G.CodeClosed=0
	 
END
GO
