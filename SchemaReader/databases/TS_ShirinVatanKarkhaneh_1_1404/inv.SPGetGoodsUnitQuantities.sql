USE TS_ShirinVatanKarkhaneh_1_1404
GO
SET ANSI_NULLS, QUOTED_IDENTIFIER ON
GO
--EXEC [inv].[SPGetGoodsUnitQuantities] '2101', 18, 1, ''
CREATE PROCEDURE [inv].[SPGetGoodsUnitQuantities]
	@GoodsID		Varchar(20)		= Null,
	@GoodsQty		DECIMAL(28,9)	= Null,
	@MainUnit		Bit 			= Null,
	@ExtraParams	NVarChar(500)	= Null

WITH ENCRYPTION
AS 
DECLARE @StrSelect1	NVarChar(Max);
DECLARE @TableName	NVarChar(100);
DECLARE @LangID		VarChar(3);
DECLARE @LanguageID	VarChar(3);

-- ======
DECLARE @goods_id					Varchar(20);
DECLARE @goods_quantityGoodsOty		DECIMAL(28,9);
DECLARE @goods_quantitySubUnitQty	DECIMAL(28,9);

-- ======
DECLARE @unit_nameGoodsOty			nvarchar(200);
DECLARE @unit_idGoodsOty			varchar(20);
DECLARE @unit_valueGoodsOty			DECIMAL(28,9);
DECLARE @unit_valueGoodsOty_Temp	DECIMAL(28,9);
DECLARE @Mainunit_valueGoodsOty		DECIMAL(28,9);
DECLARE @CntGoodsQty				INT;

DECLARE @unit_nameGoodsOty1			nvarchar(200);
DECLARE @unit_idGoodsOty1			varchar(20);
DECLARE @unit_valueGoodsOty1		DECIMAL(28,9);
DECLARE @Mainunit_valueGoodsOty1	DECIMAL(28,9);

DECLARE @unit_nameGoodsOty2			nvarchar(200);
DECLARE @unit_idGoodsOty2			varchar(20);
DECLARE @unit_valueGoodsOty2		DECIMAL(28,9);
DECLARE @Mainunit_valueGoodsOty2	DECIMAL(28,9);

BEGIN --============== S T A R T  C O D E =======================================

	SET NOCOUNT ON;

	--========================
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
	
-- ===================================
	SELECT @LanguageID = pub.funGetCurrentLanguageID();
	SET @LangID			  = LTrim(Str(@LanguageID));

	-- ===================================
	begin try
		drop table #tbl_result
	end try
	begin catch
	end catch
	
	Create Table #tbl_result
	(
		GoodsID						varchar(20) collate Arabic_CS_AS null,
		GoodsName					nvarchar(200) collate Arabic_CS_AS null,
		TotalQuantityGoodsOty		DECIMAL(28,9),
		UnitIDGoodsOty1				varchar(20) collate Arabic_CS_AS null,
		UnitNameGoodsOty1			nvarchar(100) collate Arabic_CS_AS null,
		TotalQuantityGoodsOty1		DECIMAL(28,9),
		UnitIDGoodsOty2				varchar(20) collate Arabic_CS_AS null,
		UnitNameGoodsOty2			nvarchar(20) collate Arabic_CS_AS null,
		TotalQuantityGoodsOty2		DECIMAL(28,9),
		Weight						float,
		Volume						float,
		BarCode						varchar(20) collate Arabic_CS_AS null
	);

	-- ===================================
	DECLARE @tbl_units as table
	(
		unit_idGoodsOty				varchar(20) not null, 
		unit_nameGoodsOty			nvarchar(200) not null, 
		unit_valueGoodsOty			float not null,
		Mainunit_valueGoodsOty		float not null,
		cntGoodsOty					int not null								
	);
	
	-- ===================================
	SET @StrSelect1 = '
		Insert Into #tbl_result
		Values (''' + @GoodsID + ''', '''', ' + LTRIM(RTrim(Str(@GoodsQty, LEN(@GoodsQty), 10))) + ', '''', '''', 0, '''', '''', 0, 0, 0, '''')'
					   
	Print @StrSelect1;
	Exec sp_executesql @StrSelect1;
	
	--Select * From #tbl_result
	-- ******************************************************************************
	-- *********************************** Units ************************************
	-- ******************************************************************************
	declare cur_goods cursor for
		select GoodsID, TotalQuantityGoodsOty
		from #tbl_result
	open cur_goods;
	
	fetch next from cur_goods into @goods_id, @goods_quantityGoodsOty
	
	while (@@fetch_status = 0)
	begin

		--====================== Units
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

		--====================== End Units
		-- read units row by row
		declare cur_units cursor for
			select *
			from @tbl_units
		open cur_units;

		-- init
		set @unit_idGoodsOty1			 = '';
		set @unit_nameGoodsOty1			 = '';
		set @unit_valueGoodsOty1		 =  0;
		set @Mainunit_valueGoodsOty1	 =  0;
		
		set @unit_idGoodsOty2			 = '';
		set @unit_nameGoodsOty2			 = '';
		set @unit_valueGoodsOty2		 =  0;
		set @Mainunit_valueGoodsOty2	 =  0;	
		
		-- First Unit
		fetch next from cur_units into @unit_idGoodsOty, @unit_nameGoodsOty, @unit_valueGoodsOty, @Mainunit_valueGoodsOty, @CntGoodsQty;
		if (@@fetch_status = 0)
		begin
			set @unit_idGoodsOty1		 = @unit_idGoodsOty;
			set @unit_nameGoodsOty1		 = @unit_nameGoodsOty;
								
			if @CntGoodsQty > 0
			Begin
				set @unit_valueGoodsOty1 = floor((@goods_quantityGoodsOty + 0.000000001) * @unit_valueGoodsOty / @Mainunit_valueGoodsOty)
			End
			Else
			Begin
				set @unit_valueGoodsOty1 = @goods_quantityGoodsOty * @unit_valueGoodsOty / @Mainunit_valueGoodsOty
			End
			
			set @goods_quantityGoodsOty  = @goods_quantityGoodsOty - Cast((@unit_valueGoodsOty1 * @Mainunit_valueGoodsOty / @unit_valueGoodsOty) As Decimal(28,9))

			-- Second Unit
			fetch next from cur_units into @unit_idGoodsOty, @unit_nameGoodsOty, @unit_valueGoodsOty, @Mainunit_valueGoodsOty, @CntGoodsQty;
			if (@@fetch_status = 0)
			begin
				set @unit_idGoodsOty2		= @unit_idGoodsOty;
				set @unit_nameGoodsOty2		= @unit_nameGoodsOty;
				
				if @CntGoodsQty > 1 
				Begin
					set @unit_valueGoodsOty2 = floor((@goods_quantityGoodsOty + 0.000000001) * @unit_valueGoodsOty / @Mainunit_valueGoodsOty)
				End
				else	
				Begin
					set @unit_valueGoodsOty2 = @goods_quantityGoodsOty * @unit_valueGoodsOty / @Mainunit_valueGoodsOty
				End
				
				set @goods_quantityGoodsOty  = @goods_quantityGoodsOty - Cast((@unit_valueGoodsOty2 * @Mainunit_valueGoodsOty / @unit_valueGoodsOty) As Decimal(28,9))
				
			end;

		end;

		-- close units cursor
		close cur_units;
		deallocate cur_units;

		-- update result
		Update #tbl_result
		Set GoodsName					= IsNull([pub].[funGetGoodsName](G.GoodsID,@LangID),''),
			UnitIDGoodsOty1				= IsNull(@unit_idGoodsOty1,''),
			UnitNameGoodsOty1			= IsNull(@unit_nameGoodsOty1,''),
			TotalQuantityGoodsOty1		= IsNull(@unit_valueGoodsOty1,0),
			UnitIDGoodsOty2				= IsNull(@unit_idGoodsOty2,''),
			UnitNameGoodsOty2			= IsNull(@unit_nameGoodsOty2,''),
			TotalQuantityGoodsOty2		= IsNull(@unit_valueGoodsOty2,0),
			Weight						= IsNull(G.GoodsWeight,0),
			Volume						= IsNull(G.GoodsLength * G.GoodsHeight * G.GoodsWidth,0),
			BarCode						= IsNull([inv].[FunGetGoodsBarCode] (G.GoodsID), '')
		From inv.tblGoods G
		INNER JOIN inv.tblGoodsDtl GD ON GD.GoodsID = SUBSTRING(G.GoodsID,@str_Goods+1, @str_GoodsSum) AND GD.PartNumber= @UnitPart AND GD.LanguageID = @LangID
		Where G.GoodsID = @goods_id --AND #tbl_result.GoodsID = @goods_id

		-- next
		fetch next from cur_goods into @goods_id, @goods_quantityGoodsOty
	end

	-- close goods cursor
	Close cur_goods;
	Deallocate cur_goods;
	-- ******************************************************************************
	-- ********************************** Units End *********************************
	-- ******************************************************************************
	--Select * From @tbl_units
	--Select * From #tbl_result 
	
	--Select SUM(TotalQuantityGoodsOty) TotalQuantityGoodsOty, SUM(TotalQuantityGoodsOty1) TotalQuantityGoodsOty1,
	--	   SUM(TotalQuantityGoodsOty2) TotalQuantityGoodsOty2
	--From #tbl_result
			
	IF @MainUnit = 1 
		Select IsNull(SUM(TotalQuantityGoodsOty1),0) TotalQuantityGoodsOty1
		From #tbl_result
	ELSE
		Select IsNull(SUM(TotalQuantityGoodsOty2),0) TotalQuantityGoodsOty2
		From #tbl_result	

END
GO
