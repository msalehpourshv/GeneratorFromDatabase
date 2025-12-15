USE TS_ShirinVatanKarkhaneh_1_1404
GO
SET ANSI_NULLS, QUOTED_IDENTIFIER ON
GO
-- =========== TS-QC:NOTOK ========================
-- Author        : Alian Pour
-- Create date   : 1400/11/06
-- Viewed By	 : 
-- Last Modified : 
-- Description   : 
-- =============================================
Create PROCEDURE inv.sp_api_Brango_GetUpdatedGoods

@DateFrom AS datetime,
@DateNow As nvarchar(50),
@SaleTypeId as nvarchar(50)

WITH ENCRYPTION
 AS
BEGIN
	DECLARE @StrErrorMessage NVARCHAR(MAX)
	DECLARE @strQuery  NVARCHAR(Max)
	
BEGIN TRY
DECLARE @SumLayer  NVARCHAR(Max)
	SELECT @SumLayer=  Layer1+Layer2+Layer3+Layer4+Layer5+Layer6+Layer7+Layer8+Layer9
	FROM pub.tblCodeLayer
	WHERE TableName ='inv.tblGoods' AND PartNumber=1

	 SELECT 
		GoodsID as Sku,
		[inv].[funGetGoodsRemain](null,null,null,null,NULL,null ,GoodsID,'',@DateNow,0)  AS Stock_Quantity,
		[sal].[funGetGoodsAmountSaleType](GoodsID,'' ,@DateNow ,@SaleTypeId,1,0,0) Regular_Price,
		LastUpdate
		
		FROM inv.tblGoods 
		
		WHERE  LEN(GoodsID)=@SumLayer AND NotShowInTablet=0 
	

	     AND LastUpdate>=@DateFrom


END TRY
BEGIN CATCH


	Set @StrErrorMessage = ERROR_MESSAGE() 
	raiserror (@StrErrorMessage, 16, 1)

END CATCH

END	
GO
