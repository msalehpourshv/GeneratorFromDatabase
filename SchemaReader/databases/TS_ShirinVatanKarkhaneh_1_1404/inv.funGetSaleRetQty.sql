USE TS_ShirinVatanKarkhaneh_1_1404
GO
SET ANSI_NULLS, QUOTED_IDENTIFIER ON
GO
CREATE FUNCTION [inv].[funGetSaleRetQty]( -- Not Used // Dont Use this function its heavy to execute //
	@ProcessID	TinyInt,
	@ProcessNo	TinyInt,
	@FiscalYear	SmallInt,
	@SerialNo	Int,
	@DocRowNo	Int
)
RETURNS Int
WITH ENCRYPTION
AS
Begin -- === S T A R T ===========================================

	Declare @Result AS Int

	SELECT	@Result = IsNull(Sum(GoodsQuantity), 0)
	FROM    inv.tblStorageDocsDtl
	WHERE   BaseProcessID = @ProcessID   AND BaseProcessNo = @ProcessNo AND
			BaseFiscalYear = @FiscalYear AND BaseSerialNo  = @SerialNo AND
			BaseDocRowNo = @DocRowNo
 
	Return @Result
End   -- === E N D ===============================================





GO
