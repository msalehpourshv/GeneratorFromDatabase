USE TS_ShirinVatanKarkhaneh_1_1404
GO
SET ANSI_NULLS, QUOTED_IDENTIFIER ON
GO
-- =========== TS-QC:UPDATED ====================
-- Author		 : TakroSystem\Zia
-- Create date   : 1389/09/27
-- Viewed By	 : 
-- Last Modified : 1390/08/03
-- Last Modifier : TakroSystem\Zia
-- Description   : <فرمول تولید محصول - بهمراه موجودی>
-- =================================================================
Create PROCEDURE [prd].[RptPrd_ProductGoods_One_Stock]
	@ProductID			varchar(20),
	@ProductQuantity	float = 1,
	@FormulaNo			int = 0,
	@SelectedStore		int = 0,
	@SelectedGoods		int = 0,
	@DateTo				char(10) = null,
	@StoreID			varchar(20) = null,
	@RepOptions			nvarchar(100) = '01',
	@RepInfo			nvarchar(100) = '1@1@1' -- bit array options
WITH ENCRYPTION
AS
declare	@StrSelect	NVarChar(max)
declare	@StrFrom	NVarChar(max)
declare	@StrWhere0	NVarChar(max)
declare	@StrWhere1	NVarChar(max)
declare	@StrWhere2	NVarChar(max)
declare	@StrWhere3	NVarChar(max)

declare	@LangID		Char(1);
declare	@SessionNo	Int; -- برای حالت کدهای انتخابی
declare	@ReportID	Int; -- برای حالت کدهای انتخابی

declare	@FirstLayer bit;
declare	@ShowPrice	bit;
declare	@OtherGoods	bit;
BEGIN
	SET NOCOUNT ON;

	-- init ------------------------------------------------------------
	if (@RepInfo		Is Null)	set @RepInfo = '1@1@1';
	if (@RepOptions		Is Null)	set @RepOptions = '010';
	if (@SelectedStore	Is Null)	set @SelectedStore = 0;
	if (@SelectedGoods	Is Null)	set @SelectedGoods = 0;

	set @LangID		= pub.funSplitString(@RepInfo, '@', 1);
	set @SessionNo	= pub.funSplitString(@RepInfo, '@', 2);
	set @ReportID	= pub.funSplitString(@RepInfo, '@', 3);

	set @FirstLayer = Substring(@RepOptions, 1, 1);
	set @ShowPrice	= Substring(@RepOptions, 2, 1);
	set @OtherGoods	= Substring(@RepOptions, 3, 1);
	---------------------------------------------------------------------------
	
	
	Declare @ConstPrdText1Name  nVarchar(100)
	Declare @ConstPrdText2Name  nVarchar(100)
	Declare @ConstPrdText3Name  nVarchar(100)
	Declare @ConstPrdText4Name  nVarchar(100)
	Declare @ConstPrdText5Name  nVarchar(100)
	
	
	SELECT @ConstPrdText1Name=SettingValue 	FROM pub.tblSettings 	WHERE SettingKey = 'ConstPrdText1'
	SELECT @ConstPrdText2Name=SettingValue 	FROM pub.tblSettings 	WHERE SettingKey = 'ConstPrdText2'
	SELECT @ConstPrdText3Name=SettingValue 	FROM pub.tblSettings 	WHERE SettingKey = 'ConstPrdText3'
	SELECT @ConstPrdText4Name=SettingValue 	FROM pub.tblSettings 	WHERE SettingKey = 'ConstPrdText4'
	SELECT @ConstPrdText5Name=SettingValue 	FROM pub.tblSettings 	WHERE SettingKey = 'ConstPrdText5'
	
	
	-- where section ----------------------------------------------------------
	if (@FormulaNo <> 0) 
		set @StrWhere0 = '(H.SerialNo = ' + Str(@FormulaNo) + ')'
	else
		set @StrWhere0 = '(H.IsDefault = 1)' 
	
	set @StrWhere1 = '(H.ProductID = ''' + @ProductID + ''')';

	set @StrWhere2 = '(1=1)'

	if (@SelectedGoods > 0)
		set @StrWhere2 = @StrWhere2 + ' AND ' + pub.funGetFilterString(@SessionNo, @ReportID, @SelectedGoods, 'D.GoodsID') 
		
	set @StrWhere3 = '(1=1)'

	if (@SelectedGoods > 0)
		set @StrWhere3 = @StrWhere3 + ' AND ' + pub.funGetFilterString(@SessionNo, @ReportID, @SelectedGoods, 'T.GoodsID') 
	---------------------------------------------------------------------------
	-- select section ---------------------------------------------------------
	create table #tbl_PrdProductGoodsOneStock_Result
	(
		ProductID		varchar(20) collate Arabic_CS_AS  Not Null, 
		GoodsID		varchar(20) collate Arabic_CS_AS  Not Null, 
		GoodsID2		varchar(20) collate Arabic_CS_AS  Not Null, 
		Quantity	float Not Null,
		ConstPrdText1  nVarchar(100),
		ConstPrdText2  nVarchar(100),
		ConstPrdText3  nVarchar(100),
		ConstPrdText4  nVarchar(100),
		ConstPrdText5  nVarchar(100)
	);
	create table #tbl_PrdProductGoodsOneStock_Balance
	(
		GoodsID	varchar(20) collate Arabic_CS_AS  Not Null, 
		Balance	float Not Null
	);
	create table #tbl_PrdProductGoodsOneStock_Prices
	(
		GoodsID varchar(20) collate arabic_cs_as not null,
		Amount	float not null
	);
	
	------------------------------------------------------------------------------
	IF (@OtherGoods = 1)
	
		SELECT	D.SerialNo,D.ProductID, case when isnull(A.GoodsID,'''')=''''		then D.GoodsID		else isnull(A.GoodsID,'''') end  GoodsID , D.GoodsID GoodsID2,
			Case When isnull(A.GoodsQuantity,0) =0 then D.GoodsQuantity else  isnull(A.GoodsQuantity,0) end GoodsQuantity	 
			,D.ConstPrdText1,D.ConstPrdText2,D.ConstPrdText3,D.ConstPrdText4,D.ConstPrdText5,D.DocRowNo
			into #ProductGoods
			FROM	prd.tblFormulasDtl D
					left join prd.tblFormulasAtm A on D.ProductID = A.ProductID  and D.SerialNo = A.SerialNo and D.DocRowNo = A.DocRowNo 
	
	-----------------------------------------------------------------------------
	-- fill ---------------------------------------------------------------------
	IF (@FirstLayer = 1)
	Begin
	IF (@OtherGoods = 0)
		set @StrSelect = '
		insert into	#tbl_PrdProductGoodsOneStock_Result
		select	H.ProductID,D.GoodsID,D.GoodsID GoodsID2, isnull(sum((' + LTrim(Str(@ProductQuantity,20,5)) + ' / H.ProductCount) * D.GoodsQuantity), 0) Quantity
		,ConstPrdText1,ConstPrdText2,ConstPrdText3,ConstPrdText4,ConstPrdText5
		from	prd.tblFormulasDtl D
					inner join prd.tblFormulasHdr H on D.SerialNo = H.SerialNo and D.ProductID = H.ProductID and ' + @StrWhere0 + '
		where  ' + @StrWhere1 + ' and ' + @StrWhere2 + ' 
		group by H.ProductID,D.GoodsID,ConstPrdText1,ConstPrdText2,ConstPrdText3,ConstPrdText4,ConstPrdText5'
		else
		set @StrSelect = '
		insert into	#tbl_PrdProductGoodsOneStock_Result
		select	H.ProductID,case when isnull(A.GoodsID,'''')=''''		then D.GoodsID		else isnull(A.GoodsID,'''') end  GoodsID ,D.GoodsID GoodsID2
		,Case When isnull(A.GoodsQuantity,0) =0 then isnull(sum((' + LTrim(Str(@ProductQuantity,20,5)) + ' / H.ProductCount) * D.GoodsQuantity), 0)
		 else isnull(sum((' + LTrim(Str(@ProductQuantity,20,5)) + ' / H.ProductCount)  * isnull(A.GoodsQuantity,0)), 0)  end Quantity
		,ConstPrdText1,ConstPrdText2,ConstPrdText3,ConstPrdText4,ConstPrdText5
		from	prd.tblFormulasDtl D
					inner join prd.tblFormulasHdr H on D.SerialNo = H.SerialNo and D.ProductID = H.ProductID and ' + @StrWhere0 + '
					left join prd.tblFormulasAtm A on D.ProductID = A.ProductID  and D.SerialNo = A.SerialNo and D.DocRowNo = A.DocRowNo 
		where  ' + @StrWhere1 + ' and ' + @StrWhere2 + ' 
		group by H.ProductID,D.GoodsID,ConstPrdText1,ConstPrdText2,ConstPrdText3,ConstPrdText4,ConstPrdText5, A.GoodsQuantity,A.GoodsID'
		
	End
	ELSE
	Begin
	   IF (@OtherGoods = 0)
		set @StrSelect = '
			WITH tblTemp(ProductID, GoodsID,GoodsID2, [level], Quantity, L2,ConstPrdText1,ConstPrdText2,ConstPrdText3,ConstPrdText4,ConstPrdText5) AS
		(
		SELECT	H.ProductID, D.GoodsID, D.GoodsID GoodsID2, 
				cast(nchar(Row_Number() over (order by GoodsID)+64) as varchar(50)) as [level], 
				(' + LTrim(Str(@ProductQuantity,20,5)) + ' / H.ProductCount) * D.GoodsQuantity As Quantity,
				cast(100+(Row_Number() over (order by DocRowNo)) as varchar(100)) as L2
			,D.ConstPrdText1,D.ConstPrdText2,D.ConstPrdText3,D.ConstPrdText4,D.ConstPrdText5
			FROM	prd.tblFormulasDtl D
						INNER JOIN prd.tblFormulasHdr H ON D.SerialNo = H.SerialNo AND D.ProductID = H.ProductID 
			WHERE  (H.ProductID = ''' + @ProductID + ''') AND ' + @StrWhere0+ '

			UNION All
			
			SELECT	H.ProductID, D.GoodsID,D.GoodsID GoodsID2,  
				cast(tblTemp.level + char(Row_Number() over (order by H.ProductID,D.GoodsID)+64) as varchar(50)) as [level], 
				(tblTemp.Quantity / H.ProductCount) * D.GoodsQuantity As Quantity,
				cast( ltrim(tblTemp.L2)+''-''+ cast(100+(Row_Number() over (order by H.ProductID,D.DocRowNo)) as char(3)) as varchar(100)) as L2
			,D.ConstPrdText1,D.ConstPrdText2,D.ConstPrdText3,D.ConstPrdText4,D.ConstPrdText5
			FROM	prd.tblFormulasDtl D
						INNER JOIN prd.tblFormulasHdr H ON D.SerialNo = H.SerialNo AND D.ProductID = H.ProductID, tblTemp
			WHERE  (H.ProductID = tblTemp.GoodsID) AND ' + @StrWhere0+ '
		)
		insert	into	#tbl_PrdProductGoodsOneStock_Result
		select	T.ProductID,T.GoodsID,T.GoodsID2, isnull(sum(Quantity), 0) Quantity ,ConstPrdText1,ConstPrdText2,ConstPrdText3,ConstPrdText4,ConstPrdText5
		from	tblTemp T where ' + @StrWhere3 + '
		group by T.ProductID,T.GoodsID,T.GoodsID2,ConstPrdText1,ConstPrdText2,ConstPrdText3,ConstPrdText4,ConstPrdText5'
		
		else
		set @StrSelect = '
			WITH tblTemp(ProductID, GoodsID,GoodsID2,  [level], Quantity, L2,ConstPrdText1,ConstPrdText2,ConstPrdText3,ConstPrdText4,ConstPrdText5) AS
		(
		SELECT	H.ProductID,  D.GoodsID	, D.GoodsID2, 
				cast(nchar(Row_Number() over (order by  D.GoodsID		)+64) as varchar(50)) as [level], 
				(' + LTrim(Str(@ProductQuantity,20,5)) + ' / H.ProductCount) * D.GoodsQuantity Quantity	 ,
				cast(100+(Row_Number() over (order by  D.DocRowNo		)) as varchar(100)) as L2
			,D.ConstPrdText1,D.ConstPrdText2,D.ConstPrdText3,D.ConstPrdText4,D.ConstPrdText5
			FROM	 #ProductGoods D
						INNER JOIN prd.tblFormulasHdr H ON D.SerialNo = H.SerialNo AND D.ProductID = H.ProductID 
			WHERE  (H.ProductID = ''' + @ProductID + ''') AND ' + @StrWhere0+ '

			UNION All
			
			SELECT	H.ProductID, D.GoodsID, D.GoodsID2, 
				cast(tblTemp.level + char(Row_Number() over (order by H.ProductID,D.GoodsID)+64) as varchar(50)) as [level], 
				(tblTemp.Quantity / H.ProductCount) * D.GoodsQuantity As Quantity,
				cast( ltrim(tblTemp.L2)+''-''+ cast(100+(Row_Number() over (order by H.ProductID,D.DocRowNo)) as char(3)) as varchar(100)) as L2
			,D.ConstPrdText1,D.ConstPrdText2,D.ConstPrdText3,D.ConstPrdText4,D.ConstPrdText5
			FROM	 #ProductGoods D
						INNER JOIN prd.tblFormulasHdr H ON D.SerialNo = H.SerialNo AND D.ProductID = H.ProductID, tblTemp
			WHERE  (H.ProductID = tblTemp.GoodsID) AND ' + @StrWhere0+ '
		)
		insert	into	#tbl_PrdProductGoodsOneStock_Result
		select	T.ProductID,T.GoodsID, T.GoodsID2, isnull(sum(Quantity), 0) Quantity ,ConstPrdText1,ConstPrdText2,ConstPrdText3,ConstPrdText4,ConstPrdText5
		from	tblTemp T where ' + @StrWhere3 + '
		group by T.ProductID,T.GoodsID,T.GoodsID2,ConstPrdText1,ConstPrdText2,ConstPrdText3,ConstPrdText4,ConstPrdText5'
		
	
	End

	print @StrSelect;
	exec sp_executesql @StrSelect;	   	
	--------------------------------------------------------------------
	-- calc balance of stores ------------------------------------------
	set @StrWhere0 = '(D.GoodsID in (select GoodsID from #tbl_PrdProductGoodsOneStock_Result))';

	if (@DateTo is not null)
		set @StrWhere0 = @StrWhere0 + ' and (D.DocDate <= ''' + @DateTo + ''')'
	if (@StoreID is not null)
		set @StrWhere0 = @StrWhere0 + ' and (D.StoreID = ''' + @StoreID + ''')'
	if (@SelectedStore > 0)
		set @StrWhere0 = @StrWhere0 + ' and ' + pub.funGetFilterString(@SessionNo, @ReportID, @SelectedStore, 'D.StoreID')

	set @StrSelect ='
		insert	into #tbl_PrdProductGoodsOneStock_Balance(GoodsID, Balance)
		select	D.GoodsID, sum(D.GoodsQuantity * D.EnterKind)
		from	inv.tblStorageDocsDtl D
		where	' + @StrWhere0 + '
		group by D.GoodsID '

	print @StrSelect;
	exec sp_executesql @StrSelect;
	--------------------------------------------------------------------
	-- calc price of goods ---------------------------------------------
	if (@ShowPrice = 1)
	begin
		insert into #tbl_PrdProductGoodsOneStock_Prices
		select *
		from 
		(
			select distinct GoodsID, 
				(
					select top 1 GoodsAmount 
					from inv.tblStorageDocsDtl D 
					where (D.GoodsID = M.GoodsID) and (D.GoodsAmount <> 0) and (D.EnterKind = 2)  -- no sd price for lux iran
					order by DocDate DESC, VolumeRowNo DESC
				) GoodsAmount
			from inv.tblStorageDocsDtl M
		) T 
		where GoodsAmount is not null
		
		update #tbl_PrdProductGoodsOneStock_Prices
		set Amount = GoodsPrice
		from inv.tblGoods
		where #tbl_PrdProductGoodsOneStock_Prices.GoodsID = inv.tblGoods.GoodsID 
			and #tbl_PrdProductGoodsOneStock_Prices.Amount = 0
			
		insert into #tbl_PrdProductGoodsOneStock_Prices(GoodsID, Amount)
		select GoodsID, GoodsPrice
		from inv.tblGoods
		where GoodsID not in (select GoodsID from #tbl_PrdProductGoodsOneStock_Prices)
			
	end;
	--------------------------------------------------------------------
	
	
	update #tbl_PrdProductGoodsOneStock_Result
	Set ConstPrdText1  =f.ConstPrdText1 ,
		ConstPrdText2  =f.ConstPrdText2 ,
		ConstPrdText3  =f.ConstPrdText3  ,
		ConstPrdText4  =f.ConstPrdText4  ,
		ConstPrdText5  =f.ConstPrdText5  
		from #tbl_PrdProductGoodsOneStock_Result a inner join prd.tblFormulasDtl f
		on a.GoodsID=f.GoodsID
		INNER JOIN prd.tblFormulasHdr H ON f.ProductID = H.ProductID AND f.SerialNo = H.SerialNo
		and H.IsDefault = 1 
		
	
	-- final select ----------------------------------------------------
	select	R.ProductID,	R.GoodsID, R.GoodsID2 GoodsIDBase, R.Quantity, [pub].[funGetGoodsName](R.GoodsID, @LangID) As GoodsName, [pub].[funGetGoodsName](R.GoodsID2, @LangID) As GoodsNameBase,
	Case when R.GoodsID<> R.GoodsID2 then 1 else 0 end GoodsIDChanged,
			isnull(B.Balance, 0) Balance, 
			isnull(P.Amount, 0) LastAmount
	,ConstPrdText1,ConstPrdText2,ConstPrdText3,ConstPrdText4,ConstPrdText5,
	@ConstPrdText1Name ConstPrdText1Name,@ConstPrdText2Name ConstPrdText2Name,@ConstPrdText3Name ConstPrdText3Name,
	@ConstPrdText4Name ConstPrdText4Name,@ConstPrdText5Name ConstPrdText5Name, [pub].[funGetGoodsUnitName] (R.GoodsID,1) UnitName
	from	#tbl_PrdProductGoodsOneStock_Result R
				left join #tbl_PrdProductGoodsOneStock_Prices P on P.GoodsID = R.GoodsID
				left join #tbl_PrdProductGoodsOneStock_Balance B on R.GoodsID = B.GoodsID
	--------------------------------------------------------------------
END
GO
