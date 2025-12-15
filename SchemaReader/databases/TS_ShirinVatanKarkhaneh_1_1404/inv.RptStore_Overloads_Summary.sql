USE TS_ShirinVatanKarkhaneh_1_1404
GO
SET ANSI_NULLS, QUOTED_IDENTIFIER ON
GO
-- =========== TS-QC:UPDATED ====================
-- Author		 : Ahmadnejad
-- Create date   : 1386/04/06
-- Viewed By	 : 
-- Last Modified : 1388/04/01
-- Last Modifier : TakroSystem\Ahmadnejad
-- Description	 : گزارش سربار خرید - خلاصه 
-- ==============================================
Create PROCEDURE [inv].[RptStore_Overloads_Summary]
	@ProcessID			Int,
    -- 55 ' خريد كالا
    -- 56 ' (خريد كالا 11(باسكول
    -- 60 ' برگشت از خريد
    -- 65 ' قيمت تمام شده برگشت از خريد
	@ProcessNo			Int = Null,
	@FiscalYearFr		Int = Null,
	@SerialNoFr			Int = Null,
	@FiscalYearTo		Int = Null,
	@SerialNoTo			Int = Null,
	@DocDateFr			Char(10) = Null,
	@DocDateTo			Char(10) = Null,
	@SelectedGoods		Int = 0, 
	@SelectedAcnt1		Int = 0, 
	@SelectedAcnt2		Int = 0, 
	@SelectedAcnt3		Int = 0, 
	@SelectedAcnt4		Int = 0, 
	@RepOptions			VarChar(10) = '110', -- bit array options
	@SortFields			NVarChar(200) = Null,
	@RepInfo			NVarChar(100) = Null
WITH ENCRYPTION
AS 
---- Declarations ---------------
DECLARE @StrSelect		NVarChar(4000);
DECLARE @StrFrom		NVarChar(2000);
DECLARE @StrWhere		NVarChar(2000);
DECLARE @ShowQuantity	Bit;  -- شامل ستون مقدار
DECLARE @ShowPrice		Bit;  -- شامل ستون قیمت
DECLARE @ShowDesc		Bit;  -- شامل ستون شرح
DECLARE	@LangID			Char(1);
DECLARE	@SessionNo		Int; -- برای حالت کدهای انتخابی
DECLARE	@ReportID		Int; -- برای حالت کدهای انتخابی
Begin --============== S T A R T  C O D E ===================================================

	SET NOCOUNT ON;

	-- Init Variables --------------------------------
	IF (@ProcessNo Is Null)			SET @ProcessNo = 1;
	IF (@RepOptions Is Null)		SET @RepOptions = '110';
	IF (@RepInfo Is Null)			SET @RepInfo = '1@1@1'

	IF (@SelectedGoods Is Null)		SET @SelectedGoods = 0;
	IF (@SelectedAcnt1 Is Null)		SET @SelectedAcnt1 = 0;
	IF (@SelectedAcnt2 Is Null)		SET @SelectedAcnt2 = 0;
	IF (@SelectedAcnt3 Is Null)		SET @SelectedAcnt3 = 0;
	IF (@SelectedAcnt4 Is Null)		SET @SelectedAcnt4 = 0;

	IF (@FiscalYearFr Is Null)		SET @SerialNoFr = Null;
	IF (@FiscalYearTo Is Null)		SET @SerialNoTo = Null;
	IF (@SerialNoFr	Is Null)		SET @FiscalYearFr = Null;
	IF (@SerialNoTo	Is Null)		SET @FiscalYearTo = Null;

	SET @LangID		= pub.funSplitString(@RepInfo, '@', 1);
	SET @SessionNo	= pub.funSplitString(@RepInfo, '@', 2);
	SET @ReportID	= pub.funSplitString(@RepInfo, '@', 3);

	SET @ShowQuantity	= Substring(@RepOptions, 1, 1);
	SET @ShowPrice		= Substring(@RepOptions, 2, 1);
	-- -----------------------------------------------
	-- Where Clause -----------------------------------------------------------
	Set @StrWhere = ' O.ProcessID = ' + LTrim(Str(@ProcessID))

	If @ProcessNo Is Not Null
		Set @StrWhere = @StrWhere + ' AND O.ProcessNo = ' + LTrim(Str(@ProcessNo))

	IF (@SerialNoFr Is Not Null)
		SET @StrWhere = @StrWhere + ' AND (O.FiscalYear > ' + LTrim(Str(@FiscalYearFr)) + ' OR 
		(O.FiscalYear = ' + LTrim(Str(@FiscalYearFr)) + ' AND O.SerialNo >= ' + LTrim(Str(@SerialNoFr)) + '))' 
	IF (@SerialNoTo Is Not Null)
		SET @StrWhere = @StrWhere + ' AND (O.FiscalYear < ' + LTrim(Str(@FiscalYearTo)) + ' OR 
		(O.FiscalYear = ' + LTrim(Str(@FiscalYearTo)) + ' AND O.SerialNo <= ' + LTrim(Str(@SerialNoTo)) + '))' 

	IF (@DocDateFr Is Not Null) OR (@DocDateTo Is Not Null)
		IF (@DocDateFr = @DocDateTo)
			SET @StrWhere = @StrWhere + ' AND (H.VchDate  = ''' + @DocDateFr + ''')'
		Else 
		Begin
			IF (@DocDateFr Is Not Null)
				SET @StrWhere = @StrWhere + ' AND (H.VchDate >= ''' + @DocDateFr + ''')'
			IF @DocDateTo Is Not Null
				SET @StrWhere = @StrWhere + ' AND (H.VchDate <= ''' + @DocDateTo + ''')'
		End

	IF (@SelectedGoods > 0)
		SET @StrWhere = @StrWhere + ' AND ' + pub.funGetFilterString(@SessionNo, @ReportID, @SelectedGoods, 'D.GoodsID') 

	IF (@SelectedAcnt1 > 0)
		SET @StrWhere = @StrWhere + ' AND ' + pub.funGetFilterString(@SessionNo, @ReportID, @SelectedAcnt1, 'O.AtomAcntCode')
	IF (@SelectedAcnt2 > 0)
		SET @StrWhere = @StrWhere + ' AND ' + pub.funGetFilterString(@SessionNo, @ReportID, @SelectedAcnt2, 'O.AtomAcntCode')
	IF (@SelectedAcnt3 > 0)
		SET @StrWhere = @StrWhere + ' AND ' + pub.funGetFilterString(@SessionNo, @ReportID, @SelectedAcnt3, 'O.AtomAcntCode')
	IF (@SelectedAcnt4 > 0)
		SET @StrWhere = @StrWhere + ' AND ' + pub.funGetFilterString(@SessionNo, @ReportID, @SelectedAcnt4, 'O.AtomAcntCode')
	------------------------------------------------------------
	-- Select Clause -------------------------------------------
	Set @StrSelect = '
	SELECT a.GoodsID,
		   SUM(Price*Quantity)/SUM(Quantity) Price,
		   SUM(Quantity) Quantity,
		   GoodsName 
	FROM (
		SELECT	D.GoodsID,
				Sum(O.AtomAmount) Price,
				Sum(D.GoodsQuantity) Quantity,
				pub.GetGoodsName(D.GoodsID, ' + @LangID +') GoodsName
		FROM	inv.tblStorageDocsAtom O 
				INNER JOIN inv.tblStorageDocsDtl D ON O.ProcessID = D.ProcessID AND O.ProcessNo = D.ProcessNo AND O.FiscalYear = D.FiscalYear AND O.SerialNo = D.SerialNo AND O.DocRowNo = D.DocRowNo
				INNER JOIN inv.tblStorageDocsHdr H ON H.ProcessID = D.ProcessID AND H.ProcessNo = D.ProcessNo AND H.FiscalYear = D.FiscalYear AND H.SerialNo = D.SerialNo
		WHERE	' + @StrWhere + '
		GROUP BY D.GoodsID, D.GoodsQuantity, D.SerialNo, O.AtomAcntCode
	) a
	group by GoodsID,GoodsName'
	------------------------------------------------------------
	If @SortFields Is Not Null 
	Set @StrSelect = @StrSelect + '
	ORDER BY ' + @SortFields
	-- Run -----------------------------------------------------
	print @StrSelect;
	Exec sp_executesql @StrSelect;
	------------------------------------------------------------
End
GO
