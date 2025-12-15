USE TS_ShirinVatanKarkhaneh_1_1404
GO
SET ANSI_NULLS, QUOTED_IDENTIFIER ON
GO
-- =============================================
-- Author:		Hadi Sadeghi
-- Create date: 86/11/06
-- Description:	Control Receipt 
-- =============================================
-- [inv].[spFrmStorageDocsLoadConfirmDoc] 90,1,93,252,'1393/07/28','101001','1',1
Create PROCEDURE inv.spFrmStorageDocsLoadConfirmDoc
	   @ProcessID		Smallint,
	   @ProcessNo		tinyint,
	   @FiscalYear		smallint,
	   @SerialNo		int,
	   @DocDate			Char(10),
	   @AcntCode		Varchar(20),
	   @StoreID			Varchar(20),
	   @LanguageID		Tinyint,
	   @PartNumberEnd	Tinyint=0,
	   @ExtraParams	NVarChar(Max) 
WITH ENCRYPTION
AS
BEGIN
SET NOCOUNT ON;

DECLARE @strMsgText	 NVarChar(2044)
DECLARE @DocStep Tinyint
DECLARE @Counter Tinyint
DECLARE @SalRet_RetToSalOdr AS BIT
DECLARE @DocStep1 tinyint
DECLARE @HasConfirmForPreSale AS BIT
DECLARE @UnitPart TINYINT
DECLARE @PreSal_GetRemain AS BIT
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
SET @DocStep = 1
SET @SalRet_RetToSalOdr = 'False'
SET @HasConfirmForPreSale = 'False'
SET @PreSal_GetRemain = 'False'
	
SELECT @SalRet_RetToSalOdr = SettingValue
FROM pub.tblSettings
WHERE SettingKey = 'SalRet_RetToSalOdr' 

SELECT @HasConfirmForPreSale = SettingValue
FROM pub.tblSettings
WHERE SettingKey = 'HasConfirmForPreSale'

SELECT @PreSal_GetRemain=SettingValue
FROM pub.tblSettings
WHERE SettingKey = 'PreSal_GetRemain'

IF @HasConfirmForPreSale = 'False' 
	SET @DocStep1 = 1
ELSE
	SET @DocStep1 = 2

Declare @ConfirmCount	int;
DECLARE @Sgn1			BIT;
DECLARE @Sgn2			BIT;
DECLARE @Sgn3			BIT;
DECLARE @Sgn4			BIT;
DECLARE @Sgn5			BIT;
DECLARE @Confirm		BIT;

SET @ConfirmCount		= pub.funSplitString(@ExtraParams, '@', 2);
SET @Sgn1				= pub.funSplitString(@ExtraParams, '@', 3);
SET @Sgn2				= pub.funSplitString(@ExtraParams, '@', 4);
SET @Sgn3				= pub.funSplitString(@ExtraParams, '@', 5);
SET @Sgn4				= pub.funSplitString(@ExtraParams, '@', 6);
SET @Sgn5				= pub.funSplitString(@ExtraParams, '@', 7);
SET @Confirm			= pub.funSplitString(@ExtraParams, '@', 8);
		
IF @ProcessID = 55  OR @ProcessID = 90 OR @ProcessID = 110
BEGIN

	Declare @SaleOrderAcntCode Varchar(20)=''
	IF @ProcessID = 90	
		SELECT @SaleOrderAcntCode = SettingValue FROM pub.tblSettings WHERE SettingKey = 'SaleOrderAcntCode'
	IF @ProcessID = 55	
		SELECT @SaleOrderAcntCode = SettingValue FROM pub.tblSettings WHERE SettingKey = 'BuyOrderAcntCode'
	
	declare @YR varchar(4) =right(DB_Name(),4)
		
	Select TOP 0 CD.BaseProcessID , CD.BaseProcessNo , CD.BaseFiscalYear , CD.BaseSerialNo , 
		CD.BaseDocRowNo , CD.GoodsQuantity INTO #tblRetAllYears2
	From inv.tblStorageDocsDtl CD
	
	insert into #tblRetAllYears2
	exec [inv].[spGetBaseRetInAllYears] @ProcessID,@ProcessNo,@YR,NULL

 SELECT *,round(inv.funGetGoodsSubQuantity(A.GoodsID,A.SubUnitID,BaseRemain),5) SubUnitRemain FROM (
	SELECT DISTINCT	acc.funIsCodeClosed(OD.AcntCode) IsCodeClosed,OD.ProcessID, OD.ProcessNo, OD.FiscalYear, 
		OD.SerialNo, OD.RowNo, OD.VolumeRowNo, OD.DocStep, OD.DocDate, OD.StoreID, OD.EnterKind, OD.StoreID2, OD.VisitorPercent ,OD.VisitorPriceOneGoods, OD.VisitorPercent2,
		OD.AcntCode, OD.VisitorAcntCode, OD.VisitorAcntCode2, DiscountAcntCode, AfterSaleDiscountAcntCode, DiscountPercent, Discount, Discount2, OD.OrderAcntCode, OD.SaleTypeID,
		OD.GoodsID, OD.SubUnitID,round( inv.funGetGoodsSubQuantity(OD.GoodsID,OD.SubUnitID,Cn.GoodsQuantity),5) SubUnitQuantity, Cn.GoodsQuantity, OD.QtyRemain, OD.GoodsAmount, OD.AtomAmount, 
		OD.GoodsPrice, OD.DescDtl, OD.BaseProcessID, IsReward, OD.BaseProcessNo, OD.BaseFiscalYear, OD.BaseSerialNo, 
		OD.BaseDocRowNo, OD.AgreeNo, OD.DocRowNo, [inv].[funGetTechnicalSpecifications](OD.GoodsID) AS TechnicalSpecifications,
		OD.TaxOverWorthCostDtl, OD.TollOverWorthCostDtl, H.DriverID, H.DistributerID1, H.DistributerID2,
		IsNull(H.LocationID,'') As LocationID,H.TransportationCostAcntCode, H.TransportationCost, H.TransportationIncomeAcntCode, H.TransportationIncome,
		H.OtherCostAcntCode, H.OtherCost, H.OtherIncomeAcntCode, H.OtherIncome, H.TaxCost, H.SaleTypeID As HdrSaleTypeID,
		SubUnitPrice,SubUnitPrice2,SubUnitQuantity2, pub.funGetGoodsName(OD.GoodsID,@LanguageID) AS GoodsName, 
		inv.funGetUnitName(SubUnitID,@LanguageID) AS SubUnitName, H.HasNoReward,H.HasNoDiscountDtl, OD.UserPriceID, H.BaseDistributionProcessID, 
		H.BaseDistributionProcessNo,H.BaseDistributionFiscalYear, H.BaseDistributionSerialNo,
		IsNull((Select UParams From inv.tblGoodsUserPrice p Where p.ID=OD.UserPriceID) ,'') as UserPrice,
		[inv].[funGetMaxGoodsRemain](OD.ProcessID, OD.ProcessNo, OD.FiscalYear, OD.SerialNo, OD.ProcessID, OD.ProcessNo,
									 OD.FiscalYear,OD.SerialNo,OD.DocRowNo,OD.StoreID,OD.GoodsID,OD.BatchNo,OD.DocDate,1) AS GoodsRemain,
		CASE WHEN @ProcessID = 110 THEN Cn.GoodsQuantity ELSE [inv].[funGetGoodsRemain](null,null,null,null,null,@StoreID,OD.GoodsID,OD.BatchNo,@DocDate,OD.UserPriceID) END BaseRemain,
		OD.DiscountPercentDtl,(DiscountDtl * Cn.GoodsQuantity )/OD.GoodsQuantity as DiscountDtl ,
		G.ExtraField1, G.ExtraField2, G.ExtraField3, G.ExtraField4, G.ExtraField5,
		OD.ConstText1, OD.ConstText2, OD.ConstText3, OD.ConstText4, H.VisitorCost, 
		H.VisitorCost2, H.PackingCost, H.PackingCostPercent, H.TaxOverWorthCost, H.TollOverWorthCost, H.DiscountTaxOverWorth, 
		'' DtlSaleTypeID, H.TransporterID, H.TransporterID2, H.CarNo ,Cn.Var1 ,Cn.Var2
		,[inv].[funGetTechnicalNo](OD.GoodsID) AS TechnicalNo
		,H.StoreID HdrStoreID,SgnSN1,SgnSN2,SgnSN3,SgnSN4,SgnSN5,TPInp
		FROM inv.tblStorageDocsDtl OD 
		INNER JOIN inv.tblStorageDocsHdr H ON OD.ProcessID=H.ProcessID AND OD.ProcessNo=H.ProcessNo AND 
											  OD.FiscalYear=H.FiscalYear AND OD.SerialNo=H.SerialNo
				INNER JOIN
				(
					Select	Cnf.ProcessID , Cnf.ProcessNo , Cnf.FiscalYear , Cnf.SerialNo,Cnf.DocRowNo,
							Cnf.GoodsQuantity - ISNULL(Rtn.GoodsQuantity,0) GoodsQuantity ,Cnf.Var1,Cnf.Var2
					From
						(
							Select	OD.ProcessID , OD.ProcessNo , OD.FiscalYear , OD.SerialNo , 
									OD.DocRowNo , OD.GoodsQuantity, OD.SubUnitQuantity ,OD.Var1 ,OD.Var2
							From inv.tblStorageDocsDtl OD
							Where OD.ProcessID = @ProcessID  AND OD.ProcessNo  = @ProcessNo AND 
								 (@AcntCode IS NULL OR OD.AcntCode = @AcntCode) AND 
								  OD.DocDate <= @DocDate AND OD.DocStep IN (0,1,2,3,11)  
								  AND
									((------------حذف اطلاعاتی که اسناد آنها ازنوع یادداشت است------------------------------------------------------
										SELECT COUNT(*)	from acc.tblVoucherDtl  v 
										WHERE v.SourceProcessID= OD.ProcessID and  v.SourceProcessNo= OD.ProcessNo
										and  v.SourceFiscalYear= OD.FiscalYear and  v.SourceSerialNo= OD.SerialNo
										and (v.AcntCode= OD.AcntCode or v.AcntCode=[pub].[funMergCode](@SaleOrderAcntCode,OD.AcntCode)) and v.VchKind<>0 
									) > 0 OR @ProcessID = 110) 

						) Cnf
					LEFT JOIN 
					(
					select * from #tblRetAllYears2
						--Select	OD.BaseProcessID , OD.BaseProcessNo , OD.BaseFiscalYear , OD.BaseSerialNo , 
						--		OD.BaseDocRowNo , Sum(OD.GoodsQuantity) GoodsQuantity
						--From inv.tblStorageDocsDtl OD
						--Where OD.BaseProcessID = @ProcessID AND OD.ProcessNo  = @ProcessNo AND
						--	 (@AcntCode IS NULL OR AcntCode = @AcntCode)
						--Group BY OD.BaseProcessID , OD.BaseProcessNo , OD.BaseFiscalYear , 
						--		 OD.BaseSerialNo , OD.BaseDocRowNo
					) Rtn
					ON	Cnf.ProcessID = Rtn.BaseProcessID AND Cnf.ProcessNo = Rtn.BaseProcessNo AND 
						Cnf.FiscalYear = Rtn.BaseFiscalYear AND Cnf.SerialNo = Rtn.BaseSerialNo AND 
					Cnf.DocRowNo = Rtn.BaseDocRowNo	
				) Cn ON Cn.ProcessID  = OD.ProcessID  AND Cn.ProcessNo = OD.ProcessNo AND 
						Cn.FiscalYear = OD.FiscalYear AND Cn.SerialNo  = OD.SerialNo  AND
						Cn.DocRowNo   = OD.DocRowNo   AND OD.ProcessID = @ProcessID   AND 
						 Cn.GoodsQuantity > 0 AND
						--(@StoreID IS NULL OR StoreID = @StoreID) AND 
						OD.ProcessNo = @ProcessNo AND
						OD.FiscalYear = @FiscalYear   AND OD.SerialNo  = @SerialNo 
		INNER JOIN
		(SELECT GoodsID,ExtraField1,ExtraField2,ExtraField3,ExtraField4,ExtraField5 FROM inv.tblGoods WHERE CodeClosed = 'False'   AND PartNumber = @UnitPart ) G
		ON  SUBSTRING(OD.GoodsID,@str_Goods+1,@str_GoodsSum) = G.GoodsID
) A WHERE IsCodeClosed = 0
	And	(ProcessID<>90 or  (ProcessID=90 and TPInp<>7))
	And	(
		(@ConfirmCount= 0)
		OR (@ConfirmCount = 1 AND SgnSN1 <> 0)
		OR (@ConfirmCount = 2 AND SgnSN1 <> 0 AND SgnSN2 <> 0)
		OR (@ConfirmCount = 3 AND SgnSN1 <> 0 AND SgnSN2 <> 0 AND SgnSN3 <> 0)
		OR (@ConfirmCount = 4 AND SgnSN1 <> 0 AND SgnSN2 <> 0 AND SgnSN3 <> 0 AND SgnSN4 <> 0)
		OR (@ConfirmCount = 5 AND SgnSN1 <> 0 AND SgnSN2 <> 0 AND SgnSN3 <> 0 AND SgnSN4 <> 0 AND SgnSN5 <> 0)
		)			

ORDER BY DocRowNo	

END
	
ELSE IF @ProcessID=180 -- سفارش فروش
begin
	DECLARE @DontCheckProcessNoInSale AS BIT
	SET @DontCheckProcessNoInSale = 'False'
	SELECT @DontCheckProcessNoInSale=SettingValue FROM pub.tblSettings WHERE SettingKey = 'DontCheckProcessNoInSale'
	IF @DontCheckProcessNoInSale = 'True' 
		SET @ProcessNo = NULL
	DECLARE @Sal_StoreDtl as BIT
	SET @Sal_StoreDtl = 'False'
	SELECT @Sal_StoreDtl=SettingValue FROM pub.tblSettings WHERE SettingKey = 'Sal_StoreDtl'

SELECT * FROM (
	SELECT DISTINCT	acc.funIsCodeClosed(OD.AcntCode) IsCodeClosed,OD.ProcessID, OD.ProcessNo, OD.FiscalYear, OD.SerialNo, OD.RowNo, OD.DocStep, 
			OD.DocDate, OD.AcntCode, OD.VisitorAcntCode, OD.VisitorAcntCode2, OD.GoodsID, OD.SubUnitID, CMRSaleOrderHdr.ConfirmQuantity, CMRSaleOrderHdr.ConfirmQuantity GoodsQuantity,
			round(inv.funGetGoodsSubQuantity(OD.GoodsID,OD.SubUnitID,CMRSaleOrderHdr.ConfirmQuantity),5) SubUnitQuantity,
			OD.GoodsPrice,SubUnitPrice,SubUnitPrice2, OD.DescDtl,OH.DocDesc,OH.DocDesc2, OD.BaseProcessID,OD.DiscountPercentDtl,OD.DiscountDtl, OD.VisitorPercent,OD.VisitorPriceOneGoods, OD.VisitorPercent2,
			OD.BaseProcessNo, OD.BaseFiscalYear, OD.BaseSerialNo, OD.BaseDocRowNo, OD.AgreeNo, OD.DocRowNo, 0 BaseDistributionProcessID, 
		    0 BaseDistributionProcessNo,0 BaseDistributionFiscalYear, 0 BaseDistributionSerialNo, OD.SaleTypeID As DtlSaleTypeID, OD.TaxOverWorthCostDtl, 
		    OD.TollOverWorthCostDtl, OD.Var1, OD.Var2, OD.Var3, OD.Var4, IsReward, '' TransportationCostAcntCodeBuy, '' TransportationIncomeAcntCodeBuy, 
			OH.EarnestMoneyPercent, OH.EarnestMoney, OH.EarnestMoneyAcntCode, OH.CurrencyTypeID, OH.CurrencyRate, OH.CurrencyDiscount,
			IsNull(OH.LocationID,'') As LocationID, OH.SaleTypeID, OH.TransportationCostAcntCode, OH.TransportationCost, OH.TransportationIncomeAcntCode, OH.TransportationIncome, 
			OH.VisitorAcntCode As VisitorAcntCodeHdr, OH.VisitorPercent As HdrVisitorPercent, OH.VisitorCost, OH.HasNoReward,OH.HasNoDiscountDtl, OH.PayOffTypeID, 
			OH.VisitorAcntCode2 As VisitorAcntCodeHdr2, OH.VisitorPercent2 As HdrVisitorPercent2, OH.VisitorCost2, OH.PackingCost, OH.TaxCost, OH.PackingCostPercent,
			OH.TaxOverWorthCost, OH.TollOverWorthCost,OH.DiscountTaxOverWorth,  OH.OtherCostAcntCode, OH.OtherCost, OH.OtherIncomeAcntCode, OH.OtherIncome,			
			[inv].[funGetTechnicalSpecifications](OD.GoodsID) AS TechnicalSpecifications,OH.Discount,OH.DiscountPercent,OH.Discount2,
			pub.funGetGoodsName(OD.GoodsID,@LanguageID) AS GoodsName, inv.funGetUnitName(SubUnitID,@LanguageID) AS SubUnitName ,
			[inv].[funGetMaxGoodsRemain](OD.ProcessID,OD.ProcessNo,OD.FiscalYear,OD.SerialNo,OD.ProcessID,OD.ProcessNo,
			OD.FiscalYear,OD.SerialNo,OD.DocRowNo,@StoreID,OD.GoodsID,'',@DocDate,1)  AS BaseRemain,
			[inv].[funGetGoodsRemain](null,null,null,null,null,CASE WHEN @StoreID IS NULL OR @Sal_StoreDtl='False' THEN @StoreID ELSE OD.StoreID END ,OD.GoodsID,'',@DocDate,OD.UserPriceID) GoodsRemain,
			ExtraField1,ExtraField2,ExtraField3,ExtraField4,ExtraField5,OD.ConstText1,OD.ConstText2,OD.ConstText3,OD.ConstText4
			,[inv].[funGetTechnicalNo](OD.GoodsID) AS TechnicalNo
			,SgnSN1,SgnSN2,SgnSN3,SgnSN4,SgnSN5, OH.StoreID HdrStoreID, OD.StoreID StoreID
	FROM	
		(Select	ProcessID ,ProcessNo ,FiscalYear ,SerialNo, DocRowNo, DocDate, ConfirmQuantity
			FROM  [cmr].[FunGetSaleOrder](@AcntCode,@DocDate,@DocStep,@SalRet_RetToSalOdr,@FiscalYear,@SerialNo) 
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
	(SELECT GoodsID,ExtraField1,ExtraField2,ExtraField3,ExtraField4,ExtraField5  FROM inv.tblGoods WHERE CodeClosed = 'False'   AND PartNumber = @UnitPart  ) G
	ON  SUBSTRING(OD.GoodsID,@str_Goods+1,@str_GoodsSum) = G.GoodsID 		
	WHERE	OD.ProcessID=@ProcessID  AND (@ProcessNo IS NULL OR OD.ProcessNo = @ProcessNo) AND OD.FiscalYear=@FiscalYear AND OD.SerialNo=@SerialNo AND 
		   (@AcntCode IS NULL OR SubString(OD.AcntCode,1,len(@AcntCode)) = @AcntCode) AND OD.DocDate<=@DocDate AND CMRSaleOrderHdr.ConfirmQuantity>0  
) A WHERE IsCodeClosed = 0
	And	(
		(@ConfirmCount= 0)
		OR (@ConfirmCount = 1 AND SgnSN1 <> 0)
		OR (@ConfirmCount = 2 AND SgnSN1 <> 0 AND SgnSN2 <> 0)
		OR (@ConfirmCount = 3 AND SgnSN1 <> 0 AND SgnSN2 <> 0 AND SgnSN3 <> 0)
		OR (@ConfirmCount = 4 AND SgnSN1 <> 0 AND SgnSN2 <> 0 AND SgnSN3 <> 0 AND SgnSN4 <> 0)
		OR (@ConfirmCount = 5 AND SgnSN1 <> 0 AND SgnSN2 <> 0 AND SgnSN3 <> 0 AND SgnSN4 <> 0 AND SgnSN5 <> 0)
		)
order by DocRowNo
 end
ELSE IF @ProcessID = 240 -- پیش فاکتور فروش
BEGIN
 
 --select @str_Goods+1,@str_GoodsSum,@UnitPart,@ConfirmCount
	IF @PreSal_GetRemain = 'False'
	SELECT *,BaseRemain GoodsRemain,round(IsNull(inv.funGetGoodsSubQuantity(A.GoodsID,A.SubUnitID,BaseRemain),0),5) SubUnitRemain FROM (
		SELECT  acc.funIsCodeClosed(OD.AcntCode) IsCodeClosed,OD.ProcessID,OD.ProcessNo,OD.FiscalYear,OD.SerialNo,OD.RowNo,OD.DocRowNo,
				OD.GoodsAmount AS GoodsPrice, OD.GoodsAmount AS SubUnitPrice, 1 DocStep, OD.DocDate, OD.AcntCode, OD.GoodsID,
				pub.funGetGoodsUnitID(OD.GoodsID) As GSubUnitID, OD.SubUnitID SubUnitID, CMRSaleOrderHdr.ConfirmQuantity AS GSubUnitQuantity, OD.SubUnitQuantity,
				CMRSaleOrderHdr.ConfirmQuantity, CMRSaleOrderHdr.ConfirmQuantity GoodsQuantity, OH.CurrencyTypeID, OH.CurrencyRate, OH.CurrencyDiscount,
				OD.SaleTypeID As DtlSaleTypeID,OH.SaleTypeID,OD.TaxOverWorthCostDtl, OD.TollOverWorthCostDtl, OD.DescDtl, OH.HasNoReward,OH.HasNoDiscountDtl, 
				IsNull(OH.LocationID,'') As LocationID, OH.DiscountPercent As DiscountPercentH, OD.Var1, OD.Var2, OD.Var3, OD.Var4,
				OH.Discount , OH.Discount2 ,[inv].[funGetTechnicalSpecifications](OD.GoodsID) AS TechnicalSpecifications, OH.TransporterID,
				OD.DiscountPercent As DiscountPercentDtl, OD.Discount As DiscountDtl, OD.Discount2 As Discount2D,TransportationCostAcntCode,
				TransportationCost,TransportationIncomeAcntCode,TransportationIncome, 0 BaseDistributionProcessID, 0 BaseDistributionProcessNo,
				0 BaseDistributionFiscalYear, 0 BaseDistributionSerialNo,OH.VisitorAcntCode VisitorAcntCodeHdr, OH.VisitorPercent VisitorPercentHdr,
				VisitorCost,PackingCost,TaxCost,'' PackingCostPercent,TaxOverWorthCost,TollOverWorthCost,0 DiscountTaxOverWorth,  OD.VisitorAcntCode, OD.VisitorPercent,OD.VisitorPriceOneGoods, 
				OH.VisitorAcntCode2 VisitorAcntCodeHdr2, OH.VisitorPercent2 VisitorPercentHdr2, OH.VisitorCost2,OH.DiscountPercent DiscountPercentHdr,
				OD.VisitorAcntCode2, OD.VisitorPercent2, --OH.CurrencyTypeID, OH.CurrencyRate, OD.CurrencyAmount,
				OtherCostAcntCode,OtherCost,OtherIncomeAcntCode,OtherIncome,pub.funGetGoodsName(OD.GoodsID,@LanguageID) AS GoodsName,
				pub.funGetGoodsUnitName(OD.GoodsID,@LanguageID) AS GSubUnitName, [inv].[funGetUnitName](OD.SubUnitID,@LanguageID) SubUnitName,
				[inv].[funGetGoodsRemain](null,null,null,null,null,@StoreID,OD.GoodsID,'',@DocDate,0) BaseRemain,
				ExtraField1,ExtraField2,ExtraField3,ExtraField4,ExtraField5,OD.ConstText1,OD.ConstText2,OD.ConstText3,OD.ConstText4
				, GoodsID3,pub.GetGoodsNamePart(OD.GoodsID3,@PartNumberEnd,@LanguageID) AS GoodsName3, GoodsQuantity3, SubUnitQuantity3, GoodsPrice3, SubUnitID3, Height, Width, ServiceAmount
				, inv.funGetUnitName(OD.SubUnitID3,@LanguageID) AS SubUnitName3
				,[inv].[funGetTechnicalNo](OD.GoodsID) AS TechnicalNo,OH.DocDesc,OH.DocDesc2,OD.StoreID,OH.StoreID HdrStoreID
				,SgnSN1,SgnSN2,SgnSN3,SgnSN4,SgnSN5

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
					SELECT DISTINCT BaseProcessID,BaseProcessNo,BaseFiscalYear,BaseSerialNo
					FROM  [cmr].[FunGetBaseSaleGoods](@AcntCode,@DocDate,0,1,@SerialNo,@FiscalYear)
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
		(SELECT GoodsID,ExtraField1,ExtraField2,ExtraField3,ExtraField4,ExtraField5 FROM inv.tblGoods WHERE CodeClosed = 'False'   AND PartNumber = @UnitPart  ) G
		ON  SUBSTRING(OD.GoodsID,@str_Goods+1,@str_GoodsSum) = G.GoodsID 
		WHERE	OD.ProcessID=@ProcessID AND OD.ProcessNo=@ProcessNo AND OD.FiscalYear=@FiscalYear AND OD.SerialNo=@SerialNo AND 
			   (@AcntCode IS NULL OR OD.AcntCode = @AcntCode) AND OD.DocDate<= @DocDate  AND CMRSaleOrderHdr.ConfirmQuantity>0 
	) A WHERE IsCodeClosed = 0
	And	(
		(@ConfirmCount= 0)
		OR (@ConfirmCount = 1 AND SgnSN1 <> 0)
		OR (@ConfirmCount = 2 AND SgnSN1 <> 0 AND SgnSN2 <> 0)
		OR (@ConfirmCount = 3 AND SgnSN1 <> 0 AND SgnSN2 <> 0 AND SgnSN3 <> 0)
		OR (@ConfirmCount = 4 AND SgnSN1 <> 0 AND SgnSN2 <> 0 AND SgnSN3 <> 0 AND SgnSN4 <> 0)
		OR (@ConfirmCount = 5 AND SgnSN1 <> 0 AND SgnSN2 <> 0 AND SgnSN3 <> 0 AND SgnSN4 <> 0 AND SgnSN5 <> 0)
		)
		ORDER BY SerialNo,DocRowNo					
	ELSE
	BEGIN
		SELECT *,BaseRemain GoodsRemain,round(IsNull(inv.funGetGoodsSubQuantity(A.GoodsID,A.SubUnitID,BaseRemain),0),5) SubUnitRemain  FROM (
				SELECT  acc.funIsCodeClosed(OD.AcntCode) IsCodeClosed,OD.ProcessID,OD.ProcessNo,OD.FiscalYear,OD.SerialNo,OD.RowNo,OD.DocRowNo,
				OD.GoodsAmount AS GoodsPrice, OD.GoodsAmount AS SubUnitPrice, 1 DocStep, OD.DocDate, OD.AcntCode, OD.GoodsID,
				pub.funGetGoodsUnitID(OD.GoodsID) As GSubUnitID, OD.SubUnitID SubUnitID, CMRSaleOrderHdr.ConfirmQuantity AS GSubUnitQuantity,CMRSaleOrderHdr.ConfirmQuantity SubUnitQuantity,
				CMRSaleOrderHdr.ConfirmQuantity, CMRSaleOrderHdr.ConfirmQuantity GoodsQuantity, OH.CurrencyTypeID, OH.CurrencyRate, OH.CurrencyDiscount,
				OD.SaleTypeID As DtlSaleTypeID,OH.SaleTypeID,OD.TaxOverWorthCostDtl, OD.TollOverWorthCostDtl, OD.DescDtl, OH.HasNoReward,OH.HasNoDiscountDtl, 
				IsNull(OH.LocationID,'') As LocationID, OH.DiscountPercent As DiscountPercentH, OD.Var1, OD.Var2, OD.Var3, OD.Var4,
				OH.Discount , OH.Discount2 ,[inv].[funGetTechnicalSpecifications](OD.GoodsID) AS TechnicalSpecifications, OH.TransporterID,
				OD.DiscountPercent As DiscountPercentDtl, OD.Discount As DiscountDtl, OD.Discount2 As Discount2D,TransportationCostAcntCode,
				TransportationCost,TransportationIncomeAcntCode,TransportationIncome, 0 BaseDistributionProcessID, 0 BaseDistributionProcessNo,
				0 BaseDistributionFiscalYear, 0 BaseDistributionSerialNo,OH.VisitorAcntCode VisitorAcntCodeHdr, OH.VisitorPercent VisitorPercentHdr,
				VisitorCost,PackingCost,TaxCost, '' PackingCostPercent,TaxOverWorthCost,TollOverWorthCost,0 DiscountTaxOverWorth,  OD.VisitorAcntCode, OD.VisitorPercent,OD.VisitorPriceOneGoods, 
				OH.VisitorAcntCode2 VisitorAcntCodeHdr2, OH.VisitorPercent2 VisitorPercentHdr2, OH.VisitorCost2,OH.DiscountPercent DiscountPercentHdr,
				OD.VisitorAcntCode2, OD.VisitorPercent2, --OH.CurrencyTypeID, OH.CurrencyRate, OD.CurrencyAmount,
				OtherCostAcntCode,OtherCost,OtherIncomeAcntCode,OtherIncome,pub.funGetGoodsName(OD.GoodsID,@LanguageID) AS GoodsName,
				pub.funGetGoodsUnitName(OD.GoodsID,@LanguageID) AS GSubUnitName, [inv].[funGetUnitName](OD.SubUnitID,@LanguageID) SubUnitName,
				[inv].[funGetGoodsRemain](null,null,null,null,null,@StoreID,OD.GoodsID,'',@DocDate,0) BaseRemain,
				ExtraField1,ExtraField2,ExtraField3,ExtraField4,ExtraField5,OD.ConstText1,OD.ConstText2,OD.ConstText3,OD.ConstText4
				, GoodsID3,pub.GetGoodsNamePart(OD.GoodsID3,@PartNumberEnd,@LanguageID) AS GoodsName3, GoodsQuantity3, SubUnitQuantity3, GoodsPrice3, SubUnitID3, Height, Width, ServiceAmount
				, inv.funGetUnitName(OD.SubUnitID3,@LanguageID) AS SubUnitName3
				,[inv].[funGetTechnicalNo](OD.GoodsID) AS TechnicalNo,OD.StoreID,OH.StoreID HdrStoreID
				,SgnSN1,SgnSN2,SgnSN3,SgnSN4,SgnSN5
				FROM	
					(
						
					SELECT	DISTINCT Cnf.ProcessID , Cnf.ProcessNo , Cnf.FiscalYear , Cnf.SerialNo , Cnf.DocRowNo ,DocDate
							,Cnf.GoodsQuantity - ISNULL(sd.ConfirmQuantity,0) AS ConfirmQuantity
					FROM	inv.tblPreSaleDtl Cnf	
					LEFT JOIN (
							Select BaseProcessID , BaseProcessNo , BaseFiscalYear , BaseSerialNo , BaseDocRowNo,Sum(GoodsQuantity) ConfirmQuantity 
							From inv.tblStorageDocsDtl
							Where BaseProcessID = 240 AND
								(@AcntCode IS NULL   OR AcntCode = @AcntCode) AND  DocDate <= @DocDate 
							Group BY BaseProcessID , BaseProcessNo , BaseFiscalYear , BaseSerialNo ,BaseDocRowNo
						) sd

					ON	Cnf.ProcessID = sd.BaseProcessID AND Cnf.ProcessNo = sd.BaseProcessNo AND 
						Cnf.FiscalYear = sd.BaseFiscalYear AND Cnf.SerialNo = sd.BaseSerialNo AND 
						Cnf.DocRowNo = sd.BaseDocRowNo
					WHERE Cnf.DocStep=@DocStep1 and Cnf.GoodsQuantity - ISNULL(sd.ConfirmQuantity,0)>0	
										
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
				(SELECT GoodsID,ExtraField1,ExtraField2,ExtraField3,ExtraField4,ExtraField5 FROM inv.tblGoods WHERE CodeClosed = 'False' AND PartNumber = @UnitPart ) G
				ON SUBSTRING(OD.GoodsID,@str_Goods+1,@str_GoodsSum) = G.GoodsID 
				WHERE	OD.ProcessID=@ProcessID AND OD.FiscalYear=@FiscalYear AND OD.SerialNo=@SerialNo AND --OD.ProcessNo=@ProcessNo AND  
						(@AcntCode IS NULL OR OD.AcntCode = @AcntCode) AND OD.DocDate<= @DocDate  AND CMRSaleOrderHdr.ConfirmQuantity>0 
		) A WHERE IsCodeClosed = 0	
			And	(
				(@ConfirmCount= 0)
				OR (@ConfirmCount = 1 AND SgnSN1 <> 0)
				OR (@ConfirmCount = 2 AND SgnSN1 <> 0 AND SgnSN2 <> 0)
				OR (@ConfirmCount = 3 AND SgnSN1 <> 0 AND SgnSN2 <> 0 AND SgnSN3 <> 0)
				OR (@ConfirmCount = 4 AND SgnSN1 <> 0 AND SgnSN2 <> 0 AND SgnSN3 <> 0 AND SgnSN4 <> 0)
				OR (@ConfirmCount = 5 AND SgnSN1 <> 0 AND SgnSN2 <> 0 AND SgnSN3 <> 0 AND SgnSN4 <> 0 AND SgnSN5 <> 0)
				)		
		ORDER BY SerialNo,DocRowNo					
	END
END

ELSE IF @ProcessID = 56 -- باسکول خرید
	SELECT *, 0 ProcessNo, 0 FiscalYear, 0 DiscountDtl, 0 TaxOverWorthCostDtl, 0 TollOverWorthCostDtl
	FROM (
		  SELECT D.*, H.AcntCode, pub.funGetGoodsName(D.GoodsID,@LanguageID) AS GoodsName, 
				 H.DocDate, inv.funGetUnitName(D.SubUnitID, @LanguageID) AS SubUnitName, 
				 [inv].[funGetTechnicalSpecifications](D.GoodsID) AS TechnicalSpecifications, 
				 D.SubUnitQuantity As ConfirmQuantity, D.SubUnitQuantity As GoodsQuantity, D.Fee GoodsPrice,
				 D.Fee SubUnitPrice, D.Fee SubUnitPrice2, H.TransportationCost, acc.funIsCodeClosed(H.AcntCode) IsCodeClosed,
				 H.LocationID,H.VehicleNo,H.VehicleTypeID,H.DriverID
				,[inv].[funGetTechnicalNo](D.GoodsID) AS TechnicalNo ,H.StoreID HdrStoreID

		  FROM 
		  (
				SELECT ProcessID, 0 ProcessNo, 0 FiscalYear, SerialNo
				FROM inv.tblBaskulSalesHdr H
				WHERE ProcessID = @ProcessID 
				EXCEPT
				SELECT BaseProcessID, 0 BaseProcessNo, 0 BaseFiscalYear, BaseSerialNo
				FROM inv.tblStorageDocsHdr 
				WHERE ProcessID = 55 And BaseProcessID = @ProcessID	  
		  ) H1
		  INNER JOIN inv.tblBaskulSalesHdr H ON H.ProcessID = H1.ProcessID And H.SerialNo = H1.SerialNo
		  INNER JOIN inv.tblBaskulSalesDtl D ON H.ProcessID = D.ProcessID And H.SerialNo = D.SerialNo
		  WHERE H.ProcessID = @ProcessID And H.SerialNo = @SerialNo
		 ) A WHERE IsCodeClosed = 0
	
ELSE IF @ProcessID = 91    -- باسکول فروش
	SELECT *, 0 ProcessNo, 0 FiscalYear, 0 DiscountDtl, 0 TaxOverWorthCostDtl, 0 TollOverWorthCostDtl,
		   '' DtlSaleTypeID
	FROM (
		  SELECT D.*, H.AcntCode, pub.funGetGoodsName(D.GoodsID,@LanguageID) AS GoodsName, 
				 inv.funGetUnitName(D.SubUnitID, @LanguageID) AS SubUnitName, 
				 [inv].[funGetTechnicalSpecifications](D.GoodsID) AS TechnicalSpecifications, 
				 D.SubUnitQuantity As ConfirmQuantity, D.SubUnitQuantity As GoodsQuantity, D.Fee GoodsPrice,
				 D.Fee SubUnitPrice, H.TransportationCost, acc.funIsCodeClosed(H.AcntCode) IsCodeClosed,
				 H.LocationID,H.VehicleNo,H.VehicleTypeID,H.DriverID
				,[inv].[funGetTechnicalNo](D.GoodsID) AS TechnicalNo,H.StoreID HdrStoreID
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
		  WHERE H.ProcessID = @ProcessID And H.SerialNo = @SerialNo		  
		 ) A WHERE IsCodeClosed = 0
ELSE IF   @ProcessID = 194   -- باسکول فروش
	SELECT *, 0 ProcessNo, 0 FiscalYear, 0 DiscountDtl, 0 TaxOverWorthCostDtl, 0 TollOverWorthCostDtl,
		   '' DtlSaleTypeID
	FROM (
		  SELECT D.*,AcntCodeDtl AcntCode, pub.funGetGoodsName(D.GoodsID,@LanguageID) AS GoodsName, 
				 inv.funGetUnitName(D.SubUnitID, @LanguageID) AS SubUnitName, 
				 [inv].[funGetTechnicalSpecifications](D.GoodsID) AS TechnicalSpecifications, 
				 D.SubUnitQuantity As ConfirmQuantity, D.SubUnitQuantity As GoodsQuantity, D.Fee GoodsPrice,
				 D.Fee SubUnitPrice, H.TransportationCost, acc.funIsCodeClosed(H.AcntCode) IsCodeClosed,
				 H.LocationID,H.VehicleNo,H.VehicleTypeID,H.DriverID
				,[inv].[funGetTechnicalNo](D.GoodsID) AS TechnicalNo,H.StoreID HdrStoreID
		  FROM 
		   (		  
			select  a.ProcessID,	a.FiscalYear,	a.SerialNo,	a.DocRowNo FROM inv.tblBaskulSalesDtl a where ProcessID=194 
			 except 
			select b.BaseProcessID,	b.BaseFiscalYear,	b.BaseSerialNo,	b.BaseDocRowNo FROM inv.tblStorageDocsDtl b			 
		  )H1
		  INNER JOIN inv.tblBaskulSalesDtl D ON H1.ProcessID = D.ProcessID And H1.FiscalYear = D.FiscalYear And H1.SerialNo = D.SerialNo And H1.DocRowNo = D.DocRowNo
		  INNER JOIN inv.tblBaskulSalesHdr H ON H.ProcessID = D.ProcessID And H.SerialNo = D.SerialNo
		  WHERE H.ProcessID = @ProcessID And H.SerialNo = @SerialNo
		  and (@AcntCode IS NULL OR   D.AcntCodeDtl = @AcntCode) 
		 ) A WHERE IsCodeClosed = 0
		 		 	
ELSE IF @ProcessID = 150 -- درخواست خرید
	SELECT * FROM (
	SELECT DISTINCT	acc.funIsCodeClosed(OD.AcntCode) IsCodeClosed,OD.ProcessID, OD.ProcessNo, OD.FiscalYear, OD.SerialNo, OD.RowNo, OD.DocRowNo, 
			OD.DocStep, OD.DocDate, OD.AcntCode, OD.GoodsID, OD.SubUnitID, OD.SubUnitQuantity, '' TransportationCostAcntCode, '' TransportationIncomeAcntCode,
			CMROrderHdr.ConfirmQuantity, OD.GoodsQuantity, OD.DescDtl, OD.OrderDate, 0 As AgreeNo, 0 As HdrAgreeNo,
			'' OtherCostAcntCode, '' OtherIncomeAcntCode, OD.BaseProcessID, OD.BaseProcessNo, OD.BaseFiscalYear,OD.BaseSerialNo, OD.BaseDocRowNo,
			[inv].[funGetTechnicalSpecifications](OD.GoodsID) AS TechnicalSpecifications, OH.DocDesc,OH.DocDesc DocDesc2,
			pub.funGetGoodsName(OD.GoodsID,@LanguageID) AS GoodsName, inv.funGetUnitName(OD.SubUnitID,@LanguageID) AS SubUnitName,
			ExtraField1,ExtraField2,ExtraField3,ExtraField4,ExtraField5
			,[inv].[funGetTechnicalNo](OD.GoodsID) AS TechnicalNo
			,SgnSN1,SgnSN2,SgnSN3,SgnSN4,SgnSN5,OD.StoreID,OH.StoreID HdrStoreID
	FROM	
		(
		Select	CmrCnf.ProcessID , CmrCnf.ProcessNo , CmrCnf.FiscalYear , CmrCnf.SerialNo , CmrCnf.DocRowNo,CmrCnf.DocDate,
				CmrCnf.ConfirmQuantity  - ISNULL(CmrOrder.ConfirmQuantity,0) - ISNULL(InvTempReceipt.ConfirmQuantity,0) - ISNULL(StorageDocs.ConfirmQuantity,0) AS ConfirmQuantity  
		From
			(
				SELECT DISTINCT * 
				FROM  [cmr].[FunGetCmrGoods](@AcntCode,@DocDate) 
			) CmrCnf 
		LEFT JOIN 
			(
				SELECT DISTINCT BaseProcessID,BaseProcessNo,BaseFiscalYear,BaseSerialNo,BaseDocRowNo,ConfirmQuantity
				FROM  [cmr].[FunGetBaseOrderGoods](@AcntCode,@DocDate,1,2,NULL,NULL) 
			) CmrOrder
			ON CmrCnf.ProcessID = CmrOrder.BaseProcessID AND  CmrCnf.ProcessNo = CmrOrder.BaseProcessNo AND 
			   CmrCnf.FiscalYear = CmrOrder.BaseFiscalYear AND CmrCnf.SerialNo = CmrOrder.BaseSerialNo AND 
			   CmrCnf.DocRowNo = CmrOrder.BaseDocRowNo 
		LEFT JOIN
			(
				SELECT DISTINCT BaseProcessID,BaseProcessNo,BaseFiscalYear,BaseSerialNo,BaseDocRowNo,ConfirmQuantity
				FROM  [cmr].[FunGetBaseInvTempReceiptGoods](@AcntCode,@DocDate,1,2,NULL,NULL) 
			) InvTempReceipt
			ON CmrCnf.ProcessID = InvTempReceipt.BaseProcessID AND  CmrCnf.ProcessNo = InvTempReceipt.BaseProcessNo AND 
			   CmrCnf.FiscalYear = InvTempReceipt.BaseFiscalYear AND CmrCnf.SerialNo = InvTempReceipt.BaseSerialNo AND 
		   	   CmrCnf.DocRowNo = InvTempReceipt.BaseDocRowNo 
		LEFT JOIN 
			(
				Select	BaseProcessID , BaseProcessNo , BaseFiscalYear , BaseSerialNo , BaseDocRowNo ,ConfirmQuantity 
				From [cmr].[FunGetBaseStorageDocsGoods](@AcntCode,@DocDate,1,2,@SerialNo,@FiscalYear) 
			) StorageDocs
			ON CmrCnf.ProcessID = StorageDocs.BaseProcessID AND  CmrCnf.ProcessNo = StorageDocs.BaseProcessNo AND 
			   CmrCnf.FiscalYear = StorageDocs.BaseFiscalYear AND CmrCnf.SerialNo = StorageDocs.BaseSerialNo AND 
			   CmrCnf.DocRowNo = StorageDocs.BaseDocRowNo 
		) CMROrderHdr
		INNER JOIN
		cmr.tblCMRDtl OD
		ON OD.ProcessID = CMROrderHdr.ProcessID AND  OD.ProcessNo = CMROrderHdr.ProcessNo AND 
		   OD.FiscalYear = CMROrderHdr.FiscalYear AND OD.SerialNo = CMROrderHdr.SerialNo AND 
		   OD.DocRowNo = CMROrderHdr.DocRowNo 
		INNER JOIN
		cmr.tblCMRHdr OH
		ON OH.ProcessID = CMROrderHdr.ProcessID AND  OH.ProcessNo = CMROrderHdr.ProcessNo AND 
		   OH.FiscalYear = CMROrderHdr.FiscalYear AND OH.SerialNo = CMROrderHdr.SerialNo		   
   		INNER JOIN
		(SELECT GoodsID,ExtraField1,ExtraField2,ExtraField3,ExtraField4,ExtraField5 
		 FROM inv.tblGoods WHERE CodeClosed = 'False'    AND PartNumber = @UnitPart) G
		ON SUBSTRING(OD.GoodsID,@str_Goods+1,@str_GoodsSum) = G.GoodsID 
	WHERE OD.ProcessID=@ProcessID AND OD.FiscalYear=@FiscalYear AND OD.SerialNo=@SerialNo AND 
		 (@AcntCode IS NULL OR OD.AcntCode = @AcntCode) AND OD.DocDate<=@DocDate AND CMROrderHdr.ConfirmQuantity>0 
	) A WHERE IsCodeClosed = 0
		And	(
			(@ConfirmCount= 0)
			OR (@ConfirmCount = 1 AND SgnSN1 <> 0)
			OR (@ConfirmCount = 2 AND SgnSN1 <> 0 AND SgnSN2 <> 0)
			OR (@ConfirmCount = 3 AND SgnSN1 <> 0 AND SgnSN2 <> 0 AND SgnSN3 <> 0)
			OR (@ConfirmCount = 4 AND SgnSN1 <> 0 AND SgnSN2 <> 0 AND SgnSN3 <> 0 AND SgnSN4 <> 0)
			OR (@ConfirmCount = 5 AND SgnSN1 <> 0 AND SgnSN2 <> 0 AND SgnSN3 <> 0 AND SgnSN4 <> 0 AND SgnSN5 <> 0)
			)	
		 		 	
END
GO
