USE TS_ShirinVatanKarkhaneh_1_1404
GO
SET ANSI_NULLS, QUOTED_IDENTIFIER ON
GO
-- =========== TS-QC:UPDATED ====================
-- Author		 : Hadi Sadeghi
-- Create date   : 1392/05/22
-- Viewed By	 : 
-- Last Modified : 
-- Last Modifier : 
-- Description	 : 
-- =============================================
CREATE PROCEDURE [cac].[Rptcac_CompareProduct_Sale] 
	
	@ToDate				AS	CHAR(10)='1999/12/29',
	@GoodsFilterObjID	AS	int=0,
	@StoreFilterObjID	AS	int=0,
	@ShowSubReport		AS	BIT='true',
	@ShowDetails		AS	BIT=0,
	@RepInfo			AS	NVarChar(100) = '1@1@1'

WITH ENCRYPTION
AS

DECLARE @StrSelect		NVarChar(MAX);
DECLARE @StrWhere		NVarChar(2000);
DECLARE @StrAmount		varchar(50);

DECLARE	@LangID			Char(1);
DECLARE	@SessionNo		Int; -- برای حالت کدهای انتخابی
DECLARE	@ReportID		Int; -- برای حالت کدهای انتخابی
DECLARE	@UserID			Int;
DECLARE	@UserIsAdmin	 bit;
DECLARE @db_0000		nvarchar(50);

BEGIN 
	-- ============================ S T A R T =====================================================

	-- Init --------------------------
	SET NOCOUNT ON;
	
	set @db_0000 = Substring(db_name(), 1, Len(db_name()) - 4) + '0000'
	
	SET @LangID		= pub.funSplitString(@RepInfo, '@', 1);
	SET @SessionNo	= pub.funSplitString(@RepInfo, '@', 2);
	SET @ReportID	= pub.funSplitString(@RepInfo, '@', 3);
	SET @UserID		= pub.funSplitString(@RepInfo, '@', 4);
	SET @UserIsAdmin= pub.funSplitString(@RepInfo, '@', 5);
	
	IF CAST (pub.funSplitString(@ToDate,'/',2) as tinyint)>=1
		SET @StrAmount = 'GoodsAmount' + ltrim(STR( CAST (pub.funSplitString(@ToDate,'/',2) as tinyint)))-- 1
	ELSE	
		SET @StrAmount = 'GoodsAmount'

--
	set @StrWhere = '1=1'	
	
	IF (@GoodsFilterObjID > 0)
		SET @StrWhere = @StrWhere + ' AND ' + pub.funGetFilterString(@SessionNo, @ReportID, @GoodsFilterObjID, 'GoodsID')
		 
	IF (@StoreFilterObjID > 0)
		SET @StrWhere = @StrWhere + ' AND ' + pub.funGetFilterString(@SessionNo, @ReportID, @StoreFilterObjID, 'StoreID') 
		
-- ================ SELECT ===========================
	
	SET @StrSelect = '
		SELECT * 
		FROM 
		(
			SELECT a.StoreID,pub.GetStoreName(StoreID,1) AS StoreName, 
					GoodsID, pub.GetGoodsName(GoodsID,1)GoodsName,
					ISNULL((
					SELECT SUM(GoodsQuantity*' + @StrAmount + ') 
					FROM inv.tblStorageDocsDtl 
					WHERE ProcessID IN (80,72,73) AND 
						 StoreID=a.StoreID AND 
						 GoodsID=a.GoodsID AND 
						 DocDate<='''+ @ToDate +'''),0) SumPrd,
					ISNULL((
						SELECT SUM(GoodsQuantity) 
						FROM inv.tblStorageDocsDtl 
						WHERE ProcessID IN (80,72,73) AND 
							 StoreID=a.StoreID AND 
							 GoodsID=a.GoodsID AND 
							 DocDate<='''+ @ToDate +'''),0) PrdQuantity,
					ISNULL((
					SELECT SUM(GoodsQuantity*GoodsPrice) 
					FROM inv.tblStorageDocsDtl 
					WHERE ProcessID IN (90) AND 
						 StoreID=a.StoreID AND 
						 GoodsID=a.GoodsID AND 
						 DocDate<='''+ @ToDate +'''),0) SumSal,
					ISNULL((
						SELECT SUM(GoodsQuantity) 
						FROM inv.tblStorageDocsDtl 
						WHERE ProcessID IN (90) AND 
						    StoreID=a.StoreID AND 
							GoodsID=a.GoodsID AND 
							DocDate<='''+ @ToDate +'''),0) SalQuantity
			FROM cac.tblPortionSum a
			where ' +  @StrWhere + ' 
			GROUP BY StoreID, GoodsID
		) a '

-- ================ SELECT ===========================

	-- Exeute --------------------------
	PRINT @StrSelect;
	EXEC sp_executesql @StrSelect;

	--=========================================================================================
END
GO
