USE TS_ShirinVatanKarkhaneh_1_1404
GO
SET ANSI_NULLS, QUOTED_IDENTIFIER ON
GO
-- =========== TS-QC:UPDATED ====================
-- Author		 : TakroSystem\Zia
-- Create date   : 1392/04/12
-- Viewed By	 : 
-- Last Modified : 
-- Last Modifier : TakroSystem\Zia
-- Description	 : آمار دریافت روزانه
-- ===============================================
CREATE PROCEDURE [trs].[RptTrs_SMS2]
	@SelectedAcnt1	int = 0,
	@SelectedAcnt2	int = 0,
	@SelectedAcnt3	int = 0,
	@SelectedAcnt4	int = 0,
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

BEGIN --============================ S T A R T ===============================================

	SET NOCOUNT ON;

	--=== INIT =========================================================================
	IF (@RepOptions	Is Null)	SET @RepOptions = '1';
	IF (@SelectedAcnt1 Is Null)	SET @SelectedAcnt1 = 0;
	IF (@SelectedAcnt2 Is Null)	SET @SelectedAcnt2 = 0;
	IF (@SelectedAcnt3 Is Null)	SET @SelectedAcnt3 = 0;
	IF (@SelectedAcnt4 Is Null)	SET @SelectedAcnt4 = 0;

	SET @LangID		= pub.funSplitString(@RepInfo, '@', 1);
	SET @SessionNo	= pub.funSplitString(@RepInfo, '@', 2);
	SET @ReportID	= pub.funSplitString(@RepInfo, '@', 3);

	--=== WHERE =========================================================================
	SET @StrWhere = '(H.ProcessID=1) and (H.DocDate = ''' + @CurrentDate + ''')';
	
	If (@SelectedAcnt1 > 0)
		SET @StrWhere = @StrWhere + ' AND ' + pub.funGetFilterString(@SessionNo, @ReportID, @SelectedAcnt1, 'H.AcntCode')
	If (@SelectedAcnt2 > 0)
		SET @StrWhere = @StrWhere + ' AND ' + pub.funGetFilterString(@SessionNo, @ReportID, @SelectedAcnt2, 'H.AcntCode')
	If (@SelectedAcnt3 > 0)
		SET @StrWhere = @StrWhere + ' AND ' + pub.funGetFilterString(@SessionNo, @ReportID, @SelectedAcnt3, 'H.AcntCode')
	If (@SelectedAcnt4 > 0)
		SET @StrWhere = @StrWhere + ' AND ' + pub.funGetFilterString(@SessionNo, @ReportID, @SelectedAcnt4, 'H.AcntCode')

	--=== SELECT ================================================================

	SET @StrSelect = '
		select isnull(sum(case when PayTypeID= 1 then Amount else 0 end),0) AmountSum1,
			   isnull(sum(case when PayTypeID<>1 then Amount else 0 end),0) AmountSum2
		from trs.tblPayDtl D
				inner join trs.tblPayHdr H on H.ProcessID=D.ProcessID AND H.ProcessNo=D.ProcessNo and H.FiscalYear=D.FiscalYear and H.SerialNo=D.SerialNo
		where ' + @StrWhere

	Print @StrSelect;	
	Exec sp_executesql @StrSelect;
END
GO
