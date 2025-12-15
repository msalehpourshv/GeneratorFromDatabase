USE TS_ShirinVatanKarkhaneh_1_1404
GO
SET ANSI_NULLS, QUOTED_IDENTIFIER ON
GO
-- =========== TS-QC:UPDATED ====================
-- Author		 : Mohammadi
-- Create date   : 1389/11/16
-- Viewed By	 : 
-- Last Modified : 1389/11/24
-- Last Modifier : TakroSystem\Mohammadi
-- ==============================================
Create PROCEDURE [inv].[spGetInvRecordsForCosting]
	@FromDate   Char(10),
	@ToDate     Char(10),
	@LanguageID SmallInt,
	@CalcnGoodsCountFormula as bit
WITH ENCRYPTION
AS
BEGIN

	DECLARE @Inv_CalcEndAmountOnFIFO	bit
	DECLARE @MultiPart			bit
	DECLARE @UnitPart			TINYINT
	SET @UnitPart  = 1
	SET @MultiPart  = 'False'
	SET @Inv_CalcEndAmountOnFIFO  = 'False'

	SELECT @Inv_CalcEndAmountOnFIFO = SettingValue from pub.tblSettings where SettingKey = 'Inv_CalcEndAmountOnFIFO'

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

	SELECT GoodsID INTO #TService  from inv.tblGoods WHERE IsService='True'  AND PartNumber=@UnitPart 

	IF @Inv_CalcEndAmountOnFIFO = 'True'
	BEGIN
		SELECT  SD.DocDate, SD.GoodsID, SD.VolumeRowNo, SD.EnterKind,SD.SubUnitQuantity, Case when EnterKind=0 then 0 else SD.GoodsQuantity END GoodsQuantity, SD.QtyRemain, SD.GoodsAmount, SD.UserGoodsAmount, 
				SD.AtomAmount, SD.AmntRemain, SD.AmntRemain0, SD.ProcessID, SD.DocStep, LTrim(RTrim(SD.StoreID)) StoreID, LTrim(RTrim(SD.StoreID2)) StoreID2, SD.GoodsPrice, SD.ProcessNo, SD.FiscalYear, SD.SerialNo, 
				SD.RowNo, SD.DocRowNo, SD.BaseProcessID, SD.BaseProcessNo, SD.BaseFiscalYear, SD.BaseSerialNo, SD.BaseDocRowNo, SD.AcntCode,SD.IsReward, 
				SD.WageRate,SD.Wage, SH.ProductCount, SH.BaseDocType, SH.FormulaNo AS FormulaNoHdr ,SD.FormulaNo AS FormulaNoDtl, 
				Case SH.ProcessID WHEN 80 THEN [pub].[funGetGoodsName](GoodsID,@LanguageID)  ELSE '' END GoodsName, 
				Case SH.ProcessID WHEN 80 THEN [inv].[funGetUnitName](SubUnitID,@LanguageID) ELSE '' END UnitName , SH.SaleTypeID ,SD.BatchNo,SH.BatchNo BatchNoHdr,ProductID,DiscountDtl,
				CostAcntCode,CostPercent,PricePercent,CASE WHEN @CalcnGoodsCountFormula = 'False' THEN 0  ELSE [prd].[funGoodsCountFormula](SH.ProductID,SD.GoodsID,SH.FormulaNo) END FCnt,GoodsQuantity GQTY,SD.Shipment,SD.BranchID,SD.UserPriceID,SH.ModificationKind,
				ISNULL(AtomRowNo,0) AtomRowNo,ISNULL(PortionGoods,0) PortionGoods,ISNULL(PortionSalary,0) PortionSalary,ISNULL(PortionOverLoad,0) PortionOverLoad,ISNULL(PortionOtherCost,0) PortionOtherCost,		
				ISNULL(GoodsRemain,0) GoodsRemain,ISNULL(SalaryRemain,0) SalaryRemain,ISNULL(OverLoadRemain,0) OverLoadRemain,ISNULL(OtherCostRemain,0) OtherCostRemain	,SH.VchNo	
		FROM inv.tblStorageDocsDtl SD
		INNER JOIN inv.tblStorageDocsHdr SH 
		ON SD.ProcessID=SH.ProcessID AND SD.ProcessNo=SH.ProcessNo AND SD.FiscalYear=SH.FiscalYear AND SD.SerialNo=SH.SerialNo 
		LEFT JOIN (
				   SELECT * 
			       FROM (SELECT ROW_NUMBER()over(partition by ProcessID, ProcessNo, FiscalYear, SerialNo, DocRowNo order by ProcessID, ProcessNo, FiscalYear, SerialNo, DocRowNo,AtomRowNo  desc) R ,* 
			             FROM cac.tblStorageDocsPortionAtm
						 WHERE  DocDate <= @ToDate
						 ) a
			       WHERE R=1
				   ) PA 
		ON SD.ProcessID=PA.ProcessID AND SD.ProcessNo=PA.ProcessNo AND SD.FiscalYear=PA.FiscalYear AND SD.SerialNo=PA.SerialNo AND  SD.DocRowNo=PA.DocRowNo
		WHERE  SD.DocDate <= @ToDate  AND SUBSTRING(SD.GoodsID,@str_Goods+1,@str_GoodsSum) NOT IN (SELECT * from #TService) 
		ORDER BY DocDate,VolumeRowNo,GoodsID,StoreID,BatchNo,UserPriceID

	END
	ELSE
	BEGIN
	---- سند هاي 120 كه 125 آنها در محدوده قبل است
	SELECT  SD.DocDate, SD.GoodsID, SD.VolumeRowNo, SD.EnterKind,SD.SubUnitQuantity,  Case when EnterKind=0 then 0 else SD.GoodsQuantity END GoodsQuantity, SD.QtyRemain, SD.GoodsAmount, SD.UserGoodsAmount, 
			SD.AtomAmount, SD.AmntRemain, SD.AmntRemain0, SD.ProcessID, SD.DocStep, LTrim(RTrim(SD.StoreID)) StoreID, LTrim(RTrim(SD.StoreID2)) StoreID2, SD.GoodsPrice, SD.ProcessNo, SD.FiscalYear, SD.SerialNo, 
			SD.RowNo, SD.DocRowNo, SD.BaseProcessID, SD.BaseProcessNo, SD.BaseFiscalYear, SD.BaseSerialNo, SD.BaseDocRowNo, SD.AcntCode,SD.IsReward, 
			SD.WageRate,SD.Wage, 0 ProductCount, 0 BaseDocType, 0 FormulaNoHdr ,0 FormulaNoDtl, '' GoodsName, '' UnitName , '' SaleTypeID ,SD.BatchNo,'' BatchNoHdr,'' ProductID,DiscountDtl,
			'' CostAcntCode,0.0 CostPercent,0.0 PricePercent,-1 FCnt,GoodsQuantity GQTY,SD.Shipment,SD.BranchID,SD.UserPriceID,0 ModificationKind,
			ISNULL(AtomRowNo,0) AtomRowNo,ISNULL(PortionGoods,0) PortionGoods,ISNULL(PortionSalary,0) PortionSalary,ISNULL(PortionOverLoad,0) PortionOverLoad,ISNULL(PortionOtherCost,0) PortionOtherCost,		
				ISNULL(GoodsRemain,0) GoodsRemain,ISNULL(SalaryRemain,0) SalaryRemain,ISNULL(OverLoadRemain,0) OverLoadRemain,ISNULL(OtherCostRemain,0) OtherCostRemain	,0 VchNo	
	FROM	inv.tblStorageDocsDtl SD
	LEFT JOIN (SELECT * 
			   FROM (SELECT ROW_NUMBER()over(partition by ProcessID, ProcessNo, FiscalYear, SerialNo, DocRowNo order by ProcessID, ProcessNo, FiscalYear, SerialNo, DocRowNo,AtomRowNo  desc) R ,* 
			         FROM cac.tblStorageDocsPortionAtm
					 WHERE  DocDate < @FromDate AND ProcessID=120
					 ) a
			    WHERE R=1
				) PA 
	ON SD.ProcessID=PA.ProcessID AND SD.ProcessNo=PA.ProcessNo AND SD.FiscalYear=PA.FiscalYear AND SD.SerialNo=PA.SerialNo AND  SD.DocRowNo=PA.DocRowNo
	WHERE   SD.DocDate < @FromDate AND SD.ProcessID=120 AND 
			SUBSTRING(SD.GoodsID,@str_Goods+1,@str_GoodsSum) NOT IN (SELECT * from #TService) AND 
			(SELECT COUNT(SD2.ProcessID) 
			 FROM inv.tblStorageDocsDtl SD2 
			 WHERE SD2.ProcessID=125 AND SD.ProcessNo=SD2.ProcessNo AND SD.FiscalYear=SD2.FiscalYear AND SD.SerialNo=SD2.SerialNo AND SD.DocRowNo=SD2.DocRowNo 
				 AND @FromDate <= SD2.DocDate AND SD2.DocDate <= @ToDate ) >0

	---- سند هاي 260 كه 265 آنها در محدوده قبل است
	UNION	  

	SELECT  SD.DocDate, SD.GoodsID, SD.VolumeRowNo, SD.EnterKind,SD.SubUnitQuantity,  Case when EnterKind=0 then 0 else SD.GoodsQuantity END GoodsQuantity, SD.QtyRemain, SD.GoodsAmount, SD.UserGoodsAmount, 
			SD.AtomAmount, SD.AmntRemain, SD.AmntRemain0, SD.ProcessID, SD.DocStep, LTrim(RTrim(SD.StoreID)) StoreID, LTrim(RTrim(SD.StoreID2)) StoreID2, SD.GoodsPrice, SD.ProcessNo, SD.FiscalYear, SD.SerialNo, 
			SD.RowNo, SD.DocRowNo, SD.BaseProcessID, SD.BaseProcessNo, SD.BaseFiscalYear, SD.BaseSerialNo, SD.BaseDocRowNo, SD.AcntCode,SD.IsReward, 
			SD.WageRate,SD.Wage, 0 ProductCount, 0 BaseDocType, 0 FormulaNoHdr ,0 FormulaNoDtl, '' GoodsName, '' UnitName , '' SaleTypeID ,SD.BatchNo,'' BatchNoHdr,'' ProductID,DiscountDtl,
			'' CostAcntCode,0.0 CostPercent,0.0 PricePercent,-1 FCnt,GoodsQuantity GQTY,SD.Shipment,SD.BranchID,SD.UserPriceID,0 ModificationKind,
			ISNULL(AtomRowNo,0) AtomRowNo,ISNULL(PortionGoods,0) PortionGoods,ISNULL(PortionSalary,0) PortionSalary,ISNULL(PortionOverLoad,0) PortionOverLoad,ISNULL(PortionOtherCost,0) PortionOtherCost,		
				ISNULL(GoodsRemain,0) GoodsRemain,ISNULL(SalaryRemain,0) SalaryRemain,ISNULL(OverLoadRemain,0) OverLoadRemain,ISNULL(OtherCostRemain,0) OtherCostRemain	,0 VchNo	
	FROM	inv.tblStorageDocsDtl SD
	LEFT JOIN (SELECT * 
			   FROM (SELECT ROW_NUMBER()over(partition by ProcessID, ProcessNo, FiscalYear, SerialNo, DocRowNo order by ProcessID, ProcessNo, FiscalYear, SerialNo, DocRowNo,AtomRowNo  desc) R ,* 
			         FROM cac.tblStorageDocsPortionAtm
					 WHERE  DocDate < @FromDate AND ProcessID=260
					 ) a
			    WHERE R=1
				) PA 
	ON SD.ProcessID=PA.ProcessID AND SD.ProcessNo=PA.ProcessNo AND SD.FiscalYear=PA.FiscalYear AND SD.SerialNo=PA.SerialNo AND  SD.DocRowNo=PA.DocRowNo
	WHERE   SD.DocDate < @FromDate AND SD.ProcessID=260 AND 
			SUBSTRING(SD.GoodsID,@str_Goods+1,@str_GoodsSum) NOT IN (SELECT * from #TService) AND 
			(SELECT COUNT(SD2.ProcessID) 
			 FROM inv.tblStorageDocsDtl SD2 
			 WHERE SD2.ProcessID=265 AND SD.ProcessNo=SD2.ProcessNo AND SD.FiscalYear=SD2.FiscalYear AND SD.SerialNo=SD2.SerialNo AND SD.DocRowNo=SD2.DocRowNo 
				 AND @FromDate <= SD2.DocDate AND SD2.DocDate <= @ToDate )>0

	---- ركوردهاي مرجع 
	UNION	  

	SELECT  SD.DocDate, SD.GoodsID, SD.VolumeRowNo, SD.EnterKind,SD.SubUnitQuantity,  Case when EnterKind=0 then 0 else SD.GoodsQuantity END GoodsQuantity, SD.QtyRemain, SD.GoodsAmount, SD.UserGoodsAmount, 
			SD.AtomAmount, SD.AmntRemain, SD.AmntRemain0, SD.ProcessID, SD.DocStep, LTrim(RTrim(SD.StoreID)) StoreID, LTrim(RTrim(SD.StoreID2)) StoreID2, SD.GoodsPrice, SD.ProcessNo, SD.FiscalYear, SD.SerialNo, 
			SD.RowNo, SD.DocRowNo, SD.BaseProcessID, SD.BaseProcessNo, SD.BaseFiscalYear, SD.BaseSerialNo, SD.BaseDocRowNo, SD.AcntCode,SD.IsReward, 
			SD.WageRate,SD.Wage, 0 ProductCount, 0 BaseDocType, 0 FormulaNoHdr ,0 FormulaNoDtl, '' GoodsName, '' UnitName , '' SaleTypeID ,SD.BatchNo,'' BatchNoHdr,'' ProductID,DiscountDtl,
			'' CostAcntCode,0.0 CostPercent,0.0 PricePercent,-1 FCnt,GoodsQuantity GQTY,SD.Shipment,SD.BranchID,SD.UserPriceID,0 ModificationKind,
			ISNULL(AtomRowNo,0) AtomRowNo,ISNULL(PortionGoods,0) PortionGoods,ISNULL(PortionSalary,0) PortionSalary,ISNULL(PortionOverLoad,0) PortionOverLoad,ISNULL(PortionOtherCost,0) PortionOtherCost,		
				ISNULL(GoodsRemain,0) GoodsRemain,ISNULL(SalaryRemain,0) SalaryRemain,ISNULL(OverLoadRemain,0) OverLoadRemain,ISNULL(OtherCostRemain,0) OtherCostRemain	,0 VchNo
	FROM	inv.tblStorageDocsDtl SD
	LEFT JOIN (SELECT * 
			   FROM (SELECT ROW_NUMBER()over(partition by ProcessID, ProcessNo, FiscalYear, SerialNo, DocRowNo order by ProcessID, ProcessNo, FiscalYear, SerialNo, DocRowNo,AtomRowNo  desc) R ,* 
			         FROM cac.tblStorageDocsPortionAtm
					 WHERE  DocDate < @FromDate AND ProcessID<>70
					 ) a
			    WHERE R=1
				) PA 
	ON SD.ProcessID=PA.ProcessID AND SD.ProcessNo=PA.ProcessNo AND SD.FiscalYear=PA.FiscalYear AND SD.SerialNo=PA.SerialNo AND  SD.DocRowNo=PA.DocRowNo	
	WHERE   SD.ProcessID <> 70 AND SD.DocDate < @FromDate AND SUBSTRING(SD.GoodsID,@str_Goods+1,@str_GoodsSum) NOT IN (SELECT * from #TService) AND   
			(SELECT COUNT(SD2.ProcessID) 
			 FROM inv.tblStorageDocsDtl SD2 
			 WHERE SD.ProcessID=SD2.BaseProcessID AND SD.ProcessNo=SD2.BaseProcessNo AND SD.FiscalYear=SD2.BaseFiscalYear AND 
				   SD.SerialNo =SD2.BaseSerialNo AND SD.DocRowNo =SD2.BaseDocRowNo 
				 AND @FromDate <= SD2.DocDate AND SD2.DocDate <= @ToDate )>0

	---- ركوردهاي مرجع 80 
	UNION	  

	SELECT  SD.DocDate, SD.GoodsID, SD.VolumeRowNo, SD.EnterKind,SD.SubUnitQuantity,  Case when EnterKind=0 then 0 else SD.GoodsQuantity END GoodsQuantity, SD.QtyRemain, SD.GoodsAmount, SD.UserGoodsAmount, 
			SD.AtomAmount, SD.AmntRemain, SD.AmntRemain0, SD.ProcessID, SD.DocStep, LTrim(RTrim(SD.StoreID)) StoreID, LTrim(RTrim(SD.StoreID2)) StoreID2, SD.GoodsPrice, SD.ProcessNo, SD.FiscalYear, SD.SerialNo, 
			SD.RowNo, SD.DocRowNo, SD.BaseProcessID, SD.BaseProcessNo, SD.BaseFiscalYear, SD.BaseSerialNo, SD.BaseDocRowNo, SD.AcntCode,SD.IsReward, 
			SD.WageRate,SD.Wage, SH.ProductCount, SH.BaseDocType, SH.FormulaNo AS FormulaNoHdr ,SD.FormulaNo AS FormulaNoDtl, '' GoodsName, '' UnitName, SH.SaleTypeID ,SD.BatchNo,SH.BatchNo BatchNoHdr,ProductID,DiscountDtl,
			'' CostAcntCode,0.0 CostPercent,0.0 PricePercent,CASE WHEN @CalcnGoodsCountFormula = 'False' THEN 0  ELSE [prd].[funGoodsCountFormula](SH.ProductID,SD.GoodsID,SH.FormulaNo) END FCnt,GoodsQuantity GQTY,SD.Shipment,SD.BranchID,SD.UserPriceID,SH.ModificationKind,
			ISNULL(AtomRowNo,0) AtomRowNo,ISNULL(PortionGoods,0) PortionGoods,ISNULL(PortionSalary,0) PortionSalary,ISNULL(PortionOverLoad,0) PortionOverLoad,ISNULL(PortionOtherCost,0) PortionOtherCost,		
				ISNULL(GoodsRemain,0) GoodsRemain,ISNULL(SalaryRemain,0) SalaryRemain,ISNULL(OverLoadRemain,0) OverLoadRemain,ISNULL(OtherCostRemain,0) OtherCostRemain	,SH.VchNo	
	FROM	inv.tblStorageDocsDtl SD
	INNER JOIN inv.tblStorageDocsHdr SH  
	ON	SD.ProcessID=SH.ProcessID AND SD.ProcessNo=SH.ProcessNo AND SD.FiscalYear=SH.FiscalYear AND SD.SerialNo=SH.SerialNo 
	LEFT JOIN (SELECT * 
			   FROM (SELECT ROW_NUMBER()over(partition by ProcessID, ProcessNo, FiscalYear, SerialNo, DocRowNo order by ProcessID, ProcessNo, FiscalYear, SerialNo, DocRowNo,AtomRowNo  desc) R ,* 
			         FROM cac.tblStorageDocsPortionAtm
					 WHERE  DocDate < @ToDate AND ProcessID=70
					 ) a
			    WHERE R=1
				) PA 
	ON SD.ProcessID=PA.ProcessID AND SD.ProcessNo=PA.ProcessNo AND SD.FiscalYear=PA.FiscalYear AND SD.SerialNo=PA.SerialNo AND  SD.DocRowNo=PA.DocRowNo	
	WHERE SD.ProcessID=70 AND SD.DocDate < @FromDate AND SUBSTRING(SD.GoodsID,@str_Goods+1,@str_GoodsSum) NOT IN (SELECT * from #TService)  AND  
		   ( (SELECT COUNT(SD2.ProcessID) 
		     FROM inv.tblStorageDocsDtl SD2 
		     WHERE SD.ProcessID=SD2.BaseProcessID AND SD.ProcessNo=SD2.BaseProcessNo AND SD.FiscalYear=SD2.BaseFiscalYear AND 
				   SD.SerialNo =SD2.BaseSerialNo 
				 AND @FromDate <= SD2.DocDate AND SD2.DocDate <= @ToDate )>0  OR
			(SELECT COUNT(SD2.ProcessID) 
		     FROM inv.tblStorageDocsDtl SD2 
		     WHERE SH.BatchNo=SD2.BatchNo
			   AND SH.BatchNo<>'' AND @FromDate <= SD2.DocDate AND SD2.DocDate <= @ToDate )>0 	 )

	----- ركوردهاي مانده قبلي
	UNION

	SELECT SD.DocDate, SD.GoodsID, SD.VolumeRowNo, SD.EnterKind,SD.SubUnitQuantity,  Case when EnterKind=0 then 0 else SD.GoodsQuantity END GoodsQuantity, SD.QtyRemain, SD.GoodsAmount, SD.UserGoodsAmount, 
		   SD.AtomAmount, SD.AmntRemain, SD.AmntRemain0, SD.ProcessID, SD.DocStep, LTrim(RTrim(SD.StoreID)) StoreID, LTrim(RTrim(SD.StoreID2)) StoreID2, SD.GoodsPrice, SD.ProcessNo, SD.FiscalYear, SD.SerialNo, 
		   SD.RowNo, SD.DocRowNo, SD.BaseProcessID, SD.BaseProcessNo, SD.BaseFiscalYear, SD.BaseSerialNo, SD.BaseDocRowNo, SD.AcntCode,SD.IsReward, 
		   SD.WageRate,SD.Wage, SH.ProductCount, SH.BaseDocType, SH.FormulaNo AS FormulaNoHdr ,SD.FormulaNo AS FormulaNoDtl, '' GoodsName, '' UnitName , SH.SaleTypeID ,SD.BatchNo,SH.BatchNo BatchNoHdr,ProductID,DiscountDtl,
		   '' CostAcntCode,0.0 CostPercent,0.0 PricePercent,CASE WHEN @CalcnGoodsCountFormula = 'False' THEN 0  ELSE [prd].[funGoodsCountFormula](SH.ProductID,SD.GoodsID,SH.FormulaNo) END FCnt,GoodsQuantity GQTY,SD.Shipment,SD.BranchID,SD.UserPriceID,SH.ModificationKind,
			ISNULL(AtomRowNo,0) AtomRowNo,ISNULL(PortionGoods,0) PortionGoods,ISNULL(PortionSalary,0) PortionSalary,ISNULL(PortionOverLoad,0) PortionOverLoad,ISNULL(PortionOtherCost,0) PortionOtherCost,		
				ISNULL(GoodsRemain,0) GoodsRemain,ISNULL(SalaryRemain,0) SalaryRemain,ISNULL(OverLoadRemain,0) OverLoadRemain,ISNULL(OtherCostRemain,0) OtherCostRemain	,SH.VchNo	
	FROM  inv.tblStorageDocsDtl SD
	INNER JOIN inv.tblStorageDocsHdr SH
	ON SD.ProcessID=SH.ProcessID AND SD.ProcessNo=SH.ProcessNo AND SD.FiscalYear=SH.FiscalYear AND SD.SerialNo=SH.SerialNo
	INNER JOIN   
		( 
		SELECT SD1.GoodsID, SD1.StoreID, SD1.DocDate,SD1.BatchNo,SD1.UserPriceID , MAX(VolumeRowNo) AS VolumeRowNo 
		FROM inv.tblStorageDocsDtl AS SD2,  
			( 
			SELECT GoodsID, StoreID,BatchNo,UserPriceID , MAX(DocDate) AS DocDate 
			FROM inv.tblStorageDocsDtl 
			WHERE DocDate < @FromDate
			GROUP BY GoodsID, StoreID ,BatchNo,UserPriceID 
			) AS SD1 
		 WHERE SD2.DocDate < @FromDate AND SD1.GoodsID=SD2.GoodsID AND SD1.StoreID=SD2.StoreID AND SD1.DocDate=SD2.DocDate 
			  AND SD1.BatchNo=SD2.BatchNo AND SD1.UserPriceID=SD2.UserPriceID 
		 GROUP BY SD1.GoodsID, SD1.StoreID, SD1.DocDate,SD1.BatchNo,SD1.UserPriceID 
	) AS SD3 
	ON  SD.GoodsID=SD3.GoodsID AND SD.StoreID=SD3.StoreID AND SD.DocDate=SD3.DocDate AND SD.VolumeRowNo=SD3.VolumeRowNo AND
		SD.BatchNo=SD3.BatchNo AND SD.UserPriceID=SD3.UserPriceID  
	LEFT JOIN (SELECT * 
			   FROM (SELECT ROW_NUMBER()over(partition by ProcessID, ProcessNo, FiscalYear, SerialNo, DocRowNo order by ProcessID, ProcessNo, FiscalYear, SerialNo, DocRowNo,AtomRowNo  desc) R ,* 
			         FROM cac.tblStorageDocsPortionAtm
					 WHERE  DocDate <= @ToDate
					 ) a
			    WHERE R=1
				) PA 
	ON SD.ProcessID=PA.ProcessID AND SD.ProcessNo=PA.ProcessNo AND SD.FiscalYear=PA.FiscalYear AND SD.SerialNo=PA.SerialNo AND  SD.DocRowNo=PA.DocRowNo	
	WHERE SUBSTRING(SD.GoodsID,@str_Goods+1,@str_GoodsSum) NOT IN (SELECT * from #TService)  

	----- ركوردهاي جاري
	UNION

	SELECT  SD.DocDate, SD.GoodsID, SD.VolumeRowNo, SD.EnterKind,SD.SubUnitQuantity,  Case when EnterKind=0 then 0 else SD.GoodsQuantity END GoodsQuantity, SD.QtyRemain, SD.GoodsAmount, SD.UserGoodsAmount, 
			SD.AtomAmount, SD.AmntRemain, SD.AmntRemain0, SD.ProcessID, SD.DocStep, LTrim(RTrim(SD.StoreID)) StoreID, LTrim(RTrim(SD.StoreID2)) StoreID2, SD.GoodsPrice, SD.ProcessNo, SD.FiscalYear, SD.SerialNo, 
			SD.RowNo, SD.DocRowNo, SD.BaseProcessID, SD.BaseProcessNo, SD.BaseFiscalYear, SD.BaseSerialNo, SD.BaseDocRowNo, SD.AcntCode,SD.IsReward, 
			SD.WageRate,SD.Wage, SH.ProductCount, SH.BaseDocType, SH.FormulaNo AS FormulaNoHdr ,SD.FormulaNo AS FormulaNoDtl, 
			Case SH.ProcessID WHEN 80 THEN [pub].[funGetGoodsName](GoodsID,@LanguageID)  ELSE '' END GoodsName, 
			Case SH.ProcessID WHEN 80 THEN [inv].[funGetUnitName](SubUnitID,@LanguageID) ELSE '' END UnitName , SH.SaleTypeID ,SD.BatchNo,SH.BatchNo BatchNoHdr,ProductID,DiscountDtl,
			CostAcntCode,CostPercent,PricePercent,CASE WHEN @CalcnGoodsCountFormula = 'False' THEN 0  ELSE [prd].[funGoodsCountFormula](SH.ProductID,SD.GoodsID,SH.FormulaNo) END FCnt,GoodsQuantity GQTY,SD.Shipment,SD.BranchID,SD.UserPriceID,SH.ModificationKind,
			ISNULL(AtomRowNo,0) AtomRowNo,ISNULL(PortionGoods,0) PortionGoods,ISNULL(PortionSalary,0) PortionSalary,ISNULL(PortionOverLoad,0) PortionOverLoad,ISNULL(PortionOtherCost,0) PortionOtherCost,		
				ISNULL(GoodsRemain,0) GoodsRemain,ISNULL(SalaryRemain,0) SalaryRemain,ISNULL(OverLoadRemain,0) OverLoadRemain,ISNULL(OtherCostRemain,0) OtherCostRemain	,SH.VchNo	
	FROM inv.tblStorageDocsDtl SD
	INNER JOIN inv.tblStorageDocsHdr SH 
	ON SD.ProcessID=SH.ProcessID AND SD.ProcessNo=SH.ProcessNo AND SD.FiscalYear=SH.FiscalYear AND SD.SerialNo=SH.SerialNo  
	LEFT JOIN (SELECT * 
			   FROM (SELECT ROW_NUMBER()over(partition by ProcessID, ProcessNo, FiscalYear, SerialNo, DocRowNo order by ProcessID, ProcessNo, FiscalYear, SerialNo, DocRowNo,AtomRowNo  desc) R ,* 
			         FROM cac.tblStorageDocsPortionAtm
					 WHERE  @FromDate <= DocDate and DocDate <= @ToDate
					 ) a
			    WHERE R=1
				) PA 
	ON SD.ProcessID=PA.ProcessID AND SD.ProcessNo=PA.ProcessNo AND SD.FiscalYear=PA.FiscalYear AND SD.SerialNo=PA.SerialNo AND  SD.DocRowNo=PA.DocRowNo	
	WHERE @FromDate <= SD.DocDate and SD.DocDate <= @ToDate  AND SUBSTRING(SD.GoodsID,@str_Goods+1,@str_GoodsSum) NOT IN (SELECT * from #TService) 
	ORDER BY DocDate,VolumeRowNo,GoodsID,StoreID,BatchNo,UserPriceID

	END
END
GO
