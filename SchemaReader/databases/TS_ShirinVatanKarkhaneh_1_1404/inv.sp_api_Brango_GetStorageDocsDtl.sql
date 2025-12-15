USE TS_ShirinVatanKarkhaneh_1_1404
GO
SET ANSI_NULLS, QUOTED_IDENTIFIER ON
GO
-- =========== TS-QC:NOTOK ========================
-- Author        : Alian Pour
-- Create date   : 1400/10/13
-- Viewed By	 : 
-- Last Modified : 
-- Description   : 
-- =============================================
CREATE PROCEDURE [inv].[sp_api_Brango_GetStorageDocsDtl]

@SerialNo as nvarchar(50),
@ProcessID as smallint,
@ProcessNo as tinyint,
@FiscalYear as nvarchar(50)


WITH ENCRYPTION
 AS
BEGIN
	DECLARE @StrErrorMessage NVARCHAR(MAX)
BEGIN TRY



	SELECT FiscalYear,ProcessNo,SerialNo,ProcessID,sd.DocRowNo,sd.RowNo,DiscountPercentDtl,
		sd.GoodsID,GoodsQuantity,sd.GoodsPrice,sd.SubUnitID,DescDtl,
		DocDate,sd.SaleTypeID,sd.StoreID,g.TechnicalNo as TechnicalNo,DiscountDtl,IsReward,
		gd.GoodsName as GoodsName,saleType.SaleTypeName ,store.StoreName

	FROM inv.tblStorageDocsDtl sd

		LEFT JOIN inv.tblGoodsDtl gd on sd.GoodsID=gd.GoodsID
		LEFT JOIN inv.tblGoods g on sd.GoodsID=g.GoodsID
		Left Join sal.tblSaleTypesDtl saleType on sd.SaleTypeID=saleType.SaleTypeID
		Left Join inv.tblStoresDtl store on sd.StoreID=store.StoreID


	WHERE (ProcessID=@ProcessID)  AND SerialNo=@SerialNo AND
		  ProcessNo=4 AND FiscalYear=@FiscalYear  


END TRY
BEGIN CATCH


	Set @StrErrorMessage = ERROR_MESSAGE() 
	raiserror (@StrErrorMessage, 16, 1)

END CATCH

END	
GO
