USE TS_ShirinVatanKarkhaneh_1_1404
GO
SET ANSI_NULLS, QUOTED_IDENTIFIER ON
GO
CREATE FUNCTION [inv].[funGetSaleTypeID](
	@ProcessID	SmallInt,
	@ProcessNo	TinyInt,
	@FiscalYear	SmallInt,
	@SerialNo	Int
)
RETURNS VarChar(20)
WITH ENCRYPTION
AS
Begin -- === S T A R T ===========================================

	DECLARE @Result AS VarChar(20)

	IF @ProcessID = 90
		SELECT	@Result = SaleTypeID
		FROM	inv.tblStorageDocsHdr S
		WHERE	S.ProcessID = @ProcessID AND 
				S.ProcessNo = @ProcessNo AND
				S.SerialNo	= @SerialNo AND  
				S.FiscalYear= @FiscalYear
	Else
		SELECT @Result = Null
 
	Return @Result
End 

GO
