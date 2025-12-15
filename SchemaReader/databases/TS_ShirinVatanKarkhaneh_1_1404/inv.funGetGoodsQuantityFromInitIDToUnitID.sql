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
-- Description	 : مقدار واحد  فرعی  براساس واحد اصلی کالا
-- ==============================================
Create FUNCTION [inv].[funGetGoodsQuantityFromInitIDToUnitID]
(
	
 @GoodsID varchar(20),
 @SubUnitIDFrom varchar(20) ,
 @SubUnitIDTo varchar(20) ,
 @GoodsQuantity decimal(28,9)
)
RETURNS Float
WITH ENCRYPTION
AS
BEGIN

	
Declare @UnitID varchar(20) 
Declare @NewGoodsQuantity decimal(28,9)
Declare @Inv_MultiGoodsID as bit
DECLARE @Len tinyint
select @Len=Layer1+Layer2+Layer3+Layer4+Layer5+Layer6+Layer7+Layer8+Layer9 from pub.tblCodeLayer where TableName='inv.tblGoods' AND PartNumber=1

Select @UnitID=UnitID From inv.tblGoods where PartNumber =1 AND GoodsID=SUBSTRING(@GoodsID,1,@Len)


if @UnitID=@SubUnitIDFrom 
	SELECT @NewGoodsQuantity = [inv].[funGetSubUnitFromGoodsQuantity](@GoodsID,@SubUnitIDTo,@GoodsQuantity)
ELSE if @UnitID<>@SubUnitIDFrom 
BEGIN
	SELECT @GoodsQuantity =[inv].[funGetGoodsQuantityFromSubUnit](@GoodsID,@SubUnitIDFrom,@GoodsQuantity)
	SELECT @NewGoodsQuantity = [inv].[funGetSubUnitFromGoodsQuantity](@GoodsID,@SubUnitIDTo,@GoodsQuantity)
END


	return isnull( @NewGoodsQuantity,0)
END
GO
