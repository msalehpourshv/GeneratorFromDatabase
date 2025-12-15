USE TS_ShirinVatanKarkhaneh_1_1404
GO
SET ANSI_NULLS, QUOTED_IDENTIFIER ON
GO
--EXEC [inv].[SPGetUnitQuantities] 90, 10, 95, 15634, Null, 1, ''
CREATE PROCEDURE [inv].[SPGetUnitQuantities]
	@ProcessID		Int				= Null,
	@ProcessNo		TinyInt 		= Null,
	@FiscalYear		Int 			= Null,
	@SerialNo		Int 			= Null

WITH ENCRYPTION
AS 
DECLARE @StrSelect1	NVarChar(Max);
DECLARE @TableName	NVarChar(100);

-- ======
DECLARE @goods_id					Varchar(20);
DECLARE @process_id					int;
DECLARE @process_no					int;
DECLARE @fiscal_year				int;
DECLARE @serial_no					int;
DECLARE @rowNo_no					int;
DECLARE @goods_quantityGoodsOty		DECIMAL(28,9);

-- ======
DECLARE @unit_valueGoodsOty			float;
DECLARE @unit_valueGoodsOty_Temp	float;
DECLARE @Mainunit_valueGoodsOty		float;
DECLARE @CntGoodsQty				INT;

DECLARE @unit_valueGoodsOty1		float;
DECLARE @Mainunit_valueGoodsOty1	float;

DECLARE @unit_valueGoodsOty2		float;

BEGIN --============== S T A R T  C O D E =======================================

	SET NOCOUNT ON;


	
-- ===================================
	
	IF @ProcessID = 90 or @ProcessID = 55  or @ProcessID = 110 or @ProcessID = 115
		SET @TableName = 'inv.tblStorageDocsDtl'
	ELSE IF @ProcessID = 180
		SET @TableName = 'sal.tblSaleOrderDtl'
	ELSE IF @ProcessID = 240
		SET @TableName = 'inv.tblPreSaleDtl'		

	-- ===================================
	begin try
		drop table #tbl_result
	end try
	begin catch
	end catch
	
	Create Table #tbl_result
	(
		ProcessID					Int, 
		ProcessNo					Int,
		FiscalYear					Int,
		SerialNo					Int,
		RowNo						Int,	
		GoodsID						varchar(20) collate Arabic_CS_AS null,
		TotalQuantityGoodsOty		DECIMAL(28,9),
		UnitIDGoodsOty1				varchar(20) collate Arabic_CS_AS null,
		TotalQuantityGoodsOty1		DECIMAL(28,9),
		UnitIDGoodsOty2				varchar(20) collate Arabic_CS_AS null,
		TotalQuantityGoodsOty2		DECIMAL(28,9)
	);

	-- ===================================
	DECLARE @tbl_units as table
	(
		unit_valueGoodsOty			float not null,
		Mainunit_valueGoodsOty		float not null,
		cntGoodsOty					int not null								
	);
	
	-- ===================================
	SET @StrSelect1 = 'Insert Into #tbl_result
					   Select S.ProcessID, S.ProcessNo, S.FiscalYear, S.SerialNo, S.RowNo, S.GoodsID, 
					    S.GoodsQuantity, '''',  0, '''', 0
					   From ' + @TableName + ' S
					   Where ProcessID = ' + LTrim(RTrim(Str(@ProcessID))) + ' And ProcessNo = '  + LTrim(RTrim(Str(@ProcessNo))) + ' And 
							 FiscalYear = ' +  LTrim(RTrim(Str(@FiscalYear))) + ' And SerialNo = ' +  LTrim(RTrim(Str(@SerialNo))) 
	Print @StrSelect1;
	Exec sp_executesql @StrSelect1;
	
	--Select * From #tbl_result		
		
	-- ******************************************************************************
	-- *********************************** Units ************************************
	-- ******************************************************************************
	declare cur_goods cursor for
		select ProcessID, ProcessNo, FiscalYear, SerialNo, RowNo, GoodsID, TotalQuantityGoodsOty
		from #tbl_result
	open cur_goods;
	
	fetch next from cur_goods into @process_id, @process_no, @fiscal_year, @serial_no, @rowNo_no, @goods_id, @goods_quantityGoodsOty
	
	while (@@fetch_status = 0)
	begin

		--====================== Units
		-- 1- empty units table
		delete from @tbl_units
		
		-- 2- fill units of 1 goods
		insert into @tbl_units
		select top 3  t.UnitValue, t.MainUnitValue,
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
			
		) t 
		order by (t.MainUnitValue/ t.UnitValue ) desc

		--====================== End Units
					
		-- read units row by row
		declare cur_units cursor for
			select *
			from @tbl_units
		open cur_units;

		-- init
		set @unit_valueGoodsOty1		 =  0;
		set @Mainunit_valueGoodsOty1	 =  0;
		set @unit_valueGoodsOty2		 =  0;
		
		-- First Unit
		fetch next from cur_units into  @unit_valueGoodsOty, @Mainunit_valueGoodsOty, @CntGoodsQty;

		if (@@fetch_status = 0)
		begin
								
			if @CntGoodsQty > 1
			Begin
				set @unit_valueGoodsOty1 = floor((@goods_quantityGoodsOty + 0.000000001) * @unit_valueGoodsOty / @Mainunit_valueGoodsOty)
			End
			Else
			Begin
				set @unit_valueGoodsOty1 = @goods_quantityGoodsOty * @unit_valueGoodsOty / @Mainunit_valueGoodsOty
			End

			set @goods_quantityGoodsOty  = @goods_quantityGoodsOty - (@unit_valueGoodsOty1 * @Mainunit_valueGoodsOty / @unit_valueGoodsOty)

			-- Second Unit
			fetch next from cur_units into @unit_valueGoodsOty, @Mainunit_valueGoodsOty, @CntGoodsQty;

			if (@@fetch_status = 0)
			begin
				
				if @CntGoodsQty > 2 
				Begin
					set @unit_valueGoodsOty2 = floor((@goods_quantityGoodsOty + 0.000000001) * @unit_valueGoodsOty / @Mainunit_valueGoodsOty)
				End
				else	
				Begin
					set @unit_valueGoodsOty2 = @goods_quantityGoodsOty * @unit_valueGoodsOty / @Mainunit_valueGoodsOty
				End
				
				set @goods_quantityGoodsOty  = @goods_quantityGoodsOty - (@unit_valueGoodsOty2 * @Mainunit_valueGoodsOty / @unit_valueGoodsOty)
				
			end;

		end;

		-- close units cursor
		close cur_units;
		deallocate cur_units;

		-- update result
		Update #tbl_result
		Set TotalQuantityGoodsOty1		= IsNull(@unit_valueGoodsOty1,0),
			TotalQuantityGoodsOty2		= IsNull(@unit_valueGoodsOty2,0)
		Where GoodsID = @goods_id And ProcessID = @process_id And 
			  ProcessNo = @process_no And FiscalYear = @fiscal_year And 
			  SerialNo = @serial_no AND RowNo = @rowNo_no

		-- next
		fetch next from cur_goods into @process_id, @process_no, @fiscal_year, @serial_no, @rowNo_no, @goods_id, @goods_quantityGoodsOty
	end

	-- close goods cursor
	Close cur_goods;
	Deallocate cur_goods;
			
	Select IsNull(SUM(TotalQuantityGoodsOty1),0) TotalQuantityGoodsOty1,IsNull(SUM(TotalQuantityGoodsOty2),0) TotalQuantityGoodsOty2
	From #tbl_result

END
GO
