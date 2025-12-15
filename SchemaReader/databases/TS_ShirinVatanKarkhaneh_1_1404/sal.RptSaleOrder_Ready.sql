USE TS_ShirinVatanKarkhaneh_1_1404
GO
SET ANSI_NULLS, QUOTED_IDENTIFIER ON
GO
-- =========== TS-QC:UPDATED ====================
-- Author        : TakroSystem\Ahmadnejad
-- Create date   : 1386/11/14
-- Viewed By	 : Majid Mohammadi
-- Last Modified : 1392/05/22
-- Last Modifier : TakroSystem\Zia
-- Description   : آمار (یا وضعیت) سفارش یک کالا یا یک سفارش دهنده
-- ==============================================
Create PROCEDURE [sal].[RptSaleOrder_Ready]
	@ProcessNo		Int = 1,
	@GoodsID		VarChar(20) = NULL,
	@AcntCode		VarChar(20) = NULL,
	@AgreeNoFr		VarChar(20) = NULL,
	@AgreeNoTo		VarChar(20) = NULL,
	@SelectedGoods	Int = NULL, 
	@SelectedStore	Int = NULL, 
	@SelectedOrder1	Int = NULL, 
	@SelectedOrder2	Int = NULL, 
	@SelectedOrder3	Int = NULL, 
	@SelectedOrder4	Int = NULL, 
	@VisitorCode1	Int = NULL,
	@VisitorCode2	Int = NULL,
	@VisitorCode3	Int = NULL,
	@VisitorCode4	Int = NULL,
	@RepOptions		VarChar(20) = '1002', -- bit array
	@RepInfo		NVarChar(100) = '1@1@1'
WITH ENCRYPTION
AS 
Declare @RemainOnly	Bit; -- فقط سفارشاتی که مانده دارند (سفارش با تحویل برابر نیست) بیاید؟
Declare @DecRet		Bit; 
Declare @AcntFT		Bit; 
Declare @PE			Bit; 
Declare @DocStep	Int;

Declare @StrSelect	NVarChar(max);
Declare @StrWhere	NVarChar(max);
Declare @StrFrom	NVarChar(max);
DECLARE @StrWhereS	NVarChar(max);
DECLARE @StrWhereX	NVarChar(max);

Declare @CodeField	VarChar(20);
Declare @NameField	NVarChar(200);
Declare @BalanceField	VarChar(2000);

DECLARE @LangID		Char(1);
DECLARE @SessionNo	VarChar(10);
DECLARE @ReportID	VarChar(10);

DECLARE @AcntCodeTo	VarChar(20);
Declare @SoldOnly		Bit; 
DECLARE @round_val		int;
DECLARE @GetRemainSaleOrder	Bit;
Begin --============== S T A R T  C O D E ===================================================

	Set NoCount On;

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

	SET @GetRemainSaleOrder = 'False'
	SELECT @GetRemainSaleOrder = SettingValue
	FROM pub.tblSettings
	WHERE SettingKey = 'GetRemainSaleOrder'
	
	-- I N I T ----------------------------------------------------------------
	IF (@RepInfo	Is Null)	SET @RepInfo    = '1@1@1'
	IF (@RepOptions	Is Null)	SET @RepOptions = '10';
	If (@ProcessNo	Is Null)	SET @ProcessNo  = 1;

	If (@SelectedGoods Is Null) SET @SelectedGoods = 0;
	If (@SelectedStore Is Null) SET @SelectedStore = 0;

	IF (@SelectedOrder1 Is Null)	SET @SelectedOrder1 = 0
	IF (@SelectedOrder2 Is Null)	SET @SelectedOrder2 = 0
	IF (@SelectedOrder3 Is Null)	SET @SelectedOrder3 = 0
	IF (@SelectedOrder4 Is Null)	SET @SelectedOrder4 = 0

	IF (@VisitorCode1 Is Null)	SET @VisitorCode1 = 0
	IF (@VisitorCode2 Is Null)	SET @VisitorCode2 = 0
	IF (@VisitorCode3 Is Null)	SET @VisitorCode3 = 0
	IF (@VisitorCode4 Is Null)	SET @VisitorCode4 = 0

	SET	@LangID		= pub.funSplitString(@RepInfo, '@', 1);
	SET @SessionNo	= pub.funSplitString(@RepInfo, '@', 2);
	SET @ReportID	= pub.funSplitString(@RepInfo, '@', 3);

	SET @RemainOnly	= Substring(@RepOptions, 1, 1);
	SET @DecRet		= Substring(@RepOptions, 2, 1);

	if len(@RepOptions) > 2
		SET @AcntFT	= Substring(@RepOptions, 3, 1);
	else
		SET @AcntFT	= 0;

	if len(@RepOptions) > 3
		SET @PE	= Substring(@RepOptions, 4, 1);
	else
		SET @PE	= 1;
	
	if len(@RepOptions) > 4
		SET @DocStep= Substring(@RepOptions, 5, 1);
	else
		SET @DocStep= 1;
		
	if len(@RepOptions) > 5
		SET @SoldOnly= Substring(@RepOptions, 6, 1);
	else
		SET @SoldOnly= 0;
	
	if (@AcntFT = 1)
	begin
		set @AcntCodeTo = @GoodsID;
		set @GoodsID = null;
	end
	
	select @round_val = isnull(SettingValue, 0)
	from pub.tblSettings
	where SettingKey = 'QuantityDecimals'	
	---------------------------------------------------------------------------
	-- W H E R E --------------------------------------------------------------
	SET @StrWhere = '(D.ProcessID=180) AND D.ProcessNo=' + LTrim(Str(@ProcessNo))

	-- Goods
	If (@GoodsID Is Not Null)
		SET @StrWhere = @StrWhere + ' AND (D.GoodsID=''' + @GoodsID + ''')'
	If	(@SelectedGoods > 0)
		SET @StrWhere = @StrWhere + ' AND ' + pub.funGetFilterString(@SessionNo, @ReportID, @SelectedGoods, 'D.GoodsID') 

	-- Acnt
	if (@AcntFT = 1)
	begin
		if (@AcntCode is not null)
			set @StrWhere = @StrWhere + ' AND (D.AcntCode >= ''' + @AcntCode + ''')'
		if (@AcntCodeTo is not null)
			SET @StrWhere = @StrWhere + ' AND (D.AcntCode <= ''' + @AcntCodeTo + ''')'
	end
	else
		if (@AcntCode Is Not Null)
			set @StrWhere = @StrWhere + ' AND D.AcntCode = ''' + @AcntCode + ''''

	If	(@SelectedOrder1 > 0)
		SET @StrWhere = @StrWhere + ' AND ' + pub.funGetFilterString(@SessionNo, @ReportID, @SelectedOrder1, 'D.AcntCode') 
	If	(@SelectedOrder2 > 0)
		SET @StrWhere = @StrWhere + ' AND ' + pub.funGetFilterString(@SessionNo, @ReportID, @SelectedOrder2, 'D.AcntCode') 
	If	(@SelectedOrder3 > 0)
		SET @StrWhere = @StrWhere + ' AND ' + pub.funGetFilterString(@SessionNo, @ReportID, @SelectedOrder3, 'D.AcntCode') 
	If	(@SelectedOrder4 > 0)
		SET @StrWhere = @StrWhere + ' AND ' + pub.funGetFilterString(@SessionNo, @ReportID, @SelectedOrder4, 'D.AcntCode') 

	-- Visitor
	If	(@VisitorCode1 > 0)
		SET @StrWhere = @StrWhere + ' AND ' + pub.funGetFilterString(@SessionNo, @ReportID, @VisitorCode1, 'H.VisitorAcntCode')
	If	(@VisitorCode2 > 0)
		SET @StrWhere = @StrWhere + ' AND ' + pub.funGetFilterString(@SessionNo, @ReportID, @VisitorCode2, 'H.VisitorAcntCode')
	If	(@VisitorCode3 > 0)
		SET @StrWhere = @StrWhere + ' AND ' + pub.funGetFilterString(@SessionNo, @ReportID, @VisitorCode3, 'H.VisitorAcntCode')
	If	(@VisitorCode4 > 0)
		SET @StrWhere = @StrWhere + ' AND ' + pub.funGetFilterString(@SessionNo, @ReportID, @VisitorCode4, 'H.VisitorAcntCode')

	-- AgreeNo
	If (@AgreeNoFr Is Not Null)
		SET @StrWhere = @StrWhere + ' AND D.AgreeNo >= ''' + @AgreeNoFr + '''' 
	If (@AgreeNoTo Is Not Null)
		SET @StrWhere = @StrWhere + ' AND D.AgreeNo <= ''' + @AgreeNoTo + '''' 

	-- DocStep
	If (@DocStep > 0)
		Set @StrWhere = @StrWhere + ' AND (D.DocStep = ' + Str(@DocStep) + ')'
	---------------------------------------------------------------------------

	-- S E L E C T ------------------------------------------------------------
	declare @Where_Balance nvarchar(2000)
	if (@PE = 0)
		set @Where_Balance = '(PhysicallyEffected = 1)'
	else
		set @Where_Balance = '(1=1)'

	if (@SelectedStore <> 0)
		set @Where_Balance = @Where_Balance + ' and ' + pub.funGetFilterString(@SessionNo, @ReportID, @SelectedStore, 'StoreID')
	
	If (@GoodsID Is Not Null)
	Begin
		Set @CodeField = 'AcntCode'
		Set @NameField = '[pub].GetCodeName(T.AcntCode, ' + @LangID + ') As AcntName, '''' BarCode'
		Set @BalanceField = '0'
	End
	Else
	Begin
		Set @CodeField = 'GoodsID'
		Set @NameField = '[pub].[funGetGoodsName](T.GoodsID,' + LTrim(RTrim(@LangID)) + ') As GoodsName,
   						  IsNull([inv].[FunGetGoodsBarCode] (T.GoodsID), '''') BarCode'
		
		Set @BalanceField = '
			(
				select isNull(sum(GoodsQuantity * EnterKind), 0) Balance
				from inv.tblStorageDocsDtl
				where ' + @Where_Balance + ' and (GoodsID = T.GoodsID)
			) '
	End
		
	if (@DecRet = 1) 
		set @StrSelect = '
			(
				SELECT	IsNull(Sum(GoodsQuantity), 0) AS SoldRet
				FROM    inv.tblStorageDocsDtl
				WHERE   BaseProcessID = SD.ProcessID AND BaseProcessNo = SD.ProcessNo AND BaseFiscalYear = SD.FiscalYear AND BaseSerialNo = SD.SerialNo AND	BaseDocRowNo = SD.DocRowNo
			)'
	else
		set @StrSelect = 'cast(0 as float)'

	set @StrWhereS = '(SD.ProcessID=90)'
	
	--- extended ------------------------------------------------
	
	set @StrWhereX = '(1=1)'
	
	-- مقدار تحویل داده شده بیشتر از صفر باشد
	if (@SoldOnly = 1)
		set @StrWhereX = @StrWhereX + ' AND (Round(SoldQuantity,' + ltrim(str(@round_val)) + ')>0)'

	-- مقدار تحویل داده شده برابر با خالص سفارش نباشد
	if (@RemainOnly = 1)
		set @StrWhereX = @StrWhereX + ' AND (Round(OrderQuantity-(SoldQuantity-SoldRetQuantity),' + ltrim(str(@round_val)) + ')<>0)'

IF @GetRemainSaleOrder = 'TRUE'
	BEGIN
		Set @StrSelect = '
		SELECT	' + @CodeField + ', Sum(OrderQuantity) OrderQuantity, 
				Sum(SoldQuantity) SoldQuantity, Sum(SoldRetQuantity) SoldRetQuantity, 
				' + @NameField + ', ' + @BalanceField + ' BalanceQuantity
		FROM
		(
			SELECT	D.' + @CodeField + ', 
					(D.GoodsQuantity - 
						(
							SELECT	IsNull(Sum(GoodsQuantity), 0)
							FROM	sal.tblSaleOrderDtl
							WHERE	BaseProcessID = D.ProcessID AND BaseProcessNo = D.ProcessNo AND BaseFiscalYear = D.FiscalYear AND BaseSerialNo = D.SerialNo AND BaseDocRowNo = D.DocRowNo
						)
					) AS OrderQuantity,
					(
						-- sum of sold qty 
						SELECT IsNull(Sum(Sold), 0)
						FROM
						(
							SELECT	GoodsQuantity AS Sold
							FROM	inv.tblStorageDocsDtl SD
							WHERE	' + @StrWhereS + '
								AND SD.BaseProcessID = D.ProcessID 
								AND SD.BaseProcessNo = D.ProcessNo 
								AND SD.BaseFiscalYear = D.FiscalYear 
								AND SD.BaseSerialNo = D.SerialNo 
								AND SD.BaseDocRowNo = D.DocRowNo
						) Sale
					) AS SoldQuantity, 0 AS SoldRetQuantity
			FROM    sal.tblSaleOrderDtl AS D
						INNER JOIN sal.tblSaleOrderHdr H ON H.ProcessID = D.ProcessID AND H.ProcessNo = D.ProcessNo AND H.FiscalYear = D.FiscalYear AND H.SerialNo = D.SerialNo
			WHERE   ' + @StrWhere + '
		) T  
		WHERE ' + @StrWhereX + '
		GROUP BY T.' + @CodeField
	END
ELSE
	BEGIN
		Set @StrSelect = '
		SELECT	' + @CodeField + ', Sum(OrderQuantity) OrderQuantity, 
				Sum(SoldQuantity) SoldQuantity, Sum(SoldRetQuantity) SoldRetQuantity, 
				' + @NameField + ', ' + @BalanceField + ' BalanceQuantity
		FROM
		(
			SELECT	D.' + @CodeField + ', 
					(D.GoodsQuantity - 
						(
							SELECT	IsNull(Sum(GoodsQuantity), 0)
							FROM	sal.tblSaleOrderDtl
							WHERE	BaseProcessID = D.ProcessID AND BaseProcessNo = D.ProcessNo AND BaseFiscalYear = D.FiscalYear AND BaseSerialNo = D.SerialNo AND BaseDocRowNo = D.DocRowNo
						)
					) AS OrderQuantity,
					(
						-- sum of sold qty 
						SELECT IsNull(Sum(Sold), 0)
						FROM
						(
							SELECT	GoodsQuantity AS Sold
							FROM	inv.tblStorageDocsDtl SD
							WHERE	' + @StrWhereS + '
								AND SD.BaseProcessID = D.ProcessID 
								AND SD.BaseProcessNo = D.ProcessNo 
								AND SD.BaseFiscalYear = D.FiscalYear 
								AND SD.BaseSerialNo = D.SerialNo 
								AND SD.BaseDocRowNo = D.DocRowNo
						) Sale
					) AS SoldQuantity, 0 AS SoldRetQuantity
			FROM    sal.tblSaleOrderDtl AS D
						INNER JOIN sal.tblSaleOrderHdr H ON H.ProcessID = D.ProcessID AND H.ProcessNo = D.ProcessNo AND H.FiscalYear = D.FiscalYear AND H.SerialNo = D.SerialNo
			WHERE   ' + @StrWhere + '
			  AND (SELECT COUNT(*)
				   FROM inv.tblStorageDocsDtl SD
				   WHERE D.ProcessID = SD.BaseProcessID
				     AND D.ProcessNo = SD.BaseProcessNo 
					 AND D.FiscalYear = SD.BaseFiscalYear  
					 AND D.SerialNo = SD.BaseSerialNo 
					 AND SD.ProcessID = 90) = 0
		) T  
		WHERE ' + @StrWhereX + '
		GROUP BY T.' + @CodeField
	END

	---- S O R T --------------------------------------------------------------
	Set @StrSelect = @StrSelect + '
	ORDER BY T.' + @CodeField 
	---------------------------------------------------------------------------

	---- R U N ----------------------------------------------------------------
	Print @StrSelect;
	Exec sp_executesql @StrSelect;
	---------------------------------------------------------------------------
End
GO
