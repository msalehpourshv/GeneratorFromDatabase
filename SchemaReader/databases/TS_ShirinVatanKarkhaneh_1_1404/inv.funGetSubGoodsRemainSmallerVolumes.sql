USE TS_ShirinVatanKarkhaneh_1_1404
GO
SET ANSI_NULLS, QUOTED_IDENTIFIER ON
GO
-- =========== TS-QC:NOTOK =====================
-- Author        : Hadi Sadeghi
-- Create date   : 95/03/30
-- Viewed By	 : 
-- Last Modified : 
-- Description   : 
-- =============================================
Create FUNCTION [inv].[funGetSubGoodsRemainSmallerVolumes]
(	
	@ProcessID		smallint=null,
	@ProcessNo		tinyint=null,
	@FiscalYear		smallint=null,
	@SerialNo		int=null,
	@VolumeRowNo    float=NULL,
	@StoreID		Varchar(20),
	@GoodsID		Varchar(20),
	@UnitID			Varchar(20),
	@DocDate		Char(10),
	@BatchNo		Varchar(20),
	@UserPriceID    int=0
)
RETURNS decimal(38,5)
WITH ENCRYPTION
AS
BEGIN
	
	IF @FiscalYear IS NULL OR @FiscalYear = 0
		SET @FiscalYear =  RIGHT(db_name(),4)
		
	DECLARE @QtyRemain Decimal(28,9)
	
	SET @QtyRemain =0
	DECLARE @str_Goods  tinyint,
			@str_GoodsSum tinyint,
			@UnitPart TINYINT

	SELECT @UnitPart = SettingValue from pub.tblSettings where SettingKey = 'UnitPart'

	IF @UnitPart IS NULL or @UnitPart = 0
		SET @UnitPart = 1

	select @str_Goods = ISNULL(SUM (Layer1+Layer2+Layer3+Layer4+Layer5+Layer6+Layer7+Layer8+Layer9),0)
	from pub.tblCodeLayer 
	where TableName='inv.tblGoods' AND PartNumber<@UnitPart

	select @str_GoodsSum = Layer1+Layer2+Layer3+Layer4+Layer5+Layer6+Layer7+Layer8+Layer9
	from pub.tblCodeLayer 
	where TableName= 'inv.tblGoods' AND PartNumber=@UnitPart

	IF (SELECT COUNT(GoodsID) FROM inv.tblGoods 
	    WHERE IsService='True' AND 
		      GoodsID=SUBSTRING(@GoodsID,@str_Goods+1,@str_GoodsSum) AND PartNumber=@UnitPart) = 1
		RETURN 1000000000
	
	IF @DocDate = '' OR @GoodsID = '' --OR @StoreID = ''
	BEGIN 
		RETURN 0
	END
	IF @BatchNo = '' OR @BatchNo IS NULL
		BEGIN
			IF @StoreID IS NULL OR @StoreID = ''
				BEGIN
					SELECT top 1 @QtyRemain = IsNull(Sum(CASE WHEN G.UnitID = @UnitID THEN GoodsQuantity * EnterKind ELSE case when a.SubUnitID=@UnitID THEN SubUnitQuantity * EnterKind ELSE GoodsQuantity*b.UnitValue/b.MainUnitValue * EnterKind END END),0) 
					FROM   inv.tblStorageDocsDtl a 
					INNER JOIN inv.tblGoods G ON SUBSTRING(@GoodsID,@str_Goods+1,@str_GoodsSum)=G.GoodsID AND PartNumber = @UnitPart
					Left join inv.tblSubUnitsDtl b on  (a.GoodsID=b.GoodsID  ) and (b.SubUnitID=@UnitID )
					WHERE  a.GoodsID = @GoodsID AND DocDate <= @DocDate AND FiscalYear=@FiscalYear AND (@UserPriceID =0 or UserPriceID=@UserPriceID)
				END
			ELSE IF @VolumeRowNo IS NULL
				BEGIN
					SELECT top 1 @QtyRemain = IsNull(Sum(CASE WHEN G.UnitID = @UnitID THEN GoodsQuantity * EnterKind ELSE case when a.SubUnitID=@UnitID THEN SubUnitQuantity * EnterKind ELSE GoodsQuantity*b.UnitValue/b.MainUnitValue * EnterKind END END),0) 
					FROM   inv.tblStorageDocsDtl a 
					INNER JOIN inv.tblGoods G ON SUBSTRING(@GoodsID,@str_Goods+1,@str_GoodsSum)=G.GoodsID AND PartNumber = @UnitPart
					Left join inv.tblSubUnitsDtl b on  (a.GoodsID=b.GoodsID  ) and (b.SubUnitID=@UnitID )
					WHERE  StoreID = @StoreID AND a.GoodsID = @GoodsID AND DocDate <= @DocDate AND FiscalYear=@FiscalYear AND (@UserPriceID =0 or UserPriceID=@UserPriceID)

				END
			ELSE
				BEGIN
					SELECT top 1 @QtyRemain = IsNull(Sum(CASE WHEN G.UnitID = @UnitID THEN GoodsQuantity * EnterKind ELSE case when a.SubUnitID=@UnitID THEN SubUnitQuantity * EnterKind ELSE GoodsQuantity*b.UnitValue/b.MainUnitValue * EnterKind END END) ,0)
					FROM   inv.tblStorageDocsDtl a 
					INNER JOIN inv.tblGoods G ON SUBSTRING(@GoodsID,@str_Goods+1,@str_GoodsSum)=G.GoodsID AND PartNumber = @UnitPart
					Left join inv.tblSubUnitsDtl b on  (a.GoodsID=b.GoodsID  ) and (b.SubUnitID=@UnitID )
					WHERE  StoreID = @StoreID AND a.GoodsID = @GoodsID  AND 
						 ((DocDate < @DocDate) OR (DocDate = @DocDate AND VolumeRowNo<= @VolumeRowNo))AND FiscalYear=@FiscalYear AND (@UserPriceID =0 or UserPriceID=@UserPriceID)

				END
		END
		ELSE
		BEGIN
			IF @StoreID IS NULL OR @StoreID = ''
				BEGIN
					SELECT top 1 @QtyRemain = IsNull(Sum(CASE WHEN G.UnitID = @UnitID THEN GoodsQuantity * EnterKind ELSE case when a.SubUnitID=@UnitID THEN SubUnitQuantity * EnterKind ELSE GoodsQuantity*b.UnitValue/b.MainUnitValue * EnterKind END END),0) 
					FROM   inv.tblStorageDocsDtl a 
					INNER JOIN inv.tblGoods G ON SUBSTRING(@GoodsID,@str_Goods+1,@str_GoodsSum)=G.GoodsID AND PartNumber = @UnitPart
					Left join inv.tblSubUnitsDtl b  on  (a.GoodsID=b.GoodsID  ) and (b.SubUnitID=@UnitID )
					WHERE  a.GoodsID = @GoodsID AND a.BatchNo = @BatchNo AND DocDate <= @DocDate AND FiscalYear=@FiscalYear AND (@UserPriceID =0 or UserPriceID=@UserPriceID)
				END
			ELSE IF @VolumeRowNo IS NULL
				BEGIN
					SELECT top 1 @QtyRemain = IsNull(Sum(CASE WHEN G.UnitID = @UnitID THEN GoodsQuantity * EnterKind ELSE case when a.SubUnitID=@UnitID THEN SubUnitQuantity * EnterKind ELSE GoodsQuantity*b.UnitValue/b.MainUnitValue * EnterKind END END),0) 
					FROM   inv.tblStorageDocsDtl a 
					INNER JOIN inv.tblGoods G ON SUBSTRING(@GoodsID,@str_Goods+1,@str_GoodsSum)=G.GoodsID AND PartNumber = @UnitPart
					Left join inv.tblSubUnitsDtl b  on  (a.GoodsID=b.GoodsID  ) and (b.SubUnitID=@UnitID )
					WHERE  StoreID = @StoreID AND a.GoodsID = @GoodsID AND a.BatchNo = @BatchNo AND DocDate <= @DocDate AND FiscalYear=@FiscalYear AND (@UserPriceID =0 or UserPriceID=@UserPriceID)

				END
			ELSE
				BEGIN
					SELECT top 1 @QtyRemain = IsNull(Sum(CASE WHEN G.UnitID = @UnitID THEN GoodsQuantity * EnterKind ELSE case when a.SubUnitID=@UnitID THEN SubUnitQuantity * EnterKind ELSE GoodsQuantity*b.UnitValue/b.MainUnitValue * EnterKind END END) ,0)
					FROM   inv.tblStorageDocsDtl a 
					INNER JOIN inv.tblGoods G ON SUBSTRING(@GoodsID,@str_Goods+1,@str_GoodsSum)=G.GoodsID AND PartNumber = @UnitPart
					Left join inv.tblSubUnitsDtl b  on  (a.GoodsID=b.GoodsID  ) and (b.SubUnitID=@UnitID )
					WHERE  StoreID = @StoreID AND a.GoodsID = @GoodsID  AND a.BatchNo = @BatchNo AND 
						 ((DocDate < @DocDate) OR (DocDate = @DocDate AND VolumeRowNo <> @VolumeRowNo))AND FiscalYear=@FiscalYear AND (@UserPriceID =0 or UserPriceID=@UserPriceID)

				END
		END


	IF @QtyRemain -ROUND(@QtyRemain,5)<0
		SET @QtyRemain = @QtyRemain -0.000009
		
	RETURN @QtyRemain 

END
GO
