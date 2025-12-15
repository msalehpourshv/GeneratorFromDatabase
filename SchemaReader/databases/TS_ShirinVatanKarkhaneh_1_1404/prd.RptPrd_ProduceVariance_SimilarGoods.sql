USE TS_ShirinVatanKarkhaneh_1_1404
GO
SET ANSI_NULLS, QUOTED_IDENTIFIER ON
GO
-- =========== TS-QC:UPDATED ====================
-- Author		 : TakroSystem\Zia
-- Create date   : 1390/10/11
-- Viewed By	 : 
-- Last Modified : 1392/10/21
-- Last Modifier : TakroSystem\Hamid
-- Description   : <لیست انحرافات تولید نسبت به فرمول تولید>
-- =================================================================
Create PROCEDURE [prd].[RptPrd_ProduceVariance_SimilarGoods]
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
	@ProductID2		Varchar(20) = Null,
	@GoodsID2		Varchar(20) = Null,	
	@RepOptions		NVarChar(200) = '111',
	@RepInfo		NVarChar(100) = '1@1@1' -- bit array options
WITH ENCRYPTION
AS

DECLARE @StrSelect		NVarChar(2000)
DECLARE @StrFrom		NVarChar(2000)
DECLARE @StrWhere		NVarChar(2000)
DECLARE @StrWhereG		NVarChar(max)

DECLARE	@procs			varchar(20);
DECLARE	@ProductID		varchar(20);
DECLARE	@BatchNo		varchar(20);
DECLARE	@GoodsID		varchar(20);
DECLARE	@FGoodsID		varchar(20);

DECLARE	@LangID			Char(1);
DECLARE	@DocDate		char(10);

DECLARE	@BaseFiscalYear	smallint;
DECLARE	@SessionNo		Int; -- برای حالت کدهای انتخابی
DECLARE	@ReportID		Int; -- برای حالت کدهای انتخابی
DECLARE	@Round			Int;
DECLARE	@ProcessID		int	;
DECLARE	@ProcessNo		int	;
DECLARE	@FiscalYear		int	;
DECLARE	@SerialNo		int	;
DECLARE	@FormulaNo		int	;
DECLARE	@BaseSerialNo	int;
DECLARE	@FDocRowNo		int;
DECLARE	@Count			int;
DECLARE	@ProdQuantity	float;
DECLARE	@GoodsQuantity	float;
DECLARE	@FGoodsQuantity	float;

DECLARE	@70				bit;
DECLARE	@82				bit;
DECLARE	@Accept			bit;
DECLARE	@Failed			bit;
DECLARE	@GroupByBatchNo	bit;
declare @DontShowZeroOffset as bit;

BEGIN

	SET NOCOUNT ON;

	-- I N I T ------------------------------------------------------------
	SET @BatchNo = ''
	IF (@RepInfo		Is Null)	SET @RepInfo = '1@1@1';
	IF (@RepOptions		Is Null)	SET @RepOptions = '1';

	IF (@SelectedGoods	Is Null)	SET @SelectedGoods = 0;
	IF (@SelectedProds	Is Null)	SET @SelectedProds = 0;
	IF (@SelectedAcnt1	Is Null)	SET @SelectedAcnt1 = 0;
	IF (@SelectedAcnt2	Is Null)	SET @SelectedAcnt2 = 0;
	IF (@SelectedAcnt3	Is Null)	SET @SelectedAcnt3 = 0;
	IF (@SelectedAcnt4	Is Null)	SET @SelectedAcnt4 = 0;

	SET @LangID		= pub.funSplitString(@RepInfo, '@', 1);
	SET @SessionNo	= pub.funSplitString(@RepInfo, '@', 2);
	SET @ReportID	= pub.funSplitString(@RepInfo, '@', 3);
	SET @BatchNo	= pub.funSplitString(@RepInfo, '@', 6);
	SET @DontShowZeroOffset = pub.funSplitString(@RepInfo, '@', 9);
		
	set @70				 = Substring(@RepOptions, 1, 1);
	set @82				= Substring(@RepOptions, 2, 1);
	set @Accept			= Substring(@RepOptions, 3, 1);
	set @Failed			= Substring(@RepOptions, 4, 1);
	set @GroupByBatchNo = Substring(@RepOptions, 5, 1);
	
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
	if (@BatchNo is not null)
		SET @StrWhere = @StrWhere + ' AND (H.BatchNo = ''' + @BatchNo + ''')'

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
		ProdQuantity	float	not null,
		BaseFiscalYear	smallint not null,
		BaseSerialNo	int not null,
		DocDate			char(10) not null	
	)
	
	create table #tbl_Prd_ProduceVariance_Total
	(
		FiscalYear	int	not null,
		SerialNo	int	not null,
		ProductID	varchar(20) collate arabic_cs_as not null,
		FormulaNo	int	not null,
		GoodsID		varchar(20)	collate arabic_cs_as not null,
		ProdQuantity	float	not null,
		SentQuantity	float	not null,
		FormulaQuantity float	not null,
		BaseFiscalYear	smallint not null,
		BaseSerialNo	int not null,
		DocDate			char(10) not null
	);
	
	create table #tbl_Prd_ProduceVariance_DocsDtl
	(
		GoodsID		varchar(20)	collate arabic_cs_as not null,
		GoodsQuantity float
	);
	
	create table #tbl_Temp
	(
		ProcessID	int	not null,
		ProcessNo	int	not null,
		FiscalYear	smallint not null,
		SerialNo	int not null,
		FormulaNo	int	not null,
		ProductID	varchar(20) collate arabic_cs_as not null,
		GoodsID		varchar(20)	collate arabic_cs_as not null,
		GoodsQuantity	float	not null,
		ProductCount	float	not null
	);
	
	SET @StrSelect = '
	insert	into #tbl_Prd_ProduceVariance_DocsHdr(ProcessID, ProcessNo, FiscalYear, SerialNo, ProductID, FormulaNo,
												  ProdQuantity, BaseFiscalYear, BaseSerialNo, DocDate)
	select	distinct H.ProcessID, H.ProcessNo, H.FiscalYear, H.SerialNo, H.ProductID, H.FormulaNo, H.ProductCount,
			H.BaseFiscalYear, H.BaseSerialNo, H.DocDate
	from	inv.tblStorageDocsDtl D 
				inner join inv.tblStorageDocsHdr H on H.ProcessID = D.ProcessID and H.ProcessNo = D.ProcessNo and H.FiscalYear = D.FiscalYear and H.SerialNo = D.SerialNo
	where ' + @StrWhere 

	Print @StrSelect;
	Exec sp_executesql @StrSelect;

 	Declare	cur_SH CURSOR For 
		SELECT	ProcessID,ProcessNo,FiscalYear,SerialNo,ProductID,FormulaNo,ProdQuantity,BaseFiscalYear,BaseSerialNo,DocDate	
		FROM #tbl_Prd_ProduceVariance_DocsHdr
 	Open  cur_SH;

	Fetch NEXT From cur_SH Into @ProcessID,@ProcessNo,@FiscalYear,@SerialNo,@ProductID,@FormulaNo,@ProdQuantity,@BaseFiscalYear,@BaseSerialNo,@DocDate

	While (@@Fetch_Status = 0)
	BEGIN 
		-- #tbl_Prd_ProduceVariance_DocsHdr --
		--------------------------------------
		delete from #tbl_Temp

		insert into #tbl_Temp(ProcessID,ProcessNo,FiscalYear,SerialNo,FormulaNo,ProductID,GoodsID,GoodsQuantity,ProductCount)
		select H.ProcessID,H.ProcessNo,H.FiscalYear,H.SerialNo,H.FormulaNo,ProductID,GoodsID,GoodsQuantity,ProductCount
		from inv.tblStorageDocsDtl D
				inner join inv.tblStorageDocsHdr H on H.ProcessID=D.ProcessID and H.ProcessNo=D.ProcessNo and H.FiscalYear=D.FiscalYear AND H.SerialNo=D.SerialNo
		where H.ProcessID=@ProcessID and H.ProcessNo=@ProcessNo and H.FiscalYear=@FiscalYear and H.SerialNo=@SerialNo

		update #tbl_Temp
		set GoodsID = FD.GoodsID, GoodsQuantity=a.GoodsQuantity * (FD.GoodsQuantity / FA.GoodsQuantity)
		from #tbl_Temp a
			inner join prd.tblFormulasDtl FD on FD.ProductID=a.ProductID AND FD.SerialNo= a.FormulaNo 
		inner join prd.tblFormulasHdr H on H.ProductID=FD.ProductID and H.SerialNo=FD.SerialNo
			Inner join prd.tblFormulasAtm FA on FD.ProductID=FA.ProductID AND FD.SerialNo= FA.SerialNo and FA.DocRowNo=FD.DocRowNo AND FA.GoodsID=a.GoodsID
		 where FA.GoodsQuantity <> 0 and round(abs((FD.GoodsQuantity * a.ProductCount / H.ProductCount)-a.GoodsQuantity),2)<0.001
		 
		Declare	cur_SD CURSOR For 
			select GoodsID,SUM(GoodsQuantity)  GoodsQuantity
			from #tbl_Temp
			where ProcessID=@ProcessID and ProcessNo=@ProcessNo and FiscalYear=@FiscalYear and SerialNo=@SerialNo
			GROUP BY GoodsID

		Open  cur_SD;

		Fetch NEXT From cur_SD Into @GoodsID, @GoodsQuantity

		While (@@Fetch_Status = 0)
		BEGIN
			-- inv.tblStorageDocsDtl --
			
			select @FGoodsID='', @FGoodsQuantity=0;
			
			select @FGoodsID=D.GoodsID, @FGoodsQuantity=D.GoodsQuantity * @ProdQuantity / H.ProductCount
			from prd.tblFormulasDtl D
					inner join prd.tblFormulasHdr H on H.ProductID=D.ProductID and H.SerialNo=D.SerialNo
			where D.ProductID=@ProductID and D.SerialNo=@FormulaNo and GoodsID=@GoodsID
			
			if (@FGoodsID <> '')
			begin
				if (Round(@GoodsQuantity, @Round) <> Round(@FGoodsQuantity, @Round)) OR @GroupByBatchNo='True'
					insert into #tbl_Prd_ProduceVariance_Total(FiscalYear, SerialNo, ProductID, ProdQuantity, FormulaNo, GoodsID,
															   SentQuantity, FormulaQuantity, BaseFiscalYear, BaseSerialNo, DocDate)
					values (@FiscalYear, @SerialNo, @ProductID, @ProdQuantity, @FormulaNo, @GoodsID, @GoodsQuantity, @FGoodsQuantity,
						    @BaseFiscalYear, @BaseSerialNo, @DocDate)
			end
			else
			begin
				select @FGoodsID=GoodsID, @FGoodsQuantity=A.GoodsQuantity * @ProdQuantity / H.ProductCount
				from prd.tblFormulasAtm A
					inner join prd.tblFormulasHdr H on H.ProductID=A.ProductID and H.SerialNo=A.SerialNo
				where A.ProductID=@ProductID and A.SerialNo=@FormulaNo and GoodsID=@GoodsID
				
				if (@FGoodsID <> '')
				begin
					if (Round(@GoodsQuantity, @Round) <> Round(@FGoodsQuantity, @Round))
						insert into #tbl_Prd_ProduceVariance_Total(FiscalYear, SerialNo, ProductID, ProdQuantity, FormulaNo,
																   GoodsID, SentQuantity, FormulaQuantity, BaseFiscalYear, BaseSerialNo, DocDate)
						values (@FiscalYear, @SerialNo, @ProductID, @ProdQuantity, @FormulaNo, @GoodsID, @GoodsQuantity, @FGoodsQuantity,
							    @BaseFiscalYear, @BaseSerialNo, @DocDate)
				end
				else
					insert into #tbl_Prd_ProduceVariance_Total(FiscalYear, SerialNo, ProductID, ProdQuantity, FormulaNo,
															   GoodsID, SentQuantity, FormulaQuantity, BaseFiscalYear, BaseSerialNo, DocDate)
					values (@FiscalYear, @SerialNo, @ProductID, @ProdQuantity, @FormulaNo, @GoodsID, @GoodsQuantity, 0,
							@BaseFiscalYear, @BaseSerialNo, @DocDate)
			end

			-- inv.tblStorageDocsDtl END --
			Fetch NEXT From cur_SD Into @GoodsID, @GoodsQuantity
		END

		Close cur_SD;
		Deallocate cur_SD; 

		------------------------------------
		Insert Into #tbl_Prd_ProduceVariance_DocsDtl(GoodsID, GoodsQuantity)
		select GoodsID,SUM(GoodsQuantity)  GoodsQuantity
		from #tbl_Temp
		where ProcessID=@ProcessID and ProcessNo=@ProcessNo and FiscalYear=@FiscalYear and SerialNo=@SerialNo
		GROUP BY ProcessID,ProcessNo,FiscalYear,SerialNo,FormulaNo,ProductID,GoodsID	

		--Select GoodsID, GoodsQuantity
		--From inv.tblStorageDocsDtl
		--Where ProcessID=@ProcessID And ProcessNo= @ProcessNo And FiscalYear=@FiscalYear And SerialNo=@SerialNo
		
		Declare	cur_FDA CURSOR For 
			select D.GoodsID, D.GoodsQuantity * @ProdQuantity / H.ProductCount, D.DocRowNo
			from prd.tblFormulasDtl D
					inner join prd.tblFormulasHdr H on H.ProductID=D.ProductID and H.SerialNo=D.SerialNo
			where D.ProductID=@ProductID and D.SerialNo=@FormulaNo
		Open  cur_FDA;

		Fetch NEXT From cur_FDA Into @FGoodsID, @FGoodsQuantity, @FDocRowNo
		
		While (@@Fetch_Status = 0)
		BEGIN		
			Select @Count=COUNT(*)
			From #tbl_Prd_ProduceVariance_DocsDtl
			Where GoodsID = @FGoodsID Or GoodsID In (
													 Select GoodsID
													 From prd.tblFormulasAtm
													 Where ProductID=@ProductID And
													       SerialNo=@FormulaNo  And
													       DocRowNo=@FDocRowNo
													 )
			if (@Count=0)
			begin
				insert into #tbl_Prd_ProduceVariance_Total(FiscalYear, SerialNo, ProductID, ProdQuantity, FormulaNo, GoodsID,
														   SentQuantity, FormulaQuantity, BaseFiscalYear, BaseSerialNo, DocDate)
				values (@FiscalYear, @SerialNo, @ProductID, @ProdQuantity, @FormulaNo, @FGoodsID, 0, @FGoodsQuantity,
						@BaseFiscalYear, @BaseSerialNo, @DocDate)
			end
			
			Fetch NEXT From cur_FDA Into @FGoodsID, @FGoodsQuantity, @FDocRowNo
		END		

		Close cur_FDA;
		Deallocate cur_FDA; 		
		------------------------------------
		
		delete from #tbl_Prd_ProduceVariance_DocsDtl
		
		-- #tbl_Prd_ProduceVariance_DocsHdr END --
		Fetch NEXT From cur_SH Into @ProcessID,@ProcessNo,@FiscalYear,@SerialNo,@ProductID,@FormulaNo,@ProdQuantity,@BaseFiscalYear, @BaseSerialNo, @DocDate
	END

	Close cur_SH;
	Deallocate cur_SH; 

	If (@SelectedGoods > 0)
		SET @StrWhereG = pub.funGetFilterString(@SessionNo, @ReportID, @SelectedGoods, 'T.GoodsID') 
	else
		set @StrWhereG = '(1 = 1)'
		
	if (@ProductID2 is not null) 
		SET @StrWhereG = @StrWhereG + ' AND (T.ProductID = ''' + LTrim(@ProductID2) + ''')'
		
	if (@GoodsID2 is not null)
		SET @StrWhereG = @StrWhereG + ' AND (T.GoodsID = ''' + LTrim(@GoodsID2) + ''')'		
	
	select T.*, [pub].[funGetGoodsName](T.GoodsID, 1) As GoodsName, 
		   [pub].[funGetGoodsName](T.ProductID, 1) As ProductName, 
		   [pub].[funGetGoodsUnitName] (T.GoodsID, 1) As UnitName, 
		   [pub].[funGetGoodsUnitName] (T.ProductID, 1) As ProductUnitName
		   , cast('' as varchar(20)) BatchNo
		   into #tbl_Prd_Produce_Total
	from #tbl_Prd_ProduceVariance_Total T
	where (1 = 0)

	set @StrSelect = 'insert into #tbl_Prd_Produce_Total
	select T.*, [pub].[funGetGoodsName](T.GoodsID, ' + LTrim(@LangID) + ') As GoodsName, 
		   [pub].[funGetGoodsName](T.ProductID, ' + LTrim(@LangID) + ') As ProductName, 
		   [pub].[funGetGoodsUnitName] (T.GoodsID, ' + LTrim(@LangID) + ') As UnitName, 
		   [pub].[funGetGoodsUnitName] (T.ProductID, ' + LTrim(@LangID) + ') As ProductUnitName
		   ,'''' BatchNo
	from #tbl_Prd_ProduceVariance_Total T
	where ' + @StrWhereG
	
	Print @StrSelect;
	Exec sp_executesql @StrSelect;	

	update #tbl_Prd_Produce_Total
		set BatchNo=H.BatchNo
	from #tbl_Prd_Produce_Total T
		inner join inv.tblStorageDocsHdr H On T.SerialNo=H.SerialNo and T.FiscalYear=H.FiscalYear and H.ProductID=T.ProductID
		inner join inv.tblStorageDocsDtl D on H.ProcessID = D.ProcessID and H.ProcessNo = D.ProcessNo and H.FiscalYear = D.FiscalYear and H.SerialNo = D.SerialNo
	where (H.ProcessID in (0, 70, 82)) 
	
	if @GroupByBatchNo='True'
		if @DontShowZeroOffset = 0
		begin
			select	ProductID,	FormulaNo,	GoodsID,	ProdQuantity,	SUm(SentQuantity) SentQuantity,	FormulaQuantity	,''	DocDate	,BatchNo,	GoodsName	,ProductName	,UnitName,	ProductUnitName
			from #tbl_Prd_Produce_Total
			WHERE (@BatchNo = '' OR BatchNo=@BatchNo)		 
			Group by ProductID,	FormulaNo,	GoodsID,	ProdQuantity,	FormulaQuantity	,BatchNo,	GoodsName	,ProductName	,UnitName,	ProductUnitName
			having Sum(SentQuantity )<>Sum(FormulaQuantity)
			order by BatchNo , ProductID,	GoodsID
		end
		else
		begin
			select	ProductID,	FormulaNo,	GoodsID,	ProdQuantity,	SUm(SentQuantity) SentQuantity,	FormulaQuantity	,''	DocDate	,BatchNo,	GoodsName	,ProductName	,UnitName,	ProductUnitName
			from #tbl_Prd_Produce_Total
			WHERE (@BatchNo = '' OR BatchNo=@BatchNo) 
			AND (SentQuantity-FormulaQuantity) <> 0
			Group by ProductID,	FormulaNo,	GoodsID,	ProdQuantity,	FormulaQuantity	,BatchNo,	GoodsName	,ProductName	,UnitName,	ProductUnitName
			having Sum(SentQuantity )<>Sum(FormulaQuantity)
			order by BatchNo , ProductID,	GoodsID
		end
	else
		if @DontShowZeroOffset = 0
		begin
			select * 
			from #tbl_Prd_Produce_Total
			where SentQuantity<>FormulaQuantity	
			Order By FiscalYear,SerialNo,	GoodsID
		end
		else
		begin
			select * 
			from #tbl_Prd_Produce_Total
			where SentQuantity<>FormulaQuantity
			AND (SentQuantity-FormulaQuantity) <> 0
			Order By FiscalYear,SerialNo,	GoodsID
		end
END	
GO
