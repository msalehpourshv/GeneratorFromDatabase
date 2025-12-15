USE TS_ShirinVatanKarkhaneh_1_1404
GO
SET ANSI_NULLS, QUOTED_IDENTIFIER ON
GO
-- =========== TS-QC:UPDATED ====================
-- Author		 : TakroSystem\Mostafavi
-- Create date   : 1402/12/12
-- Viewed By	 : 
-- Last Modified : 
-- Last Modifier : 
-- Description	 : Main Doc Journal Report 
-- =======================================
Create PROCEDURE [acc].[RptAcc_JournalAll]
	@DateFr			Char(10) = Null,
	@DateTo			Char(10) = Null,
	@SerialNoFr		Int = Null,
	@SerialNoTo		Int = Null,
	@RepOptions		varchar(100) = '1',
	@RepInfo		NVarChar(100) = '1@1@1'
WITH ENCRYPTION
AS

DECLARE @StrQuery	NVarChar(Max);
DECLARE @StrSelect	NVarChar(Max);
DECLARE @StrFrom	NVarChar(1000);
DECLARE @StrWhere	NVarChar(1000);

DECLARE @StrSerialNo	NVarChar(150);
DECLARE @StrDocDate		NVarChar(150);

DECLARE	@LangID		Char(1);
DECLARE	@SessionNo	Int; 
DECLARE	@ReportID	Int;
	
BEGIN 
	------------------------------------------------------------------------------------------------------------------------------------------------------
	SET NOCOUNT ON;

	IF @RepInfo Is Null SET @RepInfo = '1@1@1';

	SET @LangID		= pub.funSplitString(@RepInfo, '@', 1);
	SET @SessionNo	= pub.funSplitString(@RepInfo, '@', 2);
	SET @ReportID	= pub.funSplitString(@RepInfo, '@', 3);

	------------------------------------------------------------------------------------------------------------------------------------------------------
	Set @StrQuery = ''
	------------------------------------------------------------------------------------------------------------------------------------------------------
	/* Set Select Clause */
	Set @StrSelect = '
		SELECT	VD.SerialNo, VD.DocDate, VD.AcntCode, VD.Debit, VD.Credit,
				pub.GetCodeName(VD.AcntCode,' + @LangID + ') AcntName, VH.FromSerialNo, VH.ToSerialNo,
				acc.funGetAcntFullName(VD.AcntCode) AcntFullName,VD.DocDesc,VD.DocDesc2,VD.VchKind,VD.MonthCode'
	-- ========== Set From Clause ===========
	Set @StrFrom = '
		From acc.tblVoucherAllDtl VD
				Inner Join acc.tblVoucherAllHdr VH ON VD.SerialNo = VH.SerialNo '
	-- =======================================
	-- ========== Set Where Clause ===========
	Set @StrWhere = '(VD.VchKind <> 0)'
	If (@DateFr <> '') 
		Set @StrWhere = @StrWhere + ' And (VD.MonthCode >= ''' + @DateFr + ''')'
	If (@DateTo <> '') 
		Set @StrWhere = @StrWhere + ' And (VD.MonthCode <= ''' + @DateTo + ''')'
	If (@SerialNoFr <> '') 
		Set @StrWhere = @StrWhere + ' AND (VD.SerialNo >= ' + LTrim(Str(@SerialNoFr)) + ')'
	If (@SerialNoTo <> '') 
		Set @StrWhere = @StrWhere + ' AND (VD.SerialNo <= ' + LTrim(Str(@SerialNoTo)) + ')'
	
	Set @StrQuery = @StrSelect + RTrim(LTrim(@StrFrom)) + '
		WHERE ' + LTrim(RTrim(@StrWhere))
		
	-- =======================================
	-- =========== Group By Clause ===========	

	/* --------------------------- */
	/* --- Set Order By Clause --- */
	Set @StrQuery = @StrQuery + ' ORDER BY VD.RowNo'		
	Print @StrQuery;    
	Exec sp_executesql @StrQuery;
	
END
GO
