USE TS_ShirinVatanKarkhaneh_1_1404
GO
SET ANSI_NULLS, QUOTED_IDENTIFIER ON
GO
-- =========== TS-QC:NOTOK ========================
-- Author        : Seyed Mahdi Mostafavi
-- Create date   : 1403-11-13
-- Viewed By	 : 
-- Last Modified : 
-- Description   : 
-- =============================================
Create PROCEDURE [prd].[spResturanSalesOtherDtlAuto]
@ToDate as varchar(10),
@BranchID AS NVARCHAR(20),
@FiscalYear AS Int

WITH ENCRYPTION
 AS
BEGIN

BEGIN TRY

	BEGIN TRAN 

	update sal.tblRestaurantSaleHdr
	SET TaxOverWorthAmount = SS
	from sal.tblRestaurantSaleHdr a
	inner join ( select ProcessID,ProcessNo,FiscalYear,SerialNo,BranchID,SUM(TaxOverWorthCostDtl) SS,SUM(TollOverWorthCostDtl) TT 
	             from  sal.tblRestaurantSaleDtl 
				 where  DocDate<=@ToDate
					AND   BranchID = @BranchID
					AND   FiscalYear = @FiscalYear
					AND   ProcessID = 92
				 group by ProcessID,ProcessNo,FiscalYear,SerialNo,BranchID
				 ) b
	on a.ProcessID=b.ProcessID
	and a.ProcessNo=b.ProcessNo
	and a.FiscalYear=b.FiscalYear
	and a.SerialNo=b.SerialNo
	and a.BranchID=b.BranchID
	WHERE TaxOverWorthAmount <> SS

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
