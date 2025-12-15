USE TS_ShirinVatanKarkhaneh_1_1404
GO
SET ANSI_NULLS, QUOTED_IDENTIFIER ON
GO
--exec "TS_AzarSoozan_2_1394"."prd"."RptProduce_Send_Situation";1 70, 1, 94, 499, 94, 499, NULL, NULL, N'1@62071@160059@0@1', N''
-- =========== TS-QC:UPDATED ====================
-- Author        : TakroSystem\Hamid	
-- Create date   : 1394/09/10
-- Viewed By		 : Hadi Sadeghi
-- Last Modified : 
-- Last Modifier : 
-- Description   : گزارش وضعیت ارسال مواد
-- =============================================
CREATE PROCEDURE [prd].[RptProduce_Send_Situation]
	@ProcessID		Int = 70, 
	@ProcessNo		Int = 1,
	@FiscalYearFr	Int = Null,
	@SerialNoFr		Int = Null,
	@FiscalYearTo	Int = Null,
	@SerialNoTo		Int = Null,
	@DocDateFr		Char(10) = Null,
	@DocDateTo		Char(10) = Null,
	@RepInfo		NVarChar(100) = '1@1@1',
	@ExtraParams	NVarChar(500) = ''

WITH ENCRYPTION
AS
Declare @StrSelect	NVarChar(Max);
Declare @StrSelect1	NVarChar(Max);
Declare @StrSelect2	NVarChar(Max);
Declare @StrSelect3	NVarChar(Max);
Declare @StrWhere	NVarChar(Max);

Declare @StrGoodsID		VarChar(100);
Declare @StrGoodsName	VarChar(100);
Declare @StrQuantity	VarChar(100);
Declare @StrGoodsUnit	VarChar(100);
Declare @StrOrderDuration VarChar(100);
DECLARE	@LangID			Char(1);
DECLARE	@SessionNo		Int; -- برای حالت کدهای انتخابی
DECLARE	@ReportID		Int; -- برای حالت کدهای انتخابی

DECLARE @UnitPart	TINYINT

Begin --============== S T A R T  C O D E ===================================================

--	SET @LanguageID = pub.funGetCurrentLanguageID();

	Set NoCount On;

	--================================== UnitPart
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
	--==================================
	
	-- I N I T ----------------------------------------------------------------
	If (@ProcessNo  Is Null) Set @ProcessNo  = 1;
	IF (@RepInfo	Is Null) SET @RepInfo	= '1@1@1';

	IF (@FiscalYearFr Is Null)		SET @SerialNoFr = Null;
	IF (@FiscalYearTo Is Null)		SET @SerialNoTo = Null;
	IF (@SerialNoFr	Is Null)		SET @FiscalYearFr = Null;
	IF (@SerialNoTo	Is Null)		SET @FiscalYearTo = Null;

	SET @LangID		= pub.funSplitString(@RepInfo, '@', 1);
	SET @SessionNo	= pub.funSplitString(@RepInfo, '@', 2);
	SET @ReportID	= pub.funSplitString(@RepInfo, '@', 3);
	---------------------------------------------------------------------------

	-- W H E R E --------------------------------------------------------------
	Set @StrWhere = 'SD1.ProcessID = ' + LTrim(Str(@ProcessID)) + ' AND SD1.ProcessNo = ' + LTrim(Str(@ProcessNo))

	If (@SerialNoFr Is Not Null)
		Set @StrWhere = @StrWhere + ' AND (SD1.FiscalYear > ' + LTrim(Str(@FiscalYearFr)) + ' OR 
		(SD1.FiscalYear = ' + LTrim(Str(@FiscalYearFr)) + ' AND SD1.SerialNo >= ' + LTrim(Str(@SerialNoFr)) + '))' 

	If (@SerialNoTo Is Not Null)
		Set @StrWhere = @StrWhere + ' AND (SD1.FiscalYear < ' + LTrim(Str(@FiscalYearTo)) + ' OR 
		(SD1.FiscalYear = ' + LTrim(Str(@FiscalYearTo)) + ' AND SD1.SerialNo <= ' + LTrim(Str(@SerialNoTo)) + '))' 

	IF (@DocDateFr Is Not Null) OR (@DocDateTo Is Not Null)
		IF (@DocDateFr = @DocDateTo)
			SET @StrWhere = @StrWhere + ' AND (SD1.DocDate = ''' + @DocDateFr + ''')'
		Else
		Begin
			IF (@DocDateFr Is Not Null) 
				SET @StrWhere = @StrWhere + ' AND (SD1.DocDate >= ''' + @DocDateFr + ''')'
			IF @DocDateTo Is Not Null
				SET @StrWhere = @StrWhere + ' AND (SD1.DocDate <= ''' + @DocDateTo + ''')'
		End
	---------------------------------------------------------------------------

	---- S E L E C T ----------------------------------------------------------
Set @StrSelect = '
	Select SD1.ProcessID, SD1.ProcessNo, SD1.FiscalYear, SD1.SerialNo, SH.ProductID, GD2.GoodsName As ProductName, 
		   IsNull(SH.ProductCount,0) As ProductCount, --SD1.GoodsID, GD1.GoodsName, 
		   Case When SD1.DocStep >= 1 Then ''True'' Else ''False'' End As SendPermission,
		   Case When SD1.DocStep > 1 Then ''True'' Else ''False'' End As SendNumeric,
		   IsNull(R.SubUnitQuantity,0) As ReceiveQuantity, IsNull(R.VchNo, 0) As VchNo,
		   Case When R.DocStep >= 1 Then ''True'' Else ''False'' End As ReceiveNumeric,
		   Case When R.DocStep > 1 Then ''True'' Else ''False'' End As ReceiveCurrency	   
	From inv.tblStorageDocsDtl SD1
	Inner Join (SELECT H.ProcessID,H.ProcessNo,H.FiscalYear,H.SerialNo,
				Case When  	PGD.SerialNo IS NULL THEN IsNull(H.ProductCount,0)	ELSE SubUnitQuantity END As ProductCount,
				Case When  	PGD.SerialNo IS NULL THEN IsNull(H.ProductID,0)	ELSE PGD.ProductID END As ProductID
	            FROM inv.tblStorageDocsHdr H
			LEFT JOIN prd.tblProductGroupsDtl PGD								   
			ON H.BaseSerialNo = PGD.SerialNo 
		) SH ON SH.ProcessID = SD1.ProcessID And SH.ProcessNo = SD1.ProcessNo And
			SH.FiscalYear = SD1.FiscalYear And SH.SerialNo = SD1.SerialNo
	--================ دریافت محصول
	Left Join 
	(Select SD.ProcessID, SD.ProcessNo, SD.FiscalYear, SD.SerialNo, SH.ProductID, SD.GoodsID, SD.DocRowNo, SD.DocDate, SD.AcntCode, 
			SD.SubUnitID, SD.BaseProcessID, SD.BaseProcessNo, SD.BaseFiscalYear, SD.BaseSerialNo, SD.BaseDocRowNo, SD.BaseDocDate, 
			IsNull(SD.SubUnitQuantity, 0) SubUnitQuantity, SH.DocStep, SH.VchNo
	 From inv.tblStorageDocsDtl SD
	 Inner Join inv.tblStorageDocsHdr SH ON SH.ProcessID = SD.ProcessID And SH.ProcessNo = SD.ProcessNo And SH.FiscalYear = SD.FiscalYear And 
											SH.SerialNo = SD.SerialNo
	 Where SD.ProcessID = 80) R 
	 ON R.BaseProcessID = SH.ProcessID And R.BaseProcessNo = SH.ProcessNo And
		R.BaseFiscalYear = SH.FiscalYear And R.BaseSerialNo = SH.SerialNo
	    
	INNER JOIN inv.tblGoodsDtl GD1 ON GD1.GoodsID = SUBSTRING(SD1.GoodsID,' + LTrim(RTrim(@str_Goods)) + ' + 1, ' + LTrim(RTrim(@str_GoodsSum)) + ') AND GD1.PartNumber=' + LTRIM(STR(@UnitPart)) + '
	LEFT JOIN inv.tblGoodsDtl GD2 ON GD2.GoodsID = SUBSTRING(SH.ProductID,' + LTrim(RTrim(@str_Goods)) + ' + 1, ' + LTrim(RTrim(@str_GoodsSum)) + ') AND GD2.PartNumber=' + LTRIM(STR(@UnitPart)) + '
	
	Where ' + @StrWhere + '
	Group By SD1.ProcessID, SD1.ProcessNo, SD1.FiscalYear, SD1.SerialNo, SH.ProductID, GD2.GoodsName, 
		  SH.ProductCount, R.SubUnitQuantity, SD1.DocStep, R.DocStep, R.VchNo '
	---------------------------------------------------------------------------

	---- R U N ----------------------------------------------------------------
	--Print '--================================================'
	Print @StrSelect;
	Exec sp_executesql @StrSelect;
	---------------------------------------------------------------------------
End
GO
