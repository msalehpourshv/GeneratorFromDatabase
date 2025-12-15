USE TS_ShirinVatanKarkhaneh_1_1404
GO
SET ANSI_NULLS, QUOTED_IDENTIFIER ON
GO
-- =========== TS-QC:UPDATED ====================
-- Author		 : TakroSystem\Jafari
-- Create date   : 1401/09/13
-- Viewed By	 : 
-- Last Modified : 
-- Last Modifier : 
-- ----------------------------------------------
-- Description	 : بررسی تناسب واحد کالا در کارت به کارت
-- ==============================================
Create procedure inv.spCardToCardTest
 @GoodsID as VARCHAR(20),
 @GoodsID2 as VARCHAR(20),
 @UnitID AS VARCHAR(20) 
WITH ENCRYPTION
AS
BEGIN

Declare @UnitID1		VARCHAR(20) 
Declare @UnitID2		VARCHAR(20) 
Declare @UnitValue1		float
Declare @MainUnitValue1	float
Declare @UnitValue2		float
Declare @MainUnitValue2	float
DECLARE @UnitPart		TINYINT
DECLARE @str_Goods		TINYINT
DECLARE @str_GoodsSum	TINYINT

	SET @UnitPart  = 1
	SELECT @UnitPart = SettingValue from pub.tblSettings where SettingKey = 'UnitPart'

	IF @UnitPart IS NULL or @UnitPart = 0
		SET @UnitPart = 1

	select @str_Goods = ISNULL(SUM (Layer1+Layer2+Layer3+Layer4+Layer5+Layer6+Layer7+Layer8+Layer9),0)
	from pub.tblCodeLayer 
	where TableName='inv.tblGoods' AND PartNumber<@UnitPart

	select @str_GoodsSum = Layer1+Layer2+Layer3+Layer4+Layer5+Layer6+Layer7+Layer8+Layer9
	from pub.tblCodeLayer 
	where TableName= 'inv.tblGoods' AND PartNumber=@UnitPart

	set @GoodsID=SUBSTRING(@GoodsID,@str_Goods+1,@str_GoodsSum)
	set @GoodsID2=SUBSTRING(@GoodsID2,@str_Goods+1,@str_GoodsSum)

	if ((select UnitID from inv.tblGoods where GoodsID =@GoodsID AND PartNumber=@UnitPart ) =@UnitID and (select UnitID from inv.tblGoods where GoodsID =@GoodsID2 AND PartNumber=@UnitPart) =@UnitID)
	 begin
		 Select  1 RetType , ''RetDesc
		 return 
	 end 
	if ((select UnitID from inv.tblGoods where GoodsID =@GoodsID AND PartNumber=@UnitPart) =@UnitID and (select UnitID from inv.tblGoods where GoodsID =@GoodsID2 AND PartNumber=@UnitPart) <>@UnitID)
	 begin
		Select  0 RetType, 'واحد ورودی برای  کالای اول اصلی  و برای کالای دوم واحد فرعی میباشد ' RetDesc
		 return 
	 end 
	if ((select UnitID from inv.tblGoods where GoodsID =@GoodsID AND PartNumber=@UnitPart) <>@UnitID and (select UnitID from inv.tblGoods where GoodsID =@GoodsID2 AND PartNumber=@UnitPart) =@UnitID)
	 begin
		Select  0 RetType, 'واحد ورودی برای  کالای اول فرعی  و برای کالای دوم واحد اصلی میباشد ' RetDesc
		 return 
	 end 
	if (select count(*) from inv.tblSubUnitsDtl where GoodsID =@GoodsID and SubUnitID= @UnitID) <=0
	 begin
		Select 0 RetType, 'واحد ورودی برای  کالای اول پیدا نشد ' RetDesc
		 return 
	 end 
	if (select count(*) from inv.tblSubUnitsDtl where GoodsID =@GoodsID2 and SubUnitID= @UnitID ) <=0
	 begin
		Select 0 RetType, 'واحد ورودی برای  کالای دوم پیدا نشد ' RetDesc
		 return 
	 end 	
	
	select @UnitValue1=UnitValue,@MainUnitValue1=MainUnitValue  from inv.tblSubUnitsDtl where GoodsID =@GoodsID and SubUnitID= @UnitID 
	select @UnitValue2=UnitValue,@MainUnitValue2=MainUnitValue  from inv.tblSubUnitsDtl where GoodsID =@GoodsID2 and SubUnitID= @UnitID 
		
	if @MainUnitValue1 / @UnitValue1 <> @MainUnitValue2/@UnitValue2
	 begin
		Select 0 RetType, 'تناسب واحد اصلی و فرعی برای کالای اول و دوم یکسان نیست  ' RetDesc
		 return 
	 end 
	

	Select  1 RetType , ''RetDesc
		
END
GO
