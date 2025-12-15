USE TS_ShirinVatanKarkhaneh_1_1404
GO
SET ANSI_NULLS, QUOTED_IDENTIFIER ON
GO
-- =========== TS-QC:UPDATED ====================
-- Author		 : TakroSystem\Zia
-- Creation Date : 1391/01/21
-- Viewed By	 : 
-- Last Modified : 1391/01/21
-- Last Modifier : TakroSystem\Zia
-- Description	 : گزارش لیست برگه های امانی
-- ==============================================
CREATE PROCEDURE [inv].[RptStore_TrustList]
	@ProcessID_Snd	Int = 130,
	@ProcessID_Rcv	Int = 135,
	@FiscalYearFr	Int = Null,
	@SerialNoFr		Int = Null,
	@FiscalYearTo	Int = Null,
	@SerialNoTo		Int = Null,
	@DocDateFr		Char(10) = Null,
	@DocDateTo		Char(10) = Null,
	@SelectedGoods	Int = 0,
	@SelectedStore	Int = 0,
	@SelectedAcnt1	Int = 0,
	@SelectedAcnt2	Int = 0,
	@SelectedAcnt3	Int = 0,
	@SelectedAcnt4	Int = 0,
	@RepOptions		VarChar(30) = '0', -- bit array options
	@RepInfo		NVarChar(100) = Null,
	@SortFields		NVarChar(100) = Null
WITH ENCRYPTION
AS 
---- Declarations ---------------
DECLARE @StrSelect	NVarChar(max);
DECLARE @StrFrom	NVarChar(max);
DECLARE @StrWhere	NVarChar(max);
DECLARE @PIDSnd		VarChar(3);
DECLARE @PIDRcv		VarChar(3);

DECLARE	@LangID		Char(1);
DECLARE	@SessionNo	Int; -- برای حالت کدهای انتخابی
DECLARE	@ReportID	Int; -- برای حالت کدهای انتخابی
declare @ZQ			bit;
Begin --============== S T A R T  C O D E ===================================================

	SET NOCOUNT ON;

	-- Init -------------------------------------------------
	IF (@RepOptions Is Null)		SET @RepOptions = '0';
	IF (@RepInfo Is Null)			SET @RepInfo = '1@1@1';

	IF (@SelectedGoods Is Null)		SET @SelectedGoods = 0;
	IF (@SelectedStore Is Null)		SET @SelectedStore = 0;
	IF (@SelectedAcnt1 Is Null)		SET @SelectedAcnt1 = 0;
	IF (@SelectedAcnt2 Is Null)		SET @SelectedAcnt2 = 0;
	IF (@SelectedAcnt3 Is Null)		SET @SelectedAcnt3 = 0;
	IF (@SelectedAcnt4 Is Null)		SET @SelectedAcnt4 = 0;

	If (@FiscalYearFr Is Null)	SET @SerialNoFr = Null;
	If (@FiscalYearTo Is Null)	SET @SerialNoTo = Null;
	If (@SerialNoFr	Is Null)	SET @FiscalYearFr = Null;
	If (@SerialNoTo	Is Null)	SET @FiscalYearTo = Null;

	SET @LangID		= pub.funSplitString(@RepInfo, '@', 1);
	SET @SessionNo	= pub.funSplitString(@RepInfo, '@', 2);
	SET @ReportID	= pub.funSplitString(@RepInfo, '@', 3);

	SET @PIDSnd = @ProcessID_Snd;
	SET @PIDRcv = @ProcessID_Rcv;
	SET @ZQ		= Substring(@RepOptions, 1, 1)
	---------------------------------------------------------
	-- Where Clause -----------------------------------------
	Set @StrWhere = ' D.ProcessID in (' + @PIDSnd + ')'

	If (@SerialNoFr Is Not Null)
		Set @StrWhere = @StrWhere + ' AND (D.FiscalYear > ' + LTrim(Str(@FiscalYearFr)) + ' OR (D.FiscalYear = ' + LTrim(Str(@FiscalYearFr)) + ' AND D.SerialNo >= ' + LTrim(Str(@SerialNoFr)) + '))' 
	If (@SerialNoTo Is Not Null)
		Set @StrWhere = @StrWhere + ' AND (D.FiscalYear < ' + LTrim(Str(@FiscalYearTo)) + ' OR (D.FiscalYear = ' + LTrim(Str(@FiscalYearTo)) + ' AND D.SerialNo <= ' + LTrim(Str(@SerialNoTo)) + '))' 

	IF (@DocDateFr Is Not Null) 
		SET @StrWhere = @StrWhere + ' AND (D.DocDate >= ''' + @DocDateFr + ''')'
	IF @DocDateTo Is Not Null
		SET @StrWhere = @StrWhere + ' AND (D.DocDate <= ''' + @DocDateTo + ''')'
	
	If (@SelectedGoods > 0)
		SET @StrWhere = @StrWhere + ' AND ' + pub.funGetFilterString(@SessionNo, @ReportID, @SelectedGoods, 'D.GoodsID') 
	If (@SelectedStore > 0)
		SET @StrWhere = @StrWhere + ' AND ' + pub.funGetFilterString(@SessionNo, @ReportID, @SelectedStore, 'D.StoreID') 

	If (@SelectedAcnt1 > 0)
		SET @StrWhere = @StrWhere + ' AND ' + pub.funGetFilterString(@SessionNo, @ReportID, @SelectedAcnt1, 'D.AcntCode')
	If (@SelectedAcnt2 > 0)
		SET @StrWhere = @StrWhere + ' AND ' + pub.funGetFilterString(@SessionNo, @ReportID, @SelectedAcnt2, 'D.AcntCode')
	If (@SelectedAcnt3 > 0)
		SET @StrWhere = @StrWhere + ' AND ' + pub.funGetFilterString(@SessionNo, @ReportID, @SelectedAcnt3, 'D.AcntCode')
	If (@SelectedAcnt4 > 0)
		SET @StrWhere = @StrWhere + ' AND ' + pub.funGetFilterString(@SessionNo, @ReportID, @SelectedAcnt4, 'D.AcntCode')
	---------------------------------------------------------

	-- SELECT Clause ----------------------------------------
	SET @StrSelect = '
	SELECT	D.ProcessID, D.ProcessNo, D.FiscalYear, D.SerialNo, D.DocDate, D.DocRowNo, 
			D.AcntCode, pub.GetCodeName(D.AcntCode, ' + @LangID + ') AS AcntName,H.DocDesc,D.DescDtl,
			D.GoodsQuantity as QuantitySnd, D.GoodsID, G.GoodsName,
			isnull(
			(
				SELECT	IsNull(SUM(GoodsQuantity), 0)
				FROM	inv.tblStorageDocsDtl DD
				WHERE	DD.ProcessID = ' + @PIDRcv + ' AND 
						DD.BaseProcessID = D.ProcessID AND 
						DD.BaseProcessNo = D.ProcessNo AND 
						DD.BaseFiscalYear = D.FiscalYear AND 
						DD.BaseSerialNo = D.SerialNo AND 
						DD.GoodsID = D.GoodsID AND 
						DD.BaseDocRowNo = D.DocRowNo
			), 0) QuantityRcv
	FROM  inv.tblStorageDocsDtl D 
	INNER JOIN inv.tblStorageDocsHdr H
	ON H.ProcessID=D.ProcessID and H.ProcessNo=D.ProcessNo and H.FiscalYear=D.FiscalYear and H.SerialNo=D.SerialNo 
			left join inv.tblGoodsDtl G on G.GoodsID = D.GoodsID
	WHERE ' + @StrWhere
	------------------------------------------------------------
	if (@ZQ <> 1) 
		SET @StrSelect = ' select * from (' + @StrSelect +') T where (QuantitySnd-QuantityRcv > 0)'
		
	-- SORT Clause ---------------------------------------------
	If (@SortFields Is Not Null)
		Set @StrSelect = @StrSelect + '
	 ORDER BY ' + @SortFields
	------------------------------------------------------------

	-- RUN -----------------------------------------------------
	Print @StrSelect;
	Exec sp_executesql @StrSelect;
	------------------------------------------------------------
End
GO
