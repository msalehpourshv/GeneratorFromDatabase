USE TS_ShirinVatanKarkhaneh_1_1404
GO
SET ANSI_NULLS, QUOTED_IDENTIFIER ON
GO
-- =========== TS-QC:UPDATED ====================
-- Author		 : TakroSystem\Ahmadnejad
-- Create date   : 1387/06/21
-- Viewed By	 : 
-- Last Modified : 1392/11/26
-- Last Modifier : TakroSystem\Hamid
-- Description	 : پیش فاکتور فروش
-- ==============================================
Create PROCEDURE [sal].[RptSale_PreSale_Doc]
	@ProcessID		Int = 240,
	@ProcessNo		Int = 1,
	@FiscalYear		Int = 95,
	@SerialNo		Int = 1,
	@FiscalYearTo	Int = 95,
	@SerialNoTo		Int = 1

WITH ENCRYPTION
AS 

Declare @ShowDiscount TinyInt = 0;
Declare @StrSelect	NVarChar(Max);
Declare @StrSelect1	NVarChar(Max);
Declare @StrSelect2	NVarChar(Max);
Declare @StrSelect3	NVarChar(Max);
Declare @StrWhere	NVarChar(Max);

Declare @StrSelectIMGField	NVarChar(Max);
Declare @StrSelectIMGTable	NVarChar(Max);


DECLARE @LanguageID TinyInt;
DECLARE @comp_info  nvarchar(1024);
DECLARE @fval float;
DECLARE @rval int;
DECLARE @sval varchar(20);

-- ======
DECLARE @goods_id					Varchar(20);
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

DECLARE @SH					NVarChar(50);
DECLARE @SD					NVarChar(50);
DECLARE @StrFields4	NVarChar(Max);

if len(@FiscalYear) > 4
begin
	Set @FiscalYear = cast(SUBSTRING(Cast(@FiscalYear as varchar),1,4) as int) 
	set @ShowDiscount = 1
end


Begin --============== S T A R T  C O D E =======================================

	SET NOCOUNT ON;

	--==============
	Declare @SalShowRemainInPreSaleDoc Bit;
	SET @SalShowRemainInPreSaleDoc = 0

	SELECT @SalShowRemainInPreSaleDoc = SettingValue
	FROM pub.tblSettings
	WHERE SettingKey = 'SalShowRemainInPreSaleDoc'

		--===============
	Declare @ShowGoodsImage Bit;
	Set @ShowGoodsImage = 0

	Select @ShowGoodsImage = SettingValue
	From pub.tblSettings
	Where SettingKey = 'ShowGoodsImage'
	--==============
	Declare @sal_ShowTrsInfoInSaleReports Bit;
	SET @sal_ShowTrsInfoInSaleReports = 0

	SELECT @sal_ShowTrsInfoInSaleReports = SettingValue
	FROM pub.tblSettings
	WHERE SettingKey = 'sal_ShowTrsInfoInSaleReports'
	
	IF (@sal_ShowTrsInfoInSaleReports Is Null) SET @sal_ShowTrsInfoInSaleReports = 0;

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
	
	-- ==========
	Declare @sal_ShowMainAndSubUnitInRpt Bit;
	SET @sal_ShowMainAndSubUnitInRpt = 0

	SELECT @sal_ShowMainAndSubUnitInRpt = SettingValue
	FROM pub.tblSettings
	WHERE SettingKey = 'sal_ShowMainAndSubUnitInRpt'
	
	-- ==========
	Declare @sal_ShowRptAmountByCurrency Bit;
	SET @sal_ShowRptAmountByCurrency = 0

	SELECT @sal_ShowRptAmountByCurrency = SettingValue
	FROM pub.tblSettings
	WHERE SettingKey = 'sal_ShowRptAmountByCurrency'
	
	-- ==========
	begin try
		drop table #tbl_result
	end try
	begin catch
	end catch

	begin try
		drop table ##tbl_Tmp
	end try
	begin catch
	end catch	
	
	-- ==========
	DECLARE @QuantityDecimalsToForms AS Int

	SET		@QuantityDecimalsToForms = 3
	SELECT  @QuantityDecimalsToForms=SettingValue
	FROM pub.tblSettings
	WHERE SettingKey = 'QuantityDecimalsToForms'

	IF @QuantityDecimalsToForms>0
		SET		@QuantityDecimalsToForms = @QuantityDecimalsToForms - 1

	Create Table #tbl_result
	(
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
		cnt						int not null
	);
	
	--================================
	
	DECLARE @Db0000				VarChar(50);
	
SELECT @Db0000 = Substring(db_name(), 1, Len(db_name()) - 4) + '0000'

	CREATE TABLE #tbl_Invoice_Signatures
	(
		UserID   Int,
		UserSign Image
	);
	
	SET @StrSelect1 = '
	INSERT INTO #tbl_Invoice_Signatures(UserID, UserSign)
	SELECT UserID, UserSignature
	FROM ' + LTrim(RTrim(@Db0000)) + '.usr.tblUsers U '
	
	Print @StrSelect1;
	Exec sp_executesql @StrSelect1;
		 
	SET @LanguageID = pub.funGetCurrentLanguageID();
	  
	set @rval = 0;
	set @fval = 0;
	
	set @sval = '0'
	set @sval = ISNULL((
		select replace(SettingValue,'/','.')
		from pub.tblSettings
		where SettingKey = 'TaxOverWorthPercentInSale'), '0')
	if (@sval <> '')
		set @fval = @fval + CAST(@sval as float);
		
	set @sval = '0'
	set @sval = ISNULL((
		select replace(SettingValue,'/','.')
		from pub.tblSettings
		where SettingKey = 'TollOverWorthPercentInSale'), '0')
	if (@sval <> '')
		set @fval = @fval + CAST(@sval as float);

	set @sval = '0'
	set @sval = ISNULL((
		select SettingValue
		from pub.tblSettings
		where SettingKey = 'AcntPartNumberForRemainCalculation'), '0')
	if (@sval <> '')
		set @rval = CAST(@sval as float);
		
	IF (@ProcessNo Is Null)		SET @ProcessNo = 1;
	IF (@SerialNo Is Null)		SET @SerialNo = 0;
	IF (@FiscalYear Is Null)	SET @FiscalYear = 0;
	IF (@SerialNoTo Is Null)	SET @SerialNoTo = @SerialNo;
	IF (@FiscalYearTo Is Null)	SET @FiscalYearTo = @FiscalYear;
	
	select @comp_info = [pub].[funCompanyInfo]('#')
	
	-- ================================
	--SET @sal_ShowRptAmountByCurrency = 1
	if (@sal_ShowRptAmountByCurrency = 1)
	begin
		set @SH = 'sal.vwPreSaleHdr_Currency'
		set @SD = 'sal.vwPreSaleDtl_Currency'		
	end
	else
	begin
		set @SH = 'inv.tblPreSaleHdr'
		set @SD = 'inv.tblPreSaleDtl'		
	end
		
	-------------------------------------------------- Where
	Set @StrWhere  = '(D.ProcessID=' + LTRIM(RTrim(Str(@ProcessID))) + ') AND (D.ProcessNo=' + LTRIM(RTrim(Str(@ProcessNo))) + ') AND 
					  (D.FiscalYear>=' + LTRIM(RTrim(Str(@FiscalYear))) + ') AND (D.SerialNo>=' + LTRIM(RTrim(Str(@SerialNo))) + ') AND 
					  (D.FiscalYear<=' + LTRIM(RTrim(Str(@FiscalYearTo))) + ') AND (D.SerialNo<=' + LTRIM(RTrim(Str(@SerialNoTo))) + ')'
	
	--------------------------------------------------
If (1 = 1)
	Begin
	declare @CountPartRemain tinyint
	SET @CountPartRemain=0;

	DECLARE @Part1End			TinyInt;

	SELECT	@Part1End = Layer1 
	FROM	pub.tblCodeLayer 
	WHERE  (TableName = 'acc.tblAcnt') AND (PartNumber = 1)
	DECLARE @Remain1	Bit;
	DECLARE @Remain2	Bit;
	DECLARE @Remain3	Bit;
	DECLARE @Remain4	Bit;
	DECLARE @Part1Start	Int;
	DECLARE @Part2Start	Int;
	DECLARE @Part3Start	Int;
	DECLARE @Part4Start	Int;
	DECLARE @Part1Len	Int;
	DECLARE @Part2Len	Int;
	DECLARE @Part3Len	Int;
	DECLARE @Part4Len	Int;

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

	SELECT @Remain1 = SettingValue	FROM pub.tblSettings	WHERE SettingKey = 'SalIvcRemain1'
	SELECT @Remain2 = SettingValue	FROM pub.tblSettings	WHERE SettingKey = 'SalIvcRemain2'
	SELECT @Remain3 = SettingValue	FROM pub.tblSettings	WHERE SettingKey = 'SalIvcRemain3'
	SELECT @Remain4 = SettingValue	FROM pub.tblSettings	WHERE SettingKey = 'SalIvcRemain4'
		 
	SET @CountPartRemain=0;
	DECLARE @Eqal		NVarChar(2000);

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
----  برای نمایش مانده حساب ارزی بر اساس ارز
		Declare @SumDebitCredit as varchar(100)=' IsNull(Sum(Debit - Credit),0) Debit  '
		Declare @WhereCurrency  as varchar(100)='    '
		Declare @GroupbyCurrency  as varchar(100)='    '
		if @sal_ShowRptAmountByCurrency=1 
		begin
			set  @SumDebitCredit='  IsNull(Sum( case when Debit>0 then  CurrencyAmount else CurrencyAmount  *-1 end ),0) Debit    ' 
			set  @WhereCurrency='  M.CurrencyTypeID=H.CurrencyTypeID and'
			set  @GroupbyCurrency='  H.CurrencyTypeID , '
		end 
		--SET @StrFields3 = @StrFields3 + ', Cast(0 AS Decimal) DebitRemain, Cast(0 AS Decimal) DebitRemain2 '
		SET @StrFields4 =  '
				SELECT	'+  @SumDebitCredit  +'-- IsNull(Sum(Debit - Credit),0) Debit 
				FROM	acc.tblVoucherDtl M 
				INNER JOIN acc.tblVoucherHdr VH ON VH.SerialNo = M.SerialNo
				INNER JOIN acc.tblAcnt b ON b.PartNumber = 1 AND SUBSTRING(M.AcntCode, 1, ' + LTrim(RTrim(STR(@Part1End))) + ') = SUBSTRING(b.AcntCode, 1, ' + LTrim(RTrim(STR(@Part1End))) + ') AND LEN(b.AcntCode) = ' + LTrim(RTrim(STR(@Part1End))) + '
				WHERE   '+ @WhereCurrency +' b.AcntType NOT IN (91,92) AND M.VchKind <> 0 AND VH.DocRegisterState > 0 AND (' + @Eqal + ') AND 
					(M.DocDate <= H.DocDate AND Not (
									M.DocDate = H.VchDate AND 
									M.SourceProcessID  = H.ProcessID AND 
									M.SourceProcessNo  = H.ProcessNo AND 
									M.SourceFiscalYear = H.FiscalYear AND 
									M.SourceSerialNo   >= H.SerialNo
									))'									
				
	End
	
	-- SELECT Clause ----------------------------------------

	set @StrSelectIMGField=',Cast('''' as Image) GoodsImage '
	set @StrSelectIMGTable=' '

	if @ShowGoodsImage='True'
	begin
		set @StrSelectIMGField=', GI.GoodsImage '
		set @StrSelectIMGTable=' Left  Join inv.tblGoodsImages GI On GH.GoodsID = GI.GoodsID '
	end 
	
	Set @StrSelect1  = '
	SELECT	D.*,
			pub.GetCodeName(D.VisitorAcntCode,' + LTrim(RTrim(Str(@LanguageID))) + ') AS VisitorNameDtl,
			pub.GetCodeName(D.VisitorAcntCode2,' + LTrim(RTrim(Str(@LanguageID))) + ') AS VisitorName2Dtl,
			pub.funFarsiDate(GETDATE()) PrintDate
			'+@StrSelectIMGField +' ,GH.ExtraField1, IsNull(CT.ISOCode,'''') CurrencyTypeISOName, pub.funChangeDate_PersianToGergorian(D.DocDate) GeorgDocDate,
			H.IsSubUnit, H.Discount AS DiscountHdr, H.Discount2 AS Discount2Hdr, U.UnitName,W2.UnitName As SubUnitName,
			H.TransporterID, [sal].[GetTransporterNameAry] (H.TransporterID) As TransporterNameAry,
			IsNull(W.UnitName,'''') UnitName2, H.DiscountPercent AS DiscountPercentHdr, H.DiscountPercent2 AS DiscountPercent2Hdr, H.DocDesc, H.DocDesc2,H.AgreeNo, S.StoreName, 
			H.TransportationCostAcntCode, H.TransportationCost, H.TransportationIncomeAcntCode, GH.PureWeight GoodsPureWeight, GH.GoodsWeight,
			[pub].[funGetSaleTypesName](H.SaleTypeID,' + LTrim(RTrim(Str(@LanguageID))) + ') SaleTypesName, H.TransportationIncome, H.VisitorAcntCode HdrVisitorAcntCode, 
			pub.GetCodeName(H.VisitorAcntCode,' + LTrim(RTrim(Str(@LanguageID))) + ') AS VisitorNameHdr,
			H.VisitorPercent HdrVisitorPercent, H.VisitorCost HdrVisitorCost, H.PackingCost, H.VisitorAcntCode2 HdrVisitorAcntCode2, 
			pub.GetCodeName(H.VisitorAcntCode2,' + LTrim(RTrim(Str(@LanguageID))) + ') AS VisitorName2Hdr,
			H.VisitorPercent2 HdrVisitorPercent2, H.VisitorCost2 HdrVisitorCost2, H.TaxCost, H.TaxOverWorthCost, H.TollOverWorthCost, 
			H.OtherCostAcntCode, H.OtherCost, H.OtherIncomeAcntCode, H.OtherIncome, 
			[pub].[funGetGoodsName](D.GoodsID,' + LTrim(RTrim(Str(@LanguageID))) + ') GoodsName, 
			IsNull([inv].[FunGetGoodsBarCode] (D.GoodsID), '''') BarCode, LD.LocationName, IsNull(V.UnitValue,1)UnitValue,  
			IsNull(V.MainUnitValue,1)MainUnitValue,F.NationalIdentity, F.NationalIDNumber, GH.TechnicalNo,
			GH.TechnicalSpecifications, GH.MiscSpecifications, H.AcntName As HdrAcntName,
			CAST(CASE WHEN LTrim(D.AcntCode) = '''' THEN H.AcntName	ELSE F.AcntName	END AS NVarChar(100)) AS AcntName,
			IsNull(TKD.TransportationKindName,'''') TransportationKindName,
			IsNull(GRD.ReciverAddress,'''') ReciverAddress,
			inv.funGetStoreAddress(S.StoreID,' + LTrim(RTrim(Str(@LanguageID))) + ') StoreAddress,
			IsNull(F.Tel,'''') CustomerTelNumber, 
			IsNull(F.Mobile,'''') CustomerMobileNumber,
			IsNull(F.InternetAddress,'''') CustomerInternetAddress,
			IsNull(F.Email,'''') CustomerEmail, 
			IsNull(F.ZipCode, '''') as CustomerZipCode, 
			IsNull(F.OrganzationName,'''') CustomerOrganzationName,
			IsNull(F.EconomicalCode, '''') as CustomerEconomicalCode, 
			IsNull(F.CompanyRegisterNo,'''') as CustomerCompRegisterNo,
			IsNull(F.NationalIDNumber, '''') as CustomerNationalIDNumber, 
			IsNull(F.Address1, '''')+'' '' + IsNull(F.Address2, '''') as CustomerAddress, 
			IsNull(F.CustomerFirstName,'''')+'' '' + IsNull(F.CustomerLastName,'''') CustomerName,
			IsNull(F.MaxDebitRemain, 0) MaxDebitRemain, 
			IsNull(F.MaxReceivableRemain, 0) MaxReceivableRemain, 
			IsNull(inv.funGetUnitName(V.SubUnitID,' + LTrim(RTrim(Str(@LanguageID))) + '),'''') As GSubUnitName,
			IsNull(D.GoodsQuantity * V.UnitValue / V.MainUnitValue ,0) As GoodsSubUnitQTY,
			pub.GetUserName(H.SessionNo) AS UserName, ''' + LTrim(RTrim(@comp_info)) + ''' as CompanyInfo, ' + 
			LTrim(RTrim(Str(@fval))) + ' as VATPercent,'
	Set @StrSelect2  = '								 
			S1.UserSign As UserSignature1,
			S2.UserSign As UserSignature2,
			S3.UserSign As Signature1,
			S4.UserSign As Signature2,
			S5.UserSign As Signature3,
			S6.UserSign As Signature4,
			S7.UserSign As Signature5,EarnestMoney,EarnestMoneyPercent,EarnestMoneyAcntCode, (' + @StrFields4 + ') DebitRemain,
			ISNULL(DR.DescRetSaleID,'''') DescRetSaleID,
			ISNULL(DR.DescRetSaleName,'''') DescRetSaleName, 
			'+LTrim(RTrim(str(@ShowDiscount)))+' ShowDiscount,
			H.CurrencyDiscount,
			H.CurrencyRate, 
			H.CurrencyTypeID, 
			[pub].[funGetCurrencyTypesName] ( H.CurrencyTypeID,'+ LTrim(RTrim(str(@LanguageID))) +') CurrencyTypesName,
			'+ Str(@sal_ShowRptAmountByCurrency) +' AmountByCurrency, 
			H.CurrencyTransportationCost, 
			H.CurrencyTransportationIncome,
			H.PreSaleExpireDate
	INTO	##tbl_Tmp
	FROM	' + @SD + ' D 
				INNER JOIN ' + @SH + ' H ON H.ProcessID = D.ProcessID AND H.ProcessNo = D.ProcessNo AND H.FiscalYear = D.FiscalYear AND H.SerialNo = D.SerialNo
				LEFT  JOIN inv.tblStoresDtl S ON S.StoreID = D.StoreID AND S.LanguageID = ' + LTrim(RTrim(Str(@LanguageID))) + '
				OUTER APPLY acc.funGetCodeInfo(D.AcntCode) AS F
				LEFT  JOIN pub.tblLocationsDtl LD ON LD.LocationID = H.LocationID AND LD.LanguageID = ' + LTrim(RTrim(Str(@LanguageID))) + '
				LEFT  JOIN inv.tblGoods GH ON GH.GoodsID=SUBSTRING(D.GoodsID,' + ltrim(rtrim(STR(@str_Goods+1))) + ',' + ltrim(rtrim(STR( @str_GoodsSum))) + ') AND GH.PartNumber=' + ltrim(rtrim(STR(@UnitPart)))+ '
				'+ @StrSelectIMGTable +'
				Left  Join trn.tblTransportationKindDtl TKD On H.TransportationKindID = TKD.TransportationKindID
				Left  Join inv.tblGoodsReciverDtl GRD On H.GoodsReciverID = GRD.ReciverID
				Left  Join pub.tblCurrencyTypes CT On H.CurrencyTypeID = CT.CurrencyTypeID
				LEFT  JOIN inv.tblUnitsDtl U ON U.UnitID=GH.UnitID
				LEFT  JOIN inv.tblSubUnitsDtl V ON V.GoodsID=D.GoodsID and V.ShowInInvoice=1
				LEFT  JOIN inv.tblUnitsDtl W ON W.UnitID=V.SubUnitID				
				LEFT  JOIN inv.tblUnitsDtl W2 ON W2.UnitID=D.SubUnitID
				LEFT  JOIN sal.tblDescRetSaleDtl DR ON DR.DescRetSaleID=H.DescRetSaleID	AND LD.LanguageID = ' + LTrim(RTrim(Str(@LanguageID))) + '
				LEFT  JOIN #tbl_Invoice_Signatures S1 ON S1.UserID = ' + LTrim(RTrim(@Db0000))+ '.[pub].[funGetUserID](H.SessionNo)
	LEFT  JOIN #tbl_Invoice_Signatures S2 ON S2.UserID = ' + LTrim(RTrim(@Db0000))+ '.[pub].[funGetUserID](H.SessionNo2)
	LEFT  JOIN #tbl_Invoice_Signatures S3 ON S3.UserID = ' + LTrim(RTrim(@Db0000))+ '.[pub].[funGetUserID](H.SgnSN1)
	LEFT  JOIN #tbl_Invoice_Signatures S4 ON S4.UserID = ' + LTrim(RTrim(@Db0000))+ '.[pub].[funGetUserID](H.SgnSN2)
	LEFT  JOIN #tbl_Invoice_Signatures S5 ON S5.UserID = ' + LTrim(RTrim(@Db0000))+ '.[pub].[funGetUserID](H.SgnSN3)
	LEFT  JOIN #tbl_Invoice_Signatures S6 ON S6.UserID = ' + LTrim(RTrim(@Db0000))+ '.[pub].[funGetUserID](H.SgnSN4)
	LEFT  JOIN #tbl_Invoice_Signatures S7 ON S7.UserID = ' + LTrim(RTrim(@Db0000))+ '.[pub].[funGetUserID](H.SgnSN5)   
   '
	Set @StrSelect3  = '					
	WHERE ' + @StrWhere + '
	ORDER BY D.FiscalYear, D.SerialNo, D.DocRowNo'
	------------------------------------------------------------
	Print @StrSelect1;
	Print @StrSelect2;
	Print @StrSelect3;
		
	Set @StrSelect1 = @StrSelect1 + @StrSelect2 + @StrSelect3;
	EXEC sp_executesql @StrSelect1;
		 
	 --Select * From ##tbl_Tmp
	-- ******************************************************************************

	SET @StrSelect = '
	INSERT INTO #tbl_result
	Select S.SerialNo, S.DocRowNo, S.GoodsID, '''', GoodsQuantity, '''', '''', 0, 
		   '''', '''', 0, 0, 0, ''''
	From ##tbl_Tmp S 
	-- =========='
	
	--Print @StrSelect;
	Exec sp_executesql @StrSelect;
 	
	--Select * From #tbl_result	
	-- ******************************************************************************
	-- *********************************** Units ************************************
	-- ******************************************************************************
	declare cur_goods cursor for
		select SerialNo, RowNo, GoodsID, GoodsQuantity
		from #tbl_result
	open cur_goods;
		
	fetch next from cur_goods into @serial_no, @rowno, @goods_id, @goods_quantity
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
			
		) t inner join inv.tblUnitsDtl u on u.UnitID = t.UnitID and u.LanguageID = @LanguageID
		order by (t.MainUnitValue/ t.UnitValue ) desc
			
		-- read units row by row
		declare cur_units cursor for
			select * from @tbl_units
		open cur_units;
			
		--select * from @tbl_units

		-- init
		set @unit_idGoods1			 = '';
		set @unit_nameGoods1		 = '';
		set @unit_valueGoods1		 =  0;
		set @Mainunit_valueGoods1	 =  0;
		
		set @unit_idGoods2			 = '';
		set @unit_nameGoods2		 = '';
		set @unit_valueGoods2		 =  0;
		set @Mainunit_valueGoods2	 =  0;
		
		--select * from @tbl_units
		
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
		set UnitIDGoods1			= IsNull(@unit_idGoods1,''),
			UnitNameGoods1			= IsNull(@unit_nameGoods1,''),
			GoodsQuantity1			= IsNull(@unit_valueGoods1,0),
			UnitIDGoods2			= IsNull(@unit_idGoods2,''),
			UnitNameGoods2			= IsNull(@unit_nameGoods2,''),
			GoodsQuantity2			= IsNull(@unit_valueGoods2,0)
		where GoodsID = @goods_id And SerialNo = @serial_no And RowNo = @rowno
			  
		update #tbl_result
		set GoodsName				= IsNull([pub].[funGetGoodsName](G.GoodsID, @LanguageID), ''),
			Weight					= IsNull(G.GoodsWeight,0),
			Volume					= IsNull(G.GoodsLength * G.GoodsHeight * G.GoodsWidth,0),
			BarCode					= IsNull([inv].[FunGetGoodsBarCode] (G.GoodsID), '')
		from inv.tblGoods G
		INNER JOIN inv.tblGoodsDtl GD ON GD.GoodsID = SUBSTRING(G.GoodsID,@str_Goods+1, @str_GoodsSum) AND GD.PartNumber= @UnitPart AND GD.LanguageID = @LanguageID
		where G.GoodsID = @goods_id AND #tbl_result.GoodsID = @goods_id And #tbl_result.SerialNo = @serial_no And
			  #tbl_result.RowNo = @rowno
		
		-- next
		fetch next from cur_goods into @serial_no, @rowno, @goods_id, @goods_quantity
	end

	-- close goods cursor
	Close cur_goods;
	Deallocate cur_goods;
	-- ******************************************************************************
	-- ********************************** Units End *********************************
	-- ******************************************************************************
	
	 select AcntCode,DocDate,MaxDebitRemain DebitRemain,MaxDebitRemain  CustomerRemain,MaxDebitRemain  DebitRemain2,MaxDebitRemain  UnReceiptRemain,MaxDebitRemain  ReturnedRemain
	 into   #tblAcntCodeRemain  from  ##tbl_Tmp where 1=0

	 insert into #tblAcntCodeRemain  
	 select Distinct AcntCode,DocDate,0,0,0,0,0 from ##tbl_Tmp T
	 	 
	update #tblAcntCodeRemain
	set 	DebitRemain=acc.funAcntDebitRemainFull(AcntCode,DocDate) ,
			DebitRemain2=acc.funAcntDebitRemain(AcntCode) ,			
			UnReceiptRemain=[trs].[funReceivableDocs_UnReceipt_Sum](AcntCode, 1, SubString(pub.funFarsiDate(GETDATE()), 1, 10)) ,
			ReturnedRemain=trs.funAcntReturnedRemain(AcntCode, 1) ,
			CustomerRemain=acc.funAcntDebitRemainFull(AcntCode,DocDate)

	Select T.*, @SalShowRemainInPreSaleDoc SalShowRemainInPreSaleDoc, @ShowGoodsImage ShowGoodsImage, Round(IsNull(R.GoodsQuantity,0), @QuantityDecimalsToForms) RGoodsQuantity,
		   Round(IsNull(R.GoodsQuantity1,0), @QuantityDecimalsToForms) GoodsQuantity1, ISNULL(R.UnitIDGoods1,'') UnitIDGoods1, 
		   ISNULL(R.UnitNameGoods1,'') UnitNameGoods1, Round(IsNull(R.GoodsQuantity2,0), @QuantityDecimalsToForms) GoodsQuantity2, 
		   ISNULL(R.UnitIDGoods2,'') UnitIDGoods2, ISNULL(R.UnitNameGoods2,'') UnitNameGoods2, ISNULL(R.Weight,0) RWeight, 
		   ISNULL(R.Volume,0) RVolume, ISNULL(R.BarCode,0) RBarCode, @sal_ShowMainAndSubUnitInRpt MainAndSubUnit, 
		   @sal_ShowTrsInfoInSaleReports ShowTrsInfoInSaleReports, T.DebitRemain,CustomerRemain
		   ,DebitRemain2,UnReceiptRemain,ReturnedRemain
	From ##tbl_Tmp T
	left join #tbl_result R ON R.GoodsID = T.GoodsID And R.SerialNo = T.SerialNo And R.RowNo = T.DocRowNo
	inner join #tblAcntCodeRemain AR on AR.AcntCode=T.AcntCode
	Left  Join inv.tblGoodsImages GI On  T.GoodsID = GI.GoodsID --+ @GoodsImageNameJoin
END
GO
