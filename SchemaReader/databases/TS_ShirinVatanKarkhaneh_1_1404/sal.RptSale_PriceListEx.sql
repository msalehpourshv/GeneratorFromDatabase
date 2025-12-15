USE TS_ShirinVatanKarkhaneh_1_1404
GO
SET ANSI_NULLS, QUOTED_IDENTIFIER ON
GO
-- =========== TS-QC:UPDATED ====================
-- Author		 : TakroSystem\Zia
-- Creation Date : 1389/02/29
-- Viewed By	 : 
-- Last Modified : 1391/05/28
-- Last Modifier : TakroSystem\Zia
-- Description   : 
-- ==============================================
Create PROCEDURE [sal].[RptSale_PriceListEx]
	@SelectedGoods	Int = 0,
	@CustomerCode1	VarChar(20) = null,
	@CustomerCode2	VarChar(20) = null,
	@CustomerCode3	VarChar(20) = null,
	@CustomerName1	VarChar(50) = null,
	@CustomerName2	VarChar(50) = null,
	@CustomerName3	VarChar(50) = null,
	@DateTo			Char(10) = Null,
	@SortFields		VarChar(100) = Null,
	@RepOptions		VarChar(100) = '00',
	@RepInfo		NVarChar(100) = '1@1@1'
WITH ENCRYPTION
AS 
DECLARE @LangID		Char(1);
DECLARE @SerialNo	VarChar(10);
DECLARE @SessionNo	VarChar(10);
DECLARE @ReportID	VarChar(10);

DECLARE @StrSelect1	NVarChar(max);
DECLARE @StrSelect2	NVarChar(max);
DECLARE @StrWhere	NVarChar(max);
DECLARE	@CurrencyTypeID	VarChar(20);

DECLARE @InvDate		Char(10);
DECLARE @Amount1		NVarChar(200);
DECLARE @Percnt1		NVarChar(200);
DECLARE @Discnt1		NVarChar(200);
DECLARE @Description1	NVarChar(max);
DECLARE @Amount2		NVarChar(200);
DECLARE @Percnt2		NVarChar(200);
DECLARE @Discnt2		NVarChar(200);
DECLARE @Description2	NVarChar(max);
DECLARE @Amount3		NVarChar(200);
DECLARE @Percnt3		NVarChar(200);
DECLARE @Discnt3		NVarChar(200);
DECLARE @Description3	NVarChar(max);
DECLARE @CloseCode		Char(1);
DECLARE	@ZeroRemain		Bit; -- شامل سطرهاي با موجودي صفر

BEGIN --============== S T A R T  C O D E ===================================================

	SET NoCount On;

	--==============
	DECLARE @UnitPart TINYINT
	SET @UnitPart  = 1
	SET @SerialNo = ''
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

	-- I N I T ----------------------------------------------------------------
	if (@RepInfo is Null)		set @RepInfo = '1@1@1';
	if (@RepOptions	= '')		set @RepOptions = '0000';
	if (@RepOptions	is Null)	set @RepOptions = '0000';
	if (@SortFields	is null)	set @SortFields = 'D.GoodsID';
	if (@CustomerCode1 is null)	set @CustomerCode1 = '';
	if (@CustomerCode2 is null)	set @CustomerCode2 = '';
	if (@CustomerCode3 is null)	set @CustomerCode3 = '';

	set	@LangID		= pub.funSplitString(@RepInfo, '@', 1);
	set @SessionNo	= pub.funSplitString(@RepInfo, '@', 2);
	set @ReportID	= pub.funSplitString(@RepInfo, '@', 3);
	set @SerialNo	= pub.funSplitString(@RepInfo, '@', 6);
	set @CurrencyTypeID	= pub.funSplitString(@RepInfo, '@', 7);
	
	SET @CloseCode		= Substring(@RepOptions, 4, 1);
	SET @ZeroRemain		= Substring(@RepOptions, 5, 1);
	
	if (@DateTo is null)
		set @InvDate = '9999/99/99'
	else
		set @InvDate = @DateTo
	---------------------------------------------------------------------------
	set @StrWhere = '(1=1)'
	if (@CloseCode=0)
		Set @StrWhere = @StrWhere + ' AND (SELECT COUNT(*) 
										   FROM inv.tblGoods H1 
										   WHERE H1.CodeClosed = ''True''
											 AND SUBSTRING(GH.GoodsID,1,LEN(H1.GoodsID)) = H1.GoodsID) = 0'
	
	if (@CustomerCode1 = '')
	begin
		set @Amount1 = '0';
		set @Discnt1 = '0';
		set @Percnt1 = '0';
		Set @Description1 = '';
	end
	else
	begin
		set @Amount1 = 'D.Amount' + @CustomerCode1;
		set @Discnt1 = 'D.Discount' + @CustomerCode1;
		set @Percnt1 = 'D.DiscountPercent' + @CustomerCode1;
		set @Description1 = 'D.Description' + @CustomerCode1;
	end;

	if (@CustomerCode2 = '')
	begin
		set @Amount2 = '0';
		set @Discnt2 = '0';
		set @Percnt2 = '0';
		Set @Description2 = '';
	end
	else
	begin
		set @Amount2 = 'D.Amount' + @CustomerCode2;
		set @Discnt2 = 'D.Discount' + @CustomerCode2;
		set @Percnt2 = 'D.DiscountPercent' + @CustomerCode2;
		set @Description2 = 'D.Description' + @CustomerCode2;
	end;

	if (@CustomerCode3 = '')
	begin
		set @Amount3 = '0';
		set @Discnt3 = '0';
		set @Percnt3 = '0';
		Set @Description3 = '';
	end
	else
	begin
		set @Amount3 = 'D.Amount' + @CustomerCode3;
		set @Discnt3 = 'D.Discount' + @CustomerCode3;
		set @Percnt3 = 'D.DiscountPercent' + @CustomerCode3;
		set @Description3 = 'D.Description' + @CustomerCode3;
	end;
	
	if (@SerialNo <> '0') and  (@SerialNo <> '')
		set @StrWhere = @StrWhere + ' AND D.SerialNo=' + @SerialNo
		
	if (@CurrencyTypeID  is not null) and  (@CurrencyTypeID <> '')
		set @StrWhere = @StrWhere + ' AND D.CurrencyTypeID=''' + @CurrencyTypeID +''''		
		
	if (@SelectedGoods > 0)
		set @StrWhere = @StrWhere + ' AND ' + pub.funGetFilterString(@SessionNo, @ReportID, @SelectedGoods, 'D.GoodsID') 

	if (@DateTo is not null)
		set @StrWhere = @StrWhere + 
			  ' AND ((D.FromDate<''' +  @DateTo + ''' OR (D.FromDate=''' +  @DateTo + ''' AND D.FromTime<=substring(convert(varchar(10), GETDATE(), 108),1,5))
				   AND
				     (D.ToDate>''' +  @DateTo + ''' OR   (D.ToDate=''' +  @DateTo + ''' AND  D.ToTime>=substring(convert(varchar(10), GETDATE(), 108),1,5) ))
			     	)) '
	
	if (@SerialNo = '0') OR  (@SerialNo = '')
	BEGIN
	Declare @strCustomerKindDate as nvarchar (1000) = ''
	IF @CustomerCode1 <> '' and @CustomerCode2 <> '' and @CustomerCode3 <> ''
		SET @strCustomerKindDate = ' AND H1.CustomerKind in ('+@CustomerCode1+','+@CustomerCode2+','+@CustomerCode3+')'
	IF @CustomerCode1 <> '' and @CustomerCode2 = '' and @CustomerCode3 <> ''
		SET @strCustomerKindDate = ' AND H1.CustomerKind in ('+@CustomerCode1+','+@CustomerCode3+')'
	IF @CustomerCode1 = '' and @CustomerCode2 <> '' and @CustomerCode3 <> ''
		SET @strCustomerKindDate = ' AND H1.CustomerKind in ('+@CustomerCode2+','+@CustomerCode3+')'
	IF @CustomerCode1 <> '' and @CustomerCode2 <> '' and @CustomerCode3 = ''
		SET @strCustomerKindDate = ' AND H1.CustomerKind in ('+@CustomerCode1+','+@CustomerCode2+')'
	IF @CustomerCode1 <> '' and @CustomerCode2 = '' and @CustomerCode3 = ''
		SET @strCustomerKindDate = ' AND H1.CustomerKind in ('+@CustomerCode1+')'
	IF @CustomerCode1 = '' and @CustomerCode2 <> '' and @CustomerCode3 = ''
		SET @strCustomerKindDate = ' AND H1.CustomerKind in ('+@CustomerCode2+')'
	IF @CustomerCode1 <> '' and @CustomerCode2 = '' and @CustomerCode3 <> ''
		SET @strCustomerKindDate = ' AND H1.CustomerKind in ('+@CustomerCode3+')'

		set @StrWhere = @StrWhere +  
			' AND (
			D.FromDate = 
			(
				SELECT MAX(FromDate) 
				FROM sal.tblGoodsPriceForCustomerKindHdr H1
				INNER JOIN sal.tblGoodsPriceForCustomerKindDtl D1 ON H1.SerialNo = D1.SerialNo
				WHERE D1.GoodsID = D.GoodsID 
				  AND H1.CurrencyTypeID = D.CurrencyTypeID
				  '+ @strCustomerKindDate +'
			) OR
			D.FromDate2 = 
			(
				SELECT MAX(FromDate) 
				FROM sal.tblGoodsPriceForCustomerKindHdr H1
				INNER JOIN sal.tblGoodsPriceForCustomerKindDtl D1 ON H1.SerialNo = D1.SerialNo
				WHERE D1.GoodsID = D.GoodsID 
				  AND H1.CurrencyTypeID = D.CurrencyTypeID
				  '+ @strCustomerKindDate +'
			) OR
			D.FromDate3 = 
			(
				SELECT MAX(FromDate) 
				FROM sal.tblGoodsPriceForCustomerKindHdr H1
				INNER JOIN sal.tblGoodsPriceForCustomerKindDtl D1 ON H1.SerialNo = D1.SerialNo
				WHERE D1.GoodsID = D.GoodsID 
				  AND H1.CurrencyTypeID = D.CurrencyTypeID
				  '+ @strCustomerKindDate +'
			)
			)'	
	END
	If (@ZeroRemain = 0)
		SET @StrWhere = @StrWhere + ' AND (D.GoodsID In 
									  (Select T.GoodsID From
											(Select D.GoodsID, 
												   SUM(CASE WHEN D.EnterKind = +1 THEN D.GoodsQuantity ELSE 0 END) TotalQuantityInput,
												   SUM(CASE WHEN D.EnterKind = -1 THEN D.GoodsQuantity ELSE 0 END) TotalQuantityOutput,
												   SUM(CASE WHEN D.EnterKind = +1 THEN D.GoodsQuantity ELSE 0 END) -
												   SUM(CASE WHEN D.EnterKind = -1 THEN D.GoodsQuantity ELSE 0 END) As GoodsRemain   
											 From inv.tblStorageDocsDtl D
											 Group by D.GoodsID) T
										Where T.GoodsRemain > 0)) '	
	
	-- ============================================================
	IF @Description1 IS null OR @Description1=''
		SET @Description1 = ''''''
	IF @Description2 IS null OR @Description2=''
		SET @Description2 = ''''''
	IF @Description3 IS null  OR @Description3=''
		SET @Description3 = ''''''

	Declare @T1NewWhere as nvarchar (1000) = ''
	IF @CustomerCode1 <> ''
		Set @T1NewWhere = ' AND (H.CustomerKind = '''+ @CustomerCode1 +''' OR H.CustomerKind = '''')'

	Declare @T2NewWhere as nvarchar (1000) = ''
	IF @CustomerCode2 <> ''
		Set @T2NewWhere = ' AND (H.CustomerKind = '''+ @CustomerCode2 +''' OR H.CustomerKind = '''')'

	Declare @T3NewWhere as nvarchar (1000) = ''
	IF @CustomerCode3 <> ''
		Set @T3NewWhere = ' AND (H.CustomerKind = '''+ @CustomerCode3 +''' OR H.CustomerKind = '''')'
	
	Declare @strCustomerKind as nvarchar (1000) = ''
	IF @CustomerCode1 <> '' and @CustomerCode2 <> '' and @CustomerCode3 <> ''
		SET @strCustomerKind = 'H.CustomerKind in ('+@CustomerCode1+','+@CustomerCode2+','+@CustomerCode3+') AND '
	IF @CustomerCode1 <> '' and @CustomerCode2 = '' and @CustomerCode3 <> ''
		SET @strCustomerKind = 'H.CustomerKind in ('+@CustomerCode1+','+@CustomerCode3+') AND '
	IF @CustomerCode1 = '' and @CustomerCode2 <> '' and @CustomerCode3 <> ''
		SET @strCustomerKind = 'H.CustomerKind in ('+@CustomerCode2+','+@CustomerCode3+') AND '
	IF @CustomerCode1 <> '' and @CustomerCode2 <> '' and @CustomerCode3 = ''
		SET @strCustomerKind = 'H.CustomerKind in ('+@CustomerCode1+','+@CustomerCode2+') AND '
	IF @CustomerCode1 <> '' and @CustomerCode2 = '' and @CustomerCode3 = ''
		SET @strCustomerKind = 'H.CustomerKind in ('+@CustomerCode1+') AND '
	IF @CustomerCode1 = '' and @CustomerCode2 <> '' and @CustomerCode3 = ''
		SET @strCustomerKind = 'H.CustomerKind in ('+@CustomerCode2+') AND '
	IF @CustomerCode1 <> '' and @CustomerCode2 = '' and @CustomerCode3 <> ''
		SET @strCustomerKind = 'H.CustomerKind in ('+@CustomerCode3+') AND '

	SET @StrSelect1 = '
	SELECT SerialNo,
		   DocDate,
		   D.GoodsID,
		   Amount,
		   ManualUserPrice,
		   D.GoodsName,
		   D.BarCode,
		   Amount1,
		   Amount2,
		   Amount3,
		   Percent1,
		   Percent2,
		   Percent3,
		   Discount1,
		   Discount2,
		   Discount3,
		   Description1,
		   Description2,
		   Description3,
		   ISNULL(SU.UnitValue,1) UnitValue,     
		   ISNULL(SU.MainUnitValue,1) MainUnitValue,      
		   ISNULL(D.SubUnitID, '''') UnitID,    
		   UD.UnitName,     
		   US.UnitID SubUnitID, 
		   US.UnitName SubUnitName,  
		   GH.UnitID MainUnitID,    
		   UM.UnitName MainUnitName,
		   D.SubUnitID,
		   LastBuyPrice
	FROM
	(SELECT 
		   ISNULL(a.SerialNo,0) SerialNo, 
	 	   ISNULL(a.DocDate,'''') DocDate,
		   ISNULL(a.GoodsID, '''') GoodsID,
		   ISNULL(a.Amount,0) Amount,
		   ISNULL(a.ManualUserPrice, 0) ManualUserPrice,
		   [pub].[funGetGoodsName](a.GoodsID,' + LTrim(RTrim(@LangID)) + ') GoodsName,
	 	   ISNULL([inv].[FunGetGoodsBarCode] (a.GoodsID), '''') BarCode,
		   ISNULL(Amount1, 0) Amount1, ISNULL(Percent1, 0) Percent1, ISNULL(Discount1, 0) Discount1, ISNULL(Description1, '''') as Description1,
		   ISNULL(Amount2, 0) Amount2, ISNULL(Percent2, 0) Percent2, ISNULL(Discount2, 0) Discount2, ISNULL(Description2, '''') as Description2,
		   ISNULL(Amount3, 0) Amount3, ISNULL(Percent3, 0) Percent3, ISNULL(Discount3, 0) Discount3, ISNULL(Description3, '''') as Description3,
		   a.FromDate,
		   b.FromDate2,
		   c.FromDate3,
		   a.ToDate,
		   a.CurrencyTypeID,
		   a.FromTime,
		   a.ToTime,
		   a.SubUnitID,
		   ISNULL((SELECT TOP 1 GoodsPrice
	 			   FROM inv.tblStorageDocsDtl
	 			   WHERE (GoodsID = a.GoodsID) 
	 				 AND (DocDate <= ''' + @InvDate + ''') 
	 				 AND (GoodsPrice > 0) 
	 				 AND (ProcessID = 55) 
	 			   ORDER BY DocDate DESC, VolumeRowNo DESC
	 			   ),0) LastBuyPrice
	FROM
		(SELECT D.SerialNo,          
				D.DocDate,        
				D.GoodsID,        
				D.Amount,         
				D.SubUnitID UnitID, 
				D.FromDate,
				D.ToDate,
				D.FromTime,
				D.ToTime,
				D.CurrencyTypeID,
				D.SubUnitID,
				[pub].[funGetGoodsName](D.GoodsID,1) GoodsName,   
				ISNULL([inv].[FunGetGoodsBarCode] (D.GoodsID), '''') BarCode,     
				D.ManualUserPrice,
				ISNULL(' + @Amount1 + ',0) Amount1, ISNULL(' + @Percnt1 + ',0) Percent1, ISNULL(' + @Discnt1 + ',0) Discount1, ISNULL('+@Description1+','''') as Description1 
		 FROM (SELECT ROW_NUMBER()over(partition by GoodsID order by H.CustomerKind desc,FromDate desc ) R,
					  H.FromDate,
					  H.ToDate,
					  H.FromTime,
					  H.ToTime,
					  H.CustomerKind,
					  H.CurrencyTypeID,
					  D.*
			   FROM sal.tblGoodsPriceForCustomerKindDtl D
			   INNER JOIN sal.tblGoodsPriceForCustomerKindHdr H ON H.SerialNo = D.SerialNo 
			   WHERE (1=1) 
				      ' + @T1NewWhere 

		SET @StrSelect2 = '
			  ) D WHERE R=1 ) a
		Full join (SELECT D.SerialNo SerialNoA2,
						  D.DocDate DocDateA2,
						  D.FromDate2, 
						  D.GoodsID,
						  D.Amount AmountA2,
						  ISNULL(' + @Amount2 + ',0) Amount2, ISNULL(' + @Percnt2 + ',0) Percent2, ISNULL(' + @Discnt2 + ',0) Discount2, ISNULL('+@Description2+','''') as Description2
				   FROM (SELECT ROW_NUMBER()over(partition by GoodsID order by H.CustomerKind desc,FromDate desc ) R,
								H.FromDate FromDate2,
								H.ToDate ToDate2,
								H.FromTime FromTime2,
								H.ToTime ToTime2,
								H.CustomerKind CustomerKind2,
								H.CurrencyTypeID CurrencyTypeID2,
								D.*
						 FROM sal.tblGoodsPriceForCustomerKindDtl D
						 INNER JOIN sal.tblGoodsPriceForCustomerKindHdr H ON H.SerialNo = D.SerialNo 
						 WHERE (1=1) 
						    ' + @T2NewWhere +'
						) D WHERE R=1 ) b on a.GoodsID = b.GoodsID
		FULL JOIN (SELECT D.SerialNo SerialNoA3, 
						  D.DocDate DocDateA3,
						  D.FromDate3,
						  D.GoodsID,
						  D.Amount AmountA3,
						  ISNULL(' + @Amount3 + ',0) Amount3, ISNULL(' + @Percnt3 + ',0) Percent3, ISNULL(' + @Discnt3 + ',0) Discount3, ISNULL('+@Description3+','''') as Description3
				   FROM (SELECT ROW_NUMBER()over(partition by GoodsID order by H.CustomerKind desc,FromDate desc ) R,
								H.FromDate FromDate3,
								H.ToDate ToDate3,
								H.FromTime FromTime3,
								H.ToTime ToTime3,
								H.CustomerKind CustomerKind3,
								H.CurrencyTypeID CurrencyTypeID3,
								D.*
						 FROM sal.tblGoodsPriceForCustomerKindDtl D
						 INNER JOIN sal.tblGoodsPriceForCustomerKindHdr H ON H.SerialNo = D.SerialNo 
						 WHERE (1=1) 
						   ' + @T3NewWhere +'
						) D WHERE R=1 ) c ON a.GoodsID = c.GoodsID	
	) D
	INNER JOIN inv.tblGoods GH ON GH.GoodsID = SUBSTRING(D.GoodsID,' + ltrim(rtrim(STR(@str_Goods+1))) + ',' + ltrim(rtrim(STR( @str_GoodsSum))) + ') AND GH.PartNumber=' + ltrim(rtrim(STR(@UnitPart)))+ '
	INNER JOIN inv.tblGoodsDtl GD ON GD.GoodsID = SUBSTRING(D.GoodsID,' + ltrim(rtrim(STR(@str_Goods+1))) + ',' + ltrim(rtrim(STR(@str_GoodsSum))) + ') AND GD.PartNumber=' + ltrim(rtrim(STR(@UnitPart))) + ' And GD.LanguageID = ' + LTrim(RTrim(@LangID)) + '
	LEFT JOIN inv.tblUnitsDtl UD on UD.UnitID = D.SubUnitID 
	LEFT JOIN inv.tblUnitsDtl UM on UM.UnitID = GH.UnitID 
	LEFT JOIN inv.tblSubUnitsDtl SU on SU.GoodsID=D.GoodsID and SU.ShowInInvoice=1
	LEFT JOIN inv.tblUnitsDtl US on US.UnitID = SU.SubUnitID
	WHERE ' + @StrWhere + 
	'
	ORDER BY ' + @SortFields + ',SerialNo desc,DocDate desc'
	
	--select @StrSelect1
	--select @StrSelect2
	PRINT @StrSelect1;
	PRINT @StrSelect2;

	Set @StrSelect1 = @StrSelect1 + @StrSelect2
	EXEC sp_executesql @StrSelect1;

END
GO
