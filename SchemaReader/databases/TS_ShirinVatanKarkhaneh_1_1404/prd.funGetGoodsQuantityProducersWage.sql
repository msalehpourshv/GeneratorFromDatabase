USE TS_ShirinVatanKarkhaneh_1_1404
GO
SET ANSI_NULLS, QUOTED_IDENTIFIER ON
GO
CREATE FUNCTION [prd].[funGetGoodsQuantityProducersWage] 
(
	@AcntCode VarChar(20) ,
	@GoodsID VarChar(20),
	@ContractSerialNo Int
)
RETURNS decimal(28,9)
WITH ENCRYPTION
AS

BEGIN
	DECLARE @Resulat decimal(28,9)
	SET @Resulat=0
	SELECT TOP 1 @Resulat=GoodsQuantity 
        FROM  prd.tblProducersWageDtl 
		WHERE ProducerAcntCode = @AcntCode AND GoodsID =  SUBSTRING(@GoodsID ,1,LEN(GoodsID))
	AND (@ContractSerialNo = 0 OR SerialNo=@ContractSerialNo)		
	ORDER BY SerialNo desc

	RETURN @Resulat  
END
GO
