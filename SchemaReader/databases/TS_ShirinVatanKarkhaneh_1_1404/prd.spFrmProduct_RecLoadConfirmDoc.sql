USE TS_ShirinVatanKarkhaneh_1_1404
GO
SET ANSI_NULLS, QUOTED_IDENTIFIER ON
GO
-- =========== TS-QC:NOTOK ========================
-- Author        : Hadi Sadeghi
-- Create date   : 87/02/03
-- Viewed By	 : 
-- Last Modified : 
-- Description   : 
-- =============================================
Create PROCEDURE [prd].[spFrmProduct_RecLoadConfirmDoc] 
	@ProcessID			tinyint,
	@ProcessNo			tinyint,
	@FiscalYear			smallint,
	@SerialNo			int,
	@DocStep			TINYINT,
	@DocDate			Char(10),
	@AcntCode			Varchar(20),
	@StoreID			Varchar(20),
	@GroupProduct		Tinyint,
	@ContractSerialNo	Int,
	@LanguageID			Tinyint,
	@ExtraParams		NVarChar(Max) = '' 
WITH ENCRYPTION
AS
BEGIN

SET NOCOUNT ON;

	Declare @ConfirmCount	int;
	DECLARE @Sgn1			BIT;
	DECLARE @Sgn2			BIT;
	DECLARE @Sgn3			BIT;
	DECLARE @Sgn4			BIT;
	DECLARE @Sgn5			BIT;
	DECLARE @Confirm		BIT;

	SET @ProcessNo			= LTrim(pub.funSplitString(@ExtraParams, '@', 1)); 
	SET @ConfirmCount		= pub.funSplitString(@ExtraParams, '@', 2);
	SET @Sgn1				= pub.funSplitString(@ExtraParams, '@', 3);
	SET @Sgn2				= pub.funSplitString(@ExtraParams, '@', 4);
	SET @Sgn3				= pub.funSplitString(@ExtraParams, '@', 5);
	SET @Sgn4				= pub.funSplitString(@ExtraParams, '@', 6);
	SET @Sgn5				= pub.funSplitString(@ExtraParams, '@', 7);
	SET @Confirm			= pub.funSplitString(@ExtraParams, '@', 8);

--=======
Declare @DecreasePrdQtyByPrdSendRet AS bit
SELECT @DecreasePrdQtyByPrdSendRet = SettingValue
FROM pub.tblSettings
WHERE SettingKey = 'DecreasePrdQtyByPrdSendRet'
	
--=======
DECLARE @HasGroupPRD TINYINT
SET @HasGroupPRD = 0

	IF @GroupProduct = 1
	BEGIN
		IF (SELECT BaseSerialNo 
			FROM inv.tblStorageDocsHdr 
		    WHERE ProcessID=70 AND SerialNo = @SerialNo AND ProcessNo = @ProcessNo AND FiscalYear = @FiscalYear)>0
			SET @HasGroupPRD = 1
	END 
	 
	IF @HasGroupPRD = 1
	BEGIN
		SELECT  P.ProductID AS GoodsID, 
				P.SubUnitQuantity - ISNULL(R.SubUnitQuantity,0) AS GoodsQuantity, 
				P.SubUnitQuantity - ISNULL(R.SubUnitQuantity,0) AS SubUnitQuantity, 
				P.AcntCode, 
				P.WageRate,
				pub.funGetGoodsName(P.ProductID,@LanguageID) AS GoodsName, 
				P.SubUnitQuantity - ISNULL(R.SubUnitQuantity,0) AS ConfirmQuantity, 
				P.FormulaNo,
				[prd].[funGetWageAmountProducersWage](P.AcntCode,P.ProductID,@ContractSerialNo) AS WageAmountProducersWage,
				[prd].[funGetGoodsQuantityProducersWage](OD.AcntCode,P.ProductID,@ContractSerialNo) AS GoodsQuantityProducersWage,
				pub.funGetGoodsUnitName(P.ProductID,@LanguageID) AS SubUnitName,
				[pub].[funGetGoodsUnitID](P.ProductID) AS SubUnitID,
				ISNULL(CASE P.WageRate WHEN 1 THEN Wage1 WHEN 2 THEN Wage2 WHEN 3 THEN Wage3 WHEN 4 THEN Wage4 WHEN 5 THEN Wage5 WHEN 6 THEN Wage6 WHEN 7 THEN Wage7 WHEN 8 THEN Wage8 WHEN 9 THEN Wage9 WHEN 10 THEN Wage10 ELSE 0 END,0) Wage,
				FH.ProductCount AS FormulaProductCount,
				'' DocDesc
		FROM prd.tblProductGroupsDtl P
		LEFT JOIN (SELECT * 
				   FROM prd.tblFormulasOverLoadHdr 
				   WHERE (OverLoadProduct=1 OR (OverLoadProduct=0 AND OverLoadDecomposition=0)) 
				   ) F	ON F.ProductID = P.ProductID AND F.SerialNo = P.FormulaNo 
		LEFT JOIN (SELECT ProductID,SerialNo,ProductCount 
				   FROM prd.tblFormulasHdr ) FH	ON FH.ProductID = P.ProductID AND FH.SerialNo = P.FormulaNo 
		INNER JOIN inv.tblStorageDocsHdr AS OD ON P.SerialNo = OD.BaseSerialNo AND OD.ProcessID = 70
		LEFT JOIN (SELECT BaseSerialNo,GoodsID,Sum(SubUnitQuantity) SubUnitQuantity 
				   FROM inv.tblStorageDocsDtl
				   WHERE ProcessID=80 AND ProcessNo=@ProcessNo 
				   Group by  BaseSerialNo,GoodsID) AS R ON OD.SerialNo = R.BaseSerialNo and P.ProductID = R.GoodsID 
		WHERE OD.SerialNo = @SerialNo AND OD.FiscalYear = @FiscalYear AND OD.ProcessID = 70 AND
			  OD.ProcessNo = @ProcessNo AND (@AcntCode IS NULL OR OD.AcntCode = @AcntCode) AND OD.DocDate <= @DocDate
			 AND (
				(@ConfirmCount=0 AND (	(@Confirm=0 AND OD.DocStep=1)
									  or(@Confirm=1 AND OD.DocStep=2))
				)OR 
				(@ConfirmCount>0 AND ((@Sgn1=0 AND SgnSN1=0) OR (@Sgn1>0 AND SgnSN1>0)  )
				  				 AND ((@Sgn2=0 AND SgnSN2=0) OR (@Sgn2>0 AND SgnSN2>0)  )
								 AND ((@Sgn3=0 AND SgnSN3=0) OR (@Sgn3>0 AND SgnSN3>0)  )
								 AND ((@Sgn4=0 AND SgnSN4=0) OR (@Sgn4>0 AND SgnSN4>0)  )
								 AND ((@Sgn5=0 AND SgnSN5=0) OR (@Sgn5>0 AND SgnSN5>0)  )
				)
				)	
	END
	ELSE
	BEGIN
		DECLARE @AllowEditQuantityInProductReceive AS BIT
	 
		SET @AllowEditQuantityInProductReceive = 'False'
	
		SELECT @AllowEditQuantityInProductReceive = SettingValue
		FROM pub.tblSettings
		WHERE SettingKey = 'prdAllowEditQuantityInProductReceive' 

		SELECT	OD.ProcessID, 
				OD.ProcessNo, 
				OD.FiscalYear, 
				OD.SerialNo, 
				DocStep, 
				DocDate,
				ISNULL(DfStoreID,'') StoreID, 
				Cnf.ProductID AS GoodsID,
				OD.ProductCount AS GoodsQuantity,
				Cnf.GoodsQuantity As SubUnitQuantity, --OD.ProductCount AS SubUnitQuantity,
				StoreID2, 
				AcntCode, 
				OD.BaseProcessID, 
				OD.BaseProcessNo, 
				OD.BaseFiscalYear, 
				OD.BaseSerialNo, 
				OD.BaseDocType, 
				AgreeNo, 
				FormulaNo, 
				CASE WHEN OD.ProductID = Cnf.ProductID THEN WageRate ELSE 100 END WageRate, 
				BatchNo, 
				pub.funGetGoodsName(Cnf.ProductID,@LanguageID) AS GoodsName,
				Cnf.GoodsQuantity ConfirmQuantity,
				[prd].[funGetWageAmountProducersWage](AcntCode,OD.ProductID,@ContractSerialNo) AS WageAmountProducersWage,
				[prd].[funGetGoodsQuantityProducersWage](AcntCode,OD.ProductID,@ContractSerialNo) AS GoodsQuantityProducersWage,
				OD.DocDesc,
				pub.funGetGoodsUnitName(Cnf.ProductID,@LanguageID) AS SubUnitName,
				Cnf.UnitID AS SubUnitID,
				CASE WHEN OD.ProductID = Cnf.ProductID THEN CASE WageRate WHEN 1 THEN Wage1 WHEN 2 THEN Wage2 WHEN 3 THEN Wage3 WHEN 4 THEN Wage4 WHEN 5 THEN Wage5 WHEN 6 THEN Wage6 WHEN 7 THEN Wage7 WHEN 8 THEN Wage8 WHEN 9 THEN Wage9 WHEN 10 THEN Wage10 ELSE 0 END ELSE 0 END Wage,
				FH.ProductCount AS FormulaProductCount, 
				OD.UserPriceID, 
				isnull((SELECT UParams 
						FROM inv.tblGoodsUserPrice p 
						WHERE p.ID=OD.UserPriceID),'') AS UserPrice 
		FROM 	
		prd.funPrd_ReceiveProduct(@ProcessID,@ProcessNo,@FiscalYear,@SerialNo,'','') Cnf
		INNER JOIN inv.tblStorageDocsHdr AS OD ON Cnf.ProcessID = OD.ProcessID AND Cnf.ProcessNo = OD.ProcessNo AND 
												  Cnf.FiscalYear = OD.FiscalYear AND Cnf.SerialNo = OD.SerialNo
		LEFT JOIN (SELECT * 
				   FROM prd.tblFormulasOverLoadHdr 
				   WHERE (OverLoadProduct=1 or (OverLoadProduct=0 and OverLoadDecomposition=0))
				   ) F ON F.ProductID = OD.ProductID AND F.SerialNo = FormulaNo 
		LEFT JOIN (SELECT ProductID,SerialNo,ProductCount 
				   FROM prd.tblFormulasHdr
				   ) FH	ON FH.ProductID = OD.ProductID AND FH.SerialNo = FormulaNo 
	    LEFT JOIN inv.tblGoods G ON Cnf.ProductID=G.GoodsID 
		WHERE Cnf.SerialNo = @SerialNo AND Cnf.FiscalYear = @FiscalYear AND 
			  OD.ProcessNo = @ProcessNo AND (@AcntCode IS NULL OR AcntCode = @AcntCode) AND DocDate <= @DocDate
			  AND (
				(@ConfirmCount=0 AND (	(@Confirm=0 AND DocStep=1)
									  OR(@Confirm=1 AND DocStep=2)
									  )
				)OR 
				(@ConfirmCount>0 AND ((@Sgn1=0 AND SgnSN1=0) OR (@Sgn1>0 AND SgnSN1>0)  )
				  				 AND ((@Sgn2=0 AND SgnSN2=0) OR (@Sgn2>0 AND SgnSN2>0)  )
								 AND ((@Sgn3=0 AND SgnSN3=0) OR (@Sgn3>0 AND SgnSN3>0)  )
								 AND ((@Sgn4=0 AND SgnSN4=0) OR (@Sgn4>0 AND SgnSN4>0)  )
								 AND ((@Sgn5=0 AND SgnSN5=0) OR (@Sgn5>0 AND SgnSN5>0)  )
				)
				)
	END
END
GO
