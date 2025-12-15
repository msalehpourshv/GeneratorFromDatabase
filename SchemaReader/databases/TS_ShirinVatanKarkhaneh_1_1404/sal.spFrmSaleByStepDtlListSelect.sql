USE TS_ShirinVatanKarkhaneh_1_1404
GO
SET ANSI_NULLS, QUOTED_IDENTIFIER ON
GO
-- =========== TS-QC:NOTOK =====================
-- Author        : Hadi Sadeghi
-- Create date   : 86/12/01
-- Viewed By	 : 
-- Last Modified : 
-- Description   : 
-- =============================================
Create PROCEDURE [sal].[spFrmSaleByStepDtlListSelect]

	@ProcessID	Tinyint,
	@ProcessNo	Tinyint,
	@StoreID    Varchar(20),
	@AcntCode	VarChar(20),
	@GoodsID	VarChar(20),
	@DocDate	Char(10),
	@LanguageID Int,
	@SerialNo	Int,
	@FiscalYear Smallint,
	@BaseSerialNo	Int,
	@BaseFiscalYear Smallint   ,
	@ExtraParams		NVarChar(Max) 

WITH ENCRYPTION
 AS
BEGIN

SET NOCOUNT ON;
	DECLARE @FromDate	VarChar(10)
	DECLARE @ToDate	VarChar(10)
	DECLARE @FromFiscalYear	Int
	DECLARE @FromSerialNo	Int
	DECLARE @ToFiscalYear	Int
	DECLARE @ToSerialNo		Int
	DECLARE @FilterGoodsID	VarChar(20)

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

	
declare @Var1 float
declare @Var2 float
declare @Var3 float
declare @Var4 float
declare @CT1 Nvarchar(100)
declare @CT2 Nvarchar(100)
declare @CT3 Nvarchar(100)
declare @CT4 Nvarchar(100)
DECLARE @DontCheckProcessNoInSale AS BIT
	SET @DontCheckProcessNoInSale = 'False'

	SELECT @DontCheckProcessNoInSale=SettingValue
	FROM pub.tblSettings
	WHERE SettingKey = 'DontCheckProcessNoInSale'

SET @Var1				= LTrim(pub.funSplitString(@ExtraParams, '@', 1)); 
SET @Var2				= LTrim(pub.funSplitString(@ExtraParams, '@', 2)); 
SET @Var3				= LTrim(pub.funSplitString(@ExtraParams, '@', 3));
SET @Var4				= LTrim(pub.funSplitString(@ExtraParams, '@', 4)); 
SET @CT1				= LTrim(pub.funSplitString(@ExtraParams, '@', 5)); 
SET @CT2				= LTrim(pub.funSplitString(@ExtraParams, '@', 6)); 
SET @CT3				= LTrim(pub.funSplitString(@ExtraParams, '@', 7)); 
SET @CT4				= LTrim(pub.funSplitString(@ExtraParams, '@', 8)); 

SET @FromDate			= LTrim(pub.funSplitString(@ExtraParams, '@', 9)); 
SET @ToDate				= LTrim(pub.funSplitString(@ExtraParams, '@', 10)); 
SET @FromFiscalYear		= LTrim(pub.funSplitString(@ExtraParams, '@', 11)); 
SET @FromSerialNo		= LTrim(pub.funSplitString(@ExtraParams, '@', 12)); 
SET @ToFiscalYear		= LTrim(pub.funSplitString(@ExtraParams, '@', 13)); 
SET @ToSerialNo			= LTrim(pub.funSplitString(@ExtraParams, '@', 14)); 
SET @FilterGoodsID		= LTrim(pub.funSplitString(@ExtraParams, '@', 15)); 

--select  @Var1 , @Var2, @Var3, @Var4, @CT1 , @CT2 , @CT3 , @CT4 

IF @ProcessID = 240 
	BEGIN
		DECLARE @DocStep1 tinyint
		DECLARE @HasConfirmForPreSale AS BIT
		DECLARE @PreSal_GetRemain AS BIT
		
		SET @HasConfirmForPreSale = 'False'
		SET @PreSal_GetRemain = 'False'
		
		SELECT @PreSal_GetRemain=SettingValue
		FROM pub.tblSettings
		WHERE SettingKey = 'PreSal_GetRemain'
			
		SELECT @HasConfirmForPreSale=SettingValue
		FROM pub.tblSettings
		WHERE SettingKey = 'HasConfirmForPreSale'

		DECLARE @ConfirmCountInPreSale AS  TinyInt;
		SET @ConfirmCountInPreSale = 0
		SELECT @ConfirmCountInPreSale = SettingValue
		FROM pub.tblSettings
		WHERE SettingKey = 'ConfirmCountInPreSale'

		IF @HasConfirmForPreSale = 'False' 
			SET @DocStep1 = 1
		ELSE
			SET @DocStep1 = 2
			
			IF @PreSal_GetRemain = 'False'
				SELECT * FROM (
					SELECT   acc.funIsCodeClosed(OD.AcntCode) IsCodeClosed,OD.ProcessID, OD.ProcessNo, OD.FiscalYear, OD.SerialNo, OD.RowNo, OD.DocRowNo,
							1 DocStep,OD.DescDtl, OD.DocDate, OD.AcntCode, OD.GoodsID, pub.funGetGoodsUnitID(OD.GoodsID) as SubUnitID, 
							CMRSaleOrderHdr.ConfirmQuantity AS SubUnitQuantity, CMRSaleOrderHdr.ConfirmQuantity,
							[inv].[funGetTechnicalSpecifications](OD.GoodsID) AS TechnicalSpecifications,OD.ConstText1,OD.ConstText2,OD.ConstText3,OD.ConstText4,
							pub.funGetGoodsName(OD.GoodsID,@LanguageID) AS GoodsName,pub.funGetGoodsUnitName(OD.GoodsID,@LanguageID) AS SubUnitName  ,OD.VisitorAcntCode,
							[inv].[funGetGoodsRemain](null,null,null,null,null,@StoreID,OD.GoodsID,'',@DocDate,0) GoodsRemain,OD.Var1,OD.Var2,OD.Var3,OD.Var4
							,OD.GoodsAmount,OD.GoodsAmount GoodsPrice ,OD.GoodsAmount  SubUnitPrice,TaxOverWorthCostDtl	,TollOverWorthCostDtl,OD.Discount DiscountDtl,OD.StoreID
							,PH.SgnSN1,PH.SgnSN2,PH.SgnSN3,PH.SgnSN4,PH.SgnSN5,[inv].[funGetTechnicalNo](OD.GoodsID) AS TechnicalNo,OD.UserPriceID,
							IsNull((Select UParams From inv.tblGoodsUserPrice p Where p.ID=OD.UserPriceID) ,'') as UserPrice												
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
					inv.tblPreSaleHdr PH
					ON	OD.ProcessID = PH.ProcessID AND  OD.ProcessNo = PH.ProcessNo AND 
						OD.FiscalYear = PH.FiscalYear AND OD.SerialNo = PH.SerialNo 
					INNER JOIN
					(SELECT GoodsID FROM inv.tblGoods WHERE CodeClosed = 'False' AND PartNumber=@UnitPart  ) G
					ON SUBSTRING(OD.GoodsID,@str_Goods+1,@str_GoodsSum) = G.GoodsID 
					WHERE	(@AcntCode IS NULL OR OD.AcntCode = @AcntCode) AND (@GoodsID IS NULL OR OD.GoodsID = @GoodsID) AND
							PH.ConfirmState <> 2 AND
							OD.DocDate<=@DocDate AND CMRSaleOrderHdr.ConfirmQuantity>0 AND 
   							(@BaseSerialNo IS NULL OR (OD.SerialNo=@BaseSerialNo AND OD.FiscalYear=@BaseFiscalYear)) 
   							and (@Var1 =0 OR OD.Var1 = @Var1  )
							and (@Var2 =0 OR OD.Var2 = @Var2  )
							and (@Var3 =0 OR OD.Var3 = @Var3  )
							and (@Var4 =0 OR OD.Var4 = @Var4  )
							and (@CT1 ='' OR OD.ConstText1 like '%' + @CT1 + '%' )
							and (@CT2 ='' OR OD.ConstText2 like '%' + @CT2 + '%' )
							and (@CT3 ='' OR OD.ConstText3 like '%' + @CT3 + '%' )
							and (@CT4 ='' OR OD.ConstText4 like '%' + @CT4 + '%' )
							And 
							(
								(@ConfirmCountInPreSale= 0)
								OR (@ConfirmCountInPreSale = 1 AND PH.SgnSN1 <> 0)
								OR (@ConfirmCountInPreSale = 2 AND PH.SgnSN1 <> 0 AND PH.SgnSN2 <> 0)
								OR (@ConfirmCountInPreSale = 3 AND PH.SgnSN1 <> 0 AND PH.SgnSN2 <> 0 AND PH.SgnSN3 <> 0)
								OR (@ConfirmCountInPreSale = 4 AND PH.SgnSN1 <> 0 AND PH.SgnSN2 <> 0 AND PH.SgnSN3 <> 0 AND PH.SgnSN4 <> 0)
								OR (@ConfirmCountInPreSale = 5 AND PH.SgnSN1 <> 0 AND PH.SgnSN2 <> 0 AND PH.SgnSN3 <> 0 AND PH.SgnSN4 <> 0 AND PH.SgnSN5 <> 0)
							 )

				) A
				 WHERE IsCodeClosed = 0
			ELSE
				SELECT * FROM (
					SELECT   acc.funIsCodeClosed(OD.AcntCode) IsCodeClosed,OD.ProcessID, OD.ProcessNo, OD.FiscalYear, OD.SerialNo, OD.RowNo, OD.DocRowNo,
							1 DocStep, OD.DescDtl,OD.DocDate, OD.AcntCode, OD.GoodsID, pub.funGetGoodsUnitID(OD.GoodsID) as SubUnitID, 
							CMRSaleOrderHdr.ConfirmQuantity AS SubUnitQuantity, CMRSaleOrderHdr.ConfirmQuantity,
							[inv].[funGetTechnicalSpecifications](OD.GoodsID) AS TechnicalSpecifications,OD.ConstText1,OD.ConstText2,OD.ConstText3,OD.ConstText4,
							pub.funGetGoodsName(OD.GoodsID,@LanguageID) AS GoodsName,pub.funGetGoodsUnitName(OD.GoodsID,@LanguageID) AS SubUnitName  ,OD.VisitorAcntCode,
							[inv].[funGetGoodsRemain](null,null,null,null,null,@StoreID,OD.GoodsID,'',@DocDate,0) GoodsRemain
							,PH.SgnSN1,PH.SgnSN2,PH.SgnSN3,PH.SgnSN4,PH.SgnSN5,OD.Var1,OD.Var2,OD.Var3,OD.Var4,
							OD.GoodsAmount,OD.GoodsAmount GoodsPrice ,OD.GoodsAmount  SubUnitPrice,TaxOverWorthCostDtl	,TollOverWorthCostDtl,OD.Discount DiscountDtl,OD.StoreID
							,[inv].[funGetTechnicalNo](OD.GoodsID) AS TechnicalNo,OD.UserPriceID,
							IsNull((Select UParams From inv.tblGoodsUserPrice p Where p.ID=OD.UserPriceID) ,'') as UserPrice
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
							WHERE Cnf.GoodsQuantity - ISNULL(sd.ConfirmQuantity,0)>0
						) CMRSaleOrderHdr
					INNER JOIN
					inv.tblPreSaleDtl OD
					ON	OD.ProcessID = CMRSaleOrderHdr.ProcessID AND  OD.ProcessNo = CMRSaleOrderHdr.ProcessNo AND 
						OD.FiscalYear = CMRSaleOrderHdr.FiscalYear AND OD.SerialNo = CMRSaleOrderHdr.SerialNo AND 
						OD.DocRowNo = CMRSaleOrderHdr.DocRowNo
					INNER JOIN
					inv.tblPreSaleHdr PH
					ON	OD.ProcessID = PH.ProcessID AND  OD.ProcessNo = PH.ProcessNo AND 
						OD.FiscalYear = PH.FiscalYear AND OD.SerialNo = PH.SerialNo 
					Inner Join (SELECT ProcessID,ProcessNo,FiscalYear,SerialNo from inv.tblPreSaleHdr 
								except	
								SELECT BaseProcessID,BaseProcessNo,BaseFiscalYear,BaseSerialNo from sal.tblSaleOrderDtl where ProcessID=180 and BaseProcessID=240
								)S
					ON PH.ProcessID = S.ProcessID AND PH.ProcessNo = S.ProcessNo AND PH.FiscalYear = S.FiscalYear AND PH.SerialNo = S.SerialNo
					INNER JOIN
					(SELECT GoodsID FROM inv.tblGoods WHERE CodeClosed = 'False' AND PartNumber=@UnitPart  ) G
					ON SUBSTRING(OD.GoodsID,@str_Goods+1,@str_GoodsSum) = G.GoodsID 
					WHERE	PH.DocStep=@DocStep1 AND (@AcntCode IS NULL OR OD.AcntCode = @AcntCode) AND (@GoodsID IS NULL OR OD.GoodsID = @GoodsID) AND
							PH.ConfirmState <> 2 AND
							OD.DocDate<=@DocDate AND CMRSaleOrderHdr.ConfirmQuantity>0 AND 
   							(@BaseSerialNo IS NULL OR (OD.SerialNo=@BaseSerialNo AND OD.FiscalYear=@BaseFiscalYear)) 
							and (@Var1 =0 OR OD.Var1 = @Var1  )
							and (@Var2 =0 OR OD.Var2 = @Var2  )
							and (@Var3 =0 OR OD.Var3 = @Var3  )
							and (@Var4 =0 OR OD.Var4 = @Var4  )
							and (@CT1 ='' OR OD.ConstText1 like '%' + @CT1 + '%' )
							and (@CT2 ='' OR OD.ConstText2 like '%' + @CT2 + '%' )
							and (@CT3 ='' OR OD.ConstText3 like '%' + @CT3 + '%' )
							and (@CT4 ='' OR OD.ConstText4 like '%' + @CT4 + '%' )
							And 
							(
								(@ConfirmCountInPreSale= 0)
								OR (@ConfirmCountInPreSale = 1 AND PH.SgnSN1 <> 0)
								OR (@ConfirmCountInPreSale = 2 AND PH.SgnSN1 <> 0 AND PH.SgnSN2 <> 0)
								OR (@ConfirmCountInPreSale = 3 AND PH.SgnSN1 <> 0 AND PH.SgnSN2 <> 0 AND PH.SgnSN3 <> 0)
								OR (@ConfirmCountInPreSale = 4 AND PH.SgnSN1 <> 0 AND PH.SgnSN2 <> 0 AND PH.SgnSN3 <> 0 AND PH.SgnSN4 <> 0)
								OR (@ConfirmCountInPreSale = 5 AND PH.SgnSN1 <> 0 AND PH.SgnSN2 <> 0 AND PH.SgnSN3 <> 0 AND PH.SgnSN4 <> 0 AND PH.SgnSN5 <> 0)
							 )

				) A
				 WHERE IsCodeClosed = 0
	END	   		   

IF @ProcessID = 91 -- باسکول فروش
	BEGIN
		SELECT *, 0 FiscalYear 
		FROM 
		(
		  SELECT D.*, 0 DiscountDtl, 0 TaxOverWorthCostDtl, 0 TollOverWorthCostDtl, 
				 H.AcntCode, pub.funGetGoodsName(D.GoodsID,@LanguageID) AS GoodsName, 
				 inv.funGetUnitName(D.SubUnitID,@LanguageID) AS SubUnitName, 
				 [inv].[funGetTechnicalSpecifications](D.GoodsID) AS TechnicalSpecifications, 
				 D.SubUnitQuantity As ConfirmQuantity, D.SubUnitQuantity As GoodsQuantity, D.Fee GoodsPrice,
				 D.Fee SubUnitPrice, H.TransportationCost, acc.funIsCodeClosed(H.AcntCode) IsCodeClosed
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
		  WHERE H.ProcessID = @ProcessID And 
				H.SerialNo Not In (SELECT BaseSerialNo
								   FROM inv.tblStorageDocsHdr 
								   WHERE ProcessID = 90 And BaseProcessID = @ProcessID)
		) A WHERE IsCodeClosed = 0
	END
		 		   
ELSE IF @ProcessID = 90 OR @ProcessID = 180
BEGIN
	DECLARE @SalOrder_ConfirmDocStep Nvarchar(100)
	DECLARE @DocStep tinyint
	DECLARE @SalRet_RetToSalOdr AS BIT
	DECLARE @LastPriceInSaleorderForSale AS BIT
	DECLARE @Sal_StoreDtl AS BIT
	DECLARE @AllowSaleOrderSetAcntToOtherCustomer AS BIT

	SET @LastPriceInSaleorderForSale = 'False'
	SET @SalOrder_ConfirmDocStep = 'False'
	SET @SalRet_RetToSalOdr = 'False'
	SET @Sal_StoreDtl = 'False'
	SET @AllowSaleOrderSetAcntToOtherCustomer = 'False'
	
	SELECT @LastPriceInSaleorderForSale=SettingValue FROM pub.tblSettings WHERE SettingKey = 'LastPriceInSaleorderForSale'
	
	SELECT @SalRet_RetToSalOdr = SettingValue FROM pub.tblSettings WHERE SettingKey = 'SalRet_RetToSalOdr' 
	
	SELECT @SalOrder_ConfirmDocStep=SettingValue FROM pub.tblSettings WHERE SettingKey = 'SalOrder_ConfirmDocStep'

	SELECT @Sal_StoreDtl=SettingValue FROM pub.tblSettings WHERE SettingKey = 'Sal_StoreDtl'

	SELECT @AllowSaleOrderSetAcntToOtherCustomer=SettingValue FROM pub.tblSettings WHERE SettingKey = 'AllowSaleOrderSetAcntToOtherCustomer'

	IF @AllowSaleOrderSetAcntToOtherCustomer = 'True'
		SET @AcntCode = NULL
					
	IF @DontCheckProcessNoInSale = 'True'
		SET @ProcessNo = NULL
				
	IF @SalOrder_ConfirmDocStep = 'False' 
		SET @DocStep = 1
	ELSE
		SET @DocStep = 2
		
	SELECT * , inv.funGetGoodsSubQuantity(A.GoodsID,A.SubUnitID,GoodsRemain) SubUnitRemain FROM (
	SELECT   acc.funIsCodeClosed(OD.AcntCode) IsCodeClosed,OD.ProcessID, OD.ProcessNo, OD.FiscalYear, OD.SerialNo, OD.RowNo, OD.DocRowNo,
			OD.DocStep, OD.DocDate, OD.AcntCode, OD.GoodsID, OD.SubUnitID,OD.ConstText1,OD.ConstText2,OD.ConstText3,OD.ConstText4,
			inv.funGetGoodsSubQuantity(OD.GoodsID,OD.SubUnitID,CMRSaleOrderHdr.ConfirmQuantity) SubUnitQuantity, 
			CMRSaleOrderHdr.ConfirmQuantity,CMRSaleOrderHdr.ConfirmQuantity GoodsQuantity, OD.DescDtl, OD.VisitorPercent,
			IsNull(CMRSaleOrderHdr.CurrencyTypeID, '') CurrencyTypeID, IsNull(CMRSaleOrderHdr.CurrencyRate, 0) CurrencyRate,
			OD.BaseProcessID, OD.BaseProcessNo, OD.BaseFiscalYear,OD.BaseSerialNo, OD.BaseDocRowNo, OD.TaxOverWorthCostDtl, 
			OD.TollOverWorthCostDtl, OD.DiscountPercentDtl, OD.DiscountDtl, 
			[inv].[funGetTechnicalSpecifications](OD.GoodsID) AS TechnicalSpecifications,DfStoreID as StoreID,
			pub.funGetGoodsName(OD.GoodsID,@LanguageID) AS GoodsName,inv.funGetUnitName(OD.SubUnitID,@LanguageID) AS SubUnitName,
			[inv].[funGetGoodsRemain](@ProcessID,@ProcessNo,@FiscalYear,@BaseSerialNo,null,CASE WHEN  @Sal_StoreDtl = 'True' and DfStoreID<>'' THEN DfStoreID ELSE @StoreID END,OD.GoodsID,'',@DocDate,0) GoodsRemain ,SubUnitPrice,
			CASE WHEN @LastPriceInSaleorderForSale = 'False' THEN CMRSaleOrderHdr.GoodsPrice 
			ELSE [sal].[funGetGoodsAmountSaleType](OD.GoodsID,'',CMRSaleOrderHdr.DocDate,CMRSaleOrderHdr.SaleTypeID,@LanguageID,0,0) END AS GoodsPrice,
			CMRSaleOrderHdr.SgnSN1, CMRSaleOrderHdr.SgnSN2, CMRSaleOrderHdr.SgnSN3, CMRSaleOrderHdr.SgnSN4, CMRSaleOrderHdr.SgnSN5,OD.SaleTypeID
			,[inv].[funGetTechnicalNo](OD.GoodsID) AS TechnicalNo
			,OD.OtherIncomePerentDtl,OD.OtherIncomeDtl
	FROM	
		(
		Select	CmrCnf.ProcessID ,CmrCnf.ProcessNo ,CmrCnf.FiscalYear ,CmrCnf.SerialNo ,CmrCnf.DocRowNo, CmrCnf.DocDate,
				CmrCnf.ConfirmQuantity  AS ConfirmQuantity ,GoodsPrice, SaleTypeID, CmrCnf.CurrencyTypeID, CmrCnf.CurrencyRate,
				CmrCnf.SgnSN1, CmrCnf.SgnSN2, CmrCnf.SgnSN3, CmrCnf.SgnSN4, CmrCnf.SgnSN5
				--CmrCnf.ConfirmQuantity - ISNULL(CmrOrder.ConfirmQuantity,0) AS ConfirmQuantity ,GoodsPrice,SaleTypeID
		From
			(
				SELECT DISTINCT * 
				FROM  [cmr].[FunGetSaleOrder](@AcntCode,@DocDate,@DocStep,@SalRet_RetToSalOdr,@FiscalYear,@BaseSerialNo) 
				WHERE (@ProcessNo IS NULL OR ProcessNo = @ProcessNo)			
			) CmrCnf 
		--LEFT JOIN 
		--	(
		--		SELECT DISTINCT BaseProcessID,BaseProcessNo,BaseFiscalYear,BaseSerialNo,BaseDocRowNo,ConfirmQuantity
		--		FvROM  [cmr].[FunGetBaseSaleGoods](@AcntCode,@DocDate,1,2,@SerialNo,@FiscalYear)
		--		WHERE (@GoodsID IS NULL OR GoodsID = @GoodsID)  
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
	(SELECT GoodsID,DfStoreID FROM inv.tblGoods WHERE CodeClosed = 'False' AND PartNumber=@UnitPart  ) G
	ON SUBSTRING(OD.GoodsID,@str_Goods+1,@str_GoodsSum) = G.GoodsID 
	WHERE	(@AcntCode IS NULL OR OD.AcntCode = @AcntCode) AND  (@GoodsID IS NULL OR OD.GoodsID = @GoodsID) AND
			OD.DocDate<=@DocDate AND CMRSaleOrderHdr.ConfirmQuantity>0 AND 
			(@BaseSerialNo IS NULL OR (OD.SerialNo=@BaseSerialNo AND OD.FiscalYear=@BaseFiscalYear)) 
	   AND  (@FilterGoodsID ='' OR OD.GoodsID = @FilterGoodsID)
	   AND  (@FromSerialNo =0 OR (OD.FiscalYear =@FromFiscalYear AND OD.SerialNo >= @FromSerialNo))
	   AND  (@ToSerialNo =0 OR (OD.FiscalYear =@ToFiscalYear AND OD.SerialNo <= @ToSerialNo))
	   AND  (@FromDate ='' OR (OD.DocDate >= @FromDate))
	   AND  (@ToDate ='' OR (OD.DocDate <= @ToDate))
) A
 WHERE IsCodeClosed = 0
			
END
ELSE IF @ProcessID = 55
	BEGIN
		DECLARE @TempFiscalYear SMALLINT
		DECLARE @StrSelect	NVarChar(4000)
		
		SET @TempFiscalYear = RIGHT(DB_NAME(),4)
		
		IF @BaseFiscalYear = 0 OR @BaseFiscalYear IS NULL
			SET @BaseFiscalYear = RIGHT(DB_NAME(),4)
			
		SELECT * INTO ##tblS
		FROM [cmr].[FunGetSale](@AcntCode,@DocDate,@BaseFiscalYear)
		WHERE BaseProcessNo = @ProcessNo	
		
		SET @TempFiscalYear = @TempFiscalYear + 1
		
		WHILE (SELECT COUNT(NAME) from master.sys.databases
			   WHERE name= LEFT(DB_NAME(),LEN(DB_NAME())-4) + LTRIM(STR(@TempFiscalYear)))=1
		   BEGIN
				SET @StrSelect = 'INSERT INTO ##tblS
						SELECT * 
						FROM ' + LEFT(DB_NAME(),LEN(DB_NAME())-4) + LTRIM(STR(@TempFiscalYear)) + '.[inv].[FunGetBuy](''' + ISNULL(@AcntCode,'') + ''',''' + @DocDate + ''',' + LTRIM(STR(@BaseFiscalYear)) + ')
						WHERE BaseProcessNo = ' + LTRIM(STR(@ProcessNo))
				PRINT @StrSelect
				Exec sp_executesql @StrSelect; 
				SET @TempFiscalYear = @TempFiscalYear + 1	   	
		   END
				  
		SELECT * FROM (
			SELECT   acc.funIsCodeClosed(OD.AcntCode) IsCodeClosed,	OD.ProcessID, OD.ProcessNo, OD.FiscalYear, OD.SerialNo, OD.RowNo, OD.VolumeRowNo, OD.DocStep, 
					OD.DocDate, OD.StoreID, OD.EnterKind, OD.StoreID2, OD.AcntCode, OD.VisitorAcntCode, BatchNo ,
					OD.OrderAcntCode, OD.GoodsID, UnitID SubUnitID, (OD.GoodsQuantity) SubUnitQuantity, (OD.GoodsQuantity ) ConfirmQuantity, OD.QtyRemain, 
					OD.GoodsAmount, OD.AtomAmount, OD.GoodsPrice, OD.DescDtl, OD.BaseProcessID,OD.DiscountPercentDtl,(DiscountDtl * (OD.GoodsQuantity))/OD.GoodsQuantity as DiscountDtl, 
					OD.BaseProcessNo, OD.BaseFiscalYear, OD.BaseSerialNo, OD.BaseDocRowNo, OD.AgreeNo, OD.DocRowNo,
					[inv].[funGetTechnicalSpecifications](OD.GoodsID) AS TechnicalSpecifications,
					pub.funGetGoodsName(OD.GoodsID,@LanguageID) AS GoodsName, inv.funGetUnitName(UnitID,@LanguageID) AS SubUnitName,
					OD.ConstText1,OD.ConstText2,OD.ConstText3,OD.ConstText4,
					[inv].[funGetMaxGoodsRemain](OD.ProcessID,OD.ProcessNo,OD.FiscalYear,OD.SerialNo,OD.ProcessID,OD.ProcessNo,
					OD.FiscalYear,OD.SerialNo,OD.DocRowNo,StoreID,OD.GoodsID,OD.BatchNo,DocDate,1)  AS Remain
					,[inv].[funGetTechnicalNo](OD.GoodsID) AS TechnicalNo
			FROM inv.tblStorageDocsDtl OD 
				LEFT JOIN
				(
					SELECT BaseProcessID , BaseProcessNo , BaseFiscalYear , 
						   BaseSerialNo , BaseDocRowNo, ISNULL(SUM(ConfirmQuantity),0) ConfirmQuantity
					FROM ##tblS
					GROUP BY BaseProcessID , BaseProcessNo , BaseFiscalYear , 
							 BaseSerialNo , BaseDocRowNo				
				) Cn 
			ON Cn.BaseProcessID = OD.ProcessID AND Cn.BaseProcessNo = OD.ProcessNo AND 
			   Cn.BaseFiscalYear = OD.FiscalYear AND Cn.BaseSerialNo = OD.SerialNo AND 
			   Cn.BaseDocRowNo = OD.DocRowNo 
			INNER JOIN
			(SELECT GoodsID,UnitID FROM inv.tblGoods WHERE CodeClosed = 'False' AND PartNumber=@UnitPart  ) G
			ON SUBSTRING(OD.GoodsID,@str_Goods+1,@str_GoodsSum) = G.GoodsID
			WHERE OD.ProcessID=55 AND OD.ProcessNo=@ProcessNo AND DocDate<=@DocDate  AND  (@GoodsID IS NULL OR OD.GoodsID = @GoodsID) AND
   				  (@BaseSerialNo IS NULL OR (OD.SerialNo=@BaseSerialNo AND OD.FiscalYear=@BaseFiscalYear)) --AND  OD.GoodsQuantity - ISNULL(Cn.ConfirmQuantity,0) >0 
		) A
		 WHERE IsCodeClosed = 0
		 
		DROP TABLE ##tblS	
		 
	END
ELSE IF @ProcessID = 100  or  @ProcessID = 171
	BEGIN
		DECLARE @TempFiscalYear1 SMALLINT
		DECLARE @StrSelect1	NVarChar(4000)
		
		SET @TempFiscalYear1 = RIGHT(DB_NAME(),4)
		
		IF @BaseFiscalYear = 0 OR @BaseFiscalYear IS NULL
			SET @BaseFiscalYear = RIGHT(DB_NAME(),4)
			
		SELECT * INTO ##tblS1
		FROM [cmr].[FunGetSale](@AcntCode,@DocDate,@BaseFiscalYear)
		WHERE BaseProcessNo = @ProcessNo	
		
		SET @TempFiscalYear1 = @TempFiscalYear1 + 1
		
		WHILE (SELECT COUNT(NAME) from master.sys.databases
			   WHERE name= LEFT(DB_NAME(),LEN(DB_NAME())-4) + LTRIM(STR(@TempFiscalYear1)))=1
		   BEGIN
				SET @StrSelect1 = 'INSERT INTO ##tblS1
						SELECT * 
						FROM ' + LEFT(DB_NAME(),LEN(DB_NAME())-4) + LTRIM(STR(@TempFiscalYear1)) + '.[cmr].[FunGetSale](''' + ISNULL(@AcntCode,'') + ''',''' + @DocDate + ''',' + LTRIM(STR(@BaseFiscalYear)) + ')
						WHERE BaseProcessNo = ' + LTRIM(STR(@ProcessNo))
				PRINT @StrSelect1
				Exec sp_executesql @StrSelect1; 
				SET @TempFiscalYear1 = @TempFiscalYear1 + 1	   	
		   END
				  
		SELECT * FROM (
			SELECT  acc.funIsCodeClosed(OD.AcntCode) IsCodeClosed, OD.ProcessID, OD.ProcessNo, OD.FiscalYear, OD.SerialNo, 
					OD.RowNo, OD.VolumeRowNo, OD.DocStep, OD.DocDate, OD.StoreID, OD.EnterKind, OD.StoreID2, OD.AcntCode, 
					OD.VisitorAcntCode, OD.BatchNo, OD.OrderAcntCode, OD.GoodsID, UnitID, SubUnitID, OD.UserPriceID,
					IsNull((Select UParams From inv.tblGoodsUserPrice p Where p.ID=OD.UserPriceID) ,'') as UserPrice,
					inv.funGetGoodsSubQuantity(OD.GoodsID,OD.SubUnitID,(OD.GoodsQuantity - ISNULL(Cn.ConfirmQuantity,0))) SubUnitQuantity,
				    OD.GoodsQuantity - ISNULL(Cn.ConfirmQuantity,0) GoodsQuantity, OD.GoodsQuantity - ISNULL(Cn.ConfirmQuantity,0) ConfirmQuantity,
					OD.QtyRemain, OD.GoodsAmount, OD.AtomAmount, OD.SubUnitPrice, OD.GoodsPrice, OD.DescDtl, OD.BaseProcessID,OD.DiscountPercentDtl,(DiscountDtl * (OD.GoodsQuantity - ISNULL(Cn.ConfirmQuantity,0)))/OD.GoodsQuantity as DiscountDtl, 
					OD.BaseProcessNo, OD.BaseFiscalYear, OD.BaseSerialNo, OD.BaseDocRowNo, OD.AgreeNo, OD.DocRowNo,
					[inv].[funGetTechnicalSpecifications](OD.GoodsID) AS TechnicalSpecifications,OD.ConstText1,OD.ConstText2,
					OD.ConstText3,OD.ConstText4,OD.TaxOverWorthCostDtl, OD.TollOverWorthCostDtl,OD.SaleTypeID,
					pub.funGetGoodsName(OD.GoodsID,@LanguageID) AS GoodsName, inv.funGetUnitName(SubUnitID, @LanguageID) AS SubUnitName,
					[inv].[funGetMaxGoodsRemain](OD.ProcessID,OD.ProcessNo,OD.FiscalYear,OD.SerialNo,OD.ProcessID,OD.ProcessNo,
					OD.FiscalYear,OD.SerialNo,OD.DocRowNo,OD.StoreID,OD.GoodsID,OD.BatchNo,OD.DocDate,1) AS Remain,
					OH.SgnSN1, OH.SgnSN2, OH.SgnSN3, OH.SgnSN4, OH.SgnSN5,[inv].[funGetTechnicalNo](OD.GoodsID) AS TechnicalNo
			FROM inv.tblStorageDocsDtl OD
				--	-------------------------------------------------------------------			

			Inner Join inv.tblStorageDocsHdr OH ON OH.ProcessID = OD.ProcessID And OH.ProcessNo = OD.ProcessNo And
												   OH.FiscalYear = OD.FiscalYear And OH.SerialNo = OD.SerialNo
			LEFT JOIN
			(
				SELECT BaseProcessID, BaseProcessNo, BaseFiscalYear, BaseSerialNo,
					   BaseDocRowNo, ISNULL(SUM(ConfirmQuantity),0) ConfirmQuantity
				FROM ##tblS1
				GROUP BY BaseProcessID , BaseProcessNo , BaseFiscalYear , 
						 BaseSerialNo , BaseDocRowNo				
			 ) Cn ON Cn.BaseProcessID = OD.ProcessID AND Cn.BaseProcessNo = OD.ProcessNo AND 
						Cn.BaseFiscalYear = OD.FiscalYear AND Cn.BaseSerialNo = OD.SerialNo AND 
						Cn.BaseDocRowNo = OD.DocRowNo 
			INNER JOIN
			(
				SELECT GoodsID, UnitID 
				FROM inv.tblGoods 
				WHERE CodeClosed = 'False' AND PartNumber=@UnitPart
			 ) G ON SUBSTRING(OD.GoodsID,@str_Goods+1,@str_GoodsSum) = G.GoodsID
			 
			WHERE OD.ProcessID=90 AND OD.ProcessNo=@ProcessNo AND OD.DocDate<=@DocDate AND (@AcntCode IS NULL OR OD.AcntCode = @AcntCode) AND  (@GoodsID IS NULL OR OD.GoodsID = @GoodsID) AND
   				  (@BaseSerialNo IS NULL OR (OD.SerialNo=@BaseSerialNo AND OD.FiscalYear=@BaseFiscalYear)) AND  OD.GoodsQuantity - ISNULL(Cn.ConfirmQuantity,0) >0 
		) A
		 WHERE IsCodeClosed = 0 and 
			(------------حذف اطلاعاتی که اسناد آنها ازنوع یادداشت است------------------------------------------------------
			SELECT COUNT(*)	from acc.tblVoucherDtl  v 
			WHERE v.SourceProcessID= A.ProcessID and  v.SourceProcessNo= A.ProcessNo
			and  v.SourceFiscalYear= A.FiscalYear and  v.SourceSerialNo= A.SerialNo
			and  v.AcntCode= A.AcntCode and v.VchKind<>0 
			) > 0

		 
		DROP TABLE ##tblS1	
		 
	END
END
GO
