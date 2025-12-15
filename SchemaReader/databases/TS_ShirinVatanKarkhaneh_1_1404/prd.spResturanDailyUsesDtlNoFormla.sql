USE TS_ShirinVatanKarkhaneh_1_1404
GO
SET ANSI_NULLS, QUOTED_IDENTIFIER ON
GO
--[prd].[spResturanDailyUsesDtlNoFormla]'1394/08/23','1394/08/23',94,'001','21112',4,1,0
-- =========== TS-QC:NOTOK ========================
-- Author        : Reza Nogrepasand
-- Create date   : 92/01/19
-- Viewed By	 : 
-- Last Modified : 
-- Description   : 
-- =============================================
Create PROCEDURE prd.spResturanDailyUsesDtlNoFormla
	@ProcessID AS int,
	@FromDate as CHAR(10),
	@ToDate as CHAR(10),
	@FiscalYear as SMALLINT,
	@BranchID AS VARCHAR(20),
	@GoodsID AS VARCHAR(20),
	@Qty AS Decimal(38,10),
	@DocRowNo AS INT,
	@GoodsPrice AS FLOAT,
	@SaleTypeID AS VARCHAR(20),
	@TaxOverWorthCostDtl AS FLOAT,
	@TollOverWorthCostDtl AS FLOAT

WITH ENCRYPTION
 AS
BEGIN

BEGIN TRY

	BEGIN TRAN 
	DECLARE @maxSerialNo INT
	DECLARE @StoreID1 AS VARCHAR(20)
	DECLARE @StoreID2 AS VARCHAR(20)
	DECLARE @StoreID3 AS VARCHAR(20)
	DECLARE @AcntCode AS VARCHAR(20)
	DECLARE @RowNo AS INT
	DECLARE @DocRowNo1 AS INT
	DECLARE @IsReward AS bit

	SET @maxSerialNo = 0
	SET @IsReward = 0
	if (@GoodsPrice=0)
	set @IsReward =1

	SELECT @StoreID1 = StoreID1, @StoreID2 = StoreID2 , @StoreID3 = StoreID3
	FROM sal.tblBranches
	WHERE  BranchID=@BranchID
	
	SELECT @AcntCode= GoodsInProductionAcntCode 
	FROM inv.tblStores
	WHERE StoreID= @StoreID1
	
	

	--############################################################################
	
	SET @maxSerialNo = 0

	SELECT @maxSerialNo = isnull(MAX(SerialNo),0)
	FROM inv.tblStorageDocsHdr 
	WHERE ProcessID=@ProcessID 
	  AND ProcessNo=11
	  AND FiscalYear=@FiscalYear
	  AND BRN = @BranchID	
			 	
	 SELECT @RowNo = isnull(MAX(RowNo),0)
	FROM inv.tblStorageDocsDtl 
	WHERE ProcessID=@ProcessID  
	  AND ProcessNo=11
	  AND FiscalYear=@FiscalYear
	  AND SerialNo=@maxSerialNo
	  
	   SELECT @DocRowNo1 = isnull(MAX(DocRowNo),0)
	FROM inv.tblStorageDocsDtl 
	WHERE ProcessID=@ProcessID  
	  AND ProcessNo=11
	  AND FiscalYear=@FiscalYear
	  AND SerialNo=@maxSerialNo
DECLARE @EnterKind int
DECLARE @StoreID AS VARCHAR(20)

if @ProcessID  =90
begin
	set @EnterKind=-1
	set @StoreID=@StoreID2
end 
else 
begin
	set @EnterKind=1
	set @StoreID=@StoreID3
end 
	----------------------------
	INSERT INTO inv.tblStorageDocsDtl
	(ProcessID, ProcessNo, FiscalYear, SerialNo, RowNo, DocRowNo, VolumeRowNo,
		DocStep, DocDate, StoreID, PhysicallyEffected, EnterKind, StoreID2, AcntCode,SaleTypeID,
		VisitorAcntCode, OrderAcntCode, GoodsID, SubUnitID, SubUnitQuantity,
		GoodsQuantity, QtyRemain, GoodsAmount, AmntRemain, AtomAmount, GoodsPrice,
		DescDtl, BaseProcessID, BaseProcessNo, BaseFiscalYear, BaseSerialNo,
		BaseDocRowNo, BaseDocType, AgreeNo, BatchNo, DiscountPercentDtl, DiscountDtl,
		BaseDocDate, VirtualQuantity, IsReward, FormulaNo, GoodsID2, Wage, WageRate,
		FormulaProductCount, CurrencyAmount, CalculatingAmount, VchDate2, SubUnitPrice,
		UserGoodsAmount, [ExpireDate], SourceSerialNo, SourceProcessNo,
		DailyUsesBranchID, GoodsAmount1, GoodsAmount2, GoodsAmount3, GoodsAmount4,
		GoodsAmount5, GoodsAmount6, GoodsAmount7, GoodsAmount8, GoodsAmount9,
		GoodsAmount10, GoodsAmount11, GoodsAmount12, StoreVariable1, StoreVariable2,
		SalePrice, PhrBatchNo, GregorianExpireDate,TaxOverWorthCostDtl,TollOverWorthCostDtl)
		
	select @ProcessID , 11, @FiscalYear, @maxSerialNo, @RowNo+1 RowNo,@DocRowNo1+1 DocRowNo, 
		   0, 3, @ToDate, @StoreID2, 'True', @EnterKind, '', @AcntCode,@SaleTypeID, '', '', @GoodsID,f.UnitID SubUnitID,@Qty SubUnitQuantity,
		   @Qty GoodsQuantity,0 QtyRemain,0 GoodsAmount,0 AmntRemain,0 AtomAmount,@GoodsPrice GoodsPrice,'' DescDtl,
		   0 BaseProcessID,0 BaseProcessNo,0 BaseFiscalYear,0 BaseSerialNo,0 BaseDocRowNo,'' BaseDocType,0 AgreeNo,
		   '' BatchNo,0 DiscountPercentDtl,0 DiscountDtl,'' BaseDocDate,0 VirtualQuantity,@IsReward,
		   0,'' GoodsID2,0 Wage,0 WageRate,0 FormulaProductCount,0 CurrencyAmount,0 CalculatingAmount,
		   '' VchDate2,0 SubUnitPrice,0 UserGoodsAmount,'' [ExpireDate],0 SourceSerialNo,0 SourceProcessNo,@BranchID DailyUsesBranchID,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,'','',@TaxOverWorthCostDtl,@TollOverWorthCostDtl
	FROM	
		(SELECT g.UnitID FROM 
			 inv.tblGoods g
		WHERE g.GoodsID=@GoodsID) f
	----------------------------
	
	COMMIT TRAN
END TRY
BEGIN CATCH

	ROLLBACK TRAN
	Declare @StrErrorMessage As Nvarchar(1024)
	Set @StrErrorMessage = ERROR_MESSAGE() 
	raiserror (@StrErrorMessage, 16, 1)

END CATCH

END
GO
