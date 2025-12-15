USE TS_ShirinVatanKarkhaneh_1_1404
GO
SET ANSI_NULLS, QUOTED_IDENTIFIER ON
GO
-- =========== TS-QC:UPDATED ====================
-- Author		 : TakroSystem\Ahmadnejad
-- Create Date   : 1387/10/30
-- Viewed By	 : 
-- Last Modified : 1390/10/21
-- Last Modifier : 
-- Description	 : گزارش نقل و انتقال دارائی
-- ==============================================
CREATE PROCEDURE [ast].[RptAst_Transfer]
	@AssetPlaqueFr		VarChar(20) = Null,
	@AssetPlaqueTo		VarChar(20) = Null,
	@DateFr				VarChar(10) = Null,
	@DateTo				VarChar(10) = Null,
	@AstGroupIDFr		VarChar(20) = Null,
	@AstGroupIDTo		VarChar(20) = Null,
	@LocateIDFr			VarChar(20) = Null,
	@LocateIDTo			VarChar(20) = Null,
	@AstGroupIDMask		VarChar(20) = Null,
	@AstGroupNameMask	NVarChar(50) = Null,
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
	---------------------------------------------------------------------------

	---- WHERE ----------------------------------------------------------------
	SET @StrWhere = '(D.ProcessID in (450,455,460,480,485,495,500,505))'
	
	IF (@LocateIDFr Is Not Null) AND (@LocateIDTo Is Not Null) AND (@LocateIDFr = @LocateIDTo)
		SET @StrWhere = @StrWhere + ' AND (D.LocateID like ''' + @LocateIDFr + '%'')'
	ELSE
	BEGIN
		IF (@LocateIDFr Is Not Null)
			SET @StrWhere = @StrWhere + ' AND (D.LocateID >= ''' + @LocateIDFr + ''')'
		IF (@LocateIDTo Is Not Null)
			SET @StrWhere = @StrWhere + ' AND (D.LocateID <= ''' + @LocateIDTo + ''')'
	END
	
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

	If (@AssetStatus Is Not Null)
		SET @StrWhere = @StrWhere + ' AND (D.AssetState = ' + LTRim(Str(@AssetStatus)) + ')'
	---------------------------------------------------------------------------

	---- SELECT ---------------------------------------------------------------
	SET @StrSelect = '
	SELECT	D.*, G.AstGroupName, L.LocateName, pub.funGetProcessName(D.ProcessID,D.ProcessNo, ' + @LangID + ') ProcessName,
			pub.GetCodeName(D.AssetManagerID, ' + @LangID + ') AssetManagerName, H.VchNo, 
			pub.GetCodeName(D.ResponsibleID, ' + @LangID + ') ResponsibleName
	FROM	ast.tblAssetsDtl D
				INNER JOIN ast.tblAssetsHdr H ON H.ProcessID = D.ProcessID AND H.ProcessNo = D.ProcessNo AND H.FiscalYear = D.FiscalYear AND H.SerialNo = D.SerialNo 	
				LEFT JOIN ast.tblAstGroupsDtl G ON G.AstGroupID = D.AstGroupID AND G.LanguageID = ' + @LangID + '
				LEFT JOIN ast.tblLocatesDtl L ON L.LocateID = D.LocateID AND L.LanguageID = ' + @LangID + '
	WHERE ' + @StrWhere
	---------------------------------------------------------------------------

	PRINT @StrSelect;
	EXEC sp_executesql @StrSelect;
End
GO
