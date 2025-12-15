USE TS_ShirinVatanKarkhaneh_1_1404
GO
SET ANSI_NULLS, QUOTED_IDENTIFIER ON
GO
-- =========== TS-QC:UPDATED ====================
-- Author        : TakroSystem\Zia
-- Create date   : 1386/11/15
-- Viewed By	 : 
-- Last Modified : 1391/04/12
-- Last Modifier : TakroSystem\Zia
-- Description   : لیست سفارشات
-- =============================================
CREATE PROCEDURE [sal].[RptSaleOrder_Docs_Ex1]
	@ProcessNo		Int = 1,
	@FiscalYearFr	Int = NULL,
	@SerialNoFr		Int = NULL,
	@FiscalYearTo	Int = NULL,
	@SerialNoTo		Int = NULL,
	@DocDateFr		Char(10) = NULL,
	@DocDateTo		Char(10) = NULL,
	@OrdDateFr		Char(10) = NULL,
	@OrdDateTo		Char(10) = NULL,
	@DelDateFr		Char(10) = NULL,
	@DelDateTo		Char(10) = NULL,
	@SelectedAcnt1	Int = NULL,
	@SelectedAcnt2	Int = NULL,
	@SelectedAcnt3	Int = NULL,
	@SelectedAcnt4	Int = NULL,
	@VisitorCode1	Int = NULL,
	@VisitorCode2	Int = NULL,
	@VisitorCode3	Int = NULL,
	@VisitorCode4	Int = NULL,
	@SortFields		VarChar(100) = NULL,
	@RepOptions		VarChar(20) = '21000', -- bit array
	@RepInfo		VarChar(100) = '1@1@1'
WITH ENCRYPTION
AS 
declare @PayableAmount	int
declare @DecReturns		int
Begin --============== S T A R T  C O D E ===================================================

	SET NOCOUNT ON;

	-- I N I T ----------------------------------------------------------------
	set @PayableAmount	= 0;
	set @DecReturns		= 0;
	
	SET @PayableAmount	= Substring(@RepOptions, 4, 1);
	SET @DecReturns		= Substring(@RepOptions, 5, 1);

	begin try
		drop table #tbl_SaleOrder_Docs_Ex1_Orders
		drop table #tbl_SAL
		drop table #tbl_RET
	end try
	begin catch
	end catch
	
	---------------------------------------------------------------------------
	-- S E L E C T ------------------------------------------------------------
	create table #tbl_SaleOrder_Docs_Ex1_Orders
	(
		ProcessID int not null,
		ProcessNo int not null,
		FiscalYear int not null,
		SerialNo int not null,
		DocDate char(10) collate arabic_cs_as,
		AcntCode varchar(20) collate arabic_cs_as
	)

	create table #tbl_SAL
	(
		ProcessID int not null,
		ProcessNo int not null,
		FiscalYear int not null,
		SerialNo int not null,
		BaseProcessID int not null,
		BaseProcessNo int not null,
		BaseFiscalYear int not null,
		BaseSerialNo int not null,
		MainPrice float,
		SidePrice float
	)

	create table #tbl_RET
	(
		ProcessID int not null,
		ProcessNo int not null,
		FiscalYear int not null,
		SerialNo int not null,
		BaseProcessID int not null,
		BaseProcessNo int not null,
		BaseFiscalYear int not null,
		BaseSerialNo int not null,
		MainPrice float,
		SidePrice float
	)
		
	insert into #tbl_SaleOrder_Docs_Ex1_Orders
	exec [sal].[RptSaleOrder_Docs_Ex_Inner] 
		@ProcessNo		,
		@FiscalYearFr	,
		@SerialNoFr		,
		@FiscalYearTo	,
		@SerialNoTo		,
		@DocDateFr		,
		@DocDateTo		,
		@OrdDateFr		,
		@OrdDateTo		,
		@DelDateFr		,
		@DelDateTo		,
		@SelectedAcnt1	,
		@SelectedAcnt2	,
		@SelectedAcnt3	,
		@SelectedAcnt4	,
		@VisitorCode1	,
		@VisitorCode2	,
		@VisitorCode3	,
		@VisitorCode4	,
		@SortFields		,
		@RepOptions		,
		@RepInfo		

	-------------------------------------------------------------------------------------
	insert into	#tbl_SAL (ProcessID, ProcessNo, FiscalYear, SerialNo, BaseProcessID, BaseProcessNo, BaseFiscalYear, BaseSerialNo, MainPrice, SidePrice)
	select	H.ProcessID, H.ProcessNo, H.FiscalYear, H.SerialNo, G.BaseProcessID, G.BaseProcessNo, G.BaseFiscalYear, G.BaseSerialNo, Sum(G.GoodsPriceSum), SUM(H.SidePriceSum)
	from	inv.vwStorageDocsHdr H 
			inner join 
			(
				select	D.ProcessID, D.ProcessNo, D.FiscalYear, D.SerialNo, D.BaseProcessID, D.BaseProcessNo, D.BaseFiscalYear, D.BaseSerialNo, SUM(D.GoodsQuantity*D.GoodsPrice) GoodsPriceSum
				from inv.tblStorageDocsDtl D
				where D.ProcessID=90
				group by D.ProcessID, D.ProcessNo, D.FiscalYear, D.SerialNo, D.BaseProcessID, D.BaseProcessNo, D.BaseFiscalYear, D.BaseSerialNo
			) G on H.ProcessID=G.ProcessID and H.ProcessNo=G.ProcessNo and H.FiscalYear=G.FiscalYear and H.SerialNo=G.SerialNo
	group by H.ProcessID, H.ProcessNo, H.FiscalYear, H.SerialNo, G.BaseProcessID, G.BaseProcessNo, G.BaseFiscalYear, G.BaseSerialNo
	
	insert into	#tbl_RET(ProcessID, ProcessNo, FiscalYear, SerialNo, BaseProcessID, BaseProcessNo, BaseFiscalYear, BaseSerialNo, MainPrice, SidePrice)
	select	H.ProcessID, H.ProcessNo, H.FiscalYear, H.SerialNo, G.BaseProcessID, G.BaseProcessNo, G.BaseFiscalYear, G.BaseSerialNo, Sum(G.GoodsPriceSum), SUM(H.SidePriceSum)
	from	inv.vwStorageDocsHdr H 
			inner join 
			(
				select	D.ProcessID, D.ProcessNo, D.FiscalYear, D.SerialNo, D.BaseProcessID, D.BaseProcessNo, D.BaseFiscalYear, D.BaseSerialNo, SUM(D.GoodsQuantity*D.GoodsPrice) GoodsPriceSum
				from inv.tblStorageDocsDtl D
				where D.ProcessID=100
				group by D.ProcessID, D.ProcessNo, D.FiscalYear, D.SerialNo, D.BaseProcessID, D.BaseProcessNo, D.BaseFiscalYear, D.BaseSerialNo
			) G on H.ProcessID=G.ProcessID and H.ProcessNo=G.ProcessNo and H.FiscalYear=G.FiscalYear and H.SerialNo=G.SerialNo
	group by H.ProcessID, H.ProcessNo, H.FiscalYear, H.SerialNo, G.BaseProcessID, G.BaseProcessNo, G.BaseFiscalYear, G.BaseSerialNo

	select	DocDate, 
			COUNT(*) OrderCount,
			SUM(SumPriceSOR) SumPrice, 
			SUM(SumPriceSAL) SumPriceSale
	from
	(
		select	X.*, 
				isnull((
					select SUM(D.GoodsQuantity*D.GoodsPrice)
					from sal.tblSaleOrderDtl D
					where X.ProcessID=D.ProcessID and X.ProcessNo=D.ProcessNo and X.FiscalYear=D.FiscalYear and X.SerialNo=D.SerialNo
				),0) SumPriceSOR,
				isnull((
					select SUM(S.MainPrice + @PayableAmount*S.SidePrice - @DecReturns*(isnull(R.MainPrice,0) + @PayableAmount*isnull(R.SidePrice,0)))
					from #tbl_SAL S
						left join #tbl_RET R on R.BaseProcessID=S.ProcessID and R.BaseProcessNo=S.ProcessNo and R.BaseFiscalYear=S.FiscalYear and R.BaseSerialNo=S.SerialNo
					where S.BaseProcessID=X.ProcessID and S.BaseProcessNo=X.ProcessNo and S.BaseFiscalYear=X.FiscalYear and S.BaseSerialNo=X.SerialNo
				),0) SumPriceSAL
		from #tbl_SaleOrder_Docs_Ex1_Orders X
	) Y
	group by DocDate
	order by DocDate

	---------------------------------------------------------------------------
End
 
GO
