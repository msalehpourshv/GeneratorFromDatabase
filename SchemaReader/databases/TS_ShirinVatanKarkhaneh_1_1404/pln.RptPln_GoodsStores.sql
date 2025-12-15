USE TS_ShirinVatanKarkhaneh_1_1404
GO
SET ANSI_NULLS, QUOTED_IDENTIFIER ON
GO
-- =========== TS-QC:UPDATED ====================
-- Author		 : TakroSystem\Zia
-- Create date   : 1389/10/06
-- Viewed By	 : 
-- Last Modified : 
-- Last Modifier : 
-- Description	 : 
-- ==============================================
CREATE PROCEDURE [pln].[RptPln_GoodsStores]
	@SelectedGoods	Int = 0,
	@SelectedDepts	Int = 0,
	@SelectedProds	int = 0,
	@SelectedStore1	int = 0,
	@SelectedStore2	int = 0,
	@SelectedStore3	int = 0,
	@SelectedStore4	int = 0,
	@SelectedProd	VarChar(20) = Null,
	@FormulaSerial	int = 0, -- 0 = default
	@SortFields		NVarChar(100) = Null,
	@ExtraParams	NVarChar(100) = '',
	@RepOptions		VarChar(10) = '',  -- bit array options
	@RepInfo		NVarChar(100) = '1@1@1'
WITH ENCRYPTION
AS
DECLARE @StrSelect	NVarChar(4000)
DECLARE @StrWhere0	NVarChar(4000)
DECLARE @StrWhere1	NVarChar(4000)
DECLARE @StrWhere2	NVarChar(4000)
DECLARE @StrFrom	NVarChar(4000)

DECLARE	@LangID		Char(1);
DECLARE	@SessionNo	Int; 
DECLARE	@ReportID	Int; 
Begin
	SET NOCOUNT ON;

	-- I N I T -----------------------------------------------------------------
	IF (@RepInfo		Is Null)	SET @RepInfo = '1@1@1';
	IF (@RepOptions		Is Null)	SET @RepOptions	= '';
	IF (@ExtraParams	Is Null)	SET @ExtraParams= '';

	IF (@SelectedProds	Is Null)	SET @SelectedProds = 0;
	IF (@SelectedGoods	Is Null)	SET @SelectedGoods = 0;
	IF (@SelectedDepts	Is Null)	SET @SelectedDepts = 0;
	IF (@SelectedStore1	Is Null)	SET @SelectedStore1 = 0;
	IF (@SelectedStore2	Is Null)	SET @SelectedStore2 = 0;
	IF (@SelectedStore3	Is Null)	SET @SelectedStore3 = 0;
	IF (@SelectedStore4	Is Null)	SET @SelectedStore4 = 0;
	IF (@SortFields		Is Null)	SET @SortFields = 'GoodsID';
	IF (@SortFields		= '')		SET @SortFields = 'GoodsID';
	IF (@SelectedProd	= '')		set @SelectedProd = null;

	SET @LangID		= pub.funSplitString(@RepInfo, '@', 1);
	SET @SessionNo	= pub.funSplitString(@RepInfo, '@', 2);
	SET @ReportID	= pub.funSplitString(@RepInfo, '@', 3);
	---------------------------------------------------------------------------
	-- W H E R E --------------------------------------------------------------
	SET @StrWhere1 = '(1=1)'
	SET @StrWhere2 = '(1=1)'

	IF (@SelectedGoods > 0)
		SET @StrWhere1 = @StrWhere1 + ' AND ' + pub.funGetFilterString(@SessionNo, @ReportID, @SelectedGoods, 'D.GoodsID')

	IF (@SelectedStore1 > 0)
		SET @StrWhere2 = @StrWhere2 + ' AND ' + pub.funGetFilterString(@SessionNo, @ReportID, @SelectedStore1, 'T1.StoreID')
	IF (@SelectedStore2 > 0)
		SET @StrWhere2 = @StrWhere2 + ' AND ' + pub.funGetFilterString(@SessionNo, @ReportID, @SelectedStore2, 'T2.StoreID')
	IF (@SelectedStore3 > 0)
		SET @StrWhere2 = @StrWhere2 + ' AND ' + pub.funGetFilterString(@SessionNo, @ReportID, @SelectedStore3, 'T3.StoreID')

--	IF (@SelectedDepts > 0)
--		SET @StrWhereD = @StrWhereD + ' AND ' + pub.funGetFilterString(@SessionNo, @ReportID, @SelectedDepts, 'DP.DepartmentID')
--	IF (@SelectedDepts > 0)
--		SET @StrWhere = @StrWhere + ' AND ((select count(*) from pln.tblProduceStepDtl DP where ' + @StrWhereD + ') > 0)'

	---------------------------------------------------------------------------
	set @StrFrom = 'pln.tblGoodsStores D'
	
	if (@SelectedProd is not null)
		set @StrFrom = @StrFrom + ' inner join #tblProdGoods P on P.GoodsID = D.GoodsID '
	-- S E L E C T ------------------------------------------------------------
	if (@FormulaSerial <> 0) 
		set @StrWhere0 = '(H.SerialNo = ' + Str(@FormulaSerial) + ')'
	else
		set @StrWhere0 = '(H.IsDefault = 1)' 

	if (@SelectedProd is not null)
	begin
		
		create table #tblProdGoods
		(
			GoodsID varchar(20) collate arabic_cs_as
		);

		SET @StrSelect = '
		with tblTemp(GoodsID) AS
		(
			select	D.GoodsID
			from	prd.tblFormulasDtl D
						inner join prd.tblFormulasHdr H on (D.SerialNo = H.SerialNo) and (D.ProductID = H.ProductID) and (' + @StrWhere0 + ') 
			where	D.ProductID = ''' + @SelectedProd + '''
			union	all
			select	D.GoodsID
			from	prd.tblFormulasDtl D
						inner join prd.tblFormulasHdr H on (D.SerialNo = H.SerialNo) and (D.ProductID = H.ProductID) and (' + @StrWhere0 + '), tblTemp
			where	(H.ProductID = tblTemp.GoodsID)
		)
		insert into	#tblProdGoods
		select	distinct T.GoodsID
		from	tblTemp T '
	end;

	PRINT @StrSelect;
	EXEC sp_executesql @StrSelect;

	SET @StrSelect = '
	select	distinct G0.GoodsID, T1.StoreID as StoreID1, T2.StoreID as StoreID2, T3.StoreID as StoreID3, [pub].[funGetGoodsName](G0.GoodsID,1) GoodsName, 
			S1.StoreName as StoreName1, S2.StoreName as StoreName2, S3.StoreName as StoreName3
	from  
	(  
		select distinct D.GoodsID  
		from ' + @StrFrom + '
		where ' + @StrWhere1 + '
	) G0  
		LEFT JOIN pln.tblGoodsStores T1 ON T1.GoodsID = G0.GoodsID and T1.StoreType = 1 
		LEFT JOIN pln.tblGoodsStores T2 ON T2.GoodsID = G0.GoodsID and T2.StoreType = 2 
		LEFT JOIN pln.tblGoodsStores T3 ON T3.GoodsID = G0.GoodsID and T3.StoreType = 3 
		LEFT JOIN inv.tblStoresDtl S1 ON S1.StoreID = T1.StoreID  
		LEFT JOIN inv.tblStoresDtl S2 ON S2.StoreID = T2.StoreID  
		LEFT JOIN inv.tblStoresDtl S3 ON S3.StoreID = T3.StoreID  
	where ' + @StrWhere2 + '
	order by ' + @SortFields
   	---------------------------------------------------------------------------
	---------------------------------------------------------------------------
	PRINT @StrSelect;
	EXEC sp_executesql @StrSelect;
	---------------------------------------------------------------------------
End
GO
