USE TS_ShirinVatanKarkhaneh_1_1404
GO
SET ANSI_NULLS, QUOTED_IDENTIFIER ON
GO
-- =========== TS-QC:UPDATED ====================
-- Author        : TakroSystem\Ahmadnejad
-- Create date   : 1387/02/14
-- Viewed By	 : 
-- Last Modified : 1389/06/25
-- Last Modifier : TakroSystem\Zia
-- Description   : لیست سفارشات یک سفارش دهنده 
-- =============================================
Create PROCEDURE [sal].[RptSaleOrder_Docs_Acnt]
	@ProcessNo		Int = 1,
	@FiscalYearFr	Int = NULL,
	@FiscalYearTo	Int = NULL,
	@SerialNoFr		Int = NULL,
	@SerialNoTo		Int = NULL,
	@DateFr			Char(10) = NULL,
	@DateTo			Char(10) = NULL,
	@AgreeNoFr		VarChar(20) = NULL,
	@AgreeNoTo		VarChar(20) = NULL,
	@AcntCode		VarChar(20) = '0',
	@SelectedGoods	Int = NULL,
	@VisitorCode1	Int = NULL,
	@VisitorCode2	Int = NULL,
	@VisitorCode3	Int = NULL,
	@VisitorCode4	Int = NULL,
	@SortFields		VarChar(100) = NULL,
	@RepOptions		VarChar(20) = '02', -- bit array
	@RepInfo		NVarChar(100) = '1@1@1'
WITH ENCRYPTION
AS 
DECLARE @StrSelect	NVarChar(4000);
DECLARE @StrWhere	NVarChar(2000);

DECLARE @LangID		Char(1);
DECLARE @SessionNo	VarChar(10);
DECLARE @ReportID	VarChar(10);

DECLARE @DocStep	Int;
Declare @DecRet		Bit; 
DECLARE @RemainOnly	bit;    -- فقط سفارشاتی که مانده دارند (سفارش با تحویل برابر نیست) بیاید؟
DECLARE @PrintType		Bit
DECLARE @PriceField		NVarChar(2000);
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
	
	-- I N I T ----------------------------------------------------------------
	IF (@RepInfo	  Is Null)	SET @RepInfo      = '1@1@1'
	IF (@RepOptions	Is Null)	SET @RepOptions = '0';
	IF (@ProcessNo	  Is Null)	SET @ProcessNo    = 1;

	IF (@VisitorCode1 Is Null)	SET @VisitorCode1 = 0
	IF (@VisitorCode2 Is Null)	SET @VisitorCode2 = 0
	IF (@VisitorCode3 Is Null)	SET @VisitorCode3 = 0
	IF (@VisitorCode4 Is Null)	SET @VisitorCode4 = 0
	
	SET	@LangID		= pub.funSplitString(@RepInfo, '@', 1);
	SET @SessionNo	= pub.funSplitString(@RepInfo, '@', 2);
	SET @ReportID	= pub.funSplitString(@RepInfo, '@', 3);

	SET @DecRet		= Substring(@RepOptions, 1, 1);
	SET @DocStep	= Substring(@RepOptions, 2, 1);
	SET @RemainOnly	= Substring(@RepOptions, 3, 1);
	SET @PrintType	= Substring(@RepOptions, 4, 1);

	If (@FiscalYearFr   Is Null)	SET @SerialNoFr	    = Null;
	If (@FiscalYearTo	Is Null)	SET @SerialNoTo		= Null;
	If (@SerialNoFr		Is Null)	SET @FiscalYearFr	= Null;
	If (@SerialNoTo		Is Null)	SET @FiscalYearTo   = Null;

	If (@SortFields		Is Null)	SET @SortFields     = 'FiscalYear, SerialNo';
	---------------------------------------------------------------------------

	-- W H E R E --------------------------------------------------------------
	SET @StrWhere = '(D.AcntCode=''' + @AcntCode + ''') AND (D.ProcessID=180) AND (D.ProcessNo=' + LTrim(Str(@ProcessNo)) + ')'

	If (@FiscalYearFr	Is Not Null)
		SET @StrWhere = @StrWhere + ' AND (D.FiscalYear > ' + LTrim(Str(@FiscalYearFr)) + ' OR (D.FiscalYear = ' + LTrim(Str(@FiscalYearFr)) + ' AND D.SerialNo >= ' + LTrim(Str(@SerialNoFr)) + ')) '
	If (@FiscalYearTo Is Not Null)
		SET @StrWhere = @StrWhere + ' AND (D.FiscalYear < ' + LTrim(Str(@FiscalYearTo)) + ' OR (D.FiscalYear = ' + LTrim(Str(@FiscalYearTo)) + ' AND D.SerialNo <= ' + LTrim(Str(@SerialNoTo)) + ')) '

	If (@DateFr Is Not Null)
		SET @StrWhere = @StrWhere + ' AND D.DocDate >= ''' + @DateFr + ''''
	If (@DateTo Is Not Null)
		SET @StrWhere = @StrWhere + ' AND D.DocDate <= ''' + @DateTo + ''''

	-- Goods
	If	(@SelectedGoods > 0)
		SET @StrWhere = @StrWhere + ' AND ' + pub.funGetFilterString(@SessionNo, @ReportID, @SelectedGoods, 'D.GoodsID')

	-- Visitor
	If	(@VisitorCode1 > 0)
		SET @StrWhere = @StrWhere + ' AND ' + pub.funGetFilterString(@SessionNo, @ReportID, @VisitorCode1, 'H.VisitorAcntCode')
	If	(@VisitorCode2 > 0)
		SET @StrWhere = @StrWhere + ' AND ' + pub.funGetFilterString(@SessionNo, @ReportID, @VisitorCode2, 'H.VisitorAcntCode')
	If	(@VisitorCode3 > 0)
		SET @StrWhere = @StrWhere + ' AND ' + pub.funGetFilterString(@SessionNo, @ReportID, @VisitorCode3, 'H.VisitorAcntCode')
	If	(@VisitorCode4 > 0)
		SET @StrWhere = @StrWhere + ' AND ' + pub.funGetFilterString(@SessionNo, @ReportID, @VisitorCode4, 'H.VisitorAcntCode')

	If (@DocStep > 0)
		Set @StrWhere = @StrWhere + ' AND (D.DocStep=' + Str(@DocStep) + ')'
	---------------------------------------------------------------------------

	-- S E L E C T ------------------------------------------------------------
	if (@DecRet = 1)
		set @StrSelect = '
						(
							SELECT	IsNull(Sum(GoodsQuantity), 0) AS SoldRet
							FROM    inv.tblStorageDocsDtl
							WHERE   ProcessID = 100 AND BaseProcessID = SD.ProcessID AND BaseProcessNo = SD.ProcessNo AND 
									BaseFiscalYear = SD.FiscalYear AND BaseSerialNo = SD.SerialNo AND 
									BaseDocRowNo = SD.DocRowNo AND SD.GoodsID = D.GoodsID
						) SoldRet'
	else
		set @StrSelect = 'cast(0 as float) SoldRet'


	if @PrintType =1
		set @PriceField='D.GoodsQuantity*D.GoodsPrice GoodsPrice,(
					SELECT	IsNull(Sum(GoodsQuantity*GoodsPrice), 0)
					FROM	sal.tblSaleOrderDtl
					WHERE	BaseProcessID = D.ProcessID AND BaseProcessNo = D.ProcessNo AND BaseFiscalYear = D.FiscalYear AND BaseSerialNo = D.SerialNo AND BaseDocRowNo = D.DocRowNo
				) AS CancelPrice
				,
				(
					-- Sold Pure Qty = sum of sold qty per order - sum of sold returns qty per sold
					SElECT IsNull(Sum((SOLD.GoodsQuantity - SOLD.SoldRet)* GoodsPrice), 0)
					FROM
					(
						SELECT	GoodsQuantity, ' + @StrSelect + '   ,SD.GoodsPrice  
						FROM	inv.tblStorageDocsDtl SD
						WHERE	SD.ProcessID = 90 AND SD.BaseProcessID = D.ProcessID AND SD.BaseProcessNo = D.ProcessNo AND 
								SD.BaseFiscalYear = D.FiscalYear AND SD.BaseSerialNo = D.SerialNo AND 
								SD.BaseDocRowNo = D.DocRowNo AND SD.GoodsID = D.GoodsID
					) AS SOLD
				) AS SoldPrice'
		else 
		set @PriceField='0 GoodsPrice, 0 CancelPrice, 0 SoldPrice'


	SET @StrSelect = '
	SELECT	T.*, [pub].[funGetGoodsName](T.GoodsID,' + LTrim(RTrim(@LangID)) + ') GoodsName,
		    IsNull([inv].[FunGetGoodsBarCode] (T.GoodsID), '''') BarCode
	FROM
	(
		SELECT	D.FiscalYear, D.SerialNo, D.DocDate, D.GoodsID, D.OrderDate, D.DeliveryDate, D.AgreeNo,	D.GoodsQuantity,
				(
					SELECT	IsNull(Sum(GoodsQuantity), 0)
					FROM	sal.tblSaleOrderDtl
					WHERE	BaseProcessID = D.ProcessID AND BaseProcessNo = D.ProcessNo AND BaseFiscalYear = D.FiscalYear AND BaseSerialNo = D.SerialNo AND BaseDocRowNo = D.DocRowNo
				) AS CancelQuantity,
				
				(
					-- Sold Pure Qty = sum of sold qty per order - sum of sold returns qty per sold
					SElECT IsNull(Sum(SOLD.GoodsQuantity - SOLD.SoldRet), 0)
					FROM
					(
						SELECT	GoodsQuantity, ' + @StrSelect + '   
						FROM	inv.tblStorageDocsDtl SD
						WHERE	SD.ProcessID = 90 AND SD.BaseProcessID = D.ProcessID AND SD.BaseProcessNo = D.ProcessNo AND 
								SD.BaseFiscalYear = D.FiscalYear AND SD.BaseSerialNo = D.SerialNo AND 
								SD.BaseDocRowNo = D.DocRowNo AND SD.GoodsID = D.GoodsID
					) AS SOLD
				) AS SoldQuantity
				,'+@PriceField+'
		FROM	sal.tblSaleOrderDtl AS D
		INNER JOIN sal.tblSaleOrderHdr H ON H.ProcessID = D.ProcessID AND H.ProcessNo = D.ProcessNo AND H.FiscalYear = D.FiscalYear AND H.SerialNo = D.SerialNo
		WHERE   ' + @StrWhere + '
	) T '

	SET @StrSelect = @StrSelect + '
	ORDER BY ' + @SortFields
	---------------------------------------------------------------------------

	---- R U N ----------------------------------------------------------------
	Print @StrSelect;
	Exec sp_executesql @StrSelect;
	---------------------------------------------------------------------------
END
GO
