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
Create PROCEDURE [sal].[sp_api_TakroSystem_AutoSaleOrderDtl]
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

	INSERT INTO sal.tblSaleOrderDtl
	(ProcessID, ProcessNo, FiscalYear, SerialNo, RowNo, DocRowNo,
	DocStep, DocDate, StoreID, AcntCode,
	GoodsID, SubUnitID, SubUnitQuantity,GoodsQuantity, GoodsPrice,
	DescDtl,SubUnitPrice,VisitorAcntCode)
	
	select 180, @ProcessNo, @FiscalYear, @SerialNo, @RowNo , @RowNo ,
		   @DocStep, @DocDate, @StoreID, @AcntCode, 
		   @GoodsID,UnitID ,@Quantity ,@Quantity ,@GoodsPrice ,
		   @DescDtl ,@GoodsPrice SubUnitPrice,@VisitorAcntCode
	FROM inv.tblGoods 
	where GoodsID=@GoodsID
    
END TRY
BEGIN CATCH

	Set @StrErrorMessage = ERROR_MESSAGE() 
	raiserror (@StrErrorMessage, 16, 1)

END CATCH

END	

GO
