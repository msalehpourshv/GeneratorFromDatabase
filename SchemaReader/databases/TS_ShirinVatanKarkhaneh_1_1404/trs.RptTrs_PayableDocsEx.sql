USE TS_ShirinVatanKarkhaneh_1_1404
GO
SET ANSI_NULLS, QUOTED_IDENTIFIER ON
GO
-- =========== TS-QC:UPDATED ====================
-- Author		 : TakroSystem\Zia
-- Create date   : 1391/01/26
-- Viewed By	 : 
-- Last Modified : 1392/01/07
-- Last Modifier : TakroSystem\Zia
-- Description	 : اختلاف اسناد انبار با حسابداری
-- ==============================================
CREATE PROCEDURE [trs].[RptTrs_PayableDocsEx]
	@ProcessNo		int = 1,
	@FiscalYearFr	Int = Null,
	@SerialNoFr		Int = Null,
	@FiscalYearTo	Int = Null,
	@SerialNoTo		Int = Null,
	@DocDateFr		Char(10) = Null,
	@DocDateTo		Char(10) = Null,
	@UsanceDateFr	Char(10) = Null, -- تاریخ سررسید از
	@UsanceDateTo	Char(10) = Null, --تاریخ سررسید تا
	@DebitCode1		Int = 0,
	@DebitCode2		Int = 0,
	@DebitCode3		Int = 0,
	@DebitCode4		Int = 0,
	@SelectedBank	Int = 0,
	@AmountFr		float = -1,
	@AmountTo		float = -1,
	@SortFields		NVarChar(100) = Null,
	@RepOptions		NVarChar(20) = '1', -- bit array
	@RepInfo		NVarChar(100) = '1@1@1'
WITH ENCRYPTION
AS 
---- Declarations ---------------
DECLARE @StrSelect	NVarChar(max);
DECLARE @StrFrom	NVarChar(max);
DECLARE @StrWhere	NVarChar(max);
DECLARE @StrGroup	NVarChar(max);

DECLARE @BankCode	VarChar(20);
DECLARE @BankName	VarChar(50);

DECLARE @StrListNames	NVarChar(max);
DECLARE @StrListCodes	NVarChar(max);
DECLARE @StrListSums	NVarChar(max);
DECLARE @list_type		char(1);

DECLARE	@LangID		Char(1);
DECLARE	@SessionNo	Int; -- برای حالت کدهای انتخابی
DECLARE	@ReportID	Int; -- برای حالت کدهای انتخابی
Begin --============== S T A R T  C O D E ===================================================

	SET NOCOUNT ON;

	-- Init Variables ----------------------------------------------------------
	IF (@SelectedBank Is Null)	SET @SelectedBank = 0;
	IF (@RepOptions	 Is Null)	SET @RepOptions = '1111';

	IF (@FiscalYearFr Is Null)	SET @SerialNoFr	= Null;
	IF (@FiscalYearTo Is Null)	SET @SerialNoTo	= Null;
	IF (@SerialNoFr	Is Null)	SET @FiscalYearFr = Null;
	IF (@SerialNoTo	Is Null)	SET @FiscalYearTo = Null;

	IF (@DebitCode1 Is Null)	SET @DebitCode1 = 0;
	IF (@DebitCode2 Is Null)	SET @DebitCode2 = 0;
	IF (@DebitCode3 Is Null)	SET @DebitCode3 = 0;
	IF (@DebitCode4 Is Null)	SET @DebitCode4 = 0;

	SET @list_type	= Substring(@RepOptions, 1, 1)

	SET @LangID		= pub.funSplitString(@RepInfo, '@', 1);
	SET @SessionNo	= pub.funSplitString(@RepInfo, '@', 2);
	SET @ReportID	= pub.funSplitString(@RepInfo, '@', 3);

	----------------------------------------------------------------------------
	-- Where Clause ------------------------------------------------------------
	SET @StrWhere = '(D.PayTypeID in (8,28)) 
		and (D.ProcessNo = ' + LTRIM(STR(@ProcessNo)) + ')
		and (D.ProcessID in (2,25))';

	IF (@FiscalYearFr Is Not Null)
		SET @StrWhere = @StrWhere + ' AND (D.FiscalYear>' + LTrim(Str(@FiscalYearFr)) + ' OR (D.FiscalYear=' + LTrim(Str(@FiscalYearFr)) + ' AND D.SerialNo>=' + LTrim(Str(@SerialNoFr)) + '))'

	IF (@FiscalYearTo Is Not Null)
		SET @StrWhere = @StrWhere + ' AND (D.FiscalYear<' + LTrim(Str(@FiscalYearTo)) + ' OR (D.FiscalYear=' + LTrim(Str(@FiscalYearTo)) + ' AND D.SerialNo<=' + LTrim(Str(@SerialNoTo)) + '))'

	IF	(@DebitCode1 > 0)
		SET @StrWhere = @StrWhere + ' AND ' + pub.funGetFilterString(@SessionNo, @ReportID, @DebitCode1, 'D.DebitCode') 
	IF	(@DebitCode2 > 0)
		SET @StrWhere = @StrWhere + ' AND ' + pub.funGetFilterString(@SessionNo, @ReportID, @DebitCode2, 'D.DebitCode') 
	IF	(@DebitCode3 > 0)
		SET @StrWhere = @StrWhere + ' AND ' + pub.funGetFilterString(@SessionNo, @ReportID, @DebitCode3, 'D.DebitCode') 
	IF	(@DebitCode4 > 0)
		SET @StrWhere = @StrWhere + ' AND ' + pub.funGetFilterString(@SessionNo, @ReportID, @DebitCode4, 'D.DebitCode') 

	If (@DocDateFr Is Not Null)
		SET @StrWhere = @StrWhere + ' AND (D.DocDate>=''' + @DocDateFr + ''')'
	If (@DocDateTo Is Not Null)
		SET @StrWhere = @StrWhere + ' AND (D.DocDate<=''' + @DocDateTo + ''')'

	IF (@UsanceDateFr Is Not Null)
		SET @StrWhere = @StrWhere + ' AND (D.ChequeDate>=''' + @UsanceDateFr + ''')'
	IF (@UsanceDateTo Is Not Null)
		SET @StrWhere = @StrWhere + ' AND (D.ChequeDate<=''' + @UsanceDateTo + ''')'

	IF (@AmountFr Is Not Null) and (@AmountFr <> -1)
		SET @StrWhere = @StrWhere + ' AND D.Amount>=' + LTrim(@AmountFr)
	IF (@AmountTo Is Not Null) and (@AmountTo <> -1)
		SET @StrWhere = @StrWhere + ' AND D.Amount<=' + LTrim(@AmountTo)

	If (@SelectedBank > 0)
		SET @StrWhere = @StrWhere + ' AND ' + pub.funGetFilterString(@SessionNo, @ReportID, @SelectedBank, 'D.CreditCode') 
	----------------------------------------------------------------------------------
	create table #tbl_Trs_PayableDocsEx_All
	(
		BankCode	varchar(20) collate arabic_cs_as,
		ChequeDate	char(10),
		Amount		float
	);
	
	set @StrListCodes = '';
	set @StrListNames = '';
	set @StrListSums = '';
	
	set @StrSelect = '
	insert into #tbl_Trs_PayableDocsEx_All
	select CreditCode, ChequeDate, Amount
	from trs.tblPayDtl D
			INNER JOIN 
			(
				select DI.VolumeFiscalYear, DI.VolumeRowNo, Max(DI.EventNo) EventNo 
				from trs.tblPayDtl DI
				where (DI.ProcessNo=' + LTRIM(STR(@ProcessNo)) + ') and (DI.PayTypeID in (8,28))
				group by DI.VolumeFiscalYear, DI.VolumeRowNo
			) MX ON D.VolumeFiscalYear = MX.VolumeFiscalYear AND D.VolumeRowNo = MX.VolumeRowNo AND D.EventNo = MX.EventNo
	where ' + @StrWhere

	print @StrSelect;
	exec sp_executesql @StrSelect;
	
	DECLARE csr_Trs_PayableDocsEx CURSOR FOR 
		select distinct A.BankCode, B.BankName
		from #tbl_Trs_PayableDocsEx_All A
			left join trs.tblOurBanksDtl B on B.BankCode = A.BankCode
		order by BankCode desc

	OPEN csr_Trs_PayableDocsEx
	FETCH NEXT FROM csr_Trs_PayableDocsEx INTO @BankCode, @BankName
	
	WHILE (@@Fetch_Status = 0)
	BEGIN
		IF (@StrListNames <> '') SET @StrListNames = @StrListNames + ',';
		IF (@StrListCodes <> '') SET @StrListCodes = @StrListCodes + ',';
		IF (@StrListSums <> '') SET @StrListSums = @StrListSums + '+';

		if (@list_type = '1')
			SET @StrListNames = @StrListNames + '[' + LTrim(@BankCode) + '] as [(' + LTrim(@BankCode) + ') ' + LTrim(@BankName) + ']'
		else 
			SET @StrListNames = @StrListNames + '[' + LTrim(@BankCode) + ']'
		
		SET @StrListCodes = @StrListCodes + '[' + LTrim(@BankCode) + ']'
		SET @StrListSums = @StrListSums + 'isnull([' + LTrim(@BankCode) + '],0)'
		
		FETCH NEXT FROM csr_Trs_PayableDocsEx INTO @BankCode, @BankName
	END

	CLOSE		csr_Trs_PayableDocsEx
	DEALLOCATE	csr_Trs_PayableDocsEx

	if (@StrListCodes = '')
		set @StrListCodes = '[''بدون اطلاعات'']'
	if (@StrListNames = '')
		set @StrListNames = '[''بدون اطلاعات'']'
	if (@StrListSums = '')
		set @StrListSums = '0'
	
	SET @StrSelect = '
	SELECT ' + @StrListNames + ', ' + @StrListSums + ' as [جمع], ChequeDate as [تاریخ سررسید]
	FROM 
	(
		SELECT D.BankCode, D.ChequeDate, sum(D.Amount) Amount
		FROM #tbl_Trs_PayableDocsEx_All D
		GROUP BY D.BankCode, D.ChequeDate
	) P	PIVOT 
		(
			Sum(P.Amount)
			FOR P.BankCode In (' + @StrListCodes + ')
		) AS PVT '	
	
	print @StrSelect;
	exec sp_executesql @StrSelect;
	------------------------------------------------------------
End
GO
