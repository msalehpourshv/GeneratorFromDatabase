USE TS_ShirinVatanKarkhaneh_1_1404
GO
SET ANSI_NULLS, QUOTED_IDENTIFIER ON
GO

-- =========== TS-QC:NOTOK =====================
-- Author        : Hadi Sadeghi
-- Create date   : 90/01/28
-- Viewed By	 : 
-- Last Modified : 
-- Description   : 
-- =============================================
CREATE FUNCTION [inv].[FunGetGoodsAmount] 
(
	@ProcessID	Int,
	@ProcessNo	TinyInt,
	@FiscalYear	SmallInt,
	@SerialNo	Int,
	@DocRowNo	Int
)
RETURNS float
WITH ENCRYPTION
AS
BEGIN
	
	Declare @GoodsAmount  as Float
	SET @GoodsAmount = 0
	
	SELECT @GoodsAmount = GoodsAmount12 
	FROM inv.tblStorageDocsDtl
	WHERE	ProcessID=@ProcessID	AND
			ProcessNo=@ProcessNo	AND
			FiscalYear=@FiscalYear	AND
			SerialNo=@SerialNo		AND
			DocRowNo=@DocRowNo

	RETURN @GoodsAmount
	
END
GO
