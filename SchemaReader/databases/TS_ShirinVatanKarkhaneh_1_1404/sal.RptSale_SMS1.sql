USE TS_ShirinVatanKarkhaneh_1_1404
GO
SET ANSI_NULLS, QUOTED_IDENTIFIER ON
GO
-- =========== TS-QC:UPDATED ====================
-- Author		 : TakroSystem\Zia
-- Create date   : 1391/09/12
-- Viewed By	 : 
-- Last Modified : 
-- Last Modifier : TakroSystem\Zia
-- Description	 : آمار فروش برای ارسال
-- ===============================================
CREATE PROCEDURE [sal].[RptSale_SMS1]
	@SelectedAcnt1	int = 0,
	@SelectedAcnt2	int = 0,
	@SelectedAcnt3	int = 0,
	@SelectedAcnt4	int = 0,
	@SelectedGoods	int = 0,
	@CurrentDate	char(10) = '',
	@RepOptions		VarChar(20) = '1',
	@RepInfo		NVarChar(100) = '1@1@1'
WITH ENCRYPTION
AS
DECLARE @StrSelect	NVarChar(4000);
DECLARE @StrWhere	NVarChar(2000);

DECLARE	@LangID		Char(1);
DECLARE	@SessionNo	Int; 
DECLARE	@ReportID	Int;

DECLARE	@GoodsOnly	bit;
BEGIN --============================ S T A R T ===============================================

	SET NOCOUNT ON;

	--=== INIT =========================================================================
	IF (@RepOptions	Is Null)	SET @RepOptions = '1';
	IF (@SelectedAcnt1 Is Null)	SET @SelectedAcnt1 = 0;
	IF (@SelectedAcnt2 Is Null)	SET @SelectedAcnt2 = 0;
	IF (@SelectedAcnt3 Is Null)	SET @SelectedAcnt3 = 0;
	IF (@SelectedAcnt4 Is Null)	SET @SelectedAcnt4 = 0;
	IF (@SelectedGoods Is Null)	SET @SelectedGoods = 0;

	SET @LangID		= pub.funSplitString(@RepInfo, '@', 1);
	SET @SessionNo	= pub.funSplitString(@RepInfo, '@', 2);
	SET @ReportID	= pub.funSplitString(@RepInfo, '@', 3);

	SET @GoodsOnly	= Substring(@RepOptions, 1, 1);

	--=== WHERE =========================================================================
	SET @StrWhere = '(H.ProcessID=90) and (H.DocDate = ''' + @CurrentDate + ''')';
	
	if (@GoodsOnly = 1) and (@SelectedGoods > 0)
		SET @StrWhere = @StrWhere + ' AND ' + pub.funGetFilterString(@SessionNo, @ReportID, @SelectedGoods, 'D.GoodsID') 

	If (@SelectedAcnt1 > 0)
		SET @StrWhere = @StrWhere + ' AND ' + pub.funGetFilterString(@SessionNo, @ReportID, @SelectedAcnt1, 'H.AcntCode')
	If (@SelectedAcnt2 > 0)
		SET @StrWhere = @StrWhere + ' AND ' + pub.funGetFilterString(@SessionNo, @ReportID, @SelectedAcnt2, 'H.AcntCode')
	If (@SelectedAcnt3 > 0)
		SET @StrWhere = @StrWhere + ' AND ' + pub.funGetFilterString(@SessionNo, @ReportID, @SelectedAcnt3, 'H.AcntCode')
	If (@SelectedAcnt4 > 0)
		SET @StrWhere = @StrWhere + ' AND ' + pub.funGetFilterString(@SessionNo, @ReportID, @SelectedAcnt4, 'H.AcntCode')

	--=== SELECT ================================================================

	if (@GoodsOnly = 1)
		SET @StrSelect = '
		select isnull(sum(GoodsQuantity*GoodsPrice),0) TotalPrice
		from inv.tblStorageDocsDtl D
				inner join inv.tblStorageDocsHdr H on H.ProcessID = D.ProcessID AND H.ProcessNo = D.ProcessNo and H.FiscalYear = D.FiscalYear and H.SerialNo = D.SerialNo
		where ' + @StrWhere
	else
		SET @StrSelect = '
		select isnull(SUM(PriceSum),0) TotalPrice
		from
		(
			select  H.SidePriceSum +
				(
					select sum(D.GoodsQuantity*D.GoodsPrice) 
					from inv.tblStorageDocsDtl D 
					where H.ProcessID = D.ProcessID AND H.ProcessNo = D.ProcessNo and H.FiscalYear = D.FiscalYear and H.SerialNo = D.SerialNo
				) PriceSum 
			from [inv].[vwStorageDocsHdr] H 
			where ' + @StrWhere + '
		) M '

	Print @StrSelect;	
	Exec sp_executesql @StrSelect;
END
GO
