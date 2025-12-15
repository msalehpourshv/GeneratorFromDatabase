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
CREATE PROCEDURE [prd].[RptPrd_ProduceStepsOx2]
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

DECLARE	@LangID		Char(1);
DECLARE	@SessionNo	Int; -- برای حالت کدهای انتخابی
DECLARE	@ReportID	Int; -- برای حالت کدهای انتخابی

BEGIN

	SET NOCOUNT ON;

	-- init ------------------------------------------------------------
	if (@RepInfo		Is Null)	set @RepInfo = '1@1@1';
	if (@RepOptions		Is Null)	set @RepOptions = '';

	set @LangID		= pub.funSplitString(@RepInfo, '@', 1);
	set @SessionNo	= pub.funSplitString(@RepInfo, '@', 2);
	set @ReportID	= pub.funSplitString(@RepInfo, '@', 3);
	---------------------------------------------------------------------------
	-- where section ----------------------------------------------------------
	set @StrWhere = '(1=1)';
	
	---------------------------------------------------------------------------
	create table #tbl_Products
	(
		GroupID   varchar(20) collate Arabic_CS_AS null,
		ProductID varchar(20) collate Arabic_CS_AS null
	);

	set @StrSelect = '
	insert	into #tbl_Products(GroupID, ProductID)
	select	distinct G.GoodsGroupID, P.GoodsID
	from	inv.tblGoods P
				inner join inv.tblGoodsGroupsGoodsListDtl G on P.GoodsID = G.GoodsID
	where ' + @StrWhere

	print @StrSelect;
	exec sp_executesql @StrSelect;
	
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
		InFlowQty5	float,
		GoodsName	nvarchar(50),
		SetPoint	float,
		RemainOrder	float
	);
	
	insert into #tbl_Result
	exec [prd].[RptPrd_ProduceStepsOx1] 
			@GoodsCodeMask1,
			@GoodsCodeMask2,
			@GoodsCodeMask3,
			@GoodsCodeMask4,
			@GoodsCodeMask5,
			@SelectedProdsP,
			@SelectedGroupP,
			@SelectedStoreP,
			@SelectedStore1,
			@SelectedStore2,
			@SelectedStore3,
			@SelectedStore4,
			@SelectedStore5,
			@SelectedGoods1,
			@SelectedGoods2,
			@SelectedGoods3,
			@SelectedGoods4,
			@SelectedGoods5,
			@SelectedAcnt11,
			@SelectedAcnt12,
			@SelectedAcnt13,
			@SelectedAcnt21,
			@SelectedAcnt22,
			@SelectedAcnt23,
			@SelectedAcnt31,
			@SelectedAcnt32,
			@SelectedAcnt33,
			@SelectedAcnt41,
			@SelectedAcnt42,
			@SelectedAcnt43,
			@SelectedAcnt51,
			@SelectedAcnt52,
			@SelectedAcnt53,
			@DocDateTo,
			@SetDiffFr	= @SetDiffFr,
			@SetDiffTo	= @SetDiffTo,
			@OrdDiffFr	= @OrdDiffFr,
			@OrdDiffTo	= @OrdDiffTo,
			@RepOptions	=@RepOptions,  
			@RepInfo	=@RepInfo,
			@ExtraParams=@ExtraParams
	
	---------------------------------------------------------
	
	select T.*, GoodsGroupName
	from 
	(
		select	P.GroupID, 
				Sum(R.GoodsQty1) GoodsQty1, 
				Sum(R.GoodsQty2) GoodsQty2, 
				Sum(R.GoodsQty3) GoodsQty3, 
				Sum(R.GoodsQty4) GoodsQty4, 
				Sum(R.GoodsQty5) GoodsQty5,
				Sum(R.InFlowQty1) InFlowQty1,
				Sum(R.InFlowQty2) InFlowQty2,
				Sum(R.InFlowQty3) InFlowQty3,
				Sum(R.InFlowQty4) InFlowQty4,
				Sum(R.InFlowQty5) InFlowQty5,
				Sum(R.SetPoint) SetPoint, 
				Sum(R.RemainOrder) RemainOrder
		from #tbl_Result R
				inner join #tbl_Products P on P.ProductID=R.ProductID
		group by P.GroupID
	) T inner join inv.tblGoodsGroupsDtl G on G.GoodsGroupID = T.GroupID
	order by GroupID
	---------------------------------------------------------------------------
END
GO
