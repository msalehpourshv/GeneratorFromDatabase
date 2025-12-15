USE TS_ShirinVatanKarkhaneh_1_1404
GO
SET ANSI_NULLS, QUOTED_IDENTIFIER ON
GO
-- =========== TS-QC:UPDATED ====================
-- Author		 : TakroSystem\Ahmadnejad
-- Create Date   : 1387/10/03
-- Viewed By	 : 
-- Last Modified : 1391/02/31
-- Last Modifier : TakroSystem\Zia
-- Description	 : گزارش گروه اموال
-- ==============================================
CREATE PROCEDURE [ast].[RptAst_AssetGroupsList]
	@AssetPlaqueFr		VarChar(20) = Null,
	@AssetPlaqueTo		VarChar(20) = Null,
	@LocateIDFr			VarChar(20) = Null, -- محل استقرار
	@LocateIDTo			VarChar(20) = Null, -- Not Used Now
	@AstGroupIDFr		VarChar(20) = Null,
	@AstGroupIDTo		VarChar(20) = Null,
	@AstGroupIDMask		VarChar(20) = Null,
	@AstGroupNameMask	NVarChar(50) = Null,
	@GoodsIDFr			VarChar(20) = Null,  
	@GoodsIDTo			VarChar(20) = Null,  
	@GoodsIDMask		VarChar(20) = Null,  
	@GoodsNameMask		NVarChar(50) = Null,  
	@RegisteredValueFr	Float = Null, -- ارزش دفتری
	@RegisteredValueTo	Float = Null,
	@FinalValueFr		Float = Null, -- قیمت تمام شده
	@FinalValueTo		Float = Null,
	@DeprecAmountFr		Float = Null, -- استهلاک انباشته جاری
	@DeprecAmountTo		Float = Null,
	@DeprecRateFr		TinyInt = Null, -- نرخ استهلاک
	@DeprecRateTo		TinyInt = Null,
	@DeprecMethod		TinyInt = Null, -- روش محاسبه استهلاک
	@AssetStatus		TinyInt = Null -- وضعیت جاری
	WITH ENCRYPTION
AS 
DECLARE @LanguageID TinyInt;
DECLARE @StrSelect	NVarChar(4000);
DECLARE @StrWhere	NVarChar(4000);
DECLARE @StrGroup	NVarChar(4000);
Begin 
	--============== S T A R T  C O D E =======================================

	SET NOCOUNT ON;
	
	---- Init ------------------------------------------
	SET @LanguageID = pub.funGetCurrentLanguageID();
	----------------------------------------------------

	SET @StrSelect = '
	SELECT	G.AstGroupID, G.AstGroupName, 
			Count(*) GoodsQuantity, 
			Sum(D.CostAmount) CostAmount, 
			Sum(D.DepreciationAmount) DepreciationAmount, 
			Sum(D.RegisteredValue) RegisteredValue
	FROM	ast.tblAstGroupsDtl G
			LEFT JOIN ast.tblAssetsDtl D ON D.AstGroupID = G.AstGroupID
			INNER JOIN 
			(
			SELECT    b.AssetPlaque, b.DocDate, max(b.EventNo) EventNo FROM   ast.tblAssetsDtl b 
			inner join 
				(select    DISTINCT AssetPlaque, MAX(DocDate) AS DocDate From  ast.tblAssetsDtl b GROUP BY AssetPlaque) a 
                   on a.AssetPlaque=b.AssetPlaque and a.DocDate=b.DocDate

			GROUP BY   b.AssetPlaque, b.DocDate			
			) MX on MX.AssetPlaque = D.AssetPlaque  and MX.DocDate = D.DocDate and MX.EventNo = D.EventNo
			LEFT JOIN ast.tblAssetsHdr H ON H.ProcessID = D.ProcessID AND H.ProcessNo = D.ProcessNo AND H.FiscalYear = D.FiscalYear AND H.SerialNo = D.SerialNo	'

	SET @StrGroup = 'G.AstGroupID, G.AstGroupName'
	SET @StrWhere = '(G.AstGroupID <> '''') AND (D.AssetState not in (485,495)) AND (G.LanguageID = ' + LTrim(Str(@LanguageID)) + ')'
	
	If (@AssetPlaqueFr Is Not Null) AND (@AssetPlaqueTo Is Not Null) AND (@AssetPlaqueFr = @AssetPlaqueTo)
		SET @StrWhere = @StrWhere + ' AND (D.AssetPlaque = ''' + @AssetPlaqueFr + ''')'
	Else
	Begin
		If (@AssetPlaqueFr Is Not Null)
			SET @StrWhere = @StrWhere + ' AND (D.AssetPlaque >= ''' + @AssetPlaqueFr + ''')'
		If (@AssetPlaqueTo Is Not Null)
			SET @StrWhere = @StrWhere + ' AND (D.AssetPlaque <= ''' + @AssetPlaqueTo + ''')'
	End

	If (@LocateIDFr Is Not Null) AND (@LocateIDTo Is Not Null) AND (@LocateIDFr = @LocateIDTo)
		SET @StrWhere = @StrWhere + ' AND (D.LocateID = ''' + @LocateIDFr + ''')'
	Else
	Begin
		If (@LocateIDFr Is Not Null)
			SET @StrWhere = @StrWhere + ' AND (D.LocateID >= ''' + @LocateIDFr + ''')'
		If (@LocateIDTo Is Not Null)
			SET @StrWhere = @StrWhere + ' AND (D.LocateID <= ''' + @LocateIDTo + ''')'
	End

	If (@AstGroupIDFr Is Not Null) AND (@AstGroupIDTo Is Not Null) AND (@AstGroupIDFr = @AstGroupIDTo)
		SET @StrWhere = @StrWhere + ' AND (G.AstGroupID = ''' + @AstGroupIDFr + ''')'
	Else
	Begin
		If (@AstGroupIDFr Is Not Null)
			SET @StrWhere = @StrWhere + ' AND (G.AstGroupID >= ''' + @AstGroupIDFr + ''')'
		If (@AstGroupIDTo Is Not Null)
			SET @StrWhere = @StrWhere + ' AND (G.AstGroupID <= ''' + @AstGroupIDTo + ''')'
	End

	If (@AstGroupIDMask Is Not Null)
		SET @StrWhere = @StrWhere + ' AND (G.AstGroupID LIKE N''' + RTrim(Replace(@AstGroupIDMask, ' ', '_')) + '%'')'

--	If (@AstGroupNameMask Is Not Null)
--		?

	If (@GoodsIDFr Is Not Null) AND (@GoodsIDTo Is Not Null) AND (@GoodsIDFr = @GoodsIDTo)
		SET @StrWhere = @StrWhere + ' AND (D.GoodsID = ''' + @GoodsIDFr + ''')'
	Else 
	Begin
		If (@GoodsIDFr Is Not Null)
			SET @StrWhere = @StrWhere + ' AND (D.GoodsID >= ''' + @GoodsIDFr + ''')'
		If (@GoodsIDTo Is Not Null)
			SET @StrWhere = @StrWhere + ' AND (D.GoodsID <= ''' + @GoodsIDTo + ''')'
	End

	If (@GoodsIDMask Is Not Null)
		SET @StrWhere = @StrWhere + ' AND (D.GoodsID LIKE ''' + RTrim(Replace(@GoodsIDMask, ' ', '_')) + '%'')'

	If (@GoodsNameMask Is Not Null)
		SET @StrWhere = @StrWhere + ' AND Replace(D.AssetTitle, '' '', '''') LIKE N''%' + RTrim(Replace(@GoodsNameMask, ' ', '')) + '%'''

	If (@RegisteredValueFr Is Not Null) AND (@RegisteredValueTo Is Not Null) AND (@RegisteredValueFr = @RegisteredValueTo)
		SET @StrWhere = @StrWhere + ' AND (D.RegisteredValue = ' + LTRim(Str(@RegisteredValueFr)) + ')'
	Else
	Begin
		If (@RegisteredValueFr Is Not Null)
			SET @StrWhere = @StrWhere + ' AND (D.RegisteredValue >= ' + LTRim(Str(@RegisteredValueFr)) + ')'
		If (@RegisteredValueTo Is Not Null)
			SET @StrWhere = @StrWhere + ' AND (D.RegisteredValue <= ' + LTRim(Str(@RegisteredValueTo)) + ')'
	End
	
	If (@FinalValueFr Is Not Null) AND (@FinalValueTo Is Not Null) AND (@FinalValueFr = @FinalValueTo)
		SET @StrWhere = @StrWhere + ' AND (D.CostAmount = ' + LTRim(Str(@FinalValueFr)) + ')'
	Else
	Begin
		If (@FinalValueFr Is Not Null)
			SET @StrWhere = @StrWhere + ' AND (D.CostAmount >= ' + LTRim(Str(@FinalValueFr)) + ')'
		If (@FinalValueTo Is Not Null)
			SET @StrWhere = @StrWhere + ' AND (D.CostAmount <= ' + LTRim(Str(@FinalValueTo)) + ')'
	End

	If (@DeprecAmountFr Is Not Null) AND (@DeprecAmountTo Is Not Null) AND (@DeprecAmountFr = @DeprecAmountTo)
		SET @StrWhere = @StrWhere + ' AND (D.DepreciationAmount = ' + LTRim(Str(@DeprecAmountFr)) + ')'
	Else
	Begin
		If (@DeprecAmountFr Is Not Null)
			SET @StrWhere = @StrWhere + ' AND (D.DepreciationAmount >= ' + LTRim(Str(@DeprecAmountFr)) + ')'
		If (@DeprecAmountTo Is Not Null)
			SET @StrWhere = @StrWhere + ' AND (D.DepreciationAmount <= ' + LTRim(Str(@DeprecAmountTo)) + ')'
	End

	If (@DeprecRateFr Is Not Null) AND (@DeprecRateTo Is Not Null) AND (@DeprecRateFr = @DeprecRateTo)
		SET @StrWhere = @StrWhere + ' AND (D.DepreciationRate = ' + LTRim(Str(@DeprecRateFr)) + ')'
	Else
	Begin
		If (@DeprecRateFr Is Not Null)
			SET @StrWhere = @StrWhere + ' AND (D.DepreciationRate >= ' + LTRim(Str(@DeprecRateFr)) + ')'
		If (@DeprecRateTo Is Not Null)
			SET @StrWhere = @StrWhere + ' AND (D.DepreciationRate <= ' + LTRim(Str(@DeprecRateTo)) + ')'
	End

	If (@DeprecMethod Is Not Null)
		SET @StrWhere = @StrWhere + ' AND (D.DepreciationMethod = ' + LTRim(Str(@DeprecMethod)) + ')'

	If (@AssetStatus Is Not Null)
		SET @StrWhere = @StrWhere + ' AND (D.AssetState = ' + LTRim(Str(@AssetStatus)) + ')'

	SET @StrSelect = @StrSelect + '
	WHERE ' + @StrWhere + '
	GROUP BY ' + @StrGroup

	PRINT @StrSelect;
	EXEC sp_executesql @StrSelect;
End
GO
