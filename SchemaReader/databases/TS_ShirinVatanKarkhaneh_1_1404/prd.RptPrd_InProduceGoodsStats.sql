USE TS_ShirinVatanKarkhaneh_1_1404
GO
SET ANSI_NULLS, QUOTED_IDENTIFIER ON
GO
-- =========== TS-QC:UPDATED ====================
-- Author		 : TakroSystem\Zia
-- Create date   : 1390/03/07
-- Viewed By	 : 
-- Last Modified : 
-- Last Modifier : 
-- Description	 : 
-- ==============================================
CREATE PROCEDURE [prd].[RptPrd_InProduceGoodsStats]
	@SelectedGoods		Int = 0, 
	@SelectedAcnt1		Int = Null, -- کد واحد تولید
	@SelectedAcnt2		Int = Null, -- کد واحد تولید
	@SelectedAcnt3		Int = Null, -- کد واحد تولید
	@SelectedAcnt4		Int = Null, -- کد واحد تولید
	@DocDateFr			Char(10) = Null,
	@DocDateTo			Char(10) = Null,
	@IncludeQuantity	Bit = 1, -- شامل ستون مقدار
	@IncludePrice		Bit = 1, -- شامل ستون قیمت
	@RepInfo			NVarChar(100) = '1@1@1' -- bit array options
WITH ENCRYPTION
AS 
---- Declarations ---------------
Declare @StrSelect	NVarChar(4000);
Declare @StrFrom	NVarChar(1000);
Declare @StrWhere	NVarChar(2000);
Declare @StrDate	NVarChar(2000);

DECLARE	@LangID			Char(1);
DECLARE	@SessionNo		Int; -- برای حالت کدهای انتخابی
DECLARE	@ReportID		Int; -- برای حالت کدهای انتخابی
DECLARE @DateField	nvarchar(20);

DECLARE @UnitPart	TINYINT

Begin --============== S T A R T  C O D E ===================================================

	SET NOCOUNT ON;

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
	
	-- I N I T ------------------------------------------------------------
	IF (@RepInfo		Is Null)	SET @RepInfo = '1@1@1';
	IF (@SelectedGoods	Is Null)	SET @SelectedGoods = 0;
	IF (@SelectedAcnt1	Is Null)	SET @SelectedAcnt1 = 0;
	IF (@SelectedAcnt2	Is Null)	SET @SelectedAcnt2 = 0;
	IF (@SelectedAcnt3	Is Null)	SET @SelectedAcnt3 = 0;
	IF (@SelectedAcnt4	Is Null)	SET @SelectedAcnt4 = 0;

	SET @LangID		= pub.funSplitString(@RepInfo, '@', 1);
	SET @SessionNo	= pub.funSplitString(@RepInfo, '@', 2);
	SET @ReportID	= pub.funSplitString(@RepInfo, '@', 3);

	SET @StrDate = ''
	
	if (@IncludePrice = 1)
		set @DateField = 'DocDate'	
		--set @DateField = 'VchDate2'
	else
		set @DateField = 'DocDate'	
	---------------------------------------------------------------------------

	-- W H E R E --------------------------------------------------------------
	SET @StrWhere = 'D.ProcessID = 70'

	If (@DocDateFr Is Not Null) OR (@DocDateTo Is Not Null)
		If (@DocDateFr = @DocDateTo)
			SET @StrDate = @StrDate + ' AND ' + LTrim(@DateField) + '  = ''' + @DocDateFr + ''''
		Else 
		Begin
			If (@DocDateFr Is Not Null)
				SET @StrDate = @StrDate + ' AND ' + LTrim(@DateField) + ' >= ''' + @DocDateFr + ''''
			If (@DocDateTo Is Not Null)
				SET @StrDate = @StrDate + ' AND '  + LTrim(@DateField) + ' <>'''' AND ' + LTrim(@DateField) + ' <= ''' + @DocDateTo + ''''
		End

	If (@SelectedGoods > 0)
		SET @StrWhere = @StrWhere + ' AND ' + pub.funGetFilterString(@SessionNo, @ReportID, @SelectedGoods, 'D.GoodsID') 

	If (@SelectedAcnt1 > 0)
		SET @StrWhere = @StrWhere + ' AND ' + pub.funGetFilterString(@SessionNo, @ReportID, @SelectedAcnt1, 'D.AcntCode')
	If (@SelectedAcnt2 > 0)
		SET @StrWhere = @StrWhere + ' AND ' + pub.funGetFilterString(@SessionNo, @ReportID, @SelectedAcnt2, 'D.AcntCode')
	If (@SelectedAcnt3 > 0)
		SET @StrWhere = @StrWhere + ' AND ' + pub.funGetFilterString(@SessionNo, @ReportID, @SelectedAcnt3, 'D.AcntCode')
	If (@SelectedAcnt4 > 0)
		SET @StrWhere = @StrWhere + ' AND ' + pub.funGetFilterString(@SessionNo, @ReportID, @SelectedAcnt4, 'D.AcntCode')
	---------------------------------------------------------------------------

	-- S E L E C T ------------------------------------------------------------
	SET @StrSelect = '
	SELECT	AcntCode, D.GoodsID, G.GoodsName,
			Sum(GoodsQuantity) GoodsQuantity, 
			Sum(GoodsAmount * GoodsQuantity) GoodsAmount,
			pub.GetCodeName(AcntCode, ' + @LangID + ') AS AcntName
	FROM	inv.tblStorageDocsDtl D
				INNER JOIN
				(
					SELECT	ProcessNo, FiscalYear, SerialNo
					FROM	inv.tblStorageDocsDtl
					WHERE	ProcessID = 70 AND DocStep IN (0,2) ' + @StrDate + '
					EXCEPT
					SELECT	BaseProcessNo, BaseFiscalYear, BaseSerialNo
					FROM	inv.tblStorageDocsDtl
					WHERE	ProcessID = 80 ' + @StrDate + '
				) R ON D.ProcessNo = R.ProcessNo AND D.FiscalYear = R.FiscalYear AND D.SerialNo = R.SerialNo 
	
	LEFT JOIN inv.tblGoodsDtl G ON G.GoodsID = SUBSTRING(D.GoodsID,' + LTrim(RTrim(@str_Goods)) + ' + 1, ' + LTrim(RTrim(@str_GoodsSum)) + ') AND G.PartNumber=' + LTRIM(STR(@UnitPart)) + '

	WHERE ' + @StrWhere + '
	GROUP BY AcntCode, D.GoodsID, GoodsName'
	--------------------------------------------------------------

	-- RUN -------------------------------------------------------
	PRINT @StrSelect;
	EXEC sp_executesql @StrSelect;
	--------------------------------------------------------------
End
GO
