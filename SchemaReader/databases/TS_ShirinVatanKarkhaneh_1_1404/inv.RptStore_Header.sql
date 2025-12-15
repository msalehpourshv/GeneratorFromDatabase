USE TS_ShirinVatanKarkhaneh_1_1404
GO
SET ANSI_NULLS, QUOTED_IDENTIFIER ON
GO
-- =========== TS-QC:UPDATED ====================
-- Author		 : TakroSystem\Ahmadnejad
-- Creation Date : 1388/02/29
-- Viewed By	 : 
-- Last Modified : 1393/08/10
-- Last Modifier : TakroSystem\Hamid
-- Description	 : گزارش سربرگ برگه های انبار
-- ==============================================
Create PROCEDURE [inv].[RptStore_Header]
	@ProcessID			Int = 90,  -- default is sale
	@ProcessNo			Int = Null,
	@FiscalYearFr		Int = Null,
	@SerialNoFr			Int = Null,
	@FiscalYearTo		Int = Null,
	@SerialNoTo			Int = Null,
	@DocDateFr			VarChar(60) = Null,
	@DocDateTo			VarChar(60) = Null,
	@VchNoFr			Int = Null,
	@VchNoTo			Int = Null,
	@SelectedGoods		Int = Null,
	@SelectedStore		Int = Null,
	@SelectedStore2		Int = Null,
	@SelectedAcnt1		Int = 0, 
	@SelectedAcnt2		Int = 0, 
	@SelectedAcnt3		Int = 0, 
	@SelectedAcnt4		Int = 0, 
	@SelectedOrders1	Int = 0, 
	@SelectedOrders2	Int = 0, 
	@SelectedOrders3	Int = 0, 
	@SelectedOrders4	Int = 0, 
	@SelectedVisitor1	Int = 0, 
	@SelectedVisitor2	Int = 0, 
	@SelectedVisitor3	Int = 0, 
	@SelectedVisitor4	Int = 0, 
	@DocStep			Int = 0,  -- مرحله
	@SaleTypeID			VarChar(20) = Null, -- کد نوع فروش
	@DocDescMask		NVarChar(100) = Null, -- بخشی از شرح
	@UseAmount			Bit = 0,
	@AddedValue			Bit = 0,
	@DistributeInfo		NVarChar(2000) = 'null#null#null#null#null#null#null#null#null#null#null#null',
	@SortFields			NVarChar(100) = Null,
	@RepInfo			NVarChar(100) = '1@1@1',
	@ExtraParams		NVarChar(200) = '0@0@0@-1@-1@1000'
WITH ENCRYPTION
AS 
DECLARE @Eqal					NVarChar(2000);
DECLARE @StrSelect11			NVarChar(max);
DECLARE @StrSelect12			NVarChar(max);
DECLARE @StrSelect21			NVarChar(max);
DECLARE @StrSelect22			NVarChar(max);
DECLARE @StrFrom				NVarChar(max);
DECLARE @StrWhere				NVarChar(max);
DECLARE @AddedValueN			Bit;
DECLARE @chkTTMS				Bit;

DECLARE	@LangID	      		    Char(1);
DECLARE	@SessionNo				Int; -- برای حالت کدهای انتخابی
DECLARE	@ReportID               Int; -- برای حالت کدهای انتخابی

DECLARE @TransporterID			NVarChar(20);

DECLARE @Dist0					NVarChar(20); -- DriverID
DECLARE @Dist1					NVarChar(20); -- DistributerID1
DECLARE @Dist2					NVarChar(20); -- DistributerID2
DECLARE @Dist3					NVarChar(20); -- BaseDistributionProcessID
DECLARE @Dist4					NVarChar(20); -- BaseDistributionProcessNo
DECLARE @Dist5					NVarChar(20); -- BaseDistributionFiscalYear fr
DECLARE @Dist6					NVarChar(20); -- BaseDistributionSerialNo   fr
DECLARE @Dist7					NVarChar(20); -- BaseDistributionFiscalYear to
DECLARE @Dist8					NVarChar(20); -- BaseDistributionSerialNo   to
DECLARE @CustKind				VarChar(20);
DECLARE @UseVch2				bit;
DECLARE @Vch					varchar(20);
DECLARE @PriceFr				float(20);
DECLARE @PriceTo				float(20);
DECLARE @PureAmountWithOverFlow	VarChar(20);

DECLARE @Remain0				char(4);
DECLARE @Remain1				Bit;
DECLARE @Remain2				Bit;
DECLARE @Remain3				Bit;
DECLARE @Remain4				Bit;

DECLARE @Part1Start				Int;
DECLARE @Part2Start				Int;
DECLARE @Part3Start				Int;
DECLARE @Part4Start				Int;
DECLARE @Part1Len				Int;
DECLARE @Part2Len				Int;
DECLARE @Part3Len				Int;
DECLARE @Part4Len				Int;

DECLARE @SelectedGoods2			Int;

DECLARE @WithWageRate			Bit;
DECLARE @WithoutWageRate		Bit;
DECLARE @WageRateByContract		Bit;
DECLARE @onlyCurrancyInvoice    Bit;

DECLARE	@GoodsReciverID			INT

DECLARE @AcntWithTaxToll		Bit;
DECLARE @AcntWithoutTaxToll		Bit;
DECLARE @KotagNo				NVarChar(20);
DECLARE @KotagDate				Char(10);
DECLARE @AssessmentLocation		NVarChar(20);
DECLARE @ExitLocation			NVarChar(20);
DECLARE @TaxSerialNoFr			Int ;
DECLARE @TaxSerialNoTo			Int ;
DECLARE	@UserID					Int;
DECLARE	@UserIsAdmin			bit;
DECLARE @SelectedVisitor21		Int ;
DECLARE @SelectedVisitor22		Int ;
DECLARE @SelectedVisitor23		Int ;
DECLARE @SelectedVisitor24		Int ;
DECLARE @SelectedCustomerInfo	Int ;
DECLARE @DebitRemain			Bit ;
DECLARE @StrDebitRemain			NVarChar(max);
DECLARE @Sal_SpecialSale		bit=0;
DECLARE @FlockTypeField			NVarChar(2000);
DECLARE @StartLayerAcntRemain	int;
DECLARE @LenLayerAcntRemain		int;

DECLARE @chkRetail				bit;
DECLARE @chkIsOfficial			int;
BEGIN --============== S T A R T  C O D E ===================================================

	SET NOCOUNT ON;

	-- Init -------------------------------------------------
	IF (@RepInfo	Is Null)	SET @RepInfo = '1@1@1';
	IF (@ProcessNo	Is Null)	SET @ProcessNo = 1;
	IF (@DocStep	Is Null)	SET @DocStep = 0;
	If (@UseAmount  Is Null)    SET @UseAmount = 0;
	If (@ExtraParams Is Null)   SET @ExtraParams = '0@0@0@-1@-1@1000';

	IF (@DocDateFr	Is Null)	SET @DocDateFr = '@@@';
	IF (@DocDateTo	Is Null)	SET @DocDateTo = '@@@';
	IF (@DistributeInfo	Is Null)	SET @DistributeInfo = 'null#null#null#null#null#null';

	IF (@SelectedGoods Is Null)		SET @SelectedGoods = 0
	IF (@SelectedStore	Is Null)	SET @SelectedStore = 0
	IF (@SelectedStore2 Is Null)	SET @SelectedStore2 = 0
	IF (@SelectedAcnt1	Is Null)	SET @SelectedAcnt1 = 0
	IF (@SelectedAcnt2	Is Null)	SET @SelectedAcnt2 = 0
	IF (@SelectedAcnt3	Is Null)	SET @SelectedAcnt3 = 0
	IF (@SelectedAcnt4	Is Null)	SET @SelectedAcnt4 = 0
	IF (@SelectedOrders1 Is Null)	SET @SelectedOrders1 = 0
	IF (@SelectedOrders2 Is Null)	SET @SelectedOrders2 = 0
	IF (@SelectedOrders3 Is Null)	SET @SelectedOrders3 = 0
	IF (@SelectedOrders4 Is Null)	SET @SelectedOrders4 = 0
	IF (@SelectedVisitor1 Is Null)	SET @SelectedVisitor1 = 0
	IF (@SelectedVisitor2 Is Null)	SET @SelectedVisitor2 = 0
	IF (@SelectedVisitor3 Is Null)	SET @SelectedVisitor3 = 0
	IF (@SelectedVisitor4 Is Null)	SET @SelectedVisitor4 = 0

	IF (@FiscalYearFr Is Null)	SET @SerialNoFr = Null;
	IF (@FiscalYearTo Is Null)	SET @SerialNoTo = Null;
	IF (@SerialNoFr	Is Null)	SET @FiscalYearFr = Null;
	IF (@SerialNoTo	Is Null)	SET @FiscalYearTo = Null;

	IF (@DistributeInfo <> '')
	Begin
		SET @Dist0	= pub.funSplitString(@DistributeInfo, '#', 1);
		SET @Dist1	= pub.funSplitString(@DistributeInfo, '#', 3);
		SET @Dist2	= pub.funSplitString(@DistributeInfo, '#', 5);
		SET @Dist3	= pub.funSplitString(@DistributeInfo, '#', 7);
		SET @Dist4	= pub.funSplitString(@DistributeInfo, '#', 8);
		SET @Dist5	= pub.funSplitString(@DistributeInfo, '#', 9);
		SET @Dist6	= pub.funSplitString(@DistributeInfo, '#', 10);
		SET @Dist7	= pub.funSplitString(@DistributeInfo, '#', 11);
		SET @Dist8	= pub.funSplitString(@DistributeInfo, '#', 12);
	End
	Else
	Begin
		SET @Dist0	= 'null';
		SET @Dist1	= 'null';
		SET @Dist2	= 'null';
		SET @Dist3	= 'null'; 
		SET @Dist4	= 'null';
		SET @Dist5	= 'null';
		SET @Dist6	= 'null';
		SET @Dist7	= 'null';
		SET @Dist8	= 'null';
	End

	SET @LangID					= pub.funSplitString(@RepInfo, '@', 1);
	SET @SessionNo				= pub.funSplitString(@RepInfo, '@', 2);
	SET @ReportID				= pub.funSplitString(@RepInfo, '@', 3);
	SET @UserID					= pub.funSplitString(@RepInfo, '@', 4);
	SET @UserIsAdmin			= pub.funSplitString(@RepInfo, '@', 5);

	SET @CustKind               = LTrim(pub.funSplitString(@ExtraParams, '@', 1)); -- 1
	SET @PureAmountWithOverFlow = LTrim(pub.funSplitString(@ExtraParams, '@', 8)); -- 8
	SET @WithWageRate			= LTrim(pub.funSplitString(@ExtraParams, '@', 9)); -- 9
	SET @WithoutWageRate		= LTrim(pub.funSplitString(@ExtraParams, '@', 10)); -- 10
	SET @WageRateByContract		= LTrim(pub.funSplitString(@ExtraParams, '@', 11)); -- 11
    set @GoodsReciverID			= LTrim(pub.funSplitString(@ExtraParams, '@', 12)); -- 12
    SET @TransporterID			= LTrim(pub.funSplitString(@ExtraParams, '@', 14));--14
    SET @onlyCurrancyInvoice	= LTrim(pub.funSplitString(@ExtraParams, '@', 15));--15
    set @KotagNo				= LTrim(pub.funSplitString(@ExtraParams, '@', 18));
	set @KotagDate				= LTrim(pub.funSplitString(@ExtraParams, '@', 19));
	set @AssessmentLocation		= LTrim(pub.funSplitString(@ExtraParams, '@', 20));
	set @ExitLocation			= LTrim(pub.funSplitString(@ExtraParams, '@', 21));
	set @TaxSerialNoFr			= LTrim(pub.funSplitString(@ExtraParams, '@', 22));
	set @TaxSerialNoTo			= LTrim(pub.funSplitString(@ExtraParams, '@', 23));
	set @SelectedVisitor21		= LTrim(pub.funSplitString(@ExtraParams, '@', 24));
	set @SelectedVisitor22		= LTrim(pub.funSplitString(@ExtraParams, '@', 25));
	set @SelectedVisitor23		= LTrim(pub.funSplitString(@ExtraParams, '@', 26));
	set @SelectedVisitor24		= LTrim(pub.funSplitString(@ExtraParams, '@', 27));
	set @SelectedCustomerInfo	= LTrim(pub.funSplitString(@ExtraParams, '@', 28));
	set @DebitRemain			= LTrim(pub.funSplitString(@ExtraParams, '@', 29));

	set @chkRetail				= LTrim(pub.funSplitString(@ExtraParams, '@', 30));
	set @chkIsOfficial			= LTrim(pub.funSplitString(@ExtraParams, '@', 31));
	set @chkTTMS				= LTrim(pub.funSplitString(@ExtraParams, '@', 32));

	IF (@SelectedVisitor21 Is Null)	SET @SelectedVisitor21 = 0;
	IF (@SelectedVisitor22 Is Null)	SET @SelectedVisitor22 = 0;
	IF (@SelectedVisitor23 Is Null)	SET @SelectedVisitor23 = 0;
	IF (@SelectedVisitor24 Is Null)	SET @SelectedVisitor24 = 0;
	IF (@SelectedCustomerInfo Is Null)SET @SelectedCustomerInfo = 0;
	If (@chkIsOfficial Is Null)SET @chkIsOfficial = 0;

	begin try
		SET @SelectedGoods2 = cast(LTrim(pub.funSplitString(@ExtraParams, '@', 2)) as int); -- 2
	end try
	begin catch
		SET @SelectedGoods2 = 0;
	end catch

	SET @UseVch2 = LTrim(pub.funSplitString(@ExtraParams, '@', 3)); -- 3
	SET @PriceFr = LTrim(pub.funSplitString(@ExtraParams, '@', 4)); -- 4
	SET @PriceTo = LTrim(pub.funSplitString(@ExtraParams, '@', 5)); -- 5

	begin try
		SET @Remain0 = cast(LTrim(pub.funSplitString(@ExtraParams, '@', 6)) as int); -- 6
	end try
	begin catch
		SET @Remain0 = '1000';
	end catch

	SET @AcntWithTaxToll	 = cast(LTrim(pub.funSplitString(@ExtraParams, '@', 16)) as int); -- 16
	SET @AcntWithoutTaxToll  = cast(LTrim(pub.funSplitString(@ExtraParams, '@', 17)) as int); -- 17
	
	if (@Remain0 = '0000')	set @Remain0 = '1000';
	SET @Remain1 = Substring(@Remain0, 1, 1);
	SET @Remain2 = Substring(@Remain0, 2, 1);
	SET @Remain3 = Substring(@Remain0, 3, 1);
	SET @Remain4 = Substring(@Remain0, 4, 1);
	
	
	Select @StartLayerAcntRemain=acc.FunGetAcntInfoForRemain(2 )
	Select @LenLayerAcntRemain=acc.FunGetAcntInfoForRemain(3 )

	SELECT  @Sal_SpecialSale=SettingValue 	FROM pub.tblSettings 	WHERE SettingKey = 'Sal_SpecialSale'
	set @FlockTypeField=','''' Flocks '
	if (@Sal_SpecialSale='true')
	set @FlockTypeField=' ,isnull( stuff((
		select '', '', FlockTypeName +'' ''  + cast( Quantity as varchar(20) ) from sal.tblFlockDtl D
	    inner join  sal.tblFlockTypeDtl F  on D.FlockTypeID=F.FlockTypeID and LanguageID=1
		where SerialNo = (
		select top 1 isnull(SerialNo,0) from sal.tblFlockHdr  
		where AcntCode=substring(H.AcntCode,'+str(@StartLayerAcntRemain)+','+str(@LenLayerAcntRemain)+')  
		order by DocDate desc , SerialNo Desc 
		) 
		and  AcntCode=substring(H.AcntCode,'+str(@StartLayerAcntRemain)+','+str(@LenLayerAcntRemain)+') 

			for xml path('''')
		),1,1,''''),'''')  Flocks '

	begin try
		SET @AddedValueN = LTrim(pub.funSplitString(@ExtraParams, '@', 7)) ; -- 7
	end try
	begin catch
		SET @AddedValueN = 0;
	end catch

	SET		@Part1Start = 1;
	SELECT	@Part1Len = Layer1 + Layer2 + Layer3 + Layer4 + Layer5 + Layer6 + Layer7 + Layer8 + Layer9 
	FROM	pub.tblCodeLayer 
	WHERE	(TableName = 'acc.tblAcnt') AND (PartNumber = 1)

	SELECT	@Part2Start = @Part1Start + @Part1Len + 1;
	SELECT	@Part2Len = Layer1 + Layer2 + Layer3 + Layer4 + Layer5 + Layer6 + Layer7 + Layer8 + Layer9 
	FROM	pub.tblCodeLayer 
	WHERE	(TableName = 'acc.tblAcnt') AND (PartNumber = 2)

	SELECT	@Part3Start = @Part2Start + @Part2Len + 1;
	SELECT	@Part3Len = Layer1 + Layer2 + Layer3 + Layer4 + Layer5 + Layer6 + Layer7 + Layer8 + Layer9 
	FROM	pub.tblCodeLayer 
	WHERE	(TableName = 'acc.tblAcnt') AND (PartNumber = 3)

	SELECT	@Part4Start = @Part3Start + @Part3Len + 1;
	SELECT	@Part4Len = Layer1 + Layer2 + Layer3 + Layer4 + Layer5 + Layer6 + Layer7 + Layer8 + Layer9 
	FROM	pub.tblCodeLayer 
	WHERE	(TableName = 'acc.tblAcnt') AND (PartNumber = 4)
	
	declare @CountPartRemain tinyint
	SET @CountPartRemain=0;
	
	SET @Eqal = '1=1'

	IF (@Remain1 = 1)
		SET @CountPartRemain = @CountPartRemain + 1
	IF (@Remain2 = 1) AND @CountPartRemain = 1
		SET @CountPartRemain = @CountPartRemain + 1
	IF (@Remain3 = 1) AND @CountPartRemain = 2
		SET @CountPartRemain = @CountPartRemain + 1
	IF (@Remain4 = 1) AND @CountPartRemain = 3
		SET @CountPartRemain = @CountPartRemain + 1

	IF (select COUNT(*) from pub.tblCodeLayer where TableName='acc.tblAcnt' and Layer1>0) = @CountPartRemain
		BEGIN
				SET @Eqal = @Eqal + ' AND M.AcntCode=H.AcntCode'
		END
		ELSE
		BEGIN
			IF (@Remain1 = 1)
				SET @Eqal = @Eqal + ' AND Substring(M.AcntCode,' + LTrim(Str(@Part1Start)) + ',' + LTrim(Str(@Part1Len)) + ')=Substring(H.AcntCode,' + LTrim(Str(@Part1Start)) + ',' + LTrim(Str(@Part1Len)) + ')'
			IF (@Remain2 = 1)
				SET @Eqal = @Eqal + ' AND Substring(M.AcntCode,' + LTrim(Str(@Part2Start)) + ',' + LTrim(Str(@Part2Len)) + ')=Substring(H.AcntCode,' + LTrim(Str(@Part2Start)) + ',' + LTrim(Str(@Part2Len)) + ')'
			IF (@Remain3 = 1)
				SET @Eqal = @Eqal + ' AND Substring(M.AcntCode,' + LTrim(Str(@Part3Start)) + ',' + LTrim(Str(@Part3Len)) + ')=Substring(H.AcntCode,' + LTrim(Str(@Part3Start)) + ',' + LTrim(Str(@Part3Len)) + ')'
			IF (@Remain4 = 1)
				SET @Eqal = @Eqal + ' AND Substring(M.AcntCode,' + LTrim(Str(@Part4Start)) + ',' + LTrim(Str(@Part4Len)) + ')=Substring(H.AcntCode,' + LTrim(Str(@Part4Start)) + ',' + LTrim(Str(@Part4Len)) + ')'
		END	
---------------------------------------------------------

	-- Where Clause -----------------------------------------
	SET @StrWhere = ' H.ProcessID = ' + LTrim(Str(@ProcessID))

	If (@AddedValue = 1)
		SET @StrWhere = @StrWhere + ' AND H.TaxOverWorthCost > 0'
	If (@AddedValueN = 1)
		SET @StrWhere = @StrWhere + ' AND H.TaxOverWorthCost = 0'

	if (@CustKind <> '') and (@CustKind <> '0')
		Set @StrWhere = @StrWhere + ' AND (pub.funGetCustomerKindID(H.AcntCode) = ''' + @CustKind + ''')'

	If (@ProcessNo Is Not Null)
		SET @StrWhere = @StrWhere + ' AND H.ProcessNo = ' + LTrim(Str(@ProcessNo))
		
	IF (@TransporterID <> '')
		Set @StrWhere = @StrWhere + ' AND (H.TransporterID = ''' + Ltrim(@TransporterID) + ''')'

	If (@Dist0 <> 'null')
	begin
		if (@ProcessID = 100)
			SET @StrWhere = @StrWhere + ' AND
				 (SELECT isnull(H2.DriverID,'''')DriverID2 from inv.tblStorageDocsHdr H2
							WHERE H.BaseProcessID=H2.ProcessID
							and H.BaseSerialNo=H2.SerialNo
							and H.BaseProcessNo=H2.ProcessNo
							and H.BaseFiscalYear=H2.FiscalYear) = ''' + LTrim(@Dist0) + ''''
		else
			SET @StrWhere = @StrWhere + ' AND H.DriverID = ''' + LTrim(@Dist0) + ''''
	end
	
	If (@Dist1 <> 'null')
		SET @StrWhere = @StrWhere + ' AND H.DistributerID1 = ''' + LTrim(@Dist1) + ''''
	If (@Dist2 <> 'null')
		SET @StrWhere = @StrWhere + ' AND H.DistributerID2 = ''' + LTrim(@Dist2) + ''''

	If (@Dist5 <> 'null')
		SET @StrWhere = @StrWhere + ' AND H.BaseDistributionProcessID = ' + LTrim(@Dist3) + ' AND H.BaseDistributionProcessNo = ' + LTrim(@Dist4) + ' AND H.BaseDistributionFiscalYear = ' + LTrim(@Dist5) + ' AND H.BaseDistributionSerialNo >= ' + LTrim(@Dist6)
	If (@Dist7 <> 'null')
		SET @StrWhere = @StrWhere + ' AND H.BaseDistributionProcessID = ' + LTrim(@Dist3) + ' AND H.BaseDistributionProcessNo = ' + LTrim(@Dist4) + ' AND H.BaseDistributionFiscalYear = ' + LTrim(@Dist7) + ' AND H.BaseDistributionSerialNo <= ' + LTrim(@Dist8)
	If (@TaxSerialNoFr Is Not Null and @TaxSerialNoFr>0)
		SET @StrWhere = @StrWhere + ' AND H.TaxSerialNoInvoice >= ' + LTrim(Str(@TaxSerialNoFr)) + '' 
	If (@TaxSerialNoTo Is Not Null and @TaxSerialNoTo>0)
		SET @StrWhere = @StrWhere + ' AND H.TaxSerialNoInvoice <= ' + LTrim(Str(@TaxSerialNoTo)) + '' 
	
	If (@SerialNoFr Is Not Null)
		SET @StrWhere = @StrWhere + ' AND (H.FiscalYear > ' + LTrim(Str(@FiscalYearFr)) + ' OR (H.FiscalYear = ' + LTrim(Str(@FiscalYearFr)) + ' AND H.SerialNo >= ' + LTrim(Str(@SerialNoFr)) + '))' 
	If (@SerialNoTo Is Not Null)
		SET @StrWhere = @StrWhere + ' AND (H.FiscalYear < ' + LTrim(Str(@FiscalYearTo)) + ' OR (H.FiscalYear = ' + LTrim(Str(@FiscalYearTo)) + ' AND H.SerialNo <= ' + LTrim(Str(@SerialNoTo)) + '))' 

	IF (@DocDateFr Is Not Null) AND (@DocDateFr <> '@@@')
		SET @StrWhere = @StrWhere + ' AND ' + inv.funGetDateFilter(@DocDateFr, '>=', 'H.DocDate', 'H.DocDate2', 'H.DocDate3', 'H.DocDate4')
	IF (@DocDateTo Is Not Null) AND (@DocDateTo <> '@@@')
		SET @StrWhere = @StrWhere + ' AND ' + inv.funGetDateFilter(@DocDateTo, '<=', 'H.DocDate', 'H.DocDate2', 'H.DocDate3', 'H.DocDate4')

	if (@UseVch2 = 1)
		set @Vch = 'H.VchNo2'
	else
		set @Vch = 'H.VchNo'

	IF @KotagNo Is Not Null And @KotagNo <> ''
	 	    SET @StrWhere = @StrWhere + ' AND  KotagNo ='''+ @KotagNo +''''
	IF @KotagDate Is Not Null And @KotagDate <> ''
	 	    SET @StrWhere = @StrWhere + ' AND  KotagDate ='''+ @KotagDate +''''
	IF @AssessmentLocation Is Not Null And @AssessmentLocation <> ''
	 	    SET @StrWhere = @StrWhere + ' AND  AssessmentLocation ='''+ @AssessmentLocation +''''
	IF @ExitLocation Is Not Null And @ExitLocation <> ''
	 	    SET @StrWhere = @StrWhere + ' AND  ExitLocation ='''+ @ExitLocation +''''	    	 	    

	If (@VchNoFr Is Not Null) OR (@VchNoTo Is Not Null)
		If (@VchNoFr = @VchNoTo)
			SET @StrWhere = @StrWhere + ' AND ' + @Vch + '=' + LTrim(Str(@VchNoFr))
		Else
		Begin
			If (@VchNoFr Is Not Null)
				SET @StrWhere = @StrWhere + ' AND ' + @Vch + ' >= ' + LTrim(Str(@VchNoFr))
			If (@VchNoTo Is Not Null)
				SET @StrWhere = @StrWhere + ' AND ' + @Vch + ' <= ' + LTrim(Str(@VchNoTo))
		End

	If (@SelectedGoods > 0)
		SET @StrWhere = @StrWhere + ' AND ' + pub.funGetFilterString(@SessionNo, @ReportID, @SelectedGoods, 'H.ProductID') 
	If (@SelectedStore > 0)
		SET @StrWhere = @StrWhere + ' AND ' + pub.funGetFilterString(@SessionNo, @ReportID, @SelectedStore, 'H.StoreID') 
	If (@SelectedStore2 > 0)
		SET @StrWhere = @StrWhere + ' AND ' + pub.funGetFilterString(@SessionNo, @ReportID, @SelectedStore2, 'H.StoreID2')

	If (@SelectedOrders1 > 0)
		SET @StrWhere = @StrWhere + ' AND ' + pub.funGetFilterString(@SessionNo, @ReportID, @SelectedOrders1, 'H.OrderAcntCode') 
	If (@SelectedOrders2 > 0)
		SET @StrWhere = @StrWhere + ' AND ' + pub.funGetFilterString(@SessionNo, @ReportID, @SelectedOrders2, 'H.OrderAcntCode') 
	If (@SelectedOrders3 > 0)
		SET @StrWhere = @StrWhere + ' AND ' + pub.funGetFilterString(@SessionNo, @ReportID, @SelectedOrders3, 'H.OrderAcntCode') 
	If (@SelectedOrders4 > 0)
		SET @StrWhere = @StrWhere + ' AND ' + pub.funGetFilterString(@SessionNo, @ReportID, @SelectedOrders4, 'H.OrderAcntCode')

	If (@SelectedVisitor1 > 0)
		SET @StrWhere = @StrWhere + ' AND (' + pub.funGetFilterString(@SessionNo, @ReportID, @SelectedVisitor1, 'H.VisitorAcntCode') + ')'
	If (@SelectedVisitor2 > 0)
		SET @StrWhere = @StrWhere + ' AND (' + pub.funGetFilterString(@SessionNo, @ReportID, @SelectedVisitor2, 'H.VisitorAcntCode') + ')'
	If (@SelectedVisitor3 > 0)
		SET @StrWhere = @StrWhere + ' AND (' + pub.funGetFilterString(@SessionNo, @ReportID, @SelectedVisitor3, 'H.VisitorAcntCode') + ')'
	If (@SelectedVisitor4 > 0)
		SET @StrWhere = @StrWhere + ' AND (' + pub.funGetFilterString(@SessionNo, @ReportID, @SelectedVisitor4, 'H.VisitorAcntCode') + ')'
	IF (@SelectedVisitor21 > 0)
		SET @StrWhere = @StrWhere + ' AND (' + pub.funGetFilterString(@SessionNo, @ReportID, @SelectedVisitor21, 'H.VisitorAcntCode2') + ')'
	IF (@SelectedVisitor22 > 0)
		SET @StrWhere = @StrWhere + ' AND (' + pub.funGetFilterString(@SessionNo, @ReportID, @SelectedVisitor22, 'H.VisitorAcntCode2') + ')'
	IF (@SelectedVisitor23 > 0)
		SET @StrWhere = @StrWhere + ' AND (' + pub.funGetFilterString(@SessionNo, @ReportID, @SelectedVisitor23, 'H.VisitorAcntCode2') + ')'
	IF (@SelectedVisitor24 > 0)
		SET @StrWhere = @StrWhere + ' AND (' + pub.funGetFilterString(@SessionNo, @ReportID, @SelectedVisitor24, 'H.VisitorAcntCode2') + ')'
	
	IF (@SelectedCustomerInfo > 0)
		SET @StrWhere = @StrWhere + ' AND (' + pub.funGetFilterString(@SessionNo, @ReportID, @SelectedCustomerInfo, 'H.OrderAcntCode') + ')'
	
	If @SaleTypeID Is Not Null
		Set @StrWhere = @StrWhere + ' AND (H.SaleTypeID = ''' + @SaleTypeID + ''')'

	If (@DocStep > 0)
		if @ProcessID = 55
			Set @StrWhere = @StrWhere + ' AND H.DocStep = ' + LTrim(Str(@DocStep))
		else
			Set @StrWhere = @StrWhere + ' AND H.DocStep >= ' + LTrim(Str(@DocStep))

	-- Acnt Filter 
	If (@SelectedAcnt1 > 0)
		SET @StrWhere = @StrWhere + ' AND ' + pub.funGetFilterString(@SessionNo, @ReportID, @SelectedAcnt1, 'H.AcntCode')
	If (@SelectedAcnt2 > 0)
		SET @StrWhere = @StrWhere + ' AND ' + pub.funGetFilterString(@SessionNo, @ReportID, @SelectedAcnt2, 'H.AcntCode')
	If (@SelectedAcnt3 > 0)
		SET @StrWhere = @StrWhere + ' AND ' + pub.funGetFilterString(@SessionNo, @ReportID, @SelectedAcnt3, 'H.AcntCode')
	If (@SelectedAcnt4 > 0)
		SET @StrWhere = @StrWhere + ' AND ' + pub.funGetFilterString(@SessionNo, @ReportID, @SelectedAcnt4, 'H.AcntCode')

	If (@DocDescMask Is Not Null)
		Set @StrWhere = @StrWhere + ' AND (Replace(H.DocDesc, '' '', '''') LIKE N''%' + RTrim(Replace(@DocDescMask, ' ', '')) + '%'')'
	
	
	if (@GoodsReciverID > 0) 
		SET @StrWhere = @StrWhere + ' AND ' + pub.funGetFilterString(@SessionNo, @ReportID, @GoodsReciverID, 'H.GoodsReciverID')
	
	if(@onlyCurrancyInvoice = 1 )
		SET @StrWhere = @StrWhere + 'AND H.CurrencyTypeID<>'''' ' 
			
	IF (@AcntWithTaxToll = 1 And @AcntWithoutTaxToll = 0)
		Set @StrWhere = @StrWhere + ' And F.AcntContainTax = 1 '		
		
	IF (@AcntWithoutTaxToll = 1 And @AcntWithTaxToll = 0)
		Set @StrWhere = @StrWhere + ' And F.AcntContainTax = 0 '

	If @chkIsOfficial = 2
		Set @StrWhere = @StrWhere + ' AND (H.IsOfficial = 0)'	
	If @chkIsOfficial = 1
		Set @StrWhere = @StrWhere + ' AND (H.IsOfficial = 1)'		
	If @chkIsOfficial = 0
		Set @StrWhere = @StrWhere + ''

	IF (@chkTTMS = '0')
		Set @StrWhere = @StrWhere + ''	
	IF (@chkTTMS = '1')
		Set @StrWhere = @StrWhere + ' AND (H.NoSentTTMS = ' + LTrim(RTrim(str(@chkTTMS))) + ')'
	---------------------------------------------------------	
	BEGIN TRY
		DROP TABLE #tblAcntCode
		DROP TABLE #tblStoreID
		DROP TABLE #tblVisitorAcntCode
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
	
	Insert into  #tblVisitorAcntCode (VisitorAcntCode)	SELECT Distinct VisitorAcntCode	FROM inv.tblStorageDocsHdr
	Insert into  #tblAcntCode (AcntCode)				SELECT Distinct AcntCode		FROM inv.tblStorageDocsHdr
	Insert into  #tblStoreID (StoreID)					SELECT Distinct StoreID			FROM inv.tblStorageDocsHdr
	if @UserIsAdmin=0
	begin

		 exec pub.SpFilterByPermission2 '#tblAcntCode', 'AcntCode', 'acc.tblAcnt', @UserID;
		 exec pub.SpFilterByPermission2 '#tblVisitorAcntCode', 'VisitorAcntCode', 'acc.tblAcnt', @UserID;
		 exec pub.SpFilterByPermission2 '#tblStoreID', 'StoreID', 'inv.tblStores', @UserID;

		SET @StrWhere =  @StrWhere+
			' and H.AcntCode in (SELECT AcntCode FROM  #tblAcntCode ) ' +
			' and H.VisitorAcntCode in (SELECT VisitorAcntCode FROM  #tblVisitorAcntCode ) ' + 
			' and H.StoreID in (SELECT StoreID FROM  #tblStoreID ) '
	END

	-- FROM Clause ------------------------------------------
	Set @StrFrom = ''
	
	if (@SelectedGoods2 > 0)
		Set @StrFrom = @StrFrom + '
		INNER JOIN (
			select distinct ProcessID, ProcessNo, FiscalYear, SerialNo
			from inv.tblStorageDocsDtl D2
			where ' + pub.funGetFilterString(@SessionNo, @ReportID, @SelectedGoods2, 'D2.GoodsID') + ') T1 on T1.ProcessID = H.ProcessID and T1.ProcessNo = H.ProcessNo and T1.FiscalYear = H.FiscalYear and T1.SerialNo = H.SerialNo '
	---------------------------------------------------------
	-- SELECT Clause ----------------------------------------
	DECLARE @Prc AS VarChar(20);
	DECLARE @strGoodsAmount as varchar(200) = 'GoodsAmount'

	DECLARE @DocDate01 as VarChar(10)
	DECLARE @DocDate02 as VarChar(10)
	DECLARE @DocDate03 as VarChar(10)
	DECLARE @DocDate04 as VarChar(10)

	SELECT @DocDate01 = LTrim(pub.funSplitString(@DocDateTo, '@', 1));
	SELECT @DocDate02 = LTrim(pub.funSplitString(@DocDateTo, '@', 2));
	SELECT @DocDate03 = LTrim(pub.funSplitString(@DocDateTo, '@', 3));
	SELECT @DocDate04 = LTrim(pub.funSplitString(@DocDateTo, '@', 4));

	IF @DocDate01 IS NULL SET @DocDate01 = ''
	IF @DocDate02 IS NULL SET @DocDate02 = ''
	IF @DocDate03 IS NULL SET @DocDate03 = ''
	IF @DocDate04 IS NULL SET @DocDate04 = ''
	
	IF @DocDate01 <> ''
		SET @DocDateTo = @DocDate01
	
	IF @DocDate01 = '' and @DocDate02 <> ''
		SET @DocDateTo = @DocDate02

	IF @DocDate01 = '' and @DocDate02 = '' and @DocDate03 <> ''
		SET @DocDateTo = @DocDate03

	IF @DocDate01 = '' and @DocDate02 = '' and @DocDate03 = '' and @DocDate04 <> ''
		SET @DocDateTo = @DocDate04

			
	IF (@DocDateTo = '@@@') 
		SET @DocDateTo = ''

	SET @strGoodsAmount = LTRIM(RTrim((inv.funGoodsAmount(@DocDateTo))))

	IF (@UseAmount = 1)
		SET @Prc = @strGoodsAmount
	ELSE
		SET @Prc = 'GoodsPrice'

	SET @StrSelect11 = '
	SELECT	--H.*,
	H.ProcessID, H.ProcessNo, H.FiscalYear, H.SerialNo, H.FormulaNo, H.DocStep, H.DocDate, H.StoreID, H.StoreID2, H.AcntCode, H.VisitorAcntCode, H.OrderAcntCode, H.CurrencyTypeID, H.CurrencyRate, Amount, 
	DiscountPercent, Discount, Discount2, TotalLineDiscount, H.BaseProcessID, H.BaseProcessNo, H.BaseFiscalYear, H.BaseSerialNo, H.BaseDocType, VchNo, H.DocDesc, H.WageRate,
	CASE WHEN H.ProcessID = 80 THEN CASE WHEN D.GoodsQuantity = D.SubUnitQuantity THEN D.GoodsQuantity ELSE D.SubUnitQuantity END ELSE H.ProductCount END ProductCount, 
	CASE WHEN H.ProcessID = 80 THEN D.GoodsID ELSE ProductID END ProductID, H.AgreeNo,
	H.RecID, H.SessionNo, H.SaleTypeID, H.TransporterID,TransportationCost, PackingCost, TaxCost, VisitorCostAcntCode, H.VisitorPercent, VisitorCost, DiscountAcntCode, EarnestMoney, EarnestMoneyPercent, 
	EarnestMoneyAcntCode, H.BatchNo, TransportationCostAcntCode, Price, TaxOverWorthCost, VchNo2, IsConfirmed, SettlementDate, TransportationIncomeAcntCode, TransportationIncome, OtherCostAcntCode, 
	OtherIncomeAcntCode, OtherCost, OtherIncome, DocDate2, DocDate3, DocDate4, AfterSaleDiscount, AfterSaleDesc, AfterSaleVchNo, AfterSaleDate, 
	Case When H.OldSerialNo <> 0 Then H.OldSerialNo Else VH.OldSerialNo End as OldSerialNo, HardRecivable, IsAutoDoc, 
	AfterSaleDiscountAcntCode, VchDate, SessionNo2, SessionNo3, SessionNo4, SessionNo5, TollOverWorthCost, DriverID, DistributerID1, DistributerID2, BaseDistributionProcessID, BaseDistributionProcessNo, 
	BaseDistributionFiscalYear, H.BaseDistributionSerialNo, DestinationAddress, BaseSaleSerialNo, DistributeCostAcntCode, DistributeAcntCode, DistributePercent, DistributeAmount, 
	OwnerDocNo, FixCostAcntCode, FixCost, ConfirmReceipt, TransporterID2, CashAmount, ChequeAmount, H.Address, CCNo, CCDiscount, CCPrivilege, H.SourceSerialNo, H.SourceProcessNo, H.DailyUsesBranchID, 
	DiscountTaxOverWorth, ComssionCostPrice, BasculePrice, LaborPrice, TransportPrice, DailyUsesToDate, CostAcntCode, CostPercent, SgnSN1, SgnSN2, SgnSN3, SgnSN4, SgnSN5, IsSendInfo, IntTrnTypID, 
	BankID, BankAmnt, AwardAmnt, TrnID, C1, C2, C3, C4, C5, C6, IAToll, IATollCod, H, H.BSN, H.BRN, BankID2, BankAmnt2, CashID, CashAmnt, H.VisitorAcntCode2, VisitorCostAcntCode2, H.VisitorPercent2, 
	VisitorCost2, ReceiptType, EnterTime, TransportationType, CarNo, Count, Weight, BaseSendID, H.LoadWeight, H.EmptyWeight, TrukNo, ExitTime, ExtraField1, TransferSerialNo, FarmerID, PackingPrice, 
	H.UserPriceID, CurrencyDiscount, H.DescRetSaleID, HasNoReward, PayOffTypeID, GoodsReciverID, TTMSPayOffTypeID, TaxSerialNo, BranchSerialNo, KotagNo, KotagDate, AssessmentLocation, 
	ExitLocation, SubCustomerCode, Export, AllowProduce, Cash, Remain, BascolWeight, WasteWeight, PureWeight, PayWithOutCheque, PayWithCheque, SaleState, AddOverload, DocTime, Interval, BRDS, H.BranchID, 
	H.Shipment, CreditCardDiscount, Discount3, ConflictWeightSN, AutoDiscont2, AutoDiscont, AutoDiscontPercent, CreateSumVoucher, BaskulSerialNo, ForoushType, C7, C8, C9, C10, C11, C12, HasTaxSerialNo, 
	H.Tax_Type, H.SourceProcessID, H.SourceFiscalYear, H.PriceParvane, ProductSerialID, PSerialNo, NationalID, FmlParam1, DiscountPercent2, H.DocDesc2, SenderDepartmentID, BaseSettlementID, ModificationKind, 
	ScoreGet, ScoreUsed, DontControlSerialCount, ScoreGetLater, NetWeightHdr, GrossWeight, CurrencyValue, DeclaredCompanyName, HasNotPayOffDiscounts, AutoOrder, TransporterDate, TransporterID3, ContractNumber, 
	PackingCostPercent, H.LastUpdate, TransferAmountFor, NoSentTTMS, SendTaxToll, SendTaxTollState, CreateTime, ReferenceID, TaxID, BaseTaxID, TPEdited, TPContractNo, PayType, PayTypeCashAmount, 
	TPInp, GUID_SerialNo, TPCanceled, TaxID2, TPPriceBeforDiscount, TPPriceAfterDiscount, TPCanceledDate, SortSerialNo, SortProcessNo, TransportationKindID, NoSentSale2TTMS, IsOfficial, AccConfirmForOdoo, 
	HasNotPayTaxToll, HasNoDiscountDtl, TaxSerialNoInvoice, SidePriceSum,
	ISNULL((select CurrencyTypeName from pub.tblCurrencyTypesDtl CT where CT.CurrencyTypeID = H.CurrencyTypeID and LanguageID = ' + @LangID + '),'''') CurrencyTypeName,
	 S1.StoreName, ISNULL(S2.StoreName,'''') StoreName2,
	'
	SET @StrSelect12 = '
			pub.GetCodeName(H.VisitorAcntCode, ' + @LangID + ') AS VisitorAcntName,pub.GetCodeName(H.VisitorAcntCode2, ' + @LangID + ') AS VisitorAcntName2,
			pub.GetCodeName(H.AcntCode, ' + @LangID + ') AS AcntName, ' +
			Case When @PureAmountWithOverFlow = 1 Then '
			IsNull((
				SELECT SUM(A.AtomAmount)
				FROM inv.tblStorageDocsDtl A
				WHERE (A.ProcessID=H.ProcessID) AND (A.ProcessNo=H.ProcessNo) AND (A.FiscalYear=H.FiscalYear) AND (A.SerialNo=H.SerialNo)
			),0) + 
			IsNull((
				SELECT SUM(D.' + @Prc + ' * D.GoodsQuantity)
				FROM inv.tblStorageDocsDtl D
				WHERE D.ProcessID = H.ProcessID AND D.ProcessNo = H.ProcessNo AND D.FiscalYear = H.FiscalYear AND D.SerialNo = H.SerialNo
			),0) As PriceSum,' Else 
			
			'IsNull((
				SELECT SUM(D.' + @Prc + ' * D.GoodsQuantity)
				FROM inv.tblStorageDocsDtl D
				WHERE D.ProcessID = H.ProcessID AND D.ProcessNo = H.ProcessNo AND D.FiscalYear = H.FiscalYear AND D.SerialNo = H.SerialNo
			),0) As PriceSum, ' End + 		

			'IsNull((
				SELECT SUM (A.AtomAmount * A.GoodsQuantity)
				FROM inv.tblStorageDocsAtom A
				WHERE (A.ProcessID=H.ProcessID) 
				  AND (A.ProcessNo=H.ProcessNo) 
				  AND (A.FiscalYear=H.FiscalYear) 
				  AND (A.SerialNo=H.SerialNo)
			),0) As AtomSum,'
	if @DebitRemain='true'
		set @StrDebitRemain=' IsNull((
				SELECT	Sum(Debit-Credit) Debit 
				FROM	acc.tblVoucherDtl M INNER JOIN acc.tblVoucherHdr VH ON VH.SerialNo=M.SerialNo
				WHERE   VH.DocRegisterState>0 AND (' + @Eqal + ') AND 
						(M.DocDate<=H.VchDate AND Not (M.DocDate=H.VchDate AND M.SourceProcessID=H.ProcessID AND M.SourceProcessNo=H.ProcessNo AND M.SourceFiscalYear=H.FiscalYear AND M.SourceSerialNo>=H.SerialNo))
			),0) DebitRemain '
	else 
		set @StrDebitRemain=' 0 DebitRemain '
		
set @StrSelect21 ='
			pub.GetGoodsName(CASE WHEN H.ProcessID = 80 THEN D.GoodsID ELSE ProductID END,' + @LangID + ') ProductName,
			(select sum(GoodsQuantity) from inv.tblStorageDocsDtl D where D.ProcessID=H.ProcessID and D.ProcessNo=H.ProcessNo and D.FiscalYear=H.FiscalYear and D.SerialNo=H.SerialNo) as QtySum,
			ISNULL(TR.TransporterName,'''') TransporterName,LD.LocationName, F.Address1 + '' '' + F.Address2 AcntAddress, Tel, OtherTels, 
			cast(CASE WHEN H.LocationID<>'''' THEN  H.LocationID ELSE LD.LocationID END AS NVarChar (20)) as LocationID,
			cast(CASE WHEN F.EconomicalCode<>'''' THEN  F.EconomicalCode ELSE H.EconomicalCode END AS NVarChar (20)) as EconomicalCode,
			AcntComment, Address1, Address2, InitialGrad, CustomerFirstName, CustomerLastName, 
			cast(CASE WHEN  F.ZipCode<>'''' THEN F.ZipCode ELSE H.ZipCode END As NVarChar(20)) as ZipCode,
			CompanyRegisterNo, 
			cast(CASE WHEN  F.NationalIDNumber<>'''' THEN F.NationalIDNumber ELSE H.NationalIDNumber END As NVarChar(20)) as NationalIDNumber,
			Mobile, SMSMobile, OrganzationName, MaxDebitRemain, MaxReceivableRemain, DistributionPoint, AsnafID, Sequence Fax, Email, MemberDate, VisitPathID1, VisitPathID2,
			VisitPathID3, VisitPathID4, NationalIdentity, SaleCustomerType, BuyCustomerType, CustomerKindID, SalesRoomClass, SaleCash, TableauText, AcntContainTax, PersonType
			,'+@StrDebitRemain+@FlockTypeField+ ',
			IsNull((
				SELECT SUM(D.Wage * D.GoodsQuantity)
				FROM inv.tblStorageDocsDtl D
				WHERE D.ProcessID = H.ProcessID AND D.ProcessNo = H.ProcessNo AND D.FiscalYear = H.FiscalYear AND D.SerialNo = H.SerialNo
			),0) WageSum,
			case When DiscountTaxOverWorth =0 then  [Discount]+[Discount2]+[Discount3]+[TotalLineDiscount]
			else TaxOverWorthCost+TollOverWorthCost+[Discount]+[Discount2]+[Discount3]+[TotalLineDiscount] 
			end DiscountSum,	
			[AfterSaleDiscount]+[FixCost]+[VisitorCost]+[VisitorCost2]+[DistributeAmount]+ case When H.ProcessID =55 or H.ProcessID =100 then [TransportationIncome]+[OtherIncome] else [OtherCost]+[TransportationCost] end   AS DecreaseSum,
			[PackingCost]+[TaxCost]+[TaxOverWorthCost]+[TollOverWorthCost]+[IAToll]+ case When H.ProcessID =55 or H.ProcessID =100 then [OtherCost]+[TransportationCost]  else  [TransportationIncome]+[OtherIncome] end    AS IncreaseSum,ISNULL(DRS.DescRetSaleName,'''') DescRetSaleName,
			ISNULL(CI.CustomerInfoID,'''') LYL_CustomerInfoID,'+str(@chkRetail)+' checkRetail,ISNULL(CI.BirthDate,'''') LYL_BirthDate,ISNULL(CI.RegisterDate,'''') LYL_RegisterDate,ISNULL(CI.MobileNumber,'''') LYL_MobileNumber,
			ISNULL(CI.PhoneNumber,'''') LYL_PhoneNumber,ISNULL(CI.Gender,'''') LYL_Gender,ISNULL(CID.FirstName,'''') LYL_FirstName,ISNULL(CID.LastName,'''') LYL_LastName, 
			ISNULL(CID.Adress,'''') LYL_Adress,
			IsNull((SELECT STUFF (
						  (SELECT '', ''+IsNull(CAST(PH.SerialNo as NVarChar),'''')
						  FROM trs.tblPayHdr PH 
						  LEFT JOIN inv.tblStorageDocsHdr HP ON 
						 	PH.BaseProcessID = HP.ProcessID AND 
						  	PH.BaseProcessNo = HP.ProcessNo AND 
						  	PH.BaseFiscalYear = HP.FiscalYear AND 
						  	PH.BaseSerialNo = HP.SerialNo AND 
						  	PH.DebitCode = HP.AcntCode
						  LEFT JOIN inv.tblStorageDocsDtl D ON 
						 	D.ProcessID = HP.ProcessID AND 
						  	D.ProcessNo = HP.ProcessNo AND 
						  	D.FiscalYear = HP.FiscalYear AND 
						  	D.SerialNo = HP.SerialNo
						  WHERE H.SerialNo = PH.BaseSerialNo
						  GROUP BY PH.SerialNo
						  FOR XML PATH(''''),TYPE).value(''.'',''NVARCHAR(MAX)''),1,2,'''')),'''') as PaySerial
	'
	SET @StrSelect22 = '
	FROM inv.vwStorageDocsHdr H 
		 INNER JOIN (SELECT ROW_NUMBER()OVER(PARTITION BY ProcessID,ProcessNo,FiscalYear,SerialNo ORDER BY ProcessID,ProcessNo,FiscalYear,SerialNo,DocRowNo) R, * From inv.tblStorageDocsDtl) D ON H.ProcessID = D.ProcessID AND H.ProcessNo = D.ProcessNo AND H.FiscalYear = D.FiscalYear AND H.SerialNo = D.SerialNo AND D.R =1       
		 LEFT JOIN inv.tblStoresDtl S1 ON H.StoreID  = S1.StoreID AND S1.LanguageID = ' + @LangID + '
		 LEFT JOIN inv.tblStoresDtl S2 ON H.StoreID2 = S2.StoreID AND S2.LanguageID = ' + @LangID + '
		 LEFT JOIN sal.tblTransportersDtl TR ON TR.TransporterID = H.TransporterID AND TR.LanguageID = ' + @LangID + '
		 LEFT JOIN sal.tblDescRetSaleDtl DRS ON DRS.DescRetSaleID = H.DescRetSaleID AND DRS.LanguageID = ' + @LangID + '
		 LEFT JOIN lyl.tblCustomerInfo CI ON CI.CustomerInfoID = H.OrderAcntCode		
		 LEFT JOIN lyl.tblCustomerInfoDtl CID ON CID.CustomerInfoID = H.OrderAcntCode AND CID.LanguageID=' + @LangID + '
		 LEFT JOIN acc.tblVoucherHdr VH ON H.VchNo = VH.SerialNo
		 OUTER APPLY acc.funGetCodeInfo(H.AcntCode) F
		 LEFT JOIN pub.tblLocationsDtl LD ON LD.LocationID = F.LocationID ' + @StrFrom + '
	WHERE ' + @StrWhere
	
	if (@PriceFr <> -1) or (@PriceTo <> -1) 
	begin
		set @StrWhere = '(1 = 1)'

		if (@PriceFr <> -1)
			set @StrWhere = @StrWhere + ' AND (PriceSum + SidePriceSum >= ' + LTrim(Str(@PriceFr)) + ')'

		if (@PriceTo <> -1)
			set @StrWhere = @StrWhere + ' AND (PriceSum + SidePriceSum <= ' + LTrim(Str(@PriceTo)) + ')'
		
		set @StrSelect11 = 
		'SELECT T.* FROM (' + @StrSelect11+ @StrSelect12 + @StrSelect21 + @StrSelect22  + ') T WHERE ' + @StrWhere 
			-- SORT Clause ---------------------------------------------
		If (@SortFields Is Not Null)
			Set @StrSelect11 = @StrSelect11 + @StrSelect12 + ' 
		ORDER BY ' + @SortFields

	end
	ELSE
	BEGIN
		--	 SORT Clause ---------------------------------------------
		If (@SortFields Is Not Null)
			Set @StrSelect11 = @StrSelect11 + @StrSelect12 + @StrSelect21 + @StrSelect22 + ' 
		ORDER BY ' + @SortFields

	END
	------------------------------------------------------------

	------------------------------------------------------------
	--Select @StrSelect11
	-- RUN -----------------------------------------------------
	Print @StrSelect11;
	Exec sp_executesql @StrSelect11;
	------------------------------------------------------------
END
GO
