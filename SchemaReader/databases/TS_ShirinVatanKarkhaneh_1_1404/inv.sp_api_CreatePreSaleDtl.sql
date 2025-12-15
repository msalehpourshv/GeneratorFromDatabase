USE TS_ShirinVatanKarkhaneh_1_1404
GO
SET ANSI_NULLS, QUOTED_IDENTIFIER ON
GO
-- =============================================
-- Author        : h.ahmadnejad
-- Create date   : 1402/03/06
-- Viewed By	 : 
-- Last Modified : 
-- Description   : 
-- =============================================
CREATE PROCEDURE inv.sp_api_CreatePreSaleDtl
	@ProcessNo				int, 
	@FiscalYear				int, 
	@SerialNo				int, 
	@DocStep				int, 
	@DocDate				nvarchar(20),
	@DescDtl				nvarchar(2000),
	@StoreID				nvarchar(20),
	@AcntCode				nvarchar(20),
	@GoodsID				nvarchar(20),
	@GoodsQuantity			float,
	@GoodsAmount			float,
	@DiscountPercent		float,
	@Discount				float,	
	@TaxOverWorthCostDtl	float,
	@TollOverWorthCostDtl	float,	
	@SaleTypeID				nvarchar(20)

WITH ENCRYPTION
AS
BEGIN
	DECLARE @AcntCodePart1	nvarchar(20)
	DECLARE @UnitID			nvarchar(20)
	DECLARE @MaxRowNo		int
	DECLARE @StrErrorMessage nvarchar(1024)
BEGIN TRY

	-- check goods id ==============================================================================================================

	IF (SELECT Count(*) FROM inv.tblGoods where GoodsID = @GoodsID) <> 1
	BEGIN
		Set @StrErrorMessage = N'کد کالا صحیح نیست'
		raiserror (@StrErrorMessage, 16, 1)
	END	

	-- check store id ==============================================================================================================

	if (@StoreID is null) or (@StoreID = '')
	begin
		select @StoreID = SettingValue
		from pub.tblSettings
		where SettingKey='OnlineStoreID'
	end	

	IF (@StoreID is null) or (@StoreID = '')
	BEGIN
		Set @StrErrorMessage = N'در تنظیمات برنامه تکروسیستم در بخش فروشگاه آنلاین، انبار را مقداردهی کنید'
		raiserror (@StrErrorMessage, 16, 1)
	END
	
	IF (SELECT Count(*) FROM inv.tblStores where StoreID=@StoreID) = 0
	BEGIN
		Set @StrErrorMessage = N'در تنظیمات برنامه تکروسیستم در بخش فروشگاه آنلاین، مقدار انبار صحیح نیست'
		raiserror (@StrErrorMessage, 16, 1)
	END	

	-- check acnt code ==============================================================================================================
	
	SELECT @AcntCodePart1 = LTrim(RTrim(SettingValue))
	FROM pub.tblSettings 
	WHERE SettingKey = 'OnlineCustomer'

	IF (@AcntCodePart1 is null) or (@AcntCodePart1 = '')
	BEGIN
		Set @StrErrorMessage = N'در تنظیمات برنامه تکروسیستم در بخش فروشگاه آنلاین، کد حسابداری مشتری (فقط معین) را مقداردهی کنید'
		raiserror (@StrErrorMessage, 16, 1)
	END

	-- init ==============================================================================================================

	SET @AcntCode = @AcntCodePart1 + ' ' + @AcntCode

	SELECT @UnitID = UnitID FROM inv.tblGoods WHERE GoodsID=@GoodsID

	SELECT @MaxRowNo = isnull(MAX(RowNo), 0)
	FROM inv.tblPreSaleDtl
	WHERE ProcessID=240
	  AND ProcessNo=@ProcessNo
	  AND FiscalYear=@FiscalYear
	  AND SerialNo=@SerialNo
			 
	SET @MaxRowNo = @MaxRowNo + 1

	-- save ==============================================================================================================

	INSERT INTO inv.tblPreSaleDtl(
			ProcessID, ProcessNo, FiscalYear, SerialNo, RowNo, DocRowNo, DocDate, DocStep, 
			StoreID, AcntCode, GoodsID, GoodsQuantity, SubUnitQuantity, GoodsAmount, MainAmount, SubUnitID,
			DiscountPercent, Discount, DescDtl, SaleTypeID, TaxOverWorthCostDtl, TollOverWorthCostDtl)
	SELECT	240 ProcessID, @ProcessNo, @FiscalYear, @SerialNo, @MaxRowNo, @MaxRowNo, @DocDate, @DocStep, 
			@StoreID, @AcntCode, @GoodsID, @GoodsQuantity, @GoodsQuantity, @GoodsAmount, @GoodsAmount, @UnitID,
			@DiscountPercent, @Discount, @DescDtl, @SaleTypeID, @TaxOverWorthCostDtl, @TollOverWorthCostDtl

	select 240 ProcessID, @ProcessNo ProcessNo, @FiscalYear FiscalYear, @SerialNo SerialNo, @MaxRowNo RowNo
    
END TRY
BEGIN CATCH

	Set @StrErrorMessage = ERROR_MESSAGE() 
	raiserror (@StrErrorMessage, 16, 1)

END CATCH

END	

--Go 
-- exec inv.sp_api_CreatePreSaleDtl 1, 1402, 457, 1, '1402/02/02', 'web', '', '04300005', '60114512006949', 4, 12500, 0, 0, 4500, 0, ''
GO
