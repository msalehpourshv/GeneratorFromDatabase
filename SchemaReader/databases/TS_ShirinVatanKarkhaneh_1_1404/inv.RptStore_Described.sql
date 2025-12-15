USE TS_ShirinVatanKarkhaneh_1_1404
GO
SET ANSI_NULLS, QUOTED_IDENTIFIER ON
GO
-- =========== TS-QC:UPDATED ====================
-- Author		 : TakroSystem\Ahmadnejad
-- Creation Date : 1386/04/03
-- Viewed By	 : 
-- Last Modified : 1393/09/10
-- Last Modifier : TakroSystem\Hamid
-- Description	 : 
-- ==============================================
Create PROCEDURE [inv].[RptStore_Described]
	@ProcessID			Int = 90,  -- default is sale
	@ProcessNo			Int = Null,
	@FiscalYearFr		Int = Null,
	@SerialNoFr			Int = Null,
	@FiscalYearTo		Int = Null,
	@SerialNoTo			Int = Null,
	@VchNoFr			Int = Null,
	@VchNoTo			Int = Null,
	@DocDateFr			VarChar(60) = Null,
	@DocDateTo			VarChar(60) = Null,
	@SumPriceFr			float = Null,
	@SumPriceTo			float = Null,
	@SaleTypeID			VarChar(20) = Null, -- کد نوع فروش
	@DocDescMask		NVarChar(100) = Null, -- بخشی از شرح
	@DocStep			Int = 0,  -- مرحله
	@SelectedGoods		Int = 0, 
	@SelectedStore		Int = 0, 
	@SelectedStore2		Int = 0, 
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
	@DistributeInfo		NVarChar(2000) = 'null#null#null#null#null#null#null#null#null#null#null#null#null#null',
	@RepOptions			VarChar(50) = '1100011111111100010101011111', -- bit array options
	@RepInfo			NVarChar(100) = Null,
	@SortFields			NVarChar(100) = Null,
	@ExtraParams		NVarChar(2000) = Null
WITH ENCRYPTION
AS 
---- Declarations ---------------
DECLARE @StrSelect				NVarChar(Max);
DECLARE @StrSelect1				NVarChar(Max);
DECLARE @StrSelect2				NVarChar(Max);
DECLARE @StrSelect3				NVarChar(Max);
DECLARE @StrSelect4				NVarChar(Max);
DECLARE @StrFrom				NVarChar(Max);
DECLARE @StrFrom2				NVarChar(Max);
DECLARE @StrFrom3				NVarChar(Max);
DECLARE @StrFrom4				NVarChar(Max);
DECLARE @StrWhere				NVarChar(Max);
DECLARE @StrWhereSession		NVarChar(Max);
DECLARE @StrWhereDisc			NVarChar(Max);
DECLARE @StrOverload			NVarChar(2000);
DECLARE @StrOverloadCount		NVarChar(2000);
DECLARE @BaseDate				VarChar(10);
DECLARE @StrQty					VarChar(Max);
DECLARE @StrPrc					VarChar(2000);
DECLARE @StrRetPID				VarChar(3);
DECLARE @StrPID		    		VarChar(20);
DECLARE @StrDocDesc				NVarChar(600);
DECLARE @StrSaleAndRetsQTY		NVarChar(1000);
DECLARE @StrSaleAndRetsWhere	NVarChar(1000);

--print sysdatetime()

DECLARE @ShowQuantity		Bit;  -- شامل ستون مقدار
DECLARE @ShowPrice			Bit;  -- شامل ستون قیمت
DECLARE @ShowOverload		Bit;  -- شامل ستون سربار
DECLARE @ShowDesc			Bit;  -- شامل ستون شرح
DECLARE @DecReturn			Bit;  -- کسر برگشتیها
DECLARE @UseAmount			Bit;  -- Use Amount Filed Instead of Price
DECLARE @UseVchBy0			Bit;  
DECLARE @UseVchBy1			Bit;  
DECLARE @Discounted			bit;
DECLARE @DiscountedX		bit;
DECLARE @ShowSerials		bit;
DECLARE @VATY				bit;
DECLARE @VATN				bit;
DECLARE @PID1				bit;
DECLARE @PID2				bit;
DECLARE @PID3				bit;
DECLARE @SubUnitQty			Bit;

DECLARE @RefY				Bit;
DECLARE @RefN				Bit;
DECLARE @Rewd				Bit;

DECLARE	@LangID				Char(1);
DECLARE	@SessionNo			Int;
DECLARE	@ReportID			Int;
DECLARE	@UserID				Int;
DECLARE	@UserIsAdmin		bit;

DECLARE @Dist0				NVarChar(20); -- DriverID
DECLARE @Dist1				NVarChar(20); -- DistributerID1
DECLARE @Dist2				NVarChar(20); -- DistributerID2
DECLARE @Dist3				NVarChar(20); -- BaseDistributionProcessID
DECLARE @Dist4				NVarChar(20); -- BaseDistributionProcessNo
DECLARE @Dist5				NVarChar(20); -- BaseDistributionFiscalYear fr
DECLARE @Dist6				NVarChar(20); -- BaseDistributionSerialNo   fr
DECLARE @Dist7				NVarChar(20); -- BaseDistributionFiscalYear to
DECLARE @Dist8				NVarChar(20); -- BaseDistributionSerialNo   to
DECLARE @Dist9				NVarChar(20); -- WithoutDistributer
DECLARE @Dist10				NVarChar(20); -- WithDistributer
DECLARE @CustKind			VarChar(20);
DECLARE @Location			VarChar(20);
DECLARE @Location2			VarChar(20);
DECLARE @UserIDEx			VarChar(10);
DECLARE @SelectedProduct	int;
DECLARE @BatchNoFr			NVarChar(20);
DECLARE @BatchNoTo			NVarChar(20);
DECLARE @BatchNoGoodsFr		NVarChar(20);
DECLARE @BatchNoGoodsTo		NVarChar(20);
DECLARE @IsReward			int;
DECLARE @DescRetSale		int;

DECLARE @CardNo				VarChar(20);
DECLARE @RefDocFYFr			int;
DECLARE @RefDocSNFr			int;
DECLARE @RefDocFYTo			int;
DECLARE @RefDocSNTo			int;
DECLARE @BuyTypeID			varchar(20);
DECLARE @IsCurrency			Bit;
DECLARE @FilterByServices	Bit;
DECLARE @SH					NVarChar(50);
DECLARE @SD					NVarChar(50);
DECLARE @SerialsField		NVarChar(2000);
DECLARE @FlockTypeField		NVarChar(2000);
DECLARE @GoodsGroup			int;

DECLARE @ContractFYFr		int;
DECLARE @ContractSNFr		int;
DECLARE @ContractFYTo		int;
DECLARE @ContractSNTo		int;

DECLARE @TransporterID		NVarChar(20);
DECLARE @TransporterID2		NVarChar(20);
DECLARE @StoreVar1			float;
DECLARE @StoreVar2			float;
DECLARE @StoreVar3		    float;
DECLARE @StoreVar4			float;

DECLARE	@HasSerial			Bit;
DECLARE	@FromExpireDate		Varchar(10);
DECLARE	@ToExpireDate		Varchar(10);
DECLARE @PrdBatchNoFr		NVarChar(20);
DECLARE @PrdBatchNoTo		NVarChar(20);
DECLARE @PrdSerialFr		NVarChar(20);
DECLARE @PrdSerialTo		NVarChar(20);

DECLARE @bolSaleAndRet			Bit;
DECLARE @HaveCardDiscountNo		Bit;
DECLARE @Export					Bit;
DECLARE @DiscountTaxOverWorth	Bit;
DECLARE @NotPrintIsService		Bit;
DECLARE @GoodsWithTaxToll		Bit;
DECLARE @GoodsWithoutTaxToll	Bit;
DECLARE @WithTaxToll			Bit;
DECLARE @WithoutTaxToll			Bit;
DECLARE @AcntWithTaxToll		Bit;
DECLARE @AcntWithoutTaxToll		Bit;

DECLARE @AllContentsReturned	Bit;

DECLARE @WithWageRate			Bit;
DECLARE @WithoutWageRate		Bit;
DECLARE @WageRateByContract		Bit;

DECLARE @SaleRetsWithDiscounts	Bit;
DECLARE @SaleRetsWithTaxs		Bit;

DECLARE @DiscountPercentFrom	Float;
DECLARE @DiscountPercentTo		Float;
DECLARE @DiscountAmountFrom		Float;
DECLARE @DiscountAmountTo		Float;

-- ======
DECLARE @process_id					int;
DECLARE @process_no					int;
DECLARE @fiscal_year				int;
DECLARE @serial_no					int;
DECLARE @rowNo_no					int;
DECLARE @goods_id					Varchar(20);
DECLARE @goods_quantityGoodsOty		DECIMAL(28,9);
DECLARE @goods_quantitySubUnitQty	DECIMAL(28,9);

-- ======
DECLARE @unit_nameGoodsOty			nvarchar(200);
DECLARE @unit_idGoodsOty			varchar(20);
DECLARE @unit_valueGoodsOty			float;
DECLARE @unit_valueGoodsOty_Temp	float;
DECLARE @Mainunit_valueGoodsOty		float;
DECLARE @CntGoodsQty				INT;

DECLARE @unit_nameGoodsOty1			nvarchar(200);
DECLARE @unit_idGoodsOty1			varchar(20);
DECLARE @unit_valueGoodsOty1		float;
DECLARE @Mainunit_valueGoodsOty1	float;

DECLARE @unit_nameGoodsOty2			nvarchar(200);
DECLARE @unit_idGoodsOty2			varchar(20);
DECLARE @unit_valueGoodsOty2		float;
DECLARE @Mainunit_valueGoodsOty2	float;

DECLARE @MainAndSubUnit  bit;
DECLARE @GoodsReciverID  INT
DECLARE @DriverID	   	 VarChar(20);
DECLARE @AgreeNo		 NVarChar(20);

DECLARE @SelectedCampaign as int 
DECLARE @AcntPartNumberForRemainCalculation AS VarChar(10) 

DECLARE @FormulaBaseCalc as bit

DECLARE @StrUserPrice		NVarChar(1000);
DECLARE @StrUserPriceGrp	NVarChar(1000);

DECLARE @CustomerCode				 VarChar(20);
DECLARE @VisitPathID1			int;
DECLARE @VisitPathID2			int;
DECLARE @VisitPathID3			int;
DECLARE @VisitPathID4			int;
DECLARE @SalesRoomClass			int;

DECLARE @StartLayerAcntRemain		int;
DECLARE @LenLayerAcntRemain		int;
DECLARE @AcntGroupDoc1		Int ;
DECLARE @AcntGroupDoc2		Int ; 
DECLARE @AcntGroupDoc3		Int ; 
DECLARE @AcntGroupDoc4		Int ; 
DECLARE @KotagNo			NVarChar(20);
DECLARE @KotagDate			Char(10);
DECLARE @AssessmentLocation	NVarChar(20);
DECLARE @ExitLocation		NVarChar(20);
DECLARE @BuskulConflictWeight	Bit;
DECLARE @TaxSerialNoFr			Int ;
DECLARE @TaxSerialNoTo			Int ;	
DECLARE @SelectedVisitor21		Int ;
DECLARE @SelectedVisitor22		Int ;
DECLARE @SelectedVisitor23		Int ;
DECLARE @SelectedVisitor24		Int ;
DECLARE @SelectedDepartment		Int ;
DECLARE @SelectedCustomerInfo	Int ;
DECLARE @BoolFactorArzi			bit=0;
DECLARE @Sal_SpecialSale		bit=0;

DECLARE @chkRetail				bit;
DECLARE @chkTTMS				bit;
DECLARE @TempSerialNoFr			Int ;
DECLARE @TempSerialNoTo			Int ;	
DECLARE @TempFiscalYFr			Int ;
DECLARE @TempFiscalYTo			Int ;	
DECLARE @DocDescMaskAlt			NVarChar(100);
DECLARE @chkIsOfficial			int;
DECLARE @ShowSaleBasedBuys		int;

DECLARE @POFiscalYearFr			int;
DECLARE @POSerialNoFr			int;
DECLARE @POFiscalYearTo			int;
DECLARE @POSerialNoTo			int;

DECLARE @TOFiscalYearFr			int;
DECLARE @TOSerialNoFr			int;
DECLARE @TOFiscalYearTo			int;
DECLARE @TOSerialNoTo			int;
DECLARE @AllSaleRet				Bit;
DECLARE @IsMultiplex			Bit;

DECLARE @Inv_ShowBatchNo			Bit;
DECLARE @Prd_ProduceBatchNo			Bit;
Declare  @ProductCount2 as 	NVarChar(Max);

Begin --============== S T A R T  C O D E ===================================================

	SET NOCOUNT ON;

	-- ==========
	DECLARE @QuantityDecimalsToForms AS Int
	
	Select @StartLayerAcntRemain=acc.FunGetAcntInfoForRemain(2 )
	Select @LenLayerAcntRemain=acc.FunGetAcntInfoForRemain(3 )
	
	select @Inv_ShowBatchNo = SettingValue from pub.tblSettings	where SettingKey='Inv_ShowBatchNo'
	select @Prd_ProduceBatchNo = SettingValue from pub.tblSettings	where SettingKey='Prd_ProduceBatchNo'

	If @Inv_ShowBatchNo is null Set @Inv_ShowBatchNo = 'False'
	If @Prd_ProduceBatchNo is null Set @Prd_ProduceBatchNo = 'False'

	SELECT  @Sal_SpecialSale=SettingValue 	FROM pub.tblSettings 	WHERE SettingKey = 'Sal_SpecialSale'

	SET		@QuantityDecimalsToForms = 3
	SELECT  @QuantityDecimalsToForms=SettingValue 	FROM pub.tblSettings 	WHERE SettingKey = 'QuantityDecimalsToForms'

	--IF @QuantityDecimalsToForms>0
	--	SET		@QuantityDecimalsToForms = @QuantityDecimalsToForms - 1

	SET @AcntPartNumberForRemainCalculation = '1'		
	Select @AcntPartNumberForRemainCalculation = SettingValue	From pub.tblSettings	Where SettingKey = 'AcntPartNumberForRemainCalculation'
		  
	-- ===============================================
	Declare @sal_AggregateSimilarGoodsInRpt Bit;
	SET @sal_AggregateSimilarGoodsInRpt = 0

	SELECT @sal_AggregateSimilarGoodsInRpt = SettingValue	FROM pub.tblSettings	WHERE SettingKey = 'sal_AggregateSimilarGoodsInRpt'

	-- ==========
	Declare @sal_AggregateSimilarGoodsUPI Bit;
	SET @sal_AggregateSimilarGoodsUPI = 0

	SELECT @sal_AggregateSimilarGoodsUPI = SettingValue	FROM pub.tblSettings	WHERE SettingKey = 'sal_AggregateSimilarGoodsUPI'

	-- ==========
	Declare @sal_AggregateSimilarGoodsByPrice Bit;
	SET @sal_AggregateSimilarGoodsByPrice = 0

	SELECT @sal_AggregateSimilarGoodsByPrice = SettingValue	FROM pub.tblSettings	WHERE SettingKey = 'sal_AggregateSimilarGoodsByPrice'
		
	-- ==========
	Declare @Pub_UseGergorianDate Bit;
	SET @Pub_UseGergorianDate = 0

	SELECT @Pub_UseGergorianDate = SettingValue	FROM pub.tblSettings	WHERE SettingKey = 'Pub_UseGergorianDate'			  
			  
	DECLARE @SetDtlTaxAndToll BIT
	SET @SetDtlTaxAndToll = 'False'
	if @ProcessID=55 
		SELECT @SetDtlTaxAndToll = SettingValue	FROM pub.tblSettings	WHERE SettingKey = 'SetBuyDtlTaxAndToll'			  
	else
		SELECT @SetDtlTaxAndToll = SettingValue	FROM pub.tblSettings	WHERE SettingKey = 'SetDtlTaxAndToll'			  
	
	-- ==========
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
		--GoodsName					nvarchar(200) collate Arabic_CS_AS null,
		TotalQuantityGoodsOty		DECIMAL(28,9),
		TotalSubUnitGoodsOty		DECIMAL(28,9),
		UnitIDGoodsOty1				varchar(20) collate Arabic_CS_AS null,
		UnitNameGoodsOty1			nvarchar(20) collate Arabic_CS_AS null,
		TotalQuantityGoodsOty1		DECIMAL(28,9),
		UnitIDGoodsOty2				varchar(20) collate Arabic_CS_AS null,
		UnitNameGoodsOty2			nvarchar(20) collate Arabic_CS_AS null,
		TotalQuantityGoodsOty2		DECIMAL(28,9)
		--,
		--Weight						float,
		--Volume						float,
		--BarCode						varchar(20) collate Arabic_CS_AS null
	);

	-- ==========
	DECLARE @tbl_units as table
	(
		unit_idGoodsOty				varchar(20) not null, 
		unit_nameGoodsOty			nvarchar(200) not null, 
		unit_valueGoodsOty			float not null,
		Mainunit_valueGoodsOty		float not null,
		cntGoodsOty					int not null								
	);
	
	Create Table #tbl_TmpQty
	(
		ProcessID			int,
		ProcessNo			int,
		FiscalYear			int,
		SerialNo			int,
		RowNo				int,
		GoodsID				Varchar(20) collate Arabic_CS_AS null,
		GoodsQuantity		DECIMAL(28,9),
		SubUnitQuantity		DECIMAL(28,9),
		NoSentTTMS			bit
	);		

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
	
	-- Init -------------------------------------------------
	IF (@RepOptions Is Null)		SET @RepOptions = '110001111111110000';
	IF (@RepInfo Is Null)			SET @RepInfo = '1@1@1';
	IF (@ProcessNo Is Null)			SET @ProcessNo = 1;
	IF (@DocStep Is Null)			SET @DocStep = 0;
	IF (@DistributeInfo	Is Null)	SET @DistributeInfo = 'null#null#null#null#null#null#null#null#null#null#null#null#null';

	IF (@DocDateFr	Is Null)		SET @DocDateFr = '@@@';
	IF (@DocDateTo	Is Null)		SET @DocDateTo = '@@@';
	IF (@SelectedGoods Is Null)		SET @SelectedGoods = 0;
	IF (@SelectedStore Is Null)		SET @SelectedStore = 0;
	IF (@SelectedStore2 Is Null)	SET @SelectedStore2 = 0;
	IF (@SelectedAcnt1 Is Null)		SET @SelectedAcnt1 = 0;
	IF (@SelectedAcnt2 Is Null)		SET @SelectedAcnt2 = 0;
	IF (@SelectedAcnt3 Is Null)		SET @SelectedAcnt3 = 0;
	IF (@SelectedAcnt4 Is Null)		SET @SelectedAcnt4 = 0;
	IF (@SelectedOrders1 Is Null)	SET @SelectedOrders1 = 0;
	IF (@SelectedOrders2 Is Null)	SET @SelectedOrders2 = 0;
	IF (@SelectedOrders3 Is Null)	SET @SelectedOrders3 = 0;
	IF (@SelectedOrders4 Is Null)	SET @SelectedOrders4 = 0;
	IF (@SelectedVisitor1 Is Null)	SET @SelectedVisitor1 = 0;
	IF (@SelectedVisitor2 Is Null)	SET @SelectedVisitor2 = 0;
	IF (@SelectedVisitor3 Is Null)	SET @SelectedVisitor3 = 0;
	IF (@SelectedVisitor4 Is Null)	SET @SelectedVisitor4 = 0;

	IF (@FiscalYearFr Is Null)	SET @SerialNoFr = Null;
	IF (@FiscalYearTo Is Null)	SET @SerialNoTo = Null;
	IF (@SerialNoFr	Is Null)	SET @FiscalYearFr = Null;
	IF (@SerialNoTo	Is Null)	SET @FiscalYearTo = Null;
	SET @SelectedProduct = 0;

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
		SET @Dist9	= pub.funSplitString(@DistributeInfo, '#', 13);
		SET @Dist10	= pub.funSplitString(@DistributeInfo, '#', 14);
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
		SET @Dist9	= 'null';
		SET @Dist10	= 'null';
	End

	SET @LangID			 = pub.funSplitString(@RepInfo, '@', 1);
	SET @SessionNo		 = pub.funSplitString(@RepInfo, '@', 2);
	SET @ReportID		 = pub.funSplitString(@RepInfo, '@', 3);
	SET @UserID			 = pub.funSplitString(@RepInfo, '@', 4);
	SET @UserIsAdmin	 = pub.funSplitString(@RepInfo, '@', 5);

	SET @CustKind		 		= LTrim(pub.funSplitString(@ExtraParams, '@', 3)); 
	SET @Location		 		= LTrim(pub.funSplitString(@ExtraParams, '@', 4));
	SET @UserIDEx		 		= LTrim(pub.funSplitString(@ExtraParams, '@', 5));
	SET @SelectedProduct 		= LTrim(pub.funSplitString(@ExtraParams, '@', 6));
	SET @Location2		 		= LTrim(pub.funSplitString(@ExtraParams, '@', 7));
	SET @BatchNoFr		 		= LTrim(pub.funSplitString(@ExtraParams, '@', 8));
	SET @BatchNoTo		 		= LTrim(pub.funSplitString(@ExtraParams, '@', 9));
	SET @CardNo			 		= LTrim(pub.funSplitString(@ExtraParams, '@', 10));
	SET @RefDocFYFr		 		= LTrim(pub.funSplitString(@ExtraParams, '@', 11));
	SET @RefDocSNFr		 		= LTrim(pub.funSplitString(@ExtraParams, '@', 12));
	SET @RefDocFYTo		 		= LTrim(pub.funSplitString(@ExtraParams, '@', 13));
	SET @RefDocSNTo		 		= LTrim(pub.funSplitString(@ExtraParams, '@', 14));
	SET @BuyTypeID		 		= LTrim(pub.funSplitString(@ExtraParams, '@', 15));
	SET @TransporterID2	 		= LTrim(pub.funSplitString(@ExtraParams, '@', 16));
	SET @StoreVar1		 		= LTrim(pub.funSplitString(@ExtraParams, '@', 17));
	SET @HasSerial		 		= LTrim(pub.funSplitString(@ExtraParams, '@', 18));
	SET @FromExpireDate	 		= LTrim(pub.funSplitString(@ExtraParams, '@', 19));
	SET @ToExpireDate	 		= LTrim(pub.funSplitString(@ExtraParams, '@', 20));
	SET @PrdBatchNoFr	 		= LTrim(pub.funSplitString(@ExtraParams, '@', 21));
	SET @PrdBatchNoTo	 		= LTrim(pub.funSplitString(@ExtraParams, '@', 22));
	SET @PrdSerialFr	 		= LTrim(pub.funSplitString(@ExtraParams, '@', 23));
	SET @PrdSerialTo	 		= LTrim(pub.funSplitString(@ExtraParams, '@', 24));
	SET @bolSaleAndRet	 		= LTrim(pub.funSplitString(@ExtraParams, '@', 25));
	SET @ContractFYFr	 		= LTrim(pub.funSplitString(@ExtraParams, '@', 26));
	SET @ContractSNFr	 		= LTrim(pub.funSplitString(@ExtraParams, '@', 27));
	SET @ContractFYTo	 		= LTrim(pub.funSplitString(@ExtraParams, '@', 28));
	SET @ContractSNTo	 		= LTrim(pub.funSplitString(@ExtraParams, '@', 29));
	SET @BatchNoGoodsFr	 		= LTrim(pub.funSplitString(@ExtraParams, '@', 30));
	SET @BatchNoGoodsTo	 		= LTrim(pub.funSplitString(@ExtraParams, '@', 31));
	SET @IsReward		 		= LTrim(pub.funSplitString(@ExtraParams, '@', 32));
	SET @DescRetSale	 		= LTrim(pub.funSplitString(@ExtraParams, '@', 33));
	SET @DiscountPercentFrom 	= LTrim(pub.funSplitString(@ExtraParams, '@', 34));
	SET @DiscountPercentTo	 	= LTrim(pub.funSplitString(@ExtraParams, '@', 35));
	SET @DiscountAmountFrom	 	= LTrim(pub.funSplitString(@ExtraParams, '@', 36));
	SET @DiscountAmountTo	 	= LTrim(pub.funSplitString(@ExtraParams, '@', 37));
	SET @MainAndSubUnit			= LTrim(pub.funSplitString(@ExtraParams, '@', 38));
	SET @GoodsReciverID			= LTrim(pub.funSplitString(@ExtraParams, '@', 39));
	SET @AgreeNo				= LTrim(pub.funSplitString(@ExtraParams, '@', 40));
	SET @SelectedCampaign       = LTrim(pub.funSplitString(@ExtraParams, '@', 41));
	SET @TransporterID          = LTrim(pub.funSplitString(@ExtraParams, '@', 42));
	SET @DriverID				= LTrim(pub.funSplitString(@ExtraParams, '@', 43));
	SET @GoodsGroup		    	= LTrim(pub.funSplitString(@ExtraParams, '@', 44));
	set @FormulaBaseCalc        = LTrim(pub.funSplitString(@ExtraParams, '@', 46));
	set @CustomerCode	        = LTrim(pub.funSplitString(@ExtraParams, '@', 47));
	set @VisitPathID1	        = LTrim(pub.funSplitString(@ExtraParams, '@', 48));
	set @VisitPathID2	        = LTrim(pub.funSplitString(@ExtraParams, '@', 49));
	set @VisitPathID3	        = LTrim(pub.funSplitString(@ExtraParams, '@', 50));
	set @VisitPathID4	        = LTrim(pub.funSplitString(@ExtraParams, '@', 51));
	set @SalesRoomClass	        = LTrim(pub.funSplitString(@ExtraParams, '@', 52));
	set @sal_AggregateSimilarGoodsInRpt	        = LTrim(pub.funSplitString(@ExtraParams, '@', 53));
	set @sal_AggregateSimilarGoodsUPI	        = LTrim(pub.funSplitString(@ExtraParams, '@', 54));
	set @SubUnitQty				= LTrim(pub.funSplitString(@ExtraParams, '@', 55));
	set @AcntGroupDoc1			= LTrim(pub.funSplitString(@ExtraParams, '@', 56));
	set @AcntGroupDoc2			= LTrim(pub.funSplitString(@ExtraParams, '@', 57));
	set @AcntGroupDoc3			= LTrim(pub.funSplitString(@ExtraParams, '@', 58));
	set @AcntGroupDoc4			= LTrim(pub.funSplitString(@ExtraParams, '@', 59));
	set @KotagNo				= LTrim(pub.funSplitString(@ExtraParams, '@', 60));
	set @KotagDate				= LTrim(pub.funSplitString(@ExtraParams, '@', 61));
	set @AssessmentLocation		= LTrim(pub.funSplitString(@ExtraParams, '@', 62));
	set @ExitLocation			= LTrim(pub.funSplitString(@ExtraParams, '@', 63));
	set @TaxSerialNoFr			= LTrim(pub.funSplitString(@ExtraParams, '@', 64));
	set @TaxSerialNoTo			= LTrim(pub.funSplitString(@ExtraParams, '@', 65));
	set @SelectedVisitor21		= LTrim(pub.funSplitString(@ExtraParams, '@', 66));
	set @SelectedVisitor22		= LTrim(pub.funSplitString(@ExtraParams, '@', 67));
	set @SelectedVisitor23		= LTrim(pub.funSplitString(@ExtraParams, '@', 68));
	set @SelectedVisitor24		= LTrim(pub.funSplitString(@ExtraParams, '@', 69));
	set @SelectedDepartment		= LTrim(pub.funSplitString(@ExtraParams, '@', 70));
	SET @StoreVar2		 		= LTrim(pub.funSplitString(@ExtraParams, '@', 71));
	SET @StoreVar3		 		= LTrim(pub.funSplitString(@ExtraParams, '@', 72));
	SET @StoreVar4		 		= LTrim(pub.funSplitString(@ExtraParams, '@', 73));
	set @SelectedCustomerInfo	= LTrim(pub.funSplitString(@ExtraParams, '@', 74));

	set @chkRetail				= LTRIM(pub.funSplitString(@ExtraParams, '@', 75));
	set @chkTTMS				= LTRIM(pub.funSplitString(@ExtraParams, '@', 76));
	set @TempFiscalYFr			= LTRIM(pub.funSplitString(@ExtraParams, '@', 77));
	set @TempSerialNoFr			= LTRIM(pub.funSplitString(@ExtraParams, '@', 78));
	set @TempFiscalYTo			= LTRIM(pub.funSplitString(@ExtraParams, '@', 79));
	set @TempSerialNoTo			= LTRIM(pub.funSplitString(@ExtraParams, '@', 80));
	set @DocDescMaskAlt			= LTRIM(pub.funSplitString(@ExtraParams, '@', 81));
	set @chkIsOfficial			= LTRIM(pub.funSplitString(@ExtraParams, '@', 82));
	set @ShowSaleBasedBuys		= LTRIM(pub.funSplitString(@ExtraParams, '@', 84));
		
	set @POFiscalYearFr			= LTRIM(pub.funSplitString(@ExtraParams, '@', 85));
	set @POSerialNoFr			= LTRIM(pub.funSplitString(@ExtraParams, '@', 86));
	set @POFiscalYearTo			= LTRIM(pub.funSplitString(@ExtraParams, '@', 87));
	set @POSerialNoTo			= LTRIM(pub.funSplitString(@ExtraParams, '@', 88));

	set @TOFiscalYearFr			= LTRIM(pub.funSplitString(@ExtraParams, '@', 89));
	set @TOSerialNoFr			= LTRIM(pub.funSplitString(@ExtraParams, '@', 90));
	set @TOFiscalYearTo			= LTRIM(pub.funSplitString(@ExtraParams, '@', 91));
	set @TOSerialNoTo			= LTRIM(pub.funSplitString(@ExtraParams, '@', 92));
	set @IsMultiplex			= LTRIM(pub.funSplitString(@ExtraParams, '@', 93));
		
	IF (@SelectedVisitor21 Is Null)	SET @SelectedVisitor21 = 0;
	IF (@SelectedVisitor22 Is Null)	SET @SelectedVisitor22 = 0;
	IF (@SelectedVisitor23 Is Null)	SET @SelectedVisitor23 = 0;
	IF (@SelectedVisitor24 Is Null)	SET @SelectedVisitor24 = 0;
	IF (@SelectedDepartment Is Null)SET @SelectedDepartment = 0;
	IF (@SelectedCustomerInfo Is Null)SET @SelectedCustomerInfo = 0;
	If (@chkIsOfficial Is Null)SET @chkIsOfficial = 0;

	SET @ShowQuantity	= Substring(@RepOptions, 1, 1)
	SET @ShowPrice		= Substring(@RepOptions, 2, 1)
	SET @ShowOverload	= Substring(@RepOptions, 3, 1)
	SET @ShowDesc		= Substring(@RepOptions, 4, 1)
	SET @DecReturn		= Substring(@RepOptions, 5, 1)
	SET @UseAmount		= Substring(@RepOptions, 6, 1)
	SET @UseVchBy0		= Substring(@RepOptions, 7, 1)
	SET @UseVchBy1		= Substring(@RepOptions, 8, 1)
	SET @Discounted		= Substring(@RepOptions, 11, 1)
	SET @DiscountedX	= Substring(@RepOptions, 14, 1)
	SET @PID1			= Substring(@RepOptions, 15, 1)
	SET @PID2			= Substring(@RepOptions, 16, 1)
	SET @PID3			= Substring(@RepOptions, 17, 1)
	SET @VATY			= Substring(@RepOptions, 18, 1)
	SET @RefY			= Substring(@RepOptions, 19, 1)
	SET @RefN			= Substring(@RepOptions, 20, 1)
	SET @Rewd			= Substring(@RepOptions, 21, 1)
	-- 22 is used
	SET @VATN			= Substring(@RepOptions, 23, 1)
	SET @IsCurrency		= Substring(@RepOptions, 25, 1)
		-- 26,27 is used
	SET @FilterByServices	 	= Substring(@RepOptions, 27, 1)
	SET @ShowSerials		 	= Substring(@RepOptions, 28, 1)
	SET @HaveCardDiscountNo	 	= Substring(@RepOptions, 29, 1)
	SET @GoodsWithTaxToll	 	= Substring(@RepOptions, 30, 1)
	SET @GoodsWithoutTaxToll 	= Substring(@RepOptions, 31, 1)
	SET @AllContentsReturned 	= Substring(@RepOptions, 32, 1)
	SET @WithWageRate		 	= Substring(@RepOptions, 33, 1)
	SET @WithoutWageRate	 	= Substring(@RepOptions, 34, 1)
	SET @WageRateByContract	 	= Substring(@RepOptions, 35, 1)
	SET @SaleRetsWithDiscounts	= Substring(@RepOptions, 36, 1)
	SET @AcntWithTaxToll	 	= Substring(@RepOptions, 38, 1)
	SET @AcntWithoutTaxToll 	= Substring(@RepOptions, 39, 1)
	SET @Export				 	= Substring(@RepOptions, 40, 1)
	SET @BuskulConflictWeight	= Substring(@RepOptions, 41, 1)
	SET @DiscountTaxOverWorth	= Substring(@RepOptions, 42, 1)
	SET @NotPrintIsService		= Substring(@RepOptions, 43, 1)
	SET @BoolFactorArzi			= Substring(@RepOptions, 44, 1)
	SET @WithTaxToll	 		= Substring(@RepOptions, 45, 1)
	SET @WithoutTaxToll 		= Substring(@RepOptions, 46, 1)
	SET @AllSaleRet		 		= Substring(@RepOptions, 47, 1)	
	SET @SaleRetsWithTaxs		= Substring(@RepOptions, 48, 1)	

	SET @StrOverload = '0';

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

	IF (@ProcessID = 90) 
		SET @StrRetPID = '100'
	ELSE IF (@ProcessID = 55) 
		SET @StrRetPID = '60'
	ELSE
		SET @StrRetPID = '0'
	
	SET @BaseDate = Left(pub.funFarsiDate(GetDate()), 10)

	IF (@ProcessID = 70) or (@ProcessID = 80)
	BEGIN	
		IF (@PID1=0 and @PID2=0 and @PID3=0)
			SET @PID1 = 1
			
		SET @StrPID = '0';

		IF (@PID1 = 1)
			SET @StrPID = @StrPID + ',' + ltrim(str(@ProcessID));

		IF (@PID2 = 1)
			IF (@ProcessID = 70) 
				SET @StrPID = @StrPID + ',82' 
			ELSE
				SET @StrPID = @StrPID + ',72' 
			
		IF (@PID3 = 1)
			IF (@ProcessID = 70) 
				SET @StrPID = @StrPID + ',83' 
			ELSE
				SET @StrPID = @StrPID + ',73' 
	END
	ELSE 
		IF @bolSaleAndRet = 1
			SET @StrPID = '90, 100'
		Else
			SET @StrPID = LTRIM(STR(@ProcessID))
	---------------------------------------------------------
	--Print @bolSaleAndRet
	-- Where Clause -----------------------------------------
	SET @StrSelect = ''
	SET @StrSelect1 = ''
	SET @StrSelect2 = ''
	SET @StrSelect3 = ''
	SET @StrSelect4 = ''
	Set @StrWhere = ' D.ProcessID IN (' + @StrPID + ')'
	SET @StrWhereDisc = ''
	SET @StrWhereSession = ''

	IF (@BatchNoFr <> '')
		Set @StrWhere = @StrWhere + ' AND (H.BatchNo >= ''' + Ltrim(@BatchNoFr) + ''')'
	IF (@BatchNoTo <> '')
		Set @StrWhere = @StrWhere + ' AND (H.BatchNo <= ''' + Ltrim(@BatchNoTo) + ''')'

	IF (@BatchNoGoodsFr <> '')
		Set @StrWhere = @StrWhere + ' AND (D.BatchNo >= ''' + Ltrim(@BatchNoGoodsFr) + ''')'

	IF (@BatchNoGoodsTo <> '')
		Set @StrWhere = @StrWhere + ' AND (D.BatchNo <= ''' + Ltrim(@BatchNoGoodsTo) + ''')'

	IF not (@RefY = 1)
		set @StrWhere = @StrWhere + ' AND (D.BaseSerialNo = 0)'
	IF not (@RefN = 1)
		set @StrWhere = @StrWhere + ' AND (D.BaseSerialNo <> 0)'

	IF (@Rewd = 1)
		set @StrWhere = @StrWhere + ' AND ( select Count(*) from inv.tblStorageDocsDtl DD where  (DD.IsReward = 1 or DD.IsReward0 = 1) 
										and D.ProcessID=DD.ProcessID	and D.ProcessNo=DD.ProcessNo
											and D.FiscalYear=DD.FiscalYear and D.SerialNo=DD.SerialNo)>0 '
	IF (@Export = 1) and  (@VATY = 1)
			Set @StrWhere = @StrWhere + ' AND (H.TaxOverWorthCost > 0 OR H.Export=1 )'
	else IF (@Export = 1) and  (@VATY = 0)
			Set @StrWhere = @StrWhere + ' AND (H.Export=1 )'
	else IF (@Export = 0) and  (@VATY = 1)
			Set @StrWhere = @StrWhere + ' AND (H.TaxOverWorthCost > 0)'
	IF @BuskulConflictWeight=1
		Set @StrWhere = @StrWhere + ' AND (H.ConflictWeightSN <> 0)'			
	IF @DiscountTaxOverWorth=1
		Set @StrWhere = @StrWhere + ' AND (H.DiscountTaxOverWorth =1)'			
	IF (@VATN = 1)
		Set @StrWhere = @StrWhere + ' AND (H.TaxOverWorthCost = 0)'

	IF (@Discounted = 1)
		Set @StrWhere = @StrWhere + ' AND ((H.Discount+H.Discount2+H.Discount3+H.TotalLineDiscount) > 0)'

	IF (@DiscountedX = 1)
		Set @StrWhere = @StrWhere + ' AND (H.AfterSaleDiscount > 0)'

	IF (@CustKind <> '')
		Set @StrWhere = @StrWhere + ' AND (pub.funGetCustomerKindID(D.AcntCode) = ''' + @CustKind + ''')'

	IF (@Location <> '')
		Set @StrWhere = @StrWhere + ' AND (Left(H.LocationID, ' + str(len(@Location)) + ') >= ''' + @Location + ''')'
	IF (@Location2 <> '')
		Set @StrWhere = @StrWhere + ' AND (Left(H.LocationID, ' + str(len(@Location2)) + ') <= ''' + @Location2 + ''')'


    IF  @BoolFactorArzi=1
        Set @StrWhere=@StrWhere+'AND H.CurrencyTypeID<>'''' ' 

	IF (@DocStep > 0)
		Set @StrWhere = @StrWhere + ' AND D.DocStep = ' + LTrim(Str(@DocStep))
		
	IF @ProcessNo Is Not Null and @ProcessNo>0
		Set @StrWhere = @StrWhere + ' AND D.ProcessNo = ' + LTrim(Str(@ProcessNo))
		
	IF (@CardNo is not null) and (@CardNo <> '') 
		SET @StrWhere = @StrWhere + ' AND H.CCNo = ''' + LTrim(@CardNo) + ''''

	IF (@Dist0 <> 'null')
		SET @StrWhere = @StrWhere + ' AND H.DriverID = ''' + LTrim(@Dist0) + ''''
	IF (@Dist1 <> 'null')
		SET @StrWhere = @StrWhere + ' AND H.DistributerID1 = ''' + LTrim(@Dist1) + ''''
	IF (@Dist2 <> 'null')
		SET @StrWhere = @StrWhere + ' AND H.DistributerID2 = ''' + LTrim(@Dist2) + ''''

	IF (@Dist5 <> 'null')
		SET @StrWhere = @StrWhere + ' AND H.BaseDistributionProcessID = ' + LTrim(@Dist3) + ' AND H.BaseDistributionFiscalYear = ' + LTrim(@Dist5) + ' AND H.BaseDistributionSerialNo >= ' + LTrim(@Dist6)
	IF (@Dist7 <> 'null')
		SET @StrWhere = @StrWhere + ' AND H.BaseDistributionProcessID = ' + LTrim(@Dist3) + ' AND H.BaseDistributionFiscalYear = ' + LTrim(@Dist7) + ' AND H.BaseDistributionSerialNo <= ' + LTrim(@Dist8)

	IF ((@Dist9 <> 'null') And (@Dist9 <> '0') And (@Dist10 <> '')) And ((@Dist10 = 'null') Or (@Dist10 = '0') Or (@Dist9 = ''))
		SET @StrWhere = @StrWhere + ' AND (H.DistributerID1 = '''' AND H.DistributerID2 = '''')'
	IF ((@Dist10 <> 'null') And (@Dist10 <> '0') And (@Dist10 <> '')) And ((@Dist9 = 'null') Or (@Dist9 = '0') Or (@Dist9 = ''))
		SET @StrWhere = @StrWhere + ' AND (H.DistributerID1 <> '''' OR H.DistributerID2 <> '''')'		
	IF (@TaxSerialNoFr Is Not Null) And (@TaxSerialNoFr <> 0)
		Set @StrWhere = @StrWhere + ' AND H.TaxSerialNoInvoice >= ' + LTrim(Str(@TaxSerialNoFr)) + '' 
	IF (@TaxSerialNoTo Is Not Null) And (@TaxSerialNoTo <> 0)
		Set @StrWhere = @StrWhere + ' AND H.TaxSerialNoInvoice <= ' + LTrim(Str(@TaxSerialNoTo)) + '' 
		
	IF (@SerialNoFr Is Not Null) And (@SerialNoFr <> 0)
		Set @StrWhere = @StrWhere + ' AND (D.FiscalYear > ' + LTrim(Str(@FiscalYearFr)) + ' OR (D.FiscalYear = ' + LTrim(Str(@FiscalYearFr)) + ' AND D.SerialNo >= ' + LTrim(Str(@SerialNoFr)) + '))' 
	IF (@SerialNoTo Is Not Null) And (@SerialNoTo <> 0)
		Set @StrWhere = @StrWhere + ' AND (D.FiscalYear < ' + LTrim(Str(@FiscalYearTo)) + ' OR (D.FiscalYear = ' + LTrim(Str(@FiscalYearTo)) + ' AND D.SerialNo <= ' + LTrim(Str(@SerialNoTo)) + '))' 
	IF (@DocDateFr Is Not Null) AND (@DocDateFr <> '@@@')
		SET @StrWhere = @StrWhere + ' AND ' + inv.funGetDateFilter(@DocDateFr, '>=', 'H.DocDate', 'H.DocDate2', 'H.DocDate3', 'H.DocDate4')
	IF (@DocDateTo Is Not Null) AND (@DocDateTo <> '@@@')
		SET @StrWhere = @StrWhere + ' AND ' + inv.funGetDateFilter(@DocDateTo, '<=', 'H.DocDate', 'H.DocDate2', 'H.DocDate3', 'H.DocDate4')

	IF (@RefDocSNFr <> 0)
		Set @StrWhere = @StrWhere + ' AND (D.BaseFiscalYear > ' + LTrim(Str(@RefDocFYFr)) + ' OR (D.BaseFiscalYear = ' + LTrim(Str(@RefDocFYFr)) + ' AND D.BaseSerialNo >= ' + LTrim(Str(@RefDocSNFr)) + '))' 
	IF (@RefDocSNTo <> 0)
		Set @StrWhere = @StrWhere + ' AND (D.BaseFiscalYear < ' + LTrim(Str(@RefDocFYTo)) + ' OR (D.BaseFiscalYear = ' + LTrim(Str(@RefDocFYTo)) + ' AND D.BaseSerialNo <= ' + LTrim(Str(@RefDocSNTo)) + '))' 
	IF (@IsReward = 0)
		Set @StrWhere = @StrWhere + ' AND (D.IsReward = 0) ' 
	IF (@IsReward = 1)
		Set @StrWhere = @StrWhere + ' AND (D.IsReward = 1) ' 
	
	IF (@UseVchBy0 = 0)
		SET @StrWhere = @StrWhere + ' AND CASE WHEN D.BaseProcessID = 610 THEN 
										  (SELECT TOP 1 T.VchNo FROM pln.tblTaskOrderHdr T 
										   WHERE T.ProcessID = D.BaseProcessID and T.ProcessNo = D.BaseProcessNo and T.FiscalYear = D.BaseFiscalYear and T.SerialNo = D.BaseSerialNo ) 
										   ELSE H.VchNo END <> 0'
	IF (@UseVchBy1 = 0)
		SET @StrWhere = @StrWhere + ' AND CASE WHEN D.BaseProcessID = 610 THEN 
										  (SELECT TOP 1 T.VchNo FROM pln.tblTaskOrderHdr T 
										   WHERE T.ProcessID = D.BaseProcessID and T.ProcessNo = D.BaseProcessNo and T.FiscalYear = D.BaseFiscalYear and T.SerialNo = D.BaseSerialNo ) 
										   ELSE H.VchNo END = 0'

	IF (@VchNoFr Is Not Null) OR (@VchNoTo Is Not Null)
		IF (@VchNoFr = @VchNoTo)
			Set @StrWhere = @StrWhere + ' AND H.VchNo  = ' + LTrim(Str(@VchNoFr))
		Else
		Begin
			IF (@VchNoFr Is Not Null)
				Set @StrWhere = @StrWhere + ' AND H.VchNo >= ' + LTrim(Str(@VchNoFr))
			IF (@VchNoTo Is Not Null)
				Set @StrWhere = @StrWhere + ' AND H.VchNo <= ' + LTrim(Str(@VchNoTo))
		End

	IF @SaleTypeID Is Not Null And @SaleTypeID <> ''
		Set @StrWhere = @StrWhere + ' AND (D.SaleTypeID = ''' + @SaleTypeID + ''')'
	IF (@BuyTypeID <> '')
		Set @StrWhere = @StrWhere + ' AND (H.SaleTypeID = ''' + @BuyTypeID + ''')'
			
	IF @DocDescMask Is Not Null And @DocDescMask <> ''
		Set @StrWhere= @StrWhere+ ' and  ((H.DocDesc LIKE N''%' + @DocDescMask + '%'' OR D.DescDtl LIKE N''%' + @DocDescMask + '%''  OR isnull((SELECT top 1  DocDesc  FROM inv.tblStorageDocsHdr BH where  BH.ProcessID = D.BaseProcessID AND BH.ProcessNo = D.BaseProcessNo AND BH.FiscalYear = D.BaseFiscalYear AND BH.SerialNo = D.BaseSerialNo ),'''') LIKE N''%' + @DocDescMask + '%''  )'
	IF @DocDescMaskAlt Is Not Null And @DocDescMaskAlt <> ''
		Set @StrWhere= @StrWhere+ ' or  (H.DocDesc LIKE N''%' + @DocDescMaskAlt + '%'' OR D.DescDtl LIKE N''%' + @DocDescMaskAlt + '%''  OR isnull((SELECT top 1  DocDesc  FROM inv.tblStorageDocsHdr BH where  BH.ProcessID = D.BaseProcessID AND BH.ProcessNo = D.BaseProcessNo AND BH.FiscalYear = D.BaseFiscalYear AND BH.SerialNo = D.BaseSerialNo ),'''') LIKE N''%' + @DocDescMaskAlt + '%''  ))'

    IF @AgreeNo Is Not Null And @AgreeNo <> ''
		Set @StrWhere = @StrWhere + ' AND (H.AgreeNo  =''' + @AgreeNo + ''' )'
        
	if (@GoodsReciverID > 0) 
		SET @StrWhere = @StrWhere + ' AND ' + pub.funGetFilterString(@SessionNo, @ReportID, @GoodsReciverID, 'H.GoodsReciverID')
	--IF @DocDescMask Is Not Null
	--	Set @StrWhere = @StrWhere + ' AND (LC.CustomerInfoID LIKE ''' + @DocDescMask + '%'')'

	IF @DriverID Is Not Null And @DriverID <> ''
		Set @StrWhere = @StrWhere + ' AND (H.DriverID = ''' + @DriverID + ''')'

	IF (@DescRetSale > 0) And (@DescRetSale Is Not Null)
			SET @StrWhere = @StrWhere + ' AND ' + pub.funGetFilterString(@SessionNo, @ReportID, @DescRetSale, 'H.DescRetSaleID') 

	IF (@SelectedProduct > 0)
		IF (@ProcessID = 80 Or @ProcessID = 85)
			SET @StrWhere = @StrWhere + ' AND ' + pub.funGetFilterString(@SessionNo, @ReportID, @SelectedProduct, 'D.GoodsID') 
		Else
			SET @StrWhere = @StrWhere + ' AND ' + pub.funGetFilterString(@SessionNo, @ReportID, @SelectedProduct, 'H.ProductID') 

	IF (@SelectedGoods > 0)
	begin
		IF (@ProcessID = 80 Or @ProcessID = 85)
			begin
			if(@FormulaBaseCalc =1)
			begin
			       SET @StrWhere = @StrWhere + ' AND D.GoodsID in (Select ProductID from prd.tblFormulasDtl where ' + pub.funGetFilterString(@SessionNo, @ReportID, @SelectedGoods, 'GoodsID') +')' 
			   end
			 else
			   begin
			      SET @StrWhere = @StrWhere + ' AND D.SerialNo in (Select SerialNo from inv.tblStorageDocsDtl where ProcessID  = 70 and  ' + pub.funGetFilterString(@SessionNo, @ReportID, @SelectedGoods, 'GoodsID') +')' 
			   end
			end
		else
		begin
			SET @StrWhere = @StrWhere + ' AND ' + pub.funGetFilterString(@SessionNo, @ReportID, @SelectedGoods, 'D.GoodsID') 
			SET @StrWhereDisc = @StrWhereDisc + ' AND ' + pub.funGetFilterString(@SessionNo, @ReportID, @SelectedGoods, 'DD.GoodsID') 
		end
	end
	
	IF (@CustomerCode <> '') And (@CustomerCode Is Not Null)
		Set @StrWhere = @StrWhere + ' AND (D.CustomerCode = ''' + LTrim(RTrim(@CustomerCode)) + ''')'
	
	-- ======================================================
	IF (@SelectedStore > 0)
	begin
		SET @StrWhere = @StrWhere + ' AND ' + pub.funGetFilterString(@SessionNo, @ReportID, @SelectedStore, 'D.StoreID') 
		SET @StrWhereDisc = @StrWhereDisc + ' AND ' + pub.funGetFilterString(@SessionNo, @ReportID, @SelectedStore, 'DD.StoreID') 
	end
	
	IF (@SelectedStore2 > 0)
		SET @StrWhere = @StrWhere + ' AND ' + pub.funGetFilterString(@SessionNo, @ReportID, @SelectedStore2, 'D.StoreID2')
	IF (@SelectedDepartment > 0)
		SET @StrWhere = @StrWhere + ' AND ' + pub.funGetFilterString(@SessionNo, @ReportID, @SelectedDepartment, 'H.SenderDepartmentID')
	IF (@SelectedCustomerInfo > 0)
		SET @StrWhere = @StrWhere + ' AND ' + pub.funGetFilterString(@SessionNo, @ReportID, @SelectedCustomerInfo, 'H.OrderAcntCode')
		
	IF (@SelectedAcnt1 > 0)
		SET @StrWhere = @StrWhere + ' AND ' + pub.funGetFilterString(@SessionNo, @ReportID, @SelectedAcnt1, 'D.AcntCode')
	IF (@SelectedAcnt2 > 0)
		SET @StrWhere = @StrWhere + ' AND ' + pub.funGetFilterString(@SessionNo, @ReportID, @SelectedAcnt2, 'D.AcntCode')
	IF (@SelectedAcnt3 > 0)
		SET @StrWhere = @StrWhere + ' AND ' + pub.funGetFilterString(@SessionNo, @ReportID, @SelectedAcnt3, 'D.AcntCode')
	IF (@SelectedAcnt4 > 0)
		SET @StrWhere = @StrWhere + ' AND ' + pub.funGetFilterString(@SessionNo, @ReportID, @SelectedAcnt4, 'D.AcntCode')
	IF (@AcntGroupDoc1 > 0)
		SET @StrWhere = @StrWhere +  ' AND  RTrim(Substring(D.AcntCode, '+str(acc.funGetAcntLayerStartandLen(1,1))+', '+str(acc.funGetAcntLayerStartandLen(1,2))+')) IN (SELECT	DISTINCT AcntCode FROM	 acc.tblAcntGroupsDocDtl G WHERE PartNumber=1 and ' + pub.funGetFilterString(@SessionNo, @ReportID, @AcntGroupDoc1, 'G.AcntGroupID')+')'
	IF (@AcntGroupDoc2 > 0)
		SET @StrWhere = @StrWhere + ' AND  RTrim(Substring(D.AcntCode, '+str(acc.funGetAcntLayerStartandLen(2,1))+', '+str(acc.funGetAcntLayerStartandLen(2,2))+')) IN (SELECT	DISTINCT AcntCode FROM	 acc.tblAcntGroupsDocDtl G WHERE  PartNumber=2 and ' + pub.funGetFilterString(@SessionNo, @ReportID, @AcntGroupDoc2, 'G.AcntGroupID')+')'
	IF (@AcntGroupDoc3 > 0)
		SET @StrWhere = @StrWhere +  ' AND  RTrim(Substring(D.AcntCode, '+str(acc.funGetAcntLayerStartandLen(3,1))+', '+str(acc.funGetAcntLayerStartandLen(3,2))+')) IN (SELECT	DISTINCT AcntCode FROM	 acc.tblAcntGroupsDocDtl G WHERE  PartNumber=3 and ' + pub.funGetFilterString(@SessionNo, @ReportID, @AcntGroupDoc3, 'G.AcntGroupID')+')'
	IF (@AcntGroupDoc4 > 0)
		SET @StrWhere = @StrWhere + ' AND  RTrim(Substring(D.AcntCode, '+str(acc.funGetAcntLayerStartandLen(4,1))+', '+str(acc.funGetAcntLayerStartandLen(4,2))+')) IN (SELECT	DISTINCT AcntCode FROM	 acc.tblAcntGroupsDocDtl G WHERE  PartNumber=4 and ' + pub.funGetFilterString(@SessionNo, @ReportID, @AcntGroupDoc4, 'G.AcntGroupID')+')'

	IF (@SelectedOrders1 > 0)
		SET @StrWhere = @StrWhere + ' AND ' + pub.funGetFilterString(@SessionNo, @ReportID, @SelectedOrders1, 'D.OrderAcntCode') 
	IF (@SelectedOrders2 > 0)
		SET @StrWhere = @StrWhere + ' AND ' + pub.funGetFilterString(@SessionNo, @ReportID, @SelectedOrders2, 'D.OrderAcntCode') 
	IF (@SelectedOrders3 > 0)
		SET @StrWhere = @StrWhere + ' AND ' + pub.funGetFilterString(@SessionNo, @ReportID, @SelectedOrders3, 'D.OrderAcntCode') 
	IF (@SelectedOrders4 > 0)
		SET @StrWhere = @StrWhere + ' AND ' + pub.funGetFilterString(@SessionNo, @ReportID, @SelectedOrders4, 'D.OrderAcntCode')

	IF (@SelectedCampaign > 0)
	 	    SET @StrWhere = @StrWhere + ' AND  substring(H.AcntCode,'+str(@StartLayerAcntRemain)+','+str(@LenLayerAcntRemain)+') in (select AcntCode  from acc.tblAcnt where '+ pub.funGetFilterString(@SessionNo, @ReportID, @SelectedCampaign, 'CampaignID') +' ) '
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

	IF @KotagNo Is Not Null And @KotagNo <> ''
	 	    SET @StrWhere = @StrWhere + ' AND  KotagNo ='''+ @KotagNo +''''
	IF @KotagDate Is Not Null And @KotagDate <> ''
	 	    SET @StrWhere = @StrWhere + ' AND  KotagDate ='''+ @KotagDate +''''
	IF @AssessmentLocation Is Not Null And @AssessmentLocation <> ''
	 	    SET @StrWhere = @StrWhere + ' AND  AssessmentLocation ='''+ @AssessmentLocation +''''
	IF @ExitLocation Is Not Null And @ExitLocation <> ''
	 	    SET @StrWhere = @StrWhere + ' AND  ExitLocation ='''+ @ExitLocation +''''	    	 	    
	IF (@SelectedVisitor1 > 0)
		SET @StrWhere = @StrWhere + ' AND (' + pub.funGetFilterString(@SessionNo, @ReportID, @SelectedVisitor1, 'D.VisitorAcntCode') + ')'
	IF (@SelectedVisitor2 > 0)
		SET @StrWhere = @StrWhere + ' AND (' + pub.funGetFilterString(@SessionNo, @ReportID, @SelectedVisitor2, 'D.VisitorAcntCode') + ')'
	IF (@SelectedVisitor3 > 0)
		SET @StrWhere = @StrWhere + ' AND (' + pub.funGetFilterString(@SessionNo, @ReportID, @SelectedVisitor3, 'D.VisitorAcntCode') + ')'
	IF (@SelectedVisitor4 > 0)
		SET @StrWhere = @StrWhere + ' AND (' + pub.funGetFilterString(@SessionNo, @ReportID, @SelectedVisitor4, 'D.VisitorAcntCode') + ')'
	IF (@SelectedVisitor21 > 0)
		SET @StrWhere = @StrWhere + ' AND (' + pub.funGetFilterString(@SessionNo, @ReportID, @SelectedVisitor21, 'D.VisitorAcntCode2') + ')'
	IF (@SelectedVisitor22 > 0)
		SET @StrWhere = @StrWhere + ' AND (' + pub.funGetFilterString(@SessionNo, @ReportID, @SelectedVisitor22, 'D.VisitorAcntCode2') + ')'
	IF (@SelectedVisitor23 > 0)
		SET @StrWhere = @StrWhere + ' AND (' + pub.funGetFilterString(@SessionNo, @ReportID, @SelectedVisitor23, 'D.VisitorAcntCode2') + ')'
	IF (@SelectedVisitor24 > 0)
		SET @StrWhere = @StrWhere + ' AND (' + pub.funGetFilterString(@SessionNo, @ReportID, @SelectedVisitor24, 'D.VisitorAcntCode2') + ')'

	IF (@UserIDEx <> '' and @UserIDEx <> '-1')
		SET @StrWhereSession = @StrWhereSession + '(U.SessionNo = H.SessionNo)'
		--SET @StrWhere = @StrWhere + ' AND (U.SessionNo = H.SessionNo)'
		
	IF (@TransporterID <> '')
		Set @StrWhere = @StrWhere + ' AND (H.TransporterID = ''' + Ltrim(@TransporterID) + ''')'		
		
	IF (@TransporterID2 <> '')
		Set @StrWhere = @StrWhere + ' AND (H.TransporterID2 = ''' + Ltrim(@TransporterID2) + ''')'		

	IF (@StoreVar1 <> '0')
		Set @StrWhere = @StrWhere + ' AND (D.StoreVariable1 = ' + Ltrim(@StoreVar1) + ')'
	
	IF (@StoreVar2 <> '0')
		Set @StrWhere = @StrWhere + ' AND (D.StoreVariable2 = ' + Ltrim(@StoreVar2) + ')'
		
	IF (@StoreVar3 <> '0')
		Set @StrWhere = @StrWhere + ' AND (D.Var3 = ' + Ltrim(@StoreVar3) + ')'
		
	IF (@StoreVar4 <> '0')
		Set @StrWhere = @StrWhere + ' AND (D.Var4 = ' + Ltrim(@StoreVar4) + ')'	
		
	IF (@chkTTMS = '0')
		Set @StrWhere = @StrWhere + ' '	
	IF (@chkTTMS = '1')
		Set @StrWhere = @StrWhere + ' AND (H.NoSentTTMS = ' + LTrim(RTrim(str(@chkTTMS))) + ')'		

	IF (@ContractFYFr <> 0 AND @ContractSNFr<>0)
		Set @StrWhere = @StrWhere + ' AND (H.BaseFiscalYear > ' + LTrim(Str(@ContractFYFr)) + 
		' OR (H.BaseFiscalYear = ' + LTrim(Str(@ContractFYFr)) + '
		 AND H.BaseSerialNo >= ' + LTrim(Str(@ContractSNFr)) + '))' 
				
	IF (@ContractFYTo <> 0 AND @ContractSNTo<>0)
		Set @StrWhere = @StrWhere + ' AND (H.BaseFiscalYear < ' + LTrim(Str(@ContractFYFr))+ 
		' OR (H.BaseFiscalYear = ' + LTrim(Str(@ContractFYTo)) + ' 
		AND H.BaseSerialNo <= ' + LTrim(Str(@ContractSNTo)) + '))' 

	If @chkIsOfficial = 2
		Set @StrWhere = @StrWhere + ' AND (H.IsOfficial = 0)'	
	If @chkIsOfficial = 1
		Set @StrWhere = @StrWhere + ' AND (H.IsOfficial = 1)'		
	If @chkIsOfficial = 0
		Set @StrWhere = @StrWhere + ''
	-- ================================
	if (@IsCurrency = 1)
	begin
		if (@GoodsGroup > 0)
		begin
 			set @SH = 'inv.vwStorageHdr_Group_Currency'
			set @SD = 'inv.funStorageDtl_Group_Currency ('+ltrim(STR(@GoodsGroup))+')'
		end
		else
		begin
			set @SH = 'inv.vwStorageHdr_Currency'
			set @SD = 'inv.vwStorageDtl_Currency'		
		end		
	end
	else
	begin
		if (@GoodsGroup > 0)
		begin
 			set @SH = 'inv.vwStorageHdr_Group'
			set @SD = 'inv.funStorageDtl_Group ('+ltrim(STR(@GoodsGroup))+',0)'
		end
		else
		begin
			set @SH = 'inv.tblStorageDocsHdr'
			set @SD = 'inv.tblStorageDocsDtl'		
		end
	end

	if @TempSerialNoFr <>0 AND @TempSerialNoFr <>''
		Set @StrWhere = @StrWhere + ' AND (H.SourceFiscalYear > ' + LTrim(Str(@TempFiscalYFr)) + ' OR (H.SourceFiscalYear = ' + LTrim(Str(@TempFiscalYFr)) + ' AND H.SourceSerialNo >= ' + LTrim(Str(@TempSerialNoFr)) + '))' 
	else
		Set @StrWhere = @StrWhere + ''
	if @TempSerialNoTo <>0 AND @TempSerialNoTo <>''
		Set @StrWhere = @StrWhere + ' AND (H.SourceFiscalYear < ' + LTrim(Str(@TempFiscalYTo)) + ' OR (H.SourceFiscalYear = ' + LTrim(Str(@TempFiscalYTo)) + ' AND H.SourceSerialNo <= ' + LTrim(Str(@TempSerialNoTo)) + '))'
	else
		Set @StrWhere = @StrWhere + ''

	-- ================================
	IF (@HaveCardDiscountNo = 1)
		Set @StrWhere = @StrWhere + ' AND H.CCNo <> '''''
	
	IF (@FilterByServices = 1)
		Set @StrWhere = @StrWhere + ' And G.IsService = 1 '
	IF (@NotPrintIsService= 1)
		Set @StrWhere = @StrWhere + ' And G.IsService = 0 '
		
	IF (@GoodsWithTaxToll = 1 And @GoodsWithoutTaxToll = 0)
		Set @StrWhere = @StrWhere + ' And G.ContainTax = 1 '		
		
	IF (@GoodsWithoutTaxToll = 1 And @GoodsWithTaxToll = 0)
		Set @StrWhere = @StrWhere + ' And G.ContainTax = 0 '				

	IF (@WithTaxToll = 1 And @WithoutTaxToll = 0)
		Set @StrWhere = @StrWhere + ' And (D.TaxOverWorthCostDtl >0 or TollOverWorthCostDtl>0)  '		
		
	IF (@WithoutTaxToll = 1 And @WithTaxToll = 0)
		Set @StrWhere = @StrWhere + ' And  D.TaxOverWorthCostDtl =0 And TollOverWorthCostDtl=0  '				
	
	IF (@AcntWithTaxToll = 1 And @AcntWithoutTaxToll = 0)
		Set @StrWhere = @StrWhere + ' And F.AcntContainTax = 1 '		
		
	IF (@AcntWithoutTaxToll = 1 And @AcntWithTaxToll = 0)
		Set @StrWhere = @StrWhere + ' And F.AcntContainTax = 0 '
			
	IF @AllContentsReturned = 1
	BEGIN
		SET @StrSaleAndRetsQTY = '
			(Select SUM(GoodsQuantity) From inv.tblStorageDocsDtl Sale 
			 Where Sale.ProcessID = D.BaseProcessID And Sale.ProcessNo = D.BaseProcessNo And
				   Sale.FiscalYear = D.BaseFiscalYear And Sale.SerialNo = D.BaseSerialNo) As SaleQTY,
				   
			(Select SUM(GoodsQuantity) From inv.tblStorageDocsDtl Ret 
			 Where Ret.BaseProcessID = D.BaseProcessID And Ret.BaseProcessNo = D.BaseProcessNo And
				   Ret.BaseFiscalYear = D.BaseFiscalYear And Ret.BaseSerialNo = D.BaseSerialNo) As RetQTY, '
		
		SET @StrSaleAndRetsWhere = ' And SaleQTY = RetQTY '
	END
	ELSE
	BEGIN
		SET @StrSaleAndRetsQTY = ''
		SET @StrSaleAndRetsWhere = ''
	END
	
	IF (@WithWageRate = 1) AND (@WithoutWageRate = 0) AND (@WageRateByContract = 0)
		SET @StrWhere = @StrWhere + ' AND (D.WageRate <> 100)'
	IF (@WithWageRate = 0) AND (@WithoutWageRate = 1) AND (@WageRateByContract = 0)
		SET @StrWhere = @StrWhere + ' AND (D.WageRate = 100)'
	IF (@WithWageRate = 0) AND (@WithoutWageRate = 0) AND (@WageRateByContract = 1)		
		SET @StrWhere = @StrWhere + ' AND (D.WageRate = 101)'
	IF (@WithWageRate = 1) AND (@WithoutWageRate = 1) AND (@WageRateByContract = 0)
		SET @StrWhere = @StrWhere + ' AND (D.WageRate <> 101)'
	IF (@WithWageRate = 1) AND (@WithoutWageRate = 0) AND (@WageRateByContract = 1)
		SET @StrWhere = @StrWhere + ' AND (D.WageRate <> 100)'		
	IF (@WithWageRate = 0) AND (@WithoutWageRate = 1) AND (@WageRateByContract = 1)
		SET @StrWhere = @StrWhere + ' AND (D.WageRate = 100 OR D.WageRate = 101)'

	-- ==============================================
			
	IF @sal_AggregateSimilarGoodsUPI = 1
	Begin
		SET	@StrUserPrice    = 'ISNULL(UPI.UParams,'''') UserPrice'				
		SET	@StrUserPriceGrp = ', UPI.UParams'				
	End	
	Else
	Begin
		SET	@StrUserPrice    = '0 UserPrice'				
		SET	@StrUserPriceGrp = ''				
	End	
				
	-- ======================================================
	BEGIN TRY
	Drop Table ##tblSessionNo
	END TRY
	BEGIN CATCH 
	End CATCH
	
	Create Table ##tblSessionNo
	(
		SessionNo	Int
	)
	
	IF @UserIDEx Is Null OR @UserIDEx = ''
		SET @UserIDEx = '0'
			
	SET @StrSelect = '
	Insert Into ##tblSessionNo
	Select * From [' + pub.funGetBranchDBName() + '].[pub].[funSessionNoList2](' + IsNull(Ltrim(@UserIDEx),0) + ')'
	
	Print @StrSelect;
	Exec sp_executesql @StrSelect;		
	
	--Select * from ##tblSessionNo
	--print '##tblRets'
	--print sysdatetime()
	-- ======================================================
	BEGIN TRY
	Drop Table ##tblRets
	END TRY
	BEGIN CATCH 
	End CATCH
	
	Create Table ##tblRets
	(
		SameDate_Rets			  Float,
		AfterSale_Rets			  Float,
		AfterSale_RetsNoDateLimit Float,
		WithoutBaseDoc_Rets		  Float,
		WithBeforeDateSale		  Float,
		QtyWithoutBase			  Float,
		QtyWithBase				  Float,
		SaleRets_Sum			  Float
	)
	
	Insert Into  ##tblRets
	Exec [sal].[SPSaleReturn_Price1] @ProcessID, @ProcessNo, @FiscalYearFr, @SerialNoFr, 
									 @FiscalYearTo, @SerialNoTo, Null, @VchNoFr, @VchNoTo, @DocDateFr, @DocDateTo, 
									 @SaleTypeID, @SelectedGoods, @SelectedStore, @SelectedStore2, @SelectedAcnt1, @SelectedAcnt2, 
									 @SelectedAcnt3, @SelectedAcnt4, @SelectedOrders1,
									 @SelectedOrders2, @SelectedOrders3, @SelectedOrders4, @SelectedVisitor1, @SelectedVisitor2, 
									 @SelectedVisitor3, @SelectedVisitor4, @DistributeInfo, @SaleRetsWithDiscounts,@SaleRetsWithTaxs, 0, @RepInfo
 
	declare @strSaleReturn_Price2 nvarchar(max)
	
	SELECT 	@strSaleReturn_Price2 = sal.funSaleReturn_Price2(@ProcessID, @ProcessNo, @FiscalYearFr, @SerialNoFr, 
									 @FiscalYearTo, @SerialNoTo, Null, @VchNoFr, @VchNoTo, @DocDateFr, @DocDateTo, 
									 @SaleTypeID, @SelectedGoods, @SelectedStore, @SelectedStore2, @SelectedAcnt1, @SelectedAcnt2, 
									 @SelectedAcnt3, @SelectedAcnt4, @SelectedOrders1,
									 @SelectedOrders2, @SelectedOrders3, @SelectedOrders4, @SelectedVisitor1, @SelectedVisitor2, 
									 @SelectedVisitor3, @SelectedVisitor4, @DistributeInfo, @SaleRetsWithDiscounts, @SaleRetsWithTaxs, 1, 2, @RepInfo)


declare @tblAfterSale_Rets NVARCHAR(MAX)
SELECT @tblAfterSale_Rets =sal.funSaleReturn_Price2( @ProcessID, @ProcessNo, @FiscalYearFr, @SerialNoFr, 
									 @FiscalYearTo, @SerialNoTo, Null, @VchNoFr, @VchNoTo, @DocDateFr, @DocDateTo, 
									 @SaleTypeID, @SelectedGoods, @SelectedStore, @SelectedStore2, @SelectedAcnt1, @SelectedAcnt2, 
									 @SelectedAcnt3, @SelectedAcnt4, @SelectedOrders1,
									 @SelectedOrders2, @SelectedOrders3, @SelectedOrders4, @SelectedVisitor1, @SelectedVisitor2, 
									 @SelectedVisitor3, @SelectedVisitor4, @DistributeInfo, @SaleRetsWithDiscounts, @SaleRetsWithTaxs, 0, 3, @RepInfo)							 
	
	
	declare @tblAfterSale_RetsNoDateLimit NVARCHAR(MAX)
	SELECT @tblAfterSale_RetsNoDateLimit =[sal].funSaleReturn_Price2(@ProcessID, @ProcessNo, @FiscalYearFr, @SerialNoFr, 
									 @FiscalYearTo, @SerialNoTo, Null, @VchNoFr, @VchNoTo, @DocDateFr, @DocDateTo, 
									 @SaleTypeID, @SelectedGoods, @SelectedStore, @SelectedStore2, @SelectedAcnt1, @SelectedAcnt2, 
									 @SelectedAcnt3, @SelectedAcnt4, @SelectedOrders1,
									 @SelectedOrders2, @SelectedOrders3, @SelectedOrders4, @SelectedVisitor1, @SelectedVisitor2, 
									 @SelectedVisitor3, @SelectedVisitor4, @DistributeInfo, @SaleRetsWithDiscounts, @SaleRetsWithTaxs, 0, 4, @RepInfo)

	declare @tblWithoutBaseDoc_Rets NVARCHAR(MAX)
	SELECT @tblWithoutBaseDoc_Rets =[sal].funSaleReturn_Price2(@ProcessID, @ProcessNo, @FiscalYearFr, @SerialNoFr, 
									 @FiscalYearTo, @SerialNoTo, Null, @VchNoFr, @VchNoTo, @DocDateFr, @DocDateTo, 
									 @SaleTypeID, @SelectedGoods, @SelectedStore, @SelectedStore2, @SelectedAcnt1, @SelectedAcnt2, 
									 @SelectedAcnt3, @SelectedAcnt4, @SelectedOrders1,
									 @SelectedOrders2, @SelectedOrders3, @SelectedOrders4, @SelectedVisitor1, @SelectedVisitor2, 
									 @SelectedVisitor3, @SelectedVisitor4, @DistributeInfo, @SaleRetsWithDiscounts, @SaleRetsWithTaxs, 0, 6, @RepInfo)		
	
	declare @tblWithBeforeDateSale NVARCHAR(MAX)
	SELECT @tblWithBeforeDateSale =[sal].funSaleReturn_Price2(@ProcessID, @ProcessNo, @FiscalYearFr, @SerialNoFr, 
									 @FiscalYearTo, @SerialNoTo, Null, @VchNoFr, @VchNoTo, @DocDateFr, @DocDateTo, 
									 @SaleTypeID, @SelectedGoods, @SelectedStore, @SelectedStore2, @SelectedAcnt1, @SelectedAcnt2, 
									 @SelectedAcnt3, @SelectedAcnt4, @SelectedOrders1,
									 @SelectedOrders2, @SelectedOrders3, @SelectedOrders4, @SelectedVisitor1, @SelectedVisitor2, 
									 @SelectedVisitor3, @SelectedVisitor4, @DistributeInfo, @SaleRetsWithDiscounts, @SaleRetsWithTaxs, 0, 7, @RepInfo)


--1
Create Table #strSaleReturn_Price2
	(
		ProcessID					Int, 
		ProcessNo					Int,
		FiscalYear					Int,
		SerialNo					Int,
		DocRowNo					Int,	
		GoodsID						varchar(20) collate Arabic_CS_AS null,
		SameDateRetPrice			Float
	);
--2
Create Table #tblAfterSale_Rets
	(
		ProcessID					Int, 
		ProcessNo					Int,
		FiscalYear					Int,
		SerialNo					Int,
		DocRowNo					Int,	
		GoodsID						varchar(20) collate Arabic_CS_AS null,
		AfterSale_Rets				Float
	);
--3
Create Table #tblAfterSale_RetsNoDateLimit
	(
		ProcessID					Int, 
		ProcessNo					Int,
		FiscalYear					Int,
		SerialNo					Int,
		DocRowNo					Int,	
		GoodsID						varchar(20) collate Arabic_CS_AS null,
		AfterSale_RetsNoDateLimit	Float
	);
--4
Create Table #tblWithoutBaseDoc_Rets
	(
		ProcessID					Int, 
		ProcessNo					Int,
		FiscalYear					Int,
		SerialNo					Int,
		DocRowNo					Int,	
		GoodsID						varchar(20) collate Arabic_CS_AS null,
		WithoutBaseDoc_Rets			Float
	);
	--5
Create Table #tblWithBeforeDateSale
	(
		ProcessID					Int, 
		ProcessNo					Int,
		FiscalYear					Int,
		SerialNo					Int,
		DocRowNo					Int,	
		GoodsID						varchar(20) collate Arabic_CS_AS null,
		WithBeforeDateSale			Float
	);

--select @strSaleReturn_Price2									 
--select @tblAfterSale_Rets									 
--select @tblAfterSale_RetsNoDateLimit									 
--select @tblWithoutBaseDoc_Rets									 
--select @tblWithBeforeDateSale

	if @ProcessID<>110
	begin	
		SET @StrSelect = ' insert into #strSaleReturn_Price2 ' + @strSaleReturn_Price2
			Exec sp_executesql @StrSelect;
		SET @StrSelect = ' insert into #tblAfterSale_Rets ' + @tblAfterSale_Rets
			Exec sp_executesql @StrSelect;
		SET @StrSelect = ' insert into #tblAfterSale_RetsNoDateLimit ' + @tblAfterSale_RetsNoDateLimit
			Exec sp_executesql @StrSelect;
		SET @StrSelect = ' insert into #tblWithoutBaseDoc_Rets ' + @tblWithoutBaseDoc_Rets
			Exec sp_executesql @StrSelect;
		SET @StrSelect = ' insert into #tblWithBeforeDateSale ' + @tblWithBeforeDateSale
			Exec sp_executesql @StrSelect;
	end

	select @StrWhere=ISNULL(@StrWhere,' 1=1 ')

--return 									 
	---------------------------------------------------------
--	print 'tbl_TmpQty'
--print sysdatetime()
	-- =========================== 
	SET @StrSelect1 = 'Insert Into #tbl_TmpQty
					   Select D.ProcessID, D.ProcessNo, D.FiscalYear, D.SerialNo, D.RowNo, D.GoodsID, D.GoodsQuantity, D.SubUnitQuantity, H.NoSentTTMS
					   From ' + @SD + ' D
					   Inner Join ' + @SH + ' H ON H.ProcessID=D.ProcessID AND H.ProcessNo=D.ProcessNo AND H.FiscalYear=D.FiscalYear AND 
												   H.SerialNo = D.SerialNo
					   Left  Join inv.tblGoods G ON G.GoodsID = SUBSTRING(D.GoodsID,' + ltrim(rtrim(STR(@str_Goods+1))) + ',' + ltrim(rtrim(STR( @str_GoodsSum))) + ') AND G.PartNumber=' + ltrim(rtrim(STR(@UnitPart)))+ '
					   --Outer Apply [' + pub.funGetBranchDBName() + '].[pub].[funSessionNoList2](' + Ltrim(@UserIDEx) + ') U
					   OUTER APPLY acc.funGetCodeInfo(H.AcntCode) AS F 
					   Where ' + @StrWhere 		   
	Print @StrSelect1;
	Exec sp_executesql @StrSelect1;		
	
	If @POFiscalYearFr <> 0
		Set @StrWhere = @StrWhere + ' AND TA.BaseFiscalYear>='+ str(@POFiscalYearFr)
	If @POSerialNoFr <> 0
		Set @StrWhere = @StrWhere + ' AND TA.BaseSerialNo>='+ str(@POSerialNoFr)
	If @POFiscalYearTo <> 0
		Set @StrWhere = @StrWhere + ' AND TA.BaseFiscalYear<='+ str(@POFiscalYearTo)
	If @POSerialNoTo <> 0
		Set @StrWhere = @StrWhere + ' AND TA.BaseSerialNo<='+ str(@POSerialNoTo)

	
	If @TOFiscalYearFr <> 0
		Set @StrWhere = @StrWhere + ' AND TA.FiscalYear>='+ str(@TOFiscalYearFr)
	If @TOSerialNoFr <> 0
		Set @StrWhere = @StrWhere + ' AND TA.SerialNo>='+ str(@TOSerialNoFr)
	If @TOFiscalYearTo <> 0
		Set @StrWhere = @StrWhere + ' AND TA.FiscalYear<='+ str(@TOFiscalYearTo)
	If @TOSerialNoTo <> 0
		Set @StrWhere = @StrWhere + ' AND TA.SerialNo<='+ str(@TOSerialNoTo)

--	print 'tbl_TmpQty'
--print sysdatetime()
	-- ==========
	SET @StrSelect1 = 'Insert Into #tbl_result
					   select S.ProcessID, S.ProcessNo, S.FiscalYear, S.SerialNo, S.RowNo, S.GoodsID, S.GoodsQuantity, S.SubUnitQuantity,'''', '''', 0, '''', '''', 0
					   from #tbl_TmpQty S'
	--Print @StrSelect1;
	Exec sp_executesql @StrSelect1;	
--	print 'tbl_result'
--print sysdatetime()
			
--Select * From #tbl_TmpQty
--Select * From #tbl_result		
	-- ******************************************************************************
	-- *********************************** Units ************************************
	-- ******************************************************************************
	IF @SubUnitQty= '1' OR @MainAndSubUnit = '1'
	BEGIN
		declare cur_goods cursor for
			select ProcessID, ProcessNo, FiscalYear, SerialNo, RowNo, GoodsID, GoodsQuantity,SubUnitQuantity
			from #tbl_TmpQty
		open cur_goods;
		
		fetch next from cur_goods into @process_id, @process_no, @fiscal_year, @serial_no, @rowNo_no, @goods_id, @goods_quantityGoodsOty,@goods_quantitySubUnitQty
		
		while (@@fetch_status = 0)
		begin

			--====================== Units
			-- 1- empty units table
			delete from @tbl_units
			
			-- 2- fill units of 1 goods
			insert into @tbl_units
			select top 2 t.UnitID, u.UnitName, t.UnitValue, t.MainUnitValue,
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
			WHILE @@FETCH_STATUS = 0 
			begin
				if (@unit_valueGoodsOty= @Mainunit_valueGoodsOty)--@goods_quantityGoodsOty=@goods_quantitySubUnitQty
				begin
					set @unit_idGoodsOty2		= @unit_idGoodsOty;
					set @unit_nameGoodsOty2		= @unit_nameGoodsOty;
					if @goods_quantityGoodsOty=@goods_quantitySubUnitQty
						set @unit_valueGoodsOty2=@goods_quantityGoodsOty
					else						
						if @CntGoodsQty > 2 
							set @unit_valueGoodsOty2 = floor((@goods_quantityGoodsOty + 0.000000001) * @unit_valueGoodsOty / @Mainunit_valueGoodsOty)
						else	
							set @unit_valueGoodsOty2 = @goods_quantityGoodsOty * @unit_valueGoodsOty / @Mainunit_valueGoodsOty
				end 
				else
				begin
					set @unit_idGoodsOty1		 = @unit_idGoodsOty;
					set @unit_nameGoodsOty1		 = @unit_nameGoodsOty;
					if @goods_quantityGoodsOty=@goods_quantitySubUnitQty
					BEGIN
						if @CntGoodsQty > 1
							set @unit_valueGoodsOty1 = floor((@goods_quantityGoodsOty + 0.000000001) * @unit_valueGoodsOty / @Mainunit_valueGoodsOty)
						Else
							set @unit_valueGoodsOty1 = @goods_quantityGoodsOty * @unit_valueGoodsOty / @Mainunit_valueGoodsOty
					End
					ELSE
						set @unit_valueGoodsOty1=@goods_quantitySubUnitQty
				END
			fetch next from cur_units into @unit_idGoodsOty, @unit_nameGoodsOty, @unit_valueGoodsOty, @Mainunit_valueGoodsOty, @CntGoodsQty;
			END

			close cur_units;
			deallocate cur_units;
 
			-- update result
			Update #tbl_result
			Set --GoodsName					= IsNull([pub].[funGetGoodsName](G.GoodsID,@LangID),''),
				UnitIDGoodsOty1				= IsNull(@unit_idGoodsOty1,''),
				UnitNameGoodsOty1			= IsNull(@unit_nameGoodsOty1,''),
				TotalQuantityGoodsOty1		= IsNull(@unit_valueGoodsOty1,0),
				UnitIDGoodsOty2				= IsNull(@unit_idGoodsOty2,''),
				UnitNameGoodsOty2			= IsNull(@unit_nameGoodsOty2,''),
				TotalQuantityGoodsOty2		= IsNull(@unit_valueGoodsOty2,0)
				--,Weight						= IsNull(G.GoodsWeight,0),
				--Volume						= IsNull(G.GoodsLength * G.GoodsHeight * G.GoodsWidth,0)
				--,BarCode						= IsNull([inv].[FunGetGoodsBarCode] (G.GoodsID), '')
			From inv.tblGoods G
			INNER JOIN inv.tblGoodsDtl GD ON GD.GoodsID = SUBSTRING(G.GoodsID,@str_Goods+1, @str_GoodsSum) AND GD.PartNumber= @UnitPart AND GD.LanguageID = @LangID
			Where G.GoodsID = @goods_id AND #tbl_result.GoodsID = @goods_id And #tbl_result.ProcessID = @process_id And 
				  #tbl_result.ProcessNo = @process_no And #tbl_result.FiscalYear = @fiscal_year And #tbl_result.SerialNo = @serial_no AND 
				  #tbl_result.RowNo = @rowNo_no

			if @SubUnitQty= '1'
				UPDATE #tbl_result
				SET UnitNameGoodsOty1 = (select isnull(UnitName , '')
									  from inv.tblUnitsDtl 
									  where UnitID = (select UnitID from inv.tblGoods where GoodsID =  SUBSTRING(@goods_id,@str_Goods+1,@str_GoodsSum) AND PartNumber=@UnitPart ) and LanguageID = @LangID ) 
				   ,UnitNameGoodsOty2 = ISNULL((select isnull(UnitName , '')
									  from inv.tblUnitsDtl 
									  where UnitID = (select SubUnitID from inv.tblSubUnitsDtl where GoodsID =  @goods_id and ShowInInvoice='True' ) and LanguageID = @LangID ),'')

			-- next
			fetch next from cur_goods into @process_id, @process_no, @fiscal_year, @serial_no, @rowNo_no, @goods_id, @goods_quantityGoodsOty,@goods_quantitySubUnitQty
		end

		-- close goods cursor
		Close cur_goods;
		Deallocate cur_goods;
	END	
	-- ******************************************************************************
	-- ********************************** Units End *********************************
	-- ******************************************************************************
	--Select * From #tbl_result
	
	declare @STID nvarchar(50)='H.StoreID '
	IF @sal_AggregateSimilarGoodsInRpt = 0
		SET @STID = 'D.StoreID'

	-- FROM Clause ------------------------------------------
	Set @StrFrom = @SD + ' D 
			INNER JOIN ' + @SH + ' H ON H.ProcessID = D.ProcessID AND H.ProcessNo = D.ProcessNo AND H.FiscalYear = D.FiscalYear AND H.SerialNo = D.SerialNo '
	if @AllSaleRet='True'
		Set @StrFrom = @StrFrom +
		'inner join (
				select   a.ProcessID,a.ProcessNo,a.FiscalYear,a.SerialNo 
				from inv.tblStorageDocsDtl a
				where ProcessID=90
				except
				select  a.ProcessID,a.ProcessNo,a.FiscalYear,a.SerialNo from (
				select   a.ProcessID,a.ProcessNo,a.FiscalYear,a.SerialNo ,DocRowNo,a.GoodsQuantity
				from inv.tblStorageDocsDtl a
				left join 
				(select   BaseProcessID,BaseProcessNo,BaseFiscalYear,BaseSerialNo ,BaseDocRowNo ,Sum(GoodsQuantity) GoodsQuantity
				from inv.tblStorageDocsDtl 
				where ProcessID=100
				group by BaseProcessID,BaseProcessNo,BaseFiscalYear,BaseSerialNo ,BaseDocRowNo
				) b
				on a.ProcessID=b.BaseProcessID and a.ProcessNo=b.BaseProcessNo and a.FiscalYear=b.BaseFiscalYear and a.SerialNo=b.BaseSerialNo and a.DocRowNo=b.BaseDocRowNo
				where a.GoodsQuantity-isnull(b.GoodsQuantity,0)>0 and a.ProcessID=90
				) a) AllSaleRet on  AllSaleRet.ProcessID = D.ProcessID AND AllSaleRet.ProcessNo = D.ProcessNo AND AllSaleRet.FiscalYear = D.FiscalYear AND AllSaleRet.SerialNo = D.SerialNo '

	Set @StrFrom = @StrFrom +
			'LEFT JOIN pln.tblTaskOrderHdr TA on D.BaseProcessID=TA.ProcessID and D.BaseProcessNo=TA.ProcessNo and D.BaseFiscalYear=TA.FiscalYear and D.BaseSerialNo=TA.SerialNo 
			LEFT JOIN sal.tblTransportersDtl TR1 ON TR1.TransporterID = H.TransporterID 
			LEFT JOIN acc.tblVoucherHdr VH ON H.VchNo = VH.SerialNo
			LEFT JOIN sal.tblTransportersDtl TR2 ON TR2.TransporterID = H.TransporterID2 
			LEFT JOIN prs.tblDepartmentsDtl DEP ON DEP.DepartmentID = H.SenderDepartmentID 
			LEFT JOIN inv.tblStoresDtl S1 ON ' + @STID + '= S1.StoreID And S1.LanguageID = ' + LTrim(RTrim(@LangID)) + '
			LEFT JOIN sal.tblSaleTypesDtl ST ON ST.SaleTypeID = D.SaleTypeID
			LEFT JOIN pub.tblProcess P ON P.ProcessID = H.ProcessID and P.ProcessNo = H.ProcessNo
			LEFT JOIN inv.tblStoresDtl S2 ON D.StoreID2 = S2.StoreID And S2.LanguageID = ' + LTrim(RTrim(@LangID)) + '
			LEFT JOIN pub.tblCurrencyTypesDtl Cr ON H.CurrencyTypeID = Cr.CurrencyTypeID And Cr.LanguageID = ' + LTrim(RTrim(@LangID)) + '
			--LEFT  JOIN lyl.tblLoyalCardDtl LC ON LC.LoyalCardNo = H.CCNo
			LEFT JOIN pub.tblLocationsDtl L2 ON L2.LocationID = H.LocationID 	
			LEFT JOIN inv.tblGoods G ON G.GoodsID = SUBSTRING(D.GoodsID,' + ltrim(rtrim(STR(@str_Goods+1))) + ',' + ltrim(rtrim(STR( @str_GoodsSum))) + ') AND G.PartNumber=' + ltrim(rtrim(STR(@UnitPart)))+ '
			LEFT JOIN inv.tblGoodsStatusDtl GS ON GS.StoreID = D.StoreID And GS.GoodsID = D.GoodsID 
			LEFT JOIN inv.tblGoodsReciverDtl GR on GR.ReciverID = H.GoodsReciverID
			LEFT JOIN pub.tblDriversDtl DR on DR.DriverID = H.DriverID
			LEFT JOIN pub.tblDrivers DRH on DRH.DriverID = H.DriverID
			LEFT JOIN inv.tblSubUnitsDtl SUD on D.GoodsID= SUD.GoodsID and SUD.ShowInInvoice = 1
			LEFT JOIN sal.tblGoodsPricesDtl GP ON GP.GoodsID=D.GoodsID and GP.SaleTypeID=D.SaleTypeID and GP.IsGroupCode=''False'' AND GP.UserPriceID=D.UserPriceID
			LEFT JOIN inv.tblBaskulSalesHdr BS on BS.ProcessID = H.BaseProcessID And BS.ProcessNo = H.BaseProcessNo And
												   BS.FiscalYear = H.BaseFiscalYear And BS.SerialNo = H.BaseSerialNo
			LEFT JOIN pub.tblLocationsDtl L3 ON L3.LocationID = BS.LocationID		
			LEFT JOIN sal.tblDescRetSaleDtl DRS ON DRS.DescRetSaleID = H.DescRetSaleID		
			LEFT JOIN prs.tblPersonnels tP1 on tP1.PersonnelID = H.DistributerID1
			LEFT JOIN prs.tblPersonnels tP2 on tP2.PersonnelID = H.DistributerID2
			OUTER APPLY acc.funGetCodeInfo(H.AcntCode) AS F 
			LEFT JOIN #tmpUserName U1 ON U1.SessionNo = H.SessionNo
			LEFT JOIN #tmpUserName U2 ON U2.SessionNo = H.SessionNo
			LEFT JOIN #tmpUserName U3 ON U3.SessionNo = H.SessionNo
			LEFT JOIN #tmpUserName U4 ON U4.SessionNo = H.SessionNo
			LEFT JOIN #tmpUserName U5 ON U5.SessionNo = H.SessionNo
			INNER JOIN ##tblRets Rets ON 1 = 1 '
			SET @StrFrom2 = '
			LEFT JOIN #strSaleReturn_Price2  SDR ON SDR.ProcessID = D.ProcessID AND SDR.ProcessNo = D.ProcessNo AND 
											   SDR.FiscalYear = D.FiscalYear AND SDR.SerialNo = D.SerialNo AND
											   SDR.DocRowNo = D.DocRowNo
			LEFT JOIN #tblAfterSale_Rets  ASR ON ASR.ProcessID = D.ProcessID AND ASR.ProcessNo = D.ProcessNo AND 
												 ASR.FiscalYear = D.FiscalYear AND ASR.SerialNo = D.SerialNo AND
												 ASR.DocRowNo = D.DocRowNo'
			SET @StrFrom3 = '
			LEFT JOIN #tblAfterSale_RetsNoDateLimit  ASRNR ON ASRNR.ProcessID = D.ProcessID AND ASRNR.ProcessNo = D.ProcessNo AND 
															  ASRNR.FiscalYear = D.FiscalYear AND ASRNR.SerialNo = D.SerialNo AND
															  ASRNR.DocRowNo = D.DocRowNo
			LEFT JOIN #tblWithoutBaseDoc_Rets WOBDR ON WOBDR.ProcessID = D.ProcessID AND WOBDR.ProcessNo = D.ProcessNo AND 
														WOBDR.FiscalYear = D.FiscalYear AND WOBDR.SerialNo = D.SerialNo AND
														WOBDR.DocRowNo = D.DocRowNo'
			SET @StrFrom4 = '
			LEFT JOIN #tblWithBeforeDateSale WBDSR ON WBDSR.ProcessID = D.ProcessID AND WBDSR.ProcessNo = D.ProcessNo AND 
													   WBDSR.FiscalYear = D.FiscalYear AND WBDSR.SerialNo = D.SerialNo AND
													   WBDSR.DocRowNo = D.DocRowNo
			LEFT JOIN #tbl_result R2 ON R2.ProcessID = D.ProcessID AND R2.ProcessNo = D.ProcessNo And R2.FiscalYear = D.FiscalYear AND  R2.SerialNo = D.SerialNo AND 
										R2.RowNo = D.RowNo  and R2.GoodsID = D.GoodsID 
			LEFT JOIN inv.tblGoodsUserPrice UPI ON UPI.GoodsID = D.GoodsID And D.UserPriceID = UPI.ID
			'
	
	IF (@UserIDEx <> '' and @UserIDEx <> '-1')
	BEGIN
		SET @StrFrom4 = @StrFrom4 + ' 
			--OUTER APPLY [' + pub.funGetBranchDBName() + '].[pub].[funSessionNoList2](' + Ltrim(@UserIDEx) + ') U 
			INNER JOIN (Select * From ##tblSessionNo) U ON ' + @StrWhereSession
			
	END

IF @sal_AggregateSimilarGoodsInRpt = 0
begin
	Set @StrOverloadCount = ' ,(
				SELECT	IsNull(count(*), 0)
				FROM	inv.tblStorageDocsAtom A
				WHERE   A.ProcessID  = D.ProcessID  AND A.ProcessNo = D.ProcessNo AND 
						A.FiscalYear = D.FiscalYear AND A.SerialNo  = D.SerialNo AND A.DocRowNo = D.DocRowNo) OverLoadCount '
	
	IF (@ShowOverload = 1) 
		Set @StrOverload = '(
				SELECT	IsNull(SUM(AtomAmount), 0)
				FROM	inv.tblStorageDocsAtom A
				WHERE   A.ProcessID  = D.ProcessID  AND A.ProcessNo = D.ProcessNo AND 
						A.FiscalYear = D.FiscalYear AND A.SerialNo  = D.SerialNo AND A.DocRowNo = D.DocRowNo)'
end 
else
begin
	Set @StrOverloadCount = ' ,(
				SELECT	IsNull(count(*), 0)
				FROM	inv.tblStorageDocsAtom A
				WHERE   A.ProcessID  = D.ProcessID  AND A.ProcessNo = D.ProcessNo AND 
						A.FiscalYear = D.FiscalYear AND A.SerialNo  = D.SerialNo ) OverLoadCount '
	
	IF (@ShowOverload = 1) 
		Set @StrOverload = '(
				SELECT	IsNull(SUM(AtomAmount), 0)
				FROM	inv.tblStorageDocsAtom A
				WHERE   A.ProcessID  = D.ProcessID  AND A.ProcessNo = D.ProcessNo AND 
						A.FiscalYear = D.FiscalYear AND A.SerialNo  = D.SerialNo )'
end 

	---------------------------------------------------------
	-- SELECT Clause ----------------------------------------
	DECLARE @StrPrice AS NVarChar(20);

	IF (@UseAmount = 1)
		SET @StrPrice = @strGoodsAmount
	ELSE
		SET @StrPrice = 'GoodsPrice'

	--IF (@ShowDesc = 1)
	--BEGIN
		IF (@ProcessID = 80 )
			SET @StrDocDesc = 'ISNULL((SELECT Top 1 DocDesc from inv.tblStorageDocsHdr a WHERE a.ProcessID = D.BaseProcessID AND a.ProcessNo = D.BaseProcessNo AND a.FiscalYear = D.BaseFiscalYear AND a.SerialNo = D.BaseSerialNo ),'''')'
		ELSE
			SET @StrDocDesc = 'H.DocDesc'
	--END
	--ELSE
	--	SET @StrDocDesc = 'CAST('''' AS NVarChar(600))'
	
	
		SET @StrQty	= 'D.GoodsQuantity '
		SET @StrPrc	= 'D.GoodsQuantity * D.' + @StrPrice 

-- ==========================================================================================	
	-- ============================================================ Updare TotalLineDiscount
	UPDATE inv.tblStorageDocsHdr
	SET TotalLineDiscount = d
	FROM inv.tblStorageDocsHdr a
	INNER JOIN (
				 SELECT ProcessID,ProcessNo,FiscalYear,SerialNo,SUM(DiscountDtl) d FROM inv.tblStorageDocsDtl
				 GROUP BY ProcessID,ProcessNo,FiscalYear,SerialNo
				 ) b
				 ON a.ProcessID=b.ProcessID and a.ProcessNo=b.ProcessNo and a.FiscalYear=b.FiscalYear and a.SerialNo=b.SerialNo
				 WHERE a.TotalLineDiscount-b.d<>0 and a.ProcessID in (90,100)
 
	-- ==========================================================================================	
	-- ============================================================ Updare Rets BaseDocRowNo
--print sysdatetime()
	UPDATE inv.tblStorageDocsDtl 
	SET BaseDocRowNo = A.DocRowNo --Select *
	FROM inv.tblStorageDocsDtl B 
	INNER JOIN 
	(Select * From inv.tblStorageDocsDtl  where ProcessID=90 AND BatchNo='') A 
	 On A.ProcessID=B.BaseProcessID AND A.ProcessNo=B.BaseProcessNo  AND 
		A.FiscalYear=B.BaseFiscalYear  AND A.SerialNo=B.BaseSerialNo  AND A.GoodsID=B.GoodsID AND 
		A.DocRowNo<>B.BaseDocRowNo AND 
		A.GoodsID NOT IN 
					(Select GoodsID 
					 From inv.tblStorageDocsDtl AA 
					 Where AA.ProcessID = 90 AND AA.ProcessID=A.ProcessID AND 
					 AA.ProcessNo=A.ProcessNo AND AA.FiscalYear=A.FiscalYear AND AA.SerialNo=A.SerialNo 
					 Group By ProcessID,ProcessNo,FiscalYear,SerialNo,GoodsID 
					 Having COUNT(GoodsID)>1)
	-- ==========
--print sysdatetime()
	UPDATE inv.tblStorageDocsDtl 
	SET BaseDocRowNo = A.DocRowNo 
	--Select *
	FROM inv.tblStorageDocsDtl B 
	INNER JOIN 
	(Select * From inv.tblStorageDocsDtl  where ProcessID=90 AND BatchNo='') A 
	 On A.ProcessID=B.BaseProcessID AND A.ProcessNo=B.BaseProcessNo  AND 
		A.FiscalYear=B.BaseFiscalYear  AND A.SerialNo=B.BaseSerialNo  AND 
		A.GoodsID=B.GoodsID AND A.DocRowNo<>B.BaseDocRowNo AND A.GoodsQuantity=B.GoodsQuantity AND 
		A.GoodsID NOT IN 
					(Select GoodsID
					 From inv.tblStorageDocsDtl AA 
					 Where AA.ProcessID = 90 AND AA.ProcessID=A.ProcessID AND 
						   AA.ProcessNo=A.ProcessNo AND AA.FiscalYear=A.FiscalYear AND AA.SerialNo=A.SerialNo AND AA.GoodsPrice=A.GoodsPrice
					 Group By ProcessID,ProcessNo,FiscalYear,SerialNo,GoodsID ,GoodsQuantity
					 Having COUNT(GoodsID)>1)
					 
	Declare @QtyStr nvarchar(2000)
	
	DECLARE @DbName_0000 varchar(500)=Substring(db_name(), 1, Len(db_name()) - 4) + '0000'
	
	
--print sysdatetime()
	begin try
		drop table #tmpUserName
		drop table #SessionNo
	end try
	begin catch
	end catch
	
	Create Table #SessionNo
	(
	SessionNo					Int 
	)
	set @QtyStr =
	'INSERT INTO #SessionNo 
		select distinct SessionNo from	inv.tblStorageDocsHdr
		union
		select distinct SessionNo2 from inv.tblStorageDocsHdr
		union
		select distinct SessionNo3 from inv.tblStorageDocsHdr
		union
		select distinct SessionNo4 from inv.tblStorageDocsHdr
		union
		select distinct SessionNo5 from inv.tblStorageDocsHdr
	'
	
	Exec sp_executesql @QtyStr;
	
	Create Table #tmpUserName
	(
	SessionNo					Int, 
	UserName					nvarchar(500) 
	)
	print sysdatetime()				 
		set @QtyStr = 
		   'insert into #tmpUserName
		    select SessionNo, UserName  
			from ' + @DbName_0000 + '.usr.tblSessions SI
			inner join (
				SELECT SN.SessionNo,SessionID
				FROM ' + @DbName_0000 + '.usr.tblSessionNumbers SN 
				INNER JOIN  #SessionNo SD
				ON SD.SessionNo=SN.SessionNo
			)SN
			ON SN.SessionID=SI.SessionID
			inner join  (SELECT UserID,' + @DbName_0000 + '.[pub].[funUserFullName](UserID) UserName FROM ' + @DbName_0000 + '.usr.tblUsers) U
			on SI.UserID=U.UserID	'				 
	PRINT @QtyStr
	Exec sp_executesql @QtyStr;
	
--	print @QtyStr
--print sysdatetime()

	-- ==========================================================================================	
	-- ==========================================================================================

	IF @SubUnitQty = 'False'
	BEGIN	
		IF @sal_AggregateSimilarGoodsInRpt = 0
			set @QtyStr = ',D.SubUnitQuantity '
		ELSE
			set @QtyStr = ',SUM(D.SubUnitQuantity) SubUnitQuantity'
	end
	else
	begin
		IF @sal_AggregateSimilarGoodsInRpt = 0
			set @QtyStr = ',case when (D.SubUnitID = SUD.SubUnitID) then D.SubUnitQuantity else D.GoodsQuantity * (SUD.UnitValue / SUD.MainUnitValue) end SubUnitQuantity '
		ELSE
			set @QtyStr = ',SUM(case when (D.SubUnitID = SUD.SubUnitID) then D.SubUnitQuantity else D.GoodsQuantity * (SUD.UnitValue / SUD.MainUnitValue) end) SubUnitQuantity '
	end	
	-- ===========================================================	
	
	IF @sal_AggregateSimilarGoodsInRpt = 0
	BEGIN	
		SET @StrSelect = '
			SELECT D.ProcessID,D.ProcessNo,D.FiscalYear,D.SerialNo,D.DocDate, H.DocDate2, H.DocDate3, H.DocDate4,D.DocRowNo,D.DescDtl,D.BaseProcessID, D.BaseProcessNo,D.BaseFiscalYear,D.BaseSerialNo,D.BaseDocRowNo,
					pub.funFarsiDateDiff(''Day'', ''' + @BaseDate + ''', ' + Case When @Pub_UseGergorianDate = 1 Then + '
										 [pub].[funChangeDate_GergorianToPersian] (D.DocDate)' Else 'D.DocDate' End + ') AS DateDuration,
					D.BatchNo,H.BatchNo as BatchNoH,
					[inv].[funGetBatchName](D.BatchNo,' + LTrim(RTrim(@LangID)) + ') BatchNameDtl,[inv].[funGetBatchName](H.BatchNo,' + LTrim(RTrim(@LangID)) + ') BatchNameHdr,
					D.StoreID,D.StoreID2,S1.StoreName,IsNull(S2.StoreName,'''') AS StoreName2,P.ProcessName,D.UserGoodsAmount, D.GoodsPrice,ISNULL(GP.SalePrice,0) SaleTypePrice, D.GoodsID,
					[pub].[funGetGoodsName](D.GoodsID,' + LTrim(RTrim(@LangID)) + ') GoodsName, [inv].[funGetUnitNameWithGoodsID](D.GoodsID ,' + LTrim(RTrim(@LangID)) + ') UnitName, G.GoodsCID,G.TechnicalNo, G.TechnicalSpecifications, G.MiscSpecifications,  H.TaxID,[prs].[funGetPersonnelName](H.DistributerID1,'+@LangID+') DistributerName1,[prs].[funGetPersonnelName](H.DistributerID2,'+@LangID+') DistributerName2, tP1.Tel DistributerTel1, tP1.Mobile DistributerMobile1, tP2.Tel DistributerTel2, tP2.Mobile DistributerMobile2, D.ConstText1, D.ConstText2, D.ConstText3, 
					D.ConstText4, IsNull([inv].[FunGetGoodsBarCode] (D.GoodsID), '''') BarCode ,G.IsService, H.AgreeNo, H.SettlementDate, D.CustomerCode DemandantCode, 
					acc.funGetAcntName(D.CustomerCode , ' + LTRIM(RTrim(@AcntPartNumberForRemainCalculation)) + ', ' + LTRIM(RTrim(@LangID)) + ') DemandantName, 
					D.GoodsAmount, D.AcntCode,pub.GetCodeName(D.AcntCode, ' + @LangID + ') AS AcntName,D.Wage, D.GoodsQuantity,
					CASE WHEN D.ProcessID = 80 THEN D.FormulaNo WHEN D.ProcessID = 70 THEN H.FormulaNo ELSE 0 END FormulaNo, 
					CASE WHEN D.ProcessID = 80 THEN ISNULL((SELECT Top 1 FormulaName FROM prd.tblFormulasHdr WHERE ProductID = D.GoodsID And SerialNo = D.FormulaNo),0)
						 WHEN D.ProcessID = 70 THEN ISNULL((SELECT Top 1 FormulaName FROM prd.tblFormulasHdr WHERE ProductID = H.ProductID And SerialNo = H.FormulaNo),0) 
						 ELSE '''' END FormulaName, 
					VH.OldSerialNo,
					H.DiscountPercent,H.DiscountPercent2,H.Discount,H.Discount2+H.Discount3 Discount2,H.TransportationIncome,D.SaleTypeID,ST.SaleTypeName,H.TransporterID2,
					H.TransportationCost, H.CurrencyTransportationCost, H.CurrencyTransportationIncome, H.TransportPrice, H.OtherIncome,H.OtherCost,H.PackingCost,H.TaxCost,H.TransporterID, ' + @StrQty + ' Quantity,' + 
					@StrPrc + ' Price, ISNULL(UPI.UParams,'''') UserPrice, AtomAmount Overload '+  @StrOverloadCount +',' + @StrDocDesc + ' DocDesc, 
					H.DocDesc2, H.ProductID, H.ProductCount, 
					IsNull(pub.funGetGoodsName(H.ProductID, ' + @LangID + '),'''') As ProductName,' + @StrSaleAndRetsQTY + ' H.CCNo, H.CCPrivilege, 
					IsNull(H.GoodsReciverID,'''') GoodsReciverID, IsNull(GR.ReciverName,'''') ReciverName, H.CCDiscount,H.DiscountTaxOverWorth,
					IsNull(H.DriverID,'''') DriverID, IsNull(DR.FirstName + '' '' + DR.LastName, '''') DriverName, DRH.NationalNumber, IsNull(DRH.DriverTel,'''') DriverTel,IsNull(DRH.VehicleNo,'''')VehicleNo_D,IsNull(DRH.DriverMobile,'''')DriverMobile,IsNull(DR.VehicleName,'''') VehicleName,H.C1,H.C2,H.C3,H.C4,H.C5,H.C6,H.C7, H.C8, H.C9, H.C10, H.C11, H.C12, H.TaxSerialNoInvoice TaxSerialNo,
					(	
						SELECT	IsNull(SUM(GoodsQuantity), 0)
						FROM	' + @SD + ' 
						WHERE	ProcessID = ' + @StrRetPID + ' AND 
								(' + LTRIM(RTrim(Str(@ProcessNo))) + '=0 OR ProcessNo = ' + LTRIM(RTrim(Str(@ProcessNo))) + ') AND
								BaseProcessID = D.ProcessID AND 
								BaseProcessNo = D.ProcessNo AND 
								BaseFiscalYear = D.FiscalYear AND 
								BaseSerialNo = D.SerialNo AND 
								BaseDocRowNo = D.DocRowNo
					) ReturnQuantity, H.EarnestMoney, 0-H.Discount-H.Discount2-H.Discount3-H.TotalLineDiscount-H.AfterSaleDiscount-H.OtherCost-
													  H.TransportationCost-H.TransportPrice+H.OtherIncome+H.TransportationIncome+H.PackingCost+H.TaxCost-
													  H.FixCost+H.TaxOverWorthCost+H.TollOverWorthCost-H.DistributeAmount SidePriceSum,
					(	
						SELECT IsNull(Sum(GoodsQuantity * ' + @StrPrice + '), 0)
						FROM	' + @SD + '
						WHERE ProcessID = H.ProcessID AND ProcessNo = H.ProcessNo AND FiscalYear = H.FiscalYear AND SerialNo = H.SerialNo) GoodsPriceSum, 
						H.VisitorAcntCode, H.VisitorCostAcntCode, H.VisitorCost, H.VisitorPercent, pub.GetCodeName(H.VisitorAcntCode, 1) VisitorAcntName,  D.VisitorPercent As DtlVisitorPercent, ((D.SubUnitQuantity * D.GoodsPrice) * D.VisitorPercent / 100) As DtlVisitorCost,
						H.VisitorAcntCode2,H.VisitorCostAcntCode2,H.VisitorCost2,H.VisitorPercent2,pub.GetCodeName(H.VisitorAcntCode2, 1) VisitorAcntName2,D.VisitorPercent2 As DtlVisitorPercent2, ((D.SubUnitQuantity * D.GoodsPrice) * D.VisitorPercent2 / 100) As DtlVisitorCost2,					
					(SELECT ISNULL(SUM(DiscountDtl),0) from  inv.tblStorageDocsDtl DD WHERE DD.ProcessID=D.ProcessID AND 
					 DD.ProcessNo = D.ProcessNo AND DD.FiscalYear = D.FiscalYear AND DD.SerialNo=D.SerialNo ' + @StrWhereDisc + ') TotalLineDiscount,
					H.OrderAcntCode,H.SessionNo,H.SessionNo2,H.SessionNo3,H.SessionNo4,H.SessionNo5,D.DiscountDtl,L2.LocationName LocationName2,H.FixCost, H.DistributeAmount,
					U1.UserName, U1.UserName UserName1, U2.UserName UserName2, U3.UserName UserName3, U4.UserName UserName4, U5.UserName UserName5,Var1,Var2,Var3,Var4, '					
		SET @StrSelect2 = ' 
					isnull(TR1.TransporterName , ''-'') TransporterName,isnull(TR2.TransporterName , ''-'')  TransporterName2,H.AfterSaleDiscount, D.DiscountPercentDtl, H.TaxOverWorthCost, H.TollOverWorthCost, D.TaxOverWorthCostDtl, D.TollOverWorthCostDtl, 
					H.OwnerDocNo, H.BaseDistributionFiscalYear, H.BaseDistributionSerialNo,H.IAToll,ISNULL(DEP.DepartmentName,'''') DepartmentName ,
					ISNULL((Select Top 1 ProductCount  From prd.tblFormulasHdr Where ProductID=D.GoodsID And IsDefault=1),0) As ProductQty,
					 F.EconomicalCode, F.CustomerFirstName + '' '' + F.CustomerLastName AS CustomerName, 
					 F.Address1, F.Address2, F.CompanyRegisterNo, F.NationalIDNumber, F.NationalIdentity, F.OrganzationName, 
					 F.ZipCode, IsNull(F.Tel, '''') Tel,IsNull(F.Mobile, '''') Mobile,IsNull(F.SMSMobile, '''') SMSMobile,H.VchNo, ' + 
					 Case When @DecReturn = 1 Then '
					 IsNull(SDR.SameDateRetPrice,0) SameDate_RetsDtl, IsNull(ASR.AfterSale_Rets,0) AfterSale_RetsDtl, 
					 IsNull(ASRNR.AfterSale_RetsNoDateLimit,0) AfterSale_RetsNoDateLimitDtl, 
					 IsNull(WOBDR.WithoutBaseDoc_Rets,0) WithoutBaseDoc_RetsDtl, 
					 IsNull(WBDSR.WithBeforeDateSale,0) WithBeforeDateSaleDtl,' 
					  Else '
					 0 SameDate_RetsDtl, 0 AfterSale_RetsDtl, 0 AfterSale_RetsNoDateLimitDtl, 0 WithoutBaseDoc_RetsDtl, 
					 0 WithBeforeDateSaleDtl,' End + 
					 Case When @DecReturn = 1 Then '
					 Rets.SameDate_Rets, Rets.AfterSale_Rets, Rets.AfterSale_RetsNoDateLimit, Rets.WithoutBaseDoc_Rets, 
					 Rets.WithBeforeDateSale, Rets.SaleRets_Sum ,Rets.QtyWithoutBase	,Rets.QtyWithBase ' 
					  Else '
					 0 SameDate_Rets, 0 AfterSale_Rets, 0 AfterSale_RetsNoDateLimit, 0 WithoutBaseDoc_Rets, 
					 0 WithBeforeDateSale, 0 SaleRets_Sum,0 QtyWithoutBase	,0 QtyWithBase  ' 
					 End + ', H.DescRetSaleID, DRS.DescRetSaleName, BS.LocationID, L3.LocationName,
					 ROUND(IsNull(R2.TotalQuantityGoodsOty,0), ' + LTrim(RTrim(Str(@QuantityDecimalsToForms))) + ') RTotalQuantityGoodsOty, IsNull(R2.UnitIDGoodsOty1,'''') RUnitIDGoodsOty1, 
					 IsNull(R2.UnitNameGoodsOty1,'''') RUnitNameGoodsOty1, ROUND(IsNull(R2.TotalQuantityGoodsOty1,0), ' + LTrim(RTrim(Str(@QuantityDecimalsToForms))) + ') RTotalQuantityGoodsOty1, 
					 IsNull(R2.UnitIDGoodsOty2,'''') RUnitIDGoodsOty2, IsNull(R2.UnitNameGoodsOty2,'''') RUnitNameGoodsOty2, 
					 ROUND(IsNull(R2.TotalQuantityGoodsOty2,0), ' + LTrim(RTrim(Str(@QuantityDecimalsToForms))) + ') RTotalQuantityGoodsOty2,	
					 IsNull(G.GoodsWeight,0) RWeight, IsNull(G.GoodsLength * G.GoodsHeight * G.GoodsWidth,0) RVolume, 
					 IsNull([inv].[FunGetGoodsBarCode] (D.GoodsID), '''') RBarCode' + @QtyStr
					 +'  ,H.NetWeightHdr,H.GrossWeight,H.CurrencyValue,H.DeclaredCompanyName,H.KotagNo,	H.KotagDate,H.AssessmentLocation,H.ExitLocation,H.PriceParvane ,H.DestinationAddress ,
					 H.Address,H.CurrencyTypeID,H.CurrencyRate,isnull(CurrencyTypeName,'''') CurrencyTypeName ,SubUnitPrice, 
					 IsNull((SELECT STUFF 
							((SELECT '',''+IsNull(CAST(DD.FiscalYear as NVarChar) + ''/'' + CAST(DD.SerialNo as NVarChar),'''')
							 FROM inv.tblStorageDocsDtl DD 
							 LEFT JOIN inv.tblStorageDocsDtl DDD ON DDD.BaseProcessID = DD.ProcessID 
							 									AND DDD.BaseProcessNo = DD.ProcessNo 
							 									AND DDD.BaseFiscalYear = DD.FiscalYear 
							 									AND DDD.BaseSerialNo = DD.SerialNo 
							 									AND DDD.BaseDocRowNo = DD.DocRowNo
							WHERE D.SerialNo = DD.BaseSerialNo
							  AND D.DocRowNo = DD.BaseDocRowNo
							  AND D.ProcessID = 55 
							  AND DD.ProcessID = 90 
							  AND D.ProcessNo = DD.ProcessNo
							GROUP BY DD.FiscalYear,DD.SerialNo
							FOR XML PATH('''')),1,1,'''')),'''') as SaleFiscalSerial, 
					 IsNull((SELECT Sum(DD.GoodsQuantity)
							 FROM inv.tblStorageDocsDtl DD 
							 LEFT JOIN inv.tblStorageDocsDtl DDD ON DDD.BaseProcessID = DD.ProcessID 
							 									AND DDD.BaseProcessNo = DD.ProcessNo 
							 									AND DDD.BaseFiscalYear = DD.FiscalYear 
							 									AND DDD.BaseSerialNo = DD.SerialNo 
							 									AND DDD.BaseDocRowNo = DD.DocRowNo
							WHERE D.SerialNo = DD.BaseSerialNo
							  AND D.DocRowNo = DD.BaseDocRowNo
							  AND D.GoodsID = DD.GoodsID
							  AND D.ProcessID = 55 
							  AND DD.ProcessID = 90 
							  AND D.ProcessNo = DD.ProcessNo
							GROUP BY DD.FiscalYear,DD.SerialNo)
							,0) as SaleQuantity'
		SET @StrSelect3 = ' 
			FROM  ' + @StrFrom + @StrFrom2 + @StrFrom3 +  @StrFrom4 + '
			WHERE ' + @StrWhere
	END
	ELSE -- ===========================================
	BEGIN
		SET @StrSelect = '
			SELECT  D.ProcessID, D.ProcessNo, D.FiscalYear, D.SerialNo, D.DocDate, H.DocDate2, H.DocDate3, H.DocDate4, 0 DocRowNo,D.DescDtl,D.BaseProcessID, D.BaseProcessNo, D.BaseFiscalYear, D.BaseSerialNo,0 BaseDocRowNo,
					pub.funFarsiDateDiff(''Day'', ''' + @BaseDate + ''', D.DocDate) AS DateDuration,'''' BatchNo, H.BatchNo As BatchNoH,
					'''' BatchNameDtl,[inv].[funGetBatchName](H.BatchNo,' + LTrim(RTrim(@LangID)) + ') BatchNameHdr,
					D.GoodsID, H.StoreID, D.StoreID2, S1.StoreName, IsNull(S2.StoreName,'''') AS StoreName2, P.ProcessName, 
					D.UserGoodsAmount,Sum(D.GoodsPrice) GoodsPrice,0 SaleTypePrice, [pub].[funGetGoodsName](D.GoodsID,' + LTrim(RTrim(@LangID)) + ') GoodsName, [inv].[funGetUnitNameWithGoodsID](D.GoodsID ,' + LTrim(RTrim(@LangID)) + ') UnitName , G.GoodsCID,G.TechnicalNo, G.TechnicalSpecifications,G.MiscSpecifications, H.TaxID,[prs].[funGetPersonnelName](H.DistributerID1,'+@LangID+') DistributerName1,[prs].[funGetPersonnelName](H.DistributerID2,'+@LangID+') DistributerName2,tP1.Tel  DistributerTel1, tP1.Mobile DistributerMobile1, tP2.Tel DistributerTel2, tP2.Mobile DistributerMobile2,  
					Case When IsNumeric(D.ConstText1) = 0 OR D.ConstText1 = ''0'' OR D.ConstText1 = '''' Then 0 Else D.ConstText1 End As ConstText1,
					Sum(Case When IsNumeric(D.ConstText2) = 0 Then 0 Else Cast(D.ConstText2 As Float) End) ConstText2,
					Sum(Case When IsNumeric(D.ConstText3) = 0 Then 0 Else Cast(D.ConstText3 As Float) End) ConstText3,
					Sum(Case When IsNumeric(D.ConstText4) = 0 Then 0 Else Cast(D.ConstText4 As Float) End) ConstText4,
					IsNull([inv].[FunGetGoodsBarCode] (D.GoodsID), '''') BarCode, G.IsService, H.AgreeNo, H.SettlementDate, '''' DemandantCode, 
					'''' DemandantName, Sum(D.GoodsAmount) GoodsAmount, D.AcntCode, pub.GetCodeName(D.AcntCode, ' + @LangID + ') AS AcntName, 
					D.Wage, Sum(D.GoodsQuantity) GoodsQuantity, 0 FormulaNo, '''' FormulaName, VH.OldSerialNo,
					Sum(D.VisitorPercent) As DtlVisitorPercent, Sum(((D.SubUnitQuantity * D.GoodsPrice) * D.VisitorPercent / 100)) As DtlVisitorCost,
					Sum(D.VisitorPercent2) As DtlVisitorPercent2, Sum(((D.SubUnitQuantity * D.GoodsPrice) * D.VisitorPercent2 / 100)) As DtlVisitorCost2,
					H.DiscountPercent, H.DiscountPercent2,H.Discount, H.Discount2+H.Discount3 Discount2, H.TransportationIncome, 
					D.SaleTypeID, ST.SaleTypeName,H.TransporterID2, H.TransportationCost, H.TransportPrice, H.CurrencyTransportationCost, H.CurrencyTransportationIncome,
					H.OtherIncome, H.OtherCost, H.PackingCost, H.TaxCost, H.TransporterID, Sum(' + @StrQty + ') Quantity, Sum(' + @StrPrc + ') Price, 
					' + @StrUserPrice + ', Sum(AtomAmount) Overload  '+  @StrOverloadCount +' ,' + @StrDocDesc + ' DocDesc,H.DocDesc2, H.ProductID, H.ProductCount, 
					IsNull(pub.funGetGoodsName(H.ProductID, ' + @LangID + '),'''') As ProductName, ' + @StrSaleAndRetsQTY + ' H.CCNo, H.CCPrivilege, 
					IsNull(H.GoodsReciverID,'''') GoodsReciverID, IsNull(GR.ReciverName,'''') ReciverName, H.CCDiscount, H.DiscountTaxOverWorth,
					IsNull(H.DriverID,'''') DriverID, IsNull(DR.FirstName + '' '' + DR.LastName, '''') DriverName, DRH.NationalNumber, IsNull(DRH.DriverTel,'''') DriverTel,IsNull(DRH.VehicleNo,'''')VehicleNo_D,IsNull(DRH.DriverMobile,'''')DriverMobile,IsNull(DR.VehicleName,'''') VehicleName, '''' C1,'''' C2,'''' C3,'''' C4,'''' C5,'''' C6, H.TaxSerialNoInvoice TaxSerialNo,
					(	
						SELECT	IsNull(SUM(GoodsQuantity), 0)
						FROM	' + @SD + ' 
						WHERE	ProcessID = ' + @StrRetPID + ' AND 
								(' + LTRIM(RTrim(Str(@ProcessNo))) + '=0 OR ProcessNo = ' + LTRIM(RTrim(Str(@ProcessNo))) + ') AND 
								BaseProcessID = D.ProcessID AND 
								BaseProcessNo = D.ProcessNo AND 
								BaseFiscalYear = D.FiscalYear AND 
								BaseSerialNo = D.SerialNo AND
								GoodsID = D.GoodsID 
								--BaseDocRowNo = D.DocRowNo
					) ReturnQuantity, 
					H.EarnestMoney, 0-H.Discount-H.Discount2-H.Discount3-H.TotalLineDiscount-H.AfterSaleDiscount-H.OtherCost-H.TransportationCost
					-H.TransportPrice+H.OtherIncome+H.TransportationIncome+H.PackingCost+H.TaxCost-H.FixCost+H.TaxOverWorthCost+H.TollOverWorthCost-
					H.DistributeAmount SidePriceSum,
					(	
						SELECT IsNull(Sum(GoodsQuantity * ' + @StrPrice + '), 0)
						FROM	' + @SD + '
						WHERE ProcessID = H.ProcessID AND ProcessNo = H.ProcessNo AND FiscalYear = H.FiscalYear AND SerialNo = H.SerialNo
					) GoodsPriceSum, H.VisitorAcntCode, H.VisitorCostAcntCode, H.VisitorCost,H.VisitorAcntCode2, H.VisitorCostAcntCode2, H.VisitorCost2, H.FixCost, H.DistributeAmount,
					(SELECT ISNULL(SUM(DiscountDtl),0) from  inv.tblStorageDocsDtl DD WHERE DD.ProcessID=D.ProcessID AND 
					 DD.ProcessNo = D.ProcessNo AND DD.FiscalYear = D.FiscalYear AND DD.SerialNo=D.SerialNo ' + @StrWhereDisc + ') TotalLineDiscount,
					H.VisitorPercent,H.VisitorPercent2,H.OrderAcntCode,H.SessionNo,H.SessionNo2,H.SessionNo3,H.SessionNo4,H.SessionNo5,Sum(D.DiscountDtl) DiscountDtl,
					L2.LocationName LocationName2, U1.UserName , U1.UserName UserName1, 
					U2.UserName UserName2, U3.UserName UserName3, U4.UserName UserName4, 
					U5.UserName AS UserName5,
					Var1,Var2,Var3,Var4, '
		SET @StrSelect2 = ' 
					isnull(TR1.TransporterName , ''-'') TransporterName,isnull(TR2.TransporterName , ''-'')  TransporterName2, H.AfterSaleDiscount, Sum(D.DiscountPercentDtl) DiscountPercentDtl, H.TaxOverWorthCost, H.TollOverWorthCost, 
					Sum(D.TaxOverWorthCostDtl) TaxOverWorthCostDtl, Sum(D.TollOverWorthCostDtl) TollOverWorthCostDtl, 
					pub.GetCodeName(H.VisitorAcntCode, 1) VisitorAcntName, pub.GetCodeName(H.VisitorAcntCode2, 1) VisitorAcntName2, H.OwnerDocNo, H.BaseDistributionFiscalYear, 
					H.BaseDistributionSerialNo, H.IAToll,ISNULL(DEP.DepartmentName,'''') DepartmentName,
					ISNULL((SELECT Top 1 ProductCount 
					 FROM prd.tblFormulasHdr 
					 WHERE ProductID=D.GoodsID And IsDefault=1),0) As ProductQty,
					 F.EconomicalCode, F.CustomerFirstName + '' '' + F.CustomerLastName AS CustomerName, 
					 F.Address1, F.Address2, F.CompanyRegisterNo, F.NationalIDNumber, F.NationalIdentity, F.OrganzationName, 
					 F.ZipCode, IsNull(F.Tel, '''') Tel,IsNull(F.Mobile, '''') Mobile,IsNull(F.SMSMobile, '''') SMSMobile,H.VchNo, ' + 
					 Case When @DecReturn = 1 Then '
					 IsNull(SDR.SameDate_Rets,0) SameDate_RetsDtl, IsNull(ASR.AfterSale_Rets,0) AfterSale_RetsDtl, 
					 IsNull(ASRNR.AfterSale_RetsNoDateLimit,0) AfterSale_RetsNoDateLimitDtl, 
					 IsNull(WOBDR.WithoutBaseDoc_Rets,0) WithoutBaseDoc_RetsDtl, 
					 IsNull(WBDSR.WithBeforeDateSale,0) WithBeforeDateSaleDtl,' 
					  Else '
					 0 SameDate_RetsDtl, 0 AfterSale_RetsDtl, 0 AfterSale_RetsNoDateLimitDtl, 0 WithoutBaseDoc_RetsDtl, 
					 0 WithBeforeDateSaleDtl,' End + 
					 Case When @DecReturn = 1 Then '
					 Rets.SameDate_Rets, Rets.AfterSale_Rets, Rets.AfterSale_RetsNoDateLimit, Rets.WithoutBaseDoc_Rets, 
					 Rets.WithBeforeDateSale, Rets.SaleRets_Sum ,Rets.QtyWithoutBase	,Rets.QtyWithBase ' 
					  Else '
					 0 SameDate_Rets, 0 AfterSale_Rets, 0 AfterSale_RetsNoDateLimit, 0 WithoutBaseDoc_Rets, 
					 0 WithBeforeDateSale, 0 SaleRets_Sum ,0 QtyWithoutBase	,0 QtyWithBase  ' 
					 End + ', H.DescRetSaleID, DRS.DescRetSaleName, BS.LocationID, L3.LocationName,
					 SUM(ROUND(IsNull(R2.TotalQuantityGoodsOty,0), ' + LTrim(RTrim(Str(@QuantityDecimalsToForms))) + ')) RTotalQuantityGoodsOty, IsNull(R2.UnitIDGoodsOty1,'''') RUnitIDGoodsOty1, 
					 IsNull(R2.UnitNameGoodsOty1,'''') RUnitNameGoodsOty1, SUM(ROUND(IsNull(R2.TotalQuantityGoodsOty1,0), ' + LTrim(RTrim(Str(@QuantityDecimalsToForms))) + ')) RTotalQuantityGoodsOty1, 
					 IsNull(R2.UnitIDGoodsOty2,'''') RUnitIDGoodsOty2, IsNull(R2.UnitNameGoodsOty2,'''') RUnitNameGoodsOty2, 
					 SUM(ROUND(IsNull(R2.TotalQuantityGoodsOty2,0), ' + LTrim(RTrim(Str(@QuantityDecimalsToForms))) + ')) RTotalQuantityGoodsOty2,	
					 SUM(IsNull(G.GoodsWeight,0)) RWeight, SUM(IsNull(G.GoodsLength * G.GoodsHeight * G.GoodsWidth,0)) RVolume, IsNull([inv].[FunGetGoodsBarCode] (D.GoodsID), '''') RBarCode' + @QtyStr
					 +'  ,H.NetWeightHdr,H.GrossWeight,H.CurrencyValue,H.DeclaredCompanyName,H.KotagNo,	H.KotagDate,H.AssessmentLocation,H.ExitLocation,H.PriceParvane ,H.DestinationAddress,
					 H.Address,H.CurrencyTypeID,H.CurrencyRate,isnull(CurrencyTypeName,'''') CurrencyTypeName ,SubUnitPrice, , 
					 IsNull((SELECT STUFF 
							((SELECT '',''+IsNull(CAST(DD.FiscalYear as NVarChar) + ''/'' + CAST(DD.SerialNo as NVarChar),'''')
							 FROM inv.tblStorageDocsDtl DD 
							 LEFT JOIN inv.tblStorageDocsDtl DDD ON DDD.BaseProcessID = DD.ProcessID 
							 									AND DDD.BaseProcessNo = DD.ProcessNo 
							 									AND DDD.BaseFiscalYear = DD.FiscalYear 
							 									AND DDD.BaseSerialNo = DD.SerialNo 
							 									AND DDD.BaseDocRowNo = DD.DocRowNo
							WHERE D.SerialNo = DD.BaseSerialNo 
							  AND D.ProcessID = 55 
							  AND DD.ProcessID = 90 
							  AND D.ProcessNo = DD.ProcessNo
							GROUP BY DD.FiscalYear,DD.SerialNo
							FOR XML PATH('''')),1,1,'''')),'''') as SaleFiscalSerial'
		SET @StrSelect3 = ' 
			FROM  ' + @StrFrom + @StrFrom2 + @StrFrom3 +  @StrFrom4 + '
			WHERE ' + @StrWhere
		SET @StrSelect4 = ' 
			GROUP BY D.ProcessID, D.ProcessNo, D.FiscalYear, D.SerialNo, D.DocDate, H.DocDate2, H.DocDate3, H.DocDate4, D.DescDtl, D.BaseProcessID, D.BaseProcessNo, D.BaseFiscalYear, D.BaseSerialNo, H.BatchNo, 
					 D.GoodsID, H.StoreID, D.StoreID2, S1.StoreName, S2.StoreName, P.ProcessName,G.GoodsWeight,G.GoodsLength , G.GoodsHeight , G.GoodsWidth,G.IsService,G.GoodsCID,G.TechnicalNo, G.TechnicalSpecifications, G.MiscSpecifications, H.TaxID, H.DistributerID1,H.DistributerID2,tP1.Tel,tP2.Tel,tP1.Mobile ,tP2.Mobile ,H.SettlementDate, H.AgreeNo,
					 Case When IsNumeric(D.ConstText1) = 0 OR D.ConstText1 = ''0'' OR D.ConstText1 = '''' Then 0 Else D.ConstText1 End,
					 D.UserGoodsAmount,D.Wage, H.DiscountPercent, H.DiscountPercent2, H.Discount, H.Discount2,H.Discount3 , H.TransportationIncome, D.SaleTypeID, D.AcntCode,VH.OldSerialNo,
					 ST.SaleTypeName,H.TransporterID2, H.TransportationCost, H.CurrencyTransportationCost, H.CurrencyTransportationIncome, H.TransportPrice, H.OtherIncome, H.OtherCost, H.PackingCost, H.TaxCost, H.TransporterID,
					 H.DocDesc,H.DocDesc2, H.ProductID, H.ProductCount, H.CCNo, H.CCPrivilege, H.CCDiscount, H.GoodsReciverID, GR.ReciverName,
					 H.DiscountTaxOverWorth, H.DriverID, DR.FirstName, DR.LastName,DRH.NationalNumber,DRH.DriverTel,DRH.VehicleNo,DRH.DriverMobile,DR.VehicleName, H.EarnestMoney, H.TotalLineDiscount, H.AfterSaleDiscount,
					 H.FixCost, H.TaxOverWorthCost, H.TollOverWorthCost, H.DistributeAmount, H.ProcessID, H.ProcessNo, H.FiscalYear, H.SerialNo,
					 H.VisitorAcntCode, H.VisitorCostAcntCode, H.VisitorCost, H.VisitorPercent, H.VisitorAcntCode2, H.VisitorCostAcntCode2, H.VisitorCost2, H.VisitorPercent2,H.OrderAcntCode, H.SessionNo, H.SessionNo2, H.SessionNo3, 
					 H.SessionNo4, H.SessionNo5, L2.LocationName, TR1.TransporterName ,TR2.TransporterName , H.OwnerDocNo, H.BaseDistributionFiscalYear,H.TaxSerialNoInvoice,
					 H.BaseDistributionSerialNo, H.IAToll,DEP.DepartmentName, F.EconomicalCode, F.CustomerFirstName, F.CustomerLastName, F.Address1, F.Address2,
					 F.CompanyRegisterNo, F.NationalIDNumber, F.NationalIdentity, F.OrganzationName, F.ZipCode, IsNull(F.Tel, ''''),F.Mobile,F.SMSMobile,H.VchNo, H.DescRetSaleID,
					 DRS.DescRetSaleName, BS.LocationID, L3.LocationName, R2.UnitIDGoodsOty1, R2.UnitNameGoodsOty1, R2.UnitIDGoodsOty2,
					 U1.UserName,U2.UserName,U3.UserName,U4.UserName,U5.UserName,Var1,Var2,Var3,Var4,
					 R2.UnitNameGoodsOty2' + @StrUserPriceGrp + ',H.NetWeightHdr,H.GrossWeight,H.CurrencyValue,H.DeclaredCompanyName, H.KotagNo,	H.KotagDate,H.AssessmentLocation,H.ExitLocation,
					 H.PriceParvane,H.DestinationAddress,H.Address,H.CurrencyTypeID,H.CurrencyRate,CurrencyTypeName ,SubUnitPrice
					 '	
	END
	
	----------------------------------------------------------------------------------
	begin try
		drop table #tbl_RptStore_Stock_Prices
	end try
	begin catch
	end catch
	
	create table #tbl_RptStore_Stock_Prices
	(
		GoodsID varchar(20) collate arabic_cs_as not null,
		BuyPrice float not null,
		ProductSerialID varchar(20) collate arabic_cs_as not null,
		BatchNo varchar(20) collate arabic_cs_as not null,
		ExpireDate varchar(10) collate arabic_cs_as not null
	);

	insert into #tbl_RptStore_Stock_Prices
	select *
	from 
	(
		select distinct GoodsID, 
			(
				select top 1 GoodsPrice
				from inv.tblStorageDocsDtl D 
				where (D.GoodsID = M.GoodsID) and (D.ProcessID = 55)
				order by DocDate DESC, VolumeRowNo DESC
			) BuyPrice,
			'' As ProductSerialID, '' As BatchNo, '' As ExpireDate
		from inv.tblStorageDocsDtl M
	) T 
	where BuyPrice is not null

	update #tbl_RptStore_Stock_Prices
	set BuyPrice = GoodsPrice
	from inv.tblGoods
	where #tbl_RptStore_Stock_Prices.GoodsID = inv.tblGoods.GoodsID 
		and #tbl_RptStore_Stock_Prices.BuyPrice = 0

	insert into #tbl_RptStore_Stock_Prices(GoodsID, BuyPrice, ProductSerialID, BatchNo, ExpireDate)
	select GoodsID, GoodsPrice, '' As ProductSerialID, '' As BatchNo, '' As ExpireDate
	from inv.tblGoods
	where GoodsID not in (select GoodsID from #tbl_RptStore_Stock_Prices)
	----------------------------------------------------------------------------------
	
	begin try
		drop table ##tbl_Store_Described
	end try
	begin catch
	end catch
	
	set @FlockTypeField=','''' Flocks '
	if (@Sal_SpecialSale='true')
	set @FlockTypeField=' ,isnull( stuff((
		select '', '', FlockTypeName +'' ''  + cast( Quantity as varchar(20) ) from sal.tblFlockDtl D
	    inner join  sal.tblFlockTypeDtl F  on D.FlockTypeID=F.FlockTypeID and LanguageID=1
		where SerialNo = (
		select top 1 isnull(SerialNo,0) from sal.tblFlockHdr  
		where AcntCode=substring(T.AcntCode,'+str(@StartLayerAcntRemain)+','+str(@LenLayerAcntRemain)+')  
		order by DocDate desc , SerialNo Desc 
		) 
		and  AcntCode=substring(T.AcntCode,'+str(@StartLayerAcntRemain)+','+str(@LenLayerAcntRemain)+') 

			for xml path('''')
		),1,1,''''),'''')  Flocks '


	set @SerialsField = 'Cast('''' as nvarchar(2000)) Serials ,Cast('''' as nvarchar(2000)) PSerialCID '
	
	if (@ShowSerials = 1)
		set @SerialsField = '
		stuff((
			select '', '', convert(varchar(20), PS.SerialNo)
			from inv.tblStorageDocsSerials S
				inner join pln.tblProductSerials PS on PS.ProductSerialID=S.ProductSerialID
			where S.ProcessID=T.ProcessID 
				and S.ProcessNo=T.ProcessNo
				and S.FiscalYear=T.FiscalYear
				and S.SerialNo=T.SerialNo
				and S.DocRowNo=T.DocRowNo
			for xml path('''')
		),1,1,'''')  Serials , stuff((
			select '', '', convert(varchar(20), PS.PSerialCID)
			from inv.tblStorageDocsSerials S
				inner join pln.tblProductSerials PS on PS.ProductSerialID=S.ProductSerialID
			where S.ProcessID=T.ProcessID 
				and S.ProcessNo=T.ProcessNo
				and S.FiscalYear=T.FiscalYear
				and S.SerialNo=T.SerialNo
				and S.DocRowNo=T.DocRowNo
			for xml path('''')
		),1,1,'''') PSerialCID '


	--IF (@SumPriceFr Is Not Null) OR (@SumPriceTo Is Not Null)
	SET @StrSelect = '
	SELECT  distinct  T.*, P.BuyPrice LastBuyPrice, ' + @SerialsField + @FlockTypeField+' 
	into ##tbl_Store_Described
	FROM 
	(' + @StrSelect 
	
	SET @StrSelect2 = @StrSelect2
	
	SET @StrSelect4 =
	@StrSelect4 + '
	) T left join #tbl_RptStore_Stock_Prices P on P.GoodsID=T.GoodsID
	WHERE (Quantity <> 0)' + @StrSaleAndRetsWhere -- dont remove it	
	-- ========== Price
	IF (@SumPriceFr Is Not Null) 
		SET @StrSelect4 = @StrSelect4 + ' AND (T.GoodsPriceSum + T.SidePriceSum) >= ' + LTrim(Str(@SumPriceFr))

	IF (@SumPriceTo Is Not Null) 
		SET @StrSelect4 = @StrSelect4 + ' AND (T.GoodsPriceSum + T.SidePriceSum) <= ' + LTrim(Str(@SumPriceTo))
		
	-- ========== Discount
	
	IF (@DiscountPercentFrom Is Not Null) And (@DiscountPercentFrom <> 0)
		SET @StrSelect4 = @StrSelect4 + ' AND (T.DiscountPercent >= ' + LTrim(Str(@DiscountPercentFrom)) + ')'
	IF (@DiscountPercentTo Is Not Null) And (@DiscountPercentTo <> 0)
		SET @StrSelect4 = @StrSelect4 + ' AND (T.DiscountPercent <= ' + LTrim(Str(@DiscountPercentTo)) + ')'

	IF (@DiscountAmountFrom Is Not Null) And (@DiscountAmountFrom <> 0)
		SET @StrSelect4 = @StrSelect4 + ' AND (T.Discount >= ' + LTrim(Str(@DiscountAmountFrom)) + ')'
	IF (@DiscountAmountTo Is Not Null) And (@DiscountAmountTo <> 0)
		SET @StrSelect4 = @StrSelect4 + ' AND (T.Discount <= ' + LTrim(Str(@DiscountAmountTo)) + ')'

	------------------------------------------------------------
	-- SORT Clause ---------------------------------------------
	IF (@SortFields Is Not Null)
		Set @StrSelect4 = @StrSelect4 + '
	 ORDER BY ' + @SortFields

	------------------------------------------------------------
	-- RUN -----------------------------------------------------
	Print @StrSelect;
	Print @StrSelect2;
	--Print @StrSelect3;
			 
	PRINT ' FROM  ' + @StrFrom 
	PRINT @StrFrom2 
	PRINT @StrFrom3 
	PRINT @StrFrom4 
	PRINT ' WHERE ' + @StrWhere
	Print @StrSelect4;
	
	SET @StrSelect = @StrSelect + @StrSelect2 + @StrSelect3 + @StrSelect4
	Exec sp_executesql @StrSelect;
	
	---return 

	SELECT *   into #tblOld	FROM ##tbl_Store_Described	
	------------------------------------------------------------
	IF (@UserIsAdmin = 0)
	Begin
		if @ProcessID =120
			Exec pub.SpFilterByPermission2 '##tbl_Store_Described', 'StoreID2', 'inv.tblStores', @UserID;
		else
			Exec pub.SpFilterByPermission2 '##tbl_Store_Described', 'StoreID', 'inv.tblStores', @UserID;
		Exec pub.SpFilterByPermission2 '##tbl_Store_Described', 'GoodsID', 'inv.tblGoods', @UserID;
		Exec pub.SpFilterByPermission2 '##tbl_Store_Described', 'AcntCode', 'acc.tblAcnt', @UserID;
	End
	 -------برای حذف فاکتور هایی که ردیف کالای آنها حذف شده است
	delete from ##tbl_Store_Described
	from ##tbl_Store_Described a
	inner join (select count(*) cnt,ProcessID,ProcessNo,FiscalYear,SerialNo  from ##tbl_Store_Described
	group by ProcessID,ProcessNo,FiscalYear,SerialNo  ) b
	on a.ProcessID =b.ProcessID and a.ProcessNo =b.ProcessNo and a.FiscalYear = b.FiscalYear and a.SerialNo=b.SerialNo
	inner join (select count(*) cnt,ProcessID,ProcessNo,FiscalYear,SerialNo  from #tblOld
	group by ProcessID,ProcessNo,FiscalYear,SerialNo  ) c
	on c.ProcessID =b.ProcessID and c.ProcessNo =b.ProcessNo and c.FiscalYear = b.FiscalYear and c.SerialNo=b.SerialNo
	and  c.cnt >b.cnt	
	
	IF @SetDtlTaxAndToll = 'True'
	BEGIN
		update ##tbl_Store_Described
		set TaxOverWorthCost = b.TaxOverWorthCostDtl
	   	   ,TollOverWorthCost =b.TollOverWorthCostDtl
		FROM ##tbl_Store_Described a
		inner join (SELECT ProcessID,ProcessNo,FiscalYear,SerialNo ,SUM(TaxOverWorthCostDtl) TaxOverWorthCostDtl,SUM(TollOverWorthCostDtl) TollOverWorthCostDtl
					FROM ##tbl_Store_Described 
					group by ProcessID,ProcessNo,FiscalYear,SerialNo) b
		ON a.ProcessID=b.ProcessID and a.ProcessNo=b.ProcessNo and a.FiscalYear=b.FiscalYear and a.SerialNo=b.SerialNo
		where b.TaxOverWorthCostDtl>0
	END
	---------علت انتقال به خاطر حذف کلیه سطرها در حیطه دسترسی میشد----------------------------------------------------------
	update ##tbl_Store_Described
	set AcntCode=CASE WHEN D.BaseProcessID<>610 THEN D.AcntCode ELSE ISNULL((SELECT TOP 1 OperatorID from pln.tblTaskOrderOperators a WHERE a.ProcessID=D.BaseProcessID and a.ProcessNo=D.BaseProcessNo and a.FiscalYear=D.BaseFiscalYear and a.SerialNo=D.BaseSerialNo and a.RowNo=D.BaseDocRowNo )	,'''') END 
	,AcntName=CASE WHEN D.BaseProcessID<>610 THEN pub.GetCodeName(D.AcntCode,  @LangID  ) ELSE [prs].[funGetPersonnelName](ISNULL((SELECT TOP 1 OperatorID from pln.tblTaskOrderOperators a WHERE a.ProcessID=D.BaseProcessID and a.ProcessNo=D.BaseProcessNo and a.FiscalYear=D.BaseFiscalYear and a.SerialNo=D.BaseSerialNo and a.RowNo=D.BaseDocRowNo ),''''), @LangID ) END 
	from ##tbl_Store_Described D
	-----------------------------------------------------------------------------------
	DECLARE @FinalWhere AS NVARCHAR (200) = ' WHERE (1=1)'

	IF @ShowSaleBasedBuys = 1
		SET @FinalWhere = @FinalWhere + ' AND SaleFiscalSerial <> '''''
	IF @ShowSaleBasedBuys = 2
		SET @FinalWhere = @FinalWhere + ' AND SaleFiscalSerial = '''''
	IF @ShowSaleBasedBuys = 3
		SET @FinalWhere = @FinalWhere + ' '

		
	set @ProductCount2 =' ProductCount '
	if @ProcessID=70 and (@Inv_ShowBatchNo='True' or @Prd_ProduceBatchNo='True')
		set @ProductCount2='
			(Select Sum(ProductCount2 ) as ProductCount2 from ((Select Distinct BatchNoH ,ProductCount  ProductCount2 FROM ##tbl_Store_Described)) aa) '

	 SET @StrSelect = 
		'SELECT a.*, 
				ISNULL(b.DocDate,'''') SaleOrderDocDate,
				ISNULL(CI.CustomerInfoID,'''') LYL_CustomerInfoID,
				'+str(@chkRetail)+' checkRetail,
				ISNULL(CI.BirthDate,'''') LYL_BirthDate,
				ISNULL(CI.RegisterDate,'''') LYL_RegisterDate,
				ISNULL(CI.MobileNumber,'''') LYL_MobileNumber,
				ISNULL(CI.PhoneNumber,'''') LYL_PhoneNumber,
				ISNULL(CI.Gender,'''') LYL_Gender,
				ISNULL(CID.FirstName,'''') LYL_FirstName,
				ISNULL(CID.LastName,'''') LYL_LastName,
				ISNULL(CID.Adress,'''') LYL_Adress,
				'+@ProductCount2+' ProductCount2,
				'+ str(@Inv_ShowBatchNo) +' Inv_ShowBatchNo,
				'+ str(@Prd_ProduceBatchNo) +' Prd_ProduceBatchNo
		FROM ##tbl_Store_Described a
		LEFT JOIN sal.tblSaleOrderHdr b ON a.BaseProcessID = b.ProcessID 
									   AND a.BaseProcessNo = b.ProcessNo 
									   AND a.BaseFiscalYear = b.FiscalYear 
									   AND a.BaseSerialNo=b.SerialNo 
		LEFT JOIN lyl.tblCustomerInfo CI ON CI.CustomerInfoID = a.OrderAcntCode		
		LEFT JOIN lyl.tblCustomerInfoDtl CID ON CID.CustomerInfoID = a.OrderAcntCode 
											 AND CID.LanguageID=' + LTrim(RTrim(@LangID)) + '
		' + @FinalWhere + '
		ORDER BY ' + @SortFields
	 
	print @StrSelect
	Exec sp_executesql @StrSelect;

END
GO
