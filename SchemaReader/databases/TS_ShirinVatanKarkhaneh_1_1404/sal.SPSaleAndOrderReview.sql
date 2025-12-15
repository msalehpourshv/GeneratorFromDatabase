USE TS_ShirinVatanKarkhaneh_1_1404
GO
SET ANSI_NULLS, QUOTED_IDENTIFIER ON
GO
-- =========== TS-QC:NOTOK ========================
-- Author        : Jafari
-- Create date   : 1402/04/06
-- Viewed By	 : 
-- Last Modified : 
-- Description   : 
-- =============================================
Create PROCEDURE sal.SPSaleAndOrderReview 
@ExtraParams		NVarChar(Max) = '',
@RepInfo			NVarChar(100) = '1@1@1'
WITH ENCRYPTION
AS
begin

DECLARE @StrSelect11	NVarChar(max)
DECLARE @StrSelect12	NVarChar(max)
DECLARE @StrSelect2		NVarChar(max)
DECLARE @StrSelect31	NVarChar(max)
DECLARE @StrSelect32	NVarChar(max)
DECLARE @StrSelect4		NVarChar(max)
DECLARE @StrWhere		NVarChar(max)
DECLARE @StrWhereD		NVarChar(max)
DECLARE @StrWhereSD		NVarChar(max) = ''
DECLARE @StrDiscountSale	NVarChar(500) = ''
DECLARE @StrDiscountOrder	NVarChar(500) = ''

DECLARE @FYFR90		int  
DECLARE @FYTO90		int 
DECLARE @SNFR90		int
DECLARE @SNTo90		int

DECLARE @FYFR100	int  
DECLARE @FYTO100	int 
DECLARE @SNFR100	int
DECLARE @SNTo100	int

DECLARE @FYFR180	int  
DECLARE @FYTO180	int 
DECLARE @SNFR180	int
DECLARE @SNTo180	int

DECLARE @FYFR185	int  
DECLARE @FYTO185	int 
DECLARE @SNFR185	int
DECLARE @SNTo185	int

DECLARE @DocDateFR	char(10)
DECLARE @DocDateTo	char(10)

DECLARE @ProcessNo	Varchar(100)
DECLARE @ProcessID	Varchar(100)

DECLARE @UnitPart		TINYINT
DECLARE @str_Goods		TINYINT
DECLARE @str_GoodsSum	TINYINT
DECLARE @Layer1	TINYINT
DECLARE @Layer2	TINYINT
DECLARE @Layer3	TINYINT
DECLARE @Layer4	TINYINT
DECLARE @Layer5	TINYINT
DECLARE @Layer6	TINYINT
DECLARE @Layer7	TINYINT
DECLARE @Layer8	TINYINT
DECLARE @Layer9	TINYINT
DECLARE @PriceDecimalsToForms	TINYINT
DECLARE @QuantityDecimalsToForms	TINYINT
DECLARE	@LangID			Char(1);
DECLARE	@SessionNo		Int; 
DECLARE	@ReportID		Int;
DECLARE	@UserID			Int;
DECLARE	@UserIsAdmin	bit;
DECLARE	@AcntCode1		Varchar(20);
DECLARE	@AcntCode2		Varchar(20);
DECLARE	@AcntCode3		Varchar(20);
DECLARE	@AcntCode4		Varchar(20);
DECLARE	@Visitor1  		Varchar(20);
DECLARE	@Visitor2  		Varchar(20);
DECLARE	@Visitor3  		Varchar(20);
DECLARE	@Visitor4  		Varchar(20);
DECLARE	@StoreID		Varchar(20);
DECLARE	@GoodsID		Varchar(20);
DECLARE	@SaleTypeID		Varchar(20);
DECLARE	@CustomerKindID	Varchar(20);
DECLARE	@chkHasVchNo	Bit;
DECLARE	@chkHasNVchNo	Bit;
DECLARE	@chkTPCanceled	Bit;
DECLARE	@chkDistributeHdrDiscount	Bit;



SET @LangID		= pub.funSplitString(@RepInfo, '@', 1);
SET @SessionNo	= pub.funSplitString(@RepInfo, '@', 2);
SET @ReportID	= pub.funSplitString(@RepInfo, '@', 3);
SET @UserID		= pub.funSplitString(@RepInfo, '@', 4);
SET @UserIsAdmin= pub.funSplitString(@RepInfo, '@', 5);

	SELECT @PriceDecimalsToForms	= SettingValue FROM pub.tblSettings WHERE SettingKey = 'PriceDecimalsToForms'
	SELECT @QuantityDecimalsToForms = SettingValue FROM pub.tblSettings WHERE SettingKey = 'QuantityDecimalsToForms'
	SELECT @UnitPart				= SettingValue FROM pub.tblSettings WHERE SettingKey = 'UnitPart'

	IF @UnitPart IS NULL or @UnitPart = 0
		SET @UnitPart = 1
	
	SELECT @str_Goods= ISNULL(SUM (Layer1+Layer2+Layer3+Layer4+Layer5+Layer6+Layer7+Layer8+Layer9),0)
	FROM pub.tblCodeLayer 
	WHERE TableName = 'inv.tblGoods'
	  AND PartNumber<@UnitPart
			
	SELECT 
		@Layer1 = Layer1
		,  @Layer2 = Layer1+Layer2
		,  @Layer3 = Layer1+Layer2+Layer3
		,  @Layer4 = Layer1+Layer2+Layer3+Layer4
		,  @Layer5 = Layer1+Layer2+Layer3+Layer4+Layer5
		,  @Layer6 = Layer1+Layer2+Layer3+Layer4+Layer5+Layer6
		,  @Layer7 = Layer1+Layer2+Layer3+Layer4+Layer5+Layer6+Layer7
		,  @Layer8 = Layer1+Layer2+Layer3+Layer4+Layer5+Layer6+Layer7+Layer8
		,  @Layer9 = Layer1+Layer2+Layer3+Layer4+Layer5+Layer6+Layer7+Layer8+Layer9
	FROM pub.tblCodeLayer 
	WHERE TableName = 'inv.tblGoods' 
	  AND PartNumber<=@UnitPart

	IF @Layer8=@Layer9
		SET @Layer9=0		
	IF @Layer7=@Layer8
		SET @Layer8=0
	IF @Layer6=@Layer7
		SET @Layer7=0
	IF @Layer5=@Layer6
		SET @Layer6=0
	IF @Layer4=@Layer5
		SET @Layer5=0
	IF @Layer3=@Layer4
		SET @Layer4=0
	IF @Layer2=@Layer3
		SET @Layer3=0
	IF @Layer1=@Layer2
		SET @Layer2=0
 
	SELECT @str_GoodsSum = Layer1+Layer2+Layer3+Layer4+Layer5+Layer6+Layer7+Layer8+Layer9
	FROM pub.tblCodeLayer 
	WHERE TableName = 'inv.tblGoods'
	  AND PartNumber=@UnitPart

	SET  @ProcessID	= LTrim(pub.funSplitString(@ExtraParams, '@', 1)); 
	SET  @ProcessNo	= LTrim(pub.funSplitString(@ExtraParams, '@', 2)); 
	SET  @DocDateFR	= LTrim(pub.funSplitString(@ExtraParams, '@', 3)); 
	SET  @DocDateTo	= LTrim(pub.funSplitString(@ExtraParams, '@', 4)); 
	SET  @FYFR90	= LTrim(pub.funSplitString(@ExtraParams, '@', 5)); 	
	SET  @SNFR90	= LTrim(pub.funSplitString(@ExtraParams, '@', 6)); 	
	SET  @FYTO90	= LTrim(pub.funSplitString(@ExtraParams, '@', 7)); 	
	SET  @SNTo90	= LTrim(pub.funSplitString(@ExtraParams, '@', 8)); 	
	SET  @FYFR100	= LTrim(pub.funSplitString(@ExtraParams, '@', 9)); 
	SET  @SNFR100	= LTrim(pub.funSplitString(@ExtraParams, '@', 10)); 	
	SET  @FYTO100	= LTrim(pub.funSplitString(@ExtraParams, '@', 11)); 
	SET  @SNTo100	= LTrim(pub.funSplitString(@ExtraParams, '@', 12)); 
	SET  @FYFR180	= LTrim(pub.funSplitString(@ExtraParams, '@', 13)); 
	SET  @SNFR180	= LTrim(pub.funSplitString(@ExtraParams, '@', 14)); 	
	SET  @FYTO180	= LTrim(pub.funSplitString(@ExtraParams, '@', 15)); 
	SET  @SNTo180	= LTrim(pub.funSplitString(@ExtraParams, '@', 16)); 
	SET  @FYFR185	= LTrim(pub.funSplitString(@ExtraParams, '@', 17)); 
	SET  @SNFR185	= LTrim(pub.funSplitString(@ExtraParams, '@', 18)); 
	SET  @FYTO185	= LTrim(pub.funSplitString(@ExtraParams, '@', 19)); 
	SET  @SNTo185	= LTrim(pub.funSplitString(@ExtraParams, '@', 20)); 	
	SET  @AcntCode1		= LTrim(pub.funSplitString(@ExtraParams, '@', 21)); 
	SET  @AcntCode2		= LTrim(pub.funSplitString(@ExtraParams, '@', 22)); 
	SET  @AcntCode3		= LTrim(pub.funSplitString(@ExtraParams, '@', 23)); 
	SET  @AcntCode4		= LTrim(pub.funSplitString(@ExtraParams, '@', 24)); 
	SET  @Visitor1		= LTrim(pub.funSplitString(@ExtraParams, '@', 25)); 
	SET  @Visitor2		= LTrim(pub.funSplitString(@ExtraParams, '@', 26)); 
	SET  @Visitor3		= LTrim(pub.funSplitString(@ExtraParams, '@', 27)); 
	SET  @Visitor4		= LTrim(pub.funSplitString(@ExtraParams, '@', 28)); 
	SET  @StoreID		= LTrim(pub.funSplitString(@ExtraParams, '@', 29)); 
	SET  @GoodsID		= LTrim(pub.funSplitString(@ExtraParams, '@', 30)); 
	SET  @SaleTypeID	= LTrim(pub.funSplitString(@ExtraParams, '@', 31)); 
	SET  @CustomerKindID		   = LTrim(pub.funSplitString(@ExtraParams, '@', 32)); 
	SET  @chkHasVchNo			   = LTrim(pub.funSplitString(@ExtraParams, '@', 33)); 
	SET  @chkHasNVchNo			   = LTrim(pub.funSplitString(@ExtraParams, '@', 34)); 
	SET  @chkTPCanceled			   = LTrim(pub.funSplitString(@ExtraParams, '@', 35)); 
	SET  @chkDistributeHdrDiscount = LTrim(pub.funSplitString(@ExtraParams, '@', 36)); 

	SET @StrWhere = ' 1=1 '
	SET @StrWhereD = ''

	IF @ProcessID<>''
		SET @StrWhere = @StrWhere+' AND ' + @ProcessID + ''
	IF @ProcessNo<>''
		SET @StrWhere = @StrWhere+' AND ' + @ProcessNo + ''

	IF @DocDateFR<>'' 
		SET @StrWhere =@StrWhere+ ' AND D.DocDate	>=''' + @DocDateFR + ''''
	IF @DocDateTo<>'' 
		SET @StrWhere = @StrWhere+' AND D.DocDate	<=''' + @DocDateTo + ''''

	IF @DocDateFR<>'' 
		SET @StrWhere =@StrWhere+ ' AND D.DocDate	>=''' + @DocDateFR + ''''
	IF @DocDateTo<>'' 
		SET @StrWhere = @StrWhere+' AND D.DocDate	<=''' + @DocDateTo + ''''
	
	IF @FYFR90>0
		SET @StrWhere =@StrWhere+ ' AND D.ProcessID =90 AND  D.FiscalYear>=' +str(@FYFR90)
	IF @SNFR90>0
		SET @StrWhere = @StrWhere+' AND D.SerialNo  >=' +str(@SNFR90)
	IF @FYTO90>0
		SET @StrWhere =@StrWhere+ ' AND D.ProcessID =90 AND D.FiscalYear<=' +str(@FYTO90)
	IF @SNTo90>0
		SET @StrWhere = @StrWhere+' AND D.SerialNo	<=' +str(@SNTo90)
	
	IF @FYFR100>0
		SET @StrWhere =@StrWhere+ ' AND D.ProcessID =100 AND D.FiscalYear>=' +str(@FYFR100)
	IF @SNFR100>0
		SET @StrWhere = @StrWhere+' AND D.SerialNo  >=' +str(@SNFR100)
	IF @FYTO100>0
		SET @StrWhere =@StrWhere+ ' AND D.ProcessID =100 AND D.FiscalYear<=' +str(@FYTO100)
	IF @SNTo100>0
		SET @StrWhere = @StrWhere+' AND D.SerialNo	<=' +str(@SNTo100)
	
	IF @FYFR180>0
		SET @StrWhere =@StrWhere+ ' AND D.ProcessID =180 AND D.FiscalYear>=' +str(@FYFR180)
	IF @SNFR180>0
		SET @StrWhere = @StrWhere+' AND D.SerialNo  >=' +str(@SNFR180)
	IF @FYTO180>0
		SET @StrWhere =@StrWhere+ ' AND D.ProcessID =180 AND D.FiscalYear<=' +str(@FYTO180)
	IF @SNTo180>0
		SET @StrWhere = @StrWhere+' AND D.SerialNo	<=' +str(@SNTo180)
	
	IF @FYFR185>0
		SET @StrWhere =@StrWhere+ ' AND D.ProcessID =185 AND D.FiscalYear>=' +str(@FYFR185)
	IF @SNFR185>0
		SET @StrWhere = @StrWhere+' AND D.SerialNo  >=' +str(@SNFR185)
	IF @FYTO185>0
		SET @StrWhere =@StrWhere+ ' AND D.ProcessID =185 AND D.FiscalYear<=' +str(@FYTO185)
	IF @SNTo185>0
		SET @StrWhere = @StrWhere+' AND D.SerialNo	<=' +str(@SNTo185)

	IF (@AcntCode1 > 0)
		SET @StrWhere = @StrWhere + ' AND ' + pub.funGetFilterString(@SessionNo, @ReportID, @AcntCode1, 'H.AcntCode')
	
	IF (@AcntCode2 > 0)
		SET @StrWhere = @StrWhere + ' AND ' + pub.funGetFilterString(@SessionNo, @ReportID, @AcntCode2, 'H.AcntCode')
	
	IF (@AcntCode3 > 0)
		SET @StrWhere = @StrWhere + ' AND ' + pub.funGetFilterString(@SessionNo, @ReportID, @AcntCode3, 'H.AcntCode')
	
	IF (@AcntCode4 > 0)	
		SET @StrWhere = @StrWhere + ' AND ' + pub.funGetFilterString(@SessionNo, @ReportID, @AcntCode4, 'H.AcntCode')
	
	IF (@Visitor1 > 0)
		SET @StrWhere = @StrWhere + ' AND ' + pub.funGetFilterString(@SessionNo, @ReportID, @Visitor1, 'H.VisitorAcntCode')
	
	IF (@Visitor2 > 0)
		SET @StrWhere = @StrWhere + ' AND ' + pub.funGetFilterString(@SessionNo, @ReportID, @Visitor2, 'H.VisitorAcntCode')
	
	IF (@Visitor3 > 0)
		SET @StrWhere = @StrWhere + ' AND ' + pub.funGetFilterString(@SessionNo, @ReportID, @Visitor3, 'H.VisitorAcntCode')
	
	IF (@Visitor4 > 0)
		SET @StrWhere = @StrWhere + ' AND ' + pub.funGetFilterString(@SessionNo, @ReportID, @Visitor4, 'H.VisitorAcntCode')

	IF (@StoreID > 0)
		SET @StrWhere = @StrWhere + ' AND ' + pub.funGetFilterString(@SessionNo, @ReportID, @StoreID, 'H.StoreID')
	
	IF (@GoodsID > 0)
		SET @StrWhereD = @StrWhereD + ' AND ' + pub.funGetFilterString(@SessionNo, @ReportID, @GoodsID, 'D.GoodsID')

	IF (@SaleTypeID> 0)
		SET @StrWhere = @StrWhere + ' AND ' + pub.funGetFilterString(@SessionNo, @ReportID, @SaleTypeID, 'H.SaleTypeID')
	
	IF (@CustomerKindID> 0)
		SET @StrWhere = @StrWhere + ' AND ' + pub.funGetFilterString(@SessionNo, @ReportID, @CustomerKindID, 'F.CustomerKindID')	

	IF @chkHasVchNo <> @chkHasNVchNo
	BEGIN
		If (@chkHasVchNo > 0)
		BEGIN
			SET @StrWhere = @StrWhere + ' AND ((D.ProcessID IN (90,100) AND H.VchNo > 0) OR D.ProcessID not IN (90,100) )'	
		END
		IF (@chkHasNVchNo > 0)
		BEGIN
			SET @StrWhere = @StrWhere + ' AND ((D.ProcessID IN (90,100) AND H.VchNo = 0) OR D.ProcessID not IN (90,100) )'	
		END
	END

	IF @chkTPCanceled = 1
		SET @StrWhereSD = @StrWhereSD + ' AND (H.TPCanceled = 1)'	

	IF @chkDistributeHdrDiscount = 1
	BEGIN
		SET @StrDiscountSale = '+ CASE WHEN Price = 0 OR Price = TotalLineDiscount 
								   THEN 0 
								   ELSE (D.GoodsPrice * D.GoodsQuantity - DiscountDtl) * (AfterSaleDiscount + Discount + Discount2 + Discount3 + OtherCost) / (Price - TotalLineDiscount) END'
		SET @StrDiscountOrder = '+ CASE WHEN Price = 0 OR Price = TotalLineDiscount 
								   THEN 0 
								   ELSE (D.GoodsPrice * D.GoodsQuantity - DiscountDtl) * (Discount + Discount2 + OtherCost) / (Price - TotalLineDiscount) END'
	END
	ELSE
	BEGIN
		SET @StrDiscountSale = ''
		SET @StrDiscountOrder = ''
	END

	--if (@ProcessID = 'D.ProcessID in ( 999,90,100)' or @ProcessID = 'D.ProcessID in ( 999,90)' or @ProcessID = 'D.ProcessID in ( 999,100)')
	--Begin
	--End
	
IF @UserIsAdmin=0
	BEGIN
	BEGIN TRY
			DROP TABLE #tblAcntCode
			DROP TABLE #tblStoreID
			DROP TABLE #tblVisitorAcntCode
			DROP TABLE #tblGoods
		END TRY
		BEGIN CATCH
		END CATCH
	 CREATE TABLE #tblAcntCode
	(
	AcntCode 			Varchar(20)collate arabic_cs_as null
	)
	 CREATE TABLE #tblGoods
	(
	GoodsID 			Varchar(20)collate arabic_cs_as null
	)
	CREATE TABLE #tblStoreID
	(
	StoreID 			Varchar(20)collate arabic_cs_as null
	)
	 CREATE TABLE #tblVisitorAcntCode
	(
	VisitorAcntCode 			Varchar(20)collate arabic_cs_as null
	)
	 INSERT INTO  #tblVisitorAcntCode (VisitorAcntCode) SELECT  Distinct VisitorAcntCode	FROM inv.tblStorageDocsHdr
	 INSERT INTO  #tblAcntCode (AcntCode)				SELECT  Distinct AcntCode			FROM inv.tblStorageDocsHdr
	 INSERT INTO  #tblGoods (GoodsID)					SELECT  Distinct GoodsID			FROM inv.tblStorageDocsDtl	 	
	 INSERT INTO  #tblStoreID (StoreID)					SELECT  Distinct StoreID			FROM inv.tblStorageDocsHdr

	 INSERT INTO  #tblVisitorAcntCode (VisitorAcntCode) SELECT  Distinct VisitorAcntCode	FROM sal.tblSaleOrderHdr 
	 INSERT INTO  #tblAcntCode (AcntCode)				SELECT  Distinct AcntCode			FROM sal.tblSaleOrderHdr 
	 INSERT INTO  #tblGoods (GoodsID)					SELECT  Distinct GoodsID			FROM sal.tblSaleOrderDtl	 	
	 INSERT INTO  #tblStoreID (StoreID)					SELECT  Distinct StoreID			FROM sal.tblSaleOrderHdr 
	 	
	EXEC pub.SpFilterByPermission2 '#tblAcntCode', 'AcntCode', 'acc.tblAcnt', @UserID;
	EXEC pub.SpFilterByPermission2 '#tblVisitorAcntCode', 'VisitorAcntCode', 'acc.tblAcnt', @UserID;
	EXEC pub.SpFilterByPermission2 '#tblStoreID', 'StoreID', 'inv.tblStores', @UserID;
	EXEC pub.SpFilterByPermission2 '#tblGoods', 'GoodsID', 'inv.tblGoods', @UserID;
	 
	-----------------------------------------------------------------
	--SET @StrWhereH = '  and  acc.funAllowAcntCode('+ltrim(str(@UserID))+','+ ltrim(str(@UserIsAdmin))+',	H.AcntCode,'+ltrim(str(@PartNumber))+') =1 '
	SET @StrWhereD =  @StrWhereD + ' AND H.AcntCode in (SELECT AcntCode	FROM  #tblAcntCode    ) '
	SET @StrWhereD =  @StrWhereD + ' AND H.VisitorAcntCode in (SELECT VisitorAcntCode FROM  #tblVisitorAcntCode    ) '
	SET @StrWhereD =  @StrWhereD + ' AND H.StoreID in (SELECT StoreID FROM #tblStoreID) '
	SET @StrWhereD =  @StrWhereD + ' AND D.GoodsID in (SELECT GoodsID FROM #tblGoods) '
------------------------------------------------------------------------------------------------
	END
 		
			
	SET @StrSelect11=N' 
	SELECT D.ProcessID
		, ProcessName 
		, D.ProcessNo
		, D.FiscalYear
		, D.SerialNo
		, D.GoodsID
		, G.GoodsCID
		, D.StoreID
		, [pub].[GetStoreName](D.StoreID ,1) StoreName
		, [pub].[GetGoodsName](D.GoodsID,1 ) GoodsName	
		, [inv].[funGetUnitName] (G.UnitID,1) UnitNameGoods
		, round (Case when D.ProcessID=90 then 1 else -1 end  * cast (D.GoodsQuantity as float ), '+str(@QuantityDecimalsToForms)+') GoodsQuantity
		, [inv].[funGetUnitName] (U.SubUnitID,1) UnitNameSale
		, round (Case when D.ProcessID=90 then 1 else -1 end  * D.GoodsQuantity*UnitValue/MainUnitValue, '+str(@QuantityDecimalsToForms)+')SubUnitGoodsQuantity
		, round (Case when D.ProcessID=90 then 1 else -1 end  * cast (isnull(R.GoodsQuantity,0) as float ), '+str(@QuantityDecimalsToForms)+')  GoodsQuantityRet
		, 0 GoodsQuantitySale
		, 0 GoodsQuantityRemain
		, G.GoodsWeight*D.GoodsQuantity GoodsWeight
		, G.PureWeight*D.GoodsQuantity  PureWeight
		, ISNULL(StationName,'''') StationName
		, REPLACE(H.AcntCode,'' '','' '' ) AcntCode
		, CAST(D.DocStep as NVarChar) DocStep
		, PersonTypeName
		, F.AcntName
		, F.NationalIDNumber
		, NationalIdentity
		, F.EconomicalCode
		, F.ZipCode
		, F.Mobile
		, F.Tel
		, F.Address1
		, pub.funGetLocationName(F.LocationID,1) LocationName
		, isnull(V1.VisitPathName,'''') VisitPathName1
		, isnull(V2.VisitPathName,'''') VisitPathName2
		, isnull(V3.VisitPathName,'''') VisitPathName3
		, isnull(V4.VisitPathName,'''') VisitPathName4
		, isnull(CampaignName,'''')  CampaignName
		, pub.GetCodeName(H.VisitorAcntCode,1) AS VisitorName1
		, pub.GetCodeName(H.VisitorAcntCode2,1) AS VisitorName2
		, D.IsReward
		, Case when D.BaseProcessID=180 then  H.BaseSerialNo else 0 end OrderSerialNo,Case when D.BaseProcessID=90 then str( H.BaseSerialNo)	else ''0'' end SaleSerialNo	
		, MiscSpecifications	
		, H.DocDate	'
		
		SET @StrSelect12 = '
		, pub.funGetSaleTypesName(case when isnull(D.SaleTypeID, '''')=''''  then H.SaleTypeID else D.SaleTypeID end ,1) SaleTypesName
		, round (Case when D.ProcessID=90 then 1 else -1 end  * Case When D.SubUnitQuantity = D.GoodsQuantity then D.GoodsPrice else D.SubUnitPrice end ,'+str(@PriceDecimalsToForms)+') GoodsPrice
		, round (Case when D.ProcessID=90 then 1 else -1 end  * Case When D.SubUnitQuantity = D.GoodsQuantity then D.GoodsPrice else D.SubUnitPrice end * D.SubUnitQuantity ,'+str(@PriceDecimalsToForms)+') TotalPrice
		, round (Case when D.ProcessID=90 then 1 else -1 end  *  D.DiscountDtl ,'+str(@PriceDecimalsToForms)+') '+ @StrDiscountSale +' DiscountDtl
		, round (Case when D.ProcessID=90 then 1 else -1 end  *  (Case When D.SubUnitQuantity = D.GoodsQuantity then D.GoodsPrice else D.SubUnitPrice end *D.SubUnitQuantity - (D.DiscountDtl '+ @StrDiscountSale +')),'+str(@PriceDecimalsToForms)+')  GoodsPrice2
		, round (Case when D.ProcessID=90 then 1 else -1 end  *  (D.TaxOverWorthCostDtl+D.TollOverWorthCostDtl) ,'+str(@PriceDecimalsToForms)+') TaxToll,DiscountTaxOverWorth
		, round (Case when D.ProcessID=90 then 1 else -1 end  *  (Case When D.SubUnitQuantity = D.GoodsQuantity then D.GoodsPrice else D.SubUnitPrice end *D.SubUnitQuantity - (D.DiscountDtl '+ @StrDiscountSale +') +D.TaxOverWorthCostDtl+D.TollOverWorthCostDtl ) ,'+str(@PriceDecimalsToForms)+') GoodsPrice3,TaxID	
		, SubString(D.GoodsID,1,'+str(@Layer1) +') Layer1, GD1.GoodsName Layername1
		, SubString(D.GoodsID,1,'+str(@Layer2) +') Layer2, GD2.GoodsName Layername2
		, SubString(D.GoodsID,1,'+str(@Layer3) +') Layer3, GD3.GoodsName Layername3
		, SubString(D.GoodsID,1,'+str(@Layer4) +') Layer4, GD4.GoodsName Layername4
		, SubString(D.GoodsID,1,'+str(@Layer5) +') Layer5, GD5.GoodsName Layername5
		, SubString(D.GoodsID,1,'+str(@Layer6) +') Layer6, GD6.GoodsName Layername6
		, SubString(D.GoodsID,1,'+str(@Layer7) +') Layer7, GD7.GoodsName Layername7
		, SubString(D.GoodsID,1,'+str(@Layer8) +') Layer8, GD8.GoodsName Layername8
		, SubString(D.GoodsID,1,'+str(@Layer9) +') Layer9, GD9.GoodsName Layername9
		, [sal].[funGetCustomerKindName](F.CustomerKindID ,1 )CustomerKindName
		, ISNULL(H.Discount2,0) Discount2
		, D.DescDtl
		'
	SET @StrSelect2=' 
	FROM inv.tblStorageDocsDtl  D 
	INNER JOIN inv.tblStorageDocsHdr H On H.ProcessID = D.ProcessID AND H.ProcessNo = D.ProcessNo AND H.FiscalYear = D.FiscalYear AND H.SerialNo = D.SerialNo 
	INNER JOIN inv.tblGoods G on G.GoodsID=SUBSTRING(D.GoodsID,'+str(@str_Goods+1) +','+ Str(@str_GoodsSum)+') AND G.PartNumber= '+str(@UnitPart)+'
	LEFT JOIN inv.tblGoodsDtl GD1 ON GD1.GoodsID=SUBSTRING(D.GoodsID,1,'+str(@Layer1) +') AND GD1.PartNumber= '+str(@UnitPart)+'
	LEFT JOIN inv.tblGoodsDtl GD2 ON GD2.GoodsID=SUBSTRING(D.GoodsID,1,'+str(@Layer2) +') AND GD2.PartNumber= '+str(@UnitPart)+'
	LEFT JOIN inv.tblGoodsDtl GD3 ON GD3.GoodsID=SUBSTRING(D.GoodsID,1,'+str(@Layer3) +') AND GD3.PartNumber= '+str(@UnitPart)+'
	LEFT JOIN inv.tblGoodsDtl GD4 ON GD4.GoodsID=SUBSTRING(D.GoodsID,1,'+str(@Layer4) +') AND GD4.PartNumber= '+str(@UnitPart)+'
	LEFT JOIN inv.tblGoodsDtl GD5 ON GD5.GoodsID=SUBSTRING(D.GoodsID,1,'+str(@Layer5) +') AND GD5.PartNumber= '+str(@UnitPart)+'
	LEFT JOIN inv.tblGoodsDtl GD6 ON GD6.GoodsID=SUBSTRING(D.GoodsID,1,'+str(@Layer6) +') AND GD6.PartNumber= '+str(@UnitPart)+'
	LEFT JOIN inv.tblGoodsDtl GD7 ON GD7.GoodsID=SUBSTRING(D.GoodsID,1,'+str(@Layer7) +') AND GD7.PartNumber= '+str(@UnitPart)+'
	LEFT JOIN inv.tblGoodsDtl GD8 ON GD8.GoodsID=SUBSTRING(D.GoodsID,1,'+str(@Layer8) +') AND GD8.PartNumber= '+str(@UnitPart)+'
	LEFT JOIN inv.tblGoodsDtl GD9 ON GD9.GoodsID=SUBSTRING(D.GoodsID,1,'+str(@Layer9) +') AND GD9.PartNumber= '+str(@UnitPart)+'
	LEFT JOIN (SELECT BaseProcessID, BaseProcessNo, BaseFiscalYear, BaseSerialNo, BaseDocRowNo, SUM(GoodsQuantity) GoodsQuantity FROM inv.tblStorageDocsDtl WHERE BaseProcessID>0 AND BaseDocRowNo>0 GROUP BY BaseProcessID,BaseProcessNo,BaseFiscalYear,BaseSerialNo,BaseDocRowNo ) R On R.BaseProcessID = D.ProcessID AND R.BaseProcessNo = D.ProcessNo AND R.BaseFiscalYear = D.FiscalYear AND R.BaseSerialNo = D.SerialNo  AND R.BaseDocRowNo= D.DocRowNo	
	LEFT JOIN inv.tblSubUnitsDtl U ON G.GoodsID=U.GoodsID and U.ShowInInvoice=1
	LEFT JOIN pub.tblStationDtl S  ON S.StationID=H.BRN
	OUTER APPLY acc.funGetCodeInfo(D.AcntCode) AS F 
	LEFT JOIN acc.tblVisitPathDtl  V1  ON V1.VisitPathID = F.VisitPathID1 AND V1.PartNumber=1
	LEFT JOIN acc.tblVisitPathDtl  V2  ON V2.VisitPathID = F.VisitPathID2 AND V2.PartNumber=2
	LEFT JOIN acc.tblVisitPathDtl  V3  ON V3.VisitPathID = F.VisitPathID3 AND V3.PartNumber=3
	LEFT JOIN acc.tblVisitPathDtl  V4  ON V4.VisitPathID = F.VisitPathID4 AND V4.PartNumber=4
	LEFT JOIN acc.tblCampaignDtl   Ca  ON Ca.CampaignID  = F.CampaignID 
	LEFT JOIN pub.tblProcess P ON P.ProcessID = D.ProcessID AND P.ProcessNo = D.ProcessNo
	WHERE '+ @StrWhere +@StrWhereD+ @StrWhereSD
	
	SET @StrSelect31='
	UNION ALL 
	SELECT D.ProcessID
		, ProcessName 
		, D.ProcessNo
		, D.FiscalYear
		, D.SerialNo
		, D.GoodsID
		, G.GoodsCID
		, D.StoreID 
		, [pub].[GetStoreName](D.StoreID ,1) StoreName
		, [pub].[GetGoodsName](D.GoodsID,1 ) GoodsName	
		, [inv].[funGetUnitName] (G.UnitID,1) UnitNameGoods	
		, round (Case when D.ProcessID=180 then 1 else -1 end  * cast (D.GoodsQuantity as float ),'+str(@QuantityDecimalsToForms)+')  GoodsQuantity
		, [inv].[funGetUnitName] (U.SubUnitID,1) UnitNameSale
		, round (Case when D.ProcessID=180 then 1 else -1 end  * D.GoodsQuantity*UnitValue/MainUnitValue,'+str(@QuantityDecimalsToForms)+')  SubUnitGoodsQuantity
		, round (Case when D.ProcessID=180 then 1 else -1 end  * cast (isnull(R.GoodsQuantity,0) as float ),'+str(@QuantityDecimalsToForms)+')  GoodsQuantityRet,round (cast (isnull(DD.GoodsQuantity,0) as float ) ,'+str(@QuantityDecimalsToForms)+') GoodsQuantitySale 
		, round (Case when D.ProcessID=180 then cast ((isnull(D.GoodsQuantity,0)-isnull(R.GoodsQuantity,0)-isnull(DD.GoodsQuantity,0)) as float ) else 0 end ,'+str(@QuantityDecimalsToForms)+')  GoodsQuantityRemain,G.GoodsWeight*D.GoodsQuantity GoodsWeight,G.PureWeight*D.GoodsQuantity  PureWeight,ISNULL(StationName,'''') StationName
		, REPLACE(H.AcntCode,'' '','' '' ) AcntCode
		, CAST(D.DocStep as NVarChar) DocStep
		, PersonTypeName
		, F.AcntName
		, F.NationalIDNumber
		, NationalIdentity
		, F.EconomicalCode
		, F.ZipCode
		, F.Mobile
		, F.Tel
		, F.Address1
		, pub.funGetLocationName(F.LocationID,1) LocationName
		, isnull(V1.VisitPathName,'''') VisitPathName1
		, isnull(V2.VisitPathName,'''') VisitPathName2
		, isnull(V3.VisitPathName,'''') VisitPathName3
		, isnull(V4.VisitPathName,'''') VisitPathName4
		, isnull(CampaignName,'''')  CampaignName
		, pub.GetCodeName(H.VisitorAcntCode,1) AS VisitorName1
		, pub.GetCodeName(H.VisitorAcntCode2,1) AS VisitorName2
		, D.IsReward
		, CASE WHEN D.BaseProcessID = 180 THEN H.BaseSerialNo ELSE 0 END OrderSerialNo
		, CASE WHEN DD.ProcessID = 90 THEN  --DD.SerialNo	
		 (SELECT   stuff((			SELECT ''  '' + convert(varchar(50), ltrim(str(SerialNo))+'''')		
									FROM inv.tblStorageDocsDtl DD 	
										WHERE DD.BaseProcessID = D.ProcessID AND DD.BaseProcessNo = D.ProcessNo AND DD.BaseFiscalYear = D.FiscalYear AND DD.BaseSerialNo = D.SerialNo  AND DD.BaseDocRowNo = D.DocRowNo
									for xml path('''')		),1,1,''''))  
		ELSE ''0'' END SaleSerialNo	
		, MiscSpecifications'

		SET @StrSelect32 = '	
		, CASE WHEN H.DocDate2 <> '''' THEN H.DocDate2 ELSE H.DocDate END DocDate 
		, pub.funGetSaleTypesName(CASE WHEN isnull(D.SaleTypeID, '''') = '''' THEN H.SaleTypeID ELSE D.SaleTypeID END ,1) SaleTypesName
		, round (CASE WHEN D.ProcessID=180 THEN 1 ELSE -1 END * D.GoodsPrice ,'+str(@PriceDecimalsToForms)+') GoodsPrice
		, round (CASE WHEN D.ProcessID=180 THEN 1 ELSE -1 END * D.GoodsPrice * D.SubUnitQuantity,'+str(@PriceDecimalsToForms)+') TotalPrice
		, round (CASE WHEN D.ProcessID=180 THEN 1 ELSE -1 END * D.DiscountDtl ,'+str(@PriceDecimalsToForms)+') '+ @StrDiscountOrder +' DiscountDtl 
		, round (CASE WHEN D.ProcessID=180 THEN 1 ELSE -1 END * ( D.GoodsPrice * D.SubUnitQuantity - (D.DiscountDtl '+ @StrDiscountOrder +')),'+str(@PriceDecimalsToForms)+') GoodsPrice2
		, round (CASE WHEN D.ProcessID=180 THEN 1 ELSE -1 END * ( D.TaxOverWorthCostDtl + D.TollOverWorthCostDtl),'+str(@PriceDecimalsToForms)+') TaxToll, DiscountTaxOverWorth
		, round (CASE WHEN D.ProcessID=180 THEN 1 ELSE -1 END * ( D.GoodsPrice * D.SubUnitQuantity - (D.DiscountDtl '+ @StrDiscountOrder +') + D.TaxOverWorthCostDtl + D.TollOverWorthCostDtl),'+str(@PriceDecimalsToForms)+') GoodsPrice3
		, '''' TaxID
		, SubString(D.GoodsID,1,'+str(@Layer1) +') Layer1, GD1.GoodsName Layername1
		, SubString(D.GoodsID,1,'+str(@Layer2) +') Layer2, GD2.GoodsName Layername2
		, SubString(D.GoodsID,1,'+str(@Layer3) +') Layer3, GD3.GoodsName Layername3
		, SubString(D.GoodsID,1,'+str(@Layer4) +') Layer4, GD4.GoodsName Layername4
		, SubString(D.GoodsID,1,'+str(@Layer5) +') Layer5, GD5.GoodsName Layername5
		, SubString(D.GoodsID,1,'+str(@Layer6) +') Layer6, GD6.GoodsName Layername6
		, SubString(D.GoodsID,1,'+str(@Layer7) +') Layer7, GD7.GoodsName Layername7
		, SubString(D.GoodsID,1,'+str(@Layer8) +') Layer8, GD8.GoodsName Layername8
		, SubString(D.GoodsID,1,'+str(@Layer9) +') Layer9, GD9.GoodsName Layername9
		, [sal].[funGetCustomerKindName](F.CustomerKindID ,1 )CustomerKindName
		, ISNULL(H.Discount2,0) Discount2
		, D.DescDtl
	'
	set @StrSelect4=' 
	
	FROM sal.tblSaleOrderDtl D 
	INNER JOIN sal.tblSaleOrderHdr H ON H.ProcessID = D.ProcessID AND H.ProcessNo = D.ProcessNo AND H.FiscalYear = D.FiscalYear AND H.SerialNo = D.SerialNo 
	INNER JOIN inv.tblGoods G ON G.GoodsID=SUBSTRING(D.GoodsID,'+str(@str_Goods+1) +','+ Str(@str_GoodsSum)+') AND G.PartNumber= '+str(@UnitPart)+'
	LEFT JOIN inv.tblGoodsDtl  GD1 ON GD1.GoodsID = SUBSTRING(D.GoodsID,1,'+str(@Layer1) +') AND GD1.PartNumber = '+str(@UnitPart)+'
	LEFT JOIN inv.tblGoodsDtl  GD2 ON GD2.GoodsID = SUBSTRING(D.GoodsID,1,'+str(@Layer2) +') AND GD2.PartNumber = '+str(@UnitPart)+'
	LEFT JOIN inv.tblGoodsDtl  GD3 ON GD3.GoodsID = SUBSTRING(D.GoodsID,1,'+str(@Layer3) +') AND GD3.PartNumber = '+str(@UnitPart)+'
	LEFT JOIN inv.tblGoodsDtl  GD4 ON GD4.GoodsID = SUBSTRING(D.GoodsID,1,'+str(@Layer4) +') AND GD4.PartNumber = '+str(@UnitPart)+'
	LEFT JOIN inv.tblGoodsDtl  GD5 ON GD5.GoodsID = SUBSTRING(D.GoodsID,1,'+str(@Layer5) +') AND GD5.PartNumber = '+str(@UnitPart)+'
	LEFT JOIN inv.tblGoodsDtl  GD6 ON GD6.GoodsID = SUBSTRING(D.GoodsID,1,'+str(@Layer6) +') AND GD6.PartNumber = '+str(@UnitPart)+'
	LEFT JOIN inv.tblGoodsDtl  GD7 ON GD7.GoodsID = SUBSTRING(D.GoodsID,1,'+str(@Layer7) +') AND GD7.PartNumber = '+str(@UnitPart)+'
	LEFT JOIN inv.tblGoodsDtl  GD8 ON GD8.GoodsID = SUBSTRING(D.GoodsID,1,'+str(@Layer8) +') AND GD8.PartNumber = '+str(@UnitPart)+'
	LEFT JOIN inv.tblGoodsDtl  GD9 ON GD9.GoodsID = SUBSTRING(D.GoodsID,1,'+str(@Layer9) +') AND GD9.PartNumber = '+str(@UnitPart)+'
	LEFT JOIN (SELECT BaseProcessID, BaseProcessNo, BaseFiscalYear, BaseSerialNo, BaseDocRowNo, SUM(GoodsQuantity) GoodsQuantity FROM sal.tblSaleOrderDtl WHERE BaseProcessID>0 AND BaseDocRowNo > 0 GROUP BY BaseProcessID,BaseProcessNo,BaseFiscalYear,BaseSerialNo,BaseDocRowNo ) R On R.BaseProcessID = D.ProcessID AND R.BaseProcessNo = D.ProcessNo AND R.BaseFiscalYear = D.FiscalYear AND R.BaseSerialNo = D.SerialNo  AND R.BaseDocRowNo= D.DocRowNo	
	LEFT JOIN inv.tblSubUnitsDtl U ON G.GoodsID = U.GoodsID AND U.ShowInInvoice=1
	LEFT JOIN pub.tblStationDtl S  ON S.StationID = H.BRN
	OUTER APPLY acc.funGetCodeInfo(D.AcntCode) AS F 
	LEFT JOIN (SELECT ProcessID, Sum(GoodsQuantity) GoodsQuantity, BaseProcessID, BaseProcessNo, BaseFiscalYear, BaseSerialNo, BaseDocRowNo
			   FROM inv.tblStorageDocsDtl 
			   GROUP BY ProcessID, BaseProcessID, BaseProcessNo, BaseFiscalYear, BaseSerialNo, BaseDocRowNo)DD 
	On DD.BaseProcessID = D.ProcessID AND DD.BaseProcessNo = D.ProcessNo AND DD.BaseFiscalYear = D.FiscalYear AND DD.BaseSerialNo = D.SerialNo  AND DD.BaseDocRowNo = D.DocRowNo
	LEFT JOIN acc.tblVisitPathDtl V1 ON V1.VisitPathID = F.VisitPathID1 AND V1.PartNumber=1
	LEFT JOIN acc.tblVisitPathDtl V2 ON V2.VisitPathID = F.VisitPathID2 AND V2.PartNumber=2
	LEFT JOIN acc.tblVisitPathDtl V3 ON V3.VisitPathID = F.VisitPathID3 AND V3.PartNumber=3
	LEFT JOIN acc.tblVisitPathDtl V4 ON V4.VisitPathID = F.VisitPathID4 AND V4.PartNumber=4
	LEFT JOIN acc.tblCampaignDtl  Ca ON Ca.CampaignID  = F.CampaignID 
	LEFT JOIN pub.tblProcess P ON P.ProcessID = D.ProcessID AND P.ProcessNo = D.ProcessNo
	WHERE '+ @StrWhere+@StrWhereD
	
	print @StrSelect11
	print @StrSelect12
	print @StrSelect2
	print @StrSelect31
	print @StrSelect32
	print @StrSelect4
	set @StrSelect11=@StrSelect11+@StrSelect12+@StrSelect2+@StrSelect31+@StrSelect32+@StrSelect4
	Exec sp_executesql  @StrSelect11;
end
GO
