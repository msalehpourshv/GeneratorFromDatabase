USE TS_ShirinVatanKarkhaneh_1_1404
GO
SET ANSI_NULLS, QUOTED_IDENTIFIER ON
GO
-- =========== TS-QC:NOTOK ========================
-- Author        : Alian Pour
-- Create date   : 1400/06/03
-- Viewed By	 : 
-- Last Modified : 
-- Description   : 
-- =============================================
CREATE PROCEDURE [sal].[sp_api_Tasnim_AutoSaleOrderHdr]
@ProcessNo as Int,
@FiscalYear as Int,
@DocStep as tinyint,
@DocDate as CHAR(10),
@StoreID AS VARCHAR(20),
--@AcntCode AS VARCHAR(20),
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
@TransportationIncome as float,
@TransferSerialNo as NVARCHAR(100),
@OrderId as NVARCHAR(100)

WITH ENCRYPTION
 AS
BEGIN
	DECLARE @maxSerialNo INT
	DECLARE @SaleAcntCodeInSaleTypes BIT
	DECLARE @DiscountAcntCode VARCHAR(20)
	Declare @StrErrorMessage As Nvarchar(1024)
	Declare @AcntCode1 AS VARCHAR(20)='1'
	--DECLARE @AcntCustomerCode as Varchar(20)='3'
	--DECLARE @PartXLen	Int;
	--Declare @CustomerPartNo AS Tinyint
	DECLARE @TransportationIncomeAcntCode as varchar(20)

BEGIN TRY

	if (select count(*) from sal.tblSaleOrderHdr where TransferSerialNo=@OrderId)=0
	begin

	IF @AcntCode1=''
	BEGIN
		--Set @StrErrorMessage = N'کد مشتری را پر کنید'
		Set @StrErrorMessage = N'کد مشتری صحیح نمی باشد'
		raiserror (@StrErrorMessage, 16, 1)
	END
	
 	--SET @CustomerPartNo = 1
	
	--SELECT @CustomerPartNo = SettingValue
	--FROM pub.tblSettings
	--WHERE SettingKey = 'AcntPartNumberForRemainCalculation'

	--SELECT	@PartXLen = Layer1 + Layer2 + Layer3 + Layer4 + Layer5 + Layer6 + Layer7 + Layer8 + Layer9 
	--FROM	pub.tblCodeLayer 
	--WHERE	(TableName = 'acc.tblAcnt') AND (PartNumber = @CustomerPartNo)

	---SELECT @AcntCode = @AcntCustomerCode + pub.funPadLeft(@AcntCode,'0',@PartXLen-LEN(@AcntCustomerCode))
	
	--IF (SELECT COUNT(*) from acc.tblAcnt where PartNumber=@CustomerPartNo and AcntCode=@AcntCode)=0
	IF (SELECT COUNT(*) from acc.tblAcnt where AcntCode=@AcntCode1)=0
	BEGIN
		Set @StrErrorMessage = N' کد حسابداری '+@AcntCode1+' نامعتبر است'
		raiserror (@StrErrorMessage, 16, 1)
	END


	IF (SELECT Count(*) FROM inv.tblStores
		where StoreID=@StoreID )=0
	BEGIN
		Set @StrErrorMessage = N'کد انبار  '+@StoreID+' نامعتبر است '
		raiserror (@StrErrorMessage, 16, 1)
	END	
	
	IF (SELECT Count(*) FROM sal.tblSaleTypes
		where SaleTypeID=@SaleTypeID )=0
	BEGIN
		Set @StrErrorMessage = N'کد نوع فروش نامعتبر است'
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
	FROM [sal].[tblSaleOrderHdr]
	WHERE ProcessID=180
	  AND ProcessNo=@ProcessNo
	  AND FiscalYear=@FiscalYear
			 
	SET @maxSerialNo = @maxSerialNo +1

	INSERT INTO [sal].[tblSaleOrderHdr]
	(ProcessID, ProcessNo, FiscalYear, SerialNo, DocStep, DocDate,	StoreID, AcntCode,
	 Amount,Price, DiscountPercent, Discount, Discount2, TotalLineDiscount,DocDesc,SaleTypeID,
	 TaxOverWorthCost, TollOverWorthCost,DocDate2,
	 TransportationIncomeAcntCode,TransportationIncome,TransferSerialNo)
	
	SELECT 180, @ProcessNo, @FiscalYear, @maxSerialNo, @DocStep, @DocDate, @StoreID, @AcntCode1, 
		  @Amount,@Price,@DiscountPercent,@Discount,@Discount2, @TotalLineDiscount,@DocDesc,
		  @SaleTypeID,@TaxOverWorthCost, @TollOverWorthCost,@DocDate DocDate2,
		  @TransportationIncomeAcntCode,@TransportationIncome,@TransferSerialNo

         	-----------------

	SELECT 180 ProcessID ,@maxSerialNo SerialNo,@AcntCode1 AcntCode,@StoreID StoreID,@SaleTypeID SaleTypeID,0 IsExist
	End

	else
	SELECT 180 ProcessID ,1 SerialNo,'' AcntCode,1 StoreID,'' SaleTypeID,1 IsExist

END TRY
BEGIN CATCH


	Set @StrErrorMessage = ERROR_MESSAGE() 
	raiserror (@StrErrorMessage, 16, 1)

END CATCH

END	
GO
