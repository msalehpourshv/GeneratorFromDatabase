USE TS_ShirinVatanKarkhaneh_1_1404
GO
SET ANSI_NULLS, QUOTED_IDENTIFIER ON
GO
-- =========== TS-QC:UPDATED ====================
-- Author		 : TakroSystem\Zia
-- Create date   : 1390/10/11
-- Viewed By	 : 
-- Last Modified : 1392/10/21
-- Last Modifier : TakroSystem\Hamid
-- Description   : <لیست انحرافات تولید نسبت به فرمول تولید>
-- =================================================================
Create PROCEDURE prd.RptPrd_ProduceVariance
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
	@ProductID		Varchar(20) = Null,
	@GoodsID		Varchar(20) = Null,
	@RepOptions		NVarChar(200) = '1111',
	@RepInfo		NVarChar(100) = '1@1@1' -- bit array options
WITH ENCRYPTION
AS
DECLARE @StrSelect	NVarChar(max)
DECLARE @StrFrom	NVarChar(2000)
DECLARE @StrWhere	NVarChar(2000)

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
declare @Pln_RegInOutInAnyStepForTask as bit;
declare @DontShowZeroOffset as bit;
Declare @QuantityDecimals as int;
Declare @PriceDecimals	  as int;
Declare @ShowZeroDecimals as int;

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
	
	SET @TaskSerialNoFR		= pub.funSplitString(@RepInfo, '@', 7);
	SET @TaskSerialNoTo		= pub.funSplitString(@RepInfo, '@', 8);
	SET @DontShowZeroOffset = pub.funSplitString(@RepInfo, '@', 9);
	SET @QuantityDecimals	= pub.funSplitString(@RepInfo, '@', 10);
	SET @PriceDecimals		= pub.funSplitString(@RepInfo, '@', 11);
	SET @ShowZeroDecimals   = pub.funSplitString(@RepInfo, '@', 12);

 
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
		SET @StrWhere = @StrWhere + ' AND (H.SerialNo >= ' + LTrim(STR(@SerialNoFr)) + ')'
	if (@SerialNoTo is not null) and (@SerialNoTo > 0)
		SET @StrWhere = @StrWhere + ' AND (H.SerialNo <= ' + LTrim(STR(@SerialNoTo)) + ')'
	
	if (@DocDateFr is not null) 
		SET @StrWhere = @StrWhere + ' AND (H.DocDate >= ''' + @DocDateFr + ''')'
	if (@DocDateTo is not null)
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
		
	if (@ProductID is not null) 
		SET @StrWhere = @StrWhere + ' AND (H.ProductID = ''' + LTrim(@ProductID) + ''')'
		
	if (@GoodsID is not null)
		SET @StrWhere = @StrWhere + ' AND (D.GoodsID = ''' + LTrim(@GoodsID) + ''')'
	
	if (@TaskSerialNoFR is not null) and (@TaskSerialNoFR > 0)
		SET @StrWhere = @StrWhere + ' AND (D.BaseSerialNo >= ' + LTrim(STR(@TaskSerialNoFR)) + ')'
	if (@TaskSerialNoTo is not null) and (@TaskSerialNoTo > 0)
		SET @StrWhere = @StrWhere + ' AND (D.BaseSerialNo <= ' + LTrim(STR(@TaskSerialNoTo)) + ')'
				
	-------------------------------------------------
	-- SELECT SECTION -------------------------------
	create table #tbl_Prd_ProduceVariance_Total
	(
		FiscalYear		int	not null,
		SerialNo		int	not null,
		ProductID		varchar(20) collate arabic_cs_as not null,
		FormulaNo		int	not null,
		GoodsID			varchar(20)	collate arabic_cs_as not null,
		ProdQuantity	float	not null,
		SentQuantity	float	not null,
		BaseFiscalYear	smallint not null,
		BaseSerialNo	int not null,
		BaseDocRowNo	int not null,
		DocDate			char(10) not null,
		GoodsAmount		float	not null,
	);
	
	
select @Pln_RegInOutInAnyStepForTask =SettingValue from pub.tblSettings where SettingKey='Pln_RegInOutInAnyStepForTask'
	set @Pln_RegInOutInAnyStepForTask=isnull(@Pln_RegInOutInAnyStepForTask, 'False')
 if @Pln_RegInOutInAnyStepForTask='False'
	SET @StrSelect = '
	Insert Into #tbl_Prd_ProduceVariance_Total(FiscalYear, SerialNo, ProductID, FormulaNo, GoodsID, ProdQuantity, SentQuantity,
											   BaseFiscalYear, BaseSerialNo, BaseDocRowNo, DocDate,GoodsAmount)
	Select	H.FiscalYear, H.SerialNo, H.ProductID, H.FormulaNo, D.GoodsID, H.ProductCount, SUM(D.GoodsQuantity),
			H.BaseFiscalYear, H.BaseSerialNo, D.BaseDocRowNo, H.DocDate, D.GoodsAmount
	From	inv.tblStorageDocsDtl D
				inner join inv.tblStorageDocsHdr H on H.ProcessID = D.ProcessID and H.ProcessNo = D.ProcessNo and H.FiscalYear = D.FiscalYear and H.SerialNo = D.SerialNo
	Where	' + @StrWhere + '
	Group By H.FiscalYear, H.SerialNo, H.ProductID, H.FormulaNo, D.GoodsID, H.ProductCount, H.BaseFiscalYear, H.BaseSerialNo, D.BaseDocRowNo, H.DocDate, D.GoodsAmount '
else
	SET @StrSelect = '
	Insert Into #tbl_Prd_ProduceVariance_Total(FiscalYear, SerialNo, ProductID, FormulaNo, GoodsID, ProdQuantity, SentQuantity,
											   BaseFiscalYear, BaseSerialNo, BaseDocRowNo, DocDate,GoodsAmount)
	Select	H.FiscalYear, H.SerialNo, H.ProductID, H.FormulaNo, D.GoodsID, H.ProductCount, SUM(D.GoodsQuantity),
			H.BaseFiscalYear, H.BaseSerialNo, D.BaseDocRowNo, H.DocDate, D.GoodsAmount
	From	inv.tblStorageDocsDtl D
				inner join inv.tblStorageDocsHdr H on H.ProcessID = D.ProcessID and H.ProcessNo = D.ProcessNo and H.FiscalYear = D.FiscalYear and H.SerialNo = D.SerialNo
				inner join pln.tblTaskOrderDtl td on D.BaseProcessID = td.ProcessID and D.BaseProcessNo = td.ProcessNo and D.BaseFiscalYear = td.FiscalYear and D.BaseSerialNo = td.SerialNo and D.BaseDocRowNo= td.DocRowNo
	Where	' + @StrWhere + '
	and ProduceStepID in ( select min(ProduceStepID) from pln.tblTaskOrderDtl td where D.BaseProcessID = td.ProcessID and D.BaseProcessNo = td.ProcessNo and D.BaseFiscalYear = td.FiscalYear and D.BaseSerialNo = td.SerialNo)
	Group By H.FiscalYear, H.SerialNo, H.ProductID, H.FormulaNo, D.GoodsID, H.ProductCount, H.BaseFiscalYear, H.BaseSerialNo, D.BaseDocRowNo, H.DocDate, D.GoodsAmount '
		
	Print @StrSelect;
	Exec sp_executesql @StrSelect;
	if @DontShowZeroOffset = 0 
	begin
	Set @StrSelect = '
		SELECT M.*, 
			[pub].[funGetGoodsName](M.ProductID, '+Ltrim(Rtrim(str(@LangID)))+') As ProductName, 
			[pub].[funGetGoodsName](M.GoodsID, '+Ltrim(Rtrim(str(@LangID)))+') As GoodsName, 
			[pub].[funGetGoodsUnitName] (M.GoodsID, '+Ltrim(Rtrim(str(@LangID)))+') As UnitName, 
			[pub].[funGetGoodsUnitName] (M.ProductID, '+Ltrim(Rtrim(str(@LangID)))+') As ProductUnitName
		FROM
		(	
			SELECT FiscalYear, 
				SerialNo, 
				ProductID, 
				FormulaNo, 
				GoodsID, 
				Round(SentQuantity,'+Ltrim(Rtrim(str(@QuantityDecimals)))+') SentQuantity, 
				Round(FormulaQuantity,'+Ltrim(Rtrim(str(@QuantityDecimals)))+') FormulaQuantity, 
				+1 as Kind,
				BaseFiscalYear, 
				BaseSerialNo, 
				BaseDocRowNo, 
				DocDate, 
				ProdQuantity,
				GoodsAmount
			FROM
			(
				SELECT	T.FiscalYear, 
					T.SerialNo, 
					T.ProductID, 
					T.FormulaNo, 
					T.GoodsID, 
					T.SentQuantity,
					T.BaseFiscalYear, 
					T.BaseSerialNo, 
					T.BaseDocRowNo, 
					T.DocDate, 
					T.ProdQuantity,
					isnull((
						SELECT sum(D.GoodsQuantity / H.ProductCount)
						FROM prd.tblFormulasDtl D 
							INNER JOIN prd.tblFormulasHdr H ON H.ProductID = D.ProductID AND H.SerialNo = D.SerialNo
							WHERE (D.ProductID = T.ProductID) AND (D.SerialNo = T.FormulaNo) AND (D.GoodsID = T.GoodsID)
						), 0) * T.ProdQuantity as FormulaQuantity,
					GoodsAmount
				FROM #tbl_Prd_ProduceVariance_Total T
					 INNER JOIN #tbl_ProduceVariance_Goods G ON G.GoodsID=T.GoodsID
			) X
			--WHERE (round(X.SentQuantity, '+Ltrim(Rtrim(str(@Round)))+') > round(X.FormulaQuantity, '+Ltrim(Rtrim(str(@Round)))+')) --OR 
			--	   --round(X.SentQuantity, '+Ltrim(Rtrim(str(@Round)))+') = round(X.FormulaQuantity, '+Ltrim(Rtrim(str(@Round)))+'))
			UNION ALL
			SELECT FiscalYear, 
				SerialNo, 
				ProductID, 
				FormulaNo, 
				GoodsID, 
				SentQuantity, 
				FormulaQuantity, 
				-1 as Kind,
				BaseFiscalYear, 
				BaseSerialNo, 
				BaseDocRowNo, 
				DocDate, 
				ProdQuantity,
				GoodsAmount
			FROM
			(
				SELECT	SH.FiscalYear, 
					SH.SerialNo, 
					SH.ProductID, 
					SH.FormulaNo, 
					FD.GoodsID, 
					SH.BaseFiscalYear, 
					SH.BaseSerialNo, 
					SH.BaseDocRowNo,
					SH.DocDate, 
					SH.ProdQuantity,
					[inv].[funGetLastGoodsAmount](FD.GoodsID,SH.DocDate,0) GoodsAmount,
					isnull((
						SELECT sum(SD.SentQuantity)
						FROM #tbl_Prd_ProduceVariance_Total SD
						WHERE (SD.FiscalYear = SH.FiscalYear) AND (SD.SerialNo = SH.SerialNo) AND (SD.GoodsID = FD.GoodsID)), 0) as SentQuantity,
					sum(FD.GoodsQuantity / FH.ProductCount) * SH.ProdQuantity as FormulaQuantity
				FROM prd.tblFormulasDtl FD 
					INNER JOIN prd.tblFormulasHdr FH ON FH.ProductID = FD.ProductID AND FH.SerialNo = FD.SerialNo
					INNER JOIN 
						(
							SELECT distinct FiscalYear, 
								   SerialNo, 
								   ProductID, 
								   FormulaNo, 
								   ProdQuantity,  
								   BaseFiscalYear, 
								   BaseSerialNo, 
								   BaseDocRowNo, 
								   DocDate
							FROM #tbl_Prd_ProduceVariance_Total
						) SH ON SH.ProductID = FD.ProductID AND SH.FormulaNo = FD.SerialNo
						INNER JOIN #tbl_ProduceVariance_Prods P ON P.ProductID = FD.ProductID
						INNER JOIN #tbl_ProduceVariance_Goods G ON G.GoodsID = FD.GoodsID
				GROUP BY SH.FiscalYear, SH.SerialNo, SH.ProductID, SH.FormulaNo, FD.GoodsID, SH.ProdQuantity,
						 SH.BaseFiscalYear, SH.BaseSerialNo, SH.BaseDocRowNo, SH.DocDate, SH.ProdQuantity
			) X
			WHERE X.SentQuantity=0 --(round(X.FormulaQuantity, '+Ltrim(Rtrim(str(@Round)))+') > round(X.SentQuantity, '+Ltrim(Rtrim(str(@Round)))+'))	
		) M	
		ORDER BY M.FiscalYear, M.SerialNo, M.GoodsID'
	Print @StrSelect;
	Exec sp_executesql @StrSelect;
	end
	else
	begin
	Set @StrSelect = '
	SELECT M.*, 
			[pub].[funGetGoodsName](M.ProductID, '+Ltrim(Rtrim(str(@LangID)))+') As ProductName, 
			[pub].[funGetGoodsName](M.GoodsID, '+Ltrim(Rtrim(str(@LangID)))+') As GoodsName, 
			[pub].[funGetGoodsUnitName] (M.GoodsID, '+Ltrim(Rtrim(str(@LangID)))+') As UnitName, 
			[pub].[funGetGoodsUnitName] (M.ProductID, '+Ltrim(Rtrim(str(@LangID)))+') As ProductUnitName
		FROM
		(	
			SELECT FiscalYear, 
				SerialNo, 
				ProductID, 
				FormulaNo, 
				GoodsID, 
				Round(SentQuantity,'+Ltrim(Rtrim(str(@QuantityDecimals)))+') SentQuantity, 
				Round(FormulaQuantity,'+Ltrim(Rtrim(str(@QuantityDecimals)))+') FormulaQuantity, 
				+1 as Kind,
				BaseFiscalYear, 
				BaseSerialNo, 
				BaseDocRowNo, 
				DocDate, 
				ProdQuantity,
				GoodsAmount
			FROM
			(
				SELECT	T.FiscalYear, 
					T.SerialNo, 
					T.ProductID, 
					T.FormulaNo, 
					T.GoodsID, 
					T.SentQuantity,
					T.BaseFiscalYear, 
					T.BaseSerialNo, 
					T.BaseDocRowNo, 
					T.DocDate, 
					T.ProdQuantity,
					isnull((
						SELECT sum(D.GoodsQuantity / H.ProductCount)
						FROM prd.tblFormulasDtl D 
							INNER JOIN prd.tblFormulasHdr H ON H.ProductID = D.ProductID AND H.SerialNo = D.SerialNo
							WHERE (D.ProductID = T.ProductID) AND (D.SerialNo = T.FormulaNo) AND (D.GoodsID = T.GoodsID)
						), 0) * T.ProdQuantity as FormulaQuantity,
					GoodsAmount
				FROM #tbl_Prd_ProduceVariance_Total T
					 INNER JOIN #tbl_ProduceVariance_Goods G ON G.GoodsID=T.GoodsID
			) X
			--WHERE (round(X.SentQuantity, '+Ltrim(Rtrim(str(@Round)))+') > round(X.FormulaQuantity, '+Ltrim(Rtrim(str(@Round)))+')) --OR 
			--	   --round(X.SentQuantity, '+Ltrim(Rtrim(str(@Round)))+') = round(X.FormulaQuantity, '+Ltrim(Rtrim(str(@Round)))+'))
			UNION ALL
			SELECT FiscalYear, 
				SerialNo, 
				ProductID, 
				FormulaNo, 
				GoodsID, 
				SentQuantity, 
				FormulaQuantity, 
				-1 as Kind,
				BaseFiscalYear, 
				BaseSerialNo, 
				BaseDocRowNo, 
				DocDate, 
				ProdQuantity,
				GoodsAmount
			FROM
			(
				SELECT	SH.FiscalYear, 
					SH.SerialNo, 
					SH.ProductID, 
					SH.FormulaNo, 
					FD.GoodsID, 
					SH.BaseFiscalYear, 
					SH.BaseSerialNo, 
					SH.BaseDocRowNo,
					SH.DocDate, 
					SH.ProdQuantity,
					[inv].[funGetLastGoodsAmount](FD.GoodsID,SH.DocDate,0) GoodsAmount,
					isnull((
						SELECT sum(SD.SentQuantity)
						FROM #tbl_Prd_ProduceVariance_Total SD
						WHERE (SD.FiscalYear = SH.FiscalYear) AND (SD.SerialNo = SH.SerialNo) AND (SD.GoodsID = FD.GoodsID)), 0) as SentQuantity,
					sum(FD.GoodsQuantity / FH.ProductCount) * SH.ProdQuantity as FormulaQuantity
				FROM prd.tblFormulasDtl FD 
					INNER JOIN prd.tblFormulasHdr FH ON FH.ProductID = FD.ProductID AND FH.SerialNo = FD.SerialNo
					INNER JOIN 
						(
							SELECT distinct FiscalYear, 
								   SerialNo, 
								   ProductID, 
								   FormulaNo, 
								   ProdQuantity,  
								   BaseFiscalYear, 
								   BaseSerialNo, 
								   BaseDocRowNo, 
								   DocDate
							FROM #tbl_Prd_ProduceVariance_Total
						) SH ON SH.ProductID = FD.ProductID AND SH.FormulaNo = FD.SerialNo
						INNER JOIN #tbl_ProduceVariance_Prods P ON P.ProductID = FD.ProductID
						INNER JOIN #tbl_ProduceVariance_Goods G ON G.GoodsID = FD.GoodsID
				GROUP BY SH.FiscalYear, SH.SerialNo, SH.ProductID, SH.FormulaNo, FD.GoodsID, SH.ProdQuantity,
						 SH.BaseFiscalYear, SH.BaseSerialNo, SH.BaseDocRowNo, SH.DocDate, SH.ProdQuantity
			) X
			WHERE X.SentQuantity=0 --(round(X.FormulaQuantity, '+Ltrim(Rtrim(str(@Round)))+') > round(X.SentQuantity, '+Ltrim(Rtrim(str(@Round)))+'))	
		) M	
		WHERE (M.SentQuantity - M.FormulaQuantity) <> 0
		ORDER BY M.FiscalYear, M.SerialNo, M.GoodsID'		
	Print @StrSelect;
	Exec sp_executesql @StrSelect;
	end

END
GO
