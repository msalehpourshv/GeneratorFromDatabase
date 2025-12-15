USE TS_ShirinVatanKarkhaneh_1_1404
GO
SET ANSI_NULLS, QUOTED_IDENTIFIER ON
GO
-- =========== TS-QC:UPDATED ====================
-- Author		 : TakroSystem\
-- Create date   : 1404/05/12
-- Viewed By	 : 
-- Last Modified : 
-- Last Modifier : TakroSystem\
-- Description   : نمایش تصویر کالا
-- ==============================================

Create PROCEDURE [sal].[RptSale_PriceList2_Images]
	@GoodsID		VarChar(20) = Null
WITH ENCRYPTION
AS 
---- Declarations ---------------
DECLARE @StrSelect		NVarChar(4000);

BEGIN --============== S T A R T  C O D E ===================================================

	SET NOCOUNT ON;

	--================================
	CREATE TABLE #tbl_Goods_Images
	(
		GoodsID    Varchar(20) COLLATE Arabic_CS_AS,
		GoodsImage Image
	);

	SET @StrSelect = '
	INSERT INTO #tbl_Goods_Images(GoodsID, GoodsImage)
	SELECT GoodsID,
		   GoodsImage
	FROM inv.tblGoodsImages GI'
		
	PRINT @StrSelect;
	EXEC sp_executesql @StrSelect;	
	-----------------------------------------------------------	
	SET @StrSelect = '
		SELECT GI1.GoodsImage 
		FROM #tbl_Goods_Images GI1 
		WHERE GoodsID = ' + '''' + LTrim(RTrim(@GoodsID)) +''''
	-- Run -------------------------------------------------------
	PRINT @StrSelect;
	EXEC sp_executesql @StrSelect;
	--------------------------------------------------------------
END
GO
