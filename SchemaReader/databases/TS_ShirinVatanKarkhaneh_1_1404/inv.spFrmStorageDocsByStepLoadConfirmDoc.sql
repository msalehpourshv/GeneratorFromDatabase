USE TS_ShirinVatanKarkhaneh_1_1404
GO
SET ANSI_NULLS, QUOTED_IDENTIFIER ON
GO
-- =============================================
-- Author:		Hadi Sadeghi
-- Create date: 86/10/15
-- Description:	Control Receipt 
-- =============================================
Create PROCEDURE [inv].[spFrmStorageDocsByStepLoadConfirmDoc]
	 @BaseProcessID		int,
	 @ProcessID			int,
	 @ProcessNo			tinyint,
	 @BaseFiscalYear	smallint,
	 @BaseSerialNo		int,
	 @DocDate			Char(10),
	 @StoreID			varchar(20),
	 @AcntCode			varchar(20),
	 @LanguageID		Tinyint,
	 @SerialNo			Int,
	 @FiscalYear		SmallInt,
	 @OneStep			BIT,
	 @ExtraParams	NVarChar(Max) 

WITH ENCRYPTION
AS
BEGIN

--======================================
	SET NOCOUNT ON;

    DECLARE @strMsgText	 NVarChar(2044)
    DECLARE @Counter Tinyint
	DECLARE @SalOrder_ConfirmDocStep Nvarchar(100)
	DECLARE @DocStep tinyint
	DECLARE @SalRet_RetToSalOdr AS BIT
	DECLARE @DocStep1 tinyint
	DECLARE @HasConfirmForPreSale AS BIT
	DECLARE @buy_StoreDtl AS BIT
	DECLARE @PreSal_GetRemain AS BIT
	DECLARE @Buy_DontCheckDateConvertTempReceiptToBuy AS Bit

	SELECT @Buy_DontCheckDateConvertTempReceiptToBuy=SettingValue
	FROM   pub.tblSettings
	WHERE SettingKey = 'Buy_DontCheckDateConvertTempReceiptToBuy'

--======================================
	DECLARE @UnitPart TINYINT
	SET @UnitPart  = 1

	SELECT @UnitPart = SettingValue from pub.tblSettings where SettingKey = 'UnitPart'

	IF @UnitPart IS NULL or @UnitPart = 0
		SET @UnitPart = 1

	DECLARE @str_Goods  tinyint,
			@str_GoodsSum tinyint

	Select @str_Goods = ISNULL(SUM (Layer1+Layer2+Layer3+Layer4+Layer5+Layer6+Layer7+Layer8+Layer9),0)
	From pub.tblCodeLayer 
	Where TableName='inv.tblGoods' AND PartNumber<@UnitPart

	Select @str_GoodsSum = Layer1+Layer2+Layer3+Layer4+Layer5+Layer6+Layer7+Layer8+Layer9
	From pub.tblCodeLayer 
	Where TableName= 'inv.tblGoods' AND PartNumber=@UnitPart
		
	SET @SalOrder_ConfirmDocStep = 'False'
	SET @SalRet_RetToSalOdr = 'False'
	SET @HasConfirmForPreSale = 'False'
	SET @buy_StoreDtl = 'False'
	SET @PreSal_GetRemain = 'False'
		
	SELECT @SalRet_RetToSalOdr = SettingValue
	FROM pub.tblSettings
	WHERE SettingKey = 'SalRet_RetToSalOdr' 
	
	SELECT @SalOrder_ConfirmDocStep=SettingValue
	FROM pub.tblSettings
	WHERE SettingKey = 'SalOrder_ConfirmDocStep'

	SELECT @buy_StoreDtl=SettingValue
	FROM pub.tblSettings
	WHERE SettingKey = 'Buy_StoreDtl'

	SELECT @PreSal_GetRemain=SettingValue
	FROM pub.tblSettings
	WHERE SettingKey = 'PreSal_GetRemain'

	IF @SalOrder_ConfirmDocStep = 'False' 
		SET @DocStep = 1
	ELSE
		SET @DocStep = 2

	SELECT @HasConfirmForPreSale=SettingValue
	FROM pub.tblSettings
	WHERE SettingKey = 'HasConfirmForPreSale'

	IF @HasConfirmForPreSale = 'False' 
		SET @DocStep1 = 1
	ELSE
		SET @DocStep1 = 2
		
--======================================
DECLARE @BuyDocStep TinyInt
DECLARE @DocStepCondition AS Bit

SELECT @DocStepCondition=SettingValue
FROM   pub.tblSettings
WHERE SettingKey = 'DocStepConditionInBuyRet'

IF @DocStepCondition = 'False' 
	SET @BuyDocStep = 1
ELSE
	SET @BuyDocStep = 2
--======================================

declare @UserID float
declare @StartAcnt int=1
declare @LenAcnt int=0
declare @PartNo int=1

SET @UserID				= pub.funSplitString(@ExtraParams, '@', 1);
IF pub.funSplitString(@ExtraParams, '@', 2)<>''
BEGIN
	SET @StartAcnt				= pub.funSplitString(@ExtraParams, '@', 2);
	SET @LenAcnt				= pub.funSplitString(@ExtraParams, '@', 3);
	SET @PartNo					= pub.funSplitString(@ExtraParams, '@', 4);
END
		
IF @BaseProcessID=150 or  @BaseProcessID=160  or  @BaseProcessID=170 
begin 
if (SELECT isnull(SettingValue,0) FROM pub.tblSettings WHERE SettingKey = 'HasCMR234')=0
		set @ProcessNo=0
	
end 	

IF @BaseProcessID=90 and @ProcessID=90   -- خرید طبق فروش
BEGIN
	SELECT * 
	FROM inv.tblStorageDocsHdr 
	WHERE ProcessID = @ProcessID AND ProcessNo = @ProcessNo AND 
		  SerialNo = @BaseSerialNo AND FiscalYear = @BaseFiscalYear 
END
ELSE IF @BaseProcessID=150   -- درخواست خرید
BEGIN

	SELECT *, 0 DiscountDtl,0 TaxOverWorthCostDtl,0 TollOverWorthCostDtl FROM (
		Select DISTINCT	acc.funIsCodeClosed(AcntCode) IsCodeClosed,ProcessID, ProcessNo, FiscalYear, SerialNo, RowNo, DocRowNo, 
			DocStep, DocDate, AcntCode, GoodsID, SubUnitID,ConfirmQuantity SubUnitQuantity, 
			[inv].[funGetGoodsQuantityFromSubUnit](GoodsID, SubUnitID,ConfirmQuantity) GoodsQuantity, 
			ConfirmQuantity, DocDesc ,DescDtl, DocDate OrderDate, 0 As AgreeNo, 0 As HdrAgreeNo,
			BaseProcessID, BaseProcessNo, BaseFiscalYear,BaseSerialNo, BaseDocRowNo,
			[inv].[funGetTechnicalSpecifications](GoodsID) AS TechnicalSpecifications, 
			pub.funGetGoodsName(GoodsID,@LanguageID) AS GoodsName, inv.funGetUnitName(SubUnitID,@LanguageID) AS SubUnitName,
			ExtraField1,ExtraField2,ExtraField3,ExtraField4,ExtraField5,StoreID
			from cmr.FunCmrGoodsQtyRemain(@BaseProcessID,@ProcessNo  ,@BaseFiscalYear,@BaseSerialNo,0,0,0,0,0,0)
				where (@AcntCode IS NULL OR AcntCode LIKE  @AcntCode + '%' ) 
						AND  SerialNo=@BaseSerialNo 
						AND  DocDate<=@DocDate 
						AND ConfirmQuantity>0
						AND   DocStep = 2
				) A WHERE IsCodeClosed = 0

END

ELSE IF @BaseProcessID=160 -- درخواست خرید
BEGIN
 
	SELECT A.*, 0 DiscountDtl,0 TaxOverWorthCostDtl,0 TollOverWorthCostDtl , CurrencyAmount	FROM (			
			SELECT DISTINCT	acc.funIsCodeClosed(AcntCode) IsCodeClosed,ProcessID, ProcessNo, FiscalYear, SerialNo, RowNo, DocRowNo,
			DocStep, DocDate, AcntCode, GoodsID, SubUnitID,ConfirmQuantity SubUnitQuantity, 0 TransportationCost,
			[inv].[funGetGoodsQuantityFromSubUnit](GoodsID, SubUnitID,ConfirmQuantity) GoodsQuantity, 
			ConfirmQuantity,DocDesc ,DescDtl,  GoodsPrice,GoodsPrice SubUnitPrice, 		
			BaseProcessID, BaseProcessNo, BaseFiscalYear,BaseSerialNo, BaseDocRowNo, 0 AgreeNo,
			[inv].[funGetTechnicalSpecifications](GoodsID) AS TechnicalSpecifications, 0 as HdrAgreeNo, 
			pub.funGetGoodsName(GoodsID,@LanguageID) AS GoodsName,inv.funGetUnitName(SubUnitID,@LanguageID) AS SubUnitName ,
			ExtraField1,ExtraField2,ExtraField3,ExtraField4,ExtraField5--,RolQty,
			--,InOutWithServiceType
			,StoreID,TransferAmountFor,CurrencyTypeID,CurrencyRate
				from cmr.FunCmrGoodsQtyRemain(@BaseProcessID,@ProcessNo  ,@BaseFiscalYear,@BaseSerialNo,0,0,0,0,0,0)
				where (@AcntCode IS NULL OR AcntCode = @AcntCode) 
						AND  SerialNo=@BaseSerialNo 
						AND  DocDate<=@DocDate 
						AND ConfirmQuantity>0
						AND DocStep=2
		) A
		inner join cmr.tblOrderDtl O on  A.ProcessID=O.ProcessID And A.ProcessNo=O.ProcessNo And A.FiscalYear=O.FiscalYear And A.SerialNo=O.SerialNo And A.DocRowNo=O.DocRowNo
		WHERE IsCodeClosed = 0

END

ELSE IF @BaseProcessID = 170 -- رسید موقت
SELECT *, 0 DiscountDtl,0 TaxOverWorthCostDtl,0 TollOverWorthCostDtl FROM (
				SELECT DISTINCT	acc.funIsCodeClosed(AcntCode) IsCodeClosed,ProcessID, ProcessNo, FiscalYear, SerialNo, DocRowNo RowNo, DocRowNo,
			DocStep, DocDate, --StoreID,
			 AcntCode, GoodsID, SubUnitID,ConfirmQuantity SubUnitQuantity, 
			[inv].[funGetGoodsQuantityFromSubUnit](GoodsID, SubUnitID,ConfirmQuantity) GoodsQuantity, 
			ConfirmQuantity,DescDtl,DocDesc  , BaseProcessID, BaseProcessNo, BaseFiscalYear, BaseSerialNo, BaseDocRowNo,
			[inv].[funGetTechnicalSpecifications](GoodsID) AS TechnicalSpecifications,Recognition,PenaltyPercent,
			CASE ISNULL(Recognition,'-1')  WHEN 0 THEN 'انتخاب نشده' WHEN 1 THEN 'تایید' WHEN 2 THEN 'تایید مشروط' WHEN 3 THEN 'تایید ارفاقی' WHEN 4 THEN 'عدم تایید' ELSE '' END RecognitionD ,
			pub.funGetGoodsName(GoodsID,@LanguageID) AS GoodsName,inv.funGetUnitName(SubUnitID,@LanguageID) AS SubUnitName
			,ExtraField1, ExtraField2, ExtraField3, ExtraField4, ExtraField5
			--, ConstText1, ConstText2, ConstText3, ConstText4
			,GoodsPrice  ,GoodsPrice  SubUnitPrice,StoreID,BatchNo,TransporterID2
			from cmr.FunCmrGoodsQtyRemain(@BaseProcessID,@ProcessNo  ,@BaseFiscalYear,@BaseSerialNo,0,0,0,0,0,0)
				where  --(@AcntCode IS NULL OR AcntCode = @AcntCode) AND
						 (DocDate<=@DocDate or @Buy_DontCheckDateConvertTempReceiptToBuy='True') 
						AND ConfirmQuantity>0
						AND DocStep=2
						and Recognition NOT IN (0, 4)
				) A WHERE IsCodeClosed = 0
		
ELSE IF @BaseProcessID = 56 -- باسکول خرید
SELECT *, 0 DiscountDtl, 0 TaxOverWorthCostDtl, 0 TollOverWorthCostDtl
FROM (
	  SELECT D.*,H.DriverID, H.AcntCode, pub.funGetGoodsName(D.GoodsID,@LanguageID) AS GoodsName, 
			 H.DocDate, inv.funGetUnitName(D.SubUnitID, @LanguageID) AS SubUnitName, 
			 [inv].[funGetTechnicalSpecifications](D.GoodsID) AS TechnicalSpecifications, 
    		 [inv].[funGetGoodsQuantityFromSubUnit](D.GoodsID, D.SubUnitID,D.SubUnitQuantity ) GoodsQuantity, 
			 D.SubUnitQuantity As ConfirmQuantity, D.SubUnitQuantity SubUnitQuantity1, D.Fee GoodsPrice,
			 D.Fee SubUnitPrice, H.TransportationCost, acc.funIsCodeClosed(H.AcntCode) IsCodeClosed
	  FROM 
	  (
			SELECT ProcessID, 0 ProcessNo, 0 FiscalYear, SerialNo
			FROM inv.tblBaskulSalesHdr H
			WHERE ProcessID = @BaseProcessID and Step=4
			EXCEPT
			SELECT BaseProcessID, 0 BaseProcessNo, 0 BaseFiscalYear, BaseSerialNo
			FROM inv.tblStorageDocsHdr 
			WHERE ProcessID = 55 And BaseProcessID = @BaseProcessID	  
	  ) H1
	  INNER JOIN inv.tblBaskulSalesHdr H ON H.ProcessID = H1.ProcessID And H.SerialNo = H1.SerialNo
	  INNER JOIN inv.tblBaskulSalesDtl D ON H.ProcessID = D.ProcessID And H.SerialNo = D.SerialNo
	  WHERE H.ProcessID = @ProcessID And H.SerialNo = @BaseSerialNo
	 ) A WHERE IsCodeClosed = 0
		
ELSE IF @BaseProcessID=180 -- سفارش فروش

SELECT * FROM (
	SELECT DISTINCT	acc.funIsCodeClosed(OD.AcntCode) IsCodeClosed,OD.ProcessID, OD.ProcessNo, OD.FiscalYear, OD.SerialNo, OD.RowNo, OD.DocRowNo,
			OD.DocStep, OD.DocDate, OD.AcntCode, OD.GoodsID, OD.SubUnitID, OD.SubUnitQuantity, 
			[inv].[funGetGoodsQuantityFromSubUnit](OD.GoodsID, OD.SubUnitID,CMRSaleOrderHdr.ConfirmQuantity) GoodsQuantity, 
			CMRSaleOrderHdr.ConfirmQuantity, OD.DescDtl, SubUnitPrice,
			OD.BaseProcessID, OD.BaseProcessNo, OD.BaseFiscalYear,OD.BaseSerialNo, OD.BaseDocRowNo,
			CMRSaleOrderHdr.TransportationCostAcntCode, CMRSaleOrderHdr.TransportationCost, CMRSaleOrderHdr.TransportationIncomeAcntCode, 
			CMRSaleOrderHdr.TransportationIncome, CMRSaleOrderHdr.VisitorAcntCodeHdr, CMRSaleOrderHdr.HdrVisitorPercent, 
			CMRSaleOrderHdr.VisitorCost, CMRSaleOrderHdr.PackingCost, CMRSaleOrderHdr.TaxCost, CMRSaleOrderHdr.TaxOverWorthCost, 
			CMRSaleOrderHdr.TollOverWorthCost, CMRSaleOrderHdr.OtherCostAcntCode, CMRSaleOrderHdr.OtherCost, 
			CMRSaleOrderHdr.OtherIncomeAcntCode, CMRSaleOrderHdr.OtherIncome,
			[inv].[funGetTechnicalSpecifications](OD.GoodsID) AS TechnicalSpecifications,
			pub.funGetGoodsName(OD.GoodsID,@LanguageID) AS GoodsName,inv.funGetUnitName(OD.SubUnitID,@LanguageID) AS SubUnitName,
			ExtraField1,ExtraField2,ExtraField3,ExtraField4,ExtraField5,OD.ConstText1,OD.ConstText2,OD.ConstText3,OD.ConstText4
	FROM	
		(
			Select	ProcessID, ProcessNo, FiscalYear, SerialNo, DocRowNo, DocDate, ConfirmQuantity,
					TransportationCostAcntCode, TransportationCost, TransportationIncomeAcntCode, TransportationIncome, 
					VisitorAcntCodeHdr, HdrVisitorPercent, VisitorCost, PackingCost, TaxCost, 
					TaxOverWorthCost, TollOverWorthCost, OtherCostAcntCode, OtherCost, OtherIncomeAcntCode, OtherIncome			
			FROM  [cmr].[FunGetSaleOrder](@AcntCode,@DocDate,@DocStep,@SalRet_RetToSalOdr,@BaseFiscalYear,@BaseSerialNo) 
		) CMRSaleOrderHdr
		INNER JOIN
		sal.tblSaleOrderDtl OD
		ON	OD.ProcessID = CMRSaleOrderHdr.ProcessID AND  OD.ProcessNo = CMRSaleOrderHdr.ProcessNo AND 
			OD.FiscalYear = CMRSaleOrderHdr.FiscalYear AND OD.SerialNo = CMRSaleOrderHdr.SerialNo AND 
			OD.DocRowNo = CMRSaleOrderHdr.DocRowNo 
   		INNER JOIN
		(SELECT GoodsID,ExtraField1,ExtraField2,ExtraField3,ExtraField4,ExtraField5  FROM inv.tblGoods WHERE CodeClosed = 'False'  AND PartNumber = @UnitPart  ) G
		ON SUBSTRING(OD.GoodsID,@str_Goods+1,@str_GoodsSum) = G.GoodsID 		
		WHERE	OD.ProcessID=@ProcessID AND OD.FiscalYear=@BaseFiscalYear AND OD.SerialNo=@BaseSerialNo AND 
			   (@AcntCode IS NULL OR AcntCode = @AcntCode) AND OD.DocDate<=@DocDate AND CMRSaleOrderHdr.ConfirmQuantity>0
) A WHERE IsCodeClosed = 0

ELSE IF @ProcessID = 240 -- پیش فاکتور
	IF @PreSal_GetRemain = 'False'
		SELECT * FROM (
		SELECT  acc.funIsCodeClosed(OD.AcntCode) IsCodeClosed,  OD.ProcessID, OD.ProcessNo, OD.FiscalYear, OD.SerialNo, OD.RowNo, OD.DocRowNo,OD.GoodsAmount AS GoodsPrice,OD.GoodsAmount SubUnitPrice,
				1 DocStep, OD.DocDate, OD.AcntCode, OD.GoodsID, pub.funGetGoodsUnitID(OD.GoodsID) as SubUnitID, 
				CMRSaleOrderHdr.ConfirmQuantity AS SubUnitQuantity,
				[inv].[funGetGoodsQuantityFromSubUnit](OD.GoodsID, OD.SubUnitID,CMRSaleOrderHdr.ConfirmQuantity) GoodsQuantity, 
				 CMRSaleOrderHdr.ConfirmQuantity,
				[inv].[funGetTechnicalSpecifications](OD.GoodsID) AS TechnicalSpecifications,OH.DiscountPercent,OH.Discount,OH.Discount2,
				TransportationCostAcntCode,TransportationCost,TransportationIncomeAcntCode,TransportationIncome,
				OH.VisitorAcntCode ,OH.VisitorPercent ,VisitorCost,PackingCost,TaxCost,TaxOverWorthCost,TollOverWorthCost,
				OtherCostAcntCode,OtherCost,OtherIncomeAcntCode,OtherIncome,CurrencyTypeID, CurrencyRate, OD.CurrencyAmount,
				OD.VisitorPercent VisitorPercentDtl, OD.VisitorAcntCode VisitorAcntCodeDtl,
				pub.funGetGoodsName(OD.GoodsID,@LanguageID) AS GoodsName,pub.funGetGoodsUnitName(OD.GoodsID,@LanguageID) AS SubUnitName  ,
				[inv].[funGetGoodsRemain](null,null,null,null,null,@StoreID,OD.GoodsID,'',@DocDate,0) GoodsRemain,
				ExtraField1,ExtraField2,ExtraField3,ExtraField4,ExtraField5,OD.ConstText1,OD.ConstText2,OD.ConstText3,OD.ConstText4
		FROM	
			(
			Select	CmrCnf.ProcessID , CmrCnf.ProcessNo , CmrCnf.FiscalYear , CmrCnf.SerialNo , CmrCnf.DocRowNo,CmrCnf.DocDate,
					CmrCnf.ConfirmQuantity  AS ConfirmQuantity  
			From
				 (
					SELECT DISTINCT *
					FROM  [inv].[FunGetPreSale](@AcntCode,@DocDate,@DocStep1) 
					WHERE ProcessNo = @ProcessNo			
				) CmrCnf 
			INNER JOIN 
				(
					SELECT DISTINCT ProcessID,ProcessNo,FiscalYear,SerialNo
					FROM  [inv].[FunGetPreSale](@AcntCode,@DocDate,@DocStep1) 
				Except 
					(
					Select	DISTINCT BaseProcessID , BaseProcessNo , BaseFiscalYear , BaseSerialNo 
					From  [cmr].[FunGetBaseSaleGoods](@AcntCode,@DocDate,0,1,@SerialNo,@FiscalYear)  
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
			(SELECT GoodsID,ExtraField1,ExtraField2,ExtraField3,ExtraField4,ExtraField5 FROM inv.tblGoods WHERE CodeClosed = 'False'  AND PartNumber = @UnitPart  ) G
			ON SUBSTRING(OD.GoodsID,@str_Goods+1,@str_GoodsSum) = G.GoodsID 
			WHERE	OD.ProcessID=@ProcessID AND OD.ProcessNo=@ProcessNo AND OD.FiscalYear=@BaseFiscalYear AND OD.SerialNo=@BaseSerialNo AND 
				   (@AcntCode IS NULL OR OD.AcntCode = @AcntCode) AND OD.DocDate<= @DocDate  AND CMRSaleOrderHdr.ConfirmQuantity>0 
		) A WHERE IsCodeClosed = 0		 	 
	ELSE
		SELECT * FROM (
				SELECT  acc.funIsCodeClosed(OD.AcntCode) IsCodeClosed,  OD.ProcessID, OD.ProcessNo, OD.FiscalYear, OD.SerialNo, OD.RowNo, OD.DocRowNo,OD.GoodsAmount AS GoodsPrice,
						1 DocStep, OD.DocDate, OD.AcntCode, OD.GoodsID, OH.PayOffTypeID, pub.funGetGoodsUnitID(OD.GoodsID) as SubUnitID, 
						CMRSaleOrderHdr.ConfirmQuantity AS SubUnitQuantity, CMRSaleOrderHdr.ConfirmQuantity,OD.StoreID,
						[inv].[funGetTechnicalSpecifications](OD.GoodsID) AS TechnicalSpecifications,OH.DiscountPercent,
				        [inv].[funGetGoodsQuantityFromSubUnit](OD.GoodsID, OD.SubUnitID,CMRSaleOrderHdr.ConfirmQuantity) GoodsQuantity, 
						OH.Discount, OH.Discount2, OD.DiscountPercent As DiscountPercentDtl, OD.Discount as DiscountDtl,
						OD.SaleTypeID As DtlSaleTypeID,OD.ConstText1,OD.ConstText2, OD.ConstText3,OD.ConstText4,OH.HasNoReward,OH.HasNoDiscountDtl, OH.TransporterID, IsNull(OH.LocationID,'') As LocationID, 
						OH.SaleTypeID, TransportationCostAcntCode,TransportationCost,TransportationIncomeAcntCode,TransportationIncome,
						OH.VisitorAcntCode VisitorAcntCodeHdr, OH.VisitorPercent VisitorPercentHdr, VisitorCost, PackingCost, TaxCost, 
						TaxOverWorthCost,TollOverWorthCost,	OH.VisitorAcntCode2 VisitorAcntCodeHdr2, OH.VisitorPercent2 VisitorPercentHdr2, 
						OH.VisitorCost2, OD.VisitorAcntCode2, OD.VisitorPercent2, OD.VisitorAcntCode, OD.VisitorPercent, OtherCostAcntCode, 
						OtherCost, OtherIncomeAcntCode, OtherIncome, pub.funGetGoodsName(OD.GoodsID,@LanguageID) AS GoodsName,
						pub.funGetGoodsUnitName(OD.GoodsID,@LanguageID) AS SubUnitName,	
						[inv].[funGetGoodsRemain](null,null,null,null,null,@StoreID,OD.GoodsID,'',@DocDate,0) GoodsRemain,
						OH.CurrencyTypeID, OH.CurrencyRate, OD.CurrencyAmount,OH.CurrencyDiscount
				FROM	
					(
						
					SELECT	DISTINCT Cnf.ProcessID , Cnf.ProcessNo , Cnf.FiscalYear , Cnf.SerialNo , Cnf.DocRowNo ,DocDate
							,Cnf.GoodsQuantity - ISNULL(sd.ConfirmQuantity,0) AS ConfirmQuantity
					FROM	inv.tblPreSaleDtl Cnf	
					LEFT JOIN (
							Select BaseProcessID , BaseProcessNo , BaseFiscalYear , BaseSerialNo , BaseDocRowNo,Sum(GoodsQuantity) ConfirmQuantity 
							From inv.tblStorageDocsDtl
							Where BaseProcessID = 240 AND DocStep =@DocStep AND
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
				Inner Join (SELECT ProcessID,ProcessNo,FiscalYear,SerialNo from inv.tblPreSaleHdr 
							except	
							SELECT BaseProcessID,BaseProcessNo,BaseFiscalYear,BaseSerialNo from sal.tblSaleOrderDtl where ProcessID=180 and BaseProcessID=240
							)S
				ON OH.ProcessID = S.ProcessID AND OH.ProcessNo = S.ProcessNo AND OH.FiscalYear = S.FiscalYear AND OH.SerialNo = S.SerialNo
				INNER JOIN
				(SELECT GoodsID FROM inv.tblGoods WHERE CodeClosed = 'False' AND PartNumber = @UnitPart ) G
				ON SUBSTRING(OD.GoodsID,@str_Goods+1,@str_GoodsSum) = G.GoodsID 
				WHERE	OD.ProcessID=@ProcessID AND OD.FiscalYear=@BaseFiscalYear AND OD.SerialNo=@BaseSerialNo AND --OD.ProcessNo=@ProcessNo AND  
					   (@AcntCode IS NULL OR OD.AcntCode = @AcntCode) AND OD.DocDate<= @DocDate  AND CMRSaleOrderHdr.ConfirmQuantity>0 
		) A WHERE IsCodeClosed = 0	


ELSE IF @BaseProcessID = 55 -- خرید
SELECT * FROM (
	SELECT DISTINCT	acc.funIsCodeClosed(OD.AcntCode) IsCodeClosed,OD.ProcessID, OD.ProcessNo, OD.FiscalYear, OD.SerialNo, OD.RowNo, OD.VolumeRowNo, OD.DocStep, 
			OD.DocDate, DfStoreID As StoreID, OD.EnterKind, OD.StoreID2, OD.AcntCode, OD.VisitorAcntCode, OD.BatchNo,
			OD.OrderAcntCode, OD.GoodsID, UnitID, SubUnitID, SubUnitQuantity,
			Cn.ConfirmQuantity GoodsQuantity, 
			Cn.ConfirmQuantity, OD.QtyRemain, 
			0 GoodsAmount, OD.AtomAmount, OD.GoodsPrice,OD.SubUnitPrice,OD.SubUnitPrice2, OD.DescDtl, OD.BaseProcessID, 
			OD.BaseProcessNo, OD.BaseFiscalYear, OD.BaseSerialNo, OD.BaseDocRowNo, OD.AgreeNo, OD.DocRowNo,
			OD.TaxOverWorthCostDtl, OD.TollOverWorthCostDtl,
			[inv].[funGetTechnicalSpecifications](OD.GoodsID) AS TechnicalSpecifications,
			pub.funGetGoodsName(OD.GoodsID,@LanguageID) AS GoodsName, inv.funGetUnitName(SubUnitID,@LanguageID) AS SubUnitName,
			
			inv.funGetGoodsSubQuantity(OD.GoodsID,OD.SubUnitID,([inv].[funGetMaxGoodsRemain](OD.ProcessID,OD.ProcessNo,OD.FiscalYear,
									   OD.SerialNo,OD.ProcessID,OD.ProcessNo,OD.FiscalYear,OD.SerialNo,OD.DocRowNo,@StoreID,OD.GoodsID,
									   OD.BatchNo,OD.DocDate,1))) AS Remain,
			
			inv.funGetGoodsSubQuantity(OD.GoodsID,OD.SubUnitID,([inv].[funGetGoodsRemain](null,null,null,null,null,
									   CASE WHEN  @buy_StoreDtl = 'True' THEN DfStoreID ELSE @StoreID END,OD.GoodsID,OD.BatchNo,@DocDate,
									   OD.UserPriceID))) GoodsRemain, 									   
			G.ExtraField1, ExtraField2, ExtraField3, ExtraField4, ExtraField5,
			OD.DiscountPercentDtl,(DiscountDtl * Cn.ConfirmQuantity )/OD.GoodsQuantity as DiscountDtl,
			OH.DiscountPercent DiscountPercentHdr, OH.Discount DiscountHdr, OH.Discount2+OH.Discount3 Discount2Hdr,
			OH.TaxOverWorthCost, OH.TollOverWorthCost, OH.TotalLineDiscount,
			OD.ConstText1, OD.ConstText2, OD.ConstText3, OD.ConstText4,				
			IsNull((Select UParams From inv.tblGoodsUserPrice P Where P.ID = OD.UserPriceID) ,'') As UserPrice,OD.UserPriceID
	FROM inv.tblStorageDocsDtl OD
		INNER JOIN inv.tblStorageDocsHdr OH ON OH.ProcessID = OD.ProcessID And OH.ProcessNo = OD.ProcessNo And
										   OH.FiscalYear = OD.FiscalYear And OH.SerialNo = OD.SerialNo
		INNER JOIN
		(
			Select	Cnf.ProcessID , Cnf.ProcessNo , Cnf.FiscalYear , Cnf.SerialNo,Cnf.DocRowNo,
					Cnf.GoodsQuantity - ISNULL(Rtn.GoodsQuantity,0) ConfirmQuantity
			From
				(
					Select	ProcessID ,ProcessNo , FiscalYear , SerialNo , 
							DocRowNo , GoodsQuantity
					From inv.tblStorageDocsDtl 
					Where ProcessID = 55 AND ProcessNo=@ProcessNo AND 
						  (@AcntCode IS NULL OR AcntCode = @AcntCode) AND DocDate <= @DocDate AND --DocStep in (0,2) 
						  DocStep>=@BuyDocStep
				) Cnf
			LEFT JOIN 
			(
				Select	BaseProcessID , BaseProcessNo , BaseFiscalYear , BaseSerialNo , 
						BaseDocRowNo , Sum(GoodsQuantity) GoodsQuantity
				From inv.tblStorageDocsDtl 
				Where BaseProcessID = 55 AND ProcessNo=@ProcessNo AND (@AcntCode IS NULL OR AcntCode = @AcntCode) 
				Group BY BaseProcessID , BaseProcessNo , BaseFiscalYear , 
						 BaseSerialNo , BaseDocRowNo
			) Rtn
			ON	Cnf.ProcessID = Rtn.BaseProcessID AND Cnf.ProcessNo = Rtn.BaseProcessNo AND 
				Cnf.FiscalYear = Rtn.BaseFiscalYear AND Cnf.SerialNo = Rtn.BaseSerialNo AND 
				Cnf.DocRowNo = Rtn.BaseDocRowNo
		) Cn ON Cn.ProcessID = OD.ProcessID AND Cn.ProcessNo = OD.ProcessNo AND 
				Cn.FiscalYear = OD.FiscalYear AND Cn.SerialNo = OD.SerialNo AND 
				Cn.DocRowNo = OD.DocRowNo 
	INNER JOIN
	(
	 SELECT GoodsID, ExtraField1, ExtraField2, ExtraField3, ExtraField4, ExtraField5, DfStoreID, UnitID  
	 FROM inv.tblGoods 
	 WHERE CodeClosed = 'False' AND PartNumber = @UnitPart) G
	ON SUBSTRING(OD.GoodsID,@str_Goods+1,@str_GoodsSum) = G.GoodsID 				
	WHERE Cn.SerialNo = @BaseSerialNo AND Cn.FiscalYear = @BaseFiscalYear AND 
		 (@AcntCode IS NULL OR OD.AcntCode   = @AcntCode) AND OD.DocDate<=@DocDate AND 
		  Cn.ConfirmQuantity>0
) A WHERE IsCodeClosed = 0

ELSE IF  @ProcessID = 230 -- مصرف داخلی
begin
	DECLARE @ConfirmCountInUseRequest AS  TinyInt=0;
			SELECT @ConfirmCountInUseRequest = SettingValue
			FROM pub.tblSettings
			WHERE SettingKey = 'ConfirmCountInUseRequest'
	set @ConfirmCountInUseRequest=ISnull(@ConfirmCountInUseRequest,0)
SELECT * FROM (
	SELECT DISTINCT	acc.funIsCodeClosed(OD.AcntCode) IsCodeClosed,OD.ProcessID, OD.ProcessNo, OD.FiscalYear, OD.SerialNo, OD.RowNo, 
				OD.DocStep, OD.AcntCode As RequestAcntCode, OD.DocDate, OD.GoodsID, OD.SubUnitID, 
				SUBSTRING(OD.AcntCode,@StartAcnt,@LenAcnt) CustomerCode, acc.funGetAcntName(SUBSTRING(OD.AcntCode,@StartAcnt,@LenAcnt),@PartNo, 1) AS CustomerName,
				CMROrderHdr.ConfirmQuantity GoodsQuantity, 
				[inv].[funGetSubUnitFromGoodsQuantity](OD.GoodsID, OD.SubUnitID,CMROrderHdr.ConfirmQuantity) SubUnitQuantity, 
				CMROrderHdr.ConfirmQuantity,
				OD.DescDtl, OD.BaseProcessID,OD.BaseProcessNo, OD.BaseFiscalYear, OD.BaseSerialNo, OD.BaseDocRowNo, OD.DocRowNo,
				pub.funGetGoodsName(OD.GoodsID,@LanguageID) AS GoodsName, inv.funGetUnitName(SubUnitID,@LanguageID) AS SubUnitName,
				[inv].[funGetTechnicalSpecifications](OD.GoodsID) AS TechnicalSpecifications,
				[inv].[funGetGoodsRemain](null,null,null,null,null,@StoreID,OD.GoodsID,'',@DocDate,0) GoodsRemain,
				[inv].[funGetMaxGoodsRemain](OD.ProcessID,OD.ProcessNo,OD.FiscalYear,OD.SerialNo,OD.ProcessID,OD.ProcessNo,
				OD.FiscalYear,OD.SerialNo,OD.DocRowNo,@StoreID,OD.GoodsID,'',@DocDate,1)  AS Remain,
				ExtraField1, ExtraField2, ExtraField3, ExtraField4, ExtraField5, OD.StoreID,OD.AcntCode2,DocDesc,
				[inv].[funGetTechnicalNo](OD.GoodsID) AS TechnicalNo
		FROM	
			(
				Select	CmrCnf.ProcessID , CmrCnf.ProcessNo , CmrCnf.FiscalYear , CmrCnf.SerialNo , CmrCnf.DocRowNo,
						CmrCnf.ConfirmQuantity - ISNULL(StorageDocs.ConfirmQuantity,0) AS ConfirmQuantity  
				From
				(
					Select	A.ProcessID , A.ProcessNo , A.FiscalYear , A.SerialNo,A.DocRowNo,A.DocDate,A.GoodsQuantity- ISNULL(B.GoodsQuantity,0) as ConfirmQuantity
					FROM  inv.tblStoresRequestsDtl A
					LEFT JOIN  inv.tblStoresRequestsDtl B
					ON A.ProcessID = B.BaseProcessID AND A.ProcessNo = B.BaseProcessNo AND  A.FiscalYear = B.BaseFiscalYear AND 
    				   A.SerialNo  = B.BaseSerialNo AND  A.DocRowNo  = B.BaseDocRowNo AND A.GoodsQuantity - ISNULL(B.GoodsQuantity,0)>0 
					WHERE A.ProcessID = 230
				) CmrCnf 
			LEFT JOIN 
				(
					Select	BaseProcessID , BaseProcessNo , BaseFiscalYear , BaseSerialNo , BaseDocRowNo ,ConfirmQuantity 
					From [cmr].[FunGetBaseStorageDocsGoodsUse](@AcntCode,@DocDate) 
				) StorageDocs
				ON CmrCnf.ProcessID  = StorageDocs.BaseProcessID  AND  CmrCnf.ProcessNo = StorageDocs.BaseProcessNo AND 
				   CmrCnf.FiscalYear = StorageDocs.BaseFiscalYear AND CmrCnf.SerialNo   = StorageDocs.BaseSerialNo  AND 
				   CmrCnf.DocRowNo   = StorageDocs.BaseDocRowNo  AND CmrCnf.DocDate<=@DocDate 
			) CMROrderHdr
		INNER JOIN
		inv.tblStoresRequestsDtl OD
		ON OD.ProcessID = CMROrderHdr.ProcessID AND  OD.ProcessNo = CMROrderHdr.ProcessNo AND 
		   OD.FiscalYear = CMROrderHdr.FiscalYear AND OD.SerialNo = CMROrderHdr.SerialNo AND 
		   OD.DocRowNo = CMROrderHdr.DocRowNo 
		  	INNER JOIN
		inv.tblStoresRequestsHdr ODH
		ON ODH.ProcessID = CMROrderHdr.ProcessID AND  ODH.ProcessNo = CMROrderHdr.ProcessNo AND 
		   ODH.FiscalYear = CMROrderHdr.FiscalYear AND ODH.SerialNo = CMROrderHdr.SerialNo  
   		INNER JOIN
		(SELECT GoodsID,ExtraField1,ExtraField2,ExtraField3,ExtraField4,ExtraField5  FROM inv.tblGoods WHERE CodeClosed = 'False'  AND PartNumber = @UnitPart  ) G
		ON SUBSTRING(OD.GoodsID,@str_Goods+1,@str_GoodsSum) = G.GoodsID 			   
		WHERE (@AcntCode IS NULL OR OD.AcntCode = @AcntCode) AND OD.DocDate<=@DocDate AND CMROrderHdr.ConfirmQuantity>0 AND 
			  (@BaseSerialNo IS NULL OR (OD.SerialNo=@BaseSerialNo AND OD.FiscalYear=@BaseFiscalYear)) 
	And ((@ConfirmCountInUseRequest = 0)
			OR (@ConfirmCountInUseRequest = 1 AND SgnSN1 <> 0)
			OR (@ConfirmCountInUseRequest = 2 AND SgnSN1 <> 0 AND SgnSN2 <> 0)
			OR (@ConfirmCountInUseRequest = 3 AND SgnSN1 <> 0 AND SgnSN2 <> 0 AND SgnSN3 <> 0)
			OR (@ConfirmCountInUseRequest = 4 AND SgnSN1 <> 0 AND SgnSN2 <> 0 AND SgnSN3 <> 0 AND SgnSN4 <> 0)
			OR (@ConfirmCountInUseRequest = 5 AND SgnSN1 <> 0 AND SgnSN2 <> 0 AND SgnSN3 <> 0 AND SgnSN4 <> 0 AND SgnSN5 <> 0)
		)
) A WHERE IsCodeClosed = 0
end 
ELSE IF @BaseProcessID = 127 -- درخواست انتقال بین انبارها
BEGIN
	DECLARE @ConfirmCountInTransferRequest AS  TinyInt=0;
			SELECT @ConfirmCountInTransferRequest = SettingValue
			FROM pub.tblSettings
			WHERE SettingKey = 'ConfirmCountInTransferRequest'
	SELECT * FROM (
		SELECT DISTINCT	acc.funIsCodeClosed(OD.AcntCode) IsCodeClosed,OD.ProcessID, OD.ProcessNo, OD.FiscalYear, OD.SerialNo, OD.RowNo, 
					OD.DocStep, AcntCode As RequestAcntCode, OD.DocDate, OD.GoodsID, OD.SubUnitID, OD.SubUnitQuantity SubUnitQuantity1, 
					[inv].[funGetSubUnitFromGoodsQuantity](OD.GoodsID, OD.SubUnitID,CMROrderHdr.ConfirmQuantity) SubUnitQuantity, 
					CMROrderHdr.ConfirmQuantity GoodsQuantity,CMROrderHdr.ConfirmQuantity, OD.DescDtl, CMROrderHdr.DocDesc, OD.BaseProcessID,
					OD.BaseProcessNo, OD.BaseFiscalYear, OD.BaseSerialNo, OD.BaseDocRowNo, OD.DocRowNo, OD.UserPriceID, 
					pub.funGetGoodsName(OD.GoodsID,@LanguageID) AS GoodsName, inv.funGetUnitName(SubUnitID,@LanguageID) AS SubUnitName,
					IsNull((Select UParams From inv.tblGoodsUserPrice P Where P.ID = OD.UserPriceID) ,'') As UserPrice,
					[inv].[funGetTechnicalSpecifications](OD.GoodsID) AS TechnicalSpecifications, CMROrderHdr.IntTrnTypID,
					[inv].[funGetGoodsRemain](null,null,null,null,null,@StoreID,OD.GoodsID,'',@DocDate,0) GoodsRemain,
					[inv].[funGetMaxGoodsRemain](OD.ProcessID,OD.ProcessNo,OD.FiscalYear,OD.SerialNo,OD.ProcessID,OD.ProcessNo,
					OD.FiscalYear,OD.SerialNo,OD.DocRowNo,@StoreID,OD.GoodsID,'',@DocDate,1)  AS Remain,
					ExtraField1, ExtraField2, ExtraField3, ExtraField4, ExtraField5, OD.StoreID, OD.StoreID2,
					OD.BatchNo, OD.GoodsWeight, OD.WeightQty, G.UserPrice UserPriceL, IsNull(U.ID, 0) UserPriceIDL,
					OD.TaskFiscalYear, OD.TaskSerialNo,OD.BaseTaskFiscalYear, OD.BaseTaskSerialNo, SgnSN1, SgnSN2, SgnSN3, SgnSN4, SgnSN5
			FROM	
				(
					Select	CmrCnf.ProcessID , CmrCnf.ProcessNo , CmrCnf.FiscalYear , CmrCnf.SerialNo , CmrCnf.DocRowNo,
							CmrCnf.ConfirmQuantity - ISNULL(StorageDocs.ConfirmQuantity,0) AS ConfirmQuantity, CmrCnf.DocDesc,
							CmrCnf.IntTrnTypID, CmrCnf.SgnSN1, CmrCnf.SgnSN2, CmrCnf.SgnSN3, CmrCnf.SgnSN4, CmrCnf.SgnSN5
					From
					(
						Select	A.ProcessID, A.ProcessNo, A.FiscalYear, A.SerialNo, A.DocRowNo, A.DocDate, H.DocDesc,
								H.IntTrnTypID, A.GoodsQuantity - ISNULL(B.GoodsQuantity,0) As ConfirmQuantity, SgnSN1, SgnSN2, SgnSN3, SgnSN4, SgnSN5
						FROM  inv.tblStoresRequestsDtl A
						INNER JOIN inv.tblStoresRequestsHdr H ON A.ProcessID = H.ProcessID AND A.ProcessNo = H.ProcessNo AND 
															  A.FiscalYear = H.FiscalYear AND A.SerialNo  = H.SerialNo
						LEFT  JOIN  ( Select BaseProcessID , BaseProcessNo , BaseFiscalYear , BaseSerialNo , BaseDocRowNo,Sum(GoodsQuantity) GoodsQuantity From inv.tblStoresRequestsDtl 
					group by  BaseProcessID , BaseProcessNo , BaseFiscalYear , BaseSerialNo , BaseDocRowNo)B
						ON A.ProcessID = B.BaseProcessID AND A.ProcessNo = B.BaseProcessNo AND A.FiscalYear = B.BaseFiscalYear AND 
	    				   A.SerialNo  = B.BaseSerialNo AND A.DocRowNo  = B.BaseDocRowNo 
						WHERE A.ProcessID = 127 AND  A.ProcessNo = @ProcessNo AND A.GoodsQuantity - ISNULL(B.GoodsQuantity,0)>0  
						
					) CmrCnf 
				LEFT JOIN 
					(
						Select	BaseProcessID , BaseProcessNo , BaseFiscalYear , BaseSerialNo , BaseDocRowNo ,ConfirmQuantity 
						From [inv].[FunGetBaseStorageDocsStoreTransfer](@AcntCode,@DocDate)
						where BaseProcessNo = @ProcessNo
					) StorageDocs
					ON CmrCnf.ProcessID  = StorageDocs.BaseProcessID  AND  CmrCnf.ProcessNo = StorageDocs.BaseProcessNo AND 
					   CmrCnf.FiscalYear = StorageDocs.BaseFiscalYear AND CmrCnf.SerialNo   = StorageDocs.BaseSerialNo  AND 
					   CmrCnf.DocRowNo   = StorageDocs.BaseDocRowNo  AND CmrCnf.DocDate<=@DocDate 
				) CMROrderHdr
			INNER JOIN
			inv.tblStoresRequestsDtl OD	ON OD.ProcessID = CMROrderHdr.ProcessID AND  OD.ProcessNo = CMROrderHdr.ProcessNo AND 
										   OD.FiscalYear = CMROrderHdr.FiscalYear AND OD.SerialNo = CMROrderHdr.SerialNo AND 
										   OD.DocRowNo = CMROrderHdr.DocRowNo 
	   		INNER JOIN
			(
				 SELECT GoodsID,ExtraField1,ExtraField2,ExtraField3,ExtraField4,ExtraField5,UserPrice
				 FROM inv.tblGoods 
				 WHERE CodeClosed = 'False' AND PartNumber = @UnitPart
			 ) G ON SUBSTRING(OD.GoodsID,@str_Goods+1,@str_GoodsSum) = G.GoodsID
			
			LEFT JOIN inv.tblGoodsUserPrice U ON G.GoodsID = U.GoodsID And G.UserPrice = U.UserPrice	   
			
			WHERE (@AcntCode IS NULL OR AcntCode = @AcntCode) AND OD.DocDate <= @DocDate AND CMROrderHdr.ConfirmQuantity>0 AND 
				  (@BaseSerialNo IS NULL OR (OD.SerialNo=@BaseSerialNo AND OD.FiscalYear=@BaseFiscalYear)) 
	) A WHERE IsCodeClosed = 0
		AND ((SELECT COUNT(*) 
					FROM inv.tblUsersIOAccessDtl 
					WHERE StoreID=A.StoreID AND UserID=@UserID)=0 OR 
						 ISNULL((SELECT TOP 1  [Output] 
						  FROM inv.tblUsersIOAccessDtl 
						  WHERE StoreID=A.StoreID AND UserID=@UserID),'True')='True')
		And ((@ConfirmCountInTransferRequest = 0)
			OR (@ConfirmCountInTransferRequest = 1 AND SgnSN1 <> 0)
			OR (@ConfirmCountInTransferRequest = 2 AND SgnSN1 <> 0 AND SgnSN2 <> 0)
			OR (@ConfirmCountInTransferRequest = 3 AND SgnSN1 <> 0 AND SgnSN2 <> 0 AND SgnSN3 <> 0)
			OR (@ConfirmCountInTransferRequest = 4 AND SgnSN1 <> 0 AND SgnSN2 <> 0 AND SgnSN3 <> 0 AND SgnSN4 <> 0)
			OR (@ConfirmCountInTransferRequest = 5 AND SgnSN1 <> 0 AND SgnSN2 <> 0 AND SgnSN3 <> 0 AND SgnSN4 <> 0 AND SgnSN5 <> 0)
		)
	order by DocRowNo
END
ELSE IF @BaseProcessID = 100 and @ProcessID=110 -- برگه مصرف مواد اوليه يا كالا
SELECT OD.ProcessID, OD.ProcessNo, OD.FiscalYear, OD.SerialNo, OD.RowNo, OD.VolumeRowNo, OD.DocStep, 
			OD.DocDate, OD.StoreID, OD.EnterKind, OD.StoreID2, OD.AcntCode, OD.VisitorAcntCode, BatchNo,
			OD.OrderAcntCode, OD.GoodsID, OD.SubUnitID, OD.SubUnitQuantity, 
			[inv].[funGetGoodsQuantityFromSubUnit](OD.GoodsID, OD.SubUnitID,Cn.ConfirmQuantity) GoodsQuantity, 
			Cn.ConfirmQuantity, OD.QtyRemain, 
			OD.GoodsAmount, OD.AtomAmount, OD.GoodsPrice, OD.DescDtl, OD.BaseProcessID, SubUnitPrice,
			OD.BaseProcessNo, OD.BaseFiscalYear, OD.BaseSerialNo, OD.BaseDocRowNo, OD.AgreeNo, OD.DocRowNo,
			[inv].[funGetTechnicalSpecifications](OD.GoodsID) AS TechnicalSpecifications,
			pub.funGetGoodsName(OD.GoodsID,@LanguageID) AS GoodsName, inv.funGetUnitName(SubUnitID,@LanguageID) AS SubUnitName,
			[inv].[funGetMaxGoodsRemain](OD.ProcessID,OD.ProcessNo,OD.FiscalYear,OD.SerialNo,OD.ProcessID,OD.ProcessNo,
			OD.FiscalYear,OD.SerialNo,OD.DocRowNo,StoreID,OD.GoodsID,OD.BatchNo,DocDate,1)  AS GoodsRemain,
			ExtraField1,ExtraField2,ExtraField3,ExtraField4,ExtraField5 
			,IsNull((Select UParams From inv.tblGoodsUserPrice P Where P.ID = OD.UserPriceID) ,'') As UserPrice,OD.UserPriceID
	FROM inv.tblStorageDocsDtl OD 
		INNER JOIN
		(
			Select	Cnf.ProcessID , Cnf.ProcessNo , Cnf.FiscalYear , Cnf.SerialNo,Cnf.DocRowNo,
					Cnf.GoodsQuantity - ISNULL(Rtn.GoodsQuantity,0) ConfirmQuantity
			From
				(
					Select	ProcessID ,ProcessNo , FiscalYear , SerialNo , 
							DocRowNo , GoodsQuantity
					From inv.tblStorageDocsDtl 
					Where ProcessID = 100   AND ProcessNo = @ProcessNo AND 
						  DocDate <= @DocDate AND DocStep >=1
				) Cnf
			LEFT JOIN 
			(
				Select	BaseProcessID , BaseProcessNo , BaseFiscalYear , BaseSerialNo , 
						BaseDocRowNo , Sum(GoodsQuantity) GoodsQuantity
				From inv.tblStorageDocsDtl 
				Where BaseProcessID = 110 AND ProcessNo=@ProcessNo  
				Group BY BaseProcessID , BaseProcessNo , BaseFiscalYear , 
						 BaseSerialNo , BaseDocRowNo
			) Rtn
			ON	Cnf.ProcessID = Rtn.BaseProcessID AND Cnf.ProcessNo = Rtn.BaseProcessNo AND 
				Cnf.FiscalYear = Rtn.BaseFiscalYear AND Cnf.SerialNo = Rtn.BaseSerialNo AND 
				Cnf.DocRowNo = Rtn.BaseDocRowNo
		) Cn ON Cn.ProcessID = OD.ProcessID AND Cn.ProcessNo = OD.ProcessNo AND 
				Cn.FiscalYear = OD.FiscalYear AND Cn.SerialNo = OD.SerialNo AND 
				Cn.DocRowNo = OD.DocRowNo 
   	INNER JOIN
	(SELECT GoodsID,ExtraField1,ExtraField2,ExtraField3,ExtraField4,ExtraField5  FROM inv.tblGoods WHERE CodeClosed = 'False' AND PartNumber = @UnitPart ) G
	ON SUBSTRING(OD.GoodsID,@str_Goods+1,@str_GoodsSum) = G.GoodsID 				
	WHERE Cn.SerialNo = @BaseSerialNo AND Cn.FiscalYear = @BaseFiscalYear AND 
		 (@AcntCode IS NULL OR AcntCode = @AcntCode) AND DocDate<=@DocDate AND
		  Cn.ConfirmQuantity>0 
			  
ELSE IF @BaseProcessID = 110 -- برگه مصرف مواد اوليه يا كالا
begin
DECLARE @ConfirmCountInUse AS  TinyInt;
			SELECT @ConfirmCountInUse = SettingValue
			FROM pub.tblSettings
			WHERE SettingKey = 'ConfirmCountInUse'
SELECT * FROM (
	SELECT DISTINCT	acc.funIsCodeClosed(OD.AcntCode) IsCodeClosed,OD.ProcessID, OD.ProcessNo, OD.FiscalYear, OD.SerialNo, OD.RowNo, OD.VolumeRowNo, OD.DocStep, 
			OD.DocDate, OD.StoreID, OD.EnterKind, OD.StoreID2, OD.AcntCode, OD.VisitorAcntCode, OD.BatchNo,
			OD.OrderAcntCode, OD.GoodsID, OD.SubUnitID, OD.SubUnitQuantity,
			[inv].[funGetGoodsQuantityFromSubUnit](OD.GoodsID, OD.SubUnitID,Cn.ConfirmQuantity) GoodsQuantity, 
			 Cn.ConfirmQuantity, OD.QtyRemain, 
			OD.GoodsAmount, OD.AtomAmount, OD.GoodsPrice, OD.DescDtl, OD.BaseProcessID, SubUnitPrice,
			OD.BaseProcessNo, OD.BaseFiscalYear, OD.BaseSerialNo, OD.BaseDocRowNo, OD.AgreeNo, OD.DocRowNo,
			[inv].[funGetTechnicalSpecifications](OD.GoodsID) AS TechnicalSpecifications,
			pub.funGetGoodsName(OD.GoodsID,@LanguageID) AS GoodsName, inv.funGetUnitName(SubUnitID,@LanguageID) AS SubUnitName,
			[inv].[funGetMaxGoodsRemain](OD.ProcessID,OD.ProcessNo,OD.FiscalYear,OD.SerialNo,OD.ProcessID,OD.ProcessNo,
			OD.FiscalYear,OD.SerialNo,OD.DocRowNo,OD.StoreID,OD.GoodsID,OD.BatchNo,OD.DocDate,1)  AS GoodsRemain,
			G.ExtraField1,ExtraField2,ExtraField3,ExtraField4,ExtraField5 
			,SgnSN1,SgnSN2,SgnSN3,SgnSN4,SgnSN5
			,IsNull((Select UParams From inv.tblGoodsUserPrice P Where P.ID = OD.UserPriceID) ,'') As UserPrice,OD.UserPriceID	
	FROM inv.tblStorageDocsDtl OD 
			inner join inv.tblStorageDocsHdr H
					on  OD.ProcessID = H.ProcessID AND OD.ProcessNo = H.ProcessNo AND OD.FiscalYear = H.FiscalYear AND OD.SerialNo = H.SerialNo
		INNER JOIN
		(
			Select	Cnf.ProcessID , Cnf.ProcessNo , Cnf.FiscalYear , Cnf.SerialNo,Cnf.DocRowNo,
					Cnf.GoodsQuantity - ISNULL(Rtn.GoodsQuantity,0) ConfirmQuantity
			From
				(
					Select	ProcessID ,ProcessNo , FiscalYear , SerialNo , 
							DocRowNo , GoodsQuantity
					From inv.tblStorageDocsDtl 
					Where ProcessID = 110   AND ProcessNo = @ProcessNo AND 
						 (@AcntCode IS NULL OR AcntCode   = @AcntCode) AND 
						  DocDate <= @DocDate AND DocStep >=1
				) Cnf
			LEFT JOIN 
			(
				Select	BaseProcessID , BaseProcessNo , BaseFiscalYear , BaseSerialNo , 
						BaseDocRowNo , Sum(GoodsQuantity) GoodsQuantity
				From inv.tblStorageDocsDtl 
				Where BaseProcessID = 110 AND ProcessNo=@ProcessNo AND 
					 (@AcntCode IS NULL OR AcntCode   = @AcntCode)  
				Group BY BaseProcessID , BaseProcessNo , BaseFiscalYear , 
						 BaseSerialNo , BaseDocRowNo
			) Rtn
			ON	Cnf.ProcessID = Rtn.BaseProcessID AND Cnf.ProcessNo = Rtn.BaseProcessNo AND 
				Cnf.FiscalYear = Rtn.BaseFiscalYear AND Cnf.SerialNo = Rtn.BaseSerialNo AND 
				Cnf.DocRowNo = Rtn.BaseDocRowNo
		) Cn ON Cn.ProcessID = OD.ProcessID AND Cn.ProcessNo = OD.ProcessNo AND 
				Cn.FiscalYear = OD.FiscalYear AND Cn.SerialNo = OD.SerialNo AND 
				Cn.DocRowNo = OD.DocRowNo 
   	INNER JOIN
	(SELECT GoodsID,ExtraField1,ExtraField2,ExtraField3,ExtraField4,ExtraField5  FROM inv.tblGoods WHERE CodeClosed = 'False' AND PartNumber = @UnitPart ) G
	ON SUBSTRING(OD.GoodsID,@str_Goods+1,@str_GoodsSum) = G.GoodsID 				
	WHERE Cn.SerialNo = @BaseSerialNo AND Cn.FiscalYear = @BaseFiscalYear AND 
		 (@AcntCode IS NULL OR OD.AcntCode = @AcntCode) AND OD.DocDate<=@DocDate AND
		  Cn.ConfirmQuantity>0 
) A WHERE IsCodeClosed = 0 AND (@OneStep='True' OR (@OneStep='False' AND A.DocStep>2) )
And 	((@ConfirmCountInUse = 0)
			OR (@ConfirmCountInUse = 1 AND SgnSN1 <> 0)
			OR (@ConfirmCountInUse = 2 AND SgnSN1 <> 0 AND SgnSN2 <> 0)
			OR (@ConfirmCountInUse = 3 AND SgnSN1 <> 0 AND SgnSN2 <> 0 AND SgnSN3 <> 0)
			OR (@ConfirmCountInUse = 4 AND SgnSN1 <> 0 AND SgnSN2 <> 0 AND SgnSN3 <> 0 AND SgnSN4 <> 0)
			OR (@ConfirmCountInUse = 5 AND SgnSN1 <> 0 AND SgnSN2 <> 0 AND SgnSN3 <> 0 AND SgnSN4 <> 0 AND SgnSN5 <> 0)
		)
end
ELSE IF @BaseProcessID = 115 --برگه برگشت مصرف مواد اوليه يا كالا
SELECT * FROM (
	SELECT DISTINCT	acc.funIsCodeClosed(OD.AcntCode) IsCodeClosed,OD.ProcessID, OD.ProcessNo, OD.FiscalYear, OD.SerialNo, OD.RowNo, OD.DocRowNo, 
			OD.DocStep, OD.DocDate, OD.StoreID, OD.AcntCode, OD.GoodsID, OD.SubUnitID, OD.SubUnitQuantity, 
			[inv].[funGetGoodsQuantityFromSubUnit](OD.GoodsID, OD.SubUnitID,CMROrderHdr.ConfirmQuantity) ConfirmGoodsQuantity, 
			CMROrderHdr.ConfirmQuantity, OD.GoodsQuantity, OD.DescDtl,  
			OD.BaseProcessID, OD.BaseProcessNo, OD.BaseFiscalYear,OD.BaseSerialNo, OD.BaseDocRowNo, 
			[inv].[funGetTechnicalSpecifications](OD.GoodsID) AS TechnicalSpecifications,
			pub.funGetGoodsName(OD.GoodsID,@LanguageID) AS GoodsName,inv.funGetUnitName(OD.SubUnitID,@LanguageID) AS SubUnitName ,
			ExtraField1,ExtraField2,ExtraField3,ExtraField4,ExtraField5  
	FROM	
		(
			Select	CmrCnf.ProcessID , CmrCnf.ProcessNo , CmrCnf.FiscalYear , CmrCnf.SerialNo , CmrCnf.DocRowNo,CmrCnf.DocDate,
					CmrCnf.ConfirmQuantity - CmrOrder.ConfirmQuantity AS ConfirmQuantity  
			From
			(
				Select	A.ProcessID , A.ProcessNo , A.FiscalYear , A.SerialNo,A.DocRowNo,A.DocDate,A.GoodsQuantity - ISNULL(B.GoodsQuantity,0) as ConfirmQuantity
				FROM  inv.tblStoresRequestsDtl  A
				LEFT JOIN  inv.tblStoresRequestsDtl B
				ON A.ProcessID = B.BaseProcessID AND A.ProcessNo = B.BaseProcessNo AND  A.FiscalYear = B.BaseFiscalYear AND 
    			   A.SerialNo  = B.BaseSerialNo AND  A.DocRowNo  = B.BaseDocRowNo AND A.GoodsQuantity - ISNULL(B.GoodsQuantity,0)>0 
				WHERE A.ProcessID = 230 

			) CmrCnf 
		LEFT JOIN 
			(
				Select	BaseProcessID , BaseProcessNo , BaseFiscalYear , BaseSerialNo , BaseDocRowNo ,ConfirmQuantity 
				From [cmr].[FunGetBaseStorageDocsGoods](@AcntCode,@DocDate,1,2,@SerialNo,@FiscalYear) 
				WHERE ConfirmQuantity > 0	
			) CmrOrder
			ON CmrCnf.ProcessID = CmrOrder.BaseProcessID AND  CmrCnf.ProcessNo = CmrOrder.BaseProcessNo AND 
			CmrCnf.FiscalYear = CmrOrder.BaseFiscalYear AND CmrCnf.SerialNo = CmrOrder.BaseSerialNo AND 
			CmrCnf.DocRowNo = CmrOrder.BaseDocRowNo 
			WHERE CmrCnf.DocDate<=@DocDate 
		) CMROrderHdr
	INNER JOIN
	inv.tblStoresRequestsDtl OD
	ON OD.ProcessID = CMROrderHdr.ProcessID AND  OD.ProcessNo = CMROrderHdr.ProcessNo AND 
	   OD.FiscalYear = CMROrderHdr.FiscalYear AND OD.SerialNo = CMROrderHdr.SerialNo AND 
	   OD.DocRowNo = CMROrderHdr.DocRowNo 
	INNER JOIN
	(SELECT GoodsID,ExtraField1,ExtraField2,ExtraField3,ExtraField4,ExtraField5  FROM inv.tblGoods WHERE CodeClosed = 'False'  AND PartNumber = @UnitPart  ) G
	ON SUBSTRING(OD.GoodsID,@str_Goods+1,@str_GoodsSum) = G.GoodsID 
	WHERE (@AcntCode IS NULL OR AcntCode = @AcntCode) AND OD.DocDate<=@DocDate AND CMROrderHdr.ConfirmQuantity>0 AND
		OD.ProcessID=@ProcessID AND OD.FiscalYear=@BaseFiscalYear AND OD.SerialNo=@BaseSerialNo 
) A WHERE IsCodeClosed = 0

ELSE IF  @ProcessID = 235 -- برگشت از مصرف داخلی

SELECT * FROM (
	SELECT DISTINCT	acc.funIsCodeClosed(OD.AcntCode) IsCodeClosed,OD.ProcessID, OD.ProcessNo, OD.FiscalYear, OD.SerialNo, OD.RowNo, OD.DocStep, 
			OD.DocDate, OD.StoreID, OD.AcntCode, OD.GoodsID, OD.SubUnitID, OD.SubUnitQuantity,
			[inv].[funGetGoodsQuantityFromSubUnit](OD.GoodsID, OD.SubUnitID,Cn.ConfirmQuantity) GoodsQuantity, 
			 Cn.ConfirmQuantity, OD.DescDtl, OD.BaseProcessID, 
			OD.BaseProcessNo, OD.BaseFiscalYear, OD.BaseSerialNo, OD.BaseDocRowNo, OD.DocRowNo,
			pub.funGetGoodsName(OD.GoodsID,@LanguageID) AS GoodsName, inv.funGetUnitName(SubUnitID,@LanguageID) AS SubUnitName,
			[inv].[funGetGoodsRemain](null,null,null,null,null,@StoreID,OD.GoodsID,'',@DocDate,0) GoodsRemain,
			[inv].[funGetMaxGoodsRemain](OD.ProcessID,OD.ProcessNo,OD.FiscalYear,OD.SerialNo,OD.ProcessID,OD.ProcessNo,
						OD.FiscalYear,OD.SerialNo,OD.DocRowNo,StoreID,OD.GoodsID,'',OD.DocDate,1)  AS Remain,
						ExtraField1,ExtraField2,ExtraField3,ExtraField4,ExtraField5 
	FROM inv.tblStoresRequestsDtl OD 
		INNER JOIN
		(
			Select	CmrCnf.ProcessID , CmrCnf.ProcessNo , CmrCnf.FiscalYear , CmrCnf.SerialNo , CmrCnf.DocRowNo,
					CmrCnf.ConfirmQuantity - ISNULL(StorageDocs.ConfirmQuantity,0) AS ConfirmQuantity  
			From
			(
				Select	ProcessID , ProcessNo , FiscalYear , SerialNo,DocRowNo,DocDate,GoodsQuantity as ConfirmQuantity
				FROM  inv.tblStoresRequestsDtl 

			) CmrCnf 
		LEFT JOIN 
			(
				Select	BaseProcessID , BaseProcessNo , BaseFiscalYear , BaseSerialNo , BaseDocRowNo ,ConfirmQuantity 
				From [cmr].[FunGetBaseStorageDocsGoodsUse](@AcntCode,@DocDate) 
			) StorageDocs
			ON CmrCnf.ProcessID  = StorageDocs.BaseProcessID  AND  CmrCnf.ProcessNo = StorageDocs.BaseProcessNo AND 
			   CmrCnf.FiscalYear = StorageDocs.BaseFiscalYear AND CmrCnf.SerialNo   = StorageDocs.BaseSerialNo  AND 
			   CmrCnf.DocRowNo   = StorageDocs.BaseDocRowNo  AND CmrCnf.DocDate<=@DocDate
--			Select	CmrCnf.ProcessID , CmrCnf.ProcessNo , CmrCnf.FiscalYear , CmrCnf.SerialNo , CmrCnf.DocRowNo,CmrCnf.DocDate,
--					CmrCnf.ConfirmQuantity - ISNULL(CmrOrder.ConfirmQuantity,0) AS ConfirmQuantity  
--			From
--			(
--				Select	ProcessID , ProcessNo , FiscalYear , SerialNo,DocRowNo,DocDate,ConfirmQuantity
--				FROM  [cmr].[FunGetUseRequests](@AcntCode,@DocDate) 
--			) CmrCnf 
--			LEFT JOIN 
--			(
--				Select	BaseProcessID , BaseProcessNo , BaseFiscalYear , BaseSerialNo , BaseDocRowNo ,ConfirmQuantity 
--				From [cmr].[FunGetBaseStorageDocsGoodsUse](@AcntCode,@DocDate) 
--			) CmrOrder
--			ON CmrCnf.ProcessID = CmrOrder.BaseProcessID AND  CmrCnf.ProcessNo = CmrOrder.BaseProcessNo AND 
--			   CmrCnf.FiscalYear = CmrOrder.BaseFiscalYear AND CmrCnf.SerialNo = CmrOrder.BaseSerialNo AND 
--			   CmrCnf.DocRowNo = CmrOrder.BaseDocRowNo AND CmrCnf.DocDate<=@DocDate 
		) Cn ON Cn.ProcessID = OD.ProcessID AND Cn.ProcessNo = OD.ProcessNo AND 
				Cn.FiscalYear = OD.FiscalYear AND Cn.SerialNo = OD.SerialNo AND 
				Cn.DocRowNo = OD.DocRowNo 
	INNER JOIN
	(SELECT GoodsID,ExtraField1,ExtraField2,ExtraField3,ExtraField4,ExtraField5  FROM inv.tblGoods WHERE CodeClosed = 'False'  AND PartNumber = @UnitPart  ) G
	ON SUBSTRING(OD.GoodsID,@str_Goods+1,@str_GoodsSum) = G.GoodsID 				
	WHERE Cn.SerialNo = @BaseSerialNo AND Cn.FiscalYear = @BaseFiscalYear AND 
		 (@AcntCode IS NULL OR AcntCode = @AcntCode) AND OD.DocDate<=@DocDate AND
		  Cn.ConfirmQuantity>0 
) A WHERE IsCodeClosed = 0
		  
ELSE IF @BaseProcessID = 250 -- پیش فاکتور
SELECT * FROM (
	SELECT DISTINCT	acc.funIsCodeClosed(OD.AcntCode) IsCodeClosed,OD.ProcessID, OD.ProcessNo, OD.FiscalYear, OD.SerialNo, OD.RowNo, OD.VolumeRowNo, OD.DocStep, 
			OD.DocDate, OD.StoreID, OD.EnterKind, OD.StoreID2, OD.AcntCode, OD.VisitorAcntCode, BatchNo,
			OD.OrderAcntCode, OD.GoodsID, OD.SubUnitID, OD.SubUnitQuantity,
			[inv].[funGetGoodsQuantityFromSubUnit](OD.GoodsID, OD.SubUnitID,Cn.ConfirmQuantity) GoodsQuantity, 
			 Cn.ConfirmQuantity, OD.QtyRemain, 
			OD.GoodsAmount, OD.AtomAmount, OD.GoodsPrice, OD.DescDtl, OD.BaseProcessID, 
			OD.BaseProcessNo, OD.BaseFiscalYear, OD.BaseSerialNo, OD.BaseDocRowNo, OD.AgreeNo, OD.DocRowNo,
			[inv].[funGetTechnicalSpecifications](OD.GoodsID) AS TechnicalSpecifications,SubUnitPrice,
			pub.funGetGoodsName(OD.GoodsID,@LanguageID) AS GoodsName, inv.funGetUnitName(SubUnitID,@LanguageID) AS SubUnitName,
			[inv].[funGetMaxGoodsRemain](OD.ProcessID,OD.ProcessNo,OD.FiscalYear,OD.SerialNo,OD.ProcessID,OD.ProcessNo,
						OD.FiscalYear,OD.SerialNo,OD.DocRowNo,StoreID,OD.GoodsID,OD.BatchNo,DocDate,1)  AS GoodsRemain,
						ExtraField1,ExtraField2,ExtraField3,ExtraField4,ExtraField5 
			,IsNull((Select UParams From inv.tblGoodsUserPrice P Where P.ID = OD.UserPriceID) ,'') As UserPrice,OD.UserPriceID			
	FROM inv.tblStorageDocsDtl OD 
		INNER JOIN
		(
			Select	Cnf.ProcessID , Cnf.ProcessNo , Cnf.FiscalYear , Cnf.SerialNo,Cnf.DocRowNo,
					Cnf.GoodsQuantity - ISNULL(Rtn.GoodsQuantity,0) ConfirmQuantity
			From
				(
					Select	ProcessID ,ProcessNo , FiscalYear , SerialNo , 
							DocRowNo , GoodsQuantity
					From inv.tblStorageDocsDtl 
					Where ProcessID = 250   AND ProcessNo = @ProcessNo AND 
						 (@AcntCode IS NULL OR AcntCode   = @AcntCode) AND 
						  DocDate <= @DocDate AND DocStep >=1
				) Cnf
			LEFT JOIN 
			(
				Select	BaseProcessID , BaseProcessNo , BaseFiscalYear , BaseSerialNo , 
						BaseDocRowNo , Sum(GoodsQuantity) GoodsQuantity
				From inv.tblStorageDocsDtl 
				Where BaseProcessID = 250 AND ProcessNo=@ProcessNo AND 
					 (@AcntCode IS NULL OR AcntCode   = @AcntCode)  
				Group BY BaseProcessID , BaseProcessNo , BaseFiscalYear , 
						 BaseSerialNo , BaseDocRowNo
			) Rtn
			ON	Cnf.ProcessID = Rtn.BaseProcessID AND Cnf.ProcessNo = Rtn.BaseProcessNo AND 
				Cnf.FiscalYear = Rtn.BaseFiscalYear AND Cnf.SerialNo = Rtn.BaseSerialNo AND 
				Cnf.DocRowNo = Rtn.BaseDocRowNo
		) Cn ON Cn.ProcessID = OD.ProcessID AND Cn.ProcessNo = OD.ProcessNo AND 
				Cn.FiscalYear = OD.FiscalYear AND Cn.SerialNo = OD.SerialNo AND 
				Cn.DocRowNo = OD.DocRowNo 
	INNER JOIN
	(SELECT GoodsID,ExtraField1,ExtraField2,ExtraField3,ExtraField4,ExtraField5  FROM inv.tblGoods WHERE CodeClosed = 'False'  AND PartNumber = @UnitPart  ) G
	ON SUBSTRING(OD.GoodsID,@str_Goods+1,@str_GoodsSum) = G.GoodsID 				
	WHERE Cn.SerialNo = @BaseSerialNo AND Cn.FiscalYear = @BaseFiscalYear AND 
		 (@AcntCode IS NULL OR AcntCode = @AcntCode) AND DocDate<=@DocDate AND
		  Cn.ConfirmQuantity>0 
) A WHERE IsCodeClosed = 0

ELSE IF @BaseProcessID = 255 -- برگشت از مصرف داخلی
SELECT * FROM (
	SELECT DISTINCT	acc.funIsCodeClosed(OD.AcntCode) IsCodeClosed,OD.ProcessID, OD.ProcessNo, OD.FiscalYear, OD.SerialNo, OD.RowNo, OD.DocStep, 
			OD.DocDate, OD.StoreID, OD.AcntCode, OD.GoodsID, OD.SubUnitID, OD.SubUnitQuantity,
			[inv].[funGetGoodsQuantityFromSubUnit](OD.GoodsID, OD.SubUnitID,Cn.ConfirmQuantity) GoodsQuantity, 
			 Cn.ConfirmQuantity, OD.DescDtl, OD.BaseProcessID, 
			OD.BaseProcessNo, OD.BaseFiscalYear, OD.BaseSerialNo, OD.BaseDocRowNo, OD.DocRowNo,
			pub.funGetGoodsName(OD.GoodsID,@LanguageID) AS GoodsName, inv.funGetUnitName(SubUnitID,@LanguageID) AS SubUnitName,
			[inv].[funGetGoodsRemain](null,null,null,null,null,@StoreID,OD.GoodsID,'',@DocDate,0) GoodsRemain,
			[inv].[funGetMaxGoodsRemain](OD.ProcessID,OD.ProcessNo,OD.FiscalYear,OD.SerialNo,OD.ProcessID,OD.ProcessNo,
						OD.FiscalYear,OD.SerialNo,OD.DocRowNo,StoreID,OD.GoodsID,'',OD.DocDate,1)  AS Remain,
						ExtraField1,ExtraField2,ExtraField3,ExtraField4,ExtraField5 
	FROM inv.tblStoresRequestsDtl OD 
		INNER JOIN
		(
			Select	CmrCnf.ProcessID , CmrCnf.ProcessNo , CmrCnf.FiscalYear , CmrCnf.SerialNo , CmrCnf.DocRowNo,
					CmrCnf.ConfirmQuantity - ISNULL(StorageDocs.ConfirmQuantity,0) AS ConfirmQuantity  
			From
			(
				Select	ProcessID , ProcessNo , FiscalYear , SerialNo,DocRowNo,DocDate,GoodsQuantity as ConfirmQuantity
				FROM  inv.tblStoresRequestsDtl 

			) CmrCnf 
		LEFT JOIN 
			(
				Select	BaseProcessID , BaseProcessNo , BaseFiscalYear , BaseSerialNo , BaseDocRowNo ,ConfirmQuantity 
				From [ast].[FunGetBaseStorageDocsGoodsAssetDelivery](@AcntCode,@DocDate) 
			) StorageDocs
			ON CmrCnf.ProcessID  = StorageDocs.BaseProcessID  AND  CmrCnf.ProcessNo = StorageDocs.BaseProcessNo AND 
			   CmrCnf.FiscalYear = StorageDocs.BaseFiscalYear AND CmrCnf.SerialNo   = StorageDocs.BaseSerialNo  AND 
			   CmrCnf.DocRowNo   = StorageDocs.BaseDocRowNo  AND CmrCnf.DocDate<=@DocDate
		) Cn ON Cn.ProcessID = OD.ProcessID AND Cn.ProcessNo = OD.ProcessNo AND 
				Cn.FiscalYear = OD.FiscalYear AND Cn.SerialNo = OD.SerialNo AND 
				Cn.DocRowNo = OD.DocRowNo 
	INNER JOIN
	(SELECT GoodsID,ExtraField1,ExtraField2,ExtraField3,ExtraField4,ExtraField5  FROM inv.tblGoods WHERE CodeClosed = 'False'  AND PartNumber = @UnitPart  ) G
	ON SUBSTRING(OD.GoodsID,@str_Goods+1,@str_GoodsSum) = G.GoodsID 				
	WHERE Cn.SerialNo = @BaseSerialNo AND Cn.FiscalYear = @BaseFiscalYear AND 
		 (@AcntCode IS NULL OR AcntCode = @AcntCode) AND OD.DocDate<=@DocDate AND
		  Cn.ConfirmQuantity>0 
) A WHERE IsCodeClosed = 0
	  
ELSE IF @BaseProcessID = 456 -- پیش فاکتور
	SELECT DISTINCT	OD.ProcessID, OD.ProcessNo, OD.FiscalYear, OD.SerialNo, OD.RowNo, 
			OD.DocDate, 1 EnterKind, OD.GoodsID, G.UnitID SubUnitID, OD.ConfirmQuantity  SubUnitQuantity,
			[inv].[funGetGoodsQuantityFromSubUnit](OD.GoodsID,  G.UnitID,OD.ConfirmQuantity) GoodsQuantity, 
			 OD.ConfirmQuantity,  OD.DocRowNo,OD.GoodsPrice,
			[inv].[funGetTechnicalSpecifications](OD.GoodsID) AS TechnicalSpecifications,
			pub.funGetGoodsName(OD.GoodsID,1) AS GoodsName, inv.funGetUnitName(G.UnitID,1) AS SubUnitName,
			[inv].[funGetMaxGoodsRemain](OD.ProcessID,OD.ProcessNo,OD.FiscalYear,OD.SerialNo,OD.ProcessID,OD.ProcessNo,
						OD.FiscalYear,OD.SerialNo,OD.DocRowNo,''  ,OD.GoodsID,''  ,DocDate,1)  AS GoodsRemain,
						ExtraField1,ExtraField2,ExtraField3,ExtraField4,ExtraField5 
			
	FROM 
		(
			Select	Cnf.ProcessID , Cnf.ProcessNo , Cnf.FiscalYear , Cnf.SerialNo,Cnf.DocRowNo,
					Cnf.GoodsQuantity - ISNULL(Rtn.GoodsQuantity,0) ConfirmQuantity,GoodsID,DocDate,RowNo,GoodsPrice
			From
				(
					Select	ProcessID ,ProcessNo , FiscalYear , SerialNo , 
							DocRowNo ,1 GoodsQuantity,GoodsID,DocDate,RowNo,CostAmount-DepreciationAmount GoodsPrice
					From ast.tblAssetsDtl 
					Where ProcessID = 456   AND ProcessNo =@ProcessNo AND 						
						  DocDate <= @DocDate
				) Cnf
			LEFT JOIN 
			(
				Select	BaseProcessID , BaseProcessNo , BaseFiscalYear , BaseSerialNo , 
						BaseDocRowNo , Sum(GoodsQuantity) GoodsQuantity
				From inv.tblStorageDocsDtl 
				Where BaseProcessID = 456 AND ProcessNo=@ProcessNo 
				Group BY BaseProcessID , BaseProcessNo , BaseFiscalYear , 
						 BaseSerialNo , BaseDocRowNo
			) Rtn
			ON	Cnf.ProcessID = Rtn.BaseProcessID AND Cnf.ProcessNo = Rtn.BaseProcessNo AND 
				Cnf.FiscalYear = Rtn.BaseFiscalYear AND Cnf.SerialNo = Rtn.BaseSerialNo AND 
				Cnf.DocRowNo = Rtn.BaseDocRowNo
		)   OD
	INNER JOIN
	(SELECT GoodsID,UnitID,ExtraField1,ExtraField2,ExtraField3,ExtraField4,ExtraField5  FROM inv.tblGoods WHERE CodeClosed = 'False'  AND PartNumber = @UnitPart   ) G
	ON SUBSTRING(OD.GoodsID,@str_Goods+1,@str_GoodsSum) = G.GoodsID 			
	WHERE OD.SerialNo = @BaseSerialNo AND OD.FiscalYear = @BaseFiscalYear AND 
	    DocDate<=@DocDate and OD.ConfirmQuantity >0

END
GO
