USE TS_ShirinVatanKarkhaneh_1_1404
GO
SET ANSI_NULLS, QUOTED_IDENTIFIER ON
GO
-- =========== TS-QC:UPDATED ====================
-- Author		 : TakroSystem\Zia
-- Create date   : 1390/01/25
-- Viewed By	 : 
-- Last Modified : 1390/08/04
-- Last Modifier : TakroSystem\Zia
-- Description	 : برای تولید مواد اولیه جهت درخواست خرید
-- ==============================================
Create PROCEDURE [prd].[RptPrd_ProductGoods_All_Stock_Fx]
	@SelectedGoods	int = 0,
	@FormulaNo		int = 0,
	@DateTo			char(10) = null,         
	@StoreID		varchar(20) = null,
	@SortFields		nvarchar(100) = Null,
	@RepOptions		varchar(10) = '10100',  -- bit array options
	@RepInfo		nvarchar(100) = '1@1@1'
WITH ENCRYPTION
AS
declare	@LangID		char(1);
declare	@SessionNo	int; 
declare	@ReportID	int; 
declare	@UserID		int; 

Begin
	set NOCOUNT ON;

	set @LangID		= pub.funSplitString(@RepInfo, '@', 1);
	set @SessionNo	= pub.funSplitString(@RepInfo, '@', 2);
	set @ReportID	= pub.funSplitString(@RepInfo, '@', 3);
	set @UserID		= pub.funSplitString(@RepInfo, '@', 4);

	create table #tbl_Inner
	(
		GoodsID		varchar(20) collate arabic_cs_as not null,
		Quantity	float not null,
		Balance		float not null,
		GoodsName	nvarchar(100) not null,
		UnitID		varchar(20) collate arabic_cs_as not null,
		UnitName	nvarchar(100) not null,
		SumCMR		float not null,
		SumBuy		float not null,
		LastAmount	float not null,
		SetPoint	float not null,
		ConstPrdText1		varchar(20) collate arabic_cs_as   null,
		ConstPrdText2		varchar(20) collate arabic_cs_as   null,
		ConstPrdText3		varchar(20) collate arabic_cs_as   null,
		ConstPrdText4		varchar(20) collate arabic_cs_as   null,
		ConstPrdText5		varchar(20) collate arabic_cs_as   null,
		ConstPrdText1Name		varchar(20) collate arabic_cs_as   null,
		ConstPrdText2Name		varchar(20) collate arabic_cs_as   null,
		ConstPrdText3Name		varchar(20) collate arabic_cs_as   null,
		ConstPrdText4Name		varchar(20) collate arabic_cs_as   null,
		ConstPrdText5Name		varchar(20) collate arabic_cs_as   null
		
	);

	insert into #tbl_Inner(GoodsID, Quantity, Balance, GoodsName, UnitID, UnitName, SumCMR, SumBuy, LastAmount,SetPoint	
	,ConstPrdText1	,ConstPrdText2	,ConstPrdText3	,ConstPrdText4	,ConstPrdText5	,ConstPrdText1Name, ConstPrdText2Name,ConstPrdText3Name, ConstPrdText4Name, ConstPrdText5Name)
	exec [prd].[RptPrd_ProductGoods_All_Stock] 0, 0, @FormulaNo, 0, @SelectedGoods, @DateTo, null, @SortFields, '01000', @RepInfo

	insert into prd.tblProductSlc(ProductID, UserID, ReportID, ObjectID, Quantity)
	select A.GoodsID, @UserID, @ReportID, 1, A.Quantity
	from #tbl_Inner A

	exec [prd].[RptPrd_ProductGoods_All_Stock] 0, 0, @FormulaNo, 0, @SelectedGoods, @DateTo, @StoreID, @SortFields, '10100', @RepInfo

	---------------------------------------------------------------------------
End
GO
