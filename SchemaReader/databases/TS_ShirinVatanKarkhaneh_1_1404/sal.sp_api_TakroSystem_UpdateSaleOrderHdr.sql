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
Create PROCEDURE [sal].[sp_api_TakroSystem_UpdateSaleOrderHdr]
@ProcessNo as Int,
@FiscalYear as Int,
@SerialNo as int,
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
@VisitorAcntCode as nvarchar(100),
@SessionNo as int,
@TransferSerialNo as nvarchar(50)

WITH ENCRYPTION
 AS
BEGIN

Declare @StrErrorMessage As Nvarchar(1024)
DECLARE @IsNoEdit AS bit
DECLARE @AcntPart AS INT
DECLARE @Moin AS NVARCHAR(50)
BEGIN TRY
	set @SaleTypeID='00001'
	set @StoreID='01'

	--VALIDATIONS
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
	
	IF (SELECT NoEditFromMobile FROM sal.tblSaleOrderHdr
		where ProcessID=180 and ProcessNo=@ProcessNo and  FiscalYear=@FiscalYear and SerialNo=@SerialNo )=1
	BEGIN
		DECLARE @strSerialNo AS NVARCHAR(50)
		SET @strSerialNo=CAST(@SerialNo AS NVARCHAR(50))
		Set @StrErrorMessage = N'فاکتور '+@strSerialNo+' تایید شده است ، حذف و ویرایش امکان پذیر نیست'
		raiserror (@StrErrorMessage, 16, 1)
	END	

	
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


	--UPDATE
	update sal.tblSaleOrderHdr
	set DocDate=@DocDate,DocTime=@DocTime,StoreID=@StoreID, AcntCode=@AcntCode,OrderName=@AcntName,
	 Amount=@Amount,Price=@Price, DiscountPercent=@DiscountPercent, Discount=@Discount, Discount2=@Discount2,
	 TotalLineDiscount=@TotalLineDiscount,DocDesc=@DocDesc,SaleTypeID=SaleTypeID,TaxOverWorthCost=@TaxOverWorthCost, 
	 TollOverWorthCost =@TollOverWorthCost,SessionNo=@SessionNo,VisitorAcntCode=@VisitorAcntCode,TransferSerialNo=@TransferSerialNo
	where 
	 ProcessID=180 and ProcessNo=@ProcessNo and  FiscalYear=@FiscalYear and SerialNo=@SerialNo 

         	-----------------

	SELECT @SerialNo SerialNo,@StoreID StoreID,@SaleTypeID SaleTypeID

END TRY
BEGIN CATCH


	Set @StrErrorMessage = ERROR_MESSAGE() 
	raiserror (@StrErrorMessage, 16, 1)

END CATCH

END	
GO
