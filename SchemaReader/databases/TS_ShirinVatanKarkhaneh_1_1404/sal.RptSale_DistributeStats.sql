USE TS_ShirinVatanKarkhaneh_1_1404
GO
SET ANSI_NULLS, QUOTED_IDENTIFIER ON
GO
-- =========== TS-QC:UPDATED ====================
-- Author		 : zia
-- Create date   : 1388/12/24
-- Viewed By	 : 
-- Last Modified : 1392/06/16
-- Last Modifier : zia
-- Description	 : آمار تجمعي پخش
-- ==============================================
Create PROCEDURE [sal].[RptSale_DistributeStats]
	@ProcessID		int = 90,
	@SerialNoFr		int = null,
	@SerialNoTo		int = null,
	@DocDateFr		char(10) = null,
	@DocDateTo		char(10) = null,
	@SerialList		varchar(50) = null,
	@VisitorAcnt1	int = 0,
	@VisitorAcnt2	int = 0,
	@VisitorAcnt3	int = 0,
	@VisitorAcnt4	int = 0,
	@RepInfo		NVarChar(200) = '1@1@1'
	
WITH ENCRYPTION
AS 
declare @serial_no				int;
declare @dst_serial_no			int;
declare @SaleSerials			VARCHAR(4000);
declare @saleCountInDist		int;
declare @store_id				varchar(20);
declare @goods_id				varchar(20);
declare @goods_quantity			DECIMAL(28,9);
declare @goods_price			float;
declare @goods_price2			float;
declare @unit_id				varchar(20);
declare @unit_name				varchar(20);
declare @unit_value				float;
declare @Mainunit_value			float;
declare @Cnt					INT;
declare @unit1_name				nvarchar(200);
declare @unit1_id				varchar(20);
declare @unit1_value			float;
declare @unit1_value_Temp		float;
declare @Mainunit1_value		float;
declare @unit2_id				varchar(20);
declare @unit2_name				nvarchar(200);
declare @unit2_value			float;
declare @Mainunit2_value		float;
declare @unit3_id				varchar(20);
declare @unit3_name				nvarchar(200);
declare @unit3_value			float;
declare @Mainunit3_value		float;
declare @idx					int;
declare @LangID					int;
declare @str_select				nvarchar(max);
declare @str_selectSale			nvarchar(max);
declare @str_selectRet			nvarchar(max);
declare @SessionNo				int;
declare @ReportID				int;
declare @ShowUserPrice			bit;
declare @UserPrice				int;
declare	@FiscalYearFr2			Int
declare	@SerialNoFr2			Int
declare	@FiscalYearTo2			Int
declare	@SerialNoTo2			Int

declare @strUserPriceID1		varchar(20);
declare @strUserPriceIDGrpBy1	varchar(20);

declare @strUserPriceID2		varchar(20);
declare @strUserPriceIDGrpBy2	varchar(20);

declare @NoGroupByRets			bit;
declare @Dst_HasBranch			bit;
declare @StoreID				int ;
declare @ShowQtyByMinAndActUnit	bit;
declare @DistributDateFr		Char(10);
declare @DistributDateTo		Char(10);
DECLARE @StrSelect				NVarChar(Max);
DECLARE @StrSelect2				NVarChar(Max);
DECLARE @db_0000				nvarchar(50)
declare @NotShowReward			bit;

Begin

	-- init --------------------------------------------------
	
	IF (@VisitorAcnt1	Is Null)	SET @VisitorAcnt1 = 0;
	IF (@VisitorAcnt2	Is Null)	SET @VisitorAcnt2 = 0;
	IF (@VisitorAcnt3	Is Null)	SET @VisitorAcnt3 = 0;
	IF (@VisitorAcnt4	Is Null)	SET @VisitorAcnt4 = 0;

	SET @LangID					= pub.funSplitString(@RepInfo, '@', 1);
	SET @SessionNo				= pub.funSplitString(@RepInfo, '@', 2);
	SET @ReportID				= pub.funSplitString(@RepInfo, '@', 3);
	
	SET @ShowUserPrice			= pub.funSplitString(@RepInfo, '@', 6);	
	SET @FiscalYearFr2			= pub.funSplitString(@RepInfo, '@', 7);
	SET @SerialNoFr2			= pub.funSplitString(@RepInfo, '@', 8);
	SET @FiscalYearTo2			= pub.funSplitString(@RepInfo, '@', 9);
	SET @SerialNoTo2			= pub.funSplitString(@RepInfo, '@', 10);	
	SET @NoGroupByRets			= pub.funSplitString(@RepInfo, '@', 11);	
	SET @Dst_HasBranch			= pub.funSplitString(@RepInfo, '@', 12);	
	SET @StoreID				= pub.funSplitString(@RepInfo, '@', 13);	
	SET @ShowQtyByMinAndActUnit	= pub.funSplitString(@RepInfo, '@', 14);	
	SET @DistributDateFr		= pub.funSplitString(@RepInfo, '@', 15);	
	SET @DistributDateTo		= pub.funSplitString(@RepInfo, '@', 16);	
	SET @NotShowReward			= pub.funSplitString(@RepInfo, '@', 17);	

	IF (@FiscalYearFr2 	Is Null)	SET @SerialNoFr2 	= Null;
	IF (@FiscalYearTo2 	Is Null)	SET @SerialNoTo2 	= Null;
	IF (@SerialNoFr2	Is Null)	SET @FiscalYearFr2  = Null;
	IF (@SerialNoTo2	Is Null)	SET @FiscalYearTo2  = Null;

	SET @strUserPriceID1 = ''
	SET @strUserPriceIDGrpBy1 = ''
	SET @strUserPriceID2 = ''
	SET @strUserPriceIDGrpBy2 = ''
	--==============
	DECLARE @UnitPart TINYINT
	SET @UnitPart  = 1

	SELECT @UnitPart = SettingValue from pub.tblSettings where SettingKey = 'UnitPart'

	IF @UnitPart IS NULL or @UnitPart = 0
		SET @UnitPart = 1

	DECLARE @str_Goods  tinyint,
			@str_GoodsSum tinyint

	select @str_Goods = IsNull(SUM (Layer1+Layer2+Layer3+Layer4+Layer5+Layer6+Layer7+Layer8+Layer9),0)
	from pub.tblCodeLayer 
	where TableName='inv.tblGoods' AND PartNumber<@UnitPart

	select @str_GoodsSum = Layer1+Layer2+Layer3+Layer4+Layer5+Layer6+Layer7+Layer8+Layer9
	from pub.tblCodeLayer 
	where TableName= 'inv.tblGoods' AND PartNumber=@UnitPart
	
	-- create tables -----------------------------------------
	begin try
		drop table #tbl_goods
		drop table #tbl_result
		drop table #tbl_Invoice_Signatures
	end try
	begin catch
	end catch
			
	create table #tbl_Invoice_Signatures
	(
		UserID	int,
		UserSign	image
	);
	
	set @db_0000 = Substring(db_name(), 1, Len(db_name()) - 4) + '0000'
	------
	set @StrSelect = '
	INSERT INTO #tbl_Invoice_Signatures(UserID, UserSign)
	SELECT UserID, UserSignature
	FROM ' + ltrim(rtrim(@db_0000)) + '.usr.tblUsers U '
	
	print @StrSelect;
	exec sp_executesql @StrSelect;

	delete from #tbl_Invoice_Signatures where UserSign IS NULL

	create table #tbl_goods
	(
		SerialNo			int,
		DstSerialNo			int,
		GoodsID				varchar(20),
		SaleSerials			VARCHAR(4000),
		saleCountInDist		int,
		Quantity			DECIMAL(28,9),
		Price				float,
		Price2				float,
		UserPriceID			int,
		StoreID			Varchar(20)collate arabic_cs_as null
	);

	-- ==========
	DECLARE @QuantityDecimalsToForms AS Int

	SET		@QuantityDecimalsToForms = 3
	SELECT  @QuantityDecimalsToForms = SettingValue
	FROM pub.tblSettings
	WHERE SettingKey = 'QuantityDecimalsToForms'

	IF @QuantityDecimalsToForms>0
		SET @QuantityDecimalsToForms = @QuantityDecimalsToForms - 1

	create table #tbl_result
	(
		SerialNo			int,
		DstSerialNo			int,
		GoodsID				varchar(20) COLLATE ARABIC_CS_AS ,
		SaleSerials			VARCHAR(4000),
		saleCountInDist		int,		
		GoodsName			nvarchar(200),
		Quantity			DECIMAL(28,9),
		Price				float,
		Price2				float,
		UnitID1				varchar(20),
		UnitName1			nvarchar(20),
		Quantity1			DECIMAL(28,9),
		UnitID2				varchar(20),
		UnitName2			nvarchar(20),
		Quantity2			DECIMAL(28,9),
		UnitID3				varchar(20),
		UnitName3			nvarchar(20),
		Quantity3			DECIMAL(28,9),
		Weight				float,
		Volume				float,
		BarCode				varchar(20),
		UserPriceID			int,
		StoreID			Varchar(20)collate arabic_cs_as null
	)

	declare @tbl_units as table
	(
		unit_id		varchar(20) not null, 
		unit_name	nvarchar(200) not null, 
		unit_value	float not null,
		Mainunit_value	float not null,
		cnt	int not null
	);

	-- select goods 
		
	if @ProcessID = 100
	begin
		set @str_select     = 'S.ProcessID = ' + LTrim(RTrim(Str(@ProcessID)))
		set @str_selectRet  = 'D.ProcessID = ' + LTrim(RTrim(Str(@ProcessID)))
		set @str_selectSale = 'H.ProcessID = 100 And H.ProcessNo = 10'
		
		if (@SerialNoFr is not null)
		begin
			set @str_select = @str_select + ' and H.BaseDistributionSerialNo >= ' + ltrim(str(@SerialNoFr))
			set @str_selectSale = @str_selectSale + ' and H.BaseDistributionSerialNo >= ' + ltrim(str(@SerialNoFr))
		end
		if (@SerialNoTo is not null)
		begin
			set @str_select = @str_select + ' and H.BaseDistributionSerialNo <= ' + ltrim(str(@SerialNoTo))
			set @str_selectSale = @str_selectSale + ' and H.BaseDistributionSerialNo <= ' + ltrim(str(@SerialNoTo))
		end
		if (@SerialList is not null)
		begin
			set @str_select = @str_select + ' and H.BaseDistributionSerialNo In (' + ltrim(@SerialList) + ')'
			set @str_selectSale = @str_selectSale + ' and H.BaseDistributionSerialNo In (' + ltrim(@SerialList) + ')'
		end
		
	end
	
	if @ProcessID = 210
	begin
		set @str_select = '(A.ProcessID=' + str(@ProcessID) + ')'
		if (@SerialNoFr is not null)
			set @str_select = @str_select + ' and A.SerialNo >= ' + ltrim(str(@SerialNoFr))
		if (@SerialNoTo is not null)
			set @str_select = @str_select + ' and A.SerialNo <= ' + ltrim(str(@SerialNoTo))
		if (@SerialList is not null)
			set @str_select = @str_select + ' and A.SerialNo In (' + ltrim(@SerialList) + ')'
	end
		
	if (@DocDateFr is not null)
	begin
		set @str_select = @str_select + ' and H.DocDate >= ''' + @DocDateFr + ''''
		set @str_selectRet = @str_selectRet + ' and H.DocDate >= ''' + @DocDateFr + ''''
	end
	if (@DocDateTo is not null)
	begin
		set @str_select = @str_select + ' and H.DocDate <= ''' + @DocDateTo + ''''
		set @str_selectRet = @str_selectRet + ' and H.DocDate <= ''' + @DocDateTo + ''''
	end
	
	if (@DistributDateFr is not null) And (@DistributDateFr <> '')
	begin
		set @str_select = @str_select + ' and H.DistributDate >= ''' + @DistributDateFr + ''''
	end
	if (@DistributDateTo is not null) And (@DistributDateTo <> '')
	begin
		set @str_select = @str_select + ' and H.DistributDate <= ''' + @DistributDateTo + ''''
	end

	IF (@VisitorAcnt1 > 0)
	begin
		SET @str_select = @str_select + ' AND ' + pub.funGetFilterString(@SessionNo, @ReportID, @VisitorAcnt1, 'D.VisitorAcntCode')
		SET @str_selectSale = @str_selectSale + ' AND ' + pub.funGetFilterString(@SessionNo, @ReportID, @VisitorAcnt1, 'D.VisitorAcntCode')
	end
	IF (@VisitorAcnt2 > 0)
	begin
		SET @str_select = @str_select + ' AND ' + pub.funGetFilterString(@SessionNo, @ReportID, @VisitorAcnt2, 'D.VisitorAcntCode')
		SET @str_selectSale = @str_selectSale + ' AND ' + pub.funGetFilterString(@SessionNo, @ReportID, @VisitorAcnt2, 'D.VisitorAcntCode')
	end
	IF (@VisitorAcnt3 > 0)
	begin
		SET @str_select = @str_select + ' AND ' + pub.funGetFilterString(@SessionNo, @ReportID, @VisitorAcnt3, 'D.VisitorAcntCode')
		SET @str_selectSale = @str_selectSale + ' AND ' + pub.funGetFilterString(@SessionNo, @ReportID, @VisitorAcnt3, 'D.VisitorAcntCode')
	end
	IF (@VisitorAcnt4 > 0)
	begin
		SET @str_select = @str_select + ' AND ' + pub.funGetFilterString(@SessionNo, @ReportID, @VisitorAcnt4, 'D.VisitorAcntCode')
		SET @str_selectSale = @str_selectSale + ' AND ' + pub.funGetFilterString(@SessionNo, @ReportID, @VisitorAcnt4, 'D.VisitorAcntCode')
	end
	IF (@StoreID > 0)
	begin
		SET @str_select = @str_select + ' AND ' + pub.funGetFilterString(@SessionNo, @ReportID, @StoreID, 'H.StoreID')
		SET @str_selectSale = @str_selectSale + ' AND ' + pub.funGetFilterString(@SessionNo, @ReportID, @StoreID, 'H.StoreID')
	end
		
	IF @ProcessID = 210 
	Begin		
		IF (@SerialNoFr2 Is Not Null) And (@SerialNoFr2 <> 0)
			SET @str_select = @str_select + ' AND (D.BaseSaleFiscalYear > ' + LTrim(Str(@FiscalYearFr2)) + ' OR (D.BaseSaleFiscalYear = ' + LTrim(Str(@FiscalYearFr2)) + ' AND D.BaseSaleSerialNo >= ' + LTrim(Str(@SerialNoFr2)) + '))' 
		IF (@SerialNoTo2 Is Not Null) And (@SerialNoTo2 <> 0)
			SET @str_select = @str_select + ' AND (D.BaseSaleFiscalYear < ' + LTrim(Str(@FiscalYearTo2)) + ' OR (D.BaseSaleFiscalYear = ' + LTrim(Str(@FiscalYearTo2)) + ' AND D.BaseSaleSerialNo <= ' + LTrim(Str(@SerialNoTo2)) + '))' 
	End
	Else
	Begin		
		IF (@SerialNoFr2 Is Not Null) And (@SerialNoFr2 <> 0)
		Begin		
			SET @str_select = @str_select + ' AND (H.BaseFiscalYear > ' + LTrim(Str(@FiscalYearFr2)) + ' OR (H.BaseFiscalYear = ' + LTrim(Str(@FiscalYearFr2)) + ' AND H.BaseSerialNo >= ' + LTrim(Str(@SerialNoFr2)) + '))' 
			SET @str_selectRet = @str_selectRet + ' AND (H.BaseFiscalYear > ' + LTrim(Str(@FiscalYearFr2)) + ' OR (H.BaseFiscalYear = ' + LTrim(Str(@FiscalYearFr2)) + ' AND H.BaseSerialNo >= ' + LTrim(Str(@SerialNoFr2)) + '))' 
		End
		IF (@SerialNoTo2 Is Not Null) And (@SerialNoTo2 <> 0)
		Begin		
			SET @str_select = @str_select + ' AND (H.BaseFiscalYear < ' + LTrim(Str(@FiscalYearTo2)) + ' OR (H.BaseFiscalYear = ' + LTrim(Str(@FiscalYearTo2)) + ' AND H.BaseSerialNo <= ' + LTrim(Str(@SerialNoTo2)) + '))' 
			SET @str_selectRet = @str_selectRet + ' AND (H.BaseFiscalYear < ' + LTrim(Str(@FiscalYearTo2)) + ' OR (H.BaseFiscalYear = ' + LTrim(Str(@FiscalYearTo2)) + ' AND H.BaseSerialNo <= ' + LTrim(Str(@SerialNoTo2)) + '))' 
		End
	End
	
	IF @Dst_HasBranch = 1 And @ProcessID = 210
	Begin		
		SET @str_select = @str_select + ' And IsNull(H.BranchManagerConfirmed, 0) = 1'
	End

	--IF @Dst_HasBranch = 1 And @ProcessID = 100
	--Begin		
	--	SET @str_selectRet = @str_selectRet + ' And IsNull(dh.SaleRetsConfirmed, 0) = 1'
	--End 	

	if @ShowUserPrice=0
	begin
		SET @strUserPriceID1 = '0 UserPriceID'
		SET @strUserPriceID2 = '0 UserPriceID'
		SET @strUserPriceIDGrpBy1 = ''	
		SET @strUserPriceIDGrpBy2 = ''	
	end
	else
	begin
		SET @strUserPriceID1 = 'A.UserPriceID'
		SET @strUserPriceID2 = 'D.UserPriceID'
		SET @strUserPriceIDGrpBy1 = ', A.UserPriceID'	
		SET @strUserPriceIDGrpBy2 = ', D.UserPriceID'	
	end
	 
	if @NotShowReward=1
		begin
			set  @str_select += ' And A.IsReward=0 And A.IsReward0=0 '
			set  @str_selectSale += ' And D.IsReward=0 And D.IsReward0=0'
			set  @str_selectRet += ' And D.IsReward=0 And D.IsReward0=0'
		end 
	if @ProcessID = 210
	Begin
		set @str_select = '
			insert into #tbl_goods
			select A.SerialNo, A.SerialNo DstSerialNo, A.GoodsID, 0 SaleSerials, 0 saleCountInDist, Sum(A.Quantity), Sum(A.SubUnitQuantity*A.Price), 
				   Sum(A.SubUnitQuantity2 * A.SubUnitPrice2),	' + @strUserPriceID1 + ', H.StoreID
			from sal.tblDistributionsAtom A
			inner join sal.tblDistributionsDtl D ON D.ProcessID = A.ProcessID AND D.SerialNo = A.SerialNo and D.DocRowNo=A.DocRowNo
			inner join sal.tblDistributionsHdr H ON H.ProcessID = A.ProcessID AND H.SerialNo = A.SerialNo
			where  ' + @str_select + '
			group by A.SerialNo, GoodsID' + @strUserPriceIDGrpBy1 +', H.StoreID'
	End

	if @ProcessID = 100
	Begin
		if @NoGroupByRets = 1
			set @str_select = 
				'
				Insert Into #tbl_goods
				Select 0, S.BaseDistributionSerialNo DstSerialNo, D.GoodsID, 0 SaleSerials, 0 saleCountInDist,
					   ROUND( Sum(D.GoodsQuantity),6), Sum(D.GoodsQuantity * D.GoodsPrice) - Sum(D.DiscountDtl), 
					   Sum(D.GoodsQuantity * D.GoodsPrice) - Sum(D.DiscountDtl), ' + @strUserPriceID2 + ', H.StoreID
				From inv.tblStorageDocsDtl D
				Inner Join  inv.tblStorageDocsHdr H  On H.ProcessID  = D.ProcessID  And H.ProcessNo = D.ProcessNo and  
														H.FiscalYear = D.FiscalYear And H.SerialNo  = D.SerialNo
				Inner Join 
				(
					Select D.*, H.BaseDistributionSerialNo
					From inv.tblStorageDocsDtl D
					Inner Join inv.tblStorageDocsHdr H On H.ProcessID  = D.ProcessID  And  H.ProcessNo = D.ProcessNo And  
														  H.FiscalYear = D.FiscalYear And  H.SerialNo  = D.SerialNo
					Where ' + @str_selectSale + '
				) S ON D.ProcessID = S.ProcessID And D.ProcessNo = S.ProcessNo And D.FiscalYear = S.FiscalYear And
					   D.SerialNo = S.SerialNo And D.DocRowNo = S.DocRowNo
			left Join  inv.tblStorageDocsHdr HH  On H.BaseProcessID  = HH.ProcessID  And H.BaseProcessNo = HH.ProcessNo and H.BaseFiscalYear = HH.FiscalYear And H.BaseSerialNo  = HH.SerialNo				
			left JOIN  sal.tblDistributionsDtl dd	on HH.ProcessID=dd.BaseSaleProcessID and HH.ProcessNo=dd.BaseSaleProcessNo and HH.FiscalYear=dd.BaseSaleFiscalYear and HH.SerialNo=dd.BaseSaleSerialNo 		
			left JOIN sal.tblDistributionsHdr dh on dh.ProcessID=dd.ProcessID and dh.SerialNo=dd.SerialNo
				Where ' + @str_selectRet + '
				Group By S.BaseDistributionSerialNo, D.GoodsID' + @strUserPriceIDGrpBy2 +', H.StoreID				
				'
		else
			set @str_select = 
				'
				Insert Into #tbl_goods
				Select D.SerialNo, S.BaseDistributionSerialNo DstSerialNo, D.GoodsID, 0 SaleSerials, 0 saleCountInDist,
					   ROUND( Sum(D.GoodsQuantity),6), Sum(D.GoodsQuantity * D.GoodsPrice) - Sum(D.DiscountDtl), 
					   Sum(D.GoodsQuantity * D.GoodsPrice) - Sum(D.DiscountDtl), ' + @strUserPriceID2 + ', H.StoreID
				From inv.tblStorageDocsDtl D
				Inner Join  inv.tblStorageDocsHdr H  On H.ProcessID  = D.ProcessID  And H.ProcessNo = D.ProcessNo and  
														H.FiscalYear = D.FiscalYear And H.SerialNo  = D.SerialNo
				Inner Join 
				(
					Select D.*, H.BaseDistributionSerialNo
					From inv.tblStorageDocsDtl D
					Inner Join inv.tblStorageDocsHdr H On H.ProcessID  = D.ProcessID  And  H.ProcessNo = D.ProcessNo And  
														  H.FiscalYear = D.FiscalYear And  H.SerialNo  = D.SerialNo
					Where ' + @str_selectSale + '
				) S ON D.ProcessID = S.ProcessID And D.ProcessNo = S.ProcessNo And D.FiscalYear = S.FiscalYear And
					   D.SerialNo = S.SerialNo And D.DocRowNo = S.DocRowNo
			left Join  inv.tblStorageDocsHdr HH  On H.BaseProcessID  = HH.ProcessID  And H.BaseProcessNo = HH.ProcessNo and H.BaseFiscalYear = HH.FiscalYear And H.BaseSerialNo  = HH.SerialNo				
			left JOIN  sal.tblDistributionsDtl dd	on HH.ProcessID=dd.BaseSaleProcessID and HH.ProcessNo=dd.BaseSaleProcessNo and HH.FiscalYear=dd.BaseSaleFiscalYear and HH.SerialNo=dd.BaseSaleSerialNo 		
			left JOIN sal.tblDistributionsHdr dh on dh.ProcessID=dd.ProcessID and dh.SerialNo=dd.SerialNo
			Where ' + @str_selectRet + '
				Group By D.SerialNo, S.BaseDistributionSerialNo, D.GoodsID' + @strUserPriceIDGrpBy2 +', H.StoreID				
				'
	End

	print @str_select;
	exec sp_executesql @str_select;

	-- ===================================
	DECLARE @strSN as varchar(4000)
	DECLARE @strSNSum as varchar(4000)

	declare cur_BS cursor for
		select SerialNo, DstSerialNo, StoreID from #tbl_goods
		group by SerialNo, DstSerialNo, StoreID
	open cur_BS;
			
	FETCH NEXT FROM cur_BS into @serial_no, @dst_serial_no, @store_id
	WHILE (@@fetch_status = 0)
	BEGIN
		SET @strSN = ''
		SET @strSNSum = ''

		-- =================================== Serials
	    IF @ProcessID = 210 
		BEGIN
			SELECT @strSNSum = COALESCE(@strSNSum  + ', ', ' ') + Cast(BaseSaleFiscalYear AS VARCHAR(4)) + '/' + Cast(BaseSaleSerialNo AS VARCHAR(9)) 
			FROM   sal.tblDistributionsDtl 
			WHERE  SerialNo = @serial_no And BaseSaleRetSerialNo > -1  
			
		END
		
		ELSE   -- ================== ProcessID = 100
		
		BEGIN
			SELECT @strSNSum = COALESCE(@strSNSum + ', ', ' ') + Cast(FiscalYear AS VARCHAR(4)) + '/' + Cast(SerialNo AS VARCHAR(9))
			FROM   inv.tblStorageDocsHdr 
			WHERE ProcessID = 100 AND BaseDistributionSerialNo = @dst_serial_no AND StoreID = @store_id
			
	 	END
		
		-- =================================== Serials
		IF LEN(@strSNSum) > 0
			SET @strSNSum = SUBSTRING(@strSNSum, 2, LEN(@strSNSum))
		
		UPDATE #tbl_goods
		SET SaleSerials = @strSNSum,
			saleCountInDist = 
			IsNull((SELECT COUNT(*)
			FROM   inv.tblStorageDocsHdr
			WHERE ProcessID =  CASE WHEN  @ProcessID = 210 THEN 90 ELSE 100 END AND BaseDistributionSerialNo = @dst_serial_no And StoreID = @store_id),0)
		WHERE Case When @ProcessID = 210 Then SerialNo Else DstSerialNo End = Case When @ProcessID = 210 Then @serial_no Else @dst_serial_no End
		AND StoreID = @store_id
	
		-- ===================================
		
		FETCH NEXT FROM cur_BS into @serial_no, @dst_serial_no, @store_id
				
	END	

	close cur_BS;
	deallocate cur_BS;
		
	-- =================================================================================
	-- =================================================================================
	-- =================================================================================
	if @ShowUserPrice = 0
		Update #tbl_goods Set UserPriceID = 0
		
	Insert Into #tbl_result
	Select SerialNo, DstSerialNo, GoodsID, SaleSerials, saleCountInDist, '', Quantity, Price, Price2, '', '', 0, '', '', 0 , '', '', 0, 0, 0, '',UserPriceID,StoreID
	From   #tbl_goods

	declare cur_goods cursor for
		select SerialNo, DstSerialNo, GoodsID, SaleSerials, saleCountInDist, Quantity, 
			   Price, Price2, UserPriceID, StoreID	
		from #tbl_goods
	open cur_goods;
	
	-- fetch 1st goods 
	fetch next from cur_goods into @serial_no, @dst_serial_no, @goods_id, @SaleSerials, @saleCountInDist, @goods_quantity, @goods_price, @goods_price2, @UserPrice,@StoreID;

	while (@@fetch_status = 0)
	begin
		-- 1- empty units table
		delete 
		from @tbl_units

		-- 2- fill units of 1 goods
		insert into @tbl_units
		select top 3 t.UnitID, u.UnitName, t.UnitValue, t.MainUnitValue,
		(SELECT COUNT(*) from(
								select UnitID, 1 As UnitValue,1 MainUnitValue
								from inv.tblGoods
								where GoodsID = @goods_id
								union
								select SubUnitID, UnitValue,MainUnitValue
								from inv.tblSubUnitsDtl S
								where GoodsID = @goods_id And 
									  Case When @ShowQtyByMinAndActUnit = 1 Then ShowInInvoice Else 1 End = 1
			) z
		)cnt
		from
		(
			select UnitID, 1 As UnitValue,1 MainUnitValue
			from inv.tblGoods
			where GoodsID = @goods_id
			union
			select SubUnitID, UnitValue,MainUnitValue
			from inv.tblSubUnitsDtl S
			where GoodsID = @goods_id And 
				  Case When @ShowQtyByMinAndActUnit = 1 Then ShowInInvoice Else 1 End = 1
			
		) t inner join inv.tblUnitsDtl u on u.UnitID = t.UnitID and u.LanguageID = @LangID
		order by (t.MainUnitValue/ t.UnitValue ) desc
			
		-- read units row by row
		declare cur_units cursor for
			select *
			from @tbl_units
		open cur_units;

		-- init
		set @unit1_id	= '';
		set @unit1_name	= '';
		set @unit1_value= 0;
		set @Mainunit1_value= 0;
		set @unit2_id	= '';
		set @unit2_name	= '';
		set @unit2_value= 0;
		set @Mainunit2_value= 0;
		set @unit3_id	= '';
		set @unit3_name	= '';
		set @unit3_value= 0;
		set @Mainunit3_value= 0;
	
		-- first unit
		fetch next from cur_units into @unit_id, @unit_name, @unit_value, @Mainunit_value,@Cnt;

		if (@@fetch_status = 0)
		begin
			set @unit1_id		= @unit_id;
			set @unit1_name		= @unit_name;
			if @Cnt > 1 
				set @unit1_value	= floor((@goods_quantity+0.000000001) * @unit_value / @Mainunit_value)
			else
				set @unit1_value	= @goods_quantity * @unit_value / @Mainunit_value

			set @goods_quantity = @goods_quantity - (@unit1_value * @Mainunit_value / @unit_value )

			-- second unit
			fetch next from cur_units into @unit_id, @unit_name, @unit_value, @Mainunit_value,@Cnt;

			if (@@fetch_status = 0)
			begin

			set @unit2_id		= @unit_id;
			set @unit2_name		= @unit_name;
			if @Cnt > 2 
				set @unit2_value	= floor((@goods_quantity+0.000000001) * @unit_value / @Mainunit_value)
			else	
				set @unit2_value	= @goods_quantity * @unit_value / @Mainunit_value
			set @goods_quantity = @goods_quantity - (@unit2_value * @Mainunit_value / @unit_value )

				-- third unit
				fetch next from cur_units into @unit_id, @unit_name, @unit_value, @Mainunit_value,@Cnt;

				if (@@fetch_status = 0)
				begin
					set @unit3_id		= @unit_id;
					set @unit3_name		= @unit_name;
					set @unit3_value	= ((@goods_quantity+0.000000001) * @unit_value / @Mainunit_value)
				end;
			end;

		end;

		-- close units cursor
		close cur_units;
		deallocate cur_units;

		-- update result
		update #tbl_result
		set GoodsName	= [pub].[funGetGoodsName](G.GoodsID,@LangID),
			UnitID1		= @unit1_id,
			UnitName1	= @unit1_name,
			Quantity1	= @unit1_value,
			UnitID2		= @unit2_id,
			UnitName2	= @unit2_name,
			Quantity2	= @unit2_value,
			UnitID3		= @unit3_id,
			UnitName3	= @unit3_name,
			Quantity3	= @unit3_value,
			Weight		= G.GoodsWeight,
			Volume		= G.GoodsLength * G.GoodsHeight * G.GoodsWidth,
			BarCode		= IsNull([inv].[FunGetGoodsBarCode] (G.GoodsID), '')
			
		from inv.tblGoods G
				INNER JOIN inv.tblGoodsDtl GD ON GD.GoodsID = SUBSTRING(G.GoodsID,@str_Goods+1, @str_GoodsSum) AND GD.PartNumber= @UnitPart AND GD.LanguageID = @LangID
		where G.GoodsID = @goods_id And #tbl_result.GoodsID = @goods_id  And #tbl_result.SerialNo=@serial_no And
			  #tbl_result.DstSerialNo=@dst_serial_no And #tbl_result.SaleSerials = @SaleSerials And 
			  #tbl_result.UserPriceID = @UserPrice And #tbl_result.StoreID=@StoreID
		-- next
		fetch next from cur_goods into @serial_no, @dst_serial_no, @goods_id, @SaleSerials, @saleCountInDist, @goods_quantity, @goods_price, @goods_price2, @UserPrice,@StoreID;
	end

	-- close goods cursor
	Close cur_goods;
	Deallocate cur_goods;
	
	-- ==============================
		set @StrSelect = '	SELECT  R.SerialNo, R.DstSerialNo, R.GoodsID, R.GoodsName, R.saleCountInDist, R.SaleSerials,
				Round(R.Quantity, '+ str(@QuantityDecimalsToForms) +') Quantity, R.Price, R.Price2,
				 pub.funFarsiDate(GETDATE()) PrintDate,
				R.UnitID1, R.UnitName1, Round(R.Quantity1, '+ str(@QuantityDecimalsToForms) +') Quantity1, R.UnitID2, R.UnitName2,
				Round(R.Quantity2, '+ str(@QuantityDecimalsToForms) +') Quantity2, R.UnitID3, R.UnitName3, 
				Round(R.Quantity3, '+ str(@QuantityDecimalsToForms) +') Quantity3, R.Weight, R.Volume, R.BarCode, R.UserPriceID,
				H.DriverID, H.DistributerID1, H.DistributerID2, H.DocDesc, H.DocDate, H.DistributDate, 
				Case When '+ str(@ProcessID ) +' = 100 Then R.StoreID else H.StoreID End StoreID, ST.StoreKeeperID, SK.StoreKeeperName, 
				DV.FirstName + '' '' + DV.LastName as DriverName, D.DriverTel, D.DriverMobile, D.VehicleNo, 
				IsNull(PR1.PersonnelName,'''') as DistributerName1, 
				IsNull(PR1.Tel ,'''') as DistributerTel1, 
				IsNull(PR1.Mobile ,'''') as DistributerMobile1, 
				IsNull(PR2.PersonnelName,'''') as DistributerName2,
				IsNull(PR2.Tel ,'''') as DistributerTel2, 
				IsNull(PR2.Mobile ,'''') as DistributerMobile2,
				G.TechnicalSpecifications ,G.TechnicalNo,
				IsNull((
						Select UParams 
						from inv.tblGoodsUserPrice p 
						where p.ID=UserPriceID) ,'''') as UserPrice, '+ str(@ShowUserPrice) +' ShowUserPrice,
				IsNull((
						select top 1 a.SerialNo 
						From sal.tblDistributionsDtl a 
						inner join inv.tblStorageDocsDtl b on a.BaseSaleProcessID  = b.BaseProcessID  and 
															  a.BaseSaleProcessNo  = b.BaseProcessNo  and 
															  a.BaseSaleFiscalYear = b.BaseFiscalYear and 
															  a.BaseSaleSerialNo   = b.BaseSerialNo
						where b.SerialNo=R.DstSerialNo),0) BaseSerialNo, '+ str(@NoGroupByRets ) +'NoGroupByRets,
						IsNull(H.Confirmed, 0) Confirmed, IsNull(H.BranchManagerConfirmed, 0) BranchManagerConfirmed,
						Case When '+ str(@ProcessID) +' = 100 Then pub.GetStoreName(R.StoreID,'+ str(@LangID) +') Else pub.GetStoreName(H.StoreID,'+ str(@LangID) +' ) End StoreName
						,S1.UserSign as UserSignature1, S2.UserSign as UserSignature2, S3.UserSign as UserSignature3, 
					S4.UserSign as UserSignature4, S5.UserSign as UserSignature5
					,' + @db_0000 + '.[pub].[funUserName](' + @db_0000 + '.[pub].[funGetUserID](H.SessionNo)) UserName
					,' + @db_0000 + '.[pub].[funUserName](' + @db_0000 + '.[pub].[funGetUserID](H.SessionNo2)) UserName2
					,' + @db_0000 + '.[pub].[funUserName](' + @db_0000 + '.[pub].[funGetUserID](H.SessionNo3)) UserName3
					,' + @db_0000 + '.[pub].[funUserName](' + @db_0000 + '.[pub].[funGetUserID](H.SessionNo4)) UserName4
					,' + @db_0000 + '.[pub].[funUserName](' + @db_0000 + '.[pub].[funGetUserID](H.SessionNo5)) UserName5
	'	
	set @StrSelect2 = '	FROM #tbl_result R
				LEFT JOIN sal.tblDistributionsHdr H on H.SerialNo = R.DstSerialNo
				LEFT JOIN pub.tblDriversDtl DV on H.DriverID = DV.DriverID and DV.LanguageID = 1
				LEFT JOIN pub.tblDrivers D on H.DriverID = D.DriverID 
				LEFT JOIN prs.vwPersonnels PR1 on H.DistributerID1 = PR1.PersonnelID 
				LEFT JOIN prs.vwPersonnels PR2 on H.DistributerID2 = PR2.PersonnelID
				LEFT JOIN inv.tblStores ST on ST.StoreID = H.StoreID
				LEFT JOIN inv.tblStoreKeepersDtl SK on SK.StoreKeeperID = ST.StoreKeeperID
				LEFT JOIN inv.tblGoods G ON SUBSTRING(R.GoodsID,'+ str(@str_Goods+1) +', '+ str(@str_GoodsSum) +')=G.GoodsID AND G.PartNumber= '+ str(@UnitPart) +'
				LEFT join #tbl_Invoice_Signatures S1 on S1.UserID = ' + ltrim(rtrim(@db_0000))+ '.[pub].[funGetUserID](H.SessionNo)
				LEFT join #tbl_Invoice_Signatures S2 on S2.UserID = ' + ltrim(rtrim(@db_0000))+ '.[pub].[funGetUserID](H.SessionNo2)
				LEFT join #tbl_Invoice_Signatures S3 on S3.UserID = ' + ltrim(rtrim(@db_0000))+ '.[pub].[funGetUserID](H.SessionNo3)
				LEFT join #tbl_Invoice_Signatures S4 on S4.UserID = ' + ltrim(rtrim(@db_0000))+ '.[pub].[funGetUserID](H.SessionNo4)
				LEFT join #tbl_Invoice_Signatures S5 on S5.UserID = ' + ltrim(rtrim(@db_0000))+ '.[pub].[funGetUserID](H.SessionNo5)
		ORDER BY R.DstSerialNo, R.GoodsID'
		Print @StrSelect;
		Print @StrSelect2;
		set @StrSelect=@StrSelect+@StrSelect2;
	exec sp_executesql @StrSelect;
END
GO
