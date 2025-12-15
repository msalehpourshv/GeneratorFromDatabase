USE TS_ShirinVatanKarkhaneh_1_1404
GO
SET ANSI_NULLS, QUOTED_IDENTIFIER ON
GO

-- =========== TS-QC:NOTOK ========================
-- Author        : Alian Pour
-- Create date   : 1400/08/28
-- Viewed By	 : 
-- Last Modified : 
-- Description   : 
-- =============================================
Create PROCEDURE [inv].[sp_api_TakroSystem_SearchSaleHdrForTransfer]
@SerialNo 	 AS int ,
@ProcessId AS int,
@FiscalYear AS int,
@ProcessNo AS int


WITH ENCRYPTION
 AS
BEGIN
	DECLARE @StrErrorMessage NVARCHAR(MAX)
	DECLARE @CompanyEconimicCode NVARCHAR(MAX)
	DECLARE @CompanyNationalCode NVARCHAR(MAX)
	DECLARE @CompanyNationalIdentity NVARCHAR(MAX)
	DECLARE @CompanyPersonalityType NVARCHAR(MAX)
	DECLARE @TaxBranchId NVARCHAR(MAX)
	DECLARE @PartNumber int
	DECLARE @BranchPart AS varchar(50) 
	DECLARE @BranchPartLen AS varchar(50)
	DECLARE @StartTo AS varchar(50)='0'
	declare @From as int
	declare @To as int
	declare @PartNumberGoods as int
	declare @Len1 as int
	declare @Len2 as int
	declare @Len3 as int
	declare @Len4 as int
	DECLARE @Sal_SaleProcessForTaxTollSender1  AS NVARCHAR(50) ='1'
BEGIN TRY
	--********************************************************

	IF(@ProcessNo=1)
	BEGIN
		SELECT @Sal_SaleProcessForTaxTollSender1=ISNULL(SettingValue,'1') FROM pub.tblSettings 
		WHERE SettingKey='Sal_SaleProcessForTaxTollSender1' 

		IF( @Sal_SaleProcessForTaxTollSender1<>'True' OR @Sal_SaleProcessForTaxTollSender1=''  OR @Sal_SaleProcessForTaxTollSender1='1')
		BEGIN
			Set @StrErrorMessage ='این نوع فروش برای ارسال در  سامانه تعریف نشده است'
			raiserror (@StrErrorMessage, 16, 1)
		END
	END

	ELSE
	BEGIN
		Set @StrErrorMessage ='این نوع فروش برای ارسال در  سامانه تعریف نشده است'
		raiserror (@StrErrorMessage, 16, 1)
	END
	--********************************************************
	select @PartNumberGoods=isnull(SettingValue,0) from pub.tblSettings
	where SettingKey = 'UnitPart' and 1=1

	select @Len1=Layer1+Layer2+Layer3+Layer4+Layer5+Layer6+Layer7+Layer8+Layer9 from pub.tblCodeLayer where TableName='inv.tblGoods' and PartNumber=1 
	select @Len2=Layer1+Layer2+Layer3+Layer4+Layer5+Layer6+Layer7+Layer8+Layer9 from pub.tblCodeLayer where TableName='inv.tblGoods' and PartNumber=2
	select @Len3=Layer1+Layer2+Layer3+Layer4+Layer5+Layer6+Layer7+Layer8+Layer9 from pub.tblCodeLayer where TableName='inv.tblGoods' and PartNumber=3 
	select @Len4=Layer1+Layer2+Layer3+Layer4+Layer5+Layer6+Layer7+Layer8+Layer9 from pub.tblCodeLayer where TableName='inv.tblGoods' and PartNumber=4
	
	if(@PartNumberGoods=0)
	 set @PartNumberGoods=1

	if(@PartNumberGoods=1)
	begin
	 set @To=@Len1
	 set @From= 1
	end

	if(@PartNumberGoods=2)
	begin
	 set @To=@Len2
	 set @From= @Len1+1
	end

	if(@PartNumberGoods=3)
	begin
	 set @To=@Len3
	 set @From= @Len1+@Len2+1
	end

	if(@PartNumberGoods=4)
	begin
	 set @To=@Len4
	 set @From= @Len1+@Len2+@Len3+1
	end


	--********************************************************
	IF (SELECT COUNT(*) FROM pub.tblSettings WHERE SettingKey = 'TaxBranchID' )>0
		SELECT @TaxBranchId= SettingValue 
		FROM pub.tblSettings
		WHERE SettingKey ='TaxBranchID'
	
	SELECT @PartNumber=SettingValue FROM pub.tblSettings
	WHERE SettingKey = 'AcntPartNumberForRemainCalculation'
	
	--********************************************************
	SELECT @BranchPart=ISNULL(SettingValue,'0')
	FROM pub.tblSettings
	WHERE SettingKey = 'TaxTollSendBranchAcntCode'

	SELECT @BranchPartLen=ISNULL(SettingValue,'0') 
	FROM pub.tblSettings
	WHERE SettingKey = 'TaxTollSendBranchAcntCodeLen'
	
	IF(@BranchPart='2')
		select @StartTo=Layer1+Layer2+Layer3+Layer4+Layer5+Layer6+Layer7+Layer8+Layer9 from pub.tblCodeLayer
		where PartNumber=1 and TableName='acc.tblAcnt'
	IF(@BranchPart='3')
	BEGIN
		select @StartTo=Layer1+Layer2+Layer3+Layer4+Layer5+Layer6+Layer7+Layer8+Layer9 from pub.tblCodeLayer
		where PartNumber=1 and TableName='acc.tblAcnt'

		select @StartTo=@StartTo+Layer1+Layer2+Layer3+Layer4+Layer5+Layer6+Layer7+Layer8+Layer9 from pub.tblCodeLayer
		where PartNumber=2 and TableName='acc.tblAcnt'
	END

	SELECT 
	-------------------------------------------------مبلغ نقدی--------------------------------------------------------------------------------
	CASE
		WHEN H.PayType=2 THEN (CAST(floor(PayTypeCashAmount) AS decimal))
		WHEN H.PayType=1 THEN (CAST(floor (H.Price-
		CASE WHEN DiscountTaxOverWorth=1 THEN TotalLineDiscount+H.TaxOverWorthCost
			 WHEN DiscountTaxOverWorth=0 THEN TotalLineDiscount
		END
		)as decimal))
		WHEN H.PayType=0 THEN (CAST(0 AS DECIMAL))
	END Cap,
	-------------------------------------------------مبلغ نسیه--------------------------------------------------------------------------------
	CASE
		--WHEN PayType=3 THEN CAST((CAST (FLOOR(H.Price) AS DECIMAL))-PayTypeCashAmount AS DECIMAL)--+CAST(FLOOR(TaxOverWorthCost +TollOverWorthCost) AS DECIMAL)
		WHEN H.PayType=2 THEN CAST(floor((H.Price-
		CASE WHEN DiscountTaxOverWorth=1 THEN TotalLineDiscount+H.TaxOverWorthCost
			 WHEN DiscountTaxOverWorth=0 THEN TotalLineDiscount
		END
		) -PayTypeCashAmount) AS decimal)
		WHEN H.PayType=1 THEN (CAST(0 AS DECIMAL))
		WHEN H.PayType=0 THEN (CAST(0 AS DECIMAL))
	END Insp,
	-------------------------------------------------مالیات مبلغ برای نقد و نسیه----------------------------------------------------------------
	CASE
		WHEN H.PayType=3 THEN CAST(floor ((PayTypeCashAmount/ ( H.Price  + (H.TaxOverWorthCost +H.TollOverWorthCost ))*(H.TaxOverWorthCost +H.TollOverWorthCost )))as decimal)
		WHEN H.PayType=1 THEN CAST(floor((H.TaxOverWorthCost +H.TollOverWorthCost) ) AS decimal)
		WHEN H.PayType=0 or H.PayType=2 THEN  (CAST(0 AS DECIMAL))
	END Tvop,
	H.Price,
	------------------------------------------------- محاسبه مبالغ---------------------------------------------------------------------------------
	CAST(floor (H.Price) AS DECIMAL) AS PriceBeforDiscount,

	CAST(
		case 
			when Discount<>0  or Discount is not null then Discount
			when Discount2<>0 or Discount2 is not null then Discount2
			when Discount3<>0 or Discount3 is not null then Discount3
			when DiscountTaxOverWorth<>0 or DiscountTaxOverWorth is not null then DiscountTaxOverWorth
			when AfterSaleDiscount<>0 or AfterSaleDiscount is not null then AfterSaleDiscount
			when AfterSaleDiscount=0 and DiscountTaxOverWorth=0 and Discount3=0 and Discount2=0 and Discount=0 then 0
		end
	AS decimal) AS Discount2,

		CAST(
		case 
			when TransferAmountFor<>0   or   TransferAmountFor   is not null then TransferAmountFor
			when Acnt.TransferCostIsForce<>0	or Acnt.TransferCostIsForce is not null  then Acnt.TransferCostIsForce
			when TransportationCost<>0	or TransportationCost  is not null then TransportationCost
			when PackingCost<>0			or TransportationCost  is not null then PackingCost
			when PackingCost=0 and TransportationCost=0 and Acnt.TransferCostIsForce=0 and TransferAmountFor=0 then 0
		end
	AS decimal) AS OtherPrice,


	CAST(floor (CASE 
				WHEN DiscountTaxOverWorth=1 THEN TotalLineDiscount+H.TaxOverWorthCost
				WHEN DiscountTaxOverWorth=0 THEN TotalLineDiscount
				END
	)AS DECIMAL) AS Discount,

	CAST(floor (H.Price-
		CASE WHEN DiscountTaxOverWorth=1 THEN TotalLineDiscount+H.TaxOverWorthCost
			 WHEN DiscountTaxOverWorth=0 THEN TotalLineDiscount
		END
	)AS DECIMAL) AS PriceAfterDiscount,
	CAST(floor (H.TollOverWorthCost)AS DECIMAL) AS Toll,
	CAST(floor (H.TaxOverWorthCost +H.TollOverWorthCost)AS DECIMAL) AS Tax,
	CASE
	WHEN TPInp<>7 THEN CAST(floor(H.Price-
		CASE WHEN DiscountTaxOverWorth=1 THEN TotalLineDiscount+H.TaxOverWorthCost
			 WHEN DiscountTaxOverWorth=0 THEN TotalLineDiscount
		END
		+(H.TaxOverWorthCost+H.TollOverWorthCost)) AS decimal)
	WHEN TPInp=7 THEN  CAST(floor(H.Price+H.TaxOverWorthCost+H.TollOverWorthCost)AS DECIMAL)
	END BillTotal,
	-------------------------------------------------کد یا شناسه ملی-----------------------------------------------------------------------------------
	CASE 
		WHEN ISNULL(Acnt.PersonType,0)=2 OR Acnt.PersonType=3 THEN
			CASE 
				WHEN  ISNULL(LTRIM(RTRIM(Acnt.NationalIdentity)),'')='' THEN Acnt.EconomicalCode
				WHEN  ISNULL(LTRIM(RTRIM(Acnt.NationalIdentity)),'')<>'' THEN ISNULL(LTRIM(RTRIM(Acnt.NationalIdentity)),'')
			END
		WHEN ISNULL(Acnt.PersonType,0)=0 OR Acnt.PersonType IS NULL or Acnt.PersonType=5 THEN ''
		WHEN ISNULL(Acnt.PersonType,0)=1 OR ISNULL(Acnt.PersonType,0)=4 
			THEN CASE
				WHEN LTRIM(RTRIM(Acnt.EconomicalCode))<>'' THEN ISNULL(Acnt.EconomicalCode,'')
				WHEN LTRIM(RTRIM(Acnt.EconomicalCode))='' THEN ISNULL(Acnt.NationalIDNumber,'')
			END
	END NationalIdOfBuyer,H.RecID,

	--------------------------------------------------فیلد های دیگر------------------------------------------------------------------------------------
	CAST(H.DocStep AS INT )AS DocStep,CAST(TaxSerialNo AS nvarchar(50)) AS TaxSerialNo,TPCanceled,
	CAST(pub.funDecimalPlace (NetWeightHdr,3)AS DECIMAL(28,3)) AS NetWeightHdr,
	CAST(pub.funDecimalPlace(CurrencyRate,4)AS DECIMAL(28,4)) AS CurrencyRate,H.PayType,
	CAST(floor(TPPriceBeforDiscount)AS DECIMAL) AS TPPriceBeforDiscount,
	
	CAST(floor(TPPriceAfterDiscount-
		CASE WHEN DiscountTaxOverWorth=1 THEN H.TaxOverWorthCost
			 WHEN DiscountTaxOverWorth=0 THEN 0
		END
	)AS DECIMAL) AS TPPriceAfterDiscount,
	ISNULL(TPEdited,0)as TPEdit,ISNULL(Acnt.EconomicalCode,'') AS EconomicalCode,ISNULL(Acnt.NationalIdentity,'') AS NationalIdentity,
	ISNULL(Acnt.NationalIDNumber,'') AS NationalIDNumber,
	
	ISNULL(aBranch.AccExtraField2,'') AS TaxBranchId,
	ISNULL(Acnt.ZipCode,'') AS ZipCode,ISNULL(Acnt.PersonType,'') AS PersonType ,ISNULL(AcntDtl.AcntName ,'') AS AcntName,
	CASE
	WHEN TPCanceled=1 THEN Dispatch.TPCanceledDate
	WHEN TPCanceled=0 THEN 
		CASE WHEN TPEdited=1 and TPEditedDate<>'' THEN TPEditedDate
			 WHEN TPEdited=1 and TPEditedDate='' THEN VchDate
			 WHEN TPEdited=0 THEN VchDate
		END
	END DocDate ,CAST (H.SerialNo AS nvarchar(200) ) AS SerialNo,CAST (ISNULL(Acnt.PersonType,0) AS INT) AS Tob,ISNULL (Acnt.AcntCode,'') AS AcntCode,	TPContractNo, TPInp,ISNULL(BaseTaxID,'') AS BaseTaxID,
	KotagNo,KotagDate,AssessmentLocation,CurrencyTypeID,'' AS Scln,CAST (H.FiscalYear AS INT) AS FiscalYear,
	CAST(H.ProcessID AS	int) AS ProcessID,	CAST(H.ProcessNo AS NVARCHAR(200)) AS ProcessNo,
	SendTaxTollState AS StateTax,H.BaseSerialNo,CAST (BaseProcessID AS INT) AS BaseProcessID,CAST (BaseProcessNo AS INT) AS BaseProcessNo,CAST (BaseFiscalYear AS INT ) AS BaseFiscalYear,DocTime,
	TaxID,ReferenceID,ISNULL(Acnt.AccExtraField2 ,'') AS Bbc,
	ISNULL(SourceLocation.TPCountryLocID,'') AS SourceCountry,     ISNULL(SourceLocation.TPCityLocID,'') AS SourceCity,
	ISNULL(DestinationLocation.TPCountryLocID,'') AS DestinationCountry,ISNULL(DestinationLocation.TPCityLocID,'') AS DestinationCity,
	ISNULL(DRIVER.NationalNumber,'') AS DriverNational,

	CASE
		WHEN ISNULL(RECEIVER.EconomicalCode,'')<>''    THEN RECEIVER.EconomicalCode
		WHEN ISNULL(RECEIVER.NationalIdentity,'')<>''  THEN RECEIVER.NationalIdentity
		WHEN ISNULL(RECEIVER.NationalIDNumber,'')<>''  THEN RECEIVER.NationalIDNumber
		WHEN ISNULL(RECEIVER.NationalIDNumber,'')='' AND
		 ISNULL(RECEIVER.NationalIdentity,'')='' AND ISNULL(RECEIVER.EconomicalCode,'')='' THEN ''
	END AS Receiver,
	CAST(ISNULL(TransportSealType,0) AS tinyint) AS TransportSealType ,ISNULL(WaybillNo,'') AS WaybillNo, ISNULL(Vehicles.VehicleIDNumber,'') AS VinCode,

	CAST(pub.funDecimalPlace (Quantity,3)AS DECIMAL(28,3)) AS Quantity,
	CASE
		WHEN ISNULL(SENDER.EconomicalCode,'')<>''    THEN SENDER.EconomicalCode
		WHEN ISNULL(SENDER.NationalIdentity,'')<>''  THEN SENDER.NationalIdentity
		WHEN ISNULL(SENDER.NationalIDNumber,'')<>''  THEN SENDER.NationalIDNumber
		WHEN ISNULL(SENDER.NationalIDNumber,'')='' AND
		     ISNULL(SENDER.NationalIdentity,'')='' AND ISNULL(SENDER.EconomicalCode,'')='' THEN ''
	END AS Sender ,Dispatch.DriverID,SenderAcntCode,ReciverAcntCode,
	LTRIM(RTRIM(inv.FunGetGoodsCID( substring(Dispatch.GoodsID,@From,@To)))) as GoodsCId,
	pub.funGetGoodsName( substring(Dispatch.GoodsID,@From,@To),1) as GoodsName
	
	FROM  inv.tblStorageDocsHdr H
		

	LEFT JOIN [trn].[tblDispatchHdr] Dispatch ON H.BaseSerialNo=Dispatch.SerialNo AND H.BaseProcessID=Dispatch.ProcessID
	AND H.BaseProcessNo=Dispatch.ProcessNo AND H.BaseFiscalYear=Dispatch.FiscalYear

	LEFT JOIN pub.tblLocations SourceLocation ON SourceLocation.LocationID=Dispatch.SourceLocationID  

	LEFT JOIN pub.tblLocations DestinationLocation ON DestinationLocation.LocationID=Dispatch.DestinationLocationID  

	LEFT JOIN trn.tblVehicles Vehicles on Vehicles.VehicleID=Dispatch.VehicleID

	LEFT JOIN pub.tblDrivers DRIVER
	ON DRIVER.DriverID=Dispatch.DriverID 

	LEFT JOIN acc.tblAcnt SENDER
	ON SENDER.AcntCode=Dispatch.SenderAcntCode AND 
	SENDER.PartNumber= @PartNumber

	LEFT JOIN acc.tblAcnt RECEIVER
	ON RECEIVER.AcntCode=Dispatch.ReciverAcntCode AND 
	RECEIVER.PartNumber= @PartNumber

	LEFT JOIN acc.tblAcnt Acnt

	ON acc.FunGetAcntCodeForRemain(H.AcntCode)=Acnt.AcntCode AND 
	 Acnt.PartNumber=   case when len(H.AcntCode)>=acc.funGetAcntLayerStartandLen(@PartNumber,1) then @PartNumber else @PartNumber-1	end 

	LEFT JOIN acc.tblAcntDtl AcntDtl
	ON AcntDtl.AcntCode=Acnt.AcntCode AND  AcntDtl.PartNumber=   case when len(H.AcntCode)>=acc.funGetAcntLayerStartandLen(@PartNumber,1) then @PartNumber else @PartNumber-1	end 

	LEFT JOIN acc.tblAcnt aBranch on 
	aBranch.AcntCode= substring(H.AcntCode,CAST(@StartTo AS int)+2,CAST(@BranchPartLen AS int)+1)
	and aBranch.PartNumber=@BranchPart

	WHERE (SendTaxTollState<>3 ) AND (H.ProcessID=@ProcessId) and H.SerialNo=@SerialNo
	and H.FiscalYear=@FiscalYear and H.ProcessNo=@ProcessNo


END TRY
BEGIN CATCH

	Set @StrErrorMessage = ERROR_MESSAGE() 
	raiserror (@StrErrorMessage, 16, 1)

END CATCH

END	
GO
