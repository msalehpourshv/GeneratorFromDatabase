USE TS_ShirinVatanKarkhaneh_1_1404
GO
SET ANSI_NULLS, QUOTED_IDENTIFIER ON
GO
-- =========== TS-QC:UPDATED ====================
-- Author		 : TakroSystem\Zia
-- Creation Date : 1390/06/07
-- Viewed By	 : 
-- Last Modified : 
-- Last Modifier : 
-- Description	 : لیست مواد رزرو شده سفارشات تولید
-- ==============================================
CREATE PROCEDURE [pln].[RptPln_ProduceOrder_Reserves]
	@ProcSetFr			VarChar(20) = Null,
	@ProcSetTo			VarChar(20) = Null,
	@DocDateFr			VarChar(10) = Null,
	@DocDateTo			VarChar(10) = Null,
	@ProduceStepList	varchar(20) = null,
	@SelectedProds		int = 0, 
	@SelectedGoods		int = 0, 
	@FormulaNo			int = 0,
	@SortFields			NVarChar(100) = Null,
	@RepOptions			VarChar(10) = '11111111', -- bit array options
	@RepInfo			NVarChar(100) = Null
WITH ENCRYPTION
AS 
---- Declarations ---------------
DECLARE @StrSelect		NVarChar(4000);
DECLARE @StrFrom		NVarChar(1000);
DECLARE @StrWhere		NVarChar(2000);
DECLARE @StrWhereF		NVarChar(2000);

DECLARE @ProductID		varchar(20);
DECLARE @Quantity		float;

DECLARE	@ProcessID		Int;
DECLARE	@ProcessNo		Int;
DECLARE	@FiscalYear		Int;
DECLARE	@SerialNo		Int;
DECLARE	@FiscalYearFr	Int;
DECLARE	@SerialNoFr		Int;
DECLARE	@FiscalYearTo	Int;
DECLARE	@SerialNoTo		Int;

DECLARE	@LangID			char(1);
DECLARE	@SessionNo		int; -- برای حالت کدهای انتخابی
DECLARE	@ReportID		int; -- برای حالت کدهای انتخابی
DECLARE	@UserID			int;

Begin --============== S T A R T  C O D E ===================================================

	SET NOCOUNT ON;

	-- Init -------------------------------------------------
	IF (@RepOptions Is Null)		SET @RepOptions = '11111111';
	IF (@RepInfo Is Null)			SET @RepInfo = '1@1@1';
	IF (@SelectedProds Is Null)		SET @SelectedProds = 0;
	IF (@SelectedGoods Is Null)		SET @SelectedGoods = 0;

	SET @ProcessID		= 600;
	SET @ProcessNo		= 0;
	SET @FiscalYearFr	= null;
	SET @SerialNoFr		= null;
	SET @FiscalYearTo	= null;
	SET @SerialNoTo		= null;

	IF (@ProcSetFr Is Not Null)
	Begin
		SET @ProcessID		= pub.funSplitString(@ProcSetFr, '@', 1);
		SET @ProcessNo		= pub.funSplitString(@ProcSetFr, '@', 2);
		SET @FiscalYearFr	= pub.funSplitString(@ProcSetFr, '@', 3);
		SET @SerialNoFr		= pub.funSplitString(@ProcSetFr, '@', 4);
	END

	IF (@ProcSetTo Is Not Null)
	Begin
		SET @ProcessID		= pub.funSplitString(@ProcSetTo, '@', 1);
		SET @ProcessNo		= pub.funSplitString(@ProcSetTo, '@', 2);
		SET @FiscalYearTo	= pub.funSplitString(@ProcSetTo, '@', 3);
		SET @SerialNoTo		= pub.funSplitString(@ProcSetTo, '@', 4);
	END

	SET @LangID		= pub.funSplitString(@RepInfo, '@', 1);
	SET @SessionNo	= pub.funSplitString(@RepInfo, '@', 2);
	SET @ReportID	= pub.funSplitString(@RepInfo, '@', 3);
	SET @UserID		= pub.funSplitString(@RepInfo, '@', 4);

		DECLARE @UnitPart TINYINT
	SET @UnitPart  = 1

	SELECT @UnitPart = SettingValue from pub.tblSettings where SettingKey = 'UnitPart'

	IF @UnitPart IS NULL or @UnitPart = 0
		SET @UnitPart = 1

	DECLARE @str_Goods  tinyint,
			@str_GoodsSum tinyint

	select @str_Goods = IsNull(SUM (Layer1+Layer2+Layer3+Layer4+Layer5+Layer6+Layer7+Layer8+Layer9),0)
	from pub.tblCodeLayer 
	where TableName='inv.tblGoods' AND PartNumber<@UnitPart

	select @str_GoodsSum = Layer1+Layer2+Layer3+Layer4+Layer5+Layer6+Layer7+Layer8+Layer9
	from pub.tblCodeLayer 
	where TableName= 'inv.tblGoods' AND PartNumber=@UnitPart

	---------------------------------------------------------

	-- Where Clause -----------------------------------------
	set @StrWhereF = '(D.GoodsID not in (select ProductID from prd.tblFormulasHdr))' 

	if (@FormulaNo <> 0) 
		set @StrWhereF = @StrWhereF + ' and (H.SerialNo = ' + Str(@FormulaNo) + ')'
	else
		set @StrWhereF = @StrWhereF + ' and (H.IsDefault = 1)' 

	Set @StrWhere = '(D.ProcessID=600) and (H.ReserveGoods=1)'

	IF (@ProcSetFr Is Not Null)
		SET @StrWhere = @StrWhere + ' AND (D.FiscalYear > ' + LTrim(Str(@FiscalYearFr)) + ' OR (D.FiscalYear = ' + LTrim(Str(@FiscalYearFr)) + ' AND D.SerialNo >= ' + LTrim(Str(@SerialNoFr)) + '))' 
	IF (@ProcSetTo Is Not Null)
		SET @StrWhere = @StrWhere + ' AND (D.FiscalYear < ' + LTrim(Str(@FiscalYearTo)) + ' OR (D.FiscalYear = ' + LTrim(Str(@FiscalYearTo)) + ' AND D.SerialNo <= ' + LTrim(Str(@SerialNoTo)) + '))' 
	If (@ProcessNo > 0)
		SET @StrWhere = @StrWhere + ' AND (D.ProcessNo = ' + LTrim(Str(@ProcessNo)) + ')' 

	IF (@DocDateFr Is Not Null) 
		SET @StrWhere = @StrWhere + ' AND (H.DocDate >= ''' + @DocDateFr + ''')'
	IF (@DocDateTo Is Not Null) 
		SET @StrWhere = @StrWhere + ' AND (H.DocDate <= ''' + @DocDateTo + ''')'

	if (@ProduceStepList is not null)
		set @StrWhere = @StrWhere + ' AND (H.ProduceStepID in (' + @ProduceStepList + '))'

	if (@SelectedProds > 0)
		set @StrWhere = @StrWhere + ' AND ' + pub.funGetFilterString(@SessionNo, @ReportID, @SelectedProds, 'A.GoodsID')
	---------------------------------------------------------
	-- SELECT Clause ----------------------------------------
	create table #tbl_RptPln_ProduceOrder_Reserves_Avail
	(	
		ProcessID	int not null,
		ProcessNo	int not null,
		FiscalYear	int not null,
		SerialNo	int not null,
		ProductID	varchar(20) collate arabic_cs_as not null,
		Quantity	float not null
	);

	create table #tbl_RptPln_ProduceOrder_Reserves_Result
	(	
		ProcessID	int not null,
		ProcessNo	int not null,
		FiscalYear	int not null,
		SerialNo	int not null,
		GoodsID		varchar(20) collate arabic_cs_as not null,
		Quantity	float not null
	);

	-- enlist produce orders 
	SET @StrSelect = '
	insert into #tbl_RptPln_ProduceOrder_Reserves_Avail
	select	A.ProcessID, A.ProcessNo, A.FiscalYear, A.SerialNo, A.GoodsID, sum(A.GoodsQuantity) as Quantity
	from	pln.tblAvailProduceOrders A
				inner join pln.tblProduceOrderHdr H on H.ProcessID = A.ProcessID and H.ProcessNo = A.ProcessNo and H.FiscalYear = A.FiscalYear and H.SerialNo = A.SerialNo
				inner join pln.tblProduceOrderDtl D on D.ProcessID = A.ProcessID and D.ProcessNo = A.ProcessNo and D.FiscalYear = A.FiscalYear and D.SerialNo = A.SerialNo
	where ' + @StrWhere + '
	group by A.ProcessID, A.ProcessNo, A.FiscalYear, A.SerialNo, A.GoodsID '

	Print @StrSelect;
	Exec sp_executesql @StrSelect;

	-- enlist avail produce orders
	declare cursor_PO cursor for
		select distinct ProcessID, ProcessNo, FiscalYear, SerialNo
		from   #tbl_RptPln_ProduceOrder_Reserves_Avail

	declare cursor_PR cursor for
		select distinct ProductID, Quantity
		from   prd.tblProductSlc
		where (UserID = @UserID) and (ReportID = @ReportID) and (ObjectID = 1)

	open  cursor_PO
	fetch next from cursor_PO into @ProcessID, @ProcessNo, @FiscalYear, @SerialNo

	-- scroll with produce orders
	while (@@FETCH_STATUS = 0)
	begin
		-- fill products of current ProcSet into SLC
		delete from prd.tblProductSlc
		where (UserID = @UserID) and (ReportID = @ReportID) and (ObjectID = 1)

		insert into prd.tblProductSlc(ProductID, UserID, ReportID, ObjectID, Quantity)
		select A.ProductID, @UserID, @ReportID, 1, A.Quantity
		from #tbl_RptPln_ProduceOrder_Reserves_Avail A

		-- scroll with SLC products & find there goods
		open  cursor_PR
		fetch next from cursor_PR into @ProductID, @Quantity

		while (@@FETCH_STATUS = 0)
		begin
			set @StrSelect = '
				insert into #tbl_RptPln_ProduceOrder_Reserves_Result(ProcessID, ProcessNo, FiscalYear, SerialNo, GoodsID, Quantity)
				select	' + str(@ProcessID) + ',' + str(@ProcessNo) + ',' + str(@FiscalYear) + ',' + str(@SerialNo) + ',' + 'D.GoodsID, ((' + LTrim(Str(@Quantity)) + ' / H.ProductCount) * D.GoodsQuantity) 
				from	prd.tblFormulasDtl D
							inner join prd.tblFormulasHdr H on D.SerialNo = H.SerialNo and D.ProductID = H.ProductID
				where  (H.ProductID = ''' + @ProductID + ''') and ' + @StrWhereF
			
			print @StrSelect;
			exec sp_executesql @StrSelect;

			fetch next from cursor_PR into @ProductID, @Quantity
		end

		close cursor_PR

		fetch next from cursor_PO into @ProcessID, @ProcessNo, @FiscalYear, @SerialNo
	end

	deallocate  cursor_PR

	close cursor_PO
	deallocate  cursor_PO

	------------------------------------------------------------
	set @StrWhere = '(1=1)'

	if (@SelectedGoods > 0)
		set @StrWhere = @StrWhere + ' AND ' + pub.funGetFilterString(@SessionNo, @ReportID, @SelectedGoods, 'R.GoodsID')

	SET @StrSelect = '
	SELECT	D.*, [pub].[funGetGoodsName](D.GoodsID,' + @LangID + ') GoodsName, U.UnitName, S.ProduceStepName, H.Title, H.DocDate
	FROM	
	(
		select R.GoodsID, R.ProcessID, R.ProcessNo, R.FiscalYear, R.SerialNo, Sum(Quantity) as Quantity
		from	#tbl_RptPln_ProduceOrder_Reserves_Result R
		where ' + @StrWhere + '
		group by R.GoodsID, R.ProcessID, R.ProcessNo, R.FiscalYear, R.SerialNo
	) D
		inner join pln.tblProduceOrderHdr H on H.ProcessID = D.ProcessID and H.ProcessNo = D.ProcessNo and H.FiscalYear = D.FiscalYear and H.SerialNo = D.SerialNo
		left join inv.tblGoods GH on GH.GoodsID =  SUBSTRING(D.GoodsID,' + ltrim(rtrim(STR(@str_Goods+1))) + ',' + ltrim(rtrim(STR( @str_GoodsSum))) + ') AND GH.PartNumber=' + ltrim(rtrim(STR(@UnitPart)))+ '
		left join inv.tblUnitsDtl U on U.UnitID = GH.UnitID 
		left join pln.tblProduceOrderStepsDtl S on S.ProduceStepID = H.ProduceStepID '
	------------------------------------------------------------

	-- SORT Clause ---------------------------------------------
	If (@SortFields Is Not Null)
		Set @StrSelect = @StrSelect + '
	 ORDER BY ' + @SortFields
	------------------------------------------------------------

	-- RUN -----------------------------------------------------
	Print @StrSelect;
	Exec sp_executesql @StrSelect;
	------------------------------------------------------------
End
--go 
--exec [pln].[RptPln_ProduceOrder_Reserves] '600@1@90@2','600@1@90@2', @SortFields = 'GoodsID,SerialNo'
GO
