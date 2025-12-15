USE TS_ShirinVatanKarkhaneh_1_1404
GO
SET ANSI_NULLS, QUOTED_IDENTIFIER ON
GO
CREATE FUNCTION [inv].[funExistInFormula_Recursive]
(
	@ProductID	NVarChar(20),
	@GoodsID	NVarChar(20), 
	@SerialNo	Int,
	@RowNo		Int
)
RETURNS Bit
WITH ENCRYPTION
AS
------------------------------------------------------------------
-- This function checks whether a goods exists -------------------
-- in formula details of a product or not ------------------------
------------------------------------------------------------------
Begin -- === S T A R T ===========================================

	DECLARE @Result AS Bit;
	Set @Result = 0;

	WITH tblTemp(GoodsID) AS
    (
		SELECT FD.GoodsID
        FROM   prd.tblFormulasDtl FD
		WHERE  FD.ProductID = @ProductID And NOT (FD.ProductID=@GoodsID AND SerialNo=@SerialNo AND RowNo=@RowNo)

		UNION All
		
		SELECT FD.GoodsID
        FROM   prd.tblFormulasDtl FD CROSS JOIN tblTemp
		WHERE  (FD.ProductID = tblTemp.GoodsID) And NOT (FD.ProductID=@GoodsID AND SerialNo=@SerialNo AND RowNo=@RowNo)
	)
	
	SELECT @Result = Count(*)
	FROM   tblTemp
	WHERE  GoodsID = @GoodsID

	Return @Result;
End   -- === E N D ===============================================
GO
