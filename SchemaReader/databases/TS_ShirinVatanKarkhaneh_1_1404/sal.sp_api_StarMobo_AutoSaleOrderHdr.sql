USE TS_ShirinVatanKarkhaneh_1_1404
GO
SET ANSI_NULLS, QUOTED_IDENTIFIER ON
GO
-- =========== TS-QC:NOTOK ========================
-- Author        : Alian
-- Create date   : 1400/09/22
-- Viewed By	 : 
-- Last Modified : 
-- Description   : 
-- =============================================
Create PROCEDURE [sal].[sp_api_StarMobo_AutoSaleOrderHdr]
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
@DiscountTaxOverWorth as Bit,
@TransferSerialNo as Nvarchar(30),
@AcntCode as NVARCHAR(50)

WITH ENCRYPTION
 AS
BEGIN
	DECLARE @maxSerialNo INT
	DECLARE @SaleAcntCodeInSaleTypes BIT
	DECLARE @DiscountAcntCode VARCHAR(20)
	DECLARE @PartXLen	Int;
	Declare @StrErrorMessage As Nvarchar(1024)

	DECLARE @SaleTypeID as VARCHAR(20)='00002'
	DECLARE @TransportationIncomeAcntCode as varchar(20)
	Declare @CustomerPartNo AS Tinyint
BEGIN TRY

	if(select COUNT(*) from sal.tblSaleOrderHdr where TransferSerialNo=@TransferSerialNo)=0
	BEGIN
		SET @Price=@Price*10

		IF (SELECT COUNT(*) from acc.tblAcnt where AcntCode=@AcntCode and PartNumber=2)=0
		BEGIN
			Set @StrErrorMessage = N' کد حسابداری '+ @AcntCode+' نامعتبر است'
			raiserror (@StrErrorMessage, 16, 1)
		END	
	
		SET @AcntCode='111307 '+@AcntCode
	
		IF (SELECT Count(*) FROM sal.tblSaleTypes
			where SaleTypeID=@SaleTypeID )=0
		BEGIN
			Set @StrErrorMessage = N' کد نوع فروش  '+@SaleTypeID+' نامعتبر است '
			raiserror (@StrErrorMessage, 16, 1)
		END	
	
		SELECT @maxSerialNo = isnull(MAX(SerialNo),0)
		FROM sal.tblSaleOrderHdr 
		WHERE ProcessID=180
		AND ProcessNo=@ProcessNo
		AND FiscalYear=@FiscalYear
			 
		SET @maxSerialNo = @maxSerialNo +1

		INSERT INTO sal.tblSaleOrderHdr
			(ProcessID, ProcessNo, FiscalYear, SerialNo, DocStep, DocDate, AcntCode,
			 Amount,Price, DiscountPercent, Discount, Discount2, TotalLineDiscount,DocDesc,
			SaleTypeID,TaxOverWorthCost, TollOverWorthCost,DocDate2,
			 TransportationIncomeAcntCode,TransportationIncome,TransferSerialNo)
	
		SELECT 180, @ProcessNo, @FiscalYear, @maxSerialNo, @DocStep, @DocDate, @AcntCode, 
		  @Amount,@Price,@DiscountPercent,@Discount,@Discount2, @TotalLineDiscount,@DocDesc+' '+@TransferSerialNo,
		  @SaleTypeID,@TaxOverWorthCost, @TollOverWorthCost,@DocDate DocDate2,
		  '',@TransportationIncome,@TransferSerialNo

         	-----------------

		SELECT 180 ProcessID ,@maxSerialNo SerialNo,@AcntCode AcntCode,@SaleTypeID SaleTypeID
	END
		SELECT 180 ProcessID ,0 SerialNo,@AcntCode AcntCode,@SaleTypeID SaleTypeID


END TRY
BEGIN CATCH


	Set @StrErrorMessage = ERROR_MESSAGE() 
	raiserror (@StrErrorMessage, 16, 1)

END CATCH

END	
GO
