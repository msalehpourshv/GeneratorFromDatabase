USE TS_ShirinVatanKarkhaneh_1_1404
GO
SET ANSI_NULLS, QUOTED_IDENTIFIER ON
GO
-- =========== TS-QC:UPDATED ====================
-- Author		 : TakroSystem\Ahmadnejad
-- Create date   : 1389/03/26
-- Viewed By	 : 
-- Last Modified : 
-- Last Modifier : 
-- Description	 : Monthly balance sheet 
-- =======================================
CREATE PROCEDURE [acc].[RptAccounts_Year_Statistics2]
	@LayerLen		Int, -- طول لایه ای که به آن طول باید اطلاعات برگردانده شود
	@DateFr			Char(10) = Null,
	@DateTo			Char(10) = Null,
	@SerialNoFr		Int = Null,
	@SerialNoTo		Int = Null,
	@RepInfo		NVarChar(100) = '1@1@1'
WITH ENCRYPTION
AS
DECLARE @StrQuery	NVarChar(4000);
DECLARE @StrSelect	NVarChar(2000);
DECLARE @StrFrom	NVarChar(1000);
DECLARE @StrWhere	NVarChar(1000);

DECLARE @StrAcntCode	NVarChar(200);
DECLARE @StrMonthCode   NVarChar(200);
DECLARE @StrDCOrder		NVarChar(200);

DECLARE	@LangID			Char(1);
DECLARE	@SessionNo		Int; 
DECLARE	@ReportID		Int;
BEGIN 
	------------------------------------------------------------------------
	SET NOCOUNT ON;

	IF @RepInfo Is Null SET @RepInfo = '1@1@1';

	SET @LangID		= pub.funSplitString(@RepInfo, '@', 1);
	SET @SessionNo	= pub.funSplitString(@RepInfo, '@', 2);
	SET @ReportID	= pub.funSplitString(@RepInfo, '@', 3);

	------------------------------------------------------------------------

	/* --- Set Where Clause --- */
	Set @StrWhere = ' (VD.VchKind <> 0) '

	If (@DateFr Is Not Null)
		Set @StrWhere = @StrWhere + ' AND (VD.DocDate >= ''' + @DateFr + ''')'

	If (@DateTo Is Not Null)
		Set @StrWhere = @StrWhere + ' AND (VD.DocDate <= ''' + @DateTo + ''')'

	If (@SerialNoFr Is Not Null)
		Set @StrWhere = @StrWhere + ' AND (VD.SerialNo >= ' + LTrim(Str(@SerialNoFr)) + ')'
	
	If (@SerialNoTo Is Not Null)
		Set @StrWhere = @StrWhere + ' AND (VD.SerialNo <= ' + LTrim(Str(@SerialNoTo)) + ')'
	/* ----------------------- */
	/* Set Select Clause */
	set @StrDCOrder = '(case when VD.Credit = 0 then 0 else 1 end)'
	set @StrAcntCode = 'Substring(VD.AcntCode, 1, ' + LTrim(Str(@LayerLen)) +')'
	set @StrMonthCode = 'Substring(VD.DocDate, 6, 2)'

	Set @StrQuery = '
	select t.*, pub.GetCodeName(t.AcntCode, ' + @LangID + ') as AcntName,
			pub.funGetTypeText(10, cast(t.MonthCode as int), 1) as MonthName
	from
	(
		select	' + @StrMonthCode + ' as MonthCode, 
				' + @StrAcntCode + ' as AcntCode,
				' + @StrDCOrder + ' as DC_Order,
				Sum(VD.Debit) as Debit, 
				Sum(VD.Credit) as Credit
		from	acc.tblVoucherDtl AS VD
		where ' + @StrWhere + '
		group by (Case When VD.Credit = 0 Then 0 Else 1 End), ' + @StrMonthCode + ', ' + @StrAcntCode + ' 
	) t
	order by t.MonthCode, t.DC_Order, t.AcntCode ' 
	/* --------------------------- */

	Print @StrQuery;    
	Exec sp_executesql @StrQuery;
END
GO
