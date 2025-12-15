USE TS_ShirinVatanKarkhaneh_1_1404
GO
SET ANSI_NULLS, QUOTED_IDENTIFIER ON
GO
-- =========== TS-QC:UPDATED ====================
-- Author		 : TakroSystem\Zia
-- Create date   : 1392/09/06
-- Viewed By	 : 
-- Last Modified : 1392/09/06
-- Last Modifier : TakroSystem\Zia
-- Description   : <لیست انحرافات تولید نسبت به فرمول تولید>
-- =================================================================
CREATE PROCEDURE [prd].[RptPrd_Produce_SimilarGoods_Used]
	@FiscalYearFr	int = null,
	@FiscalYearTo	int = null,
	@SerialNoFr		int = null,
	@SerialNoTo		int = null,
	@DocDateFr		char(10) = null,
	@DocDateTo		char(10) = null,
	@SelectedProds	int = 0,
	@SelectedGoods	int = 0,
	@SelectedAcnt1	int = 0,
	@SelectedAcnt2	int = 0,
	@SelectedAcnt3	int = 0,
	@SelectedAcnt4	int = 0,
	@RepOptions		NVarChar(200) = '111',
	@RepInfo		NVarChar(100) = '1@1@1' -- bit array options
WITH ENCRYPTION
AS
DECLARE @StrSelect	NVarChar(max)
DECLARE @StrFrom	NVarChar(max)
DECLARE @StrWhere	NVarChar(max)
DECLARE @StrWhereG	NVarChar(max)

DECLARE	@LangID		Char(1);
DECLARE	@SessionNo	Int; -- برای حالت کدهای انتخابی
DECLARE	@ReportID	Int; -- برای حالت کدهای انتخابی

DECLARE	@Round		Int;
DECLARE	@procs		varchar(20);
DECLARE	@70			bit;
DECLARE	@82			bit;

DECLARE	@ProcessID		int	;
DECLARE	@ProcessNo		int	;
DECLARE	@FiscalYear		int	;
DECLARE	@SerialNo		int	;
DECLARE	@FormulaNo		int	;
DECLARE	@ProdQuantity	float;
DECLARE	@ProductID		varchar(20);

DECLARE	@GoodsID		varchar(20);
DECLARE	@GoodsQuantity	float;

DECLARE	@FGoodsID		varchar(20);
DECLARE	@FGoodsQuantity	float;

DECLARE	@FDocRowNo int;
DECLARE	@Count int;
BEGIN

	SET NOCOUNT ON;

	-- I N I T ------------------------------------------------------------
	IF (@RepInfo		Is Null)	SET @RepInfo = '1@1@1';
	IF (@RepOptions		Is Null)	SET @RepOptions = '1';

	IF (@SelectedGoods	Is Null)	SET @SelectedGoods = 0;
	IF (@SelectedProds	Is Null)	SET @SelectedProds = 0;
	IF (@SelectedAcnt1	Is Null)	SET @SelectedAcnt1 = 0;
	IF (@SelectedAcnt2	Is Null)	SET @SelectedAcnt2 = 0;
	IF (@SelectedAcnt3	Is Null)	SET @SelectedAcnt3 = 0;
	IF (@SelectedAcnt4	Is Null)	SET @SelectedAcnt4 = 0;

	IF (@FiscalYearFr Is Null)		SET @SerialNoFr = Null;
	IF (@FiscalYearTo Is Null)		SET @SerialNoTo = Null;
	IF (@SerialNoFr	Is Null)		SET @FiscalYearFr = Null;
	IF (@SerialNoTo	Is Null)		SET @FiscalYearTo = Null;

	SET @LangID		= pub.funSplitString(@RepInfo, '@', 1);
	SET @SessionNo	= pub.funSplitString(@RepInfo, '@', 2);
	SET @ReportID	= pub.funSplitString(@RepInfo, '@', 3);
	
	set @70 = Substring(@RepOptions, 1, 1);
	set @82 = Substring(@RepOptions, 2, 1);

	set @Round = 1;

	select @Round = SettingValue
	from pub.tblSettings
	where SettingKey = 'QuantityDecimals'
	---------------------------------------------------------------------------

	-- WHERE SECTION --------------------------------
	SET @procs = '0'
	
	if (@70 = 1)
		SET @procs = @procs + ', 70'
	if (@82 = 1)
		SET @procs = @procs + ', 82'
	
	SET @StrWhere = '(H.ProcessID in (' + @procs + '))'
	
	If (@SerialNoFr Is Not Null)
		Set @StrWhere = @StrWhere + ' AND (H.FiscalYear>' + LTrim(Str(@FiscalYearFr)) + ' OR (H.FiscalYear=' + LTrim(Str(@FiscalYearFr)) + ' AND H.SerialNo>=' + LTrim(Str(@SerialNoFr)) + '))'
	If (@SerialNoTo Is Not Null)
		Set @StrWhere = @StrWhere + ' AND (H.FiscalYear<' + LTrim(Str(@FiscalYearTo)) + ' OR (H.FiscalYear=' + LTrim(Str(@FiscalYearTo)) + ' AND H.SerialNo<=' + LTrim(Str(@SerialNoTo)) + '))'

	if (@DocDateFr is not null) 
		SET @StrWhere = @StrWhere + ' AND (H.DocDate >= ''' + @DocDateFr + ''')'
	if (@DocDateTo is not null)
		SET @StrWhere = @StrWhere + ' AND (H.DocDate <= ''' + @DocDateTo + ''')'

	--If (@SelectedGoods > 0)
	--	SET @StrWhere = @StrWhere + ' AND ' + pub.funGetFilterString(@SessionNo, @ReportID, @SelectedGoods, 'D.GoodsID') 
	If (@SelectedProds > 0)
		SET @StrWhere = @StrWhere + ' AND ' + pub.funGetFilterString(@SessionNo, @ReportID, @SelectedProds, 'H.ProductID') 

	If (@SelectedAcnt1 > 0)
		SET @StrWhere = @StrWhere + ' AND ' + pub.funGetFilterString(@SessionNo, @ReportID, @SelectedAcnt1, 'H.AcntCode')
	If (@SelectedAcnt2 > 0)
		SET @StrWhere = @StrWhere + ' AND ' + pub.funGetFilterString(@SessionNo, @ReportID, @SelectedAcnt2, 'H.AcntCode')
	If (@SelectedAcnt3 > 0)
		SET @StrWhere = @StrWhere + ' AND ' + pub.funGetFilterString(@SessionNo, @ReportID, @SelectedAcnt3, 'H.AcntCode')
	If (@SelectedAcnt4 > 0)
		SET @StrWhere = @StrWhere + ' AND ' + pub.funGetFilterString(@SessionNo, @ReportID, @SelectedAcnt4, 'H.AcntCode')
		
	If (@SelectedGoods > 0)
		SET @StrWhereG = ' AND ' + pub.funGetFilterString(@SessionNo, @ReportID, @SelectedGoods, 'A.GoodsID') 
	else
		set @StrWhereG = ''
	-------------------------------------------------

	-- SELECT SECTION -------------------------------
	create table #tbl_Prd_ProduceVariance_DocsHdr
	(
		ProcessID		int	not null,
		ProcessNo		int	not null,
		FiscalYear		int	not null,
		SerialNo		int	not null,
		ProductID		varchar(20) collate arabic_cs_as not null,
		FormulaNo		int	not null,
		ProdQuantity	float not null
	)
	
	create table #tbl_Prd_ProduceVariance_Total
	(
		FiscalYear	int	not null,
		SerialNo	int	not null,
		FormulaNo	int	not null,
		ProdGoodsID	varchar(20) collate arabic_cs_as not null,
		SentGoodsID	varchar(20)	collate arabic_cs_as not null,
		MainGoodsID	varchar(20)	collate arabic_cs_as not null,
		ProdQuantity float	not null,
		SentQuantity float	not null,
		MainQuantity float	not null,
		BaseFiscalYear	int	not null,
		BaseSerialNo	int	not null,
		DocDate		char(10)
	);

	create table #tbl_Prd_ProduceVariance_Formula
	(
		SimilarGoodsID	varchar(20)	collate arabic_cs_as not null,
		FormulaGoodsID	varchar(20)	collate arabic_cs_as not null,
		SimilarQuantity float,
		FormulaQuantity float
	);
	
	SET @StrSelect = '
	insert	into #tbl_Prd_ProduceVariance_DocsHdr(ProcessID, ProcessNo, FiscalYear, SerialNo, ProductID, FormulaNo, ProdQuantity)
	select	H.ProcessID, H.ProcessNo, H.FiscalYear, H.SerialNo, H.ProductID, H.FormulaNo, H.ProductCount
	from	inv.tblStorageDocsHdr H 
	where   ' + @StrWhere + '
	order by H.DocDate, H.FiscalYear, H.SerialNo '

	Print @StrSelect;
	Exec sp_executesql @StrSelect;

 	Declare	cur_SH CURSOR For 
		SELECT	ProcessID,ProcessNo,FiscalYear,SerialNo,ProductID,FormulaNo,ProdQuantity	
		FROM #tbl_Prd_ProduceVariance_DocsHdr
 	Open  cur_SH;

	Fetch NEXT From cur_SH Into @ProcessID,@ProcessNo,@FiscalYear,@SerialNo,@ProductID,@FormulaNo,@ProdQuantity

	While (@@Fetch_Status = 0)
	BEGIN 
		set @StrSelect = '
		insert into #tbl_Prd_ProduceVariance_Formula(SimilarGoodsID, SimilarQuantity, FormulaGoodsID, FormulaQuantity)
		select	A.GoodsID, A.GoodsQuantity*' + Ltrim(Str(@ProdQuantity)) + '/H.ProductCount, D.GoodsID, D.GoodsQuantity*' + Ltrim(Str(@ProdQuantity)) + '/H.ProductCount
		from	prd.tblFormulasAtm A
					inner join prd.tblFormulasDtl D on D.ProductID=A.ProductID and D.SerialNo=A.SerialNo and D.DocRowNo=A.DocRowNo
					inner join prd.tblFormulasHdr H on H.ProductID=D.ProductID and H.SerialNo=D.SerialNo
		where	(A.ProductID=''' + @ProductID + ''') and (A.SerialNo=' + Ltrim(Str(@FormulaNo)) + ')' + @StrWhereG
		
		print @StrSelect; 
		exec sp_executesql @StrSelect;
		
		insert into #tbl_Prd_ProduceVariance_Total(FiscalYear, SerialNo, FormulaNo, ProdGoodsID, ProdQuantity, MainGoodsID, MainQuantity, SentGoodsID, SentQuantity, BaseFiscalYear, BaseSerialNo, DocDate)
		select @FiscalYear, @SerialNo, @FormulaNo, @ProductID, @ProdQuantity, F.FormulaGoodsID, F.FormulaQuantity, D.GoodsID, D.GoodsQuantity, D.BaseFiscalYear, D.BaseSerialNo, D.DocDate
		from inv.tblStorageDocsDtl D
			left join #tbl_Prd_ProduceVariance_Formula F on F.SimilarGoodsID=D.GoodsID
		where (ProcessID=@ProcessID) and (ProcessNo=@ProcessNo) and (FiscalYear=@FiscalYear) and (SerialNo=@SerialNo)
			and F.FormulaGoodsID not in 
			(
				select GoodsID
				from inv.tblStorageDocsDtl D
				where (ProcessID=@ProcessID) 
					and (ProcessNo=@ProcessNo) 
					and (FiscalYear=@FiscalYear) 
					and (SerialNo=@SerialNo)
			) 
			and F.FormulaGoodsID is not null
				
		delete from #tbl_Prd_ProduceVariance_Formula

		Fetch NEXT From cur_SH Into @ProcessID,@ProcessNo,@FiscalYear,@SerialNo,@ProductID,@FormulaNo,@ProdQuantity	
	END

	Close cur_SH;
	Deallocate cur_SH; 
	
	SELECT T.*, 
		[pub].[funGetGoodsName](T.ProdGoodsID, @LangID) As ProdGoodsName,
		[pub].[funGetGoodsName](T.MainGoodsID, @LangID) As MainGoodsName,
		[pub].[funGetGoodsName](T.SentGoodsID, @LangID) As SentGoodsName
	FROM #tbl_Prd_ProduceVariance_Total T
	ORDER BY T.DocDate, T.FiscalYear, T.SerialNo, T.SentGoodsID
END
GO
