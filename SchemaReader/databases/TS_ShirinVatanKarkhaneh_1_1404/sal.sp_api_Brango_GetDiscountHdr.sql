USE TS_ShirinVatanKarkhaneh_1_1404
GO
SET ANSI_NULLS, QUOTED_IDENTIFIER ON
GO
-- =========== TS-QC:NOTOK ========================
-- Author        : Alian Pour
-- Create date   : 1401/04/26
-- Viewed By	 : 
-- Last Modified : 
-- Description   : 
-- =============================================
Create PROCEDURE sal.sp_api_Brango_GetDiscountHdr

WITH ENCRYPTION
 AS
BEGIN
	DECLARE @StrErrorMessage NVARCHAR(MAX)
	DECLARE @strQuery NVARCHAR(Max)
	
BEGIN TRY
	

	SELECT distinct FromDate,H.SerialNo,ToDate,FromQty,ToQty,ForQty,isnull(Discount,0),isnull(DiscountPercent,0)
	FROM sal.tblDiscountPoliciesHdr H 
		inner join sal.tblDiscountPoliciesDtl D 
		ON H.ProcessID=D.ProcessID and H.SerialNo=D.SerialNo 
		Inner join inv.tblGoods G on SUBSTRING(G.GoodsID,1,LEN(D.GoodsID))=D.GoodsID
	WHERE H.ProcessID = 200 

	
END TRY
BEGIN CATCH


	Set @StrErrorMessage = ERROR_MESSAGE() 
	raiserror (@StrErrorMessage, 16, 1)

END CATCH

END	
GO
