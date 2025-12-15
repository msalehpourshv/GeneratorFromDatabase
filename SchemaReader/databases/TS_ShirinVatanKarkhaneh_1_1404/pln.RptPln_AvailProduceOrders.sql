USE TS_ShirinVatanKarkhaneh_1_1404
GO
SET ANSI_NULLS, QUOTED_IDENTIFIER ON
GO
-- =========== TS-QC:UPDATED ====================
-- Author		 : TakroSystem\Zia
-- Create date   : 1389/11/02
-- Viewed By	 : 
-- Last Modified : 
-- Last Modifier : 
-- Description   : سفارشات آماده تولید
-- =============================================
Create Procedure [pln].[RptPln_AvailProduceOrders] 
	@ProcSet	VarChar(20),
	@SortFields	VarChar(50) = Null,
	@RepOptions	VarChar(20) = '101',
	@RepInfo	NVarChar(100) = '1@1@1'
WITH ENCRYPTION
As
DECLARE @StrSelect	NVarChar(4000);
DECLARE @StrWhere	NVarChar(4000);
DECLARE @StrFrom	NVarChar(4000);

DECLARE	@LangID		Char(1);
DECLARE	@SessionNo	Int; 
DECLARE	@ReportID	Int;

declare	@ProcessID	Int;
declare	@ProcessNo	Int;
declare	@FiscalYear	Int;
declare	@SerialNo	Int;
declare @UseStores	bit;
declare @Unconfrmd	bit;
declare @ThisProc	bit;
begin
	SET NOCOUNT ON;

	-- init --------------------------------------------------------------------
	IF (@RepOptions	Is Null)	SET @RepOptions	= '000';

	set @ProcessID	= pub.funSplitString(@ProcSet, '@', 1);
	set @ProcessNo	= pub.funSplitString(@ProcSet, '@', 2);
	set @FiscalYear	= pub.funSplitString(@ProcSet, '@', 3);
	set @SerialNo	= pub.funSplitString(@ProcSet, '@', 4);

	set @LangID		= pub.funSplitString(@RepInfo, '@', 1);
	set @SessionNo	= pub.funSplitString(@RepInfo, '@', 2);
	set @ReportID	= pub.funSplitString(@RepInfo, '@', 3);

	set @UseStores	= Substring(@RepOptions, 1, 1);
	set @Unconfrmd	= Substring(@RepOptions, 2, 1);
	set @ThisProc	= Substring(@RepOptions, 3, 1);
	----------------------------------------------------------------------------
	-- where -------------------------------------------------------------------
	create table #tbl_Stock
	(
		GoodsID varchar(20) collate arabic_cs_as null,
		Balance float null
	);
	create table #tbl_Running
	(
		ProductID varchar(20) collate arabic_cs_as null,
		Quantity  float
	);
	create table #tbl_Finished
	(
		ProductID varchar(20) collate arabic_cs_as null,
		Quantity  float
	);
	----------------------------------------------------------------------------
	-- avail orders ------------------------------------------------------------
	select	AO.RowNo, AO.GoodsID, AO.GoodsQuantity, AO.StepNo, AO.FormulaNo
	into	#tbl_Avail
	from	pln.tblAvailProduceOrders AO  
				inner join  
				( 
					select ProcessID, ProcessNo, FiscalYear, SerialNo  
					from pln.tblProduceOrderHdr  
					where BaseProcessID = @ProcessID AND BaseProcessNo = @ProcessNo AND BaseFiscalYear = @FiscalYear AND BaseSerialNo = @SerialNo
					union all  
					select @ProcessID, @ProcessNo, @FiscalYear, @SerialNo
				) P on P.ProcessID = AO.ProcessID AND P.ProcessNo = AO.ProcessNo AND P.FiscalYear = AO.FiscalYear AND P.SerialNo = AO.SerialNo
	----------------------------------------------------------------------------
	-- running orders ----------------------------------------------------------
	set @StrWhere = '(H.TaskStateID in(2,3))'

	if (@Unconfrmd = 0)
		set @StrWhere = @StrWhere + ' and (H.TaskStateID > 1)'
	
	set @StrWhere = @StrWhere + ' and  BaseSerialNo=	' + str(@SerialNo)

	set @StrFrom = 'pln.tblTaskOrderHdr H'

	if (@ThisProc = 1) 
		set @StrFrom = @StrFrom + ' 
		inner join pln.tblItemRelations IR on (IR.ProcessID = H.ProcessID) and (IR.ProcessNo = H.ProcessNo) and (IR.FiscalYear = H.FiscalYear) and (IR.SerialNo = H.SerialNo) 
		inner join 
		(
			select ProcessID, ProcessNo, FiscalYear, SerialNo
			from pln.tblProduceOrderHdr 
			where (BaseProcessID = ' + LTrim(Str(@ProcessID)) + ') and (BaseProcessNo = ' + LTrim(Str(@ProcessNo)) + ') and (BaseFiscalYear = ' + LTrim(Str(@FiscalYear)) + ') and (BaseSerialNo = ' + LTrim(Str(@SerialNo)) + ')
			union all
			select ' + LTrim(Str(@ProcessID)) + ', ' + LTrim(Str(@ProcessNo)) + ', ' + LTrim(Str(@FiscalYear)) + ', ' + LTrim(Str(@SerialNo)) + '
		) P on (P.ProcessID = IR.BaseProcessID) AND (P.ProcessNo = IR.BaseProcessNo) AND (P.FiscalYear = IR.BaseFiscalYear) AND (P.SerialNo = IR.BaseSerialNo) '

	set @StrSelect = '
	insert into	#tbl_Running
	select	ProductID, isnull(sum(H.OrderCount), 0) as Quantity  
	from	' + @StrFrom  + '
	where	' + @StrWhere + ' 
	and ProductID in (select GoodsID from #tbl_Avail)
	group by ProductID ' 
	
	print @StrSelect;
	exec sp_executesql @StrSelect;
	----------------------------------------------------------------------------
	-- finished orders ---------------------------------------------------------
	set @StrWhere = '
	T.ProduceStepID = 
	(
		select Max(M.ProduceStepID) AS MaxProduceStepID
		from pln.tblProduceStepDtl M
		where M.SerialNo = T.ProduceStepSerialNo AND M.ProductID = T.ProductID
	)'
		set @StrWhere = @StrWhere + ' and  BaseSerialNo=	' + str(@SerialNo)

	set @StrFrom = 'pln.vwTaskOrderHD T'

	if (@ThisProc = 1) 
		set @StrFrom = @StrFrom + ' 
		inner join pln.tblItemRelations IR on (IR.ProcessID = T.ProcessID) and (IR.ProcessNo = T.ProcessNo) and (IR.FiscalYear = T.FiscalYear) and (IR.SerialNo = T.SerialNo) 
		inner join 
		(
			select ProcessID, ProcessNo, FiscalYear, SerialNo
			from pln.tblProduceOrderHdr 
			where (BaseProcessID = ' + LTrim(Str(@ProcessID)) + ') and (BaseProcessNo = ' + LTrim(Str(@ProcessNo)) + ') and (BaseFiscalYear = ' + LTrim(Str(@FiscalYear)) + ') and (BaseSerialNo = ' + LTrim(Str(@SerialNo)) + ')
			union all
			select ' + LTrim(Str(@ProcessID)) + ', ' + LTrim(Str(@ProcessNo)) + ', ' + LTrim(Str(@FiscalYear)) + ', ' + LTrim(Str(@SerialNo)) + '
		) P on (P.ProcessID = IR.BaseProcessID) AND (P.ProcessNo = IR.BaseProcessNo) AND (P.FiscalYear = IR.BaseFiscalYear) AND (P.SerialNo = IR.BaseSerialNo) '

	set @StrSelect = '
	insert into	#tbl_Finished
	select	T.ProductID, isnull(sum(T.AcceptableCount), 0) AS Quantity  
	from	' + @StrFrom  + '
	where	' + @StrWhere + ' 
	and ProductID in (select GoodsID from #tbl_Avail)
	group by T.ProductID ' 

	print @StrSelect;
	exec sp_executesql @StrSelect;
	----------------------------------------------------------------------------
	-- store balance -----------------------------------------------------------
	set @StrWhere = '
		D.GoodsID in 
		(
			select GoodsID
			from #tbl_Avail
		)';

	if (@UseStores = 1)
		set @StrWhere = @StrWhere + '
		and D.StoreID in 
		(
			select S.StoreID
			from pln.tblGoodsStores S
			where (S.StoreType = 2) and (S.GoodsID = D.GoodsID)
		)'

	set @StrSelect = '
		insert into #tbl_Stock
		select GoodsID, IsNull(Sum(D.GoodsQuantity * D.EnterKind), 0) Balance
		from inv.tblStorageDocsDtl D   
		where ' + @StrWhere + '
		group by GoodsID'

	print @StrSelect;
	exec sp_executesql @StrSelect;
	----------------------------------------------------------------------------
	--select *	from #tbl_Avail 
	--select *	from #tbl_Stock 
	--select *	from #tbl_Running 
	--select *	from #tbl_Finished 

	-- final -------------------------------------------------------------------
	select A.*, [pub].[funGetGoodsName]( ISNULL(A.GoodsID,'-'),@LangID) GoodsName, 
		isnull(B.Balance, 0) Balance,
		isnull(R.Quantity, 0) RunQuantity,
		isnull(F.Quantity, 0) FinQuantity
	from #tbl_Avail A
		left join #tbl_Stock B on B.GoodsID = A.GoodsID
		left join #tbl_Running R on R.ProductID = A.GoodsID
		left join #tbl_Finished F on F.ProductID = A.GoodsID
End
GO
