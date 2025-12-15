USE TS_ShirinVatanKarkhaneh_1_1404
GO
SET ANSI_NULLS, QUOTED_IDENTIFIER ON
GO
-- =========== TS-QC:UPDATED ====================
-- Author		 : Reza Nogrehpasand
-- Create date   : 1392/04/3
-- Viewed By	 : 
-- Last Modified : 
-- Last Modifier : 
-- Description	 : گزارش بهاي تمام شده محصول
-- =============================================
CREATE PROCEDURE [cac].[Rptcac_ProductEndAmountEx]
	@ProductID	varchar(20),
	@StoreID	varchar(20),
	@ToDate		CHAR(10),
	@RepInfo	NVarChar(100) = '1@1@1'
WITH ENCRYPTION
AS

DECLARE @StrSelect	NVarChar(MAX);
DECLARE @StrWhere	NVarChar(MAX);
DECLARE @MaxDate	Char(10);
DECLARE @LevelStr	VarChar(1024);
DECLARE @StrAmout	VARCHAR(30);
DECLARE @Indent		int;
DECLARE @IsGroup	bit;

DECLARE	@LangID			Char(1);
DECLARE	@SessionNo		Int; -- برای حالت کدهای انتخابی
DECLARE	@ReportID		Int; -- برای حالت کدهای انتخابی
DECLARE	@UserID			Int;
DECLARE	@UserIsAdmin	bit;

DECLARE @MainProductID	varchar(20)
DECLARE @GoodsID		varchar(20)
DECLARE @DocDate		char(10)
DECLARE @VolumeRowNo	int;
DECLARE @ProductQty		float;
DECLARE @GoodsQty		float;
DECLARE @GoodsAmt		float;
DECLARE @ProduceQty		float;
DECLARE @MainProduceQty		float;

DECLARE @ProcessID		int;
DECLARE @ProcessNo		int;
DECLARE @FiscalYear		int;
DECLARE @SerialNo		int;
DECLARE @RowNo			int;
DECLARE @BaseProcessID	int;
DECLARE @BaseProcessNo	int;
DECLARE @BaseFiscalYear	int;
DECLARE @BaseSerialNo	int;
DECLARE @BaseDocRowNo	int;
DECLARE @FromDate		NVarCHAR(1000)=''

BEGIN 
	-- ============================ S T A R T =====================================================

	-- Init --------------------------
	SET NOCOUNT ON;
	
	SET @LangID		= pub.funSplitString(@RepInfo, '@', 1);
	SET @SessionNo	= pub.funSplitString(@RepInfo, '@', 2);
	SET @ReportID	= pub.funSplitString(@RepInfo, '@', 3);
	SET @UserID		= pub.funSplitString(@RepInfo, '@', 4);
	SET @UserIsAdmin= pub.funSplitString(@RepInfo, '@', 5);
	SET @FromDate   = pub.funSplitString(@RepInfo, '@', 7);
	set @MainProductID = @ProductID

	IF CAST (pub.funSplitString(@ToDate,'/',2) as tinyint)>=1
		SET @StrAmout = 'GoodsAmount' + ltrim(STR( CAST (pub.funSplitString(@ToDate,'/',2) as tinyint)))-- 1
	ELSE	
		SET @StrAmout = 'GoodsAmount'

	select @MaxDate = MAX(DocDate) 
	from cac.tblPortionSum 
	where DocDate <= @ToDate

	
	IF LTRIM(@FromDate) <>'' 
		SET @FromDate =' AND DocDate>='''+ @FromDate +''''
		
	set @Indent	= 4;

	create table #tbl_ProductEndAmount_Result
	(
		ProductID	varchar(20) collate arabic_cs_as,
		ProductQty	float,
		GoodsID		varchar(20) collate arabic_cs_as,
		GoodsQty	float,
		GoodsAmt	float,
		ProduceQty	float,
		LevelStr	nvarchar(1024),
		IsGroup		bit
	)

	create table #tbl_ProductEndAmount_Goods
	(
		GoodsID		varchar(20) collate arabic_cs_as,
		SumSendQty	float,
		SendAmount	float
	)
	
	create table #tbl_ProductEndAmount_Amount
	(
		GoodsID	varchar(20) collate arabic_cs_as,
		Amount	float
	)

	create table #tbl_ProductEndAmount_Produce
	(
		GoodsID		varchar(20) collate arabic_cs_as,
		Quantity	float
	)
	
	-- ================ SELECT ==============================================================
	
	set @StrSelect = '
	insert into #tbl_ProductEndAmount_Amount(GoodsID, Amount)
	select GoodsID, SUM(D.' + @StrAmout + '*GoodsQuantity)/SUM(GoodsQuantity) 
	from inv.tblStorageDocsDtl D
	where  ' + @FromDate + ' (D.DocDate <= ''' + @ToDate +  ''')
		and ProcessID in (72,73,80)
	group by D.GoodsID'
	
	print @StrSelect;
	exec sp_executesql @StrSelect;

	set @StrSelect = '
	insert into #tbl_ProductEndAmount_Produce(GoodsID, Quantity)
	select GoodsID, Sum(GoodsQuantity)
	from inv.tblStorageDocsDtl D
	where	 ' + @FromDate + ' (D.DocDate <= ''' + @ToDate +  ''') 
		and (ProcessID in (72,73,80))
	group by D.GoodsID'
	
	print @StrSelect;
	exec sp_executesql @StrSelect;
	
	SELECT	@MainProduceQty = SUM(D.GoodsQuantity)
	FROM	inv.tblStorageDocsDtl D
	WHERE   (D.GoodsID=@ProductID)
		AND (D.DocDate<=@ToDate )
		AND (D.ProcessID IN (80,72,73))	
	
	SET @StrSelect = '
	insert	into #tbl_ProductEndAmount_Result(ProductID, ProductQty, GoodsID, GoodsQty, GoodsAmt, ProduceQty, LevelStr, IsGroup)
	values (null, null, ''' + @ProductID + ''',
				(
					SELECT	SUM(D.GoodsQuantity)
					FROM	inv.tblStorageDocsDtl D
					WHERE   (D.GoodsID=''' + @ProductID + ''') ' + @FromDate + '
						AND (D.DocDate<=''' + @ToDate + ''')
						AND (D.ProcessID IN (80,72,73))
				), 
				(
					SELECT	SUM(D.GoodsQuantity*D.' + @StrAmout + ')/SUM(D.GoodsQuantity)
					FROM	inv.tblStorageDocsDtl D
					WHERE   (D.GoodsID=''' + @ProductID + ''') ' + @FromDate + '
						AND (D.DocDate<=''' + @ToDate + ''')
						AND (D.ProcessID IN (80,72,73))
				),				
				' + ltrim(str(@MainProduceQty)) + ',
				str(1, ' + ltrim(str(@Indent)) + '), 0
			)'

	PRINT @StrSelect;
	EXEC sp_executesql @StrSelect;
	
	-----------------------------------
	
 	declare	cur_Prods CURSOR for
		SELECT ProductID, ProductQty, GoodsID, GoodsQty, GoodsAmt, ProduceQty, LevelStr, IsGroup
		FROM #tbl_ProductEndAmount_Result
		  
 	open cur_Prods;

	fetch next from cur_Prods into @ProductID, @ProductQty, @GoodsID, @GoodsQty, @GoodsAmt, @ProduceQty, @LevelStr, @IsGroup

	While (@@Fetch_Status = 0)
	Begin
		set @ProductID = @GoodsID
		set @ProductQty = @GoodsQty
		
		delete from #tbl_ProductEndAmount_Goods

		----------------------------------------------
		
		SET @StrSelect = '
		insert	into #tbl_ProductEndAmount_Goods(GoodsID, SumSendQty, SendAmount)
		select  T.GoodsID, Sum(T.GoodsQuantity), Sum(T.GoodsQuantity*T.GoodsAmount)/Sum(T.GoodsQuantity)
		from
		(
			SELECT	D.GoodsID, D.GoodsQuantity, D.' + @StrAmout + ' GoodsAmount
			FROM	inv.tblStorageDocsDtl D
						inner join inv.tblStorageDocsHdr H on H.ProcessID=D.ProcessID AND H.ProcessNo=D.ProcessNo AND H.FiscalYear=D.FiscalYear AND H.SerialNo=D.SerialNo
			WHERE	(D.ProcessID=82)  ' + @FromDate + '
				and (D.DocDate<=''' + @ToDate + ''') 
				and (H.ProductID=''' + @ProductID + ''') 
		) T 
		group by T.GoodsID'
	
		
		if (@IsGroup<>1) 
		begin
			PRINT @StrSelect;
			EXEC sp_executesql @StrSelect;
		end
		
		if (@ProductID <> @MainProductID) and (select COUNT(*) from #tbl_ProductEndAmount_Goods) > 0
		begin
			SELECT	@MainProduceQty = SUM(D.GoodsQuantity)
			FROM	inv.tblStorageDocsDtl D
			WHERE   (D.GoodsID=@ProductID) AND (@FromDate ='' OR D.DocDate>= @FromDate)
					AND (D.DocDate<=@ToDate )
					AND (D.ProcessID IN (80,72,73))
		end
		
		SET @StrSelect = '
		insert	into #tbl_ProductEndAmount_Result(ProductID, ProductQty, GoodsID, GoodsQty, GoodsAmt, ProduceQty, LevelStr, IsGroup)
		select	''' + @ProductID + ''' ProductID, ' + str(@ProductQty) + ' ProductQty, 
				D.GoodsID, D.SumSendQty/' + str(@MainProduceQty) + '*' + str(@ProductQty) + ' GoodsQty,
				D.SendAmount GoodsAmt,
				isnull((
					SELECT	SUM(I.GoodsQuantity)
					FROM	inv.tblStorageDocsDtl I
								inner join inv.tblStorageDocsHdr H on H.ProcessID=I.ProcessID AND H.ProcessNo=I.ProcessNo AND H.FiscalYear=I.FiscalYear AND H.SerialNo=I.SerialNo
					WHERE	(I.ProcessID in (72,73)) ' + replace(@FromDate,'D.','I.') + '
						AND (I.DocDate<=''' + @ToDate + ''')
						AND (I.GoodsID=D.GoodsID)
						AND (H.ProductID=''' + @ProductID + ''')
				),0) ProduceQty,
				CAST(''' + @LevelStr + ''' + Str(Row_Number() over (order by D.GoodsID), ' + ltrim(str(@Indent)) + ') as nvarchar(50)) as LevelStr, 0 IsGroup
		from	#tbl_ProductEndAmount_Goods D '

		if (@IsGroup<>1)
		begin
			PRINT @StrSelect;
			EXEC sp_executesql @StrSelect;
		end

		if (@ProductID <> @MainProductID) and (select COUNT(*) from #tbl_ProductEndAmount_Goods) > 0
		begin
			insert	into #tbl_ProductEndAmount_Result(ProductID, ProductQty, GoodsID, GoodsQty, GoodsAmt, ProduceQty, LevelStr, IsGroup)
			select NULL, Null, @ProductID, @ProductQty, @GoodsAmt, @ProduceQty, @LevelStr + '   0', 1
		end
	
		fetch next from cur_Prods into @ProductID, @ProductQty, @GoodsID, @GoodsQty, @GoodsAmt, @ProduceQty, @LevelStr, @IsGroup
	End
	 
	close cur_Prods;
	Deallocate cur_Prods; 
	
	DECLARE @UnitPart TINYINT
	SET @UnitPart  = 1

	SELECT @UnitPart = SettingValue from pub.tblSettings where SettingKey = 'UnitPart'

	IF @UnitPart IS NULL or @UnitPart = 0
		SET @UnitPart = 1

	DECLARE @str_Goods  tinyint,
			@str_GoodsSum tinyint

	select @str_Goods = ISNULL(SUM (Layer1+Layer2+Layer3+Layer4+Layer5+Layer6+Layer7+Layer8+Layer9),0)
	from pub.tblCodeLayer 
	where TableName='inv.tblGoods' AND PartNumber<@UnitPart

	select @str_GoodsSum = Layer1+Layer2+Layer3+Layer4+Layer5+Layer6+Layer7+Layer8+Layer9
	from pub.tblCodeLayer 
	where TableName= 'inv.tblGoods' AND PartNumber=@UnitPart


	-- Exeute --------------------------
	select T.*, T.GoodsAmountNet-T.PortionGoods-T.WageAmount-T.OverAmount-T.OtherAmount GoodsAmount,
			pub.funGetGoodsName(P.GoodsID,1) AS  ProductName, pub.funGetGoodsName(G.GoodsID,1) AS GoodsName, 
			CAST(LEN(LevelStr)/4 as int) LevelNo,
			Space(Len(LevelStr)-4) + T.GoodsID GoodsIDEx
	from
	(
		select	R.*,
				case when R.ProduceQty=0 then R.GoodsAmt*R.GoodsQty else A.Amount*R.GoodsQty end GoodsAmountNet,
				isnull((
					select	sum(PortionSalary)
					from	cac.tblPortionSum P
					where	(P.GoodsID=R.GoodsID) AND (@FromDate ='' OR P.DocDate>= @FromDate)
						and (P.DocDate=@MaxDate)
				)*GoodsQty/F.Quantity,0) WageAmount,
				isnull((
					select	sum(PortionOverLoad)
					from	cac.tblPortionSum P
					where	(P.GoodsID=R.GoodsID) AND (@FromDate ='' OR P.DocDate>= @FromDate)
						and (P.DocDate=@MaxDate)
				)*GoodsQty/F.Quantity,0) OverAmount,
				isnull((
					select	sum(PortionOtherCost)
					from	cac.tblPortionSum P
					where	(P.GoodsID=R.GoodsID) AND (@FromDate ='' OR P.DocDate>= @FromDate)
						and (P.DocDate=@MaxDate)
				)*GoodsQty/F.Quantity,0) OtherAmount,
				isnull((
					select	sum(PortionGoods)
					from	cac.tblPortionSum P
					where	(P.GoodsID=R.GoodsID) AND (@FromDate ='' OR P.DocDate>= @FromDate)
						and (P.ProcessID=70)
						and (P.DocDate=@MaxDate)
				)*GoodsQty/F.Quantity,0) PortionGoods
		from #tbl_ProductEndAmount_Result R
				left  join #tbl_ProductEndAmount_Amount  A on A.GoodsID=R.GoodsID
				left  join #tbl_ProductEndAmount_Produce F on F.GoodsID=R.GoodsID
	) T
		left join inv.tblGoodsDtl G on  G.PartNumber=@UnitPart AND G.GoodsID=SUBSTRING(T.GoodsID,@str_Goods+1,@str_GoodsSum) 
		left join inv.tblGoodsDtl P on  G.PartNumber=@UnitPart AND P.GoodsID=SUBSTRING(T.ProductID,@str_Goods+1,@str_GoodsSum) 
	order by len(LevelStr), LevelStr, ProductID, GoodsID
	--=========================================================================================
END
--go
--exec [cac].[Rptcac_ProductEndAmountEx] '006013130268', '0602', '1392/09/30'
GO
