USE TS_ShirinVatanKarkhaneh_1_1404
GO
SET ANSI_NULLS, QUOTED_IDENTIFIER ON
GO
-- =========== TS-QC:NOTOK ========================
-- Author        : Alian Pour
-- Create date   : 1401/04/20
-- Viewed By	 : 
-- Last Modified : 
-- Description   : 
-- =============================================
create PROCEDURE  sal.sp_api_Brango_GetDiscountDtl

	@FromDate			Varchar(20)=NULL, 
	@ForQty				int=NULL,
	@FromQty				int=NULL,
	@ToQty				int=NULL,
	@Discount           int=NULL,
	@DiscountPercent	int=NULL,
	@ToDate				char(10)=NULL



WITH ENCRYPTION
 AS
BEGIN
	DECLARE @StrErrorMessage NVARCHAR(MAX)
	DECLARE @strQuery NVARCHAR(Max)
	
BEGIN TRY


	SELECT G.GoodsID
	FROM sal.tblDiscountPoliciesHdr H 
		inner join sal.tblDiscountPoliciesDtl D 
		ON H.ProcessID=D.ProcessID and H.SerialNo=D.SerialNo 
		Inner join inv.tblGoods G on SUBSTRING(G.GoodsID,1,LEN(D.GoodsID))=D.GoodsID
	WHERE H.ProcessID = 200 and FromDate=@FromDate and ToDate=@ToDate and ForQty=@ForQty and FromQty=@FromQty and ToQty=@ToQty and Discount=@Discount and DiscountPercent=@DiscountPercent
	order by H.SerialNo desc




END TRY
BEGIN CATCH

	Set @StrErrorMessage = ERROR_MESSAGE() 
	raiserror (@StrErrorMessage, 16, 1)

END CATCH

END	
GO
