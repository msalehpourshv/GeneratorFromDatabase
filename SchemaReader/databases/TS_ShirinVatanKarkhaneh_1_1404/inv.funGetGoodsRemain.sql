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
CREATE FUNCTION [inv].[funGetGoodsRemain]
(	
	@ProcessID		int=null,
	@ProcessNo		tinyint=null,
	@FiscalYear		smallint=null,
	@SerialNo		int=null,
	@VolumeRowNo    float=NULL,
	@StoreID		Varchar(20),
	@GoodsID		Varchar(20),
	@BatchNo		Varchar(20),
	@DocDate		Char(10),
	@UserPriceID    int=0
)
RETURNS float --decimal(38,5)
WITH ENCRYPTION
AS
BEGIN
	
	declare @ReservedSaleOrder  BIt
	DECLARE @OtherFiscalYear		varchar(1)
	SET @OtherFiscalYear  = '0'

	SET @ReservedSaleOrder='False'

	SELECT @OtherFiscalYear = SettingValue from pub.tblSettings where SettingKey = 'OtherFiscalYear'
	IF @OtherFiscalYear IS NULL 
		SET @OtherFiscalYear = '0'

	SELECT @ReservedSaleOrder = SettingValue
	FROM pub.tblSettings
	WHERE SettingKey = 'ReservedSaleOrder'

	IF @FiscalYear IS NULL OR @FiscalYear = 0
		SET @FiscalYear = RIGHT(db_name(),4)
	
	IF @OtherFiscalYear <>'0'
		SET @FiscalYear = 0

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
	IF @ProcessID>0 and @ProcessNo>0 and @SerialNo>0 and @FiscalYear>0 and @VolumeRowNo>0 and @StoreID<>''
		BEGIN
			SELECT @QtyRemain = IsNull(Sum(GoodsQuantity * EnterKind) ,0)
			FROM   inv.tblStorageDocsDtl
			WHERE  StoreID = @StoreID AND GoodsID = @GoodsID  AND BatchNo = @BatchNo AND 
					((DocDate < @DocDate) OR (DocDate = @DocDate AND VolumeRowNo<= @VolumeRowNo))AND (FiscalYear=@FiscalYear ) AND (UserPriceID=@UserPriceID)

		END
	ELSE IF @BatchNo = '' OR @BatchNo IS NULL
		BEGIN
			IF @StoreID IS NULL OR @StoreID = ''
				BEGIN
					SELECT @QtyRemain = IsNull(Sum(GoodsQuantity * EnterKind),0) 
					FROM   inv.tblStorageDocsDtl
					WHERE  GoodsID = @GoodsID AND DocDate <= @DocDate AND (@FiscalYear = 0 OR FiscalYear=@FiscalYear ) AND (@UserPriceID =0 or UserPriceID=@UserPriceID)
				END
			ELSE IF @VolumeRowNo IS NULL
				BEGIN
					SELECT @QtyRemain = IsNull(Sum(GoodsQuantity * EnterKind),0) 
					FROM   inv.tblStorageDocsDtl
					WHERE  StoreID = @StoreID AND GoodsID = @GoodsID AND DocDate <= @DocDate AND (@FiscalYear = 0 OR FiscalYear=@FiscalYear )  AND (@UserPriceID =0 or UserPriceID=@UserPriceID)
				END
			ELSE
				BEGIN
					SELECT @QtyRemain = IsNull(Sum(GoodsQuantity * EnterKind) ,0)
					FROM   inv.tblStorageDocsDtl
					WHERE  StoreID = @StoreID AND GoodsID = @GoodsID  AND 
						 ((DocDate < @DocDate) OR (DocDate = @DocDate AND VolumeRowNo<= @VolumeRowNo))AND (@FiscalYear = 0 OR FiscalYear=@FiscalYear ) AND (@UserPriceID =0 or UserPriceID=@UserPriceID)
				END
		END
	ELSE
		BEGIN
			IF @StoreID IS NULL OR @StoreID = ''
				BEGIN
					SELECT @QtyRemain = IsNull(Sum(GoodsQuantity * EnterKind),0) 
					FROM   inv.tblStorageDocsDtl
					WHERE  GoodsID = @GoodsID AND BatchNo = @BatchNo AND DocDate <= @DocDate AND (@FiscalYear = 0 OR FiscalYear=@FiscalYear ) AND (@UserPriceID =0 or UserPriceID=@UserPriceID)
				END
			ELSE IF @VolumeRowNo IS NULL
				BEGIN
					SELECT @QtyRemain = IsNull(Sum(GoodsQuantity * EnterKind),0) 
					FROM   inv.tblStorageDocsDtl
					WHERE  StoreID = @StoreID AND GoodsID = @GoodsID AND BatchNo = @BatchNo AND DocDate <= @DocDate AND (@FiscalYear = 0 OR FiscalYear=@FiscalYear ) AND (@UserPriceID =0 or UserPriceID=@UserPriceID)
				END
			ELSE
				BEGIN
					SELECT @QtyRemain = IsNull(Sum(GoodsQuantity * EnterKind) ,0)
					FROM   inv.tblStorageDocsDtl
					WHERE  StoreID = @StoreID AND GoodsID = @GoodsID  AND BatchNo = @BatchNo AND 
						 ((DocDate < @DocDate) OR (DocDate = @DocDate AND VolumeRowNo<= @VolumeRowNo))AND (@FiscalYear = 0 OR FiscalYear=@FiscalYear ) AND (@UserPriceID =0 or UserPriceID=@UserPriceID)
				END
		END

	--IF @QtyRemain -ROUND(@QtyRemain,5)<0
	--	SET @QtyRemain = @QtyRemain -0.000009

	IF (@ProcessID = 90 OR @ProcessID = 180 ) AND 	@ReservedSaleOrder = 'True'
		SELECT  @QtyRemain = @QtyRemain - [sal].[funGetGoodsRemainMinesReserved](@GoodsID,@StoreID,@DocDate,@ProcessID,@ProcessNo,@FiscalYear,@SerialNo)
		
	RETURN @QtyRemain 

END
GO
