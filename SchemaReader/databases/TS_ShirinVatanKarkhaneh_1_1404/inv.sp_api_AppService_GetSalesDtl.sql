USE TS_ShirinVatanKarkhaneh_1_1404
GO
SET ANSI_NULLS, QUOTED_IDENTIFIER ON
GO
-- =========== TS-QC:NOTOK ========================
-- Author        : Alian Pour
-- Create date   : 1400/11/06
-- Viewed By	 : 
-- Last Modified : 1403/03/30 r.moayed 
-- Description   : 
-- =============================================
CREATE PROCEDURE inv.sp_api_AppService_GetSalesDtl
@SerialNo as nvarchar(50),
@ProcessID as nvarchar(50),
@ProcessNo as nvarchar(50),
@FiscalYear as nvarchar(50),
@AcntCustomerCode as nvarchar(200)

WITH ENCRYPTION
 AS
BEGIN
	DECLARE @StrErrorMessage NVARCHAR(MAX)
	DECLARE @TaxOverWorthPercentInSale AS NVARCHAR(50)
	DECLARE @strQuery  NVARCHAR(Max)

BEGIN TRY
	
	DECLARE @PartNumber Int;
	DECLARE @PStart Int;
	DECLARE @PLen Int;
	DECLARE @PLenSubString Int;

		if( @AcntCustomerCode<>'')
		begin
			select @PartNumber = [acc].[FunGetAcntInfoForRemain](1)

			select @PStart = acc.funGetAcntLayerStartandLen(@PartNumber,1)
		
			select @PLenSubString = Len(pub.funSplitString('' + @AcntCustomerCode + '',',',1))

			SET @AcntCustomerCode=' and SubString(D.AcntCode,' + LTrim(Str(@PStart)) + ',' + LTrim(Str(@PLenSubString)) + ') in (' + @AcntCustomerCode + ')'

		end
	
	SELECT @TaxOverWorthPercentInSale=ISNULL(SettingValue,'0') FROM pub.tblSettings 
	WHERE SettingKey = 'TaxOverWorthPercentInSale'
	
	
	SET @strQuery ='
		SELECT DocDate , FiscalYear , ProcessNo ,ProcessID, SerialNo , D.StoreID , DescDtl , G.GoodsID ,
		GoodsName ,cast ( D.GoodsPrice as float) as GoodsPrice , cast(GoodsQuantity as float) as GoodsQuantity , D.RowNo , 
		D.SaleTypeID , u.UnitName , TechnicalNo , S.StoreName ,cast( DiscountPercentDtl as float) as DiscountPercentDtl,
		cast(DiscountDtl as float) as DiscountDtl ,
			   CASE
			   WHEN ' + @TaxOverWorthPercentInSale + '<>''0'' OR ' + @TaxOverWorthPercentInSale + '<>'''' THEN CAST(' + @TaxOverWorthPercentInSale + 'AS INT)
			   WHEN ' + @TaxOverWorthPercentInSale + '=''0'' OR ' + @TaxOverWorthPercentInSale + '='''' THEN CAST(G.Tax AS INT)
			   END Tax,TaxOverWorthCostDtl as TaxOverWorthCost,TollOverWorthCostDtl as TollOverWorthCost
		FROM inv.tblStorageDocsDtl D
			LEFT JOIN inv.tblGoodsDtl GD on D.GoodsID=GD.GoodsID
			LEFT JOIN inv.tblGoods G on D.GoodsID=G.GoodsID
			LEFT JOIN inv.tblSubUnitsDtl su ON G.GoodsID=su.GoodsID and su.ShowInInvoice=1
			LEFT JOIN inv.tblUnitsDtl u ON G.UnitID =u.UnitID 
			LEFT JOIN inv.tblUnitsDtl U ON su.SubUnitID=U.UnitID
			LEFT JOIN inv.tblStoresDtl S ON S.StoreID=D.StoreID
		WHERE ProcessID=' + @ProcessID +' AND SerialNo=' + @SerialNo + ' AND
			  ProcessNo=' + @ProcessNo + ' AND FiscalYear=' + @FiscalYear + ' AND 
			  u.LanguageID=1 AND  GD.LanguageID=1 ' + @AcntCustomerCode
		
	PRINT @strQuery
	EXEC sp_executesql @strQuery

END TRY
BEGIN CATCH


	Set @StrErrorMessage = ERROR_MESSAGE() 
	raiserror (@StrErrorMessage, 16, 1)

END CATCH

END	
GO
