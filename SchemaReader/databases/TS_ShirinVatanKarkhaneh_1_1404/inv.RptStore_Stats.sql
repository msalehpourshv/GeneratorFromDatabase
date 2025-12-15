USE TS_ShirinVatanKarkhaneh_1_1404
GO
SET ANSI_NULLS, QUOTED_IDENTIFIER ON
GO
-- =========== TS-QC:UPDATED ====================
-- Author		 : TakroSystem\Ahmadnejad
-- Create date   : 1388/04/22
-- Viewed By	 : 
-- Last Modified : 1392/09/25
-- Last Modifier : TakroSystem\Zia
-- Description	 : 
-- =============================================
Create PROCEDURE [inv].[RptStore_Stats] 
	@IsStore		Bit = 1,
	@IsPrice		Bit = 0,
	@GoodsPrice		Bit = 0,
	@DateFr			Char(10)= '0000/00/00',
	@DateTo			Char(10)= '9999/99/99',
	@SelectedStore	Int = 0,
	@SelectedGoods	Int = 0,
	@SelectedAcnt1	Int = 0, 
	@SelectedAcnt2	Int = 0,
	@SelectedAcnt3	Int = 0,
	@SelectedAcnt4	Int = 0,
	@SelectedProcs	Int = 0,
	@RepOptions		VarChar(10) = '1',
	@RepInfo		NVarChar(100) = '1@1@1'
WITH ENCRYPTION
AS

DECLARE @StrListNamesQty	NVarChar(max);
DECLARE @StrListNamesPrc	NVarChar(max);
DECLARE @StrListNamesAmnt	NVarChar(max);
DECLARE @StrListCodes	NVarChar(max);
DECLARE @StrSumAmount	NVarChar(max);
DECLARE @StrSelect		NVarChar(max);
DECLARE @StrSelectQty	NVarChar(max);
DECLARE @StrSelectPrc	NVarChar(max);
DECLARE @StrSelectAmnt  NVarChar(max);
DECLARE @StrWhere		NVarChar(max);
DECLARE @StrWhereGoodsRemain	NVarChar(max);
DECLARE @GoodsAmountID	VarChar(200);
DECLARE @GdsAmnt	    VarChar(200);

DECLARE	@LangID			Char(1);
DECLARE	@SessionNo		Int; -- برای حالت کدهای انتخابی
DECLARE	@ReportID		Int; -- برای حالت کدهای انتخابی

DECLARE @ProcessID		Int;
DECLARE @ProcessNo		Int;
DECLARE @ProcessName	NVarChar(100);
DECLARE @ProcessOrder	Int;
DECLARE @StrValPrc		NVarChar(200);
DECLARE @StrValQty		NVarChar(200);
DECLARE @CodeField		NVarChar(200);
DECLARE @NameField		NVarChar(200);
DECLARE @IsGrouped		bit;
DECLARE @IsCac			bit;
DECLARE @DecDiscount	bit;
DECLARE @IsService		bit;

BEGIN 
	-- ============================ S T A R T =====================================================

	-- Init --------------------------
	SET NOCOUNT ON;

	IF (@DateFr Is Null)		SET @DateFr  = '0000/00/00';
	IF (@DateTo Is Null)		SET @DateTo  = '9999/99/99';
	IF (@RepInfo Is Null)		SET @RepInfo = '1@1@1';
	IF (@SelectedProcs Is Null)	SET @SelectedProcs = 0;
	IF (@SelectedStore Is Null)	SET @SelectedStore = 0;
	IF (@SelectedGoods Is Null)	SET @SelectedGoods = 0;
	IF (@RepOptions Is Null)	SET @RepOptions = '10';

	IF (@SelectedAcnt1	Is Null)	SET @SelectedAcnt1 = 0;
	IF (@SelectedAcnt2	Is Null)	SET @SelectedAcnt2 = 0;
	IF (@SelectedAcnt3	Is Null)	SET @SelectedAcnt3 = 0;
	IF (@SelectedAcnt4	Is Null)	SET @SelectedAcnt4 = 0;

	SET @LangID		= pub.funSplitString(@RepInfo, '@', 1);
	SET @SessionNo	= pub.funSplitString(@RepInfo, '@', 2);
	SET @ReportID	= pub.funSplitString(@RepInfo, '@', 3);

	SET @StrListCodes = '';
	SET @StrSumAmount='';
	SET @StrListNamesQty = '';
	SET @StrListNamesPrc = '';
	SET @StrListNamesAmnt = '';
	SET @StrSelectAmnt   = ''

	SET @IsGrouped	= Substring(@RepOptions, 1, 1);
	SET @DecDiscount= Substring(@RepOptions, 2, 1);
	SET @IsCac		= Substring(@RepOptions, 3, 1);
	SET @IsService	= Substring(@RepOptions, 4, 1);

	DECLARE	@QuantityDecimals	CHAR(1);
	SET	@QuantityDecimals = '2';
	SELECT @QuantityDecimals = SettingValue 
	FROM pub.tblSettings 
	WHERE SettingKey = 'QuantityDecimals'

	DECLARE	@PriceDecimals	CHAR(1);
	SET	@PriceDecimals = '2';
	SELECT @PriceDecimals = SettingValue 
	FROM pub.tblSettings 
	WHERE SettingKey = 'PriceDecimals'

	IF @DateTo= '9999/99/99'
	BEGIN
		set @GdsAmnt = 'CAST((CASE WHEN D.GoodsQuantity = 0 THEN D.GoodsPrice ELSE D.GoodsAmount12 END) AS DECIMAL (28, ' + @PriceDecimals + ')) GoodsAmount12 '
		SET  @GoodsAmountID = 'GoodsAmount12 * (CASE WHEN GoodsQuantity = 0 THEN 1 ELSE GoodsQuantity END) * EnterKind' 
	END
	ELSE
	BEGIN
		set @GdsAmnt = 'CAST((CASE WHEN D.GoodsQuantity = 0 THEN D.GoodsPrice ELSE  D.' + LTRIM(inv.funGoodsAmount(@DateTo)) + ' END) AS DECIMAL (28, ' + @PriceDecimals + ')) ' + LTRIM(inv.funGoodsAmount(@DateTo)) + ' '
		SET  @GoodsAmountID = LTRIM(inv.funGoodsAmount(@DateTo)) + ' * (CASE WHEN GoodsQuantity = 0 THEN 1 ELSE GoodsQuantity END) * EnterKind' 
	END

			
	IF (Select Count(*) From sys.tables Where name = 'tblTmpQty') > 0 DROP Table inv.tblTmpQty
	IF (Select Count(*) From sys.tables Where name = 'tblTmpPrc') > 0 DROP Table inv.tblTmpPrc
	IF (Select Count(*) From sys.tables Where name = 'tblTmpAmnt') > 0 DROP Table inv.tblTmpAmnt
	--=========================================================================================
	-- Get Process List -----------------
	DECLARE csr_RptStore_Stats CURSOR FOR 
			SELECT DISTINCT P.ProcessID, P.ProcessNo, ProcessName, ProcessOrder
		FROM pub.tblProcess P 
		WHERE P.ProcessNo >= 1 
		and P.ProcessID IN ( SELECT CodeFrom 
								FROM rpt.tblFilters 
								WHERE SessionNo = @SessionNo AND ReportID = @ReportID AND ObjectID = @SelectedProcs	)
		ORDER BY ProcessOrder DESC, ProcessID, ProcessNo desc

	OPEN csr_RptStore_Stats 
	FETCH NEXT FROM csr_RptStore_Stats INTO @ProcessID, @ProcessNo, @ProcessName, @ProcessOrder

	WHILE (@@Fetch_Status = 0)
	BEGIN
		IF (@StrListNamesQty <> '') SET @StrListNamesQty = @StrListNamesQty + ', ';
		IF (@StrListNamesPrc <> '') SET @StrListNamesPrc = @StrListNamesPrc + ', ';
		IF (@StrListNamesAmnt <> '') SET @StrListNamesAmnt = @StrListNamesAmnt + ', ';
		IF (@StrListCodes <> '') SET @StrListCodes = @StrListCodes + ', ';
		IF (@StrSumAmount <> '') SET @StrSumAmount = @StrSumAmount + ' + ';
		
if @ProcessNo>1
begin
		SET @StrListNamesQty = @StrListNamesQty + 'CAST([' + LTrim(Str(@ProcessNo)) + LTrim(Str(@ProcessID)) + '] AS DECIMAL (28, ' + @QuantityDecimals + ')) AS ''' + @ProcessName +LTrim(Str(@ProcessNo))+ case when (@IsPrice is null) then ' - تعدادی' else '' end + ''''
		SET @StrListNamesPrc = @StrListNamesPrc + 'CAST([' + LTrim(Str(@ProcessNo)) + LTrim(Str(@ProcessID)) + '] AS DECIMAL (28, ' + @PriceDecimals + ')) AS ''' + @ProcessName +LTrim(Str(@ProcessNo))+ case when (@IsPrice is null) then ' - ریالی' else '' end + ''''
		SET @StrListNamesAmnt = @StrListNamesAmnt + 'CAST([' + LTrim(Str(@ProcessNo)) + LTrim(Str(@ProcessID)) + '] AS DECIMAL (28, ' + @PriceDecimals + ')) AS ''' + @ProcessName +LTrim(Str(@ProcessNo))+ case when (@IsPrice is null) then ' - تسهیم' else '' end + ''''
		SET @StrSumAmount = @StrSumAmount + 'CAST(ISNULL([' +  @ProcessName +LTrim(Str(@ProcessNo))+ case when (@IsPrice is null) then ' - تسهیم' else '' end + '],0) AS DECIMAL (28, ' + @PriceDecimals + '))'
end 
else
begin
		SET @StrListNamesQty = @StrListNamesQty + 'CAST([' + LTrim(Str(@ProcessNo)) + LTrim(Str(@ProcessID)) + '] AS DECIMAL (28, ' + @QuantityDecimals + ')) AS ''' + @ProcessName + case when (@IsPrice is null) then ' - تعدادی' else '' end + ''''
		SET @StrListNamesPrc = @StrListNamesPrc + 'CAST([' + LTrim(Str(@ProcessNo)) + LTrim(Str(@ProcessID)) + '] AS DECIMAL (28, ' + @PriceDecimals + ')) AS ''' + @ProcessName + case when (@IsPrice is null) then ' - ریالی' else '' end + ''''
		SET @StrListNamesAmnt = @StrListNamesAmnt + 'CAST([' + LTrim(Str(@ProcessNo)) + LTrim(Str(@ProcessID)) + '] AS DECIMAL (28, ' + @PriceDecimals + ')) AS ''' + @ProcessName + case when (@IsPrice is null) then ' - تسهیم' else '' end + ''''
		SET @StrSumAmount = @StrSumAmount + 'CAST(ISNULL([' + @ProcessName + case when (@IsPrice is null) then ' - تسهیم' else '' end + '], 0) AS DECIMAL (28, ' + @PriceDecimals + '))'
end 


		SET @StrListCodes = @StrListCodes + '[' + LTrim(Str(@ProcessNo)) + LTrim(Str(@ProcessID)) + ']'
		
		FETCH NEXT FROM csr_RptStore_Stats INTO @ProcessID, @ProcessNo, @ProcessName, @ProcessOrder
	END

	CLOSE		csr_RptStore_Stats 
	DEALLOCATE	csr_RptStore_Stats 

	--=========================================================================================
	-- Where Section -------------------------------
	SET @StrWhere = '(D.DocDate >= ''' + @DateFr + ''') and (D.DocDate <= ''' + @DateTo + ''') 
			AND D.ProcessID IN 
			(
				SELECT CodeFrom
				FROM rpt.tblFilters
				WHERE (SessionNo = ' + Str(@SessionNo) + ') AND (ReportID = ' + Str(@ReportID) + ') AND (ObjectID = ' + Str(@SelectedProcs) + ')
			)'

	SET @StrWhereGoodsRemain = ' (D1.DocDate <= ''' + @DateTo + ''') '
	IF (@SelectedGoods > 0)
		SET @StrWhere = @StrWhere + ' AND ' + pub.funGetFilterString(@SessionNo, @ReportID, @SelectedGoods, 'D.GoodsID') 
	
	IF (@SelectedStore > 0)
	BEGIN
		SET @StrWhere = @StrWhere + ' AND ' + pub.funGetFilterString(@SessionNo, @ReportID, @SelectedStore, 'D.StoreID') 
		SET @StrWhereGoodsRemain = @StrWhereGoodsRemain + ' AND ' + pub.funGetFilterString(@SessionNo, @ReportID, @SelectedStore, 'D1.StoreID') 
	END

	IF (@SelectedAcnt1 > 0)
		SET @StrWhere = @StrWhere + ' AND ' + pub.funGetFilterString(@SessionNo, @ReportID, @SelectedAcnt1, 'D.AcntCode')
	IF (@SelectedAcnt2 > 0)
		SET @StrWhere = @StrWhere + ' AND ' + pub.funGetFilterString(@SessionNo, @ReportID, @SelectedAcnt2, 'D.AcntCode')
	IF (@SelectedAcnt3 > 0)
		SET @StrWhere = @StrWhere + ' AND ' + pub.funGetFilterString(@SessionNo, @ReportID, @SelectedAcnt3, 'D.AcntCode')
	IF (@SelectedAcnt4 > 0)
		SET @StrWhere = @StrWhere + ' AND ' + pub.funGetFilterString(@SessionNo, @ReportID, @SelectedAcnt4, 'D.AcntCode')

	-- Select section -------------------------------
	if (@DecDiscount = 1)
	begin
		if (@GoodsPrice = 1)
			SET @StrValPrc = 'CAST((GoodsPrice * (CASE WHEN GoodsQuantity = 0 THEN 1 ELSE GoodsQuantity END)) - CASE WHEN PID=90 THEN DiscountDtl ELSE 0 END AS DECIMAL (28, ' + @PriceDecimals + ')) * EnterKind'
		else
			SET @StrValPrc = 'CAST(((CASE WHEN GoodsQuantity = 0 THEN GoodsPrice ELSE GoodsAmount *GoodsQuantity END) * EnterKind) - CASE WHEN PID=90 THEN DiscountDtl ELSE 0 END AS DECIMAL (28, ' + @PriceDecimals + '))'
	end
	else
	begin
		if (@GoodsPrice = 1)
			SET @StrValPrc = 'CAST(GoodsPrice * (CASE WHEN GoodsQuantity = 0 THEN 1 ELSE GoodsQuantity END) AS DECIMAL (28, ' + @PriceDecimals + ')) * EnterKind'
		else
			SET @StrValPrc = 'CAST((CASE WHEN GoodsQuantity = 0 THEN GoodsPrice ELSE GoodsAmount *GoodsQuantity END) AS DECIMAL (28, ' + @PriceDecimals + ')) * EnterKind'
	end

	SET @StrValQty = 'CAST(GoodsQuantity AS DECIMAL (28, ' + @QuantityDecimals + ')) * EnterKind'

	IF (@IsStore = 1)
	begin
		set @CodeField = 'کد انبار'
		set @NameField = 'نام انبار'
	end
	else
	begin
		if (@IsGrouped = 1)
		begin
			set @CodeField = 'کد گروه'
			set @NameField = 'نام گروه'
		end
		else
		begin
			set @CodeField = 'کد کالا'
			set @NameField = 'نام کالا'
		end
	end

	DECLARE @strIsService as nVarChar(300) = ''
	DECLARE @strIsServiceJoin as nVarChar(300) = ''

	IF (@IsService = 1)
	BEGIN
		SET @strIsService = ' AND G.IsService = 0'
		SET @strIsServiceJoin = 'Inner join inv.tblGoods G On D.GoodsID = G.GoodsID'
	END
	ELSE
	BEGIN
		SET @strIsService = ''
		SET @strIsServiceJoin = ''
	END

	IF (@IsStore = 1)
	begin
		SET @StrSelect = '
		SELECT [-1] AS ''موجودی'',  ' + @StrListNamesQty + ', 
				StoreName AS N''' + @NameField + ''', StoreID AS N''' + @CodeField + '''
		INTO inv.tblTmpQty
		FROM 
		(
			SELECT DISTINCT T.*
			FROM
			(
				select  D.StoreID, S.StoreName, isnull(D.ProcessID, -1) ProcessID,
						CAST(IsNull(Sum(' + @StrValQty + '), 0) AS DECIMAL (28, ' + @PriceDecimals + ')) SumValue
				from
				(
					SELECT D.StoreID, cast(ltrim(str(ProcessNo)) + ltrim(str(ProcessID)) as int) ProcessID, 
							CAST(D.GoodsQuantity AS DECIMAL (28, ' + @QuantityDecimals + ')) GoodsQuantity, 
							CAST(D.GoodsAmount AS DECIMAL (28, ' + @PriceDecimals + ')) GoodsAmount, 
							CAST(D.GoodsPrice AS DECIMAL (28, ' + @PriceDecimals + ')) GoodsPrice, D.EnterKind, 
							CAST(D.DiscountDtl AS DECIMAL (28, ' + @PriceDecimals + ')) DiscountDtl, ProcessID as PID
					FROM inv.tblStorageDocsDtl D
					' + @strIsServiceJoin + '
					WHERE ' + @StrWhere + @strIsService + '
				) D INNER JOIN inv.tblStoresDtl S ON S.StoreID = D.StoreID
				GROUP BY D.StoreID, S.StoreName, D.ProcessID
				WITH ROLLUP 
			) T
			WHERE (StoreID Is Not Null) AND (StoreName Is Not Null) 
		) P	PIVOT 
			(
				Sum(P.SumValue)
				FOR P.ProcessID In ([-1], ' + @StrListCodes + ')
			) AS PVT 
		ORDER BY StoreID;
		SELECT [-1] AS ''مبلغ ریالی کل'', 
				' + @StrListNamesQty + ',
				StoreName AS N''' + @NameField + ''', StoreID AS N''' + @CodeField + '''
		INTO inv.tblTmpPrc
		FROM 
		(
			SELECT DISTINCT T.*
			FROM
			(
				select  D.StoreID, S.StoreName, isnull(D.ProcessID, -1) ProcessID,
						CAST(IsNull(Sum(' + @StrValPrc + '), 0) AS DECIMAL (28, ' + @PriceDecimals + ')) SumValue
				from
				(
					SELECT D.StoreID, cast(ltrim(str(ProcessNo)) + ltrim(str(ProcessID)) as int) ProcessID, 
						   CAST(D.GoodsQuantity AS DECIMAL (28, ' + @QuantityDecimals + ')) GoodsQuantity, 
						   CAST(D.GoodsAmount AS DECIMAL (28, ' + @PriceDecimals + ')) GoodsAmount, 
						   CAST(D.GoodsPrice AS DECIMAL (28, ' + @PriceDecimals + ')) GoodsPrice, D.EnterKind, 
						   CAST(D.DiscountDtl AS DECIMAL (28, ' + @PriceDecimals + ')) DiscountDtl, ProcessID as PID
					FROM inv.tblStorageDocsDtl D
					WHERE ' + @StrWhere + '
				) D INNER JOIN inv.tblStoresDtl S ON S.StoreID = D.StoreID
				GROUP BY D.StoreID, S.StoreName, D.ProcessID
				WITH ROLLUP 
			) T
			WHERE (StoreID Is Not Null) AND (StoreName Is Not Null) 
		) P	PIVOT 
			(
				Sum(P.SumValue)
				FOR P.ProcessID In ([-1], ' + @StrListCodes + ')
			) AS PVT 
		ORDER BY StoreID;
		'
		IF @IsCac = 1
		begin
			SET @StrSelect = @StrSelect +  '
				select DISTINCT *
				into #tbl_AMNT
				from 
				(
					select  D.StoreID, S.StoreName, isnull(D.ProcessID, -1) ProcessID,
							CAST(IsNull(Sum(' + @GoodsAmountID + '), 0) AS DECIMAL (28, ' + @PriceDecimals + ')) SumValue
					from
					(			
						SELECT D.StoreID, cast(ltrim(str(ProcessNo)) + ltrim(str(ProcessID)) as int) ProcessID, 
							   CAST(D.GoodsQuantity AS DECIMAL (28, ' + @QuantityDecimals + ')) GoodsQuantity, 
							   ' + @GdsAmnt + ', 
							   CAST(D.GoodsPrice AS DECIMAL (28, ' + @PriceDecimals + ')) GoodsPrice, D.EnterKind, 
							   CAST(D.DiscountDtl AS DECIMAL (28, ' + @PriceDecimals + ')) DiscountDtl, ProcessID as PID
						FROM inv.tblStorageDocsDtl D
						' + @strIsServiceJoin + '
						WHERE ' + @StrWhere + @strIsService + '
					) D 
					INNER JOIN inv.tblStoresDtl S ON S.StoreID = D.StoreID
					group by D.StoreID, D.ProcessID, S.StoreName
					WITH ROLLUP 
				) T
				where (T.StoreID Is Not Null) AND (T.StoreName Is Not Null)'


			SET @StrSelect = @StrSelect + '
			SELECT [-1] AS ''مبلغ تسهیم کل'', 
					' + @StrListNamesAmnt + ',
					StoreName AS N''' + @NameField + ''', StoreID AS N''' + @CodeField + '''
			INTO inv.tblTmpAmnt
			FROM 
			(   SELECT	T.* FROM	#tbl_AMNT T
			) P	PIVOT 
				(
					Sum(P.SumValue)
					FOR P.ProcessID In ([-1], ' + @StrListCodes + ')
				) AS PVT 
			ORDER BY StoreID '
		
		end
	end
	ELSE
	Begin
		if (@IsGrouped = 1)
		begin
			set @StrSelectQty = '
			select DISTINCT R.GoodsGroupID GoodsID, isnull(N.GoodsGroupName, ''مجموع کالاهای بدون گروه'') as GoodsName,
					ProcessID, 
					CAST(isnull(sum(SumValue), 0) AS DECIMAL (28, ' + @PriceDecimals + ')) SumValue
			into #tbl_QTY
			from 
			(
				select  D.GoodsID, [pub].[funGetGoodsName](D.GoodsID,' + LTrim(RTrim(@LangID)) + ') GoodsName, isnull(D.ProcessID, -1) ProcessID,
						CAST(IsNull(Sum(' + @StrValQty + '), 0) AS DECIMAL (28, ' + @PriceDecimals + ')) SumValue
				from
				(
					SELECT D.GoodsID, cast(ltrim(str(ProcessNo)) + ltrim(str(ProcessID)) as int) ProcessID, 
							CAST(D.GoodsQuantity AS DECIMAL (28, ' + @QuantityDecimals + ')) GoodsQuantity, 
							CAST(D.GoodsAmount AS DECIMAL (28, ' + @PriceDecimals + ')) GoodsAmount, 
							CAST(D.GoodsPrice AS DECIMAL (28, ' + @PriceDecimals + ')) GoodsPrice, D.EnterKind, 
							CAST(D.DiscountDtl AS DECIMAL (28, ' + @PriceDecimals + ')) DiscountDtl, ProcessID as PID
					FROM inv.tblStorageDocsDtl D
					' + @strIsServiceJoin + '
					WHERE ' + @StrWhere + @strIsService + '
				) D 
				GROUP BY D.GoodsID, D.ProcessID
				WITH ROLLUP 
			) T
				left join inv.tblGoodsGroupsGoodsListDtl R on R.GoodsID = T.GoodsID
				left join inv.tblGoodsGroupsDtl N on N.GoodsGroupID = R.GoodsGroupID
			where (T.GoodsID Is Not Null) AND (T.GoodsName Is Not Null)	
			group by R.GoodsGroupID, N.GoodsGroupName, ProcessID'
			
			set @StrSelectPrc = '
			select DISTINCT R.GoodsGroupID GoodsID, isnull(N.GoodsGroupName, ''مجموع کالاهای بدون گروه'') as GoodsName,
					ProcessID, 
					CAST(isnull(sum(SumValue), 0) AS DECIMAL (28, ' + @PriceDecimals + ')) SumValue
			into #tbl_PRC
			from 
			(
				select  D.GoodsID,  [pub].[funGetGoodsName](D.GoodsID,' + LTrim(RTrim(@LangID)) + ') GoodsName, isnull(D.ProcessID, -1) ProcessID,
						CAST(IsNull(Sum(' + @StrValQty + '), 0) AS DECIMAL (28, ' + @PriceDecimals + ')) SumValue
				from
				(
					SELECT D.GoodsID, cast(ltrim(str(ProcessNo)) + ltrim(str(ProcessID)) as int) ProcessID, 
							CAST(D.GoodsQuantity AS DECIMAL (28, ' + @QuantityDecimals + ')) GoodsQuantity, 
							CAST(D.GoodsAmount AS DECIMAL (28, ' + @PriceDecimals + ')) GoodsAmount, 
							CAST(D.GoodsPrice AS DECIMAL (28, ' + @PriceDecimals + ')) GoodsPrice, D.EnterKind, 
							CAST(D.DiscountDtl AS DECIMAL (28, ' + @PriceDecimals + ')) DiscountDtl, ProcessID as PID
					FROM inv.tblStorageDocsDtl D
					' + @strIsServiceJoin + '
					WHERE ' + @StrWhere + @strIsService + '
				) D 
				GROUP BY D.GoodsID, D.ProcessID
				WITH ROLLUP 
			) T
				left join inv.tblGoodsGroupsGoodsListDtl R on R.GoodsID = T.GoodsID
				left join inv.tblGoodsGroupsDtl N on N.GoodsGroupID = R.GoodsGroupID
			where (T.GoodsID Is Not Null) AND (T.GoodsName Is Not Null)	
			group by R.GoodsGroupID, N.GoodsGroupName, ProcessID'
		end
		else
		begin
			set @StrSelectQty = '
			select DISTINCT T.*
			into #tbl_QTY
			from 
			(
				select  D.GoodsID,[pub].[funGetGoodsName](D.GoodsID,' + LTrim(RTrim(@LangID)) + ') GoodsName, isnull(D.ProcessID, -1) ProcessID,
						CAST(IsNull(Sum(' + @StrValQty + '), 0) AS DECIMAL (28, ' + @PriceDecimals + ')) SumValue
				from
				(
					SELECT D.GoodsID, cast(ltrim(str(ProcessNo)) + ltrim(str(ProcessID)) as int) ProcessID, 
							CAST(D.GoodsQuantity AS DECIMAL (28, ' + @QuantityDecimals + ')) GoodsQuantity, 
							CAST(D.GoodsAmount AS DECIMAL (28, ' + @PriceDecimals + ')) GoodsAmount, 
							CAST(D.GoodsPrice AS DECIMAL (28, ' + @PriceDecimals + ')) GoodsPrice, D.EnterKind, 
							CAST(D.DiscountDtl AS DECIMAL (28, ' + @PriceDecimals + ')) DiscountDtl, ProcessID as PID
					FROM inv.tblStorageDocsDtl D
					' + @strIsServiceJoin + '
					WHERE ' + @StrWhere + @strIsService + '
				) D 
				GROUP BY D.GoodsID, D.ProcessID
				WITH ROLLUP 
			) T
			where (T.GoodsID Is Not Null) AND (T.GoodsName Is Not Null)'
			
			set @StrSelectPrc = '
			select DISTINCT *
			into #tbl_PRC
			from 
			(
				select  D.GoodsID, [pub].[funGetGoodsName](D.GoodsID,' + LTrim(RTrim(@LangID)) + ') GoodsName, isnull(D.ProcessID, -1) ProcessID,
						CAST(IsNull(Sum(' + @StrValPrc + '), 0) AS DECIMAL (28, ' + @PriceDecimals + ')) SumValue
				from
				(			
					SELECT D.GoodsID, cast(ltrim(str(ProcessNo)) + ltrim(str(ProcessID)) as int) ProcessID, 
							CAST(D.GoodsQuantity AS DECIMAL (28, ' + @QuantityDecimals + ')) GoodsQuantity, 
							CAST(D.GoodsAmount AS DECIMAL (28, ' + @PriceDecimals + ')) GoodsAmount, 
							CAST(D.GoodsPrice AS DECIMAL (28, ' + @PriceDecimals + ')) GoodsPrice, D.EnterKind, 
							CAST(D.DiscountDtl AS DECIMAL (28, ' + @PriceDecimals + ')) DiscountDtl, ProcessID as PID
					FROM inv.tblStorageDocsDtl D
					' + @strIsServiceJoin + '
					WHERE ' + @StrWhere  + @strIsService + '
				) D 
				group by D.GoodsID, D.ProcessID
				WITH ROLLUP 
			) T
			where (T.GoodsID Is Not Null) AND (T.GoodsName Is Not Null)'
			IF @IsCac = 1
				set @StrSelectAmnt = '
				select DISTINCT *
				into #tbl_AMNT
				from 
				(
					select  D.GoodsID, [pub].[funGetGoodsName](D.GoodsID,' + LTrim(RTrim(@LangID)) + ') GoodsName, isnull(D.ProcessID, -1) ProcessID,
							CAST(IsNull(Sum(' + @GoodsAmountID + '), 0) AS DECIMAL (28, ' + @PriceDecimals + ')) SumValue
					from
					(			
						SELECT D.GoodsID, cast(ltrim(str(ProcessNo)) + ltrim(str(ProcessID)) as int) ProcessID, 
								CAST(D.GoodsQuantity AS DECIMAL (28, ' + @PriceDecimals + ')) GoodsQuantity, 
								' + @GdsAmnt + ',
								CAST(D.GoodsPrice AS DECIMAL (28, ' + @PriceDecimals + ')) GoodsPrice, D.EnterKind, 
								CAST(D.DiscountDtl AS DECIMAL (28, ' + @PriceDecimals + ')) DiscountDtl, ProcessID as PID
						FROM inv.tblStorageDocsDtl D
						' + @strIsServiceJoin + '
						WHERE ' + @StrWhere + @strIsService + '
					) D 
					group by D.GoodsID, D.ProcessID
					WITH ROLLUP 
				) T
				where (T.GoodsID Is Not Null) AND (T.GoodsName Is Not Null)'
		end

		SET @StrSelect = @StrSelectQty + ' ' + @StrSelectPrc + ' ' + @StrSelectAmnt + '
		-----------------------------------------------------------
		SELECT [-1] AS ''موجودی'', 
				' + @StrListNamesQty + ',
				GoodsName AS N''' + @NameField + ''', GoodsID AS N''' + @CodeField + '''
		INTO inv.tblTmpQty
		FROM 
		(	SELECT	T.* FROM	#tbl_QTY T
		) P	PIVOT 
			(
				Sum(P.SumValue)
				FOR P.ProcessID In ([-1], ' + @StrListCodes + ')
			) AS PVT 
		ORDER BY GoodsID 
		-----------------------------------------------------------
		SELECT [-1] AS ''مبلغ ریالی کل'', 
				' + @StrListNamesPrc + ',
				GoodsName AS N''' + @NameField + ''', GoodsID AS N''' + @CodeField + '''
		INTO inv.tblTmpPrc
		FROM 
		(   SELECT	T.*  FROM	#tbl_PRC T
		) P	PIVOT 
			( Sum(P.SumValue)
				FOR P.ProcessID In ([-1], ' + @StrListCodes + ')
			) AS PVT 
		ORDER BY GoodsID '
		IF @IsCac = 1
		
			SET @StrSelect = @StrSelect + '
			-----------------------------------------------------------
			SELECT [-1] AS ''مبلغ تسهیم کل'', 
					' + @StrListNamesAmnt + ',
					GoodsName AS N''' + @NameField + ''', GoodsID AS N''' + @CodeField + '''
			INTO inv.tblTmpAmnt
			FROM 
			(   SELECT	T.* FROM	#tbl_AMNT T
			) P	PIVOT 
				(
					Sum(P.SumValue)
					FOR P.ProcessID In ([-1], ' + @StrListCodes + ')
				) AS PVT 
			ORDER BY GoodsID '
		
	End 

	IF @IsCac = 1
	BEGIN
			set	@StrSelect = @StrSelect + ' ;
			UPDATE inv.tblTmpAmnt
			SET [مبلغ تسهیم کل] = CAST(' + @StrSumAmount + ' AS DECIMAL (28, ' + @PriceDecimals + '))'
			
		if (@IsPrice is null)
		set	@StrSelect = @StrSelect + '
		Select A.*,E.*, [inv].[funGetUnitNameWithGoodsID](A.[' + @CodeField + '],1) AS '' واحد کالا '',C.*, [inv].[FunGetGoodsBarCode] (A.[' + @CodeField + ']) AS '' بارکد ''
		From inv.tblTmpQty C
		INNER JOIN inv.tblTmpPrc A ON C.[' + @CodeField + '] = A.[' + @CodeField + ']
		INNER JOIN inv.tblTmpAmnt E ON C.[' + @CodeField + '] = E.[' + @CodeField + ']'

		if (@IsPrice = 1)
		set	@StrSelect = @StrSelect + '
		Select T.*,E.*, [inv].[funGetUnitNameWithGoodsID](T.[' + @CodeField + '],1) AS '' واحد کالا '', [inv].[FunGetGoodsBarCode] (T.[' + @CodeField + ']) AS '' بارکد ''
		From inv.tblTmpPrc T 
		INNER JOIN inv.tblTmpAmnt E ON T.[' + @CodeField + '] = E.[' + @CodeField + ']'

	END
	ELSE
	BEGIN
		if (@IsPrice is null)
		set	@StrSelect = @StrSelect + '
		Select A.*, [inv].[funGetUnitNameWithGoodsID](A.[' + @CodeField + '],1) AS '' واحد کالا '', C.*, [inv].[FunGetGoodsBarCode] (A.[' + @CodeField + ']) AS '' بارکد ''
		From inv.tblTmpQty C
		INNER JOIN inv.tblTmpPrc A ON C.[' + @CodeField + '] = A.[' + @CodeField + ']'

		if (@IsPrice = 1)
		set	@StrSelect = @StrSelect + '
		Select T.*,[inv].[funGetUnitNameWithGoodsID](T.[' + @CodeField + '],1) AS '' واحد کالا '', [inv].[FunGetGoodsBarCode] (T.[' + @CodeField + ']) AS '' بارکد ''
		From inv.tblTmpPrc T '

	END

	if (@IsGrouped <>1) --and (@IsStore <> 1)
		SET @StrWhereGoodsRemain ='
			CAST((SELECT IsNull(Sum(GoodsQuantity * EnterKind),0) 
			  FROM   inv.tblStorageDocsDtl D1
			  WHERE   D1.GoodsID = T.[' + @CodeField + '] AND D1.DocDate <= ''' + @DateTo + '''  AND ' + @StrWhereGoodsRemain + ') AS DECIMAL (28, ' + @PriceDecimals + ')) [مانده واقعی] ,'
	else
	SET @StrWhereGoodsRemain = ''

	if (@IsPrice = 0)
	set	@StrSelect = @StrSelect + '
	Select ' + @StrWhereGoodsRemain + ' T.*, [inv].[funGetUnitNameWithGoodsID](T.[' + @CodeField + '],1) AS '' واحد کالا '', [inv].[FunGetGoodsBarCode] (T.[' + @CodeField + ']) AS '' بارکد '' 
	From inv.tblTmpQty T '

	-- Exeute --------------------------
	PRINT @StrSelect;
	EXEC sp_executesql @StrSelect;

	--=========================================================================================
END
GO
