USE TS_ShirinVatanKarkhaneh_1_1404
GO
SET ANSI_NULLS, QUOTED_IDENTIFIER ON
GO
CREATE Procedure [cac].[SpCalcPortionSum]
	@FromDate CHAR(10),
	@Date CHAR(10)
	WITH ENCRYPTION
AS
BEGIN
	DECLARE @MAXDate CHAR(10)
	SELECT @MAXDate=ISNULL(MAX(ToDate),'') FROM cac.tblPortionCosts WHERE ToDate<@Date
	
	INSERT INTO cac.tblPortionSum
	(ProcessID,FiscalYear,DocDate,StoreID,GoodsID,PortionSalary,PortionOverLoad,PortionGoods,PortionOtherCost)
	SELECT 70 ProcessID,PH.FiscalYear,@Date DocDate, PGD.StoreID,GoodsID,SUM(SalaryAmount)PortionSalary,SUM(OverLoadAmount)PortionOverLoad,SUM(GoodsAmount)PortionGoods ,SUM(OtherCostAmount)PortionOtherCost
	FROM cac.tblPortionGoodsDtl PGD
	inner join cac.tblPortionHdr PH
	on PGD.SerialNo=PH.SerialNo AND PGD.FiscalYear=PH.FiscalYear
	WHERE (@MAXDate = '' OR DocDate>@MAXDate) AND  DocDate<=@Date
	GROUP BY PH.FiscalYear,GoodsID, PGD.StoreID
	
	SELECT *,PortionGoods/Qty GoodsAmount,PortionSalary/Qty SalaryAmount,PortionOverLoad/Qty OverLoadAmount,PortionOtherCost/Qty OtherCostAmount,
	      (PortionGoods+PortionSalary+PortionOverLoad+PortionOtherCost)/Qty Amount 
	from  (
			SELECT *,(SELECT SUM(GoodsQuantity) 
					 FROM inv.tblStorageDocsDtl 
					 WHERE ProcessID IN (80,72,73) AND 
						 GoodsID=cac.tblPortionSum.GoodsID AND 
						 StoreID=cac.tblPortionSum.StoreID AND
						(@FromDate='' OR DocDate>=@FromDate ) AND
						 DocDate<=cac.tblPortionSum.DocDate) Qty
			FROM cac.tblPortionSum
			WHERE DocDate=@Date AND ProcessID = 70
		  ) a

END
GO
