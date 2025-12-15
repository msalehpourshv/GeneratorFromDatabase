USE TS_ShirinVatanKarkhaneh_1_1404
GO
SET ANSI_NULLS, QUOTED_IDENTIFIER ON
GO
-- =========== TS-QC:UPDATED ====================
-- Author		 : TakroSystem\Zia
-- Create date   : 1391/01/26
-- Viewed By	 : 
-- Last Modified : 
-- Last Modifier : TakroSystem\Zia
-- Description	 : اختلاف اسناد انبار با حسابداری
-- ==============================================
CREATE PROCEDURE [inv].[RptStore_StockAccDiff]
	@DocDateFr		Char(10) = Null,
	@DocDateTo		Char(10) = Null,
	@SelectedStore	Int = 0,
	@SelectedGoods	Int = 0,
	@MaxDiffValue	float = 0, 
	@ValueRanges	NVarChar(1500) = Null, -- فیلتر مقادیر
	@SortFields		NVarChar(100) = Null,
	@RepOptions		NVarChar(20) = '102', -- bit array
	@RepInfo		NVarChar(100) = '1@1@1'
WITH ENCRYPTION
AS 
---- Declarations ---------------
DECLARE @StrSelect	NVarChar(4000);
DECLARE @StrFrom	NVarChar(4000);
DECLARE @StrWhereI	NVarChar(4000);
DECLARE @StrWhereA	NVarChar(4000);
DECLARE @StrGroup	NVarChar(4000);
DECLARE @StrYear	Char(4);

DECLARE @ZeroAmount		Bit; -- شامل سطرهای مبلغ صفر
DECLARE @AllRows		Bit; 
DECLARE @Ph_Effected	Bit; 

DECLARE	@LangID			Char(1);
DECLARE	@SessionNo		Int; -- برای حالت کدهای انتخابی
DECLARE	@ReportID		Int; -- برای حالت کدهای انتخابی
Begin --============== S T A R T  C O D E ===================================================

	SET NOCOUNT ON;

	-- Init Variables ----------------------------------------------------------
	IF (@SelectedGoods Is Null) SET @SelectedGoods = 0;
	IF (@SelectedStore Is Null) SET @SelectedStore = 0;
	IF (@RepOptions	 Is Null)	SET @RepOptions = '121';

	SET @ZeroAmount	= Substring(@RepOptions, 1, 1)
	set @AllRows	= Substring(@RepOptions, 2, 1)

	IF Substring(@RepOptions, 3, 1) = '2'
		SET @Ph_Effected = Null
	ELSE
		SET @Ph_Effected = Substring(@RepOptions, 3, 1)

	SET @LangID		= pub.funSplitString(@RepInfo, '@', 1);
	SET @SessionNo	= pub.funSplitString(@RepInfo, '@', 2);
	SET @ReportID	= pub.funSplitString(@RepInfo, '@', 3);

	SET @StrYear = LTrim(RIGHT(db_name(), 4))
	----------------------------------------------------------------------------
	-- Where Clause ------------------------------------------------------------
	SET @StrWhereI = '(D.FiscalYear = ' + @StrYear + ') And D.GoodsID IN (Select GoodsID From inv.tblGoods Where IsService = 0)';
	SET @StrWhereA = '(1=1)';

	If (@Ph_Effected Is Not Null)
		If (@Ph_Effected = 1) 
			SET @StrWhereI = @StrWhereI + ' AND (D.PhysicallyEffected = 1)'
		Else
			SET @StrWhereI = @StrWhereI + ' AND (D.PhysicallyEffected = 0)'

	If (@DocDateTo Is Not Null)
		SET @StrWhereI = @StrWhereI + ' AND (D.DocDate <= ''' + @DocDateTo + ''')'
	If (@DocDateTo Is Not Null)
		SET @StrWhereA = @StrWhereA + ' AND (D.DocDate <= ''' + @DocDateTo + ''')'

	If (@SelectedGoods > 0)
		SET @StrWhereI = @StrWhereI + ' AND ' + pub.funGetFilterString(@SessionNo, @ReportID, @SelectedGoods, 'D.GoodsID') 
	If (@SelectedStore > 0)
		SET @StrWhereI = @StrWhereI + ' AND ' + pub.funGetFilterString(@SessionNo, @ReportID, @SelectedStore, 'D.StoreID') 
		
	If (@SelectedStore > 0)
		SET @StrWhereA = @StrWhereA + ' AND ' + pub.funGetFilterString(@SessionNo, @ReportID, @SelectedStore, 'S.StoreID') 

	If (@ZeroAmount = 0) 
		SET @StrWhereI = @StrWhereI + ' AND (D.GoodsAmount <> 0) '
	----------------------------------------------------------------------------------
	
	create table #tbl_Store_StockAccDiff_INV
	(
		StoreID			varchar(20) collate arabic_cs_as,
		AcntCode		varchar(20) collate arabic_cs_as,
		AmountPrimI		float,
		AmountInputI	float,
		AmountOutputI	float
	);

	create table #tbl_Store_StockAccDiff_ACC1
	(
		StoreID			varchar(20) collate arabic_cs_as,
		AcntCode		varchar(20) collate arabic_cs_as,
		AmountPrimA		float,
		AmountInputA	float,
		AmountOutputA	float
	);

	create table #tbl_Store_StockAccDiff_ACC2
	(
		StoreID			varchar(20) collate arabic_cs_as,
		AcntCode		varchar(20) collate arabic_cs_as,
		AmountPrimM		float,
		AmountInputM	float,
		AmountOutputM	float
	);

	-- Select Clause -----------------------------------------------------------------------------------------
	SET @StrSelect = '
	insert into #tbl_Store_StockAccDiff_INV
	select D.StoreID, S.StockAcntCode, ' + 
	CASE WHEN (@DocDateFr Is Not Null) THEN '
		SUM(CASE WHEN DocDate< ''' + @DocDateFr + ''' THEN D.GoodsQuantity*D.GoodsAmount*D.EnterKind ELSE 0 END),
		SUM(CASE WHEN DocDate>=''' + @DocDateFr + ''' AND D.EnterKind=+1 THEN D.GoodsQuantity*D.GoodsAmount ELSE 0 END),
		SUM(CASE WHEN DocDate>=''' + @DocDateFr + ''' AND D.EnterKind=-1 THEN D.GoodsQuantity*D.GoodsAmount ELSE 0 END)'
	ELSE '
		SUM(CASE WHEN D.ProcessID= 50 THEN D.GoodsQuantity*D.GoodsAmount ELSE 0 END),
		SUM(CASE WHEN D.ProcessID<>50 AND D.EnterKind=+1 THEN D.GoodsQuantity*D.GoodsAmount ELSE 0 END),
		SUM(CASE WHEN D.ProcessID<>50 AND D.EnterKind=-1 THEN D.GoodsQuantity*D.GoodsAmount ELSE 0 END)'
	END + ' 
	from inv.tblStorageDocsDtl D
			LEFT JOIN inv.tblStores S ON D.StoreID = S.StoreID
 	where ' + @StrWhereI + '
	group by D.StoreID, S.StockAcntCode '
	----------------------------------------------------------------------------------------------------------
	-- Run -----------------------------------------------------
	print @StrSelect;
	Exec sp_executesql @StrSelect;
	------------------------------------------------------------
	-- Select Clause -----------------------------------------------------------------------------------------
	SET @StrSelect = '
	insert into #tbl_Store_StockAccDiff_ACC1
	select S.StoreID, S.StockAcntCode, ' + 
	CASE WHEN (@DocDateFr Is Not Null) THEN '
		SUM(CASE WHEN DocDate< ''' + @DocDateFr + ''' THEN D.Debit-D.Credit ELSE 0 END),
		SUM(CASE WHEN DocDate>=''' + @DocDateFr + ''' THEN D.Debit  ELSE 0 END),
		SUM(CASE WHEN DocDate>=''' + @DocDateFr + ''' THEN D.Credit ELSE 0 END)'
	ELSE '
		SUM(CASE WHEN D.VchKind= 2 THEN D.Debit-D.Credit ELSE 0 END),
		SUM(CASE WHEN D.VchKind<>2 THEN D.Debit  ELSE 0 END),
		SUM(CASE WHEN D.VchKind<>2 THEN D.Credit ELSE 0 END)'
	END + ' 
	from acc.tblVoucherDtl D
			INNER JOIN inv.tblStores S ON D.AcntCode = S.StockAcntCode
 	where (D.IsAutoDoc=1) and ' + @StrWhereA + '
	group by S.StoreID, S.StockAcntCode '
	----------------------------------------------------------------------------------------------------------
	-- Run -----------------------------------------------------
	print @StrSelect;
	Exec sp_executesql @StrSelect;
	------------------------------------------------------------
	-- Select Clause -----------------------------------------------------------------------------------------
	SET @StrSelect = '
	insert into #tbl_Store_StockAccDiff_ACC2
	select S.StoreID, S.StockAcntCode, ' + 
	CASE WHEN (@DocDateFr Is Not Null) THEN '
		SUM(CASE WHEN DocDate< ''' + @DocDateFr + ''' THEN D.Debit-D.Credit ELSE 0 END),
		SUM(CASE WHEN DocDate>=''' + @DocDateFr + ''' THEN D.Debit  ELSE 0 END),
		SUM(CASE WHEN DocDate>=''' + @DocDateFr + ''' THEN D.Credit ELSE 0 END)'
	ELSE '
		SUM(CASE WHEN D.VchKind= 2 THEN D.Debit-D.Credit ELSE 0 END),
		SUM(CASE WHEN D.VchKind<>2 THEN D.Debit  ELSE 0 END),
		SUM(CASE WHEN D.VchKind<>2 THEN D.Credit ELSE 0 END)'
	END + ' 
	from acc.tblVoucherDtl D
			INNER JOIN inv.tblStores S ON D.AcntCode = S.StockAcntCode
 	where (D.IsAutoDoc=0) and ' + @StrWhereA + '
	group by S.StoreID, S.StockAcntCode '
	----------------------------------------------------------------------------------------------------------
	-- Run -----------------------------------------------------
	print @StrSelect;
	Exec sp_executesql @StrSelect;
	------------------------------------------------------------

	select T.StoreID, T.AcntCode, S.StoreName,
		SUM(AmountPrimI) AmountPrimI,
		SUM(AmountInputI) AmountInputI,
		SUM(AmountOutputI) AmountOutputI,
		SUM(AmountPrimA) AmountPrimA,
		SUM(AmountInputA) AmountInputA,
		SUM(AmountOutputA) AmountOutputA,
		SUM(AmountPrimM) AmountPrimM,
		SUM(AmountInputM) AmountInputM,
		SUM(AmountOutputM) AmountOutputM
	into #tbl_Store_StockAccDiff_Result
	from
	(
		select StoreID, AcntCode, AmountPrimI, AmountInputI, AmountOutputI, 0 AmountPrimA, 0 AmountInputA, 0 AmountOutputA, 0 AmountPrimM, 0 AmountInputM, 0 AmountOutputM
		from #tbl_Store_StockAccDiff_INV
		union all
		select StoreID, AcntCode, 0 AmountPrimI, 0 AmountInputI, 0 AmountOutputI, AmountPrimA, AmountInputA, AmountOutputA, 0 AmountPrimM, 0 AmountInputM, 0 AmountOutputM
		from #tbl_Store_StockAccDiff_ACC1
		union all
		select StoreID, AcntCode, 0 AmountPrimI, 0 AmountInputI, 0 AmountOutputI, 0 AmountPrimA, 0 AmountInputA, 0 AmountOutputA, AmountPrimM, AmountInputM, AmountOutputM
		from #tbl_Store_StockAccDiff_ACC2
	) T left join inv.tblStoresDtl S on S.StoreID = T.StoreID
	group by T.StoreID, T.AcntCode, S.StoreName
	order by T.StoreID
	------------------------------------------------------------
	
	if (@AllRows = 1)
		select * 
		from #tbl_Store_StockAccDiff_Result
	else
		select * 
		from #tbl_Store_StockAccDiff_Result
		where	Round(Abs((AmountPrimI+AmountInputI-AmountOutputI) - (AmountPrimA+AmountInputA-AmountOutputA) - (AmountPrimM+AmountInputM-AmountOutputM)),0) > @MaxDiffValue
	
End
GO
