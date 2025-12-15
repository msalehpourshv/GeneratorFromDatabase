USE TS_ShirinVatanKarkhaneh_1_1404
GO
SET ANSI_NULLS, QUOTED_IDENTIFIER ON
GO
-- =========== TS-QC:UPDATED ====================
-- Author        : TakroSystem\Zia
-- Create date   : 1390/12/14
-- Viewed By	 : 
-- Last Modified : 
-- Last Modifier : 
-- Description   : لیست سفارشات فروش تحویل داده نشده
-- =============================================
CREATE PROCEDURE [sal].[SpSor_Docs_Remain_Warn]
	@ProcessID		Int = 180,
	@ProcessNo		Int = 1,
	@DeliveryDateFr	Char(10) = NULL,
	@DeliveryDateTo	Char(10) = NULL,
	@RepOptions		NVarChar(20) = '1', -- bit array
	@RepInfo		NVarChar(100) = '1@1@1'
WITH ENCRYPTION
AS 
DECLARE @StrSelect	NVarChar(4000);
DECLARE @StrWhere	NVarChar(2000);

DECLARE @LangID		Char(1);
DECLARE @SessionNo	VarChar(10);
DECLARE @ReportID	VarChar(10);
Begin --============== S T A R T  C O D E ===================================================

	Set NoCount On;

	-- I N I T ----------------------------------------------------------------
	IF (@RepInfo	Is Null)	SET @RepInfo    = '1@1@1';
	IF (@RepOptions	Is Null)	SET @RepOptions = '1';
	IF (@ProcessNo	   Is Null) SET @ProcessNo  = 1;

	SET	@LangID		= pub.funSplitString(@RepInfo, '@', 1);
	SET @SessionNo	= pub.funSplitString(@RepInfo, '@', 2);
	SET @ReportID	= pub.funSplitString(@RepInfo, '@', 3);
	---------------------------------------------------------------------------

	-- W H E R E --------------------------------------------------------------
	SET @StrWhere = ' (H.ProcessID=' + LTrim(Str(@ProcessID)) + ') AND (H.ProcessNo=' + LTrim(Str(@ProcessNo)) + ')'

	If (@DeliveryDateFr Is Not Null)
		SET @StrWhere = @StrWhere + ' AND (H.DeliveryDate>=''' + @DeliveryDateFr + ''')'

	If (@DeliveryDateTo Is Not Null)
		SET @StrWhere = @StrWhere + ' AND (H.DeliveryDate<=''' + @DeliveryDateTo + ''')'
	---------------------------------------------------------------------------

	-- S E L E C T ------------------------------------------------------------
	Set @StrSelect = '
	SELECT	H.FiscalYear, H.SerialNo, H.DocDate, H.AcntCode, H.DocDesc, H.OrderDate, H.DeliveryDate,
			pub.GetCodeName(H.AcntCode,1) AcntName
	FROM sal.tblSaleOrderHdr H
	WHERE ' + @StrWhere
	---------------------------------------------------------------------------

	---- R U N ----------------------------------------------------------------
	PRINT @StrSelect;
	EXEC sp_executesql @StrSelect;
	---------------------------------------------------------------------------
End
GO
