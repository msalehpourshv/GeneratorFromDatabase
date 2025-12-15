USE TS_ShirinVatanKarkhaneh_1_1404
GO
SET ANSI_NULLS, QUOTED_IDENTIFIER ON
GO
-- =========== TS-QC:NOTOK ========================
-- Author        : Alianpour
-- Create date   : 1400/12/25
-- Viewed By	 : 
-- Last Modified : 
-- Description   : 
-- =============================================
CREATE PROCEDURE prd.sp_api_AsmanRasa_GetPriceOfProductCost

@GoodsId AS nVARCHAR(100),
@Date AS NVARCHAR(10),
@Personnel AS NVARCHAR(100),
@statusId as nvarchar(100)

WITH ENCRYPTION
 AS
BEGIN

DECLARE @StrErrorMessage As Nvarchar(1024)
DECLARE @MaxSerialNo AS INT

BEGIN TRY

	--SELECT ISNULL(D.FixAmountForInvoice,1)as FixAmountForInvoice,
	--	   ISNULL(D.AmountOfGood,0)as AmountOfGood,
	--	   ISNULL(D.PercentOfOrder,0) as PercentOfOrder

	declare @fix as float=1
	declare @Amount as float=0
	declare @Percent as float=0


	SELECT @fix as FixAmountForInvoice,
		   @Amount as AmountOfGood,
		   @Percent as PercentOfOrder

	FROM prd.tblManufacturersWageHdr H
	JOIN prd.tblManufacturersWageDtl D
	ON H.SerialNo=D.SerialNo 
	--WHERE H.FromDate>=@Date 
	--	 AND (H.ToDate='' or H.ToDate<=@Date)
	--	 AND D.PersonnelID=@Personnel 
	--	 AND D.GoodsID=@GoodsId 
	--	 AND D.StatusID=D.StatusID


END TRY
BEGIN CATCH


	Set @StrErrorMessage = ERROR_MESSAGE() 
	raiserror (@StrErrorMessage, 16, 1)

END CATCH

END	

GO
