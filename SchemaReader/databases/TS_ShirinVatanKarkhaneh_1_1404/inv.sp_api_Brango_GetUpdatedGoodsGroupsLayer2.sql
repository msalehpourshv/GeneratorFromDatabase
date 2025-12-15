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
create PROCEDURE inv.sp_api_Brango_GetUpdatedGoodsGroupsLayer2

@DateFrom AS NVARCHAR(50)

WITH ENCRYPTION
 AS
BEGIN
	DECLARE @StrErrorMessage NVARCHAR(MAX)
	DECLARE @Layer2 int
	DECLARE @Layer1  int
BEGIN TRY

	SELECT @Layer2=Layer1+Layer2 FROM pub.tblCodeLayer
	WHERE TableName ='inv.tblGoods' AND PartNumber=1

	SELECT @Layer1=Layer1 FROM pub.tblCodeLayer
	WHERE TableName ='inv.tblGoods' AND PartNumber=1

	--SELECT g.LastUpdate,SUBSTRING(g.GoodsID,1,@Layer1) AS PraneId,gd.GoodsName,g.GoodsID,gd.Description,i.GoodsImage FROM inv.tblGoods g
	SELECT SUBSTRING(g.GoodsID,1,@Layer1) AS PraneId,gd.GoodsName,g.GoodsID,
		   gd.Description,cast(cast(i.GoodsImage as binary)as varchar(max)) AS GoodsImage
	
	FROM inv.tblGoods g	

		LEFT JOIN inv.tblGoodsDtl gd
		ON g.GoodsID=gd.GoodsID 

		LEFT JOIN [inv].[tblGoodsImages] i
		ON g.GoodsID=i.GoodsID AND i.PartNumber=1  
	
	WHERE LEN(g.GoodsID)= @Layer2 and g.NotShowInTablet=0
		 --AND g.LastUpdate>=@DateFrom 
	
	
END TRY
BEGIN CATCH


	Set @StrErrorMessage = ERROR_MESSAGE() 
	raiserror (@StrErrorMessage, 16, 1)

END CATCH

END	
GO
