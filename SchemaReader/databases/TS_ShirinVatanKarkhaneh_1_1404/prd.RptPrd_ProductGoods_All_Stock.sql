USE TS_ShirinVatanKarkhaneh_1_1404
GO
SET ANSI_NULLS, QUOTED_IDENTIFIER ON
GO
-- =========== TS-QC:UPDATED ====================
-- Author		 : TakroSystem\Zia
-- Create date   : 1390/01/25
-- Viewed By	 : 
-- Last Modified : 1390/08/04
-- Last Modifier : TakroSystem\Zia
-- Description	 : 
-- ==============================================
Create PROCEDURE [prd].[RptPrd_ProductGoods_All_Stock]
	@ProductID			varchar(20) = null, -- not used
	@ProductQuantity	float = 0,          -- not used        
	@FormulaNo			int = 0,
	@SelectedStore		int = 0, 
	@SelectedGoods		int = 0,
	@DateTo				char(10) = null,
	@StoreID			varchar(20) = null,
	@SortFields			nvarchar(100) = Null,
	@RepOptions			varchar(10) = '10100',  -- bit array options
	@RepInfo			nvarchar(100) = '1@1@1'
WITH ENCRYPTION
AS
declare @StrSelect	nvarchar(4000)
declare @StrWhere	nvarchar(4000)
declare @StrFrom	nvarchar(4000)
declare @StrSelect2	nvarchar(2000)
declare @WhrStore	nvarchar(4000)
declare @RepInfoX	nvarchar(100) 
declare	@LangID		char(1);
declare	@SessionNo	int; 
declare	@UserID		int; 
declare	@ReportID	int; 
declare	@ReportIDX	int; 

declare	@FirstLayer		bit;
declare	@WithFormula	bit; -- فقط کالاهائی که فرمول تولید دارند
declare	@WithoutFormula	bit; 
declare	@CalcPlanning	bit; 
declare @MyProductID	varchar(20);
declare @MyProductQty	float;
Begin
	set NOCOUNT ON;


	Declare @ConstPrdText1Name  nVarchar(100)
	Declare @ConstPrdText2Name  nVarchar(100)
	Declare @ConstPrdText3Name  nVarchar(100)
	Declare @ConstPrdText4Name  nVarchar(100)
	Declare @ConstPrdText5Name  nVarchar(100)
	
	
	set @ConstPrdText1Name = ''
	set @ConstPrdText2Name = ''
	set @ConstPrdText3Name = ''
	set @ConstPrdText4Name = ''
	set @ConstPrdText5Name = ''

	SELECT @ConstPrdText1Name=SettingValue 	FROM pub.tblSettings 	WHERE SettingKey = 'ConstPrdText1'
	SELECT @ConstPrdText2Name=SettingValue 	FROM pub.tblSettings 	WHERE SettingKey = 'ConstPrdText2'
	SELECT @ConstPrdText3Name=SettingValue 	FROM pub.tblSettings 	WHERE SettingKey = 'ConstPrdText3'
	SELECT @ConstPrdText4Name=SettingValue 	FROM pub.tblSettings 	WHERE SettingKey = 'ConstPrdText4'
	SELECT @ConstPrdText5Name=SettingValue 	FROM pub.tblSettings 	WHERE SettingKey = 'ConstPrdText5'
	
		-- I N I T -----------------------------------------------------------------
	if (@RepInfo		Is Null)	set @RepInfo = '1@1@1';
	if (@RepOptions		Is Null)	set @RepOptions	= '10100';

	if (@SelectedGoods	Is Null)	set @SelectedGoods = 0;
	if (@SortFields		Is Null)	set @SortFields = 'GoodsID';

	set @ReportIDX	= 20101010
	set @LangID		= pub.funSplitString(@RepInfo, '@', 1);
	set @SessionNo	= pub.funSplitString(@RepInfo, '@', 2);
	set @ReportID	= pub.funSplitString(@RepInfo, '@', 3);
	set @UserID		= pub.funSplitString(@RepInfo, '@', 4);
	set @RepInfoX	= @LangID + '@' + LTrim(Str(@SessionNo)) + '@' + LTrim(Str(@ReportIDX)) + '@' + LTrim(Str(@UserID)) 

	set @FirstLayer		= Substring(@RepOptions, 1, 1);
	set @WithFormula	= Substring(@RepOptions, 2, 1);
	set @WithoutFormula	= Substring(@RepOptions, 3, 1);

	if len(@RepOptions) > 3
		set @CalcPlanning= Substring(@RepOptions, 4, 1)
	else
		set @CalcPlanning= 0
	---------------------------------------------------------------------------
	-- W H E R E --------------------------------------------------------------
	create table #tblResult
	(
		GoodsID		VarChar(20) collate arabic_cs_as not null,
		StoreID		VarChar(20) collate arabic_cs_as not null,
		Quantity	float	not null ,
		ConstPrdText1  nVarchar(100),
		ConstPrdText2  nVarchar(100),
		ConstPrdText3  nVarchar(100),
		ConstPrdText4  nVarchar(100),
		ConstPrdText5  nVarchar(100)
		
	);
	create table #tblBalance
	(
		GoodsID		varchar(20) collate Arabic_CS_AS  Not Null, 
		Quantity	float Not Null
	);
	-- جدول موقت برای آخرین قیمت کالاها
	create table #tblRptPrd_ProductGoods_All_Stock_Prices
	(
		GoodsID varchar(20) collate arabic_cs_as not null,
		Amount float not null
	);

	if (@FormulaNo <> 0) 
		set @StrWhere = '(H.SerialNo = ' + Str(@FormulaNo) + ')'
	else
		set @StrWhere = '(H.IsDefault = 1)' 

	declare csr_Products cursor for
		select ProductID, Quantity
		from prd.tblProductSlc
		where (UserID = @UserID) and (ReportID = @ReportID) 
	open csr_Products;

	fetch NEXT from csr_Products into @MyProductID, @MyProductQty;
	
	while (@@fetch_status = 0)
	begin
	
		if (@FirstLayer = 1)
		begin
			set @StrSelect = '
			insert into #tblResult
			select	D.GoodsID, D.DefaultStoreID, ((' + LTrim(Str(@MyProductQty)) + ' / H.ProductCount) * D.GoodsQuantity) as Quantity
			,ConstPrdText1,ConstPrdText2,ConstPrdText3,ConstPrdText4,ConstPrdText5
			from	prd.tblFormulasDtl D
						inner join prd.tblFormulasHdr H on D.SerialNo = H.SerialNo and D.ProductID = H.ProductID
			where  (H.ProductID = ''' + @MyProductID + ''') and ' + @StrWhere 
		end
		else
		begin
			set @StrSelect = '
			WITH tblTemp(ProductID, GoodsID,StoreID, Quantity,ConstPrdText1,ConstPrdText2,ConstPrdText3,ConstPrdText4,ConstPrdText5) AS
			(
				select	H.ProductID, D.GoodsID, D.DefaultStoreID, ((' + LTrim(Str(@MyProductQty)) + ' / H.ProductCount) * D.GoodsQuantity) As Quantity
				,ConstPrdText1,ConstPrdText2,ConstPrdText3,ConstPrdText4,ConstPrdText5
				from	prd.tblFormulasDtl D
							inner join prd.tblFormulasHdr H ON D.SerialNo = H.SerialNo AND D.ProductID = H.ProductID 
				where  (H.ProductID = ''' + @MyProductID + ''') AND ' + @StrWhere + '

				union all
				
				select	H.ProductID, D.GoodsID, D.DefaultStoreID, ((tblTemp.Quantity / H.ProductCount) * D.GoodsQuantity) As Quantity
				,D.ConstPrdText1,D.ConstPrdText2,D.ConstPrdText3,D.ConstPrdText4,D.ConstPrdText5
				from	prd.tblFormulasDtl D
							inner join prd.tblFormulasHdr H ON D.SerialNo = H.SerialNo AND D.ProductID = H.ProductID, tblTemp
				where  (H.ProductID = tblTemp.GoodsID) AND ' + @StrWhere + '
			)
			insert into #tblResult
			select	T.GoodsID,T.StoreID, isnull(Sum(Quantity), 0) as Quantity,ConstPrdText1,ConstPrdText2,ConstPrdText3,ConstPrdText4,ConstPrdText5
			from	tblTemp T
			group BY T.GoodsID ,T.StoreID,ConstPrdText1,ConstPrdText2,ConstPrdText3,ConstPrdText4,ConstPrdText5'
		end
			
		exec sp_executesql @StrSelect;
		fetch NEXT from csr_Products into @MyProductID, @MyProductQty;
	end

	close csr_Products;
	deallocate csr_Products;
	---------------------------------------------------------------------------
	-- fill balance -----------------------------------------------------------
	set @WhrStore = '(D.GoodsID in (select GoodsID from #tblResult))'

	if (@StoreID is not null) and (@StoreID <> '') and (@StoreID <> '0')
		set @WhrStore = @WhrStore + ' and (D.StoreID = ''' + @StoreID + ''')'

	if (@SelectedStore > 0)
		set @WhrStore = @WhrStore + ' and ' + pub.funGetFilterString(@SessionNo, @ReportID, @SelectedStore, 'D.StoreID') 

	set @StrSelect = '
	insert into #tblBalance(GoodsID, Quantity)
	select	D.GoodsID, isnull(sum(D.GoodsQuantity * D.EnterKind), 0)
	from	inv.tblStorageDocsDtl D
	where	' + @WhrStore 	
	if (@DateTo is not null)
		set @StrSelect  = @StrSelect  + ' and (D.DocDate <= ''' + @DateTo + ''')'
	set @StrSelect =@StrSelect + '	group by D.GoodsID'

	print @StrSelect;
	exec sp_executesql @StrSelect;
	---------------------------------------------------------------------------
	--- calc prices -----------------------------------------------------------
	insert into #tblRptPrd_ProductGoods_All_Stock_Prices
	select *
	from 
	(
		select distinct GoodsID, 
			(
				select top 1 GoodsAmount 
				from inv.tblStorageDocsDtl D 
				where (D.GoodsID = M.GoodsID) and (D.ProcessID in (55,50)) and (D.GoodsAmount <> 0) and (D.EnterKind = 1)  -- no sd price for lux iran
				order by DocDate DESC, VolumeRowNo DESC
			) GoodsAmount
		from inv.tblStorageDocsDtl M
	) T 
	where GoodsAmount is not null
	
	update #tblRptPrd_ProductGoods_All_Stock_Prices
	set Amount = GoodsPrice
	from inv.tblGoods
	where #tblRptPrd_ProductGoods_All_Stock_Prices.GoodsID = inv.tblGoods.GoodsID 
		and #tblRptPrd_ProductGoods_All_Stock_Prices.Amount = 0

	insert into #tblRptPrd_ProductGoods_All_Stock_Prices(GoodsID, Amount)
	select GoodsID, GoodsPrice
	from inv.tblGoods
	where GoodsID not in (select GoodsID from #tblRptPrd_ProductGoods_All_Stock_Prices)

	---------------------------------------------------------------------------
	-- S E L E C T ------------------------------------------------------------
	set @StrWhere = '(1=1)' 

	if (@WithFormula = 1)
		set @StrWhere = @StrWhere + ' AND (R.GoodsID in (select ProductID from prd.tblFormulasHdr))' 

	if (@WithoutFormula = 1)
		set @StrWhere = @StrWhere + ' AND (R.GoodsID not in (select ProductID from prd.tblFormulasHdr))' 

	if (@SelectedGoods > 0)
		set @StrWhere = @StrWhere + ' AND ' + pub.funGetFilterString(@SessionNo, @ReportID, @SelectedGoods, 'R.GoodsID') 

	set @StrSelect = '
	select R.GoodsID,R.StoreID, isnull(R.Quantity, 0) Quantity, isnull(B.Quantity, 0) Balance, 
		   [pub].[funGetGoodsName](R.GoodsID, ' + Ltrim(RTrim(@LangID)) + ') As GoodsName, UD.UnitID, UD.UnitName,
		   isnull((select sum(ConfirmQuantity) from cmr.tblCMRDtl where GoodsID = R.GoodsID), 0) SumCMR,
		   isnull((select sum(GoodsQuantity)   from inv.tblStorageDocsDtl where (ProcessID = 55) and (GoodsID = R.GoodsID) and (BaseProcessID = 150)), 0) SumBuy,
		   isnull(P.Amount, 0) LastAmount,ISNULL(GS.SetPoint,0) SetPoint
	,ConstPrdText1,ConstPrdText2,ConstPrdText3,ConstPrdText4,ConstPrdText5
		,'''+@ConstPrdText1Name +''' ConstPrdText1Name,'''+@ConstPrdText2Name +''' ConstPrdText2Name,'''+@ConstPrdText3Name +''' ConstPrdText3Name,
	'''+@ConstPrdText4Name +''' ConstPrdText4Name,'''+@ConstPrdText5Name +''' ConstPrdText5Name
	
	from (select GoodsID,StoreID, isnull(Sum(Quantity), 0) Quantity ,ConstPrdText1,ConstPrdText2,ConstPrdText3,ConstPrdText4,ConstPrdText5
	from #tblResult group by GoodsID,StoreID,ConstPrdText1,ConstPrdText2,ConstPrdText3,ConstPrdText4,ConstPrdText5
	) R
			inner join inv.tblGoods		G ON G.GoodsID	= R.GoodsID
			inner join inv.tblUnitsDtl UD ON UD.UnitID	= G.UnitID And LanguageID=' + Ltrim(RTrim(@LangID)) + '
			Left  join (SELECT GoodsID,SUM(SetPoint) SetPoint from inv.tblGoodsStatusDtl D WHERE 1=1 AND ' + @WhrStore + ' GROUP BY GoodsID)  GS ON  GS.GoodsID=R.GoodsID 
			left  join #tblBalance B on R.GoodsID = B.GoodsID
			left  join #tblRptPrd_ProductGoods_All_Stock_Prices P on P.GoodsID = R.GoodsID
	where ' + @StrWhere; 
	---------------------------------------------------------------------------
	-- planing orders ---------------------------------------------------------
	
	if (@CalcPlanning = 1)
	begin
		create table #tblOuter_Sum
		(
			GoodsID		varchar(20) collate arabic_cs_as not null,
			Quantity	float not null,
		ConstPrdText1  nVarchar(100),
		ConstPrdText2  nVarchar(100),
		ConstPrdText3  nVarchar(100),
		ConstPrdText4  nVarchar(100),
		ConstPrdText5  nVarchar(100)
			
		);

		create table #tblInner
		(
			GoodsID		varchar(20) collate arabic_cs_as not null,
			Quantity	float not null,
			Balance		float not null,
			GoodsName	nvarchar(100) not null,
			UnitID		varchar(20) collate arabic_cs_as not null,
			UnitName	nvarchar(100) not null,
			SumCMR		float not null,
			SumBuy		float not null,
			LastAmount  float,
			SetPoint    float,
			ConstPrdText1		varchar(20) collate arabic_cs_as   null,
			ConstPrdText2		varchar(20) collate arabic_cs_as   null,
			ConstPrdText3		varchar(20) collate arabic_cs_as   null,
			ConstPrdText4		varchar(20) collate arabic_cs_as   null,
			ConstPrdText5		varchar(20) collate arabic_cs_as   null,
			ConstPrdText1Name		varchar(20) collate arabic_cs_as   null,
			ConstPrdText2Name		varchar(20) collate arabic_cs_as   null,
			ConstPrdText3Name		varchar(20) collate arabic_cs_as   null,
			ConstPrdText4Name		varchar(20) collate arabic_cs_as   null,
			ConstPrdText5Name		varchar(20) collate arabic_cs_as   null
		);

		create table #tblOuter
		(
			GoodsID		varchar(20) collate arabic_cs_as not null,
			Quantity	float null,
			Balance		float not null,
			GoodsName	nvarchar(100) not null,
			UnitID		varchar(20) collate arabic_cs_as not null,
			UnitName	nvarchar(100) not null,
			SumCMR		float not null,
			SumBuy		float not null,
			LastAmount  float,
			SetPoint    float,
			ConstPrdText1		varchar(20) collate arabic_cs_as   null,
			ConstPrdText2		varchar(20) collate arabic_cs_as   null,
			ConstPrdText3		varchar(20) collate arabic_cs_as   null,
			ConstPrdText4		varchar(20) collate arabic_cs_as   null,
			ConstPrdText5		varchar(20) collate arabic_cs_as   null,
			ConstPrdText1Name		varchar(20) collate arabic_cs_as   null,
			ConstPrdText2Name		varchar(20) collate arabic_cs_as   null,
			ConstPrdText3Name		varchar(20) collate arabic_cs_as   null,
			ConstPrdText4Name		varchar(20) collate arabic_cs_as   null,
			ConstPrdText5Name		varchar(20) collate arabic_cs_as   null
		);

		delete from prd.tblProductSlc 
		where (UserID = @UserID) and (ReportID = @ReportIDX) and (ObjectID = 1)		

        insert into prd.tblProductSlc(ProductID, UserID, ReportID, ObjectID, Quantity)
        select ProductID, @UserID, @ReportIDX, 1, ProductCount as Quantity 
        from pln.tblProduceOrderHdr H
				inner join pln.tblProduceOrderDtl D on D.ProcessID = H.ProcessID and D.ProcessNo = H.ProcessNo and D.FiscalYear = H.FiscalYear and D.SerialNo = H.SerialNo
        where (H.ReserveGoods = 1) and (H.IsFinished = 0)

		insert into #tblInner(GoodsID, Quantity, Balance, GoodsName, UnitID, UnitName, SumCMR, SumBuy, LastAmount,SetPoint,ConstPrdText1,ConstPrdText2,ConstPrdText3,ConstPrdText4,ConstPrdText5,ConstPrdText1Name,ConstPrdText2Name,ConstPrdText3Name,ConstPrdText4Name,ConstPrdText5Name)
		exec [prd].[RptPrd_ProductGoods_All_Stock] null, 0, @FormulaNo, 0, 0, @DateTo, null, @SortFields, '01000', @RepInfoX

		insert into prd.tblProductSlc(ProductID, UserID, ReportID, ObjectID, Quantity)
		select A.GoodsID, @UserID, @ReportIDX, 1, A.Quantity
		from #tblInner A

		insert into #tblOuter
		exec [prd].[RptPrd_ProductGoods_All_Stock] null, 0, @FormulaNo, 0, 0, @DateTo, null, @SortFields, '10100', @RepInfoX

		insert into #tblOuter_Sum(GoodsID,Quantity)
		select GoodsID, isnull(Sum(Quantity), 0) Quantity
		from #tblOuter
		group by GoodsID
		except 
		select GoodsID, isnull(Sum(GoodsQuantity), 0) as Quantity
		from inv.tblStorageDocsDtl
		where ProcessID = 120 and BaseProcessID = 600
		group by GoodsID


	update  #tblOuter_Sum 
	Set ConstPrdText1  =f.ConstPrdText1 ,
		ConstPrdText2  =f.ConstPrdText2 ,
		ConstPrdText3  =f.ConstPrdText3  ,
		ConstPrdText4  =f.ConstPrdText4  ,
		ConstPrdText5  =f.ConstPrdText5  
		from  #tblOuter_Sum  a inner join prd.tblFormulasDtl f
		on a.GoodsID=f.GoodsID
		INNER JOIN prd.tblFormulasHdr H ON f.ProductID = H.ProductID AND f.SerialNo = H.SerialNo
		and H.IsDefault = 1 
		
		
		set @StrSelect = ' 
		select T.*, isnull(R.Quantity, 0) as Reserved
		,R.ConstPrdText1,R.ConstPrdText2,R.ConstPrdText3,R.ConstPrdText4,R.ConstPrdText5,
	'+@ConstPrdText1Name +' ConstPrdText1Name,'+@ConstPrdText2Name +'  ConstPrdText2Name,'+@ConstPrdText3Name +' ConstPrdText3Name,
	'+@ConstPrdText4Name +' ConstPrdText4Name,'+@ConstPrdText5Name +' ConstPrdText5Name
	from (' + @StrSelect +') T left join #tblOuter_Sum R on R.GoodsID = T.GoodsID'
	end

	set @StrSelect = @StrSelect + ' order by ' + @SortFields

	print @StrSelect;
	exec sp_executesql @StrSelect;
	---------------------------------------------------------------------------
End
GO
