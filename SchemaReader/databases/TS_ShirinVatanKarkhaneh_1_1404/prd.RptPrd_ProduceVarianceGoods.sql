USE TS_ShirinVatanKarkhaneh_1_1404
GO
SET ANSI_NULLS, QUOTED_IDENTIFIER ON
GO
-- =========== TS-QC:UPDATED ====================
-- Author		 : TakroSystem\jafari
-- Create date   : 1400/01/18
-- Viewed By	 : 
-- Last Modified : 
-- Last Modifier : 
-- Description   : <لیست انحرافات تولید  >
-- =================================================================
Create PROCEDURE prd.RptPrd_ProduceVarianceGoods
	@FiscalYearFr	int = 0,
	@FiscalYearTo	int = 0,
	@SerialNoFr		int = 0,
	@SerialNoTo		int = 0,
	@DocDateFr		char(10) = null,
	@DocDateTo		char(10) = null,
	@SelectedProds	int = 0,
	@SelectedGoods	int = 0,
	@ExtraParams	NVarChar(Max) = '',
	@RepOptions		NVarChar(200) = '111',
	@RepInfo		NVarChar(100) = '1@1@1' -- bit array options
WITH ENCRYPTION
AS
DECLARE @StrSelect	NVarChar(4000)
DECLARE @StrWhere	NVarChar(4000)
DECLARE @StrWhere2	NVarChar(4000)
DECLARE @StrWhereF	NVarChar(4000)
DECLARE @SessionNo  int;
DECLARE @ReportID   int;
DECLARE	@Round		Int;
DECLARE	@LangID		Char(1);
DECLARE	@procs		varchar(20);

BEGIN

	SET NOCOUNT ON;
	-- I N I T ------------------------------------------------------------
	set @Round = 1;
	select @Round = SettingValue
	from pub.tblSettings
	where SettingKey = 'QuantityDecimals'
	---------------------------------------------------------------------------
	-- init ----------------------------------------
	IF (@RepInfo Is Null)		SET @RepInfo = '1@1@1';

	SET @LangID		= pub.funSplitString(@RepInfo, '@', 1);
	SET @SessionNo	= pub.funSplitString(@RepInfo, '@', 2);
	SET @ReportID	= pub.funSplitString(@RepInfo, '@', 3);

	declare @Remain bit
	declare @RemainValue bit
	declare @RemainValue1 float
	declare @RemainValue2 float
	declare @RemainPercent bit
	declare @RemainPercent1 float
	declare @RemainPercent2 float

	SET @Remain			= pub.funSplitString(@ExtraParams, '@', 1);
	SET @RemainValue	= pub.funSplitString(@ExtraParams, '@', 2);
	SET @RemainValue1	= pub.funSplitString(@ExtraParams, '@', 3);
	SET @RemainValue2	= pub.funSplitString(@ExtraParams, '@', 4);
	SET @RemainPercent	= pub.funSplitString(@ExtraParams, '@', 5);
	SET @RemainPercent1	= pub.funSplitString(@ExtraParams, '@', 6);
	SET @RemainPercent2	= pub.funSplitString(@ExtraParams, '@', 7);

	set @StrWhere2=' 1=1 '

	if @Remain='true'
		SET @StrWhere2 = @StrWhere2 + ' AND RemainGQ<>0' 
	if @RemainValue='true'
	begin
		SET @StrWhere2 = @StrWhere2 + ' AND RemainGQ>=' +str(@RemainValue1)
		SET @StrWhere2 = @StrWhere2 + ' AND RemainGQ<=' +str(@RemainValue2)
	end
	if @RemainPercent='true'
	begin
		SET @StrWhere2 = @StrWhere2 + ' AND PercentGQ>=' +str(@RemainPercent1)
		SET @StrWhere2 = @StrWhere2 + ' AND PercentGQ<=' +str(@RemainPercent2)
	end
		
	select @Round = SettingValue from pub.tblSettings where SettingKey = 'QuantityDecimals'
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
	
	--if (@70 = 1)
		SET @procs = @procs + ', 70'
	--if (@82 = 1)
		SET @procs = @procs + ', 82'
	
	SET @StrWhere = '(D.ProcessID in (' + @procs + '))'	
	
	if (@SerialNoFr is not null) and (@SerialNoFr > 0)
		SET @StrWhere = @StrWhere + ' AND (H.SerialNo >= ' + LTrim(STR(@SerialNoFr)) + ')'
	if (@SerialNoTo is not null) and (@SerialNoTo > 0)
		SET @StrWhere = @StrWhere + ' AND (H.SerialNo <= ' + LTrim(STR(@SerialNoTo)) + ')'
	
	if (@DocDateFr is not null) 
		SET @StrWhere = @StrWhere + ' AND (H.DocDate >= ''' + @DocDateFr + ''')'
	if (@DocDateTo is not null)
		SET @StrWhere = @StrWhere + ' AND (H.DocDate <= ''' + @DocDateTo + ''')'

	If (@SelectedProds > 0)
		SET @StrWhere = @StrWhere + ' AND ' + pub.funGetFilterString(@SessionNo, @ReportID, @SelectedProds, 'H.ProductID') 

	-------------------------------------------------
	-- SELECT SECTION -------------------------------
	create table #tbl_Prd_ProduceVariance_Total
	(
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
		DocDate			char(10) not null
	);
	
	SET @StrSelect = '
	Insert Into #tbl_Prd_ProduceVariance_Total(FiscalYear, SerialNo, ProductID, FormulaNo, GoodsID, ProdQuantity, SentQuantity,
											   BaseFiscalYear, BaseSerialNo, BaseDocRowNo, DocDate)
	Select	H.FiscalYear, H.SerialNo, H.ProductID, H.FormulaNo, D.GoodsID, H.ProductCount, SUM(D.GoodsQuantity),
			H.BaseFiscalYear, H.BaseSerialNo, D.BaseDocRowNo, H.DocDate
	From	inv.tblStorageDocsDtl D
				inner join inv.tblStorageDocsHdr H on H.ProcessID = D.ProcessID and H.ProcessNo = D.ProcessNo and H.FiscalYear = D.FiscalYear and H.SerialNo = D.SerialNo
	Where	' + @StrWhere + '
	Group By H.FiscalYear, H.SerialNo, H.ProductID, H.FormulaNo, D.GoodsID, H.ProductCount, H.BaseFiscalYear, H.BaseSerialNo, D.BaseDocRowNo, H.DocDate '

	Print @StrSelect;
	Exec sp_executesql @StrSelect;

	select M.*, [pub].[funGetGoodsName](M.ProductID, @LangID) As ProductName, [pub].[funGetGoodsName](M.GoodsID, @LangID) As GoodsName, 
				[pub].[funGetGoodsUnitName] (M.GoodsID, @LangID) As UnitName, [pub].[funGetGoodsUnitName] (M.ProductID, @LangID) As ProductUnitName
				into #Temp
	from
	(	
		select FiscalYear, SerialNo, ProductID, FormulaNo, GoodsID, SentQuantity, FormulaQuantity, +1 as Kind,
			   BaseFiscalYear, BaseSerialNo, BaseDocRowNo, DocDate, ProdQuantity
		from
		(
			select	T.FiscalYear, T.SerialNo, T.ProductID, T.FormulaNo, T.GoodsID, T.SentQuantity,
					T.BaseFiscalYear, T.BaseSerialNo, T.BaseDocRowNo, T.DocDate, T.ProdQuantity,
					isnull((
						select sum(D.GoodsQuantity / H.ProductCount)
						from prd.tblFormulasDtl D 
								inner join prd.tblFormulasHdr H on H.ProductID = D.ProductID and H.SerialNo = D.SerialNo
						where (D.ProductID = T.ProductID) and (D.SerialNo = T.FormulaNo) and (D.GoodsID = T.GoodsID)
					), 0) * T.ProdQuantity as FormulaQuantity
			from	#tbl_Prd_ProduceVariance_Total T
					inner join #tbl_ProduceVariance_Goods G on G.GoodsID=T.GoodsID
		) X
		where (round(X.SentQuantity, @Round) > round(X.FormulaQuantity, @Round)) --Or 
			   --round(X.SentQuantity, @Round) = round(X.FormulaQuantity, @Round))
		union all
		select FiscalYear, SerialNo, ProductID, FormulaNo, GoodsID, SentQuantity, FormulaQuantity, -1 as Kind,
			   BaseFiscalYear, BaseSerialNo, BaseDocRowNo, DocDate, ProdQuantity
		from
		(
			select	SH.FiscalYear, SH.SerialNo, SH.ProductID, SH.FormulaNo, FD.GoodsID, SH.BaseFiscalYear, SH.BaseSerialNo, SH.BaseDocRowNo,
					SH.DocDate, SH.ProdQuantity,
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
							select distinct FiscalYear, SerialNo, ProductID, FormulaNo, ProdQuantity,  BaseFiscalYear, BaseSerialNo, BaseDocRowNo, DocDate
							from #tbl_Prd_ProduceVariance_Total
						) SH on SH.ProductID = FD.ProductID and SH.FormulaNo = FD.SerialNo
					inner join #tbl_ProduceVariance_Prods P on P.ProductID=FD.ProductID
					inner join #tbl_ProduceVariance_Goods G on G.GoodsID=FD.GoodsID
			group by SH.FiscalYear, SH.SerialNo, SH.ProductID, SH.FormulaNo, FD.GoodsID, SH.ProdQuantity,
					 SH.BaseFiscalYear, SH.BaseSerialNo, SH.BaseDocRowNo, SH.DocDate, SH.ProdQuantity
		) X
		where (round(X.FormulaQuantity, @Round) > round(X.SentQuantity, @Round))	
	) M	
    order by M.FiscalYear, M.SerialNo, M.GoodsID

	SET @StrSelect = '
		select * from (
			select GoodsID,Sum(SentQuantity )GoodsQuantity,sum(FormulaQuantity) NeedGoodsQuantity
				,SUM(SentQuantity- FormulaQuantity) As RemainGQ
				,round(CASE WHEN SUM(SentQuantity)=0 THEN 200 ELSE SUM(FormulaQuantity) *100/SUM(SentQuantity) END ,'+str(@Round)+')-100  PercentGQ	,GoodsName  
			from #Temp
			group by GoodsID,GoodsName
		) aa
		where '+ @StrWhere2 

	Print @StrSelect;
	Exec sp_executesql @StrSelect;
END
GO
