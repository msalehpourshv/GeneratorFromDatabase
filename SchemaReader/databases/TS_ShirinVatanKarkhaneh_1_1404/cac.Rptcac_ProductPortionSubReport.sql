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
CREATE  PROCEDURE [cac].[Rptcac_ProductPortionSubReport] 
	
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

BEGIN 
	-- ============================ S T A R T =====================================================

	-- Init --------------------------
	SET NOCOUNT ON;
	
	set @db_0000 = Substring(db_name(), 1, Len(db_name()) - 4) + '0000'

	IF @RepInfo IS  NULL
	BEGIN
		SET @RepInfo = ''
	END

	SET @LangID		= pub.funSplitString(@RepInfo, '@', 1);
	SET @SessionNo	= pub.funSplitString(@RepInfo, '@', 2);
	SET @ReportID	= pub.funSplitString(@RepInfo, '@', 3);

--
	set @StrWhere = '1=1'	
	
	--IF (@GoodsFilter IS NOT null)
	--	SET @StrWhere = @StrWhere + ' AND ' + @GoodsFilter 
		
	--IF (@StoreFilter IS NOT null)
	--	SET @StrWhere = @StrWhere + ' AND ' + @StoreFilter 
		

		DECLARE @StrAmout AS VARCHAR(30)
		SELECT @StrAmout = [inv].[funGoodsAmount](@ToDate)
-- ================ SELECT ===========================
	
	SET @StrSelect = '
	SELECT C.GoodsID,C.StoreID,SUM(C.GoodsQuantity) GoodsQuantity,SUM(C.GoodsQuantity*GoodsAmount) GoodsAmount ,
		pub.GetStoreName(C.StoreID,'+ltrim(rtrim(str(@LangID)))+')AS StoreName , pub.GetGoodsName(C.GoodsID,'+ltrim(rtrim(str(@LangID)))+')as GoodsName  
	FROM (
		SELECT A.*,A.'+ @StrAmout + ' AS RealGoodsAmount	
		FROM inv.tblStorageDocsDtl A
		INNER JOIN (
		SELECT * FROM inv.tblStorageDocsDtl
		WHERE GoodsID='''+ @GoodsID +''' AND StoreID='''+ @StoreID + ''' AND DocDate <='''+rtrim(@ToDate)+'''
		AND ProcessID=80) B
		ON A.ProcessID=B.BaseProcessID AND A.ProcessNo=B.BaseProcessNo
		AND A.FiscalYear=B.BaseFiscalYear AND A.SerialNo=B.BaseSerialNo
		WHERE A.ProcessID = 70
		 
		  UNION
			 
		SELECT A.*,A.'+ @StrAmout + ' AS RealGoodsAmount	
		FROM inv.tblStorageDocsDtl A
		INNER JOIN (
		SELECT * FROM inv.tblStorageDocsDtl
		WHERE GoodsID='''+ @GoodsID + ''' AND StoreID=''' + @StoreID + ''' AND DocDate<=''' +rtrim(@ToDate)+ '''
		AND ProcessID in (72 ,73)) B
		ON A.BaseProcessID=B.BaseProcessID AND A.BaseProcessNo=B.BaseProcessNo
		AND A.BaseFiscalYear=B.BaseFiscalYear AND A.BaseSerialNo=B.BaseSerialNo AND A.BaseDocRowNo=B.BaseDocRowNo
		WHERE A.ProcessID IN (82,83)) C
	GROUP BY C.GoodsID,C.StoreID'	
 
	 
-- ================ SELECT ===========================

	-- Exeute --------------------------
	PRINT @StrSelect;
	EXEC sp_executesql @StrSelect;

	--=========================================================================================
END
GO
