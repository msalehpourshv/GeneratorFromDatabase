USE TS_ShirinVatanKarkhaneh_1_1404
GO
SET ANSI_NULLS, QUOTED_IDENTIFIER ON
GO

-- =============================================================================================
-- =============================================================================================
-- =============================================================================================
CREATE PROCEDURE sal.Rpt_Sale_Docs_SHV_01
	@ProcessID  Int           = 90,
	@ProcessNo  Int           = 1,
	@FiscalYear Int           = 1404,
	@SerialNoFr Int           = 0,
	@SerialNoTo Int           = 0,
	@DocDateFr  Char(10)      = '1404/04/01',
	@DocDateTo  Char(10)      = '1404/04/30',
	@AcntCode   VarChar(Max)  = '3161500',
	@StoreID_01 VarChar(20)   = '0852',
	@StoreID_02 VarChar(20)   = '0301',
	@GoodsGroup VarChar(20)   = '0401',
	@GoodsID    VarChar(Max)  = '41010201101007',
	@OP_Type    Int           = 1 -- 2 => Detailed

WITH ENCRYPTION
AS

	DECLARE @StrSelect_1  NVarchar(Max);
	DECLARE @StrSelect_2 NVarchar(Max);
	DECLARE @StrWhere    NVarchar(Max);

	-- ===================================================================================
	SET @StrSelect_1  = ''
	SET @StrSelect_2  = ''
	SET @StrWhere     = '1 = 1'
	
BEGIN --============== S T A R T  C O D E ===================================================

	SET NOCOUNT ON;

	-- ===================================================================================
	-- =================================================================================== WHERE
	-- ===================================================================================
	IF @ProcessID <> 0 And @ProcessID Is Not Null
		SET @StrWhere = @StrWhere + ' 
		 And D.ProcessID  = ' + LTrim(RTrim(Str(@ProcessID)))

	IF @ProcessNo <> 0 And @ProcessNo Is Not Null
		SET @StrWhere = @StrWhere + ' 
		 And D.ProcessNo  = ' + LTrim(RTrim(Str(@ProcessNo)))

	IF @FiscalYear <> 0 And @FiscalYear Is Not Null
		SET @StrWhere = @StrWhere + ' 
		 And D.FiscalYear = ' + LTrim(RTrim(Str(@FiscalYear)))

	IF @SerialNoFr <> 0 And @SerialNoFr Is Not Null
		SET @StrWhere = @StrWhere + ' 
		 And D.SerialNo  >= ' + LTrim(RTrim(Str(@SerialNoFr)))

	IF @SerialNoTo <> 0 And @SerialNoTo Is Not Null
		SET @StrWhere = @StrWhere + ' 
		 And D.SerialNo  <= ' + LTrim(RTrim(Str(@SerialNoTo)))

	IF @DocDateFr <> '' And @DocDateFr Is Not Null
		SET @StrWhere = @StrWhere + ' 
		 And D.DocDate   >= ''' + LTrim(RTrim(@DocDateFr)) + ''''

	IF @DocDateTo <> '' And @DocDateTo Is Not Null
		SET @StrWhere = @StrWhere + ' 
		 And D.DocDate   <= ''' + LTrim(RTrim(@DocDateTo)) + ''''

	--IF @AcntCode <> '' And @AcntCode Is Not Null
	--	SET @StrWhere = @StrWhere + '  
	--	 And D.AcntCode Like ''%' + LTrim(RTrim(@AcntCode)) + '%'''

	IF @AcntCode <> '' And @AcntCode Is Not Null
		SET @StrWhere = @StrWhere + '  
		 And SubString(D.AcntCode, 7, 20) IN(' + LTrim(RTrim(@AcntCode)) + ')'

	IF @StoreID_01 <> '' And @StoreID_01 Is Not Null
		SET @StrWhere = @StrWhere + '  
		 And D.StoreID    = ''' + LTrim(RTrim(@StoreID_01)) + ''''

	IF @StoreID_02 <> '' And @StoreID_02 Is Not Null
		SET @StrWhere = @StrWhere + '  
		 And D.StoreID2   = ''' + LTrim(RTrim(@StoreID_02)) + ''''

	IF @GoodsGroup <> '' And @GoodsGroup Is Not Null
		SET @StrWhere = @StrWhere + ' 
		 And D.GoodsID   IN(Select GoodsID From inv.tblGoodsGroupsGoodsListDtl Where GoodsGroupID = '''+ LTrim(RTrim(@GoodsGroup)) +''')'

	--IF @GoodsID <> '' And @GoodsID Is Not Null
	--	SET @StrWhere = @StrWhere + '  
	--	 And D.GoodsID Like ''%' + LTrim(RTrim(@GoodsID)) + '%'''

	IF @GoodsID <> '' And @GoodsID Is Not Null
		SET @StrWhere = @StrWhere + '  
		 And D.GoodsID   IN(' + LTrim(RTrim(@GoodsID)) + ')'

	-- =====================================================================================
	-- ===================================================================================== Select
	-- =====================================================================================
	IF @OP_Type = 1
	Begin
	   SET @StrSelect_1 = '
       SELECT H.FiscalYear, H.SerialNo, H.DocDate, SubString(H.AcntCode, 7, 20) AcntCode, Cast(Sum(SubUnitQuantity) As Decimal(9, 2)) Qty, 
              REPLACE(CONVERT(VARCHAR, CONVERT(MONEY, Sum(SubUnitQuantity * G.GoodsWeight)), 1), ''.00'', '''') [Weight],
              REPLACE(CONVERT(VARCHAR, CONVERT(MONEY, Price), 1), ''.00'', '''') Amount, 
			  REPLACE(CONVERT(VARCHAR, CONVERT(MONEY, Amount), 1), ''.00'', '''') Pure_Amount
       FROM       inv.tblStorageDocsHdr          H
       INNER JOIN inv.tblStorageDocsDtl          D ON H.ProcessID = D.ProcessID And H.ProcessNo = D.ProcessNo And H.FiscalYear = D.FiscalYear And H.SerialNo = D.SerialNo
       INNER JOIN inv.tblGoods                   G ON G.GoodsID = D.GoodsID
       WHERE ' + @StrWhere + '
       GROUP BY H.FiscalYear, H.SerialNo, H.DocDate, H.AcntCode, Price, Amount
       ORDER BY H.FiscalYear, H.SerialNo
	   '
	End
	ELSE
	Begin
	   SET @StrSelect_1 = '
       SELECT FiscalYear, SerialNo, DocRowNo, DocDate, AcntCode, GoodsID, Qty, [Weight], Goods_Amount, 
              Row_Amount, Discount_Percent, (RowAmount * Discount_Percent) / 100 Pure_Amount
       FROM
       (
         SELECT H.FiscalYear, D.SerialNo, D.RowNo, D.DocRowNo, H.DocDate, SubString(H.AcntCode, 7, 20) AcntCode, D.GoodsID, 
               Cast(SubUnitQuantity As Decimal(9, 2)) Qty, REPLACE(CONVERT(VARCHAR, CONVERT(MONEY, SubUnitQuantity * G.GoodsWeight), 1), ''.00'', '''') [Weight],
               REPLACE(CONVERT(VARCHAR, CONVERT(MONEY, D.GoodsPrice), 1), ''.00'', '''') Goods_Amount,
               D.GoodsPrice * D.SubUnitQuantity RowAmount, REPLACE(CONVERT(VARCHAR, CONVERT(MONEY, D.GoodsPrice * D.SubUnitQuantity), 1), ''.00'', '''') Row_Amount,
               100 * ((H.Discount + H.Discount2 + H.Discount3) / H.Price) Discount_Percent
         FROM       inv.tblStorageDocsHdr          H
         INNER JOIN inv.tblStorageDocsDtl          D ON H.ProcessID = D.ProcessID And H.ProcessNo = D.ProcessNo And H.FiscalYear = D.FiscalYear And H.SerialNo = D.SerialNo
         INNER JOIN inv.tblGoods                   G ON G.GoodsID = D.GoodsID
         WHERE ' + @StrWhere + '
       ) A
       ORDER BY FiscalYear, SerialNo
	   '
	End

	-- ===================================================================================== EXEC
	--PRINT @StrSelect_1
	EXEC sp_executesql @StrSelect_1;

END

GO
