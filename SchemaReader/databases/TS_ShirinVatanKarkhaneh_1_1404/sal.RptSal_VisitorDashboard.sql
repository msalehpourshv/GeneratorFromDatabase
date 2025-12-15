USE TS_ShirinVatanKarkhaneh_1_1404
GO
SET ANSI_NULLS, QUOTED_IDENTIFIER ON
GO
-- =========== TS-QC:UPDATED ====================
-- Author		 : Reza Nogrehpasand
-- Create date   : 1391/11/02
-- Viewed By	 : 
-- Last Modified : 
-- Last Modifier : 
-- Description	 : گزارش داشبوردويزيتور  
-- =============================================
CREATE PROCEDURE [sal].[RptSal_VisitorDashboard] 
		
	@WorkdaysOfMonth	INT =0,
	@DocDate			CHAR(10)='',
	@SelectedMonth		CHAR(2),
	@ToDate				INT=0,
	@VisitorAcntCode	VARCHAR(20)='',
	@AllowDiscount		BIT='False',
	@RemainDays			INT=0,
	@RepInfo			NVarChar(100) = '1@1@1'

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

	set @StrWhere = ' AND (1=1) '
	
	IF (@VisitorAcntCode IS NOT null)
		SET @StrWhere = @StrWhere + ' AND V.VisitorAcntCode=''' + @VisitorAcntCode + ''''
		
-- ================ SELECT ===========================

	SET @StrSelect =' SELECT V.*,vd.MonthCode, vd.VisitorAcntCode, vd.CeilingAmount
				FROM (
				SELECT d.VisitorAcntCode,
				SUM(d.GoodsPrice*d.GoodsQuantity) AS SaleAmount
				,pub.GetCodeName(d.VisitorAcntCode,'+ str(@LangID) +') AS VisitorName 
				FROM inv.tblStorageDocsDtl d
				WHERE SUBSTRING(d.DocDate,6,2)='''+ @SelectedMonth +''' AND d.ProcessID=90
				GROUP BY d.VisitorAcntCode) V
				INNER JOIN sal.tblVisitCeilingDtl vd
				ON V.VisitorAcntCode=vd.VisitorAcntCode 
				WHERE vd.MonthCode='''+ @SelectedMonth +'''' + @StrWhere

-- ================ SELECT ===========================

	-- Exeute --------------------------
	PRINT @StrSelect;
	EXEC sp_executesql @StrSelect;

	--=========================================================================================
END
GO
