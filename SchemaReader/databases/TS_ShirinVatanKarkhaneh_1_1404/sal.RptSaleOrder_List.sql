USE TS_ShirinVatanKarkhaneh_1_1404
GO
SET ANSI_NULLS, QUOTED_IDENTIFIER ON
GO
-- =========== TS-QC:UPDATED ====================
-- Author        : TakroSystem\Ahmadnejad
-- Create date   : 1386/11/15
-- Viewed By	 : Majid Mohammadi
-- Last Modified : 1393/08/24
-- Last Modifier : TakroSystem\Hamid
-- Description   : لیست برگه های سفارش فروش
-- =============================================
Create PROCEDURE [sal].[RptSaleOrder_List]
	@ProcessID		Int = 180,
		-- 180 = لیست برگه های سفارش
		-- 185 = لیست برگه های انصراف از سفارش
	@ProcessNo		Int  = 1,
	@FiscalYearFr	Int = NULL,
	@SerialNoFr		Int = NULL,
	@FiscalYearTo	Int = NULL,
	@SerialNoTo		Int = NULL,
	@DateFr			Char(10) = NULL,
	@DateTo			Char(10) = NULL,
	@DeliveryDateFr Char(10) = NULL,
	@DeliveryDateTo Char(10) = NULL,
	@SelectedGoods	Int = 0, 
	@SelectedStore	Int = 0, 
	@SelectedOrder1	Int = NULL,
	@SelectedOrder2	Int = NULL,
	@SelectedOrder3	Int = NULL,
	@SelectedOrder4	Int = NULL,
	@VisitorCode1	Int = NULL,
	@VisitorCode2	Int = NULL,
	@VisitorCode3	Int = NULL,
	@VisitorCode4	Int = NULL,
	@SortFields		NVarChar(100) = Null,  -- لیست فیلدها برای مرتب کردن
	@RepOptions		VarChar(20) = '111', -- bit array
	@RepInfo		NVarChar(100) = '1@1@1',
	@ExtraParams	NVarChar(200) = ''

WITH ENCRYPTION
AS
DECLARE @StrSelect	NVarChar(4000);
DECLARE @StrWhere	NVarChar(2000);

DECLARE @StrGoodsID		VarChar(100);
DECLARE @StrGoodsName	VarChar(100);
DECLARE @StrQuantity	VarChar(100);
DECLARE @StrGoodsUnit	VarChar(100);
DECLARE @StrOrderDuration VarChar(100);

DECLARE @LangID		Char(1);
DECLARE @SessionNo	VarChar(10);
DECLARE @ReportID	VarChar(10);
DECLARE	@UserID			Int;
DECLARE	@UserIsAdmin	bit;

DECLARE @HasSgn1	bit;
DECLARE @HasSgn2	bit;
DECLARE @HasSgn3	bit;
DECLARE @HasSgn4	bit;
DECLARE @HasSgn5	bit;
DECLARE @NotSgn1	bit;
DECLARE @NotSgn2	bit;
DECLARE @NotSgn3	bit;
DECLARE @NotSgn4	bit;
DECLARE @NotSgn5	bit;
DECLARE @VATY		bit;
DECLARE @VATN		bit;

DECLARE @Sgn1	VarChar(10);
DECLARE @Sgn2	VarChar(10);
DECLARE @Sgn3	VarChar(10);
DECLARE @Sgn4	VarChar(10);
DECLARE @Sgn5	VarChar(10);

DECLARE @DecReturn	bit;
DECLARE @DocStep	Int;
DECLARE @IsDetailed	Bit;	         -- آیا گزارش تفصیلی می باشد؟

DECLARE	@HasSerial			Bit;
DECLARE	@FromExpireDate		Varchar(10);
DECLARE	@ToExpireDate		Varchar(10);
DECLARE @Batch				NVarChar(20);

DECLARE	@BaseFiscalYearFr	Int;
DECLARE	@BaseFiscalYearTo	Int;
DECLARE	@BaseSerialNoFr		Int;
DECLARE	@BaseSerialNoTo		Int;
DECLARE @db_0000   nvarchar(50)
DECLARE @ViwOtrUsrInvoice	bit;

Begin --============== S T A R T  C O D E ===================================================

	--SET @LanguageID = pub.funGetCurrentLanguageID();

	SET NOCOUNT ON;

	--==============
	SET @db_0000 = Substring(db_name(), 1, Len(db_name()) - 4) + '0000'

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
	IF (@SortFields Is Null)	SET @SortFields = 'D.FiscalYear, D.SerialNo'
	IF (@RepInfo	Is Null)	SET @RepInfo    = '1@1@1';
	IF (@DocStep < 1)			SET @DocStep	= Null;
	IF (@ProcessNo	   Is Null) SET @ProcessNo  = 1;

	IF (@FiscalYearFr Is Null)	SET @SerialNoFr = Null;
	IF (@FiscalYearTo Is Null)	SET @SerialNoTo = Null;
	IF (@SerialNoFr	Is Null)	SET @FiscalYearFr = Null;
	IF (@SerialNoTo	Is Null)	SET @FiscalYearTo = Null;

	IF (@SelectedGoods	Is Null)	SET @SelectedGoods = 0;
	IF (@SelectedStore	Is Null)	SET @SelectedStore = 0;

	IF (@SelectedOrder1 Is Null)	SET @SelectedOrder1 = 0;
	IF (@SelectedOrder2 Is Null)	SET @SelectedOrder2 = 0;
	IF (@SelectedOrder3 Is Null)	SET @SelectedOrder3 = 0;
	IF (@SelectedOrder4 Is Null)	SET @SelectedOrder4 = 0;

	IF (@VisitorCode1 Is Null)	SET @VisitorCode1 = 0;
	IF (@VisitorCode2 Is Null)	SET @VisitorCode2 = 0;
	IF (@VisitorCode3 Is Null)	SET @VisitorCode3 = 0;
	IF (@VisitorCode4 Is Null)	SET @VisitorCode4 = 0;

	SET	@LangID		= pub.funSplitString(@RepInfo, '@', 1);
	SET @SessionNo	= pub.funSplitString(@RepInfo, '@', 2);
	SET @ReportID	= pub.funSplitString(@RepInfo, '@', 3);
	SET @UserID		= pub.funSplitString(@RepInfo, '@', 4);
	SET @UserIsAdmin= pub.funSplitString(@RepInfo, '@', 5);

	SET @IsDetailed	= Substring(@RepOptions, 1, 1);
	SET @DocStep	= Substring(@RepOptions, 2, 1);
	SET @DecReturn	= Substring(@RepOptions, 3, 1);
	SET @HasSgn1	= Substring(@RepOptions, 4, 1);
	SET @HasSgn2	= Substring(@RepOptions, 5, 1);
	SET @HasSgn3	= Substring(@RepOptions, 6, 1);
	SET @HasSgn4	= Substring(@RepOptions, 7, 1);
	SET @HasSgn5	= Substring(@RepOptions, 8, 1);
	SET @NotSgn1	= Substring(@RepOptions, 9, 1);
	SET @NotSgn2	= Substring(@RepOptions, 10, 1);
	SET @NotSgn3	= Substring(@RepOptions, 11, 1);
	SET @NotSgn4	= Substring(@RepOptions, 12, 1);
	SET @NotSgn5	= Substring(@RepOptions, 13, 1);
	SET @VATY		= Substring(@RepOptions, 14, 1)
	SET @VATN		= Substring(@RepOptions, 15, 1)
	
	SET @HasSerial		  = LTrim(pub.funSplitString(@ExtraParams, '@', 1));
	SET @FromExpireDate	  = LTrim(pub.funSplitString(@ExtraParams, '@', 2));
	SET @ToExpireDate	  = LTrim(pub.funSplitString(@ExtraParams, '@', 3));
	SET @Batch			  = LTrim(pub.funSplitString(@ExtraParams, '@', 4));	
	SET @BaseFiscalYearFr = LTrim(pub.funSplitString(@ExtraParams, '@', 5));	
	SET @BaseSerialNoFr	  = LTrim(pub.funSplitString(@ExtraParams, '@', 6));	
	SET @BaseFiscalYearTo = LTrim(pub.funSplitString(@ExtraParams, '@', 7));	
	SET @BaseSerialNoTo   = LTrim(pub.funSplitString(@ExtraParams, '@', 8));	
	SET @Sgn1			  = LTrim(pub.funSplitString(@ExtraParams, '@', 9));	
	SET @Sgn2			  = LTrim(pub.funSplitString(@ExtraParams, '@', 10));	
	SET @Sgn3			  = LTrim(pub.funSplitString(@ExtraParams, '@', 11));	
	SET @Sgn4			  = LTrim(pub.funSplitString(@ExtraParams, '@', 12));	
	SET @Sgn5			  = LTrim(pub.funSplitString(@ExtraParams, '@', 13));	
	SET @ViwOtrUsrInvoice = LTrim(pub.funSplitString(@ExtraParams, '@', 14));	
		
	---------------------------------------------------------------------------

	-- W H E R E --------------------------------------------------------------
	--SET @StrWhere = ' (D.AutoOrder = 0) and D.ProcessID  = ' + LTrim(Str(@ProcessID)) + ' AND D.ProcessNo = ' + LTrim(Str(@ProcessNo))
	SET @StrWhere = '(D.ProcessID= ' + LTrim(Str(@ProcessID)) + ') AND (D.ProcessNo=' + LTrim(Str(@ProcessNo)) + ')'

	If (@FiscalYearFr Is Not Null)
		SET @StrWhere = @StrWhere + ' AND (D.FiscalYear > ' + LTrim(Str(@FiscalYearFr)) + ' OR (D.FiscalYear = ' + LTrim(Str(@FiscalYearFr)) + ' AND D.SerialNo >= ' + LTrim(Str(@SerialNoFr)) + ')) '
	If (@FiscalYearTo Is Not Null)
		SET @StrWhere = @StrWhere + ' AND (D.FiscalYear < ' + LTrim(Str(@FiscalYearTo)) + ' OR (D.FiscalYear = ' + LTrim(Str(@FiscalYearTo)) + ' AND D.SerialNo <= ' + LTrim(Str(@SerialNoTo)) + ')) '

	If (@SelectedGoods > 0)
		SET @StrWhere = @StrWhere + ' AND ' + pub.funGetFilterString(@SessionNo, @ReportID, @SelectedGoods, 'D.GoodsID') 
	If (@SelectedStore > 0)
		SET @StrWhere = @StrWhere + ' AND ' + pub.funGetFilterString(@SessionNo, @ReportID, @SelectedStore, 'D.StoreID') 

	If (@DateFr Is Not Null)
		Set @StrWhere = @StrWhere + ' AND (D.DocDate >= ''' + @DateFr + ''')'
	If (@DateTo Is Not Null)
		Set @StrWhere = @StrWhere + ' AND (D.DocDate <= ''' + @DateTo + ''')'

	If (@DeliveryDateFr Is Not Null)
		Set @StrWhere = @StrWhere + ' AND (D.DeliveryDate >= ''' + @DeliveryDateFr + ''')'
	If (@DeliveryDateTo Is Not Null)
		Set @StrWhere = @StrWhere + ' AND (D.DeliveryDate <= ''' + @DeliveryDateTo + ''')'

	-- Acnt
	IF	(@SelectedOrder1 > 0)
		SET @StrWhere = @StrWhere + ' AND ' + pub.funGetFilterString(@SessionNo, @ReportID, @SelectedOrder1, 'D.AcntCode') 
	IF	(@SelectedOrder2 > 0)
		SET @StrWhere = @StrWhere + ' AND ' + pub.funGetFilterString(@SessionNo, @ReportID, @SelectedOrder2, 'D.AcntCode') 
	IF	(@SelectedOrder3 > 0)
		SET @StrWhere = @StrWhere + ' AND ' + pub.funGetFilterString(@SessionNo, @ReportID, @SelectedOrder3, 'D.AcntCode') 
	IF	(@SelectedOrder4 > 0)
		SET @StrWhere = @StrWhere + ' AND ' + pub.funGetFilterString(@SessionNo, @ReportID, @SelectedOrder4, 'D.AcntCode') 

	-- Visitor
	IF	(@VisitorCode1 > 0)
		SET @StrWhere = @StrWhere + ' AND ' + pub.funGetFilterString(@SessionNo, @ReportID, @VisitorCode1, 'H.VisitorAcntCode')
	IF	(@VisitorCode2 > 0)
		SET @StrWhere = @StrWhere + ' AND ' + pub.funGetFilterString(@SessionNo, @ReportID, @VisitorCode2, 'H.VisitorAcntCode')
	IF	(@VisitorCode3 > 0)
		SET @StrWhere = @StrWhere + ' AND ' + pub.funGetFilterString(@SessionNo, @ReportID, @VisitorCode3, 'H.VisitorAcntCode')
	IF	(@VisitorCode4 > 0)
		SET @StrWhere = @StrWhere + ' AND ' + pub.funGetFilterString(@SessionNo, @ReportID, @VisitorCode4, 'H.VisitorAcntCode')

	If (@DocStep > 0)
		Set @StrWhere = @StrWhere + ' AND (D.DocStep = ' + Str(@DocStep) + ')'
		
	If (@DecReturn = 1)
		Set @StrWhere = @StrWhere + ' And (LTRIM(STR(D.ProcessID)) + ''@'' + LTRIM(STR(D.ProcessNo)) + ''@'' + LTRIM(STR(D.FiscalYear)) + ''@'' + LTRIM(STR(D.SerialNo))+ ''@'' + LTRIM(STR(D.DocRowNo))) 
		Not In (Select (LTRIM(STR(BaseProcessID)) + ''@'' + LTRIM(STR(BaseProcessNo)) + ''@'' + LTRIM(STR(BaseFiscalYear)) + ''@'' + LTRIM(STR(BaseSerialNo))+ ''@'' + LTRIM(STR(BaseDocRowNo)))  From sal.tblSaleOrderDtl Where ProcessID = 185  )'
	If (@BaseFiscalYearFr Is Not Null) And (@BaseFiscalYearFr <> 0)
		SET @StrWhere = @StrWhere + ' AND (D.BaseFiscalYear > ' + LTrim(Str(@BaseFiscalYearFr)) + ' OR (D.BaseFiscalYear = ' + LTrim(Str(@BaseFiscalYearFr)) + ' AND D.BaseSerialNo >= ' + LTrim(Str(@BaseSerialNoFr)) + ')) '
	If (@BaseFiscalYearTo Is Not Null) And (@BaseFiscalYearTo <> 0)
		SET @StrWhere = @StrWhere + ' AND (D.BaseFiscalYear < ' + LTrim(Str(@BaseFiscalYearTo)) + ' OR (D.BaseFiscalYear = ' + LTrim(Str(@BaseFiscalYearTo)) + ' AND D.BaseSerialNo <= ' + LTrim(Str(@BaseSerialNoTo)) + ')) '
	
	IF @HasSgn1 = 1
		Set @StrWhere = @StrWhere + ' And H.SgnSN1<>0 '
	IF @HasSgn2 = 1
		Set @StrWhere = @StrWhere + ' And H.SgnSN2<>0 '
	IF @HasSgn3 = 1
		Set @StrWhere = @StrWhere + ' And H.SgnSN3<>0 '
	IF @HasSgn4 = 1
		Set @StrWhere = @StrWhere + ' And H.SgnSN4<>0 '
	IF @HasSgn5 = 1
		Set @StrWhere = @StrWhere + ' And H.SgnSN5<>0 '

	IF @NotSgn1 = 1
		Set @StrWhere = @StrWhere + ' And H.SgnSN1=0 '
	IF @NotSgn2 = 1								  
		Set @StrWhere = @StrWhere + ' And H.SgnSN2=0 '
	IF @NotSgn3 = 1								  
		Set @StrWhere = @StrWhere + ' And H.SgnSN3=0 '
	IF @NotSgn4 = 1								  
		Set @StrWhere = @StrWhere + ' And H.SgnSN4=0 '
	IF @NotSgn5 = 1								  
		Set @StrWhere = @StrWhere + ' And H.SgnSN5=0 '

	IF @Sgn1 <> '-1'
		Set @StrWhere = @StrWhere + ' And ' + ltrim(rtrim(@db_0000)) + '.pub.funGetUserID(H.SgnSN1)=' + @Sgn1 + ' '
	
	IF @Sgn2 <> '-1'
		Set @StrWhere = @StrWhere + ' And ' + ltrim(rtrim(@db_0000)) + '.pub.funGetUserID(H.SgnSN2)=' + @Sgn2 + ' '

	IF @Sgn3 <> '-1'
		Set @StrWhere = @StrWhere + ' And ' + ltrim(rtrim(@db_0000)) + '.pub.funGetUserID(H.SgnSN3)=' + @Sgn3 + ' '

	IF @Sgn4 <> '-1'
		Set @StrWhere = @StrWhere + ' And ' + ltrim(rtrim(@db_0000)) + '.pub.funGetUserID(H.SgnSN4)=' + @Sgn4 + ' '

	IF @Sgn5 <> '-1'
		Set @StrWhere = @StrWhere + ' And ' + ltrim(rtrim(@db_0000)) + '.pub.funGetUserID(H.SgnSN5)=' + @Sgn5 + ' '

	 IF (@VATY = 1)
		Set @StrWhere = @StrWhere + ' AND (H.TaxOverWorthCost > 0)'
		
	IF (@VATN = 1)
		Set @StrWhere = @StrWhere + ' AND (H.TaxOverWorthCost = 0)'

	if @ViwOtrUsrInvoice='False'
		Set @StrWhere = @StrWhere + ' AND (' + ltrim(rtrim(@db_0000)) + '.pub.funGetUserID(H.SessionNo) = '+str(@UserID)+' )'

	---------------------------------------------------------------------------
	---- S E L E C T ----------------------------------------------------------
	If (@IsDetailed = 1)  
		-- Detailed Report --
		Set @StrSelect = '
		SELECT	D.ProcessID, D.ProcessNo, D.FiscalYear, D.SerialNo, D.DocRowNo, D.DocDate, D.AcntCode, D.GoodsID, 
				D.GoodsQuantity, D.OrderDate,D.DocRowNo,
				inv.funGetUnitName(D.SubUnitID, ' + @LangID + ') SubUnitName,
				inv.funGetUnitName(G.UnitID, ' + @LangID + ') Unit, D.BaseFiscalYear, D.BaseSerialNo, D.ConfirmQuantity,
				[pub].GetCodeName(D.AcntCode, ' + @LangID + ') As AcntName,
				[pub].[funGetGoodsName](D.GoodsID,' + LTrim(RTrim(@LangID)) + ') GoodsName,
				IsNull([inv].[FunGetGoodsBarCode] (D.GoodsID), '''') BarCode,
				H.VisitorAcntCode, [pub].GetCodeName(H.VisitorAcntCode, ' + @LangID + ') As VisitorAcntName, H.DocDesc, 
				IsNull(L2.LocationName,'''') As LocationName, H.DocDate2, D.SubUnitQuantity, D.SubUnitPrice , isNull(GRD.ReciverName,'''') ReciverName,
				isNull(GRD.ReciverAddress,'''') ReciverAddress, isNull(GRD.StoreZipCode,'''') StoreZipCode, isNull(GRD.Tel,'''') Tel, isNull(GRD.Mobile,'''') Mobile, 
				D.BatchNo,G.ExtraField1
		FROM    sal.tblSaleOrderDtl D 
		INNER JOIN sal.tblSaleOrderHdr H ON H.ProcessID = D.ProcessID AND H.ProcessNo = D.ProcessNo AND H.FiscalYear = D.FiscalYear AND H.SerialNo = D.SerialNo
		LEFT  JOIN pub.tblLocationsDtl L2 ON L2.LocationID = H.LocationID 
		LEFT  JOIN inv.tblGoods G ON G.GoodsID=SUBSTRING(D.GoodsID,' + ltrim(rtrim(STR(@str_Goods+1))) + ',' + ltrim(rtrim(STR(@str_GoodsSum))) + ') AND G.PartNumber=' + ltrim(rtrim(STR(@UnitPart)))+ '
		LEFT JOIN  inv.tblGoodsReciverDtl GRD on GRD.ReciverID=H.GoodsReciverID
		WHERE   ' + @StrWhere + '
		--ORDER BY ' + @SortFields
	Else 
		-- Summary Report --
		Set @StrSelect = '
		SELECT	DISTINCT H.ProcessID, H.ProcessNo, H.FiscalYear, H.SerialNo, H.DocDate, H.AcntCode, 
			    [pub].GetCodeName(H.AcntCode, ' + @LangID + ') As AcntName,1 DocRowNo,
				H.VisitorAcntCode, [pub].GetCodeName(H.VisitorAcntCode, ' + @LangID + ') As VisitorAcntName, H.DocDesc, IsNull(L2.LocationName,'''') As LocationName,
				H.DocDate2 , isNull(GRD.ReciverName,'''') ReciverName,
				isNull(GRD.ReciverAddress,'''') ReciverAddress, isNull(GRD.StoreZipCode,'''') StoreZipCode, isNull(GRD.Tel,'''') Tel, isNull(GRD.Mobile,'''') Mobile, 
				'''' BatchNo,'''' ExtraField1
		FROM    sal.tblSaleOrderDtl D
		INNER JOIN sal.tblSaleOrderHdr H ON H.ProcessID = D.ProcessID AND H.ProcessNo = D.ProcessNo AND H.FiscalYear = D.FiscalYear AND H.SerialNo = D.SerialNo
		LEFT  JOIN pub.tblLocationsDtl L2 ON L2.LocationID = H.LocationID
		LEFT JOIN  inv.tblGoodsReciverDtl GRD on GRD.ReciverID=H.GoodsReciverID
		WHERE   ' + @StrWhere + '
		--ORDER BY ' + @SortFields
		
	---------------------------------------------------------------------------
	---- R U N ----------------------------------------------------------------
	
	Print @StrSelect;
	Exec sp_executesql @StrSelect;
	---------------------------------------------------------------------------
END
GO
