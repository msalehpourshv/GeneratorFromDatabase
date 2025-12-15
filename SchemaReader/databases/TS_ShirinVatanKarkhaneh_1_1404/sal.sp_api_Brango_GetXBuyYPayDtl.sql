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
create PROCEDURE  sal.sp_api_Brango_GetXBuyYPayDtl
	@FromDate			Varchar(20)=NULL, 
	@ToDate				Varchar(20)=NULL, 
	@XBuy				Varchar(20)=NULL, 
	@YPay				Varchar(20)=NULL


WITH ENCRYPTION
 AS
BEGIN
	DECLARE @StrErrorMessage NVARCHAR(MAX)
	DECLARE @strQuery NVARCHAR(Max)
	
BEGIN TRY

	select G.GoodsID, BH.FromDate,BH.ToDate,BH.XBuy,BH.YPay
	from sal.tbl3buy2PayHdr BH INNER JOIN  
	sal.tbl3buy2PayDtl6 BD
	ON BH.SerialNo=BD.SerialNo
	inner join inv.tblGoods G
	on BD.GoodsID=left(G.GoodsID,LenGoodsID)
	where XBuy=@XBuy AND YPay=YPay AND FromDate=@FromDate AND ToDate=@ToDate 

END TRY
BEGIN CATCH

	Set @StrErrorMessage = ERROR_MESSAGE() 
	raiserror (@StrErrorMessage, 16, 1)

END CATCH

END	
GO
