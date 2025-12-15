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
Create PROCEDURE [sal].[RptSale_VisitorSaleStatsEx]
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
DECLARE @StrSelect				NVarChar(Max)
DECLARE @StrSelect2				NVarChar(Max)
DECLARE @StrSelect3				NVarChar(Max)
DECLARE @StrCount				NVarChar(Max)
DECLARE @StrWhere				NVarChar(Max)
DECLARE @StrWhereB				NVarChar(Max)
DECLARE @StrWhereG				NVarChar(Max)
DECLARE @StrFrom				NVarChar(Max)
DECLARE	@LangID					Char(1);
DECLARE	@SessionNo				Int; 
DECLARE	@ReportID				Int; 
DECLARE @goods_id				Varchar(20);
DECLARE @visitor_acnt_code		Varchar(20);
DECLARE @visitor_acnt_code2		Varchar(20);
DECLARE @sale_quantity			DECIMAL(28,9);
DECLARE @ret_quantity			DECIMAL(28,9);
DECLARE @unit_name				nvarchar(200);
DECLARE @unit_id				varchar(20);
DECLARE @unit_value				float;
DECLARE @unit_value_Temp		float;
DECLARE @Mainunit_value			float;
DECLARE @Cnt					INT;
DECLARE @unit_nameSale1			nvarchar(200);
DECLARE @unit_idSale1			varchar(20);
DECLARE @unit_valueSale1		float;
DECLARE @Mainunit_valueSale1	float;
DECLARE @unit_nameSale2			nvarchar(200);
DECLARE @unit_idSale2			varchar(20);
DECLARE @unit_valueSale2		float;
DECLARE @Mainunit_valueSale2	float;
DECLARE @unit_nameRet1			nvarchar(200);
DECLARE @unit_idRet1			varchar(20);
DECLARE @unit_valueRet1			float;
DECLARE @Mainunit_valueRet1		float;
DECLARE @unit_nameRet2			nvarchar(200);
DECLARE @unit_idRet2			varchar(20);
DECLARE @unit_valueRet2			float;
DECLARE @Mainunit_valueRet2		float;
DECLARE @bolMainAndSubUnit		Bit;
DECLARE @SelectedGoods			Int;
DECLARE @CustomerKindID			varchar(20)
DECLARE @CampaignID				int;
DECLARE @VisitPathID1			int;
DECLARE @VisitPathID2			int;
DECLARE @VisitPathID3			int;
DECLARE @VisitPathID4			int;
DECLARE @SalesRoomClass			int;
DECLARE @StartLayerAcntRemain	int;
DECLARE @LenLayerAcntRemain		int;
DECLARE	@UserID					Int;
DECLARE	@UserIsAdmin			bit;
DECLARE @SelectedVisitor21		Int ;
DECLARE @SelectedVisitor22		Int ;
DECLARE @SelectedVisitor23		Int ;
DECLARE @SelectedVisitor24		Int ;
BEGIN

	SET NOCOUNT ON;
			
	Select @StartLayerAcntRemain=acc.FunGetAcntInfoForRemain(2 )
	Select @LenLayerAcntRemain=acc.FunGetAcntInfoForRemain(3 )
	
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

	SET @LangID			= pub.funSplitString(@RepInfo, '@', 1);
	SET @SessionNo		= pub.funSplitString(@RepInfo, '@', 2);
	SET @ReportID		= pub.funSplitString(@RepInfo, '@', 3);
	SET @UserID			= pub.funSplitString(@RepInfo, '@', 4);
	SET @UserIsAdmin	= pub.funSplitString(@RepInfo, '@', 5);

	SET @bolMainAndSubUnit	= Substring(@RepOptions, 1, 1);

	SET @SelectedGoods = LTrim(pub.funSplitString(@ExtraParams, '@', 1)); 
	SET @CustomerKindID= LTrim(pub.funSplitString(@ExtraParams, '@', 2)); 
		SET @CampaignID	     = pub.funSplitString(@ExtraParams,'@',3);
	SET @VisitPathID1 	 = pub.funSplitString(@ExtraParams, '@', 4);
	SET @VisitPathID2	 = pub.funSplitString(@ExtraParams, '@', 5);
	SET @VisitPathID3	 = pub.funSplitString(@ExtraParams, '@', 6);
	SET @VisitPathID4	 = pub.funSplitString(@ExtraParams, '@', 7);
	SET @SalesRoomClass	 = pub.funSplitString(@ExtraParams, '@', 8);
	set @SelectedVisitor21		= LTrim(pub.funSplitString(@ExtraParams, '@', 9));
	set @SelectedVisitor22		= LTrim(pub.funSplitString(@ExtraParams, '@', 10));
	set @SelectedVisitor23		= LTrim(pub.funSplitString(@ExtraParams, '@', 11));
	set @SelectedVisitor24		= LTrim(pub.funSplitString(@ExtraParams, '@', 12));
	IF (@SelectedGoods Is Null)	SET @SelectedGoods = 0;
 
 --select @SelectedVisitor21,@SelectedVisitor22,@SelectedVisitor23,@SelectedVisitor24
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
		VisitorAcntCode2		varchar(20) collate Arabic_CS_AS null,
		GoodsID					varchar(20) collate Arabic_CS_AS null,
		SaleGoodsQuantity		DECIMAL(28,9),
		RetGoodsQuantity		DECIMAL(28,9)
	);
		

	Create Table #tbl_result
	(
		VisitorAcntCode			varchar(20) collate Arabic_CS_AS null,
		VisitorAcntCode2		varchar(20) collate Arabic_CS_AS null,
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
	
	if(@CustomerKindID != ''    )
	SET @StrWhere = @StrWhere + 'And   substring(H.AcntCode,'+str(@StartLayerAcntRemain)+','+str(@LenLayerAcntRemain)+')  In (select AcntCode  from acc.tblAcnt where  CustomerKindID='''+@CustomerKindID+''')'
	
	SET @StrWhereB = '1 = 1'
	SET @StrWhereG = ''

	IF (@DocStep > 0)
		SET @StrWhere = @StrWhere + ' AND (H.DocStep >= ' + LTrim(Str(@DocStep)) + ')'

	If @SaleTypeID Is Not Null
		Set @StrWhere = @StrWhere + ' AND (H.SaleTypeID = ''' + @SaleTypeID + ''')'

	IF (@VistAcnt1 > 0)
		SET @StrWhere = @StrWhere + ' AND ' + pub.funGetFilterString(@SessionNo, @ReportID, @VistAcnt1, 'D.VisitorAcntCode')
	IF (@VistAcnt2 > 0)
		SET @StrWhere = @StrWhere + ' AND ' + pub.funGetFilterString(@SessionNo, @ReportID, @VistAcnt2, 'D.VisitorAcntCode')
	IF (@VistAcnt3 > 0)
		SET @StrWhere = @StrWhere + ' AND ' + pub.funGetFilterString(@SessionNo, @ReportID, @VistAcnt3, 'D.VisitorAcntCode')
	IF (@VistAcnt4 > 0)
		SET @StrWhere = @StrWhere + ' AND ' + pub.funGetFilterString(@SessionNo, @ReportID, @VistAcnt4, 'D.VisitorAcntCode')
	If (@SelectedVisitor21 > 0)
		SET @StrWhere = @StrWhere + ' AND (' + pub.funGetFilterString(@SessionNo, @ReportID, @SelectedVisitor21, 'D.VisitorAcntCode2') + ')'
	If (@SelectedVisitor22 > 0)	
		SET @StrWhere = @StrWhere + ' AND (' + pub.funGetFilterString(@SessionNo, @ReportID, @SelectedVisitor22, 'D.VisitorAcntCode2') + ')'
	If (@SelectedVisitor23 > 0)
		SET @StrWhere = @StrWhere + ' AND (' + pub.funGetFilterString(@SessionNo, @ReportID, @SelectedVisitor23, 'D.VisitorAcntCode2') + ')'
	If (@SelectedVisitor24 > 0)
		SET @StrWhere = @StrWhere + ' AND (' + pub.funGetFilterString(@SessionNo, @ReportID, @SelectedVisitor24, 'D.VisitorAcntCode2') + ')'
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
			
		IF (@CampaignID > 0)
	 	    SET @StrWhere = @StrWhere + ' AND  substring(H.AcntCode,'+str(@StartLayerAcntRemain)+','+str(@LenLayerAcntRemain)+') in (select AcntCode  from acc.tblAcnt where '+ pub.funGetFilterString(@SessionNo, @ReportID, @CampaignID, 'CampaignID') +' ) '
	IF (@VisitPathID1 > 0)
	 	    SET @StrWhere = @StrWhere + ' AND  substring(H.AcntCode,'+str(@StartLayerAcntRemain)+','+str(@LenLayerAcntRemain)+') in (select AcntCode  from acc.tblAcnt where '+ pub.funGetFilterString(@SessionNo, @ReportID, @VisitPathID1, 'VisitPathID1') +' ) '
	IF (@VisitPathID2 > 0)
	 	    SET @StrWhere = @StrWhere + ' AND  substring(H.AcntCode,'+str(@StartLayerAcntRemain)+','+str(@LenLayerAcntRemain)+') in (select AcntCode  from acc.tblAcnt where '+ pub.funGetFilterString(@SessionNo, @ReportID, @VisitPathID2, 'VisitPathID2') +' ) '
	IF (@VisitPathID3 > 0)
	 	    SET @StrWhere = @StrWhere + ' AND  substring(H.AcntCode,'+str(@StartLayerAcntRemain)+','+str(@LenLayerAcntRemain)+') in (select AcntCode  from acc.tblAcnt where '+ pub.funGetFilterString(@SessionNo, @ReportID, @VisitPathID3, 'VisitPathID3') +' ) '
	IF (@VisitPathID4 > 0)
	 	    SET @StrWhere = @StrWhere + ' AND  substring(H.AcntCode,'+str(@StartLayerAcntRemain)+','+str(@LenLayerAcntRemain)+') in (select AcntCode  from acc.tblAcnt where '+ pub.funGetFilterString(@SessionNo, @ReportID, @VisitPathID4, 'VisitPathID4') +' ) '
	IF (@SalesRoomClass > 0)
	 	    SET @StrWhere = @StrWhere + ' AND  substring(H.AcntCode,'+str(@StartLayerAcntRemain)+','+str(@LenLayerAcntRemain)+') in (select AcntCode  from acc.tblAcnt where '+ pub.funGetFilterString(@SessionNo, @ReportID, @SalesRoomClass, 'SalesRoomClass') +' ) '


	If (@SelectedGoods > 0)
		SET @StrWhereG = ' AND ' + pub.funGetFilterString(@SessionNo, @ReportID, @SelectedGoods, 'D.GoodsID') 
			 
	--===============================================================================
	BEGIN TRY
		DROP TABLE #tblAcntCode
		DROP TABLE #tblStoreID
		DROP TABLE #tblVisitorAcntCode
		DROP TABLE #tblVisitorAcntCode2
	END TRY
	BEGIN CATCH
	END CATCH

	CREATE TABLE #tblAcntCode
	(
	AcntCode 			Varchar(20)collate arabic_cs_as null
	)
	CREATE TABLE #tblStoreID
	(
	StoreID 			Varchar(20)collate arabic_cs_as null
	)
	CREATE TABLE #tblVisitorAcntCode
	(
	VisitorAcntCode 			Varchar(20)collate arabic_cs_as null
	)
	CREATE TABLE #tblVisitorAcntCode2
	(
	VisitorAcntCode2 			Varchar(20)collate arabic_cs_as null
	)
	
	Insert into  #tblVisitorAcntCode (VisitorAcntCode)	SELECT Distinct VisitorAcntCode	FROM inv.tblStorageDocsHdr
	Insert into  #tblVisitorAcntCode2 (VisitorAcntCode2)	SELECT Distinct VisitorAcntCode2	FROM inv.tblStorageDocsHdr
	Insert into  #tblAcntCode (AcntCode)				SELECT Distinct AcntCode		FROM inv.tblStorageDocsHdr
	Insert into  #tblStoreID (StoreID)					SELECT Distinct StoreID			FROM inv.tblStorageDocsHdr
	if @UserIsAdmin=0
	begin

		 exec pub.SpFilterByPermission2 '#tblAcntCode', 'AcntCode', 'acc.tblAcnt', @UserID;
		 exec pub.SpFilterByPermission2 '#tblVisitorAcntCode', 'VisitorAcntCode', 'acc.tblAcnt', @UserID;
		 exec pub.SpFilterByPermission2 '#tblVisitorAcntCode2', 'VisitorAcntCode2', 'acc.tblAcnt', @UserID;
		 exec pub.SpFilterByPermission2 '#tblStoreID', 'StoreID', 'inv.tblStores', @UserID;

		SET @StrWhere =  @StrWhere+
			' and H.AcntCode in (SELECT AcntCode FROM  #tblAcntCode ) ' +
			' and H.VisitorAcntCode in (SELECT VisitorAcntCode FROM  #tblVisitorAcntCode ) ' + 
			' and H.VisitorAcntCode2 in (SELECT VisitorAcntCode2 FROM  #tblVisitorAcntCode2 ) ' + 
			' and H.StoreID in (SELECT StoreID FROM  #tblStoreID ) '
	END
	-- ******************************************************************************
	SET @StrSelect = '
	INSERT INTO #tbl_Tmp
	Select Sale.VisitorAcntCode, Sale.VisitorAcntCode2, Sale.GoodsID, 
		   IsNull(Sum(Sale.GoodsQuantity),0) SaleGoodsQuantity, IsNull(Sum(Ret.GoodsQuantity),0) RetGoodsQuantity
	From (
	select  H.VisitorAcntCode, H.VisitorAcntCode2, D.GoodsID, SUM(D.GoodsQuantity) GoodsQuantity
	from	inv.vwStorageDocsHdr H
	Inner Join inv.tblStorageDocsDtl D ON D.ProcessID = H.ProcessID And D.ProcessNo = H.ProcessNo And D.FiscalYear = H.FiscalYear And
										  D.SerialNo = H.SerialNo
	Where  (H.ProcessID = 90) And ' + @StrWhere + @StrWhereG + '
	Group By H.VisitorAcntCode,H.VisitorAcntCode2,D.GoodsID
	) Sale
	Left Join 
	( 
		select  H.VisitorAcntCode, H.VisitorAcntCode2, D.GoodsID, SUM(D.GoodsQuantity) GoodsQuantity
		from	inv.vwStorageDocsHdr H
		Inner Join inv.tblStorageDocsDtl D ON D.ProcessID = H.ProcessID And D.ProcessNo = H.ProcessNo And D.FiscalYear = H.FiscalYear And
											  D.SerialNo = H.SerialNo
		where  (H.ProcessID = 100) And ' + @StrWhere  + @StrWhereG  + '
		group by H.VisitorAcntCode,H.VisitorAcntCode2,D.GoodsID
	) Ret ON Sale.VisitorAcntCode = Ret.VisitorAcntCode And Sale.VisitorAcntCode2 = Ret.VisitorAcntCode2 And Sale.GoodsID = Ret.GoodsID
	Group By Sale.VisitorAcntCode, Sale.VisitorAcntCode2, Sale.GoodsID'
	
	PRINT @StrSelect;
	EXEC sp_executesql @StrSelect;
	-- ******************************************************************************	
	--===============================================================================
	SET @StrSelect = '
	INSERT INTO #tbl_result
	Select VisitorAcntCode, VisitorAcntCode2, GoodsID, SaleGoodsQuantity, '''', '''', 0, '''', '''', 0, RetGoodsQuantity, '''', '''', 0, '''', '''', 0,
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
		select  VisitorAcntCode, VisitorAcntCode2, GoodsID, SaleGoodsQuantity, RetGoodsQuantity
		from #tbl_Tmp
	open cur_goods;
		
	fetch next from cur_goods into @visitor_acnt_code,@visitor_acnt_code2, @goods_id, @sale_quantity, @ret_quantity

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
		where G.GoodsID = @goods_id AND #tbl_result.GoodsID = @goods_id And #tbl_result.VisitorAcntCode = @visitor_acnt_code And #tbl_result.VisitorAcntCode2 = @visitor_acnt_code2

		-- next
		fetch next from cur_goods into @visitor_acnt_code,@visitor_acnt_code2, @goods_id, @sale_quantity, @ret_quantity
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
		SET @StrCount= '	select  Count(D.GoodsID) Counts from  inv.tblStorageDocsDtl  D inner join 
 inv.tblStorageDocsHdr  H ON D.ProcessID = H.ProcessID And D.ProcessNo = H.ProcessNo And D.FiscalYear = H.FiscalYear And	 D.SerialNo = H.SerialNo '

	---------------------------------------------------------------------------
	-- S E L E C T ------------------------------------------------------------
	SET @StrSelect = '
	SELECT	T.VisitorAcntCode, T.VisitorAcntCode2, pub.GetCodeName(T.VisitorAcntCode, 1) as VisitorAcntName,pub.GetCodeName(T.VisitorAcntCode2, 1) as VisitorAcntName2,
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
			isnull(sum(T.AfterSaleDiscount), 0) as AfterSaleDiscount,
			ROUND(IsNull(R2.QuantitySale1,0), ' + LTrim(RTrim(Str(@QuantityDecimalsToForms))) + ') SaleQuantity1, 
			ROUND(IsNull(R2.QuantitySale2,0), ' + LTrim(RTrim(Str(@QuantityDecimalsToForms))) + ') SaleQuantity2,
			ROUND(IsNull(R2.QuantityRet1,0), ' + LTrim(RTrim(Str(@QuantityDecimalsToForms))) + ') RetQuantity1, 
			ROUND(IsNull(R2.QuantityRet2,0), ' + LTrim(RTrim(Str(@QuantityDecimalsToForms))) + ') RetQuantity2
			,( '+ @StrCount+' where  D.ProcessID =90 and '+  @StrWhere  +' Group by D.ProcessID ) CountSale 
			,('+ @StrCount+' where  D.ProcessID =100 and '+  @StrWhere  +' Group by D.ProcessID )CountRet
	FROM
	('

	SET @StrSelect2 = '	
	 	select  H.VisitorAcntCode, H.VisitorAcntCode2, H.Discount as DiscountX, H.Discount2+H.Discount3 as Discount2X,
				(
					SELECT COUNT(SerialNo) from (select SerialNo
					from inv.tblStorageDocsDtl D 
					where H.ProcessID = D.ProcessID AND H.ProcessNo = D.ProcessNo AND H.FiscalYear = D.FiscalYear AND H.SerialNo = D.SerialNo
					'+ @StrWhereG + '
					group by SerialNo)a
				) as CountX, 
				(
					select sum(GoodsPrice * GoodsQuantity) 
					from inv.tblStorageDocsDtl D 
					where H.ProcessID = D.ProcessID AND H.ProcessNo = D.ProcessNo AND H.FiscalYear = D.FiscalYear AND H.SerialNo = D.SerialNo
					' + @StrWhereG + '
				) SumPriceX, --+ H.SidePriceSum as SumPriceX,
				(
					select Distinct Count(SerialNo) 
					from inv.tblStorageDocsDtl D 
					where H.ProcessID = D.ProcessID AND H.ProcessNo = D.ProcessNo AND H.FiscalYear = D.FiscalYear AND H.SerialNo = D.SerialNo
					' + @StrWhereG + '
				) SerialNoQty, 
				(
					select sum(GoodsQuantity) 
					from inv.tblStorageDocsDtl D 
					where H.ProcessID = D.ProcessID AND H.ProcessNo = D.ProcessNo AND H.FiscalYear = D.FiscalYear AND H.SerialNo = D.SerialNo
					' + @StrWhereG + '
				) Qty,0 as CountR, 0 as SumPriceR,0 as SerialNoQtyR,0 as QtyR, 0 as DiscountR, 0 as Discount2R,
				isnull((
					select SUM(B.Price)
					from (select distinct ProcessID,  SerialNo, BaseSaleProcessID, BaseSaleProcessNo, BaseSaleFiscalYear, BaseSaleSerialNo from  sal.tblDistributionsDtl where VisitorAcntCode=H.VisitorAcntCode ) D2 
						inner join sal.tblAfterSaleBillDtl B on B.BaseProcessID=D2.BaseSaleProcessID and B.BaseProcessNo=D2.BaseSaleProcessNo and B.BaseFiscalYear=D2.BaseSaleFiscalYear and B.BaseSerialNo=D2.BaseSaleSerialNo
						AND B.BaseProcessID=H.ProcessID and B.BaseProcessNo=H.ProcessNo and B.BaseFiscalYear=H.FiscalYear and B.BaseSerialNo=H.SerialNo
						inner join sal.tblAfterSaleBillHdr BH on BH.ProcessID=B.ProcessID and BH.SerialNo=B.SerialNo
					where ' + @StrWhereB + ' and D2.ProcessID = H.BaseDistributionProcessID and D2.SerialNo = H.BaseDistributionSerialNo
				),0) Discount3X, 0 as Discount3R, H.TotalLineDiscount as Discount4X, 0 as Discount4R,AfterSaleDiscount
		from	inv.vwStorageDocsHdr H
			inner join inv.tblStorageDocsDtl D 		On  H.ProcessID = D.ProcessID AND H.ProcessNo = D.ProcessNo AND H.FiscalYear = D.FiscalYear AND H.SerialNo = D.SerialNo	
		where  (H.ProcessID = 90) and ' + @StrWhere + @StrWhereG +' 
		group by H.VisitorAcntCode, H.VisitorAcntCode2, H.Discount, H.Discount2,H.Discount3, H.TotalLineDiscount, H.ProcessID, H.ProcessNo, H.FiscalYear, H.SerialNo, SidePriceSum, BaseDistributionProcessID, BaseDistributionSerialNo,AfterSaleDiscount' 
		
	SET @StrSelect3 = '	
		union all
		select  H.VisitorAcntCode, H.VisitorAcntCode2, 0 as DiscountX, 0 as Discount2X, 0 as CountX, 0 as SumPriceX,0 as SerialNoQty,0 as Qty ,
				(
					SELECT COUNT(SerialNo) from (select SerialNo
					from inv.tblStorageDocsDtl D 
					where H.ProcessID = D.ProcessID AND H.ProcessNo = D.ProcessNo AND H.FiscalYear = D.FiscalYear AND H.SerialNo = D.SerialNo
					' + @StrWhereG + '
					group by SerialNo)a
				) as CountR, 
				(
					select sum(GoodsQuantity*GoodsPrice) 
					from inv.tblStorageDocsDtl D 
					where D.VisitorAcntCode = H.VisitorAcntCode and D.VisitorAcntCode2 = H.VisitorAcntCode2 AND H.ProcessID = D.ProcessID AND H.ProcessNo = D.ProcessNo AND H.FiscalYear = D.FiscalYear AND H.SerialNo = D.SerialNo
					' + @StrWhereG + '
				) SumPriceR ,--+ (-1) * H.SidePriceSum SumPriceR, 
				(
					select Distinct Count(SerialNo) 
					from inv.tblStorageDocsDtl D 
					where D.VisitorAcntCode = H.VisitorAcntCode AND D.VisitorAcntCode2 = H.VisitorAcntCode2 AND H.ProcessID = D.ProcessID AND H.ProcessNo = D.ProcessNo AND H.FiscalYear = D.FiscalYear AND H.SerialNo = D.SerialNo
					' + @StrWhereG + '
				) SerialNoQtyR ,(
					select sum(GoodsPrice*GoodsQuantity) 
					from inv.tblStorageDocsDtl D 
					where D.VisitorAcntCode = H.VisitorAcntCode and D.VisitorAcntCode2 = H.VisitorAcntCode2 AND H.ProcessID = D.ProcessID AND H.ProcessNo = D.ProcessNo AND H.FiscalYear = D.FiscalYear AND H.SerialNo = D.SerialNo
					' + @StrWhereG + '
				) QtyR ,H.Discount as DiscountR, H.Discount2+H.Discount3 as Discount2R, 0 as Discount3X, 0 as Discount3R, 0 AS Discount4X, H.TotalLineDiscount AS Discount4R,AfterSaleDiscount
		from	inv.vwStorageDocsHdr H
		inner join inv.tblStorageDocsDtl D 		On  H.ProcessID = D.ProcessID AND H.ProcessNo = D.ProcessNo AND H.FiscalYear = D.FiscalYear AND H.SerialNo = D.SerialNo
		where  (H.ProcessID=100) and ' + @StrWhere + @StrWhereG +  ' 
		group by H.VisitorAcntCode, H.VisitorAcntCode2, H.Discount, H.Discount2,H.Discount3, H.TotalLineDiscount, H.ProcessID, H.ProcessNo, H.FiscalYear, H.SerialNo, SidePriceSum,AfterSaleDiscount
	) T
	LEFT JOIN (Select VisitorAcntCode,VisitorAcntCode2, SUM(QuantitySale1) QuantitySale1,SUM(QuantitySale2)QuantitySale2,
					  SUM(QuantityRet1) QuantityRet1,SUM(QuantityRet2)QuantityRet2
			   From #tbl_result
			   Group By VisitorAcntCode,VisitorAcntCode2) R2 ON R2.VisitorAcntCode = T.VisitorAcntCode and R2.VisitorAcntCode2 = T.VisitorAcntCode2 --AND R2.GoodsID = T.GoodsID
	GROUP BY T.VisitorAcntCode,T.VisitorAcntCode2, R2.QuantitySale1, R2.QuantitySale2, R2.QuantityRet1, R2.QuantityRet2
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
