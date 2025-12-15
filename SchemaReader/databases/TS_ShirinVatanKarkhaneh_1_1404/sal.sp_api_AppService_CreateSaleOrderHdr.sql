USE TS_ShirinVatanKarkhaneh_1_1404
GO
SET ANSI_NULLS, QUOTED_IDENTIFIER ON
GO
-- =========== TS-QC:NOTOK ========================
-- Author        : Alian Pour
-- Create date   : 1400/10/19
-- Viewed By	 : 
-- Last Modified : 
-- Description   : 
-- =============================================
create PROCEDURE sal.sp_api_AppService_CreateSaleOrderHdr
@ProcessId as int,
@FiscalYear			  As NVARCHAR(50) ,
@ProcessNo			  As NVARCHAR(50) ,
@SaleTypeID			  As NVARCHAR(50) ,
@StoreID			  As NVARCHAR(50) ,
@Price				  As NVARCHAR(50) ,
@Amount				  As NVARCHAR(50) ,
@DocDate			  As NVARCHAR(50) ,
@DocDesc			  As NVARCHAR(50) ,
@AcntCode As NVARCHAR(50) ,
@TotalLineDiscount AS FLOAT,
@TransportationIncome AS FLOAT,
@Discount			  As NVARCHAR(50) ,
@DiscountPercent	  As NVARCHAR(50) ,
@Discount2			  As NVARCHAR(50) ,
@TaxOverWorthCost	  As NVARCHAR(50) ,
@TollOverWorthCost	  As NVARCHAR(50) ,
@TransferSerialNo	  As NVARCHAR(50) ,
@CurrencyTypeID       AS NVARCHAR(50)
WITH ENCRYPTION
 AS
BEGIN
	DECLARE @maxSerialNo INT
	DECLARE @StrErrorMessage NVARCHAR(MAX)

BEGIN TRY


	IF(select count(*) from sal.tblSaleOrderHdr where TransferSerialNo=@TransferSerialNo)=0
	Begin
		
		IF @AcntCode=''
		BEGIN
			SET @StrErrorMessage = N'کد مشتری را پر کنید'
			raiserror (@StrErrorMessage, 16, 1)
		END

		IF (SELECT COUNT(*) FROM inv.tblStores
		WHERE StoreID=@StoreID )=0
		BEGIN
			SET @StrErrorMessage = N'کد انبار '+@StoreID+' صحیح نیست '
			raiserror (@StrErrorMessage, 16, 1)
		END	

		IF (SELECT Count(*) FROM sal.tblSaleTypes
		WHERE SaleTypeID=@SaleTypeID )=0
		BEGIN
			SET @StrErrorMessage = N'کد نوع فروش نامعتبر است'
			raiserror (@StrErrorMessage, 16, 1)
		END	

		SELECT @maxSerialNo = isnull(MAX(SerialNo),0)
		FROM sal.tblSaleOrderHdr 
		WHERE ProcessID=@ProcessId
		  AND ProcessNo=@ProcessNo
		  AND FiscalYear=@FiscalYear

		SET @maxSerialNo = @maxSerialNo +1

		INSERT INTO sal.tblSaleOrderHdr
			(ProcessID, ProcessNo, FiscalYear, SerialNo, DocStep, DocDate,	StoreID, AcntCode,
			Amount,Price, DiscountPercent, Discount, Discount2, TotalLineDiscount,DocDesc,SaleTypeID,
			TaxOverWorthCost, TollOverWorthCost,DocDate2,
			TransportationIncome,TransferSerialNo)
	
		SELECT @ProcessId, @ProcessNo, @FiscalYear, @maxSerialNo, 1, @DocDate, @StoreID, @AcntCode,
			@Amount,@Price,@DiscountPercent,@Discount,@Discount2, @TotalLineDiscount,@DocDesc,@SaleTypeID,
			@TaxOverWorthCost, @TollOverWorthCost,@DocDate DocDate2,
			@TransportationIncome,@TransferSerialNo

		SELECT @maxSerialNo AS SerialNo
	END
	
	ELSE
	BEGIN
		DECLARE @SaleSerialNO AS INt

		SET @StrErrorMessage = N'این فاکتور با شماره شناسه '+cast(@TransferSerialNo as nvarchar(50))+' ثبت شده است '		
		raiserror (@StrErrorMessage, 16, 1)
    END

END TRY
BEGIN CATCH


	Set @StrErrorMessage = ERROR_MESSAGE() 
	raiserror (@StrErrorMessage, 16, 1)

END CATCH

END	
GO
