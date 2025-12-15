USE TS_ShirinVatanKarkhaneh_1_1404
GO
SET ANSI_NULLS, QUOTED_IDENTIFIER ON
GO
-- =========== TS-QC:UPDATED ====================
-- Author		 : Ahmadnejad
-- Create date   : 1387/01/22
-- Viewed By	 : 
-- Last Modified : 
-- Description   : آمار باربری ها
-- ==============================================
CREATE PROCEDURE [sal].[RptSale_TransStatistics]
	@TransPorterID	VarChar(3),
	@FiscalYearFrom	SmallInt = Null,
	@FiscalYearTo	SmallInt = Null,
	@SerialNoFrom	SmallInt = Null,
	@SerialNoTo		SmallInt = Null,
	@DateFrom		Char(10) = Null,
	@DateTo			Char(10) = Null,
	@FullInvoices	Bit = 0,
	@LanguageID		TinyInt = 1
WITH ENCRYPTION
AS 
---- Declarations ---------------
DECLARE @StrSelect	NVarChar(4000);
DECLARE @StrWhere	NVarChar(2000);
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
	
	-- Init Variables ---------------------------
	If (@LanguageID Is Null) SET @LanguageID = 1

	If (@FiscalYearFrom Is Null) SET @SerialNoFrom	= Null;
	If (@FiscalYearTo	Is Null) SET @SerialNoTo	= Null;

	If (@SerialNoFrom	Is Null) SET @FiscalYearFrom= Null;
	If (@SerialNoTo		Is Null) SET @FiscalYearTo  = Null;
	---------------------------------------------

	-- Where Clause ------------------------------------------------------------
	SET @StrWhere = '(H.ProcessID = 90) AND (H.TransporterID = ' + @TransPorterID + ')'

	If (@FiscalYearFrom	Is Not Null)
		SET @StrWhere = @StrWhere + ' AND (D.FiscalYear > ' + LTrim(Str(@FiscalYearFrom)) + ' OR 
		(D.FiscalYear = ' + LTrim(Str(@FiscalYearFrom)) + ' AND D.SerialNo >= ' + LTrim(Str(@SerialNoFrom)) + ')) '

	If (@FiscalYearTo Is Not Null)
		SET @StrWhere = @StrWhere + ' AND (D.FiscalYear < ' + LTrim(Str(@FiscalYearTo)) + ' OR 
		(D.FiscalYear = ' + LTrim(Str(@FiscalYearTo)) + ' AND D.SerialNo <= ' + LTrim(Str(@SerialNoTo)) + ')) '

	If (@DateFrom Is Not Null) OR (@DateTo Is Not Null)
		If (@DateFrom = @DateTo)
			SET @StrWhere = @StrWhere + ' AND D.DocDate  = ''' + @DateFrom + ''''
		Else 
		Begin
			If (@DateFrom Is Not Null)
				SET @StrWhere = @StrWhere + ' AND D.DocDate >= ''' + @DateFrom + ''''
			If @DateTo Is Not Null
				SET @StrWhere = @StrWhere + ' AND D.DocDate <= ''' + @DateTo + ''''
		End
	------------------------------------------------------------

	-- Select Clause -------------------------------------------
	SET @StrSelect = '
		SELECT D.GoodsID, [pub].[funGetGoodsName](D.GoodsID,' + LTrim(RTrim(@LanguageID)) + ') GoodsName,
			   IsNull([inv].[FunGetGoodsBarCode] (D.GoodsID), '''') BarCode, IsNull(Sum(GoodsQuantity), 0) SumQuantity, U.UnitName
		FROM	[inv].[tblStorageDocsDtl] D
		INNER JOIN [inv].[tblStorageDocsHdr] H ON H.ProcessID = D.ProcessID AND H.ProcessNo = D.ProcessNo AND H.FiscalYear = D.FiscalYear AND H.SerialNo = D.SerialNo
		INNER JOIN [inv].[tblGoodsDtl] G ON G.GoodsID=SUBSTRING(D.GoodsID,' + ltrim(rtrim(STR(@str_Goods+1))) + ',' + ltrim(rtrim(STR(@str_GoodsSum))) + ') AND G.PartNumber=' + ltrim(rtrim(STR(@UnitPart)))+ ' AND G.LanguageID = ' + LTrim(Str(@LanguageID)) + '
		LEFT JOIN [inv].[tblUnitsDtl] U ON U.UnitID = D.SubUnitID AND U.LanguageID = ' + LTrim(Str(@LanguageID)) + '
		WHERE	' + @StrWhere + '
		GROUP BY D.GoodsID, G.GoodsName, U.UnitName '
	--------------------------------------------------------------

	-- Run -------------------------------------------------------
	Print @StrSelect;
	Exec sp_executesql @StrSelect;
	--------------------------------------------------------------
End
GO
