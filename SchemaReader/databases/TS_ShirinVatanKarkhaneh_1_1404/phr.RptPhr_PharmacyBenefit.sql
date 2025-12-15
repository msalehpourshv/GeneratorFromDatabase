USE TS_ShirinVatanKarkhaneh_1_1404
GO
SET ANSI_NULLS, QUOTED_IDENTIFIER ON
GO
-- =========== TS-QC:UPDATED ====================
-- Author		 : TakroSystem\Reza
-- Create date   : 1393/09/02
-- Viewed By	 : 
-- Last Modified :  
-- Last Modifier : 
-- Description	 : 
-- ==============================================
create PROCEDURE [phr].[RptPhr_PharmacyBenefit]-- 93,3662

	@GoodsID		   Varchar(20) = Null,
	@DocDateFr			Char(10) = Null,
	@DocDateTo			Char(10) = Null,
	@RepInfo			NVarChar(100) = '1@1@1'

WITH ENCRYPTION
AS 
---- Declarations ---------------
Declare @StrSelect	NVarChar(4000);
Declare @StrWhere	NVarChar(4000);

DECLARE	@LangID		Char(1);
DECLARE	@SessionNo	Int; 
DECLARE	@ReportID	Int;
 

Begin -- ============== S T A R T  C O D E ====================================

	SET NOCOUNT ON;

	-- Init Variables -------------------------------------
 
	SET @LangID		= pub.funSplitString(@RepInfo, '@', 1);
	SET @SessionNo	= pub.funSplitString(@RepInfo, '@', 2);
	SET @ReportID	= pub.funSplitString(@RepInfo, '@', 3);
	
	 
	-- Where Clause -----------------------------------------
	Select @StrWhere = ' D.ProcessID = 90  AND D.ProcessNo = 1'

 
	IF (@DocDateFr Is Not Null)
		SET @StrWhere = @StrWhere + ' AND D.DocDate >= ''' + LTrim(RTrim(@DocDateFr)) + '''' 

	IF (@DocDateTo Is Not Null)
		SET @StrWhere = @StrWhere + ' AND D.DocDate <= ''' + LTrim(RTrim(@DocDateTo)) + ''''
		
	
	IF @GoodsID Is NOT NULL		
		SET @StrWhere = @StrWhere + ' AND D.GoodsID = ''' + LTrim(RTrim(@GoodsID)) + ''''
		
	-- Select Clause -------------------------------------------
	
	
		SET @StrSelect = '
		SELECT	D.GoodsID,pub.GetGoodsName(D.GoodsID,'+ @LangID +')GoodsName,
		sum(GoodsQuantity)as SaleCount,
		(Select SalePrice from inv.tblGoods G where G.GoodsID=D.GoodsID)SalePrice,
		(Select BuyPrice from inv.tblGoods G where G.GoodsID=D.GoodsID)BuyPrice
	from	inv.tblStorageDocsDtl D 
		Where '+ @StrWhere + '
		group by D.GoodsID '
				 
	------------------------------------------------------------
	-- Run -----------------------------------------------------
	Print @StrSelect;
	Exec sp_executesql @StrSelect;
	------------------------------------------------------------
End
GO
