USE TS_ShirinVatanKarkhaneh_1_1404
GO
SET ANSI_NULLS, QUOTED_IDENTIFIER ON
GO
-- =========== TS-QC:UPDATED ====================
-- Author		 : TakroSystem\Zia
-- Create date   : 1391/02/16
-- Viewed By	 : 
-- Last Modified : 
-- Last Modifier : 
-- Description	 : <سفارش کارهای مورد نیاز برای یک سفارش تولید بهمراه موجودی>
-- =================================================================
CREATE PROCEDURE [pln].[RptPln_AvailProduceOrders_Stock]
	@ProcSet		varchar(20), -- سفارش تولید
	@SelectedStore1	int = 0, 
	@SelectedStore2	int = 0, 
	@SelectedGoods	int = 0, 
	@DateTo			char(10) = null, -- تاریخ برای محاسبه موجودی
	@RepOptions		varchar(10) = '11',  -- bit array options
	@RepInfo		nvarchar(100) = '1@1@1'
WITH ENCRYPTION
AS
declare @LangID		Char(1);
declare @SessionNo	Int; -- برای حالت کدهای انتخابی
declare @ReportID	Int; -- برای حالت کدهای انتخابی

declare @StrSelect	nvarchar(4000);
declare @StrWhere	nvarchar(2000);
declare @WhrStore1	nvarchar(4000);
declare @WhrStore2	nvarchar(4000);

declare @PID as varchar(10);
declare @PNO as varchar(2);
declare @FYR as varchar(4);
declare @SNO as varchar(10);
BEGIN 
	SET NOCOUNT ON;

	-- init ------------------------------------------------------------
	if (@RepInfo		Is Null)	set @RepInfo = '1@1@1';
	if (@RepOptions		Is Null)	set @RepOptions = '11';
	if (@SelectedGoods	Is Null)	set @SelectedGoods = 0;
	if (@SelectedStore1	Is Null)	set @SelectedStore1 = 0;
	if (@SelectedStore2	Is Null)	set @SelectedStore2 = 0;

	SET @LangID		= pub.funSplitString(@RepInfo, '@', 1);
	SET @SessionNo	= pub.funSplitString(@RepInfo, '@', 2);
	SET @ReportID	= pub.funSplitString(@RepInfo, '@', 3);

	SET @PID = LTRIM(pub.funSplitString(@ProcSet, '@', 1));
	SET @PNO = LTRIM(pub.funSplitString(@ProcSet, '@', 2));
	SET @FYR = LTRIM(pub.funSplitString(@ProcSet, '@', 3));
	SET @SNO = LTRIM(pub.funSplitString(@ProcSet, '@', 4));
	
	set @StrWhere = '(P.ProcessID = ' + @PID + ') and (P.ProcessNo = ' + @PNO + ') and (P.FiscalYear = ' + @FYR + ') and (P.SerialNo = ' + @SNO + ')'
	set @WhrStore1 = '(S.InventoryOwnership=0) and (S.InventoryType<3) and (D.GoodsID=T.GoodsID)'
	set @WhrStore2 = '(S.InventoryOwnership=1) and (S.InventoryType<3) and (D.GoodsID=T.GoodsID)'

	if (@SelectedGoods > 0)
		set @StrWhere = pub.funGetFilterString(@SessionNo, @ReportID, @SelectedGoods, 'P.GoodsID')
	
	if (@DateTo is not null)
	begin
		set @WhrStore1 = @WhrStore1 + ' and (D.DocDate <= ''' + @DateTo + ''')'
		set @WhrStore2 = @WhrStore2 + ' and (D.DocDate <= ''' + @DateTo + ''')'
	end;
		
	if (@SelectedStore1 > 0)
		set @WhrStore1 = @WhrStore1 + ' and ' + pub.funGetFilterString(@SessionNo, @ReportID, @SelectedStore1, 'D.StoreID')
	if (@SelectedStore2 > 0)
		set @WhrStore2 = @WhrStore2 + ' and ' + pub.funGetFilterString(@SessionNo, @ReportID, @SelectedStore2, 'D.StoreID') 

	set @StrSelect = '
	select T.GoodsID, sum(GoodsQuantity) Quantity, [pub].[funGetGoodsName](T.GoodsID,1) GoodsName,
			isnull((
				SELECT	IsNull(Sum(D.GoodsQuantity * D.EnterKind), 0)
				FROM    inv.tblStorageDocsDtl D
							inner join inv.tblStores S on S.StoreID = D.StoreID
				WHERE	' + @WhrStore1 + '
			),0) as Balance1,
			isnull((
				SELECT	IsNull(Sum(D.GoodsQuantity * D.EnterKind), 0)
				FROM    inv.tblStorageDocsDtl D
							inner join inv.tblStores S on S.StoreID = D.StoreID
				WHERE	' + @WhrStore2 + '
			),0) as Balance2
	from
	(
		SELECT	P.GoodsID, P.GoodsQuantity 
		FROM	pln.tblAvailProduceOrders P
		WHERE ' + @StrWhere + '
	) T 
	group by T.GoodsID '

	print @StrSelect;
	exec sp_executesql @StrSelect;
END
GO
