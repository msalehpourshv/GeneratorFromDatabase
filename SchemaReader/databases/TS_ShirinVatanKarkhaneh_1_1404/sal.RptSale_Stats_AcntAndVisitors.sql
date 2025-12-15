USE TS_ShirinVatanKarkhaneh_1_1404
GO
SET ANSI_NULLS, QUOTED_IDENTIFIER ON
GO
-- =========== TS-QC:UPDATED ====================
-- Author		 : TakroSystem\Ahmadnejad
-- Creation Date : 1391/01/08
-- Viewed By	 : 
-- Last Modified : 1394/03/12
-- Last Modifier : TakroSystem\ZiA
-- Description   : گزارش سرجمع فروش بهمراه بازاریاب
-- ==============================================
Create PROCEDURE [sal].[RptSale_Stats_AcntAndVisitors]
	@ProcessID			Int = 90,
	@ProcessNo			Int = 1,
	@FiscalYearFr		Int = Null,
	@SerialNoFr			Int = Null,
	@FiscalYearTo		Int = Null,
	@SerialNoTo			Int = Null,
	@DocDateFr			VarChar(60) = Null,
	@DocDateTo			VarChar(60) = Null,
	@VchNoFr			Int = Null,
	@VchNoTo			Int = Null,
	@SelectedGoods		Int = 0, 
	@SelectedStore		Int = 0, 
	@SelectedAcnt1		Int = 0, 
	@SelectedAcnt2		Int = 0, 
	@SelectedAcnt3		Int = 0, 
	@SelectedAcnt4		Int = 0, 
	@SelectedVisitor1	Int = 0, 
	@SelectedVisitor2	Int = 0, 
	@SelectedVisitor3	Int = 0, 
	@SelectedVisitor4	Int = 0, 
	@PriceFr			float = null,
	@PriceTo			float = null,
	@LocationFr			VarChar(20) = null,
	@LocationTo			VarChar(20) = null,
	@CustKind			VarChar(20) = null,
	@DocStep			Int = 0,  -- مرحله
	@RepOptions			VarChar(20) = '1101111101', -- bit array options
	@SortFields			NVarChar(100) = Null,   -- Order By Field List
	@RepInfo			NVarChar(100) = '1@1@1' -- bit array options

WITH ENCRYPTION
AS 
---- Declarations ---------------
DECLARE @StrSelect	NVarChar(MAX);
DECLARE @StrSelect2	NVarChar(MAX);
--DECLARE @StrFrom	NVarChar(1000);
DECLARE @StrWhereD	NVarChar(MAX);
DECLARE @StrWhereH	NVarChar(MAX);
DECLARE @StrWhereR	NVarChar(MAX);
DECLARE @StrWhereR2	NVarChar(MAX);
DECLARE @StrWhereR3	NVarChar(MAX);
	
declare @StrPrice	nvarchar(MAX);
declare @StrSumPrice varchar(MAX);
declare @StrSumPriceVisitor varchar(MAX);
declare @StrSumVisitorDiscount varchar(MAX);

DECLARE @StrQty		NVarChar(200);
DECLARE @StrQty_Ret	NVarChar(200);
DECLARE @StrPrc		NVarChar(200);
DECLARE @StrPrc_Ret	NVarChar(200);
DECLARE @StrExtraGroup	NVarChar(100);

DECLARE @ShowQuantity	Bit;  -- شامل ستون مقدار
DECLARE @ShowPrice		Bit;  -- شامل ستون قیمت
DECLARE @DecDiscount	Bit;  
DECLARE @ShowZeroRows	Bit; -- Not Used; Only for Sync with summary report
DECLARE @DecReturn		Bit; -- Not Used; Only for Sync with summary report
DECLARE @UseAmount		Bit; -- Use Amount Field Instead of Price?
DECLARE @RefY			Bit;
DECLARE @RefN			Bit;
DECLARE @WithoutVisitor	Bit;
DECLARE @AddNotRefRets	Bit;

DECLARE	@LangID			Char(1);
DECLARE	@SessionNo		Int; -- برای حالت کدهای انتخابی
DECLARE	@ReportID		Int; -- برای حالت کدهای انتخابی

DECLARE @EP			VarChar(1024);
DECLARE @PID_Org	VarChar(20);
DECLARE @PID_Ret	VarChar(20);

DECLARE @ret_qty as nvarchar(4000);
DECLARE @ret_prc as nvarchar(4000);
DECLARE @ret_vis as nvarchar(4000);

DECLARE @CustomersAcntPartNumber AS TinyInt;
DECLARE @StartLayerIndex AS TinyInt;
DECLARE @LayerLen AS TinyInt;
DECLARE @SelectedVisitor21		Int ;
DECLARE @SelectedVisitor22		Int ;
DECLARE @SelectedVisitor23		Int ;
DECLARE @SelectedVisitor24		Int ;

Begin --============== S T A R T  C O D E ===================================================

	SET NOCOUNT ON;

	-- Init Variables --------
	IF (@RepOptions Is Null)	SET @RepOptions = '11000111111111'
	IF (@DocStep	Is Null)	SET @DocStep = 0;

	IF (@DocDateFr	Is Null)	SET @DocDateFr = '@@@';
	IF (@DocDateTo	Is Null)	SET @DocDateTo = '@@@';

	IF (@SelectedGoods	Is Null)	SET @SelectedGoods = 0;
	IF (@SelectedStore	Is Null)	SET @SelectedStore = 0;
	IF (@SelectedAcnt1	Is Null)	SET @SelectedAcnt1 = 0;
	IF (@SelectedAcnt2	Is Null)	SET @SelectedAcnt2 = 0;
	IF (@SelectedAcnt3	Is Null)	SET @SelectedAcnt3 = 0;
	IF (@SelectedAcnt4	Is Null)	SET @SelectedAcnt4 = 0;
	IF (@SelectedVisitor1 Is Null)	SET @SelectedVisitor1 = 0;
	IF (@SelectedVisitor2 Is Null)	SET @SelectedVisitor2 = 0;
	IF (@SelectedVisitor3 Is Null)	SET @SelectedVisitor3 = 0;
	IF (@SelectedVisitor4 Is Null)	SET @SelectedVisitor4 = 0;

	IF (@FiscalYearFr Is Null)		SET @SerialNoFr = Null;
	IF (@FiscalYearTo Is Null)		SET @SerialNoTo = Null;
	IF (@SerialNoFr	Is Null)		SET @FiscalYearFr = Null;
	IF (@SerialNoTo	Is Null)		SET @FiscalYearTo = Null;

	SET @ShowQuantity	= Substring(@RepOptions, 1, 1);
	SET @ShowPrice		= Substring(@RepOptions, 2, 1);
	SET @ShowZeroRows	= Substring(@RepOptions, 3, 1);
	SET @DecReturn		= Substring(@RepOptions, 4, 1);
	SET @DecDiscount	= Substring(@RepOptions, 5, 1);
	SET @UseAmount		= Substring(@RepOptions, 6, 1);
	SET @WithoutVisitor	= Substring(@RepOptions, 7, 1);
	SET @RefY			= Substring(@RepOptions, 8, 1);
	SET @RefN			= Substring(@RepOptions, 9, 1);
	SET @AddNotRefRets	= Substring(@RepOptions, 10, 1);

	SET @LangID		= pub.funSplitString(@RepInfo, '@', 1);
	SET @SessionNo	= pub.funSplitString(@RepInfo, '@', 2);
	SET @ReportID	= pub.funSplitString(@RepInfo, '@', 3);

	set @SelectedVisitor21		= LTrim(pub.funSplitString(@RepInfo, '@', 6));
	set @SelectedVisitor22		= LTrim(pub.funSplitString(@RepInfo, '@', 7));
	set @SelectedVisitor23		= LTrim(pub.funSplitString(@RepInfo, '@', 8));
	set @SelectedVisitor24		= LTrim(pub.funSplitString(@RepInfo, '@', 9));

	SET @PID_Org = LTrim(RTrim(Str(@ProcessID)))
	SET @PID_Ret = '100'
	
	SET @CustomersAcntPartNumber = 0
	SET @StartLayerIndex = 0
	SET @LayerLen = 0
	
	SELECT @StartLayerIndex = SettingValue
	FROM pub.tblSettings
	WHERE SettingKey = 'StartLayerIndex'

	SELECT @LayerLen = SettingValue
	FROM pub.tblSettings
	WHERE SettingKey = 'LayerLen'
	
	SELECT @CustomersAcntPartNumber = SettingValue
	FROM pub.tblSettings
	WHERE SettingKey = 'AcntPartNumberForRemainCalculation'
	
	-- --------------------------------------------------
	-- Where Clause -----------------------------------------------------------
	Set @StrWhereD = '(D.ProcessID=' + @PID_Org + ')'
	Set @StrWhereH = '(1=1)'
	Set @StrWhereR = '(RR.ProcessID=100) 
				AND (RR.ProcessNo=' + STR(@ProcessNo) + ') 
				AND (RR.BaseSerialNo=0)'

	Set @StrWhereR2 = '(R.ProcessID=' + @PID_Ret + ') and (R.BaseProcessID=D.ProcessID) and (R.BaseProcessNo=D.ProcessNo) and (R.BaseFiscalYear=D.FiscalYear) and (R.BaseSerialNo=D.SerialNo) and (R.BaseDocRowNo=D.DocRowNo)'
	
	Set @StrWhereR3 = '(R.ProcessID=' + @PID_Ret + ') and (R.BaseProcessID=X.ProcessID) and (R.BaseProcessNo=X.ProcessNo) and (R.BaseFiscalYear=X.FiscalYear) and (R.BaseSerialNo=X.SerialNo)'
		
	If (@ProcessNo Is Not Null)
		SET @StrWhereD = @StrWhereD + ' AND (D.ProcessNo=' + LTrim(Str(@ProcessNo)) + ')'
		
	if not (@RefY = 1)
		set @StrWhereD = @StrWhereD + ' AND (D.BaseSerialNo=0)'
	if not (@RefN = 1)
		set @StrWhereD = @StrWhereD + ' AND (D.BaseSerialNo<>0)'
	
	If (@SerialNoFr Is Not Null)
		SET @StrWhereD = @StrWhereD + ' AND (D.FiscalYear>' + LTrim(Str(@FiscalYearFr)) + ' OR (D.FiscalYear=' + LTrim(Str(@FiscalYearFr)) + ' AND D.SerialNo>=' + LTrim(Str(@SerialNoFr)) + '))' 
	If (@SerialNoTo Is Not Null)
		SET @StrWhereD = @StrWhereD + ' AND (D.FiscalYear<' + LTrim(Str(@FiscalYearTo)) + ' OR (D.FiscalYear=' + LTrim(Str(@FiscalYearTo)) + ' AND D.SerialNo<=' + LTrim(Str(@SerialNoTo)) + '))' 

	IF (@DocDateFr Is Not Null) AND (@DocDateFr <> '@@@')
		SET @StrWhereH = @StrWhereH + ' AND ' + inv.funGetDateFilter(@DocDateFr, '>=', 'H.DocDate', 'H.DocDate2', 'H.DocDate3', 'H.DocDate4')
	IF (@DocDateTo Is Not Null) AND (@DocDateTo <> '@@@')
		SET @StrWhereH = @StrWhereH + ' AND ' + inv.funGetDateFilter(@DocDateTo, '<=', 'H.DocDate', 'H.DocDate2', 'H.DocDate3', 'H.DocDate4')

	IF (@DocDateFr Is Not Null) AND (@DocDateFr <> '@@@')
	Begin
		SET @StrWhereR = @StrWhereR + ' AND ' + inv.funGetDateFilter(@DocDateFr, '>=', 'RR.DocDate', 'RR.DocDate2', 'RR.DocDate3', 'RR.DocDate4')
		--SET @StrWhereR2 = @StrWhereR2 + ' AND ' + inv.funGetDateFilter(@DocDateFr, '>=', 'R.DocDate', 'R.DocDate2', 'R.DocDate3', 'R.DocDate4')
		--SET @StrWhereR3 = @StrWhereR3 + ' AND ' + inv.funGetDateFilter(@DocDateFr, '>=', 'R.DocDate', 'R.DocDate2', 'R.DocDate3', 'R.DocDate4')
	End
	
	IF (@DocDateTo Is Not Null) AND (@DocDateTo <> '@@@')
	Begin
		SET @StrWhereR = @StrWhereR + ' AND ' + inv.funGetDateFilter(@DocDateTo, '<=', 'RR.DocDate', 'RR.DocDate2', 'RR.DocDate3', 'RR.DocDate4')
		--SET @StrWhereR2 = @StrWhereR2 + ' AND ' + inv.funGetDateFilter(@DocDateTo, '<=', 'R.DocDate', 'R.DocDate2', 'R.DocDate3', 'R.DocDate4')
		--SET @StrWhereR3 = @StrWhereR3 + ' AND ' + inv.funGetDateFilter(@DocDateTo, '<=', 'R.DocDate', 'R.DocDate2', 'R.DocDate3', 'R.DocDate4')
	End

	If (@SelectedGoods > 0)
		SET @StrWhereD = @StrWhereD + ' AND ' + pub.funGetFilterString(@SessionNo, @ReportID, @SelectedGoods, 'D.GoodsID') 
	If (@SelectedStore > 0)
		SET @StrWhereD = @StrWhereD + ' AND ' + pub.funGetFilterString(@SessionNo, @ReportID, @SelectedStore, 'D.StoreID') 

	If (@SelectedAcnt1 > 0)
		SET @StrWhereD = @StrWhereD + ' AND ' + pub.funGetFilterString(@SessionNo, @ReportID, @SelectedAcnt1, 'D.AcntCode')
	If (@SelectedAcnt2 > 0)
		SET @StrWhereD = @StrWhereD + ' AND ' + pub.funGetFilterString(@SessionNo, @ReportID, @SelectedAcnt2, 'D.AcntCode')
	If (@SelectedAcnt3 > 0)
		SET @StrWhereD = @StrWhereD + ' AND ' + pub.funGetFilterString(@SessionNo, @ReportID, @SelectedAcnt3, 'D.AcntCode')
	If (@SelectedAcnt4 > 0)
		SET @StrWhereD = @StrWhereD + ' AND ' + pub.funGetFilterString(@SessionNo, @ReportID, @SelectedAcnt4, 'D.AcntCode')

	--- HDR ---
	If (@SelectedVisitor1 > 0)
		SET @StrWhereH = @StrWhereH + ' AND (' + pub.funGetFilterString(@SessionNo, @ReportID, @SelectedVisitor1, 'T.VisitorAcntCode') + ')'
	If (@SelectedVisitor2 > 0)
		SET @StrWhereH = @StrWhereH + ' AND (' + pub.funGetFilterString(@SessionNo, @ReportID, @SelectedVisitor2, 'T.VisitorAcntCode') + ')'
	If (@SelectedVisitor3 > 0)
		SET @StrWhereH = @StrWhereH + ' AND (' + pub.funGetFilterString(@SessionNo, @ReportID, @SelectedVisitor3, 'T.VisitorAcntCode') + ')'
	If (@SelectedVisitor4 > 0)
		SET @StrWhereH = @StrWhereH + ' AND (' + pub.funGetFilterString(@SessionNo, @ReportID, @SelectedVisitor4, 'T.VisitorAcntCode') + ')'

	If (@SelectedVisitor21 > 0)
		SET @StrWhereH = @StrWhereH + ' AND (' + pub.funGetFilterString(@SessionNo, @ReportID, @SelectedVisitor21, 'T.VisitorAcntCode2') + ')'
	If (@SelectedVisitor22 > 0)
		SET @StrWhereH = @StrWhereH + ' AND (' + pub.funGetFilterString(@SessionNo, @ReportID, @SelectedVisitor22, 'T.VisitorAcntCode2') + ')'
	If (@SelectedVisitor23 > 0)
		SET @StrWhereH = @StrWhereH + ' AND (' + pub.funGetFilterString(@SessionNo, @ReportID, @SelectedVisitor23, 'T.VisitorAcntCode2') + ')'
	If (@SelectedVisitor24 > 0)
		SET @StrWhereH = @StrWhereH + ' AND (' + pub.funGetFilterString(@SessionNo, @ReportID, @SelectedVisitor24, 'T.VisitorAcntCode2') + ')'

	if (@LocationFr <> '')
		Set @StrWhereH = @StrWhereH + ' AND (Left(H.LocationID,' + str(len(@LocationFr)) + ')>=''' + @LocationFr + ''')'
	if (@LocationTo <> '')
		Set @StrWhereH = @StrWhereH + ' AND (Left(H.LocationID,' + str(len(@LocationTo)) + ')<=''' + @LocationTo + ''')'

	IF (@DocStep > 0)
		SET @StrWhereH = @StrWhereH + ' AND (H.DocStep = ' + LTrim(Str(@DocStep)) + ')'

	if (@CustKind is not null) and (@CustKind <> '')
		Set @StrWhereH = @StrWhereH + ' AND (pub.funGetCustomerKindID(H.AcntCode) = ''' + @CustKind + ''')'
		
	if (@WithoutVisitor <> 1)
		Set @StrWhereH = @StrWhereH + ' AND (H.VisitorAcntCode <> '''')'

	If (@VchNoFr Is Not Null) OR (@VchNoTo Is Not Null)
		If (@VchNoFr = @VchNoTo)
			SET @StrWhereH = @StrWhereH + ' AND H.VchNo  = ' + LTrim(Str(@VchNoFr))
		Else
		Begin
			If (@VchNoFr Is Not Null)
				SET @StrWhereH = @StrWhereH + ' AND H.VchNo >= ' + LTrim(Str(@VchNoFr))
			If (@VchNoTo Is Not Null)
				SET @StrWhereH = @StrWhereH + ' AND H.VchNo <= ' + LTrim(Str(@VchNoTo))
		End
	---------------------------------------------------------
	-- Select Clause ----------------------------------------
	set @StrQty		= 'D.GoodsQuantity'	
	set @StrQty_Ret	= 'R.GoodsQuantity'	
			
	If (@UseAmount = 1)
	begin
		SET @StrPrc     = 'D.GoodsQuantity*D.GoodsAmount'
		SET @StrPrc_Ret = 'R.GoodsQuantity*R.GoodsAmount'	
		SET @StrExtraGroup = 'D.GoodsAmount'
	end
	Else 
	begin
		SET @StrPrc		= 'D.GoodsQuantity*D.GoodsPrice'
		SET @StrPrc_Ret = 'R.GoodsQuantity*R.GoodsPrice'
		SET @StrExtraGroup = 'D.GoodsPrice'		
	end
--print @StrWhereR
--print @StrWhereR2
--print @StrWhereR3
	If (@DecReturn = 1) 
	begin
		--set @ret_qty = 'isnull((select sum(' + @StrQty_Ret + ') from inv.tblStorageDocsDtl R where (R.ProcessID=' + @PID_Ret + ') and (R.BaseProcessID=D.ProcessID) and (R.BaseProcessNo=D.ProcessNo) and (R.BaseFiscalYear=D.FiscalYear) and (R.BaseSerialNo=D.SerialNo) and (R.BaseDocRowNo=D.DocRowNo)' + @StrWhereR + '),0)';
		--set @ret_prc = 'isnull((select sum(' + @StrPrc_Ret + ') from inv.tblStorageDocsDtl R where (R.ProcessID=' + @PID_Ret + ') and (R.BaseProcessID=D.ProcessID) and (R.BaseProcessNo=D.ProcessNo) and (R.BaseFiscalYear=D.FiscalYear) and (R.BaseSerialNo=D.SerialNo) and (R.BaseDocRowNo=D.DocRowNo)' + @StrWhereR + '),0)';
		--set @ret_vis = 'isnull((select sum(R.VisitorCost) from inv.tblStorageDocsHdr R where (R.ProcessID=' + @PID_Ret + ') and (R.BaseProcessID=X.ProcessID) and (R.BaseProcessNo=X.ProcessNo) and (R.BaseFiscalYear=X.FiscalYear) and (R.BaseSerialNo=X.SerialNo)' + @StrWhereR + '),0)';
		
        set @ret_qty = 'isnull((select sum(' + @StrQty_Ret + ') from inv.tblStorageDocsDtl R where ' + @StrWhereR2 + '),0)';
		set @ret_prc = 'isnull((select sum(' + @StrPrc_Ret + ') from inv.tblStorageDocsDtl R where ' + @StrWhereR2 + '),0)';
		set @ret_vis = 'isnull((select sum(R.VisitorCost) from inv.tblStorageDocsHdr R where ' + @StrWhereR3 + '),0)';		
	end
	else
	begin
		set @ret_qty = '0';
		set @ret_prc = '0';
		set @ret_vis = '0';
	end;
	

	--select @ret_qty
	--select @ret_prc
	--select @ret_vis
	if (@DecDiscount=0)
	begin
		set @StrPrice = 'T.SumPrice'
		set @StrSumVisitorDiscount = '-'
	end
	else
	begin
		-- dec discounts
		if (@DecReturn = 0)
			set @StrPrice = 'T.SumPrice-H.Discount-H.Discount2-H.Discount3-H.TotalLineDiscount' 
		else
			set @StrPrice = 'T.SumPrice-H.Discount-H.Discount2-H.Discount3-H.TotalLineDiscount+isnull(R.Discount,0)+isnull(R.Discount2,0)+isnull(R.Discount3,0)+isnull(R.TotalLineDiscount,0)' 
	end

	if (@AddNotRefRets = 0)
	Begin
		set @StrSumPrice = 'Sum(' + @StrPrice + ')'
		
		set @StrSumPriceVisitor = '(Case When Sum(T.SumPrice)=0 Then 0 Else H.VisitorCost-T.SumVisitorCostRet End)'
		--set @StrSumPriceVisitor = '(Case When Sum(T.SumPrice)=0 Then 0 Else H.VisitorCost End)'
	End
	else
	Begin
		set @StrSumPrice = 'Sum(' + @StrPrice + ')
		-(
		  isnull((
			select  Sum(RR.GoodsQuantity*RR.GoodsPrice)  
			from inv.tblStorageDocsDtl RR
			where ' + @StrWhereR + '				
				AND (RR.AcntCode=T.AcntCode) 
				AND (RR.VisitorAcntCode=T.VisitorAcntCode)		
			), 0) + 
		  isnull((
			select  Sum(RR.SidePriceSum)  
			from inv.vwStorageDocsHdr RR
			where ' + @StrWhereR + '				
				AND (RR.AcntCode=T.AcntCode) 
				AND (RR.VisitorAcntCode=T.VisitorAcntCode)
			), 0)
		)'

		set @StrSumPriceVisitor = '(Case When Sum(T.SumPrice)=0 Then 0 Else H.VisitorCost-T.SumVisitorCostRet End)
		-(
		  isnull((
			select  Sum(RR.VisitorCost)
			from inv.tblStorageDocsHdr RR
			where ' + @StrWhereR + '				
				AND (RR.AcntCode=T.AcntCode) 
				AND (RR.VisitorAcntCode=T.VisitorAcntCode)		
			), 0)
		)'		
		
	End
	
	SET @StrSelect2 = '
	select	T.SerialNo,T.AcntCode, T.VisitorAcntCode, T.VisitorAcntCode2, Count(*) as Count, 
		    IsNull(acc.funGetAcntName(SubString(T.AcntCode, ' + LTrim(RTrim(Str(@StartLayerIndex))) + ',' + LTrim(RTrim(Str(@LayerLen))) + '),' + LTrim(RTrim(Str(@CustomersAcntPartNumber))) + ', ' + LTrim(RTrim(Str(@LangID))) + '),'''') As AcntName,
			pub.GetCodeName(T.VisitorAcntCode, ' + @LangID + ') AS VisitorAcntName,pub.GetCodeName(T.VisitorAcntCode2, ' + @LangID + ') AS VisitorAcntName2,
			Sum(T.SumQuantity) SumQuantity, ' + @StrSumPrice + ' SumPrice,H.Discount,H.Discount2+H.Discount3 Discount2,H.TotalLineDiscount,
			Sum(H.Discount+H.Discount2+H.TotalLineDiscount-IsNull(R1.Discount,0)-IsNull(R1.Discount2,0)-IsNull(R1.Discount3,0)-IsNull(R1.TotalLineDiscount,0)) SumDiscount, F.NationalIDNumber,
			' + @StrSumPriceVisitor + ' As SumVisitorCost
	from
	( select	ProcessID, ProcessNo, FiscalYear, SerialNo, AcntCode, VisitorAcntCode,VisitorAcntCode2,
				Sum(SumQuantity) SumQuantity, SUM(SumPrice) SumPrice,
				'+@ret_vis+' as SumVisitorCostRet
		from		(	
			SELECT  D.ProcessID, D.ProcessNo, D.FiscalYear, D.SerialNo, D.AcntCode, D.VisitorAcntCode,D.VisitorAcntCode2,
					(' + @StrQty + ' - ' + @ret_qty + ') SumQuantity,
					(' + @StrPrc + ' - ' + @ret_prc + ') SumPrice
			FROM    inv.tblStorageDocsDtl D 
			WHERE   ' + @StrWhereD + '
			GROUP BY D.ProcessID, D.ProcessNo, D.FiscalYear, D.SerialNo, D.AcntCode, D.VisitorAcntCode, D.VisitorAcntCode2, D.DocRowNo, D.GoodsQuantity, ' + @StrExtraGroup + '
		) X
		group by ProcessID, ProcessNo, FiscalYear, SerialNo, AcntCode, VisitorAcntCode		, VisitorAcntCode2		
	) T	'
SET @StrSelect = '		
		INNER JOIN inv.tblStorageDocsHdr H ON H.ProcessID = T.ProcessID AND	H.ProcessNo = T.ProcessNo AND H.FiscalYear = T.FiscalYear AND H.SerialNo = T.SerialNo
		LEFT JOIN	(
		SELECT M.BaseProcessID, M.BaseProcessNo, M.BaseFiscalYear, M.BaseSerialNo,SUM(R.Discount) Discount,SUM(R.Discount2) Discount2,SUM(R.Discount3) Discount3,SUM(R.TotalLineDiscount) TotalLineDiscount 
		FROM inv.tblStorageDocsHdr R
		INNER JOIN (
			SELECT distinct ProcessID, ProcessNo, FiscalYear, SerialNo, BaseProcessID, BaseProcessNo, BaseFiscalYear, BaseSerialNo 
			FROM inv.tblStorageDocsDtl D 
			WHERE D.ProcessID = 100 and BaseProcessID = ' + LTrim(RTrim(Str(@ProcessID))) + '	
		) M 
		ON R.ProcessID = M.ProcessID AND R.ProcessNo = M.ProcessNo AND R.FiscalYear = M.FiscalYear AND R.SerialNo = M.SerialNo
		group by M.BaseProcessID, M.BaseProcessNo, M.BaseFiscalYear, M.BaseSerialNo
		) R1
		ON R1.BaseProcessID=H.ProcessID and R1.BaseProcessNo=H.ProcessNo and R1.BaseFiscalYear=H.FiscalYear and R1.BaseSerialNo=H.SerialNo
		OUTER APPLY acc.funGetCodeInfo(T.AcntCode)  F 
	WHERE ' + @StrWhereH + '
	group by T.SerialNo,T.AcntCode, T.VisitorAcntCode,T.VisitorAcntCode2,H.Discount,H.Discount2,H.Discount3,H.TotalLineDiscount,H.VisitorCost,T.SumVisitorCostRet ,H.VisitorCost2,F.NationalIDNumber'

	print @StrSelect2;
	print @StrSelect;

	if (@PriceFr is not null) Or (@PriceTo is not null) 
	begin
		set @StrWhereH = '(1=1)'

		if (@PriceFr is not null)
			Set @StrWhereH = @StrWhereH + ' AND (M.SumPrice >= ' + str(@PriceFr) + ')'
		if (@PriceTo is not null)
			Set @StrWhereH = @StrWhereH + ' AND (M.SumPrice <= ' + str(@PriceTo) + ')'
			
		SET @StrSelect = '
		select M.*
		from 
		(' + @StrSelect2 +@StrSelect + '
		) M
		where ' + @StrWhereH 
	end
	else
	SET @StrSelect = @StrSelect2 +@StrSelect
	------------------------------------------------------------

	-- Sort Clause ---------------------------------------------
	If (@SortFields Is Not Null) AND (@SortFields <> '') 
		SET @StrSelect = @StrSelect + '
	order by ' + @SortFields
	------------------------------------------------------------

	-- Run -----------------------------------------------------
	print @StrSelect;
	Exec sp_executesql @StrSelect;
	------------------------------------------------------------
End

GO
