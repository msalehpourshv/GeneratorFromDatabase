USE TS_ShirinVatanKarkhaneh_1_1404
GO
SET ANSI_NULLS, QUOTED_IDENTIFIER ON
GO
-- =========== TS-QC:NOTOK =====================
-- Author        : Hadi Sadeghi
-- Create date   : 86/12/22
-- Viewed By	 : 
-- Last Modified : 1393/08/04 - Hamid
-- Description   : 
-- =============================================
Create PROCEDURE sal.spFrmSaleByStepLoadConfirmDoc
	@ProcessID		tinyint,
	@ProcessNo		tinyint,
	@BaseFiscalYear smallint,
	@BaseSerialNo	int,
	@DocDate		Char(10),
	@AcntCode		Varchar(20)=NULL,
	@StoreID		Varchar(20),
	@LanguageID		Tinyint,
	@FiscalYear		smallint=NULL,
	@SerialNo		int=NULL,
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
		
IF @ProcessID = 240 --پیش فاکتور
BEGIN
			DECLARE @ConfirmState1 tinyint
			DECLARE @ConfirmState2 tinyint
			
			DECLARE @PreSaleConfirmDayLimit AS Int
			DECLARE @PreSaleConfirmHourLimit AS Varchar(10)
				
			SELECT @PreSaleConfirmDayLimit=SettingValue
			FROM pub.tblSettings
			WHERE SettingKey = 'PreSaleConfirmDay'	
			
			SELECT @PreSaleConfirmHourLimit=SettingValue
			FROM pub.tblSettings
			WHERE SettingKey = 'PreSaleConfirmHour'	
			
			IF @PreSaleConfirmDayLimit <> 0 And @PreSaleConfirmHourLimit <> '' And @PreSaleConfirmHourLimit Is Not Null
			Begin
				SET @ConfirmState1 = 1
				SET @ConfirmState2 = 1
			End
			ELSE
			Begin
				SET @ConfirmState1 = 0
				SET @ConfirmState2 = 3
			End

	DECLARE @ConfirmCountInPreSale AS  TinyInt;
	set @ConfirmCountInPreSale = 0
	SELECT @ConfirmCountInPreSale = SettingValue
	FROM pub.tblSettings
	WHERE SettingKey = 'ConfirmCountInPreSale'

	IF @PreSal_GetRemain = 'False'
		SELECT * ,IsNull(inv.funGetGoodsSubQuantity(A.GoodsID,A.SubUnitID,GoodsRemain),0) SubUnitRemain 
		FROM (
			SELECT  acc.funIsCodeClosed(OD.AcntCode) IsCodeClosed,  OD.ProcessID, OD.ProcessNo, OD.FiscalYear, OD.SerialNo, OD.RowNo, 
					OD.DocRowNo,--OD.GoodsAmount AS GoodsPrice,
					CASE WHEN @LastPriceInSaleorderForSale = 'False' THEN OD.GoodsAmount ELSE [sal].[funGetGoodsAmountSaleType](OD.GoodsID,'',OD.DocDate,OD.SaleTypeID,@LanguageID,OD.UserPriceID,0) END AS GoodsPrice,
					CASE WHEN @LastPriceInSaleorderForSale = 'False' THEN OD.MainAmount ELSE [sal].[funGetGoodsAmountSaleType](OD.GoodsID,'',OD.DocDate,OD.SaleTypeID,@LanguageID,OD.UserPriceID,0) END AS SubUnitPrice,
					1 DocStep, OD.DocDate, OD.AcntCode, OD.GoodsID, OH.PayOffTypeID,
					OD.SubUnitID,round (IsNull(inv.funGetGoodsSubQuantity(OD.GoodsID,OD.SubUnitID,CMRSaleOrderHdr.ConfirmQuantity),0),5) SubUnitQuantity,
					OD.SaleTypeID As DtlSaleTypeID,OD.ConstText1,OD.ConstText2,OD.ConstText3,OD.ConstText4, OH.HasNoReward,OH.HasNoDiscountDtl,
					pub.funGetGoodsUnitID(OD.GoodsID) as GSubUnitID, OD.MainAmount, OD.DiscountPercent As DiscountPercentDtl, OD.Discount as DiscountDtl,OD.TaxOverWorthCostDtl,
					OD.TollOverWorthCostDtl,CMRSaleOrderHdr.ConfirmQuantity AS GSubUnitQuantity, CMRSaleOrderHdr.ConfirmQuantity, pub.funReverseForCrystal(OD.DescDtl) DescDtl,pub.funReverseForCrystal(OH.DocDesc) DocDesc,
					OD.StoreID, IsNull(OH.TransporterID,'') As TransporterID, OH.CurrencyTypeID, OH.CurrencyRate, OD.CurrencyAmount,OH.CurrencyDiscount, OH.CurrencyTransportationCost, OH.CurrencyTransportationIncome,
					IsNull(OH.LocationID,'') As LocationID,OH.SaleTypeID,[inv].[funGetTechnicalSpecifications](OD.GoodsID) AS TechnicalSpecifications,OH.DiscountPercent,OH.DiscountPercent2,
					OH.Discount,OH.Discount2 -isnull((select sum(Discount2) from (	select distinct a.Discount2+a.Discount3 Discount2 from inv.tblStorageDocsHdr  a
						inner join inv.tblStorageDocsDtl b on a.ProcessID=b.ProcessID and a.ProcessNo=b.ProcessNo and a.FiscalYear=b.FiscalYear and a.SerialNo=b.SerialNo 
						where b.BaseProcessID=OD.ProcessID and b.BaseProcessNo=OD.ProcessNo and b.BaseFiscalYear=OD.FiscalYear and b.BaseSerialNo=OD.SerialNo   )a ),0) Discount2,						
					TransportationCostAcntCode,TransportationCost,TransportationIncomeAcntCode,TransportationIncome, OH.TransportationKindID, OH.GoodsReciverID, '' SettlementDate,
					OH.VisitorAcntCode VisitorAcntCodeHdr,OH.VisitorPercent VisitorPercentHdr, OH.VisitorCost, PackingCost, TaxCost, TaxOverWorthCost,TollOverWorthCost,OtherCostAcntCode,
					OH.VisitorAcntCode2 VisitorAcntCodeHdr2, OH.VisitorPercent2 VisitorPercentHdr2, OH.VisitorCost2, OD.VisitorAcntCode2, OD.VisitorPercent2, OD.VisitorAcntCode, OD.VisitorPercent,
					OtherCost,OtherIncomeAcntCode,OtherIncome,pub.funGetGoodsName(OD.GoodsID,@LanguageID) AS GoodsName,ExtraField1,ExtraField2,ExtraField3,ExtraField4,ExtraField5,
					inv.funGetUnitName(OD.SubUnitID,@LanguageID) AS SubUnitName,
					pub.funGetGoodsUnitName(OD.GoodsID,@LanguageID) AS GSubUnitName  ,
					[inv].[funGetGoodsRemain](@ProcessID,@ProcessNo,@FiscalYear,@BaseSerialNo,null,@StoreID,OD.GoodsID,'',@DocDate,0) GoodsRemain,
					OD.Var1, OD.Var2, OD.Var3, OD.Var4,[inv].[funGetTechnicalNo](OD.GoodsID) AS TechnicalNo,
					[inv].[funGetUnitCountForGoods](OD.GoodsID) GoodsCount,OD.UserPriceID,
					inv.FunGetGoodsWeight(OD.GoodsID) * GoodsQuantity GoodsWeight,
					inv.FunGetGoodsVolume(OD.GoodsID) * GoodsQuantity GoodsVol,
					IsNull((Select UParams From inv.tblGoodsUserPrice p Where p.ID=OD.UserPriceID) ,'') as UserPrice,0 DiscountTaxOverWorth					 
			FROM	
				(
				Select	CmrCnf.ProcessID , CmrCnf.ProcessNo , CmrCnf.FiscalYear , CmrCnf.SerialNo , CmrCnf.DocRowNo,CmrCnf.DocDate,
						CmrCnf.ConfirmQuantity  AS ConfirmQuantity  
				From
					 (
						SELECT DISTINCT *
						FROM  [inv].[FunGetPreSale](@AcntCode,@DocDate,@DocStep1) 
						WHERE (ProcessNo = @ProcessNo OR @DontCheckProcessNoInSale='True')			
					) CmrCnf 
				INNER JOIN 
					(
						SELECT DISTINCT ProcessID,ProcessNo,FiscalYear,SerialNo
						FROM  [inv].[FunGetPreSale](@AcntCode,@DocDate,@DocStep1) 
					Except 
					(
						SELECT DISTINCT BaseProcessID,BaseProcessNo,BaseFiscalYear,BaseSerialNo
						FROM  [cmr].[FunGetBaseSaleGoods](@AcntCode,@DocDate,1,2,@SerialNo,@FiscalYear) 
						UNION
					    Select	BaseProcessID , BaseProcessNo , BaseFiscalYear , BaseSerialNo 
						FROM sal.tblSaleOrderDtl
						WHERE BaseProcessID=240
					 )
					) CmrOrder
					ON CmrCnf.ProcessID = CmrOrder.ProcessID AND  CmrCnf.ProcessNo = CmrOrder.ProcessNo AND 
					CmrCnf.FiscalYear = CmrOrder.FiscalYear AND CmrCnf.SerialNo = CmrOrder.SerialNo 
				) CMRSaleOrderHdr
			INNER JOIN
			inv.tblPreSaleDtl OD
			ON	OD.ProcessID = CMRSaleOrderHdr.ProcessID AND  OD.ProcessNo = CMRSaleOrderHdr.ProcessNo AND 
				OD.FiscalYear = CMRSaleOrderHdr.FiscalYear AND OD.SerialNo = CMRSaleOrderHdr.SerialNo AND 
				OD.DocRowNo = CMRSaleOrderHdr.DocRowNo 
			INNER JOIN
			inv.tblPreSaleHdr OH
			ON	OD.ProcessID = OH.ProcessID AND  OD.ProcessNo = OH.ProcessNo AND 
				OD.FiscalYear = OH.FiscalYear AND OD.SerialNo = OH.SerialNo 
			INNER JOIN
			(SELECT GoodsID,ExtraField1,ExtraField2,ExtraField3,ExtraField4,ExtraField5 FROM inv.tblGoods WHERE CodeClosed = 'False' AND PartNumber = @UnitPart) G
			ON SUBSTRING(OD.GoodsID,@str_Goods+1,@str_GoodsSum) = G.GoodsID 
			WHERE	OD.ProcessID=@ProcessID AND OD.FiscalYear=@BaseFiscalYear AND OD.SerialNo=@BaseSerialNo AND --OD.ProcessNo=@ProcessNo AND  
				   (@AcntCode IS NULL OR OD.AcntCode = @AcntCode) AND OD.DocDate<= @DocDate  AND CMRSaleOrderHdr.ConfirmQuantity>0 
				AND OH.ConfirmState >= @ConfirmState1 And OH.ConfirmState <= @ConfirmState2
				And 
				(
					(@ConfirmCountInPreSale= 0)
					OR (@ConfirmCountInPreSale = 1 AND OH.SgnSN1 <> 0)
					OR (@ConfirmCountInPreSale = 2 AND OH.SgnSN1 <> 0 AND OH.SgnSN2 <> 0)
					OR (@ConfirmCountInPreSale = 3 AND OH.SgnSN1 <> 0 AND OH.SgnSN2 <> 0 AND OH.SgnSN3 <> 0)
					OR (@ConfirmCountInPreSale = 4 AND OH.SgnSN1 <> 0 AND OH.SgnSN2 <> 0 AND OH.SgnSN3 <> 0 AND OH.SgnSN4 <> 0)
					OR (@ConfirmCountInPreSale = 5 AND OH.SgnSN1 <> 0 AND OH.SgnSN2 <> 0 AND OH.SgnSN3 <> 0 AND OH.SgnSN4 <> 0 AND OH.SgnSN5 <> 0)
				 )
		) A WHERE IsCodeClosed = 0 

	ELSE		
		SELECT * FROM (
				SELECT  acc.funIsCodeClosed(OD.AcntCode) IsCodeClosed,  OD.ProcessID, OD.ProcessNo, OD.FiscalYear, OD.SerialNo, OD.RowNo, OD.DocRowNo,OD.GoodsAmount AS GoodsPrice,
						1 DocStep, OD.DocDate, OD.AcntCode, OD.GoodsID, OH.PayOffTypeID
						,OD.SubUnitID,round ([inv].[funGetSubUnitFromGoodsQuantity](OD.GoodsID,OD.SubUnitID,CMRSaleOrderHdr.ConfirmQuantity),5) SubUnitQuantity						
						, CMRSaleOrderHdr.ConfirmQuantity,OD.StoreID,
						[inv].[funGetTechnicalSpecifications](OD.GoodsID) AS TechnicalSpecifications,OH.DiscountPercent,OH.DiscountPercent2,
						OH.Discount, OH.Discount2-isnull((select sum(Discount2) from (	select distinct a.Discount2+ a.Discount3 Discount2 from inv.tblStorageDocsHdr  a
						inner join inv.tblStorageDocsDtl b on a.ProcessID=b.ProcessID and a.ProcessNo=b.ProcessNo and a.FiscalYear=b.FiscalYear and a.SerialNo=b.SerialNo 
						where b.BaseProcessID=OD.ProcessID and b.BaseProcessNo=OD.ProcessNo and b.BaseFiscalYear=OD.FiscalYear and b.BaseSerialNo=OD.SerialNo   )a ),0) Discount2, 
						OD.DiscountPercent As DiscountPercentDtl, OD.Discount as DiscountDtl,
						OD.SaleTypeID As DtlSaleTypeID,OD.ConstText1,OD.ConstText2, OD.ConstText3,OD.ConstText4,OH.HasNoReward,OH.HasNoDiscountDtl, OH.TransporterID, IsNull(OH.LocationID,'') As LocationID, 
						OH.SaleTypeID, TransportationCostAcntCode,TransportationCost,TransportationIncomeAcntCode,TransportationIncome, OH.TransportationKindID, OH.GoodsReciverID,
						OH.VisitorAcntCode VisitorAcntCodeHdr, OH.VisitorPercent VisitorPercentHdr, VisitorCost, PackingCost, TaxCost, '' SettlementDate,
						TaxOverWorthCost,TollOverWorthCost,	OH.VisitorAcntCode2 VisitorAcntCodeHdr2, OH.VisitorPercent2 VisitorPercentHdr2, 
						OH.VisitorCost2, OD.VisitorAcntCode2, OD.VisitorPercent2, OD.VisitorAcntCode, OD.VisitorPercent, OtherCostAcntCode, 
						OtherCost, OtherIncomeAcntCode, OtherIncome, pub.funGetGoodsName(OD.GoodsID,@LanguageID) AS GoodsName,ExtraField1,ExtraField2,ExtraField3,ExtraField4,ExtraField5,
						OD.DescDtl,inv.funGetUnitName(OD.SubUnitID,@LanguageID) AS SubUnitName,	
						[inv].[funGetGoodsRemain](@ProcessID,@ProcessNo,@FiscalYear,@BaseSerialNo,null,@StoreID,OD.GoodsID,'',@DocDate,0) GoodsRemain,
						OH.CurrencyTypeID, OH.CurrencyRate, OD.CurrencyAmount,OH.CurrencyDiscount, OH.CurrencyTransportationCost, OH.CurrencyTransportationIncome,
						[inv].[funGetTechnicalNo](OD.GoodsID) AS TechnicalNo,
						[inv].[funGetUnitCountForGoods](OD.GoodsID) GoodsCount,
						OD.UserPriceID,
						inv.FunGetGoodsWeight(OD.GoodsID) * GoodsQuantity GoodsWeight,
						inv.FunGetGoodsVolume(OD.GoodsID) * GoodsQuantity GoodsVol,
						IsNull((Select UParams From inv.tblGoodsUserPrice p Where p.ID=OD.UserPriceID) ,'') as UserPrice,0 DiscountTaxOverWorth						
				FROM	
					(
						
					SELECT	DISTINCT Cnf.ProcessID , Cnf.ProcessNo , Cnf.FiscalYear , Cnf.SerialNo , Cnf.DocRowNo ,DocDate
							,Cnf.GoodsQuantity - ISNULL(sd.ConfirmQuantity,0) AS ConfirmQuantity
					FROM	inv.tblPreSaleDtl Cnf	
					LEFT JOIN (
							Select BaseProcessID , BaseProcessNo , BaseFiscalYear , BaseSerialNo , BaseDocRowNo,Sum(GoodsQuantity) ConfirmQuantity 
							From inv.tblStorageDocsDtl
							Where BaseProcessID = 240 AND --DocStep =@DocStep AND
							 (@AcntCode IS NULL   OR AcntCode = @AcntCode) AND  DocDate <= @DocDate 
							Group BY BaseProcessID , BaseProcessNo , BaseFiscalYear , BaseSerialNo ,BaseDocRowNo
						) sd

					ON	Cnf.ProcessID = sd.BaseProcessID AND Cnf.ProcessNo = sd.BaseProcessNo AND 
						Cnf.FiscalYear = sd.BaseFiscalYear AND Cnf.SerialNo = sd.BaseSerialNo AND 
						Cnf.DocRowNo = sd.BaseDocRowNo
					WHERE Cnf.GoodsQuantity - ISNULL(sd.ConfirmQuantity,0)>0	
										
					) CMRSaleOrderHdr
				INNER JOIN
				inv.tblPreSaleDtl OD
				ON	OD.ProcessID = CMRSaleOrderHdr.ProcessID AND  OD.ProcessNo = CMRSaleOrderHdr.ProcessNo AND 
					OD.FiscalYear = CMRSaleOrderHdr.FiscalYear AND OD.SerialNo = CMRSaleOrderHdr.SerialNo AND 
					OD.DocRowNo = CMRSaleOrderHdr.DocRowNo 
				INNER JOIN
				inv.tblPreSaleHdr OH
				ON	OD.ProcessID = OH.ProcessID AND  OD.ProcessNo = OH.ProcessNo AND 
					OD.FiscalYear = OH.FiscalYear AND OD.SerialNo = OH.SerialNo 
				Inner Join (SELECT ProcessID,ProcessNo,FiscalYear,SerialNo from inv.tblPreSaleHdr where DocStep >= @DocStep1
							except	
							SELECT BaseProcessID,BaseProcessNo,BaseFiscalYear,BaseSerialNo from sal.tblSaleOrderDtl where ProcessID=180 and BaseProcessID=240
							)S
				ON OH.ProcessID = S.ProcessID AND OH.ProcessNo = S.ProcessNo AND OH.FiscalYear = S.FiscalYear AND OH.SerialNo = S.SerialNo
				INNER JOIN
				(SELECT GoodsID,ExtraField1,ExtraField2,ExtraField3,ExtraField4,ExtraField5 FROM inv.tblGoods WHERE CodeClosed = 'False' AND PartNumber = @UnitPart ) G
				ON SUBSTRING(OD.GoodsID,@str_Goods+1,@str_GoodsSum) = G.GoodsID 
				WHERE	OD.ProcessID=@ProcessID AND OD.FiscalYear=@BaseFiscalYear AND OD.SerialNo=@BaseSerialNo AND --OD.ProcessNo=@ProcessNo AND  
					   (@AcntCode IS NULL OR OD.AcntCode = @AcntCode) AND OD.DocDate<= @DocDate  AND CMRSaleOrderHdr.ConfirmQuantity>0 
				AND OH.ConfirmState >= @ConfirmState1 And OH.ConfirmState <= @ConfirmState2
				And 
				(
					(@ConfirmCountInPreSale= 0)
					OR (@ConfirmCountInPreSale = 1 AND OH.SgnSN1 <> 0)
					OR (@ConfirmCountInPreSale = 2 AND OH.SgnSN1 <> 0 AND OH.SgnSN2 <> 0)
					OR (@ConfirmCountInPreSale = 3 AND OH.SgnSN1 <> 0 AND OH.SgnSN2 <> 0 AND OH.SgnSN3 <> 0)
					OR (@ConfirmCountInPreSale = 4 AND OH.SgnSN1 <> 0 AND OH.SgnSN2 <> 0 AND OH.SgnSN3 <> 0 AND OH.SgnSN4 <> 0)
					OR (@ConfirmCountInPreSale = 5 AND OH.SgnSN1 <> 0 AND OH.SgnSN2 <> 0 AND OH.SgnSN3 <> 0 AND OH.SgnSN4 <> 0 AND OH.SgnSN5 <> 0)
				 )

		) A WHERE IsCodeClosed = 0 

END

ELSE IF @ProcessID = 180 -- سفارش فروش کالا
SELECT *, inv.funGetGoodsSubQuantity(A.GoodsID,A.SubUnitID,GoodsRemain) SubUnitRemain FROM (
	SELECT  acc.funIsCodeClosed(OD.AcntCode) IsCodeClosed,  OD.ProcessID, OD.ProcessNo, OD.FiscalYear, OD.SerialNo, OD.RowNo, OD.DocRowNo,
				OD.DocStep, OD.DocDate, OD.AcntCode, OD.GoodsID, OD.SubUnitID,round ( inv.funGetGoodsSubQuantity(OD.GoodsID,OD.SubUnitID,
				CMRSaleOrderHdr.ConfirmQuantity),5) SubUnitQuantity,CMRSaleOrderHdr.ConfirmQuantity GoodsQuantity, OD.IsReward,OD.IsReward0,CMRSaleOrderHdr.DocDesc,OH.DocDesc2, CMRSaleOrderHdr.ConfirmQuantity, OD.DescDtl, 
				OD.AgreeNo,OD.DiscountPercentDtl,OD.DiscountDtl,OD.VisitorPercent, OD.BaseProcessID, OD.BaseProcessNo, OD.BaseFiscalYear,
				OD.BaseSerialNo, OD.BaseDocRowNo, OH.HasNoReward, OH.HasNoDiscountDtl,OH.PayOffTypeID, OD.SaleTypeID As DtlSaleTypeID,OD.ConstText1, OD.ConstText2, 
				OD.ConstText3, OD.ConstText4, OD.TaxOverWorthCostDtl, OD.TollOverWorthCostDtl, OH.EarnestMoneyAcntCode, OH.EarnestMoneyPercent, IsNull(OH.SettlementDate,'') SettlementDate,
				OH.EarnestMoney, OH.StoreID HdrStoreID, OD.StoreID StoreID,ExtraField1,ExtraField2,ExtraField3,ExtraField4,ExtraField5,--DfStoreID as StoreID,
				IsNull(OH.LocationID,'') As LocationID, OH.TransportationCostAcntCode, OH.TransportationCost, OH.TransportationIncomeAcntCode, OH.TransportationIncome, OH.TransportationKindID, 
				OH.VisitorAcntCode As VisitorAcntCodeHdr, OH.VisitorPercent As HdrVisitorPercent, OH.VisitorCost, 
				OH.VisitorAcntCode2 VisitorAcntCodeHdr2, OH.VisitorPercent2 HdrVisitorPercent2, OH.VisitorCost2, OD.VisitorAcntCode2, OD.VisitorPercent2,
				OH.TaxOverWorthCost, OH.TollOverWorthCost, OH.OtherCostAcntCode, OH.OtherCost, OH.OtherIncomeAcntCode, OH.OtherIncome, OH.PackingCost, OH.TaxCost,
				[inv].[funGetTechnicalSpecifications](OD.GoodsID) AS TechnicalSpecifications,OH.Discount,OH.DiscountPercent,OH.DiscountPercent2,OH.Discount2,
				pub.funGetGoodsName(OD.GoodsID,@LanguageID) AS GoodsName,inv.funGetUnitName(OD.SubUnitID,@LanguageID) AS SubUnitName  ,
				[inv].[funGetGoodsRemain](@ProcessID,@ProcessNo,@FiscalYear,@BaseSerialNo,null,CASE WHEN  @Sal_StoreDtl = 'True' and CMRSaleOrderHdr.StoreID <>'' then CMRSaleOrderHdr.StoreID else CASE WHEN  @Sal_StoreDtl = 'True' and  DfStoreID<>'' THEN DfStoreID ELSE @StoreID END END,OD.GoodsID,'',@DocDate,0) GoodsRemain,OD.VisitorAcntCode,CMRSaleOrderHdr.SaleTypeID,
				CASE WHEN @LastPriceInSaleorderForSale = 'False' THEN CMRSaleOrderHdr.GoodsPrice ELSE [sal].[funGetGoodsAmountSaleType](OD.GoodsID,'',CMRSaleOrderHdr.DocDate,CMRSaleOrderHdr.SaleTypeID,@LanguageID,OD.UserPriceID,0) END AS GoodsPrice,
				CASE WHEN @LastPriceInSaleorderForSale = 'False' THEN CMRSaleOrderHdr.SubUnitPrice ELSE [sal].[funGetGoodsAmountSaleType](OD.GoodsID,'',CMRSaleOrderHdr.DocDate,CMRSaleOrderHdr.SaleTypeID,@LanguageID,OD.UserPriceID,0) END AS SubUnitPrice,
				OH.CurrencyTypeID,OH.CurrencyRate,CurrencyAmount,OH.CurrencyDiscount, OH.CurrencyTransportationCost, OH.CurrencyTransportationIncome, OD.UserPriceID,
				IsNull((Select UParams From inv.tblGoodsUserPrice p Where p.ID=OD.UserPriceID) ,'') as UserPrice,
				OD.Var1, OD.Var2, OD.Var3, OD.Var4,[inv].[funGetTechnicalNo](OD.GoodsID) AS TechnicalNo
				,[inv].[funGetUnitCountForGoods](OD.GoodsID) GoodsCount,
				inv.FunGetGoodsWeight(OD.GoodsID) * GoodsQuantity GoodsWeight,
				inv.FunGetGoodsVolume(OD.GoodsID) * GoodsQuantity GoodsVol,
				OD.BatchNo,OH.GoodsReciverID,OD.GoodsPriceWithTax
				,OD.OtherIncomePerentDtl,OD.OtherIncomeDtl,DiscountTaxOverWorth
		FROM	
			(
			Select	CmrCnf.ProcessID , CmrCnf.ProcessNo , CmrCnf.FiscalYear , CmrCnf.SerialNo , CmrCnf.DocRowNo,CmrCnf.StoreID,CmrCnf.DocDate,DocDesc,
					CmrCnf.ConfirmQuantity   AS ConfirmQuantity ,GoodsPrice, SubUnitPrice, VisitorAcntCode, VisitorAcntCode2, SaleTypeID 
					--CmrCnf.ConfirmQuantity  - ISNULL(CmrOrder.ConfirmQuantity,0)  AS ConfirmQuantity ,GoodsPrice,VisitorAcntCode,SaleTypeID 
			From
				(
					SELECT DISTINCT * 
					FROM  [cmr].[FunGetSaleOrder](@AcntCode,@DocDate,@DocStep,@SalRet_RetToSalOdr,@BaseFiscalYear,@BaseSerialNo)
					WHERE (@ProcessNo IS NULL OR ProcessNo = @ProcessNo)			
				) CmrCnf 
			--LEFT JOIN 
			--	(
			--		SELECT DISTINCT BaseProcessID,BaseProcessNo,BaseFiscalYear,BaseSerialNo,BaseDocRowNo,ConfirmQuantity
			--		FROM  [cmr].[FunGetBaseSaleGoods](@AcntCode,@DocDate,1,2,@SerialNo,@FiscalYear) 
			--	) CmrOrder
			--	ON CmrCnf.ProcessID = CmrOrder.BaseProcessID AND  CmrCnf.ProcessNo = CmrOrder.BaseProcessNo AND 
			--	CmrCnf.FiscalYear = CmrOrder.BaseFiscalYear AND CmrCnf.SerialNo = CmrOrder.BaseSerialNo AND 
			--	CmrCnf.DocRowNo = CmrOrder.BaseDocRowNo 
			) CMRSaleOrderHdr
		INNER JOIN
		sal.tblSaleOrderDtl OD
		ON	OD.ProcessID = CMRSaleOrderHdr.ProcessID AND  OD.ProcessNo = CMRSaleOrderHdr.ProcessNo AND 
			OD.FiscalYear = CMRSaleOrderHdr.FiscalYear AND OD.SerialNo = CMRSaleOrderHdr.SerialNo AND 
			OD.DocRowNo = CMRSaleOrderHdr.DocRowNo
		INNER JOIN
		sal.tblSaleOrderHdr OH
		ON	OD.ProcessID = OH.ProcessID AND  OD.ProcessNo = OH.ProcessNo AND 
			OD.FiscalYear = OH.FiscalYear AND OD.SerialNo = OH.SerialNo 
		INNER JOIN
		(SELECT GoodsID,DfStoreID,ExtraField1,ExtraField2,ExtraField3,ExtraField4,ExtraField5 FROM inv.tblGoods WHERE CodeClosed = 'False' AND PartNumber = @UnitPart ) G
		ON SUBSTRING(OD.GoodsID,@str_Goods+1,@str_GoodsSum) = G.GoodsID 
		WHERE	OD.ProcessID=@ProcessID AND (@ProcessNo IS NULL OR OD.ProcessNo = @ProcessNo) AND OD.FiscalYear=@BaseFiscalYear AND OD.SerialNo=@BaseSerialNo AND 
			   (@AcntCode IS NULL OR OD.AcntCode = @AcntCode) AND OD.DocDate<= @DocDate  AND CMRSaleOrderHdr.ConfirmQuantity>0 
) A WHERE IsCodeClosed = 0

ELSE IF @ProcessID = 91 -- باسکول فروش
SELECT * 
FROM (
	  SELECT D.*, H.AcntCode, pub.funGetGoodsName(D.GoodsID,@LanguageID) AS GoodsName, 
			 inv.funGetUnitName(D.SubUnitID,@LanguageID) AS SubUnitName, 
			 [inv].[funGetTechnicalSpecifications](D.GoodsID) AS TechnicalSpecifications,  
			 D.SubUnitQuantity As ConfirmQuantity, D.SubUnitQuantity As GoodsQuantity, D.Fee GoodsPrice,
			 D.Fee SubUnitPrice, '' TransportationCostAcntCode, H.TransportationCost, '' SettlementDate,
			 acc.funIsCodeClosed(H.AcntCode) IsCodeClosed,H.LocationID,H.VehicleNo,H.VehicleTypeID,H.DriverID, '' GoodsReciverID, '' TransportationKindID,
			 0 GoodsWeight,
			 0 GoodsVol
	  FROM 
	  (
			SELECT ProcessID, 0 ProcessNo, 0 FiscalYear, SerialNo
			FROM inv.tblBaskulSalesHdr H
			WHERE ProcessID = @ProcessID 
			EXCEPT
			SELECT BaseProcessID, 0 BaseProcessNo, 0 BaseFiscalYear, BaseSerialNo
			FROM inv.tblStorageDocsHdr 
			WHERE ProcessID = 90 And BaseProcessID = @ProcessID	  
	  ) H1
	  INNER JOIN inv.tblBaskulSalesHdr H ON H.ProcessID = H1.ProcessID And H.SerialNo = H1.SerialNo
	  INNER JOIN inv.tblBaskulSalesDtl D ON H.ProcessID = D.ProcessID And H.SerialNo = D.SerialNo
	  WHERE H.ProcessID = @ProcessID And H.SerialNo = @BaseSerialNo
	 ) A WHERE IsCodeClosed = 0
	 
ELSE IF @ProcessID = 90 -- فروش
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
		FROM [cmr].[FunGetSale](@AcntCode,@DocDate,@BaseFiscalYear)
		WHERE BaseProcessNo = @ProcessNo	
		
		SET @TempFiscalYear = @TempFiscalYear + 1
		
		WHILE (SELECT COUNT(NAME) from master.sys.databases
			   WHERE name= LEFT(DB_NAME(),LEN(DB_NAME())-4) + LTRIM(STR(@TempFiscalYear)))=1
		   BEGIN
				SET @StrSelect = '
						INSERT INTO ##tblS
						SELECT * 
						FROM ' + LEFT(DB_NAME(),LEN(DB_NAME())-4) + LTRIM(STR(@TempFiscalYear)) + '.[cmr].[FunGetSale](''' + ISNULL(@AcntCode,'') + ''',''' + @DocDate + ''',' + LTRIM(STR(@BaseFiscalYear)) + ')
						WHERE BaseProcessNo = ' + LTRIM(STR(@ProcessNo))
				PRINT @StrSelect
				Exec sp_executesql @StrSelect; 
				SET @TempFiscalYear = @TempFiscalYear + 1	   	
		   END
		  
			SELECT * into #tblTempSaleByStep FROM (
			SELECT  acc.funIsCodeClosed(OD.AcntCode) IsCodeClosed,OD.ProcessID, OD.ProcessNo, OD.FiscalYear, OD.SerialNo, OD.RowNo, OD.DocRowNo, OD.AgreeNo, 
				    OD.VolumeRowNo, OD.DocStep, DiscountAcntCode,DiscountPercent, DiscountPercent2, Discount, Discount2+Discount3 Discount2,Discount3, OD.DocDate, OD.StoreID , OD.StoreID As DStoreID, 
				    OD.EnterKind, OD.StoreID2, OD.AcntCode, OD.VisitorAcntCode, OD.VisitorAcntCode2, OD.BatchNo, OD.OrderAcntCode, OD.GoodsID, 
				    UnitID, SubUnitID, inv.funGetGoodsSubQuantity(OD.GoodsID,OD.SubUnitID,(OD.GoodsQuantity - ISNULL(Cn.ConfirmQuantity,0))) SubUnitQuantity,
				    OD.GoodsQuantity - ISNULL(Cn.ConfirmQuantity,0) GoodsQuantity, OD.GoodsQuantity - ISNULL(Cn.ConfirmQuantity,0) ConfirmQuantity, 
					OD.IsReward,OD.IsReward0,OD.QtyRemain, OD.GoodsAmount, OD.AtomAmount, OD.GoodsPrice, OD.DescDtl, OD.BaseProcessID, OD.BaseProcessNo, OD.PricePercent - ISNULL(Cn.PricePercent,0) PricePercent,
					OD.BaseFiscalYear, OD.BaseSerialNo, OD.BaseDocRowNo,  H.HasNoReward,H.HasNoDiscountDtl, H.BaseDistributionProcessID, H.BaseDistributionProcessNo,
					H.BaseDistributionFiscalYear, H.BaseDistributionSerialNo, H.DriverID, H.DistributerID1, H.DistributerID2, 
					[inv].[funGetTechnicalSpecifications](OD.GoodsID) As TechnicalSpecifications, OD.TaxOverWorthCostDtl, 
					OD.TollOverWorthCostDtl,H.DiscountTaxOverWorth, H.TaxOverWorthCost, H.TollOverWorthCost, H.SaleTypeID As HdrSaleTypeID, OD.Price0,
					H.CurrencyTypeID, H.CurrencyRate, OD.CurrencyAmount, H.CurrencyDiscount, H.CurrencyTransportationCost, H.CurrencyTransportationIncome, H.VisitorAcntCode2 VisitorAcntCodeHdr2, 
					H.VisitorPercent VisitorPercentHdr, H.VisitorCost VisitorCostHdr, H.VisitorPercent2 VisitorPercentHdr2, 
					H.VisitorCost2 VisitorCostHdr2, OD.VisitorPercent, OD.VisitorPercent2, OD.ConstText1, OD.ConstText2, OD.ConstText3,OD.ConstText4,
				    DiscountPercentDtl,(DiscountDtl * (OD.GoodsQuantity - ISNULL(Cn.ConfirmQuantity,0)))/OD.GoodsQuantity As DiscountDtl,
					pub.funGetGoodsName(OD.GoodsID,@LanguageID) As GoodsName, inv.funGetUnitName(SubUnitID,@LanguageID) As SubUnitName,
					[inv].[funGetMaxGoodsRemain](OD.ProcessID,OD.ProcessNo,OD.FiscalYear,OD.SerialNo,OD.ProcessID,OD.ProcessNo, OD.FiscalYear,
					OD.SerialNo,OD.DocRowNo,OD.StoreID,OD.GoodsID,OD.BatchNo,OD.DocDate,1)  As Remain, OD.UserPriceID,
					IsNull((Select UParams From inv.tblGoodsUserPrice p Where p.ID=OD.UserPriceID) ,'') as UserPrice,
					OtherIncomeAcntCode, OtherIncome, OtherCostAcntCode, OtherCost, TransportationCostAcntCode, TransportationCost, 
					SubUnitPrice, SubUnitPrice2, SubUnitQuantity2, TransportationIncomeAcntCode, TransportationIncome,VisitorCostAcntCode,
					OD.StoreVariable1, OD.StoreVariable2, OD.Var1, OD.Var2, OD.Var3, OD.Var4,OD.GBarCode,OD.SaleTypeID,[sal].[funGetSaleTypeName](OD.SaleTypeID,1) SaleTypeName,H.SaleTypeID SaleTypeID_Hdr,[sal].[funGetSaleTypeName](H.SaleTypeID,1)SaleTypeName_Hdr
					,OD.PriceParvane,[inv].[funGetTechnicalNo](OD.GoodsID) AS TechnicalNo,[inv].[funGetUnitCountForGoods](OD.GoodsID) GoodsCount,
					inv.FunGetGoodsWeight(OD.GoodsID) * GoodsQuantity GoodsWeight,
					inv.FunGetGoodsVolume(OD.GoodsID) * GoodsQuantity GoodsVol,H.BSN,H.BRN
					,pub.funGetCustomerKindID(H.AcntCode) CustomerKindID , H.PayOffTypeID,ROUND( GoodsPriceWithTax, 0) GoodsPriceWithTax,ROUND(  DistributionPrice, 0) DistributionPrice,ROUND( PurePrice, 0) PurePrice
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
				   (@AcntCode IS NULL OR OD.AcntCode = @AcntCode) AND OD.DocDate<=@DocDate AND OD.GoodsQuantity - ISNULL(Cn.ConfirmQuantity,0) > 0 And OD.DocStep > @DocStep_Sale AND OD.DocStep<90
		) A WHERE IsCodeClosed = 0 And (ProcessID<>90 or  (ProcessID=90 and TPInp<>7)) and  
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
--ELSE IF @ProcessID = 93 -- فروش
--	BEGIN
--		DECLARE @TempFiscalYear SMALLINT
--		DECLARE @StrSelect	NVarChar(4000)
		
--		SET @TempFiscalYear = RIGHT(DB_NAME(),4)
		
--		SELECT * INTO ##tblS
--		FROM [cmr].[FunGetSale](@AcntCode,@DocDate,@BaseFiscalYear)
--		WHERE BaseProcessNo = @ProcessNo	
		
--		SET @TempFiscalYear = @TempFiscalYear + 1
		
--		WHILE (SELECT COUNT(NAME) from master.sys.databases
--			   WHERE name= LEFT(DB_NAME(),LEN(DB_NAME())-4) + LTRIM(STR(@TempFiscalYear)))=1
--		   BEGIN
--				SET @StrSelect = 'INSERT INTO ##tblS
--						SELECT * 
--						FROM ' + LEFT(DB_NAME(),LEN(DB_NAME())-4) + LTRIM(STR(@TempFiscalYear)) + '.[cmr].[FunGetSale](''' + ISNULL(@AcntCode,'') + ''',''' + @DocDate + ''',' + LTRIM(STR(@BaseFiscalYear)) + ')
--						WHERE BaseProcessNo = ' + LTRIM(STR(@ProcessNo))
--				PRINT @StrSelect
--				Exec sp_executesql @StrSelect; 
--				SET @TempFiscalYear = @TempFiscalYear + 1	   	
--		   END
		  
--		SELECT * FROM (
--			SELECT  acc.funIsCodeClosed(OD.AcntCode) IsCodeClosed,OD.ProcessID, OD.ProcessNo, OD.FiscalYear, OD.SerialNo, OD.RowNo, OD.DocRowNo, OD.AgreeNo, 
--				    OD.VolumeRowNo, OD.DocStep, DiscountAcntCode,DiscountPercent, Discount, Discount2, OD.DocDate, OD.StoreID As DStoreID, 
--				    OD.EnterKind, OD.StoreID2, OD.AcntCode, OD.VisitorAcntCode, OD.VisitorAcntCode2, OD.BatchNo, OD.OrderAcntCode, OD.GoodsID, 
--				    UnitID, SubUnitID, inv.funGetGoodsSubQuantity(OD.GoodsID,OD.SubUnitID,(OD.GoodsQuantity - ISNULL(Cn.ConfirmQuantity,0))) SubUnitQuantity,
--				    OD.GoodsQuantity - ISNULL(Cn.ConfirmQuantity,0) GoodsQuantity, OD.GoodsQuantity - ISNULL(Cn.ConfirmQuantity,0) ConfirmQuantity, 
--					OD.IsReward,OD.QtyRemain, OD.GoodsAmount, OD.AtomAmount, OD.GoodsPrice, OD.DescDtl, OD.BaseProcessID, OD.BaseProcessNo, 
--					OD.BaseFiscalYear, OD.BaseSerialNo, OD.BaseDocRowNo, H.BaseDistributionProcessID, H.BaseDistributionProcessNo,
--					H.BaseDistributionFiscalYear, H.BaseDistributionSerialNo, H.DriverID, H.DistributerID1, H.DistributerID2, 
--					[inv].[funGetTechnicalSpecifications](OD.GoodsID) As TechnicalSpecifications, OD.TaxOverWorthCostDtl, 
--					OD.TollOverWorthCostDtl, H.TaxOverWorthCost, H.TollOverWorthCost, H.SaleTypeID As HdrSaleTypeID, 
--					H.CurrencyTypeID, H.CurrencyRate, OD.CurrencyAmount, H.CurrencyDiscount, H.VisitorAcntCode2 VisitorAcntCodeHdr2, 
--					H.VisitorPercent VisitorPercentHdr, H.VisitorCost VisitorCostHdr, H.VisitorPercent2 VisitorPercentHdr2, 
--					H.VisitorCost2 VisitorCostHdr2, OD.VisitorPercent, OD.VisitorPercent2, OD.ConstText1, OD.ConstText2, OD.ConstText3,OD.ConstText4,
--				    DiscountPercentDtl,(DiscountDtl * (OD.GoodsQuantity - ISNULL(Cn.ConfirmQuantity,0)))/OD.GoodsQuantity As DiscountDtl,
--					pub.funGetGoodsName(OD.GoodsID,@LanguageID) As GoodsName, inv.funGetUnitName(SubUnitID,@LanguageID) As SubUnitName,
--					[inv].[funGetMaxGoodsRemain](OD.ProcessID,OD.ProcessNo,OD.FiscalYear,OD.SerialNo,OD.ProcessID,OD.ProcessNo, OD.FiscalYear,
--					OD.SerialNo,OD.DocRowNo,OD.StoreID,OD.GoodsID,OD.BatchNo,OD.DocDate,1)  As Remain, OD.UserPriceID,
--					IsNull((Select UParams From inv.tblGoodsUserPrice p Where p.ID=OD.UserPriceID) ,'') as UserPrice,
--					OtherIncomeAcntCode, OtherIncome, OtherCostAcntCode, OtherCost, TransportationCostAcntCode, TransportationCost, 
--					SubUnitPrice, SubUnitPrice2, SubUnitQuantity2, TransportationIncomeAcntCode, TransportationIncome, VisitorCostAcntCode,
--					OD.StoreVariable1, OD.StoreVariable2, OD.Var1, OD.Var2, OD.Var3, OD.Var4
					
--			FROM inv.tblStorageDocsDtl OD 
--			INNER JOIN inv.tblStorageDocsHdr H
--			ON OD.ProcessID=H.ProcessID AND OD.ProcessNo=H.ProcessNo AND OD.FiscalYear=H.FiscalYear AND OD.SerialNo=H.SerialNo
--			LEFT JOIN
--			(
--				SELECT BaseProcessID , BaseProcessNo , BaseFiscalYear , 
--					   BaseSerialNo , BaseDocRowNo, ISNULL(SUM(ConfirmQuantity),0) ConfirmQuantity
--				FROM ##tblS
--				GROUP BY BaseProcessID , BaseProcessNo , BaseFiscalYear , 
--						 BaseSerialNo , BaseDocRowNo			
--			) Cn ON Cn.BaseProcessID = OD.ProcessID AND Cn.BaseProcessNo = OD.ProcessNo AND 
--					Cn.BaseFiscalYear = OD.FiscalYear AND Cn.BaseSerialNo = OD.SerialNo AND 
--					Cn.BaseDocRowNo = OD.DocRowNo 
--			INNER JOIN
--			(SELECT GoodsID,UnitID FROM inv.tblGoods WHERE CodeClosed = 'False' AND PartNumber = @UnitPart ) G
--			ON SUBSTRING(OD.GoodsID,@str_Goods+1,@str_GoodsSum) = G.GoodsID 
--			WHERE   OD.ProcessID=90 AND OD.ProcessNo=@ProcessNo AND OD.SerialNo = @BaseSerialNo AND OD.FiscalYear = @BaseFiscalYear AND OD.ProcessNo=@ProcessNo AND
--				   (@AcntCode IS NULL OR OD.AcntCode = @AcntCode) AND OD.DocDate<=@DocDate AND OD.GoodsQuantity - ISNULL(Cn.ConfirmQuantity,0) > 0 And OD.DocStep > 1 
--		) A WHERE IsCodeClosed = 0
		
--		DROP TABLE ##tblS	
--	END

ELSE IF @ProcessID = 171

	BEGIN
	select a.ProcessID SourceProcessID,a.ProcessNo SourceProcessNo,a.FiscalYear	SourceFiscalYear,a.SerialNo SourceSerialNo,a.DocRowNo SourceDocRowNo
	,a.BaseProcessID ProcessID,a.BaseProcessNo ProcessNo,a.BaseFiscalYear	FiscalYear,a.BaseSerialNo SerialNo	,a.BaseDocRowNo DocRowNo
	,a.StoreID	,a.GoodsID	,a.SubUnitID	,a.DocStep	,a.Qty	,a.CancelQty	,a.ConfirmQuantity	,a.DocDate	,a.AcntCode	,a.BaseProcessID	,a.BaseProcessNo	,a.BaseFiscalYear	,a.BaseSerialNo	,a.BaseDocRowNo	,a.AcntName	,a.DocDesc	,a.DescDtl	,a.Recognition	,a.PenaltyPercent	,a.ExtraField1	,a.ExtraField2	,a.ExtraField3	,a.ExtraField4	,a.ExtraField5	,a.GoodsPrice	,a.OrderDate	,a.SgnSN1	,a.SgnSN2	,a.SgnSN3	,a.SgnSN4	,a.SgnSN5	
	,a.ConfirmQuantity GoodsQuantity	,a.ConfirmQuantity SubUnitQuantity
	,inv.funGetUnitName(a.SubUnitID,@LanguageID) AS SubUnitName
	,ISNULL(TaxOverWorthCostDtl,0) TaxOverWorthCostDtl                    
	,ISNULL(TollOverWorthCostDtl,0)	TollOverWorthCostDtl
	,ISNULL(DiscountDtl,0)	DiscountDtl
	,ISNULL(TransportationCostAcntCode,'')	TransportationCostAcntCode
	,ISNULL(TransportationIncomeAcntCode,'')	TransportationIncomeAcntCode
	,ISNULL(OtherCostAcntCode,'')	OtherCostAcntCode
	,ISNULL(OtherIncomeAcntCode,'')	OtherIncomeAcntCode
	,ISNULL(H.VisitorAcntCode,'')	VisitorAcntCode
	,ISNULL(H.VisitorAcntCode2,'')	VisitorAcntCode2
	,ISNULL(DiscountAcntCode,'')	DiscountAcntCode
	,ISNULL(TaxOverWorthCost,0)	TaxOverWorthCost
	,ISNULL(TollOverWorthCost,0)	TollOverWorthCost
	,ISNULL(DiscountPercent,0)			DiscountPercent
	,ISNULL(DiscountPercent2,0)			DiscountPercent2
	,ISNULL(Discount,0)	Discount
	,ISNULL(Discount2,0)	Discount2
	,ISNULL(H.SaleTypeID,'')	HdrSaleTypeID
	,ISNULL(H.CurrencyTypeID,'')	CurrencyTypeID
	,ISNULL(H.CurrencyRate,0)	CurrencyRate
	,ISNULL(BaseDistributionSerialNo,0)	BaseDistributionSerialNo
	,ISNULL(DriverID,'')	DriverID
	,ISNULL(DistributerID1,'')	DistributerID1
	,ISNULL(DistributerID2,'')	DistributerID2
	,ISNULL(IsReward,0)	IsReward
	,ISNULL(IsReward0,0)	IsReward0
	,pub.funGetCustomerKindID(H.AcntCode) CustomerKindID , ISNULL(H.PayOffTypeID,'') PayOffTypeID,ISNULL(ROUND(GoodsPriceWithTax, 0),0) GoodsPriceWithTax,ISNULL(ROUND(DistributionPrice, 0),0) DistributionPrice,ISNULL(ROUND(PurePrice, 0),0) PurePrice
 	from cmr.FunCmrGoodsQtyRemain(171,0,0,0,0,0,0,0,0,0) a				 
	LEFT JOIN inv.tblStorageDocsDtl D 	
		ON D.ProcessID = a.BaseProcessID AND D.ProcessNo = a.BaseProcessNo AND D.FiscalYear = a.BaseFiscalYear AND D.SerialNo=a.BaseSerialNo AND D.DocRowNo=a.BaseDocRowNo
	LEFT JOIN inv.tblStorageDocsHdr H 
		ON D.ProcessID = H.ProcessID AND D.ProcessNo = H.ProcessNo AND D.FiscalYear = H.FiscalYear AND D.SerialNo=H.SerialNo
	INNER JOIN
			(SELECT GoodsID,UnitID FROM inv.tblGoods WHERE CodeClosed = 'False' AND PartNumber = @UnitPart) G
			ON SUBSTRING(a.GoodsID,@str_Goods+1,@str_GoodsSum) = G.GoodsID 
		where ConfirmQuantity>0 AND Recognition=1		
		AND a.SerialNo = @BaseSerialNo 
		AND a.FiscalYear = @BaseFiscalYear 
		AND a.DocDate <= @DocDate
	end
ELSE IF @ProcessID = 55 -- خرید

	BEGIN
		DECLARE @TempFiscalYear1 SMALLINT
		DECLARE @StrSelect1	NVarChar(4000)
		
		SET @TempFiscalYear1 = RIGHT(DB_NAME(),4)
		
		SELECT * INTO ##tblS1
		FROM [cmr].[FunGetSale](@AcntCode,@DocDate,@BaseFiscalYear)
		WHERE BaseProcessNo = @ProcessNo	
		
		SET @TempFiscalYear1 = @TempFiscalYear1 + 1
		
		WHILE (SELECT COUNT(NAME) from master.sys.databases
			   WHERE name= LEFT(DB_NAME(),LEN(DB_NAME())-4) + LTRIM(STR(@TempFiscalYear1)))=1
		   BEGIN
				SET @StrSelect1 = '
						INSERT INTO ##tblS1
						SELECT * 
						FROM ' + LEFT(DB_NAME(),LEN(DB_NAME())-4) + LTRIM(STR(@TempFiscalYear1)) + '.[inv].[FunGetBuy](''' + ISNULL(@AcntCode,'') + ''',''' + @DocDate + ''',' + LTRIM(STR(@BaseFiscalYear)) + ')
						WHERE BaseProcessNo = ' + LTRIM(STR(@ProcessNo))
				PRINT @StrSelect1
				Exec sp_executesql @StrSelect1;
				SET @TempFiscalYear1 = @TempFiscalYear1 + 1	   	
		   END
		  
		SELECT * FROM 
		(
			SELECT  acc.funIsCodeClosed(OD.AcntCode) IsCodeClosed,OD.ProcessID, OD.ProcessNo, OD.FiscalYear, OD.SerialNo, OD.RowNo, OD.VolumeRowNo, 
					OD.DocStep, DiscountAcntCode,DiscountPercent,DiscountPercent2, Discount,Discount2+Discount3 Discount2,Discount3,OD.DocDate, OD.StoreID, OD.EnterKind, OD.StoreID2, OD.AcntCode, 
					OD.VisitorAcntCode, OD.VisitorAcntCode2, OD.BatchNo, OD.OrderAcntCode, OD.GoodsID, UnitID SubUnitID, OD.GoodsQuantity  SubUnitQuantity,  
					OD.GoodsQuantity ConfirmQuantity, OD.QtyRemain, OD.GoodsAmount, OD.AtomAmount, OD.GoodsPrice, OD.DescDtl, OD.BaseProcessID, 
					OD.BaseProcessNo, OD.BaseFiscalYear, OD.BaseSerialNo, OD.BaseDocRowNo, OD.AgreeNo, OD.DocRowNo, H.HasNoReward,H.HasNoDiscountDtl,
					OD.TaxOverWorthCostDtl, OD.TollOverWorthCostDtl, [inv].[funGetTechnicalSpecifications](OD.GoodsID) AS TechnicalSpecifications,
					DiscountPercentDtl,(DiscountDtl * (OD.GoodsQuantity ))/OD.GoodsQuantity as DiscountDtl,'' As DtlSaleTypeID,
					pub.funGetGoodsName(OD.GoodsID,@LanguageID) AS GoodsName, inv.funGetUnitName(UnitID, @LanguageID) AS SubUnitName,
					[inv].[funGetMaxGoodsRemain](OD.ProcessID,OD.ProcessNo,OD.FiscalYear,OD.SerialNo,OD.ProcessID,OD.ProcessNo, 
					OD.FiscalYear,OD.SerialNo,OD.DocRowNo,OD.StoreID,OD.GoodsID,OD.BatchNo,OD.DocDate,1)  AS Remain,G.ExtraField1,G.ExtraField2,G.ExtraField3,G.ExtraField4,G.ExtraField5,
					OtherIncomeAcntCode, OtherIncome, TransportationCostAcntCode, TransportationIncomeAcntCode, OtherCostAcntCode, '' GoodsReciverID, '' TransportationKindID, 
					VisitorCostAcntCode, TransportationCost, TransportationIncome, VisitorCost, VisitorCost2, PackingCost, TaxCost, OtherCost,'' SettlementDate,
					TaxOverWorthCost, TollOverWorthCost, H.CurrencyTypeID, H.CurrencyRate, H.CurrencyDiscount, H.CurrencyTransportationCost, H.CurrencyTransportationIncome, OD.CurrencyAmount, OD.UserPriceID,
					OD.ConstText1,OD.ConstText2,OD.ConstText3,OD.ConstText4,
					IsNull((Select UParams From inv.tblGoodsUserPrice p Where p.ID=OD.UserPriceID) ,'') as UserPrice
					,[inv].[funGetTechnicalNo](OD.GoodsID) AS TechnicalNo
				    ,[inv].[funGetUnitCountForGoods](OD.GoodsID) GoodsCount,
					inv.FunGetGoodsWeight(OD.GoodsID) * GoodsQuantity GoodsWeight,
					inv.FunGetGoodsVolume(OD.GoodsID) * GoodsQuantity GoodsVol,
					CreditCardDiscount,AutoDiscont2,AutoDiscontPercent,AutoDiscont
			FROM inv.tblStorageDocsDtl OD 
			INNER JOIN inv.tblStorageDocsHdr H ON OD.ProcessID = H.ProcessID AND OD.ProcessNo = H.ProcessNo AND 
												  OD.FiscalYear = H.FiscalYear AND OD.SerialNo=H.SerialNo
			LEFT JOIN
			(
				SELECT BaseProcessID, BaseProcessNo, BaseFiscalYear, BaseSerialNo, BaseDocRowNo, ISNULL(SUM(ConfirmQuantity),0) ConfirmQuantity
				FROM ##tblS1
				GROUP BY BaseProcessID,BaseProcessNo, BaseFiscalYear, BaseSerialNo, BaseDocRowNo			
			) Cn ON Cn.BaseProcessID = OD.ProcessID AND Cn.BaseProcessNo = OD.ProcessNo AND 
					Cn.BaseFiscalYear = OD.FiscalYear AND Cn.BaseSerialNo = OD.SerialNo AND 
					Cn.BaseDocRowNo = OD.DocRowNo 
					
			INNER JOIN
			(SELECT GoodsID,UnitID,ExtraField1,ExtraField2,ExtraField3,ExtraField4,ExtraField5 FROM inv.tblGoods WHERE CodeClosed = 'False' AND PartNumber = @UnitPart) G
			ON SUBSTRING(OD.GoodsID,@str_Goods+1,@str_GoodsSum) = G.GoodsID 
			WHERE   OD.ProcessID = 55 AND OD.ProcessNo = @ProcessNo AND OD.SerialNo = @BaseSerialNo AND OD.FiscalYear = @BaseFiscalYear AND
					OD.DocDate <= @DocDate --AND OD.GoodsQuantity - ISNULL(Cn.ConfirmQuantity,0) > 0 
		) A WHERE IsCodeClosed = 0 
		
		DROP TABLE ##tblS1	

	END

END
GO
