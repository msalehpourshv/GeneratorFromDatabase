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
CREATE FUNCTION [inv].[funGetGoodsRemain2]
(	
	@ProcessID		tinyint=NULL,
	@ProcessNo		tinyint=NULL,
	@FiscalYear		smallint=NULL,
	@SerialNo		int=NULL,
	@VolumeRowNo    float=NULL,
	@StoreID		Varchar(20),
	@GoodsID		Varchar(20),
	@BatchNo		Varchar(20),
	@DocDate		Char(10),
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
					WHERE  GoodsID = @GoodsID AND DocDate <= @DocDate AND FiscalYear=@FiscalYear AND (@UserPriceID =0 or UserPriceID=@UserPriceID)
				END
			ELSE IF @VolumeRowNo IS NULL
				BEGIN
					SELECT @QtyRemain = IsNull(Sum(GoodsQuantity * EnterKind),0) 
					FROM   inv.tblStorageDocsDtl
					WHERE  StoreID = @StoreID AND GoodsID = @GoodsID AND DocDate <= @DocDate AND FiscalYear=@FiscalYear  AND (@UserPriceID =0 or UserPriceID=@UserPriceID)
				END
			ELSE
				BEGIN
					SELECT @QtyRemain = IsNull(Sum(GoodsQuantity * EnterKind) ,0)
					FROM   inv.tblStorageDocsDtl
					WHERE  StoreID = @StoreID AND GoodsID = @GoodsID  AND 
						 ((DocDate < @DocDate) OR (DocDate = @DocDate AND VolumeRowNo<= @VolumeRowNo))AND FiscalYear=@FiscalYear AND (@UserPriceID =0 or UserPriceID=@UserPriceID)
				END
		END
	ELSE
		BEGIN
			IF @StoreID IS NULL OR @StoreID = ''
				BEGIN
					SELECT @QtyRemain = IsNull(Sum(GoodsQuantity * EnterKind),0) 
					FROM   inv.tblStorageDocsDtl
					WHERE  GoodsID = @GoodsID AND BatchNo = @BatchNo AND DocDate <= @DocDate AND FiscalYear=@FiscalYear AND (@UserPriceID =0 or UserPriceID=@UserPriceID)
				END
			ELSE IF @VolumeRowNo IS NULL
				BEGIN
					SELECT @QtyRemain = IsNull(Sum(GoodsQuantity * EnterKind),0) 
					FROM   inv.tblStorageDocsDtl
					WHERE  StoreID = @StoreID AND GoodsID = @GoodsID AND BatchNo = @BatchNo AND DocDate <= @DocDate AND FiscalYear=@FiscalYear AND (@UserPriceID =0 or UserPriceID=@UserPriceID)
				END
			ELSE
				BEGIN
					SELECT @QtyRemain = IsNull(Sum(GoodsQuantity * EnterKind) ,0)
					FROM   inv.tblStorageDocsDtl
					WHERE  StoreID = @StoreID AND GoodsID = @GoodsID  AND BatchNo = @BatchNo AND 
						 ((DocDate < @DocDate) OR (DocDate = @DocDate AND VolumeRowNo<= @VolumeRowNo))AND FiscalYear=@FiscalYear AND (@UserPriceID =0 or UserPriceID=@UserPriceID)
				END
		END

	-- ==========
	DECLARE @QuantityDecimalsToForms AS Int

	SET		@QuantityDecimalsToForms = 3
	SELECT  @QuantityDecimalsToForms=SettingValue
	FROM pub.tblSettings
	WHERE SettingKey = 'QuantityDecimalsToForms'

	IF @QuantityDecimalsToForms>0
		SET		@QuantityDecimalsToForms = @QuantityDecimalsToForms - 1
		
	-- ===================================
	IF @ProcessID IS NOT NULL AND @ProcessID>0 AND @SerialNo IS NOT NULL AND @SerialNo>0  AND @FiscalYear IS NOT NULL AND @FiscalYear>0 AND @VolumeRowNo IS NOT NULL AND @VolumeRowNo>0 
		SELECT @QtyRemain = Round(@QtyRemain * b.UnitValue/b.MainUnitValue, @QuantityDecimalsToForms)
		FROM   inv.tblStorageDocsDtl a
		INNER Join inv.tblSubUnitsDtl b
		ON a.GoodsID=b.GoodsID and a.SubUnitID=b.SubUnitID
		WHERE  StoreID = @StoreID AND a.GoodsID = @GoodsID  AND 
		 DocDate = @DocDate AND FiscalYear=@FiscalYear AND ProcessID = @ProcessID AND ProcessNo=@ProcessNo AND FiscalYear=@FiscalYear and SerialNo=@SerialNo AND VolumeRowNo=@VolumeRowNo
	
	RETURN @QtyRemain 

END
GO
