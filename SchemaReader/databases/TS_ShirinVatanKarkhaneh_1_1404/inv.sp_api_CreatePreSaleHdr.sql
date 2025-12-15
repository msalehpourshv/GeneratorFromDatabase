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
CREATE PROCEDURE inv.sp_api_CreatePreSaleHdr
	@ProcessNo			as int,
	@FiscalYear			as int,
	@DocStep			as int,
	@DocDate			as nvarchar(10),
	@DocTime			as nvarchar(10),
	@DocDesc			as nvarchar(2000),
	@AcntCode			as nvarchar(20),
	@StoreID			as nvarchar(20),
	@Amount				as float ,
	@Price				as float ,
	@DiscountPercent	as float ,
	@Discount			as float ,
	@TaxOverWorthCost	as float ,
	@TollOverWorthCost	as float ,
	@TotalLineDiscount	as float ,
	@TransferSerialNo	as nvarchar(20),
	@SaleTypeID			as nvarchar(20)	
WITH ENCRYPTION
AS
BEGIN
	DECLARE @MaxSerialNo		int
	DECLARE @Boolean			bit
	DECLARE @AcntCodePart1		nvarchar(20)
	Declare @StrErrorMessage	Nvarchar(1024)
BEGIN TRY

	-- check sale type ==============================================================================================================

	if (@SaleTypeID is null) or (@SaleTypeID = '')
	begin
		select @SaleTypeID = SettingValue
		from pub.tblSettings
		where SettingKey='OnlineSaleType'
	end
	
	IF (@SaleTypeID is null) or (@SaleTypeID = '')
	BEGIN
		Set @StrErrorMessage = N'در تنظیمات برنامه تکروسیستم در بخش فروشگاه آنلاین، نوع فروش را مقداردهی کنید'
		raiserror (@StrErrorMessage, 16, 1)
	END

	IF (SELECT Count(*) FROM sal.tblSaleTypes where SaleTypeID=@SaleTypeID) = 0
	BEGIN
		Set @StrErrorMessage = N'در تنظیمات برنامه تکروسیستم در بخش فروشگاه آنلاین، مقدار نوع فروش صحیح نیست'
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

	SELECT @MaxSerialNo = isnull(MAX(SerialNo), 0)
	FROM inv.tblPreSaleHdr 
	WHERE ProcessID=240
	  AND ProcessNo=@ProcessNo
	  AND FiscalYear=@FiscalYear
			 
	SET @MaxSerialNo = @MaxSerialNo + 1

	-- save ==============================================================================================================

	INSERT INTO inv.tblPreSaleHdr(
		ProcessID, ProcessNo, FiscalYear, SerialNo, DocDate, DocTime, DocStep, DocDesc, 
		StoreID, AcntCode, SaleTypeID, AcntName, Discount, TaxOverWorthCost, TollOverWorthCost, Price, Amount, TotalLineDiscount)
	SELECT 240 ProcessID, @ProcessNo, @FiscalYear, @MaxSerialNo, @DocDate, @DocTime, @DocStep, @DocDesc,
		@StoreID, @AcntCode, @SaleTypeID, '' AcntName, @Discount, @TaxOverWorthCost, @TollOverWorthCost, @Price, @Amount, @TotalLineDiscount

    ------------------------------------------------------------------------------------------------------------------------------------------

	SELECT 240 ProcessID, @ProcessNo ProcessNo, @FiscalYear FiscalYear, @MaxSerialNo SerialNo

END TRY
BEGIN CATCH


	Set @StrErrorMessage = ERROR_MESSAGE() 
	raiserror (@StrErrorMessage, 16, 1)

END CATCH

END	

--Go 
--	exec inv.sp_api_CreatePreSaleHdr 1, 1402, 1, '1402/02/02', '12:12', N'وبسایت', 
--									'04300005', '', 54500, 50000, 0, 0, 4500, 0, 0, 'TAKRO', ''
GO
