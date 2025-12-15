USE TS_ShirinVatanKarkhaneh_1_1404
GO
SET ANSI_NULLS, QUOTED_IDENTIFIER ON
GO
-- =========== TS-QC:UPDATED ====================
-- Author		 : TakroSystem\Zia
-- Create date   : 1390/01/25
-- Viewed By	 : 
-- Last Modified : 1390/05/04
-- Last Modifier : TakroSystem\Zia
-- Description	 : برای تولید مواد اولیه جهت انتقال کالا
-- ==============================================
Create PROCEDURE [prd].[RptPrd_ProductGoods_All_Stock_Ex]
	@SelectedGoods	int = 0,
	@FormulaNo		int = 0,
	@FY				int = 0, 
	@SN				int = 0, 
	@DateTo			char(10) = null,
	@StoreID		varchar(20) = null,
	@StoreIDEx		varchar(20) = null,
	@SortFields		nvarchar(100) = Null,
	@RepOptions		varchar(10) = '101',  -- bit array options
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
		StoreID		varchar(20) collate arabic_cs_as not null,
		Balance		float not null,
		GoodsName	nvarchar(100) not null,
		UnitID		varchar(20) collate arabic_cs_as not null,
		UnitName	nvarchar(100) not null,
		SumCMR		float not null,
		SumBuy		float not null,
		LastAmount	float not null,
		SetPoint    float,
		ConstPrdText1	nVarchar(100),
		ConstPrdText2	nVarchar(100),
		ConstPrdText3	nVarchar(100),
		ConstPrdText4	nVarchar(100),
		ConstPrdText5	nVarchar(100),
		ConstPrdText1Name	nVarchar(100),
		ConstPrdText2Name   nVarchar(100),
		ConstPrdText3Name   nVarchar(100),
		ConstPrdText4Name   nVarchar(100),
		ConstPrdText5Name   nVarchar(100)
	);

	create table #tbl_Outer
	(
		GoodsID		varchar(20) collate arabic_cs_as not null,
		Quantity	float null,
		StoreID		varchar(20) collate arabic_cs_as not null,
		Balance		float not null,
		GoodsName	nvarchar(100) not null,
		UnitID		varchar(20) collate arabic_cs_as not null,
		UnitName	nvarchar(100) not null,
		SumCMR		float not null,
		SumBuy		float not null,
		LastAmount	float not null,
		SetPoint    float,
		ConstPrdText1	nVarchar(100),
		ConstPrdText2	nVarchar(100),
		ConstPrdText3	nVarchar(100),
		ConstPrdText4	nVarchar(100),
		ConstPrdText5	nVarchar(100),
		ConstPrdText1Name	nVarchar(100),
		ConstPrdText2Name   nVarchar(100),
		ConstPrdText3Name   nVarchar(100),
		ConstPrdText4Name   nVarchar(100),
		ConstPrdText5Name   nVarchar(100)
	);

	insert into #tbl_Inner(GoodsID, StoreID,Quantity,  Balance, GoodsName, UnitID, UnitName, SumCMR, SumBuy, LastAmount,SetPoint
	,ConstPrdText1,ConstPrdText2,ConstPrdText3,ConstPrdText4,ConstPrdText5
		,ConstPrdText1Name,ConstPrdText2Name,ConstPrdText3Name,ConstPrdText4Name,ConstPrdText5Name)
	exec [prd].[RptPrd_ProductGoods_All_Stock] 0,0,@FormulaNo, 0, @SelectedGoods, @DateTo, null, @SortFields, '01000', @RepInfo



	delete from prd.tblProductSlc 
	where (UserID = @UserID) and (ReportID = @ReportID) and (ObjectID = 1)
		and (ProductID not in (select GoodsID from pln.tblGoodsStores S where (S.StoreType = 1) and (S.StoreID = @StoreIDEx)))

	insert into prd.tblProductSlc(ProductID, UserID, ReportID, ObjectID, Quantity)
	select A.GoodsID, @UserID, @ReportID, 1, A.Quantity
	from #tbl_Inner A
			inner join pln.tblGoodsStores S on S.GoodsID = A.GoodsID 
	where (S.StoreType = 1) and (S.StoreID = @StoreIDEx)

	insert into #tbl_Outer(GoodsID,StoreID, Quantity, Balance, GoodsName, UnitID, UnitName, SumCMR, SumBuy, LastAmount,SetPoint
	,ConstPrdText1,ConstPrdText2,ConstPrdText3,ConstPrdText4,ConstPrdText5
		,ConstPrdText1Name,ConstPrdText2Name,ConstPrdText3Name,ConstPrdText4Name,ConstPrdText5Name)
	exec [prd].[RptPrd_ProductGoods_All_Stock] 0,0,@FormulaNo, 0, @SelectedGoods, @DateTo, @StoreID, @SortFields, '10100', @RepInfo

	 

	update #tbl_Outer
	set Quantity = Quantity - isnull((select sum(GoodsQuantity) from inv.tblStorageDocsDtl where (ProcessID = 120) and (BaseProcessID = 600) and (BaseFiscalYear = @FY) and (BaseSerialNo = @SN)and (GoodsID=#tbl_Outer.GoodsID)), 0)

	update #tbl_Outer
	set Quantity = 0
	where Quantity is null

	select *
	from #tbl_Outer
	---------------------------------------------------------------------------
End
GO
