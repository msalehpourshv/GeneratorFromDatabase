USE TS_ShirinVatanKarkhaneh_1_1404
GO
SET ANSI_NULLS, QUOTED_IDENTIFIER ON
GO
-- =========== TS-QC:UPDATED ====================
-- Author		 : TakroSystem\Zia
-- Creation Date : 1389/10/27
-- Viewed By	 : 
-- Last Modified : 
-- Last Modifier : 
-- Description   : گزارش سرجمع فروش و برگشتی
-- ==============================================
CREATE PROCEDURE [sal].[RptSale_Summary2]
	@FiscalYearFr		Int = Null,
	@SerialNoFr			Int = Null,
	@FiscalYearTo		Int = Null,
	@SerialNoTo			Int = Null,
	@DocDateFr			Char(10) = Null,
	@DocDateTo			Char(10) = Null,
	@SelectedGoods		Int = 0, 
	@SelectedStore		Int = 0, 
	@SelectedAcnt1		Int = 0, 
	@SelectedAcnt2		Int = 0, 
	@SelectedAcnt3		Int = 0, 
	@SelectedAcnt4		Int = 0, 
	@SelectedVisitor1	Int = 0, 
	@SelectedVisitor2	Int = 0, 
	@SelectedVisitor3	Int = 0, 
	@SelectedVisitor4	Int = 0, 
	@SortFields			NVarChar(100) = Null,   -- Order By Field List
	@ExtraParams		NVarChar(200) = '',
	@RepOptions			VarChar(10) = '1', -- bit array options
	@RepInfo			NVarChar(100) = '1@1@1'
WITH ENCRYPTION
AS 
	---- Declarations ---------------
DECLARE @StrSelect	NVarChar(4000);
DECLARE @StrFrom	NVarChar(4000);
DECLARE @StrWhere	NVarChar(4000);

DECLARE	@LangID		Char(1);
DECLARE	@SessionNo	Int; -- برای حالت کدهای انتخابی
DECLARE	@ReportID	Int; -- برای حالت کدهای انتخابی
DECLARE	@SumAmount1	decimal(20,5);
DECLARE	@SumAmount2	decimal(20,5);

Begin --============== S T A R T  C O D E ===================================================

	SET NOCOUNT ON;

	CREATE TABLE #tbl_Inner
	(
		GoodsID		varchar(20) collate arabic_cs_as not null,
		QuantityS	float not null,
		QuantityR	float not null,
		PriceS		bigint not null,
		PriceR		bigint not null,
		DiscountS	float not null,
		DiscountR	float not null,
		GoodsName	nvarchar(200) not null,
		BarCode     varchar(20) collate arabic_cs_as not null,
		PercentQ	float not null,
		PercentP	float not null,
		ExtraField1 nvarchar(200) not null,
		ExtraField2 nvarchar(200) not null,
		ExtraField3 nvarchar(200) not null,
		ExtraField4 nvarchar(200) not null,
		ExtraField5 nvarchar(200) not null
	)

	 INSERT INTO #tbl_Inner --Values('0101010100101',1357.000000000,3.000000000,185268000,414000,0,0,'HDF TEVER PAN - PARIS 670 - چهار قاب عمودی',0.323100,0.15122027487703,'','','','','')
	 EXEC [sal].[RptSale_Summary]
		  @FiscalYearFr, @SerialNoFr, @FiscalYearTo, @SerialNoTo, @DocDateFr, @DocDateTo, @SelectedGoods, @SelectedStore,
		  @SelectedAcnt1, @SelectedAcnt2, @SelectedAcnt3, @SelectedAcnt4, @SelectedVisitor1, @SelectedVisitor2, @SelectedVisitor3,
		  @SelectedVisitor4, @SortFields, @ExtraParams, @RepOptions, @RepInfo
	
	--==================================== Select
	SELECT	IsNull(R.GoodsGroupID, '') GoodsGroupID, isnull(N.GoodsGroupName, 'مجموع کالاهای بدون گروه') AS GoodsGroupName,
			isnull(sum(A.QuantityS), 0) QuantityS, 
			isnull(sum(A.QuantityR), 0) QuantityR,
			isnull(sum(A.PriceS), 0)	PriceS,
			isnull(sum(A.PriceR), 0)	PriceR,
			isnull(sum(A.PercentQ), 0) PercentQ,
			isnull(sum(A.PercentP), 0) PercentP
	FROM	#tbl_Inner A
			LEFT JOIN inv.tblGoodsGroupsGoodsListDtl R ON R.GoodsID = A.GoodsID
			LEFT JOIN inv.tblGoodsGroupsDtl N ON N.GoodsGroupID = R.GoodsGroupID
	GROUP BY R.GoodsGroupID, N.GoodsGroupName
	ORDER BY R.GoodsGroupID 
	--============================================
End
GO
