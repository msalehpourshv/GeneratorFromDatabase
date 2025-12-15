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
Create PROCEDURE [prd].[spFrmProductDtlListSelect] 
	@ProcessID	Tinyint,
	@ProcessNo	Tinyint,
	@DocStep	TINYINT,
	@AcntCode	VarChar(20),
	@GoodsID	VarChar(20),
	@DocDate	Char(10),
	@LanguageID int
WITH ENCRYPTION
 AS
BEGIN

SET NOCOUNT ON;

IF @ProcessID = 75
	SELECT	OD.ProcessID, OD.ProcessNo, OD.FiscalYear, OD.SerialNo, RowNo, OD.DocRowNo, VolumeRowNo, DocStep, DocDate, StoreID, 
			PhysicallyEffected, EnterKind, StoreID2, Cnf.AcntCode, VisitorAcntCode, OrderAcntCode, GoodsID, SubUnitID, 
			SubUnitQuantity, GoodsQuantity, QtyRemain, GoodsAmount, AtomAmount, GoodsPrice, DescDtl, 
			BaseProcessID, BaseProcessNo, BaseFiscalYear, BaseSerialNo, BaseDocRowNo, BaseDocType, AgreeNo, 
			BatchNo,DiscountPercentDtl, DiscountDtl,Cnf.ConfirmQuantity,
			[inv].[funGetTechnicalSpecifications](GoodsID) AS TechnicalSpecifications,
			pub.funGetGoodsName(GoodsID,@LanguageID) AS GoodsName, inv.funGetUnitName(SubUnitID,@LanguageID) AS SubUnitName,
			[inv].[funGetMaxGoodsRemain](OD.ProcessID,OD.ProcessNo,OD.FiscalYear,OD.SerialNo,OD.ProcessID,OD.ProcessNo,
						OD.FiscalYear,OD.SerialNo,OD.DocRowNo,StoreID,GoodsID,OD.BatchNo,DocDate,1)  AS Remain,
		   [pub].[GetCodeName](Cnf.AcntCode,@LanguageID) AcntName
	From  [prd].[FunGetProduct] (@AcntCode,@DocDate,@DocStep,@ProcessNo) Cnf 
	INNER JOIN inv.tblStorageDocsDtl AS OD
	ON	Cnf.ProcessID = OD.ProcessID AND Cnf.ProcessNo = OD.ProcessNo AND 
		Cnf.FiscalYear = OD.FiscalYear AND Cnf.SerialNo = OD.SerialNo AND 
		Cnf.DocRowNo = OD.DocRowNo 
	WHERE Cnf.ConfirmQuantity > 0 AND (@GoodsID IS NULL OR OD.GoodsID = @GoodsID) AND (@AcntCode IS NULL OR Cnf.AcntCode = @AcntCode) AND DocDate<=@DocDate 

ELSE IF @ProcessID = 80

	SELECT	DISTINCT OD.ProcessID, OD.ProcessNo, OD.FiscalYear, OD.SerialNo, DocStep, DocDate,0 DocRowNo, ISNULL(DfStoreID,'') StoreID, 
	        OD.ProductID AS GoodsID,OD.ProductCount -isnull(RD.GoodsQuantity,0) AS GoodsQuantity,OD.ProductCount -isnull(RD.SubUnitQuantity,0) AS SubUnitQuantity ,
			StoreID2, AcntCode, OD.BaseProcessID, OD.BaseProcessNo, OD.BaseFiscalYear, OD.BaseSerialNo, 
			OD.BaseDocType, AgreeNo, FormulaNo,WageRate,BatchNo, OD.ProductCount -isnull(RD.SubUnitQuantity,0)  AS ConfirmQuantity,
			pub.funGetGoodsName(OD.ProductID,@LanguageID) AS GoodsName,
			pub.funGetGoodsUnitName(OD.ProductID,@LanguageID) AS SubUnitName,[pub].[funGetGoodsUnitID](OD.ProductID) AS SubUnitID,
			ISNULL(CASE WageRate WHEN 1 THEN Wage1 WHEN 2 THEN Wage2 WHEN 3 THEN Wage3 WHEN 4 THEN Wage4 WHEN 5 THEN Wage5 WHEN 6 THEN Wage6 WHEN 7 THEN Wage7 WHEN 8 THEN Wage8 WHEN 9 THEN Wage9 WHEN 10 THEN Wage10 ELSE 0 END,0) Wage ,
			ISNULL(FH.ProductCount,0) AS FormulaProductCount,
		    [pub].[GetCodeName](OD.AcntCode,@LanguageID) AcntName
	From  
	(
		SELECT ProcessID,ProcessNo,FiscalYear,SerialNo
		FROM [prd].[FunGetProduct] (@AcntCode,@DocDate,@DocStep,@ProcessNo)
		EXCEPT
		SELECT BaseProcessID,BaseProcessNo,BaseFiscalYear,BaseSerialNo
		FROM [prd].[FunGetBaseProduct](@AcntCode,@DocDate,1,2,@ProcessNo)
	)Cnf 
	INNER JOIN inv.tblStorageDocsHdr AS OD
	ON	Cnf.ProcessID = OD.ProcessID AND Cnf.ProcessNo = OD.ProcessNo AND 
		Cnf.FiscalYear = OD.FiscalYear AND Cnf.SerialNo = OD.SerialNo 
	LEFT JOIN 
		( select ProcessID,ProcessNo,FiscalYear,SerialNo,BaseProcessID,BaseProcessNo,BaseFiscalYear,BaseSerialNo,GoodsID,Sum(GoodsQuantity) GoodsQuantity,Sum(SubUnitQuantity) SubUnitQuantity from  inv.tblStorageDocsDtl
		  where BaseProcessID=79 and ProcessID=80
		  group by ProcessID,ProcessNo,FiscalYear,SerialNo,BaseProcessID,BaseProcessNo,BaseFiscalYear,BaseSerialNo,GoodsID) AS RD 
	  ON RD.BaseProcessID = OD.BaseProcessID AND RD.BaseProcessNo = OD.BaseProcessNo AND RD.BaseFiscalYear = OD.BaseFiscalYear 
		  AND RD.BaseSerialNo = OD.BaseSerialNo and OD.ProductID =RD.GoodsID
	LEFT JOIN (SELECT * FROM prd.tblFormulasOverLoadHdr where (OverLoadProduct=1 or (OverLoadProduct=0 and OverLoadDecomposition=0))) F	
	ON  F.ProductID = OD.ProductID AND  F.SerialNo= FormulaNo 
	LEFT JOIN (SELECT ProductID,SerialNo,ProductCount FROM prd.tblFormulasHdr ) FH	
	ON  FH.ProductID = OD.ProductID AND  FH.SerialNo= FormulaNo 
        LEFT JOIN inv.tblGoods G on OD.ProductID=G.GoodsID 

	WHERE  (@AcntCode IS NULL OR AcntCode = @AcntCode) AND DocDate<=@DocDate 

END
GO
