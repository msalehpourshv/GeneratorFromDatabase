USE TS_ShirinVatanKarkhaneh_1_1404
GO
SET ANSI_NULLS, QUOTED_IDENTIFIER ON
GO
-- =========== TS-QC:UPDATED ====================
-- Author		 : TakroSystem\Hamid
-- Create date   : 1393/04/22
-- Viewed By	 : 
-- Last Modified : 
-- Last Modifier : 
-- Description	 : 
-- ==============================================
create PROCEDURE [phr].[RptPhr_SaleInTimeInterval]

	@GoodsID			Varchar(20) = Null,
	@FromDate			Char(10) = NULL,
	@ToDate				Char(10) = NULL,
	@ExtraParams		NVarChar(200) = '0@0',
	@RepOptions			VarChar(10) = '', -- bit array options
	@RepInfo			NVarChar(100) = '1@1@1'
	
WITH ENCRYPTION
AS 

Declare @StrSelect		NVarChar(4000);
Declare @StrWhere		NVarChar(4000);
Declare @StrWhere2		NVarChar(4000);

Declare @IsDecorDrug	Bit;

Begin -- ============== S T A R T  C O D E ====================================

	SET NOCOUNT ON;

	SET @StrWhere = 'SD.ProcessID=90 '
	
	SET @IsDecorDrug = Substring(@RepOptions, 1, 1) -- 1 is used 
	
	-- ============== Where ====================================
	
	IF @GoodsID Is Not Null
		SET @StrWhere = @StrWhere + ' AND SD.GoodsID = ''' + @GoodsID + ''''
	
	IF @FromDate IS NOT NULL
		SET  @StrWhere = @StrWhere  + ' AND SD.DocDate >= ''' + @FromDate + ''''
		
	IF @ToDate IS NOT NULL
		SET  @StrWhere = @StrWhere  + ' AND DocDate <= ''' + @ToDate + ''''		
	
	IF (@RepOptions IS NOT NULL) And (@RepOptions <> '')
		SET @StrWhere = @StrWhere + ' AND GH.IsDecorDrug = ' + LTrim(RTrim(Str(@IsDecorDrug)))
		
		
	-- Select Clause -------------------------------------------
	
	SET @StrSelect = '
		Select SD.GoodsID, GD.GoodsName, SUM(SD.SubUnitQuantity) As SaleQTY,
			   SUM(SD.SubUnitQuantity * SD.GoodsPrice) As SumSaleAmount, SD.DocDate
		From inv.tblStorageDocsDtl SD
		Inner Join inv.tblGoods GH ON GH.GoodsID = SD.GoodsID
		Inner Join inv.tblGoodsDtl GD ON GD.GoodsID = SD.GoodsID
		Where ' + @StrWhere + ' 
		Group By SD.GoodsID, GD.GoodsName, SD.DocDate
		Order By SD.DocDate'
	 
	------------------------------------------------------------
	-- Run -----------------------------------------------------
	print @StrSelect;
	Exec sp_executesql @StrSelect;
	------------------------------------------------------------
End
GO
