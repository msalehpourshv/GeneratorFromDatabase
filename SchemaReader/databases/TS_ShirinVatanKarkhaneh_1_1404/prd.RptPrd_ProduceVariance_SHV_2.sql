USE TS_ShirinVatanKarkhaneh_1_1404
GO
SET ANSI_NULLS, QUOTED_IDENTIFIER ON
GO

-- =============================================================================================
-- =============================================================================================
-- =============================================================================================
CREATE PROCEDURE [prd].[RptPrd_ProduceVariance_SHV_2]
	@FiscalYearFr	int = 0,
	@FiscalYearTo	int = 0,
	@SerialNoFr		int = 0,
	@SerialNoTo		int = 0,
	@DocDateFr		char(10) = Null,
	@DocDateTo		char(10) = Null,
	@SelectedProds	int = 0,
	@SelectedGoods	int = 0,
	@SelectedAcnt1	int = 0,
	@SelectedAcnt2	int = 0,
	@SelectedAcnt3	int = 0,
	@SelectedAcnt4	int = 0,
	@ProductID      Varchar(20) = Null,
	@GoodsID        Varchar(20) = Null,
	@RepOptions		NVarChar(200) = '1111',
	@RepInfo		NVarChar(100) = '1@1@1' -- bit array options
WITH ENCRYPTION
AS
DECLARE @StrSelect	NVarChar(MAX)
DECLARE @StrSelect2 NVarChar(MAX)
DECLARE @StrFrom	NVarChar(MAX)
DECLARE @StrWhere	NVarChar(MAX)
DECLARE @StrWhere2	NVarChar(MAX)

DECLARE	@LangID		Char(1);
DECLARE	@SessionNo	Int; -- برای حالت کدهای انتخابی
DECLARE	@ReportID	Int; -- برای حالت کدهای انتخابی
DECLARE	@Round		Int;
DECLARE	@procs		varchar(20);
DECLARE	@70			bit;
DECLARE	@82			bit;
DECLARE	@Accept		bit;
DECLARE	@Failed		bit;
DECLARE	@TaskSerialNoFR		Int;
DECLARE	@TaskSerialNoTo		Int;

BEGIN

	SET NOCOUNT ON;

	-- I N I T ------------------------------------------------------------
	IF (@RepInfo		Is Null)	SET @RepInfo = '1@1@1';
	IF (@RepOptions		Is Null)	SET @RepOptions = '111111';

	IF (@SelectedGoods	Is Null)	SET @SelectedGoods = 0;
	IF (@SelectedProds	Is Null)	SET @SelectedProds = 0;
	IF (@SelectedAcnt1	Is Null)	SET @SelectedAcnt1 = 0;
	IF (@SelectedAcnt2	Is Null)	SET @SelectedAcnt2 = 0;
	IF (@SelectedAcnt3	Is Null)	SET @SelectedAcnt3 = 0;
	IF (@SelectedAcnt4	Is Null)	SET @SelectedAcnt4 = 0;

	SET @LangID		= pub.funSplitString(@RepInfo, '@', 1);
	SET @SessionNo	= pub.funSplitString(@RepInfo, '@', 2);
	SET @ReportID	= pub.funSplitString(@RepInfo, '@', 3);
	
	SET @TaskSerialNoFR= pub.funSplitString(@RepInfo, '@', 7);
	SET @TaskSerialNoTo= pub.funSplitString(@RepInfo, '@', 8);

 
	set @70 = Substring(@RepOptions, 1, 1);
	set @82 = Substring(@RepOptions, 2, 1);
	set @Accept = Substring(@RepOptions, 3, 1);
	set @Failed = Substring(@RepOptions, 4, 1);

	set @Round = 1;

	select @Round = SettingValue
	from pub.tblSettings
	where SettingKey = 'QuantityDecimals'
	---------------------------------------------------------------------------
	create table #tbl_ProduceVariance_Goods
	(
		GoodsID varchar(20) collate arabic_cs_as
	);
	create table #tbl_ProduceVariance_Prods
	(
		ProductID varchar(20) collate arabic_cs_as
	);
	
	if (@SelectedGoods = 0)
	begin
		insert into #tbl_ProduceVariance_Goods
		select distinct GoodsID
		from inv.tblGoodsDtl
	end
	else
	begin
		set @StrSelect = '
		insert into #tbl_ProduceVariance_Goods
		select distinct GoodsID
		from inv.tblGoodsDtl
		where ' + pub.funGetFilterString(@SessionNo, @ReportID, @SelectedGoods, 'GoodsID') 
		print @StrSelect 
		exec sp_executesql @StrSelect 
	end
	
	if (@SelectedProds = 0)
	begin
		insert into #tbl_ProduceVariance_Prods
		select distinct ProductID
		from prd.tblFormulasDtl
	end
	else
	begin
		set @StrSelect = '
		insert into #tbl_ProduceVariance_Prods
		select distinct ProductID
		from prd.tblFormulasDtl
		where ' + pub.funGetFilterString(@SessionNo, @ReportID, @SelectedProds, 'ProductID')
		
		print @StrSelect 
		exec sp_executesql @StrSelect 
	end
	
	-- WHERE SECTION ----------------------------------------------------------
	SET @procs = '0'
	
	if (@70 = 1)
		SET @procs = @procs + ', 70'
	if (@82 = 1)
		SET @procs = @procs + ', 82'
	
	SET @StrWhere2 = '1 = 1'
	SET @StrWhere = '(D.ProcessID in (' + @procs + '))'
	
	if (@Accept = 0)
		SET @StrWhere = @StrWhere + ' AND 
		isnull((
			select AcceptableCount
			from pln.tblTaskOrderDtl T
			where T.ProcessID=D.BaseProcessID and T.ProcessNo=D.BaseProcessNo and T.FiscalYear=D.BaseFiscalYear and T.SerialNo=D.BaseSerialNo and T.DocRowNo=D.BaseDocRowNo),0)=0'

	if (@Failed = 0)
		SET @StrWhere = @StrWhere + ' AND 
		isnull((
			select UnacceptableCount
			from pln.tblTaskOrderDtl T
			where T.ProcessID=D.BaseProcessID and T.ProcessNo=D.BaseProcessNo and T.FiscalYear=D.BaseFiscalYear and T.SerialNo=D.BaseSerialNo and T.DocRowNo=D.BaseDocRowNo),0)=0'
	
	if (@SerialNoFr is not null) and (@SerialNoFr > 0)
		SET @StrWhere = @StrWhere + ' AND (H.BaseSerialNo >= ' + LTrim(STR(@SerialNoFr)) + ')'
	if (@SerialNoTo is not null) and (@SerialNoTo > 0)
		SET @StrWhere = @StrWhere + ' AND (H.BaseSerialNo <= ' + LTrim(STR(@SerialNoTo)) + ')'
	
	if @DocDateFr Is Not Null And @DocDateFr <> ''
		SET @StrWhere = @StrWhere + ' AND (H.DocDate >= ''' + @DocDateFr + ''')'
	if @DocDateTo Is Not Null And @DocDateTo <> ''
		SET @StrWhere = @StrWhere + ' AND (H.DocDate <= ''' + @DocDateTo + ''')'

	--If (@SelectedGoods > 0)
	--	SET @StrWhere = @StrWhere + ' AND ' + pub.funGetFilterString(@SessionNo, @ReportID, @SelectedGoods, 'D.GoodsID') 
	If (@SelectedProds > 0)
		SET @StrWhere = @StrWhere + ' AND ' + pub.funGetFilterString(@SessionNo, @ReportID, @SelectedProds, 'H.ProductID') 

	If (@SelectedAcnt1 > 0)
		SET @StrWhere = @StrWhere + ' AND ' + pub.funGetFilterString(@SessionNo, @ReportID, @SelectedAcnt1, 'D.AcntCode')
	If (@SelectedAcnt2 > 0)
		SET @StrWhere = @StrWhere + ' AND ' + pub.funGetFilterString(@SessionNo, @ReportID, @SelectedAcnt2, 'D.AcntCode')
	If (@SelectedAcnt3 > 0)
		SET @StrWhere = @StrWhere + ' AND ' + pub.funGetFilterString(@SessionNo, @ReportID, @SelectedAcnt3, 'D.AcntCode')
	If (@SelectedAcnt4 > 0)
		SET @StrWhere = @StrWhere + ' AND ' + pub.funGetFilterString(@SessionNo, @ReportID, @SelectedAcnt4, 'D.AcntCode')
		
    -- ======================================================== Product And Goods Filter
	if @ProductID <> '' And @ProductID is not null
		SET @StrWhere2 = @StrWhere2 + ' AND ProductID = ''' + LTrim(Rtrim(@ProductID)) + ''''

	if @GoodsID <> '' And @GoodsID is not null
		SET @StrWhere2 = @StrWhere2 + ' AND GoodsID = ''' + LTrim(Rtrim(@GoodsID)) + ''''
	
	--if (@TaskSerialNoFR is not null) and (@TaskSerialNoFR > 0)
	--	SET @StrWhere = @StrWhere + ' AND (D.BaseSerialNo >= ' + LTrim(STR(@TaskSerialNoFR)) + ')'
	--if (@TaskSerialNoTo is not null) and (@SerialNoTo > 0)
	--	SET @StrWhere = @StrWhere + ' AND (D.BaseSerialNo <= ' + LTrim(STR(@TaskSerialNoTo)) + ')'
				
	-------------------------------------------------
	-- SELECT SECTION -------------------------------
	--DROP TABLE #tbl_Prd_ProduceVariance_Total

	CREATE TABLE #tbl_Prd_ProduceVariance_Total
	(
		ProcessID		         int	                          null,
		ProcessNo		         int                              null,
		FiscalYear		         int                              null,
		SerialNo		         int                              null,
		ProductID		         varchar(20) collate arabic_cs_as null,
		FormulaNo		         int                              null,
		GoodsID			         varchar(20) collate arabic_cs_as null,
		ProdQuantity	         float                            null,
		SentQuantity	         float                            null,
		BaseFiscalYear	         smallint                         null,
		BaseSerialNo	         int                              null,
		BaseDocRowNo	         int                              null,
		DocDate		             char(10)                         null,
		GoodsAmount		         float                            null,
		Task_RowNo   	         int                              null,
		Standard_Prs_Count       int                              null,
		Used_Prs_Count           int                              null,
		ProducedCount_Sum        float                            null,
		ProductCountStandard     float                            null,
		ProductCount_Done        float                            null
		--OrderCount               float                            null,
		--ProducedCount_Row        float                            null,
		--ProducedCount_Sum        float                            null,
		--TotalTimeMin             float                            null,
		--ProductCountStandardBase float                            null,
		--TimeCountStandardBase    float                            null
	);
	
	SET @StrSelect = '
    INSERT INTO #tbl_Prd_ProduceVariance_Total(ProcessID, ProcessNo, FiscalYear, SerialNo, ProductID, FormulaNo, GoodsID, ProdQuantity, SentQuantity, 
                                               BaseFiscalYear, BaseSerialNo, BaseDocRowNo, DocDate, GoodsAmount, Task_RowNo, Standard_Prs_Count, Used_Prs_Count, 
											   ProducedCount_Sum, ProductCountStandard, ProductCount_Done)
    SELECT ProcessID, ProcessNo, FiscalYear, SerialNo, ProductID, FormulaNo, GoodsID, ProductCount, Goods_Used_Qty, BaseFiscalYear,
           BaseSerialNo, BaseDocRowNo, DocDate, GoodsAmount, Task_RowNo, Standard_Prs_Count, Used_Prs_Count, ProducedCount_Sum,
           Round(Case When TimeCountStandardBase * ProductCountStandardBase = 0 Then 
	                  0
                 Else 
			          TotalTimeMin * 60 / Cast(TimeCountStandardBase / ProductCountStandardBase As Float)
                 End, 0
    			) ProductCountStandard,
           (
	        Round(Case When TimeCountStandardBase * ProductCountStandardBase = 0 Then 
	                   0
                  Else 
			           TotalTimeMin * 60 / Cast(TimeCountStandardBase / ProductCountStandardBase As Float)
                  End, 0
			     ) / Case When Standard_Prs_Count > 0 Then Standard_Prs_Count Else 1 End
           ) * Used_Prs_Count ProductCount_Done
    FROM
    (
         SELECT H.ProcessID, H.ProcessNo, H.FiscalYear, H.SerialNo, H.ProductID, H.FormulaNo, D.GoodsID, H.ProductCount, SUM(D.GoodsQuantity) Goods_Used_Qty,
                H.BaseFiscalYear, H.BaseSerialNo, D.BaseDocRowNo, H.DocDate,
                Case When D.GoodsAmount > 0 Then 
                         D.GoodsAmount
                Else
		           (
                    Select GoodsAmount
                    From 
                       (
                         Select Top 1 DocDate, GoodsAmount
                         From inv.tblStorageDocsDtl
                         Where GoodsID = D.GoodsID And GoodsAmount > 0
                         Order By DocDate Desc
                       ) A
		            )
                End GoodsAmount,
                TD.RowNo Task_RowNo, PS.OperatorCount Standard_Prs_Count, TD.PersonCount Used_Prs_Count, TH.OrderCount, TD.AcceptableCount ProducedCount_Row,
                ( 
                  Select Sum(AcceptableCount) 
		          From pln.tblTaskOrderDtl
		          Where ProcessID = H.BaseProcessID and ProcessNo = H.BaseProcessNo and 
	                    FiscalYear = H.BaseFiscalYear and SerialNo = H.BaseSerialNo
		        ) ProducedCount_Sum,
	            IsNull((
		                 Select Sum(TotalTime) 
		                 From pln.tblTaskOrderDtl TD2
		                 Where TD2.ProcessID = H.BaseProcessID  and TD2.ProcessNo=H.BaseProcessNo and TD2.FiscalYear=H.BaseFiscalYear and TD2.SerialNo=H.BaseSerialNo ),0)/60 TotalTimeMin,
                IsNull((
		                 Select ProductCount 
		                 From prd.tblFormulasHdr F2 
		                 Where F2.ProductID = H.ProductID  and F2.SerialNo = D.FormulaNo), 0) ProductCountStandardBase,
                IsNull((
			             Select Sum(ProduceStepTime)
					     From pln.tblProduceStepDtl S2
					     Where S2.ProductID = H.ProductID and S2.SerialNo=TH.ProduceStepSerialNo), 0) TimeCountStandardBase
         FROM	inv.tblStorageDocsDtl    D '
	SET @StrSelect2 = '
         INNER JOIN inv.tblStorageDocsHdr H on H.ProcessID = D.ProcessID and H.ProcessNo = D.ProcessNo and H.FiscalYear = D.FiscalYear and H.SerialNo = D.SerialNo
         INNER JOIN pln.tblTaskOrderDtl   TD ON TD.ProcessID = D.BaseProcessID and TD.ProcessNo = D.BaseProcessNo and 
                                                TD.FiscalYear = D.BaseFiscalYear and TD.SerialNo = D.BaseSerialNo And 
                                                TD.DocRowNo = D.BaseDocRowNo
         INNER JOIN pln.tblTaskOrderHdr   TH ON TD.ProcessID = TH.ProcessID and TD.ProcessNo = TH.ProcessNo and 
                                                TD.FiscalYear = TH.FiscalYear and TD.SerialNo = TH.SerialNo
         INNER JOIN pln.tblProduceStepDtl PS ON PS.ProductID = H.ProductID And PS.SerialNo = TD.ProduceStepSerialNo
         WHERE' + @StrWhere + '
         GROUP BY H.ProcessID, H.ProcessNo, H.FiscalYear, H.SerialNo, H.ProductID, H.FormulaNo, D.GoodsID, H.ProductCount, 
	              H.BaseFiscalYear, H.BaseSerialNo, D.BaseDocRowNo, H.DocDate, D.GoodsAmount, TD.PersonCount, TH.OrderCount, 
		          TD.AcceptableCount, TD.RowNo, PS.OperatorCount, H.BaseProcessID, H.BaseProcessNo, D.FormulaNo,
			      TH.ProduceStepSerialNo
    ) A
'
    
	Print @StrSelect;
	Print @StrSelect2;
	SET @StrSelect = @StrSelect + @StrSelect2
	Exec sp_executesql @StrSelect;

    --Select * 
    --From #tbl_Prd_ProduceVariance_Total
    --Where 1 = 1
    --    And Case When @ProductID    <> '' Then ProductID    Else '' End IN (Case When @ProductID    <> '' Then @ProductID    Else '' End)
    --    And Case When @GoodsID      <> '' Then GoodsID      Else '' End IN (Case When @GoodsID      <> '' Then @GoodsID      Else '' End)
    --    And Case When @FiscalYearFr <> 0  Then FiscalYear   Else 0  End >=  Case When @FiscalYearFr <> 0  Then @FiscalYearFr Else 0  End
    --    And Case When @FiscalYearTo <> 0  Then FiscalYear   Else 0  End <=  Case When @FiscalYearTo <> 0  Then @FiscalYearTo Else 0  End
    --    And Case When @SerialNoFr   <> 0  Then BaseSerialNo Else 0  End >=  Case When @SerialNoFr   <> 0  Then @SerialNoFr   Else 0  End
    --    And Case When @SerialNoTo   <> 0  Then BaseSerialNo Else 0  End <=  Case When @SerialNoTo   <> 0  Then @SerialNoTo   Else 0  End
    --    And Case When @DocDateFr    <> '' Then DocDate      Else '' End >=  Case When @DocDateFr    <> '' Then @DocDateFr    Else '' End
    --    And Case When @DocDateTo    <> '' Then DocDate      Else '' End <=  Case When @DocDateTo    <> '' Then @DocDateTo    Else '' End

	-- ==================================================================================================================================
	-- ================================================================================================================================== Last Select
	-- ==================================================================================================================================
	SET @StrSelect = '
	-- ==============================================================================================================================================
	SELECT M.*, 
          [pub].[funGetGoodsName](M.ProductID, ' + LTrim(RTrim(Str(@LangID))) + ') As ProductName, 
	      [pub].[funGetGoodsName](M.GoodsID, ' + LTrim(RTrim(Str(@LangID))) + ') As GoodsName, 
		  [pub].[funGetGoodsUnitName] (M.GoodsID, ' + LTrim(RTrim(Str(@LangID))) + ') As UnitName, 
		  [pub].[funGetGoodsUnitName] (M.ProductID, ' + LTrim(RTrim(Str(@LangID))) + ') As ProductUnitName
	FROM
	(	
		Select ProcessID, ProcessNo, FiscalYear, SerialNo, ProductID, FormulaNo, GoodsID, SentQuantity, FormulaQuantity, +1 as Kind, BaseFiscalYear, 
		       BaseSerialNo, BaseDocRowNo, DocDate, ProdQuantity, GoodsAmount, Task_RowNo, Standard_Prs_Count, Used_Prs_Count, ProducedCount_Row, 
			   ProducedCount_Sum, ProductCountStandard, ProductCount_Done
		From
		(
			Select	T.ProcessID, T.ProcessNo, T.FiscalYear, T.SerialNo, T.ProductID, T.FormulaNo, T.GoodsID, T.SentQuantity,
					T.BaseFiscalYear, T.BaseSerialNo, T.BaseDocRowNo, T.DocDate, T.ProdQuantity,
					IsNull((
						     Select sum(D.GoodsQuantity / H.ProductCount)
						     From prd.tblFormulasDtl D 
							 Inner Join prd.tblFormulasHdr H on H.ProductID = D.ProductID and H.SerialNo = D.SerialNo
						     Where (D.ProductID = T.ProductID) and (D.SerialNo = T.FormulaNo) and (D.GoodsID = T.GoodsID)
					), 0) * T.ProdQuantity as FormulaQuantity, GoodsAmount,
                    Task_RowNo, Standard_Prs_Count, Used_Prs_Count, T.ProdQuantity ProducedCount_Row, ProducedCount_Sum, 
					ProductCountStandard, ProductCount_Done
			From	#tbl_Prd_ProduceVariance_Total T
					inner join #tbl_ProduceVariance_Goods G on G.GoodsID=T.GoodsID
		) X
		--where (round(X.SentQuantity, ' + LTrim(RTrim(Str(@Round))) + ') > round(X.FormulaQuantity, ' + LTrim(RTrim(Str(@Round))) + ')) --Or 
			   --round(X.SentQuantity, ' + LTrim(RTrim(Str(@Round))) + ') = round(X.FormulaQuantity, ' + LTrim(RTrim(Str(@Round))) + '))
		--union all
		--select ProcessID, ProcessNo, FiscalYear, SerialNo, ProductID, FormulaNo, GoodsID, SentQuantity, FormulaQuantity, -1 as Kind,
		--	   BaseFiscalYear, BaseSerialNo, BaseDocRowNo, DocDate, ProdQuantity,GoodsAmount
		--from
		--(
		--	select	SH.ProcessID, SH.ProcessNo, SH.FiscalYear, SH.SerialNo, SH.ProductID, SH.FormulaNo, FD.GoodsID, SH.BaseFiscalYear, SH.BaseSerialNo, SH.BaseDocRowNo,
		--			SH.DocDate, SH.ProdQuantity, Sum(GoodsAmount) GoodsAmount,
		--			isnull((
		--				    select sum(SD.SentQuantity)
		--				    from #tbl_Prd_ProduceVariance_Total SD
		--				    where (SD.FiscalYear = SH.FiscalYear) and (SD.SerialNo = SH.SerialNo) and (SD.GoodsID = FD.GoodsID)
		--			      ), 0) as SentQuantity,
		--			sum(FD.GoodsQuantity / FH.ProductCount) * SH.ProdQuantity as FormulaQuantity
		--	from prd.tblFormulasDtl FD 
		--			inner join prd.tblFormulasHdr FH on FH.ProductID = FD.ProductID and FH.SerialNo = FD.SerialNo
		--			inner join 
		--				(
		--					select distinct ProcessID, ProcessNo, FiscalYear, SerialNo, ProductID, FormulaNo, ProdQuantity, 
		--					                GoodsAmount, BaseFiscalYear, BaseSerialNo, BaseDocRowNo, DocDate
		--					from #tbl_Prd_ProduceVariance_Total
		--				) SH on SH.ProductID = FD.ProductID and SH.FormulaNo = FD.SerialNo
		--			inner join #tbl_ProduceVariance_Prods P on P.ProductID=FD.ProductID
		--			inner join #tbl_ProduceVariance_Goods G on G.GoodsID=FD.GoodsID
		--	group by SH.ProcessID, SH.ProcessNo, SH.FiscalYear, SH.SerialNo, SH.ProductID, SH.FormulaNo, FD.GoodsID, SH.ProdQuantity,
		--			 SH.BaseFiscalYear, SH.BaseSerialNo, SH.BaseDocRowNo, SH.DocDate, SH.ProdQuantity--, SH.GoodsAmount
		--) X
		----where (round(X.FormulaQuantity, ' + LTrim(RTrim(Str(@Round))) + ') > round(X.SentQuantity, ' + LTrim(RTrim(Str(@Round))) + '))	
	) M
	WHERE ' + @StrWhere2 + '
    ORDER BY M.FiscalYear, M.SerialNo, M.GoodsID
	'

	-- ============================
	--Print @StrSelect
	EXEC  sp_executesql @StrSelect 

END
GO
