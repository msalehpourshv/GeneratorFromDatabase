USE TS_ShirinVatanKarkhaneh_1_1404
GO
SET ANSI_NULLS, QUOTED_IDENTIFIER ON
GO
-- =========== TS-QC:UPDATED ====================
-- Author		 : TakroSystem\Zia
-- Creation Date : 1391/03/23
-- Viewed By	 : 
-- Last Modified : 1393/02/20
-- Last Modifier : Hamid
-- Description	 : 
-- ==============================================
Create PROCEDURE [sal].[RptSale_PreSale_Docs_Sales] 
	@ProcessID		Int = 240,
	@ProcessNo		Int = 1,
	@FiscalFr		Int = NULL,
	@SerialFr		Int = NULL,
	@FiscalTo		Int = NULL,
	@SerialTo		Int = NULL,
	@DocDateFr		Char(10) = NULL,
	@DocDateTo		Char(10) = NULL,
	@SelectedAcnt1		Int = 0,
	@SelectedAcnt2		Int = 0,
	@SelectedAcnt3		Int = 0,
	@SelectedAcnt4		Int = 0,
	@SelectedVisitor1	Int = 0,
	@SelectedVisitor2	Int = 0,
	@SelectedVisitor3	Int = 0,
	@SelectedVisitor4	Int = 0,
	@SelectedGoods		Int = 0,
	@SaleTypeID			VarChar(20) = Null,   -- کد نوع فروش
	@CustKind			VarChar(20) = null,
	@RepOptions			NVarChar(100) = '10', -- bit array (showQty-showPrc)
	@SortFields			NVarChar(100) = Null,
	@RepInfo			NVarChar(100) = '1@1@1'
WITH ENCRYPTION
AS 
---- Declarations ---------------
Declare @StrSelect	NVarChar(max);
Declare @StrSelect2	NVarChar(max);
Declare @StrFrom	NVarChar(2048);
Declare @StrWhere	NVarChar(2048);
Declare @StrWhere2	NVarChar(2048);

DECLARE	@LangID			Char(1);
DECLARE	@SessionNo		Int; -- برای حالت کدهای انتخابی
DECLARE	@ReportID		Int; -- برای حالت کدهای انتخابی

DECLARE	@RemainOnly		Tinyint;
DECLARE	@DecDiscount	bit;
DECLARE	@IsConfirm		bit;
DECLARE	@IsNotConfirm	bit;
DECLARE @VATY			bit;
DECLARE @VATN			bit;
DECLARE @set			bit;

DECLARE @tax			varchar(20);
DECLARE @tol			varchar(20);

DECLARE @var1				FLOAT
DECLARE @var2				FLOAT
DECLARE @var3				FLOAT
DECLARE @var4				FLOAT
DECLARE @ConstText1			NVarChar(100);
DECLARE @ConstText2			NVarChar(100);
DECLARE @ConstText3			NVarChar(100);
DECLARE @ConstText4			NVarChar(100);

DECLARE @SelectedStore		Varchar(10);
DECLARE @DocDate			Char(10);

Begin --============== S T A R T  C O D E ===================================================

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

	--==============
	UPDATE inv.tblStorageDocsDtl 
	SET BaseDocRowNo = A.DocRowNo 
	FROM inv.tblStorageDocsDtl B INNER JOIN 
	inv.tblPreSaleDtl A 
	ON A.ProcessID=B.BaseProcessID AND A.ProcessNo=B.BaseProcessNo  AND 
	A.FiscalYear=B.BaseFiscalYear  AND A.SerialNo=B.BaseSerialNo  AND 
	A.GoodsID=B.GoodsID AND A.DocRowNo<>B.BaseDocRowNo 
	AND A.GoodsID NOT IN (SELECT GoodsID 
	FROM inv.tblPreSaleDtl AA 
	WHERE AA.ProcessID = 240 AND AA.ProcessID=A.ProcessID AND 
	AA.ProcessNo=A.ProcessNo AND AA.FiscalYear=A.FiscalYear AND AA.SerialNo=A.SerialNo 
	GROUP BY ProcessID,ProcessNo,FiscalYear,SerialNo,GoodsID 
	HAVING COUNT(GoodsID)>1)
	--==============
	
	-- Init -------------------------------------------------
	IF (@RepInfo Is Null)			SET @RepInfo = '1@1@1'
	IF (@ProcessNo Is Null)			SET @ProcessNo = 1;
	IF (@RepOptions Is Null)		SET @RepOptions = '11';

	IF (@SelectedAcnt1 Is Null)		SET @SelectedAcnt1 = 0;
	IF (@SelectedAcnt2 Is Null)		SET @SelectedAcnt2 = 0;
	IF (@SelectedAcnt3 Is Null)		SET @SelectedAcnt3 = 0;
	IF (@SelectedAcnt4 Is Null)		SET @SelectedAcnt4 = 0;
	IF (@SelectedVisitor1 Is Null)	SET @SelectedVisitor1 = 0
	IF (@SelectedVisitor2 Is Null)	SET @SelectedVisitor2 = 0
	IF (@SelectedVisitor3 Is Null)	SET @SelectedVisitor3 = 0
	IF (@SelectedVisitor4 Is Null)	SET @SelectedVisitor4 = 0
	IF (@SelectedGoods Is Null)		SET @SelectedGoods = 0

	IF (@FiscalFr Is Null)		SET @SerialFr = Null;
	IF (@FiscalTo Is Null)		SET @SerialTo = Null;
	IF (@SerialFr	Is Null)	SET @FiscalFr = Null;
	IF (@SerialTo	Is Null)	SET @FiscalTo = Null;

	SET @LangID		= pub.funSplitString(@RepInfo, '@', 1);
	SET @SessionNo	= pub.funSplitString(@RepInfo, '@', 2);
	SET @ReportID	= pub.funSplitString(@RepInfo, '@', 3);

	--==========
	SET @SelectedStore = pub.funSplitString(@RepInfo, '@', 6);

	SET @var1	 = LTrim(pub.funSplitString(@RepInfo, '@', 7));
	SET @var2	 = LTrim(pub.funSplitString(@RepInfo, '@', 8));
	SET @var3	 = LTrim(pub.funSplitString(@RepInfo, '@', 9));
	SET @var4	 = LTrim(pub.funSplitString(@RepInfo, '@', 10));
	SET @ConstText1	 = LTrim(pub.funSplitString(@RepInfo, '@', 11));
	SET @ConstText2	 = LTrim(pub.funSplitString(@RepInfo, '@', 12));
	SET @ConstText3	 = LTrim(pub.funSplitString(@RepInfo, '@', 13));
	SET @ConstText4	 = LTrim(pub.funSplitString(@RepInfo, '@', 14));

	
	SET @RemainOnly	  = Substring(@RepOptions, 1, 1);
	SET @DecDiscount  = Substring(@RepOptions, 2, 1);
	SET @IsConfirm    = Substring(@RepOptions, 3, 1);
	SET @IsNotConfirm = Substring(@RepOptions, 4, 1);
	SET @VATY		  = Substring(@RepOptions, 5, 1)
	SET @VATN		  = Substring(@RepOptions, 6, 1)

	set @tax = '0'
	set @tax = ISNULL((
		select replace(SettingValue,'/','.')
		from pub.tblSettings
		where SettingKey = 'TaxOverWorthPercentInSale'), '0')
		
	set @tol = '0'
	set @tol = ISNULL((
		select replace(SettingValue,'/','.')
		from pub.tblSettings
		where SettingKey = 'TollOverWorthPercentInSale'), '0')
		
	set @set = 0;
	set @set = ISNULL((
		select SettingValue
		from pub.tblSettings
		where SettingKey = 'TaxOverWorthBeforDiscount'), 0)
	---------------------------------------------------------

	-- Where Clause -----------------------------------------
	Set @StrWhere = '(D.ProcessID=' + LTrim(Str(@ProcessID)) + ')'

	If (@ProcessNo Is Not Null) and (@ProcessNo > 0)
		Set @StrWhere = @StrWhere + ' AND (D.ProcessNo=' + LTrim(Str(@ProcessNo)) + ')'

	IF (@SerialFr Is Not Null)
		SET @StrWhere = @StrWhere + ' AND (D.FiscalYear>' + LTrim(Str(@FiscalFr)) + ' OR (D.FiscalYear=' + LTrim(Str(@FiscalFr)) + ' AND D.SerialNo>=' + LTrim(Str(@SerialFr)) + '))' 
	IF (@SerialTo Is Not Null)
		SET @StrWhere = @StrWhere + ' AND (D.FiscalYear<' + LTrim(Str(@FiscalTo)) + ' OR (D.FiscalYear=' + LTrim(Str(@FiscalTo)) + ' AND D.SerialNo<=' + LTrim(Str(@SerialTo)) + '))' 

	IF (@DocDateFr Is Not Null)
		SET @StrWhere = @StrWhere + ' AND (D.DocDate>=''' + @DocDateFr + ''')'
	IF @DocDateTo Is Not Null
		SET @StrWhere = @StrWhere + ' AND (D.DocDate<=''' + @DocDateTo + ''')'

	If (@var1 Is Not Null) AND @var1>0
		SET @StrWhere = @StrWhere + ' AND D.Var1 = ' + LTrim(Str(@var1))
	
	If (@var2 Is Not Null) AND @var2>0
		SET @StrWhere = @StrWhere + ' AND D.Var2 = ' + LTrim(Str(@var2))

	If (@var3 Is Not Null) AND @var3>0
		SET @StrWhere = @StrWhere + ' AND D.Var3 = ' + LTrim(Str(@var3))

	If (@var4 Is Not Null) AND @var4>0
		SET @StrWhere = @StrWhere + ' AND D.Var4 = ' + LTrim(Str(@var4))

	If (@ConstText1 Is Not Null) AND @ConstText1<>''
		SET @StrWhere = @StrWhere + ' AND D.ConstText1 LIKE ''%' + @ConstText1 + '%'''

	If (@ConstText2 Is Not Null) AND @ConstText2<>''
		SET @StrWhere = @StrWhere + ' AND D.ConstText2 LIKE ''%' + @ConstText2 + '%'''

	If (@ConstText3 Is Not Null) AND @ConstText3<>''
		SET @StrWhere = @StrWhere + ' AND D.ConstText3 LIKE ''%' + @ConstText3 + '%'''

	If (@ConstText4 Is Not Null) AND @ConstText4<>''
		SET @StrWhere = @StrWhere + ' AND D.ConstText4 LIKE ''%' + @ConstText4 + '%'''
	-- Acnt Filter 
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
		
	IF (@SelectedGoods > 0)
		SET @StrWhere = @StrWhere + ' AND (' + pub.funGetFilterString(@SessionNo, @ReportID, @SelectedGoods, 'D.GoodsID') + ')'

	If (@SaleTypeID Is Not Null)
		Set @StrWhere = @StrWhere + ' AND (D.SaleTypeID=''' + @SaleTypeID + ''')'
	
	if (@CustKind is not null AND @CustKind<>'')
		Set @StrWhere = @StrWhere + ' AND (pub.funGetCustomerKindID(H.AcntCode) = ''' + @CustKind + ''')'
	
	if (@IsConfirm is not null AND @IsConfirm=1 And @IsNotConfirm=0 )
		Set @StrWhere = @StrWhere + ' AND H.DocStep>=2'
	
	if (@IsNotConfirm is not null AND @IsNotConfirm=1 And @IsConfirm=0 )
		Set @StrWhere = @StrWhere + ' AND H.DocStep<=1'
		
	If (@SelectedStore > 0)
		SET @StrWhere = @StrWhere + ' AND ' + pub.funGetFilterString(@SessionNo, @ReportID, @SelectedStore, 'D.StoreID')		
	
	IF (@VATY = 1)
		Set @StrWhere = @StrWhere + ' AND (H.TaxOverWorthCost > 0)'
		
	IF (@VATN = 1)
		Set @StrWhere = @StrWhere + ' AND (H.TaxOverWorthCost = 0)'

	---------------------------------------------------------
	set @DocDate=[pub].[funChangeDate_GergorianToPersian](Getdate())
	-- SELECT Clause ----------------------------------------
	Set @StrSelect = '
	SELECT	D.*, pub.GetUserName(H.SessionNo) As UserName, [pub].[funGetGoodsName](D.GoodsID,' + LTrim(RTrim(@LangID)) + ') GoodsName,
		   IsNull([inv].[FunGetGoodsBarCode] (D.GoodsID), '''') BarCode, pub.GetCodeName(H.AcntCode, 1) AcntName, UD.UnitName, 
			F.CustomerFirstName+'' ''+F.CustomerLastName CustomerName, F.Address1, F.Address2,
			F.Tel, F.Mobile, F.VisitPathID1, F.VisitPathID2, F.VisitPathID3, F.VisitPathID4, 
			isnull((
				select sum(GoodsQuantity) 
				from inv.tblStorageDocsDtl S 
				where (ProcessID=90) and (S.BaseProcessID=D.ProcessID) and (S.BaseProcessNo=D.ProcessNo) and (S.BaseFiscalYear=D.FiscalYear) and (S.BaseSerialNo=D.SerialNo) and (S.BaseDocRowNo=D.DocRowNo)
			),0) + 			
			isnull((
				select sum(S.GoodsQuantity) 
				from inv.tblStorageDocsDtl S 
				INNER JOIN (
				select ProcessID,ProcessNo,FiscalYear,SerialNo,DocRowNo 
				from sal.tblSaleOrderDtl S 
				where (ProcessID=180) and (S.BaseProcessID=D.ProcessID) and (S.BaseProcessNo=D.ProcessNo) and (S.BaseFiscalYear=D.FiscalYear) and (S.BaseSerialNo=D.SerialNo) and (S.BaseDocRowNo=D.DocRowNo)) S1
				ON (S.BaseProcessID=S1.ProcessID) and (S.BaseProcessNo=S1.ProcessNo) and (S.BaseFiscalYear=S1.FiscalYear) and (S.BaseSerialNo=S1.SerialNo) and (S.BaseDocRowNo=S1.DocRowNo)
			),0) SoldQty, ' + ltrim(@tax) + ' TaxPercent, ' + ltrim(@tol) + ' TollPercent, cast(' + ltrim(@set) + ' as bit) VATBeforDiscount,
			H.DiscountPercent DiscountPercentHdr, H.TaxOverWorthCost, H.TollOverWorthCost 
			,-1*acc.funAccountRemainFromSaleSetting(D.AcntCode,'''+@DocDate+''') AcntRemain
			,isnull((
				select sum(GoodsQuantity) 
				from sal.tblSaleOrderDtl S 
				where (ProcessID=180) and (S.BaseProcessID=D.ProcessID) and (S.BaseProcessNo=D.ProcessNo) and (S.BaseFiscalYear=D.FiscalYear) and (S.BaseSerialNo=D.SerialNo) and (S.BaseDocRowNo=D.DocRowNo)
			),0) OrderQty
			,isnull((
				SELECT sum(GoodsQuantity)
				FROM sal.tblSaleOrderDtl S1
				INNER JOIN (
				select ProcessID,ProcessNo,FiscalYear,SerialNo,DocRowNo
				from sal.tblSaleOrderDtl S 
				where (ProcessID=180) and (S.BaseProcessID=D.ProcessID) and (S.BaseProcessNo=D.ProcessNo) and (S.BaseFiscalYear=D.FiscalYear) and (S.BaseSerialNo=D.SerialNo) and (S.BaseDocRowNo=D.DocRowNo)
				)S ON (S1.BaseProcessID=S.ProcessID) and (S1.BaseProcessNo=S.ProcessNo) and (S1.BaseFiscalYear=S.FiscalYear) and (S1.BaseSerialNo=S.SerialNo) and (S1.BaseDocRowNo=S.DocRowNo)
				WHERE S1.ProcessID=185
			),0) OrderRetQty '
	
	set @StrSelect2=', isnull(	(
			select sum(SR.GoodsQuantity) 
				from inv.tblStorageDocsDtl SR 
				INNER JOIN 				
				(select S.ProcessID,S.ProcessNo,S.FiscalYear,S.SerialNo,S.DocRowNo
				from inv.tblStorageDocsDtl S 
				where (ProcessID=90) and (S.BaseProcessID=D.ProcessID) and (S.BaseProcessNo=D.ProcessNo) and (S.BaseFiscalYear=D.FiscalYear) and (S.BaseSerialNo=D.SerialNo) and (S.BaseDocRowNo=D.DocRowNo)
			union  All
				select S.ProcessID,S.ProcessNo,S.FiscalYear,S.SerialNo,S.DocRowNo
				from inv.tblStorageDocsDtl S 
				INNER JOIN (
				select ProcessID,ProcessNo,FiscalYear,SerialNo,DocRowNo 
				from sal.tblSaleOrderDtl S 
				where (ProcessID=180) and (S.BaseProcessID=D.ProcessID) and (S.BaseProcessNo=D.ProcessNo) and (S.BaseFiscalYear=D.FiscalYear) and (S.BaseSerialNo=D.SerialNo) and (S.BaseDocRowNo=D.DocRowNo)) S1
				ON (S.BaseProcessID=S1.ProcessID) and (S.BaseProcessNo=S1.ProcessNo) and (S.BaseFiscalYear=S1.FiscalYear) and (S.BaseSerialNo=S1.SerialNo) and (S.BaseDocRowNo=S1.DocRowNo)
			)S
			ON (SR.BaseProcessID=S.ProcessID) and (SR.BaseProcessNo=S.ProcessNo) and (SR.BaseFiscalYear=S.FiscalYear) and (SR.BaseSerialNo=S.SerialNo) and (SR.BaseDocRowNo=S.DocRowNo)
			where (SR.ProcessID=100)
			),0) SoldQtyRet					
	FROM  inv.tblPreSaleDtl D
			INNER JOIN inv.tblPreSaleHdr H ON H.ProcessID=D.ProcessID AND H.ProcessNo=D.ProcessNo AND H.FiscalYear=D.FiscalYear AND H.SerialNo=D.SerialNo
			OUTER APPLY acc.funGetCodeInfo(D.AcntCode) F
			LEFT JOIN inv.tblGoods GH ON GH.GoodsID=SUBSTRING(D.GoodsID,' + ltrim(rtrim(STR(@str_Goods+1))) + ',' + ltrim(rtrim(STR( @str_GoodsSum))) + ') AND GH.PartNumber=' + ltrim(rtrim(STR(@UnitPart)))+ '
			--LEFT JOIN inv.tblGoodsDtl GD ON GD.GoodsID=SUBSTRING(D.GoodsID,' + ltrim(rtrim(STR(@str_Goods+1))) + ',' + ltrim(rtrim(STR(@str_GoodsSum))) + ') AND GD.PartNumber=' + ltrim(rtrim(STR(@UnitPart)))+ '
			LEFT JOIN inv.tblUnitsDtl UD on UD.UnitID=GH.UnitID
	WHERE ' + @StrWhere

	set @StrWhere2 = '(1=1)'
	
	if (@RemainOnly=1)
		set @StrWhere2 = @StrWhere2 + ' and (GoodsQuantity-SoldQty > 0)'
	ELSE if (@RemainOnly=2)
		set @StrWhere2 = @StrWhere2 + ' and (SoldQty > 0)'

	set @StrSelect = 'select * from (' + @StrSelect +@StrSelect2 + ') T where ' + @StrWhere2
	------------------------------------------------------------

	-- SORT Clause ---------------------------------------------
	If (@SortFields Is Not Null)
		Set @StrSelect = @StrSelect + ' 
	ORDER BY ' + @SortFields
	------------------------------------------------------------

	-- RUN -----------------------------------------------------
	Print @StrSelect;
	Exec sp_executesql @StrSelect;
	------------------------------------------------------------
End
GO
