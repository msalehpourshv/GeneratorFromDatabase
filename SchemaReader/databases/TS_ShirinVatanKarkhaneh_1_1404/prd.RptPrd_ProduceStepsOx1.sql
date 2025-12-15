USE TS_ShirinVatanKarkhaneh_1_1404
GO
SET ANSI_NULLS, QUOTED_IDENTIFIER ON
GO
-- =========== TS-QC:UPDATED ====================
-- Author		 : TakroSystem\Zia
-- Create date   : 1393/01/06
-- Viewed By	 : 
-- Last Modified : 
-- Last Modifier : TakroSystem\Zia
-- Description   : 
-- ==============================================
CREATE PROCEDURE [prd].[RptPrd_ProduceStepsOx1]
	@GoodsCodeMask1	nvarchar(20) = null,
	@GoodsCodeMask2	nvarchar(20) = null,
	@GoodsCodeMask3	nvarchar(20) = null,
	@GoodsCodeMask4	nvarchar(20) = null,
	@GoodsCodeMask5	nvarchar(20) = null,
	@SelectedProdsP	Int = 0,
	@SelectedGroupP	Int = 0,
	@SelectedStoreP	Int = 0,
	@SelectedStore1	Int = 0,
	@SelectedStore2	Int = 0,
	@SelectedStore3	Int = 0,
	@SelectedStore4	Int = 0,
	@SelectedStore5	Int = 0,
	@SelectedGoods1	Int = 0,
	@SelectedGoods2	Int = 0,
	@SelectedGoods3	Int = 0,
	@SelectedGoods4	Int = 0,
	@SelectedGoods5	Int = 0,
	@SelectedAcnt11	Int = 0,
	@SelectedAcnt12	Int = 0,
	@SelectedAcnt13	Int = 0,
	@SelectedAcnt21	Int = 0,
	@SelectedAcnt22	Int = 0,
	@SelectedAcnt23	Int = 0,
	@SelectedAcnt31	Int = 0,
	@SelectedAcnt32	Int = 0,
	@SelectedAcnt33	Int = 0,
	@SelectedAcnt41	Int = 0,
	@SelectedAcnt42	Int = 0,
	@SelectedAcnt43	Int = 0,
	@SelectedAcnt51	Int = 0,
	@SelectedAcnt52	Int = 0,
	@SelectedAcnt53	Int = 0,
	@DocDateTo		char(10) = Null,
	@SetDiffFr		float = Null,
	@SetDiffTo		float = Null,
	@OrdDiffFr		float = Null,
	@OrdDiffTo		float = Null,
	@RepOptions		varchar(10) = '1',  -- bit array options
	@RepInfo		nvarchar(100) = '1@1@1',
	@ExtraParams	nvarchar(200) = ''
WITH ENCRYPTION
AS
DECLARE @StrSelect	NVarChar(max)
DECLARE @StrFrom	NVarChar(max)
DECLARE @StrWhere	NVarChar(max)
DECLARE @StrWhereG	NVarChar(max)

DECLARE @StrWhere1	NVarChar(max)
DECLARE @StrWhere2	NVarChar(max)
DECLARE @StrWhere3	NVarChar(max)
DECLARE @StrWhere4	NVarChar(max)
DECLARE @StrWhere5	NVarChar(max)

DECLARE @StrWhereS	NVarChar(max)

DECLARE @StrWhereA1	NVarChar(max)
DECLARE @StrWhereA2	NVarChar(max)
DECLARE @StrWhereA3	NVarChar(max)
DECLARE @StrWhereA4	NVarChar(max)
DECLARE @StrWhereA5	NVarChar(max)

DECLARE	@LangID		Char(1);
DECLARE	@SessionNo	Int; -- برای حالت کدهای انتخابی
DECLARE	@ReportID	Int; -- برای حالت کدهای انتخابی

BEGIN

	SET NOCOUNT ON;

	-- init ------------------------------------------------------------
	if (@RepInfo		Is Null)	set @RepInfo = '1@1@1';
	if (@RepOptions		Is Null)	set @RepOptions = '';
	if (@SelectedProdsP	Is Null)	set @SelectedProdsP = 0;
	if (@SelectedGoods1	Is Null)	set @SelectedGoods1 = 0;
	if (@SelectedGoods2	Is Null)	set @SelectedGoods2 = 0;
	if (@SelectedGoods3	Is Null)	set @SelectedGoods3 = 0;
	if (@SelectedGoods4	Is Null)	set @SelectedGoods4 = 0;
	if (@SelectedGoods5	Is Null)	set @SelectedGoods5 = 0;
	if (@SelectedStore1	Is Null)	set @SelectedStore1 = 0;
	if (@SelectedStore2	Is Null)	set @SelectedStore2 = 0;
	if (@SelectedStore3	Is Null)	set @SelectedStore3 = 0;
	if (@SelectedStore4	Is Null)	set @SelectedStore4 = 0;
	if (@SelectedStore5	Is Null)	set @SelectedStore5 = 0;
	IF (@SelectedAcnt11	Is Null)	SET @SelectedAcnt11 = 0;
	IF (@SelectedAcnt21	Is Null)	SET @SelectedAcnt21 = 0;
	IF (@SelectedAcnt31	Is Null)	SET @SelectedAcnt31 = 0;
	IF (@SelectedAcnt41	Is Null)	SET @SelectedAcnt41 = 0;
	IF (@SelectedAcnt51	Is Null)	SET @SelectedAcnt51 = 0;
	IF (@SelectedAcnt12	Is Null)	SET @SelectedAcnt12 = 0;
	IF (@SelectedAcnt22	Is Null)	SET @SelectedAcnt22 = 0;
	IF (@SelectedAcnt32	Is Null)	SET @SelectedAcnt32 = 0;
	IF (@SelectedAcnt42	Is Null)	SET @SelectedAcnt42 = 0;
	IF (@SelectedAcnt52	Is Null)	SET @SelectedAcnt52 = 0;
	IF (@SelectedAcnt13	Is Null)	SET @SelectedAcnt13 = 0;
	IF (@SelectedAcnt23	Is Null)	SET @SelectedAcnt23 = 0;
	IF (@SelectedAcnt33	Is Null)	SET @SelectedAcnt33 = 0;
	IF (@SelectedAcnt43	Is Null)	SET @SelectedAcnt43 = 0;
	IF (@SelectedAcnt53	Is Null)	SET @SelectedAcnt53 = 0;
	if (@GoodsCodeMask1	= '')	set @GoodsCodeMask1 = null;
	if (@GoodsCodeMask2	= '')	set @GoodsCodeMask2 = null;
	if (@GoodsCodeMask3	= '')	set @GoodsCodeMask3 = null;
	if (@GoodsCodeMask4	= '')	set @GoodsCodeMask4 = null;
	if (@GoodsCodeMask5	= '')	set @GoodsCodeMask5 = null;

	set @LangID		= pub.funSplitString(@RepInfo, '@', 1);
	set @SessionNo	= pub.funSplitString(@RepInfo, '@', 2);
	set @ReportID	= pub.funSplitString(@RepInfo, '@', 3);
	---------------------------------------------------------------------------
	-- where section ----------------------------------------------------------
	set @StrWhere = '(1=1)';

	if (@DocDateTo is null) or (@DocDateTo = '')
		set @DocDateTo = '9999/99/99'

	if (@SelectedProdsP > 0)
		set @StrWhere = @StrWhere + ' AND ' + pub.funGetFilterString(@SessionNo, @ReportID, @SelectedProdsP, 'P.GoodsID') 

	if (@SelectedGroupP > 0)
		set @StrWhere = @StrWhere + ' AND ' + pub.funGetFilterString(@SessionNo, @ReportID, @SelectedGroupP, 'G.GoodsGroupID') 

	---------------------------------------------------------------------------
	create table #tbl_Products
	(
		ProductID varchar(20) collate Arabic_CS_AS null
	);
	create table #tbl_InProdFlow
	(
		ProductID	varchar(20) collate Arabic_CS_AS null,
		ProductQty	float,
		AcntCode	varchar(20) collate Arabic_CS_AS null
	);
	create table #tbl_Goods1
	(
		ProductID	varchar(20) collate Arabic_CS_AS null,
		GoodsID	varchar(20) collate Arabic_CS_AS null
	);
	create table #tbl_Goods2
	(
		ProductID	varchar(20) collate Arabic_CS_AS null,
		GoodsID	varchar(20) collate Arabic_CS_AS null
	);
	create table #tbl_Goods3
	(
		ProductID	varchar(20) collate Arabic_CS_AS null,
		GoodsID	varchar(20) collate Arabic_CS_AS null
	);
	create table #tbl_Goods4
	(
		ProductID	varchar(20) collate Arabic_CS_AS null,
		GoodsID	varchar(20) collate Arabic_CS_AS null
	);
	create table #tbl_Goods5
	(
		ProductID	varchar(20) collate Arabic_CS_AS null,
		GoodsID	varchar(20) collate Arabic_CS_AS null
	);

	create table #tbl_Orders
	(
		GoodsID		varchar(20) collate Arabic_CS_AS null,
		OrderQty	float
	);
	create table #tbl_Result
	(
		ProductID	varchar(20) collate Arabic_CS_AS null,
		ProductQty	float,
		GoodsQty1	float,
		GoodsQty2	float,
		GoodsQty3	float,
		GoodsQty4	float,
		GoodsQty5	float,
		InFlowQty1	float,
		InFlowQty2	float,
		InFlowQty3	float,
		InFlowQty4	float,
		InFlowQty5	float
	);
	-- select section ---------------------------------------------------------
	
	insert #tbl_Orders(GoodsID, OrderQty)
	SELECT	GoodsID, Sum(GoodsQuantity-CancelQuantity) - Sum(SoldQuantity-SoldRetQuantity) 
	FROM
	(
		SELECT	D.GoodsID, (D.GoodsQuantity) GoodsQuantity,
				isnull((
					SELECT	Sum(C.GoodsQuantity)
					FROM	sal.tblSaleOrderDtl C
					WHERE	(C.BaseProcessID=D.ProcessID)
						AND (C.BaseProcessNo=D.ProcessNo)
						AND (C.BaseFiscalYear=D.FiscalYear)
						AND (C.BaseSerialNo=D.SerialNo)
						AND (C.BaseDocRowNo=D.DocRowNo)
						AND (C.ProcessID=185)
				),0) CancelQuantity,
				isnull((
					SELECT	sum(GoodsQuantity) 
					FROM	inv.tblStorageDocsDtl SD
					WHERE	(SD.ProcessID=90)
						AND SD.BaseProcessID=D.ProcessID 
						AND SD.BaseProcessNo=D.ProcessNo 
						AND SD.BaseFiscalYear=D.FiscalYear 
						AND SD.BaseSerialNo=D.SerialNo 
						AND SD.BaseDocRowNo=D.DocRowNo
				),0) SoldQuantity, 0 SoldRetQuantity
		FROM    sal.tblSaleOrderDtl AS D
					INNER JOIN sal.tblSaleOrderHdr H ON H.ProcessID = D.ProcessID AND H.ProcessNo = D.ProcessNo AND H.FiscalYear = D.FiscalYear AND H.SerialNo = D.SerialNo
		WHERE   (D.ProcessID=180)
	) T  
	where (GoodsQuantity-CancelQuantity)-(SoldQuantity-SoldRetQuantity) > 0
	group by GoodsID

	-- enlist products
	if (@SelectedGroupP > 0) 
		set @StrSelect = '
		insert	into #tbl_Products(ProductID)
		select	distinct P.GoodsID
		from	inv.tblGoods P
					left join inv.tblGoodsGroupsGoodsListDtl G on P.GoodsID = G.GoodsID
		where ' + @StrWhere
	else
		set @StrSelect = '
		insert	into #tbl_Products(ProductID)
		select	distinct P.GoodsID
		from	inv.tblGoods P
		where ' + @StrWhere

	print @StrSelect;
	exec sp_executesql @StrSelect;
	
	------------------------------------------
	
	if (@SelectedGoods1 > 0) 
		set @StrWhere1 =  pub.funGetFilterString(@SessionNo, @ReportID, @SelectedGoods1, 'GoodsID')
	else
		set @StrWhere1 = '(1=1)'

	if (@SelectedGoods2 > 0) 
		set @StrWhere2 =  pub.funGetFilterString(@SessionNo, @ReportID, @SelectedGoods2, 'GoodsID')
	else
		set @StrWhere2 = '(1=1)'

	if (@SelectedGoods3 > 0) 
		set @StrWhere3 =  pub.funGetFilterString(@SessionNo, @ReportID, @SelectedGoods3, 'GoodsID')
	else
		set @StrWhere3 = '(1=1)'

	if (@SelectedGoods4 > 0) 
		set @StrWhere4 =  pub.funGetFilterString(@SessionNo, @ReportID, @SelectedGoods4, 'GoodsID')
	else
		set @StrWhere4 = '(1=1)'

	if (@SelectedGoods5 > 0) 
		set @StrWhere5 =  pub.funGetFilterString(@SessionNo, @ReportID, @SelectedGoods5, 'GoodsID')
	else
		set @StrWhere5 = '(1=1)'

	if (@GoodsCodeMask1 is not null) 
		set @StrWhere1 = @StrWhere1 + ' and (left(GoodsID, ' + LTrim(Str(Len(@GoodsCodeMask1))) + ')= ''' + @GoodsCodeMask1 + ''')'
	if (@GoodsCodeMask2 is not null) 
		set @StrWhere2 = @StrWhere2 + ' and (left(GoodsID, ' + LTrim(Str(Len(@GoodsCodeMask2))) + ')= ''' + @GoodsCodeMask2 + ''')'
	if (@GoodsCodeMask3 is not null) 
		set @StrWhere3 = @StrWhere3 + ' and (left(GoodsID, ' + LTrim(Str(Len(@GoodsCodeMask3))) + ')= ''' + @GoodsCodeMask3 + ''')'
	if (@GoodsCodeMask4 is not null) 
		set @StrWhere4 = @StrWhere4 + ' and (left(GoodsID, ' + LTrim(Str(Len(@GoodsCodeMask4))) + ')= ''' + @GoodsCodeMask4 + ''')'
	if (@GoodsCodeMask5 is not null) 
		set @StrWhere5 = @StrWhere5 + ' and (left(GoodsID, ' + LTrim(Str(Len(@GoodsCodeMask5))) + ')= ''' + @GoodsCodeMask5 + ''')'
	
	set @StrSelect = '
	insert into #tbl_Goods1(ProductID, GoodsID)
	select distinct P.ProductID, G.GoodsID
	from #tbl_Products P, inv.tblGoods G
	where ' + @StrWhere1 + ' 
		and substring(G.GoodsID, 3, len(P.ProductID) - 2) = substring(P.ProductID, 3, len(P.ProductID) - 2)

	insert into #tbl_Goods2(ProductID, GoodsID)
	select distinct P.ProductID, G.GoodsID
	from #tbl_Products P, inv.tblGoods G
	where ' + @StrWhere2 + ' 
		and substring(G.GoodsID, 3, len(P.ProductID) - 2) = substring(P.ProductID, 3, len(P.ProductID) - 2)

	insert into #tbl_Goods3(ProductID, GoodsID)
	select distinct P.ProductID, G.GoodsID
	from #tbl_Products P, inv.tblGoods G
	where ' + @StrWhere3 + ' 
		and substring(G.GoodsID, 3, len(P.ProductID) - 2) = substring(P.ProductID, 3, len(P.ProductID) - 2)

	insert into #tbl_Goods4(ProductID, GoodsID)
	select distinct P.ProductID, G.GoodsID
	from #tbl_Products P, inv.tblGoods G
	where ' + @StrWhere4 + ' 
		and substring(G.GoodsID, 3, len(P.ProductID) - 2) = substring(P.ProductID, 3, len(P.ProductID) - 2)

	insert into #tbl_Goods5(ProductID, GoodsID)
	select distinct P.ProductID, G.GoodsID
	from #tbl_Products P, inv.tblGoods G
	where ' + @StrWhere5 + ' 
		and substring(G.GoodsID, 3, len(P.ProductID) - 2) = substring(P.ProductID, 3, len(P.ProductID) - 2)'

	print @StrSelect;
	exec sp_executesql @StrSelect;

	--------------------------------------------------------------
	set @StrWhere = '(D.FiscalYear=' + LTrim(RIGHT(db_name(), 4)) + ') and (D.DocDate<=''' + @DocDateTo + ''')'
	set @StrWhere1 = @StrWhere
	set @StrWhere2 = @StrWhere
	set @StrWhere3 = @StrWhere
	set @StrWhere4 = @StrWhere
	set @StrWhere5 = @StrWhere

	if (@SelectedStoreP > 0)
		set @StrWhere = @StrWhere + ' AND ' + pub.funGetFilterString(@SessionNo, @ReportID, @SelectedStoreP, 'D.StoreID') 
		
	if (@SelectedStore1 > 0)
		set @StrWhere1 = @StrWhere1 + ' AND ' + pub.funGetFilterString(@SessionNo, @ReportID, @SelectedStore1, 'D.StoreID') 
	if (@SelectedStore2 > 0)
		set @StrWhere2 = @StrWhere2 + ' AND ' + pub.funGetFilterString(@SessionNo, @ReportID, @SelectedStore2, 'D.StoreID') 
	if (@SelectedStore3 > 0)
		set @StrWhere3 = @StrWhere3 + ' AND ' + pub.funGetFilterString(@SessionNo, @ReportID, @SelectedStore3, 'D.StoreID') 
	if (@SelectedStore4 > 0)
		set @StrWhere4 = @StrWhere4 + ' AND ' + pub.funGetFilterString(@SessionNo, @ReportID, @SelectedStore4, 'D.StoreID') 
	if (@SelectedStore5 > 0)
		set @StrWhere5 = @StrWhere5 + ' AND ' + pub.funGetFilterString(@SessionNo, @ReportID, @SelectedStore5, 'D.StoreID') 

	set @StrSelect = '
	insert into #tbl_Result(ProductID, ProductQty, GoodsQty1, GoodsQty2, GoodsQty3, GoodsQty4, GoodsQty5, InFlowQty1, InFlowQty2, InFlowQty3, InFlowQty4, InFlowQty5)
	select ProductID, isnull(sum(GoodsQuantity * EnterKind), 0), 0, 0, 0, 0, 0, 0, 0, 0, 0, 0
	from #tbl_Products P
			inner join inv.tblStorageDocsDtl D on P.ProductID = D.GoodsID
	where ' + @StrWhere + '
	group by ProductID'
	
	print @StrSelect;
	exec sp_executesql @StrSelect;
	
	set @StrSelect = '
	insert into #tbl_Result(ProductID, ProductQty, GoodsQty1, GoodsQty2, GoodsQty3, GoodsQty4, GoodsQty5, InFlowQty1, InFlowQty2, InFlowQty3, InFlowQty4, InFlowQty5)
	select ProductID, 0, isnull(sum(GoodsQuantity * EnterKind), 0), 0, 0, 0, 0, 0, 0, 0, 0, 0
	from #tbl_Goods1 G
			inner join inv.tblStorageDocsDtl D on G.GoodsID = D.GoodsID
	where ' + @StrWhere1 + '
	group by ProductID'

	print @StrSelect;
	exec sp_executesql @StrSelect;

	set @StrSelect = '
	insert into #tbl_Result(ProductID, ProductQty, GoodsQty1, GoodsQty2, GoodsQty3, GoodsQty4, GoodsQty5, InFlowQty1, InFlowQty2, InFlowQty3, InFlowQty4, InFlowQty5)
	select ProductID, 0, 0, isnull(sum(GoodsQuantity * EnterKind), 0), 0, 0, 0, 0, 0, 0, 0, 0
	from #tbl_Goods2 G
			inner join inv.tblStorageDocsDtl D on G.GoodsID = D.GoodsID
	where ' + @StrWhere2 + '
	group by ProductID'

	print @StrSelect;
	exec sp_executesql @StrSelect;

	set @StrSelect = '
	insert into #tbl_Result(ProductID, ProductQty, GoodsQty1, GoodsQty2, GoodsQty3, GoodsQty4, GoodsQty5, InFlowQty1, InFlowQty2, InFlowQty3, InFlowQty4, InFlowQty5)
	select ProductID, 0, 0, 0, isnull(sum(GoodsQuantity * EnterKind), 0), 0, 0, 0, 0, 0, 0, 0
	from #tbl_Goods3 G
			inner join inv.tblStorageDocsDtl D on G.GoodsID = D.GoodsID
	where ' + @StrWhere3 + '
	group by ProductID'

	print @StrSelect;
	exec sp_executesql @StrSelect;

	set @StrSelect = '
	insert into #tbl_Result(ProductID, ProductQty, GoodsQty1, GoodsQty2, GoodsQty3, GoodsQty4, GoodsQty5, InFlowQty1, InFlowQty2, InFlowQty3, InFlowQty4, InFlowQty5)
	select ProductID, 0, 0, 0, 0, isnull(sum(GoodsQuantity * EnterKind), 0), 0, 0, 0, 0, 0, 0
	from #tbl_Goods4 G
			inner join inv.tblStorageDocsDtl D on G.GoodsID = D.GoodsID
	where ' + @StrWhere4 + '
	group by ProductID'

	print @StrSelect;
	exec sp_executesql @StrSelect;

	set @StrSelect = '
	insert into #tbl_Result(ProductID, ProductQty, GoodsQty1, GoodsQty2, GoodsQty3, GoodsQty4, GoodsQty5, InFlowQty1, InFlowQty2, InFlowQty3, InFlowQty4, InFlowQty5)
	select ProductID, 0, 0, 0, 0, 0, isnull(sum(GoodsQuantity * EnterKind), 0), 0, 0, 0, 0, 0
	from #tbl_Goods5 G
			inner join inv.tblStorageDocsDtl D on G.GoodsID = D.GoodsID
	where ' + @StrWhere5 + '
	group by ProductID'

	print @StrSelect;
	exec sp_executesql @StrSelect;
	-----------------------------------
	-- on produce flow products
	set @StrWhere = '(1=1)'
	set @StrWhereA1 = @StrWhere
	set @StrWhereA2 = @StrWhere
	set @StrWhereA3 = @StrWhere
	set @StrWhereA4 = @StrWhere
	set @StrWhereA5 = @StrWhere
	
	IF (@SelectedAcnt11 > 0)
		SET @StrWhereA1 = @StrWhereA1 + ' AND ' + pub.funGetFilterString(@SessionNo, @ReportID, @SelectedAcnt11, 'F.AcntCode')
	IF (@SelectedAcnt12 > 0)
		SET @StrWhereA1 = @StrWhereA1 + ' AND ' + pub.funGetFilterString(@SessionNo, @ReportID, @SelectedAcnt12, 'F.AcntCode')
	IF (@SelectedAcnt13 > 0)
		SET @StrWhereA1 = @StrWhereA1 + ' AND ' + pub.funGetFilterString(@SessionNo, @ReportID, @SelectedAcnt13, 'F.AcntCode')

	IF (@SelectedAcnt21 > 0)
		SET @StrWhereA2 = @StrWhereA2 + ' AND ' + pub.funGetFilterString(@SessionNo, @ReportID, @SelectedAcnt21, 'F.AcntCode')
	IF (@SelectedAcnt22 > 0)
		SET @StrWhereA2 = @StrWhereA2 + ' AND ' + pub.funGetFilterString(@SessionNo, @ReportID, @SelectedAcnt22, 'F.AcntCode')
	IF (@SelectedAcnt23 > 0)
		SET @StrWhereA2 = @StrWhereA2 + ' AND ' + pub.funGetFilterString(@SessionNo, @ReportID, @SelectedAcnt23, 'F.AcntCode')

	IF (@SelectedAcnt31 > 0)
		SET @StrWhereA3 = @StrWhereA3 + ' AND ' + pub.funGetFilterString(@SessionNo, @ReportID, @SelectedAcnt31, 'F.AcntCode')
	IF (@SelectedAcnt32 > 0)
		SET @StrWhereA3 = @StrWhereA3 + ' AND ' + pub.funGetFilterString(@SessionNo, @ReportID, @SelectedAcnt32, 'F.AcntCode')
	IF (@SelectedAcnt33 > 0)
		SET @StrWhereA3 = @StrWhereA3 + ' AND ' + pub.funGetFilterString(@SessionNo, @ReportID, @SelectedAcnt33, 'F.AcntCode')

	IF (@SelectedAcnt41 > 0)
		SET @StrWhereA4 = @StrWhereA4 + ' AND ' + pub.funGetFilterString(@SessionNo, @ReportID, @SelectedAcnt41, 'F.AcntCode')
	IF (@SelectedAcnt42 > 0)
		SET @StrWhereA4 = @StrWhereA4 + ' AND ' + pub.funGetFilterString(@SessionNo, @ReportID, @SelectedAcnt42, 'F.AcntCode')
	IF (@SelectedAcnt43 > 0)
		SET @StrWhereA4 = @StrWhereA4 + ' AND ' + pub.funGetFilterString(@SessionNo, @ReportID, @SelectedAcnt43, 'F.AcntCode')

	IF (@SelectedAcnt51 > 0)
		SET @StrWhereA5 = @StrWhereA5 + ' AND ' + pub.funGetFilterString(@SessionNo, @ReportID, @SelectedAcnt51, 'F.AcntCode')
	IF (@SelectedAcnt42 > 0)
		SET @StrWhereA5 = @StrWhereA5 + ' AND ' + pub.funGetFilterString(@SessionNo, @ReportID, @SelectedAcnt52, 'F.AcntCode')
	IF (@SelectedAcnt43 > 0)
		SET @StrWhereA5 = @StrWhereA5 + ' AND ' + pub.funGetFilterString(@SessionNo, @ReportID, @SelectedAcnt53, 'F.AcntCode')

	insert into #tbl_InProdFlow(ProductID, AcntCode, ProductQty)
	select ProductID, AcntCode, SUM(Qty)
	from
	(
		select ProcessNo, FiscalYear, SerialNo, ProductID, AcntCode, ProductCount - 
					isnull((
						select SUM(GoodsQuantity)
						from inv.tblStorageDocsDtl D
						where D.ProcessID=80 and D.BaseProcessID=70 
							and D.BaseProcessNo=H.ProcessNo
							and D.BaseFiscalYear=H.FiscalYear
							and D.BaseSerialNo=H.SerialNo
					),0) Qty
		from inv.tblStorageDocsHdr H
		where ProcessID=70 and (H.DocDate<=@DocDateTo)
	) T
	where Qty > 0
	group by T.ProductID, T.AcntCode

	set @StrSelect = '
	insert into #tbl_Result(ProductID, ProductQty, GoodsQty1, GoodsQty2, GoodsQty3, GoodsQty4, GoodsQty5, InFlowQty1, InFlowQty2, InFlowQty3, InFlowQty4, InFlowQty5)
	select G.ProductID, 0, 0, 0, 0, 0, 0, isnull(sum(F.ProductQty), 0), 0, 0, 0, 0
	from #tbl_Goods1 G
			inner join #tbl_InProdFlow F on F.ProductID = G.GoodsID
	where ' + @StrWhereA1 + '
	group by G.ProductID'

	print @StrSelect;
	exec sp_executesql @StrSelect;	

	set @StrSelect = '
	insert into #tbl_Result(ProductID, ProductQty, GoodsQty1, GoodsQty2, GoodsQty3, GoodsQty4, GoodsQty5, InFlowQty1, InFlowQty2, InFlowQty3, InFlowQty4, InFlowQty5)
	select G.ProductID, 0, 0, 0, 0, 0, 0, 0, isnull(sum(F.ProductQty), 0), 0, 0, 0
	from #tbl_Goods2 G
			inner join #tbl_InProdFlow F on F.ProductID = G.GoodsID
	where ' + @StrWhereA2 + '
	group by G.ProductID'

	print @StrSelect;
	exec sp_executesql @StrSelect;	

	set @StrSelect = '
	insert into #tbl_Result(ProductID, ProductQty, GoodsQty1, GoodsQty2, GoodsQty3, GoodsQty4, GoodsQty5, InFlowQty1, InFlowQty2, InFlowQty3, InFlowQty4, InFlowQty5)
	select G.ProductID, 0, 0, 0, 0, 0, 0, 0, 0, isnull(sum(F.ProductQty), 0), 0, 0
	from #tbl_Goods3 G
			inner join #tbl_InProdFlow F on F.ProductID = G.GoodsID
	where ' + @StrWhereA3 + '
	group by G.ProductID'

	print @StrSelect;
	exec sp_executesql @StrSelect;	

	set @StrSelect = '
	insert into #tbl_Result(ProductID, ProductQty, GoodsQty1, GoodsQty2, GoodsQty3, GoodsQty4, GoodsQty5, InFlowQty1, InFlowQty2, InFlowQty3, InFlowQty4, InFlowQty5)
	select G.ProductID, 0, 0, 0, 0, 0, 0, 0, 0, 0, isnull(sum(F.ProductQty), 0), 0
	from #tbl_Goods4 G
			inner join #tbl_InProdFlow F on F.ProductID = G.GoodsID
	where ' + @StrWhereA4 + '
	group by G.ProductID'

	print @StrSelect;
	exec sp_executesql @StrSelect;	

	set @StrSelect = '
	insert into #tbl_Result(ProductID, ProductQty, GoodsQty1, GoodsQty2, GoodsQty3, GoodsQty4, GoodsQty5, InFlowQty1, InFlowQty2, InFlowQty3, InFlowQty4, InFlowQty5)
	select G.ProductID, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, isnull(sum(F.ProductQty), 0)
	from #tbl_Goods5 G
			inner join #tbl_InProdFlow F on F.ProductID = G.GoodsID
	where ' + @StrWhereA5 + '
	group by G.ProductID'

	print @StrSelect;
	exec sp_executesql @StrSelect;	
	
	-----------------------------------

	set @StrWhereS = '(D.GoodsID = T.ProductID)';

	if (@SelectedStore5 > 0)
		set @StrWhereS = @StrWhereS + ' AND ' + pub.funGetFilterString(@SessionNo, @ReportID, @SelectedStore5, 'D.StoreID') 

	set @StrSelect = '
	select T.*, [pub].[funGetGoodsName](T.ProductID, ' + LTrim(RTrim(@LangID)) + ') As GoodsName, 
			isnull((
				select SUM(D.SetPoint) SetPoint 
				from inv.tblGoodsStatusDtl D
				where ' + @StrWhereS + '
			),0) SetPoint
	from 
	(
		select	ProductID, 
				Sum(ProductQty) ProdcutQty, 
				Sum(GoodsQty1) GoodsQty1, 
				Sum(GoodsQty2) GoodsQty2, 
				Sum(GoodsQty3) GoodsQty3, 
				Sum(GoodsQty4) GoodsQty4, 
				Sum(GoodsQty5) GoodsQty5,
				Sum(InFlowQty1) InFlowQty1, 
				Sum(InFlowQty2) InFlowQty2, 
				Sum(InFlowQty3) InFlowQty3, 
				Sum(InFlowQty4) InFlowQty4, 
				Sum(InFlowQty5) InFlowQty5
				from	#tbl_Result GH
				where (select Count(*) from  inv.tblGoods D where substring (D.GoodsID,1,len (GH.ProductID))=GH.ProductID and  Len(GH.ProductID)<LEN(D.GoodsID) )=0

		group by ProductID
	) T 
	--inner join inv.tblGoodsDtl G on G.GoodsID = T.ProductID
	'

	set @StrWhere = '(1=1)'
	
	if (@SetDiffFr	is not null)
		set @StrWhere = @StrWhere + ' and (GoodsQty1+GoodsQty2+GoodsQty3+GoodsQty4+GoodsQty5-SetPoint >= ' + str(@SetDiffFr) + ')'
	if (@SetDiffTo	is not null)
		set @StrWhere = @StrWhere + ' and (GoodsQty1+GoodsQty2+GoodsQty3+GoodsQty4+GoodsQty5-SetPoint <= ' + str(@SetDiffTo) + ')'

	set @StrSelect = '
	select X.*, isnull(O.OrderQty, 0) RemainOrder
	from (' + @StrSelect + ') X
		left join #tbl_Orders O on O.GoodsID=X.ProductID
	where ' + @StrWhere + '
	order by ProductID'

	print @StrSelect;
	exec sp_executesql @StrSelect;
	---------------------------------------------------------------------------
END
GO
