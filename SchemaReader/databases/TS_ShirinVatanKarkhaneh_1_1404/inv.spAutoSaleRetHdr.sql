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
Create PROCEDURE [inv].[spAutoSaleRetHdr]
@ProcessNo as Int,
@FiscalYear as SMALLINT,
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
@TollOverWorthCost as FLOAT

WITH ENCRYPTION
 AS
BEGIN
	DECLARE @maxSerialNo INT
	DECLARE @SaleAcntCodeInSaleTypes BIT
	DECLARE @DiscountAcntCode VARCHAR(20)
	DECLARE @Part1Start	Int;
	DECLARE @Part2Start	Int;
	DECLARE @Part3Start	Int;
	DECLARE @Part4Start	Int;
	DECLARE @Part1Len	Int;
	DECLARE @Part2Len	Int;
	DECLARE @Part3Len	Int;
	DECLARE @Part4Len	Int;
	Declare @StrErrorMessage As Nvarchar(1024)
BEGIN TRY

	IF @AcntCode=''
	BEGIN
		Set @StrErrorMessage = N'کد مشتری را پر کنید'
		raiserror (@StrErrorMessage, 16, 1)
	END
	
 	SET		@Part1Start = 1;
	SELECT	@Part1Len = Layer1 + Layer2 + Layer3 + Layer4 + Layer5 + Layer6 + Layer7 + Layer8 + Layer9 
	FROM	pub.tblCodeLayer 
	WHERE	(TableName = 'acc.tblAcnt') AND (PartNumber = 1)

	SELECT	@Part2Start = @Part1Start + @Part1Len + 1;
	SELECT	@Part2Len = Layer1 + Layer2 + Layer3 + Layer4 + Layer5 + Layer6 + Layer7 + Layer8 + Layer9 
	FROM	pub.tblCodeLayer 
	WHERE	(TableName = 'acc.tblAcnt') AND (PartNumber = 2)

	SELECT	@Part3Start = @Part2Start + @Part2Len + 1;
	SELECT	@Part3Len = Layer1 + Layer2 + Layer3 + Layer4 + Layer5 + Layer6 + Layer7 + Layer8 + Layer9 
	FROM	pub.tblCodeLayer 
	WHERE	(TableName = 'acc.tblAcnt') AND (PartNumber = 3)

	SELECT	@Part4Start = @Part3Start + @Part3Len + 1;
	SELECT	@Part4Len = Layer1 + Layer2 + Layer3 + Layer4 + Layer5 + Layer6 + Layer7 + Layer8 + Layer9 
	FROM	pub.tblCodeLayer 
	WHERE	(TableName = 'acc.tblAcnt') AND (PartNumber = 4)

	IF (SELECT COUNT(*) from acc.tblAcnt where PartNumber=1 and AcntCode=SUBSTRING(@AcntCode,@Part1Start,@Part1Len))=0
	BEGIN
		Set @StrErrorMessage = N'بخش اول کد حسابداری نامعتبر است'
		raiserror (@StrErrorMessage, 16, 1)
	END

	IF LEN(LTRIM(RTRIM(@AcntCode)))>@Part2Start-1 AND 
	  (SELECT COUNT(*) from acc.tblAcnt where PartNumber=2 and AcntCode=SUBSTRING(@AcntCode,@Part2Start,@Part2Len))=0
	BEGIN
		Set @StrErrorMessage = N'بخش دوم کد حسابداری نامعتبر است'
		raiserror (@StrErrorMessage, 16, 1)
	END

	IF LEN(LTRIM(RTRIM(@AcntCode)))>@Part3Start-1 AND 
	  (SELECT COUNT(*) from acc.tblAcnt where PartNumber=3 and AcntCode=SUBSTRING(@AcntCode,@Part3Start,@Part3Len))=0
	BEGIN
		Set @StrErrorMessage = N'بخش سوم کد حسابداری نامعتبر است'
		raiserror (@StrErrorMessage, 16, 1)
	END
	
	IF LEN(LTRIM(RTRIM(@AcntCode)))>@Part4Start-1 AND 
	  (SELECT COUNT(*) from acc.tblAcnt where PartNumber=4 and AcntCode=SUBSTRING(@AcntCode,@Part4Start,@Part4Len))=0
	BEGIN
		Set @StrErrorMessage = N'بخش چهار کد حسابداری نامعتبر است'
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
	
	SELECT  @SaleAcntCodeInSaleTypes = SettingValue
	FROM pub.tblSettings
	WHERE SettingKey = 'SaleAcntCodeInSaleTypes'
	
    If @SaleAcntCodeInSaleTypes =1
		SELECT @DiscountAcntCode =SaleDiscountAcntCode FROM sal.tblSaleTypes WHERE SaleTypeID <>'' AND SaleTypeID =@SaleTypeID
    Else
		SELECT @DiscountAcntCode =SaleDiscountAcntCode FROM inv.tblStores WHERE StoreID <>'' AND StoreID = @SaleTypeID

	SELECT @maxSerialNo = isnull(MAX(SerialNo),0)
	FROM inv.tblStorageDocsHdr 
	WHERE ProcessID=100
	  AND ProcessNo=@ProcessNo
	  AND FiscalYear=@FiscalYear
			 
	SET @maxSerialNo = @maxSerialNo +1

	INSERT INTO inv.tblStorageDocsHdr
	(ProcessID, ProcessNo, FiscalYear, SerialNo, DocStep, DocDate,	StoreID, AcntCode,
	 Amount,Price, DiscountPercent, Discount, Discount2, TotalLineDiscount,DocDesc,SaleTypeID,
	 DiscountAcntCode,TaxOverWorthCost, TollOverWorthCost,DocDate2, IsAutoDoc)
	
	SELECT 100, @ProcessNo, @FiscalYear, @maxSerialNo, @DocStep, @DocDate, @StoreID, @AcntCode, 
		  @Amount,@Price,@DiscountPercent,@Discount,@Discount2, @TotalLineDiscount,@DocDesc,@SaleTypeID,
		  @DiscountAcntCode,@TaxOverWorthCost, @TollOverWorthCost,@DocDate DocDate2,'True' IsAutoDoc

         	-----------------

	SELECT @maxSerialNo SerialNo
END TRY
BEGIN CATCH

	Set @StrErrorMessage = ERROR_MESSAGE() 
	raiserror (@StrErrorMessage, 16, 1)

END CATCH

END	
GO
