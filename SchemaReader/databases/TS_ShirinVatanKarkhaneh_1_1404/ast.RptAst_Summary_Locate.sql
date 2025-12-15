USE TS_ShirinVatanKarkhaneh_1_1404
GO
SET ANSI_NULLS, QUOTED_IDENTIFIER ON
GO
-- =========== TS-QC:UPDATED ====================
-- Author		 : TakroSystem\Ahmadnejad
-- Create date   : 1387/10/29
-- Viewed By	 : 
-- Last Modified : 
-- Last Modifier : 
-- Description   : گزارش سرجمع دارائی
-- Dependencies  : 
--		These tree procedures must be sync:
--			1-RptAst_Summary_Group
--			2-RptAst_Summary_Locate
--			3-RptAst_Summary_Account
--		all of them must have the same parameters
-- ==============================================
CREATE PROCEDURE [ast].[RptAst_Summary_Locate]
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
	SELECT	D.LocateID, L.LocateName, 
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
			LEFT JOIN ast.tblLocatesDtl L ON L.LocateID = D.LocateID AND L.LanguageID = ' + LTrim(Str(@LanguageID)) + '
			inner join (	Select Sum(EnterKind) Sums, AssetPlaque  FROM	ast.tblAssetsDtl  group by AssetPlaque having Sum(EnterKind)=1) b on  D.AssetPlaque=b.AssetPlaque
	WHERE   ' + @StrWhere + '
	GROUP BY D.LocateID, L.LocateName '
	---------------------------------------------------------------------------

	---- S O R T --------------------------------------------------------------
	---------------------------------------------------------------------------

	---- R U N ----------------------------------------------------------------
	PRINT @StrSelect;
	EXEC sp_executesql @StrSelect;
	---------------------------------------------------------------------------
End
GO
