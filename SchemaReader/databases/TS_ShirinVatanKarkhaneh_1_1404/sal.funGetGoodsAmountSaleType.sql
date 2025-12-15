USE TS_ShirinVatanKarkhaneh_1_1404
GO
SET ANSI_NULLS, QUOTED_IDENTIFIER ON
GO
-- =========== TS-QC:NOTOK ========================
-- Author        : Hadi Sadeghi
-- Create date   : 86/12/24
-- Viewed By	 : 
-- Last Modified : 
-- Description   : 
-- =============================================
Create FUNCTION [sal].[funGetGoodsAmountSaleType] 
(
	@GoodsID Varchar(20),
	@StoreID Varchar(20),
	@DocDate Char(10),
	@SaleTypeID Varchar(20),
	@LanguageID TinyInt,
	@UserPriceID Int,
	@CurrencyRate float
)
RETURNS FLOAT
WITH ENCRYPTION
AS

BEGIN

	-- Declare the return variable here
	DECLARE @strMsgText Nvarchar(2024)

	DECLARE @SalePriceTypeID Tinyint
	DECLARE @SalePrice Float
	DECLARE @BasePriceTypeID Tinyint
	DECLARE @AddendAmountToPrice Float
	DECLARE @AddendPercentToPrice Tinyint
	DECLARE @RoundableDigitsInPrice Tinyint
	DECLARE @CurrencyTypeID VARCHAR(20)
	DECLARE @CurrencyPrice Float
	DECLARE @Coefficient Float
	
	Set @SalePriceTypeID = 0

	SELECT Top 1 @SalePriceTypeID = SalePriceTypeID, @SalePrice = SalePrice, @BasePriceTypeID = BasePriceTypeID, 
			@AddendAmountToPrice = AddendAmountToPrice, @AddendPercentToPrice = AddendPercentToPrice,
			@RoundableDigitsInPrice = RoundableDigitsInPrice, @CurrencyTypeID = CurrencyTypeID, 
			@CurrencyPrice = CurrencyPrice, @Coefficient = Coefficient
	From sal.tblGoodsPricesDtl 
	Where	LEN(GoodsID) > 0 AND GoodsID = SUBSTRING(@GoodsID, 1, LEN(GoodsID)) AND
			SaleTypeID = SUBSTRING(@SaleTypeID, 1, LEN(SaleTypeID))  AND
			IsGroupCode = 0 AND (@UserPriceID = 0 or UserPrice = ( select UserPrice  from inv.tblGoodsUserPrice  where ID =@UserPriceID))
	order by LEN(GoodsID) desc	,UserPriceID desc,LEN(SaleTypeID) desc
	
--	IF @SalePriceTypeID=0
--	BEGIN
--		--قیمت فروش این کالا وارد نشده است
--		SET @strMsgText=TS.pub.funGetMessages(18001,@LanguageID)
--		Raiserror (@strMsgText,16,1)
--		RETURN -1
--	END
--	ELSE

	IF @SalePriceTypeID = 1
		RETURN IsNull(@SalePrice, 0)

	ELSE IF @SalePriceTypeID = 2
		RETURN IsNull(sal.funGetRialsCalculation(@GoodsID,@StoreID,@DocDate,@BasePriceTypeID,@RoundableDigitsInPrice,@AddendAmountToPrice,@AddendPercentToPrice), 0)

	ELSE IF @SalePriceTypeID = 3
	BEGIN
		IF @CurrencyRate = 0
			SELECT TOP 1 @CurrencyRate = CurrencyRate 
			FROM pub.tblCurrencyRatesDtl
			WHERE @CurrencyTypeID=CurrencyTypeID AND DocDate <= @DocDate
			ORDER BY DocDate Desc,DocTime Desc	

--		IF @CurrencyRate IS Null
--		BEGIN
--			--قیمت فروش این کالا وارد نشده است
--			SET @strMsgText=TS.pub.funGetMessages(18001,@LanguageID)
--			Raiserror (@strMsgText,16,1)
--			RETURN -1
--		END
		IF @RoundableDigitsInPrice > 0
			RETURN  ROUND(IsNull((@CurrencyRate * @CurrencyPrice * @Coefficient), 0), -1 * @RoundableDigitsInPrice)
		ELSE
			RETURN  IsNull((@CurrencyRate * @CurrencyPrice	* @Coefficient), 0)
	END
	
	
			SELECT	top 1 @SalePriceTypeID=SalePriceTypeID, @SalePrice=SalePrice, @BasePriceTypeID=BasePriceTypeID, 
					@AddendAmountToPrice=AddendAmountToPrice, @AddendPercentToPrice=AddendPercentToPrice,
					@RoundableDigitsInPrice=RoundableDigitsInPrice, @CurrencyTypeID=CurrencyTypeID, 
					@CurrencyPrice=CurrencyPrice, @Coefficient=Coefficient
			From sal.tblGoodsPricesDtl 
			Where	GoodsID=SUBSTRING(@GoodsID,1,LEN(GoodsID)) AND
					SaleTypeID = SUBSTRING(@SaleTypeID, 1, LEN(SaleTypeID))  AND
					IsGroupCode = 1  AND  (@UserPriceID = 0 or UserPrice = ( select UserPrice  from inv.tblGoodsUserPrice  where ID =@UserPriceID)) 
			order by LEN(GoodsID) desc	,UserPriceID desc,LEN(SaleTypeID) desc
			
			IF @SalePriceTypeID=1
				RETURN IsNull(@SalePrice, 0)

			ELSE IF @SalePriceTypeID=2
				RETURN IsNull(sal.funGetRialsCalculation(@GoodsID,@StoreID,@DocDate,@BasePriceTypeID,@RoundableDigitsInPrice,@AddendAmountToPrice,@AddendPercentToPrice), 0)

			ELSE IF @SalePriceTypeID=3
			BEGIN
				SELECT TOP 1 @CurrencyRate = CurrencyRate 
				FROM pub.tblCurrencyRatesDtl
				WHERE @CurrencyTypeID=CurrencyTypeID AND DocDate <= @DocDate
				ORDER BY DocDate Desc,DocTime Desc	

				IF @RoundableDigitsInPrice >0
					RETURN  ROUND(IsNull((@CurrencyRate * @CurrencyPrice	* @Coefficient), 0),-1*@RoundableDigitsInPrice)
				ELSE
					RETURN  IsNull((@CurrencyRate * @CurrencyPrice	* @Coefficient), 0)
			END
				
	
									
RETURN 0

END
GO
