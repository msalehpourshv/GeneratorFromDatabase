USE TS_ShirinVatanKarkhaneh_1_1404
GO
SET ANSI_NULLS, QUOTED_IDENTIFIER ON
GO
-- =========== TS-QC:UPDATED ====================
-- Author		 : TakroSystem\Ahmadnejad
-- CREATE date   : 1387/02/21
-- Viewed By	 : 
-- Last Modifier : TakroSystem\Ahmadnejad
-- Last Modified : 1387/06/23
-- Description   : <List of Product Formulas>
-- =================================================================
CREATE PROCEDURE [prd].[RptPrd_FormulasList_Overloads]
	@ProductID	VarChar(50),
	@SerialNo	Int
	WITH ENCRYPTION
AS
BEGIN

	SET NOCOUNT ON;
--	SET @LanguageID = pub.funGetCurrentLanguageID();
	
	-- WHERE SECTION --------------------------------
	SELECT	DocRowNo, OverLoadAcntCode, OverLoadAmount, DescDtl, 
			pub.GetCodeName(OverLoadAcntCode,1) AcntName
	FROM	prd.tblFormulasOverLoadDtl
	WHERE	(ProductID = @ProductID) AND (SerialNo = @SerialNo)
		And (OverLoadProductDtl=1 or (OverLoadProductDtl=0 and OverLoadDecompositionDtl=0))
	ORDER BY DocRowNo
END
GO
