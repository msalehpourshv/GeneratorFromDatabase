USE TS_ShirinVatanKarkhaneh_1_1404
GO
SET ANSI_NULLS, QUOTED_IDENTIFIER ON
GO
-- =========== TS-QC:UPDATED ====================
-- Author		 : TakroSystem\Zia
-- Create date   : 1387/01/06
-- Viewed By	 : 
-- Last Modified : 1392/03/01
-- Last Modifier : TakroSystem\Zia
-- Description	 : �ѐ �����
-- ==============================================
Create PROCEDURE [inv].[RptStore_Doc_Ex]
	@ProcessID		Int = 90,
	@ProcessNo		Int = 1,
	@FiscalYear		Int = Null,
	@SerialNo		Int = Null,
	@Extraparams	nvarchar(10) = '',
	@RepOptions		varchar(20) = '1000'
WITH ENCRYPTION
AS 
DECLARE @StrSelect	NVarChar(max);
DECLARE @StrFrom	NVarChar(max);
DECLARE @StrWhere	NVarChar(max);

DECLARE @UseCurrency	bit;
Begin --============== S T A R T  C O D E =======================================

	SET NOCOUNT ON;

	-- Init ------------------------------------------
	-- Init ------------------------------------------
	IF (@ProcessNo Is Null)	SET @ProcessNo = 1;
	IF (@RepOptions Is Null)SET @RepOptions = '1000';
	
	SET @UseCurrency = Substring(@RepOptions, 1, 1);
	--------------------------------------------------

	if (@UseCurrency=1)
		set @StrFrom = 'inv.vwStorageDtl_Currency'
	else
		set @StrFrom = 'inv.tblStorageDocsDtl'
if @Extraparams='1'
	set @StrSelect = '
	SELECT	D.ProcessID	,D.ProcessNo	,D.FiscalYear	,D.SerialNo	,D.GoodsID,sum(GoodsQuantity) GoodsQuantity	,D.GoodsPrice	,H.Discount,EarnestMoney	
,TaxOverWorthCost,TaxCost,H.DiscountPercent, H.TollOverWorthCost, H.TotalLineDiscount, pub.funGetGoodsName(D.GoodsID,1) GoodsName
, H.OtherIncome, H.OtherCost, H.PackingCost,H.TransportationCost, H.TransportationIncome,AfterSaleDiscount,D.BatchNo
	FROM	' + @StrFrom + ' D 
				INNER JOIN inv.tblStorageDocsHdr H ON H.ProcessID = D.ProcessID AND H.ProcessNo = D.ProcessNo AND H.FiscalYear = D.FiscalYear AND H.SerialNo = D.SerialNo
				LEFT JOIN sal.tblTransportersDtl T ON H.TransporterID = T.TransporterID AND T.LanguageID = 1
				LEFT JOIN sal.tblTransportersDtl T2 ON H.TransporterID2 = T2.TransporterID AND T.LanguageID = 1
				LEFT JOIN inv.tblUnitsDtl U ON U.UnitID = D.SubUnitID AND U.LanguageID = 1
				LEFT JOIN inv.tblStoresDtl S ON S.StoreID = D.StoreID AND S.LanguageID = 1
				LEFT JOIN inv.tblStores SH ON SH.StoreID = D.StoreID
				LEFT JOIN inv.tblStoreKeepersDtl SK ON SH.StoreKeeperID = SK.StoreKeeperID AND SK.LanguageID = 1
				LEFT JOIN inv.tblStoresDtl S2 ON S2.StoreID = D.StoreID2 AND S2.LanguageID = 1
				--LEFT JOIN inv.tblGoodsDtl GD ON GD.GoodsID = D.GoodsID AND GD.LanguageID = 1
				LEFT JOIN inv.tblGoods	  GH ON GH.GoodsID = D.GoodsID 
				LEFT JOIN sal.tblSaleTypesDtl STD ON STD.SaleTypeID = D.SaleTypeID AND STD.LanguageID = 1
				LEFT JOIN pub.tblProcess P ON P.ProcessID = D.ProcessID AND P.ProcessNo = D.ProcessNo
				OUTER APPLY acc.funGetCodeInfo(H.AcntCode) AS F
				LEFT JOIN inv.tblSubUnitsDtl V ON V.GoodsID=D.GoodsID AND V.SubUnitID=D.SubUnitID
	WHERE 	D.ProcessID = ' + str(@ProcessID) + '
			AND D.ProcessNo = ' + str(@ProcessNo) + '
			AND	D.FiscalYear = ' + str(@FiscalYear) + '
			AND D.SerialNo = ' + str(@SerialNo) + '
			Group by D.ProcessID	,D.ProcessNo	,D.FiscalYear	,D.SerialNo	,D.GoodsID 	,D.GoodsPrice	,H.Discount,EarnestMoney	
,TaxOverWorthCost,TaxCost,H.DiscountPercent, H.TollOverWorthCost, H.TotalLineDiscount
, H.OtherIncome, H.OtherCost, H.PackingCost,H.TransportationCost, H.TransportationIncome,AfterSaleDiscount,D.BatchNo '
else
	set @StrSelect = '
	SELECT	D.*, H.VchNo, H.ProductID, H.ProductCount, H.DocDesc, H.EarnestMoney, H.DocDate2,
			pub.GetCodeName(H.VisitorAcntCode, 1) As VisitorAcntName,
			H.TaxOverWorthCost, (H.Discount + H.Discount2+ H.Discount3) AS Discount, H.TaxCost,
			H.DiscountPercent, H.TollOverWorthCost, H.TotalLineDiscount, pub.funGetGoodsName(D.GoodsID,1) GoodsName, 
			GH.ExtraField1, GH.ExtraField2, GH.ExtraField3, GH.ExtraField4, GH.ExtraField5,
			pub.funGetGoodsName(H.ProductID, 1) As ProductName, H.OtherIncome, H.OtherCost,
			pub.funGetGoodsName(D.GoodsID2, 1) AS GoodsName2, STD.SaleTypeName,
			F.*, D.AtomAmount AS OverloadAmount, T.TransporterName, U.UnitName, H.PackingCost,
			S.StoreName, S2.StoreName AS StoreName2, Cast('''' AS VarChar(100)) As Packing,
			SH.StoreKeeperID, SK.StoreKeeperName, pub.funGetLocationName(F.LocationID,1) AS LocationName,
			H.TransportationCost, H.TransportationIncome, T2.TransporterName as TransporterName2,
			pub.funGetLocationName(H.LocationID,1) AS LocationName2, isnull(P.ProcessName, '''') as ProcessName,
			H.CashAmount, H.ChequeAmount,
			pub.GetUserName(H.SessionNo) AS UserName, 
			pub.GetUserName(H.SessionNo) AS UserName1, 
			pub.GetUserName(H.SessionNo2) AS UserName2, 
			pub.GetUserName(H.SessionNo3) AS UserName3, 
			pub.GetUserName(H.SessionNo4) AS UserName4, 
			pub.GetUserName(H.SessionNo5) AS UserName5, 
			AfterSaleDiscount, V.UnitValue, V.MainUnitValue,
			inv.funSubUnit2(D.GoodsID) UnitScale,
			inv.funSubUnit2Name(D.GoodsID) UnitNameX,TransporterID2,
			GH.TechnicalSpecifications, GH.TechnicalNo,
			H.AgreeNo as AgreeNoHdr, H.ComssionCostPrice, H.BasculePrice, H.LaborPrice, H.TransportPrice,
				inv.UQ2(D.GoodsID,D.SubUnitID) SQ2
	FROM	' + @StrFrom + ' D 
				INNER JOIN inv.tblStorageDocsHdr H ON H.ProcessID = D.ProcessID AND H.ProcessNo = D.ProcessNo AND H.FiscalYear = D.FiscalYear AND H.SerialNo = D.SerialNo
				LEFT JOIN sal.tblTransportersDtl T ON H.TransporterID = T.TransporterID AND T.LanguageID = 1
				LEFT JOIN sal.tblTransportersDtl T2 ON H.TransporterID2 = T2.TransporterID AND T.LanguageID = 1
				LEFT JOIN inv.tblUnitsDtl U ON U.UnitID = D.SubUnitID AND U.LanguageID = 1
				LEFT JOIN inv.tblStoresDtl S ON S.StoreID = D.StoreID AND S.LanguageID = 1
				LEFT JOIN inv.tblStores SH ON SH.StoreID = D.StoreID
				LEFT JOIN inv.tblStoreKeepersDtl SK ON SH.StoreKeeperID = SK.StoreKeeperID AND SK.LanguageID = 1
				LEFT JOIN inv.tblStoresDtl S2 ON S2.StoreID = D.StoreID2 AND S2.LanguageID = 1
				--LEFT JOIN inv.tblGoodsDtl GD ON GD.GoodsID = D.GoodsID AND GD.LanguageID = 1
				LEFT JOIN inv.tblGoods	  GH ON GH.GoodsID = D.GoodsID 
				LEFT JOIN sal.tblSaleTypesDtl STD ON STD.SaleTypeID = D.SaleTypeID AND STD.LanguageID = 1
				LEFT JOIN pub.tblProcess P ON P.ProcessID = D.ProcessID AND P.ProcessNo = D.ProcessNo
				OUTER APPLY acc.funGetCodeInfo(H.AcntCode) AS F
				LEFT JOIN inv.tblSubUnitsDtl V ON V.GoodsID=D.GoodsID AND V.SubUnitID=D.SubUnitID
	WHERE 	D.ProcessID = ' + str(@ProcessID) + '
			AND D.ProcessNo = ' + str(@ProcessNo) + '
			AND	D.FiscalYear = ' + str(@FiscalYear) + '
			AND D.SerialNo = ' + str(@SerialNo) + '
	ORDER BY DocRowNo'
	------------------------------------------------------------
	PRINT @StrSelect;
	EXEC sp_executesql @StrSelect;
	------------------------------------------------------------
End
GO
