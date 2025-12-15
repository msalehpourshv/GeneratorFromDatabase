USE TS_ShirinVatanKarkhaneh_1_1404
GO
SET ANSI_NULLS, QUOTED_IDENTIFIER ON
GO
-- =========== TS-QC:NOTOK =====================
-- Author        : Hadi Sadeghi
-- Create date   : 86/12/01
-- Viewed By	 : 
-- Last Modified : 
-- Description   : 
-- =============================================
CREATE FUNCTION [inv].[funGetGoodsRemain3]
(	
	@ProcessID		tinyint=null,
	@ProcessNo		tinyint=null,
	@FiscalYear		smallint=null,
	@SerialNo		int=null,
	@VolumeRowNo    float=NULL,
	@GoodsID		Varchar(20),
	@BatchNo		Varchar(20),
	@DocDate		Char(10),
	@UserPriceID    int=0
)
RETURNS decimal(38,5)
WITH ENCRYPTION
AS
BEGIN
	
	declare @ReservedSaleOrder  BIt
	SET @ReservedSaleOrder='False'

	SELECT @ReservedSaleOrder = SettingValue
	FROM pub.tblSettings
	WHERE SettingKey = 'ReservedSaleOrder'


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
	SELECT @QtyRemain = IsNull(Sum(GoodsQuantity * EnterKind) ,0)
	FROM   inv.tblStorageDocsDtl a 
	inner join (SELECT StoreID from inv.tblStores WHERE InventoryType=0 and InventoryOwnership=0 ) b
	ON a.StoreID=b.StoreID
	WHERE  GoodsID = @GoodsID  AND (@BatchNo = '' OR @BatchNo IS NULL OR BatchNo = @BatchNo) AND 
			DocDate <= @DocDate AND (FiscalYear=@FiscalYear ) AND (@UserPriceID =0 or UserPriceID=@UserPriceID)

	RETURN @QtyRemain 

END
GO
