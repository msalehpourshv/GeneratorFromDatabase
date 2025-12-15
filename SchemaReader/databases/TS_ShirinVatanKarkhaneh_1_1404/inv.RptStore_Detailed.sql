USE TS_ShirinVatanKarkhaneh_1_1404
GO
SET ANSI_NULLS, QUOTED_IDENTIFIER ON
GO
-- =========== TS-QC:UPDATED ====================
-- Author		 : TakroSystem\Ahmadnejad
-- Create date   : 1386/02/19
-- Viewed By	 : 
-- Last Modified : 1390/08/17
-- Last Modifier : TakroSystem\Zia
-- Description	 : گزارش تفصیلی انبار برای یک کالا
-- ==============================================
Create PROCEDURE inv.RptStore_Detailed
	@ProcessID			Int= 55,
	@ProcessNo			Int = Null,
	@FiscalYearFr		Int = Null,
	@SerialNoFr			Int = Null,
	@FiscalYearTo		Int = Null,
	@SerialNoTo			Int = Null,
	@DocDateFr			VarChar(60) = Null,
	@DocDateTo			VarChar(60) = Null,
	@SelectedStore		Int = Null,
	@SelectedStore2		Int = Null,
	@SelectedGoods		Int = Null, -- انتخاب کالا
	@SelectedAcnt1		Int = Null, -- انتخاب طرف حساب
	@SelectedAcnt2		Int = Null,
	@SelectedAcnt3		Int = Null,
	@SelectedAcnt4		Int = Null,
	@SelectedVisitor1	Int = Null, -- انتخاب بازاریاب
	@SelectedVisitor2	Int = Null, 
	@SelectedVisitor3	Int = Null, 
	@SelectedVisitor4	Int = Null, 
	@DocStep			Int = 0,  -- مرحله
	@DistributeInfo		NVarChar(2000) = 'null#null#null#null#null#null#null#null#null#null#null#null',
	@RepOptions			VarChar(20) = '111011111',  -- bit array options
	@SortFields			NVarChar(100) = Null,
	@RepInfo			NVarChar(100) = '1@1@1',
	@ExtraParams		NVarChar(200) = ''

WITH ENCRYPTION
AS 
---- Declarations ---------------
DECLARE	@StrSelect		NVarChar(4000);
DECLARE	@StrFrom		NVarChar(4000);
DECLARE	@StrWhere		NVarChar(4000);
DECLARE	@StrQty			VarChar(2000);
DECLARE	@StrPrc			VarChar(2000);
DECLARE @StrPID		    VarChar(20);
DECLARE	@StrRetPID		VarChar(3);

DECLARE	@LangID			Char(1);
DECLARE	@SessionNo		Int; 
DECLARE	@ReportID		Int; 
DECLARE	@UserID		Int;
DECLARE	@UserIsAdmin bit;

DECLARE	@ShowQuantity	Bit;  -- شامل ستون موجودی
DECLARE	@ShowPrice		Bit;  -- شامل ستون قیمت
DECLARE	@ShowOverload	Bit;  -- شامل ستون سربار
DECLARE	@ShowAcntName	Bit;  -- شامل ستون نام حساب
DECLARE	@UseAmount		Bit;  -- Use Amount Filed Instead of Price
DECLARE	@DecReturn		Bit;  -- کسر برگشتیها
DECLARE @StrPrice		NVarChar(20);
DECLARE @PID1	bit;
DECLARE @PID2	bit;
DECLARE @PID3	bit;
declare @SelectedProds int;

DECLARE @CountFr	int;
DECLARE @CountTo	int;
DECLARE @AmountFr	bigint;
DECLARE @AmountTo	bigint;

DECLARE @Dist0		NVarChar(20); -- DriverID
DECLARE @Dist1		NVarChar(20); -- DistributerID1
DECLARE @Dist2		NVarChar(20); -- DistributerID2
DECLARE @Dist3		NVarChar(20); -- BaseDistributionProcessID
DECLARE @Dist4		NVarChar(20); -- BaseDistributionProcessNo
DECLARE @Dist5		NVarChar(20); -- BaseDistributionFiscalYear fr
DECLARE @Dist6		NVarChar(20); -- BaseDistributionSerialNo   fr
DECLARE @Dist7		NVarChar(20); -- BaseDistributionFiscalYear to
DECLARE @Dist8		NVarChar(20); -- BaseDistributionSerialNo   to
DECLARE @RowDesk	NVarChar(50);

DECLARE @CustKind	VarChar(20);

DECLARE @IsCurrency	Bit;
DECLARE @SH			NVarChar(50);
DECLARE @SD			NVarChar(50);

DECLARE @FilterByServices	Bit;
DECLARE	@HasSerial			Bit;
DECLARE	@FromExpireDate		Varchar(10);
DECLARE	@ToExpireDate		Varchar(10);
DECLARE @PrdBatchNoFr		NVarChar(20);
DECLARE @PrdBatchNoTo		NVarChar(20);
DECLARE @PrdSerialFr		NVarChar(20);
DECLARE @PrdSerialTo		NVarChar(20);
DECLARE	@GoodsID			Varchar(20);
DECLARE	@AcntCode			Varchar(20);
DECLARE @IsMultiplex		Bit;

BEGIN --============== S T A R T  C O D E ===================================================

	SET NOCOUNT ON;

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
	
	-- Init -------------------------------------------------------------------
	IF (@RepInfo	Is Null)	SET @RepInfo = '1@1@1'
	IF (@ProcessNo	Is Null)	SET @ProcessNo = 1
	IF (@RepOptions	Is Null)	SET @RepOptions = '110011111'
	IF (@DocStep	Is Null)	SET @DocStep = 0
	IF (@DistributeInfo	Is Null)	SET @DistributeInfo = 'null#null#null#null#null#null#null#null#null#null#null#null';

	IF (@DocDateFr	Is Null)	SET @DocDateFr = '@@@';
	IF (@DocDateTo	Is Null)	SET @DocDateTo = '@@@';

	IF (@SelectedGoods	Is Null)	SET @SelectedGoods = 0
	IF (@SelectedStore	Is Null)	SET @SelectedStore = 0
	IF (@SelectedStore2 Is Null)	SET @SelectedStore2 = 0
	IF (@SelectedAcnt1	Is Null)	SET @SelectedAcnt1 = 0
	IF (@SelectedAcnt2	Is Null)	SET @SelectedAcnt2 = 0
	IF (@SelectedAcnt3	Is Null)	SET @SelectedAcnt3 = 0
	IF (@SelectedAcnt4	Is Null)	SET @SelectedAcnt4 = 0
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

	SET @ShowQuantity	  = Substring(@RepOptions, 1, 1)
	SET @ShowPrice		  = Substring(@RepOptions, 2, 1)
	SET @ShowOverload	  = Substring(@RepOptions, 3, 1)
	SET @ShowAcntName	  = Substring(@RepOptions, 4, 1)
	SET @DecReturn		  = Substring(@RepOptions, 5, 1)
	SET @UseAmount		  = Substring(@RepOptions, 6, 1)
	SET @PID1			  = Substring(@RepOptions, 7, 1)
	SET @PID2			  = Substring(@RepOptions, 8, 1)
	SET @PID3			  = Substring(@RepOptions, 9, 1)
	SET @IsCurrency		  = Substring(@RepOptions, 11, 1)
	SET @FilterByServices = Substring(@RepOptions, 12, 1)
	
	SET @LangID		= pub.funSplitString(@RepInfo, '@', 1);
	SET @SessionNo	= pub.funSplitString(@RepInfo, '@', 2);
	SET @ReportID	= pub.funSplitString(@RepInfo, '@', 3);
	SET @UserID		= pub.funSplitString(@RepInfo, '@', 4);
	SET @UserIsAdmin= pub.funSplitString(@RepInfo, '@', 5);

	set @CountFr	= -1;
	set @CountTo	= -1;
	set @AmountFr	= -1;
	set @AmountTo	= -1;
	set @RowDesk	= '';

	SET @StrRetPID		 = '100'
	SET @CustKind		 = LTrim(pub.funSplitString(@ExtraParams, '@', 1));
	SET @CountFr		 = pub.funSplitString(@ExtraParams, '@', 2);
	SET @CountTo		 = pub.funSplitString(@ExtraParams, '@', 3);
	SET @AmountFr		 = pub.funSplitString(@ExtraParams, '@', 4);
	SET @AmountTo		 = pub.funSplitString(@ExtraParams, '@', 5);
	SET @RowDesk		 = pub.funSplitString(@ExtraParams, '@', 6);
	SET @SelectedProds   = pub.funSplitString(@ExtraParams, '@', 7);
	SET @HasSerial		 = LTrim(pub.funSplitString(@ExtraParams, '@', 8));
	SET @FromExpireDate	 = LTrim(pub.funSplitString(@ExtraParams, '@', 9));
	SET @ToExpireDate	 = LTrim(pub.funSplitString(@ExtraParams, '@', 10));
	SET @PrdBatchNoFr	 = LTrim(pub.funSplitString(@ExtraParams, '@', 11));
	SET @PrdBatchNoTo	 = LTrim(pub.funSplitString(@ExtraParams, '@', 12));
	SET @PrdSerialFr	 = LTrim(pub.funSplitString(@ExtraParams, '@', 13));
	SET @PrdSerialTo	 = LTrim(pub.funSplitString(@ExtraParams, '@', 14));
	SET @GoodsID		 = LTrim(pub.funSplitString(@ExtraParams, '@', 15));
	SET @AcntCode		 = LTrim(pub.funSplitString(@ExtraParams, '@', 16));
	SET @IsMultiplex	 = LTrim(pub.funSplitString(@ExtraParams, '@', 17));
				
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
	---------------------------------------------------------------------------
	-- Where Clause -----------------------------------------------------------
	Set @StrWhere = ' (D.ProcessID in (' + @StrPID + '))'

	If (@GoodsID<> '')
		SET @StrWhere = @StrWhere + ' AND (D.GoodsID =''' + LTrim(@GoodsID) + ''')'
	If (@AcntCode<> '')
		SET @StrWhere = @StrWhere + ' AND (SubString(D.AcntCode , acc.FunGetAcntInfoForRemain(2),acc.FunGetAcntInfoForRemain(3))=''' + LTrim(@AcntCode) + ''')'

	If (@RowDesk <> '')
		SET @StrWhere = @StrWhere + ' AND (D.DescDtl like N''%' + LTrim(@RowDesk) + '%'')'

	If (@CountFr <> -1)
		SET @StrWhere = @StrWhere + ' AND D.GoodsQuantity >= ' + LTrim(Str(@CountFr))
	If (@CountTo <> -1)
		SET @StrWhere = @StrWhere + ' AND D.GoodsQuantity <= ' + LTrim(Str(@CountTo))

	If (@AmountFr <> -1)
		SET @StrWhere = @StrWhere + ' AND D.GoodsPrice >= ' + LTrim(Str(@AmountFr))
	If (@AmountTo <> -1)
		SET @StrWhere = @StrWhere + ' AND D.GoodsPrice <= ' + LTrim(Str(@AmountTo))

	IF (@ProcessNo Is Not Null)
		SET @StrWhere = @StrWhere + ' AND (D.ProcessNo = ' + LTrim(Str(@ProcessNo)) + ')'

	if (@CustKind <> '')
		Set @StrWhere = @StrWhere + ' AND (pub.funGetCustomerKindID(D.AcntCode) = ''' + @CustKind + ''')'

	If (@Dist0 <> 'null')
		SET @StrWhere = @StrWhere + ' AND H.DriverID = ''' + LTrim(@Dist0) + ''''
	If (@Dist1 <> 'null')
		SET @StrWhere = @StrWhere + ' AND H.DistributerID1 = ''' + LTrim(@Dist1) + ''''
	If (@Dist2 <> 'null')
		SET @StrWhere = @StrWhere + ' AND H.DistributerID2 = ''' + LTrim(@Dist2) + ''''

	If (@Dist5 <> 'null')
		SET @StrWhere = @StrWhere + ' AND H.BaseDistributionProcessID = ' + LTrim(@Dist3) + ' AND H.BaseDistributionProcessNo = ' + LTrim(@Dist4) + ' AND H.BaseDistributionFiscalYear = ' + LTrim(@Dist5) + ' AND H.BaseDistributionSerialNo >= ' + LTrim(@Dist6)
	If (@Dist7 <> 'null')
		SET @StrWhere = @StrWhere + ' AND H.BaseDistributionProcessID = ' + LTrim(@Dist3) + ' AND H.BaseDistributionProcessNo = ' + LTrim(@Dist4) + ' AND H.BaseDistributionFiscalYear = ' + LTrim(@Dist7) + ' AND H.BaseDistributionSerialNo <= ' + LTrim(@Dist8)

	IF (@SerialNoFr Is Not Null)
		SET @StrWhere = @StrWhere + ' AND (D.FiscalYear > ' + LTrim(Str(@FiscalYearFr)) + ' OR (D.FiscalYear = ' + LTrim(Str(@FiscalYearFr)) + ' AND D.SerialNo >= ' + LTrim(Str(@SerialNoFr)) + '))' 

	IF (@SerialNoTo Is Not Null)
		SET @StrWhere = @StrWhere + ' AND (D.FiscalYear < ' + LTrim(Str(@FiscalYearTo)) + ' OR (D.FiscalYear = ' + LTrim(Str(@FiscalYearTo)) + ' AND D.SerialNo <= ' + LTrim(Str(@SerialNoTo)) + '))' 

	IF (@DocDateFr Is Not Null) AND (@DocDateFr <> '@@@')
		SET @StrWhere = @StrWhere + ' AND ' + inv.funGetDateFilter(@DocDateFr, '>=', 'H.DocDate', 'H.DocDate2', 'H.DocDate3', 'H.DocDate4')
	IF (@DocDateTo Is Not Null) AND (@DocDateTo <> '@@@')
		SET @StrWhere = @StrWhere + ' AND ' + inv.funGetDateFilter(@DocDateTo, '<=', 'H.DocDate', 'H.DocDate2', 'H.DocDate3', 'H.DocDate4')

	IF (@SelectedGoods > 0)
		SET @StrWhere = @StrWhere + ' AND ' + pub.funGetFilterString(@SessionNo, @ReportID, @SelectedGoods, 'D.GoodsID') 
	IF (@SelectedStore > 0)
		SET @StrWhere = @StrWhere + ' AND ' + pub.funGetFilterString(@SessionNo, @ReportID, @SelectedStore, 'D.StoreID') 
	IF (@SelectedStore2 > 0)
		SET @StrWhere = @StrWhere + ' AND ' + pub.funGetFilterString(@SessionNo, @ReportID, @SelectedStore2, 'D.StoreID2')
	IF (@SelectedProds > 0)
		SET @StrWhere = @StrWhere + ' AND ' + pub.funGetFilterString(@SessionNo, @ReportID, @SelectedProds, 'H.ProductID') 

	IF (@SelectedAcnt1 > 0)
		SET @StrWhere = @StrWhere + ' AND ' + pub.funGetFilterString(@SessionNo, @ReportID, @SelectedAcnt1, 'D.AcntCode')
	IF (@SelectedAcnt2 > 0)
		SET @StrWhere = @StrWhere + ' AND ' + pub.funGetFilterString(@SessionNo, @ReportID, @SelectedAcnt2, 'D.AcntCode')
	IF (@SelectedAcnt3 > 0)
		SET @StrWhere = @StrWhere + ' AND ' + pub.funGetFilterString(@SessionNo, @ReportID, @SelectedAcnt3, 'D.AcntCode')
	IF (@SelectedAcnt4 > 0)
		SET @StrWhere = @StrWhere + ' AND ' + pub.funGetFilterString(@SessionNo, @ReportID, @SelectedAcnt4, 'D.AcntCode')

	IF (@SelectedVisitor1 > 0)
		SET @StrWhere = @StrWhere + ' AND (' + pub.funGetFilterString(@SessionNo, @ReportID, @SelectedVisitor1, 'H.VisitorAcntCode') + ')'
	IF (@SelectedVisitor2 > 0)
		SET @StrWhere = @StrWhere + ' AND (' + pub.funGetFilterString(@SessionNo, @ReportID, @SelectedVisitor2, 'H.VisitorAcntCode') + ')'
	IF (@SelectedVisitor3 > 0)
		SET @StrWhere = @StrWhere + ' AND (' + pub.funGetFilterString(@SessionNo, @ReportID, @SelectedVisitor3, 'H.VisitorAcntCode') + ')'
	IF (@SelectedVisitor4 > 0)
		SET @StrWhere = @StrWhere + ' AND (' + pub.funGetFilterString(@SessionNo, @ReportID, @SelectedVisitor4, 'H.VisitorAcntCode') + ')'

	IF (@DocStep > 0)
		SET @StrWhere = @StrWhere + ' AND (D.DocStep = ' + LTrim(Str(@DocStep)) + ')'
		
	IF (@IsCurrency = 1)
		begin
			set @SH = 'inv.vwStorageHdr_Currency'
			set @SD = 'inv.vwStorageDtl_Currency'
		end
		else
		begin
			set @SH = 'inv.tblStorageDocsHdr'
			set @SD = 'inv.tblStorageDocsDtl'
		end
		
	IF (@FilterByServices = 1)
		Set @StrWhere = @StrWhere + ' And G.IsService = 1 '		

	------------------------------------------------------------
	-- Select Clause -------------------------------------------

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
	
	IF @IsMultiplex = 'False'
		Set @strGoodsAmount = 'GoodsAmount'
	ELSE
	BEGIN
		IF (@DocDateTo = '@@@') 
			SET @DocDateTo = ''

		SET @strGoodsAmount = LTRIM(RTrim((inv.funGoodsAmount(@DocDateTo))))
	END				

	IF (@UseAmount = 1)
		SET @StrPrice = @strGoodsAmount
	Else
		SET @StrPrice = 'GoodsPrice'

	IF (@DecReturn = 1)
	BEGIN
		SET @StrQty	= '(D.GoodsQuantity - 
							(
								SELECT	IsNull(SUM(GoodsQuantity), 0)
								FROM	' + @SD + ' 
								WHERE	ProcessID = ' + @StrRetPID + ' AND 
										ProcessNo = ' + Str(@ProcessNo) + ' AND 
										BaseProcessID = D.ProcessID AND 
										BaseProcessNo = D.ProcessNo AND 
										BaseFiscalYear = D.FiscalYear AND 
										BaseSerialNo = D.SerialNo AND 
										BaseDocRowNo = D.DocRowNo
							)
						)'
		SET @StrPrc	= '((D.GoodsQuantity * D.' + @StrPrice + ') - 
							(
								SELECT	IsNull(SUM(GoodsQuantity * ' + @StrPrice + '), 0)
								FROM	' + @SD + ' 
								WHERE	ProcessID = ' + @StrRetPID + ' AND 
										ProcessNo = ' + Str(@ProcessNo) + ' AND 
										BaseProcessID = D.ProcessID AND 
										BaseProcessNo = D.ProcessNo AND 
										BaseFiscalYear = D.FiscalYear AND 
										BaseSerialNo = D.SerialNo AND 
										BaseDocRowNo = D.DocRowNo
							)
						)'
	END
	ELSE
	BEGIN
		SET @StrQty	= 'D.GoodsQuantity'
		SET @StrPrc	= 'D.GoodsQuantity * D.' + @StrPrice 
	END

	begin try
		drop table ##tbl_Store_Detailed
	end try
	begin catch
	end catch

	SET @StrSelect = '
	SELECT *
	into ##tbl_Store_Detailed
	FROM
	(	
		SELECT	D.ProcessID, D.ProcessNo, D.FiscalYear, D.SerialNo, D.DocRowNo, D.DescDtl, H.DocDesc,H.TransporterID2, H.TransportationCost,H.TransportationIncome,H.VisitorAcntCode,
				D.VisitorPercent As DtlVisitorPercent, ((D.SubUnitQuantity * D.GoodsPrice) * D.VisitorPercent / 100) As DtlVisitorCost,
				D.GoodsID, [pub].[funGetGoodsName](D.GoodsID,' + LTrim(RTrim(@LangID)) + ') GoodsName,
                H.KotagNo , H.KotagDate , H.AssessmentLocation , H.ExitLocation , H.PriceParvane as PriceParvaneHdr,
				D.DocDate, D.StoreID, D.StoreID2, ' + @StrQty + ' Quantity, ' + @StrPrc + ' Price, D.AcntCode, D.' + @StrPrice + ' as UPrice,
				Cast(' + CASE WHEN (@ShowOverload = 1) THEN 'AtomAmount' Else '0' END + ' As Float) Overload, ' +
				CASE WHEN (@ShowAcntName = 1) THEN 'pub.GetCodeName(D.AcntCode, ' + @LangID + ')' Else 'CAST('''' AS NVarChar(50))' END + ' AcntName,
				(
					select isNull(sum(GoodsQuantity * EnterKind), 0) Balance
					from ' + @SD + '
					where (PhysicallyEffected = 1) and (GoodsID = D.GoodsID)
				) AS Balance,H.AgreeNo,
				IsNull(GS.SetPoint,0) As SetPoint, IsNull(GS.FitPoint,0) As FitPoint,inv.GetGoodsPlaceNameFromStore(GS.StoreID,GS.DocRowNo,1) RecDesc,
				D.StoreVariable1, D.StoreVariable2, D.Var1, D.Var2, D.Var3, D.Var4,ConstText1,ConstText2,ConstText3,ConstText4 , SubUnitID , SubUnitPrice				 
		FROM	' + @SD + ' D
					INNER JOIN ' + @SH + ' H ON H.ProcessID = D.ProcessID AND H.ProcessNo = D.ProcessNo AND H.FiscalYear = D.FiscalYear AND H.SerialNo = D.SerialNo
					
					LEFT JOIN inv.tblGoods G ON G.GoodsID = SUBSTRING(D.GoodsID,' + ltrim(rtrim(STR(@str_Goods+1))) + ',' + ltrim(rtrim(STR( @str_GoodsSum))) + ') AND G.PartNumber=' + ltrim(rtrim(STR(@UnitPart)))+ '
							
					LEFT  JOIN inv.tblGoodsStatusDtl GS ON GS.StoreID = D.StoreID And GS.GoodsID = D.GoodsID
		WHERE	' + @StrWhere + '
	) T '
	------------------------------------------------------------
	-- Sort Clause ---------------------------------------------
	IF @SortFields Is Not Null
	SET @StrSelect = @StrSelect + ' 
	ORDER BY ' + @SortFields
	------------------------------------------------------------
	-- Run -----------------------------------------------------
	print @StrSelect;
	Exec sp_executesql @StrSelect;
	
	if (@UserIsAdmin = 0)
	begin
		exec pub.SpFilterByPermission2 '##tbl_Store_Detailed', 'StoreID', 'inv.tblStores', @UserID;
		exec pub.SpFilterByPermission2 '##tbl_Store_Detailed', 'GoodsID', 'inv.tblGoods', @UserID;
		--exec pub.SpFilterByPermission2 '##tbl_Store_Detailed', 'AcntCode', 'acc.tblAcnt', @UserID;
	end
	
	SET @StrSelect =  'SELECT * ,
							  inv.funGetSubUnitFromGoodsQuantity(GoodsID,SubUnitID,Quantity) SubUnitQuantity 
					   FROM ##tbl_Store_Detailed'
	PRINT @StrSelect;
	Exec sp_executesql @StrSelect;
	------------------------------------------------------------
END
GO
