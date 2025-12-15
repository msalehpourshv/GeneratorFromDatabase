USE TS_ShirinVatanKarkhaneh_1_1404
GO
SET ANSI_NULLS, QUOTED_IDENTIFIER ON
GO
CREATE FUNCTION [inv].[GetGoodsPlaceName]
(
	@GoodsPlaceID VarChar(20), 
	@LanguageID AS TinyInt
)
	RETURNS NVarChar(500) 
WITH ENCRYPTION
AS

Begin -- ====================================================

	--SET @LanguageID = pub.funGetCurrentLanguageID();

	Declare @StrResult AS NVarChar(500)

	Select @StrResult = GoodsPlaceName
	From   inv.tblGoodsPlaceDtl
	Where  GoodsPlaceID = @GoodsPlaceID AND LanguageID = @LanguageID

	Return isnull(@StrResult,'')

END
GO
