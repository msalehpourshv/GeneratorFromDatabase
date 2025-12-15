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
CREATE PROCEDURE [sal].[RptSaleOrder_Docs_Ex2]
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
	@RepOptions		VarChar(20) = '21', -- bit array
	@RepInfo		VarChar(100) = '1@1@1'
WITH ENCRYPTION
AS 
Begin --============== S T A R T  C O D E ===================================================

	SET NOCOUNT ON;

	-- I N I T ----------------------------------------------------------------
	begin try
		drop table #tbl_SaleOrder_Docs_Ex2_Orders
	end try
	begin catch
	end catch
	---------------------------------------------------------------------------
	-- S E L E C T ------------------------------------------------------------
	create table #tbl_SaleOrder_Docs_Ex2_Orders
	(
		ProcessID int not null,
		ProcessNo int not null,
		FiscalYear int not null,
		SerialNo int not null,
		DocDate char(10) collate arabic_cs_as,
		AcntCode varchar(20) collate arabic_cs_as
	)
	
	insert into #tbl_SaleOrder_Docs_Ex2_Orders
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
	
	select	H.*, F.VisitPathID1, F.VisitPathID2, F.VisitPathID3, F.VisitPathID4, F.AcntName,
			VP1.VisitPathName VisitPathName1,
			VP2.VisitPathName VisitPathName2,
			VP3.VisitPathName VisitPathName3,
			VP4.VisitPathName VisitPathName4,
			(
				select sum(D.GoodsQuantity*D.GoodsPrice)
				from sal.tblSaleOrderDtl D
				where (D.ProcessID=H.ProcessID) and (D.ProcessNo=H.ProcessNo) and (D.FiscalYear=H.FiscalYear) and (D.SerialNo=H.SerialNo)
			) SumPrice
	from #tbl_SaleOrder_Docs_Ex2_Orders H
			outer apply acc.funGetCodeInfo(H.AcntCode) F
			left join acc.tblVisitPathDtl VP1 on VP1.VisitPathID = F.VisitPathID1 and VP1.PartNumber = 1
			left join acc.tblVisitPathDtl VP2 on VP2.VisitPathID = F.VisitPathID2 and VP2.PartNumber = 2
			left join acc.tblVisitPathDtl VP3 on VP3.VisitPathID = F.VisitPathID3 and VP3.PartNumber = 3
			left join acc.tblVisitPathDtl VP4 on VP4.VisitPathID = F.VisitPathID4 and VP4.PartNumber = 4
	order by H.ProcessID, H.ProcessNo, H.FiscalYear, H.SerialNo 
	---------------------------------------------------------------------------
End
GO
