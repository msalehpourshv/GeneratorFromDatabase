USE TS_ShirinVatanKarkhaneh_1_1404
GO
SET ANSI_NULLS, QUOTED_IDENTIFIER ON
GO
-- =========== TS-QC:UPDATED ====================
-- Author		 : TakroSystem  \ NOGREHPASAND
-- Create date   : 1392/12/25
-- Viewed By	 : 
-- Last Modified : 
-- Last Modifier : 
-- Description	 : (چاپ فاكتور - تبلت - (فروش رستوران  
-- =============================================
CREATE PROCEDURE [sal].[RptSal_Restaurant_Print_Tablet] -- '1392/01/30' ,1,'001',null

	@DocDate			CHAR(10)=NULL,
	@SerialNo			INT =NULL,
	@BranchID			VARCHAR(20)=NULL,
	@PrinterID			VARCHAR(20)=NULL
	
WITH ENCRYPTION
AS

DECLARE @StrSelect		NVarChar(4000);
DECLARE @StrWhere		NVarChar(2000);
DECLARE	@LangID			Char(1);

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

	SET @LangID = 1;
-- ================ WHERE ===========================
	SET @StrWhere = '(1=1) AND  PrintFlag=0 '
	
	IF (@SerialNo IS NOT null)
		SET @StrWhere = @StrWhere + ' AND d.SerialNo=' + LTRIM(STR(@SerialNo))
		
	IF (@DocDate IS NOT null)
		SET @StrWhere = @StrWhere + ' AND d.DocDate = ''' + @DocDate + ''''
	
								 
	IF (@PrinterID IS NOT null)
		SET @StrWhere = @StrWhere + ' AND g.PrinterID = ''' + @PrinterID + ''''
		
	IF (@BranchID IS NOT null)
		SET @StrWhere = @StrWhere + ' AND d.BranchID = ''' + @BranchID + ''''
		
-- ================ SELECT ===========================
	IF (@PrinterID IS NOT NULL)
	BEGIN
		SET @StrSelect ='
		SELECT  d.SerialNo,d.GoodsID,[pub].[funGetGoodsName](d.GoodsID,' + LTrim(RTrim(@LangID)) + ') GoodsName,
				IsNull([inv].[FunGetGoodsBarCode] (d.GoodsID), '''') BarCode,d.Qty,	td.TableName,gd.GarsonName,
				h.DocTime,h.SaleType,d.DescriptionName,pd.PrinterName,bd.BranchName
		FROM sal.tblRestaurantSaleDtl d
		LEFT JOIN sal.tblRestaurantSaleHdr h ON h.ProcessID = d.ProcessID AND h.ProcessNo = d.ProcessNo AND 
												h.FiscalYear = d.FiscalYear AND h.SerialNo = d.SerialNo AND 
												h.DocDate = d.DocDate AND h.BranchID = d.BranchID
		LEFT JOIN inv.tblGoods g ON g.GoodsID=SUBSTRING(d.GoodsID,' + ltrim(rtrim(STR(@str_Goods+1))) + ',' + ltrim(rtrim(STR( @str_GoodsSum))) + ') AND g.PartNumber=' + ltrim(rtrim(STR(@UnitPart)))+ '
		LEFT JOIN sal.tblTablesDtl td ON h.TableID=td.TableID
		LEFT JOIN sal.tblGarsonsDtl gd ON h.GarsonID=gd.GarsonID
		LEFT JOIN sal.tblPrintersDtl pd ON g.PrinterID=pd.PrinterID
		LEFT JOIN sal.tblBranchesDtl bd	ON d.BranchID=bd.BranchID
		WHERE ' + @StrWhere
	END
	
IF (@PrinterID IS NULL)
	BEGIN
		SET @StrSelect ='
		SELECT  d.SerialNo,d.GoodsID,[pub].[funGetGoodsName](d.GoodsID,' + LTrim(RTrim(@LangID)) + ') GoodsName,
				IsNull([inv].[FunGetGoodsBarCode] (d.GoodsID), '''') BarCode,d.Qty,td.TableName,gd.GarsonName,
				h.DocTime,h.SaleType,d.DescriptionName,''All Print'' PrinterName,bd.BranchName
		FROM sal.tblRestaurantSaleDtl d
		LEFT JOIN sal.tblRestaurantSaleHdr h ON h.ProcessID = d.ProcessID AND h.ProcessNo = d.ProcessNo AND 
												h.FiscalYear = d.FiscalYear AND h.SerialNo = d.SerialNo AND 
												h.DocDate = d.DocDate AND h.BranchID = d.BranchID
		LEFT JOIN inv.tblGoods g ON g.GoodsID=SUBSTRING(d.GoodsID,' + ltrim(rtrim(STR(@str_Goods+1))) + ',' + ltrim(rtrim(STR( @str_GoodsSum))) + ') AND g.PartNumber=' + ltrim(rtrim(STR(@UnitPart)))+ '
		LEFT JOIN sal.tblTablesDtl td ON h.TableID=td.TableID
		LEFT JOIN sal.tblGarsonsDtl gd ON h.GarsonID=gd.GarsonID
		LEFT JOIN sal.tblPrintersDtl pd ON g.PrinterID=pd.PrinterID
		LEFT JOIN sal.tblBranchesDtl bd	ON d.BranchID=bd.BranchID
		WHERE ' + @StrWhere
	END
	
-- ================ SELECT ===========================

	-- Exeute --------------------------
	PRINT @StrSelect;
	EXEC sp_executesql @StrSelect;

	--=========================================================================================
END
GO
