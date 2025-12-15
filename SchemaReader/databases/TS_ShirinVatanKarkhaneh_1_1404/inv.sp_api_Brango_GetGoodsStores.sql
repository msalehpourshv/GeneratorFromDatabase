USE TS_ShirinVatanKarkhaneh_1_1404
GO
SET ANSI_NULLS, QUOTED_IDENTIFIER ON
GO
-- =========== TS-QC:NOTOK ========================
-- Author        : Alian Pour
-- Create date   : 1400/11/18
-- Viewed By	 : 
-- Last Modified : 
-- Description   : 
-- =============================================
CREATE PROCEDURE [inv].[sp_api_Brango_GetGoodsStores]

@GoodsId As NVARCHAR(50)

WITH ENCRYPTION
 AS
BEGIN
	DECLARE @strSelect  NVARCHAR(MAX)
	DECLARE @StrErrorMessage NVARCHAR(MAX)
	DECLARE @SerialNo INT

BEGIN TRY

	SELECT  GoodsID,cast(SUM(EnterKind*GoodsQuantity)as nvarchar(200))AS Quantity , s.StoreName 
	FROM inv.tblStorageDocsDtl sdd
		JOIN inv.tblStoresDtl s 
		ON sdd.StoreID=s.StoreID
	WHERE GoodsID=@GoodsId
	GROUP BY GoodsID,sdd.StoreID,s.StoreName

END TRY
BEGIN CATCH


	Set @StrErrorMessage = ERROR_MESSAGE() 
	raiserror (@StrErrorMessage, 16, 1)

END CATCH

END	
GO
