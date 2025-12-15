USE TS_ShirinVatanKarkhaneh_1_1404
GO
SET ANSI_NULLS, QUOTED_IDENTIFIER ON
GO
-- =========== TS-QC:UPDATED ====================
-- Author		 : Mostafavi
-- Create date   : 1404/07/03
-- Viewed By	 : 
-- Last Modified : 
-- Description	 : 
-- =============================================
Create PROCEDURE [pln].[SpGetGoodsWasteGroupID]
	@StrGoodsID NVarChar(20),
	@LangID		TinyInt
WITH ENCRYPTION
AS

BEGIN
SET NOCOUNT ON;

	SELECT G.GoodsWasteGroupID, 
		   LGD.LoseGroupName GoodsWasteGroupName
	FROM inv.tblGoods G
	INNER JOIN pln.tblLoseGroupDtl LGD ON G.GoodsWasteGroupID = LGD.LoseGroupID 
									  AND LGD.LanguageID = @LangID
	WHERE G.GoodsID = @StrGoodsID
END
GO
