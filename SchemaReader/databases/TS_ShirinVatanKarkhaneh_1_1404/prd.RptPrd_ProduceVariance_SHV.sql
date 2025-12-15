USE TS_ShirinVatanKarkhaneh_1_1404
GO
SET ANSI_NULLS, QUOTED_IDENTIFIER ON
GO

-- =============================================================================================
-- =============================================================================================
-- =============================================================================================
CREATE PROCEDURE [prd].[RptPrd_ProduceVariance_SHV]
	@FiscalYearFr	int = 0,
	@FiscalYearTo	int = 0,
	@SerialNoFr		int = 0,
	@SerialNoTo		int = 0,
	@DocDateFr		char(10) = Null,
	@DocDateTo		char(10) = Null,
	@SelectedProds	int = 0,
	@SelectedGoods	int = 0,
	@SelectedAcnt1	int = 0,
	@SelectedAcnt2	int = 0,
	@SelectedAcnt3	int = 0,
	@SelectedAcnt4	int = 0,
	@ProductID      Varchar(20) = Null,
	@GoodsID        Varchar(20) = Null,
	@RepOptions		NVarChar(200) = '1111',
	@RepInfo		NVarChar(100) = '1@1@1' -- bit array options
WITH ENCRYPTION
AS
DECLARE @StrSelect	NVarChar(MAX)
DECLARE @StrFrom	NVarChar(MAX)
DECLARE @StrWhere	NVarChar(MAX)
DECLARE @StrWhere2	NVarChar(MAX)

DECLARE	@LangID		Char(1);
DECLARE	@SessionNo	Int; -- برای حالت کدهای انتخابی
DECLARE	@ReportID	Int; -- برای حالت کدهای انتخابی
DECLARE	@Round		Int;
DECLARE	@procs		varchar(20);
DECLARE	@70			bit;
DECLARE	@82			bit;
DECLARE	@Accept		bit;
DECLARE	@Failed		bit;
DECLARE	@TaskSerialNoFR		Int;
DECLARE	@TaskSerialNoTo		Int;

BEGIN

	SET NOCOUNT ON;

	-- I N I T ------------------------------------------------------------
	IF (@RepInfo		Is Null)	SET @RepInfo = '1@1@1';
	IF (@RepOptions		Is Null)	SET @RepOptions = '111111';

	IF (@SelectedGoods	Is Null)	SET @SelectedGoods = 0;
	IF (@SelectedProds	Is Null)	SET @SelectedProds = 0;
	IF (@SelectedAcnt1	Is Null)	SET @SelectedAcnt1 = 0;
	IF (@SelectedAcnt2	Is Null)	SET @SelectedAcnt2 = 0;
	IF (@SelectedAcnt3	Is Null)	SET @SelectedAcnt3 = 0;
	IF (@SelectedAcnt4	Is Null)	SET @SelectedAcnt4 = 0;

	SET @LangID		= pub.funSplitString(@RepInfo, '@', 1);
	SET @SessionNo	= pub.funSplitString(@RepInfo, '@', 2);
	SET @ReportID	= pub.funSplitString(@RepInfo, '@', 3);
	
	SET @TaskSerialNoFR= pub.funSplitString(@RepInfo, '@', 7);
	SET @TaskSerialNoTo= pub.funSplitString(@RepInfo, '@', 8);

 
	set @70 = Substring(@RepOptions, 1, 1);
	set @82 = Substring(@RepOptions, 2, 1);
	set @Accept = Substring(@RepOptions, 3, 1);
	set @Failed = Substring(@RepOptions, 4, 1);

	set @Round = 1;

	select @Round = SettingValue
	from pub.tblSettings
	where SettingKey = 'QuantityDecimals'
	---------------------------------------------------------------------------
	create table #tbl_ProduceVariance_Goods
	(
		GoodsID varchar(20) collate arabic_cs_as
	);
	create table #tbl_ProduceVariance_Prods
	(
		ProductID varchar(20) collate arabic_cs_as
	);
	
	if (@SelectedGoods = 0)
	begin
		insert into #tbl_ProduceVariance_Goods
		select distinct GoodsID
		from inv.tblGoodsDtl
	end
	else
	begin
		set @StrSelect = '
		insert into #tbl_ProduceVariance_Goods
		select distinct GoodsID
		from inv.tblGoodsDtl
		where ' + pub.funGetFilterString(@SessionNo, @ReportID, @SelectedGoods, 'GoodsID') 
		print @StrSelect 
		exec sp_executesql @StrSelect 
	end
	
	if (@SelectedProds = 0)
	begin
		insert into #tbl_ProduceVariance_Prods
		select distinct ProductID
		from prd.tblFormulasDtl
	end
	else
	begin
		set @StrSelect = '
		insert into #tbl_ProduceVariance_Prods
		select distinct ProductID
		from prd.tblFormulasDtl
		where ' + pub.funGetFilterString(@SessionNo, @ReportID, @SelectedProds, 'ProductID')
		
		print @StrSelect 
		exec sp_executesql @StrSelect 
	end
	
	-- WHERE SECTION ----------------------------------------------------------
	SET @procs = '0'
	
	if (@70 = 1)
		SET @procs = @procs + ', 70'
	if (@82 = 1)
		SET @procs = @procs + ', 82'
	
	SET @StrWhere2 = '1 = 1'
	SET @StrWhere = '(D.ProcessID in (' + @procs + '))'
	
	if (@Accept = 0)
		SET @StrWhere = @StrWhere + ' AND 
		isnull((
			select AcceptableCount
			from pln.tblTaskOrderDtl T
			where T.ProcessID=D.BaseProcessID and T.ProcessNo=D.BaseProcessNo and T.FiscalYear=D.BaseFiscalYear and T.SerialNo=D.BaseSerialNo and T.DocRowNo=D.BaseDocRowNo),0)=0'

	if (@Failed = 0)
		SET @StrWhere = @StrWhere + ' AND 
		isnull((
			select UnacceptableCount
			from pln.tblTaskOrderDtl T
			where T.ProcessID=D.BaseProcessID and T.ProcessNo=D.BaseProcessNo and T.FiscalYear=D.BaseFiscalYear and T.SerialNo=D.BaseSerialNo and T.DocRowNo=D.BaseDocRowNo),0)=0'
	
	if (@SerialNoFr is not null) and (@SerialNoFr > 0)
		SET @StrWhere = @StrWhere + ' AND (H.SerialNo >= ' + LTrim(STR(@SerialNoFr)) + ')'
	if (@SerialNoTo is not null) and (@SerialNoTo > 0)
		SET @StrWhere = @StrWhere + ' AND (H.SerialNo <= ' + LTrim(STR(@SerialNoTo)) + ')'
	
	if (@DocDateFr is not null) 
		SET @StrWhere = @StrWhere + ' AND (H.DocDate >= ''' + @DocDateFr + ''')'
	if (@DocDateTo is not null)
		SET @StrWhere = @StrWhere + ' AND (H.DocDate <= ''' + @DocDateTo + ''')'

	--If (@SelectedGoods > 0)
	--	SET @StrWhere = @StrWhere + ' AND ' + pub.funGetFilterString(@SessionNo, @ReportID, @SelectedGoods, 'D.GoodsID') 
	If (@SelectedProds > 0)
		SET @StrWhere = @StrWhere + ' AND ' + pub.funGetFilterString(@SessionNo, @ReportID, @SelectedProds, 'H.ProductID') 

	If (@SelectedAcnt1 > 0)
		SET @StrWhere = @StrWhere + ' AND ' + pub.funGetFilterString(@SessionNo, @ReportID, @SelectedAcnt1, 'D.AcntCode')
	If (@SelectedAcnt2 > 0)
		SET @StrWhere = @StrWhere + ' AND ' + pub.funGetFilterString(@SessionNo, @ReportID, @SelectedAcnt2, 'D.AcntCode')
	If (@SelectedAcnt3 > 0)
		SET @StrWhere = @StrWhere + ' AND ' + pub.funGetFilterString(@SessionNo, @ReportID, @SelectedAcnt3, 'D.AcntCode')
	If (@SelectedAcnt4 > 0)
		SET @StrWhere = @StrWhere + ' AND ' + pub.funGetFilterString(@SessionNo, @ReportID, @SelectedAcnt4, 'D.AcntCode')
		
    -- ======================================================== Product And Goods Filter
	if @ProductID <> '' And @ProductID is not null
		SET @StrWhere2 = @StrWhere2 + ' AND ProductID = ''' + LTrim(Rtrim(@ProductID)) + ''''

	if @GoodsID <> '' And @GoodsID is not null
		SET @StrWhere2 = @StrWhere2 + ' AND GoodsID = ''' + LTrim(Rtrim(@GoodsID)) + ''''
	
	if (@TaskSerialNoFR is not null) and (@TaskSerialNoFR > 0)
		SET @StrWhere = @StrWhere + ' AND (D.BaseSerialNo >= ' + LTrim(STR(@TaskSerialNoFR)) + ')'
	if (@TaskSerialNoTo is not null) and (@SerialNoTo > 0)
		SET @StrWhere = @StrWhere + ' AND (D.BaseSerialNo <= ' + LTrim(STR(@TaskSerialNoTo)) + ')'
				
	-------------------------------------------------
	-- SELECT SECTION -------------------------------
	create table #tbl_Prd_ProduceVariance_Total
	(
		ProcessID		int	not null,
		ProcessNo		int	not null,
		FiscalYear		int	not null,
		SerialNo		int	not null,
		ProductID		varchar(20) collate arabic_cs_as not null,
		FormulaNo		int	not null,
		GoodsID			varchar(20)	collate arabic_cs_as not null,
		ProdQuantity	float	not null,
		SentQuantity	float	not null,
		BaseFiscalYear	smallint not null,
		BaseSerialNo	int not null,
		BaseDocRowNo	int not null,
		DocDate			char(10) not null,
		GoodsAmount		float	not null,
	);
	
	SET @StrSelect = '
	INSERT INTO #tbl_Prd_ProduceVariance_Total(ProcessID, ProcessNo, FiscalYear, SerialNo, ProductID, FormulaNo, GoodsID, ProdQuantity, SentQuantity,
											   BaseFiscalYear, BaseSerialNo, BaseDocRowNo, DocDate, GoodsAmount)
	SELECT	H.ProcessID, H.ProcessNo, H.FiscalYear, H.SerialNo, H.ProductID, H.FormulaNo, D.GoodsID, H.ProductCount, SUM(D.GoodsQuantity),
			H.BaseFiscalYear, H.BaseSerialNo, D.BaseDocRowNo, H.DocDate, D.GoodsAmount
	FROM	inv.tblStorageDocsDtl D
    INNER JOIN inv.tblStorageDocsHdr H on H.ProcessID = D.ProcessID and H.ProcessNo = D.ProcessNo and H.FiscalYear = D.FiscalYear and H.SerialNo = D.SerialNo
	WHERE	' + @StrWhere + '
	GROUP BY H.ProcessID, H.ProcessNo, H.FiscalYear, H.SerialNo, H.ProductID, H.FormulaNo, D.GoodsID, H.ProductCount, 
	         H.BaseFiscalYear, H.BaseSerialNo, D.BaseDocRowNo, H.DocDate, D.GoodsAmount
	'

	Print @StrSelect;
	Exec sp_executesql @StrSelect;

	-- ==================================================================================================================================
	-- ================================================================================================================================== Last Select
	-- ==================================================================================================================================
	SET @StrSelect = '
	-- ==============================================================================================================================================
	SELECT M.*, [pub].[funGetGoodsName](M.ProductID, ' + LTrim(RTrim(Str(@LangID))) + ') As ProductName, 
	      [pub].[funGetGoodsName](M.GoodsID, ' + LTrim(RTrim(Str(@LangID))) + ') As GoodsName, 
		  [pub].[funGetGoodsUnitName] (M.GoodsID, ' + LTrim(RTrim(Str(@LangID))) + ') As UnitName, 
		  [pub].[funGetGoodsUnitName] (M.ProductID, ' + LTrim(RTrim(Str(@LangID))) + ') As ProductUnitName
	FROM
	(	
		select ProcessID, ProcessNo, FiscalYear, SerialNo, ProductID, FormulaNo, GoodsID, SentQuantity, FormulaQuantity, +1 as Kind,
			   BaseFiscalYear, BaseSerialNo, BaseDocRowNo, DocDate, ProdQuantity,GoodsAmount
		from
		(
			select	T.ProcessID, T.ProcessNo, T.FiscalYear, T.SerialNo, T.ProductID, T.FormulaNo, T.GoodsID, T.SentQuantity,
					T.BaseFiscalYear, T.BaseSerialNo, T.BaseDocRowNo, T.DocDate, T.ProdQuantity,
					isnull((
						select sum(D.GoodsQuantity / H.ProductCount)
						from prd.tblFormulasDtl D 
								inner join prd.tblFormulasHdr H on H.ProductID = D.ProductID and H.SerialNo = D.SerialNo
						where (D.ProductID = T.ProductID) and (D.SerialNo = T.FormulaNo) and (D.GoodsID = T.GoodsID)
					), 0) * T.ProdQuantity as FormulaQuantity,GoodsAmount
			from	#tbl_Prd_ProduceVariance_Total T
					inner join #tbl_ProduceVariance_Goods G on G.GoodsID=T.GoodsID
		) X
		where (round(X.SentQuantity, ' + LTrim(RTrim(Str(@Round))) + ') > round(X.FormulaQuantity, ' + LTrim(RTrim(Str(@Round))) + ')) --Or 
			   --round(X.SentQuantity, ' + LTrim(RTrim(Str(@Round))) + ') = round(X.FormulaQuantity, ' + LTrim(RTrim(Str(@Round))) + '))
		union all
		select ProcessID, ProcessNo, FiscalYear, SerialNo, ProductID, FormulaNo, GoodsID, SentQuantity, FormulaQuantity, -1 as Kind,
			   BaseFiscalYear, BaseSerialNo, BaseDocRowNo, DocDate, ProdQuantity,GoodsAmount
		from
		(
			select	SH.ProcessID, SH.ProcessNo, SH.FiscalYear, SH.SerialNo, SH.ProductID, SH.FormulaNo, FD.GoodsID, SH.BaseFiscalYear, SH.BaseSerialNo, SH.BaseDocRowNo,
					SH.DocDate, SH.ProdQuantity,0 GoodsAmount,
					isnull((
						select sum(SD.SentQuantity)
						from #tbl_Prd_ProduceVariance_Total SD
						where (SD.FiscalYear = SH.FiscalYear) and (SD.SerialNo = SH.SerialNo) and (SD.GoodsID = FD.GoodsID)
					), 0) as SentQuantity,
					sum(FD.GoodsQuantity / FH.ProductCount) * SH.ProdQuantity as FormulaQuantity
			from prd.tblFormulasDtl FD 
					inner join prd.tblFormulasHdr FH on FH.ProductID = FD.ProductID and FH.SerialNo = FD.SerialNo
					inner join 
						(
							select distinct ProcessID, ProcessNo, FiscalYear, SerialNo, ProductID, FormulaNo, ProdQuantity,  BaseFiscalYear, BaseSerialNo, BaseDocRowNo, DocDate
							from #tbl_Prd_ProduceVariance_Total
						) SH on SH.ProductID = FD.ProductID and SH.FormulaNo = FD.SerialNo
					inner join #tbl_ProduceVariance_Prods P on P.ProductID=FD.ProductID
					inner join #tbl_ProduceVariance_Goods G on G.GoodsID=FD.GoodsID
			group by SH.ProcessID, SH.ProcessNo, SH.FiscalYear, SH.SerialNo, SH.ProductID, SH.FormulaNo, FD.GoodsID, SH.ProdQuantity,
					 SH.BaseFiscalYear, SH.BaseSerialNo, SH.BaseDocRowNo, SH.DocDate, SH.ProdQuantity
		) X
		where (round(X.FormulaQuantity, ' + LTrim(RTrim(Str(@Round))) + ') > round(X.SentQuantity, ' + LTrim(RTrim(Str(@Round))) + '))	
	) M
	WHERE ' + @StrWhere2 + '
    ORDER BY M.FiscalYear, M.SerialNo, M.GoodsID
	'

	-- ============================
	Print @StrSelect
	EXEC  sp_executesql @StrSelect 

END
GO
