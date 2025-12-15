USE TS_ShirinVatanKarkhaneh_1_1404
GO
SET ANSI_NULLS, QUOTED_IDENTIFIER ON
GO
CREATE FUNCTION [sal].[funGetSaleCancelQty] -- Not Used // Dont Use this function its heavy to execute //
(
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

	SELECT	@Result = IsNull(Sum(CNL.ConfirmQuantity), 0)
	FROM	sal.tblSaleOrderDtl AS CNL
	WHERE	CNL.BaseProcessID  = @ProcessID  AND CNL.BaseProcessNo = @ProcessNo AND
			CNL.BaseFiscalYear = @FiscalYear AND CNL.BaseSerialNo  = @SerialNo  AND
			CNL.BaseDocRowNo   = @DocRowNo
 
	Return @Result
End   -- === E N D ===============================================






















GO
