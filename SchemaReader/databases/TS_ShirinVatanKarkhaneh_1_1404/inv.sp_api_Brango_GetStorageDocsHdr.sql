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
CREATE PROCEDURE [inv].[sp_api_Brango_GetStorageDocsHdr]

@OrderAcntCode As NVARCHAR(50),
@Skip As int,
@MaxResultCount As int


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

	WHERE (OrderAcntCode=@OrderAcntCode) and
		  (ProcessID='90' or ProcessID='100')
	
        ORDER BY SerialNo DESC
		OFFSET  @Skip  Rows 
		FETCH NEXT @MaxResultCount Rows ONLY
END TRY
BEGIN CATCH


	Set @StrErrorMessage = ERROR_MESSAGE() 
	raiserror (@StrErrorMessage, 16, 1)

END CATCH

END	
GO
