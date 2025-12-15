USE TS_ShirinVatanKarkhaneh_1_1404
GO
SET ANSI_NULLS, QUOTED_IDENTIFIER ON
GO
Create FUNCTION inv.funGetGoodsSubQuantityBase
(
	@GoodsID as nvarchar(20), 
	@SubUnitID as nvarchar(20),
	@GoodsQuantity as float	,
	@SubUnitQuantity as float,
	@str_Goods  tinyint,
	@str_GoodsSum tinyint
)
RETURNS float
WITH ENCRYPTION
AS
BEGIN
	--DECLARE @str_Goods  tinyint,@str_GoodsSum tinyint
	DECLARE	@RetQty as float
	--DECLARE @UnitPart TINYINT

	--SET @UnitPart  = 1
	--SELECT @UnitPart = SettingValue from pub.tblSettings where SettingKey = 'UnitPart'

	--IF @UnitPart IS NULL or @UnitPart = 0
	--	SET @UnitPart = 1
	--select @str_Goods = ISNULL(SUM (Layer1+Layer2+Layer3+Layer4+Layer5+Layer6+Layer7+Layer8+Layer9),0)
	--	from pub.tblCodeLayer 
	--	where TableName='inv.tblGoods' AND PartNumber<@UnitPart

	--select @str_GoodsSum = Layer1+Layer2+Layer3+Layer4+Layer5+Layer6+Layer7+Layer8+Layer9
	--	from pub.tblCodeLayer 
	--	where TableName= 'inv.tblGoods' AND PartNumber=@UnitPart
	if @SubUnitID IS NULL
		return @GoodsQuantity
	if @SubUnitQuantity =@GoodsQuantity
		return @GoodsQuantity
	declare @Unit as varchar(20)

	select @Unit =	UnitID   
		from inv.tblGoods
		where GoodsID = SUBSTRING(@GoodsID,@str_Goods+1,@str_GoodsSum)

	If @Unit = @SubUnitID 
		return @GoodsQuantity
--==============

	SELECT   @RetQty=  case when @SubUnitID = SubUnitID  then @SubUnitQuantity else  @GoodsQuantity * (SU.UnitValue / SU.MainUnitValue)  end  	
	from inv.tblSubUnitsDtl SU where ShowInInvoice='True' and  @GoodsID = SU.GoodsID
	 
return  isnull(round( @RetQty,10),0)

END

GO
