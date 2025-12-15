USE TS_ShirinVatanKarkhaneh_1_1404
GO
SET ANSI_NULLS, QUOTED_IDENTIFIER ON
GO

CREATE PROCEDURE [ast].[RptAst_Summary_AssetManager]
	@ProcessIDList		VarChar(500) = Null,
	@ProcessNo			TinyInt = 1, -- dont use it
	@FiscalYear			SmallInt = Null,
	@AssetPlaqueFr		VarChar(20) = Null,
	@AssetPlaqueTo		VarChar(20) = Null,
	@AssetManagerID		VarChar(20) = Null,
	@ResponsibleID		VarChar(20) = Null
WITH ENCRYPTION
AS 
DECLARE @StrSelect	NVarChar(4000);
DECLARE @StrWhere	NVarChar(2000);
DECLARE @StrFrom	NVarChar(2000);
DECLARE @LanguageID	TinyInt;

BEGIN --============== S T A R T  C O D E =====================================

	SET @LanguageID = pub.funGetCurrentLanguageID();

	SET NOCOUNT ON;

	-- I N I T ----------------------------------------------------------------
	If (@ProcessNo Is Null)	SET @ProcessNo = 1;
	If (@LanguageID Is Null) SET @LanguageID = 1;
	---------------------------------------------------------------------------

	-- W H E R E --------------------------------------------------------------
	SET @StrWhere = '(1=1)'

	If (@ProcessIDList Is Not Null)
		SET @StrWhere = @StrWhere + ' AND (D.ProcessID IN (' + @ProcessIDList + '))'

	If (@FiscalYear Is Not Null)
		SET @StrWhere = @StrWhere + ' AND (D.FiscalYear = ' + LTRim(Str(@FiscalYear)) + ')'

	If (@AssetPlaqueFr Is Not Null)
		SET @StrWhere = @StrWhere + ' AND (D.AssetPlaque >= ''' + @AssetPlaqueFr + ''')'

	If (@AssetPlaqueTo Is Not Null)
		SET @StrWhere = @StrWhere + ' AND (D.AssetPlaque <= ''' + @AssetPlaqueTo + ''')'

	If (@AssetManagerID Is Not Null)
		SET @StrWhere = @StrWhere + ' AND (D.AssetManagerID = ''' + @AssetManagerID + ''')'

	If (@ResponsibleID Is Not Null)
		SET @StrWhere = @StrWhere + ' AND (D.ResponsibleID = ''' + @ResponsibleID + ''')'
	---------------------------------------------------------------------------
	
	-- S E L E C T ------------------------------------------------------------
	SET @StrSelect = '
	SELECT	D.AssetManagerID, AM.AssetManagerName, 
			SUM(D.CostAmount) CostAmount, 
			SUM(D.DepreciationAmount) DepreciationAmount, 
			SUM(D.RegisteredValue) RegisteredValue
	FROM	ast.tblAssetsDtl D
			inner join
			(
				select M.AssetPlaque, Max(M.EventNo) EventNo
				from ast.tblAssetsDtl M
				group by M.AssetPlaque
			) MX on D.AssetPlaque = MX.AssetPlaque and D.EventNo = MX.EventNo
			LEFT JOIN ast.tblAssetManagersDtl AM ON AM.AssetManagerID = D.AssetManagerID  AND AM.LanguageID = ' + LTrim(Str(@LanguageID)) + '
			inner join (	Select Sum(EnterKind) Sums, AssetPlaque  FROM	ast.tblAssetsDtl  group by AssetPlaque having Sum(EnterKind)=1) b on  D.AssetPlaque=b.AssetPlaque
	WHERE   ' + @StrWhere + '
	GROUP BY D.AssetManagerID, AM.AssetManagerName '
	---------------------------------------------------------------------------

	---- S O R T --------------------------------------------------------------
	---------------------------------------------------------------------------

	---- R U N ----------------------------------------------------------------
	PRINT @StrSelect;
	EXEC sp_executesql @StrSelect;
	---------------------------------------------------------------------------
End
GO
