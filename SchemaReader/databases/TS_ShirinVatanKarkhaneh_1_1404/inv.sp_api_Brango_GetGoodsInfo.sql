USE TS_ShirinVatanKarkhaneh_1_1404
GO
SET ANSI_NULLS, QUOTED_IDENTIFIER ON
GO
-- =========== TS-QC:NOTOK ========================
-- Author        : Alian Pour
-- Create date   : 1400/09/10
-- Viewed By	 : 
-- Last Modified : 
-- Description   : 
-- =============================================
CREATE PROCEDURE inv.sp_api_Brango_GetGoodsInfo

@Filter AS NVARCHAR(50),
@Skip AS  NVARCHAR(50),
@MaxResultCount AS  NVARCHAR(50),
@DataFilter AS NVARCHAR(50),
@SaleTypeId As NVARCHAR(50),
@DocDate As NVARCHAR(10)

WITH ENCRYPTION
 AS
BEGIN
	DECLARE @StrErrorMessage NVARCHAR(MAX)
	DECLARE @strQuery NVARCHAR(Max)
	
BEGIN TRY

	set @strQuery='SELECT g.GoodsID,TechnicalNo,BarCode,GoodsPrice, gd.GoodsName,gd.Description ,gd.Author,
				    cast([sal].[funGetGoodsAmountSaleType](g.GoodsID,'''' , '''+@DocDate+''' ,'''+@SaleTypeId+''',1,0,0)AS nvarchar(200)) AS Price
				   FROM inv.tblGoods g
				   LEFT JOIN inv.tblGoodsDtl gd ON g.GoodsID=gd.GoodsID
				   WHERE CodeClosed=0'

	IF(@DataFilter='Goods')
	BEGIN
		set @strQuery=@strQuery+' AND (SELECT TOP 1 COUNT(*) 
								  FROM inv.tblGoods b 
								  WHERE LEFT(b.GoodsID,LEN(g.GoodsID))=g.GoodsID '
		IF( @Filter<>'')
		BEGIN

			SET @strQuery=@strQuery+ ' And  (gd.GoodsName like N''%'+@Filter+'%'' OR g.GoodsID LIKE N''%'+@Filter+'%'') '
		END

		set @strQuery=@strQuery+')=1'

	END



	IF(@DataFilter='Group')
	BEGIN

		set @strQuery=@strQuery+' AND g.GoodsID NOT IN (SELECT GoodsID from inv.tblGoods g WHERE 
														    (SELECT TOP 1 COUNT(*) from inv.tblGoods b WHERE 
																LEFT(b.GoodsID,LEN(g.GoodsID))=g.GoodsID)=1)'
	END
			
	SET @strQuery=@strQuery+' 
				   ORDER BY g.GoodsID 
				   OFFSET ' +@Skip +' Rows 
				   FETCH NEXT ' +@MaxResultCount +' Rows ONLY '

	PRINT @strQuery
	EXEC sp_executesql @strQuery

END TRY
BEGIN CATCH


	Set @StrErrorMessage = ERROR_MESSAGE() 
	raiserror (@StrErrorMessage, 16, 1)

END CATCH

END	
GO
