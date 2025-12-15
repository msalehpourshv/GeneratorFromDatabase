USE TS_ShirinVatanKarkhaneh_1_1404
GO
SET ANSI_NULLS, QUOTED_IDENTIFIER ON
GO
-- =========== TS-QC:NOTOK ========================
-- Author        : Hadi Sadeghi
-- Create date   : 86/12/04
-- Viewed By	 : 
-- Last Modified : 93/07/26
-- Description   : 
-- =============================================
Create PROCEDURE [sal].[spFrmSaleOrderLoadConfirmDoc]
	 @ProcessID		tinyint,
	 @ProcessNo		tinyint,
	 @FiscalYear	smallint,
	 @SerialNo		int,
	 @DocDate		char(10),
	 @AcntCode		Varchar(20),
	 @LanguageID	Tinyint,
	 @ExtraParams		NVarChar(Max) 
 
WITH ENCRYPTION
AS
BEGIN
SET NOCOUNT ON;
---------------------------------------------

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

	--==============
	DECLARE @UnitPart TINYINT
	SET @UnitPart  = 1

	SELECT @UnitPart = SettingValue from pub.tblSettings where SettingKey = 'UnitPart'

	IF @UnitPart IS NULL or @UnitPart = 0
		SET @UnitPart = 1

	DECLARE @str_Goods  tinyint,
			@str_GoodsSum tinyint

	SELECT @str_Goods = ISNULL(SUM (Layer1+Layer2+Layer3+Layer4+Layer5+Layer6+Layer7+Layer8+Layer9),0)
	FROM pub.tblCodeLayer 
	WHERE TableName = 'inv.tblGoods' AND PartNumber<@UnitPart

	SELECT @str_GoodsSum = Layer1+Layer2+Layer3+Layer4+Layer5+Layer6+Layer7+Layer8+Layer9
	FROM pub.tblCodeLayer 
	WHERE TableName = 'inv.tblGoods' AND PartNumber=@UnitPart

---------------------------------------------
IF @ProcessID = 240
BEGIN
	DECLARE @DocStep1 tinyint
	DECLARE @HasConfirmForPreSale AS BIT
	DECLARE @salNotShowPresaleIfRemain AS BIT
	
	SET @HasConfirmForPreSale = 'False'
	SET @salNotShowPresaleIfRemain = 'False'
	
	SELECT @HasConfirmForPreSale=SettingValue			FROM pub.tblSettings	WHERE SettingKey = 'HasConfirmForPreSale'	
	SELECT @salNotShowPresaleIfRemain = SettingValue	FROM pub.tblSettings	WHERE SettingKey = 'salNotShowPresaleIfRemain'

	Declare @InSaleOrderDonotShowWithoutVchNoInPreSale AS bit
	SELECT @InSaleOrderDonotShowWithoutVchNoInPreSale = SettingValue FROM pub.tblSettings WHERE SettingKey = 'InSaleOrderDonotShowWithoutVchNoInPreSale'
	SET @InSaleOrderDonotShowWithoutVchNoInPreSale = ISNULL(@InSaleOrderDonotShowWithoutVchNoInPreSale, 'False')	

	--=====
	IF @HasConfirmForPreSale = 'False' 
		SET @DocStep1 = 1
	ELSE
		SET @DocStep1 = 2
		
	SELECT acc.funIsCodeClosed (Cd1.AcntCode) IsCodeClosed, Cd1.ProcessID, Cd1.ProcessNo, Cd1.FiscalYear, Cd1.SerialNo, Cd1.RowNo,
           Cd1.SubUnitID, 
		   SubUnitQuantity SubUnitQuantity,
		   Cd1.DocRowNo, Cd1.DocStep, 
		   CH.DiscountPercent,CH.DiscountPercent2,CH.Discount,CH.Discount2, Cd1.Discount DiscountDtl, Cd1.DiscountPercent As DiscountPercentDtl,
		   Cd1.ProcessID BaseProcessID,Cd1.ProcessNo BaseProcessNo, Cd1.FiscalYear BaseFiscalYear,Cd1.SerialNo BaseSerialNo, Cd1.DocRowNo BaseDocRowNo,
		   Cd1.DocDate, Cd1.AcntCode, Cd1.GoodsID, Cd1.StoreID, CH.StoreID HdrStoreID, 
		   UnitID GSubUnitID, Drv.GoodsQuantity GSubUnitQuantity, Cd1.SubUnitID, Cd1.SubUnitQuantity,
		   Cd1.TaxOverWorthCostDtl, Cd1.TollOverWorthCostDtl, Drv.GoodsQuantity, GoodsAmount GoodsPrice, GoodsAmount SubUnitPrice, 
		   Cd1.DescDtl, pub.funGetGoodsName (Cd1.GoodsID,@LanguageID) AS GoodsName, 
		   inv.funGetUnitName (Cd1.SubUnitID,@LanguageID) AS SubUnitName, CH.HasNoReward,CH.HasNoDiscountDtl, CH.PayOffTypeID,
		   CH.CurrencyTypeID, CH.CurrencyRate, Cd1.CurrencyAmount, CH.CurrencyDiscount, CH.CurrencyTransportationCost, CH.CurrencyTransportationIncome, CH.LocationID,
		   CH.TransportationCost, CH.TransportationIncome, Cd1.Var1, Cd1.Var2, Cd1.Var3, Cd1.Var4,
		   CH.VisitorAcntCode VisitorAcntCodeHdr, CH.VisitorPercent VisitorPercentHdr, CH.VisitorCost, CH.PackingCost, CH.TaxCost, CH.TaxOverWorthCost, CH.TollOverWorthCost, CH.OtherCost, 
		   CH.VisitorAcntCode2 VisitorAcntCodeHdr2, CH.VisitorPercent2 VisitorPercentHdr2, CH.VisitorCost2, Cd1.VisitorAcntCode, Cd1.VisitorPercent, Cd1.VisitorPercent2,
		   CH.OtherIncome ,ISNULL(Cd1.SaleTypeID,'') SaleTypeID, ISNULL(STD.SaleTypeName,'') SaleTypeName,  CH.SaleTypeID As HSaleTypeID, 
		   [inv].[funGetTechnicalSpecifications] (Cd1.GoodsID) AS TechnicalSpecifications,
		   inv.funGetUnitName(UnitID,@LanguageID) AS SubUnitName,
		   [inv].[funGetGoodsRemain] (NULL,NULL,NULL,NULL,NULL,NULL,Cd1.GoodsID,'',@DocDate,0) AS GoodsRemain,
		   [sal].[funGetSaleOrderGoodsRemain] (Cd1.GoodsID,@DocDate,Cd1.FiscalYear,0) AS SaleOrderRemain,
		   Cd1.ConstText1,Cd1.ConstText2,Cd1.ConstText3,Cd1.ConstText4,
		   CH.DocDesc,CH.DocDesc2,
		   CH.AgreeNo,
		   Cd1.UserPriceID, 
		   ISNULL((SELECT UParams FROM inv.tblGoodsUserPrice p WHERE p.ID = Cd1.UserPriceID) ,'') AS UserPrice, 
		   Cd1.DiscountOneGoods, 
		   CH.GoodsReciverID,
		   inv.FunGetGoodsWeight (Cd1.GoodsID) * Drv.GoodsQuantity GoodsWeight,
		   inv.FunGetGoodsVolume (Cd1.GoodsID) * Drv.GoodsQuantity GoodsVol,
		   inv.funGetExtraField1 (Cd1.GoodsID) ExtraField1,
		   inv.funGetExtraField2 (Cd1.GoodsID) ExtraField2,
		   inv.funGetExtraField3 (Cd1.GoodsID) ExtraField3,
		   inv.funGetExtraField4 (Cd1.GoodsID) ExtraField4,
		   inv.funGetExtraField5 (Cd1.GoodsID) ExtraField5
	FROM inv.tblPreSaleDtl AS Cd1
	INNER JOIN (SELECT ProcessID,ProcessNo,FiscalYear,SerialNo 
				FROM inv.tblPreSaleHdr 
				except	
				SELECT BaseProcessID,BaseProcessNo,BaseFiscalYear,BaseSerialNo 
				FROM inv.tblStorageDocsDtl 
				WHERE ProcessID = 90 
				  AND BaseProcessID = 240)S	ON Cd1.ProcessID = S.ProcessID 
										   AND Cd1.ProcessNo = S.ProcessNo 
										   AND Cd1.FiscalYear = S.FiscalYear 
										   AND Cd1.SerialNo = S.SerialNo
	INNER JOIN (SELECT * 
				FROM inv.tblPreSaleHdr a
				WHERE ConfirmState <> 2 
				  AND (@salNotShowPresaleIfRemain = 'False' OR (@salNotShowPresaleIfRemain = 'True' AND (SELECT COUNT(*) 
																										 FROM sal.tblSaleOrderDtl b 
																										 WHERE a.ProcessID = b.BaseProcessID 
																										   AND a.ProcessNo = b.BaseProcessNo 
																										   AND a.FiscalYear = b.BaseFiscalYear 
																										   AND a.SerialNo = b.BaseSerialNo)=0 ))
				  AND (@InSaleOrderDonotShowWithoutVchNoInPreSale = 'False' OR VchNo<>0)) AS CH	ON Cd1.ProcessID = CH.ProcessID 
																							   AND Cd1.ProcessNo = CH.ProcessNo 
																							   AND Cd1.FiscalYear = CH.FiscalYear 
																							   AND Cd1.SerialNo = CH.SerialNo
	INNER JOIN inv.tblGoods G ON SUBSTRING(Cd1.GoodsID, @str_Goods+1, @str_GoodsSum) = G.GoodsID 
							 AND G.PartNumber = @UnitPart
	INNER JOIN (SELECT Cnf.ProcessID, Cnf.ProcessNo, Cnf.FiscalYear, Cnf.SerialNo, Cnf.DocRowNo, Cnf.GoodsQuantity - ISNULL(Rtn.GoodsQuantity,0)  AS GoodsQuantity, DocDate, AcntCode
				FROM (SELECT ProcessID, ProcessNo, FiscalYear, SerialNo, DocRowNo,GoodsQuantity GoodsQuantity, DocDate, AcntCode 
					  FROM inv.tblPreSaleDtl
					  --برای استفاده پیش فاکنور ها در سفارش های  1و2
					  WHERE ProcessID = @ProcessID 
						AND FiscalYear = @FiscalYear 
						AND SerialNo = @SerialNo 
						AND  (@AcntCode IS NULL OR AcntCode LIKE  @AcntCode + '%' ) 
						--ProcessNo=@ProcessNo AND 
					 ) Cnf
				LEFT JOIN (SELECT BaseProcessID, BaseProcessNo, BaseFiscalYear, BaseSerialNo, BaseDocRowNo, SUM(GoodsQuantity) GoodsQuantity
						   FROM sal.tblSaleOrderDtl 
						   --برای استفاده پیش فاکنور ها در سفارش های 1و2
						   WHERE BaseProcessID = @ProcessID 
						     AND BaseFiscalYear = @FiscalYear 
							 AND BaseSerialNo = @SerialNo 
							 AND (@AcntCode IS NULL OR AcntCode LIKE  @AcntCode + '%' ) 
							 --BaseProcessNo=@ProcessNo AND 
						   Group BY BaseProcessID, BaseProcessNo, BaseFiscalYear, BaseSerialNo, BaseDocRowNo) Rtn ON Cnf.ProcessID = Rtn.BaseProcessID 
																												 AND Cnf.ProcessNo = Rtn.BaseProcessNo 
																												 AND Cnf.FiscalYear = Rtn.BaseFiscalYear 
																												 AND Cnf.SerialNo = Rtn.BaseSerialNo 
																												 AND Cnf.DocRowNo = Rtn.BaseDocRowNo
				WHERE Cnf.GoodsQuantity - ISNULL(Rtn.GoodsQuantity,0) > 0) Drv ON Cd1.ProcessID = Drv.ProcessID 
																			  AND Cd1.ProcessNo = Drv.ProcessNo 
																			  AND Cd1.FiscalYear = Drv.FiscalYear 
																			  AND Cd1.SerialNo = Drv.SerialNo 
																			  AND Cd1.DocRowNo = Drv.DocRowNo 
	LEFT JOIN sal.tblSaleTypesDtl STD ON Cd1.SaleTypeID = STD.SaleTypeID
	WHERE CH.DocStep = @DocStep1 
	  AND (@AcntCode IS NULL OR Cd1.AcntCode LIKE  @AcntCode + '%') 
	  AND Cd1.DocDate <= @DocDate 
	  AND ((@ConfirmCount = 0 AND ((@Confirm = 0 AND CH.DocStep = 1) OR (@Confirm = 1 AND CH.DocStep = 2))) OR 
		   (@ConfirmCount > 0 AND ((@Sgn1 = 0 AND SgnSN1 = 0) OR (@Sgn1 > 0 AND CH.SgnSN1 > 0))
				  			  AND ((@Sgn2 = 0 AND SgnSN2 = 0) OR (@Sgn2 > 0 AND CH.SgnSN2 > 0))
							  AND ((@Sgn3 = 0 AND SgnSN3 = 0) OR (@Sgn3 > 0 AND CH.SgnSN3 > 0))
							  AND ((@Sgn4 = 0 AND SgnSN4 = 0) OR (@Sgn4 > 0 AND CH.SgnSN4 > 0))
							  AND ((@Sgn5 = 0 AND SgnSN5 = 0) OR (@Sgn5 > 0 AND CH.SgnSN5 > 0))))	
	ORDER BY Cd1.FiscalYear, Cd1.SerialNo, Cd1.DocRowNo
END

ELSE
	BEGIN
	DECLARE @SalOrder_ConfirmDocStep Nvarchar(100)
	DECLARE @DocStep tinyint
	DECLARE @SalRet_RetToSalOdr AS BIT
	DECLARE @DontCheckProcessNoInSale AS BIT

	SET @SalOrder_ConfirmDocStep = 'False'
	SET @SalRet_RetToSalOdr = 'False'
	SET @DontCheckProcessNoInSale = 'False'
	
	SELECT @SalRet_RetToSalOdr = SettingValue
	FROM pub.tblSettings
	WHERE SettingKey = 'SalRet_RetToSalOdr' 
	
	SELECT @SalOrder_ConfirmDocStep=SettingValue
	FROM pub.tblSettings
	WHERE SettingKey = 'SalOrder_ConfirmDocStep'

	SELECT @DontCheckProcessNoInSale=SettingValue
	FROM pub.tblSettings
	WHERE SettingKey = 'DontCheckProcessNoInSale'
					
	IF @DontCheckProcessNoInSale = 'True'
		SET @ProcessNo = NULL			

	IF @SalOrder_ConfirmDocStep = 'False' 
		SET @DocStep = 1
	ELSE
		SET @DocStep = 2
		Print @DocStep
		Print @str_Goods
		Print @str_GoodsSum
		Print @UnitPart
		Print @SalRet_RetToSalOdr		 

		SELECT * 
		FROM (SELECT acc.funIsCodeClosed(Cd1.AcntCode) IsCodeClosed, Cd1.ProcessID, Cd1.ProcessNo, Cd1.FiscalYear, Cd1.SerialNo, Cd1.RowNo, 
					 Cd1.DocRowNo, Cd1.DocStep, CH.DiscountPercent, CH.DiscountPercent2,CH.Discount, CH.Discount2, Cd1.DiscountPercentDtl, Cd1.DiscountDtl, Cd1.TaxOverWorthCostDtl,
					 Cd1.TollOverWorthCostDtl, Cd1.DocDate, Cd1.AcntCode, Cd1.GoodsID, Cd1.SubUnitID, Cd1.UserPriceID, 
					 IsNull((Select UParams From inv.tblGoodsUserPrice p Where p.ID=Cd1.UserPriceID) ,'') as UserPrice,
					 inv.funGetSubUnitFromGoodsQuantity(Cd1.GoodsID,Cd1.SubUnitID,Drv.GoodsQuantity) SubUnitQuantity1,
					 inv.funGetSubUnitFromGoodsQuantity(Cd1.GoodsID,Cd1.SubUnitID,Drv.GoodsQuantity) SubUnitQuantity, 
					 Drv.GoodsQuantity, Cd1.GoodsPrice, Cd1.SubUnitPrice, Cd1.SubUnitPrice2, Cd1.DescDtl, Cd1.OrderDate, Cd1.BaseProcessID, Cd1.BaseProcessNo, Cd1.BaseFiscalYear, 
					 Cd1.BaseSerialNo, Cd1.BaseDocRowNo, Cd1.AgreeNo, '' StoreID, CH.StoreID HdrStoreID,CH.TransportationCostAcntCode, 
					 CH.TransportationCost, CH.TransportationIncomeAcntCode, CH.TransportationIncome, CH.VisitorAcntCode VisitorAcntCodeHdr,
					 CH.VisitorPercent VisitorPercentHdr, CH.VisitorCost, CH.PackingCost, CH.TaxCost, CH.TaxOverWorthCost, CH.TollOverWorthCost, 
					 CH.VisitorAcntCode2 VisitorAcntCodeHdr2, CH.VisitorPercent2 VisitorPercentHdr2, CH.VisitorCost2, Cd1.VisitorAcntCode, 
					 Cd1.VisitorPercent, CH.OtherCostAcntCode, CH.OtherCost, CH.OtherIncomeAcntCode, CH.OtherIncome ,CH.SaleTypeID As HSaleTypeID, 
					 Cd1.SaleTypeID, ISNULL(STD.SaleTypeName,'') SaleTypeName , Cd1.ConstText1,Cd1.ConstText2,Cd1.ConstText3,Cd1.ConstText4,CH.HasNoReward,CH.HasNoDiscountDtl, CH.PayOffTypeID,
					 pub.funGetGoodsName(Cd1.GoodsID,@LanguageID) AS GoodsName, [inv].[funGetTechnicalSpecifications](Cd1.GoodsID) AS TechnicalSpecifications, 
					 CH.CurrencyTypeID, CH.CurrencyRate, CH.CurrencyDiscount, CH.CurrencyTransportationCost, CH.CurrencyTransportationIncome, Cd1.CurrencyAmount, CH.LocationID, 
					 inv.funGetUnitName(Cd1.SubUnitID,@LanguageID) AS SubUnitName,
					 SgnSN1,SgnSN2,SgnSN3,SgnSN4,SgnSN5,Cd1.OtherIncomePerentDtl,Cd1.OtherIncomeDtl,Cd1.BatchNo,
					 inv.FunGetGoodsWeight(Cd1.GoodsID) * Drv.GoodsQuantity GoodsWeight,
					 inv.FunGetGoodsVolume(Cd1.GoodsID) * Drv.GoodsQuantity GoodsVol,
					 inv.funGetExtraField1 (Cd1.GoodsID) ExtraField1,
					 inv.funGetExtraField2 (Cd1.GoodsID) ExtraField2,
					 inv.funGetExtraField3 (Cd1.GoodsID) ExtraField3,
					 inv.funGetExtraField4 (Cd1.GoodsID) ExtraField4,
					 inv.funGetExtraField5 (Cd1.GoodsID) ExtraField5
			  FROM sal.tblSaleOrderDtl AS Cd1 
			  INNER JOIN (SELECT ProcessID, ProcessNo, FiscalYear, SerialNo, DocRowNo,
								 SubUnitID,SubUnitQuantity,ConfirmQuantity as  GoodsQuantity ,DocDate,AcntCode
						  FROM  [cmr].[FunGetSaleOrder](@AcntCode,@DocDate,@DocStep,@SalRet_RetToSalOdr,@FiscalYear,@SerialNo) 
						  WHERE (@ProcessNo IS NULL OR ProcessNo = @ProcessNo) 
						    AND SerialNo = @SerialNo 
							AND FiscalYear = @FiscalYear) Drv ON Cd1.ProcessID = Drv.ProcessID 
															 AND Cd1.ProcessNo = Drv.ProcessNo 
															 AND Cd1.FiscalYear = Drv.FiscalYear 
															 AND Cd1.SerialNo = Drv.SerialNo 
															 AND Cd1.DocRowNo = Drv.DocRowNo 
			  INNER JOIN sal.tblSaleOrderHdr AS CH ON Cd1.ProcessID = CH.ProcessID 
												  AND Cd1.ProcessNo = CH.ProcessNo 
												  AND Cd1.FiscalYear = CH.FiscalYear 
												  AND Cd1.SerialNo = CH.SerialNo
			  LEFT JOIN (SELECT GoodsID 
						 FROM inv.tblGoods 
						 WHERE CodeClosed = 'False' 
						   AND PartNumber = @UnitPart) G ON SUBSTRING(Cd1.GoodsID,@str_Goods+1,@str_GoodsSum) = G.GoodsID
			  LEFT JOIN sal.tblSaleTypesDtl STD ON Cd1.SaleTypeID = STD.SaleTypeID
			  LEFT JOIN (SELECT * 
						 FROM inv.tblSubUnitsDtl 
						 WHERE ShowInInvoice='True') SU ON SUBSTRING(Cd1.GoodsID,@str_Goods+1,@str_GoodsSum) = SU.GoodsID
			  WHERE (@AcntCode IS NULL OR Cd1.AcntCode = @AcntCode) 
			    AND Cd1.DocDate <= @DocDate) A 
		WHERE IsCodeClosed = 0 AND ((@ConfirmCount = 0 AND ((@Confirm = 0 AND DocStep in (1,2)) OR (@Confirm = 1 AND DocStep = 2))) OR 
									(@ConfirmCount > 0 AND ((@Sgn1 = 0 AND SgnSN1 = 0) OR (@Sgn1 > 0 AND SgnSN1 > 0)) 
													   AND ((@Sgn2 = 0 AND SgnSN2 = 0) OR (@Sgn2 > 0 AND SgnSN2 > 0))
													   AND ((@Sgn3 = 0 AND SgnSN3 = 0) OR (@Sgn3 > 0 AND SgnSN3 > 0))
													   AND ((@Sgn4 = 0 AND SgnSN4 = 0) OR (@Sgn4 > 0 AND SgnSN4 > 0))
													   AND ((@Sgn5 = 0 AND SgnSN5 = 0) OR (@Sgn5 > 0 AND SgnSN5 > 0))))	
	END
END
GO
