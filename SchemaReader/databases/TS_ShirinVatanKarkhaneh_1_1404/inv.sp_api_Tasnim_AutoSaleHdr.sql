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
create PROCEDURE [inv].[sp_api_Tasnim_AutoSaleHdr]
@ProcessNo as Int,
@FiscalYear as Int,
@DocStep as tinyint,
@DocDate as CHAR(10),
@StoreID AS VARCHAR(20),
@AcntCode AS VARCHAR(20),
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
	DECLARE @PartXLen	Int;
	Declare @StrErrorMessage As Nvarchar(1024)
	DECLARE @AcntCustomerCode as Varchar(20)='3'
	DECLARE @TransportationIncomeAcntCode as varchar(20)
	DECLARE @CustomerPartNo AS Tinyint
	DECLARE @BaseSerialNo  INT

BEGIN TRY
	
	if (select count(*) from inv.tblStorageDocsHdr where TransferSerialNo=@OrderId)=0
	begin
	
	IF @AcntCode=''
	BEGIN
		Set @StrErrorMessage = N'کد مشتری را پر کنید'
		raiserror (@StrErrorMessage, 16, 1)
	END
	
 	SET @CustomerPartNo = 1
	
	SELECT @CustomerPartNo = SettingValue
	FROM pub.tblSettings
	WHERE SettingKey = 'AcntPartNumberForRemainCalculation'

	SELECT	@PartXLen = Layer1 + Layer2 + Layer3 + Layer4 + Layer5 + Layer6 + Layer7 + Layer8 + Layer9 
	FROM	pub.tblCodeLayer 
	WHERE	(TableName = 'acc.tblAcnt') AND (PartNumber = @CustomerPartNo)

	SELECT @AcntCode = @AcntCustomerCode + pub.funPadLeft(@AcntCode,'0',@PartXLen-LEN(@AcntCustomerCode))
	
	IF (SELECT COUNT(*) from acc.tblAcnt where PartNumber=@CustomerPartNo and AcntCode=@AcntCode)=0
	BEGIN
		Set @StrErrorMessage = N' کد حسابداری نامعتبر است'
		raiserror (@StrErrorMessage, 16, 1)
	END

	
	IF (SELECT Count(*) FROM inv.tblStores
		where StoreID=@StoreID )=0
	BEGIN
		Set @StrErrorMessage = N'کد انبار '+@StoreID+' نامعتبر است'
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
	FROM inv.tblStorageDocsHdr 
	WHERE ProcessID=90
	  AND ProcessNo=@ProcessNo
	  AND FiscalYear=@FiscalYear
			 
	SET @maxSerialNo = @maxSerialNo +1

	
	INSERT INTO inv.tblStorageDocsHdr
		(ProcessID, ProcessNo, FiscalYear, SerialNo, DocStep, DocDate,	StoreID, AcntCode,
		Amount,Price, DiscountPercent, Discount, Discount2, TotalLineDiscount,DocDesc,SaleTypeID,
		DiscountAcntCode,TaxOverWorthCost, TollOverWorthCost,DocDate2,DocDate3, DocDate4, IsAutoDoc,
		TransportationIncomeAcntCode,TransportationIncome,TransferSerialNo)
	
	SELECT 90, @ProcessNo, @FiscalYear, @maxSerialNo, @DocStep, @DocDate, @StoreID, @AcntCode, 
		@Amount,@Price,@DiscountPercent,@Discount,@Discount2, @TotalLineDiscount,@DocDesc,
		@SaleTypeID,@DiscountAcntCode,@TaxOverWorthCost, @TollOverWorthCost,@DocDate DocDate2,
		@DocDate DocDate3,@DocDate DocDate4,'True' IsAutoDoc,
		@TransportationIncomeAcntCode,@TransportationIncome,@TransferSerialNo
	
	select @BaseSerialNo =isnull(SerialNo,0) from sal.tblSaleOrderHdr where TransferSerialNo=@OrderId
	
	if @BaseSerialNo is not null
	begin
		update inv.tblStorageDocsHdr
		set BaseSerialNo=@BaseSerialNo,BaseProcessNo=@ProcessNo,BaseProcessID=180,BaseDocType=180,BaseFiscalYear=@FiscalYear
		where SerialNo=@maxSerialNo and ProcessID=90 and ProcessNo=@ProcessNo and FiscalYear=@FiscalYear
	end
	else
	select @BaseSerialNo=0


	SELECT 90 ProcessID ,@maxSerialNo SerialNo,@AcntCode AcntCode,@StoreID StoreID,@SaleTypeID SaleTypeID,0 IsExist,@BaseSerialNo BaseSerialNo
  End
	
  else
	SELECT 90 ProcessID ,1 SerialNo,'' AcntCode,1 StoreID,'' SaleTypeID,1 IsExist,0 BaseSerialNo

END TRY
BEGIN CATCH


	Set @StrErrorMessage = ERROR_MESSAGE() 
	raiserror (@StrErrorMessage, 16, 1)

END CATCH

END	
GO
