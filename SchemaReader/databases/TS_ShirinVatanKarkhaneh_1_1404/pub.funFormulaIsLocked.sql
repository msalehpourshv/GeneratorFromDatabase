USE TS_ShirinVatanKarkhaneh_1_1404
GO
SET ANSI_NULLS, QUOTED_IDENTIFIER ON
GO
CREATE FUNCTION [pub].[funFormulaIsLocked]
(
	@GoodsID		Varchar(20),
	@FormulaNo		Int
)
RETURNS Bit
WITH ENCRYPTION

AS
BEGIN
	
	DECLARE @Result Bit

	SET @Result = 'False'
	
	SELECT TOP 1 @Result = 'True' 
	FROM inv.tblStorageDocsHdr 
	WHERE ProductID = @GoodsID AND FormulaNo = @FormulaNo 

	IF @Result = 'False'
		SELECT TOP 1 @Result = 'True' 
		FROM inv.tblStorageDocsDtl 
		WHERE ProcessID IN (80,72,73,74) AND GoodsID = @GoodsID AND FormulaNo = @FormulaNo 
				
	RETURN @Result

END
GO
