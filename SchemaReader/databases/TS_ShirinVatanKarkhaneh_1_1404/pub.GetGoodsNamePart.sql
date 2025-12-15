USE TS_ShirinVatanKarkhaneh_1_1404
GO
SET ANSI_NULLS, QUOTED_IDENTIFIER ON
GO
CREATE FUNCTION [pub].[GetGoodsNamePart]
(
	@GoodsCode VarChar(20), 
	@PartNumber AS TinyInt,
	@LanguageID AS TinyInt
)
	RETURNS NVarChar(50) 
WITH ENCRYPTION
AS

Begin -- ====================================================

	--SET @LanguageID = pub.funGetCurrentLanguageID();

	Declare @StrResult AS NVarChar(50)

	Select @StrResult = GoodsName
	From   inv.tblGoodsDtl
	Where  GoodsID = @GoodsCode AND LanguageID = @LanguageID  AND PartNumber = @PartNumber

	Return @StrResult

END
GO
