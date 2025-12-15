USE TS_ShirinVatanKarkhaneh_1_1404
GO
SET ANSI_NULLS, QUOTED_IDENTIFIER ON
GO
-- =========== TS-QC:NOTOK ========================
-- Author        : Alian Pour
-- Create date   : 1400/07/07
-- Viewed By	 : 
-- Last Modified : 
-- Description   : 
-- =============================================
Create PROCEDURE [sal].[sp_api_StarMobo_GetGoodsInfo]
@SaleTypeId as varchar(20),
@StoreId as varchar(20)


WITH ENCRYPTION
 AS
BEGIN

Declare @StrErrorMessage As Nvarchar(1024)
 
BEGIN TRY

 SELECT  
	s.GoodsID as 'ProductId',
	cast(Sum(EnterKind*GoodsQuantity) as int) ProductStock ,
	convert(decimal,ISNULL(a.SalePrice,0)) as 'ProductReqularPrice',
	a.SaleTypeID as 'ProductSku',
	gdtl.GoodsName as 'ProductTitle',
	gdtl.GoodsName2 as 'ProductSlug',
	convert(int,ISNULL(g.GoodsWeight,0)) as 'ProductWeight'

  FROM inv.tblStorageDocsDtl s
	inner Join inv.tblGoods g 	ON s.GoodsID=g.GoodsID 
	inner Join inv.tblGoodsDtl gdtl 	ON s.GoodsID=gdtl.GoodsID and LanguageID=1
	left join sal.tblGoodsPricesDtl a on a.SaleTypeID=@SaleTypeId and s.GoodsID=a.GoodsID 

  --WHERE s.StoreID= @StoreId 
  Group by s.GoodsID ,a.SalePrice,a.SaleTypeID,gdtl.GoodsName ,gdtl.GoodsName2,g.GoodsWeight
 

END TRY

BEGIN CATCH

	Set @StrErrorMessage = ERROR_MESSAGE() 
	raiserror (@StrErrorMessage, 16, 1)

END CATCH

END	

GO
