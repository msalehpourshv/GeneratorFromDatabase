USE TS_ShirinVatanKarkhaneh_1_1404
GO
SET ANSI_NULLS, QUOTED_IDENTIFIER ON
GO
-- =========== TS-QC:UPDATED ====================
-- Author		 : TakroSystem\Ahmadnejad
-- Create Date   : 1387/10/30
-- Viewed By	 : 
-- Last Modified : 1387/10/31
-- Last Modifier : TakroSystem\Ahmadnejad
-- Description	 : گزارش لیست برگه های خرید اموال
-- ==============================================
CREATE PROCEDURE [ast].[RptAst_Purchase]
	@ProcessIDList		VarChar(200) = Null,
	@ProcessNo			TinyInt = Null,
	@FiscalFr			SmallInt = Null,
	@FiscalTo			SmallInt = Null,
	@SerialFr			Int = Null,
	@SerialTo			Int = Null,
	@VchNoFr			Int = Null,
	@VchNoTo			Int = Null,
	@DateFr				VarChar(10) = Null,
	@DateTo				VarChar(10) = Null,
	@GoodsIDFr			VarChar(20) = Null,
	@GoodsIDTo			VarChar(20) = Null,  
	@GoodsIDMask		VarChar(20) = Null,  
	@GoodsNameMask		NVarChar(50) = Null,  
	@SelectedGoods		Bit = 0,	-- کد بصورت انتخابی است؟
	@AcntCodeFr			VarChar(20) = NULL,
	@AcntCodeTo			VarChar(20) = NULL,
	@AcntCodeMask		VarChar(20) = NULL,
	@AcntNameMask		NVarChar(50) = NULL,
	@SelectedAcnt		Bit = 0,	-- کد بصورت انتخابی است؟
	@LocateIDFr			VarChar(20) = Null, -- محل استقرار
	@LocateIDTo			VarChar(20) = Null, -- Not Used Now
	@AstGroupIDFr		VarChar(20) = Null,
	@AstGroupIDTo		VarChar(20) = Null,
	@BaseFiscal			SmallInt = Null,
	@BaseSerial			Int = Null,
	@AssetManagerID		VarChar(20) = Null,
	@ResponsibleID		VarChar(20) = Null,
	@ObverseAcntCode	VarChar(20) = Null,
	@AssetStatus		TinyInt = Null -- وضعیت جاری
WITH ENCRYPTION
AS 
DECLARE @LangID		VarChar(3);
DECLARE @StrSelect	NVarChar(4000);
DECLARE @StrWhere	NVarChar(4000);

DECLARE @PlaqueWithTax	Bit;

BEGIN 
	--============== S T A R T  C O D E =======================================

	SET NOCOUNT ON;
	
	---- INIT -----------------------------------------------------------------
	SET @LangID = LTRim(Str(pub.funGetCurrentLanguageID()));

	IF @FiscalFr Is Null SET @SerialFr = Null
	IF @FiscalTo Is Null SET @SerialTo = Null
	IF @SerialFr Is Null SET @FiscalFr = Null
	IF @SerialTo Is Null SET @FiscalTo = Null
	IF @BaseSerial Is Null SET @BaseFiscal = Null
	IF @BaseFiscal Is Null SET @BaseSerial = Null
	
	SET @PlaqueWithTax = LTrim(pub.funSplitString(@ProcessIDList, '@', 2)); 

	---------------------------------------------------------------------------

	---- WHERE ----------------------------------------------------------------
	SET @StrWhere = '(1 = 1)'

	IF (@ProcessIDList Is Not Null)
		SET @StrWhere = @StrWhere + ' AND (D.ProcessID IN (' + LTrim(pub.funSplitString(@ProcessIDList, '@', 1)) + '))'

	IF (@SerialFr Is Not Null)
		SET @StrWhere = @StrWhere + ' AND (D.FiscalYear = ' + LTrim(Str(@FiscalFr)) + ') AND (D.SerialNo >= ' + LTrim(Str(@SerialFr)) + ')'
	
	IF (@SerialTo Is Not Null)
		SET @StrWhere = @StrWhere + ' AND (D.FiscalYear = ' + LTrim(Str(@FiscalTo)) + ') AND (D.SerialNo <= ' + LTrim(Str(@SerialTo)) + ')'

	IF (@VchNoFr Is Not Null)
		SET @StrWhere = @StrWhere + ' AND (H.VchNo >= ' + LTrim(Str(@FiscalTo)) + ')'

	IF (@VchNoTo Is Not Null)
		SET @StrWhere = @StrWhere + ' AND (H.VchNo <= ' + LTrim(Str(@FiscalTo)) + ')'

	IF (@DateFr Is Not Null) AND (@DateTo Is Not Null) AND (@DateFr = @DateTo)
		SET @StrWhere = @StrWhere + ' AND (D.DocDate = ''' + @DateFr + ''')'
	Else
	BEGIN
		IF (@DateFr Is Not Null)
			SET @StrWhere = @StrWhere + ' AND (D.DocDate >= ''' + @DateFr + ''')'

		IF (@DateTo Is Not Null)
			SET @StrWhere = @StrWhere + ' AND (D.DocDate <= ''' + @DateTo + ''')'
	END

	IF (@GoodsIDFr Is Not Null) AND (@GoodsIDTo Is Not Null) AND (@GoodsIDFr = @GoodsIDTo)
		SET @StrWhere = @StrWhere + ' AND (D.GoodsID = ''' + @GoodsIDFr + ''')'
	Else 
	BEGIN
		IF (@GoodsIDFr Is Not Null)
			SET @StrWhere = @StrWhere + ' AND (D.GoodsID >= ''' + @GoodsIDFr + ''')'
		IF (@GoodsIDTo Is Not Null)
			SET @StrWhere = @StrWhere + ' AND (D.GoodsID <= ''' + @GoodsIDTo + ''')'
	END

	IF (@GoodsIDMask Is Not Null)
		SET @StrWhere = @StrWhere + ' AND (D.GoodsID LIKE ''' + RTrim(Replace(@GoodsIDMask, ' ', '_')) + '%'')'

	IF (@GoodsNameMask Is Not Null)
		SET @StrWhere = @StrWhere + ' AND Replace(D.AssetTitle, '' '', '''') LIKE N''%' + RTrim(Replace(@GoodsNameMask, ' ', '')) + '%'''

	-- @SelectedGoods ???

	IF (@AcntCodeFr Is Not Null) AND (@AcntCodeTo Is Not Null) AND (@AcntCodeFr = @AcntCodeTo)
		SET @StrWhere = @StrWhere + ' AND (D.AssetAcntCode = ''' + @AcntCodeFr + ''')'
	Else
	BEGIN
		IF (@AcntCodeFr Is Not Null)
			SET @StrWhere = @StrWhere + ' AND (D.AssetAcntCode >= ''' + @AcntCodeFr + ''')'

		IF (@AcntCodeTo Is Not Null)
			SET @StrWhere = @StrWhere + ' AND (D.AssetAcntCode <= ''' + @AcntCodeTo + ''')'
	END

	IF (@AcntCodeMask Is Not Null)
		SET @StrWhere = @StrWhere + ' AND (D.AssetAcntCode LIKE ''' + RTrim(Replace(@AcntCodeMask, ' ', '_')) + '%'')'

	IF (@AcntNameMask Is Not Null)
		SET @StrWhere = @StrWhere + ' AND Replace(pub.GetCodeName(D.AssetAcntCode, 1), '' '', '''') LIKE N''%' + RTrim(Replace(@AcntNameMask, ' ', '')) + '%'''

	-- @SelectedAcnt ???
	If (@AssetManagerID Is Not Null)
		SET @StrWhere = @StrWhere + ' AND (D.AssetManagerID = ''' + @AssetManagerID + ''')'

	If (@ResponsibleID Is Not Null)
		SET @StrWhere = @StrWhere + ' AND (D.ResponsibleID = ''' + @ResponsibleID + ''')'

	IF (@ObverseAcntCode Is Not Null)
		SET @StrWhere = @StrWhere + ' AND (H.ObverseAcntCode = ''' + @ObverseAcntCode + ''')'

	IF (@LocateIDFr Is Not Null) AND (@LocateIDTo Is Not Null) AND (@LocateIDFr = @LocateIDTo)
		SET @StrWhere = @StrWhere + ' AND (D.LocateID LIKE ''' + @LocateIDFr + '%'')'
	Else
	BEGIN
		IF (@LocateIDFr Is Not Null)
			SET @StrWhere = @StrWhere + ' AND (D.LocateID >= ''' + @LocateIDFr + ''')'
		IF (@LocateIDTo Is Not Null)
			SET @StrWhere = @StrWhere + ' AND D.LocateID <= ''' + @LocateIDTo + ''''
	END

	IF (@AstGroupIDFr Is Not Null) AND (@AstGroupIDTo Is Not Null) AND (@AstGroupIDFr = @AstGroupIDTo)
		SET @StrWhere = @StrWhere + ' AND (D.AstGroupID = ''' + @AstGroupIDFr + ''')'
	Else
	BEGIN
		IF (@AstGroupIDFr Is Not Null)
			SET @StrWhere = @StrWhere + ' AND (D.AstGroupID >= ''' + @AstGroupIDFr + ''')'
		IF (@AstGroupIDTo Is Not Null)
			SET @StrWhere = @StrWhere + ' AND (D.AstGroupID <= ''' + @AstGroupIDTo + ''')'
	END

	IF (@BaseSerial Is Not Null)
		SET @StrWhere = @StrWhere + ' AND (D.BaseFiscalYear = ' + LTrim(Str(@BaseFiscal)) + ') AND (D.BaseSerialNo=' + LTrim(Str(@BaseSerial)) + ')'

	IF (@AssetStatus Is Not Null)
		SET @StrWhere = @StrWhere + ' AND (D.AssetState = ' + LTRim(Str(@AssetStatus)) + ')'
		
	IF (@PlaqueWithTax = 'True')		
		SET @StrWhere = @StrWhere + ' AND (H.TaxOverWorthCost > 0)'
	
	---------------------------------------------------------------------------

	---- SELECT ---------------------------------------------------------------
	SET @StrSelect = '
	SELECT	D.*, G.AstGroupName, L.LocateName, H.DescHdr, H.VchNo, H.VchDate, GD.GoodsName,
			H.GoodsQuantity, H.OtherCostAcntCode, H.OtherIncome, H.OtherIncomeAcntCode,
			pub.GetCodeName(D.AssetManagerID, ' + @LangID + ') AssetManagerName,
			pub.GetCodeName(D.ResponsibleID, ' + @LangID + ') ResponsibleName,
			H.TaxOverWorthCost, H.TollOverWorthCost,
			pub.GetCodeName(H.ObverseAcntCode, ' + @LangID + ') ObverseAcntName
	FROM	ast.tblAssetsDtl D
			INNER JOIN ast.tblAssetsHdr H ON H.ProcessID = D.ProcessID AND H.ProcessNo = D.ProcessNo AND H.FiscalYear = D.FiscalYear AND H.SerialNo = D.SerialNo 	
			LEFT JOIN ast.tblAstGroupsDtl G ON G.AstGroupID = D.AstGroupID AND G.LanguageID = ' + @LangID + '
			LEFT JOIN ast.tblLocatesDtl L ON L.LocateID = D.LocateID AND L.LanguageID = ' + @LangID	+ '
			LEFT JOIN inv.tblGoodsDtl GD ON GD.GoodsID = D.GoodsID AND GD.LanguageID = ' + @LangID + '
	WHERE ' + @StrWhere
	---------------------------------------------------------------------------

	PRINT @StrSelect;
	EXEC sp_executesql @StrSelect;
END
GO
