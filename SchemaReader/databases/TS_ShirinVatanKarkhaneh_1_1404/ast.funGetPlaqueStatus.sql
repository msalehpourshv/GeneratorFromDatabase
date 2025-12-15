USE TS_ShirinVatanKarkhaneh_1_1404
GO
SET ANSI_NULLS, QUOTED_IDENTIFIER ON
GO
-- =========== TS-QC:UPDATED ====================
-- Author		 : TakroSystem\Ahmadnejad
-- Create Date   : 1387/10/31
-- Viewed By	 : 
-- Last Modified : 
-- Last Modifier : 
-- Description	 : شماره یونیک پلاک را گرفته و وضعیت جاری یک پلاک را برمی گرداند
-- ==============================================
CREATE FUNCTION ast.funGetPlaqueStatus
(
	@AssetPlaque	VarChar(20)
)
RETURNS TinyInt
WITH ENCRYPTION
AS
BEGIN
	DECLARE @IntResult		TinyInt
	DECLARE @MaxEventNo		Int

	-- Get Last EventID
	SELECT	@MaxEventNo = Max(EventNo)
	FROM	ast.tblAssetsDtl
	WHERE	AssetPlaque = @AssetPlaque

	-- Get Status 
	SELECT	@IntResult = AssetState
	FROM	ast.tblAssetsDtl
	WHERE	AssetPlaque = @AssetPlaque AND EventNo = @MaxEventNo

	RETURN @IntResult
END
GO
