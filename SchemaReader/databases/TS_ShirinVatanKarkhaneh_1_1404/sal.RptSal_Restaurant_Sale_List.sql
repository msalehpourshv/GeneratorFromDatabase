USE TS_ShirinVatanKarkhaneh_1_1404
GO
SET ANSI_NULLS, QUOTED_IDENTIFIER ON
GO
-- =========== TS-QC:UPDATED ====================
-- Author		 : REZA NOGREHPASAND / TAKROSYSTEM
-- Create date   : 1394/05/17
-- Viewed By	 : 
-- Last Modified : 
-- Last Modifier : 
-- Description	 : گزارش فروش روزانه رستوران  
-- =============================================
create  PROCEDURE [sal].[RptSal_Restaurant_Sale_List] 
		
	@FromSerialNo	INT=NULL,
	@ToSerialNo		INT=NULL,
	@FromDate		CHAR(10)=NULL,
	@ToDate			CHAR(10)=NULL,
	@BranchID		VARCHAR(20)=NULL,
	@UserAcntCode	VARCHAR(20)=NULL,
	@SalonID		VARCHAR(20)=NULL,
	@SalonGroupLen	INT=2,
	@GarsonID		VARCHAR(20)=NULL,
	@GoodsID		VARCHAR(20)=NULL,
	@SaleType		INT=NULL,
	@CustomerID		VARCHAR(20)=NULL,
	@PayType		int=null,
	@RepInfo		NVarChar(100) = '1@1@1' 

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

	
	SET @LangID		= pub.funSplitString(@RepInfo, '@', 1);
	SET @SessionNo	= pub.funSplitString(@RepInfo, '@', 2);
	SET @ReportID	= pub.funSplitString(@RepInfo, '@', 3);

-- ================ WHERE ===========================

	SET @StrWhere = ' h.InvoiceStatus=0  '
	
	IF (@PayType IS NOT null AND @PayType=1 ) 
		SET @StrWhere = @StrWhere + ' AND h.CashAmount >0 AND h.PosAmount=0 AND h.IsDebit=0 ' 
	
	IF (@PayType IS NOT null AND @PayType=2 ) 
		SET @StrWhere = @StrWhere + ' AND h.CashAmount =0 AND h.PosAmount>0 AND h.IsDebit=0 ' 
	
	IF (@PayType IS NOT null AND @PayType=3 ) 
		SET @StrWhere = @StrWhere + ' AND h.CashAmount =0 AND h.PosAmount=0 AND h.IsDebit>0 ' 

	IF (@FromSerialNo IS NOT null)
		SET @StrWhere = @StrWhere + ' AND h.SerialNo >= ' + STR(@FromSerialNo) + ''

	IF (@ToSerialNo IS NOT null)
		SET @StrWhere = @StrWhere + ' AND h.SerialNo <= ' + STR(@ToSerialNo) + ''

	IF (@BranchID IS NOT null)
		SET @StrWhere = @StrWhere + ' AND h.BranchID = ''' + @BranchID + ''''
		
	IF (@FromDate IS NOT null)
		SET @StrWhere = @StrWhere + ' AND h.DocDate >= ''' + @FromDate + ''''
		
	IF (@ToDate IS NOT null)
		SET @StrWhere = @StrWhere + ' AND h.DocDate <= ''' + @ToDate + ''''
		
	IF (@UserAcntCode IS NOT null)
		SET @StrWhere = @StrWhere + ' AND h.UserAcntCode = ''' + @UserAcntCode + ''''
		
	IF (@SalonID IS NOT null)
		SET @StrWhere = @StrWhere + ' AND SUBSTRING(h.TableID,1,'+ LTRIM(str(@SalonGroupLen)) +')= ''' + @SalonID + ''''
		
	IF (@GarsonID IS NOT null)
		SET @StrWhere = @StrWhere + ' AND h.GarsonID = ''' + @GarsonID + ''''
		
	IF (@GoodsID IS NOT null)
		SET @StrWhere = @StrWhere + ' AND d.GoodsID = ''' + @GoodsID + ''''
		
	IF (@SaleType IS NOT null)
		SET @StrWhere = @StrWhere + ' AND h.SaleType = ' +LTRIM(str(@SaleType)) + ''
	
	IF (@CustomerID IS NOT null)
		SET @StrWhere = @StrWhere + ' AND h.CustomerID = ''' + @CustomerID  + ''''
				
-- ================ SELECT ===========================

	SET @StrSelect =' SELECT h.*,pub.GetCodeName(h.UserAcntCode,'+ ltrim(STR(@LangID)) +') AS ReciverName,
		ga.GarsonName,td.TableName
		FROM sal.tblRestaurantSaleHdr h
		LEFT JOIN sal.tblGarsonsDtl ga
		ON h.GarsonID=ga.GarsonID
		LEFT JOIN sal.tblTablesDtl td
		ON h.TableID=td.TableID 
	WHERE ' + @StrWhere

-- ================ SELECT ===========================

	-- Exeute --------------------------
	PRINT @StrSelect;
	EXEC sp_executesql @StrSelect;

	--=========================================================================================
END
GO
