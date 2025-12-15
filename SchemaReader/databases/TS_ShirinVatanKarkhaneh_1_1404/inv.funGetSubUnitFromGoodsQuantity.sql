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
Create FUNCTION [inv].[funGetSubUnitFromGoodsQuantity]
(
	
 @GoodsID varchar(20),
 @SubUnitID varchar(20) ,
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

--Select @Inv_MultiGoodsID =SettingValue from pub.tblSettings where SettingKey='Inv_MultiGoodsID'

if @UnitID<>@SubUnitID --or @Inv_MultiGoodsID<>0
	Select  top 1  @NewGoodsQuantity=@GoodsQuantity*UnitValue/MainUnitValue
	from inv.tblSubUnitsDtl 
	where (GoodsID=@GoodsID OR GoodsID='' ) and SubUnitID=@SubUnitID
	ORDER BY GoodsID desc
else
		set  @NewGoodsQuantity=@GoodsQuantity

	return isnull( @NewGoodsQuantity,0)
END
GO
