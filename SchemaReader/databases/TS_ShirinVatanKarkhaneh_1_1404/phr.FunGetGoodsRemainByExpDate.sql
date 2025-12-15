USE TS_ShirinVatanKarkhaneh_1_1404
GO
SET ANSI_NULLS, QUOTED_IDENTIFIER ON
GO

CREATE FUNCTION [phr].[FunGetGoodsRemainByExpDate]
(
	@GoodsID VarChar(20), 
	@DocDate Char(10), 
	@ExpDate Char(10), 
	@FiscalYear INT,
	@StoreID AS VARCHAR(20)

)
	RETURNS FLOAT
WITH ENCRYPTION
AS

Begin -- ====================================================


	Declare @StrResult AS FLOAT
	
		SELECT @StrResult= IsNull(Sum(GoodsQuantity * EnterKind),0)
		FROM   inv.tblStorageDocsDtl
		WHERE  GoodsID = @GoodsID
		AND DocDate <= @DocDate AND FiscalYear=@FiscalYear AND [ExpireDate] <> '' 
		AND StoreID=@StoreID
		AND [ExpireDate]=@ExpDate
		
		GROUP BY [ExpireDate]

	IF @StrResult IS NULL 
	BEGIN
		SET @StrResult=0
	END
	
	Return @StrResult

END -- ======================================================
GO
