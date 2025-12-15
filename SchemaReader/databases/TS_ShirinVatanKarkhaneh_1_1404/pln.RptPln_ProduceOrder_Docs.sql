USE TS_ShirinVatanKarkhaneh_1_1404
GO
SET ANSI_NULLS, QUOTED_IDENTIFIER ON
GO
-- =========== TS-QC:UPDATED ====================
-- Author		 : TakroSystem\Zia
-- Creation Date : 1389/04/13
-- Viewed By	 : 
-- Last Modified : 
-- Last Modifier : 
-- Description	 : گزارش لیست برگه های سفارش تولید
-- ==============================================
Create PROCEDURE [pln].[RptPln_ProduceOrder_Docs]
	@ProcSetFr			VarChar(20) = Null,
	@ProcSetTo			VarChar(20) = Null,
	@DocDateFr			VarChar(10) = Null,
	@DocDateTo			VarChar(10) = Null,
	@StepID				VarChar(20) = Null, -- کد مرحله
	@SelectedGoods		Int			= 0, 
	@TitleMask			NVarChar(100) = Null, -- بخشی از عنوان
	@DocDescMask		NVarChar(100) = Null, -- بخشی از شرح
	@SortFields			NVarChar(100) = Null,
	@ExtraParams		NVarChar(200) = Null,
	@RepOptions			VarChar(10)	  = '', -- bit array options
	@RepInfo			NVarChar(100) = Null

WITH ENCRYPTION
AS 
---- Declarations ---------------
DECLARE @StrSelect		NVarChar(4000);
DECLARE @StrFrom		NVarChar(1000);
DECLARE @StrWhere		NVarChar(2000);
DECLARE @StrDocDesc		NVarChar(600);

DECLARE	@ProcessID		Int;
DECLARE	@ProcessNo		Int;
DECLARE	@FiscalYearFr	Int;
DECLARE	@SerialNoFr		Int;
DECLARE	@FiscalYearTo	Int;
DECLARE	@SerialNoTo		Int;

DECLARE	@LangID			Char(1);
DECLARE	@SessionNo		Int; -- برای حالت کدهای انتخابی
DECLARE	@ReportID		Int; -- برای حالت کدهای انتخابی

declare @IsConfirmed	bit;
declare @IsNotConfirmed	bit;
declare @IsFinished		bit;
declare @ShiftTypeID		Int; 
declare	@ProductionLineID	Int;

Begin --============== S T A R T  C O D E ===================================================

	SET NOCOUNT ON;

	-- Init -------------------------------------------------
	IF (@RepOptions Is Null)		SET @RepOptions = '';
	IF (@RepInfo Is Null)			SET @RepInfo = '1@1@1';
	IF (@SelectedGoods Is Null)		SET @SelectedGoods = 0;

	SET @IsConfirmed	= Substring(@RepOptions, 1, 1);
	SET @IsNotConfirmed	= Substring(@RepOptions, 2, 1);
	SET @IsFinished		= Substring(@RepOptions, 3, 1); 
	
	SET @ShiftTypeID		= pub.funSplitString(@ExtraParams, '@', 1);
	SET @ProductionLineID	= pub.funSplitString(@ExtraParams, '@', 2);

	set @ShiftTypeID =isnull(@ShiftTypeID,0)
	set @ProductionLineID =isnull(@ProductionLineID,0)

	IF (@ProcSetFr Is Not Null)
	Begin
		SET @ProcessID		= pub.funSplitString(@ProcSetFr, '@', 1);
		SET @ProcessNo		= pub.funSplitString(@ProcSetFr, '@', 2);
		SET @FiscalYearFr	= pub.funSplitString(@ProcSetFr, '@', 3);
		SET @SerialNoFr		= pub.funSplitString(@ProcSetFr, '@', 4);
	END

	IF (@ProcSetTo Is Not Null)
	Begin
		SET @ProcessID		= pub.funSplitString(@ProcSetTo, '@', 1);
		SET @ProcessNo		= pub.funSplitString(@ProcSetTo, '@', 2);
		SET @FiscalYearTo	= pub.funSplitString(@ProcSetTo, '@', 3);
		SET @SerialNoTo		= pub.funSplitString(@ProcSetTo, '@', 4);
	END

	SET @LangID		= pub.funSplitString(@RepInfo, '@', 1);
	SET @SessionNo	= pub.funSplitString(@RepInfo, '@', 2);
	SET @ReportID	= pub.funSplitString(@RepInfo, '@', 3);

	SET @ProcessNo	= pub.funSplitString(@ExtraParams, '@', 3);

	DECLARE @UnitPart TINYINT
	SET @UnitPart  = 1

	SELECT @UnitPart = SettingValue from pub.tblSettings where SettingKey = 'UnitPart'

	IF @UnitPart IS NULL or @UnitPart = 0
		SET @UnitPart = 1

	DECLARE @str_Goods  tinyint,
			@str_GoodsSum tinyint

	select @str_Goods = IsNull(SUM (Layer1+Layer2+Layer3+Layer4+Layer5+Layer6+Layer7+Layer8+Layer9),0)
	from pub.tblCodeLayer 
	where TableName='inv.tblGoods' AND PartNumber<@UnitPart

	select @str_GoodsSum = Layer1+Layer2+Layer3+Layer4+Layer5+Layer6+Layer7+Layer8+Layer9
	from pub.tblCodeLayer 
	where TableName= 'inv.tblGoods' AND PartNumber=@UnitPart

	---------------------------------------------------------

	-- Where Clause -----------------------------------------
	Set @StrWhere = '(1=1)'

	IF (@ProcSetFr Is Not Null)
		SET @StrWhere = @StrWhere + ' AND (D.FiscalYear > ' + LTrim(Str(@FiscalYearFr)) + ' OR (D.FiscalYear = ' + LTrim(Str(@FiscalYearFr)) + ' AND D.SerialNo >= ' + LTrim(Str(@SerialNoFr)) + '))' 
	IF (@ProcSetTo Is Not Null)
		SET @StrWhere = @StrWhere + ' AND (D.FiscalYear < ' + LTrim(Str(@FiscalYearTo)) + ' OR (D.FiscalYear = ' + LTrim(Str(@FiscalYearTo)) + ' AND D.SerialNo <= ' + LTrim(Str(@SerialNoTo)) + '))' 
	If (isnull(@ProcessNo , 0) > 0)
			SET @StrWhere = @StrWhere + ' AND (D.ProcessNo = ' + LTrim(Str(@ProcessNo)) + ')' 

	IF (@DocDateFr Is Not Null) 
		SET @StrWhere = @StrWhere + ' AND (H.DocDate >= ''' + @DocDateFr + ''')'
	IF (@DocDateTo Is Not Null) 
		SET @StrWhere = @StrWhere + ' AND (H.DocDate <= ''' + @DocDateTo + ''')'

	if (@StepID is not null)
		set @StrWhere = @StrWhere + ' AND (H.ProduceStepID = ' + LTrim(Str(@StepID)) + ')'

	If (@TitleMask Is Not Null)
		Set @StrWhere = @StrWhere + ' AND (Replace(H.Title, '' '', '''') LIKE N''%' + RTrim(Replace(@TitleMask, ' ', '')) + '%'')'
	If (@DocDescMask Is Not Null)
		Set @StrWhere = @StrWhere + ' AND (Replace(H.DocDesc, '' '', '''') LIKE N''%' + RTrim(Replace(@DocDescMask, ' ', '')) + '%'')'

	IF (@SelectedGoods > 0)
		SET @StrWhere = @StrWhere + ' AND ' + pub.funGetFilterString(@SessionNo, @ReportID, @SelectedGoods, 'D.ProductID')
	IF (@ShiftTypeID > 0)
		SET @StrWhere = @StrWhere + ' AND ' + pub.funGetFilterString(@SessionNo, @ReportID, @ShiftTypeID, 'ShiftTypeID')
	IF (@ProductionLineID > 0)
		SET @StrWhere = @StrWhere + ' AND ' + pub.funGetFilterString(@SessionNo, @ReportID, @ProductionLineID, 'ProductionLineID')
		
	IF (@IsConfirmed = 1 or  @IsNotConfirmed = 1 or @IsFinished = 1 )		
	begin
		SET @StrWhere = @StrWhere + ' AND ( 1=0 '
		IF (@IsConfirmed = 1 )		
			SET @StrWhere = @StrWhere + ' or H.IsConfirmed = 1'		
		IF (@IsNotConfirmed = 1 )		
			SET @StrWhere = @StrWhere + ' or H.IsConfirmed = 0'		
		IF (@IsFinished = 1 )		
			SET @StrWhere = @StrWhere + ' or IsFinished = 1'		
		SET @StrWhere = @StrWhere + ' ) '
	end
	---------------------------------------------------------

	-- SELECT Clause ----------------------------------------
	SET @StrSelect = '
	SELECT	H.*, D.DocRowNo, D.ProductID, D.ProductCount, [pub].[funGetGoodsName](D.ProductID,' + @LangID + ') ProductName,
			U.UnitName, S.ProduceStepName,D.ProductWidth  ,D.ProductHeight ,D.ProductQuantity2, D.BatchNo,
			pub.GetUserName(H.SessionNo) AS UserName, GH.TechnicalNo,D.DescDtl,PS.ProductionLineID,pln.funGetProductionLineName(PS.ProductionLineID,1)ProductionLineName ,ShiftTypeID,emp.funGetShiftTypeName(ShiftTypeID,1) ShiftTypeName
	FROM	pln.tblProduceOrderDtl D
				inner join pln.tblProduceOrderHdr H on H.ProcessID = D.ProcessID and H.ProcessNo = D.ProcessNo and H.FiscalYear = D.FiscalYear and H.SerialNo = D.SerialNo
				left join inv.tblGoods GH on GH.GoodsID =  SUBSTRING(D.ProductID,' + ltrim(rtrim(STR(@str_Goods+1))) + ',' + ltrim(rtrim(STR( @str_GoodsSum))) + ') AND GH.PartNumber=' + ltrim(rtrim(STR(@UnitPart)))+ '
				left join inv.tblUnitsDtl U on U.UnitID = GH.UnitID and U.LanguageID = ' + @LangID + '
				left join pln.tblProduceOrderStepsDtl S on S.ProduceStepID = H.ProduceStepID and S.LanguageID = ' + @LangID + '
				left join pln.tblProduceStepHdr PS on D.ProductID=PS.ProductID and D.StepNo=PS.SerialNo  

	WHERE ' + @StrWhere
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
END
GO
