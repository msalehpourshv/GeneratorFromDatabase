USE TS_ShirinVatanKarkhaneh_1_1404
GO
SET ANSI_NULLS, QUOTED_IDENTIFIER ON
GO
-- =========== TS-QC:UPDATED ====================
-- Author		 : TakroSystem\Zia
-- Create date   : 1386/10/18
-- Viewed By	 : 
-- Last Modified : 1390/09/01
-- Last Modifier : TakroSystem\Zia
-- Description	 : لیست برگه های درخواست خرید
-- ==============================================
Create PROCEDURE [cmr].[RptCMR_List]
	@ProcessID			Int = 150, 
		-- 150 = لیست برگه های درخواست
		-- 155 = لیست برگه های انصراف از درخواست
	@ProcessNo			Int = 1,
	@FiscalYearFr		Int = Null,
	@SerialNoFr			Int = Null,
	@FiscalYearTo		Int = Null,
	@SerialNoTo			Int = Null,
	@DocDateFr			Char(10) = Null,
	@DocDateTo			Char(10) = Null,
	@SelectedAcnt1		Int = 0, 
	@SelectedAcnt2		Int = 0, 
	@SelectedAcnt3		Int = 0, 
	@SelectedAcnt4		Int = 0, 
	@IsDetailed			Bit = 0,	-- آیا گزارش تفصیلی می باشد؟
	@SortFields			NVarChar(100) = Null,  -- لیست فیلدها برای مرتب کردن
	@RepInfo			NVarChar(1000) = '1@1@1'
WITH ENCRYPTION
AS
Declare @StrSelect	NVarChar(4000);
Declare @StrWhere	NVarChar(2000);

Declare @StrGoodsID		VarChar(100);
Declare @StrGoodsName	VarChar(100);
Declare @StrQuantity	VarChar(100);
Declare @StrGoodsUnit	VarChar(100);
Declare @StrOrderDuration VarChar(100);
DECLARE	@LangID			Char(1);
DECLARE	@SessionNo		Int; -- برای حالت کدهای انتخابی
DECLARE	@ReportID		Int; -- برای حالت کدهای انتخابی

DECLARE @OrderDateFr	Char(10);
DECLARE @OrderDateTo	Char(10);
DECLARE @DescDtl			NvarChar(1000);

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
	
	-- I N I T ----------------------------------------------------------------
	If (@SortFields Is Null) Set @SortFields = 'FiscalYear, SerialNo'
	If (@ProcessNo  Is Null) Set @ProcessNo  = 1;
	IF (@RepInfo	Is Null) SET @RepInfo	= '1@1@1';

	IF (@SelectedAcnt1 Is Null)		SET @SelectedAcnt1 = 0;
	IF (@SelectedAcnt2 Is Null)		SET @SelectedAcnt2 = 0;
	IF (@SelectedAcnt3 Is Null)		SET @SelectedAcnt3 = 0;
	IF (@SelectedAcnt4 Is Null)		SET @SelectedAcnt4 = 0;

	IF (@FiscalYearFr Is Null)		SET @SerialNoFr = Null;
	IF (@FiscalYearTo Is Null)		SET @SerialNoTo = Null;
	IF (@SerialNoFr	Is Null)		SET @FiscalYearFr = Null;
	IF (@SerialNoTo	Is Null)		SET @FiscalYearTo = Null;

	SET @LangID			= pub.funSplitString(@RepInfo, '@', 1);
	SET @SessionNo		= pub.funSplitString(@RepInfo, '@', 2);
	SET @ReportID		= pub.funSplitString(@RepInfo, '@', 3);
	SET @OrderDateFr	= pub.funSplitString(@RepInfo, '@', 6);
	SET @OrderDateTo	= pub.funSplitString(@RepInfo, '@', 7);
	SET @DescDtl		= pub.funSplitString(@RepInfo, '@', 8);
	---------------------------------------------------------------------------

	-- W H E R E --------------------------------------------------------------
	Set @StrWhere = ' D.ProcessID  = ' + LTrim(Str(@ProcessID)) + ' AND D.ProcessNo = ' + LTrim(Str(@ProcessNo))

	If (@SerialNoFr Is Not Null)
		Set @StrWhere = @StrWhere + ' AND (D.FiscalYear > ' + LTrim(Str(@FiscalYearFr)) + ' OR 
		(D.FiscalYear = ' + LTrim(Str(@FiscalYearFr)) + ' AND D.SerialNo >= ' + LTrim(Str(@SerialNoFr)) + '))' 
	If (@SerialNoTo Is Not Null)
		Set @StrWhere = @StrWhere + ' AND (D.FiscalYear < ' + LTrim(Str(@FiscalYearTo)) + ' OR 
		(D.FiscalYear = ' + LTrim(Str(@FiscalYearTo)) + ' AND D.SerialNo <= ' + LTrim(Str(@SerialNoTo)) + '))' 

	IF (@DocDateFr Is Not Null) OR (@DocDateTo Is Not Null)
		IF (@DocDateFr = @DocDateTo)
			SET @StrWhere = @StrWhere + ' AND (D.DocDate  = ''' + @DocDateFr + ''')'
		Else
		Begin
			IF (@DocDateFr Is Not Null) 
				SET @StrWhere = @StrWhere + ' AND (D.DocDate >= ''' + @DocDateFr + ''')'
			IF @DocDateTo Is Not Null
				SET @StrWhere = @StrWhere + ' AND (D.DocDate <= ''' + @DocDateTo + ''')'
		End

	If (@SelectedAcnt1 > 0)
		SET @StrWhere = @StrWhere + ' AND ' + pub.funGetFilterString(@SessionNo, @ReportID, @SelectedAcnt1, 'D.AcntCode')
	If (@SelectedAcnt2 > 0)
		SET @StrWhere = @StrWhere + ' AND ' + pub.funGetFilterString(@SessionNo, @ReportID, @SelectedAcnt2, 'D.AcntCode')
	If (@SelectedAcnt3 > 0)
		SET @StrWhere = @StrWhere + ' AND ' + pub.funGetFilterString(@SessionNo, @ReportID, @SelectedAcnt3, 'D.AcntCode')
	If (@SelectedAcnt4 > 0)
		SET @StrWhere = @StrWhere + ' AND ' + pub.funGetFilterString(@SessionNo, @ReportID, @SelectedAcnt4, 'D.AcntCode')
		
	If (@OrderDateFr Is Not Null) And (@OrderDateFr <> '')
		SET @StrWhere = @StrWhere + ' AND (D.OrderDate <> '''' And D.OrderDate >= ''' + @OrderDateFr + ''')'
	If (@OrderDateTo Is Not Null) And (@OrderDateTo <> '')
		SET @StrWhere = @StrWhere + ' AND (D.OrderDate <> '''' And D.OrderDate <= ''' + @OrderDateTo + ''')'
	
	IF 	(@DescDtl Is Not Null) And (@DescDtl <> '')	
		SET @StrWhere = @StrWhere + ' AND (D.DescDtl  LIKE N''%' + @DescDtl + '%'' OR H.DocDesc  LIKE N''%' + @DescDtl + '%'' )'
		
	---------------------------------------------------------------------------
	---- S E L E C T ----------------------------------------------------------
	If (@IsDetailed = 1)  
		-- Detailed Report --
		Set @StrSelect = '
		SELECT	D.FiscalYear, D.SerialNo, D.DocDate, D.AcntCode, D.GoodsID, 
				pub.funGetGoodsName(D.GoodsID,' + LTrim(RTrim(@LangID)) + ') GoodsName,
				IsNull([inv].[FunGetGoodsBarCode] (D.GoodsID), '''') BarCode,
				D.BaseFiscalYear, D.BaseSerialNo, D.GoodsQuantity, D.ConfirmQuantity, D.OrderDate,
				inv.funGetUnitName(D.SubUnitID, ' + @LangID + ') Unit, 
				pub.GetCodeName(D.AcntCode, ' + @LangID + ') AcntName,D.DescDtl,H.DocDesc,isnull(tDD.DepartmentName,'''') DepartmentName
		FROM    cmr.tblCMRDtl D
		INNER JOIN  cmr.tblCMRHdr H ON H.ProcessID=D.ProcessID AND H.ProcessNo=D.ProcessNo AND H.FiscalYear=D.FiscalYear AND H.SerialNo=D.SerialNo 
		LEFT JOIN inv.tblGoodsDtl G ON G.GoodsID = SUBSTRING(D.GoodsID,' + ltrim(rtrim(STR(@str_Goods+1))) + ',' + ltrim(rtrim(STR(@str_GoodsSum))) + ') AND G.PartNumber=' + ltrim(rtrim(STR(@UnitPart)))+ ' AND G.LanguageID = ' + @LangID + '
		LEFT  JOIN prs.tblDepartmentsDtl tDD ON H.SenderDepartmentID = tDD.DepartmentID AND tDD.LanguageID = ' + @LangID + '
		WHERE   ' + @StrWhere + '
		ORDER BY ' + @SortFields
	Else 
		-- Summary Report --
		Set @StrSelect = '
		SELECT	FiscalYear, SerialNo, DocDate, AcntCode, 
				[pub].GetCodeName(D.AcntCode, ' + @LangID + ') As AcntName
		FROM    cmr.tblCMRHdr D
		WHERE   ' + @StrWhere + '
		ORDER BY ' + @SortFields
	---------------------------------------------------------------------------

	---- R U N ----------------------------------------------------------------
	Print @StrSelect;
	Exec sp_executesql @StrSelect;
	---------------------------------------------------------------------------
END
GO
