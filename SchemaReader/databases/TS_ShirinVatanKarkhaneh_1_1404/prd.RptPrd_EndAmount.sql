USE TS_ShirinVatanKarkhaneh_1_1404
GO
SET ANSI_NULLS, QUOTED_IDENTIFIER ON
GO
-- =========== TS-QC:UPDATED ====================
-- Author		 : TakroSystem\Zia
-- Create date   : 1391/01/28
-- Viewed By	 : 
-- Last Modified : 
-- Last Modifier : 
-- Description	 : 
-- ==============================================
Create PROCEDURE [prd].[RptPrd_EndAmount]
	@ProcListRcv		varchar(20) = '80,72,73',
	@ProcListSnd		varchar(20) = '70,82,83',
	@SelectedStoreR		Int = Null,
	@SelectedStoreS		Int = Null,
	@SelectedGoodsR		Int = Null, -- انتخاب محصول
	@SelectedGoodsS		Int = Null, -- انتخاب کالا
	@SelectedAcnt1		Int = Null, -- انتخاب طرف حساب
	@SelectedAcnt2		Int = Null,
	@SelectedAcnt3		Int = Null,
	@SelectedAcnt4		Int = Null,
	@FiscalFr			Int = Null,
	@SerialFr			Int = Null,
	@FiscalTo			Int = Null,
	@SerialTo			Int = Null,
	@DocDateFr			Char(10) = Null,
	@DocDateTo			Char(10) = Null,
	@RepOptions			VarChar(10) = '101',  -- bit array options
	@RepInfo			NVarChar(100) = '1@1@1'
WITH ENCRYPTION
AS 
---- Declarations ---------------
DECLARE	@StrSelect	NVarChar(max);
DECLARE	@StrFrom	NVarChar(max);
DECLARE	@StrWhereR	NVarChar(max);
DECLARE	@StrWhereS	NVarChar(max);
DECLARE	@Orders		NVarChar(max);

DECLARE @StrListTempl	NVarChar(max);
DECLARE @StrListNames	NVarChar(max);
DECLARE @StrListCodes	NVarChar(max);
DECLARE @StrListSumsC	NVarChar(max);
DECLARE @StrListSumsN	NVarChar(max);
DECLARE @StrGoodsField	NVarChar(50);

DECLARE @ProductID	VarChar(20);
DECLARE @ProductNm	VarChar(50);
DECLARE @DescQty	VarChar(50);
DECLARE @DescPrc1	VarChar(50);
DECLARE @DescPrc2	VarChar(50);
DECLARE @ResultFields	nVarChar(max);
DECLARE @Cnt		int;
DECLARE @UseQty		bit;
DECLARE @UsePrc1	bit;
DECLARE @UsePrc2	bit;
DECLARE @UseNames	bit;

DECLARE	@LangID		Char(1);
DECLARE	@SessionNo	Int; 
DECLARE	@ReportID	Int; 
BEGIN --============== S T A R T  C O D E ===================================================

	SET NOCOUNT ON;

	-- Init -------------------------------------------------------------------
	IF (@RepInfo	Is Null)	SET @RepInfo = '1@1@1'
	IF (@RepOptions	Is Null)	SET @RepOptions = '101'

	IF (@SelectedGoodsR	Is Null)	SET @SelectedGoodsR = 0;
	IF (@SelectedGoodsS	Is Null)	SET @SelectedGoodsS = 0;
	IF (@SelectedStoreR	Is Null)	SET @SelectedStoreR = 0;
	IF (@SelectedStoreS Is Null)	SET @SelectedStoreS = 0;
	IF (@SelectedAcnt1	Is Null)	SET @SelectedAcnt1 = 0;
	IF (@SelectedAcnt2	Is Null)	SET @SelectedAcnt2 = 0;
	IF (@SelectedAcnt3	Is Null)	SET @SelectedAcnt3 = 0;
	IF (@SelectedAcnt4	Is Null)	SET @SelectedAcnt4 = 0;

	IF (@FiscalFr	Is Null)	SET @FiscalFr = 0;
	IF (@FiscalTo	Is Null)	SET @FiscalTo = 0;
	IF (@SerialFr	Is Null)	SET @SerialFr = 0;
	IF (@SerialTo	Is Null)	SET @SerialTo = 0;

	IF (@FiscalFr=0)	SET @SerialFr = 0;
	IF (@FiscalTo=0)	SET @SerialTo = 0;
	IF (@SerialFr=0)	SET @FiscalFr = 0;
	IF (@SerialTo=0)	SET @FiscalTo = 0;
	
	set @UseQty		= Substring(@RepOptions, 1, 1);
	set @UsePrc1	= Substring(@RepOptions, 2, 1);
	set @UsePrc2	= Substring(@RepOptions, 3, 1);
	set @UseNames	= Substring(@RepOptions, 4, 1);
	
	set @Cnt = 0;
	if (@UseQty=1)	set @Cnt = @Cnt + 1
	if (@UsePrc1=1)	set @Cnt = @Cnt + 1
	if (@UsePrc2=1)	set @Cnt = @Cnt + 1

	SET @LangID		= pub.funSplitString(@RepInfo, '@', 1);
	SET @SessionNo	= pub.funSplitString(@RepInfo, '@', 2);
	SET @ReportID	= pub.funSplitString(@RepInfo, '@', 3);
	---------------------------------------------------------------------------
	-- Where Clause -----------------------------------------------------------
	-- RECEIVE -
	Set @StrWhereR = '(1=1)'

	IF (@SelectedAcnt1 > 0)
		SET @StrWhereR = @StrWhereR + ' AND ' + pub.funGetFilterString(@SessionNo, @ReportID, @SelectedAcnt1, 'D.AcntCode')
	IF (@SelectedAcnt2 > 0)
		SET @StrWhereR = @StrWhereR + ' AND ' + pub.funGetFilterString(@SessionNo, @ReportID, @SelectedAcnt2, 'D.AcntCode')
	IF (@SelectedAcnt3 > 0)
		SET @StrWhereR = @StrWhereR + ' AND ' + pub.funGetFilterString(@SessionNo, @ReportID, @SelectedAcnt3, 'D.AcntCode')
	IF (@SelectedAcnt4 > 0)
		SET @StrWhereR = @StrWhereR + ' AND ' + pub.funGetFilterString(@SessionNo, @ReportID, @SelectedAcnt4, 'D.AcntCode')

	IF (@SerialFr > 0)
		SET @StrWhereR = @StrWhereR + ' AND (D.FiscalYear > ' + LTrim(Str(@FiscalFr)) + ' OR (D.FiscalYear = ' + LTrim(Str(@FiscalFr)) + ' AND D.SerialNo >= ' + LTrim(Str(@SerialFr)) + '))' 
	IF (@SerialTo > 0)
		SET @StrWhereR = @StrWhereR + ' AND (D.FiscalYear < ' + LTrim(Str(@FiscalTo)) + ' OR (D.FiscalYear = ' + LTrim(Str(@FiscalTo)) + ' AND D.SerialNo <= ' + LTrim(Str(@SerialTo)) + '))' 

	IF (@DocDateFr Is Not Null) 
		SET @StrWhereR = @StrWhereR + ' AND (D.DocDate >= ''' + @DocDateFr + ''')'
	IF (@DocDateTo Is Not Null) 
		SET @StrWhereR = @StrWhereR + ' AND (D.DocDate <= ''' + @DocDateTo + ''')'

	IF (@SelectedGoodsR > 0)
		SET @StrWhereR = @StrWhereR + ' AND ' + pub.funGetFilterString(@SessionNo, @ReportID, @SelectedGoodsR, 'D.GoodsID') 
	IF (@SelectedStoreR > 0)
		SET @StrWhereR = @StrWhereR + ' AND ' + pub.funGetFilterString(@SessionNo, @ReportID, @SelectedStoreR, 'D.StoreID') 
		
	-- SEND -
	Set @StrWhereS = '(D.ProcessID in (' + @ProcListSnd + '))'

	IF (@SelectedAcnt1 > 0)
		SET @StrWhereS = @StrWhereS + ' AND ' + pub.funGetFilterString(@SessionNo, @ReportID, @SelectedAcnt1, 'D.AcntCode')
	IF (@SelectedAcnt2 > 0)
		SET @StrWhereS = @StrWhereS + ' AND ' + pub.funGetFilterString(@SessionNo, @ReportID, @SelectedAcnt2, 'D.AcntCode')
	IF (@SelectedAcnt3 > 0)
		SET @StrWhereS = @StrWhereS + ' AND ' + pub.funGetFilterString(@SessionNo, @ReportID, @SelectedAcnt3, 'D.AcntCode')
	IF (@SelectedAcnt4 > 0)
		SET @StrWhereS = @StrWhereS + ' AND ' + pub.funGetFilterString(@SessionNo, @ReportID, @SelectedAcnt4, 'D.AcntCode')

	IF (@DocDateFr Is Not Null) 
		SET @StrWhereS = @StrWhereS + ' AND (D.DocDate >= ''' + @DocDateFr + ''')'
	IF (@DocDateTo Is Not Null) 
		SET @StrWhereS = @StrWhereS + ' AND (D.DocDate <= ''' + @DocDateTo + ''')'

	IF (@SelectedGoodsS > 0)
		SET @StrWhereS = @StrWhereS + ' AND ' + pub.funGetFilterString(@SessionNo, @ReportID, @SelectedGoodsS, 'D.GoodsID') 
	IF (@SelectedStoreS > 0)
		SET @StrWhereS = @StrWhereS + ' AND ' + pub.funGetFilterString(@SessionNo, @ReportID, @SelectedStoreS, 'D.StoreID')
	------------------------------------------------------------
	-- Select Clause -------------------------------------------
	SET @StrListCodes = '';
	SET @StrListNames = '';
	SET @StrListSumsC = '';
	SET @StrListSumsN = '';

	begin try	
		DROP Table #tbl_Prd_EndAmount_Qty
		DROP Table #tbl_Prd_EndAmount_Prc
		DROP Table #tbl_Prd_EndAmount_Unt
	end try
	begin catch
	end catch
	
	create table #tbl_Prd_EndAmount_Snd
	(
		MID int,
		MNO int,
		MFY int,
		MSN int,
		MRN int,
		BID int,
		BNO int,
		BFY int,
		BSN int,
		BRN int,
		GID	varchar(20) collate arabic_cs_as,
		QTY	float,
		PRC	float
	);
	
	create table #tbl_Prd_EndAmount_Rcv
	(
		MID int,
		MNO int,
		MFY int,
		MSN int,
		MRN int,
		BID int,
		BNO int,
		BFY int,
		BSN int,
		BRN int,
		GID	varchar(20) collate arabic_cs_as,
		QTY	float,
		PRC	float
	);

	create table #tbl_Prd_EndAmount_List
	(
		ProductID varchar(20) collate arabic_cs_as,
		GoodsID varchar(20) collate arabic_cs_as,
		GoodsName nvarchar(100),
		Quantity float,
		Amount float
	);

	set @StrSelect = '
	insert into #tbl_Prd_EndAmount_Snd(MID, MNO, MFY, MSN, MRN, BID, BNO, BFY, BSN, BRN, GID, QTY, PRC)
	select ProcessID, ProcessNo, FiscalYear, SerialNo, DocRowNo, BaseProcessID, BaseProcessNo, BaseFiscalYear, BaseSerialNo, BaseDocRowNo, GoodsID, GoodsQuantity, GoodsAmount
	from inv.tblStorageDocsDtl D
	where ' + @StrWhereS;
	
	print @StrSelect;
	exec sp_executesql @StrSelect;

	set @StrSelect = '
	insert into #tbl_Prd_EndAmount_Rcv(MID, MNO, MFY, MSN, MRN, BID, BNO, BFY, BSN, BRN, GID, QTY, PRC)
	select ProcessID, ProcessNo, FiscalYear, SerialNo, DocRowNo, BaseProcessID, BaseProcessNo, BaseFiscalYear, BaseSerialNo, BaseDocRowNo, GoodsID, GoodsQuantity, GoodsAmount
	from inv.tblStorageDocsDtl D 
			inner join #tbl_Prd_EndAmount_Snd S on S.MID = D.BaseProcessID and S.MNO = D.BaseProcessNo and S.MFY = D.BaseFiscalYear and S.MSN = D.BaseSerialNo
	where (D.ProcessID = 80) and ' + @StrWhereR + '
	union 
	select ProcessID, ProcessNo, FiscalYear, SerialNo, DocRowNo, BaseProcessID, BaseProcessNo, BaseFiscalYear, BaseSerialNo, BaseDocRowNo, GoodsID, GoodsQuantity, GoodsAmount
	from inv.tblStorageDocsDtl D 
			inner join #tbl_Prd_EndAmount_Snd S on S.BID = D.BaseProcessID and S.BNO = D.BaseProcessNo and S.BFY = D.BaseFiscalYear and S.BSN = D.BaseSerialNo and S.BRN = D.BaseDocRowNo
	where (D.ProcessID in (72, 73)) and ' + @StrWhereR
	
	print @StrSelect;
	exec sp_executesql @StrSelect;

	insert into #tbl_Prd_EndAmount_List(ProductID, GoodsID, GoodsName, Quantity, Amount)
	select M.PRD, M.GID, G.GoodsName, SUM(M.QTY), SUM(M.PRC*M.QTY)
	from
	(
		select PRD, GID, QTY, PRC
		from 
		(
			select (
						select top 1 GID
						from #tbl_Prd_EndAmount_Rcv R
						where (R.MID = 80) and (R.BID = D.MID) and (R.BNO = D.MNO) and (R.BFY = D.MFY) and (R.BSN = D.MSN)
					) as PRD, D.GID, D.QTY, D.PRC
			from #tbl_Prd_EndAmount_Snd D
			where (D.MID = 70)
		) T
		where (T.PRD is not null)
		union all
		select PRD, GID, QTY, PRC
		from 
		(
			select (
						select top 1 GID
						from #tbl_Prd_EndAmount_Rcv R
						where (R.MID in (72, 73)) and (R.BID = D.BID) and (R.BNO = D.BNO) and (R.BFY = D.BFY) and (R.BSN = D.BSN) and (R.BRN = D.BRN)
					) as PRD, D.GID, D.QTY, D.PRC
			from #tbl_Prd_EndAmount_Snd D
			where (D.MID in (82, 83))
		) T
		where (T.PRD is not null)
	) M left join inv.tblGoodsDtl G on G.GoodsID = M.GID
	group by M.PRD, M.GID, G.GoodsName
	order by M.PRD, M.GID, G.GoodsName

	-- Get Process List -----------------
	DECLARE csr_Prd_EndAmount_GID CURSOR FOR 
		select distinct  top 900 L.ProductID, G.GoodsName as ProductName
		from #tbl_Prd_EndAmount_List L
			left join inv.tblGoodsDtl G on G.GoodsID = L.ProductID
		order by ProductID DESC  

	OPEN csr_Prd_EndAmount_GID
	FETCH NEXT FROM csr_Prd_EndAmount_GID INTO @ProductID, @ProductNm
	
	WHILE (@@Fetch_Status = 0)
	BEGIN
		IF (@StrListNames <> '') SET @StrListNames = @StrListNames + ',';
		IF (@StrListCodes <> '') SET @StrListCodes = @StrListCodes + ',';
		IF (@StrListSumsC <> '') SET @StrListSumsC = @StrListSumsC + ',';
		IF (@StrListSumsN <> '') SET @StrListSumsN = @StrListSumsN + ',';
		

		SET @StrListNames = @StrListNames + '[' + LTrim(@ProductID) + '] as ''' + LTrim(@ProductNm) + ''''
		SET @StrListCodes = @StrListCodes + '[' + LTrim(@ProductID) + ']'
		
		SET @StrListSumsC = @StrListSumsC + 'sum([' + LTrim(@ProductID) + '])'
		SET @StrListSumsN = @StrListSumsN + 'sum([' + LTrim(@ProductNm) + '])'
		
		FETCH NEXT FROM csr_Prd_EndAmount_GID INTO @ProductID, @ProductNm
	END

	CLOSE		csr_Prd_EndAmount_GID 
	DEALLOCATE	csr_Prd_EndAmount_GID
	
	if @StrListNames = ''
		set @StrListNames = '[''بدون اطلاعات'']'
	if @StrListCodes = ''
		set @StrListCodes = '[''بدون اطلاعات'']'
		
	if (@Cnt > 1)
	begin
		set @DescQty = ' + '' - تعداد'''
		set @DescPrc1 = ' + '' - فی'''
		set @DescPrc2 = ' + '' - مبلغ'''
	end
	else
	begin
		set @DescQty = ''
		set @DescPrc1 = ''
		set @DescPrc2 = ''
	end
		
	if (@UseNames = 1)
	begin
		set @StrListTempl = @StrListNames
		set @ResultFields = @StrListSumsN
		set @StrGoodsField = 'GoodsName'
	end
	else
	begin
		set @StrListTempl = @StrListCodes
		set @ResultFields = @StrListSumsC
		set @StrGoodsField = 'GoodsID'
	end
	
	if @ResultFields = ''
		set @ResultFields = '[''بدون اطلاعات'']'		 

	set @Orders = '0'
	
	if (@UseQty = 1)
		set @Orders = @Orders + ',1,11'
	if (@UsePrc1 = 1)
		set @Orders = @Orders + ',2,0'
	if (@UsePrc2 = 1)
		set @Orders = @Orders + ',3,13'
		
	SET @StrSelect = '
	SELECT ' + @StrListTempl + ', 
		' + @StrGoodsField + @DescQty + ' as [مواد اولیه / محصول],
		1 as ord
	into #tblPrd_EndAmount
	FROM 
	(
		SELECT D.ProductID, D.GoodsID, D.GoodsName, round(sum(D.Quantity),0) Quantity
		FROM #tbl_Prd_EndAmount_List D
		GROUP BY D.ProductID, D.GoodsID, D.GoodsName
	) P	PIVOT 
		(
			Sum(P.Quantity)
			FOR P.ProductID In (' + @StrListCodes + ')
		) AS PVT
	UNION ALL
	SELECT ' + @StrListTempl + ',
		' + @StrGoodsField + @DescPrc1 + ',
		2 as ord
	FROM 
	(
		SELECT D.ProductID, D.GoodsID, D.GoodsName, round(sum(Amount) / sum(D.Quantity),0) UnitAmount
		FROM #tbl_Prd_EndAmount_List D
		GROUP BY D.ProductID, D.GoodsID, D.GoodsName
	) P	PIVOT 
		(
			Sum(P.UnitAmount)
			FOR P.ProductID In (' + @StrListCodes + ')
		) AS PVT 
	UNION ALL
	SELECT ' + @StrListTempl + ', 
		' + @StrGoodsField + @DescPrc2 + ',
		3 as ord
	FROM 
	(
		SELECT D.ProductID, D.GoodsID, D.GoodsName, round(sum(D.Amount), 0) Amount
		FROM #tbl_Prd_EndAmount_List D
		GROUP BY D.ProductID, D.GoodsID, D.GoodsName
	) P	PIVOT 
		(
			Sum(P.Amount)
			FOR P.ProductID In (' + @StrListCodes + ')
		) AS PVT 
		
	UNION ALL
	select ' + @ResultFields + ', 
		''جمع تعداد تولید شده'', 
		11 as ord
	from
	(
		SELECT ' + @StrListTempl + ' 
		FROM 
		(
			SELECT D.GID GoodsID, G.GoodsName, D.QTY GoodsQuantity
			FROM #tbl_Prd_EndAmount_Rcv D
				left join inv.tblGoodsDtl G on G.GoodsID = D.GID
		) P	PIVOT 
			(
				Sum(P.GoodsQuantity)
				FOR P.GoodsID In (' + @StrListCodes + ')
			) AS PVT 
	) X
	
	insert into #tblPrd_EndAmount
	select ' + @ResultFields + ', 
		''جمع مبلغ مواد اولیه'',
		13 as ord
	from #tblPrd_EndAmount
	where ord = 3
	
	select *
	from #tblPrd_EndAmount 
	where ord in (' + @Orders + ')
	order by case when (ord <= 9) then 1 else 2 end, [مواد اولیه / محصول], ord'
	------------------------------------------------------------
	-- Run -----------------------------------------------------
	print @StrSelect;
	Exec sp_executesql @StrSelect;
	------------------------------------------------------------
END
GO
