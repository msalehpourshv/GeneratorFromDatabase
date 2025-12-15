USE TS_ShirinVatanKarkhaneh_1_1404
GO
SET ANSI_NULLS, QUOTED_IDENTIFIER ON
GO
-- =========== TS-QC:NOTOK ========================
-- Author        : Alian Pour
-- Create date   : 1400/10/13
-- Viewed By	 : 
-- Last Modified : 
-- Description   : 
-- =============================================
Create PROCEDURE [inv].[sp_api_Brango_GetSaleHdr]

@ProcessNo As NVARCHAR(50)=4,
@FiscalYear As NVARCHAR(50),
@SerialNo As NVARCHAR(200)


WITH ENCRYPTION
 AS
BEGIN
	DECLARE @strSelect  NVARCHAR(MAX)
	DECLARE @StrErrorMessage NVARCHAR(MAX)

BEGIN TRY

	SELECT  SerialNo,ProcessID,ProcessNo,FiscalYear,DocDate,sdh.SaleTypeID,saleType.SaleTypeName,
			sdh.StoreID,store.StoreName,Price,Amount,DocDesc,OrderAcntCode as AcntMobile,DiscountPercent,Discount,Discount2+Discount3 Discount2,
			TotalLineDiscount,TaxOverWorthCost,TollOverWorthCost,
			customer.FirstName as CustomerFirstName,customer.LastName as CustomerLastName

	FROM inv.tblStorageDocsHdr sdh

		Left Join sal.tblSaleTypesDtl saleType on sdh.SaleTypeID=saleType.SaleTypeID
		Left Join inv.tblStoresDtl store on sdh.StoreID=store.StoreID
		Left Join lyl.tblCustomerInfoDtl customer on sdh.OrderAcntCode=customer.CustomerInfoID

	WHERE SerialNo=@SerialNo and ProcessNo=4 
		  and FiscalYear=@FiscalYear and ProcessID='90'
	

END TRY
BEGIN CATCH


	Set @StrErrorMessage = ERROR_MESSAGE() 
	raiserror (@StrErrorMessage, 16, 1)

END CATCH

END	
GO
