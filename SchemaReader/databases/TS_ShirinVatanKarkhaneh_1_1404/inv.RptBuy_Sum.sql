USE TS_ShirinVatanKarkhaneh_1_1404
GO
SET ANSI_NULLS, QUOTED_IDENTIFIER ON
GO
-- =========== TS-QC:UPDATED ====================
-- Author		 : TakroSystem\Zia
-- Create date   : 1387/01/06
-- Viewed By	 : 
-- Last Modified : 1393/09/05
-- Last Modifier : TakroSystem\Hamid
-- Description	 : �ѐ �����
-- ==============================================
Create  PROCEDURE [inv].[RptBuy_Sum]
	@ProcessID		Int = 110,
	@ProcessNo		Int = 1,
	@FiscalYear		Int = 96,
	@SerialNo		Int = 2381,
	@FiscalYearTo	Int = 96,
	@SerialNoTo		Int = 2381
WITH ENCRYPTION
AS

DECLARE @LanguageID			TinyInt;
DECLARE @IsDistribute		bit;
DECLARE @IsSettle			bit;
DECLARE @IsMultiLng			bit;
DECLARE @Inv_SecondPrice	bit;

DECLARE @StrSelect		NVarChar(Max);
DECLARE @StrSelect2		NVarChar(Max);
DECLARE @StrSelect3		NVarChar(Max);
DECLARE @StrSelect4		NVarChar(Max);
DECLARE @StrWhere		NVarChar(Max);
DECLARE @StrWhere2		NVarChar(Max);
DECLARE @StrDebitRemain	NVarChar(Max);

DECLARE @StrUserPrice		NVarChar(1000);
DECLARE @StrUserPriceGrp	NVarChar(1000);

DECLARE @StrGoodsPrice		NVarChar(1000);
DECLARE @StrGoodsPriceGrp	NVarChar(1000);

DECLARE @Eqal				NVarChar(2000);

-- ======
DECLARE @goods_id						Varchar(20);
DECLARE @serial_no						int;
DECLARE @docrowno						int;
DECLARE @goods_quantity					DECIMAL(28,9);

-- ======
DECLARE @unit_name						nvarchar(200);
DECLARE @unit_id						varchar(20);
DECLARE @unit_value						float;
DECLARE @unit_value_Temp				float;
DECLARE @Mainunit_value					float;
DECLARE @Cnt							INT;

-- ======
DECLARE @unit_nameGoods1				nvarchar(200);
DECLARE @unit_idGoods1					varchar(20);
DECLARE @unit_valueGoods1				float;
DECLARE @Mainunit_valueGoods1			float;

DECLARE @unit_nameGoods2				nvarchar(200);
DECLARE @unit_idGoods2					varchar(20);
DECLARE @unit_valueGoods2				float;
DECLARE @Mainunit_valueGoods2			float;

DECLARE @Remain1	Bit;
DECLARE @Remain2	Bit;
DECLARE @Remain3	Bit;
DECLARE @Remain4	Bit;
DECLARE @Part1Start	Int;
DECLARE @Part2Start	Int;
DECLARE @Part3Start	Int;
DECLARE @Part4Start	Int;
DECLARE @Part1Len	Int;
DECLARE @Part2Len	Int;
DECLARE @Part3Len	Int;
DECLARE @Part4Len	Int;
DECLARE @Part1End	TinyInt;

--=======================================
--DECLARE	@HasSerial			Bit;
--DECLARE	@FromExpireDate		Varchar(10);
--DECLARE	@ToExpireDate		Varchar(10);
--DECLARE	@Batch				NVarChar(20);

DECLARE @db_0000		NVarchar(50)
SET @db_0000 = Substring(db_name(), 1, Len(db_name()) - 4) + '0000'

Begin --============== S T A R T  C O D E =======================================

	SET NOCOUNT ON;

	Declare @sal_AggregateSimilarGoodsInRpt		 Bit;
	Declare @sal_AggregateSimilarGoodsUPI		 Bit;
	Declare @sal_AggregateSimilarGoodsByPrice	 Bit;
	DECLARE @QuantityDecimalsToForms			 Int;
	Declare @sal_ShowSubUnitInRpt			     Bit;
	Declare @sal_ShowMainAndSubUnitInRpt		 Bit;
	Declare @TTMSPayTypeShowForAll				 Bit;
	Declare @sal_HasDst							 Bit;
	DECLARE @SalShowRemainInPreSaleDoc			 Bit;
	Declare @CustomerPartNo						 Tinyint
	Declare @PrintSerials						 Bit;	

	SET @sal_AggregateSimilarGoodsUPI			= 0
	SET @sal_AggregateSimilarGoodsInRpt			= 0
	SET @sal_AggregateSimilarGoodsByPrice		= 0
	SET	@QuantityDecimalsToForms				= 3
	SET @sal_ShowSubUnitInRpt					= 0
	SET @sal_ShowMainAndSubUnitInRpt			= 0
	SET @TTMSPayTypeShowForAll					= 0
	SET @sal_HasDst								= 0
	SET @SalShowRemainInPreSaleDoc				= 0
	SET @CustomerPartNo							= 0
	SET @PrintSerials							= 0
	
	SELECT @sal_AggregateSimilarGoodsInRpt = SettingValue	FROM pub.tblSettings	WHERE SettingKey = 'sal_AggregateSimilarGoodsInRpt'
	SELECT @sal_AggregateSimilarGoodsUPI = SettingValue		FROM pub.tblSettings	WHERE SettingKey = 'sal_AggregateSimilarGoodsUPI'
	SELECT @sal_AggregateSimilarGoodsByPrice = SettingValue	FROM pub.tblSettings	WHERE SettingKey = 'sal_AggregateSimilarGoodsByPrice'
	SELECT @QuantityDecimalsToForms=SettingValue			FROM pub.tblSettings	WHERE SettingKey = 'QuantityDecimalsToForms'
	SELECT @sal_ShowSubUnitInRpt = SettingValue				FROM pub.tblSettings	WHERE SettingKey = 'sal_ShowSubUnitInRpt'
	SELECT @sal_ShowMainAndSubUnitInRpt = SettingValue		FROM pub.tblSettings	WHERE SettingKey = 'sal_ShowMainAndSubUnitInRpt'
	SELECT @TTMSPayTypeShowForAll = SettingValue			FROM pub.tblSettings	WHERE SettingKey = 'TTMSPayTypeShowForAll'
	SELECT @sal_HasDst = SettingValue 						FROM pub.tblSettings	WHERE SettingKey = 'sal_HasDst'
	SELECT @SalShowRemainInPreSaleDoc = SettingValue		FROM pub.tblSettings	WHERE SettingKey = 'SalShowRemainInPreSaleDoc'
	SELECT @CustomerPartNo = SettingValue					FROM pub.tblSettings	WHERE SettingKey = 'AcntPartNumberForRemainCalculation'

	Declare @ExtraParams		NVarChar(Max)
	SELECT    @ExtraParams= Params FROM         rpt.tblRptParams where SessionNo=@FiscalYearTo

	SET @sal_HasDst							   = LTrim(pub.funSplitString(@ExtraParams, '@', 1));  
	SET @sal_AggregateSimilarGoodsInRpt		   = LTrim(pub.funSplitString(@ExtraParams, '@', 2));  
	SET @sal_AggregateSimilarGoodsUPI		   = LTrim(pub.funSplitString(@ExtraParams, '@', 3));  
	SET @sal_ShowSubUnitInRpt				   = LTrim(pub.funSplitString(@ExtraParams, '@', 4));  
	SET @sal_ShowMainAndSubUnitInRpt		   = LTrim(pub.funSplitString(@ExtraParams, '@', 5));  
	SET @sal_AggregateSimilarGoodsByPrice	   = LTrim(pub.funSplitString(@ExtraParams, '@', 6));  
	SET @SalShowRemainInPreSaleDoc			   = LTrim(pub.funSplitString(@ExtraParams, '@', 7));  
	SET @FiscalYearTo						   = LTrim(pub.funSplitString(@ExtraParams, '@', 8));  
	SET @PrintSerials						   = LTrim(pub.funSplitString(@ExtraParams, '@', 9));  
	set @LanguageID=1

	SET @StrWhere = 'AH.ProcessID = ' + LTrim(RTrim(Str(@ProcessID))) + ' AND AH.ProcessNo = ' + LTrim(RTrim(Str(@ProcessNo)))
	-- Where ----------------------------------------
	IF (@FiscalYear Is Not Null)
		SET @StrWhere = @StrWhere + ' AND ((AH.FiscalYear >' + LTrim(Str(@FiscalYear)) + ') OR (AH.FiscalYear = ' + LTrim(Str(@FiscalYear)) + ' AND AH.SerialNo >= ' + LTrim(Str(@SerialNo)) + ')) '
	IF (@FiscalYearTo Is Not Null)
		SET @StrWhere = @StrWhere + ' AND ((AH.FiscalYear < ' + LTrim(Str(@FiscalYearTo)) + ') OR (AH.FiscalYear = ' + LTrim(Str(@FiscalYearTo)) + ' AND AH.SerialNo <= ' + LTrim(Str(@SerialNoTo)) + ')) '		
	
	
	SET @StrSelect = '			
			SELECT AD.ProcessID ,AD.ProcessNo,AD.FiscalYear,AD.SerialNo, AH.DocDate,D.GoodsID,D.StoreID,SubUnitID,SubUnitPrice
			,H.AcntCode,H.DocDate2 ,H.AgreeNo AgreeNoHdr,H.CurrencyTypeID,H.CurrencyRate
			,	Sum(SubUnitQuantity) SubUnitQuantity,Sum(D.GoodsQuantity) GoodsQuantity
			,S.StoreName,pub.GetCodeName(H.AcntCode,'+ str(@LanguageID) +' ) AS AcntName
			, [pub].[funGetGoodsName](D.GoodsID,' + str(@LanguageID) + ') GoodsName
			, sum(DiscountDtl) DiscountDtl
			
			, sum(TotalLineDiscount) TotalLineDiscount
			, sum(TollOverWorthCost) TollOverWorthCost
			, sum(TaxOverWorthCost) TaxOverWorthCost
			, sum(TransportationCost) TransportationCost
			, sum(TransportationIncome) TransportationIncome
			,Sum(TaxOverWorthCostDtl) TaxOverWorthCostDtl
			,Sum(TollOverWorthCostDtl) TaxOverWorthCostDtl
			,Sum(OtherCost) OtherCost
			,Sum(TransportationCost) TransportationCost
			,Sum(TransportPrice) TransportPrice
			,sum(H.Discount + H.Discount2+ H.Discount3) AS Discount
			, Sum(CurrencyAmount) CurrencyAmount
			,ISNULL(D.GoodsPrice,0) GoodsPrice
			,AD.BaseProcessID ,AD.BaseProcessNo ,AD.BaseFiscalYear ,AD.BaseSerialNo
 FROM  inv.tblAfterBuyVoucherDtl AD
 inner join inv.tblAfterBuyVoucherHdr AH On AH.ProcessID=AD.ProcessID and AD.ProcessNo=AH.ProcessNo and AD.FiscalYear=AH.FiscalYear and AD.SerialNo=AH.SerialNo
 inner join       inv.tblStorageDocsHdr H    On H.ProcessID=AD.BaseProcessID and H.ProcessNo=AD.BaseProcessNo and H.FiscalYear=AD.BaseFiscalYear and H.SerialNo=AD.BaseSerialNo 
 inner join        inv.tblStorageDocsDtl D ON H.ProcessID = D.ProcessID AND H.ProcessNo = D.ProcessNo AND H.FiscalYear = D.FiscalYear AND H.SerialNo = D.SerialNo
	LEFT  JOIN inv.tblStoresDtl S ON S.StoreID = D.StoreID AND S.LanguageID = '+ str(@LanguageID) +'
			
WHERE ' + @StrWhere + '
Group by AH.DocDate,AD.ProcessID ,AD.ProcessNo,AD.FiscalYear,AD.SerialNo,D.GoodsID,D.StoreID,SubUnitID,SubUnitPrice
,H.AcntCode,H.DocDate2 ,H.AgreeNo,H.CurrencyTypeID,H.CurrencyRate,S.StoreName,D.GoodsPrice
 ,AD.BaseProcessID ,AD.BaseProcessNo ,AD.BaseFiscalYear ,AD.BaseSerialNo
 ORDER BY AD.ProcessID ,AD.ProcessNo,AD.FiscalYear,AD.SerialNo
 ,AD.BaseProcessID ,AD.BaseProcessNo ,AD.BaseFiscalYear ,AD.BaseSerialNo,D.GoodsID,D.StoreID,SubUnitID,SubUnitPrice
  '
			
Print @StrSelect
EXEC sp_executesql @StrSelect;


		
		
END
GO
