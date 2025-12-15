USE TS_ShirinVatanKarkhaneh_1_1404
GO
SET ANSI_NULLS, QUOTED_IDENTIFIER ON
GO
-- =========== TS-QC:UPDATED ====================
-- Author		 : TakroSystem\Ahmadnejad
-- Create Date   : 1387/10/30
-- Viewed By	 : 
-- Last Modified : 1387/11/03
-- Last Modifier : TakroSystem\Ahmadnejad
-- Description	 : گزارش لیست برگه های خرید اموال
-- ==============================================
CREATE PROCEDURE [ast].[RptAst_Sale]
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
	@AssetPlaqueFr		VarChar(20) = Null,
	@AssetPlaqueTo		VarChar(20) = Null,
	@LocateIDFr			VarChar(20) = Null, -- محل استقرار
	@LocateIDTo			VarChar(20) = Null, -- Not Used Now
	@AstGroupIDFr		VarChar(20) = Null,
	@AstGroupIDTo		VarChar(20) = Null,
	@AssetManagerID		VarChar(20) = Null,
	@ResponsibleID		VarChar(20) = Null,
	@ObverseAcntCode	VarChar(20) = Null,
	@OtherCostAcntCode  VarChar(20) = Null,
	@OtherIncomeAcntCode VarChar(20) = Null,
	@DescHdr			NVarChar(2000) = Null,
	@AssetStatus		TinyInt = Null -- وضعیت جاری
WITH ENCRYPTION
AS 
DECLARE @LangID		VarChar(3);
DECLARE @StrSelect	NVarChar(4000);
DECLARE @StrWhere	NVarChar(4000);
BEGIN 
	--============== S T A R T  C O D E =======================================

	SET NOCOUNT ON;
	
	---- INIT -----------------------------------------------------------------
	SET @LangID = LTRim(Str(pub.funGetCurrentLanguageID()));

	IF @FiscalFr Is Null SET @SerialFr = Null
	IF @FiscalTo Is Null SET @SerialTo = Null
	IF @SerialFr Is Null SET @FiscalFr = Null
	IF @SerialTo Is Null SET @FiscalTo = Null
	---------------------------------------------------------------------------

	---- WHERE ----------------------------------------------------------------
	SET @StrWhere = '(1 = 1)'

	IF (@ProcessIDList Is Not Null)
		SET @StrWhere = @StrWhere + ' AND (D.ProcessID IN (' + @ProcessIDList + '))'

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

	If (@AssetManagerID Is Not Null)
		SET @StrWhere = @StrWhere + ' AND (D.AssetManagerID = ''' + @AssetManagerID + ''')'

	If (@ResponsibleID Is Not Null)
		SET @StrWhere = @StrWhere + ' AND (D.ResponsibleID = ''' + @ResponsibleID + ''')'

	If (@AssetPlaqueFr Is Not Null)
		SET @StrWhere = @StrWhere + ' AND (D.AssetPlaque >= ''' + @AssetPlaqueFr + ''')'
	If (@AssetPlaqueTo Is Not Null)
		SET @StrWhere = @StrWhere + ' AND (D.AssetPlaque <= ''' + @AssetPlaqueTo + ''')'

	IF (@ObverseAcntCode Is Not Null)
		SET @StrWhere = @StrWhere + ' AND (H.ObverseAcntCode = ''' + @ObverseAcntCode + ''')'

	IF (@OtherCostAcntCode Is Not Null)
		SET @StrWhere = @StrWhere + ' AND (H.OtherCostAcntCode = ''' + @OtherCostAcntCode + ''')'

	IF (@OtherIncomeAcntCode Is Not Null)
		SET @StrWhere = @StrWhere + ' AND (H.OtherIncomeAcntCode = ''' + @OtherIncomeAcntCode + ''')'

	IF (@DescHdr Is Not Null)
		SET @StrWhere = @StrWhere + ' AND (H.DescHdr LIKE N''%' + @DescHdr + '%'')'

	IF (@AssetStatus Is Not Null)
		SET @StrWhere = @StrWhere + ' AND (D.AssetState = ' + LTRim(Str(@AssetStatus)) + ')'
	---------------------------------------------------------------------------

	---- SELECT ---------------------------------------------------------------
	SET @StrSelect = '
	SELECT	D.*, G.AstGroupName, L.LocateName, H.DescHdr, H.VchNo, H.VchDate, GD.GoodsName,
			H.GoodsQuantity, H.OtherCostAcntCode, H.OtherCost, H.OtherIncome, H.OtherIncomeAcntCode,
			pub.GetCodeName(D.AssetManagerID, ' + @LangID + ') AssetManagerName,
			pub.GetCodeName(D.ResponsibleID, ' + @LangID + ') ResponsibleName,
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
