USE TS_ShirinVatanKarkhaneh_1_1404
GO
SET ANSI_NULLS, QUOTED_IDENTIFIER ON
GO
-- =========== TS-QC:UPDATED ====================
-- Author		 : TakroSystem\Taha Esmaeili
-- Creation Date : 1400/11/10
-- Viewed By	 : 
-- Last Modified : 
-- Last Modifier : 
-- Description	 : 
-- ==============================================
Create PROCEDURE sal.RptRestaurantSumSale
	@ProcessID			Int = 0,
	@ProcessNo	    	Int = 0,
	@FiscalYearFr		Int = 0,
	@SerialNoFr	    	Int = 0,
    @FiscalYearTo	    Int = 0,	
	@SerialNoTo			Int = 0,
    @RepOptions			VarChar(10) = '', 
	@RepInfo			NVarChar(100) = '',
	@ExtraParams	    NVarChar(400) = ''

WITH ENCRYPTION
AS 
---- Declarations ---------------
Declare @StrSelect			NVarChar(max);
Declare @StrWhere			NVarChar(2048);
Declare @PrpLanguageID      varchar(3);

Begin --============== S T A R T  C O D E ===================================================
   
	set @StrWhere=''
	-- Acnt Filter 
	IF (@SerialNoFr <>0)
		SET @StrWhere = @StrWhere + ' AND (F.SerialNo >=' + LTrim(Str(@SerialNoFr)) + ')'	
	IF (@SerialNoTo  <>0)
		SET @StrWhere = @StrWhere + ' AND (F.SerialNo <= ' + LTrim(Str(@SerialNoTo)) + ')'		
	IF (@FiscalYearFr <>0)
		SET @StrWhere = @StrWhere + ' AND (F.FiscalYear =' + LTrim(Str(@FiscalYearFr)) + ')'	
		
 	
	Set @StrSelect = '
		SELECT *,sal.funGetSaleTypeName(F.SaleTypeID,1) SaleTypeName  FROM sal.tblRestaurantSaleDtl F 
 Left Join inv.tblGoodsDtl D  On F.GoodsID=D.GoodsID  
 LEFT JOIN  sal.tblDescriptionDtl D2 On F.DescID=D2.DescriptionID  
 WHERE 1=1 ' + @StrWhere +' ORDER BY DocRowNo'
         


               
	-- RUN -----------------------------------------------------
	Print @StrSelect;
	Exec sp_executesql @StrSelect;
	
End
GO
