USE TS_ShirinVatanKarkhaneh_1_1404
GO
SET ANSI_NULLS, QUOTED_IDENTIFIER ON
GO
-- =========== TS-QC:UPDATED ====================
-- Author		 : TakroSystem\Ahmadnejad
-- Create date   : 1388/10/27
-- Viewed By	 : 
-- Last Modified : 1394/12/10
-- Last Modifier : TakroSystem\ZiA
-- Description	 : 
-- ==============================================
Create PROCEDURE [pln].[RptProductPreSale2]
	@ProductID		VarChar(20),
	@ProduceStepID	VarChar(20),
	@BaseProcessID	Int,
	@BaseProcessNo	Int,
	@BaseFiscalYear	Int,
	@BaseSerialNo	Int,
	@FiscalYearFr	Int = Null,
	@SerialNoFr		Int = Null,
	@FiscalYearTo	Int = Null,
	@SerialNoTo		Int = Null,
	@SelectedAcnt1	Int = 0,
	@SelectedAcnt2	Int = 0,
	@SelectedAcnt3	Int = 0,
	@SelectedAcnt4	Int = 0,
	@DocDateFr		Char(10) = Null,
	@DocDateTo		Char(10) = Null,
	@AmountSorFr	Float = Null,
	@AmountSorTo	Float = Null,
	@AmountPrdFr	Float = Null,
	@AmountPrdTo	Float = Null,
	@AmountRemFr	Float = Null,
	@AmountRemTo	Float = Null,
	@RepOptions		VarChar(10) = '',  -- bit array options
	@RepInfo		NVarChar(100) = '1@1@1'
WITH ENCRYPTION
AS
DECLARE @StrSelect	NVarChar(4000)
DECLARE @StrWhere	NVarChar(4000)
DECLARE @StrFrom	NVarChar(4000)
DECLARE @StrJoin	NVarChar(4000)
DECLARE @StrWhere_G	NVarChar(4000)

DECLARE	@LangID		Char(1);
DECLARE	@SessionNo	Int; 
DECLARE	@ReportID	Int; 
Begin

	SET NOCOUNT ON;

	-- Init -------------------------------------------------------------------
	IF (@RepInfo		Is Null)	SET @RepInfo = '1@1@1';
	IF (@SelectedAcnt1	Is Null)	SET @SelectedAcnt1 = 0;
	IF (@SelectedAcnt2	Is Null)	SET @SelectedAcnt2 = 0;
	IF (@SelectedAcnt3	Is Null)	SET @SelectedAcnt3 = 0;
	IF (@SelectedAcnt4	Is Null)	SET @SelectedAcnt4 = 0;

	IF (@FiscalYearFr Is Null)	SET @SerialNoFr = Null;
	IF (@FiscalYearTo Is Null)	SET @SerialNoTo = Null;
	IF (@SerialNoFr	Is Null)	SET @FiscalYearFr = Null;
	IF (@SerialNoTo	Is Null)	SET @FiscalYearTo = Null;

	SET @LangID		= pub.funSplitString(@RepInfo, '@', 1);
	SET @SessionNo	= pub.funSplitString(@RepInfo, '@', 2);
	SET @ReportID	= pub.funSplitString(@RepInfo, '@', 3);

	SET @StrWhere = '(P.ProcessID = ' + LTrim(Str(@BaseProcessID)) + ') AND (P.ProcessNo = ' + LTrim(Str(@BaseProcessNo)) + ') AND (P.FiscalYear = ' + LTrim(Str(@BaseFiscalYear)) + ') AND (P.SerialNo = ' + LTrim(Str(@BaseSerialNo)) + ')'

	if (@ProductID <> '')
		SET @StrWhere = @StrWhere + ' and (D.GoodsID = ''' + @ProductID + ''') '

	IF (@SerialNoFr Is Not Null)
		SET @StrWhere = @StrWhere + ' AND (D.FiscalYear > ' + LTrim(Str(@FiscalYearFr)) + ' OR
		(D.FiscalYear = ' + LTrim(Str(@FiscalYearFr)) + ' AND D.SerialNo >= ' + LTrim(Str(@SerialNoFr)) + '))' 
	IF (@SerialNoTo Is Not Null)
		SET @StrWhere = @StrWhere + ' AND (D.FiscalYear < ' + LTrim(Str(@FiscalYearTo)) + ' OR
		(D.FiscalYear = ' + LTrim(Str(@FiscalYearTo)) + ' AND D.SerialNo <= ' + LTrim(Str(@SerialNoTo)) + '))' 

	IF (@DocDateFr Is Not Null) 
		SET @StrWhere = @StrWhere + ' AND (D.DocDate >= ''' + @DocDateFr + ''')'
	IF (@DocDateTo Is Not Null) 
		SET @StrWhere = @StrWhere + ' AND (D.DocDate <= ''' + @DocDateTo + ''')'

	IF (@SelectedAcnt1 > 0)
		SET @StrWhere = @StrWhere + ' AND ' + pub.funGetFilterString(@SessionNo, @ReportID, @SelectedAcnt1, 'D.AcntCode')
	IF (@SelectedAcnt2 > 0)
		SET @StrWhere = @StrWhere + ' AND ' + pub.funGetFilterString(@SessionNo, @ReportID, @SelectedAcnt2, 'D.AcntCode')
	IF (@SelectedAcnt3 > 0)
		SET @StrWhere = @StrWhere + ' AND ' + pub.funGetFilterString(@SessionNo, @ReportID, @SelectedAcnt3, 'D.AcntCode')
	IF (@SelectedAcnt4 > 0)
		SET @StrWhere = @StrWhere + ' AND ' + pub.funGetFilterString(@SessionNo, @ReportID, @SelectedAcnt4, 'D.AcntCode')

	SET @StrSelect = '
    SELECT	D.ProcessID, D.ProcessNo, D.FiscalYear, D.SerialNo, D.RowNo, D.DocRowNo, D.DocDate, D.AcntCode, D.GoodsID,
			pub.GetCodeName(D.AcntCode, ' + @LangID + ') AcntName, Sum(R.ProductCount) TotalQuantity, 0 AS CanceledQuantity ,D.ConstText1,D.ConstText2,D.ConstText3,D.ConstText4
    FROM	pln.tblItemRelations R 
				INNER JOIN sal.vwSaleOrderDtl_WithRet D ON D.ProcessID = R.BaseProcessID AND D.ProcessNo = R.BaseProcessNo AND D.FiscalYear = R.BaseFiscalYear AND D.SerialNo = R.BaseSerialNo AND D.DocRowNo = R.BaseDocRowNo 
				INNER JOIN pln.tblProduceOrderDtl P ON P.ProcessID = R.ProcessID     AND P.ProcessNo = R.ProcessNo     AND P.FiscalYear = R.FiscalYear     AND P.SerialNo = R.SerialNo     AND P.DocRowNo = R.DocRowNo 
    WHERE	' + @StrWhere + '
	GROUP BY D.ProcessID, D.ProcessNo, D.FiscalYear, D.SerialNo, D.RowNo, D.DocRowNo, D.DocDate, D.AcntCode, D.GoodsID, D.ConstText1,D.ConstText2,D.ConstText3,D.ConstText4 '

	SET @StrWhere_G = '(1=1)'

	IF (@AmountSorFr Is Not Null)
		SET @StrWhere_G = @StrWhere_G + ' AND (T.TotalQuantity >= ' + LTrim(Str(@AmountSorFr)) + ')'
	IF (@AmountSorTo Is Not Null)
		SET @StrWhere_G = @StrWhere_G + ' AND (T.TotalQuantity <= ' + LTrim(Str(@AmountSorTo)) + ')'

	IF (@AmountPrdFr Is Not Null)
		SET @StrWhere_G = @StrWhere_G + ' AND (T.OrderedQuantity >= ' + LTrim(Str(@AmountPrdFr)) + ')'
	IF (@AmountPrdTo Is Not Null)
		SET @StrWhere_G = @StrWhere_G + ' AND (T.OrderedQuantity <= ' + LTrim(Str(@AmountPrdTo)) + ')'

	IF (@AmountRemFr Is Not Null)
		SET @StrWhere_G = @StrWhere_G + ' AND (T.TotalQuantity - T.OrderedQuantity >= ' + LTrim(Str(@AmountRemFr)) + ')'
	IF (@AmountRemTo Is Not Null)
		SET @StrWhere_G = @StrWhere_G + ' AND (T.TotalQuantity - T.OrderedQuantity <= ' + LTrim(Str(@AmountRemTo)) + ')'

	SET @StrSelect = '
	SELECT  ProcessID, ProcessNo, FiscalYear, SerialNo, RowNo, DocRowNo, DocDate, AcntCode, AcntName, TotalQuantity, CanceledQuantity,
			(
				SELECT	IsNull(Sum(M.ProductCount), 0)
				FROM	pln.vwProduceOrderHD M
				WHERE	M.BaseProcessID = ' + LTrim(Str(@BaseProcessID)) + ' AND 
						M.BaseProcessNo = ' + LTrim(Str(@BaseProcessNo)) + ' AND 
						M.BaseFiscalYear = ' + LTrim(Str(@BaseFiscalYear)) + ' AND 
						M.BaseSerialNo = ' + LTrim(Str(@BaseSerialNo)) + ' AND
						M.ProductID = T.GoodsID
			) OrderedQuantity, T.GoodsID, pub.funGetGoodsName(T.GoodsID, 1) GoodsName,ConstText1,ConstText2,ConstText3,ConstText4
	FROM 	
	(' + @StrSelect + '
	) T 
	WHERE ' + @StrWhere_G + '
	GROUP BY ProcessID, ProcessNo, FiscalYear, SerialNo, RowNo, DocRowNo, DocDate, AcntCode, AcntName, T.GoodsID, TotalQuantity, CanceledQuantity,ConstText1,ConstText2,ConstText3,ConstText4 '

	PRINT @StrSelect;
	EXEC sp_executesql @StrSelect;
End
GO
