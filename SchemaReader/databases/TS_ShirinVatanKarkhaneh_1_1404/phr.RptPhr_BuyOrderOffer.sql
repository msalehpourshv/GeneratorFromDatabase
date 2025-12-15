USE TS_ShirinVatanKarkhaneh_1_1404
GO
SET ANSI_NULLS, QUOTED_IDENTIFIER ON
GO
-- =========== TS-QC:UPDATED ====================
-- Author		 : TakroSystem\Hamid
-- Create date   : 1393/04/23
-- Viewed By	 : 
-- Last Modified : 
-- Last Modifier : 
-- Description	 : 
-- ==============================================
CREATE PROCEDURE [phr].[RptPhr_BuyOrderOffer]

	@GoodsID			Varchar(20) = Null,
	@FromDate			Char(10) = NULL,
	@ToDate				Char(10) = NULL,
	@FutureDay			Float = NULL,
	@ExtraParams		NVarChar(200) = '0@0',
	@RepOptions			VarChar(10) = '', -- bit array options
	@RepInfo			NVarChar(100) = '1@1@1'
	
WITH ENCRYPTION
AS 

Declare @StrSelect		NVarChar(4000);
Declare @StrWhere		NVarChar(4000);
Declare @StrWhere2		NVarChar(4000);

Declare @DayCount			Float;
Declare @GoodsRemain		Float;
Declare @DaysWithRemain		Float;
Declare @SumSubUnitQty		Float;
Declare @RemainInEachDay	Float;
Declare @CurrentGoodsRemain	Float;
Declare @FutureGoodsRemain	Float;

Begin -- ============== S T A R T  C O D E ====================================

	SET NOCOUNT ON;

	SET @StrWhere = '1 = 1'
	
	-- ============== Where ====================================

	IF @GoodsID Is Not Null
		SET @StrWhere = @StrWhere + ' AND SD.GoodsID = ''' + @GoodsID + ''''
	
	IF @FromDate IS NOT NULL
		SET  @StrWhere = @StrWhere  + ' AND SD.DocDate >= ''' + @FromDate + ''''
		
	IF @ToDate IS NOT NULL
		SET  @StrWhere = @StrWhere  + ' AND DocDate <= ''' + @ToDate + ''''		
		
	-- ============= Set Variable Values ========================
	
		
	-- Select Clause -------------------------------------------
	
	SET @StrSelect = 'Select '''' As GoodsID, '''' As GoodsName, 0 As Requirements '
			   
	------------------------------------------------------------
	-- Run -----------------------------------------------------
	print @StrSelect;
	Exec sp_executesql @StrSelect;
	------------------------------------------------------------
End
GO
