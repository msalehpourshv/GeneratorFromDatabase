USE TS_ShirinVatanKarkhaneh_1_1404
GO
SET ANSI_NULLS, QUOTED_IDENTIFIER ON
GO
-- =========== TS-QC:UPDATED ====================
-- Author		 : TakroSystem  \ Nogrehpasand
-- Create date   : 1393/10/11
-- Viewed By	 : 
-- Last Modified : 
-- Last Modifier : 
-- Description	 :    
-- =============================================
CREATE PROCEDURE [inv].[RptStore_Trans_Doc_Numeric2]

	@ProcessNo		Int = Null,
	@FiscalYearFr	Int = Null,
	@SerialNoFr		Int = Null,
	@FiscalYearTo	Int = Null,
	@SerialNoTo		Int = Null,
	@RepOptions		VarChar(10) = '10',
	@RepInfo		NVarChar(100) = '1@1@1',
	@ExtraParams	NVarChar(200) = '@0@@@-1@-1'

WITH ENCRYPTION
AS

DECLARE @StrSelect		NVarChar(4000);
DECLARE @StrWhere		NVarChar(2000);

DECLARE	@LangID			Char(1);
DECLARE	@SessionNo		Int; -- برای حالت کدهای انتخابی
DECLARE	@ReportID		Int; -- برای حالت کدهای انتخابی 

BEGIN 
	-- ============================ S T A R T =====================================================

	-- Init --------------------------
	SET NOCOUNT ON;

	IF (@ProcessNo  Is Null)	SET @ProcessNo = 1;
	IF (@RepOptions Is Null)	SET @RepOptions = '10';
	IF (@ExtraParams Is Null)	SET @ExtraParams = '@0@@@-1@-1';

	SET @LangID		= pub.funSplitString(@RepInfo, '@', 1);
	SET @SessionNo	= pub.funSplitString(@RepInfo, '@', 2);
	SET @ReportID	= pub.funSplitString(@RepInfo, '@', 3);	
	
	IF (@FiscalYearFr Is Null)		SET @SerialNoFr = Null;
	IF (@FiscalYearTo Is Null)		SET @SerialNoTo = Null;
	IF (@SerialNoFr	Is Null)		SET @FiscalYearFr = Null;
	IF (@SerialNoTo	Is Null)		SET @FiscalYearTo = Null;
		
-- ================ WHERE ===========================
	SET @StrWhere = 'D.ProcessID = 120 And D.ProcessNo = ' + LTrim(Str(@ProcessNo))
	
	IF (@SerialNoFr Is Not Null)
		SET @StrWhere = @StrWhere + ' AND (D.FiscalYear > ' + LTrim(Str(@FiscalYearFr)) + ' OR 
		(D.FiscalYear = ' + LTrim(Str(@FiscalYearFr)) + ' AND D.SerialNo >= ' + LTrim(Str(@SerialNoFr)) + '))' 
	IF (@SerialNoTo Is Not Null)
		SET @StrWhere = @StrWhere + ' AND (D.FiscalYear < ' + LTrim(Str(@FiscalYearTo)) + ' OR 
		(D.FiscalYear = ' + LTrim(Str(@FiscalYearTo)) + ' AND D.SerialNo <= ' + LTrim(Str(@SerialNoTo)) + '))' 
	
-- ================ SELECT ===========================

	SET @StrSelect ='
		Select D.FiscalYear, D.SerialNo, D.GoodsID, GD.GoodsName, Sum(D.GoodsQuantity) As GoodsQuantity, 
			   G.UnitID, UD.UnitName, Count(*) As RCount
		From inv.tblStorageDocsHdr H
		Inner Join inv.tblStorageDocsDtl D
				   ON H.ProcessID = D.ProcessID And H.ProcessNo = D.ProcessNo And H.FiscalYear = D.FiscalYear And H.SerialNo = D.SerialNo
		Inner Join inv.tblGoods G ON D.GoodsID = G.GoodsID
		Inner Join inv.tblGoodsDtl GD ON D.GoodsID = GD.GoodsID
		Inner Join inv.tblUnitsDtl UD ON G.UnitID = UD.UnitID
		Where ' + @StrWhere + ' 
		Group By D.FiscalYear, D.SerialNo, D.GoodsID, GD.GoodsName, G.UnitID, UD.UnitName'
	
-- ================ SELECT ===========================
	-- Exeute --------------------------
	PRINT @StrSelect;
	EXEC sp_executesql @StrSelect;

END
GO
