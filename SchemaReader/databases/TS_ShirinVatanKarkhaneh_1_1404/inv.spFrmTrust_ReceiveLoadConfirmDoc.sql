USE TS_ShirinVatanKarkhaneh_1_1404
GO
SET ANSI_NULLS, QUOTED_IDENTIFIER ON
GO
-- =========== TS-QC:NOTOK ========================
-- Author        : Hadi Sadeghi
-- Create date   : 87/11/24
-- Viewed By	 : 
-- Last Modified : 
-- Description   : 
-- =============================================
CREATE PROCEDURE [inv].[spFrmTrust_ReceiveLoadConfirmDoc]
 @ProcessID		tinyint,
 @ProcessNo		tinyint,
 @BaseFiscalYear smallint,
 @BaseSerialNo	int,
 @DocDate		Char(10),
 @AcntCode		Varchar(20),
 @StoreID		Varchar(20),
 @LanguageID	Tinyint,
 @FiscalYear	smallint,
 @SerialNo		int,
 @SaleTypeID	Varchar(20)= ''
 
WITH ENCRYPTION
 AS

BEGIN

SET NOCOUNT ON;
	
	DECLARE @OtherTrust_SalePrice     BIT
	SET  @OtherTrust_SalePrice = 'False'
	
	SELECT @OtherTrust_SalePrice = SettingValue
	FROM   pub.tblSettings
	WHERE SettingKey = 'OtherTrust_SalePrice' 

 IF @ProcessID = 130

	SELECT	OD.ProcessID, OD.ProcessNo, OD.FiscalYear, OD.SerialNo, OD.RowNo, OD.VolumeRowNo, OD.DocStep, 
			OD.DocDate, OD.StoreID, OD.EnterKind, OD.StoreID2, OD.AcntCode, OD.VisitorAcntCode, OD.BatchNo , 
			OD.OrderAcntCode, OD.GoodsID, OD.SubUnitID, [inv].[funGetSubUnitFromGoodsQuantity](OD.GoodsID,OD.SubUnitID,Cn.ConfirmQuantity) SubUnitQuantity, Cn.ConfirmQuantity , Cn.ConfirmQuantity GoodsQuantity , OD.QtyRemain, 
			OD.GoodsAmount, OD.AtomAmount, OD.GoodsPrice, OD.DescDtl, OD.BaseProcessID, 
			OD.BaseProcessNo, OD.BaseFiscalYear, OD.BaseSerialNo, OD.BaseDocRowNo, OD.AgreeNo, OD.DocRowNo,
			[inv].[funGetTechnicalSpecifications](OD.GoodsID) AS TechnicalSpecifications,
			pub.funGetGoodsName(GoodsID,@LanguageID) AS GoodsName, inv.funGetUnitName(SubUnitID,@LanguageID) AS SubUnitName,
			OD.DiscountPercentDtl,OD.DiscountDtl,OH.Discount,OH.DiscountPercent,OH.Discount2+OH.Discount3 Discount2,
			[inv].[funGetMaxGoodsRemain](OD.ProcessID,OD.ProcessNo,OD.FiscalYear,OD.SerialNo,OD.ProcessID,OD.ProcessNo,
						OD.FiscalYear,OD.SerialNo,OD.DocRowNo,OD.StoreID,GoodsID,OD.BatchNo,OD.DocDate,1)  AS Remain
	FROM inv.tblStorageDocsDtl OD 
		INNER JOIN
		(
			SELECT * 
			FROM [inv].[FunGetOurTrust](@AcntCode,@DocDate)
			WHERE ProcessNo = @ProcessNo AND ConfirmQuantity >0			
		) Cn ON Cn.ProcessID = OD.ProcessID AND Cn.ProcessNo = OD.ProcessNo AND 
				Cn.FiscalYear = OD.FiscalYear AND Cn.SerialNo = OD.SerialNo AND 
				Cn.DocRowNo = OD.DocRowNo 
		INNER JOIN
		inv.tblStorageDocsHdr OH
		ON	OD.ProcessID = OH.ProcessID AND  OD.ProcessNo = OH.ProcessNo AND 
			OD.FiscalYear = OH.FiscalYear AND OD.SerialNo = OH.SerialNo 
	WHERE  Cn.SerialNo = @BaseSerialNo AND Cn.FiscalYear = @BaseFiscalYear AND OD.ProcessNo=@ProcessNo AND
		   (@AcntCode IS NULL OR OH.AcntCode = @AcntCode) AND OH.DocDate<=@DocDate 

ELSE IF @ProcessID = 136

	SELECT	OD.ProcessID, OD.ProcessNo, OD.FiscalYear, OD.SerialNo, OD.RowNo, OD.VolumeRowNo, OD.DocStep, 
			OD.DocDate, OD.StoreID, OD.EnterKind, OD.StoreID2, OD.AcntCode, OD.VisitorAcntCode, OD.BatchNo , 
			OD.GoodsID,OD.OrderAcntCode, OD.SubUnitID, [inv].[funGetSubUnitFromGoodsQuantity](OD.GoodsID,OD.SubUnitID,Cn.ConfirmQuantity) SubUnitQuantity, Cn.ConfirmQuantity, Cn.ConfirmQuantity GoodsQuantity, OD.QtyRemain, 
			CASE WHEN @OtherTrust_SalePrice = 'False' OR @SaleTypeID = '' THEN OD.GoodsPrice ELSE [sal].[funGetGoodsAmountSaleType](GoodsID,OD.StoreID,OD.DocDate,@SaleTypeID,@LanguageID,OD.UserPriceID,0) END AS GoodsPrice ,
			OD.GoodsAmount, OD.AtomAmount , OD.DescDtl, OD.BaseProcessID, 
			OD.BaseProcessNo, OD.BaseFiscalYear, OD.BaseSerialNo, OD.BaseDocRowNo, OD.AgreeNo, OD.DocRowNo,
			OD.DiscountPercentDtl,OD.DiscountDtl,OH.Discount,OH.DiscountPercent,OH.Discount2+OH.Discount3 Discount2,
			[inv].[funGetTechnicalSpecifications](OD.GoodsID) AS TechnicalSpecifications,
			pub.funGetGoodsName(GoodsID,@LanguageID) AS GoodsName, inv.funGetUnitName(SubUnitID,@LanguageID) AS SubUnitName,
			[inv].[funGetMaxGoodsRemain](OD.ProcessID,OD.ProcessNo,OD.FiscalYear,OD.SerialNo,OD.ProcessID,OD.ProcessNo,
						OD.FiscalYear,OD.SerialNo,OD.DocRowNo,OD.StoreID,GoodsID,OD.BatchNo,OD.DocDate,1)  AS Remain
	FROM inv.tblStorageDocsDtl OD 
		INNER JOIN
		(
			SELECT * 
			FROM [inv].[FunGetOtherTrust](@AcntCode,@DocDate)
			WHERE ProcessNo = @ProcessNo AND ConfirmQuantity >0			
		) Cn ON Cn.ProcessID = OD.ProcessID AND Cn.ProcessNo = OD.ProcessNo AND 
				Cn.FiscalYear = OD.FiscalYear AND Cn.SerialNo = OD.SerialNo AND 
				Cn.DocRowNo = OD.DocRowNo
		INNER JOIN
		inv.tblStorageDocsHdr OH
		ON	OD.ProcessID = OH.ProcessID AND  OD.ProcessNo = OH.ProcessNo AND 
			OD.FiscalYear = OH.FiscalYear AND OD.SerialNo = OH.SerialNo 		 
	WHERE  Cn.SerialNo = @BaseSerialNo AND Cn.FiscalYear = @BaseFiscalYear AND OD.ProcessNo=@ProcessNo AND
		   (@AcntCode IS NULL OR OH.AcntCode = @AcntCode) AND OH.DocDate<=@DocDate 
END
GO
