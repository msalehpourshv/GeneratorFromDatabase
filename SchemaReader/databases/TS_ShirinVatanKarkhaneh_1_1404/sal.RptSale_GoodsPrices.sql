USE TS_ShirinVatanKarkhaneh_1_1404
GO
SET ANSI_NULLS, QUOTED_IDENTIFIER ON
GO
-- =========== TS-QC:UPDATED ====================
-- Author		 : TakroSystem\Ahmadnejad
-- Create date   : 1387/07/08
-- Viewed By	 : 
-- Last ModIFied : 1393/05/30
-- Last ModIFier : TakroSystem\Hamid
-- Description	 : گزارش آخرین فروش برای مشتریان
-- ==============================================
CREATE PROCEDURE [sal].[RptSale_GoodsPrices]
	@GoodsIDFr			VarChar(20) = Null,
	@GoodsIDTo			VarChar(20) = Null,
	@GoodsBarCode		VarChar(20) = Null,
	@SaleTypeID			VarChar(20) = Null,
	@CustomerKindID		VarChar(20) = Null,
	@RepOptions			VarChar(20) = '00',  -- bit array options
	@RepInfo			VarChar(100) = '1@1@1'

WITH ENCRYPTION
AS
---- Declarations ---------------
DECLARE @StrSelect	NVarChar(max)
DECLARE @StrWhere	NVarChar(max)
DECLARE @StrFrom	NVarChar(max)

DECLARE @Today		Char(10);
DECLARE @LanguageID TinyInt;
DECLARE	@SessionNo	Int; 
DECLARE	@ReportID	Int; 

DECLARE	@HaveNoPrice bit;
DECLARE	@AllGoods bit;
DECLARE	@bolIsGroupCode bit;

Begin -- ============== S T A R T  C O D E ====================================

	SET NOCOUNT ON;
	SET @Today = pub.funFarsiDate(GetDate())

	IF (@RepInfo	Is Null)	SET @RepInfo = '1@1@1';
	IF (@RepOptions	Is Null)	SET @RepOptions	= '00';
	
	SET @LanguageID	= pub.funSplitString(@RepInfo, '@', 1);
	SET @SessionNo	= pub.funSplitString(@RepInfo, '@', 2);
	SET @ReportID	= pub.funSplitString(@RepInfo, '@', 3);
	
	SET @HaveNoPrice	= Substring(@RepOptions, 1, 1)
	SET @AllGoods	= Substring(@RepOptions, 2, 1)
	SET @bolIsGroupCode	= Substring(@RepOptions, 3, 1)

	-- Init Variables ---------------------------------------
--	SET @LanguageID = pub.funGetCurrentLanguageID();
	
	-- ========================================= Where
	SET @StrWhere = '1 = 1'

	IF (@GoodsIDFr <> '') And (@GoodsIDFr Is Not Null)
		SET @StrWhere = @StrWhere + ' AND GP.GoodsID >= ''' + @GoodsIDFr + ''''

	IF (@GoodsIDTo <> '') And (@GoodsIDTo Is Not Null)
		SET @StrWhere = @StrWhere + ' AND GP.GoodsID <= ''' + @GoodsIDTo + ''''
		
	IF (@SaleTypeID <> '') And (@SaleTypeID Is Not Null)
		SET @StrWhere = @StrWhere + ' AND GP.SaleTypeID = ''' + @SaleTypeID + ''''
	IF @AllGoods = 1
	BEGIN
		IF @bolIsGroupCode = 1
		 SET @StrWhere =' GP.IsGroupCode=1 '
		ELSE
		 SET @StrWhere =' GP.IsGroupCode=0 '
	END
	-- ========================================= Select
	SET @StrSelect = '
	SELECT GP.*, pub.funGetGoodsName(GP.GoodsID,' + LTrim(RTrim(STR(@LanguageID))) + ') AS GoodsName,
		   S.SaleTypeName, G.BarCode
	FROM sal.tblGoodsPricesDtl GP
	INNER JOIN inv.tblGoods G ON G.GoodsID = GP.GoodsID
	INNER JOIN sal.tblSaleTypesDtl S ON S.SaleTypeID = GP.SaleTypeID
	WHERE ' + @StrWhere
	
	--------------------------------
	PRINT @StrSelect;
	EXEC sp_executesql @StrSelect;
	--------------------------------
END
GO
