USE TS_ShirinVatanKarkhaneh_1_1404
GO
SET ANSI_NULLS, QUOTED_IDENTIFIER ON
GO
CREATE FUNCTION [pub].[GetGoodsName]
(
	@GoodsCode VarChar(20), 
	@LanguageID AS TinyInt
)
	RETURNS NVarChar(500) 
WITH ENCRYPTION
AS

Begin -- ====================================================

	--SET @LanguageID = pub.funGetCurrentLanguageID();

	Declare @StrResult AS NVarChar(500)

	Select @StrResult = GoodsName
	From   inv.tblGoodsDtl
	Where  GoodsID = @GoodsCode AND LanguageID = @LanguageID

	Return isnull(@StrResult,'')

END
GO
