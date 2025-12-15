USE TS_ShirinVatanKarkhaneh_1_1404
GO
SET ANSI_NULLS, QUOTED_IDENTIFIER ON
GO
-- =========== TS-QC:UPDATED ====================
-- Author		 : TakroSystem\Ahmadnejad
-- Create date   : 1390/02/26
-- Viewed By	 : 
-- Last Modified : 
-- Last Modifier : 
-- Description	 : لیست کالاها بهمراه مجموعه هایشان
-- ==============================================
CREATE PROCEDURE [inv].[RptStore_GoodsAndGroups] 
	@SelectedGoods		Int = 0, 
	@SelectedGroups		Int = 0, 
	@SortFields			NVarChar(100) = Null,
	@RepOptions			VarChar(10) = '111011',  -- bit array options
	@RepInfo			NVarChar(100) = '1@1@1'
WITH ENCRYPTION
AS 
---- Declarations ---------------
DECLARE	@StrSelect		NVarChar(4000);
DECLARE	@StrFrom		NVarChar(4000);
DECLARE	@StrWhere		NVarChar(4000);

DECLARE	@LangID			Char(1);
DECLARE	@SessionNo		Int; 
DECLARE	@ReportID		Int; 
BEGIN --============== S T A R T  C O D E ===================================================

	SET NOCOUNT ON;

	-- Init -------------------------------------------------------------------
	IF (@RepInfo	Is Null)	SET @RepInfo = '1@1@1';
	IF (@RepOptions	Is Null)	SET @RepOptions = '';

	IF (@SelectedGoods	Is Null)	SET @SelectedGoods = 0;
	IF (@SelectedGroups	Is Null)	SET @SelectedGroups = 0;

	SET @LangID		= pub.funSplitString(@RepInfo, '@', 1);
	SET @SessionNo	= pub.funSplitString(@RepInfo, '@', 2);
	SET @ReportID	= pub.funSplitString(@RepInfo, '@', 3);
	---------------------------------------------------------------------------
	-- Where Clause -----------------------------------------------------------
	SET @StrWhere = '(1=1)'

	IF (@SelectedGoods > 0)
		SET @StrWhere = @StrWhere + ' AND ' + pub.funGetFilterString(@SessionNo, @ReportID, @SelectedGoods, 'G.GoodsID') 
	IF (@SelectedGroups > 0)
		SET @StrWhere = @StrWhere + ' AND ' + pub.funGetFilterString(@SessionNo, @ReportID, @SelectedGroups, 'G.GoodsGroupID') 
	------------------------------------------------------------
	-- Select Clause -------------------------------------------
	SET @StrSelect = '
	SELECT T.*, D.GoodsGroupName
	FROM
	(	
		SELECT	G.GoodsID, G.GoodsName, isnull(D.GoodsGroupID, '''') GoodsGroupID,
				(
					select count(*)
					from inv.tblGoodsGroupsGoodsListDtl M
					where M.GoodsID = G.GoodsID
				) GroupCount
		FROM	inv.tblGoodsDtl G
					left join inv.tblGoodsGroupsGoodsListDtl D ON D.GoodsID = G.GoodsID
		WHERE	' + @StrWhere + '
	) T left join inv.tblGoodsGroupsDtl D on D.GoodsGroupID = T.GoodsGroupID
	ORDER BY GoodsID ' 
	------------------------------------------------------------
	-- Run -----------------------------------------------------
	print @StrSelect;
	Exec sp_executesql @StrSelect;
	------------------------------------------------------------
END
GO
