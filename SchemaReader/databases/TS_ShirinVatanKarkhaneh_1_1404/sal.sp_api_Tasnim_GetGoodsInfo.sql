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
CREATE PROCEDURE [sal].[sp_api_Tasnim_GetGoodsInfo]
@SaleTypeId as varchar(20),
@StoreId as varchar(20),
@OffsetRowNo as int

WITH ENCRYPTION
 AS
BEGIN

Declare @StrErrorMessage As Nvarchar(1024)
 
BEGIN TRY

 SELECT  s.GoodsID as 'CodeMali',Sum(EnterKind*GoodsQuantity) ExistCount 
  ,ISNULL(a.SalePrice,0) as 'ProductPrice',
 a.SaleTypeID,
 gdtl.GoodsName as 'GoodsName',
 gdtl.GoodsName2 as 'GoodsName2',
 ISNULL(g.GenericCode,0) as 'GenericName',
 gdtl.Author as 'Athor'
	FROM inv.tblStorageDocsDtl s
  inner Join inv.tblGoods g 	ON s.GoodsID=g.GoodsID 
  inner Join inv.tblGoodsDtl gdtl 	ON s.GoodsID=gdtl.GoodsID and LanguageID=1
  left join sal.tblGoodsPricesDtl a on a.SaleTypeID=@SaleTypeId and s.GoodsID=a.GoodsID 

	 WHERE s.StoreID= @StoreId 
	Group by s.GoodsID ,a.SalePrice,a.SaleTypeID,
	gdtl.GoodsName ,gdtl.GoodsName2,g.GenericCode, gdtl.Author
	
 

END TRY

BEGIN CATCH

	Set @StrErrorMessage = ERROR_MESSAGE() 
	raiserror (@StrErrorMessage, 16, 1)

END CATCH

END	

GO
