USE TS_ShirinVatanKarkhaneh_1_1404
GO
SET ANSI_NULLS, QUOTED_IDENTIFIER ON
GO
-- =========== TS-QC:NOTOK ========================
-- Author        : Alian Pour
-- Create date   : 1400/08/30
-- Viewed By	 : 
-- Last Modified : 
-- Description   : 
-- =============================================
Create PROCEDURE [sal].[sp_api_TakroSystem_AutoSaleOrderHdr]
@ProcessNo as Int,
@FiscalYear as Int,
@DocStep as tinyint,
@DocDate as CHAR(10),
@DocTime as CHAR(10),
@StoreID AS VARCHAR(20),
@AcntCode AS VARCHAR(20),
@AcntName AS VARCHAR(20),
@Amount as FLOAT,
@Price as FLOAT,
@DiscountPercent as FLOAT,
@Discount as FLOAT,
@Discount2 as FLOAT,
@TotalLineDiscount as FLOAT,
@DocDesc as NVARCHAR(500),
@SaleTypeID as VARCHAR(20),
@TaxOverWorthCost as FLOAT,
@TollOverWorthCost as FLOAT,
@VisitorAcntCode as nvarchar(50),
@SessionNo as int,
@TransferSerialNo as nvarchar(100)

WITH ENCRYPTION
 AS
BEGIN
	DECLARE @maxSerialNo INT
	Declare @StrErrorMessage As Nvarchar(1024)
	Declare @AcntPart as int
	Declare @Moin as nvarchar(50)
BEGIN TRY

	IF @AcntCode=''
	BEGIN
		Set @StrErrorMessage = N'کد مشتری را پر کنید'
		raiserror (@StrErrorMessage, 16, 1)
	END
	
	IF (SELECT Count(*) FROM inv.tblStores
		where StoreID=@StoreID )=0
	BEGIN
		Set @StrErrorMessage = N'کد انبار نامعتبر است'
		raiserror (@StrErrorMessage, 16, 1)
	END	
	
	IF (SELECT Count(*) FROM sal.tblSaleTypes
		where SaleTypeID=@SaleTypeID )=0
	BEGIN
		Set @StrErrorMessage = N'کد نوع فروش نامعتبر است'
		raiserror (@StrErrorMessage, 16, 1)
	END	
	
	SET @StoreID='01'
	SET @SaleTypeID='00001'

	---Acnt Moin
	SELECT @AcntPart = SettingValue
	FROM pub.tblSettings
	WHERE SettingKey = 'AcntPartNumberForRemainCalculation'

	IF(@AcntPart=2)
	BEGIN

		SELECT top 1 @Moin= isnull(rtrim(ltrim(SettingValue)),'') 
                FROM pub.tblSettings 
                WHERE SettingKey LIKE '%BuyerAcntCodeInSale%'
		IF(@Moin='')
		BEGIN
			Set @StrErrorMessage ='کد پیش فرض خریدار در فروش را وارد کنید'
			raiserror (@StrErrorMessage, 16, 1)
		END
		SET @AcntCode=@Moin+' '+@AcntCode
	END

	SELECT @maxSerialNo = isnull(MAX(SerialNo),0)
	FROM sal.tblSaleOrderHdr 
	WHERE ProcessID=180
	  AND ProcessNo=@ProcessNo
	  AND FiscalYear=@FiscalYear
			 
	SET @maxSerialNo = @maxSerialNo +1

	
	INSERT INTO sal.tblSaleOrderHdr
	(ProcessID, ProcessNo, FiscalYear, SerialNo, DocStep, DocDate,DocTime,StoreID, AcntCode,OrderName,
	 Amount,Price, DiscountPercent, Discount, Discount2, TotalLineDiscount,DocDesc,SaleTypeID,
	 TaxOverWorthCost, TollOverWorthCost,AutoOrder ,SessionNo,VisitorAcntCode,TransferSerialNo)
	
	SELECT 180, @ProcessNo, @FiscalYear, @maxSerialNo, @DocStep, @DocDate,@DocTime, @StoreID, @AcntCode,@AcntName, 
		  @Amount,@Price,@DiscountPercent,@Discount,@Discount2, @TotalLineDiscount,@DocDesc,@SaleTypeID,
		  @TaxOverWorthCost, @TollOverWorthCost,'True',@SessionNo,@VisitorAcntCode,@TransferSerialNo


	SELECT 180 ProcessID ,@ProcessNo ProcessNo, @FiscalYear FiscalYear,@DocDate DocDate, @maxSerialNo SerialNo,@AcntCode AcntCode,@StoreID StoreID,@SaleTypeID SaleTypeID

END TRY
BEGIN CATCH


	Set @StrErrorMessage = ERROR_MESSAGE() 
	raiserror (@StrErrorMessage, 16, 1)

END CATCH

END	
GO
