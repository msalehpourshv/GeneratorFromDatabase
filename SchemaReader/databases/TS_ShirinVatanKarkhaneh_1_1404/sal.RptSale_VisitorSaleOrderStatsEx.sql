USE TS_ShirinVatanKarkhaneh_1_1404
GO
SET ANSI_NULLS, QUOTED_IDENTIFIER ON
GO
-- =========== TS-QC:UPDATED ====================
-- Author		 : TakroSystem\Zia
-- Create date   : 1390/06/01
-- Viewed By	 : 
-- Last Modified : 
-- Last Modifier : 
-- Description	 : 
-- ==============================================
Create PROCEDURE [sal].[RptSale_VisitorSaleOrderStatsEx]
	@ProcessNo		int = 1,
	@VistAcnt1		Int = 0,
	@VistAcnt2		Int = 0,
	@VistAcnt3		Int = 0,
	@VistAcnt4		Int = 0,
	@CustAcnt1		Int = 0,
	@CustAcnt2		Int = 0,
	@CustAcnt3		Int = 0,
	@CustAcnt4		Int = 0,
	@FiscalYearFr	Int = Null,
	@SerialNoFr		Int = Null,
	@FiscalYearTo	Int = Null,
	@SerialNoTo		Int = Null,
	@DocDateFr		char(10) = null,
	@DocDateTo		char(10) = null,
	@SaleTypeID		VarChar(20) = Null, -- �� ��� ����
	@DocStep		Int = 0,  -- �����
	@SortFields		NVarChar(200) = Null,
	@ExtraParams	NVarChar(100) = '',
	@RepOptions		VarChar(10) = '1000',  -- bit array options
	@RepInfo		NVarChar(100) = '1@1@1'
WITH ENCRYPTION
AS
DECLARE @StrSelect	NVarChar(Max)
DECLARE @StrSelect2	NVarChar(Max)
DECLARE @StrSelect3	NVarChar(Max)
DECLARE @StrCount	NVarChar(Max)
DECLARE @StrWhere	NVarChar(Max)
DECLARE @StrWhereD	NVarChar(Max)
DECLARE @StrWhereB	NVarChar(Max)
DECLARE @StrWhereG	NVarChar(Max)
DECLARE @StrFrom	NVarChar(Max)

DECLARE	@LangID			Char(1);
DECLARE	@SessionNo		Int; 
DECLARE	@ReportID		Int;
DECLARE	@UserID			Int;
DECLARE	@UserIsAdmin	bit;

-- ======
DECLARE @goods_id					Varchar(20);
DECLARE @visitor_acnt_code			Varchar(20);
DECLARE @sale_quantity				DECIMAL(28,9);
DECLARE @ret_quantity				DECIMAL(28,9);

-- ======
DECLARE @unit_name			nvarchar(200);
DECLARE @unit_id			varchar(20);
DECLARE @unit_value			float;
DECLARE @unit_value_Temp	float;
DECLARE @Mainunit_value		float;
DECLARE @Cnt				INT;

-- ======
DECLARE @unit_nameSale1			nvarchar(200);
DECLARE @unit_idSale1			varchar(20);
DECLARE @unit_valueSale1		float;
DECLARE @Mainunit_valueSale1	float;

DECLARE @unit_nameSale2			nvarchar(200);
DECLARE @unit_idSale2			varchar(20);
DECLARE @unit_valueSale2		float;
DECLARE @Mainunit_valueSale2	float;

-- ======
DECLARE @unit_nameRet1			nvarchar(200);
DECLARE @unit_idRet1			varchar(20);
DECLARE @unit_valueRet1			float;
DECLARE @Mainunit_valueRet1		float;

DECLARE @unit_nameRet2			nvarchar(200);
DECLARE @unit_idRet2			varchar(20);
DECLARE @unit_valueRet2			float;
DECLARE @Mainunit_valueRet2		float;

DECLARE @bolMainAndSubUnit	Bit;

DECLARE @SelectedGoods		Int;

BEGIN

	SET NOCOUNT ON;

	SET @LangID			= pub.funSplitString(@RepInfo, '@', 1);
	SET @SessionNo		= pub.funSplitString(@RepInfo, '@', 2);
	SET @ReportID		= pub.funSplitString(@RepInfo, '@', 3);
	SET @UserID			= pub.funSplitString(@RepInfo, '@', 4);
	SET @UserIsAdmin	= pub.funSplitString(@RepInfo, '@', 5);

	--================================== UnitPart
	DECLARE @UnitPart	TINYINT
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
	--==================================
	
	-- I N I T -----------------------------------------------------------------
	IF (@RepInfo		Is Null)	SET @RepInfo = '1@1@1';
	IF (@RepOptions		Is Null)	SET @RepOptions	= '1000';
	IF (@ExtraParams	Is Null)	SET @ExtraParams= '1,2,3,4';
	IF (@SortFields		Is Null)	SET @SortFields = 'T.VisitorAcntCode';
	IF (@DocStep		Is Null)	SET @DocStep = 0;

	IF (@VistAcnt1	Is Null)	SET @VistAcnt1 = 0;
	IF (@VistAcnt2	Is Null)	SET @VistAcnt2 = 0;
	IF (@VistAcnt3	Is Null)	SET @VistAcnt3 = 0;
	IF (@VistAcnt4	Is Null)	SET @VistAcnt4 = 0;
	IF (@CustAcnt1	Is Null)	SET @CustAcnt1 = 0;
	IF (@CustAcnt2	Is Null)	SET @CustAcnt2 = 0;
	IF (@CustAcnt3	Is Null)	SET @CustAcnt3 = 0;
	IF (@CustAcnt4	Is Null)	SET @CustAcnt4 = 0;

	If (@FiscalYearFr Is Null)	SET @SerialNoFr = Null;
	If (@FiscalYearTo Is Null)	SET @SerialNoTo = Null;
	If (@SerialNoFr	Is Null)	SET @FiscalYearFr = Null;
	If (@SerialNoTo	Is Null)	SET @FiscalYearTo = Null;

	SET @LangID		= pub.funSplitString(@RepInfo, '@', 1);
	SET @SessionNo	= pub.funSplitString(@RepInfo, '@', 2);
	SET @ReportID	= pub.funSplitString(@RepInfo, '@', 3);

	SET @bolMainAndSubUnit	= Substring(@RepOptions, 1, 1);

	SET @SelectedGoods = LTrim(pub.funSplitString(@ExtraParams, '@', 1)); 

	IF (@SelectedGoods Is Null)	SET @SelectedGoods = 0;

	--==================================
	--begin try
	--	drop table ##tbl_Tmp
	--end try
	--begin catch
	--end catch
	
	--begin try
	--	drop table #tbl_result
	--end try
	--begin catch
	--end catch
	
	-- ==========
	DECLARE @QuantityDecimalsToForms AS Int

	SET		@QuantityDecimalsToForms = 3
	SELECT  @QuantityDecimalsToForms=SettingValue
	FROM pub.tblSettings
	WHERE SettingKey = 'QuantityDecimalsToForms'

	IF @QuantityDecimalsToForms>0
		SET		@QuantityDecimalsToForms = @QuantityDecimalsToForms - 1

	Create Table #tbl_Tmp
	(
		VisitorAcntCode			varchar(20) collate Arabic_CS_AS null,
		GoodsID					varchar(20) collate Arabic_CS_AS null,
		SaleGoodsQuantity		DECIMAL(28,9),
		RetGoodsQuantity		DECIMAL(28,9)
	);
		

	Create Table #tbl_result
	(
		VisitorAcntCode			varchar(20) collate Arabic_CS_AS null,
		GoodsID					varchar(20) collate Arabic_CS_AS null,
		QuantitySale			DECIMAL(28,9),
		UnitIDSale1				varchar(20) collate Arabic_CS_AS null,
		UnitNameSale1			nvarchar(20) collate Arabic_CS_AS null,
		QuantitySale1			DECIMAL(28,9),
		UnitIDSale2				varchar(20) collate Arabic_CS_AS null,
		UnitNameSale2			nvarchar(20) collate Arabic_CS_AS null,
		QuantitySale2			DECIMAL(28,9),
		QuantityRet				DECIMAL(28,9),
		UnitIDRet1				varchar(20) collate Arabic_CS_AS null,
		UnitNameRet1			nvarchar(20) collate Arabic_CS_AS null,
		QuantityRet1			DECIMAL(28,9),
		UnitIDRet2				varchar(20) collate Arabic_CS_AS null,
		UnitNameRet2			nvarchar(20) collate Arabic_CS_AS null,
		QuantityRet2			DECIMAL(28,9),
		Weight					float,
		Volume					float,
		BarCode					varchar(20) collate Arabic_CS_AS null
	);
		
	Declare @tbl_units as table
	(
		unit_id					varchar(20) not null, 
		unit_name				nvarchar(200) not null, 
		unit_value				float not null,
		Mainunit_value			float not null,
		cnt						int not null--,
	);
		
	---------------------------------------------------------------------------
	-- W H E R E --------------------------------------------------------------
	SET @StrWhere = '(H.ProcessNo = ' + LTrim(Str(@ProcessNo)) + ')'
	SET @StrWhereB = '1 = 1'
	SET @StrWhereG = ''

	IF (@DocStep > 0)
		SET @StrWhere = @StrWhere + ' AND (H.DocStep >= ' + LTrim(Str(@DocStep)) + ')'

	If @SaleTypeID Is Not Null
		Set @StrWhere = @StrWhere + ' AND (H.SaleTypeID = ''' + @SaleTypeID + ''')'

	IF (@VistAcnt1 > 0)
		SET @StrWhere = @StrWhere + ' AND ' + pub.funGetFilterString(@SessionNo, @ReportID, @VistAcnt1, 'H.VisitorAcntCode')
	IF (@VistAcnt2 > 0)
		SET @StrWhere = @StrWhere + ' AND ' + pub.funGetFilterString(@SessionNo, @ReportID, @VistAcnt2, 'H.VisitorAcntCode')
	IF (@VistAcnt3 > 0)
		SET @StrWhere = @StrWhere + ' AND ' + pub.funGetFilterString(@SessionNo, @ReportID, @VistAcnt3, 'H.VisitorAcntCode')
	IF (@VistAcnt4 > 0)
		SET @StrWhere = @StrWhere + ' AND ' + pub.funGetFilterString(@SessionNo, @ReportID, @VistAcnt4, 'H.VisitorAcntCode')

	IF (@SerialNoFr Is Not Null)
		Set @StrWhere = @StrWhere + ' AND (H.FiscalYear > ' + LTrim(Str(@FiscalYearFr)) + ' OR 
		(H.FiscalYear = ' + LTrim(Str(@FiscalYearFr)) + ' AND H.SerialNo >= ' + LTrim(Str(@SerialNoFr)) + '))' 

	IF (@SerialNoTo Is Not Null)
		Set @StrWhere = @StrWhere + ' AND (H.FiscalYear < ' + LTrim(Str(@FiscalYearTo)) + ' OR 
		(H.FiscalYear = ' + LTrim(Str(@FiscalYearTo)) + ' AND H.SerialNo <= ' + LTrim(Str(@SerialNoTo)) + '))' 

	IF (@DocDateFr is not null)
		SET @StrWhere = @StrWhere + ' AND (H.DocDate >= ''' + @DocDateFr + ''')'
	IF (@DocDateTo is not null)
		SET @StrWhere = @StrWhere + ' AND (H.DocDate <= ''' + @DocDateTo + ''')'

	IF (@DocDateFr is not null)
		SET @StrWhereB = @StrWhereB + ' AND (BH.DocDate >= ''' + @DocDateFr + ''')'
	IF (@DocDateTo is not null)
		SET @StrWhereB = @StrWhereB + ' AND (BH.DocDate <= ''' + @DocDateTo + ''')'

	IF (@CustAcnt1 > 0)
		SET @StrWhere = @StrWhere + ' AND ' + pub.funGetFilterString(@SessionNo, @ReportID, @CustAcnt1, 'H.AcntCode')
	IF (@CustAcnt2 > 0)
		SET @StrWhere = @StrWhere + ' AND ' + pub.funGetFilterString(@SessionNo, @ReportID, @CustAcnt2, 'H.AcntCode')
	IF (@CustAcnt3 > 0)
		SET @StrWhere = @StrWhere + ' AND ' + pub.funGetFilterString(@SessionNo, @ReportID, @CustAcnt3, 'H.AcntCode')
	IF (@CustAcnt4 > 0)
		SET @StrWhere = @StrWhere + ' AND ' + pub.funGetFilterString(@SessionNo, @ReportID, @CustAcnt4, 'H.AcntCode')

	If (@SelectedGoods > 0)
		SET @StrWhereG = ' AND ' + pub.funGetFilterString(@SessionNo, @ReportID, @SelectedGoods, 'D.GoodsID') 
		
	--===============================================================================
	-- ******************************************************************************
	SET @StrSelect = '
	INSERT INTO #tbl_Tmp
	Select Sale.VisitorAcntCode, Sale.GoodsID, 
		   IsNull(Sum(Sale.GoodsQuantity),0) SaleGoodsQuantity, IsNull(Sum(Ret.GoodsQuantity),0) RetGoodsQuantity
	From (
	select  H.VisitorAcntCode, D.GoodsID, SUM(D.GoodsQuantity) GoodsQuantity
	from	sal.tblSaleOrderHdr H
	Inner Join sal.tblSaleOrderDtl D ON D.ProcessID = H.ProcessID And D.ProcessNo = H.ProcessNo And D.FiscalYear = H.FiscalYear And
										  D.SerialNo = H.SerialNo
	Where  (H.ProcessID = 180) And ' + @StrWhere + @StrWhereG + '
	Group By H.VisitorAcntCode,D.GoodsID
	) Sale
	Left Join 
	( 
		select  H.VisitorAcntCode, D.GoodsID, SUM(D.GoodsQuantity) GoodsQuantity
		from	sal.tblSaleOrderHdr H
		Inner Join sal.tblSaleOrderDtl D ON D.ProcessID = H.ProcessID And D.ProcessNo = H.ProcessNo And D.FiscalYear = H.FiscalYear And
											  D.SerialNo = H.SerialNo
		where  (H.ProcessID = 185) And ' + @StrWhere  + @StrWhereG  + '
		group by H.VisitorAcntCode,D.GoodsID
	) Ret ON Sale.VisitorAcntCode = Ret.VisitorAcntCode And Sale.GoodsID = Ret.GoodsID
	Group By Sale.VisitorAcntCode, Sale.GoodsID'
	
	PRINT @StrSelect;
	EXEC sp_executesql @StrSelect;
	-- ******************************************************************************	
	--===============================================================================
	SET @StrSelect = '
	INSERT INTO #tbl_result
	Select VisitorAcntCode, GoodsID, SaleGoodsQuantity, '''', '''', 0, '''', '''', 0, RetGoodsQuantity, '''', '''', 0, '''', '''', 0,
		   0, 0, ''''
	From #tbl_Tmp S 
	-- =========='
	--Print @StrSelect;
	Exec sp_executesql @StrSelect;	
 
	--Select * From #tbl_Tmp
	--Select * From #tbl_result Order By VisitorAcntCode
	-- ******************************************************************************
	-- *********************************** Units ************************************
	-- ******************************************************************************
	declare cur_goods cursor for
		select  VisitorAcntCode, GoodsID, SaleGoodsQuantity, RetGoodsQuantity
		from #tbl_Tmp
	open cur_goods;
		
	fetch next from cur_goods into @visitor_acnt_code, @goods_id, @sale_quantity, @ret_quantity

	while (@@fetch_status = 0)
	begin
		-- 1- empty units table
		delete from @tbl_units
		
		-- 2- fill units of 1 goods
		insert into @tbl_units
		select top 3 t.UnitID, u.UnitName, t.UnitValue, t.MainUnitValue,
		(SELECT COUNT(*) 
		 from(
				select UnitID, 1 As UnitValue,1 MainUnitValue
				from inv.tblGoods
				where GoodsID = @goods_id
				union
				select SubUnitID, UnitValue,MainUnitValue
				from inv.tblSubUnitsDtl S
				where GoodsID = @goods_id And ShowInInvoice = 1) z
		)cnt
		from
		(
			select UnitID, 1 As UnitValue,1 MainUnitValue
			from inv.tblGoods
			where GoodsID = @goods_id
			union
			select SubUnitID, UnitValue,MainUnitValue
			from inv.tblSubUnitsDtl S
			where GoodsID = @goods_id And ShowInInvoice = 1
			
		) t inner join inv.tblUnitsDtl u on u.UnitID = t.UnitID and u.LanguageID = @LangID
		order by (t.MainUnitValue/ t.UnitValue ) desc
			
		-- read units row by row
		declare cur_units cursor for
			select *
			from @tbl_units
		open cur_units;

		-- init
		set @unit_idSale1			 = '';
		set @unit_nameSale1			 = '';
		set @unit_valueSale1		 =  0;
		set @Mainunit_valueSale1	 =  0;
		set @unit_idSale2			 = '';
		set @unit_nameSale2			 = '';
		set @unit_valueSale2		 =  0;
		set @Mainunit_valueSale2	 =  0;	
		
		set @unit_idRet1			 = '';
		set @unit_nameRet1			 = '';
		set @unit_valueRet1			 =  0;
		set @Mainunit_valueRet1		 =  0;
		set @unit_idRet2			 = '';
		set @unit_nameRet2			 = '';
		set @unit_valueRet2			 =  0;
		set @Mainunit_valueRet2		 =  0;
		
		-- First Unit
		fetch next from cur_units into @unit_id, @unit_name, @unit_value, @Mainunit_value, @Cnt;

		if (@@fetch_status = 0)
		begin
			set @unit_idSale1		= @unit_id;
			set @unit_nameSale1		= @unit_name;
								
			set @unit_idRet1		= @unit_id;
			set @unit_nameRet1		= @unit_name;
			
			if @Cnt > 1
			Begin
				set @unit_valueSale1	 = floor((@sale_quantity + 0.000000001) * @unit_value / @Mainunit_value)
				set @unit_valueRet1		 = floor((@ret_quantity + 0.000000001) * @unit_value / @Mainunit_value)
			End
			Else
			Begin
				set @unit_valueSale1	 = @sale_quantity * @unit_value / @Mainunit_value
				set @unit_valueRet1		 = @ret_quantity  * @unit_value / @Mainunit_value
			End
			
			set @sale_quantity = @sale_quantity - (@unit_valueSale1 * @Mainunit_value / @unit_value)
			set @ret_quantity  = @ret_quantity  - (@unit_valueRet1 * @Mainunit_value / @unit_value)

			-- Second Unit
			fetch next from cur_units into @unit_id, @unit_name, @unit_value, @Mainunit_value, @Cnt;

			if (@@fetch_status = 0)
			begin
				set @unit_idSale2		= @unit_id;
				set @unit_nameSale2		= @unit_name;
				
				set @unit_idRet2		= @unit_id;
				set @unit_nameRet2		= @unit_name;
				
				if @Cnt > 2 
				Begin
					set @unit_valueSale2	 = floor((@sale_quantity + 0.000000001) * @unit_value / @Mainunit_value)
					set @unit_valueRet2		 = floor((@ret_quantity + 0.000000001)  * @unit_value / @Mainunit_value)
				End
				else	
				Begin
					set @unit_valueSale2	 = @sale_quantity * @unit_value / @Mainunit_value
					set @unit_valueRet2		 = @ret_quantity  * @unit_value / @Mainunit_value
				End
				
				set @sale_quantity		= @sale_quantity - (@unit_valueSale2 * @Mainunit_value / @unit_value)
				set @ret_quantity		= @ret_quantity  - (@unit_valueRet2  * @Mainunit_value / @unit_value)
			end;

		end;

		-- close units cursor
		close cur_units;
		deallocate cur_units;

		-- update result
		update #tbl_result
		set UnitIDSale1				= IsNull(@unit_idSale1,''),
			UnitNameSale1			= IsNull(@unit_nameSale1,''),
			QuantitySale1			= IsNull(@unit_valueSale1,0),
			UnitIDSale2				= IsNull(@unit_idSale2,''),
			UnitNameSale2			= IsNull(@unit_nameSale2,''),
			QuantitySale2			= IsNull(@unit_valueSale2,0),

			UnitIDRet1				= IsNull(@unit_idRet1,''),
			UnitNameRet1			= IsNull(@unit_nameRet1,''),
			QuantityRet1			= IsNull(@unit_valueRet1,0),
			UnitIDRet2				= IsNull(@unit_idRet2,''),
			UnitNameRet2			= IsNull(@unit_nameRet2,''),
			QuantityRet2			= IsNull(@unit_valueRet2,0),
			
			Weight					= IsNull(G.GoodsWeight,0),
			Volume					= IsNull(G.GoodsLength * G.GoodsHeight * G.GoodsWidth,0),
			BarCode					= IsNull([inv].[FunGetGoodsBarCode] (G.GoodsID), '')
		from inv.tblGoods G
		INNER JOIN inv.tblGoodsDtl GD ON GD.GoodsID = SUBSTRING(G.GoodsID,@str_Goods+1, @str_GoodsSum) AND GD.PartNumber= @UnitPart AND GD.LanguageID = @LangID
		where G.GoodsID = @goods_id AND #tbl_result.GoodsID = @goods_id And #tbl_result.VisitorAcntCode = @visitor_acnt_code

		-- next
		fetch next from cur_goods into @visitor_acnt_code, @goods_id, @sale_quantity, @ret_quantity
	end

	-- close goods cursor
	Close cur_goods;
	Deallocate cur_goods;
	-- ******************************************************************************
	-- ********************************** Units End *********************************
	-- ******************************************************************************
	--Select * From ##tbl_Tmp
	--Select * From #tbl_result Order By VisitorAcntCode

	--Select VisitorAcntCode, SUM(QuantitySale1) QuantitySale1,SUM(QuantitySale2)QuantitySale2,
	--		 SUM(QuantityRet1) QuantityRet1,SUM(QuantityRet2)QuantityRet2
	--From #tbl_result
	--Group By VisitorAcntCode
	--Order By VisitorAcntCode
	
		SET @StrCount= ' Select Count(D.GoodsID) Counts 
						 From  sal.tblSaleOrderDtl  D 
						 Inner Join inv.tblStorageDocsHdr H ON D.ProcessID = H.ProcessID And D.ProcessNo = H.ProcessNo And 
															   D.FiscalYear = H.FiscalYear And	 D.SerialNo = H.SerialNo '
	---------------------------------------------------------------------------

	SET @StrWhereD  =  ' 1=1 '

	if @UserIsAdmin=0
	begin

	BEGIN TRY
		DROP TABLE #tblAcntCode
		DROP TABLE #tblStoreID
		DROP TABLE #tblVisitorAcntCode
		DROP TABLE #tblGoods
	END TRY
	BEGIN CATCH
	END CATCH

	CREATE TABLE #tblGoods
	(
	GoodsID 			Varchar(20)collate arabic_cs_as null
	)
	CREATE TABLE #tblVisitorAcntCode
	(
	VisitorAcntCode 			Varchar(20)collate arabic_cs_as null
	)
	
	Insert into  #tblVisitorAcntCode (VisitorAcntCode)	select Distinct VisitorAcntCode	from sal.tblSaleOrderDtl
	 exec pub.SpFilterByPermission2 '#tblVisitorAcntCode', 'VisitorAcntCode', 'acc.tblAcnt', @UserID;
	 
	SET @StrWhereD  =  ' 1=1 and T.VisitorAcntCode in (SELECT VisitorAcntCode FROM  #tblVisitorAcntCode ) '

	END


	-- S E L E C T ------------------------------------------------------------
	SET @StrSelect = '
	SELECT	T.VisitorAcntCode, pub.GetCodeName(T.VisitorAcntCode, 1) as VisitorAcntName,
			isnull(sum(T.CountX), 0) as SaleCount, 
			isnull(sum(T.Qty), 0) as Quantity, 
			isnull(sum(T.QtyR), 0) as QuantityR, 
			isnull(Count(T.SerialNoQty), 0) as SerialNoCount, 
			isnull(Count(T.SerialNoQtyR), 0) as SerialNoCountR, 
			isnull(sum(T.CountR), 0) as SaleRetCount,
			isnull(sum(T.SumPriceX), 0) as SumSale,
			isnull(sum(T.SumPriceR), 0) as SumSaleRet,
			isnull(sum(T.DiscountX), 0) as SumSaleDiscount,
			isnull(sum(T.DiscountR), 0) as SumSaleRetDiscount,
			isnull(sum(T.Discount2X), 0) as SumSaleDiscount2,
			isnull(sum(T.Discount2R), 0) as SumSaleRetDiscount2,
			isnull(sum(T.Discount3X), 0) as SumSaleDiscount3,
			isnull(sum(T.Discount3R), 0) as SumSaleRetDiscount3,
			isnull(sum(T.Discount4X), 0) as SumSaleDiscount4,
			isnull(sum(T.Discount4R), 0) as SumSaleRetDiscount4,
			ROUND(IsNull(R2.QuantitySale1,0), ' + LTrim(RTrim(Str(@QuantityDecimalsToForms))) + ') SaleQuantity1, 
			ROUND(IsNull(R2.QuantitySale2,0), ' + LTrim(RTrim(Str(@QuantityDecimalsToForms))) + ') SaleQuantity2,
			ROUND(IsNull(R2.QuantityRet1,0), ' + LTrim(RTrim(Str(@QuantityDecimalsToForms))) + ') RetQuantity1, 
			ROUND(IsNull(R2.QuantityRet2,0), ' + LTrim(RTrim(Str(@QuantityDecimalsToForms))) + ') RetQuantity2
			,( '+ @StrCount+' where  D.ProcessID =90 and '+  @StrWhere  +' Group by D.ProcessID ) CountSale 
			,('+ @StrCount+' where  D.ProcessID =100 and '+  @StrWhere  +' Group by D.ProcessID )CountRet
	FROM
	('

	SET @StrSelect2 = '	
	 	SELECT  H.VisitorAcntCode, H.Discount as DiscountX, H.Discount2 as Discount2X, count(*) as CountX, 
				(
					select sum(GoodsPrice * GoodsQuantity) 
					from sal.tblSaleOrderDtl D 
					where H.ProcessID = D.ProcessID AND H.ProcessNo = D.ProcessNo AND H.FiscalYear = D.FiscalYear AND H.SerialNo = D.SerialNo
					' + @StrWhereG + '
				) SumPriceX,
				(
					select Distinct Count(SerialNo) 
					from sal.tblSaleOrderDtl D 
					where H.ProcessID = D.ProcessID AND H.ProcessNo = D.ProcessNo AND H.FiscalYear = D.FiscalYear AND H.SerialNo = D.SerialNo
					' + @StrWhereG + '
				) SerialNoQty, 
				(
					select sum(GoodsQuantity) 
					from sal.tblSaleOrderDtl D 
					where H.ProcessID = D.ProcessID AND H.ProcessNo = D.ProcessNo AND H.FiscalYear = D.FiscalYear AND H.SerialNo = D.SerialNo
					' + @StrWhereG + '
				) Qty,0 as CountR, 0 as SumPriceR,0 as SerialNoQtyR,0 as QtyR, 0 as DiscountR, 0 as Discount2R,	0 Discount3X, 0 Discount3R,
				(
					select sum(DiscountDtl) 
					from sal.tblSaleOrderDtl D 
					where D.VisitorAcntCode = H.VisitorAcntCode AND H.ProcessID = D.ProcessID AND H.ProcessNo = D.ProcessNo AND H.FiscalYear = D.FiscalYear AND H.SerialNo = D.SerialNo
					' + @StrWhereG + '
				) Discount4X, 0 as Discount4R
		FROM	sal.tblSaleOrderHdr H
		WHERE  (H.ProcessID = 180) and ' + @StrWhere + ' 
		GROUP BY H.VisitorAcntCode, H.Discount, H.Discount2, H.ProcessID, H.ProcessNo, 
				 H.FiscalYear, H.SerialNo ' 
		
	SET @StrSelect3 = '	
		union all
		select  H.VisitorAcntCode, 0 as DiscountX, 0 as Discount2X, 0 as CountX, 0 as SumPriceX,0 as SerialNoQty,0 as Qty ,count(*) as CountR, 
				(
					select sum(GoodsQuantity*GoodsPrice) 
					from sal.tblSaleOrderDtl D 
					where D.VisitorAcntCode = H.VisitorAcntCode AND H.ProcessID = D.ProcessID AND H.ProcessNo = D.ProcessNo AND H.FiscalYear = D.FiscalYear AND H.SerialNo = D.SerialNo
					' + @StrWhereG + '
				) SumPriceR ,
				(
					select Distinct Count(SerialNo) 
					from sal.tblSaleOrderDtl D 
					where D.VisitorAcntCode = H.VisitorAcntCode AND H.ProcessID = D.ProcessID AND H.ProcessNo = D.ProcessNo AND H.FiscalYear = D.FiscalYear AND H.SerialNo = D.SerialNo
					' + @StrWhereG + '
				) SerialNoQtyR ,(
					select sum(GoodsPrice*GoodsQuantity) 
					from sal.tblSaleOrderDtl D 
					where D.VisitorAcntCode = H.VisitorAcntCode AND H.ProcessID = D.ProcessID AND H.ProcessNo = D.ProcessNo AND H.FiscalYear = D.FiscalYear AND H.SerialNo = D.SerialNo
					' + @StrWhereG + '
				) QtyR ,H.Discount as DiscountR, H.Discount2 as Discount2R, 0 as Discount3X, 0 as Discount3R, 0 AS Discount4X, 
				(
					select sum(DiscountDtl) 
					from sal.tblSaleOrderDtl D 
					where D.VisitorAcntCode = H.VisitorAcntCode AND H.ProcessID = D.ProcessID AND H.ProcessNo = D.ProcessNo AND H.FiscalYear = D.FiscalYear AND H.SerialNo = D.SerialNo
					' + @StrWhereG + '
				) Discount4R
		from	sal.tblSaleOrderHdr H
		where  (H.ProcessID=185) and ' + @StrWhere + ' 
		group by H.VisitorAcntCode, H.Discount, H.Discount2, H.ProcessID, H.ProcessNo, H.FiscalYear, H.SerialNo
	) T
	LEFT JOIN (Select VisitorAcntCode, SUM(QuantitySale1) QuantitySale1,SUM(QuantitySale2)QuantitySale2,
					  SUM(QuantityRet1) QuantityRet1,SUM(QuantityRet2)QuantityRet2
			   From #tbl_result			 
			   Group By VisitorAcntCode) R2 ON R2.VisitorAcntCode = T.VisitorAcntCode --AND R2.GoodsID = T.GoodsID
	where '+@StrWhereD+'
	GROUP BY T.VisitorAcntCode, R2.QuantitySale1, R2.QuantitySale2, R2.QuantityRet1, R2.QuantityRet2
	--Having VisitorAcntCode <> ''''
	ORDER BY ' + @SortFields 

	PRINT @StrSelect;
	PRINT @StrSelect2;
	PRINT @StrSelect3;

	set @StrSelect=@StrSelect + @StrSelect2 + @StrSelect3
	EXEC sp_executesql @StrSelect;
	---------------------------------------------------------------------------
END
GO
