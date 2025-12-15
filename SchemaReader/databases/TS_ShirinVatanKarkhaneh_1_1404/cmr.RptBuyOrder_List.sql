USE TS_ShirinVatanKarkhaneh_1_1404
GO
SET ANSI_NULLS, QUOTED_IDENTIFIER ON
GO
-- =========== TS-QC:UPDATED ====================
-- Author        : TakroSystem\Zia
-- Create date   : 1386/10/25
-- Viewed By	 : Majid Mohammadi
-- Last Modified : 1390/09/01
-- Last Modifier : TakroSystem\Zia
-- Description   : لیست برگه های سفارش خرید
-- =============================================
Create PROCEDURE [cmr].[RptBuyOrder_List]
	@ProcessID		Int = 160, 
		-- 160 = لیست برگه های سفارش
		-- 165 = لیست برگه های انصراف از سفارش
	@ProcessNo		Int = 1,
	@FiscalYearFr	Int = Null,
	@SerialNoFr		Int = Null,
	@FiscalYearTo	Int = Null,
	@SerialNoTo		Int = Null,
	@DocDateFr		Char(10) = Null,
	@DocDateTo		Char(10) = Null,
	@SelectedAcnt1	Int = 0, 
	@SelectedAcnt2	Int = 0, 
	@SelectedAcnt3	Int = 0, 
	@SelectedAcnt4	Int = 0, 
	@IsDetailed		Bit = 0,	-- آیا گزارش تفصیلی می باشد؟
	@AgreeNoFr		varchar(20) = null,
	@AgreeNoTo		varchar(20) = null,
	@SortFields		NVarChar(100) = Null,  -- لیست فیلدها برای مرتب کردن
	@RepInfo		NVarChar(100) = '1@1@1'
WITH ENCRYPTION
AS
Declare @StrSelect	NVarChar(4000);
Declare @StrWhere	NVarChar(2000);

Declare @StrGoodsID		VarChar(100);
Declare @StrGoodsName	VarChar(100);
Declare @StrQuantity	VarChar(100);
Declare @StrGoodsUnit	VarChar(100);
Declare @StrOrderDuration VarChar(100);
DECLARE	@LangID			Char(1);
DECLARE	@SessionNo		Int; -- برای حالت کدهای انتخابی
DECLARE	@ReportID		Int; -- برای حالت کدهای انتخابی
	
Declare @IsCanceled		Bit;	-- حذف برگه‌های انصرافی

Begin --============== S T A R T  C O D E ===================================================

--	SET @LanguageID = pub.funGetCurrentLanguageID();

	Set NoCount On;

	-- I N I T ----------------------------------------------------------------
	If (@SortFields Is Null) Set @SortFields = 'FiscalYear, SerialNo'
	If (@ProcessNo  Is Null) Set @ProcessNo  = 1;
	IF (@RepInfo	Is Null) SET @RepInfo	= '1@1@1';

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
	SET @IsCanceled	= pub.funSplitString(@RepInfo, '@', 6);
	---------------------------------------------------------------------------

	-- W H E R E --------------------------------------------------------------
	Set @StrWhere = ' D.ProcessID  = ' + LTrim(Str(@ProcessID)) + ' AND D.ProcessNo = ' + LTrim(Str(@ProcessNo))

	If (@SerialNoFr Is Not Null)
		Set @StrWhere = @StrWhere + ' AND (D.FiscalYear > ' + LTrim(Str(@FiscalYearFr)) + ' OR 
		(D.FiscalYear = ' + LTrim(Str(@FiscalYearFr)) + ' AND D.SerialNo >= ' + LTrim(Str(@SerialNoFr)) + '))' 

	If (@SerialNoTo Is Not Null)
		Set @StrWhere = @StrWhere + ' AND (D.FiscalYear < ' + LTrim(Str(@FiscalYearTo)) + ' OR 
		(D.FiscalYear = ' + LTrim(Str(@FiscalYearTo)) + ' AND D.SerialNo <= ' + LTrim(Str(@SerialNoTo)) + '))' 

	IF (@DocDateFr Is Not Null) OR (@DocDateTo Is Not Null)
		IF (@DocDateFr = @DocDateTo)
			SET @StrWhere = @StrWhere + ' AND (D.DocDate  = ''' + @DocDateFr + ''')'
		Else
		Begin
			IF (@DocDateFr Is Not Null) 
				SET @StrWhere = @StrWhere + ' AND (D.DocDate >= ''' + @DocDateFr + ''')'
			IF @DocDateTo Is Not Null
				SET @StrWhere = @StrWhere + ' AND (D.DocDate <= ''' + @DocDateTo + ''')'
		End

	If (@AgreeNoFr is not null)
		SET @StrWhere = @StrWhere + ' AND (D.AgreeNo>=''' + @AgreeNoFr + ''')'
	If (@AgreeNoTo is not null)
		SET @StrWhere = @StrWhere + ' AND (D.AgreeNo<=''' + @AgreeNoTo + ''')'

	If (@SelectedAcnt1 > 0)
		SET @StrWhere = @StrWhere + ' AND ' + pub.funGetFilterString(@SessionNo, @ReportID, @SelectedAcnt1, 'D.AcntCode')
	If (@SelectedAcnt2 > 0)
		SET @StrWhere = @StrWhere + ' AND ' + pub.funGetFilterString(@SessionNo, @ReportID, @SelectedAcnt2, 'D.AcntCode')
	If (@SelectedAcnt3 > 0)
		SET @StrWhere = @StrWhere + ' AND ' + pub.funGetFilterString(@SessionNo, @ReportID, @SelectedAcnt3, 'D.AcntCode')
	If (@SelectedAcnt4 > 0)
		SET @StrWhere = @StrWhere + ' AND ' + pub.funGetFilterString(@SessionNo, @ReportID, @SelectedAcnt4, 'D.AcntCode')
	---------------------------------------------------------------------------
	
	---- S E L E C T ----------------------------------------------------------
	If (@IsDetailed = 1) 
	begin
		if @IsCanceled = 1
			Begin
					-- Detailed Report --
				Set @StrSelect = '
				Select * from 
				(
				SELECT	D.*, inv.funGetUnitName(SubUnitID, ' + @LangID + ') Unit, 
						[pub].GetCodeName (D.AcntCode, ' + @LangID + ') AcntName,
						[pub].[funGetGoodsName](GoodsID,' + LTrim(RTrim(@LangID)) + ') GoodsName,
						IsNull([inv].[FunGetGoodsBarCode] (GoodsID), '''') BarCode, tOH.SettlementDate, ISNULL(tBTD.BuyTypeName,'''') BuyTypeName,
						[inv].[funGetGoodsRemain3](NULL,NULL,NULL,NULL,NULL,D.GoodsID,'''',D.DocDate,0) As RemainGoods,(
							SELECT	IsNull(Sum(CNL.GoodsQuantity), 0)
							FROM	cmr.tblOrderDtl AS CNL
							WHERE	CNL.BaseProcessID =D.ProcessID AND CNL.BaseProcessNo=D.ProcessNo AND CNL.BaseFiscalYear=D.FiscalYear AND CNL.BaseSerialNo=D.SerialNo AND CNL.BaseDocRowNo=D.DocRowNo AND CNL.ProcessID= 165
						) AS CanceledQty
				FROM    cmr.tblOrderDtl D
				Inner Join cmr.tblOrderHdr tOH on D.SerialNo = tOH.SerialNo
				Left  Join inv.tblBuyTypeDtl tBTD on tOH.BuyTypeID = tBTD.BuyTypeID
				WHERE   ' + @StrWhere + ')TT
				Where TT.ConfirmQuantity - TT.CanceledQty > 0
				ORDER BY ' + @SortFields
			End		
		if @IsCanceled = 0 
			Begin
					-- Detailed Report --
				Set @StrSelect = '
				SELECT	D.*, inv.funGetUnitName(SubUnitID, ' + @LangID + ') Unit, 
						[pub].GetCodeName (D.AcntCode, ' + @LangID + ') AcntName,
						[pub].[funGetGoodsName](GoodsID,' + LTrim(RTrim(@LangID)) + ') GoodsName,
						IsNull([inv].[FunGetGoodsBarCode] (GoodsID), '''') BarCode, tOH.SettlementDate, ISNULL(tBTD.BuyTypeName,'''') BuyTypeName,
						[inv].[funGetGoodsRemain3](NULL,NULL,NULL,NULL,NULL,D.GoodsID,'''',D.DocDate,0) As RemainGoods, 0 AS CanceledQty
				FROM    cmr.tblOrderDtl D
				Inner Join cmr.tblOrderHdr tOH on D.SerialNo = tOH.SerialNo
				Left  Join inv.tblBuyTypeDtl tBTD on tOH.BuyTypeID = tBTD.BuyTypeID
				WHERE   ' + @StrWhere + '
				ORDER BY ' + @SortFields
			End		
	end
	Else 
	begin
		 --Summary Report --
		Set @StrSelect = '
		SELECT	FiscalYear, SerialNo, DocDate, AcntCode, [pub].GetCodeName(AcntCode, ' + @LangID + ') As AcntName,
				Case When BaseSerialNo <> 0 Then LTrim(RTrim(Cast(BaseFiscalYear As Char(30)))) + ''/'' + LTrim(RTrim(Cast(BaseSerialNo As Char(30)))) Else ''بدون مرجع'' End As BaseFiscalSerial,
				SettlementDate, ISNULL(tBTD.BuyTypeName,'''') BuyTypeName,0 As RemainGoods
		FROM    cmr.tblOrderHdr D
		Left  Join [inv].[tblBuyTypeDtl] tBTD on D.BuyTypeID = tBTD.BuyTypeID
		WHERE   ' + @StrWhere + '
		ORDER BY ' + @SortFields
	end
	---------------------------------------------------------------------------

	---- R U N ----------------------------------------------------------------
	Print @StrSelect;
	Exec sp_executesql @StrSelect;
	---------------------------------------------------------------------------
End
GO
