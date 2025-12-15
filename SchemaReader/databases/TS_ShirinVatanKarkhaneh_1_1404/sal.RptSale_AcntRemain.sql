USE TS_ShirinVatanKarkhaneh_1_1404
GO
SET ANSI_NULLS, QUOTED_IDENTIFIER ON
GO
-- =========== TS-QC:UPDATED ====================
-- Author		 : TakroSystem\Zia
-- Create date   : 1389/02/12
-- Viewed By	 : 
-- Last Modified : 1392/05/28
-- Last Modifier : TakroSystem\Zia
-- ----------------------------------------------
-- Description	 : < گزارش مانده های مشتریان ویزیتورها>
-- ==============================================
Create PROCEDURE [sal].[RptSale_AcntRemain]
	@ProcessID			VarChar(20) = '90, 95',
	@ProcessNo			int = 1,
	@SelectedAcnt1		int = 0,
	@SelectedAcnt2		int = 0,
	@SelectedAcnt3		int = 0,
	@SelectedAcnt4		int = 0,
	@SelectedVisitor1	int = 0, 
	@SelectedVisitor2	int = 0, 
	@SelectedVisitor3	int = 0, 
	@SelectedVisitor4	int = 0,
	@FiscalYearFr		int = Null,
	@SerialNoFr			int = Null,
	@FiscalYearTo		int = Null,
	@SerialNoTo			int = Null,
	@DebitRemainFr		BigInt = Null,
	@DebitRemainTo		BigInt = Null,
	@CreditRemainFr		BigInt = Null,
	@CreditRemainTo		BigInt = Null,
	@DocDateFr			Char(10) = Null,
	@DocDateTo			Char(10) = Null,
	@RemainDate			Char(10) = Null,
	@RepOptions			VarChar(10) = '111', -- bit array options
	@RepInfo			NVarChar(100) = '1@1@1' -- bit array options
WITH ENCRYPTION
AS
Declare @StrSelectVoucher	NVarChar(max);
Declare @StrWhereVisitor	NVarChar(4000);
Declare @StrSelect	NVarChar(max);
Declare @StrWhere	NVarChar(4000);
Declare @StrWhereM	NVarChar(4000);

Declare @SortByName		Bit; -- مرتب بر اساس اسامی حسابها باشد یا کد حسابها؟
Declare @UseDateFilter	Bit; 
Declare @WithVisitor	bit;
Declare @WithBase	bit;

DECLARE	@LangID			Char(1);
DECLARE	@SessionNo		Int; -- برای حالت کدهای انتخابی
DECLARE	@ReportID		Int; -- برای حالت کدهای انتخابی
DECLARE	@VisitorAcnCode	VarChar(20) ;
DECLARE	@VisitorName	VarChar(200) ;

Declare @PartNumber	int;
Declare @Start		int;
Declare @Len		int;

	 select @PartNumber=[acc].[FunGetAcntInfoForRemain](1)
	 select @Start=[acc].[FunGetAcntInfoForRemain](2) 
	 select @Len=[acc].[FunGetAcntInfoForRemain](3)
BEGIN -- ============================ S T A R T =====================================================

	set @LangID		= pub.funSplitString(@RepInfo, '@', 1);
	set @SessionNo	= pub.funSplitString(@RepInfo, '@', 2);
	set @ReportID	= pub.funSplitString(@RepInfo, '@', 3);
	set @VisitorAcnCode	= pub.funSplitString(@RepInfo, '@', 6);
	set @VisitorName	= pub.funSplitString(@RepInfo, '@', 7);
	
	SET @StrWhereVisitor = ''
	
	IF (@FiscalYearFr Is Null)		SET @SerialNoFr = Null;
	IF (@FiscalYearTo Is Null)		SET @SerialNoTo = Null;
	IF (@SerialNoFr	Is Null)		SET @FiscalYearFr = Null;
	IF (@SerialNoTo	Is Null)		SET @FiscalYearTo = Null;

	if (@SelectedAcnt1	Is Null)	set @SelectedAcnt1 = 0
	if (@SelectedAcnt2	Is Null)	set @SelectedAcnt2 = 0
	if (@SelectedAcnt3	Is Null)	set @SelectedAcnt3 = 0
	if (@SelectedAcnt4	Is Null)	set @SelectedAcnt4 = 0
	if (@SelectedVisitor1 Is Null)	set @SelectedVisitor1 = 0;
	if (@SelectedVisitor2 Is Null)	set @SelectedVisitor2 = 0;
	if (@SelectedVisitor3 Is Null)	set @SelectedVisitor3 = 0;
	if (@SelectedVisitor4 Is Null)	set @SelectedVisitor4 = 0;
	if (@RemainDate Is Null) or (@RemainDate = '')	set @RemainDate = '9999/99/99';

	SET @SortByName		= Substring(@RepOptions, 1, 1)
	SET @UseDateFilter	= Substring(@RepOptions, 2, 1)
	SET @WithVisitor	= Substring(@RepOptions, 3, 1)
	SET @WithBase	= Substring(@RepOptions, 4, 1)

	set NOCOUNT ON;

	if (@WithBase=1)
		SET @StrSelectVoucher = ' (SELECT * from acc.tblVoucherDtl WHERE     (VchKind not in (2,3))) '
	else
		SET @StrSelectVoucher = ' (SELECT * from acc.tblVoucherDtl WHERE     (VchKind not in (3)) ) '
		
	------ WHERE CLAUSE ------------------------------------------------------
	set @StrWhere = '(D.ProcessID in (90,95)) and (D.AcntCode<>'''')'
	
	if (@WithVisitor=1)
		set @StrWhere = @StrWhere + ' AND (D.VisitorAcntCode <> '''')'
	
	if (@SelectedAcnt1 > 0)
		set @StrWhere = @StrWhere + ' AND ' + pub.funGetFilterString(@SessionNo, @ReportID, @SelectedAcnt1, 'AcntCode')
	if (@SelectedAcnt2 > 0)
		set @StrWhere = @StrWhere + ' AND ' + pub.funGetFilterString(@SessionNo, @ReportID, @SelectedAcnt2, 'AcntCode')
	if (@SelectedAcnt3 > 0)
		set @StrWhere = @StrWhere + ' AND ' + pub.funGetFilterString(@SessionNo, @ReportID, @SelectedAcnt3, 'AcntCode')
	if (@SelectedAcnt4 > 0)
		set @StrWhere = @StrWhere + ' AND ' + pub.funGetFilterString(@SessionNo, @ReportID, @SelectedAcnt4, 'AcntCode')

	-- Visitor --
	if (@SelectedVisitor1 > 0)
	BEGIN
		set @StrWhere = @StrWhere + ' AND (' + pub.funGetFilterString(@SessionNo, @ReportID, @SelectedVisitor1, 'D.VisitorAcntCode') + ')'
		set @StrWhereVisitor = @StrWhereVisitor + ' AND (' + pub.funGetFilterString(@SessionNo, @ReportID, @SelectedVisitor1, 'D.VisitorAcntCode') + ')'
	END
	if (@SelectedVisitor2 > 0)
	BEGIN
		set @StrWhere = @StrWhere + ' AND (' + pub.funGetFilterString(@SessionNo, @ReportID, @SelectedVisitor2, 'D.VisitorAcntCode') + ')'
		set @StrWhereVisitor = @StrWhereVisitor + ' AND (' + pub.funGetFilterString(@SessionNo, @ReportID, @SelectedVisitor2, 'D.VisitorAcntCode') + ')'
	END
	if (@SelectedVisitor3 > 0)
	BEGIN
		set @StrWhere = @StrWhere + ' AND (' + pub.funGetFilterString(@SessionNo, @ReportID, @SelectedVisitor3, 'D.VisitorAcntCode') + ')'
		set @StrWhereVisitor = @StrWhereVisitor + ' AND (' + pub.funGetFilterString(@SessionNo, @ReportID, @SelectedVisitor3, 'D.VisitorAcntCode') + ')'
	END
	if (@SelectedVisitor4 > 0)
	BEGIN
		set @StrWhere = @StrWhere + ' AND (' + pub.funGetFilterString(@SessionNo, @ReportID, @SelectedVisitor4, 'D.VisitorAcntCode') + ')'
		set @StrWhereVisitor = @StrWhereVisitor + ' AND (' + pub.funGetFilterString(@SessionNo, @ReportID, @SelectedVisitor4, 'D.VisitorAcntCode') + ')'
	END

	set @VisitorAcnCode=isnull(@VisitorAcnCode,'')
	if @VisitorAcnCode<>''
	BEGIN
		set @StrWhere = @StrWhere + ' AND '''+ @VisitorAcnCode +''' =Substring(D.VisitorAcntCode,'+ str(@Start)+','+ str(len(@VisitorAcnCode)) +' ) '
		set @StrWhereVisitor = @StrWhereVisitor + ' AND '''+ @VisitorAcnCode +''' =Substring(D.VisitorAcntCode,'+ str(@Start)+','+ str(len(@VisitorAcnCode)) +' )'
	END

	--select @VisitorAcnCode
	IF @StrWhereVisitor <>''
		if (@WithBase=1)
	
		set @StrSelectVoucher = ' (SELECT * from acc.tblVoucherDtl  D WHERE 1=1 ' + @StrWhereVisitor + '   and (VchKind not in (2,3) ) )'
		   else
		set @StrSelectVoucher = ' (SELECT * from acc.tblVoucherDtl  D WHERE 1=1 ' + @StrWhereVisitor + '   and (VchKind not in (3) ) )'
		
	-- Date To --
	if (@DocDateFr Is Not Null)
		set @StrWhere = @StrWhere + ' AND DocDate >= ''' + @DocDateFr + ''''
	if (@DocDateTo Is Not Null)
		set @StrWhere = @StrWhere + ' AND DocDate <= ''' + @DocDateTo + ''''
	
	-- Serial To --
	If (@SerialNoFr Is Not Null)
		Set @StrWhere = @StrWhere + ' AND (D.FiscalYear > ' + LTrim(Str(@FiscalYearFr)) + ' OR (D.FiscalYear = ' + LTrim(Str(@FiscalYearFr)) + ' AND D.SerialNo >= ' + LTrim(Str(@SerialNoFr)) + '))' 
	If (@SerialNoTo Is Not Null)
		Set @StrWhere = @StrWhere + ' AND (D.FiscalYear < ' + LTrim(Str(@FiscalYearTo)) + ' OR (D.FiscalYear = ' + LTrim(Str(@FiscalYearTo)) + ' AND D.SerialNo <= ' + LTrim(Str(@SerialNoTo)) + '))' 

	declare @StrWhere2 AS NVarChar(2000)
	set @StrWhere2 = '(1=1)'

	If (@DebitRemainFr Is Not Null)
		Set @StrWhere2 = @StrWhere2 + ' AND (DebitRemain >= ' + LTrim(Str(@DebitRemainFr,20)) + ')'
	If (@DebitRemainTo Is Not Null)
		Set @StrWhere2 = @StrWhere2 + ' AND (DebitRemain <= ' + LTrim(Str(@DebitRemainTo,20)) + ')'

	If (@CreditRemainFr Is Not Null)
		Set @StrWhere2 = @StrWhere2 + ' AND (0-DebitRemain >= ' + LTrim(Str(@CreditRemainFr,20)) + ')'
	If (@CreditRemainTo Is Not Null)
		Set @StrWhere2 = @StrWhere2 + ' AND (0-DebitRemain <= ' + LTrim(Str(@CreditRemainTo,20)) + ')'
	
	--===== SELECT CLAUSE =======================================================
	set @StrWhereM = '(Debit>0)'
	
	if (@UseDateFilter = 1)
	begin
		if (@DocDateFr Is Not Null)
			set @StrWhereM = @StrWhereM + ' AND (DocDate>=''' + @DocDateFr + ''')'
		if (@DocDateTo Is Not Null)
			set @StrWhereM = @StrWhereM + ' AND (DocDate<=''' + @DocDateTo + ''')'
	end
	
	
	set @StrSelect = '
	SELECT T.*,Isnull(A.DebitCredit,0) as DebitCredit,cast( '''+@VisitorName +''' as nvarchar(100) ) VisitorName
	FROM
	(
		SELECT	D.*, pub.GetCodeName(D.AcntCode, ' + @LangID + ') AcntName,	
				IsNull((
					SELECT	Sum(Debit-Credit)
					FROM ' + @StrSelectVoucher + ' V
					WHERE	(V.VchKind <> 0) AND (V.AcntCode = D.AcntCode) and (V.DocDate <= ''' + @RemainDate + ''')
				),0) DebitRemain, 
				(SELECT Max(DocDate) FROM acc.tblVoucherDtl WHERE AcntCode=D.AcntCode AND ' + @StrWhereM + ') AS LastDebitDate,
				F.Address1 + F.Address2 as Address
		FROM
		(
			SELECT	DISTINCT D.AcntCode
			FROM	inv.tblStorageDocsDtl D
			WHERE ' + @StrWhere + '
		) D 
		OUTER APPLY acc.funGetCodeInfo(D.AcntCode) AS F 
	) T left join (SELECT     SUM(Debit - Credit) AS DebitCredit, AcntCode
FROM         acc.tblVoucherDtl
WHERE     (VchKind = 2)
GROUP BY AcntCode) A
on A.AcntCode=T.AcntCode

	WHERE ' + @StrWhere2

	if (@SortByName = 1)
	set @StrSelect = @StrSelect + '
	ORDER By AcntName '
	else
	set @StrSelect = @StrSelect + '
	ORDER By AcntCode '

	Print @StrSelect;	
	Exec sp_executesql @StrSelect;

END
GO
