USE TS_ShirinVatanKarkhaneh_1_1404
GO
SET ANSI_NULLS, QUOTED_IDENTIFIER ON
GO
-- =========== TS-QC:NOTOK ========================
-- Author        : Hadi Sadeghi
-- Create date   : 89/10/19
-- Viewed By	 : 
-- Last Modified : 
-- Description   : 
-- =============================================
CREATE PROCEDURE [inv].[spSetGoodsPriceInDST] 

	 @ProcessID		Smallint,
	 @ProcessNo		Tinyint,
	 @FiscalYear	Smallint,
	 @SerialNo		Int,
	 @TypeOfTable	Varchar(20),--'INV','SOR','DST'
	 @SubUnitPrice  Bit='False'	

 WITH ENCRYPTION
AS

BEGIN
SET NOCOUNT ON;
	DECLARE @UnitPart TINYINT
	SET @UnitPart  = 1

	SELECT @UnitPart = SettingValue from pub.tblSettings where SettingKey = 'UnitPart'

	IF @UnitPart IS NULL or @UnitPart = 0
		SET @UnitPart = 1

	DECLARE @str_Goods  tinyint,
			@str_GoodsSum tinyint

	select @str_Goods = ISNULL(SUM (Layer1+Layer2+Layer3+Layer4+Layer5+Layer6+Layer7+Layer8+Layer9),0)
	from pub.tblCodeLayer 
	where TableName='inv.tblGoods' AND PartNumber<@UnitPart

	select @str_GoodsSum = Layer1+Layer2+Layer3+Layer4+Layer5+Layer6+Layer7+Layer8+Layer9
	from pub.tblCodeLayer 
	where TableName= 'inv.tblGoods' AND PartNumber=@UnitPart

	IF @TypeOfTable	= 'INV'
	BEGIN
		IF @SubUnitPrice = 'False'
		BEGIN
			UPDATE inv.tblStorageDocsDtl
			SET GoodsPrice = SubUnitPrice*SubUnitQuantity/GoodsQuantity
			FROM inv.tblStorageDocsDtl S
			INNER JOIN inv.tblSubUnitsDtl U
			ON U.GoodsID = S.GoodsID AND U.SubUnitID = S.SubUnitID
			WHERE ProcessID = @ProcessID AND
				  ProcessNo = @ProcessNo AND
				  FiscalYear = @FiscalYear AND
				  SerialNo = @SerialNo AND
				  GoodsQuantity<>0 and 
				  GoodsPrice <> SubUnitPrice*SubUnitQuantity/GoodsQuantity

			UPDATE inv.tblStorageDocsDtl
			SET GoodsPrice = S.SubUnitPrice
			FROM inv.tblStorageDocsDtl S
			INNER JOIN inv.tblGoods U
			ON U.GoodsID = SUBSTRING(S.GoodsID,@str_Goods+1,@str_GoodsSum) AND U.UnitID = S.SubUnitID
			WHERE S.ProcessID = @ProcessID AND 
				  S.ProcessNo = @ProcessNo AND
				  S.FiscalYear = @FiscalYear AND
				  S.SerialNo = @SerialNo AND 
				  U.PartNumber=@UnitPart AND
				  S.GoodsPrice <> S.SubUnitPrice

			UPDATE inv.tblStorageDocsDtl
			SET GoodsPrice = SubUnitPrice*SubUnitQuantity/GoodsQuantity
			FROM inv.tblStorageDocsDtl S
			INNER JOIN inv.tblSubUnitsDtl U
			ON U.GoodsID = '' AND U.SubUnitID = S.SubUnitID
			WHERE ProcessID = @ProcessID AND
				  ProcessNo = @ProcessNo AND
				  FiscalYear = @FiscalYear AND
				  SerialNo = @SerialNo AND
				  GoodsQuantity<>0 and (SELECT COUNT(*) FROM inv.tblGoods WHERE GoodsID=SUBSTRING(S.GoodsID,@str_Goods+1,@str_GoodsSum)  AND PartNumber=@UnitPart AND UnitID=S.SubUnitID ) = 0 AND 
				  (SELECT COUNT(*) FROM inv.tblSubUnitsDtl WHERE GoodsID=S.GoodsID AND UnitID=S.SubUnitID ) = 0 AND 
				  GoodsPrice <> SubUnitPrice*SubUnitQuantity/GoodsQuantity
				  
		END
		ELSE
		BEGIN
			UPDATE inv.tblStorageDocsDtl
			SET SubUnitPrice = S.SubUnitPrice2
			FROM inv.tblStorageDocsDtl S
			WHERE S.ProcessID = @ProcessID AND
				  S.ProcessNo = @ProcessNo AND
				  S.FiscalYear = @FiscalYear AND
				  S.SerialNo = @SerialNo  
		END
		IF @ProcessID  = 55 or @ProcessID  = 50 --OR @ProcessID  = 60
		BEGIN
			UPDATE inv.tblStorageDocsDtl
			SET GoodsAmount = GoodsPrice + ((AtomAmount - DiscountDtl) /GoodsQuantity)
			FROM inv.tblStorageDocsDtl 
			WHERE ProcessID = @ProcessID AND
				  ProcessNo = @ProcessNo AND
				  FiscalYear = @FiscalYear AND
				  SerialNo = @SerialNo AND 
				  GoodsQuantity<>0 and 
			      GoodsAmount <> GoodsPrice + ((AtomAmount- DiscountDtl)/GoodsQuantity)

			UPDATE inv.tblStorageDocsDtl
			SET GoodsAmount1 = GoodsAmount
			  , GoodsAmount2 = GoodsAmount
			  , GoodsAmount3 = GoodsAmount
			  , GoodsAmount4 = GoodsAmount
			  , GoodsAmount5 = GoodsAmount
			  , GoodsAmount6 = GoodsAmount
			  , GoodsAmount7 = GoodsAmount
			  , GoodsAmount8 = GoodsAmount
			  , GoodsAmount9 = GoodsAmount
			  , GoodsAmount10 = GoodsAmount
			  , GoodsAmount11 = GoodsAmount
			  , GoodsAmount12 = GoodsAmount
			FROM inv.tblStorageDocsDtl 
			WHERE ProcessID = @ProcessID AND
				  ProcessNo = @ProcessNo AND
				  FiscalYear = @FiscalYear AND
				  SerialNo = @SerialNo 

		END
	END		  
	ELSE IF  @TypeOfTable	= 'SOR' --AND @SubUnitPrice = 'False'
	BEGIN
		IF @SubUnitPrice = 'False'
		BEGIN
			UPDATE sal.tblSaleOrderDtl
			SET GoodsPrice = SubUnitPrice*SubUnitQuantity/GoodsQuantity
			FROM sal.tblSaleOrderDtl S
			INNER JOIN inv.tblSubUnitsDtl U
			ON U.GoodsID = S.GoodsID AND U.SubUnitID = S.SubUnitID
			WHERE ProcessID = @ProcessID AND
				  ProcessNo = @ProcessNo AND
				  FiscalYear = @FiscalYear AND
				  SerialNo = @SerialNo AND
				  GoodsQuantity<>0 and 
				  GoodsPrice <> SubUnitPrice*SubUnitQuantity/GoodsQuantity
				  
			UPDATE sal.tblSaleOrderDtl
			SET GoodsPrice = SubUnitPrice
			FROM sal.tblSaleOrderDtl S
			INNER JOIN inv.tblGoods U
			ON U.GoodsID = SUBSTRING(S.GoodsID,@str_Goods+1,@str_GoodsSum) AND U.UnitID = S.SubUnitID
			WHERE ProcessID = @ProcessID AND 
				  ProcessNo = @ProcessNo AND
				  FiscalYear = @FiscalYear AND
				  SerialNo = @SerialNo AND 
				  U.PartNumber=@UnitPart AND
				  S.GoodsPrice <> SubUnitPrice
				  
			UPDATE sal.tblSaleOrderDtl
			SET GoodsPrice = SubUnitPrice*SubUnitQuantity/GoodsQuantity
			FROM sal.tblSaleOrderDtl S
			INNER JOIN inv.tblSubUnitsDtl U
			ON U.GoodsID = ''  AND U.SubUnitID = S.SubUnitID
			WHERE ProcessID = @ProcessID AND
				  ProcessNo = @ProcessNo AND
				  FiscalYear = @FiscalYear AND
				  SerialNo = @SerialNo AND
				  GoodsQuantity<>0 and (SELECT COUNT(*) FROM inv.tblGoods WHERE GoodsID=SUBSTRING(S.GoodsID,@str_Goods+1,@str_GoodsSum)  AND PartNumber=@UnitPart AND UnitID=S.SubUnitID ) = 0 AND 
				  (SELECT COUNT(*) FROM inv.tblSubUnitsDtl WHERE GoodsID=S.GoodsID AND UnitID=S.SubUnitID ) = 0 AND 
				  GoodsPrice <> SubUnitPrice*SubUnitQuantity/GoodsQuantity	 
		END
		ELSE
		BEGIN
			UPDATE sal.tblSaleOrderDtl
			SET SubUnitPrice = S.SubUnitPrice2
			FROM sal.tblSaleOrderDtl S
			WHERE S.ProcessID = @ProcessID AND
				  S.ProcessNo = @ProcessNo AND
				  S.FiscalYear = @FiscalYear AND
				  S.SerialNo = @SerialNo  
		END 
	END	
	ELSE IF  @TypeOfTable	= 'SOR1'
	BEGIN
			UPDATE sal.tblSaleOrderDtl
			SET SubUnitPrice = GoodsPrice*GoodsQuantity/SubUnitQuantity
			FROM sal.tblSaleOrderDtl S
			INNER JOIN inv.tblSubUnitsDtl U
			ON U.GoodsID = S.GoodsID AND U.SubUnitID = S.SubUnitID
			WHERE ProcessID = @ProcessID AND
				  ProcessNo = @ProcessNo AND
				  FiscalYear = @FiscalYear AND
				  SerialNo = @SerialNo AND
				  GoodsQuantity<>0 AND 
				  SubUnitPrice <> GoodsPrice*GoodsQuantity/SubUnitQuantity
				  
			UPDATE sal.tblSaleOrderDtl
			SET SubUnitPrice = S.GoodsPrice
			FROM sal.tblSaleOrderDtl S
			INNER JOIN inv.tblGoods U
			ON U.GoodsID = SUBSTRING(S.GoodsID,@str_Goods+1,@str_GoodsSum) AND U.UnitID = S.SubUnitID
			WHERE ProcessID = @ProcessID AND 
				  ProcessNo = @ProcessNo AND
				  FiscalYear = @FiscalYear AND
				  SerialNo = @SerialNo AND 
				  U.PartNumber=@UnitPart AND
				  S.GoodsPrice <> SubUnitPrice
				  
			UPDATE sal.tblSaleOrderDtl
			SET SubUnitPrice = GoodsPrice*GoodsQuantity/SubUnitQuantity
			FROM sal.tblSaleOrderDtl S
			INNER JOIN inv.tblSubUnitsDtl U
			ON U.GoodsID = ''  AND U.SubUnitID = S.SubUnitID
			WHERE ProcessID = @ProcessID AND
				  ProcessNo = @ProcessNo AND
				  FiscalYear = @FiscalYear AND
				  SerialNo = @SerialNo AND
				  GoodsQuantity<>0 and (SELECT COUNT(*) FROM inv.tblGoods WHERE GoodsID=SUBSTRING(S.GoodsID,@str_Goods+1,@str_GoodsSum)  AND PartNumber=@UnitPart AND UnitID=S.SubUnitID ) = 0 AND 
				  (SELECT COUNT(*) FROM inv.tblSubUnitsDtl WHERE GoodsID=S.GoodsID AND UnitID=S.SubUnitID ) = 0 AND 
				  SubUnitPrice <> GoodsPrice*GoodsQuantity/SubUnitQuantity	 
	END	  
	ELSE IF  @TypeOfTable	= 'DST'
	BEGIN	  
		UPDATE inv.tblStorageDocsDtl
		SET GoodsPrice = SubUnitPrice*SubUnitQuantity/GoodsQuantity --(SubUnitPrice * UnitValue)/MainUnitValue 
		FROM inv.tblStorageDocsHdr H
		INNER JOIN inv.tblStorageDocsDtl S
		ON H.ProcessID=S.ProcessID AND H.ProcessNo=S.ProcessNo AND H.FiscalYear = S.FiscalYear AND H.SerialNo=S.SerialNo
		INNER JOIN inv.tblSubUnitsDtl U
		ON U.GoodsID = S.GoodsID AND U.SubUnitID = S.SubUnitID
		WHERE BaseDistributionProcessID = @ProcessID AND
			  BaseDistributionProcessNo = @ProcessNo AND
			  BaseDistributionFiscalYear = @FiscalYear AND
			  BaseDistributionSerialNo = @SerialNo AND
			  GoodsQuantity<>0 and 
			  GoodsPrice <> SubUnitPrice*SubUnitQuantity/GoodsQuantity
			  
		UPDATE inv.tblStorageDocsDtl
		SET GoodsPrice = S.SubUnitPrice
		FROM inv.tblStorageDocsDtl S
		INNER JOIN inv.tblStorageDocsHdr H
		ON H.ProcessID=S.ProcessID AND H.ProcessNo=S.ProcessNo AND H.FiscalYear = S.FiscalYear AND H.SerialNo=S.SerialNo
		INNER JOIN inv.tblGoods U
		ON U.GoodsID = SUBSTRING(S.GoodsID,@str_Goods+1,@str_GoodsSum) AND U.UnitID = S.SubUnitID
		WHERE BaseDistributionProcessID = @ProcessID AND 
			  BaseDistributionProcessNo = @ProcessNo AND
			  BaseDistributionFiscalYear = @FiscalYear AND
			  BaseDistributionSerialNo = @SerialNo AND
			  U.PartNumber=@UnitPart AND
			  S.GoodsPrice <> S.SubUnitPrice
			  
		UPDATE inv.tblStorageDocsDtl
		SET GoodsPrice = SubUnitPrice*SubUnitQuantity/GoodsQuantity --(SubUnitPrice * UnitValue)/MainUnitValue 
		FROM inv.tblStorageDocsHdr H
		INNER JOIN inv.tblStorageDocsDtl S
		ON H.ProcessID=S.ProcessID AND H.ProcessNo=S.ProcessNo AND H.FiscalYear = S.FiscalYear AND H.SerialNo=S.SerialNo
		INNER JOIN inv.tblSubUnitsDtl U
		ON U.GoodsID = '' AND U.SubUnitID = S.SubUnitID
		WHERE BaseDistributionProcessID = @ProcessID AND
			  BaseDistributionProcessNo = @ProcessNo AND
			  BaseDistributionFiscalYear = @FiscalYear AND
			  BaseDistributionSerialNo = @SerialNo AND
			  GoodsQuantity<>0 and (SELECT COUNT(*) FROM inv.tblGoods WHERE GoodsID=SUBSTRING(S.GoodsID,@str_Goods+1,@str_GoodsSum)  AND PartNumber=@UnitPart AND UnitID=S.SubUnitID ) = 0 AND 
			  (SELECT COUNT(*) FROM inv.tblSubUnitsDtl WHERE GoodsID=S.GoodsID AND UnitID=S.SubUnitID ) = 0 AND 
			  GoodsPrice <> SubUnitPrice*SubUnitQuantity/GoodsQuantity
	END		  
END
GO
