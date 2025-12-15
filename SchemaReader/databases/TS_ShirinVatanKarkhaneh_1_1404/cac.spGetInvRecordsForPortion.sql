USE TS_ShirinVatanKarkhaneh_1_1404
GO
SET ANSI_NULLS, QUOTED_IDENTIFIER ON
GO
--[cac].[spGetInvRecordsForPortion]'','1400/03/31',1

Create PROCEDURE [cac].[spGetInvRecordsForPortion]
	@FromDate     Char(10),
	@ToDate     Char(10),
	@LanguageID SmallInt
WITH ENCRYPTION
AS
BEGIN
	Declare @StrSelect	NVarChar(Max);
	DECLARE @strAmntRemain nvarchar(300) 
	Declare @M as tinyint
	SEt @M= SUBSTRING(@ToDate,6,2)
	SET @strAmntRemain='AmntRemain' + LTRIM(RTRIM(STR(@M-1)))

	--, a.DocStep
	SET @StrSelect = 'select a.DocDate, a.GoodsID,a.GoodsID2, a.VolumeRowNo, a.EnterKind, a.GoodsQuantity, a.QtyRemain, a.GoodsAmount, a.UserGoodsAmount, 
			a.AtomAmount, a.AmntRemain, a.ProcessID, a.StoreID, a.StoreID2, a.GoodsPrice, a.ProcessNo, a.FiscalYear, a.SerialNo, 
			a.RowNo, a.DocRowNo, a.BaseProcessID, a.BaseProcessNo, a.BaseFiscalYear, a.BaseSerialNo, a.BaseDocRowNo, a.AcntCode,a.IsReward, 
			a.WageRate,a.Wage, a.ProductCount, a.FormulaNoHdr ,a.FormulaNoDtl, 
			'''' GoodsName,'''' UnitName , a.SaleTypeID ,a.BatchNo,a.BatchNoHdr,a.UserPriceID,ProductID,DiscountDtl,ModificationKind
			,CostAcntCode,CostPercent,PricePercent,BaseUsed,
			AtomRowNo,PortionGoods,PortionSalary,PortionOverLoad,PortionOtherCost,GoodsRemain,SalaryRemain,OverLoadRemain,OtherCostRemain,
			PortionGoods PortionGoodsPrv,PortionSalary PortionSalaryPrv,PortionOverLoad PortionOverLoadPrv,PortionOtherCost PortionOtherCostPrv,
			GoodsAmount1,GoodsAmount2,GoodsAmount3,GoodsAmount4,GoodsAmount5,GoodsAmount6,
			GoodsAmount7,GoodsAmount8,GoodsAmount9,GoodsAmount10,GoodsAmount11,GoodsAmount12,
			' + @strAmntRemain + '
	from (
			SELECT  SD.DocDate, SD.GoodsID,SD.GoodsID2, SD.VolumeRowNo, SD.EnterKind, SD.GoodsQuantity, SD.QtyRemain, SD.GoodsAmount, SD.UserGoodsAmount, 
					SD.AtomAmount, SD.AmntRemain, SD.ProcessID, SD.DocStep, SD.StoreID, SD.StoreID2, SD.GoodsPrice, SD.ProcessNo, SD.FiscalYear, SD.SerialNo, 
					SD.RowNo, SD.DocRowNo, SD.BaseProcessID, SD.BaseProcessNo, SD.BaseFiscalYear, SD.BaseSerialNo, SD.BaseDocRowNo, SD.AcntCode,SD.IsReward, 
					SD.WageRate,SD.Wage, SH.ProductCount, SH.FormulaNo AS FormulaNoHdr ,SD.FormulaNo AS FormulaNoDtl, 
					SH.SaleTypeID ,SD.BatchNo,SH.BatchNo BatchNoHdr,SD.UserPriceID,ProductID,DiscountDtl,ModificationKind,
					SH.CostAcntCode,SH.CostPercent,SD.PricePercent,
					SD.GoodsAmount1,SD.GoodsAmount2,SD.GoodsAmount3,SD.GoodsAmount4,SD.GoodsAmount5,SD.GoodsAmount6,
					SD.GoodsAmount7,SD.GoodsAmount8,SD.GoodsAmount9,SD.GoodsAmount10,SD.GoodsAmount11,SD.GoodsAmount12,
					' + @strAmntRemain + ',
					(SELECT COUNT(*) FROM inv.tblStorageDocsDtl a 
					   where DocDate <=''' + @ToDate + ''' AND 
							 ((SD.ProcessID<>70 AND SD.ProcessID=a.ProcessID AND SD.ProcessNo=a.ProcessNo AND SD.FiscalYear=a.FiscalYear AND SD.SerialNo=a.SerialNo) OR  
							 (SD.ProcessID=70 AND SD.ProcessID=a.BaseProcessID AND SD.ProcessNo=a.BaseProcessNo AND SD.FiscalYear=a.BaseFiscalYear AND SD.SerialNo=a.BaseSerialNo))) BaseUsed,
				ISNULL(AtomRowNo,0) AtomRowNo,ISNULL(PortionGoods,0) PortionGoods,ISNULL(PortionSalary,0) PortionSalary,ISNULL(PortionOverLoad,0) PortionOverLoad,ISNULL(PortionOtherCost,0) PortionOtherCost,		
				ISNULL(GoodsRemain,0) GoodsRemain,ISNULL(SalaryRemain,0) SalaryRemain,ISNULL(OverLoadRemain,0) OverLoadRemain,ISNULL(OtherCostRemain,0) OtherCostRemain					
			FROM inv.tblStorageDocsDtl SD
			INNER JOIN inv.tblStorageDocsHdr SH 
			ON SD.ProcessID=SH.ProcessID AND SD.ProcessNo=SH.ProcessNo AND SD.FiscalYear=SH.FiscalYear AND SD.SerialNo=SH.SerialNo 
			LEFT JOIN (SELECT * 
			           FROM (SELECT ROW_NUMBER()over(partition by ProcessID, ProcessNo, FiscalYear, SerialNo, DocRowNo order by ProcessID, ProcessNo, FiscalYear, SerialNo, DocRowNo,AtomRowNo  desc) R ,* 
			                 FROM cac.tblStorageDocsPortionAtm) a
			           WHERE R=1) PA 
			ON SD.ProcessID=PA.ProcessID AND SD.ProcessNo=PA.ProcessNo AND SD.FiscalYear=PA.FiscalYear AND SD.SerialNo=PA.SerialNo AND  SD.DocRowNo=PA.DocRowNo
			WHERE  SD.DocDate <= ''' + @ToDate + ''' 
				  AND		  GoodsID IN (SELECT DISTINCT GoodsID 
							  FROM inv.tblStorageDocsDtl 
							  WHERE ProcessID IN(70,75,72,73,80,82,83,260,265,78,88) AND DocDate <=''' + @ToDate + ''') 
		) a
	ORDER BY a.DocDate,a.VolumeRowNo,a.GoodsID,a.StoreID'

		Print @StrSelect;
	Exec sp_executesql @StrSelect;
END
GO
