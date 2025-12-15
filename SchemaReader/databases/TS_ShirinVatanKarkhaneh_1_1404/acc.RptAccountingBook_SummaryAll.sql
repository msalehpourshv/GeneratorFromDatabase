USE TS_ShirinVatanKarkhaneh_1_1404
GO
SET ANSI_NULLS, QUOTED_IDENTIFIER ON
GO
-- =========== TS-QC:UPDATED ====================
-- Author        : Jafari
-- Create date   : 1402/12/13
-- Viewed By	 : 
-- Last Modified :  
-- Last Modifier :  
-- Description	 : < دفتر حسابداری خلاصه کل >
-- =============================================
Create PROCEDURE acc.RptAccountingBook_SummaryAll
	@PartNumber		TinyInt = 1,
	@LayerLen		TinyInt = 1,  -- on this part
	@AcntCode1Fr	VarChar(20) = Null,
	@AcntCode1To	VarChar(20) = Null,
	@MonthCodeFr		VarChar(10) = Null,
	@MonthCodeTo		VarChar(10) = Null,
	@SerialNoFr		Int = Null,
	@SerialNoTo		Int = Null,
	@UserID			Int = 0, 
	@RepOptions		VarChar(30) = '000010101000000011101',  -- bit array options
	@RepInfo		NVarChar(100) = '1@1@1'
WITH ENCRYPTION
AS
DECLARE	@LangID			Char(1);
DECLARE	@SessionNo		Int; 
DECLARE	@ReportID		Int;

DECLARE	@IncludePrimary		Bit; -- شامل سند افتتاحیه باشد؟
DECLARE	@IncludeFinish		Bit; -- شامل سند اختتامیه باشد؟
DECLARE	@IncludeClosed		Bit; -- شامل سند بستن حساب باشد؟
DECLARE	@UserIsAdmin		Bit; -- کاربر اعلام شده مدیر است یا نه؟

DECLARE @StrSelect		NVarChar(4000);
DECLARE @StrWhere		NVarChar(4000);

DECLARE @Group1			NVarChar(500);
DECLARE @MonthNameFR	NVarChar(100);
DECLARE @MonthNameTO	NVarChar(100);

BEGIN

	SET NOCOUNT ON;

	--------------------------------------------------------------------
	-- init --------------------------------------------------
	IF (@RepInfo Is Null)		SET @RepInfo = '1@1@1'
	IF (@RepOptions Is Null)	SET @RepOptions = '1110'

	SET @IncludePrimary	= Substring(@RepOptions, 1, 1)
	SET @IncludeFinish	= Substring(@RepOptions, 2, 1)
	SET @IncludeClosed	= Substring(@RepOptions, 3, 1)
	SET @UserIsAdmin	= Substring(@RepOptions, 4, 1)

	SET @LangID		= pub.funSplitString(@RepInfo, '@', 1);
	SET @SessionNo	= pub.funSplitString(@RepInfo, '@', 2);
	SET @ReportID	= pub.funSplitString(@RepInfo, '@', 3);
	
	SET @MonthNameFR	= pub.funSplitString(@RepInfo, '@', 6);
	SET @MonthNameTO	= pub.funSplitString(@RepInfo, '@', 7);

	-- Voucher Kind <> 'Note'
	SET @StrWhere = ' (D.VchKind > 0) '
	
	-- Filter Starting Doc Rows
	If (@IncludePrimary = 0)
		SET @StrWhere = @StrWhere + ' AND (D.VchKind <> 2) '

	-- Filter Finish Doc Rows
	If (@IncludeFinish = 0)
		SET @StrWhere = @StrWhere + ' AND (D.VchKind <> 3) '

	-- Filter Closing Doc Rows
	If (@IncludeClosed = 0)
		SET @StrWhere = @StrWhere  + ' AND (D.VchKind <> 4) '

	If (@AcntCode1Fr Is Not Null)
		SET @StrWhere = @StrWhere + ' AND Substring(AcntCode, 1, ' + LTrim(Str(Len(@AcntCode1Fr))) + ') >= ''' + @AcntCode1Fr + ''''

	If (@AcntCode1To Is Not Null)
		SET @StrWhere = @StrWhere + ' AND Substring(AcntCode, 1, ' + LTrim(Str(Len(@AcntCode1To))) + ') <= ''' + @AcntCode1To + ''''
	
	If (@UserIsAdmin <> 1)
	begin
		Set @StrWhere = @StrWhere + '
			AND acc.funPermitted2(' + LTRim(Str(@UserID)) + ', Substring(AcntCode, 1, ' + LTrim(Str(@LayerLen)) + '), 1)= 1 '
	end;
 
	If (@MonthCodeFr Is Not Null)
		SET @StrWhere = @StrWhere + ' AND (D.MonthCode >= ''' + @MonthCodeFr + ''')'
	If (@MonthCodeTo Is Not Null)
		SET @StrWhere = @StrWhere + ' AND (D.MonthCode <= ''' + @MonthCodeTo + ''')'

	If (@SerialNoFr Is Not Null)
		SET @StrWhere = @StrWhere + ' AND (D.SerialNo >= ' + LTrim(Str(@SerialNoFr)) + ')'
	If (@SerialNoTo Is Not Null)
		SET @StrWhere = @StrWhere + ' AND (D.SerialNo <= ' + LTrim(Str(@SerialNoTo)) + ')'

		SET @Group1 = 'Cast(Substring(AcntCode, 1, ' + LTrim(Str(@LayerLen)) + ') AS VarChar(20))'

	create table #tbl_AccountingBookSummary2_Result
	(
		MonthCode		char(10) collate arabic_cs_as not null,
		VchKind	int null,
		SerialNo int,
		DocDate	char(10),
		DocDesc	nvarchar(4000) null,
		Group1		varchar(20) collate arabic_cs_as null,
		Debit		float,
		Credit		float,
		MainDebit	float,
		MainCredit	float
	);

	-- Main section 
	SET @StrSelect = '
		INSERT INTO #tbl_AccountingBookSummary2_Result(MonthCode,VchKind,SerialNo,DocDate, DocDesc, Group1, Debit, Credit,MainDebit, MainCredit)	

		SELECT	D.MonthCode,VchKind,D.SerialNo,DocDate	, DocDesc,
				Group1, Sum(Debit) Debit, Sum(Credit) Credit,Sum(MainDebit) MainDebit, Sum(MainCredit) MainCredit
		FROM	
		(
			select D.MonthCode, D.VchKind,D.SerialNo,D.DocDate	,D.DocDesc, ' + @Group1 + ' As Group1, Debit, Credit,Debit MainDebit, Credit MainCredit
			from acc.tblVoucherAllDtl D INNER JOIN acc.tblVoucherAllHdr H on D.SerialNo=H.SerialNo 
			where   ' + @StrWhere + '
		) D
		GROUP BY MonthCode, DocDesc, Group1,VchKind,D.DocDate,D.SerialNo	'

	print @StrSelect;
	exec sp_executesql @StrSelect;

	SET @StrSelect = '
	select	T.*,
			acc.funGetAcntName(Group1,1, ' + @LangID + ') Group1Name,
			acc.funPartAcntFullName(Group1 ,1) Group1FullName 
			,V.TypeText VchKindName	,M.TypeText MonthName 
			,N'''+@MonthNameFR+''' MonthNameFR,N'''+@MonthNameTO+''' MonthNameTO
	from #tbl_AccountingBookSummary2_Result T 
	left join (select * from pub.tblTypeValues where TypeID =1) V on T.VchKind=V.TypeValue
	left join (select * from pub.tblTypeValues where TypeID =10) M  on T.MonthCode=M.TypeValue
	order by Group1, DocDate ,SerialNo'

	Print @StrSelect;
	Exec sp_executesql @StrSelect;

END

GO
