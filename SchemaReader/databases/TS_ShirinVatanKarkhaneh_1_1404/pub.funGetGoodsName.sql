USE TS_ShirinVatanKarkhaneh_1_1404
GO
SET ANSI_NULLS, QUOTED_IDENTIFIER ON
GO
Create FUNCTION [pub].[funGetGoodsName] 
(
	@GoodsID Char(20) ,
	@LanguageID TinyInt
)
RETURNS NVarChar(500)
WITH ENCRYPTION
AS

BEGIN

	--SET @LanguageID = pub.funGetCurrentLanguageID();

	-- Declare the return variable here
	DECLARE @GoodsName NVarChar(500)

	DECLARE @str_Goods1layerSum tinyint,
			@str_Goods2layerSum tinyint,
			@str_Goods3layerSum tinyint,
			@str_Goods4layerSum tinyint,
			@str_Goods5layerSum tinyint

	select @str_Goods1layerSum = Layer1+Layer2+Layer3+Layer4+Layer5+Layer6+Layer7+Layer8+Layer9
	from pub.tblCodeLayer 
	where TableName='inv.tblGoods' AND PartNumber=1

	select @str_Goods2layerSum = Layer1+Layer2+Layer3+Layer4+Layer5+Layer6+Layer7+Layer8+Layer9
	from pub.tblCodeLayer 
	where TableName= 'inv.tblGoods' AND PartNumber=2

	select @str_Goods3layerSum = Layer1+Layer2+Layer3+Layer4+Layer5+Layer6+Layer7+Layer8+Layer9
	from pub.tblCodeLayer 
	where TableName='inv.tblGoods' AND PartNumber=3

	select @str_Goods4layerSum = Layer1+Layer2+Layer3+Layer4+Layer5+Layer6+Layer7+Layer8+Layer9
	from pub.tblCodeLayer 
	where TableName='inv.tblGoods' AND PartNumber=4

	select @str_Goods5layerSum = Layer1+Layer2+Layer3+Layer4+Layer5+Layer6+Layer7+Layer8+Layer9
	from pub.tblCodeLayer 
	where TableName='inv.tblGoods' AND PartNumber=5

	Set @GoodsName = N'-'

	SELECT @GoodsName = GoodsName 
	From inv.tblGoodsDtl 
	Where LanguageID = @LanguageID AND GoodsID = SUBSTRING(@GoodsID ,1,@str_Goods1layerSum) and PartNumber = 1

	IF @str_Goods2layerSum>0 AND LEN(@GoodsID) > @str_Goods1layerSum
		SELECT @GoodsName = @GoodsName + ' ' + GoodsName
		From inv.tblGoodsDtl 
		Where LanguageID = @LanguageID AND GoodsID =  SUBSTRING(@GoodsID ,@str_Goods1layerSum+1,@str_Goods2layerSum) and PartNumber = 2

	IF @str_Goods3layerSum>0 AND LEN(@GoodsID) > @str_Goods1layerSum + @str_Goods2layerSum
		SELECT @GoodsName = @GoodsName + ' ' + GoodsName 
		From inv.tblGoodsDtl 
		Where LanguageID = @LanguageID AND GoodsID = SUBSTRING(@GoodsID ,@str_Goods1layerSum+ @str_Goods2layerSum +1,@str_Goods3layerSum) and PartNumber = 3		

	IF @str_Goods4layerSum>0 AND LEN(@GoodsID) > @str_Goods1layerSum + @str_Goods2layerSum + @str_Goods3layerSum
		SELECT @GoodsName = @GoodsName + ' ' + GoodsName 
		From inv.tblGoodsDtl 
		Where LanguageID = @LanguageID AND GoodsID = SUBSTRING(@GoodsID ,@str_Goods1layerSum+ @str_Goods2layerSum + @str_Goods3layerSum +1,@str_Goods4layerSum) and PartNumber = 4

	IF @str_Goods5layerSum>0 AND LEN(@GoodsID) > @str_Goods1layerSum + @str_Goods2layerSum + @str_Goods3layerSum + @str_Goods4layerSum
		SELECT @GoodsName = @GoodsName + ' ' + GoodsName 
		From inv.tblGoodsDtl 
		Where LanguageID = @LanguageID AND GoodsID = SUBSTRING(@GoodsID ,@str_Goods1layerSum+ @str_Goods2layerSum + @str_Goods3layerSum + @str_Goods4layerSum +1,@str_Goods5layerSum) and PartNumber = 5
					
---------برای معکوس سازی نام کالاهایی که دارای ممیز بوده و معکوس نشان میدهد-------------------------------------------------------------------
	declare @UsefunReverseForCrystalForGoodsName as bit
	select @UsefunReverseForCrystalForGoodsName=isnull(SettingValue,0) from pub.tblSettings where SettingKey='UsefunReverseForCrystalForGoodsName'			

	if @UsefunReverseForCrystalForGoodsName='True'		
		set @GoodsName =pub.funReverseForCrystal(@GoodsName)
----------------------------------------------------------------------------

	-- Return the result of the function
	RETURN @GoodsName 

END
GO
