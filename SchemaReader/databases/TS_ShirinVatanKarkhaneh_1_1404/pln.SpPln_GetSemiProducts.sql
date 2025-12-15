USE TS_ShirinVatanKarkhaneh_1_1404
GO
SET ANSI_NULLS, QUOTED_IDENTIFIER ON
GO
-- =========== TS-QC:UPDATED ===================
-- Author		 : TakroSystem\Zia
-- Create date   : 1393/11/18
-- Viewed By	 : 
-- Last Modified : 1393/11/18
-- Last Modifier : TakroSystem\Zia
-- ---------------------------------------------
--  کالاهای تولید شدنی برای یک سفارش تولید
-- =============================================
CREATE PROCEDURE [pln].[SpPln_GetSemiProducts]
	@ProcessID		int,
	@ProcessNo		int,
	@FiscalYear		int,
	@SerialNo		int,
	@RepOptions		VarChar(20) = '', -- bit array
	@RepInfo		NVarChar(100) = '1@1@1'
WITH ENCRYPTION
AS
declare	@ProductID  VarChar(20);
declare @ProductQty Real;
declare @FormulaNo	int;

declare @LangID		Char(1);
declare @SessionNo  varChar(10);
declare @ReportID   varChar(10);

declare @StrSelect  nvarchar(4000);
declare @StrWhere	nvarchar(4000);
BEGIN
	SET NOCOUNT ON;

	create table #tbl_Avail_Tmp
	(	
		GoodsID	varchar(20) collate arabic_cs_as not null,
		Quantity	float not null
	);

	-- Init ---------------------------------------------------------------------
	IF (@RepInfo Is Null)	 SET @RepInfo = '1@1@1';
	IF (@RepOptions Is Null) SET @RepOptions = '1';

	SET @LangID		= pub.funSplitString(@RepInfo, '@', 1);
	SET @SessionNo	= pub.funSplitString(@RepInfo, '@', 2);
	SET @ReportID	= pub.funSplitString(@RepInfo, '@', 3);

	-----------------------------------------------------------------------------
	-- Process ------------------------------------------------------------------
	declare crs_Prods cursor for 
		select ProductID, ProductCount, FormulaNo
		from pln.tblProduceOrderDtl
		where (ProcessID = @ProcessID) and (ProcessNo = @ProcessNo) and (FiscalYear = @FiscalYear) and (SerialNo = @SerialNo)

	open crs_Prods;
	fetch next from crs_Prods into @ProductID, @ProductQty, @FormulaNo;
	
	while (@@fetch_status = 0)
	begin
		if (@FormulaNo <> 0) 
			set @StrWhere = '(H.SerialNo = ' + Str(@FormulaNo) + ')'
		else
			set @StrWhere = '(H.IsDefault = 1)' 

		set @StrSelect = '
		WITH tblTemp(ProductID, GoodsID, Quantity) AS
		(
			SELECT	H.ProductID, D.GoodsID, (' + LTrim(Str(@ProductQty)) + ' / H.ProductCount) * D.GoodsQuantity As Quantity
			FROM	prd.tblFormulasDtl D
						INNER JOIN prd.tblFormulasHdr H ON (D.SerialNo = H.SerialNo) AND (D.ProductID = H.ProductID) 
			WHERE  (H.ProductID = ''' + @ProductID + ''') AND ' + @StrWhere + '
			UNION All
			SELECT	H.ProductID, D.GoodsID, (tblTemp.Quantity / H.ProductCount) * D.GoodsQuantity As Quantity
			FROM	prd.tblFormulasDtl D
						INNER JOIN prd.tblFormulasHdr H ON (D.SerialNo = H.SerialNo) AND (D.ProductID = H.ProductID) , tblTemp
			WHERE  (H.ProductID = tblTemp.GoodsID) AND ' + @StrWhere + '
		)
		insert  into #tbl_Avail_Tmp (GoodsID, Quantity)
		select	tblTemp.GoodsID, sum(tblTemp.Quantity) Quantity
		from	tblTemp 
			inner join inv.tblGoods G on (tblTemp.GoodsID = G.GoodsID) and (G.CodeClosed = 0)
		where tblTemp.GoodsID in (select ProductID from prd.tblFormulasHdr where OutSourcing = 0)
		group by tblTemp.GoodsID '

		print @StrSelect;
		exec sp_executesql @StrSelect;
		
		fetch next from crs_Prods into @ProductID, @ProductQty, @FormulaNo
	end;

	close crs_Prods;
	deallocate crs_Prods; 
	
	select *
	from #tbl_Avail_Tmp

END
GO
