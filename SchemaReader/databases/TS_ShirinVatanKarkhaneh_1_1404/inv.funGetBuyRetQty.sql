USE TS_ShirinVatanKarkhaneh_1_1404
GO
SET ANSI_NULLS, QUOTED_IDENTIFIER ON
GO
CREATE FUNCTION [inv].[funGetBuyRetQty](
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
	Declare @PID_BuyRet AS TinyInt

	Set @PID_BuyRet = 60 -- Buy Return ProcessID

	SELECT	@Result = IsNULL(Sum(GoodsQuantity), 0)
	FROM    inv.tblStorageDocsDtl
	WHERE   BaseProcessID = @ProcessID   AND BaseProcessNo = @ProcessNo AND
			BaseFiscalYear = @FiscalYear AND BaseSerialNo = @SerialNo AND
			BaseDocRowNo = @DocRowNo AND ProcessID = @PID_BuyRet
 
	Return @Result
End   -- === E N D ===============================================
GO
