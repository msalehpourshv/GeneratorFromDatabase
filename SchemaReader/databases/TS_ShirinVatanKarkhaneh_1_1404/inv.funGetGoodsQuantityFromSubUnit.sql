USE TS_ShirinVatanKarkhaneh_1_1404
GO
SET ANSI_NULLS, QUOTED_IDENTIFIER ON
GO
-- =========== TS-QC:UPDATED ====================
-- Author		 : TakroSystem\Jafari
-- Create date   : 1395/11/19
-- Viewed By	 : 
-- Last Modified : 
-- Last Modifier : 
-- Description	 : مقدار واحد اصلی براساس واحد فرعی کالا
-- ==============================================
Create FUNCTION [inv].[funGetGoodsQuantityFromSubUnit]
(
 @GoodsID varchar(20),
 @SubUnitID varchar(20) ,
 @GoodsQuantity decimal(28,9)
)
RETURNS Float
WITH ENCRYPTION
AS
BEGIN

	
DECLARE @UnitID varchar(20) 
DECLARE @NewGoodsQuantity decimal(28,9)
DECLARE @Inv_MultiGoodsID bit

SELECT @UnitID = isnull(UnitID,'')  
FROM inv.tblGoods 
WHERE GoodsID = @GoodsID

SELECT @Inv_MultiGoodsID = SettingValue 
FROM pub.tblSettings 
WHERE SettingKey = 'Inv_MultiGoodsID'

IF  @Inv_MultiGoodsID<>0
	
	BEGIN
	DECLARE @UnitPart BIT
	SELECT @UnitPart = SettingValue 
	FROM pub.tblSettings 
	WHERE SettingKey = 'UnitPart'


	DECLARE @Part1Start	TinyInt,@Part1Len	TinyInt;
	DECLARE @Part2Start	TinyInt,@Part2Len	TinyInt;
	DECLARE @Part3Start	TinyInt,@Part3Len	TinyInt;
	DECLARE @Part4Start	TinyInt,@Part4Len	TinyInt;

		-------- LAYERS LEN CLAUSE -----------------------------------------------------------------------
	SELECT @Part1Start = 1;
	SELECT @Part1Len = Layer1 + Layer2 + Layer3 + Layer4 + Layer5 + Layer6 + Layer7 + Layer8 + Layer9 
	FROM pub.tblCodeLayer 
	WHERE (TableName = 'inv.tblGoods') 
	  AND (PartNumber = 1)

	SELECT @Part2Start = @Part1Start + @Part1Len + 1;
	SELECT @Part2Len = Layer1 + Layer2 + Layer3 + Layer4 + Layer5 + Layer6 + Layer7 + Layer8 + Layer9 
	FROM pub.tblCodeLayer 
	WHERE (TableName = 'inv.tblGoods') 
	  AND (PartNumber = 2)

	SELECT @Part3Start = @Part2Start + @Part2Len + 1;
	SELECT @Part3Len = Layer1 + Layer2 + Layer3 + Layer4 + Layer5 + Layer6 + Layer7 + Layer8 + Layer9 
	FROM pub.tblCodeLayer 
	WHERE (TableName = 'inv.tblGoods') 
	  AND (PartNumber = 3)

	SELECT @Part4Start = @Part3Start + @Part3Len + 1;
	SELECT @Part4Len = Layer1 + Layer2 + Layer3 + Layer4 + Layer5 + Layer6 + Layer7 + Layer8 + Layer9 
	FROM pub.tblCodeLayer 
	WHERE (TableName = 'inv.tblGoods') 
	  AND (PartNumber = 4)
	
	DECLARE @GoodsID2 VARCHAR(20) = ''

	IF @UnitPart=1
		SET @GoodsID2 = substring(@GoodsID,1,@Part1Len)
	IF @UnitPart=2
		SET @GoodsID2 = substring(@GoodsID,1+@Part1Len,@Part2Len)
	IF @UnitPart=3
		SET @GoodsID2 = substring(@GoodsID,1+@Part1Len+@Part2Len,@Part3Len)
	IF @UnitPart=4
		SET @GoodsID2 = substring(@GoodsID,1+@Part1Len+@Part2Len+@Part3Len,@Part4Len)
		
	SELECT @UnitID = UnitID 
	From inv.tblGoods 
	WHERE GoodsID = @GoodsID2
		
	END
	
	IF @UnitID <> @SubUnitID 
		SELECT TOP 1 @NewGoodsQuantity = @GoodsQuantity * MainUnitValue / UnitValue
		FROM inv.tblSubUnitsDtl 
		WHERE (GoodsID = @GoodsID or GoodsID = '' ) 
		  AND SubUnitID = @SubUnitID
		ORDER BY GoodsID desc

	ELSE
		SET @NewGoodsQuantity = isnull(@GoodsQuantity,0)
			
	RETURN isnull( @NewGoodsQuantity,0)
END
GO
