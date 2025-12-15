USE TS_ShirinVatanKarkhaneh_1_1404
GO
SET ANSI_NULLS, QUOTED_IDENTIFIER ON
GO
-- =========== TS-QC:UPDATED ====================
-- Author		 : TakroSystem\h.sadeghi
-- CREATE date   : 1401/07/02
-- Viewed By	 : 
-- Last Modifier : 
-- Last Modified : 
-- Description   : 
-- =================================================================
CREATE PROCEDURE [prd].[RptPrd_FormulasList_SecondaryProduct]
	@ProductID	VarChar(50),
	@SerialNo	Int
	WITH ENCRYPTION
AS
BEGIN

	SET NOCOUNT ON;
--	SET @LanguageID = pub.funGetCurrentLanguageID();
	
	-- WHERE SECTION --------------------------------
	SELECT	*,[pub].[funGetGoodsName](GoodsID,1) GoodsName,[inv].[funGetUnitName](UnitID,1) UnitName
	FROM	[prd].[tblSecondaryProductByFormulaDtl]
	WHERE	(ProductID = @ProductID) AND (SerialNo = @SerialNo)
	ORDER BY DocRowNo
END
GO
