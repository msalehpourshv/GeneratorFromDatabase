USE TS_ShirinVatanKarkhaneh_1_1404
GO
SET ANSI_NULLS, QUOTED_IDENTIFIER ON
GO
-- =========== TS-QC:UPDATED ====================
-- Author		 : Ahmadnejad
-- Create date   : 1387/01/22
-- Viewed By	 : 
-- Last Modified : 
-- Description	 : (لیست قیمت فروش محاسباتی (بر اساس خرید
-- ==============================================
CREATE PROCEDURE [sal].[RptSale_PriceList_Calc]
	@FiscalYearFrom		SmallInt = Null,
	@FiscalYearTo		SmallInt = Null,
	@SerialNoFrom		Int = Null,
	@SerialNoTo			Int = Null,
	@DateFrom			Char(10) = Null,
	@DateTo				Char(10) = Null,
	@AcntCodeFrom		VarChar(20) = Null,
	@AcntCodeTo			VarChar(20) = Null,
	@LanguageID			TinyInt = 1,
	@SortFields			NVarChar(100) = Null
WITH ENCRYPTION
AS 
---- Declarations ---------------
DECLARE @StrSelect	NVarChar(4000);
DECLARE @StrFrom	NVarChar(1000);
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
	
	-- Init -------------------------------------------------
	If (@LanguageID Is Null) SET @LanguageID = 1
	If (@SortFields Is Null) SET @SortFields = 'SerialNo'

	If (@FiscalYearFrom Is Null) SET @SerialNoFrom	= Null;
	If (@FiscalYearTo	Is Null) SET @SerialNoTo	= Null;

	If (@SerialNoFrom	Is Null) SET @FiscalYearFrom= Null;
	If (@SerialNoTo		Is Null) SET @FiscalYearTo  = Null;
	---------------------------------------------------------

	-- Where Clause -----------------------------------------
	SET @StrWhere = ' (ProcessID = 55) '

	If (@FiscalYearFrom Is Not Null) AND (@SerialNoFrom Is Not Null)
		SET @StrWhere = @StrWhere + ' AND (FiscalYear > ' + LTrim(Str(@FiscalYearFrom)) + ' OR 
		(FiscalYear = ' + LTrim(Str(@FiscalYearFrom)) + ' AND SerialNo >= ' + LTrim(Str(@SerialNoFrom)) + '))' 

	If (@FiscalYearTo Is Not Null) AND (@SerialNoTo Is Not Null)
		SET @StrWhere = @StrWhere + ' AND (FiscalYear < ' + LTrim(Str(@FiscalYearTo)) + ' OR 
		(FiscalYear = ' + LTrim(Str(@FiscalYearTo)) + ' AND SerialNo <= ' + LTrim(Str(@SerialNoTo)) + '))' 

	If (@DateFrom Is Not Null) OR (@DateTo Is Not Null)
		If (@DateFrom = @DateTo)
			SET @StrWhere = @StrWhere + ' AND DocDate  = ''' + @DateFrom + ''''
		Else 
		Begin
			If (@DateFrom Is Not Null)
				SET @StrWhere = @StrWhere + ' AND DocDate >= ''' + @DateFrom + ''''
			If @DateTo Is Not Null
				SET @StrWhere = @StrWhere + ' AND DocDate <= ''' + @DateTo + ''''
		End

	-- Acnt Filter 
	If (@AcntCodeFrom Is Not Null) OR (@AcntCodeTo Is Not Null)
		If (@AcntCodeFrom = @AcntCodeTo)
			Set @StrWhere = @StrWhere + ' AND AcntCode = ''' + @AcntCodeFrom + ''''
		Else
		Begin
			If (@AcntCodeFrom Is Not Null)
				SET @StrWhere = @StrWhere + ' AND AcntCode >= ''' + @AcntCodeFrom + ''''
			If (@AcntCodeTo Is Not Null)
				SET @StrWhere = @StrWhere + ' AND AcntCode <= ''' + @AcntCodeTo + ''''
		End
	---------------------------------------------------------

	-- SELECT Clause ----------------------------------------
	SET @StrSelect = '
		SELECT	FiscalYear, SerialNo, DocRowNo, DocDate, GoodsPrice, GoodsID, AcntCode,
				[pub].[funGetGoodsName](GoodsID,' + LTrim(RTrim(@LanguageID)) + ') GoodsName,
				IsNull([inv].[FunGetGoodsBarCode] (GoodsID), '''') BarCode,
				pub.GetCodeName(AcntCode, ' + LTrim(Str(@LanguageID)) + ') AS AcntName,
				IsNull((
					SELECT	Top 1 IsNull(GoodsPrice, 0)
					FROM	[inv].[tblStorageDocsDtl] I
					WHERE	(ProcessID = 90) AND (I.GoodsID = D.GoodsID) AND (I.DocDate < D.DocDate OR (I.DocDate = D.DocDate AND I.VolumeRowNo < D.VolumeRowNo))
					ORDER BY DocDate DESC, VolumeRowNo DESC
				), 0) PrePrice,
				IsNull((
					SELECT	Top 1 IsNull(GoodsPrice, 0)
					FROM	[inv].[tblStorageDocsDtl] I
					WHERE	(ProcessID = 90) AND (I.GoodsID = D.GoodsID) AND (I.DocDate > D.DocDate OR (I.DocDate = D.DocDate AND I.VolumeRowNo > D.VolumeRowNo))
					ORDER BY DocDate ASC, VolumeRowNo ASC
				), 0) PostPrice
		FROM	[inv].[tblStorageDocsDtl] D
		WHERE	' + @StrWhere + '
		ORDER BY ' + @SortFields + ', DocRowNo'
	------------------------------------------------------------

	-- RUN -----------------------------------------------------
	Print @StrSelect;
	Exec sp_executesql @StrSelect;
	------------------------------------------------------------
End
GO
