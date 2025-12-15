USE TS_ShirinVatanKarkhaneh_1_1404
GO
SET ANSI_NULLS, QUOTED_IDENTIFIER ON
GO
-- =========== TS-QC:UPDATED ====================
-- Author		 : TakroSystem
-- Create date   : 1390/09/01
-- Viewed By	 : 
-- Last Modified : Hamid - 1393/09/05
-- Last Modifier : Hamid
-- Description	 : 
-- ==============================================
Create PROCEDURE sal.spFrmSaleOrderForDistDtlListSelect
	@DocDateFrom		Char(10),
	@DocDateTo			Char(10),
	@AcntCodeFrom		varchar(20),
	@AcntCodeTo			varchar(20),
	@VisitorAcntCode	varchar(20),
	@CustomerKindID		varchar(20),
	@GoodsIDFrom		varchar(20),
	@GoodsIDTo			varchar(20),
	@StoreID			varchar(20),
	@bolSortSequance	Bit='True',
	@FiscalYear			Smallint=0,
	@SerialNo			Int=0,
	@Price2				Bit='False',
	@Branch				varchar(20),
	@VisitArea			varchar(20),
	@SuperVision		varchar(20),
	@VisitRout			varchar(20),
	@ExtraParams		NVarChar(Max) 
WITH ENCRYPTION
 AS
BEGIN
SET NOCOUNT ON;
	DECLARE @LanguageID AS TinyInt
	SET @LanguageID = pub.funGetCurrentLanguageID()

	DECLARE @Price2S Nvarchar(Max)
	DECLARE @SalOrder_ConfirmDocStep Nvarchar(Max)
	DECLARE @SalOrder_ConfirmDocStep3 Nvarchar(Max)
	DECLARE @FilterStoreInOrder Bit
	DECLARE @SalOrderDocStep TINYINT
	Declare @StrSelect AS NVarChar(Max);
	Declare @StrSelect1 AS NVarChar(Max);
	Declare @StrSelect2 AS NVarChar(Max);
	Declare @StrPath AS NVarChar(Max);
	Declare @StrAcnt   AS NVarChar(Max);
	Declare @StrCustomerKind	AS NVarChar(Max);
	Declare @StrSaleTypeID		AS NVarChar(Max);
	Declare @StrVisitorAcnt  AS NVarChar(Max);
	Declare @StrFilterStore  AS NVarChar(Max);
	Declare @StrBranch		 AS NVarChar(Max);
	Declare @StrVisitArea	 AS NVarChar(Max);
	Declare @StrSuperVision  AS NVarChar(Max);
	Declare @StrVisitRout	 AS NVarChar(Max);
	Declare @StrSerialNo  AS NVarChar(Max);
	Declare @StrGoods   AS NVarChar(Max);
	Declare @StrDocDate AS NVarChar(Max);
	Declare @StrSaleOrderConfirm AS NVarChar(Max);
	Declare @CityLayerLen AS tinyint;
	Declare @AreaLayerLen AS tinyint;
	Declare @LayerLen AS TINYINT;
	Declare @StartLayerIndex AS TINYINT;
	Declare @AcntPartNumberForRemainCalculation AS TINYINT;
	DECLARE @GetRemainSaleOrder AS  Nvarchar(5);
	DECLARE @ShowVisitPathName AS  Nvarchar(5);
	DECLARE @DocDescName AS  varchar(8);
	DECLARE @TaxP AS		FLOAT;
	DECLARE @TollP AS		FLOAT;
	DECLARE @SaleTypeID		varchar(20);

	SET @SalOrder_ConfirmDocStep = 'False'
	SET @SalOrder_ConfirmDocStep3 = 'False'
	SET @FilterStoreInOrder = 'False'
	SET @GetRemainSaleOrder = 'False'
	SET @ShowVisitPathName = 'False'
	SET @StrAcnt = ''
	SET @StrVisitorAcnt = ''
	SET @StrFilterStore = ''
	SET @StrSerialNo = ''
	SET @StrCustomerKind = ''
	set @StrSaleTypeID=''
	SET @StrBranch = ''
	SET @StrVisitArea = ''
	SET @StrSuperVision = ''
	SET @StrVisitRout = ''
	SET @StrGoods = ''
	SET @StrDocDate = ''
	SET @StrSaleOrderConfirm = ''
	SET @StrPath = ''
	SET @AreaLayerLen = 0
	SET @CityLayerLen = 0
	SET @LayerLen = 0
	SET @TaxP = 0
	SET @TollP = 0
	SET @StartLayerIndex = 0
	SET @AcntPartNumberForRemainCalculation = 0
	SEt @Price2S = ''
	
	SET @SaleTypeID= LTrim(pub.funSplitString(@ExtraParams, '@', 1)); 
	SET @SaleTypeID=isnull(@SaleTypeID,'')

	 
	SELECT @TaxP=SettingValue from pub.tblSettings where SettingKey ='TaxOverWorthPercentInSale'
	
	SELECT @TollP=SettingValue from pub.tblSettings where SettingKey ='TollOverWorthPercentInSale'
	
	SELECT @ShowVisitPathName = SettingValue
	FROM pub.tblSettings
	WHERE SettingKey = 'ShowVisitPathName'
	
	SELECT @GetRemainSaleOrder = SettingValue
	FROM pub.tblSettings
	WHERE SettingKey = 'GetRemainSaleOrder'
	
	SELECT @LayerLen = SettingValue
	FROM pub.tblSettings
	WHERE SettingKey = 'LayerLen'
	
	SELECT @StartLayerIndex = SettingValue
	FROM pub.tblSettings
	WHERE SettingKey = 'StartLayerIndex'
	
	SELECT @AcntPartNumberForRemainCalculation = SettingValue
	FROM pub.tblSettings
	WHERE SettingKey = 'AcntPartNumberForRemainCalculation'

	SELECT @CityLayerLen = SettingValue
	FROM pub.tblSettings
	WHERE SettingKey = 'CityLayerLen'

	SELECT @AreaLayerLen = SettingValue
	FROM pub.tblSettings
	WHERE SettingKey = 'AreaLayerLen'

	SELECT @SalOrder_ConfirmDocStep = SettingValue
	FROM pub.tblSettings
	WHERE SettingKey = 'SalOrder_ConfirmDocStep'
	
	SELECT @SalOrder_ConfirmDocStep3 = SettingValue
	FROM pub.tblSettings
	WHERE SettingKey = 'SalOrder_ConfirmDocStep3'

	SELECT @FilterStoreInOrder = SettingValue
	FROM pub.tblSettings
	WHERE SettingKey = 'FilterStoreInOrder'

	DECLARE @ConfirmCountInSaleOrder AS  TinyInt;
	SELECT @ConfirmCountInSaleOrder = SettingValue
	FROM pub.tblSettings
	WHERE SettingKey = 'ConfirmCountInSaleOrder'
	
	-- ==================================
	IF @FilterStoreInOrder = 'True' OR @FilterStoreInOrder = '1'
		SET @StrFilterStore = ' AND StoreID = ''' + @StoreID + ''''
	
	IF @ShowVisitPathName = 'False'
		SET @StrPath = 'pub.GetCodeName(LEFT(OD.AcntCode,' + LTRIM(STR(@CityLayerLen)) + '),' + LTRIM(STR(@LanguageID)) + ') City,pub.GetCodeName(LEFT(OD.AcntCode,' + LTRIM(STR(@AreaLayerLen)) + '),' + LTRIM(STR(@LanguageID)) + ') Area'
	else
		SET @StrPath = 'acc.funVisitPathName1(OD.AcntCode,' + LTRIM(STR(@StartLayerIndex)) + ',' + LTRIM(STR(@LayerLen)) + ',' + LTRIM(STR(@AcntPartNumberForRemainCalculation)) + ',' +  LTRIM(STR(@LanguageID)) + ') Path1,
						acc.funVisitPathName2(OD.AcntCode,' + LTRIM(STR(@StartLayerIndex)) + ',' + LTRIM(STR(@LayerLen)) + ',' + LTRIM(STR(@AcntPartNumberForRemainCalculation)) + ',' +  LTRIM(STR(@LanguageID)) + ') Path2,
						acc.funVisitPathName3(OD.AcntCode,' + LTRIM(STR(@StartLayerIndex)) + ',' + LTRIM(STR(@LayerLen)) + ',' + LTRIM(STR(@AcntPartNumberForRemainCalculation)) + ',' +  LTRIM(STR(@LanguageID)) + ') Path3,
						acc.funVisitPathName4(OD.AcntCode,' + LTRIM(STR(@StartLayerIndex)) + ',' + LTRIM(STR(@LayerLen)) + ',' + LTRIM(STR(@AcntPartNumberForRemainCalculation)) + ',' +  LTRIM(STR(@LanguageID)) + ') Path4'

	IF @SalOrder_ConfirmDocStep = 'False' 
		BEGIN
			SET @SalOrderDocStep = 1
			SET @DocDescName = 'DocDesc'
		END
	ELSE
		BEGIN
			SET @SalOrderDocStep = 2
			SET @DocDescName = 'DocDesc2'
		END
		
	IF @SalOrder_ConfirmDocStep3 = 'True'
		BEGIN
			SET @SalOrderDocStep = 3
			SET @DocDescName = 'DocDesc3'
		END
		
	If (@SerialNo > 0) And (@FiscalYear > 0)
		SET @StrSerialNo = ' AND FiscalYear=' + LTrim(RTrim(@FiscalYear)) + ' AND SerialNo=' + LTrim(RTrim(@SerialNo))+ '  '
	
	If (@CustomerKindID Is Not Null) And (Len(Ltrim(@CustomerKindID)) <> 0)
		SET @StrCustomerKind = ' AND CustomerKindID=''' + LTrim(RTrim(@CustomerKindID)) + '''  '
	If (@SaleTypeID Is Not Null) And (Len(Ltrim(@SaleTypeID)) <> 0)
		SET @StrSaleTypeID=  ' AND SaleTypeID=''' + LTrim(RTrim(@SaleTypeID)) + '''  '

	If (@VisitorAcntCode Is Not Null) And (Len(Ltrim(@VisitorAcntCode)) <> 0)
		Set @StrVisitorAcnt =  ' AND SUBSTRING(VisitorAcntCode,' + LTRIM(STR(@StartLayerIndex)) + ',' + LTRIM(STR(LEN(@VisitorAcntCode))) + ')=LEFT(''' + LTrim(RTrim(@VisitorAcntCode)) + ''',' + LTRIM(STR(LEN(@VisitorAcntCode))) + ')  '

	If (@Branch Is Not Null) And (Len(Ltrim(@Branch)) <> 0)
		SET @StrBranch = ' AND VisitPathID1=''' + LTrim(RTrim(@Branch)) + '''  '
	If (@SuperVision Is Not Null) And (Len(Ltrim(@SuperVision)) <> 0)
		SET @StrSuperVision = ' AND VisitPathID2=''' + LTrim(RTrim(@SuperVision)) + '''  '
	If (@VisitArea Is Not Null) And (Len(Ltrim(@VisitArea)) <> 0)
		SET @StrVisitArea = ' AND VisitPathID3=''' + LTrim(RTrim(@VisitArea)) + '''  '
	If (@VisitRout Is Not Null) And (Len(Ltrim(@VisitRout)) <> 0)
		SET @StrVisitRout = ' AND VisitPathID4=''' + LTrim(RTrim(@VisitRout)) + '''  '
	
	If (@AcntCodeFrom Is Not Null) And (Len(Ltrim(@AcntCodeFrom)) <> 0)
		Set @StrAcnt =  ' AND SUBSTRING(AcntCode,' + LTRIM(STR(@StartLayerIndex)) + ',' + LTRIM(STR(LEN(@AcntCodeFrom))) + ')>=LEFT(''' + LTrim(RTrim(@AcntCodeFrom)) + ''',' + LTRIM(STR(LEN(@AcntCodeFrom))) + ')  '
		--Set @StrAcnt =  ' AND LEFT(AcntCode,' +LTRIM(STR(LEN(@AcntCodeFrom))) + ') >= ''' + LTrim(RTrim(@AcntCodeFrom)) + '''  '
	ELSE
		SET @AcntCodeFrom = '00000000000000000000'

	IF (@AcntCodeTo Is Not Null) AND (Len(LTrim(@AcntCodeTo)) <> 0)
		Set @StrAcnt =  @StrAcnt + ' AND SUBSTRING(AcntCode,' + LTRIM(STR(@StartLayerIndex)) + ',' + LTRIM(STR(LEN(@AcntCodeTo))) + ')<=LEFT(''' + LTrim(RTrim(@AcntCodeTo)) + ''',' + LTRIM(STR(LEN(@AcntCodeTo))) + ')  '
		--Set @StrAcnt =  @StrAcnt + ' AND LEFT(AcntCode,' +LTRIM(STR(LEN(@AcntCodeTo))) + ') <= ''' + LTrim(RTrim(@AcntCodeTo)) + '''  '
	ELSE
		SET @AcntCodeTo = '99999999999999999999'

	IF (@GoodsIDFrom Is Not Null) And (Len(Ltrim(@GoodsIDFrom)) <> 0)
		Set @StrGoods =  ' AND LEFT(OD.GoodsID,' +LTRIM(STR(LEN(@GoodsIDFrom))) + ')>=''' + LTrim(RTrim(@GoodsIDFrom)) + '''  '

	IF (@GoodsIDTo Is Not Null) AND (Len(LTrim(@GoodsIDTo)) <> 0)
		Set @StrGoods =  @StrGoods + ' AND LEFT(OD.GoodsID,' +LTRIM(STR(LEN(@GoodsIDTo))) + ')<=''' + LTrim(RTrim(@GoodsIDTo)) + '''  '

	IF (@DocDateFrom Is Not Null) And (Len(Ltrim(@DocDateFrom)) <> 0)
		Set @StrDocDate =  ' AND LEFT(DocDate,' +LTRIM(STR(LEN(@DocDateFrom))) + ')>=''' + LTrim(RTrim(@DocDateFrom)) + '''  '

	IF (@DocDateTo Is Not Null) AND (Len(LTrim(@DocDateTo)) <> 0)
		Set @StrDocDate =  @StrDocDate + ' AND LEFT(DocDate,' +LTRIM(STR(LEN(@DocDateTo))) + ')<=''' + LTrim(RTrim(@DocDateTo)) + '''  '
	
	IF @Price2 = 'False'
		SET @Price2S = 'O.SubUnitPrice'
	ELSE
		SET @Price2S = 'O.GoodsPrice' --'pub.funGetMainUnitValue(OD.GoodsID,OD.SubUnitID) * O.GoodsPrice / pub.funGetSubUnitValue(OD.GoodsID,OD.SubUnitID) '
	
	IF @ConfirmCountInSaleOrder = 1
		SET @StrSaleOrderConfirm = ' And SgnSN1 <> 0'
	IF @ConfirmCountInSaleOrder = 2
		SET @StrSaleOrderConfirm = ' And SgnSN1 <> 0 AND SgnSN2 <> 0'
	IF @ConfirmCountInSaleOrder = 3
		SET @StrSaleOrderConfirm = ' And SgnSN1 <> 0 AND SgnSN2 <> 0 AND SgnSN3 <> 0'
	IF @ConfirmCountInSaleOrder = 4
		SET @StrSaleOrderConfirm = ' And SgnSN1 <> 0 AND SgnSN2 <> 0 AND SgnSN3 <> 0 And SgnSN4 <> 0'
	IF @ConfirmCountInSaleOrder = 5
		SET @StrSaleOrderConfirm = ' And SgnSN1 <> 0 AND SgnSN2 <> 0 AND SgnSN3 <> 0 And SgnSN4 <> 0 And SgnSN5 <> 0'								

	DECLARE @strDistQuery as Nvarchar(1000)
	DECLARE @strDistQuery2 as Nvarchar(1000)
	DECLARE @strDistQuery3 as Nvarchar(1000)

	SET @strDistQuery = 'case When UsedDistribiutionPercent=''True'' then 
									[sal].[funGetDistributionPercent](OD.GoodsID,''' + @DocDateTo + ''') 
						else case When UsedDistribiutionPercentNew =''True'' then 
									[sal].[funGetDistributionPercent](OD.GoodsID,''' + @DocDateTo + ''')
						  else		0 end end  DistributionPercent ,'

	SET @strDistQuery2 = 'case When UsedDistribiutionPercent=''True'' then 
									round(  Price*100/ (100+DistributionPercent),0)
							else case When UsedDistribiutionPercentNew=''True'' then 									
								round(  Price*100/ (100+DistributionPercent),0)
								else Price end end DistributionPrice
							,case When UsedDistribiutionPercent=''True'' then 
								round( (Price*100/ (100+DistributionPercent))*100/(100+ ' + str(@TaxP+@TollP) + '),0)
							else case When UsedDistribiutionPercentNew =''True'' then 
								Price
							else round( Price*100 /(100+ ' + str(@TaxP+@TollP) + '),0) end end PurePrice,' + str(@TaxP) + ' TaxP,' + str(@TollP) + ' TollP,'
		
	SET @strDistQuery3 = ' case When UsedDistribiutionPercent=''True'' then 
								round( (DistributionPrice-PurePrice)/(TaxP+TollP)*TaxP,0) 
							else case When UsedDistribiutionPercentNew=''True'' then
								round(PurePrice*TaxP/100,0) 
							else TaxOverWorthCostDtl end end TaxOverWorthCostDtl,
							case When UsedDistribiutionPercent=''True'' then 
								round((DistributionPrice-PurePrice)/(TaxP+TollP)*TollP,0)  
							else case When UsedDistribiutionPercentNew=''True'' then
								round(PurePrice*TollP/100,0)
							else TollOverWorthCostDtl end end TollOverWorthCostDtl,'

	IF @GetRemainSaleOrder = 'True'
	BEGIN
		SET @StrSelect1 = N' SELECT ' + @strDistQuery2 + '*
								, [sal].[funGetCustomerKindName](CustomerKindID ,' + LTRIM(STR(@LanguageID)) + ' )CustomerKindName ,[pub].[funGetSaleTypesName](SaleTypeID,' + LTRIM(STR(@LanguageID)) + ') SaleTypeName
								,CASE WHEN DiscountDtlT>0 THEN DiscountDtlT ELSE sal.funGetLineDiscount(AcntCode,GoodsID,DocDate,SubUnitPriceT * SubUnitQuantity,Quantity,NULL,'''') END  DiscountDtl
							FROM (
		SELECT case when ContainTax =''False'' then ''False'' else  UsedDistribiutionPercent end UsedDistribiutionPercent , case when ContainTax =''False'' then ''False'' else  UsedDistribiutionPercentNew end UsedDistribiutionPercentNew 
		,IsNull(TransportationIncome,0)+IsNull(OtherIncome,0)+IsNull(PackingCost,0)+IsNull(TaxCost,0)+IsNull(TaxOverWorthCost,0)+IsNull(TollOverWorthCost ,0)-IsNull(TransportationCost,0)-(IsNull(CurrencyDiscount,0)*IsNull(CurrencyRate,0))
				-IsNull(OtherCost,0)-IsNull(Discount,0)-IsNull(Discount2,0)-IsNull(EarnestMoney ,0) OtherPrice,' + @strDistQuery + '
				acc.funIsCodeClosed(OD.AcntCode) IsCodeClosed,OD.ProcessID BaseOrderProcessID,OD.ProcessNo BaseOrderProcessNo,
				OD.FiscalYear BaseOrderFiscalYear,OD.SerialNo BaseOrderSerialNo,OD.RowNo,OD.DocRowNo BaseOrderDocRowNo,OD.DocDate, OH.LocationID,
				OD.AcntCode,OD.VisitorAcntCode,OD.VisitorPercent,OH.VisitorPercent VisitorPercentHdr,OD.GoodsID,OD.SubUnitID, OD.SubUnitQuantity,
				pub.funGetMainUnitValue(OD.GoodsID,OD.SubUnitID) * OD.SubUnitQuantity / pub.funGetSubUnitValue(OD.GoodsID,OD.SubUnitID) Quantity,
				O.ConfirmQuantity,OD.DescDtl,OD.BaseProcessID,OD.BaseProcessNo,OD.BaseFiscalYear,OD.BaseSerialNo,OD.BaseDocRowNo,
				inv.funGetTechnicalSpecifications(OD.GoodsID) TechnicalSpecifications, IsNull(OH.TaxOverWorthCost,0) TaxOverWorthCost, DiscountTaxOverWorth,
			    IsNull(OH.TollOverWorthCost,0) TollOverWorthCost,IsNull(OH.TransportationCost,0) TransportationCost, OH.HasNoReward,OH.HasNoDiscountDtl, OH.PayOffTypeID,sal.GetPayOffTypeName( OH.PayOffTypeID,' + LTRIM(STR(@LanguageID)) + ') PayOffTypeName,
			    IsNull(OH.TransportationIncome,0) TransportationIncome, IsNull(OH.VisitorCost,0) VisitorCost, IsNull(OH.PackingCost,0) PackingCost, 
			    IsNull(OH.TaxCost,0) TaxCost, IsNull(OH.OtherCost,0) OtherCost, IsNull(OH.OtherIncome,0) OtherIncome, OH.SaleTypeID, 
				pub.funGetGoodsName(OD.GoodsID,' + LTRIM(STR(@LanguageID)) + ') GoodsName,inv.funGetUnitName(OD.SubUnitID,' + LTRIM(STR(@LanguageID)) + ') SubUnitName,
				inv.funGetGoodsRemain(null,null,null,null,null,''' + @StoreID + ''',OD.GoodsID,'''',''' + @DocDateTo + ''',0) GoodsRemain,' + @Price2S + ' Price,
				SubUnitPrice2,SubUnitQuantity2,O.GoodsPrice,IsNull(OD.DiscountPercentDtl,0) DiscountPercentDtl,
				IsNull(OH.DiscountPercent,0) DiscountPercent,IsNull(OH.DiscountPercent2,0) DiscountPercent2, IsNull(OH.Discount,0) Discount, IsNull(OH.Discount2,0) Discount2,
				DiscountDtl DiscountDtlT,O.SubUnitPrice SubUnitPriceT,
				pub.GetCodeName(OD.AcntCode,' + LTRIM(STR(@LanguageID)) + ') AcntName,
				pub.GetCodeName(OD.VisitorAcntCode,' + LTRIM(STR(@LanguageID)) + ') VisitorAcntName,OD.TaxOverWorthCostDtl,OD.TollOverWorthCostDtl,
				' + @StrPath + ', OH.CurrencyTypeID, OH.CurrencyRate, OD.CurrencyAmount,
				GoodsWeight,Sequence,Address1,CustomerKindID,(GoodsLength*GoodsWidth*GoodsHeight) Content,OD.IsReward,OD.IsReward0,OH.' + @DocDescName + ' AS DocDesc, OH.DocDesc DocDescHdr,
				OD.UserPriceID,isnull((Select UParams from inv.tblGoodsUserPrice p where p.ID=OD.UserPriceID) ,'''') as UserPrice, 
				SgnSN1, SgnSN2, SgnSN3, SgnSN4, SgnSN5,HasNotPayOffDiscounts '

		SET @StrSelect2 = '
		FROM	
			(
			SELECT	C.ProcessID,C.ProcessNo,C.FiscalYear,C.SerialNo,C.DocRowNo,C.DocDate,
					C.ConfirmQuantity - ISNULL(SD.ConfirmQuantity,0) ConfirmQuantity,SubUnitPrice,GoodsPrice
			From
				(SELECT S.ProcessID,S.ProcessNo,S.FiscalYear,S.SerialNo,S.DocRowNo,ConfirmQuantity ConfirmQuantity,BaseProcessID,BaseProcessNo, 
					   BaseFiscalYear,BaseSerialNo,BaseDocRowNo,DocDate,AcntCode,SubUnitPrice,GoodsPrice
				FROM ( SELECT ProcessID,ProcessNo,FiscalYear,SerialNo,DocRowNo FROM  sal.tblSaleOrderDtl 
					   WHERE ProcessID=180  ' + @StrFilterStore + @StrVisitorAcnt + @StrAcnt + @StrDocDate + @StrSerialNo + ' AND DocStep = ' + LTrim(Str(@SalOrderDocStep)) + '
					   EXCEPT
					   (SELECT BaseProcessID,BaseProcessNo,BaseFiscalYear,BaseSerialNo,BaseDocRowNo FROM inv.tblStorageDocsDtl 
					    WHERE BaseProcessID=180
					    UNION 
					    SELECT BaseProcessID,BaseProcessNo,BaseFiscalYear,BaseSerialNo,BaseDocRowNo FROM sal.tblSaleOrderDtl 
					    WHERE BaseProcessID=180)) E 
					INNER JOIN sal.tblSaleOrderDtl S
					ON E.ProcessID=S.ProcessID AND E.ProcessNo=S.ProcessNo AND E.FiscalYear=S.FiscalYear AND E.SerialNo=S.SerialNo AND E.DocRowNo=S.DocRowNo
				WHERE S.ProcessID=180 ' + @StrFilterStore + @StrVisitorAcnt + @StrAcnt + @StrDocDate + ' AND DocStep=' + LTrim(Str(@SalOrderDocStep)) + '
				) C 
			LEFT JOIN 
				(SELECT DISTINCT BaseProcessID,BaseProcessNo,BaseFiscalYear,BaseSerialNo,BaseDocRowNo,ConfirmQuantity
				 FROM sal.FunGetBaseSaleGoodsForDist(''' + @AcntCodeFrom + ''',''' + @AcntCodeTo + ''',''' + @DocDateTo + ''')		
				) SD
				ON C.ProcessID=SD.BaseProcessID AND C.ProcessNo=SD.BaseProcessNo AND 
				C.FiscalYear=SD.BaseFiscalYear AND C.SerialNo=SD.BaseSerialNo AND 
				C.DocRowNo=SD.BaseDocRowNo 
			) O
		INNER JOIN sal.tblSaleOrderDtl OD
		ON	OD.ProcessID=O.ProcessID AND OD.ProcessNo=O.ProcessNo AND OD.FiscalYear=O.FiscalYear AND OD.SerialNo=O.SerialNo AND OD.DocRowNo=O.DocRowNo
		INNER JOIN sal.tblSaleOrderHdr OH
		ON	OD.ProcessID=OH.ProcessID AND OD.ProcessNo=OH.ProcessNo AND OD.FiscalYear=OH.FiscalYear AND OD.SerialNo=OH.SerialNo		
		INNER JOIN
		(SELECT GoodsID,GoodsWeight,GoodsLength,GoodsWidth,GoodsHeight,ContainTax FROM inv.tblGoods WHERE CodeClosed=''False'') G
		ON OD.GoodsID = G.GoodsID
		INNER JOIN (SELECT a.AcntCode,Sequence,Address1,CustomerKindID FROM acc.tblAcnt a INNER JOIN acc.tblAcntDtl b on a.AcntCode=b.AcntCode and a.PartNumber=b.PartNumber WHERE a.PartNumber=' + 
		LTRIM(STR(@AcntPartNumberForRemainCalculation)) + @StrCustomerKind + @StrBranch + @StrVisitArea + @StrSuperVision + @StrVisitRout + ' ) A
		ON SUBSTRING(OD.AcntCode,' + LTRIM(STR(@StartLayerIndex)) + ',' + LTRIM(STR(@LayerLen)) + ')=A.AcntCode 
		Left Join sal.tblSaleTypes ST on ST.SaleTypeID= OH.SaleTypeID
		WHERE O.ConfirmQuantity>0 ' + @StrGoods + ' 
		) A WHERE IsCodeClosed = 0 ' +@StrSaleTypeID+ @StrSaleOrderConfirm
		
	Print @StrSelect1
	Print @StrSelect2

	END	
	ELSE
	 BEGIN
		SET @StrSelect1 = N' SELECT ' + @strDistQuery2 + '* 
								, [sal].[funGetCustomerKindName](CustomerKindID ,' + LTRIM(STR(@LanguageID)) + ' )CustomerKindName ,[pub].[funGetSaleTypesName](SaleTypeID,' + LTRIM(STR(@LanguageID)) + ') SaleTypeName
								,CASE WHEN DiscountDtlT>0 THEN DiscountDtlT ELSE sal.funGetLineDiscount(AcntCode,GoodsID,DocDate,SubUnitPriceT * SubUnitQuantity,Quantity,NULL,'''') END  DiscountDtl
							FROM (
		SELECT case when ContainTax =''False'' then ''False'' else  UsedDistribiutionPercent end UsedDistribiutionPercent , case when ContainTax =''False'' then ''False'' else  UsedDistribiutionPercentNew end UsedDistribiutionPercentNew 
				,IsNull(TransportationIncome,0)+IsNull(OtherIncome,0)+IsNull(PackingCost,0)+IsNull(TaxCost,0)+IsNull(TaxOverWorthCost,0)+IsNull(TollOverWorthCost ,0)-IsNull(TransportationCost,0)-(IsNull(CurrencyDiscount,0)*IsNull(CurrencyRate,0))
				-IsNull(OtherCost,0)-IsNull(Discount,0)-IsNull(Discount2,0)-IsNull(EarnestMoney ,0) OtherPrice,' + @strDistQuery + '
				acc.funIsCodeClosed(OD.AcntCode) IsCodeClosed,OD.ProcessID BaseOrderProcessID,OD.ProcessNo BaseOrderProcessNo,
			    OD.FiscalYear BaseOrderFiscalYear,OD.SerialNo BaseOrderSerialNo,OD.RowNo,OD.DocRowNo BaseOrderDocRowNo,OD.DocDate, OH.LocationID,
			    OD.AcntCode,OD.VisitorAcntCode,OD.VisitorPercent,OH.VisitorPercent VisitorPercentHdr,OD.GoodsID,OD.SubUnitID, OD.SubUnitQuantity,
			    pub.funGetMainUnitValue(OD.GoodsID,OD.SubUnitID) * OD.SubUnitQuantity / pub.funGetSubUnitValue(OD.GoodsID,OD.SubUnitID) Quantity,
			    O.ConfirmQuantity, OD.DescDtl, OD.BaseProcessID,OD.BaseProcessNo,OD.BaseFiscalYear,OD.BaseSerialNo,OD.BaseDocRowNo,
			    inv.funGetTechnicalSpecifications(OD.GoodsID) TechnicalSpecifications,IsNull(OH.TaxOverWorthCost,0) TaxOverWorthCost, DiscountTaxOverWorth,
			    IsNull(OH.TollOverWorthCost,0) TollOverWorthCost,IsNull(OH.TransportationCost,0) TransportationCost, OH.HasNoReward,OH.HasNoDiscountDtl, OH.PayOffTypeID,sal.GetPayOffTypeName( OH.PayOffTypeID,' + LTRIM(STR(@LanguageID)) + ') PayOffTypeName,
			    IsNull(OH.TransportationIncome,0) TransportationIncome, IsNull(OH.VisitorCost,0) VisitorCost, IsNull(OH.PackingCost,0) PackingCost, 
			    IsNull(OH.TaxCost,0) TaxCost, IsNull(OH.OtherCost,0) OtherCost, IsNull(OH.OtherIncome,0) OtherIncome, OH.SaleTypeID,
			    pub.funGetGoodsName(OD.GoodsID,' + LTRIM(STR(@LanguageID)) + ') GoodsName,inv.funGetUnitName(OD.SubUnitID,' + LTRIM(STR(@LanguageID)) + ') SubUnitName,
				inv.funGetGoodsRemain(null,null,null,null,null,''' + @StoreID + ''',OD.GoodsID,'''',''' + @DocDateTo + ''',0) GoodsRemain,' + @Price2S + ' Price,
				SubUnitPrice2,SubUnitQuantity2,O.GoodsPrice,IsNull(OD.DiscountPercentDtl,0) DiscountPercentDtl,
				IsNull(OH.DiscountPercent,0) DiscountPercent,IsNull(OH.DiscountPercent2,0) DiscountPercent2, IsNull(OH.Discount,0) Discount, IsNull(OH.Discount2,0) Discount2,
				DiscountDtl DiscountDtlT,O.SubUnitPrice SubUnitPriceT,
				pub.GetCodeName(OD.AcntCode,' + LTRIM(STR(@LanguageID)) + ') AcntName,
				pub.GetCodeName(OD.VisitorAcntCode,' + LTRIM(STR(@LanguageID)) + ') VisitorAcntName,OD.TaxOverWorthCostDtl,OD.TollOverWorthCostDtl,
				' + @StrPath + ', OH.CurrencyTypeID, OH.CurrencyRate, OD.CurrencyAmount,
				GoodsWeight,Sequence,Address1,CustomerKindID,(GoodsLength*GoodsWidth*GoodsHeight) Content,OD.IsReward,OD.IsReward0,OH.' + @DocDescName + ' AS DocDesc, OH.DocDesc DocDescHdr,
				OD.UserPriceID,isnull((Select UParams from inv.tblGoodsUserPrice p where p.ID=OD.UserPriceID) ,'''') as UserPrice, 
				SgnSN1, SgnSN2, SgnSN3, SgnSN4, SgnSN5,HasNotPayOffDiscounts '

		SET @StrSelect2 = '
		FROM	
			(
			SELECT	C.ProcessID,C.ProcessNo,C.FiscalYear,C.SerialNo,C.DocRowNo,C.DocDate,
					C.ConfirmQuantity - ISNULL(SD.ConfirmQuantity,0) ConfirmQuantity,SubUnitPrice,GoodsPrice
			From(
				SELECT S.ProcessID,S.ProcessNo,S.FiscalYear,S.SerialNo,DocRowNo,ConfirmQuantity ConfirmQuantity,BaseProcessID,BaseProcessNo, 
					   BaseFiscalYear,BaseSerialNo,BaseDocRowNo,DocDate,AcntCode,SubUnitPrice,GoodsPrice
				FROM ( SELECT ProcessID,ProcessNo,FiscalYear,SerialNo FROM  sal.tblSaleOrderDtl 
					   WHERE ProcessID=180  ' + @StrFilterStore + @StrVisitorAcnt + @StrAcnt + @StrDocDate + @StrSerialNo + ' AND DocStep = ' + LTrim(Str(@SalOrderDocStep)) + '
					   EXCEPT
					   (SELECT BaseProcessID,BaseProcessNo,BaseFiscalYear,BaseSerialNo FROM inv.tblStorageDocsDtl 
					    WHERE BaseProcessID=180
					    UNION 
					    SELECT BaseProcessID,BaseProcessNo,BaseFiscalYear,BaseSerialNo FROM sal.tblSaleOrderDtl 
					    WHERE BaseProcessID=180)) E 
					INNER JOIN sal.tblSaleOrderDtl S
					ON E.ProcessID=S.ProcessID AND E.ProcessNo=S.ProcessNo AND E.FiscalYear=S.FiscalYear AND E.SerialNo=S.SerialNo	
				WHERE S.ProcessID=180 ' + @StrFilterStore + @StrVisitorAcnt + @StrAcnt + @StrDocDate + ' AND DocStep=' + LTrim(Str(@SalOrderDocStep)) + '
				) C 
			LEFT JOIN 
				(SELECT DISTINCT BaseProcessID,BaseProcessNo,BaseFiscalYear,BaseSerialNo,BaseDocRowNo,ConfirmQuantity
				 FROM sal.FunGetBaseSaleGoodsForDist(''' + @AcntCodeFrom + ''',''' + @AcntCodeTo + ''',''' + @DocDateTo + ''')		
				) SD
				ON C.ProcessID=SD.BaseProcessID AND C.ProcessNo=SD.BaseProcessNo AND 
				C.FiscalYear=SD.BaseFiscalYear AND C.SerialNo=SD.BaseSerialNo AND 
				C.DocRowNo=SD.BaseDocRowNo 
			) O
		INNER JOIN sal.tblSaleOrderDtl OD
		ON	OD.ProcessID=O.ProcessID AND OD.ProcessNo=O.ProcessNo AND OD.FiscalYear=O.FiscalYear AND OD.SerialNo=O.SerialNo AND OD.DocRowNo=O.DocRowNo
		INNER JOIN sal.tblSaleOrderHdr OH
		ON	OD.ProcessID=OH.ProcessID AND OD.ProcessNo=OH.ProcessNo AND OD.FiscalYear=OH.FiscalYear AND OD.SerialNo=OH.SerialNo
		INNER JOIN
		(SELECT GoodsID,GoodsWeight,GoodsLength,GoodsWidth,GoodsHeight,ContainTax FROM inv.tblGoods WHERE CodeClosed=''False'') G
		ON OD.GoodsID = G.GoodsID
		INNER JOIN (SELECT a.AcntCode,Sequence,Address1,CustomerKindID FROM acc.tblAcnt a INNER JOIN acc.tblAcntDtl b on a.AcntCode=b.AcntCode and a.PartNumber=b.PartNumber  WHERE a.PartNumber=' + 
		LTRIM(STR(@AcntPartNumberForRemainCalculation)) + @StrCustomerKind + @StrBranch + @StrVisitArea + @StrSuperVision + @StrVisitRout + ' ) A
		ON SUBSTRING(OD.AcntCode,' + LTRIM(STR(@StartLayerIndex)) + ',' + LTRIM(STR(@LayerLen)) + ')=A.AcntCode 
		Left Join sal.tblSaleTypes ST on ST.SaleTypeID= OH.SaleTypeID
		WHERE O.ConfirmQuantity>0 ' + @StrGoods + ' 
		) A WHERE IsCodeClosed = 0 ' +@StrSaleTypeID+ @StrSaleOrderConfirm
		

	
	END

	SET @StrSelect ='SELECT round( Price-DistributionPrice,0) DistributionPurePrice,
						case When UsedDistribiutionPercent=''True'' then 
							PurePrice+round( Price-DistributionPrice,0) 
						else Price end GoodsPriceWithOutTax 
						,case When UsedDistribiutionPercent=''True'' then 
							Price
						else Price + round(PurePrice*TaxP/100,0)+ round(PurePrice*TollP/100,0) end GoodsPriceWithTax,
	                      '+ @strDistQuery3 +'* 
	              from (' +@StrSelect1 + @StrSelect2 + ') A'

	IF @bolSortSequance = 'True'
		SET @StrSelect = @StrSelect + ' ORDER BY Sequence,A.BaseOrderSerialNo,A.AcntCode,A.BaseOrderDocRowNo'
	ELSE
		SET @StrSelect = @StrSelect + ' ORDER BY A.BaseOrderSerialNo,Sequence,A.AcntCode,A.BaseOrderDocRowNo'

	Print 'SELECT round( Price-DistributionPrice,0) DistributionPurePrice,
						case When UsedDistribiutionPercent=''True'' then 
							PurePrice+round( Price-DistributionPrice,0) 
						else Price end GoodsPriceWithOutTax 
						,case When UsedDistribiutionPercent=''True'' then 
							Price
						else Price + round(PurePrice*TaxP/100,0)+ round(PurePrice*TollP/100,0) end GoodsPriceWithTax,
	                      '+ @strDistQuery3 +'* 
	              from (' 
	Print @StrSelect1
	Print @StrSelect2
	print ') A'
	-- ===========================				
	--Print @StrSelect
	Exec sp_executesql @StrSelect;
	-- ===========================				
	

END
GO
