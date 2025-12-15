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
Create PROCEDURE [sal].[sp_api_TakroSystem_CreateOrUpdateSaleOrderDtl]
@ProcessNo as tinyint,
@FiscalYear as SMALLINT,
@SerialNo as Int,
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
Declare @MaxRowNo as Int
	Declare @AcntPart as int
	Declare @Moin as nvarchar(50)
BEGIN TRY

	

	IF (SELECT Count(*) FROM inv.tblGoods
		where GoodsID=@GoodsID )<>1
	BEGIN
		Set @StrErrorMessage = N'کد کالا صحیح نیست'
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


	----NoEditFromMobile
	--IF (SELECT NoEditFromMobile FROM sal.tblSaleOrderHdr
	--	where ProcessID=180 and ProcessNo=@ProcessNo and  FiscalYear=@FiscalYear and SerialNo=@SerialNo )=1
	--BEGIN
	--	Set @StrErrorMessage = N'فاکتور تایید شده است امکان حذف و ویرایش مقدور نیست'
	--	raiserror (@StrErrorMessage, 16, 1)
	--END	

	--Update or quantity=0 =>Delete
	if (select count (*) from sal.tblSaleOrderDtl
	 where GoodsID=@GoodsID and SerialNo=@SerialNo and 
		   ProcessNo=@ProcessNo and ProcessID=180 and FiscalYear=@FiscalYear)>0
	BEGIN
		SELECT @MaxRowNo = RowNo
		FROM sal.tblSaleOrderDtl 
		WHERE ProcessID=180
		 AND ProcessNo=@ProcessNo
		 AND FiscalYear=@FiscalYear
		 AND SerialNo=@SerialNo
		 AND GoodsID=@GoodsID

		if @Quantity=0

		--Delete
		BEGIN
			
			DELETE FROM  sal.tblSaleOrderDtl
			where RowNo=@MaxRowNo AND 
				  ProcessID=180 AND 
				  ProcessNo=@ProcessNo AND 
				  FiscalYear=@FiscalYear AND 
				  SerialNo=@SerialNo AND 
				  GoodsID=@GoodsID

			Select 'Delete' As ActionName,@MaxRowNo

		END

		ELSE

		--Update
		BEGIN
			
			update sal.tblSaleOrderDtl
			set  StoreID=@StoreID, AcntCode=@AcntCode,
			GoodsID=@GoodsID, SubUnitQuantity=@Quantity,GoodsQuantity=@Quantity, GoodsPrice=@GoodsPrice,
			DescDtl=@DescDtl,SubUnitPrice=@GoodsPrice,VisitorAcntCode=@VisitorAcntCode
			where
			ProcessID=180 and ProcessNo=@ProcessNo and  FiscalYear=@FiscalYear and SerialNo=@SerialNo and RowNo=@MaxRowNo

			Select 'Update' As ActionName,@MaxRowNo
		END
	End

	--Create
	ELSE
	
	Begin

		SELECT @MaxRowNo = isnull(MAX(RowNo),0)
		FROM sal.tblSaleOrderDtl 
		WHERE ProcessID=180
		 AND ProcessNo=@ProcessNo
		 AND FiscalYear=@FiscalYear
		 AND SerialNo=@SerialNo
			 
		SET @MaxRowNo = @MaxRowNo +1

		INSERT INTO sal.tblSaleOrderDtl
			(ProcessID, ProcessNo, FiscalYear, SerialNo, RowNo, DocRowNo,
			DocStep, DocDate, StoreID, AcntCode,
			GoodsID, SubUnitID, SubUnitQuantity,GoodsQuantity, GoodsPrice,
			DescDtl,SubUnitPrice,VisitorAcntCode)
	
		select 180, @ProcessNo, @FiscalYear, @SerialNo, @MaxRowNo , @MaxRowNo ,
			@DocStep, @DocDate, @StoreID, @AcntCode, 
		    @GoodsID,UnitID ,@Quantity ,@Quantity ,@GoodsPrice ,
		    @DescDtl ,@GoodsPrice SubUnitPrice,@VisitorAcntCode
		FROM inv.tblGoods 
		where GoodsID=@GoodsID

		Select 'Create' As ActionName,@MaxRowNo
	End
	
    
END TRY
BEGIN CATCH

	Set @StrErrorMessage = ERROR_MESSAGE() 
	raiserror (@StrErrorMessage, 16, 1)

END CATCH

END	

GO
