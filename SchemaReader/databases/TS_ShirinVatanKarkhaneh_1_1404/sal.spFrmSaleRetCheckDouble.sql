USE TS_ShirinVatanKarkhaneh_1_1404
GO
SET ANSI_NULLS, QUOTED_IDENTIFIER ON
GO
-- =========== TS-QC:NOTOK =====================
-- Author        : jafari
-- Create date   : 1404/04/25
-- Viewed By	 : 
-- Last Modified : 
-- Description   : 
-- =============================================
Create PROCEDURE sal.spFrmSaleRetCheckDouble
	@ProcessID		tinyint,
	@ProcessNo		tinyint,
	@BaseFiscalYear smallint,
	@BaseSerialNo	int,
	@DocDate		Char(10),	
	@ExtraParams	NVarChar(Max)=NULL
WITH ENCRYPTION
AS
BEGIN
SET NOCOUNT ON;

	DECLARE @SalOrder_ConfirmDocStep		Bit
	DECLARE @DocStep						tinyint
	DECLARE @LastPriceInSaleorderForSale	BIT
	DECLARE @SalRet_RetToSalOdr				BIT
	DECLARE @DocStep1						tinyint
	DECLARE @HasConfirmForPreSale			BIT
	DECLARE @PreSal_GetRemain				BIT
	DECLARE @Sal_StoreDtl					BIT
	DECLARE @PermissionFilter				NVarChar(Max) 

	SET @PermissionFilter		= LTrim(pub.funSplitString(@ExtraParams, '@', 1)); 
	set @PermissionFilter=isnull(@PermissionFilter,'')
	set @PermissionFilter= REPLACE(@PermissionFilter,'''','''''')
	
	SET @LastPriceInSaleorderForSale = 'False'
	SET @SalOrder_ConfirmDocStep = 'False'
	SET @SalRet_RetToSalOdr = 'False'
	SET @HasConfirmForPreSale = 'False'
	SET @PreSal_GetRemain = 'False'
	SET @Sal_StoreDtl = 'False'
	DECLARE @UnitPart TINYINT
	SET @UnitPart  = 1

	SELECT @UnitPart = SettingValue from pub.tblSettings where SettingKey = 'UnitPart'

	IF @UnitPart IS NULL or @UnitPart = 0
		SET @UnitPart = 1

	DECLARE @str_Goods  tinyint,
			@str_GoodsSum tinyint

	select @str_Goods = ISNULL(SUM (Layer1+Layer2+Layer3+Layer4+Layer5+Layer6+Layer7+Layer8+Layer9),0)
	from pub.tblCodeLayer 
	where TableName='inv.tblGoods' AND PartNumber<@UnitPart

	select @str_GoodsSum = Layer1+Layer2+Layer3+Layer4+Layer5+Layer6+Layer7+Layer8+Layer9
	from pub.tblCodeLayer 
	where TableName= 'inv.tblGoods' AND PartNumber=@UnitPart

	SELECT @Sal_StoreDtl=SettingValue
	FROM pub.tblSettings
	WHERE SettingKey = 'Sal_StoreDtl'


	SELECT @LastPriceInSaleorderForSale=SettingValue
	FROM pub.tblSettings
	WHERE SettingKey = 'LastPriceInSaleorderForSale'
	
	SELECT @SalRet_RetToSalOdr = SettingValue
	FROM pub.tblSettings
	WHERE SettingKey = 'SalRet_RetToSalOdr' 
	
	SELECT @PreSal_GetRemain=SettingValue
	FROM pub.tblSettings
	WHERE SettingKey = 'PreSal_GetRemain'
		
	SELECT @SalOrder_ConfirmDocStep=SettingValue
	FROM pub.tblSettings
	WHERE SettingKey = 'SalOrder_ConfirmDocStep'

	IF @SalOrder_ConfirmDocStep = 'False' 
		SET @DocStep = 1
	ELSE
		SET @DocStep = 2

	SELECT @HasConfirmForPreSale=SettingValue
	FROM pub.tblSettings
	WHERE SettingKey = 'HasConfirmForPreSale'

	-- ==========
	DECLARE @DontCheckProcessNoInSale AS BIT
	SET @DontCheckProcessNoInSale = 'False'
	
	SELECT @DontCheckProcessNoInSale=SettingValue
	FROM pub.tblSettings
	WHERE SettingKey = 'DontCheckProcessNoInSale'
		
	IF @DontCheckProcessNoInSale = 'True' AND @ProcessID <> 90 And @ProcessID <> 55
		SET @ProcessNo = NULL
					
	-- ==========
	IF @HasConfirmForPreSale = 'False' 
		SET @DocStep1 = 1
	ELSE
		SET @DocStep1 = 2
		
 IF @ProcessID = 90 -- فروش
	BEGIN
		DECLARE @TempFiscalYear SMALLINT
		DECLARE @StrSelect	NVarChar(4000)
		Declare @DocStep_Sale int 
		DECLARE @SalRetNotReturnService AS BIT
		
		Declare @SaleOrderAcntCode Varchar(20)	
		SELECT @SaleOrderAcntCode = SettingValue FROM pub.tblSettings WHERE SettingKey = 'SaleOrderAcntCode'

		SET @DocStep_Sale = 0
		SET @SalRetNotReturnService = 'False'
		
		select @DocStep_Sale = ISNULL(MAX(DocStep),0) 
		from inv.tblStorageDocsHdr
		WHERE  ProcessID=90 AND ProcessNo=@ProcessNo and DocStep<90

		IF @DocStep_Sale<=1
			SET @DocStep_Sale = -1
		ELSE
			SET @DocStep_Sale=1

		SELECT @SalRetNotReturnService = SettingValue 
		FROM pub.tblSettings 
		WHERE SettingKey = 'SalRetNotReturnService'

		SET @TempFiscalYear = RIGHT(DB_NAME(),4)
		
		SELECT * INTO ##tblS
		FROM [cmr].[FunGetSale](NULL,@DocDate,@BaseFiscalYear)
		WHERE BaseProcessNo = @ProcessNo	
		
		SET @TempFiscalYear = @TempFiscalYear + 1
		
		WHILE (SELECT COUNT(NAME) from master.sys.databases
			   WHERE name= LEFT(DB_NAME(),LEN(DB_NAME())-4) + LTRIM(STR(@TempFiscalYear)))=1
		   BEGIN
				SET @StrSelect = '
						INSERT INTO ##tblS
						SELECT * 
						FROM ' + LEFT(DB_NAME(),LEN(DB_NAME())-4) + LTRIM(STR(@TempFiscalYear)) + '.[cmr].[FunGetSale](''' + ISNULL(NULL,'') + ''',''' + @DocDate + ''',' + LTRIM(STR(@BaseFiscalYear)) + ')
						WHERE BaseProcessNo = ' + LTRIM(STR(@ProcessNo))
				PRINT @StrSelect
				Exec sp_executesql @StrSelect; 
				SET @TempFiscalYear = @TempFiscalYear + 1	   	
		   END
		  
		SELECT *  into #tblTempSaleByStep FROM (
			SELECT  OD.ProcessID, OD.ProcessNo, OD.FiscalYear, OD.SerialNo, OD.RowNo, OD.DocRowNo, OD.AgreeNo, 
				    OD.VolumeRowNo, OD.DocStep, DiscountAcntCode,DiscountPercent, DiscountPercent2, Discount, Discount2+Discount3 Discount2,Discount3, OD.DocDate, OD.StoreID , OD.StoreID As DStoreID, 
				    OD.EnterKind, OD.StoreID2, OD.AcntCode, OD.VisitorAcntCode, OD.VisitorAcntCode2, OD.BatchNo, OD.OrderAcntCode, OD.GoodsID, 
				    UnitID, SubUnitID, inv.funGetGoodsSubQuantity(OD.GoodsID,OD.SubUnitID,(OD.GoodsQuantity - ISNULL(Cn.ConfirmQuantity,0))) SubUnitQuantity,
				    OD.GoodsQuantity - ISNULL(Cn.ConfirmQuantity,0) GoodsQuantity, OD.GoodsQuantity - ISNULL(Cn.ConfirmQuantity,0) ConfirmQuantity, 
					OD.IsReward,OD.IsReward0,OD.QtyRemain, OD.GoodsAmount, OD.AtomAmount, OD.GoodsPrice, OD.DescDtl, OD.BaseProcessID, OD.BaseProcessNo, OD.PricePercent - ISNULL(Cn.PricePercent,0) PricePercent,
					OD.BaseFiscalYear, OD.BaseSerialNo, OD.BaseDocRowNo,  H.HasNoReward,H.HasNoDiscountDtl, H.BaseDistributionProcessID, H.BaseDistributionProcessNo,
					H.BaseDistributionFiscalYear, H.BaseDistributionSerialNo, H.DriverID, H.DistributerID1, H.DistributerID2, 
					 OD.TaxOverWorthCostDtl, 
					OD.TollOverWorthCostDtl,H.DiscountTaxOverWorth, H.TaxOverWorthCost, H.TollOverWorthCost, H.SaleTypeID As HdrSaleTypeID, OD.Price0,
					H.CurrencyTypeID, H.CurrencyRate, OD.CurrencyAmount, H.CurrencyDiscount, H.CurrencyTransportationCost, H.CurrencyTransportationIncome, H.VisitorAcntCode2 VisitorAcntCodeHdr2, 
					H.VisitorPercent VisitorPercentHdr, H.VisitorCost VisitorCostHdr, H.VisitorPercent2 VisitorPercentHdr2, 
					H.VisitorCost2 VisitorCostHdr2, OD.VisitorPercent, OD.VisitorPercent2, OD.ConstText1, OD.ConstText2, OD.ConstText3,OD.ConstText4,
				    DiscountPercentDtl,(DiscountDtl * (OD.GoodsQuantity - ISNULL(Cn.ConfirmQuantity,0)))/OD.GoodsQuantity As DiscountDtl, OD.UserPriceID,
					
					OtherIncomeAcntCode, OtherIncome, OtherCostAcntCode, OtherCost, TransportationCostAcntCode, TransportationCost, 
					SubUnitPrice, SubUnitPrice2, SubUnitQuantity2, TransportationIncomeAcntCode, TransportationIncome,VisitorCostAcntCode,
					OD.StoreVariable1, OD.StoreVariable2, OD.Var1, OD.Var2, OD.Var3, OD.Var4,OD.GBarCode,OD.SaleTypeID,
					H.SaleTypeID SaleTypeID_Hdr,OD.PriceParvane,H.BSN,H.BRN
					, H.PayOffTypeID,ROUND( GoodsPriceWithTax, 0) GoodsPriceWithTax,ROUND(  DistributionPrice, 0) DistributionPrice,ROUND( PurePrice, 0) PurePrice
					,CreditCardDiscount,AutoDiscont2,AutoDiscontPercent,AutoDiscont,TPInp
			FROM inv.tblStorageDocsDtl OD 
					-------------------------------------------------------------------			
	
			INNER JOIN inv.tblStorageDocsHdr H
			ON H.DocStep<90 and OD.ProcessID=H.ProcessID AND OD.ProcessNo=H.ProcessNo AND OD.FiscalYear=H.FiscalYear AND OD.SerialNo=H.SerialNo
			LEFT JOIN
			(
				SELECT BaseProcessID , BaseProcessNo , BaseFiscalYear ,BaseSerialNo , BaseDocRowNo,
				       ISNULL(SUM(PricePercent),0) PricePercent,ISNULL(SUM(ConfirmQuantity),0) ConfirmQuantity
				FROM ##tblS
				GROUP BY BaseProcessID , BaseProcessNo , BaseFiscalYear , 
						 BaseSerialNo , BaseDocRowNo			
			) Cn ON Cn.BaseProcessID = OD.ProcessID AND Cn.BaseProcessNo = OD.ProcessNo AND 
					Cn.BaseFiscalYear = OD.FiscalYear AND Cn.BaseSerialNo = OD.SerialNo AND 
					Cn.BaseDocRowNo = OD.DocRowNo 
			INNER JOIN
			(SELECT GoodsID,UnitID,IsService FROM inv.tblGoods WHERE CodeClosed = 'False' AND PartNumber = @UnitPart ) G
			ON SUBSTRING(OD.GoodsID,@str_Goods+1,@str_GoodsSum) = G.GoodsID 
			WHERE (@SalRetNotReturnService = 'False' OR  G.IsService='False' ) AND  OD.ProcessID=90 AND OD.ProcessNo=@ProcessNo AND OD.SerialNo = @BaseSerialNo AND OD.FiscalYear = @BaseFiscalYear AND OD.ProcessNo=@ProcessNo AND
				   (NULL IS NULL OR OD.AcntCode = NULL) AND OD.DocDate<=@DocDate
				   AND OD.GoodsQuantity - ISNULL(Cn.ConfirmQuantity,0) < 0 And OD.DocStep > @DocStep_Sale AND OD.DocStep<90
		) A WHERE (ProcessID<>90 or  (ProcessID=90 and TPInp<>7)) and  
		((BSN>0  AND BRN>0 )OR
		 (SELECT COUNT(*) FROM inv.tblStorageDocsDtl a 
		  WHERE  IsReward=0 and a.ProcessID  = A.ProcessID AND a.ProcessNo = A.ProcessNo AND 
			a.FiscalYear = A.FiscalYear AND a.SerialNo = A.SerialNo )=0 OR 
		 (------------حذف اطلاعاتی که اسناد آنها ازنوع یادداشت است------------------------------------------------------
			SELECT COUNT(*)	from acc.tblVoucherDtl  v 
			WHERE v.SourceProcessID= A.ProcessID and  v.SourceProcessNo= A.ProcessNo
			 and  v.SourceFiscalYear= A.FiscalYear and  v.SourceSerialNo= A.SerialNo
			 and (v.AcntCode= A.AcntCode or v.AcntCode=[pub].[funMergCode](@SaleOrderAcntCode,A.AcntCode)) and v.VchKind<>0
		) > 0)

		SET @StrSelect = '
			SELECT *  
			from #tblTempSaleByStep
			WHERE 1=1 ' + @PermissionFilter
		PRINT @StrSelect
		Exec sp_executesql @StrSelect; 

		DROP TABLE ##tblS	
		DROP TABLE #tblTempSaleByStep	
	END


END
GO
