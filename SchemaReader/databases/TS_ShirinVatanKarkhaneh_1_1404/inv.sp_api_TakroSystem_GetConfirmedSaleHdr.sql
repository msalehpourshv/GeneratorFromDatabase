USE TS_ShirinVatanKarkhaneh_1_1404
GO
SET ANSI_NULLS, QUOTED_IDENTIFIER ON
GO

-- =========== TS-QC:NOTOK ========================
-- Author        : Alian Pour
-- Create date   : 1400/08/28
-- Viewed By	 : 
-- Last ModIFied : 
-- Description   : 
-- =============================================
Create PROCEDURE [inv].[sp_api_TakroSystem_GetConfirmedSaleHdr]

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
	DECLARE @SalPos bit
	DECLARE @BranchPart as varchar(50) 
	DECLARE @BranchPartLen as varchar(50)
	DECLARE @StartTo as varchar(50)='0'
BEGIN TRY
	-----------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
	IF (SELECT COUNT(*) FROM pub.tblSettings WHERE SettingKey = 'TaxBranchID' )>0
		SELECT @TaxBranchId= SettingValue 
		FROM pub.tblSettings
		WHERE SettingKey ='TaxBranchID'
	
	SELECT @PartNumber=SettingValue FROM pub.tblSettings
	WHERE SettingKey = 'AcntPartNumberForRemainCalculation'
	
		--------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
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
	---------------------------------------------------------------------------------
		SELECT @SalPos=isnull(RTRIM(lTRIM(SettingValue)),0) FROM pub.tblSettings
		WHERE SettingKey =  'Sal_SaleProcessForTaxTollSenderPos'

	SELECT 
	-------------------------------------------------مبلغ نقدی--------------------------------------------------------------------------------
	CASE
		WHEN @SalPos=1 AND ProcessNo=1 THEN  (CAST(floor (Price-
		CASE WHEN DiscountTaxOverWorth=1 THEN TotalLineDiscount+TaxOverWorthCost
			 WHEN DiscountTaxOverWorth=0 THEN TotalLineDiscount
		END
		)as decimal))
		WHEN PayType=2 THEN (CAST(floor(PayTypeCashAmount) as decimal))
		WHEN PayType=1 THEN (CAST(floor (Price-
		CASE WHEN DiscountTaxOverWorth=1 THEN TotalLineDiscount+TaxOverWorthCost
			 WHEN DiscountTaxOverWorth=0 THEN TotalLineDiscount
		END
		)as decimal))
		WHEN PayType=0 THEN (CAST(0 AS DECIMAL))
	END Cap,
	-------------------------------------------------مبلغ نسیه--------------------------------------------------------------------------------
	CASE
		--WHEN PayType=3 THEN CAST((CAST (FLOOR(H.Price) AS DECIMAL))-PayTypeCashAmount AS DECIMAL)--+CAST(FLOOR(TaxOverWorthCost +TollOverWorthCost) AS DECIMAL)
		WHEN @SalPos=1 AND ProcessNo=1 THEN (CAST(0 AS DECIMAL))
		WHEN PayType=2 THEN CAST(floor((Price-
		CASE WHEN DiscountTaxOverWorth=1 THEN TotalLineDiscount+TaxOverWorthCost
			 WHEN DiscountTaxOverWorth=0 THEN TotalLineDiscount
		END
		) -PayTypeCashAmount) as decimal)
		WHEN PayType=1 THEN (CAST(0 AS DECIMAL))
		WHEN PayType=0 THEN (CAST(0 AS DECIMAL))
	END Insp,
	-------------------------------------------------مالیات مبلغ برای نقد و نسیه----------------------------------------------------------------
	CASE
		WHEN PayType=3 THEN CAST(floor ((PayTypeCashAmount/ ( H.Price  + (TaxOverWorthCost +TollOverWorthCost ))*(TaxOverWorthCost +TollOverWorthCost )))as decimal)
		WHEN PayType=1 THEN CAST(floor((TaxOverWorthCost +TollOverWorthCost) ) as decimal)
		WHEN PayType=0 or PayType=2 THEN  (CAST(0 AS DECIMAL))
	END Tvop,
	H.Price,
	------------------------------------------------- محاسبه مبالغ---------------------------------------------------------------------------------
	CAST(floor (H.Price) AS DECIMAL) AS PriceBeforDiscount,

	CAST(
		case 
			when Discount<>0  or Discount2<>0 or Discount3<>0 or DiscountTaxOverWorth<>0  or
			     AfterSaleDiscount<>0 or AfterSaleDiscount<>0  then 1 else 0
		end
	AS decimal) AS Discount2,

		CAST(
		case 
			when TransferAmountFor<>0     or A.TransferCostIsForce<>0	or  TransportationIncome<>0 or VisitorCost<>0  or
				 TransportationCost<>0	  or PackingCost<>0 or  TransportationCost<>0 or 
				 [OtherCost]<>0 or[OtherIncome]<>0or[TaxCost]<>0 or[FixCost]<>0 or
				 A.TransferCostIsForce<>0 or TransferAmountFor<>0 then 1 else 0
		end
	AS decimal) AS OtherPrice,


	CAST(floor (CASE 
				WHEN DiscountTaxOverWorth=1 THEN TotalLineDiscount+TaxOverWorthCost
				WHEN DiscountTaxOverWorth=0 THEN TotalLineDiscount
				END
	)AS DECIMAL) AS Discount,

	CAST(floor (Price-
		CASE WHEN DiscountTaxOverWorth=1 THEN TotalLineDiscount+TaxOverWorthCost
			 WHEN DiscountTaxOverWorth=0 THEN TotalLineDiscount
		END
	)AS DECIMAL) as PriceAfterDiscount,
	CAST(floor (TollOverWorthCost)AS DECIMAL) AS Toll,
	CAST(floor (TaxOverWorthCost +TollOverWorthCost)AS DECIMAL) AS Tax,
	CASE
	WHEN TPInp<>7 THEN CAST(floor(Price-
		CASE WHEN DiscountTaxOverWorth=1 THEN TotalLineDiscount+TaxOverWorthCost
			 WHEN DiscountTaxOverWorth=0 THEN TotalLineDiscount
		END
		+(TaxOverWorthCost+TollOverWorthCost)) AS decimal)
	WHEN TPInp=7 THEN  CAST(floor(Price+TaxOverWorthCost+TollOverWorthCost)AS DECIMAL)
	END BillTotal,
	-------------------------------------------------کد یا شناسه ملی-----------------------------------------------------------------------------------
	CASE 
		WHEN ISNULL(A.PersonType,0)=2 OR A.PersonType=3 THEN
			CASE 
				WHEN  ISNULL(LTRIM(RTRIM(A.NationalIdentity)),'')='' THEN A.EconomicalCode
				WHEN  ISNULL(LTRIM(RTRIM(A.NationalIdentity)),'')<>'' THEN ISNULL(LTRIM(RTRIM(A.NationalIdentity)),'')
			END
		WHEN ISNULL(A.PersonType,0)=0 OR A.PersonType IS NULL or A.PersonType=5 THEN ''
		WHEN ISNULL(A.PersonType,0)=1 OR ISNULL(A.PersonType,0)=4 
			THEN CASE
				WHEN LTRIM(RTRIM(A.EconomicalCode))<>'' THEN ISNULL(A.EconomicalCode,'')
				WHEN LTRIM(RTRIM(A.EconomicalCode))='' THEN ISNULL(A.NationalIDNumber,'')
			END
	END NationalIdOfBuyer,

	--------------------------------------------------فیلد های دیگر------------------------------------------------------------------------------------
	H.RecID,
	CAST(DocStep AS INT )AS DocStep,CAST(TaxSerialNo as nvarchar(50)) as TaxSerialNo ,TPCanceled,CAST(pub.funDecimalPlace (NetWeightHdr,3)AS DECIMAL(28,3)) AS NetWeightHdr,CAST(pub.funDecimalPlace(CurrencyRate,4)AS DECIMAL(28,4)) AS CurrencyRate,
	
	CASE 
	WHEN @SalPos=1 AND ProcessNo=1 THEN 1 
	ELSE PayType 
	END PayType,
	
	CASE 
	WHEN @SalPos=1 AND ProcessNo=1 THEN 1 
	ELSE TPInp 
	END TPInp,

	CAST(floor(TPPriceBeforDiscount)AS DECIMAL) as TPPriceBeforDiscount,
	
	CAST(floor(TPPriceAfterDiscount-
		CASE WHEN DiscountTaxOverWorth=1 THEN TaxOverWorthCost
			 WHEN DiscountTaxOverWorth=0 THEN 0
		END
	)AS DECIMAL) as TPPriceAfterDiscount,
	ISNULL(TPEdited,0)as TPEdit,ISNULL(A.EconomicalCode,'') AS EconomicalCode,ISNULL(A.NationalIdentity,'') AS NationalIdentity,
	ISNULL(A.NationalIDNumber,'') AS NationalIDNumber,
	
	ISNULL(aBranch.AccExtraField2,'') AS TaxBranchId,
	ISNULL(A.ZipCode,'') AS ZipCode,ISNULL(A.PersonType,'') AS PersonType ,ISNULL(A2.AcntName ,'') as AcntName,
	CASE
	WHEN TPCanceled=1 THEN TPCanceledDate
	WHEN TPCanceled=0 THEN 
		CASE WHEN TPEdited=1 and TPEditedDate<>'' THEN TPEditedDate
			 WHEN TPEdited=1 and TPEditedDate='' THEN VchDate
			 WHEN TPEdited=0 THEN VchDate
		END
	END DocDate ,CAST (SerialNo AS nvarchar(200) ) AS SerialNo,CAST (ISNULL(A.PersonType,0) AS INT) As Tob,ISNULL (A.AcntCode,'') AS AcntCode,	TPContractNo, ISNULL(BaseTaxID,'') AS BaseTaxID,
	KotagNo,KotagDate,AssessmentLocation,CurrencyTypeID,'' as Scln,CAST (FiscalYear AS INT) AS FiscalYear,CAST(ProcessID AS	int) AS ProcessID,	CAST(ProcessNo AS NVARCHAR(200)) AS ProcessNo,
	SendTaxTollState AS StateTax,BaseSerialNo,CAST (BaseProcessID AS INT) AS BaseProcessID,CAST (BaseProcessNo AS INT) AS BaseProcessNo,CAST (BaseFiscalYear AS INT ) AS BaseFiscalYear,DocTime,
	TaxID,ReferenceID,ISNULL(A.AccExtraField2 ,'') as Bbc,'' as DestinationCity,'' as DestinationCountry,'' as SourceCountry,'' as SourceCity,
	'' AS  DriverNational,'' AS RECEIVER,cast(0 as tinyint) AS TransportSealType,'' AS  WaybillNo,
	CAST(pub.funDecimalPlace (0,3)AS DECIMAL(28,3)) AS Quantity,'' AS VinCode,'' AS Sender ,'' as GoodsCID,'' as GoodsName

	FROM  inv.tblStorageDocsHdr H
	LEFT JOIN acc.tblAcnt A
	ON acc.FunGetAcntCodeForRemain(H.AcntCode)=A.AcntCode AND 
	 A.PartNumber=   case when len(H.AcntCode)>=acc.funGetAcntLayerStartandLen(@PartNumber,1) then @PartNumber else @PartNumber-1	end 

	LEFT JOIN acc.tblAcntDtl A2
	ON A2.AcntCode=A.AcntCode AND  A2.PartNumber=   case when len(H.AcntCode)>=acc.funGetAcntLayerStartandLen(@PartNumber,1) then @PartNumber else @PartNumber-1	end 

	LEFT JOIN acc.tblAcnt aBranch on 
	aBranch.AcntCode= substring(H.AcntCode,cast(@StartTo as int)+2,cast(@BranchPartLen as int)+1)
	and aBranch.PartNumber=@BranchPart

	WHERE (SendTaxTollState<>3 ) AND (ProcessID=90 or ProcessID=100) and SendTaxToll=1  
	order by DocDate,ProcessID,SerialNo

END TRY
BEGIN CATCH

	Set @StrErrorMessage = ERROR_MESSAGE() 
	raiserror (@StrErrorMessage, 16, 1)

END CATCH

END	
GO
