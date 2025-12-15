USE TS_ShirinVatanKarkhaneh_1_1404
GO
SET ANSI_NULLS, QUOTED_IDENTIFIER ON
GO
-- =========== TS-QC:UPDATED ====================
-- Author		 : TakroSystem\Ahmadnejad
-- Create date   : 1388/10/26
-- Viewed By	 : 
-- Last Modified : 1389/10/26
-- Last Modifier : TakroSystem\Zia
-- Description   : سفارشات آماده تولید
-- =============================================
CREATE Procedure [pln].[SpPln_AvailProduceOrders]
	@ProcSet	VarChar(20),
	@RepOptions	VarChar(20) = '0'
WITH ENCRYPTION	
As
declare	@ProcessID	Int;
declare	@ProcessNo	Int;
declare	@FiscalYear	Int;
declare	@SerialNo	Int;
declare @UseStores	bit;
begin
	SET NOCOUNT ON;
	-- init --------------------------------------------------------------------
	IF (@RepOptions		Is Null)	SET @RepOptions	= '0';

	set @ProcessID	= pub.funSplitString(@ProcSet, '@', 1);
	set @ProcessNo	= pub.funSplitString(@ProcSet, '@', 2);
	set @FiscalYear	= pub.funSplitString(@ProcSet, '@', 3);
	set @SerialNo	= pub.funSplitString(@ProcSet, '@', 4);

	set @UseStores	= Substring(@RepOptions, 1, 1);
	----------------------------------------------------------------------------
	-- where -------------------------------------------------------------------
	create table #tbl_Stock
	(
		GoodsID varchar(20) collate arabic_cs_as null,
		Balance float null
	);

	select	AO.RowNo, AO.GoodsID, AO.GoodsQuantity
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

	if (@UseStores = 1)
		insert into #tbl_Stock
		select GoodsID, IsNull(Sum(D.GoodsQuantity * D.EnterKind), 0) Balance
		from inv.tblStorageDocsDtl D   
		where D.GoodsID in 
			(
				select GoodsID
				from #tbl_Avail
			) and D.StoreID in 
			(
				select S.StoreID
				from pln.tblGoodsStores S
				where (S.StoreType = 2) and (S.GoodsID = D.GoodsID)
			)
		group by GoodsID
	else
		insert into #tbl_Stock
		select GoodsID, IsNull(Sum(D.GoodsQuantity * D.EnterKind), 0) Balance
		from inv.tblStorageDocsDtl D   
		where D.GoodsID in 
		(
			select GoodsID
			from #tbl_Avail
		)
		group by GoodsID

	select A.*, G.GoodsName, isnull(B.Balance, 0) Balance
	from #tbl_Avail A
		left join #tbl_Stock B on A.GoodsID = B.GoodsID
		left join inv.tblGoodsDtl G on G.GoodsID = A.GoodsID
End
GO
