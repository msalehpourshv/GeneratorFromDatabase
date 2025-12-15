USE TS_ShirinVatanKarkhaneh_1_1404
GO
SET ANSI_NULLS, QUOTED_IDENTIFIER ON
GO
-- =========== TS-QC:UPDATED ====================
-- Author		 : TakroSystem  \ Nogrehpasand
-- Create date   : 1391/08/30
-- Viewed By	 : 
-- Last Modified : 
-- Last Modifier : 
-- Description	 : (چاپ فاكتور  (فروش رستوران  
-- =============================================
CREATE PROCEDURE [sal].[RptSal_Restaurant_Print] 
		
	@CurrentSerialNo	INT =0,
	@DocDate			CHAR(10)='',
	@PrinterID			VARCHAR(20)='',
	@FirsLayerLenght	INT =0,
	@BranchID			VARCHAR(20)='',
	@SpecificPrinter 	VARCHAR(20)='',
	@AllPrint			BIT='False',
	@AllPrinterName		NVarChar(100)='',
	@RepInfo			NVarChar(100) = '1@1@1' ,
	@pmFixOptions		NVarChar(100) = '1@1@1'

WITH ENCRYPTION
AS

DECLARE @StrSelect		NVarChar(4000);

DECLARE @StrWhere		NVarChar(2000);

DECLARE	@LangID				Char(1);
DECLARE	@SessionNo			Int; -- برای حالت کدهای انتخابی
DECLARE	@ReportID			Int; -- برای حالت کدهای انتخابی

BEGIN 
	-- ============================ S T A R T =====================================================

	-- Init --------------------------
	SET NOCOUNT ON;

	--============== 
	DECLARE @UnitPart TINYINT
	SET @UnitPart  = 1

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
	
	--============== 
	SET @LangID		= pub.funSplitString(@RepInfo, '@', 1);
	SET @SessionNo	= pub.funSplitString(@RepInfo, '@', 2);
	SET @ReportID	= pub.funSplitString(@RepInfo, '@', 3);

-- ================ WHERE ===========================

	set @StrWhere = '(1=1) '
	
	IF (@CurrentSerialNo IS NOT null)
		SET @StrWhere = @StrWhere + ' AND h.SerialNo=' + LTRIM(STR(@CurrentSerialNo))
		
	IF (@DocDate IS NOT null)
		SET @StrWhere = @StrWhere + ' AND h.DocDate = ''' + @DocDate + ''''
	
	IF (@SpecificPrinter ='') AND (@AllPrint='False')
		SET @StrWhere = @StrWhere + ' AND PrintFlag=''False''' 
		
	IF (@SpecificPrinter ='') AND (@AllPrint='True')
		SET @StrWhere = @StrWhere + ' AND IsAllPrinted=''False''' 
		
		
		IF (@SpecificPrinter <> '')
		SET @PrinterID=@SpecificPrinter
						 
	IF (@PrinterID IS NOT null)
		SET @StrWhere = @StrWhere + ' AND g.PrinterID = ''' + @PrinterID + ''''
		
		IF (@BranchID IS NOT null)
		SET @StrWhere = @StrWhere + ' AND h.BranchID = ''' + @BranchID + ''''
		
-- ================ SELECT ===========================

	SET @StrSelect =' 
	SELECT bd.BranchName, h.*,d.*,g.GoodsID,g.PrinterID,g.ShowInSaleMenu,gd.GoodsID,
		   [pub].[funGetGoodsName](gd.GoodsID,' + LTrim(RTrim(@LangID)) + ') GoodsName,
		   IsNull([inv].[FunGetGoodsBarCode] (gd.GoodsID), '''') BarCode, t.TableName, gr.GarsonName,
		   pd.PrinterName,sal.funGetSalonName(h.TableID,' + ltrim(str(@FirsLayerLenght)) + ',' + ltrim(str(@LangID)) + ') as SalonName
	FROM sal.tblRestaurantSaleHdr h
	LEFT JOIN sal.tblRestaurantSaleDtl d ON d.ProcessID = h.ProcessID AND d.ProcessNo = h.ProcessNo AND	
											d.FiscalYear = h.FiscalYear AND d.SerialNo = h.SerialNo AND 
											d.DocDate = h.DocDate AND h.BranchID=d.BranchID
	LEFT JOIN sal.tblGarsonsDtl gr ON h.GarsonID = gr.GarsonID
	INNER JOIN inv.tblGoods g ON g.GoodsID=SUBSTRING(d.GoodsID,' + ltrim(rtrim(STR(@str_Goods+1))) + ',' + ltrim(rtrim(STR( @str_GoodsSum))) + ') AND g.PartNumber=' + ltrim(rtrim(STR(@UnitPart)))+ '
	INNER JOIN sal.tblPrintersDtl pd ON g.PrinterID=pd.PrinterID
	INNER JOIN inv.tblGoodsDtl gd ON gd.GoodsID=SUBSTRING(d.GoodsID,' + ltrim(rtrim(STR(@str_Goods+1))) + ',' + ltrim(rtrim(STR(@str_GoodsSum))) + ') AND gd.PartNumber=' + ltrim(rtrim(STR(@UnitPart)))+ '
	LEFT JOIN sal.tblTablesDtl t ON h.TableID=t.TableID	
	INNER JOIN sal.tblBranchesDtl bd ON h.BranchID=bd.BranchID			    
	WHERE ' + @StrWhere

-- ================ SELECT ===========================

	-- Exeute --------------------------
	PRINT @StrSelect;
	EXEC sp_executesql @StrSelect;

	--=========================================================================================
END
GO
