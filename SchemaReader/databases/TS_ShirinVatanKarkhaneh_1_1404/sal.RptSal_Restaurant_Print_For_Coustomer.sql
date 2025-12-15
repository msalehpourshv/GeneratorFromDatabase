USE TS_ShirinVatanKarkhaneh_1_1404
GO
SET ANSI_NULLS, QUOTED_IDENTIFIER ON
GO
-- =========== TS-QC:UPDATED ====================
-- Author		 : TakroSystem  \ Nogrehpasand
-- Create date   : 1391/09/06
-- Viewed By	 : 
-- Last Modified : 
-- Last Modifier : 1393/08/21
-- Description	 : (چاپ فاكتور (مخصوص مشتري) (فروش رستوران  
-- =============================================
CREATE PROCEDURE [sal].[RptSal_Restaurant_Print_For_Coustomer]

	@CurrentSerialNo	INT = 0,
	@DocDate			CHAR(10) = '',
	@FirsLayerLenght	INT = 0,
	@BranchID			VARCHAR(20) = '',
	@FooterText			NVARCHAR(200) = '',
	@RepInfo			NVarChar(100) = '1@1@1' ,
	@pmFixOptions		NVarChar(100) = '1@1@1'

WITH ENCRYPTION
AS

DECLARE @StrSelect		NVarChar(4000);
DECLARE @StrWhere		NVarChar(2000);
DECLARE @CompanyName		NVarChar(50)
 
IF (SELECT count(*)  FROM pub.tblSettings WHERE SettingKey='CompanyCompanyName')>0
Begin
	SELECT @CompanyName=cast (SettingValue as nvarchar(500))
	FROM pub.tblSettings
	WHERE SettingKey='CompanyCompanyName'
END
ELSE
BEGIN
    SET @CompanyName='رستوران'
END

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

	SET @StrWhere = '(1=1) '
	
	IF (@CurrentSerialNo IS NOT null)
		SET @StrWhere = @StrWhere + ' AND h.SerialNo=' + LTRIM(STR(@CurrentSerialNo))
		
	IF (@DocDate IS NOT null)
		SET @StrWhere = @StrWhere + ' AND h.DocDate = ''' + @DocDate + ''''
	
		
	IF (@BranchID IS NOT null)
		SET @StrWhere = @StrWhere + ' AND h.BranchID = ''' + @BranchID + ''''
	
-- ================ SELECT ===========================
PRINT @CompanyName
	SET @StrSelect = '
	SELECT bd.BranchName, h.SerialNo, h.DocDate, h.Sum, h.DiscountAmount, h.ServiceAmount, h.TaxOverWorthAmount,
		   h.RoundAmount, h.PayableAmount, h.GeustName, d.Price, Sum(d.Qty)as Qty, Sum(d.Qty * d.Price) TotalPrice, 
		   d.GoodsID,h.CustomerID, g.ShowInSaleMenu, [pub].[funGetGoodsName](d.GoodsID,' + LTrim(RTrim(@LangID)) + ') GoodsName,
		   IsNull([inv].[FunGetGoodsBarCode] (d.GoodsID), '''') BarCode, t.TableName, gr.GarsonName,
		   sal.funGetSalonName(h.TableID,'+ ltrim(str(@FirsLayerLenght)) +','+ ltrim(str(@LangID)) +') as SalonName,
		   SaleType,isnull(A.Address1,'''') as Address1 ,N'''+ @CompanyName +''' as CompanyName,
		h.ContractEarnedAmount
	FROM sal.tblRestaurantSaleHdr h
	LEFT JOIN sal.tblRestaurantSaleDtl d ON d.ProcessID = h.ProcessID AND d.ProcessNo = h.ProcessNo AND d.FiscalYear = h.FiscalYear AND 
											d.SerialNo = h.SerialNo AND d.DocDate = h.DocDate AND h.BranchID=d.BranchID
	LEFT JOIN sal.tblGarsonsDtl gr ON h.GarsonID = gr.GarsonID
	INNER JOIN inv.tblGoods g ON g.GoodsID=SUBSTRING(d.GoodsID,' + ltrim(rtrim(STR(@str_Goods+1))) + ',' + ltrim(rtrim(STR( @str_GoodsSum))) + ') AND g.PartNumber=' + ltrim(rtrim(STR(@UnitPart)))+ '
	INNER JOIN inv.tblGoodsDtl gd ON gd.GoodsID=SUBSTRING(d.GoodsID,' + ltrim(rtrim(STR(@str_Goods+1))) + ',' + ltrim(rtrim(STR(@str_GoodsSum))) + ') AND gd.PartNumber=' + ltrim(rtrim(STR(@UnitPart)))+ '
	LEFT JOIN sal.tblTablesDtl t ON h.TableID=t.TableID
	INNER JOIN sal.tblBranchesDtl bd ON h.BranchID=bd.BranchID
	LEFT JOIN acc.tblAcntDtl A ON A.AcntCode=h.CustomerID	

	WHERE ' + @StrWhere + '
	GROUP BY d.GoodsID, bd.BranchName, h.SerialNo, h.DocDate, h.Sum, h.DiscountAmount, h.ServiceAmount, h.TaxOverWorthAmount, 
	     h.RoundAmount, h.PayableAmount, h.GeustName, d.Price, h.CustomerID, g.ShowInSaleMenu, gd.GoodsName, 
	     t.TableName, gr.GarsonName, h.TableID, SaleType, A.Address1, ContractEarnedAmount 
	HAVING Sum(d.Qty) > 0 ' 

-- ================ SELECT ===========================

	-- Exeute --------------------------
	PRINT @StrSelect;
	EXEC sp_executesql @StrSelect;

END
GO
