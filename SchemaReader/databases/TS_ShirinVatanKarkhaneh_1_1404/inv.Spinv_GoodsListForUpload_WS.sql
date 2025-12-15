USE TS_ShirinVatanKarkhaneh_1_1404
GO
SET ANSI_NULLS, QUOTED_IDENTIFIER ON
GO

-- =========== TS-QC:NOTOK =====================
-- Author        : Reza NP
-- Create date   : 1392/09/13
-- Viewed By	 : 
-- Last Modified : 13403/11/13
-- Description   : 
-- =============================================
CREATE PROCEDURE  [inv].[Spinv_GoodsListForUpload_WS] 
	
	@UserID as int=0,
	@StoreID as varchar(20)='',
	@UserAcntCode as varchar(20)='',
	@IsSayman as bit='False'
	
WITH ENCRYPTION
AS

BEGIN

 if @IsSayman='False'
 
	begin
	
		SELECT  distinct G.GoodsID,G.UnitID,G.GoodsPrice,D.GoodsName,
			G.SaleTypeID,isnull(ST.DaysNo,0)DaysNo,G.HasContainerStore,
			ISNULL((SELECT SUM(GoodsQuantity*EnterKind)  Quantity 
					FROM inv.tblStorageDocsDtl SD 
					WHERE SD.GoodsID=D.GoodsID AND( @StoreID='' OR StoreID=@StoreID)),0) Quantity,
			 ISNULL(S.SubUnitID,0) UnitID2,G.HasSerial,G.HasExpireDate,G.HasBatchNo,G.HasContainer,G.HasProductionDate,
			 0 GoodsPrice1, 
			 0 GoodsPrice2, 
			 --[sal].[funGetGoodsPriceInCustomerKind](G.GoodsID,G.UnitID) GoodsPrice1, 
			 --[sal].[funGetGoodsPriceInCustomerKind](G.GoodsID,S.SubUnitID) GoodsPrice2, 
			 ISNULL(S.MainUnitValue,1) UnitValue1,ISNULL(S.UnitValue,1) UnitValue2 ,BarCode,
			 SalePrice,BuyPrice,NotShowInTablet,UserPrice,ActiveUserPrice,G.ContainTax
		FROM inv.tblGoods G 
		INNER JOIN inv.tblGoodsDtl D 
		ON D.GoodsID = G.GoodsID 
		LEFT JOIN  (select * from inv.tblSubUnitsDtl where ShowInInvoice=1) S 
		ON G.GoodsID=S.GoodsID 
		LEFT JOIN sal.tblSaleTypes ST 
		ON G.SaleTypeID=ST.SaleTypeID
		
		WHERE  NotShowInTablet='False' AND  D.LanguageID = 1  and (S.ShowInInvoice=1 or S.ShowInInvoice is null) AND G.CodeClosed=0 AND
		 
		 
		 ( -- حیطه
				(Select COUNT(*) from inv.tblGoodsRng
					where  UserID=@UserID AND AllowCodeView=1 AND 
					      LEFT(G.GoodsID,LEN(inv.tblGoodsRng.ToCode))>=LEFT(inv.tblGoodsRng.FromCode,LEN(G.GoodsID))
					  and LEFT(G.GoodsID,LEN(inv.tblGoodsRng.ToCode))<=LEFT(inv.tblGoodsRng.ToCode,LEN(G.GoodsID)))>0  
					  and G.CodeClosed=0 
				OR 
					(Select COUNT(*) from inv.tblGoodsRng
					where UserID=@UserID and AccessAllCode=1)>0
		 )
		 OR 
		LEFT(G.GoodsID,LEN(G.GoodsID)) in (select LEFT(g.GoodsID,LEN(G.GoodsID))
					  FROM inv.tblVisitorCoddingRangDtl a 
					  INNER JOIN inv.tblGoodsGroupsGoodsListDtl g 
					  ON a.GoodsGroupID=g.GoodsGroupID 
					  WHERE a.VisitorID = @UserAcntCode AND 
					  FromGoodsID = '' AND ToGoodsID = ''
					  and G.CodeClosed=0)	  
		  
		 OR
		 
		 ( 
			(Select COUNT(*) from inv.tblVisitorCoddingRangDtl
			where VisitorID = @UserAcntCode AND LEFT(G.GoodsID,LEN(G.GoodsID))>=LEFT(inv.tblVisitorCoddingRangDtl.FromGoodsID,LEN(G.GoodsID))
			and LEFT(G.GoodsID,LEN(G.GoodsID))<=LEFT(inv.tblVisitorCoddingRangDtl.ToGoodsID,LEN(G.GoodsID)))>0
			and G.CodeClosed=0 
			 
		 )
	
	end -- end if
	
 if @IsSayman='True'
	BEGIN
		
		SELECT  distinct G.GoodsID,G.UnitID,G.GoodsPrice,D.GoodsName,
			G.SaleTypeID,isnull(ST.DaysNo,0)DaysNo,G.HasContainerStore,
			ISNULL((SELECT SUM(GoodsQuantity*EnterKind)  Quantity 
					FROM inv.tblStorageDocsDtl SD 
					WHERE SD.GoodsID=D.GoodsID  AND( @StoreID='' OR StoreID=@StoreID)),0) Quantity,
			 ISNULL(S.SubUnitID,0) UnitID2,G.HasSerial,G.HasExpireDate,G.HasBatchNo,G.HasContainer,G.HasProductionDate,
			 [sal].[funGetGoodsPriceInCustomerKind](G.GoodsID,G.UnitID) GoodsPrice1, 
			 [sal].[funGetGoodsPriceInCustomerKind](G.GoodsID,S.SubUnitID) GoodsPrice2, 
			 ISNULL(S.MainUnitValue,1) UnitValue1,ISNULL(S.UnitValue,1) UnitValue2 ,BarCode,
			  SalePrice,BuyPrice,NotShowInTablet,UserPrice,ActiveUserPrice,G.ContainTax
			FROM inv.tblGoods G 
			INNER JOIN inv.tblGoodsDtl D 
			ON D.GoodsID = G.GoodsID 
			LEFT JOIN inv.tblSubUnitsDtl S 
			ON G.GoodsID=S.GoodsID 
			LEFT JOIN sal.tblSaleTypes ST 
			ON G.SaleTypeID=ST.SaleTypeID
		
		WHERE  NotShowInTablet='False' AND D.LanguageID = 1  and (S.ShowInInvoice=1 or S.ShowInInvoice is null) AND  G.CodeClosed=0 
		 
	end -- end if 
	

END
GO
