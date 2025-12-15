USE TS_ShirinVatanKarkhaneh_1_1404
GO
SET ANSI_NULLS, QUOTED_IDENTIFIER ON
GO
-- =========== TS-QC:NOTOK ========================
-- Author        :Elaheh AlianPour
-- Create date   : 1400/11/25
-- Viewed By	 : 
-- Last Modified : 
-- Description   : 
-- =============================================

CREATE PROCEDURE [inv].[sp_api_AsmanRasa_GetProductsQuantity]

@StoreId AS NVARCHAR(10),
@ProductId AS NVARCHAR(25),
@OrderId as nvarchar(20)

WITH ENCRYPTION
 AS
BEGIN

DECLARE @StrErrorMessage As Nvarchar(1024)
Declare @GoodsId as nvarchar(50)

BEGIN TRY

	IF(SELECT COUNT(*) FROM inv.tblGoods WHERE TechnicalNo=@ProductId)=0
	BEGIN
		Set @StrErrorMessage ='کد محصول  '+@ProductId+' صحیح نیست '
		raiserror (@StrErrorMessage, 16, 1)
	END

	ELSE
		SELECT @GoodsId=GoodsID FROM inv.tblGoods WHERE TechnicalNo=@ProductId


	SELECT CAST (SUM(EnterKind*GoodsQuantity) AS INT) AS GoodsQuantity,BatchNo 
	FROM inv.tblStorageDocsDtl
	WHERE GoodsID=@GoodsId and StoreID=@StoreId and (BatchNo='' or BatchNo like ''+@OrderId+'%')
	GROUP BY StoreID,BatchNo
	ORDER BY SUM(EnterKind*GoodsQuantity) DESC

END TRY
BEGIN CATCH

	Set @StrErrorMessage = ERROR_MESSAGE() 
	raiserror (@StrErrorMessage, 16, 1)

END CATCH

END	

GO
