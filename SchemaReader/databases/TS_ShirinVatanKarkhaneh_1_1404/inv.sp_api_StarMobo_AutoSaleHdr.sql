USE TS_ShirinVatanKarkhaneh_1_1404
GO
SET ANSI_NULLS, QUOTED_IDENTIFIER ON
GO
-- =========== TS-QC:NOTOK ========================
-- Author        : Hadi Sadeghi
-- Create date   : 1400/01/24
-- Viewed By	 : 
-- Last Modified : 
-- Description   : 
-- =============================================
CREATE PROCEDURE [inv].[sp_api_StarMobo_AutoSaleHdr]
@ProcessNo as Int,
@FiscalYear as Int,
@DocStep as tinyint,
@DocDate as CHAR(10),
@Amount as FLOAT,
@Price as FLOAT,
@DiscountPercent as FLOAT,
@Discount as FLOAT,
@Discount2 as FLOAT,
@TotalLineDiscount as FLOAT,
@DocDesc as NVARCHAR(500),
@TaxOverWorthCost as FLOAT,
@TollOverWorthCost as FLOAT,
@TransportationIncome as float,
@DiscountTaxOverWorth as Bit

WITH ENCRYPTION
 AS
BEGIN
	DECLARE @maxSerialNo INT
	DECLARE @SaleAcntCodeInSaleTypes BIT
	DECLARE @DiscountAcntCode VARCHAR(20)
	DECLARE @PartXLen	Int;
	Declare @StrErrorMessage As Nvarchar(1024)
	DECLARE @StoreID AS VARCHAR(20)='1003'
	DECLARE @AcntCode AS VARCHAR(20)='12000014'
	DECLARE @SaleTypeID as VARCHAR(20)='00001'
	DECLARE @TransportationIncomeAcntCode as varchar(20)
	Declare @CustomerPartNo AS Tinyint
BEGIN TRY

	
	IF (SELECT COUNT(*) from acc.tblAcnt where AcntCode=@AcntCode)=0
	BEGIN
		Set @StrErrorMessage = N' کد حسابداری '+ @AcntCode+' نامعتبر است'
		raiserror (@StrErrorMessage, 16, 1)
	END

	
	IF (SELECT Count(*) FROM inv.tblStores
		where StoreID=@StoreID )=0
	BEGIN
		--Set @StoreID='10500001'
		Set @StrErrorMessage = N' کد انبار '+ @StoreID+' نامعتبر است'
		raiserror (@StrErrorMessage, 16, 1)
	END	
	
	IF (SELECT Count(*) FROM sal.tblSaleTypes
		where SaleTypeID=@SaleTypeID )=0
	BEGIN
		Set @StrErrorMessage = N' کد نوع فروش  '+@SaleTypeID+' نامعتبر است '
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
	(ProcessID, ProcessNo, FiscalYear, SerialNo, DocStep, DocDate,	StoreID, AcntCode,
	 Amount,Price, DiscountPercent, Discount, Discount2, TotalLineDiscount,DocDesc,SaleTypeID,
	 DiscountAcntCode,TaxOverWorthCost, TollOverWorthCost,DocDate2,DocDate3, DocDate4, IsAutoDoc,
	 TransportationIncomeAcntCode,TransportationIncome,DiscountTaxOverWorth)
	
	SELECT 90, @ProcessNo, @FiscalYear, @maxSerialNo, @DocStep, @DocDate, @StoreID, @AcntCode, 
		  @Amount,@Price,@DiscountPercent,@Discount,@Discount2, @TotalLineDiscount,@DocDesc,
		  @SaleTypeID,@DiscountAcntCode,@TaxOverWorthCost, @TollOverWorthCost,@DocDate DocDate2,
		  @DocDate DocDate3,@DocDate DocDate4,'True' IsAutoDoc,
		  @TransportationIncomeAcntCode,@TransportationIncome,@DiscountTaxOverWorth

         	-----------------

	SELECT 90 ProcessID ,@maxSerialNo SerialNo,@AcntCode AcntCode,@StoreID StoreID,@SaleTypeID SaleTypeID
END TRY
BEGIN CATCH


	Set @StrErrorMessage = ERROR_MESSAGE() 
	raiserror (@StrErrorMessage, 16, 1)

END CATCH

END	
GO
