USE TS_ShirinVatanKarkhaneh_1_1404
GO
SET ANSI_NULLS, QUOTED_IDENTIFIER ON
GO

create FUNCTION [sal].[funGetUnitQuantity]
(
 @GoodsID as VARCHAR(20),
 @UnitID AS VARCHAR(20),
 @Quantity DECIMAL(28,5)
)

RETURNS FLOAT
WITH ENCRYPTION
AS
BEGIN
	
	 DECLARE @MainUnitValue FLOAT
	 DECLARE @UnitValue FLOAT
	 DECLARE @Q FLOAT
	 DECLARE @Result FLOAT
	 
	 SET @Q  =null
	 	 
	IF (select COUNT(*) from inv.tblGoods
		WHERE GoodsID=@GoodsID AND UnitID=@UnitID)=0
	BEGIN
		SELECT top 1 @MainUnitValue=MainUnitValue,@UnitValue=UnitValue  
		FROM inv.tblSubUnitsDtl
		WHERE (GoodsID = @GoodsID OR GoodsID='') AND SubUnitID=@UnitID
	    ORDER BY GoodsID desc
		
		set @Q = @Quantity * (@MainUnitValue/@UnitValue)
	END

		IF (@Q IS NULL) SET @Result=@Quantity
			
		IF NOT(@Q IS NULL) SET @Result=@Q	
	
 RETURN @Result
		
END

GO
