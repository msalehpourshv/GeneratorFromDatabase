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
CREATE PROCEDURE [inv].[sp_api_Brango_CreateStorageDocsHdr]

@ProcessId			  As NVARCHAR(50) ,
@FiscalYear			  As NVARCHAR(50) ,
@ProcessNo			  As NVARCHAR(50) ,
@SaleTypeID			  As NVARCHAR(50) ,
@StoreID			  As NVARCHAR(50) ,
@Price				  As NVARCHAR(50) ,
@Amount				  As NVARCHAR(50) ,
@DocDate			  As NVARCHAR(50) ,
@DocDesc			  As NVARCHAR(50) ,
@AcntMobile			  As NVARCHAR(50) ,
@AcntCode As NVARCHAR(50) ,
@TotalLineDiscount AS FLOAT,
@TransportationIncome AS FLOAT,
@Discount			  As NVARCHAR(50) ,
@DiscountPercent	  As NVARCHAR(50) ,
@Discount2			  As NVARCHAR(50) ,
@TaxOverWorthCost	  As NVARCHAR(50) ,
@TollOverWorthCost	  As NVARCHAR(50) ,
@TransferSerialNo	  As NVARCHAR(50) 

WITH ENCRYPTION
 AS
BEGIN
	DECLARE @maxSerialNo INT
	DECLARE @StrErrorMessage NVARCHAR(MAX)
	DECLARE @SaleAcntCodeInSaleTypes BIT
	DECLARE @TransportationIncomeAcntCode as varchar(20)
	DECLARE @DiscountAcntCode VARCHAR(20)
BEGIN TRY

	set @StoreID='0402'
	set @SaleTypeID='00001'
	set @ProcessNo='4'

	IF(select count(*) from inv.tblStorageDocsHdr where TransferSerialNo=@TransferSerialNo)=0
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

		SELECT  @SaleAcntCodeInSaleTypes = SettingValue
		FROM pub.tblSettings
		WHERE SettingKey = 'SaleAcntCodeInSaleTypes'
	
		If @SaleAcntCodeInSaleTypes =1
			SELECT @DiscountAcntCode =SaleDiscountAcntCode,@TransportationIncomeAcntCode=TransportationIncomeAcntCode FROM sal.tblSaleTypes WHERE SaleTypeID <>'' AND SaleTypeID =@SaleTypeID
		Else
			SELECT @DiscountAcntCode =SaleDiscountAcntCode,@TransportationIncomeAcntCode=TransportationIncomeAcntCode FROM inv.tblStores WHERE StoreID <>'' AND StoreID = @StoreID

		SELECT @maxSerialNo = isnull(MAX(SerialNo),0)
		FROM inv.tblStorageDocsHdr 
		WHERE ProcessID=90
		  AND ProcessNo=@ProcessNo
		  AND FiscalYear=@FiscalYear

		SET @maxSerialNo = @maxSerialNo +1

		INSERT INTO inv.tblStorageDocsHdr
			(ProcessID, ProcessNo, FiscalYear, SerialNo, DocStep, DocDate,	StoreID, AcntCode,OrderAcntCode,
			Amount,Price, DiscountPercent, Discount, Discount2, TotalLineDiscount,DocDesc,SaleTypeID,
			DiscountAcntCode,TaxOverWorthCost, TollOverWorthCost,DocDate2,DocDate3, DocDate4, IsAutoDoc,
			TransportationIncomeAcntCode,TransportationIncome,TransferSerialNo)
	
		SELECT 90, @ProcessNo, @FiscalYear, @maxSerialNo, 1, @DocDate, @StoreID, @AcntCode,@AcntMobile,
			@Amount,@Price,@DiscountPercent,@Discount,@Discount2, @TotalLineDiscount,@DocDesc,@SaleTypeID,
			@DiscountAcntCode,@TaxOverWorthCost, @TollOverWorthCost,@DocDate DocDate2,
			@DocDate DocDate3,@DocDate DocDate4,'True' IsAutoDoc,
			@TransportationIncomeAcntCode,@TransportationIncome,@TransferSerialNo

		SELECT @maxSerialNo AS SerialNo
	END
	
	ELSE
	BEGIN
		DECLARE @SaleSerialNO AS INt

		Select @SaleSerialNO =SerialNo from inv.tblStorageDocsHdr where TransferSerialNo=@TransferSerialNo

		SET @StrErrorMessage = N'این فاکتور با شماره برگه '+cast(@SaleSerialNO as nvarchar(50))+' ثبت شده است '		raiserror (@StrErrorMessage, 16, 1)
    END

END TRY
BEGIN CATCH


	Set @StrErrorMessage = ERROR_MESSAGE() 
	raiserror (@StrErrorMessage, 16, 1)

END CATCH

END	
GO
