USE TS_ShirinVatanKarkhaneh_1_1404
GO
SET ANSI_NULLS, QUOTED_IDENTIFIER ON
GO
-- =========== TS-QC:UPDATED ====================
-- Author		 : TakroSystem\Reza NP
-- Create date   : 1392/12/08
-- Viewed By	 : 
-- Last Modified : 
-- Last Modifier : 
-- Description	 : 
-- ==============================================
CREATE PROCEDURE [phr].[RptPhr_GoodsRemain]
	@GoodsID			Varchar(20) = Null,
	@StoreIDFrom		Varchar(20) = NULL,
	@StoreIDTo			Varchar(20) = NULL,
	@ToDate				Char(10) = NULL,
	@FiscalYear			Int	= 0,
	@IsCodeClosed		Bit = 0
	
WITH ENCRYPTION
AS 

Declare @StrSelect	NVarChar(4000);
Declare @StrWhere	NVarChar(4000);
Declare @StrWhere2	NVarChar(4000);

Begin -- ============== S T A R T  C O D E ====================================

	SET NOCOUNT ON;
	
	Set @StrWhere = '1 = 1'
	Set @StrWhere2 ='AND (FiscalYear = '+ ltrim(rtrim(STR(@FiscalYear))) + ' OR (FiscalYear <> ' + ltrim(rtrim(STR(@FiscalYear))) + ' AND EnterKind=1))'
	
	IF @GoodsID Is Not Null
		
		SET @StrWhere = @StrWhere + ' AND g.GoodsID = ''' + @GoodsID + ''''
	
	IF @IsCodeClosed = 1
		
		SET @StrWhere = @StrWhere + ' AND g.CodeClosed =0'
		
	IF @StoreIDFrom Is Not Null
			
		SET @StrWhere2 = @StrWhere2 + ' AND StoreID >=''' + @StoreIDFrom + ''''
		
	IF @StoreIDTo Is Not Null
			
		SET @StrWhere2 = @StrWhere2 + ' AND StoreID <=''' + @StoreIDTo + ''''		
	
	IF @ToDate IS NOT NULL
		SET  @StrWhere2 = @StrWhere2  + ' AND DocDate < =''' + @ToDate + ''''
	
	-- Select Clause -------------------------------------------

	SET @StrSelect = '
		SELECT g.GoodsID,d.GoodsName,GenericID,
			  (Select IsNull(SUM(GoodsQuantity*EnterKind),0) 
			   FROM inv.tblStorageDocsDtl SD 
			   WHERE SD.GoodsID=g.GoodsID '+ @StrWhere2 +') AS Remain,g.SalePrice,g.BuyPrice
		FROM inv.tblGoods g
		INNER JOIN inv.tblGoodsDtl d
		On g.GoodsID = d.GoodsID Where ' + @StrWhere
		
	------------------------------------------------------------
	-- Run -----------------------------------------------------
	print @StrSelect;
	Exec sp_executesql @StrSelect;
	------------------------------------------------------------

End
GO
