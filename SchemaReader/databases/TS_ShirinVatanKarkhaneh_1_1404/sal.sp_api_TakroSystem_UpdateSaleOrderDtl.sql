USE TS_ShirinVatanKarkhaneh_1_1404
GO
SET ANSI_NULLS, QUOTED_IDENTIFIER ON
GO
-- =========== TS-QC:NOTOK ========================
-- Author        : Alian Pour
-- Create date   : 1400/09/01
-- Viewed By	 : 
-- Last Modified : 
-- Description   : 
-- =============================================
Create PROCEDURE [sal].[sp_api_TakroSystem_UpdateSaleOrderDtl]
@ProcessNo as tinyint,
@FiscalYear as SMALLINT,
@SerialNo as Int,
@RowNo as Int,
@DocStep as tinyint,
@GoodsID AS VARCHAR(20),
@Quantity as FLOAT,
@GoodsPrice as FLOAT,
@SubUnitID as varchar(30),
@AcntCode AS VARCHAR(20),
@DescDtl as NVARCHAR(500),
@DocDate as CHAR(10),
@VisitorAcntCode as varchar(20),
@StoreID AS VARCHAR(20),
@SaleTypeID as VARCHAR(20)


WITH ENCRYPTION
 AS
BEGIN

Declare @StrErrorMessage As Nvarchar(1024)
DECLARE @AcntPart AS INT
DECLARE @Moin AS NVARCHAR(50)
BEGIN TRY


	IF (SELECT Count(*) FROM inv.tblGoods
		where GoodsID=@GoodsID )<>1
	BEGIN
		Set @StrErrorMessage = N'کد کالا صحیح نیست'
		raiserror (@StrErrorMessage, 16, 1)
	END	
	
	--NoEditFromMobile
	IF (SELECT NoEditFromMobile FROM sal.tblSaleOrderHdr
		where ProcessID=180 and ProcessNo=@ProcessNo and  FiscalYear=@FiscalYear and SerialNo=@SerialNo )=1
	BEGIN
		DECLARE @strSerialNo AS NVARCHAR(50)
		SET @strSerialNo=CAST(@SerialNo AS NVARCHAR(50))
		Set @StrErrorMessage = N'فاکتور '+@strSerialNo+' تایید شده است ، حذف و ویرایش امکان پذیر نیست'
		raiserror (@StrErrorMessage, 16, 1)
	END	
	--Visitor Moin

	IF (SELECT count(*) AS SettingValue  
        FROM pub.tblSettings  
        WHERE SettingKey='SetAcntCodeForVisitorAcntCode') =1
	
	begin 

		DECLARE @MoinAcntCode AS NVARCHAR(50)

		SELECT @MoinAcntCode= isnull(rtrim(ltrim(SettingValue)),'') 
		FROM pub.tblSettings 
		WHERE SettingKey='salConstantAcntCodeForVisitor'

		SET @VisitorAcntCode=@MoinAcntCode+' '+@VisitorAcntCode

	end

	---Acnt Moin
	SELECT @AcntPart = SettingValue
	FROM pub.tblSettings
	WHERE SettingKey = 'AcntPartNumberForRemainCalculation'

	IF(@AcntPart=2)
	BEGIN

		SELECT @Moin= isnull(rtrim(ltrim(SettingValue)),'') 
                FROM pub.tblSettings 
                WHERE SettingKey LIKE '%BuyerAcntCodeInSale%'
		IF(@Moin='')
		BEGIN
			Set @StrErrorMessage ='کد پیش فرض خریدار در فروش را وارد کنید'
			raiserror (@StrErrorMessage, 16, 1)
		END
		SET @AcntCode=@Moin+' '+@AcntCode
	END

	update sal.tblSaleOrderDtl
	set DocDate=@DocDate, StoreID=@StoreID, AcntCode=@AcntCode,
	GoodsID=@GoodsID, SubUnitID=@SubUnitID, SubUnitQuantity=@Quantity,GoodsQuantity=@Quantity, GoodsPrice=@GoodsPrice,
	DescDtl=@DescDtl,SubUnitPrice=@GoodsPrice,VisitorAcntCode=@VisitorAcntCode
	where
	 ProcessID=180 and ProcessNo=@ProcessNo and  FiscalYear=@FiscalYear and SerialNo=@SerialNo and RowNo=@RowNo
    
END TRY
BEGIN CATCH

	Set @StrErrorMessage = ERROR_MESSAGE() 
	raiserror (@StrErrorMessage, 16, 1)

END CATCH

END	

GO
