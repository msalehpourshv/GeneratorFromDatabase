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
--EXEC [sal].[RptSale_CustomerInfo_Detailed] 90, 1, 95, Null, 95, Null, Null, Null, Null, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, '009', '', '', '', Null, Null
CREATE PROCEDURE [sal].[RptSale_CustomerInfo_Detailed]
	@ProcessID			Int = 90,  -- default is sale
	@ProcessNo			Int = Null,
	@FiscalYearFr		Int = Null,
	@SerialNoFr			Int = Null,
	@FiscalYearTo		Int = Null,
	@SerialNoTo			Int = Null,
	@DocDateFr			VarChar(60) = Null,
	@DocDateTo			VarChar(60) = Null,
	@SaleTypeID			VarChar(20) = Null, -- کد نوع فروش
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
	@CustomerInfoID		VarChar(20) = Null,
	@LoyalCardNo		VarChar(20) = Null,
	@RepOptions			VarChar(50) = '', -- bit array options
	@RepInfo			NVarChar(100) = Null,
	@SortFields			NVarChar(100) = Null,
	@ExtraParams		NVarChar(2000) = Null
WITH ENCRYPTION
AS 
---- Declarations ---------------
DECLARE @StrSelect				NVarChar(Max);
DECLARE @StrSelect2				NVarChar(Max);
DECLARE @StrSelect3				NVarChar(Max);
DECLARE @StrFrom				NVarChar(Max);
DECLARE @StrWhere				NVarChar(Max);
DECLARE @StrWhereRet			NVarChar(Max);
DECLARE @StrRetPID				VarChar(3);
DECLARE @StrPID		    		VarChar(20);
DECLARE @StrDocDesc				NVarChar(600);

DECLARE @ShowQuantity	Bit;  -- شامل ستون مقدار
DECLARE @ShowPrice		Bit;  -- شامل ستون قیمت
DECLARE @DecReturn		Bit;  -- کسر برگشتیها
DECLARE @UseAmount		Bit;  -- Use Amount Filed Instead of Price

DECLARE	@LangID		Char(1);
DECLARE	@SessionNo	Int;
DECLARE	@ReportID	Int;
DECLARE	@UserID		Int;
DECLARE	@UserIsAdmin bit;

DECLARE @Dist0				NVarChar(20); -- DriverID
DECLARE @Dist1				NVarChar(20); -- DistributerID1
DECLARE @Dist2				NVarChar(20); -- DistributerID2
DECLARE @Dist3				NVarChar(20); -- BaseDistributionProcessID
DECLARE @Dist4				NVarChar(20); -- BaseDistributionProcessNo
DECLARE @Dist5				NVarChar(20); -- BaseDistributionFiscalYear fr
DECLARE @Dist6				NVarChar(20); -- BaseDistributionSerialNo   fr
DECLARE @Dist7				NVarChar(20); -- BaseDistributionFiscalYear to
DECLARE @Dist8				NVarChar(20); -- BaseDistributionSerialNo   to
DECLARE @CustKind			VarChar(20);
DECLARE @Location			VarChar(20);
DECLARE @UserIDEx			VarChar(10);
DECLARE @SelectedProduct	int;
DECLARE @IsReward			int;

DECLARE @RefDocFYFr			int;
DECLARE @RefDocSNFr			int;
DECLARE @RefDocFYTo			int;
DECLARE @RefDocSNTo			int;
DECLARE @BuyTypeID			varchar(20);
DECLARE @IsCurrency			Bit;
DECLARE @FilterByServices	Bit;
DECLARE @SH					NVarChar(50);
DECLARE @SD					NVarChar(50);
DECLARE @SerialsField		NVarChar(max);
DECLARE @VATY				bit;
DECLARE @VATN				bit;
DECLARE @RefY				Bit;
DECLARE @RefN				Bit;
DECLARE @Rewd				Bit;
DECLARE @Discounted			bit;
DECLARE @DiscountedX		bit;

DECLARE @TransporterID		NVarChar(20);
DECLARE @StoreVar1			float;

DECLARE @bolSaleAndRet			Bit;
DECLARE @HaveCardDiscountNo		Bit;
DECLARE @GoodsWithTaxToll		Bit;
DECLARE @GoodsWithoutTaxToll	Bit;

DECLARE @AllContentsReturned	Bit;

DECLARE @SaleRetsWithDiscounts	Bit;
DECLARE @strCustomerInfoID		VARCHAR(20)

DECLARE @Layer1			int;
DECLARE @Layer2			int;
DECLARE @Layer3			int;
DECLARE @Layer4			int;
DECLARE @Layer5			int;

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
	
	-- Init -------------------------------------------------
	IF (@RepOptions Is Null)		SET @RepOptions = '11';
	IF (@RepInfo Is Null)			SET @RepInfo = '1@1@1';
	IF (@ProcessNo Is Null)			SET @ProcessNo = 1;

	IF (@DocDateFr	Is Null)		SET @DocDateFr = '@@@';
	IF (@DocDateTo	Is Null)		SET @DocDateTo = '@@@';
	IF (@SelectedGoods Is Null)		SET @SelectedGoods = 0;
	IF (@SelectedStore Is Null)		SET @SelectedStore = 0;
	IF (@SelectedAcnt1 Is Null)		SET @SelectedAcnt1 = 0;
	IF (@SelectedAcnt2 Is Null)		SET @SelectedAcnt2 = 0;
	IF (@SelectedAcnt3 Is Null)		SET @SelectedAcnt3 = 0;
	IF (@SelectedAcnt4 Is Null)		SET @SelectedAcnt4 = 0;
	IF (@SelectedVisitor1 Is Null)	SET @SelectedVisitor1 = 0;
	IF (@SelectedVisitor2 Is Null)	SET @SelectedVisitor2 = 0;
	IF (@SelectedVisitor3 Is Null)	SET @SelectedVisitor3 = 0;
	IF (@SelectedVisitor4 Is Null)	SET @SelectedVisitor4 = 0;
	
	IF (@FiscalYearFr Is Null)	SET @SerialNoFr = Null;
	IF (@FiscalYearTo Is Null)	SET @SerialNoTo = Null;
	IF (@SerialNoFr	Is Null)	SET @FiscalYearFr = Null;
	IF (@SerialNoTo	Is Null)	SET @FiscalYearTo = Null;
	SET @SelectedProduct = 0;

	SET @LangID			 = pub.funSplitString(@RepInfo, '@', 1);
	SET @SessionNo		 = pub.funSplitString(@RepInfo, '@', 2);
	SET @ReportID		 = pub.funSplitString(@RepInfo, '@', 3);
	SET @UserID			 = pub.funSplitString(@RepInfo, '@', 4);
	SET @UserIsAdmin	 = pub.funSplitString(@RepInfo, '@', 5);

	SET @CustKind		 = LTrim(pub.funSplitString(@ExtraParams, '@', 2)); 
	SET @UserIDEx		 = LTrim(pub.funSplitString(@ExtraParams, '@', 3));
	SET @RefDocFYFr		 = LTrim(pub.funSplitString(@ExtraParams, '@', 4));
	SET @RefDocSNFr		 = LTrim(pub.funSplitString(@ExtraParams, '@', 5));
	SET @RefDocFYTo		 = LTrim(pub.funSplitString(@ExtraParams, '@', 6));
	SET @RefDocSNTo		 = LTrim(pub.funSplitString(@ExtraParams, '@', 7));
	SET @IsReward		 = LTrim(pub.funSplitString(@ExtraParams, '@', 8));

	SET @DecReturn				= Substring(@RepOptions, 1, 1)
	SET @HaveCardDiscountNo	 	= Substring(@RepOptions, 2, 1)
	SET @GoodsWithTaxToll	 	= Substring(@RepOptions, 3, 1)
	SET @GoodsWithoutTaxToll 	= Substring(@RepOptions, 4, 1)
	SET @VATY					= Substring(@RepOptions, 5, 1)
	SET @RefY					= Substring(@RepOptions, 6, 1)
	SET @RefN					= Substring(@RepOptions, 7, 1)
	SET @Rewd					= Substring(@RepOptions, 8, 1)
	SET @VATN					= Substring(@RepOptions, 9, 1)
	SET @Discounted				= Substring(@RepOptions, 10, 1)
	SET @DiscountedX			= Substring(@RepOptions, 11, 1)	
	SET @FilterByServices	 	= Substring(@RepOptions, 12, 1)

	---------------------------------------------------------
	SET @strCustomerInfoID = ''
	IF (@LoyalCardNo <> '' And @LoyalCardNo Is Not Null)
	Begin
		SELECT TOP 1 @strCustomerInfoID = CustomerInfoID
		FROM 	lyl.tblLoyalCardDtl
		WHERE IsActive ='True' AND LoyalCardNo = @LoyalCardNo
		ORDER BY DocDate DESC
	End
	
	IF @ProcessID = 90
		SET @StrPID = '90'
		
	IF (@CustomerInfoID = '' OR @CustomerInfoID Is Null) And @strCustomerInfoID <> ''
		SET @CustomerInfoID = @strCustomerInfoID
	---------------------------------------------------------
	--Print @bolSaleAndRet
	-- Where Clause -----------------------------------------
	Set @StrWhere = 'H.ProcessID In (' + LTrim(RTrim(@StrPID)) + ') And H.ProcessNo = ' + LTrim(RTrim(Str(@ProcessNo)))
	Set @StrWhereRet = 'H.ProcessID = 100 And H.ProcessNo = ' + LTrim(RTrim(Str(@ProcessNo)))
	
	IF (@RefY = 0) And (@RefN = 1)
		set @StrWhere = @StrWhere + ' AND (H.BaseSerialNo = 0)'
	IF (@RefN = 0) And (@RefY = 1)
		set @StrWhere = @StrWhere + ' AND (H.BaseSerialNo <> 0)'

	IF (@Rewd = 1)
		set @StrWhere = @StrWhere + ' AND (D.IsReward = 1)'

	IF (@VATY = 1)
		Set @StrWhere = @StrWhere + ' AND (H.TaxOverWorthCost > 0)'
		
	IF (@VATN = 1)
		Set @StrWhere = @StrWhere + ' AND (H.TaxOverWorthCost = 0)'

	IF (@Discounted = 1)
		Set @StrWhere = @StrWhere + ' AND ((H.Discount+H.Discount2+H.Discount3+H.TotalLineDiscount) > 0)'

	IF (@DiscountedX = 1)
		Set @StrWhere = @StrWhere + ' AND (H.AfterSaleDiscount > 0)'

	IF (@FilterByServices = 1)
		Set @StrWhere = @StrWhere + ' And G.IsService = 1 '
					
	IF (@CustKind <> '') And (@CustKind Is Not Null)
		Set @StrWhere = @StrWhere + ' AND (pub.funGetCustomerKindID(H.AcntCode) = ''' + @CustKind + ''')'

	IF (@Location <> '')
		Set @StrWhere = @StrWhere + ' AND (Left(H.LocationID, ' + str(len(@Location)) + ') >= ''' + @Location + ''')'

	IF (@SerialNoFr Is Not Null) And (@SerialNoFr <> '0')
		Set @StrWhere = @StrWhere + ' AND (H.FiscalYear > ' + LTrim(Str(@FiscalYearFr)) + ' OR (H.FiscalYear = ' + LTrim(Str(@FiscalYearFr)) + ' AND H.SerialNo >= ' + LTrim(Str(@SerialNoFr)) + '))' 
	IF (@SerialNoTo Is Not Null) And (@SerialNoTo <> '0')
		Set @StrWhere = @StrWhere + ' AND (H.FiscalYear < ' + LTrim(Str(@FiscalYearTo)) + ' OR (H.FiscalYear = ' + LTrim(Str(@FiscalYearTo)) + ' AND H.SerialNo <= ' + LTrim(Str(@SerialNoTo)) + '))' 

	IF (@DocDateFr Is Not Null) AND (@DocDateFr <> '@@@') AND (@DocDateFr <> '')
		SET @StrWhere = @StrWhere + ' AND ' + inv.funGetDateFilter(@DocDateFr, '>=', 'H.DocDate', 'H.DocDate2', 'H.DocDate3', 'H.DocDate4')
	IF (@DocDateTo Is Not Null) AND (@DocDateTo <> '@@@') AND (@DocDateTo <> '')
		SET @StrWhere = @StrWhere + ' AND ' + inv.funGetDateFilter(@DocDateTo, '<=', 'H.DocDate', 'H.DocDate2', 'H.DocDate3', 'H.DocDate4')

	IF (@RefDocSNFr <> 0)
		Set @StrWhere = @StrWhere + ' AND (H.BaseFiscalYear > ' + LTrim(Str(@RefDocFYFr)) + ' OR (H.BaseFiscalYear = ' + LTrim(Str(@RefDocFYFr)) + ' AND H.BaseSerialNo >= ' + LTrim(Str(@RefDocSNFr)) + '))' 
	IF (@RefDocSNTo <> 0)
		Set @StrWhere = @StrWhere + ' AND (H.BaseFiscalYear < ' + LTrim(Str(@RefDocFYTo)) + ' OR (H.BaseFiscalYear = ' + LTrim(Str(@RefDocFYTo)) + ' AND H.BaseSerialNo <= ' + LTrim(Str(@RefDocSNTo)) + '))' 
	
	--IF (@IsReward = 0)
	--	Set @StrWhere = @StrWhere + ' AND (H.IsReward = 0) ' 
	--IF (@IsReward = 1)
	--	Set @StrWhere = @StrWhere + ' AND (H.IsReward = 1) ' 
	
	IF @SaleTypeID Is Not Null And @SaleTypeID <> ''
		Set @StrWhere = @StrWhere + ' AND (H.SaleTypeID = ''' + @SaleTypeID + ''')'
	IF (@BuyTypeID <> '')
		Set @StrWhere = @StrWhere + ' AND (H.SaleTypeID = ''' + @BuyTypeID + ''')'

	IF (@SelectedProduct > 0)
		IF (@ProcessID = 80 Or @ProcessID = 85)
			SET @StrWhere = @StrWhere + ' AND ' + pub.funGetFilterString(@SessionNo, @ReportID, @SelectedProduct, 'H.GoodsID') 
		Else
			SET @StrWhere = @StrWhere + ' AND ' + pub.funGetFilterString(@SessionNo, @ReportID, @SelectedProduct, 'H.ProductID') 

	IF (@SelectedGoods > 0)
	begin
		IF (@ProcessID = 80 Or @ProcessID = 85)
			SET @StrWhere = @StrWhere + ' AND H.GoodsID in (Select ProductID from prd.tblFormulasDtl where ' + pub.funGetFilterString(@SessionNo, @ReportID, @SelectedGoods, 'GoodsID') +')' 
		else
			SET @StrWhere = @StrWhere + ' AND ' + pub.funGetFilterString(@SessionNo, @ReportID, @SelectedGoods, 'H.GoodsID') 
	end
	
	IF (@SelectedStore > 0)
	begin
		SET @StrWhere = @StrWhere + ' AND ' + pub.funGetFilterString(@SessionNo, @ReportID, @SelectedStore, 'H.StoreID') 
	end
	
	IF (@SelectedAcnt1 > 0)
		SET @StrWhere = @StrWhere + ' AND ' + pub.funGetFilterString(@SessionNo, @ReportID, @SelectedAcnt1, 'H.AcntCode')
	IF (@SelectedAcnt2 > 0)
		SET @StrWhere = @StrWhere + ' AND ' + pub.funGetFilterString(@SessionNo, @ReportID, @SelectedAcnt2, 'H.AcntCode')
	IF (@SelectedAcnt3 > 0)
		SET @StrWhere = @StrWhere + ' AND ' + pub.funGetFilterString(@SessionNo, @ReportID, @SelectedAcnt3, 'H.AcntCode')
	IF (@SelectedAcnt4 > 0)
		SET @StrWhere = @StrWhere + ' AND ' + pub.funGetFilterString(@SessionNo, @ReportID, @SelectedAcnt4, 'H.AcntCode')

	IF (@SelectedVisitor1 > 0)
		SET @StrWhere = @StrWhere + ' AND (' + pub.funGetFilterString(@SessionNo, @ReportID, @SelectedVisitor1, 'H.VisitorAcntCode') + ')'
	IF (@SelectedVisitor2 > 0)
		SET @StrWhere = @StrWhere + ' AND (' + pub.funGetFilterString(@SessionNo, @ReportID, @SelectedVisitor2, 'H.VisitorAcntCode') + ')'
	IF (@SelectedVisitor3 > 0)
		SET @StrWhere = @StrWhere + ' AND (' + pub.funGetFilterString(@SessionNo, @ReportID, @SelectedVisitor3, 'H.VisitorAcntCode') + ')'
	IF (@SelectedVisitor4 > 0)
		SET @StrWhere = @StrWhere + ' AND (' + pub.funGetFilterString(@SessionNo, @ReportID, @SelectedVisitor4, 'H.VisitorAcntCode') + ')'

	IF (@UserIDEx <> '' and @UserIDEx <> '-1')
		SET @StrWhere = @StrWhere + ' AND (U.SessionNo = H.SessionNo)'
		
	IF (@TransporterID <> '')
		Set @StrWhere = @StrWhere + ' AND (H.TransporterID = ''' + Ltrim(@TransporterID) + ''')'		

	IF (@StoreVar1 <> '0')
		Set @StrWhere = @StrWhere + ' AND (D.StoreVariable1 = ' + Ltrim(@StoreVar1) + ')'		

	IF (@HaveCardDiscountNo = 1)
	Begin
		Set @StrWhere = @StrWhere + ' AND H.CCNo <> '''''
		Set @StrWhereRet = @StrWhereRet + ' AND H.CCNo <> '''''
	End
	
	IF (@FilterByServices = 1)
		Set @StrWhere = @StrWhere + ' AND G.IsService = 1 '
		
	IF (@GoodsWithTaxToll = 1 And @GoodsWithoutTaxToll = 0)
		Set @StrWhere = @StrWhere + ' AND G.ContainTax = 1 '		
		
	IF (@GoodsWithoutTaxToll = 1 And @GoodsWithTaxToll = 0)
		Set @StrWhere = @StrWhere + ' AND G.ContainTax = 0 '				
		
	IF @LoyalCardNo <> '' And @LoyalCardNo Is Not Null
	Begin
		Set @StrWhere = @StrWhere + ' AND C.LoyalCardNo = ''' + LTrim(RTrim(@LoyalCardNo)) + ''''				
		Set @StrWhereRet = @StrWhereRet + ' AND H.CCNo = ''' + LTrim(RTrim(@LoyalCardNo)) + ''''				
	End
		
	IF @CustomerInfoID <> '' And @CustomerInfoID Is Not Null
		Set @StrWhere = @StrWhere + ' AND SUBSTRING(C.CustomerInfoID, 1, Len(''' + @CustomerInfoID + ''')) = ''' + LTrim(RTrim(@CustomerInfoID)) + ''''
			
	-- ==========================================================
	SET @StrSelect = '
	SELECT A.CustomerInfoID2, A.GroupName2, A.DefaultPrivilege, A.TotalAmount, A.GoodsQuantity, A.CCPrivilege TotalPrivilege,
		   IsNull((CCDiscount / DiscountAmount) * ForEachScore,0) UsedPrivilege, A.LoyalCardNo,
		   (IsNull(CCPrivilege,0) + IsNull(DefaultPrivilege,0)) - IsNull((CCDiscount / DiscountAmount) * ForEachScore,0) PrivilegeRemain,
		   A.LastBuyDate
	FROM (
			Select 
				  (SELECT Top 1 ISNULL(CC.CustomerInfoID, '''') From lyl.tblCustomerInfo CC
				   WHERE CC.CustomerInfoID = SUBSTRING(C.CustomerInfoID, 1, LEN(CC.CustomerInfoID))
				   ORDER BY LEN(C.CustomerInfoID)) CustomerInfoID,
				  (SELECT Top 1 ISNULL(FirstName + '' '' + LastName, '''') From lyl.tblCustomerInfo CC
				   Inner Join lyl.tblCustomerInfoDtl CD ON CC.CustomerInfoID = CD.CustomerInfoID
				   WHERE CC.CustomerInfoID = SUBSTRING(C.CustomerInfoID, 1, LEN(CC.CustomerInfoID))
				   ORDER BY LEN(C.CustomerInfoID)) GroupName,
				   C.CustomerInfoID CustomerInfoID2,
				  (SELECT Top 1 ISNULL(FirstName + '' '' + LastName, '''') From lyl.tblCustomerInfoDtl CD 
				   WHERE CD.CustomerInfoID = C.CustomerInfoID) GroupName2, C.LoyalCardNo,
				  (SELECT Top 1 ISNULL(DefaultPrivilege ,0)
				   FROM lyl.tblCustomerInfo
				   WHERE CustomerInfoID = SUBSTRING(C.CustomerInfoID, 1, LEN(CustomerInfoID)) And ISNULL(DefaultPrivilege ,0) <> 0
				   ORDER BY LEN(CustomerInfoID) Desc) DefaultPrivilege,
				  (SELECT Top 1 ISNULL(DefaultPrivilegeDate ,'''')
				   FROM lyl.tblCustomerInfo
				   WHERE CustomerInfoID = SUBSTRING(C.CustomerInfoID, 1, LEN(CustomerInfoID)) And ISNULL(DefaultPrivilege ,0) <> 0
				   ORDER BY LEN(CustomerInfoID) Desc) DefaultPrivilegeDate,
				  (SELECT Top 1 ISNULL(C.RegisterDate, '''') From lyl.tblCustomerInfo C
				   Inner Join lyl.tblCustomerInfoDtl CD ON C.CustomerInfoID = CD.CustomerInfoID
				   WHERE C.CustomerInfoID = SUBSTRING(C.CustomerInfoID, 1, LEN(C.CustomerInfoID))
				   ORDER BY LEN(C.CustomerInfoID)) RegisterDate,'
	SET @StrSelect2 = '
				  ((Select IsNull(Sum(CCDiscount),0)
				   From inv.tblStorageDocsHdr H
				   Where H.ProcessID = ' + LTrim(RTrim(Str(@ProcessID))) + ' And H.ProcessNo = ' + LTrim(RTrim(Str(@ProcessNo))) + ' And 
						 H.CCNo = C.LoyalCardNo) - 
				  (Select IsNull(Sum(CCDiscount),0)
				   From inv.tblStorageDocsHdr H
				   Where H.ProcessID = 100 And H.ProcessNo = ' + LTrim(RTrim(Str(@ProcessNo))) + ' And 
						 H.CCNo = C.LoyalCardNo)) CCDiscount,
				  ((Select IsNull(Sum(CCPrivilege),0)
				   From inv.tblStorageDocsHdr H
				   Where H.ProcessID = ' + LTrim(RTrim(Str(@ProcessID))) + ' And H.ProcessNo = ' + LTrim(RTrim(Str(@ProcessNo))) + ' And
						 H.CCNo = C.LoyalCardNo) - 
				  (Select IsNull(Sum(CCPrivilege),0)
				   From inv.tblStorageDocsHdr H
				   Where H.ProcessID = 100 And H.ProcessNo = ' + LTrim(RTrim(Str(@ProcessNo))) + ' And
						 H.CCNo = C.LoyalCardNo)) CCPrivilege,
				   IsNull(Sum(H.GoodsQuantity),0) - IsNull(Sum(HD.GoodsQuantity),0) GoodsQuantity,
				   IsNull(Sum(H.GoodsPrice * H.GoodsQuantity),0) - IsNull(Sum(HD.GoodsPrice * HD.GoodsQuantity),0) TotalAmount,
				  (Select DiscountAmount From lyl.tblLoyalCarnivalInfoHdr
				   Where CustomerInfoID = SUBSTRING(''' + @CustomerInfoID + ''', 1, LEN(CustomerInfoID))) DiscountAmount,
				  (Select ForEachScore From lyl.tblLoyalCarnivalInfoHdr
				   Where CustomerInfoID = SUBSTRING(''' + @CustomerInfoID + ''', 1, LEN(CustomerInfoID))) ForEachScore,
				  (Select Top 1 H.DocDate
				   From inv.tblStorageDocsHdr H
				   Where ProcessID = 90 And ProcessNo = 1 And H.CCNo = C.LoyalCardNo
				   Order By H.DocDate Desc) LastBuyDate
			FROM lyl.tblLoyalCardDtl C
			INNER JOIN
			(Select H.ProcessID, H.ProcessNo, H.FiscalYear, H.SerialNo, H.BaseFiscalYear, H.BaseSerialNo, H.CCNo, D.AcntCode, 
					D.VisitorAcntCode, H.DocDate, H.SaleTypeID, D.GoodsID, D.StoreID, H.TaxOverWorthCost, H.AfterSaleDiscount, 
					H.Discount, H.Discount2+H.Discount3 Discount2, H.TotalLineDiscount, D.IsReward,
					Sum(D.GoodsQuantity) GoodsQuantity, Sum(D.GoodsPrice) GoodsPrice
			 From inv.tblStorageDocsHdr H
			 Inner Join inv.tblStorageDocsDtl D ON D.ProcessID = H.ProcessID And D.ProcessNo = H.ProcessNo And
												   D.FiscalYear = H.FiscalYear And D.SerialNo = H.SerialNo 
			 Where H.ProcessID = 90 And H.ProcessNo = ' + LTrim(RTrim(Str(@ProcessNo))) + '
			 GROUP BY H.ProcessID, H.ProcessNo, H.FiscalYear, H.SerialNo, H.BaseFiscalYear, H.BaseSerialNo, H.CCNo, D.AcntCode, 
					  D.VisitorAcntCode, H.DocDate, H.SaleTypeID, D.GoodsID, D.StoreID, H.TaxOverWorthCost, H.AfterSaleDiscount, 
					  H.Discount, H.Discount2, H.Discount3, H.TotalLineDiscount, D.IsReward
			 ) H ON C.LoyalCardNo = H.CCNo'
	SET @StrSelect3 = '
			Left Join 
			(
			 Select H.ProcessID, H.ProcessNo, H.FiscalYear, H.SerialNo, H.CCNo, Sum(D.GoodsQuantity) GoodsQuantity, 
					Sum(D.GoodsPrice) GoodsPrice
			 From inv.tblStorageDocsHdr H
			 Inner Join inv.tblStorageDocsDtl D ON D.ProcessID = H.ProcessID And D.ProcessNo = H.ProcessNo And
												   D.FiscalYear = H.FiscalYear And D.SerialNo = H.SerialNo
			 Where ' + @StrWhereRet + '
			 Group By H.ProcessID, H.ProcessNo, H.FiscalYear, H.SerialNo, H.CCNo
			 ) HD ON HD.CCNo = H.CCNo
			Left Join  lyl.tblCustomerInfo CI ON CI.CustomerInfoID = C.CustomerInfoID
			Inner Join  inv.tblGoods G ON G.GoodsID = H.GoodsID
			Where ' + @StrWhere + '
			Group By C.CustomerInfoID, CI.RegisterDate, C.LoyalCardNo
			) A
			Group By A.CustomerInfoID2, A.GroupName2, A.DefaultPrivilege, A.CCPrivilege, A.DiscountAmount, A.ForEachScore, 
					 A.TotalAmount, A.GoodsQuantity, A.LastBuyDate, A.LoyalCardNo, A.CCDiscount'

	-- ==========================================================
	-- RUN -----------------------------------------------------
	Print @StrSelect;
	Print @StrSelect2;
	Print @StrSelect3;
	
	SET @StrSelect = @StrSelect + @StrSelect2 + @StrSelect3;
	Exec sp_executesql @StrSelect;
	-- ==========================================================
End
GO
