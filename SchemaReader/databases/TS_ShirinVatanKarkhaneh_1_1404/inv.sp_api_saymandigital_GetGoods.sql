USE TS_ShirinVatanKarkhaneh_1_1404
GO
SET ANSI_NULLS, QUOTED_IDENTIFIER ON
GO
-- =========== TS-QC:NOTOK ========================
-- Author        : E.Alian
-- Create date   : 1401/06/20
-- Viewed By	 : 
-- Last Modified : 
-- Description   : 
-- =============================================
Create PROCEDURE inv.sp_api_saymandigital_GetGoods
@LayerLenFilter AS NVARCHAR(100),
@StartCodeFilter AS NVARCHAR(100)

WITH ENCRYPTION
 AS
BEGIN

Declare @StrErrorMessage As Nvarchar(1024)
Declare @StrQuery As Nvarchar(MAX)


BEGIN TRY


	SET @StrQuery=' SELECT G.GoodsID,GD.GoodsName FROM inv.tblGoods G
				    JOIN inv.tblGoodsDtl GD
				    ON G.GoodsID=GD.GoodsID '

	IF(@LayerLenFilter<>0)
	BEGIN
		SET @StrQuery=@StrQuery+' WHERE LEN(G.GoodsID)= '+@LayerLenFilter  
	END

	IF(@StartCodeFilter<>'')
	BEGIN

		IF CHARINDEX('WHERE',@StrQuery)>0
		BEGIN
			SET @StrQuery=@StrQuery+' AND   G.GoodsID LIKE '''+@StartCodeFilter+'%'' '
		END

		ELSE
		BEGIN
			SET @StrQuery=@StrQuery+' WHERE   G.GoodsID LIKE '''+@StartCodeFilter+'%'''
		END

	END

	--PRINT @StrQuery
	EXEC sp_executesql @StrQuery

END TRY
BEGIN CATCH


	Set @StrErrorMessage = ERROR_MESSAGE() 
	raiserror (@StrErrorMessage, 16, 1)

END CATCH

END	

GO
