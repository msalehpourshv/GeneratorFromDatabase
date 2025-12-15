USE TS_ShirinVatanKarkhaneh_1_1404
GO
SET ANSI_NULLS, QUOTED_IDENTIFIER ON
GO
-- =========== TS-QC:UPDATED ====================
-- Author		 : TakroSystem\Jafari
-- Create date   : 1395
-- Viewed By	 : 
-- Last Modified : 1395/05/18
-- Last Modifier : 
-- Description   : <Sale Analysis>
-- ==============================================

Create PROCEDURE [sal].[RptSale_Analysis]
	@SelectedStore			Int = 0,
	@SelectedGoods			Int = 0,
	@DocDateFr				Char(10) = Null,
	@DocDateTo				Char(10) = Null,
	@SortFields				NVarChar(100) = Null,
	@ExtraParams			NVarChar(200) = Null,
	@RepInfo				NVarChar(100) = '1@1@1@1@1'
	
WITH ENCRYPTION
AS 
---- Declarations ---------------
DECLARE @StrSelect			NVarChar(max);
DECLARE @StrWhere			NVarChar(max);
DECLARE @StrWhereQty			NVarChar(max);
DECLARE @StrWhere2			NVarChar(max);

DECLARE	@LangID				Char(1);
DECLARE	@SessionNo			Int; 
DECLARE	@ReportID			Int;
DECLARE	@UserID				Int;
DECLARE	@UserIsAdmin		Bit;
DECLARE	@UseLastLayer		Bit;
DECLARE	@CountRetIn			Bit;

BEGIN --============== S T A R T  C O D E ===================================================

	SET NOCOUNT ON;

	DECLARE @GroupByLayer		Bit;
	DECLARE @LayerLen			int;
	DECLARE @GoodsIDField		varchar(200);
	
	DECLARE @SelectedAcnt1			Int = 0
	DECLARE @SelectedAcnt2			Int = 0
	DECLARE @SelectedAcnt3			Int = 0
	DECLARE @SelectedAcnt4			Int = 0

	IF (@LayerLen = 0) SET @LayerLen = 20;

	-- Init Variables ----------------------------------------------------------
	IF (@SelectedGoods Is Null) SET @SelectedGoods = 0;
	IF (@SelectedStore Is Null) SET @SelectedStore = 0;

	SET @LangID		= pub.funSplitString(@RepInfo, '@', 1);
	SET @SessionNo	= pub.funSplitString(@RepInfo, '@', 2);
	SET @ReportID	= pub.funSplitString(@RepInfo, '@', 3);
	SET @UserID		= pub.funSplitString(@RepInfo, '@', 4);
	SET @UserIsAdmin= pub.funSplitString(@RepInfo, '@', 5);

	SET @GroupByLayer			= LTrim(pub.funSplitString(@ExtraParams, '@', 2));
	SET @LayerLen				= LTrim(pub.funSplitString(@ExtraParams, '@', 3));
	SET @SelectedAcnt1				= LTrim(pub.funSplitString(@ExtraParams, '@', 4));
	SET @SelectedAcnt2				= LTrim(pub.funSplitString(@ExtraParams, '@', 5));
	SET @SelectedAcnt3				= LTrim(pub.funSplitString(@ExtraParams, '@', 6));
	SET @SelectedAcnt4				= LTrim(pub.funSplitString(@ExtraParams, '@', 7));
	SET @UseLastLayer				= LTrim(pub.funSplitString(@ExtraParams, '@', 8));
	SET @CountRetIn					= LTrim(pub.funSplitString(@ExtraParams, '@', 9));	

	IF (@SelectedAcnt1 Is Null)		SET @SelectedAcnt1 = 0;
	IF (@SelectedAcnt2 Is Null)		SET @SelectedAcnt2 = 0;
	IF (@SelectedAcnt3 Is Null)		SET @SelectedAcnt3 = 0;
	IF (@SelectedAcnt4 Is Null)		SET @SelectedAcnt4 = 0;

	SET @StrWhere='  '
	SET @StrWhereQty='  '
	SET @StrWhere2='  '
	
	IF (@DocDateTo Is Not Null)
		SET @StrWhereQty = @StrWhereQty + ' AND (b.DocDate <= ''' + @DocDateTo + ''')'
	
	IF (@DocDateTo Is Not Null)
		SET @StrWhere = @StrWhere + ' AND (b.DocDate <= ''' + @DocDateTo + ''')'
		
	IF (@DocDateFr Is Not Null)
		SET @StrWhere = @StrWhere + ' AND b.DocDate >= ''' + @DocDateFr + ''''
	
	IF (@SelectedGoods > 0)
		SET @StrWhere	 = @StrWhere	+ ' AND ' + pub.funGetFilterString(@SessionNo, @ReportID, @SelectedGoods, 'b.GoodsID') 
	
	IF (@SelectedStore > 0)
		SET @StrWhere	 = @StrWhere	+ ' AND ' + pub.funGetFilterString(@SessionNo, @ReportID, @SelectedStore, 'b.StoreID') 

	IF (@SelectedAcnt1 > 0)
		SET @StrWhere = @StrWhere + ' AND ' + pub.funGetFilterString(@SessionNo, @ReportID, @SelectedAcnt1, 'b.AcntCode')
	IF (@SelectedAcnt2 > 0)
		SET @StrWhere = @StrWhere + ' AND ' + pub.funGetFilterString(@SessionNo, @ReportID, @SelectedAcnt2, 'b.AcntCode')
	IF (@SelectedAcnt3 > 0)
		SET @StrWhere = @StrWhere + ' AND ' + pub.funGetFilterString(@SessionNo, @ReportID, @SelectedAcnt3, 'b.AcntCode')
	IF (@SelectedAcnt4 > 0)
		SET @StrWhere = @StrWhere + ' AND ' + pub.funGetFilterString(@SessionNo, @ReportID, @SelectedAcnt4, 'b.AcntCode')

	IF (@SelectedGoods > 0)
		SET @StrWhereQty = @StrWhereQty	+ ' AND ' + pub.funGetFilterString(@SessionNo, @ReportID, @SelectedGoods, 'b.GoodsID') 
	
	IF (@SelectedStore > 0)
		SET @StrWhereQty = @StrWhereQty	+ ' AND ' + pub.funGetFilterString(@SessionNo, @ReportID, @SelectedStore, 'b.StoreID') 

	IF (@SelectedGoods > 0)
		SET @StrWhere2 = @StrWhere2	+ ' AND ' + pub.funGetFilterString(@SessionNo, @ReportID, @SelectedGoods, 'GoodsID') 
	
	IF (@SelectedStore > 0)
		SET @StrWhere2 = @StrWhere2	+ ' AND ' + pub.funGetFilterString(@SessionNo, @ReportID, @SelectedStore, 'StoreID') 

	IF (@GroupByLayer = 1)
		SET @GoodsIDField = ' Distinct Left(GoodsID, ' + str(@LayerLen) + ') GoodsID'
	ELSE
		SET @GoodsIDField = ' Distinct GoodsID'
	
	IF @UseLastLayer = 1
	BEGIN
		SET @StrWhere =  @StrWhere + ' AND a.GoodsID in (SELECT GoodsID FROM inv.tblStorageDocsDtl) '
		SET @StrWhereQty =  @StrWhereQty + ' AND a.GoodsID in (SELECT GoodsID FROM inv.tblStorageDocsDtl) '
		SET @StrWhere2 =  @StrWhere2 + ' AND a.GoodsID in (SELECT GoodsID FROM inv.tblStorageDocsDtl) '
	END
	ELSE
	BEGIN
		SET @StrWhere =  @StrWhere + ''
		SET @StrWhereQty =  @StrWhere + ''
		SET @StrWhere2 =  @StrWhere2 + ''
	END
	BEGIN TRY
	DROP TABLE ##Sale_Analysis
	END TRY
	BEGIN CATCH
	END CATCH

	SET @StrSelect = '
		SELECT *,
			   (Qty + SaleQty - SaleRetQty) * GoodsPrice as qtyPrice,
			   (SaleQty - SaleRetQty) * GoodsPrice as salPrice

		INTO ##Sale_Analysis
		FROM (
			  SELECT DISTINCT GoodsID,
			  ISNULL((SELECT SUM(GoodsQuantity * EnterKind) FROM inv.tblStorageDocsDtl b WHERE a.GoodsID = b.GoodsID '+ @StrWhereQty +'),0) Qty,
			  ISNULL((SELECT SUM(GoodsQuantity) FROM inv.tblStorageDocsDtl b WHERE a.GoodsID = b.GoodsID AND ProcessID = 90 '+ @StrWhere +'),0) SaleQty,
			  CASE WHEN '+ LTrim(RTrim(STR(@CountRetIn))) +' = 1 THEN (ISNULL((SELECT  SUM(GoodsQuantity) FROM inv.tblStorageDocsDtl b WHERE a.GoodsID = b.GoodsID AND ProcessID = 100 '+ @StrWhere +'),0)) ELSE 0 END SaleRetQty,
			  (SELECT TOP 1 SalePrice FROM sal.tblGoodsPricesDtl b WHERE a.GoodsID = b.GoodsID AND SalePrice > 0) GoodsPrice
			  FROM inv.tblStorageDocsDtl a 
			 ) a
		WHERE Qty <> 0 OR SaleQty <> 0 OR SaleRetQty <> 0 '

	PRINT @StrSelect;
	EXEC sp_executesql @StrSelect;
	
	UPDATE ##Sale_Analysis
	SET GoodsPrice = 
	(SELECT TOP 1 d.GoodsPrice 
	FROM ##Sale_Analysis a 
	INNER JOIN inv.tblStorageDocsDtl d
	ON d.ProcessID = 90 
	AND d.GoodsID = a.GoodsID 
	AND d.GoodsPrice > 0 
	ORDER BY DocDate DESC  )
	WHERE GoodsPrice = 0 OR GoodsPrice IS NULL

	UPDATE ##Sale_Analysis
	SET qtyPrice = (Qty + SaleQty - SaleRetQty) * GoodsPrice
	WHERE qtyPrice=0 OR qtyPrice IS NULL

	UPDATE ##Sale_Analysis
	SET salPrice = (SaleQty - SaleRetQty) * GoodsPrice
	WHERE salPrice=0 OR salPrice IS NULL
	
--SELECT     * FROM       ##Sale_Analysis
SET @StrSelect = '
	SELECT * 
	FROM (SELECT *, 
				 CASE WHEN Qty = 0 THEN 0 ELSE SaleQty / Qty END RateQty,
				 CASE WHEN qtyPrice = 0 THEN 0 ELSE salPrice / qtyPrice END RatePrice,
				 SaleQty + Qty AS QtyAll,
				 CASE WHEN SaleQty + Qty = 0 THEN 0 ELSE SaleQty * 100 / (SaleQty + Qty) END SalePercent,
				 pub.funGetGoodsName(GoodsID,1) GoodsName,
				 IsNull([inv].[FunGetGoodsBarCode] (GoodsID), '''') BarCode
	FROM 
		(
		 SELECT g.GoodsID,
				ISNULL(SUM(Qty) ,0) Qty,
				ISNULL(SUM(qtyPrice) ,0) qtyPrice,
				ISNULL(SUM(SaleQty - SaleRetQty) ,0) SaleQty,
				ISNULL(SUM(salPrice) ,0) salPrice,
				sal.FunGetGoodsAvrageInStoreBetweenDate(g.GoodsID,''' + @DocDateFr + ''',''' + @DocDateTo + ''') as QtyAvg
		 FROM inv.tblGoods g
		 INNER JOIN ##Sale_Analysis aa On LEFT(aa.GoodsID,LEN(g.GoodsID)) = g.GoodsID
		 GROUP BY g.GoodsID 
		)a
	WHERE (Qty <> 0 OR SaleQty <> 0 OR QtyAvg <> 0) 
	  AND GoodsID in ( SELECT LEFT(GoodsID,LEN(a.GoodsID)) GoodsID 
					   FROM inv.tblStorageDocsDtl 
					   WHERE 1=1  '+ @StrWhere2 +') '
 
 IF (@GroupByLayer = 1)
	SET @StrSelect = @StrSelect + ' AND GoodsID in (SELECT GoodsID FROM inv.tblGoods WHERE LEN(GoodsID)=' + str(@LayerLen) + ') '	
		
 SET @StrSelect = @StrSelect + ' ) aa'
 
 IF (@SortFields Is Not Null) AND (@SortFields <> '') 
	SET @StrSelect = @StrSelect + ' ORDER BY ' + @SortFields

	------------------------------------------------------------
	PRINT @StrSelect;
	EXEC sp_executesql @StrSelect;	
	------------------------------------------------------------
END
GO
