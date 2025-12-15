USE TS_ShirinVatanKarkhaneh_1_1404
GO
SET ANSI_NULLS, QUOTED_IDENTIFIER ON
GO
-- =========== TS-QC:UPDATED ====================
-- Author		 : TakroSystem\Ahmadnejad
-- Create Date   : 1387/10/30
-- Viewed By	 : 
-- Last Modified : 
-- Last Modifier : 
-- Description	 : گزارش تعدیلات دارائی
-- ==============================================
-- <<< Not Used >>>
-- ==============================================
CREATE PROCEDURE [ast].[RptRptAst_Renovation] 
	@AssetPlaqueFr		VarChar(20) = Null,
	@AssetPlaqueTo		VarChar(20) = Null,
	@FiscalFr			SmallInt = Null,
	@FiscalTo			SmallInt = Null,
	@SerialFr			Int = Null,
	@SerialTo			Int = Null,
	@DateFr				VarChar(10) = Null,
	@DateTo				VarChar(10) = Null,
	@AstGroupIDFr		VarChar(20) = Null,
	@AstGroupIDTo		VarChar(20) = Null,
	@AstGroupIDMask		VarChar(20) = Null,
	@AstGroupNameMask	NVarChar(50) = Null,
	@LocateIDFr			VarChar(20) = Null,
	@LocateIDTo			VarChar(20) = Null,
	@RenovationTypeID	TinyInt	= Null,
	@AssetManagerID		VarChar(20) = Null,
	@ResponsibleID		VarChar(20) = Null,
	@AssetAcntCode		VarChar(20) = Null,
	@ObverseAcntCode	VarChar(20) = Null,
	@DescHdr			NVarChar(2000) = Null,
	@AssetStatus		TinyInt = Null -- وضعیت جاری
WITH ENCRYPTION
AS 
DECLARE @LangID		VarChar(3);
DECLARE @StrSelect	NVarChar(4000);
DECLARE @StrWhere	NVarChar(4000);
Begin 
	--============== S T A R T  C O D E =======================================

	SET NOCOUNT ON;
	
	---- INIT -----------------------------------------------------------------
	SET @LangID = LTrim(Str(pub.funGetCurrentLanguageID()))
	IF @FiscalFr Is Null SET @SerialFr = Null
	IF @FiscalTo Is Null SET @SerialTo = Null
	IF @SerialFr Is Null SET @FiscalFr = Null
	IF @SerialTo Is Null SET @FiscalTo = Null
	---------------------------------------------------------------------------

	---- WHERE ----------------------------------------------------------------
	SET @StrWhere = '(1 = 1)'

	IF (@SerialFr Is Not Null)
		SET @StrWhere = @StrWhere + ' AND (D.FiscalYear = ' + LTrim(Str(@FiscalFr)) + ') AND (D.SerialNo >= ' + LTrim(Str(@SerialFr)) + ')'
	
	IF (@SerialTo Is Not Null)
		SET @StrWhere = @StrWhere + ' AND (D.FiscalYear = ' + LTrim(Str(@FiscalTo)) + ') AND (D.SerialNo <= ' + LTrim(Str(@SerialTo)) + ')'
	
	If (@AssetPlaqueFr Is Not Null) AND (@AssetPlaqueTo Is Not Null) AND (@AssetPlaqueFr = @AssetPlaqueTo)
		SET @StrWhere = @StrWhere + ' AND (D.AssetPlaque = ''' + @AssetPlaqueFr + ''')'
	Else
	Begin
		If (@AssetPlaqueFr Is Not Null)
			SET @StrWhere = @StrWhere + ' AND (D.AssetPlaque >= ''' + @AssetPlaqueFr + ''')'

		If (@AssetPlaqueTo Is Not Null)
			SET @StrWhere = @StrWhere + ' AND (D.AssetPlaque <= ''' + @AssetPlaqueTo + ''')'
	End

	If (@DateFr Is Not Null) AND (@DateTo Is Not Null) AND (@DateFr = @DateTo)
		SET @StrWhere = @StrWhere + ' AND (D.DocDate = ''' + @DateFr + ''')'
	Else
	Begin
		If (@DateFr Is Not Null)
			SET @StrWhere = @StrWhere + ' AND (D.DocDate >= ''' + @DateFr + ''')'

		If (@DateTo Is Not Null)
			SET @StrWhere = @StrWhere + ' AND (D.DocDate <= ''' + @DateTo + ''')'
	End

	If (@AstGroupIDFr Is Not Null) AND (@AstGroupIDTo Is Not Null) AND (@AstGroupIDFr = @AstGroupIDTo)
		SET @StrWhere = @StrWhere + ' AND (D.AstGroupID = ''' + @AstGroupIDFr + ''')'
	Else
	Begin
		If (@AstGroupIDFr Is Not Null)
			SET @StrWhere = @StrWhere + ' AND (D.AstGroupID >= ''' + @AstGroupIDFr + ''')'
		If (@AstGroupIDTo Is Not Null)
			SET @StrWhere = @StrWhere + ' AND (D.AstGroupID <= ''' + @AstGroupIDTo + ''')'
	End

	If (@AstGroupIDMask Is Not Null)
		SET @StrWhere = @StrWhere + ' AND (D.AstGroupID LIKE ''' + RTrim(Replace(@AstGroupIDMask, ' ', '_')) + '%'')'

--	If (@AstGroupNameMask Is Not Null)
--		?

	If (@LocateIDFr Is Not Null) AND (@LocateIDTo Is Not Null) AND (@LocateIDFr = @LocateIDTo)
		SET @StrWhere = @StrWhere + ' AND (D.LocateID = ''' + @LocateIDFr + ''')'
	Else
	Begin
		If (@LocateIDFr Is Not Null)
			SET @StrWhere = @StrWhere + ' AND (D.LocateID >= ''' + @LocateIDFr + ''')'
		If (@LocateIDTo Is Not Null)
			SET @StrWhere = @StrWhere + ' AND D.LocateID <= ''' + @LocateIDTo + ''''
	End

	If (@RenovationTypeID Is Not Null)
		SET @StrWhere = @StrWhere + ' AND (D.RenovationTypeID = ' + LTrim(Str(@RenovationTypeID)) + ')'

	If (@AssetManagerID Is Not Null)
		SET @StrWhere = @StrWhere + ' AND (D.AssetManagerID = ''' + @AssetManagerID + ''')'

	If (@ResponsibleID Is Not Null)
		SET @StrWhere = @StrWhere + ' AND (D.ResponsibleID = ''' + @ResponsibleID + ''')'

	If (@AssetAcntCode Is Not Null)
		SET @StrWhere = @StrWhere + ' AND (D.AssetAcntCode = ''' + @AssetAcntCode + ''')'

	If (@ObverseAcntCode Is Not Null)
		SET @StrWhere = @StrWhere + ' AND (D.ObverseAcntCode = ''' + @ObverseAcntCode + ''')'

	If (@DescHdr Is Not Null)
		SET @StrWhere = @StrWhere + ' AND (H.DescHdr LIKE N''%' + @DescHdr + '%'') '

	If (@AssetStatus Is Not Null)
		SET @StrWhere = @StrWhere + ' AND (D.AssetState = ' + LTRim(Str(@AssetStatus)) + ')'
	---------------------------------------------------------------------------

	---- SELECT ---------------------------------------------------------------
	SET @StrSelect = '
	SELECT	D.*, G.AstGroupName, L.LocateName, H.DescHdr,
			pub.GetCodeName(D.AssetManagerID, ' + @LangID + ') AssetManagerName,
			pub.GetCodeName(D.ResponsibleID, ' + @LangID + ') ResponsibleName
	FROM	ast.tblAssetsDtl D
			INNER JOIN ast.tblAssetsHdr H ON H.ProcessID = D.ProcessID AND H.ProcessNo = D.ProcessNo AND H.FiscalYear = D.FiscalYear AND H.SerialNo = D.SerialNo 	
			LEFT JOIN ast.tblAstGroupsDtl G ON G.AstGroupID = D.AstGroupID AND G.LanguageID = ' + @LangID + '
			LEFT JOIN ast.tblLocatesDtl L ON L.LocateID = D.LocateID AND L.LanguageID = ' + @LangID	+ '
	WHERE   ' + @StrWhere
	---------------------------------------------------------------------------

	PRINT @StrSelect;
	EXEC sp_executesql @StrSelect;
End
GO
