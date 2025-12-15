USE TS_ShirinVatanKarkhaneh_1_1404
GO
SET ANSI_NULLS, QUOTED_IDENTIFIER ON
GO
-- =========== TS-QC:UPDATED ====================
-- Author		 : TakroSystem\Ahmadnejad
-- Create date   : 1390/11/12
-- Viewed By	 : 
-- Last Modified : 1390/11/12
-- Last Modifier : 
-- Description   : 
-- =================================================================
Create PROCEDURE [prd].[RptPrd_Forecast1]
(
	@ProductID	Varchar(20),
	@SerialNo	int = 0,
	@RepInfo	NVarChar(100) = '1@1@1',
	@RepOptions	VarChar(10) = ''
)
WITH ENCRYPTION
AS
Declare @StrSelect	NVarChar(4000);
Declare @StrFrom	NVarChar(4000);
Declare @StrWhere	NVarChar(4000);

DECLARE	@LangID		Char(1);
DECLARE	@SessionNo	Int; 
DECLARE	@ReportID	Int;
DECLARE	@Sort		Bit;
DECLARE	@SortType		int; 
BEGIN
	-- Init -------------------------------------------------------------------
	IF (@RepInfo	Is Null)	SET @RepInfo = '1@1@1'
	IF (@RepOptions	Is Null)	SET @RepOptions = '0'

	SET @LangID		= pub.funSplitString(@RepInfo, '@', 1);
	SET @SessionNo	= pub.funSplitString(@RepInfo, '@', 2);
	SET @ReportID	= pub.funSplitString(@RepInfo, '@', 3);
		
	SET @Sort		= Substring(@RepOptions, 4, 1)
	SET @SortType	= Substring(@RepOptions, 5, 1)
	
	--=============================================
	CREATE TABLE #tbl_RptGoods_Prices1
	(
		GoodsID VarChar(20) Collate arabic_cs_as not null,
		SalPrice Float NOT NULL
	);
	
	INSERT INTO #tbl_RptGoods_Prices1 (GoodsID, SalPrice)
	SELECT *
	FROM 
	(
		SELECT DISTINCT GoodsID, 
			IsNull((
				SELECT TOP 1 SalePrice 
				FROM sal.tblGoodsPricesDtl P 
				WHERE P.DefaultSalePriceTypeID=1 and P.GoodsID=M.GoodsID
			),0) SalPrice		
		FROM prd.tblPrdAmountForecastDtl M
	) T 

	UPDATE #tbl_RptGoods_Prices1
	SET SalPrice = GoodsPrice
	FROM inv.tblGoods
	WHERE #tbl_RptGoods_Prices1.GoodsID = inv.tblGoods.GoodsID And 
		  #tbl_RptGoods_Prices1.SalPrice = 0

	--=============================================
	SET @StrSelect = '
	SELECT D.*,H.ExtraPercent, H.ProductCount, H.ToDate, [pub].[funGetGoodsName](D.GoodsID,'+ str(@LangID)+') As GoodsName, 
		   [pub].[funGetGoodsName](D.ProductID, '+ str(@LangID)+') AS ProductName,
		ISNULL((Select SUM(Amount) From prd.tblPrdAmountForecastOverLoadDtl O 
				Where O.ProductID = D.ProductID and O.SerialNo = D.SerialNo),0) AS OverSum,
		ISNULL((Select SUM(Wage1+Wage2+Wage3+Wage4+Wage5+Wage6+Wage7+Wage8+Wage9+Wage10) 
				From prd.tblPrdAmountForecastWagesDtl W 
				Where W.ProductID = D.ProductID and W.SerialNo = D.SerialNo),0) AS WageSum,
				P1.SalPrice LastSalPrice
	FROM prd.tblPrdAmountForecastDtl D
		INNER JOIN prd.tblPrdAmountForecastHdr H ON H.ProductID = D.ProductID and D.SerialNo = H.SerialNo
		LEFT JOIN  #tbl_RptGoods_Prices1 P1 ON P1.GoodsID = D.GoodsID

	WHERE D.ProductID = '''+ @ProductID+'''  and D.SerialNo = '+ str(@SerialNo)+' '

if @Sort=1
begin
	SET @StrSelect = @StrSelect  + '  Order by GoodsQuantity*LastBuyAmount '
	if  @SortType=2
		SET @StrSelect = @StrSelect  + '  Desc '
end 
	PRINT @StrSelect;
	EXEC sp_executesql @StrSelect;
END
GO
