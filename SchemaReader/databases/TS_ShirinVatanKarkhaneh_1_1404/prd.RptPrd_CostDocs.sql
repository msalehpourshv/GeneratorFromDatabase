USE TS_ShirinVatanKarkhaneh_1_1404
GO
SET ANSI_NULLS, QUOTED_IDENTIFIER ON
GO
-- =========== TS-QC:UPDATED ====================
-- Author		 : TakroSystem\Zia
-- Create date   : 1391/06/25
-- Viewed By	 : 
-- Last Modified : 
-- Last Modifier : TakroSystem\Zia
-- Description	 : 
-- ==============================================
Create PROCEDURE [prd].[RptPrd_CostDocs]
	@ProcessID		Int = 77,
	@SerialFr		Int = Null,
	@SerialTo		Int = Null,
	@BSerialFr		Int = Null,
	@BSerialTo		Int = Null,
	@SelectedAcnt1	Int = Null,
	@SelectedAcnt2	Int = Null,
	@SelectedAcnt3	Int = Null,
	@SelectedAcnt4	Int = Null,
	@SelectedProduct	Int = Null, 
	@DocDateFr		char(10) = Null,
	@DocDateTo		char(10) = Null,
	@BatchNoFr		varchar(20) = Null,
	@BatchNoTo		varchar(20) = Null,
	@RepOptions		VarChar(10) = '1',  -- bit array options
	@SortFields		NVarChar(100) = Null,
	@RepInfo		NVarChar(100) = '1@1@1'
WITH ENCRYPTION
AS 
---- Declarations ---------------
DECLARE	@StrSelect		NVarChar(4000);
DECLARE	@StrFrom		NVarChar(4000);
DECLARE	@StrWhere		NVarChar(4000);

DECLARE	@LangID			Char(1);
DECLARE	@SessionNo		Int; 
DECLARE	@ReportID		Int; 
BEGIN --============== S T A R T  C O D E ===================================================

DECLARE	@ProcessNo		Int; 
DECLARE	@FiscalYear		Int; 
	SET NOCOUNT ON;

	-- Init -------------------------------------------------------------------
	IF (@RepInfo	Is Null)	SET @RepInfo = '1@1@1'
	IF (@RepOptions	Is Null)	SET @RepOptions = '1'

	IF (@SelectedProduct Is Null)	SET @SelectedProduct = 0
	IF (@SelectedAcnt1	Is Null)	SET @SelectedAcnt1 = 0
	IF (@SelectedAcnt2	Is Null)	SET @SelectedAcnt2 = 0
	IF (@SelectedAcnt3	Is Null)	SET @SelectedAcnt3 = 0
	IF (@SelectedAcnt4	Is Null)	SET @SelectedAcnt4 = 0

	SET @LangID		= pub.funSplitString(@RepInfo, '@', 1);
	SET @SessionNo	= pub.funSplitString(@RepInfo, '@', 2);
	SET @ReportID	= pub.funSplitString(@RepInfo, '@', 3);
	
	set @ProcessNo	= pub.funSplitString(@RepInfo, '@', 6);
	set @FiscalYear	= pub.funSplitString(@RepInfo, '@', 7);

	set @BatchNoFr= isnull(@BatchNoFr,0)
	if @BatchNoFr=''
		set @BatchNoFr=0
	---------------------------------------------------------------------------
	-- Where Clause -----------------------------------------------------------
	Set @StrWhere = ' (D.ProcessID = ' + LTrim(STR(@ProcessID)) + ')'
	if (@ProcessNo is not null)
		set @StrWhere = @StrWhere + ' and (D.ProcessNo = ' + LTrim(Str(@ProcessNo)) + ')'
	if (@FiscalYear is not null)
		set @StrWhere = @StrWhere + ' and (D.FiscalYear = ' + LTrim(Str(@FiscalYear)) + ')'	
	IF (@SerialFr Is Not Null)
		SET @StrWhere = @StrWhere + ' AND (D.SerialNo>=' + LTrim(Str(@SerialFr)) + ')' 
	IF (@SerialTo Is Not Null)
		SET @StrWhere = @StrWhere + ' AND (D.SerialNo<=' + LTrim(Str(@SerialTo)) + ')' 

	IF (@BSerialFr Is Not Null)
		SET @StrWhere = @StrWhere + ' AND (H.BaseSerialNo >= ' + LTrim(Str(@BSerialFr)) + ')' 
	IF (@BSerialTo Is Not Null)
		SET @StrWhere = @StrWhere + ' AND (H.BaseSerialNo <= ' + LTrim(Str(@BSerialTo)) + ')' 

	IF (@DocDateFr Is Not Null)
		SET @StrWhere = @StrWhere + ' AND (D.DocDate>=''' + @DocDateFr + ''')'
	IF @DocDateTo Is Not Null
		SET @StrWhere = @StrWhere + ' AND (D.DocDate<=''' + @DocDateTo + ''')'

	IF (@SelectedProduct > 0)
		SET @StrWhere = @StrWhere + ' AND ' + pub.funGetFilterString(@SessionNo, @ReportID, @SelectedProduct, 'H.ProductID') 
	IF (@BatchNoFr <> 0)
		SET @StrWhere = @StrWhere + ' AND ' + pub.funGetFilterString(@SessionNo, @ReportID, @BatchNoFr, 'H.BatchNo') 

	IF (@SelectedAcnt1 > 0)
		SET @StrWhere = @StrWhere + ' AND ' + pub.funGetFilterString(@SessionNo, @ReportID, @SelectedAcnt1, 'D.AcntCode')
	IF (@SelectedAcnt2 > 0)
		SET @StrWhere = @StrWhere + ' AND ' + pub.funGetFilterString(@SessionNo, @ReportID, @SelectedAcnt2, 'D.AcntCode')
	IF (@SelectedAcnt3 > 0)
		SET @StrWhere = @StrWhere + ' AND ' + pub.funGetFilterString(@SessionNo, @ReportID, @SelectedAcnt3, 'D.AcntCode')
	IF (@SelectedAcnt4 > 0)
		SET @StrWhere = @StrWhere + ' AND ' + pub.funGetFilterString(@SessionNo, @ReportID, @SelectedAcnt4, 'D.AcntCode')
	------------------------------------------------------------
	-- Select Clause -------------------------------------------
	SET @StrSelect = '
	SELECT H.*, D.DocRowNo, D.Quantity, D.Amount, [pub].[funGetGoodsName](H.ProductID, ' + LTrim(RTrim(@LangID)) + ') As ProductName,
		   pub.GetCodeName(D.AcntCode, 1) AcntName
	FROM prd.tblProductCostsDtl D
	INNER JOIN prd.tblProductCostsHdr H ON H.ProcessID = D.ProcessID AND H.ProcessNo = D.ProcessNo AND H.FiscalYear = D.FiscalYear AND H.SerialNo = D.SerialNo
	WHERE ' + @StrWhere
	------------------------------------------------------------
	-- Sort Clause ---------------------------------------------
	IF (@SortFields Is Not Null)
	SET @StrSelect = @StrSelect + ' 
	ORDER BY ' + @SortFields
	------------------------------------------------------------
	-- Run -----------------------------------------------------
	print @StrSelect;
	Exec sp_executesql @StrSelect;
	------------------------------------------------------------
END
GO
