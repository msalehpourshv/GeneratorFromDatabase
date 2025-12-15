USE TS_ShirinVatanKarkhaneh_1_1404
GO
SET ANSI_NULLS, QUOTED_IDENTIFIER ON
GO
-- =========== TS-QC:UPDATED ====================
-- Author		 : Reza Nogrehpasand
-- Create date   : 1392/03/28
-- Viewed By	 : 
-- Last Modified : 
-- Last Modifier : 
-- Description	 : گزارش وضعيت كالا در انبارها
-- =============================================
CREATE PROCEDURE [inv].[RptGoodsStaus_Doc] 
	
	
	@StoreID			VarChar(20) ,
	@GoodsID			VARCHAR(20),
	@RepInfo			NVarChar(100) = '1@1@1'

WITH ENCRYPTION
AS

DECLARE @StrSelect		NVarChar(MAX);
DECLARE @StrWhere		NVarChar(2000);


DECLARE	@LangID			Char(1);
DECLARE	@SessionNo		Int; -- برای حالت کدهای انتخابی
DECLARE	@ReportID		Int; -- برای حالت کدهای انتخابی
declare @db_0000	nvarchar(50);

BEGIN 
	-- ============================ S T A R T =====================================================

	-- Init --------------------------
	SET NOCOUNT ON;
	
	set @db_0000 = Substring(db_name(), 1, Len(db_name()) - 4) + '0000'
	
	SET @LangID		= pub.funSplitString(@RepInfo, '@', 1);
	SET @SessionNo	= pub.funSplitString(@RepInfo, '@', 2);
	SET @ReportID	= pub.funSplitString(@RepInfo, '@', 3);

--
	set @StrWhere = '1=1'	

		
	
		
	IF (@StoreID IS NOT null)
		SET @StrWhere = @StrWhere + ' AND StoreID=''' + @StoreID + '''' 
		
	IF (@GoodsID IS NOT null)
		SET @StrWhere = @StrWhere + ' AND GoodsID=''' + @GoodsID + '''' 
		
	
		
-- ================ SELECT ===========================
	
	

	SET @StrSelect = 'SELECT StoreID, RowNo, GoodsID, PlaceID, SetPoint, MaxPoint, FitPoint,RecDesc RecDesc1,inv.GetGoodsPlaceNameFromStore(StoreID,DocRowNo,1) RecDesc, DocRowNo, GoodsPlaceID ,pub.GetStoreName(StoreID,1)AS StoreName,
			pub.GetGoodsName(GoodsID,1)AS GoodsName
			FROM inv.tblGoodsStatusDtl
		    WHERE ' +  @StrWhere 
		 
		
	 
-- ================ SELECT ===========================

	-- Exeute --------------------------
	PRINT @StrSelect;
	EXEC sp_executesql @StrSelect;

	--=========================================================================================
END
GO
