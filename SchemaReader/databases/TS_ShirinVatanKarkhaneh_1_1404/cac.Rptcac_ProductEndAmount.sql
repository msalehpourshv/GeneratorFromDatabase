USE TS_ShirinVatanKarkhaneh_1_1404
GO
SET ANSI_NULLS, QUOTED_IDENTIFIER ON
GO
-- =========== TS-QC:UPDATED ====================
-- Author		 : Reza Nogrehpasand
-- Create date   : 1392/04/3
-- Viewed By	 : 
-- Last Modified : 
-- Last Modifier : 
-- Description	 : گزارش بهاي تمام شده محصول
-- =============================================
Create PROCEDURE [cac].[Rptcac_ProductEndAmount] 
	@ToDate				AS	CHAR(10)='1999/12/29',
	@GoodsFilterObjID	AS	int,
	@StoreFilterObjID	AS	int,
	@ShowSubReport		AS	BIT=1,
	@ShowDetails		AS	BIT=0,
	@RepInfo			AS	NVarChar(100) = '1@1@1'
WITH ENCRYPTION
AS

DECLARE @StrSelect		NVarChar(MAX);
DECLARE @StrWhere		NVarChar(2000);
DECLARE @StrWhereS		NVarChar(2000);
DECLARE @StrGroupBy		NVarChar(100);

DECLARE	@LangID			Char(1);
DECLARE	@SessionNo		Int; -- برای حالت کدهای انتخابی
DECLARE	@ReportID		Int; -- برای حالت کدهای انتخابی
DECLARE	@UserID			Int;
DECLARE	@UserIsAdmin	bit;
DECLARE	@Details		bit;
DECLARE @strMonth		nvarchar(2);
DECLARE @FromDate		NVarCHAR(1000)=''

BEGIN 
	-- ============================ S T A R T =====================================================

	-- Init --------------------------
	SET NOCOUNT ON;
	
	SET @LangID		= pub.funSplitString(@RepInfo, '@', 1);
	SET @SessionNo	= pub.funSplitString(@RepInfo, '@', 2);
	SET @ReportID	= pub.funSplitString(@RepInfo, '@', 3);
	SET @UserID		= pub.funSplitString(@RepInfo, '@', 4);
	SET @UserIsAdmin= pub.funSplitString(@RepInfo, '@', 5);
	SET @Details    = pub.funSplitString(@RepInfo, '@', 6);
	SET @FromDate   = pub.funSplitString(@RepInfo, '@', 7);

	set @StrWhere = ''
	set @StrWhereS = ''
	set @StrGroupBy = ' GROUP BY P.GoodsID'	
	
	IF CAST (pub.funSplitString(@ToDate,'/',2) as tinyint)>=1
		SET @strMonth = CAST (pub.funSplitString(@ToDate,'/',2) as tinyint)-- 1
	ELSE	
		SET @strMonth = ''
		
	IF (@GoodsFilterObjID > 0)
	BEGIN
		SET @StrWhere = @StrWhere + ' AND ' + pub.funGetFilterString(@SessionNo, @ReportID, @GoodsFilterObjID, 'P.GoodsID')
		SET @StrWhereS = @StrWhereS + ' AND ' + pub.funGetFilterString(@SessionNo, @ReportID, @GoodsFilterObjID, 'D.GoodsID')
	END
	IF (@StoreFilterObjID > 0)
	BEGIN
		SET @StrWhere = @StrWhere + ' AND ' + pub.funGetFilterString(@SessionNo, @ReportID, @StoreFilterObjID, 'StoreID')
		SET @StrWhereS = @StrWhereS + ' AND ' + pub.funGetFilterString(@SessionNo, @ReportID, @StoreFilterObjID, 'StoreID')
	END


	IF LTRIM(@FromDate) <>'' 
		SET @FromDate =' AND DocDate>='''+ @FromDate +''''

-- ================ SELECT ===========================
IF @Details = 'False'	
	SET @StrSelect = '
	SELECT	GoodsID, pub.GetGoodsName(P.GoodsID,1)GoodsName,
			(
				SELECT SUM(GoodsQuantity * GoodsAmount' + @strMonth + ')  
				FROM inv.tblStorageDocsDtl D
				WHERE GoodsID = P.GoodsID 
					AND D.ProcessID IN (80,72,73) ' + @FromDate + '
					AND D.DocDate<='''+ @ToDate +'''					
			) -sum(P.PortionOverLoad)
			  -sum(P.PortionSalary)
			  -sum(P.PortionOtherCost) PortionGoods, 
			sum(P.PortionSalary) PortionSalary,
			sum(P.PortionOverLoad) PortionOverLoad, 
			sum(P.PortionOtherCost) PortionOtherCost,
			(
				SELECT SUM(GoodsQuantity) 
				FROM inv.tblStorageDocsDtl D 
				WHERE D.ProcessID IN (80,72,73)						
						AND D.GoodsID=P.GoodsID ' + @FromDate + '
						AND D.DocDate<='''+ @ToDate +''''+ @StrWhereS + '
			) Quantity,0 Details,
			(
				SELECT SUM(GoodsQuantity * GoodsAmount)  
				FROM inv.tblStorageDocsDtl D
				WHERE GoodsID = P.GoodsID 
					AND D.ProcessID IN (80,72,73) ' + @FromDate + '
					AND D.DocDate<='''+ @ToDate +''''+ @StrWhereS + '					
			) SumGoodsAmount
	FROM cac.tblPortionSum P
	WHERE DocDate <= (SELECT MAX(DocDate) from cac.tblPortionSum P WHERE DocDate<=''' + @ToDate + '''' + @FromDate + ') ' + @FromDate + @StrWhere + @StrGroupBy + '
	order by GoodsID'
ELSE
	SET @StrSelect = '
	SELECT	P.GoodsID, pub.GetGoodsName(P.GoodsID,1)GoodsName
		   ,SUM(GoodsQuantity* CASE WHEN b.PortionGoods IS NULL THEN GoodsAmount' + @strMonth + ' ELSE  b.PortionGoods END ) PortionGoods 
	       ,SUM(GoodsQuantity*ISNULL(b.PortionSalary,0)) PortionSalary
	       ,SUM(GoodsQuantity*ISNULL(b.PortionOverLoad,0)) PortionOverLoad
	       ,SUM(GoodsQuantity*ISNULL(b.PortionOtherCost,0)) PortionOtherCost,
			(SELECT SUM(GoodsQuantity) 
			 FROM inv.tblStorageDocsDtl D 
			 WHERE D.ProcessID IN (80,72,73)						
			   AND D.GoodsID=P.GoodsID ' + @FromDate + '
			   AND D.DocDate<='''+ @ToDate +''''+ @StrWhereS + ') Quantity,1 Details
		   ,SUM(GoodsQuantity* GoodsAmount) SumGoodsAmount 
	FROM inv.tblStorageDocsDtl a
	LEFT join 
	(SELECT * 
	  FROM (SELECT ROW_NUMBER()over(partition by ProcessID, ProcessNo, FiscalYear, SerialNo, DocRowNo order by ProcessID, ProcessNo, FiscalYear, SerialNo, DocRowNo,AtomRowNo  desc) R ,* 
			FROM cac.tblStorageDocsPortionAtm WHERE ProcessID IN (80,72,73) ' + @FromDate + ' AND  DocDate<='''+ @ToDate +'''
			) a
	  WHERE R=1 ) b
	on a.ProcessID=b.ProcessID
	and a.ProcessNo=b.ProcessNo
	and a.FiscalYear=b.FiscalYear
	and a.SerialNo=b.SerialNo
	and a.DocRowNo=b.DocRowNo
	INNER JOIN  (SELECT DISTINCT GoodsID FROM cac.tblPortionSum P WHERE DocDate <= (SELECT MAX(DocDate) from cac.tblPortionSum WHERE DocDate<=''' + @ToDate + '''' + @FromDate + ') ' +  @StrWhere + ' )P
	ON a.GoodsID=P.GoodsID
where a.ProcessID IN (80,72,73) ' + replace(@FromDate,'DocDate','a.DocDate') + ' AND a.DocDate<='''+ @ToDate +'''
' +  @StrWhere + @StrGroupBy + '
order by P.GoodsID'

-- ================ SELECT ===========================

	-- Exeute --------------------------
	PRINT @StrSelect;
	EXEC sp_executesql @StrSelect;

	--=========================================================================================
END
GO
