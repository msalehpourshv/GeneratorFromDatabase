USE TS_ShirinVatanKarkhaneh_1_1404
GO
SET ANSI_NULLS, QUOTED_IDENTIFIER ON
GO
-- =========== TS-QC:UPDATED ====================
-- Author		 : TakroSystem\Ahmadnejad
-- Create date   : 1386
-- Viewed By	 : 
-- Last Modified : 1393/08/22
-- Last Modifier : TakroSystem\Hamid
-- Description   : <Store Stock>
-- ==============================================
CREATE PROCEDURE [inv].[RptStore_Stock_WithLayers]

	@SelectedStore			Int = 0,
	@SelectedGoods			Int = 0,
	@DocDateFr				Char(10) = Null,
	@DocDateTo				Char(10) = Null,
	@RepInfo				NVarChar(100) = '1@1@1@1@1',
	@ExtraParams			NVarChar(200) = Null
	
WITH ENCRYPTION
AS 
---- Declarations ---------------
DECLARE @StrSelect			NVarChar(max);
DECLARE @StrFrom			NVarChar(max);
DECLARE @StrWhere			NVarChar(max);
DECLARE @StrWhere2		NVarChar(max);
DECLARE @AllGoods			NVarChar(4000);
DECLARE @StrGroup			NVarChar(2000);
DECLARE @StrStore			NVarChar(2000);
DECLARE @StrHaving			NVarChar(2000);
DECLARE @StrAmount			NVarChar(4000);
DECLARE @StrYear			Char(4);
Declare @GoodsAmount		VarChar(20)
Declare @LastCalc			Char(10)

DECLARE	@LangID				Char(1);
DECLARE	@SessionNo			Int; 
DECLARE	@ReportID			Int;
DECLARE	@UserID				Int;
DECLARE	@UserIsAdmin		Bit;

DECLARE @DateField			NVarchar(20);

DECLARE @DrugSetID			VarChar(20);
DECLARE @DrugKindID			VarChar(20);
DECLARE @UseLastSalAmount	Bit;

DECLARE	@HasSerial			Bit;
DECLARE	@FromExpireDate		Varchar(10);
DECLARE	@ToExpireDate		Varchar(10);
DECLARE	@IsReservedGoods	bit;

Begin --============== S T A R T  C O D E ===================================================

	SET NOCOUNT ON;

	-- Init Variables ----------------------------------------------------------
	IF (@SelectedGoods Is Null) SET @SelectedGoods = 0;
	IF (@SelectedStore Is Null) SET @SelectedStore = 0;

	SET @LangID		= pub.funSplitString(@RepInfo, '@', 1);
	SET @SessionNo	= pub.funSplitString(@RepInfo, '@', 2);
	SET @ReportID	= pub.funSplitString(@RepInfo, '@', 3);
	SET @UserID		= pub.funSplitString(@RepInfo, '@', 4);
	SET @UserIsAdmin= pub.funSplitString(@RepInfo, '@', 5);

	SET @StrYear = LTrim(RIGHT(db_name(), 4));
	SET @GoodsAmount = LTRIM(inv.funGoodsAmount(@DocDateTo))

	--SET @DrugSetID           = LTrim(pub.funSplitString(@ExtraParams, '@', 1)); 
	--SET @DrugKindID          = LTrim(pub.funSplitString(@ExtraParams, '@', 2)); 
	
	----------------------------------------------------------------------------
	-- Where Clause ------------------------------------------------------------
	SET @StrWhere = '1 = 1';
	SET @StrWhere2 = @StrWhere;

	If (@DocDateTo Is Not Null)
		SET @StrWhere = @StrWhere + ' AND (SD.' + LTrim(@DateField) + ' <= ''' + @DocDateTo + ''')'
		
	If (@DocDateFr Is Not Null)
		SET @StrWhere2 = @StrWhere2 + ' AND SD.DocDate >= ''' + @DocDateFr + ''''

	If (@SelectedGoods > 0)
	begin
		SET @StrWhere  = @StrWhere	+ ' AND ' + pub.funGetFilterString(@SessionNo, @ReportID, @SelectedGoods, 'SUBSTRING(SD.GoodsID,1,LEN(G.GoodsID))') 
		SET @StrWhere2 = @StrWhere2 + ' AND ' + pub.funGetFilterString(@SessionNo, @ReportID, @SelectedGoods, 'SUBSTRING(SD.GoodsID,1,LEN(G.GoodsID))') 
	end
	
	If (@SelectedStore > 0)
	BEGIN
		SET @StrWhere  = @StrWhere	+ ' AND ' + pub.funGetFilterString(@SessionNo, @ReportID, @SelectedStore, 'SD.StoreID') 
		SET @StrWhere2 = @StrWhere2 + ' AND ' + pub.funGetFilterString(@SessionNo, @ReportID, @SelectedStore, 'SD.StoreID') 
	END

	----------------------------------------------------------------------------------
	-- Select Clause -----------------------------------------------------------------------------------------
	SET @StrSelect = '
	SELECT *, A.InQty - A.Qty As OutQty
	FROM (
		  Select G.GoodsID, GoodsName, SD.StoreID, SUM(GoodsQuantity * EnterKind) Qty,
			 (Select SUM(GoodsQuantity) From inv.tblStorageDocsDtl S 
			  Where G.GoodsID = SUBSTRING(S.GoodsID,1,LEN(G.GoodsID)) AND S.StoreID = SD.StoreID AND EnterKind = 1) InQty
		  FROM inv.tblGoodsDtl G
		  INNER JOIN inv.tblStorageDocsDtl SD
		  ON G.GoodsID = SUBSTRING(SD.GoodsID,1,LEN(G.GoodsID))
		  Where	' + @StrWhere + '
		  GROUP BY G.GoodsID,GoodsName,SD.StoreID
		 ) A
	WHERE InQty IS NOT NULL
	ORDER BY GoodsID'
	-------------------------------------------------------------------------------------------------------------

	------------------------------------------------------------
	Print @StrSelect;
	Exec sp_executesql @StrSelect;
	------------------------------------------------------------
End
GO
