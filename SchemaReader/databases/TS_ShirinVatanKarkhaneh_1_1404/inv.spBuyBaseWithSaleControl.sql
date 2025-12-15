USE TS_ShirinVatanKarkhaneh_1_1404
GO
SET ANSI_NULLS, QUOTED_IDENTIFIER ON
GO
-- =========== TS-QC:NOTOK ========================
-- Author        : Hadi Sadeghi
-- Create date   : 1398/12/04
-- Viewed By	 : 
-- Last Modified : 
-- Description   : 
-- =============================================
CREATE PROCEDURE [inv].[spBuyBaseWithSaleControl] 
 @ProcessID		Tinyint,
 @ProcessNo		Tinyint,
 @FiscalYear	Smallint,
 @SerialNo		Int
 WITH ENCRYPTION
AS

BEGIN
SET NOCOUNT ON;

	Declare @strMsgText		NVarChar(2044)
	SET @strMsgText = ''

	DECLARE @SaleBaseSubUnitDeviation as float
	DECLARE @BaseSubUnitQty as float
	DECLARE @SubUnitQty as float

	SELECT @SaleBaseSubUnitDeviation = SettingValue 
	FROM pub.tblSettings 
	WHERE SettingKey = 'SaleBaseSubUnitDeviation'

	SELECT @BaseSubUnitQty=ISNULL(SUM(SD.GoodsQuantity*UnitValue/MainUnitValue),0)
	FROM (SELECT a.* 
	      FROM inv.tblStorageDocsDtl a
		  inner join (select * 
		              from inv.tblStorageDocsHdr 
					  WHERE ProcessID = @ProcessID AND
							ProcessNo = @ProcessNo AND
							FiscalYear= @FiscalYear AND
							SerialNo  = @SerialNo ) b
		  On  a.ProcessID=b.BaseProcessID	
		  AND a.ProcessNo=b.BaseProcessNo
		  AND a.FiscalYear=b.BaseFiscalYear
		  AND a.SerialNo=b.BaseSerialNo
			) SD
	INNER JOIN inv.tblSubUnitsDtl SU 
	ON SD.GoodsID=SU.GoodsID AND SU.ShowInInvoice='True'
	WHERE SU.ShowInInvoice='True'

	SELECT @SubUnitQty=ISNULL(SUM(SD.GoodsQuantity*UnitValue/MainUnitValue),0)
	FROM inv.tblStorageDocsDtl SD
	INNER JOIN inv.tblSubUnitsDtl SU 
	ON SD.GoodsID=SU.GoodsID AND SU.ShowInInvoice='True'
	WHERE ProcessID = @ProcessID AND
		  ProcessNo = @ProcessNo AND
		  FiscalYear= @FiscalYear AND
		  SerialNo  = @SerialNo AND
		  SU.ShowInInvoice='True'
	IF 	@SubUnitQty>(@BaseSubUnitQty + (@BaseSubUnitQty *@SaleBaseSubUnitDeviation/100)) 
	BEGIN
		SET @strMsgText=N'مقدار دریافتی از مقدار تلرانس تعریف شده متفاوت است.' + LTRIM(str(@SubUnitQty -  @BaseSubUnitQty)) + 'واحد فرعی بیشتر است' 

		Raiserror (@strMsgText,16,1)
		Return
	END
	IF 	@SubUnitQty<(@BaseSubUnitQty - (@BaseSubUnitQty *@SaleBaseSubUnitDeviation/100))  
	BEGIN
		SET @strMsgText=N'مقدار دریافتی از مقدار تلرانس تعریف شده متفاوت است.' + LTRIM(str(@BaseSubUnitQty - @SubUnitQty)) + ' واحد فرعی کمتر است' 

		Raiserror (@strMsgText,16,1)
		Return
	END

END
GO
