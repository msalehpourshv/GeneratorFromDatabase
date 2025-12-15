USE TS_ShirinVatanKarkhaneh_1_1404
GO
SET ANSI_NULLS, QUOTED_IDENTIFIER ON
GO
-- =========== TS-QC:UPDATED ====================
-- Author		 : Ahmadnejad
-- Create date   : 1387/01/21
-- Viewed By	 : 
-- Last Modified : 1393/08/10
-- Last Modifier : TakroSystem\Hamid
-- Description	 : گزارش لیست برگه های کنترل کیفی خرید
-- ==============================================
Create PROCEDURE [inv].[RptStore_TempReceipt_List]
	@ProcessID			Int,
	@ProcessNo			Int,
	@FiscalYearFrom		Int = Null,
	@FiscalYearTo		Int = Null,
	@SerialNoFrom		Int = Null,
	@SerialNoTo			Int = Null,
	@DateFrom			Char(10) = Null,
	@DateTo				Char(10) = Null,
	@AcntCodeFrom		VarChar(20) = Null,
	@AcntCodeTo			VarChar(20) = Null,
	@Options			TinyInt = 0,
	-- 0 = All Receipts		--
	-- 1 = Not Controlled	--
	-- 2 = Controlled		--
	-- 3 = Not Confirmed	--
	-- 4 = Confirmed		--
	@SortFields			NVarChar(100) = Null,
	@ExtraParams	NVarChar(500) = ''
 WITH ENCRYPTION
AS 
---- Declarations ---------------
DECLARE @StrSelect	NVarChar(max);
DECLARE @StrWhere	NVarChar(max);

DECLARE @DescDtl	NVarChar(200);
DECLARE @SelectedGoods Int;
DECLARE	@SessionNo	Int;
DECLARE	@ReportID	Int;
DECLARE @LanguageID TinyInt;
DECLARE @LangID		VarChar(3);
Begin --============== S T A R T  C O D E ===================================================

	SET NOCOUNT ON;

	-- Init -----------------------------------
	If (@ProcessID Is Null) SET @ProcessID = 170;
	If (@ProcessNo Is Null) SET @ProcessNo = 1;

	If (@FiscalYearFrom Is Null) SET @SerialNoFrom	= Null;
	If (@FiscalYearTo	Is Null) SET @SerialNoTo	= Null;

	If (@SerialNoFrom	Is Null) SET @FiscalYearFrom= Null;
	If (@SerialNoTo		Is Null) SET @FiscalYearTo  = Null;

	If (@SortFields		Is Null) SET @SortFields	= 'SerialNo';
	
	SET @DescDtl		= LTrim(pub.funSplitString(@ExtraParams, '@', 1)); 
	SET @SessionNo		= LTrim(pub.funSplitString(@ExtraParams, '@', 2));
	SET @ReportID		= LTrim(pub.funSplitString(@ExtraParams, '@', 3));
	SET @SelectedGoods	= LTrim(pub.funSplitString(@ExtraParams, '@', 4)); 
	SELECT @LanguageID = pub.funGetCurrentLanguageID();
	SET @LangID			  = LTrim(Str(@LanguageID));
	
	-------------------------------------------

	-- Where Clause -----------------------------------------
	SET @StrWhere = ' D.ProcessID=' + LTrim(Str(@ProcessID))

	If (@FiscalYearFrom	Is Not Null)
		SET @StrWhere = @StrWhere + ' AND (D.FiscalYear > ' + LTrim(Str(@FiscalYearFrom)) + ' OR (D.FiscalYear = ' + LTrim(Str(@FiscalYearFrom)) + ' AND D.SerialNo >= ' + LTrim(Str(@SerialNoFrom)) + ')) '

	If (@FiscalYearTo Is Not Null)
		SET @StrWhere = @StrWhere + ' AND (D.FiscalYear < ' + LTrim(Str(@FiscalYearTo)) + ' OR (D.FiscalYear = ' + LTrim(Str(@FiscalYearTo)) + ' AND D.SerialNo <= ' + LTrim(Str(@SerialNoTo)) + ')) '

	If (@DateFrom Is Not Null)
		SET @StrWhere = @StrWhere + ' AND D.DocDate >= ''' + @DateFrom + ''''

	If (@DateTo Is Not Null)
		SET @StrWhere = @StrWhere + ' AND D.DocDate <= ''' + @DateTo + ''''

	If (@AcntCodeFrom Is Not Null)
		SET @StrWhere = @StrWhere + ' AND D.AcntCode >= ''' + @AcntCodeFrom + '''' 

	If (@AcntCodeTo Is Not Null)
		SET @StrWhere = @StrWhere + ' AND D.AcntCode <= ''' + @AcntCodeTo + ''''

	If @Options = 1 
		SET @StrWhere = @StrWhere + ' AND D.Recognition = 0' 

	If @Options = 2 
		SET @StrWhere = @StrWhere + ' AND D.Recognition <> 0'

	If @Options = 3 
		SET @StrWhere = @StrWhere + ' AND D.Recognition IN(4)'

	If @Options = 5 
		SET @StrWhere = @StrWhere + ' AND D.Recognition IN(2)'
		
	If @Options = 6
		SET @StrWhere = @StrWhere + ' AND D.Recognition IN(3)'				

	If @Options = 4 
		SET @StrWhere = @StrWhere + ' AND D.Recognition IN(1, 2, 3)'
		
	If (@DescDtl <> '' And @DescDtl Is Not Null)
		SET @StrWhere = @StrWhere + 'AND (D.DescDtl Like N''%' + LTrim(@DescDtl) + '%'')'

	IF (@SelectedGoods > 0)
	begin
			SET @StrWhere = @StrWhere + ' AND ' + pub.funGetFilterString(@SessionNo, @ReportID, @SelectedGoods, 'D.GoodsID') 
	end				
	---------------------------------------------------------

	-- FROM Clause ------------------------------------------
		SET @StrSelect = '
		SELECT	D.*, pub.GetCodeName(D.AcntCode,' + @LangID + ') AcntName, U.UnitName, H.DocDesc,	G.GoodsName, H.DocDate As RegDate, H.DocDate2 As ConfirmDate
		FROM    inv.tblInvTempReceiptDtl D
					inner join inv.tblInvTempReceiptHdr H ON H.ProcessID = D.ProcessID AND H.ProcessNo = D.ProcessNo AND H.FiscalYear = D.FiscalYear AND H.SerialNo = D.SerialNo
					LEFT JOIN inv.tblUnitsDtl U ON U.UnitID = D.SubUnitID
					LEFT JOIN inv.tblGoodsDtl G ON G.GoodsID = D.GoodsID
		WHERE   ' + @StrWhere + '
		ORDER BY ' + @SortFields
	---------------------------------------------------------------------------
	---- R U N ----------------------------------------------------------------
	Print @StrSelect;
	Exec sp_executesql @StrSelect;
	---------------------------------------------------------------------------
End
GO
