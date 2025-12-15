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
Create  PROCEDURE [ast].[RptAst_SummaryGrouped]
	@ProcessIDList		VarChar(500) = Null,
	@ProcessNo			TinyInt = 1, -- dont use it
	@FiscalYear			SmallInt = Null,
	@AssetPlaqueFr		VarChar(20) = Null,
	@AssetPlaqueTo		VarChar(20) = Null,
	@AssetManagerID		VarChar(20) = Null,
	@ResponsibleID		VarChar(20) = Null,
	@RepInfo			NVarChar(100) = '1@1@1@1@1',
	@RepOptions			VarChar(10) = '101', 
	@ExtraParams		NVarChar(200) = Null
	WITH ENCRYPTION
AS 
DECLARE @StrSelect	NVarChar(4000);
DECLARE @StrWhere	NVarChar(2000);
DECLARE @StrFields	NVarChar(2000);
DECLARE @StrFrom	NVarChar(2000);
DECLARE @LanguageID	TinyInt;
Declare @GroupItem  char(2) 
declare @StrJoin as NVarchar(2000) 
declare @StrGroup as NVarchar(2000) 
declare @ObverseAcntCode as Varchar(20) 
declare @AssetPlaque as Varchar(20) 
declare @GoodsID as Varchar(20) 
declare @Locates as Varchar(20) 
	
BEGIN --============== S T A R T  C O D E =====================================

	SET @LanguageID = pub.funGetCurrentLanguageID();

	SET NOCOUNT ON;

	-- I N I T ----------------------------------------------------------------
	If (@ProcessNo Is Null)	SET @ProcessNo = 1;
	If (@LanguageID Is Null) SET @LanguageID = 1;
	---------------------------------------------------------------------------


	SET @GroupItem      	 = LTrim(pub.funSplitString(@ExtraParams, '@', 1)); 
	SET @ObverseAcntCode 	 = LTrim(pub.funSplitString(@ExtraParams, '@', 2)); 
	SET @AssetPlaque 		 = LTrim(pub.funSplitString(@ExtraParams, '@', 3)); 
	SET @GoodsID 			 = LTrim(pub.funSplitString(@ExtraParams, '@', 4)); 
	SET @Locates 			 = LTrim(pub.funSplitString(@ExtraParams, '@', 5)); 
	
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
		--SET @StrWhere = @StrWhere + ' AND (D.AssetManagerID Like ''' +'%'+ @AssetManagerID + ''')'
		Set @StrWhere = @StrWhere + ' And  Substring(D.AssetManagerID, 1, ' + LTrim(Str(Len(@AssetManagerID))) + ') = ''' + @AssetManagerID + ''''

	If (@ResponsibleID Is Not Null)
		SET @StrWhere = @StrWhere + ' AND (D.ResponsibleID = ''' + @ResponsibleID + ''')'
	---------------------------------------------------------------------------

	If (@ObverseAcntCode <>'')
		SET @StrWhere = @StrWhere + ' AND ( ProcessID<>500 or  D.ObverseAcntCode = ''' + @ObverseAcntCode + ''')'
	
	If (@AssetPlaque <>'')
		SET @StrWhere = @StrWhere + ' AND (D.AssetPlaque = ''' + @AssetPlaque + ''')'
	
	If (@GoodsID <>'')
		SET @StrWhere = @StrWhere + ' AND (D.GoodsID LIKE ''' + @GoodsID + '%'')'

	If (@Locates <>'')
		SET @StrWhere = @StrWhere + ' AND (D.LocateID Like ''' + @Locates + '%'')'
	
	if  @GroupItem = '1' 
		begin
	     	set   @StrFields = 'D.AstGroupID, G.AstGroupName ,'''' GoodsID, '''' GoodsName    '
	     	set @StrJoin =''
	     	set @StrGroup = 'D.AstGroupID, G.AstGroupName'
		end
	else
	if  @GroupItem = '2' 
		begin
	    	set   @StrFields = ''''' AstGroupID,'''' AstGroupName,D.GoodsID ,GD.GoodsName'
	    	set @StrJoin = ' inner join inv.tblGoodsDtl GD on GD.GoodsID =D.GoodsID and GD.LanguageID =  ' + LTrim(Str(@LanguageID))  
	    	set @StrGroup = 'D.GoodsID ,GD.GoodsName'
		end
	if  @GroupItem = '3' 
		begin
		   set   @StrFields = 'D.AstGroupID, G.AstGroupName, D.AssetPlaque  GoodsID , D.AssetTitle GoodsName'
	    	set @StrJoin = ' inner join inv.tblGoodsDtl GD on GD.GoodsID =D.GoodsID and GD.LanguageID =  ' + LTrim(Str(@LanguageID))  
	    	set @StrGroup = 'D.AssetPlaque,D.AstGroupID, G.AstGroupName,D.AssetTitle'
	    end


	-- S E L E C T ------------------------------------------------------------
	SET @StrSelect = '
		SELECT	'+@StrFields +', D.AssetManagerID,
				SUM(D.CostAmount) CostAmount, 
				SUM(D.DepreciationAmount) DepreciationAmount, 
				SUM(D.RegisteredValue) RegisteredValue,Count(D.AstGroupID)CNT
		FROM	ast.tblAssetsDtl D
				inner join
				(
					select M.AssetPlaque, Max(M.EventNo) EventNo
					from ast.tblAssetsDtl M
					group by M.AssetPlaque
				) MX on D.AssetPlaque = MX.AssetPlaque and D.EventNo = MX.EventNo
				LEFT JOIN ast.tblAstGroupsDtl G ON G.AstGroupID = D.AstGroupID AND G.LanguageID = ' + LTrim(Str(@LanguageID)) + '
				inner join (	Select Sum(EnterKind) Sums, AssetPlaque  FROM	ast.tblAssetsDtl  group by AssetPlaque having Sum(EnterKind)=1) b on  D.AssetPlaque=b.AssetPlaque
				'+ @StrJoin +'
		WHERE   ' + @StrWhere + '
		GROUP BY D.AssetManagerID,'+@StrGroup
	---------------------------------------------------------------------------

	---- S O R T --------------------------------------------------------------
	---------------------------------------------------------------------------

	---- R U N ----------------------------------------------------------------
	PRINT @StrSelect;
	EXEC sp_executesql @StrSelect;
	---------------------------------------------------------------------------
End
GO
