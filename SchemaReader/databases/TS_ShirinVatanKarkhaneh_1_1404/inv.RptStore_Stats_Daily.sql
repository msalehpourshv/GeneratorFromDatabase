USE TS_ShirinVatanKarkhaneh_1_1404
GO
SET ANSI_NULLS, QUOTED_IDENTIFIER ON
GO
-- =========== TS-QC:UPDATED ====================
-- Author		 : TakroSystem\Zia
-- Creation Date : 1392/09/17
-- Viewed By	 : 
-- Last Modified : 1392/10/09
-- Last Modifier : TakroSystem\Zia
-- Description   : گزارش سرجمع انبار 
-- ==============================================
CREATE PROCEDURE [inv].[RptStore_Stats_Daily]
	@ProcessID			Int = 90,
	@ProcessNo			Int = 1,
	@FiscalYearFr		Int = Null,
	@SerialNoFr			Int = Null,
	@FiscalYearTo		Int = Null,
	@SerialNoTo			Int = Null,
	@DocDateFr			Char(10) = Null,
	@DocDateTo			Char(10) = Null,
	@SelectedProds		Int = 0, 
	@SelectedGoods		Int = 0, 
	@SelectedStore		Int = 0, 
	@SelectedStor2		Int = 0, 
	@SelectedAcnt1		Int = 0, 
	@SelectedAcnt2		Int = 0, 
	@SelectedAcnt3		Int = 0, 
	@SelectedAcnt4		Int = 0, 
	@SelectedVisitor1	Int = 0, 
	@SelectedVisitor2	Int = 0, 
	@SelectedVisitor3	Int = 0, 
	@SelectedVisitor4	Int = 0, 
	@CustKind			VarChar(20) = null,
	@RepOptions			VarChar(20) = '1110111111', -- bit array options
	@SortFields			NVarChar(100) = 'MonthCode',   -- Order By Field List
	@RepInfo			NVarChar(100) = '1@1@1'
WITH ENCRYPTION
AS 
	---- Declarations ---------------
DECLARE @StrSelect	NVarChar(max);
DECLARE @StrFrom	NVarChar(max);
DECLARE @StrWhere	NVarChar(max);
DECLARE @StrWhere2	NVarChar(max);

DECLARE @DocStep	Int;

DECLARE @StrPrice	NVarChar(100);
DECLARE @EP			NVarChar(100);

DECLARE @ProcessID_Ret	Int;

DECLARE @ShowOverload	Bit;
DECLARE @ShowDiscount	Bit;  
DECLARE @DecReturn		Bit; 
DECLARE @UseAmount		Bit; -- Use Amount Field Instead of Price?
DECLARE @ZeroRows		Bit;
DECLARE @RefY			Bit;
DECLARE @RefN			Bit;

DECLARE	@LangID			Char(1);
DECLARE	@SessionNo		Int; -- برای حالت کدهای انتخابی
DECLARE	@ReportID		Int; -- برای حالت کدهای انتخابی
DECLARE	@UserID		Int;
DECLARE	@UserIsAdmin bit;

DECLARE @StrPID		nVarChar(50);
DECLARE @PID1	bit;
DECLARE @PID2	bit;
DECLARE @PID3	bit;

declare @StrQty		nvarchar(max);
declare @StrPrc		nvarchar(max);
declare @StrAtm		nvarchar(max);
declare @StrQtyR	nvarchar(max);
declare @StrPrcR	nvarchar(max);
declare @StrAtmR	nvarchar(max);
Begin --============== S T A R T  C O D E ===================================================

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
	
	-- Init Variables --------
	IF (@RepOptions Is Null)	SET @RepOptions = '1110111111'
	IF (@ProcessNo  Is Null)	SET @ProcessNo = 1;

	IF (@SelectedGoods	Is Null)	SET @SelectedGoods = 0;
	IF (@SelectedStore	Is Null)	SET @SelectedStore = 0;
	IF (@SelectedProds  Is Null)	SET @SelectedProds = 0;
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

	SET @ShowOverload	= Substring(@RepOptions, 1, 1);
	SET @ShowDiscount	= Substring(@RepOptions, 2, 1);
	SET @DecReturn		= Substring(@RepOptions, 3, 1);
	SET @UseAmount		= Substring(@RepOptions, 4, 1);
	SET @RefY			= Substring(@RepOptions, 5, 1);
	SET @RefN			= Substring(@RepOptions, 6, 1);
	SET @PID1			= Substring(@RepOptions, 7, 1);
	SET @PID2			= Substring(@RepOptions, 8, 1);
	SET @PID3			= Substring(@RepOptions, 9, 1);
	
	SET @LangID		= pub.funSplitString(@RepInfo, '@', 1);
	SET @SessionNo	= pub.funSplitString(@RepInfo, '@', 2);
	SET @ReportID	= pub.funSplitString(@RepInfo, '@', 3);
	SET @UserID		= pub.funSplitString(@RepInfo, '@', 4);
	SET @UserIsAdmin= pub.funSplitString(@RepInfo, '@', 5);

    Set @StrWhere2 ='(GoodsID=T.GoodsID) and (DocDate <= T.DocDate)'

	SET @ProcessID_Ret =
		Case @ProcessID 
			When 55 Then 60
			When 70 Then 75
			When 90 Then 100
			When 110 Then 115
			Else 0
		End

	if (@PID1 = 0) and (@PID2 = 0) and (@PID3 = 0)
		set @PID1 = 1

	if (@ProcessID = 70) or (@ProcessID = 80)
	begin	
		set @StrPID = '0';

		if (@PID1 = 1)
			set @StrPID = @StrPID + ',' + ltrim(str(@ProcessID));

		if (@PID2 = 1)
			if (@ProcessID = 70) 
				set @StrPID = @StrPID + ',82' 
			else
				set @StrPID = @StrPID + ',72' 
			
		if (@PID3 = 1)
			if (@ProcessID = 70) 
				set @StrPID = @StrPID + ',83' 
			else
				set @StrPID = @StrPID + ',73' 
	end
	else
		set @StrPID = ltrim(str(@ProcessID))
	-- --------------------------------------------------
	-- Where Clause -----------------------------------------------------------
	Set @StrWhere = '(D.ProcessID in (' + @StrPID + '))'

	if not (@RefY = 1)
		set @StrWhere = @StrWhere + ' AND (D.BaseSerialNo=0)'
	if not (@RefN = 1)
		set @StrWhere = @StrWhere + ' AND (D.BaseSerialNo<>0)'

	if (@CustKind <> '')
		Set @StrWhere = @StrWhere + ' AND (pub.funGetCustomerKindID(D.AcntCode) = ''' + @CustKind + ''')'

	If (@ProcessNo Is Not Null) and (@ProcessNo > 0)
		SET @StrWhere = @StrWhere + ' AND (D.ProcessNo = ' + LTrim(Str(@ProcessNo)) + ')'

	If (@SerialNoFr Is Not Null)
		Set @StrWhere = @StrWhere + ' AND (D.FiscalYear > ' + LTrim(Str(@FiscalYearFr)) + ' OR (D.FiscalYear = ' + LTrim(Str(@FiscalYearFr)) + ' AND D.SerialNo >= ' + LTrim(Str(@SerialNoFr)) + '))' 
	If (@SerialNoTo Is Not Null)
		Set @StrWhere = @StrWhere + ' AND (D.FiscalYear < ' + LTrim(Str(@FiscalYearTo)) + ' OR (D.FiscalYear = ' + LTrim(Str(@FiscalYearTo)) + ' AND D.SerialNo <= ' + LTrim(Str(@SerialNoTo)) + '))' 

	IF (@DocDateFr Is Not Null)
		SET @StrWhere = @StrWhere + ' AND (D.DocDate >= ''' + @DocDateFr + ''')'
	IF @DocDateTo Is Not Null
		SET @StrWhere = @StrWhere + ' AND (D.DocDate <= ''' + @DocDateTo + ''')'

	If (@SelectedProds > 0)
		SET @StrWhere = @StrWhere + ' AND ' + pub.funGetFilterString(@SessionNo, @ReportID, @SelectedProds, 'H.ProductID') 
	If (@SelectedGoods > 0)
		SET @StrWhere = @StrWhere + ' AND ' + pub.funGetFilterString(@SessionNo, @ReportID, @SelectedGoods, 'D.GoodsID') 
	If (@SelectedStore > 0)
	Begin
		SET @StrWhere = @StrWhere + ' AND ' + pub.funGetFilterString(@SessionNo, @ReportID, @SelectedStore, 'D.StoreID') 
		SET @StrWhere2 = @StrWhere2 + ' AND ' + pub.funGetFilterString(@SessionNo, @ReportID, @SelectedStore, 'StoreID') 
	End
	
	If (@SelectedStor2 > 0)
		SET @StrWhere = @StrWhere + ' AND ' + pub.funGetFilterString(@SessionNo, @ReportID, @SelectedStor2, 'D.StoreID2')

	If (@SelectedAcnt1 > 0)
		SET @StrWhere = @StrWhere + ' AND ' + pub.funGetFilterString(@SessionNo, @ReportID, @SelectedAcnt1, 'D.AcntCode')
	If (@SelectedAcnt2 > 0)
		SET @StrWhere = @StrWhere + ' AND ' + pub.funGetFilterString(@SessionNo, @ReportID, @SelectedAcnt2, 'D.AcntCode')
	If (@SelectedAcnt3 > 0)
		SET @StrWhere = @StrWhere + ' AND ' + pub.funGetFilterString(@SessionNo, @ReportID, @SelectedAcnt3, 'D.AcntCode')
	If (@SelectedAcnt4 > 0)
		SET @StrWhere = @StrWhere + ' AND ' + pub.funGetFilterString(@SessionNo, @ReportID, @SelectedAcnt4, 'D.AcntCode')

	If (@SelectedVisitor1 > 0)
		SET @StrWhere = @StrWhere + ' AND (' + pub.funGetFilterString(@SessionNo, @ReportID, @SelectedVisitor1, 'H.VisitorAcntCode') + ')'
	If (@SelectedVisitor2 > 0)
		SET @StrWhere = @StrWhere + ' AND (' + pub.funGetFilterString(@SessionNo, @ReportID, @SelectedVisitor2, 'H.VisitorAcntCode') + ')'
	If (@SelectedVisitor3 > 0)
		SET @StrWhere = @StrWhere + ' AND (' + pub.funGetFilterString(@SessionNo, @ReportID, @SelectedVisitor3, 'H.VisitorAcntCode') + ')'
	If (@SelectedVisitor4 > 0)
		SET @StrWhere = @StrWhere + ' AND (' + pub.funGetFilterString(@SessionNo, @ReportID, @SelectedVisitor4, 'H.VisitorAcntCode') + ')'

	IF (@DocStep > 0)
		SET @StrWhere = @StrWhere + ' AND (D.DocStep = ' + LTrim(Str(@DocStep)) + ')'

	---------------------------------------------------------
	-- Select Clause ----------------------------------------
	If (@UseAmount = 1) or (@ProcessID = 60)
		SET @StrPrice = 'GoodsAmount'
	Else 
		SET @StrPrice = 'GoodsPrice'
	
	SET @StrQty	= 'D.GoodsQuantity'
	SET @StrPrc	= '(D.GoodsQuantity*D.' + @StrPrice + ')'
	SET @StrAtm	= 'D.AtomAmount'
	SET @StrQtyR= '0'
	SET @StrPrcR= '0'
	SET @StrAtmR= '0'

	IF (@DecReturn = 1) AND (@ProcessID_Ret <> 0) 
	BEGIN
		declare @WhrR nvarchar(max);
		set @WhrR = '(D2.ProcessID=' + str(@ProcessID_Ret) + ') AND (D2.ProcessNo=' + Str(@ProcessNo) + ') and (D2.GoodsID=D.GoodsID) AND (D2.BaseProcessID=D.ProcessID) AND (D2.BaseProcessNo=D.ProcessNo) AND (D2.BaseFiscalYear=D.FiscalYear) AND (D2.BaseSerialNo=D.SerialNo) AND (D2.BaseDocRowNo=D.DocRowNo)'
	
		SET @StrQtyR= 'isnull((SELECT SUM(D2.GoodsQuantity) FROM inv.tblStorageDocsDtl D2 WHERE ' + @WhrR + '),0)'
		SET @StrPrcR= 'isnull((SELECT SUM(D2.GoodsQuantity*D2.' + @StrPrice + ') FROM inv.tblStorageDocsDtl D2 WHERE ' + @WhrR + '),0)'
		SET @StrAtmR= 'isnull((SELECT SUM(D2.AtomAmount) FROM inv.tblStorageDocsDtl D2 WHERE ' + @WhrR + '),0)'
	END
	
	set @EP = 'Price-PriceR'

	if (@ShowOverload = 1)
		set @EP = @EP + '+Overload-OverloadR'
	if (@ShowDiscount = 1)
		set @EP = @EP + '-Discount '
		
	SET @StrSelect = '
	select	T.DocDate, T.GoodsID, 
			sum(Quantity-QuantityR) SumQuantity, 
			Sum(' + @EP + ') SumPrice,
			(
				select sum(GoodsQuantity*EnterKind)
				from inv.tblStorageDocsDtl
				where ' + @StrWhere2 + '
			) DailyBalance
	into ##tbl_Store_Stats_Daily
	from 
	(
			SELECT D.DocDate, D.GoodsID, 
					' + @StrQty + ' Quantity,
					' + @StrPrc + ' Price,
					' + @StrAtm + ' Overload,
					' + @StrQtyR + ' QuantityR,
					' + @StrPrcR + ' PriceR,
					' + @StrAtmR + ' OverloadR,
					D.DiscountDtl Discount
			FROM inv.tblStorageDocsDtl D 
					INNER JOIN inv.tblStorageDocsHdr H ON H.ProcessID=D.ProcessID AND H.ProcessNo=D.ProcessNo AND H.FiscalYear=D.FiscalYear AND H.SerialNo=D.SerialNo
			WHERE ' + @StrWhere + '
	) T 
	where (T.Quantity-T.QuantityR > 0) 
	group by T.DocDate, T.GoodsID 
	order by T.DocDate, T.GoodsID'

	begin try
		drop table ##tbl_Store_Stats_Daily
	end try
	begin catch
	end catch
	
	-- Run -----------------------------------------------------
	print @StrSelect;
	Exec sp_executesql @StrSelect;

	if (@UserIsAdmin = 0)
	begin
		exec pub.SpFilterByPermission2 '##tbl_Store_Stats_Daily', 'GoodsID', 'inv.tblGoods', @UserID;
	end
	------------------------------------------------------------

	set @StrSelect = '
	select R.*, [pub].[funGetGoodsName](R.GoodsID,' + LTrim(RTrim(@LangID)) + ') GoodsName, 
		   IsNull([inv].[FunGetGoodsBarCode] (R.GoodsID), '''') BarCode
	from ##tbl_Store_Stats_Daily R
	inner join inv.tblGoodsDtl G ON G.GoodsID = SUBSTRING(R.GoodsID,' + ltrim(rtrim(STR(@str_Goods+1))) + ',' + ltrim(rtrim(STR(@str_GoodsSum))) + ') AND G.PartNumber=' + ltrim(rtrim(STR(@UnitPart)))

	print @StrSelect;
	Exec sp_executesql @StrSelect;
End
GO
