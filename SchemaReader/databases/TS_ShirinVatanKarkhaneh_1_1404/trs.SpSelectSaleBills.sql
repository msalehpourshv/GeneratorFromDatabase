USE TS_ShirinVatanKarkhaneh_1_1404
GO
SET ANSI_NULLS, QUOTED_IDENTIFIER ON
GO
CREATE PROCEDURE [trs].[SpSelectSaleBills]
	@AcntCode		Varchar(20),
	@LanguageID		TinyInt
WITH ENCRYPTION
AS

BEGIN
	SELECT A.*,[pub].[funGetSaleTypesName](SaleTypeID,1) SaleTypesName,ProcessName,ISNULL(SumPayedAmount,0) SumPayedAmount,(PureAmount - ISNULL(SumPayedAmount,0)) Remain
	FROM(
	SELECT H.ProcessID,H.ProcessNo,H.FiscalYear,H.SerialNo,VchDate,H.SaleTypeID,SumGoodsPrice - D.TotalLineDiscount - H.Discount-H.Discount2-H.Discount3-H.TransportationCost+H.TransportationIncome
	+H.PackingCost+H.TaxCost-H.VisitorCost-H.DistributeAmount+H.TaxOverWorthCost+
	H.TollOverWorthCost-H.FixCost -H.OtherCost +H.OtherIncome AS PureAmount,H.SettlementDate
	,H.VisitorAcntCode
	FROM inv.tblStorageDocsHdr H
	INNER JOIN (SELECT	ProcessID,ProcessNo,FiscalYear,SerialNo, SUM(ROUND(GoodsPrice *GoodsQuantity,0))SumGoodsPrice  ,SUM(ROUND(DiscountDtl,0))TotalLineDiscount
				FROM inv.tblStorageDocsDtl
				where ProcessID = 90 AND AcntCode = @AcntCode
				GROUP BY ProcessID,ProcessNo,FiscalYear,SerialNo) D
	ON H.ProcessID=D.ProcessID AND H.ProcessNo=D.ProcessNo AND H.FiscalYear=D.FiscalYear AND H.SerialNo=D.SerialNo
	WHERE H.VchNo>0
	) A
	LEFT JOIN pub.tblProcess P 
	ON P.ProcessID = A.ProcessID and P.ProcessNo = A.ProcessNo
	LEFT JOIN (SELECT BaseProcessID,BaseProcessNo,BaseFiscalYear,BaseSerialNo, SUM(PayedAmount)SumPayedAmount
			   FROM trs.tblSaleBillsDtl
			   GROUP BY BaseProcessID,BaseProcessNo,BaseFiscalYear,BaseSerialNo) S 
	ON S.BaseProcessID = A.ProcessID and S.BaseProcessNo = A.ProcessNo AND
	   S.BaseFiscalYear = A.FiscalYear and S.BaseSerialNo = A.SerialNo
	WHERE PureAmount - ISNULL(SumPayedAmount,0)>0   
END
GO
