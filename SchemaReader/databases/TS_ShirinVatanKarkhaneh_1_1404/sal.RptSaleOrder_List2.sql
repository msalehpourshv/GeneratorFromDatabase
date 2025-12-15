USE TS_ShirinVatanKarkhaneh_1_1404
GO
SET ANSI_NULLS, QUOTED_IDENTIFIER ON
GO
-- =========== TS-QC:UPDATED ====================
-- Author        : REZA/Nogrepasand 
-- Create date   : 1393/07/22 
-- Viewed By	 : 
-- Last Modified :  
-- Last Modifier : 
-- Description   : لیست برگه های سفارش فروش
-- =============================================
CREATE PROCEDURE [sal].[RptSaleOrder_List2]
	@ProcessID		Int = 180,
		-- 180 = لیست برگه های سفارش
		-- 185 = لیست برگه های انصراف از سفارش
	@ProcessNo		Int  = 1,
	@FiscalYearFr	Int = NULL,
	@SerialNoFr		Int = NULL,
	@FiscalYearTo	Int = NULL,
	@SerialNoTo		Int = NULL,
	@DateFr			Char(10) = NULL,
	@DateTo			Char(10) = NULL,
	@DeliveryDateFr Char(10) = NULL,
	@DeliveryDateTo Char(10) = NULL,
	@SelectedGoods	Int = 0, 
	@SelectedStore	Int = 0, 
	@SelectedOrder1	Int = NULL,
	@SelectedOrder2	Int = NULL,
	@SelectedOrder3	Int = NULL,
	@SelectedOrder4	Int = NULL,
	@VisitorCode1	Int = NULL,
	@VisitorCode2	Int = NULL,
	@VisitorCode3	Int = NULL,
	@VisitorCode4	Int = NULL,
	@SortFields		NVarChar(100) = Null,  -- لیست فیلدها برای مرتب کردن
	@RepOptions		VarChar(20) = '1201', -- bit array
	@RepInfo		NVarChar(100) = '1@1@1'
WITH ENCRYPTION
AS
DECLARE @StrSelect	NVarChar(4000);
DECLARE @StrWhere	NVarChar(2000);

DECLARE @StrGoodsID		VarChar(100);
DECLARE @StrGoodsName	VarChar(100);
DECLARE @StrQuantity	VarChar(100);
DECLARE @StrGoodsUnit	VarChar(100);
DECLARE @StrOrderDuration VarChar(100);

DECLARE @LangID		Char(1);
DECLARE @SessionNo	VarChar(10);
DECLARE @ReportID	VarChar(10);

DECLARE @DecReturn	bit;
DECLARE @DocStep	Int;
DECLARE @IsDetailed	Bit;	 
declare	@IsSaled	bit;
        -- آیا گزارش تفصیلی می باشد؟
        
-- ======
DECLARE @goods_id					Varchar(20);
DECLARE @process_id					int;
DECLARE @process_no					int;
DECLARE @fiscal_year				int;
DECLARE @serial_no					int;
DECLARE @rowno						int;
DECLARE @goods_quantity				DECIMAL(28,9);

-- ======
DECLARE @unit_name			nvarchar(200);
DECLARE @unit_id			varchar(20);
DECLARE @unit_value			float;
DECLARE @unit_value_Temp	float;
DECLARE @Mainunit_value		float;
DECLARE @Cnt				INT;

-- ======
DECLARE @unit_nameGoods1		nvarchar(200);
DECLARE @unit_idGoods1			varchar(20);
DECLARE @unit_valueGoods1		float;
DECLARE @Mainunit_valueGoods1	float;

DECLARE @unit_nameGoods2		nvarchar(200);
DECLARE @unit_idGoods2			varchar(20);
DECLARE @unit_valueGoods2		float;
DECLARE @Mainunit_valueGoods2	float;
        
DECLARE @bolMainAndSubUnit	Bit;

DECLARE @HasSgn1	bit;
DECLARE @HasSgn2	bit;
DECLARE @HasSgn3	bit;
DECLARE @HasSgn4	bit;
DECLARE @HasSgn5	bit;
DECLARE @NotSgn1	bit;
DECLARE @NotSgn2	bit;
DECLARE @NotSgn3	bit;
DECLARE @NotSgn4	bit;
DECLARE @NotSgn5	bit;

DECLARE @Sgn1	VarChar(10);
DECLARE @Sgn2	VarChar(10);
DECLARE @Sgn3	VarChar(10);
DECLARE @Sgn4	VarChar(10);
DECLARE @Sgn5	VarChar(10);
DECLARE @db_0000   nvarchar(50)

Begin --============== S T A R T  C O D E ===================================================

	--SET @LanguageID = pub.funGetCurrentLanguageID();

	SET NOCOUNT ON;

	SET @db_0000 = Substring(db_name(), 1, Len(db_name()) - 4) + '0000'
	--==============
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
	
	-- I N I T ----------------------------------------------------------------
	IF (@SortFields Is Null)	SET @SortFields = 'H.FiscalYear, H.SerialNo'
	IF (@RepInfo	Is Null)	SET @RepInfo    = '1@1@1';
	IF (@DocStep < 1)			SET @DocStep	= Null;
	IF (@ProcessNo	   Is Null) SET @ProcessNo  = 1;

	IF (@FiscalYearFr Is Null)	SET @SerialNoFr = Null;
	IF (@FiscalYearTo Is Null)	SET @SerialNoTo = Null;
	IF (@SerialNoFr	Is Null)	SET @FiscalYearFr = Null;
	IF (@SerialNoTo	Is Null)	SET @FiscalYearTo = Null;

	IF (@SelectedGoods	Is Null)	SET @SelectedGoods = 0;
	IF (@SelectedStore	Is Null)	SET @SelectedStore = 0;

	IF (@SelectedOrder1 Is Null)	SET @SelectedOrder1 = 0;
	IF (@SelectedOrder2 Is Null)	SET @SelectedOrder2 = 0;
	IF (@SelectedOrder3 Is Null)	SET @SelectedOrder3 = 0;
	IF (@SelectedOrder4 Is Null)	SET @SelectedOrder4 = 0;

	IF (@VisitorCode1 Is Null)	SET @VisitorCode1 = 0;
	IF (@VisitorCode2 Is Null)	SET @VisitorCode2 = 0;
	IF (@VisitorCode3 Is Null)	SET @VisitorCode3 = 0;
	IF (@VisitorCode4 Is Null)	SET @VisitorCode4 = 0;

	SET	@LangID		= pub.funSplitString(@RepInfo, '@', 1);
	SET @SessionNo	= pub.funSplitString(@RepInfo, '@', 2);
	SET @ReportID	= pub.funSplitString(@RepInfo, '@', 3);
	SET @Sgn1			  = LTrim(pub.funSplitString(@RepInfo, '@', 6));	
	SET @Sgn2			  = LTrim(pub.funSplitString(@RepInfo, '@', 7));	
	SET @Sgn3			  = LTrim(pub.funSplitString(@RepInfo, '@', 8));	
	SET @Sgn4			  = LTrim(pub.funSplitString(@RepInfo, '@', 9));	
	SET @Sgn5			  = LTrim(pub.funSplitString(@RepInfo, '@', 10));	

	SET @IsDetailed			= Substring(@RepOptions, 1, 1);
	SET @DocStep			= Substring(@RepOptions, 2, 1);
	SET @DecReturn			= Substring(@RepOptions, 3, 1);
	SET @IsSaled			= Substring(@RepOptions, 4, 1);
	SET @bolMainAndSubUnit	= Substring(@RepOptions, 5, 1);
	SET @HasSgn1	= Substring(@RepOptions, 6, 1);
	SET @HasSgn2	= Substring(@RepOptions, 7, 1);
	SET @HasSgn3	= Substring(@RepOptions, 8, 1);
	SET @HasSgn4	= Substring(@RepOptions, 9, 1);
	SET @HasSgn5	= Substring(@RepOptions, 10, 1);
	SET @NotSgn1	= Substring(@RepOptions, 11, 1);
	SET @NotSgn2	= Substring(@RepOptions, 12, 1);
	SET @NotSgn3	= Substring(@RepOptions, 13, 1);
	SET @NotSgn4	= Substring(@RepOptions, 14, 1);
	SET @NotSgn5	= Substring(@RepOptions, 15, 1);
	---------------------------------------------------------------------------

	-- ==========
	begin try
		drop table #tbl_result
	end try
	begin catch
	end catch
	
	Create Table #tbl_result
	(
		ProcessID				Int, 
		ProcessNo				Int,
		FiscalYear				Int,
		SerialNo				Int,
		RowNo					Int,
		GoodsID					varchar(20) collate Arabic_CS_AS null,
		GoodsName				nvarchar(200) collate Arabic_CS_AS null,
		GoodsQuantity			DECIMAL(28,9),
		UnitIDGoods1			varchar(20) collate Arabic_CS_AS null,
		UnitNameGoods1			nvarchar(20) collate Arabic_CS_AS null,
		GoodsQuantity1			DECIMAL(28,9),
		UnitIDGoods2			varchar(20) collate Arabic_CS_AS null,
		UnitNameGoods2			nvarchar(20) collate Arabic_CS_AS null,
		GoodsQuantity2			DECIMAL(28,9),
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

	-- W H E R E --------------------------------------------------------------
	--SET @StrWhere = ' (D.AutoOrder = 0) and D.ProcessID  = ' + LTrim(Str(@ProcessID)) + ' AND D.ProcessNo = ' + LTrim(Str(@ProcessNo))
	SET @StrWhere = '(D.ProcessID= ' + LTrim(Str(@ProcessID)) + ') AND (D.ProcessNo=' + LTrim(Str(@ProcessNo)) + ')'

	If (@FiscalYearFr Is Not Null)
		SET @StrWhere = @StrWhere + ' AND (D.FiscalYear > ' + LTrim(Str(@FiscalYearFr)) + ' OR (D.FiscalYear = ' + LTrim(Str(@FiscalYearFr)) + ' AND D.SerialNo >= ' + LTrim(Str(@SerialNoFr)) + ')) '
	If (@FiscalYearTo Is Not Null)
		SET @StrWhere = @StrWhere + ' AND (D.FiscalYear < ' + LTrim(Str(@FiscalYearTo)) + ' OR (D.FiscalYear = ' + LTrim(Str(@FiscalYearTo)) + ' AND D.SerialNo <= ' + LTrim(Str(@SerialNoTo)) + ')) '

	If (@SelectedGoods > 0)
		SET @StrWhere = @StrWhere + ' AND ' + pub.funGetFilterString(@SessionNo, @ReportID, @SelectedGoods, 'D.GoodsID') 
	If (@SelectedStore > 0)
		SET @StrWhere = @StrWhere + ' AND ' + pub.funGetFilterString(@SessionNo, @ReportID, @SelectedStore, 'D.StoreID') 

	If (@DateFr Is Not Null)
		Set @StrWhere = @StrWhere + ' AND (D.DocDate >= ''' + @DateFr + ''')'
	If (@DateTo Is Not Null)
		Set @StrWhere = @StrWhere + ' AND (D.DocDate <= ''' + @DateTo + ''')'

	If (@DeliveryDateFr Is Not Null)
		Set @StrWhere = @StrWhere + ' AND (D.DeliveryDate >= ''' + @DeliveryDateFr + ''')'
	If (@DeliveryDateTo Is Not Null)
		Set @StrWhere = @StrWhere + ' AND (D.DeliveryDate <= ''' + @DeliveryDateTo + ''')'

	-- Acnt
	IF	(@SelectedOrder1 > 0)
		SET @StrWhere = @StrWhere + ' AND ' + pub.funGetFilterString(@SessionNo, @ReportID, @SelectedOrder1, 'D.AcntCode') 
	IF	(@SelectedOrder2 > 0)
		SET @StrWhere = @StrWhere + ' AND ' + pub.funGetFilterString(@SessionNo, @ReportID, @SelectedOrder2, 'D.AcntCode') 
	IF	(@SelectedOrder3 > 0)
		SET @StrWhere = @StrWhere + ' AND ' + pub.funGetFilterString(@SessionNo, @ReportID, @SelectedOrder3, 'D.AcntCode') 
	IF	(@SelectedOrder4 > 0)
		SET @StrWhere = @StrWhere + ' AND ' + pub.funGetFilterString(@SessionNo, @ReportID, @SelectedOrder4, 'D.AcntCode') 

	-- Visitor
	IF	(@VisitorCode1 > 0)
		SET @StrWhere = @StrWhere + ' AND ' + pub.funGetFilterString(@SessionNo, @ReportID, @VisitorCode1, 'H.VisitorAcntCode')
	IF	(@VisitorCode2 > 0)
		SET @StrWhere = @StrWhere + ' AND ' + pub.funGetFilterString(@SessionNo, @ReportID, @VisitorCode2, 'H.VisitorAcntCode')
	IF	(@VisitorCode3 > 0)
		SET @StrWhere = @StrWhere + ' AND ' + pub.funGetFilterString(@SessionNo, @ReportID, @VisitorCode3, 'H.VisitorAcntCode')
	IF	(@VisitorCode4 > 0)
		SET @StrWhere = @StrWhere + ' AND ' + pub.funGetFilterString(@SessionNo, @ReportID, @VisitorCode4, 'H.VisitorAcntCode')

	If (@DocStep > 0)
		Set @StrWhere = @StrWhere + ' AND (D.DocStep = ' + Str(@DocStep) + ')'
		
	If (@DecReturn = 1)
		Set @StrWhere = @StrWhere + ' And D.SerialNo Not In (Select BaseSerialNo From sal.tblSaleOrderHdr Where ProcessID = 185)'
	
	If (@IsSaled <> '' And @IsSaled = '1') And @IsDetailed = 0
		Set @StrWhere = @StrWhere + ' AND S.SerialNo is Not NULL '

	IF @HasSgn1 = 1
		Set @StrWhere = @StrWhere + ' And H.SgnSN1<>0 '
	IF @HasSgn2 = 1
		Set @StrWhere = @StrWhere + ' And H.SgnSN2<>0 '
	IF @HasSgn3 = 1
		Set @StrWhere = @StrWhere + ' And H.SgnSN3<>0 '
	IF @HasSgn4 = 1
		Set @StrWhere = @StrWhere + ' And H.SgnSN4<>0 '
	IF @HasSgn5 = 1
		Set @StrWhere = @StrWhere + ' And H.SgnSN5<>0 '

	IF @NotSgn1 = 1
		Set @StrWhere = @StrWhere + ' And H.SgnSN1=0 '
	IF @NotSgn2 = 1								  
		Set @StrWhere = @StrWhere + ' And H.SgnSN2=0 '
	IF @NotSgn3 = 1								  
		Set @StrWhere = @StrWhere + ' And H.SgnSN3=0 '
	IF @NotSgn4 = 1								  
		Set @StrWhere = @StrWhere + ' And H.SgnSN4=0 '
	IF @NotSgn5 = 1								  
		Set @StrWhere = @StrWhere + ' And H.SgnSN5=0 '


	--IF @Sgn1 <> '-1'
	--	Set @StrWhere = @StrWhere + ' And ' + ltrim(rtrim(@db_0000)) + '.pub.funGetUserID(H.SgnSN1)=' + @Sgn1 + ' '
	
	--IF @Sgn2 <> '-1'
	--	Set @StrWhere = @StrWhere + ' And ' + ltrim(rtrim(@db_0000)) + '.pub.funGetUserID(H.SgnSN2)=' + @Sgn2 + ' '

	--IF @Sgn3 <> '-1'
	--	Set @StrWhere = @StrWhere + ' And ' + ltrim(rtrim(@db_0000)) + '.pub.funGetUserID(H.SgnSN3)=' + @Sgn3 + ' '

	--IF @Sgn4 <> '-1'
	--	Set @StrWhere = @StrWhere + ' And ' + ltrim(rtrim(@db_0000)) + '.pub.funGetUserID(H.SgnSN4)=' + @Sgn4 + ' '

	--IF @Sgn5 <> '-1'
	--	Set @StrWhere = @StrWhere + ' And ' + ltrim(rtrim(@db_0000)) + '.pub.funGetUserID(H.SgnSN5)=' + @Sgn5 + ' '
		
	---------------------------------------------------------------------------
	---- S E L E C T ----------------------------------------------------------
	If (@IsDetailed = 1)  
	Begin
		-- Detailed Report --
		Set @StrSelect = '
		SELECT	D.FiscalYear, D.SerialNo, D.DocRowNo, D.DocDate, D.AcntCode, D.GoodsID, D.GoodsQuantity, D.ConfirmQuantity,
				D.OrderDate, inv.funGetUnitName(D.SubUnitID, ' + @LangID + ') Unit, D.BaseFiscalYear, D.BaseSerialNo, 
				[pub].GetCodeName(D.AcntCode, ' + @LangID + ') As AcntName,
				[pub].[funGetGoodsName](D.GoodsID,' + LTrim(RTrim(@LangID)) + ') GoodsName,
				IsNull([inv].[FunGetGoodsBarCode] (D.GoodsID), '''') BarCode,
				H.VisitorAcntCode, [pub].GetCodeName(H.VisitorAcntCode, ' + @LangID + ') As VisitorAcntName, H.DocDesc, 
				L2.LocationName, H.DocDate2, F.Address1, F.Address2, F.Tel, F.Fax, F.NationalIDNumber, F.NationalIdentity
				
		FROM    sal.tblSaleOrderDtl D 
		INNER JOIN sal.tblSaleOrderHdr H ON H.ProcessID = D.ProcessID AND H.ProcessNo = D.ProcessNo AND H.FiscalYear = D.FiscalYear AND H.SerialNo = D.SerialNo
		LEFT  JOIN pub.tblLocationsDtl L2 ON L2.LocationID = H.LocationID
		OUTER APPLY acc.funGetCodeInfo(D.AcntCode) AS F 
		WHERE   ' + @StrWhere + '
		ORDER BY ' + @SortFields
	End
	Else 
	Begin
	
		-- ******************************************************************************
		IF @bolMainAndSubUnit = 1
		BEGIN		
			SET @StrSelect = '
			INSERT INTO #tbl_result
			Select S.ProcessID, S.ProcessNo, S.FiscalYear, S.SerialNo, S.DocRowNo, S.GoodsID, '''', S.GoodsQuantity, '''', '''', 0, 
				   '''', '''', 0, 0, 0, ''''
			From 
			(
				SELECT	DISTINCT H.ProcessID, H.ProcessNo, H.FiscalYear, H.SerialNo, D.DocRowNo, H.DocDate, H.AcntCode, D.GoodsID, 
						D.GoodsQuantity, [pub].GetCodeName(H.AcntCode, ' + @LangID + ') As AcntName, H.VisitorAcntCode, 
						[pub].GetCodeName(H.VisitorAcntCode, ' + @LangID + ') As VisitorAcntName, H.DocDesc, L2.LocationName,
						H.DocDate2,S.DocDate as SaleDate,S.FiscalYear as SaleFiscaYear, S.SerialNo as SaleSerialNo, F.Address1, 
						F.Address2, F.Tel, F.Fax, F.NationalIDNumber, F.NationalIdentity
				FROM    sal.tblSaleOrderDtl D
				INNER JOIN sal.tblSaleOrderHdr H ON H.ProcessID = D.ProcessID AND H.ProcessNo = D.ProcessNo AND H.FiscalYear = D.FiscalYear AND H.SerialNo = D.SerialNo
				LEFT  JOIN pub.tblLocationsDtl L2 ON L2.LocationID = H.LocationID
				left join inv.tblStorageDocsDtl S ON D.ProcessID=S.BaseProcessID and D.ProcessNo=S.BaseProcessNo and 
													 D.FiscalYear=S.BaseFiscalYear and D.SerialNo=S.BaseSerialNo
				OUTER APPLY acc.funGetCodeInfo(D.AcntCode) AS F
				WHERE   ' + @StrWhere + '
				--ORDER BY ' + @SortFields + '
			) S '
			
			-- =========='
			--Print @StrSelect;
			Exec sp_executesql @StrSelect;	
			
			--Drop Table #tbl_result
			-- ******************************************************************************
			-- *********************************** Units ************************************
			-- ******************************************************************************
			declare cur_goods cursor for
				select ProcessID, ProcessNo, FiscalYear, SerialNo, RowNo, GoodsID, GoodsQuantity
				from #tbl_result
			open cur_goods;
				
			fetch next from cur_goods into @process_id, @process_no, @fiscal_year, @serial_no, @rowno, @goods_id, @goods_quantity
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
					select SubUnitID, UnitValue, MainUnitValue
					from inv.tblSubUnitsDtl S
					where GoodsID = @goods_id And ShowInInvoice = 1
					
				) t inner join inv.tblUnitsDtl u on u.UnitID = t.UnitID and u.LanguageID = @LangID
				order by (t.MainUnitValue/ t.UnitValue ) desc
					
				-- read units row by row
				declare cur_units cursor for
					select * from @tbl_units
				open cur_units;

				-- init
				set @unit_idGoods1			 = '';
				set @unit_nameGoods1		 = '';
				set @unit_valueGoods1		 =  0;
				set @Mainunit_valueGoods1	 =  0;
				set @unit_idGoods2			 = '';
				set @unit_nameGoods2		 = '';
				set @unit_valueGoods2		 =  0;
				set @Mainunit_valueGoods2	 =  0;
				
				-- First Unit
				fetch next from cur_units into @unit_id, @unit_name, @unit_value, @Mainunit_value, @Cnt;

				if (@@fetch_status = 0)
				begin
					set @unit_idGoods1		= @unit_id;
					set @unit_nameGoods1	= @unit_name;
					
					if @Cnt > 1
					Begin
						set @unit_valueGoods1	 = floor((@goods_quantity + 0.000000001) * @unit_value / @Mainunit_value)
					End
					Else
					Begin
						set @unit_valueGoods1	 = @goods_quantity * @unit_value / @Mainunit_value
					End
					
					set @goods_quantity = @goods_quantity - (@unit_valueGoods1 * @Mainunit_value / @unit_value)

					-- Second Unit
					fetch next from cur_units into @unit_id, @unit_name, @unit_value, @Mainunit_value, @Cnt;

					if (@@fetch_status = 0)
					begin
						set @unit_idGoods2		= @unit_id;
						set @unit_nameGoods2	= @unit_name;
										
						if @Cnt > 2 
						Begin
							set @unit_valueGoods2	 = floor((@goods_quantity + 0.000000001) * @unit_value / @Mainunit_value)
						End
						else	
						Begin
							set @unit_valueGoods2	 = @goods_quantity * @unit_value / @Mainunit_value
						End
						
						set @goods_quantity	= @goods_quantity - (@unit_valueGoods2 * @Mainunit_value / @unit_value)
					end;

				end;

				-- close units cursor
				close cur_units;
				deallocate cur_units;
				-- update result
				update #tbl_result
				set GoodsName				= IsNull([pub].[funGetGoodsName](G.GoodsID, @LangID), ''),
					UnitIDGoods1			= IsNull(@unit_idGoods1,''),
					UnitNameGoods1			= IsNull(@unit_nameGoods1,''),
					GoodsQuantity1			= IsNull(@unit_valueGoods1,0),
					UnitIDGoods2			= IsNull(@unit_idGoods2,''),
					UnitNameGoods2			= IsNull(@unit_nameGoods2,''),
					GoodsQuantity2			= IsNull(@unit_valueGoods2,0),
					
					Weight					= IsNull(G.GoodsWeight,0),
					Volume					= IsNull(G.GoodsLength * G.GoodsHeight * G.GoodsWidth,0),
					BarCode					= IsNull([inv].[FunGetGoodsBarCode] (G.GoodsID), '')
				from inv.tblGoods G
				INNER JOIN inv.tblGoodsDtl GD ON GD.GoodsID = SUBSTRING(G.GoodsID,@str_Goods+1, @str_GoodsSum) AND GD.PartNumber= @UnitPart AND GD.LanguageID = @LangID
				where G.GoodsID = @goods_id AND #tbl_result.GoodsID = @goods_id And #tbl_result.ProcessID = @process_id And 
					  #tbl_result.ProcessNo = @process_no And #tbl_result.FiscalYear = @fiscal_year And #tbl_result.SerialNo = @serial_no And
					  #tbl_result.RowNo = @rowno
				
				-- next
				fetch next from cur_goods into @process_id, @process_no, @fiscal_year, @serial_no, @rowno, @goods_id, @goods_quantity
			end

			-- close goods cursor
			Close cur_goods;
			Deallocate cur_goods;
			-- ******************************************************************************
			-- ********************************** Units End *********************************
			-- ******************************************************************************
			--Select * From #tbl_result

			Set @StrSelect = '
			SELECT	DISTINCT H.FiscalYear, H.SerialNo, H.DocDate, H.AcntCode, [pub].GetCodeName(H.AcntCode, 1) As AcntName,
						H.VisitorAcntCode, [pub].GetCodeName(H.VisitorAcntCode, 1) As VisitorAcntName, H.DocDesc, H.LocationName,
						H.DocDate2, H.DocDate as SaleDate, H.FiscalYear as SaleFiscaYear, H.SerialNo as SaleSerialNo, H.Address1, 
						H.Address2, H.Tel, H.Fax, H.NationalIDNumber, H.NationalIdentity,
						SUM(RGoodsQuantity1) RGoodsQuantity1, SUM(RGoodsQuantity2) RGoodsQuantity2
			FROM (
					SELECT	DISTINCT H.FiscalYear, H.SerialNo, D.DocRowNo, H.DocDate, H.AcntCode, D.GoodsID, D.GoodsQuantity, 
							[pub].GetCodeName(H.AcntCode, 1) As AcntName,	H.VisitorAcntCode, 
							[pub].GetCodeName(H.VisitorAcntCode, 1) As VisitorAcntName, H.DocDesc, L2.LocationName,
							H.DocDate2,S.DocDate as SaleDate,S.FiscalYear as SaleFiscaYear, S.SerialNo as SaleSerialNo, F.Address1, 
							F.Address2, F.Tel, F.Fax, F.NationalIDNumber, F.NationalIdentity,
							IsNull(R2.UnitIDGoods1,'''') RUnitIDGoods1,	IsNull(R2.UnitNameGoods1,'''') RUnitNameGoods1, 
							IsNull(R2.GoodsQuantity1,0) RGoodsQuantity1,
							IsNull(R2.UnitIDGoods2,'''') RUnitIDGoods2,	IsNull(R2.UnitNameGoods2,'''') RUnitNameGoods2, 
							IsNull(R2.GoodsQuantity2,0) RGoodsQuantity2,				
							IsNull(R2.Weight,0) RWeight, IsNull(R2.Volume,0) RVolume, IsNull(R2.BarCode,'''') RBarCode		
					FROM    sal.tblSaleOrderDtl D
					INNER JOIN sal.tblSaleOrderHdr H ON H.ProcessID = D.ProcessID AND H.ProcessNo = D.ProcessNo AND H.FiscalYear = D.FiscalYear AND H.SerialNo = D.SerialNo
					LEFT  JOIN pub.tblLocationsDtl L2 ON L2.LocationID = H.LocationID
					LEFT JOIN inv.tblStorageDocsDtl S ON D.ProcessID=S.BaseProcessID and D.ProcessNo=S.BaseProcessNo and 
														 D.FiscalYear=S.BaseFiscalYear and D.SerialNo=S.BaseSerialNo
					LEFT JOIN #tbl_result R2 on R2.GoodsID = D.GoodsID And R2.ProcessID = D.ProcessID And 
												R2.ProcessNo = D.ProcessNo And R2.FiscalYear = D.FiscalYear And 
												R2.SerialNo = D.SerialNo And R2.RowNo = D.RowNo											 
					OUTER APPLY acc.funGetCodeInfo(D.AcntCode) AS F
					WHERE   ' + @StrWhere + '
					--ORDER BY ' + @SortFields + '
			) H
			GROUP BY H.FiscalYear, H.SerialNo, H.DocDate, H.AcntCode,
						H.VisitorAcntCode, [pub].GetCodeName(H.VisitorAcntCode, 1) , H.DocDesc, H.LocationName,
						H.DocDate2, H.DocDate , H.FiscalYear, H.SerialNo , H.Address1, 
						H.Address2, H.Tel, H.Fax, H.NationalIDNumber, H.NationalIdentity'		
				
			--Print @StrSelect;
			--Exec sp_executesql @StrSelect;
		END
		ELSE
		BEGIN			
			-- Summary Report --
			Set @StrSelect = '
			SELECT	DISTINCT H.FiscalYear, H.SerialNo, H.DocDate, H.AcntCode, [pub].GetCodeName(H.AcntCode, ' + @LangID + ') As AcntName,
					H.VisitorAcntCode, [pub].GetCodeName(H.VisitorAcntCode, ' + @LangID + ') As VisitorAcntName, H.DocDesc, L2.LocationName,
					H.DocDate2,S.DocDate as SaleDate,S.FiscalYear as SaleFiscaYear, S.SerialNo as SaleSerialNo, F.Address1, 
					F.Address2, F.Tel, F.Fax, F.NationalIDNumber, F.NationalIdentity, 0 RGoodsQuantity1, 0 RGoodsQuantity2
			FROM    sal.tblSaleOrderDtl D
			INNER JOIN sal.tblSaleOrderHdr H ON H.ProcessID = D.ProcessID AND H.ProcessNo = D.ProcessNo AND H.FiscalYear = D.FiscalYear AND H.SerialNo = D.SerialNo
			LEFT  JOIN pub.tblLocationsDtl L2 ON L2.LocationID = H.LocationID
			left join inv.tblStorageDocsDtl S ON D.ProcessID=S.BaseProcessID and D.ProcessNo=S.BaseProcessNo and 
												 D.FiscalYear=S.BaseFiscalYear and D.SerialNo=S.BaseSerialNo
			OUTER APPLY acc.funGetCodeInfo(D.AcntCode) AS F
			WHERE   ' + @StrWhere + '
			ORDER BY ' + @SortFields

			--Print @StrSelect;
			--Exec sp_executesql @StrSelect;			
		END
	End
	
	---------------------------------------------------------------------------
	---- R U N ----------------------------------------------------------------
	Print @StrSelect;
	Exec sp_executesql @StrSelect;
	---------------------------------------------------------------------------
End
GO
