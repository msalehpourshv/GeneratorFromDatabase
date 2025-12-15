USE TS_ShirinVatanKarkhaneh_1_1404
GO
SET ANSI_NULLS, QUOTED_IDENTIFIER ON
GO
--use TS_ShirinVatanKarkhaneh_1_1399

-- =========== TS-QC:UPDATED =====================
-- Author		 : TakroSystem\Ahmadnejad
-- Creation Date : 1392/10/21
-- Viewed By	 : 
-- Last Modified : 1392/10/28
-- Last Modifier : TakroSystem\Zia
-- Description	 : ����� ��� ����
-- ==============================================
Create PROCEDURE [sal].[RptSale_BenefitEx]
	@FiscalYearFr		Int = NULL,
	@SerialNoFr			Int = NULL,
	@FiscalYearTo		Int = NULL,
	@SerialNoTo			Int = NULL,
	@DocDateFr			Char(10) = NULL,
	@DocDateTo			Char(10) = NULL,
	@SelectedGoods		Int = NULL,
	@SelectedStore		Int = NULL,
	@SelectedAcnt1		Int = Null, 
	@SelectedAcnt2		Int = Null,
	@SelectedAcnt3		Int = Null,
	@SelectedAcnt4		Int = Null,
	@SelectedVisitor1	Int = NULL,
	@SelectedVisitor2	Int = NULL,
	@SelectedVisitor3	Int = NULL,
	@SelectedVisitor4	Int = NULL,
	@SortField			NVarChar(100) = 'StoreID, GoodsID',
	@RepInfo			NVarChar(100) = '1@1@1',
	@RepOptions			NVarChar(50) = '0000000'
WITH ENCRYPTION
AS 
---- Declarations ---------------
Declare @StrSelect	NVarChar(max);
Declare @StrFrom	NVarChar(max);
Declare @StrWhereDAfterSaleDate	NVarChar(max);
Declare @StrWhereD	NVarChar(max);
Declare @StrWhereH	NVarChar(max);
Declare @GoodsAmount varchar(20)
Declare @StoreID	varchar(20)

DECLARE @LangID		Char(1);
DECLARE @SessionNo	Int;
DECLARE @ReportID	Int;
DECLARE @Grouped	bit;

Begin --============== S T A R T  C O D E ===================================================

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
	
	-- Init Variables --------
	IF (@RepInfo	Is Null)	SET @RepInfo = '1@1@1'
	IF (@RepOptions Is Null)	SET @RepOptions = '110001';
	
	IF (@SelectedGoods	Is Null)	SET @SelectedGoods = 0
	IF (@SelectedStore	Is Null)	SET @SelectedStore = 0
	IF (@SelectedAcnt1	Is Null)	SET @SelectedAcnt1 = 0
	IF (@SelectedAcnt2	Is Null)	SET @SelectedAcnt2 = 0
	IF (@SelectedAcnt3	Is Null)	SET @SelectedAcnt3 = 0
	IF (@SelectedAcnt4	Is Null)	SET @SelectedAcnt4 = 0
	IF (@SelectedVisitor1 Is Null)	SET @SelectedVisitor1 = 0
	IF (@SelectedVisitor2 Is Null)	SET @SelectedVisitor2 = 0
	IF (@SelectedVisitor3 Is Null)	SET @SelectedVisitor3 = 0
	IF (@SelectedVisitor4 Is Null)	SET @SelectedVisitor4 = 0

	IF (@FiscalYearFr Is Null)	SET @SerialNoFr = Null;
	IF (@FiscalYearTo Is Null)	SET @SerialNoTo = Null;
	IF (@SerialNoFr	Is Null)	SET @FiscalYearFr = Null;
	IF (@SerialNoTo	Is Null)	SET @FiscalYearTo = Null;

	SET @LangID		= pub.funSplitString(@RepInfo, '@', 1);
	SET @SessionNo	= pub.funSplitString(@RepInfo, '@', 2);
	SET @ReportID	= pub.funSplitString(@RepInfo, '@', 3);

	SET @Grouped	= Substring(@RepOptions, 7, 1);
	
	set @GoodsAmount = LTRIM(inv.funGoodsAmount(@DocDateTo))
	-- --------------------------------------------------
	-- Where Clause -----------------------------------------------------------
	set @StrWhereD = ' (1=1)'
	set @StrWhereH = ' (1=1)'
	set @StrWhereDAfterSaleDate = ''

	IF (@SerialNoFr Is Not Null)
		SET @StrWhereD = @StrWhereD + ' AND (D.FiscalYear > ' + LTrim(Str(@FiscalYearFr)) + ' OR (D.FiscalYear = ' + LTrim(Str(@FiscalYearFr)) + ' AND D.SerialNo >= ' + LTrim(Str(@SerialNoFr)) + '))' 
	IF (@SerialNoTo Is Not Null)
		SET @StrWhereD = @StrWhereD + ' AND (D.FiscalYear < ' + LTrim(Str(@FiscalYearTo)) + ' OR (D.FiscalYear = ' + LTrim(Str(@FiscalYearTo)) + ' AND D.SerialNo <= ' + LTrim(Str(@SerialNoTo)) + '))' 

	IF (@DocDateFr Is Not Null)
	BEGIN
		SET @StrWhereD = @StrWhereD + ' AND (D.DocDate >= ''' + @DocDateFr + ''')'
		SET @StrWhereDAfterSaleDate = ' AND AfterSaleDate>= ''' + @DocDateFr + ''' '
	END	
	IF @DocDateTo Is Not Null
	BEGIN
		SET @StrWhereD = @StrWhereD + ' AND (D.DocDate <= ''' + @DocDateTo + ''')'
		SET @StrWhereDAfterSaleDate = ' AND AfterSaleDate<= ''' + @DocDateTo + ''' '
	END
	IF (@SelectedGoods > 0)
		SET @StrWhereD = @StrWhereD + ' AND ' + pub.funGetFilterString(@SessionNo, @ReportID, @SelectedGoods, 'D.GoodsID') 
	IF (@SelectedStore > 0)
		SET @StrWhereD = @StrWhereD + ' AND ' + pub.funGetFilterString(@SessionNo, @ReportID, @SelectedStore, 'D.StoreID') 

	IF (@SelectedAcnt1 > 0)
		SET @StrWhereD = @StrWhereD + ' AND ' + pub.funGetFilterString(@SessionNo, @ReportID, @SelectedAcnt1, 'D.AcntCode')
	IF (@SelectedAcnt2 > 0)
		SET @StrWhereD = @StrWhereD + ' AND ' + pub.funGetFilterString(@SessionNo, @ReportID, @SelectedAcnt2, 'D.AcntCode')
	IF (@SelectedAcnt3 > 0)
		SET @StrWhereD = @StrWhereD + ' AND ' + pub.funGetFilterString(@SessionNo, @ReportID, @SelectedAcnt3, 'D.AcntCode')
	IF (@SelectedAcnt4 > 0)
		SET @StrWhereD = @StrWhereD + ' AND ' + pub.funGetFilterString(@SessionNo, @ReportID, @SelectedAcnt4, 'D.AcntCode')

	IF (@SelectedVisitor1 > 0)
		SET @StrWhereH = @StrWhereH + ' AND (' + pub.funGetFilterString(@SessionNo, @ReportID, @SelectedVisitor1, 'H.VisitorAcntCode') + ')'
	IF (@SelectedVisitor2 > 0)
		SET @StrWhereH = @StrWhereH + ' AND (' + pub.funGetFilterString(@SessionNo, @ReportID, @SelectedVisitor2, 'H.VisitorAcntCode') + ')'
	IF (@SelectedVisitor3 > 0)
		SET @StrWhereH = @StrWhereH + ' AND (' + pub.funGetFilterString(@SessionNo, @ReportID, @SelectedVisitor3, 'H.VisitorAcntCode') + ')'
	IF (@SelectedVisitor4 > 0)
		SET @StrWhereH = @StrWhereH + ' AND (' + pub.funGetFilterString(@SessionNo, @ReportID, @SelectedVisitor4, 'H.VisitorAcntCode') + ')'
	------------------------------------------------------------
	-- Select Clause -------------------------------------------
	
	if (@Grouped = 1)
		set @StoreID = 'D.StoreID'
	else 
		set @StoreID = ''''' StoreID'
	
	SET @StrSelect = '
	select	D.StoreID, D.GoodsID, D.ProcessID, D.ProcessNo, D.FiscalYear, D.SerialNo,
			Sum(D.Price) Price, 
			Sum(D.Amount) Amount, 
			Sum(D.RewardAmount) RewardAmount, 
			Sum(D.Quantity) Quantity,
			Sum(D.DiscountDtl) DiscountDtl,
			Sum(D.PriceRet) PriceRet, 
			Sum(D.AmountRet) AmountRet, 
			Sum(D.RewardAmountRet) RewardAmountRet, 
			Sum(D.QuantityRet) QuantityRet,
			Sum(D.DiscountDtlRet) DiscountDtlRet,
			case when (H.ProcessID = 90 ) then 1 else 0 end Invoice,
			case when (H.ProcessID = 90 ) then (H.Discount + H.Discount2 + H.Discount3 + CASE WHEN 1=1 ' + @StrWhereDAfterSaleDate + ' THEN  AfterSaleDiscount ELSE 0 END )*Sum(D.Quantity)/(SELECT SUM(GoodsQuantity) from inv.tblStorageDocsDtl a WHERE a.ProcessID=D.ProcessID and a.ProcessNo=D.ProcessNo and a.FiscalYear=D.FiscalYear and a.SerialNo=D.SerialNo)  else 0 end DiscountHdr,
			case when (H.ProcessID = 100) then (H.Discount + H.Discount2 + H.Discount3 )*Sum(D.QuantityRet)/(SELECT SUM(GoodsQuantity) from inv.tblStorageDocsDtl a WHERE a.ProcessID=D.ProcessID and a.ProcessNo=D.ProcessNo and a.FiscalYear=D.FiscalYear and a.SerialNo=D.SerialNo)  else 0 end DiscountHdrRet
	from
	(
		select	' + @StoreID +', D.GoodsID, D.ProcessID, D.ProcessNo, D.FiscalYear, D.SerialNo,
				D.GoodsQuantity Quantity, 
				D.DiscountDtl DiscountDtl, 
				(D.GoodsQuantity * D.GoodsPrice) Price, 
				(D.GoodsQuantity * D.' + @GoodsAmount + ') Amount,
				case when IsReward=''True'' THEN (D.GoodsQuantity * D.' + @GoodsAmount + ') ELSe 0 END RewardAmount,
				0 QuantityRet, 0 DiscountDtlRet, 0 PriceRet, 0 AmountRet,0 RewardAmountRet
		from	inv.tblStorageDocsDtl D 
		where	(D.ProcessID=90) and ' + @StrWhereD + '
		union all
		select	' + @StoreID +', D.GoodsID, D.ProcessID, D.ProcessNo, D.FiscalYear, D.SerialNo,
				0 Quantity, 0 DiscountDtl, 0 Price, 0 Amount,0 RewardAmount,
				D.GoodsQuantity QuantityRet,
				D.DiscountDtl DiscountDtlRet,
				(D.GoodsQuantity * D.GoodsPrice) PriceRet,
				(D.GoodsQuantity * D.' + @GoodsAmount + ') AmountRet,
				case when IsReward=''True'' THEN (D.GoodsQuantity * D.' + @GoodsAmount + ') ELSe 0 END RewardAmountRet
		from	inv.tblStorageDocsDtl D 
		where	(D.ProcessID=100) and ' + @StrWhereD + '
	) D inner join inv.tblStorageDocsHdr H ON H.ProcessID = D.ProcessID AND H.ProcessNo = D.ProcessNo AND H.FiscalYear = D.FiscalYear AND H.SerialNo = D.SerialNo
	where ' + @StrWhereH + '
	group by D.StoreID, D.GoodsID, D.ProcessID, D.ProcessNo, D.FiscalYear, D.SerialNo, H.ProcessID, H.TotalLineDiscount, H.Discount, H.Discount2,H.Discount3,H.AfterSaleDiscount,AfterSaleDate '

	------------------------------------------------------------
	-- Bind with Hdr -------------------------------------------
	SET @StrSelect = '
	SELECT M.*, [pub].[funGetGoodsName](M.GoodsID,' + LTrim(RTrim(@LangID)) + ') GoodsName,
		   IsNull([inv].[FunGetGoodsBarCode] (M.GoodsID), '''') BarCode, S.StoreName
	FROM(
		 Select T.StoreID, T.GoodsID, 
				sum(T.Invoice) InvoiceCount,
				Sum(T.Price) TotalPrice,
				Sum(T.Amount) TotalAmount,
				Sum(T.RewardAmount) TotalRewardAmount,
				Sum(T.Quantity) TotalQuantity,
				Sum(T.DiscountDtl) TotalDiscountDtl, 
				Sum(T.DiscountHdr) TotalDiscountHdr, 
				Sum(T.PriceRet) TotalPriceRet,
				Sum(T.AmountRet) TotalAmountRet,
				Sum(T.RewardAmountRet) TotalRewardAmountRet,
				Sum(T.QuantityRet) TotalQuantityRet,
				Sum(T.DiscountDtlRet) TotalDiscountDtlRet,
				Sum(T.DiscountHdrRet) TotalDiscountHdrRet
		 From
		( 
		' + @StrSelect + '
		) T	
		GROUP BY T.StoreID, T.GoodsID
	) M 
	INNER JOIN inv.tblGoodsDtl G ON G.GoodsID = SUBSTRING(M.GoodsID,' + ltrim(rtrim(STR(@str_Goods+1))) + ',' + ltrim(rtrim(STR(@str_GoodsSum))) + ') AND G.PartNumber=' + ltrim(rtrim(STR(@UnitPart)))+ '
	LEFT  JOIN inv.tblStoresDtl S on S.StoreID = M.StoreID 
	--WHERE (TotalQuantity-TotalQuantityRet) > 0
	'
	
	------------------------------------------------------------
	-- Sort Clause ---------------------------------------------
	If (@SortField Is Not Null) AND (@SortField <> '') 
	SET @StrSelect = @StrSelect + ' 
	ORDER BY ' + @SortField
	------------------------------------------------------------
	-- Run -----------------------------------------------------
	print @StrSelect;
	Exec sp_executesql @StrSelect;
	------------------------------------------------------------
End
GO
