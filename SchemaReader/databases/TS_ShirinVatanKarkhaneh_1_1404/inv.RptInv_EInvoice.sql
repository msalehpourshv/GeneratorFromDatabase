USE TS_ShirinVatanKarkhaneh_1_1404
GO
SET ANSI_NULLS, QUOTED_IDENTIFIER ON
GO
-- =========== TS-QC:UPDATED ====================
-- Author		 : Takrosystem\Ahmadnejad
-- Create date   : 1388/07/26
-- Viewed By	 : 
-- Last Modified : 
-- Last Modifier : Takrosystem\Ahmadnejad
-- Description	 : فاکتور الکترونیکی
-- =============================================
CREATE PROCEDURE [inv].[RptInv_EInvoice]
	@ProcessID		Int = 90,
	@ProcessNo		Int = 1,
	@FiscalYearFr	Int = Null,
	@SerialNoFr		Int = Null,
	@FiscalYearTo	Int = Null,
	@SerialNoTo		Int = Null,
	@DocDateFr		Char(10) = Null, 
	@DocDateTo		Char(10) = Null,
	@RepInfo		NVarChar(100) = '1@1@1'
WITH ENCRYPTION
AS
DECLARE @StrSelect	NVarChar(4000);
DECLARE @StrFrom	NVarChar(1000);
DECLARE @StrWhere	NVarChar(2000);
DECLARE	@LangID		Char(1);
DECLARE	@SessionNo	Int;
DECLARE	@ReportID	Int;
Begin

	-- init ----------------------------------------
	IF (@RepInfo Is Null)		SET @RepInfo = '1@1@1';

	IF (@FiscalYearFr Is Null)	SET @SerialNoFr = Null;
	IF (@FiscalYearTo Is Null)	SET @SerialNoTo = Null;
	IF (@SerialNoFr	Is Null)	SET @FiscalYearFr = Null;
	IF (@SerialNoTo	Is Null)	SET @FiscalYearTo = Null;

	SET @LangID		= pub.funSplitString(@RepInfo, '@', 1);
	SET @SessionNo	= pub.funSplitString(@RepInfo, '@', 2);
	SET @ReportID	= pub.funSplitString(@RepInfo, '@', 3);
	------------------------------------------------
	-- where ---------------------------------------
	SET @StrWhere = ' (D.ProcessID = ' + LTrim(Str(@ProcessID)) + ')'

	IF (@ProcessNo Is Not Null)
		SET @StrWhere = @StrWhere + ' AND (D.ProcessNo = ' + LTrim(Str(@ProcessNo)) + ')'

	IF (@SerialNoFr Is Not Null)
		SET @StrWhere = @StrWhere + ' AND (D.FiscalYear > ' + LTrim(Str(@FiscalYearFr)) + ' OR 
		(D.FiscalYear = ' + LTrim(Str(@FiscalYearFr)) + ' AND D.SerialNo >= ' + LTrim(Str(@SerialNoFr)) + '))' 
	IF (@SerialNoTo Is Not Null)
		SET @StrWhere = @StrWhere + ' AND (D.FiscalYear < ' + LTrim(Str(@FiscalYearTo)) + ' OR 
		(D.FiscalYear = ' + LTrim(Str(@FiscalYearTo)) + ' AND D.SerialNo <= ' + LTrim(Str(@SerialNoTo)) + '))' 

	IF (@DocDateFr Is Not Null)
		SET @StrWhere = @StrWhere + ' AND (D.DocDate >= ''' + @DocDateFr + ''')'
	IF @DocDateTo Is Not Null
		SET @StrWhere = @StrWhere + ' AND (D.DocDate <= ''' + @DocDateTo + ''')'
	------------------------------------------------------------
	-- select --------------------------------------------------
	SET @StrSelect = '
	SELECT	H.ProcessID, H.ProcessNo, H.FiscalYear, H.SerialNo, H.DocDate, H.AcntCode, H.Price + H.SidePriceSum As SumPrice,
			D.GoodsID, D.SubUnitID, D.SubUnitQuantity, D.GoodsQuantity, D.GoodsPrice, D.DocRowNo, 
			IsNull(F.DistributionPoint, ''0000000000'') DistributionPoint, IsNull(F.AsnafID, ''0000000000'') AsnafID, IsNull(F.ZipCode, ''0'') ZipCode
	FROM	inv.tblStorageDocsDtl D
				INNER JOIN inv.vwStorageDocsHdr H ON D.ProcessID = H.ProcessID AND D.ProcessNo = H.ProcessNo AND D.FiscalYear = H.FiscalYear AND D.SerialNo = H.SerialNo
				OUTER APPLY acc.funGetCodeInfo(H.AcntCode) AS F
	WHERE	' + @StrWhere + '
	ORDER BY H.FiscalYear, H.SerialNo, D.DocRowNo ' 
	------------------------------------------------------------
	-- Run -----------------------------------------------------
	print @StrSelect;
	Exec sp_executesql @StrSelect;
	------------------------------------------------------------
End
GO
