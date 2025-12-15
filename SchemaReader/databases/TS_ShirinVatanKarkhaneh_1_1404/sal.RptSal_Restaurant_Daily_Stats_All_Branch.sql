USE TS_ShirinVatanKarkhaneh_1_1404
GO
SET ANSI_NULLS, QUOTED_IDENTIFIER ON
GO
-- =========== TS-QC:UPDATED ====================
-- Author		 : REZA NOGREHPASAND / TAKROSYSTEM
-- Create date   : 1392/01/07
-- Viewed By	 : 
-- Last Modified : 
-- Last Modifier : 
-- Description	 : آمار فروش روزانه رستوران تمام شعبه ها  
-- =============================================
CREATE PROCEDURE [sal].[RptSal_Restaurant_Daily_Stats_All_Branch] 
		
	@FromDate		CHAR(10)=NULL,
	@ToDate			CHAR(10)=NULL,
	@UserAcntCode	VARCHAR(20)=NULL,
	@UserAcntName	NVARCHAR(200)=NULL,
	@SalonID		VARCHAR(20)=NULL,
	@SalonName		NVARCHAR(200)=NULL,
	@SalonGroupLen	INT=NULL,
	@GarsonID		VARCHAR(20)=NULL,
	@GarsonName		VARCHAR(200)=NULL,
	@GoodsID		INT=NULL,
	@GoodsName		NVARCHAR(200)=NULL,
	@SaleType		INT=NULL,
	@SaleTypeName	NVARCHAR(100)=NULL,
	@PurSum			FLOAT = 0,
    @ServiceAmount	FLOAT = 0,
    @Tax			FLOAT = 0,
    @Toll			FLOAT = 0,
    @PackingCost	FLOAT = 0,
    @OtherIncome	FLOAT = 0,
    @RoundAmount	FLOAT = 0,
	@Discount		FLOAT = 0,
	@TotalSum		FLOAT = 0,
	@PersonQty		FLOAT = 0,
    @InvoiceCount	FLOAT = 0,
    @TransportationIncome	FLOAT = 0,
    @PurSum1		FLOAT = 0,
    @ServiceAmount1	FLOAT = 0,
    @Tax1			FLOAT = 0,
    @Toll1			FLOAT = 0,
    @PackingCost1	FLOAT = 0,
    @OtherIncome1	FLOAT = 0,
    @RoundAmount1	FLOAT = 0,
	@Discount1		FLOAT = 0,
	@TotalSum1		FLOAT = 0,
	@PersonQty1		FLOAT = 0,
    @InvoiceCount1	FLOAT = 0,
    @TransportationIncome1	FLOAT = 0,
	@customerID		VARCHAR(20)=NULL,
	@RepInfo		NVarChar(100) = '1@1@1' 

WITH ENCRYPTION
AS

DECLARE @StrSelect		NVarChar(4000);

DECLARE @StrWhere		NVarChar(2000);
DECLARE @SaleTypeID		VarChar(20);

DECLARE	@LangID				Char(1);
DECLARE	@SessionNo			Int; -- برای حالت کدهای انتخابی
DECLARE	@ReportID			Int; -- برای حالت کدهای انتخابی
DECLARE @SelectedAcnt1		Int = 0, 
		@SelectedAcnt2		Int = 0, 
		@SelectedAcnt3		Int = 0, 
		@SelectedAcnt4		Int = 0 
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
	SET @SaleTypeID	= pub.funSplitString(@RepInfo, '@', 6);

	SET @SelectedAcnt1 = pub.funSplitString(@RepInfo, '@', 7);
	SET @SelectedAcnt2 = pub.funSplitString(@RepInfo, '@', 8);
	SET @SelectedAcnt3 = pub.funSplitString(@RepInfo, '@', 9);
	SET @SelectedAcnt4 = pub.funSplitString(@RepInfo, '@', 10);

	IF (@GoodsID Is Null)		SET @GoodsID = 0;
	IF (@SelectedAcnt1 Is Null)		SET @SelectedAcnt1 = 0;
	IF (@SelectedAcnt2 Is Null)		SET @SelectedAcnt2 = 0;
	IF (@SelectedAcnt3 Is Null)		SET @SelectedAcnt3 = 0;
	IF (@SelectedAcnt4 Is Null)		SET @SelectedAcnt4 = 0;
-- ================ WHERE ===========================

	SET @StrWhere = '(1=1) '

	--IF (@BranchID IS NOT null)
	--	SET @StrWhere = @StrWhere + ' AND h.BranchID = ''' + @BranchID + ''''
		
	IF (@FromDate IS NOT null)
		SET @StrWhere = @StrWhere + ' AND h.DocDate >= ''' + @FromDate + ''''
		
	IF (@ToDate IS NOT null)
		SET @StrWhere = @StrWhere + ' AND h.DocDate <= ''' + @ToDate + ''''
		
	IF (@SelectedAcnt1 > 0)
		SET @StrWhere = @StrWhere + ' AND ' + pub.funGetFilterString(@SessionNo, @ReportID, @SelectedAcnt1, 'h.UserAcntCode')
	IF (@SelectedAcnt2 > 0)
		SET @StrWhere = @StrWhere + ' AND ' + pub.funGetFilterString(@SessionNo, @ReportID, @SelectedAcnt2, 'h.UserAcntCode')
	IF (@SelectedAcnt3 > 0)
		SET @StrWhere = @StrWhere + ' AND ' + pub.funGetFilterString(@SessionNo, @ReportID, @SelectedAcnt3, 'h.UserAcntCode')
	IF (@SelectedAcnt4 > 0)
		SET @StrWhere = @StrWhere + ' AND ' + pub.funGetFilterString(@SessionNo, @ReportID, @SelectedAcnt4, 'h.UserAcntCode')
		
	IF (@SalonID IS NOT null)
		SET @StrWhere = @StrWhere + ' AND SUBSTRING(h.TableID,1,'+ LTRIM(STR(@SalonGroupLen)) +')= ''' + @SalonID + ''''
		
	IF (@GarsonID IS NOT null)
		SET @StrWhere = @StrWhere + ' AND h.GarsonID = ''' + @GarsonID + ''''		
	
	IF (@GoodsID > 0)		
		SET @StrWhere = @StrWhere + ' AND ' + pub.funGetFilterString(@SessionNo, @ReportID, @GoodsID, 'd.GoodsID') 		
		
	IF (@SaleType IS NOT null)
		SET @StrWhere = @StrWhere + ' AND h.SaleType = ' +LTRIM(STR(@SaleType)) + ''
	
	IF (@customerID IS NOT null)
		SET @StrWhere = @StrWhere + ' AND h.CustomerID = ''' + @customerID + ''''

	IF @SaleTypeID <>''
		SET @StrWhere = @StrWhere + ' AND d.SaleTypeID = ''' + @SaleTypeID  + ''''
		
-- ================ SELECT ===========================
	SET @StrSelect =' 
	SELECT d.GoodsID,
		   SUM(d.Qty) AS Qty,
		   SUM(d.RetQty) as RetQty,
		   Price,
		   SUM(Qty*Price) AS Total,
		   [pub].[funGetGoodsName](d.GoodsID,' + LTrim(RTrim(@LangID)) + ') GoodsName,
		   IsNull([inv].[FunGetGoodsBarCode] (d.GoodsID), '''') BarCode, 
		   h.IsPackage,
		   SUM(d.DiscountDtl) DiscountDtl
	FROM sal.tblRestaurantSaleDtl d 
	INNER JOIN sal.tblRestaurantSaleHdr h ON h.ProcessID = d.ProcessID AND h.ProcessNo = d.ProcessNo AND 
											 h.FiscalYear = d.FiscalYear AND h.SerialNo = d.SerialNo AND 
											 h.DocDate = d.DocDate AND h.BranchID = d.BranchID 
	WHERE ' + @StrWhere + '
	GROUP BY d.GoodsID,Price,h.IsPackage
	ORDER BY h.IsPackage '

-- ================ SELECT ===========================

	-- Exeute --------------------------
	PRINT @StrSelect;
	EXEC sp_executesql @StrSelect;

	--=========================================================================================
END
GO
