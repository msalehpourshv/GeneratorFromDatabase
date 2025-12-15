USE TS_ShirinVatanKarkhaneh_1_1404
GO
SET ANSI_NULLS, QUOTED_IDENTIFIER ON
GO
-- =========== TS-QC:UPDATED ====================
-- Author		 : TakroSystem\Zia
-- Create date   : 1390/12/22
-- Viewed By	 : 
-- Last Modified : 
-- Last Modifier : 
-- Description	 : اعضای یک مجموعه
-- ==============================================
CREATE PROCEDURE [inv].[RptStore_GoodsGroups]
	@GoodsGroupID	varchar(20)
WITH ENCRYPTION
AS 
Begin --============== S T A R T  C O D E =======================================

	SET NOCOUNT ON;

	-- Init ------------------------------------------
	--------------------------------------------------

	-- SELECT Clause ----------------------------------------
	SELECT	D.*, GD.GoodsName, U.UnitName
	FROM	inv.tblGoodsGroupsGoodsListDtl D
				LEFT JOIN inv.tblGoods GH ON GH.GoodsID = D.GoodsID 
				LEFT JOIN inv.tblGoodsDtl GD ON GD.GoodsID = D.GoodsID 
				LEFT JOIN inv.tblUnitsDtl U on U.UnitID = GH.UnitID
	WHERE 	D.GoodsGroupID = @GoodsGroupID
	ORDER BY DocRowNo
	------------------------------------------------------------
End
GO
