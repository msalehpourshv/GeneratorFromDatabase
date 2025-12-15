USE TS_ShirinVatanKarkhaneh_1_1404
GO
SET ANSI_NULLS, QUOTED_IDENTIFIER ON
GO
-- =========== TS-QC:UPDATED ====================
-- Author		 : REZA NOGREHPASAND / TAKROSYSTEM
-- Create date   : 1391/11/09
-- Viewed By	 : 
-- Last Modified : 
-- Last Modifier : 
-- Description	 : گزارش فروش روزانه رستوران  
-- =============================================
Create PROCEDURE [sal].[RptSal_Restaurant_DailySale] 
		
	@FromSerialNo	INT = NULL,
	@ToSerialNo		INT = NULL,
	@FromDate		CHAR(10) = NULL,
	@ToDate			CHAR(10) = NULL,
	@BranchID		VARCHAR(20) = NULL,
	@UserAcntCode	VARCHAR(20) = NULL,
	@SalonID		VARCHAR(20) = NULL,
	@SalonGroupLen	INT = NULL,
	@GarsonID		VARCHAR(20) = NULL,
	@GoodsID		INT=NULL,
	@SaleType		INT = NULL,
	@CustomerID		VARCHAR(20) = NULL,
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

	SELECT @UnitPart = SettingValue 
	FROM pub.tblSettings 
	WHERE SettingKey = 'UnitPart'

	IF @UnitPart IS NULL or @UnitPart = 0
		SET @UnitPart = 1

	DECLARE @str_Goods  tinyint,
			@str_GoodsSum tinyint

	SELECT @str_Goods = ISNULL(SUM (Layer1+Layer2+Layer3+Layer4+Layer5+Layer6+Layer7+Layer8+Layer9),0)
	FROM pub.tblCodeLayer 
	WHERE TableName = 'inv.tblGoods' AND PartNumber<@UnitPart

	SELECT @str_GoodsSum = Layer1+Layer2+Layer3+Layer4+Layer5+Layer6+Layer7+Layer8+Layer9
	FROM pub.tblCodeLayer 
	WHERE TableName = 'inv.tblGoods' AND PartNumber=@UnitPart
	
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

	SET @StrWhere = '(1=1) AND H.ProcessID = 92 '
	
	IF (@FromSerialNo IS NOT null)
		SET @StrWhere = @StrWhere + ' AND H.SerialNo >= ''' + STR(@FromSerialNo) + ''''

	IF (@ToSerialNo IS NOT null)
		SET @StrWhere = @StrWhere + ' AND H.SerialNo <= ''' + STR(@ToSerialNo) + ''''

	IF (@BranchID IS NOT null)
		SET @StrWhere = @StrWhere + ' AND H.BranchID = ''' + @BranchID + ''''
		
	IF (@FromDate IS NOT null)
		SET @StrWhere = @StrWhere + ' AND H.DocDate >= ''' + @FromDate + ''''
		
	IF (@ToDate IS NOT null)
		SET @StrWhere = @StrWhere + ' AND H.DocDate <= ''' + @ToDate + ''''
		
	IF (@SalonID IS NOT null)
		SET @StrWhere = @StrWhere + ' AND SUBSTRING(H.TableID,1,'+ LTRIM(str(@SalonGroupLen)) +') = ''' + @SalonID + ''''
		
	IF (@GarsonID IS NOT null)
		SET @StrWhere = @StrWhere + ' AND h.GarsonID = ''' + @GarsonID + ''''
		
	IF (@GoodsID > 0)		
		SET @StrWhere = @StrWhere + ' AND ' + pub.funGetFilterString(@SessionNo, @ReportID, @GoodsID, 'D.GoodsID') 		
		
	IF (@SaleType IS NOT null)
		SET @StrWhere = @StrWhere + ' AND H.SaleType = ' +LTRIM(str(@SaleType)) + ''
	
	IF (@CustomerID IS NOT null)
		SET @StrWhere = @StrWhere + ' AND H.CustomerID = ''' + @CustomerID  + ''''

	IF (@SelectedAcnt1 > 0)
		SET @StrWhere = @StrWhere + ' AND ' + pub.funGetFilterString(@SessionNo, @ReportID, @SelectedAcnt1, 'H.UserAcntCode')
	IF (@SelectedAcnt2 > 0)
		SET @StrWhere = @StrWhere + ' AND ' + pub.funGetFilterString(@SessionNo, @ReportID, @SelectedAcnt2, 'H.UserAcntCode')
	IF (@SelectedAcnt3 > 0)
		SET @StrWhere = @StrWhere + ' AND ' + pub.funGetFilterString(@SessionNo, @ReportID, @SelectedAcnt3, 'H.UserAcntCode')
	IF (@SelectedAcnt4 > 0)
		SET @StrWhere = @StrWhere + ' AND ' + pub.funGetFilterString(@SessionNo, @ReportID, @SelectedAcnt4, 'H.UserAcntCode')

	IF @SaleTypeID <>''
		SET @StrWhere = @StrWhere + ' AND D.SaleTypeID = ''' + @SaleTypeID  + ''''
	
-- ================ SELECT ===========================

	SET @StrSelect =' 
	SELECT H.*,
		   D.*,
		   [pub].[funGetGoodsName](D.GoodsID,' + LTrim(RTrim(@LangID)) + ') GoodsName,
		   IsNull([inv].[FunGetGoodsBarCode] (D.GoodsID), '''') BarCode,
		   pub.GetCodeName(H.UserAcntCode,'+ ltrim(STR(@LangID)) +') AS ReciverName,
		   ISNULL(DD.DescriptionName, '''') AS DescName, 
		   ISNULL(GA.GarsonName, '''') GarsonName,
		   ISNULL(TD.TableName, '''') TableName
	FROM sal.tblRestaurantSaleHdr H
	LEFT JOIN sal.tblRestaurantSaleDtl D ON D.ProcessID = H.ProcessID 
										AND D.ProcessNo = H.ProcessNo 
										AND D.FiscalYear = H.FiscalYear 
										AND D.SerialNo = H.SerialNo 
										AND D.DocDate = H.DocDate 
										AND D.BranchID = H.BranchID
	INNER JOIN inv.tblGoodsDtl GD ON GD.GoodsID = SUBSTRING(D.GoodsID,' + ltrim(rtrim(STR(@str_Goods+1))) + ',' + ltrim(rtrim(STR(@str_GoodsSum))) + ') 
								 AND GD.PartNumber = ' + ltrim(rtrim(STR(@UnitPart)))+ '
	LEFT JOIN sal.tblDescriptionDtl DD ON D.DescID = DD.DescriptionID
	LEFT JOIN sal.tblGarsonsDtl GA ON H.GarsonID = GA.GarsonID
	LEFT JOIN sal.tblTablesDtl TD ON H.TableID = TD.TableID 
	WHERE ' + @StrWhere

-- ================ SELECT ===========================

	-- Exeute --------------------------
	PRINT @StrSelect;
	EXEC sp_executesql @StrSelect;

	--=========================================================================================
END
GO
