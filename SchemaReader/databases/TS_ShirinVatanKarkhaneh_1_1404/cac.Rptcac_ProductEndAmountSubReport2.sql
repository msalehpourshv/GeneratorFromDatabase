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
CREATE PROCEDURE [cac].[Rptcac_ProductEndAmountSubReport2]
	
	@ToDate			AS	CHAR(10)='1999/12/29',
	@GoodsID		AS	VARCHAR(20)='0101',
	@StoreID		AS	VARCHAR(20)='0101',
	@GoodsName		AS	VARCHAR(20)='0101',
	@RepInfo		AS	NVarChar(100) = '1@1@1'

WITH ENCRYPTION
AS

DECLARE @StrSelect		NVarChar(MAX);
DECLARE @StrWhere		NVarChar(2000);

DECLARE	@LangID			Char(1);
DECLARE	@SessionNo		Int; -- برای حالت کدهای انتخابی
DECLARE	@ReportID		Int; -- برای حالت کدهای انتخابی
declare @db_0000	nvarchar(50);
DECLARE @FromDate		NVarCHAR(1000)=''

BEGIN 
	-- ============================ S T A R T =====================================================

	-- Init --------------------------
	SET NOCOUNT ON;
	
	set @db_0000 = Substring(db_name(), 1, Len(db_name()) - 4) + '0000'
	
	SET @LangID		= pub.funSplitString(@RepInfo, '@', 1);
	SET @SessionNo	= pub.funSplitString(@RepInfo, '@', 2);
	SET @ReportID	= pub.funSplitString(@RepInfo, '@', 3);

	SET @FromDate   = pub.funSplitString(@RepInfo, '@', 7);
--
	set @StrWhere = '1=1'	
	
	IF LTRIM(@FromDate) <>'' 
		SET @FromDate =' AND DocDate>='''+ @FromDate +''''


	--IF (@GoodsFilter IS NOT null)
	--	SET @StrWhere = @StrWhere + ' AND ' + @GoodsFilter 
		
	--IF (@StoreFilter IS NOT null)
	--	SET @StrWhere = @StrWhere + ' AND ' + @StoreFilter 

	DECLARE @StrAmout AS VARCHAR(30)
	
	IF CAST (pub.funSplitString(@ToDate,'/',2) as tinyint)>=1
		SET @StrAmout = 'GoodsAmount' + ltrim(STR( CAST (pub.funSplitString(@ToDate,'/',2) as tinyint)))-- 1
	ELSE	
		SET @StrAmout = 'GoodsAmount'
	
	--SELECT @StrAmout = [inv].[funGoodsAmount](@ToDate)
-- ================ SELECT ===========================
	
	SET @StrSelect = '
	select	T.GoodsID, G.GoodsName, 
			Sum(GoodsQuantity) GoodsQuantitySum, 
			Sum(GoodsQuantity*GoodsAmount) GoodsAmountSum,
			Sum(GoodsQuantity*PortionGoods) PortionGoodsSum,
			Sum(GoodsQuantity*PortionSalary) PortionSalarySum,
			Sum(GoodsQuantity*PortionOverLoad) PortionOverLoadSum,
			Sum(GoodsQuantity*PortionOtherCost) PortionOtherCostSum
	from
	(
		SELECT	A.GoodsID, A.GoodsQuantity, A.'+ @StrAmout + ' GoodsAmount
		   ,CASE WHEN C.PortionGoods IS NULL THEN A.'+ @StrAmout + ' ELSE  C.PortionGoods END PortionGoods 
	       ,ISNULL(C.PortionSalary,0) PortionSalary
	       ,ISNULL(C.PortionOverLoad,0) PortionOverLoad
	       ,ISNULL(C.PortionOtherCost,0) PortionOtherCost
		FROM	inv.tblStorageDocsDtl A
				INNER JOIN 
					(
						SELECT * 
						FROM inv.tblStorageDocsDtl
						WHERE GoodsID='''+ @GoodsID +'''  ' + @FromDate + ' AND DocDate <='''+rtrim(@ToDate)+'''
							AND ProcessID=80
					) B	ON A.ProcessID=B.BaseProcessID AND A.ProcessNo=B.BaseProcessNo AND A.FiscalYear=B.BaseFiscalYear AND A.SerialNo=B.BaseSerialNo
		LEFT JOIN (SELECT * 
				   FROM (SELECT ROW_NUMBER()over(partition by ProcessID, ProcessNo, FiscalYear, SerialNo, DocRowNo order by ProcessID, ProcessNo, FiscalYear, SerialNo, DocRowNo,AtomRowNo  desc) R ,* 
					     FROM cac.tblStorageDocsPortionAtm 
					     WHERE ProcessID IN (70) ' + @FromDate + ' AND  DocDate<='''+ @ToDate +'''
						 ) a
				    WHERE R=1 ) C
		ON  A.ProcessID =C.ProcessID
		AND A.ProcessNo =C.ProcessNo
		AND A.FiscalYear=C.FiscalYear
		AND A.SerialNo  =C.SerialNo
		AND A.DocRowNo  =C.DocRowNo
		WHERE A.ProcessID = 70
		 
		UNION ALL
			 
		SELECT	A.GoodsID, A.GoodsQuantity, A.'+ @StrAmout + ' GoodsAmount
		   ,CASE WHEN C.PortionGoods IS NULL THEN A.'+ @StrAmout + ' ELSE  C.PortionGoods END PortionGoods 
	       ,ISNULL(C.PortionSalary,0) PortionSalary
	       ,ISNULL(C.PortionOverLoad,0) PortionOverLoad
	       ,ISNULL(C.PortionOtherCost,0) PortionOtherCost
		FROM	inv.tblStorageDocsDtl A
				INNER JOIN (
					SELECT * 
					FROM inv.tblStorageDocsDtl
					WHERE GoodsID='''+ @GoodsID + '''  ' + @FromDate + ' AND DocDate<=''' +rtrim(@ToDate)+ '''
						AND ProcessID in (72 ,73)
				) B ON A.BaseProcessID=B.BaseProcessID AND A.BaseProcessNo=B.BaseProcessNo AND A.BaseFiscalYear=B.BaseFiscalYear AND A.BaseSerialNo=B.BaseSerialNo AND A.BaseDocRowNo=B.BaseDocRowNo
		LEFT JOIN (SELECT * 
				   FROM (SELECT ROW_NUMBER()over(partition by ProcessID, ProcessNo, FiscalYear, SerialNo, DocRowNo order by ProcessID, ProcessNo, FiscalYear, SerialNo, DocRowNo,AtomRowNo  desc) R ,* 
					     FROM cac.tblStorageDocsPortionAtm 
					     WHERE ProcessID IN (82,83)  ' + @FromDate + '  AND DocDate<='''+ @ToDate +'''
						 ) a
				    WHERE R=1 ) C
		ON  A.ProcessID =C.ProcessID
		AND A.ProcessNo =C.ProcessNo
		AND A.FiscalYear=C.FiscalYear
		AND A.SerialNo  =C.SerialNo
		AND A.DocRowNo  =C.DocRowNo
		WHERE A.ProcessID IN (82,83)
	) T inner join inv.tblGoodsDtl G on G.GoodsID= T.GoodsID
	group by T.GoodsID, G.GoodsName
 '
	 
-- ================ SELECT ===========================

	-- Exeute --------------------------
	PRINT @StrSelect;
	EXEC sp_executesql @StrSelect;

	--=========================================================================================
END
GO
