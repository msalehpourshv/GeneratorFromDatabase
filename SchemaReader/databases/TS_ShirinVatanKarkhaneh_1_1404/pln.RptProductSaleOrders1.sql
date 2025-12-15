USE TS_ShirinVatanKarkhaneh_1_1404
GO
SET ANSI_NULLS, QUOTED_IDENTIFIER ON
GO
-- =========== TS-QC:UPDATED ====================
-- Author		 : TakroSystem\Ahmadnejad
-- Create date   : 1388/10/22
-- Viewed By	 : 
-- Last Modified : 1394/12/10
-- Last Modifier : TakroSystem\ZiA
-- Description	 : 
-- ==============================================
Create PROCEDURE [pln].[RptProductSaleOrders1]
	@ProductID		VarChar(20),
	@ProduceStepID	VarChar(20),
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

DECLARE @DocStep	TinyInt
DECLARE @DeliveryDateFr		Char(10);
DECLARE @DeliveryDateTo		Char(10) ;

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
	SET @DeliveryDateFr	= pub.funSplitString(@RepInfo, '@', 6);
	SET @DeliveryDateTo	= pub.funSplitString(@RepInfo, '@', 7);

	-- ================================
	DECLARE @SalOrder_ConfirmDocStep Nvarchar(100)

	SELECT @SalOrder_ConfirmDocStep = SettingValue
	FROM pub.tblSettings
	WHERE SettingKey = 'SalOrder_ConfirmDocStep'

	IF @SalOrder_ConfirmDocStep = 'False' 
		SET @DocStep = 1
	ELSE
		SET @DocStep = 2
	
	-- ================================
	SET @StrWhere = ' (D.ProcessID =180) and (D.ConfirmQuantity <> 0)'

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

	IF (@DeliveryDateFr Is Not Null and @DeliveryDateFr<>'') 
		SET @StrWhere = @StrWhere + ' AND (D.DeliveryDate >= ''' + @DeliveryDateFr + ''')'
	IF (@DeliveryDateTo Is Not Null and @DeliveryDateTo<>'') 
		SET @StrWhere = @StrWhere + ' AND (D.DeliveryDate <= ''' + @DeliveryDateTo + ''')'

	IF (@SelectedAcnt1 > 0)
		SET @StrWhere = @StrWhere + ' AND ' + pub.funGetFilterString(@SessionNo, @ReportID, @SelectedAcnt1, 'D.AcntCode')
	IF (@SelectedAcnt2 > 0)
		SET @StrWhere = @StrWhere + ' AND ' + pub.funGetFilterString(@SessionNo, @ReportID, @SelectedAcnt2, 'D.AcntCode')
	IF (@SelectedAcnt3 > 0)
		SET @StrWhere = @StrWhere + ' AND ' + pub.funGetFilterString(@SessionNo, @ReportID, @SelectedAcnt3, 'D.AcntCode')
	IF (@SelectedAcnt4 > 0)
		SET @StrWhere = @StrWhere + ' AND ' + pub.funGetFilterString(@SessionNo, @ReportID, @SelectedAcnt4, 'D.AcntCode')

	SET @StrWhere = @StrWhere + ' AND D.DocStep >= ' + LTRIM(RTrim(Str(@DocStep)))

	-- ================================
	SET @StrSelect = '
    SELECT	D.ProcessID, D.ProcessNo, D.FiscalYear, D.SerialNo, D.RowNo, D.DocRowNo, D.DocStep, D.DocDate,D.DeliveryDate, D.AcntCode, 
			pub.GetCodeName(D.AcntCode, ' + @LangID + ') AcntName, D.GoodsID, pub.funGetGoodsName(D.GoodsID, 1) GoodsName,
			[inv].[funGetGoodsQuantityFromSubUnit](D.GoodsID,D.SubUnitID,D.ConfirmQuantity )TotalQuantity , D.CanceledQuantity,
			D.SgnSN1,D.SgnSN2,D.SgnSN3,D.SgnSN4,D.SgnSN5,
			IsNull(
				(
					-- Produce Order Qty
					SELECT	Sum(R.ProductCount)
					FROM 	pln.tblItemRelations R
								INNER JOIN pln.vwProduceOrderHD P ON P.ProcessID = R.ProcessID AND P.ProcessNo = R.ProcessNo AND P.FiscalYear = R.FiscalYear AND P.SerialNo = R.SerialNo AND P.DocRowNo = R.DocRowNo 
					WHERE  (P.ProduceStepID = ''' + LTrim(@ProduceStepID) + ''') AND D.ProcessID = R.BaseProcessID AND D.ProcessNo = R.BaseProcessNo AND D.FiscalYear = R.BaseFiscalYear AND D.SerialNo = R.BaseSerialNo AND D.DocRowNo = R.BaseDocRowNo 
				), 0) OrderedQuantity,D.ConstText1,D.ConstText2,D.ConstText3,D.ConstText4,DescDtl
    FROM	sal.vwSaleOrderDtl_WithRet D 
    WHERE	' + @StrWhere + '
    GROUP BY D.ProcessID, D.ProcessNo, D.FiscalYear, D.SerialNo, D.RowNo, D.DocRowNo, D.DocStep, D.DocDate,D.DeliveryDate, D.AcntCode, D.ConfirmQuantity, D.CanceledQuantity, D.GoodsID,D.ConstText1,D.ConstText2,D.ConstText3,D.ConstText4,D.SgnSN1,D.SgnSN2,D.SgnSN3,D.SgnSN4,D.SgnSN5 ,D.SubUnitID,DescDtl'
	SET @StrWhere_G = '(1=1)'
	SET @StrWhere_G = @StrWhere_G + ' AND (T.TotalQuantity-T.CanceledQuantity-T.OrderedQuantity )>0'

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
	SELECT T.*
	FROM 	
	(' + @StrSelect + '
	) T 
	WHERE ' + @StrWhere_G +	'	order by GoodsID'

	PRINT @StrSelect;
	EXEC sp_executesql @StrSelect;
END
GO
