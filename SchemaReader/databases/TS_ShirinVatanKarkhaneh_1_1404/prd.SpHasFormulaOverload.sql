USE TS_ShirinVatanKarkhaneh_1_1404
GO
SET ANSI_NULLS, QUOTED_IDENTIFIER ON
GO
-- =========== TS-QC:UPDATED ====================
-- Author		 : Hadi Sadeghi	
-- Create date   : 1389/09/27
-- Viewed By	 : 
-- Last Modified : 
-- Last Modifier : 
-- Description: بررسی وجود سربار برای فرمول تولید
-- ==============================================
CREATE PROCEDURE [prd].[SpHasFormulaOverload]
	@ProductID	VarChar(20),
	@SerialNo	int
WITH ENCRYPTION
AS
BEGIN
	SELECT	ISNULL(SUM(OverLoadAmount),0) OverLoadAmount
	FROM	prd.tblFormulasOverLoadDtl
	WHERE	ProductID = @ProductID AND SerialNo = @SerialNo
	And (OverLoadProductDtl=1 or (OverLoadProductDtl=0 and OverLoadDecompositionDtl=0))
END
GO
