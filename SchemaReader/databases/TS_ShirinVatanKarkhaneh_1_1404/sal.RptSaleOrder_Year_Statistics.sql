USE TS_ShirinVatanKarkhaneh_1_1404
GO
SET ANSI_NULLS, QUOTED_IDENTIFIER ON
GO
-- =========== TS-QC:UPDATED ====================
-- Author		 : TakroSystem\Zia
-- Create date   : 1390/04/29
-- Viewed By	 : 
-- Last Modified : 1390/04/29
-- Last Modifier : TakroSystem\Zia
-- Description	 : نمودار اسناد سفارش به تفکیک تاریخ
-- ==============================================
Create PROCEDURE [sal].[RptSaleOrder_Year_Statistics] 
	@ProcessID		Int = 180,
	@ProcessNo		Int = 1,
	@SelectedGoods	Int = 0, 
	@SelectedStore	Int = 0, 
	@SelectedAcnt1	Int = 0, 
	@SelectedAcnt2	Int = 0, 
	@SelectedAcnt3	Int = 0, 
	@SelectedAcnt4	Int = 0, 
	@DocDateFr		char(10) = null, 
	@DocDateTo		char(10) = null, 
	@RepOptions		VarChar(10) = '',
	@RepInfo		NVarChar(100) = Null
WITH ENCRYPTION
AS 
---- Declarations ---------------
Declare @StrSelect	NVarChar(4000);
Declare @StrFrom	NVarChar(1000);
Declare @StrWhere	NVarChar(2000);
Declare @StrWhereH	NVarChar(2000);
Declare @StrWhereD	NVarChar(2000);

DECLARE	@LangID		Char(1);
DECLARE	@SessionNo	Int; 
DECLARE	@ReportID	Int; 
Begin --============== S T A R T  C O D E ===================================================

	SET NOCOUNT ON;

	-- Init Variables & Default Values --------------------
	IF (@ProcessNo Is Null)			SET @ProcessNo = 1;

	IF (@SelectedGoods	Is Null)	SET @SelectedGoods = 0;
	IF (@SelectedStore	Is Null)	SET @SelectedStore = 0;
	IF (@SelectedAcnt1	Is Null)	SET @SelectedAcnt1 = 0;
	IF (@SelectedAcnt2	Is Null)	SET @SelectedAcnt2 = 0;
	IF (@SelectedAcnt3	Is Null)	SET @SelectedAcnt3 = 0;
	IF (@SelectedAcnt4	Is Null)	SET @SelectedAcnt4 = 0;

	SET @LangID		= pub.funSplitString(@RepInfo, '@', 1);
	SET @SessionNo	= pub.funSplitString(@RepInfo, '@', 2);
	SET @ReportID	= pub.funSplitString(@RepInfo, '@', 3);
	-- ----------------------------------------------------
	---------------------------------------------------------------------------
	-- Where Clause -----------------------------------------------------------

	-- 1-common --
	Set @StrWhere = '(ProcessNo=' + LTrim(Str(@ProcessNo)) + ')'

	IF (@SelectedStore > 0)
		SET @StrWhere = @StrWhere + ' AND ' + pub.funGetFilterString(@SessionNo, @ReportID, @SelectedStore, 'D.StoreID') 

	IF (@SelectedAcnt1 > 0)
		SET @StrWhere = @StrWhere + ' AND ' + pub.funGetFilterString(@SessionNo, @ReportID, @SelectedAcnt1, 'D.AcntCode')
	IF (@SelectedAcnt2 > 0)
		SET @StrWhere = @StrWhere + ' AND ' + pub.funGetFilterString(@SessionNo, @ReportID, @SelectedAcnt2, 'D.AcntCode')
	IF (@SelectedAcnt3 > 0)
		SET @StrWhere = @StrWhere + ' AND ' + pub.funGetFilterString(@SessionNo, @ReportID, @SelectedAcnt3, 'D.AcntCode')
	IF (@SelectedAcnt4 > 0)
		SET @StrWhere = @StrWhere + ' AND ' + pub.funGetFilterString(@SessionNo, @ReportID, @SelectedAcnt4, 'D.AcntCode')

	SET @StrWhereH = @StrWhere
	SET @StrWhereD = @StrWhere

	-- 3-dtl --
	IF (@SelectedGoods > 0)
		SET @StrWhereD = @StrWhereD + ' AND ' + pub.funGetFilterString(@SessionNo, @ReportID, @SelectedGoods, 'D.GoodsID')

	IF (@DocDateFr is not null)
	begin
		set @StrWhereD = @StrWhereD + ' AND (DocDate >= ''' + @DocDateFr + ''')';
		set @StrWhereH = @StrWhereH + ' AND (DocDate >= ''' + @DocDateFr + ''')';
	end;

	IF (@DocDateTo is not null)
	begin
		set @StrWhereD = @StrWhereD + ' AND (DocDate <= ''' + @DocDateTo + ''')';
		set @StrWhereH = @StrWhereH + ' AND (DocDate <= ''' + @DocDateTo + ''')';
	end;
	--------------------------------------------------------------------
	-- Select Clause ---------------------------------------------------
	IF (@DocDateFr is not null) or (@DocDateTo is not null) 
		Set @StrSelect = ''
	else
		Set @StrSelect = '
	WHILE (@idx1 <= 12)
	BEGIN
		SET @idx2 = 1

		WHILE @idx2 <= 31
		BEGIN
			INSERT INTO #tblDays	
			VALUES (CASE WHEN Len(LTrim(Str(@idx1))) < 2 THEN ''0.0'' ELSE '''' END + LTrim(Str(@idx1)) + ''/'' + CASE WHEN Len(LTrim(Str(@idx2))) < 2 THEN ''0.0'' ELSE '''' END + LTrim(Str(@idx2)))
			SET @idx2 = @idx2 + 1
		END

		SET @idx1 = @idx1 + 1
	END;'

	Set @StrSelect = '
	Declare @idx1 Int
	Declare @idx2 Int
	CREATE TABLE #tblDays (Days Char(10) COLLATE Arabic_CS_AS)
	-- Fill Table Variale With Year Days --
	SET @idx1 = 1

	' + @StrSelect + '

	SELECT	T.DocDate, 
			Round(SUM(T.Price), 0) AS Price, 
			Round(SUM(T.CancelPrice), 0) AS CancelPrice,
			Round(SUM(T.Quantity), 2) AS Quantity, 
			Round(SUM(T.CancelQuantity), 2) AS CancelQuantity
	FROM
	(
		SELECT	RIGHT(D.DocDate, 5) DocDate, 
				CASE WHEN (D.ProcessID=180) THEN (D.GoodsQuantity) ELSE 0 END AS Quantity, 
				CASE WHEN (D.ProcessID=180) THEN (D.GoodsQuantity*D.GoodsPrice) ELSE 0 END AS Price, 
				CASE WHEN (D.ProcessID=185) THEN (D.GoodsQuantity) ELSE 0 END AS CancelQuantity,
				CASE WHEN (D.ProcessID=185) THEN (D.GoodsQuantity*D.GoodsPrice) ELSE 0 END AS CancelPrice
		FROM	sal.tblSaleOrderDtl D 
		WHERE	' + @StrWhereD + '
		UNION	ALL
		SELECT	Days, 0, 0, 0, 0
		FROM #tblDays
	) T
	GROUP BY T.DocDate
	ORDER BY T.DocDate'

	------------------------------------------------------------
	-- Run -----------------------------------------------------
	PRINT @StrSelect;
	EXEC sp_executesql @StrSelect;
	------------------------------------------------------------
End
GO
