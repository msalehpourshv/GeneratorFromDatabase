USE TS_ShirinVatanKarkhaneh_1_1404
GO
SET ANSI_NULLS, QUOTED_IDENTIFIER ON
GO
-- =========== TS-QC:UPDATED ====================
-- Author		 : Reza Nogrehpasand
-- Create date   : 1391/11/05
-- Viewed By	 : 
-- Last Modified : 
-- Last Modifier : 
-- Description	 :   براي ميهن خوراك) گزارش داشبوردويزيتور)  
-- =============================================
--[sal].[RptSal_VisitorDashboard2] 25,'1391/11/07','04',10,NULL,FALSE,15,'110101'
CREATE PROCEDURE [sal].[RptSal_VisitorDashboard2] 
		
	@WorkdaysOfMonth	INT =0,
	@DocDate			CHAR(10)='',
	@SelectedMonth		CHAR(2),
	@ToDate				INT=0,
	@VisitorAcntCode	VARCHAR(20)='',
	@AllowDiscount		BIT='False',
	@RemainDays			INT=0,
	@AcntCode			VARCHAR(20)=NULL,
	@RepInfo			NVarChar(100) = '1@1@1'

WITH ENCRYPTION
AS

DECLARE @StrSelect		NVarChar(4000);
DECLARE @strFilter		NVarChar(4000);

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

	set @StrWhere = ' AND (1=1) '
	
	IF @AcntCode IS NULL
		SET @strFilter = ''
	ELSE	
		SET @strFilter = ' d.AcntCode =''' + @AcntCode + ''' AND '	
	
	IF (@VisitorAcntCode IS NOT null)
		SET @StrWhere = @StrWhere + ' AND V.VisitorAcntCode=''' + @VisitorAcntCode + ''''
		
-- ================ SELECT ===========================

	SET @StrSelect ='SELECT V.*,pub.GetCodeName(V.VisitorAcntCode,'+ STR(@LangID)+ ') AS VisitorName ,vd.MonthCode, vd.VisitorAcntCode, vd.CeilingAmount,
		(SELECT COUNT(*)  
		FROM inv.tblStorageDocsDtl d
		WHERE ' + @strFilter + 'SUBSTRING(d.DocDate,6,2)='''+ @SelectedMonth +''' AND d.ProcessID=90 and d.VisitorAcntCode=vd.VisitorAcntCode
		) AS SaleCount,
		(SELECT isnull(SUM(d.GoodsQuantity* d. GoodsPrice),0)
		FROM inv.tblStorageDocsDtl d
		WHERE ' + @strFilter + 'SUBSTRING(d.DocDate,6,2)='''+ @SelectedMonth +''' AND d.ProcessID=90 and d.VisitorAcntCode=vd.VisitorAcntCode
		)AS saleAmount,
		(SELECT COUNT(*)  
		FROM inv.tblStorageDocsDtl d
		WHERE ' + @strFilter + 'SUBSTRING(d.DocDate,6,2)='''+ @SelectedMonth +''' AND d.ProcessID=100 and d.VisitorAcntCode=vd.VisitorAcntCode
		)AS saleRetCount,
		(SELECT isnull(SUM(d.GoodsQuantity* d. GoodsPrice),0)
		FROM inv.tblStorageDocsDtl d
		WHERE ' + @strFilter + 'SUBSTRING(d.DocDate,6,2)='''+ @SelectedMonth +''' AND d.ProcessID=100 and d.VisitorAcntCode=vd.VisitorAcntCode
		)AS saleRetAmount
		FROM (
		SELECT   d.VisitorAcntCode,
		ISNULL(SUM(d.GoodsPrice*d.GoodsQuantity*EnterKind),0)*-1 AS PureSaleAmount
		FROM inv.tblStorageDocsDtl d
		WHERE ' + @strFilter + 'SUBSTRING(d.DocDate,6,2)='''+ @SelectedMonth +''' AND d.ProcessID IN (90,100)
		GROUP BY d.VisitorAcntCode) V
		LEFT JOIN sal.tblVisitCeilingDtl vd
		ON V.VisitorAcntCode=vd.VisitorAcntCode 
		WHERE vd.MonthCode='''+ @SelectedMonth +''''  + @StrWhere

-- ================ SELECT ===========================

	-- Exeute --------------------------
	PRINT @StrSelect;
	EXEC sp_executesql @StrSelect;

	--=========================================================================================
END
GO
