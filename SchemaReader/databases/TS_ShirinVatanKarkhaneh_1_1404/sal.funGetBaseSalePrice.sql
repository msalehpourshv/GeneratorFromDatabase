USE TS_ShirinVatanKarkhaneh_1_1404
GO
SET ANSI_NULLS, QUOTED_IDENTIFIER ON
GO
-- =========== TS-QC:UPDATED ====================
-- Author		 : TakroSystem\H.Sadeghi
-- Create date   : 1398/04/19
-- Viewed By	 : 
-- Last Modified : 
-- Last Modifier : 
-- Description   :
-- =================================================================
 Create FUNCTION [sal].[funGetBaseSalePrice]
	(@GoodsID	varchar(20)	)
	RETURNS float
WITH ENCRYPTION
AS
BEGIN
	if @GoodsID=''
		return 0

	DECLARE @Amount float	
	set @Amount =0

	select  TOP 1 @Amount = Amount 
	from sal.tblGoodsPriceForCustomerKindDtl a
	inner join sal.tblGoodsPriceForCustomerKindHdr b
	on a.SerialNo=b.SerialNo
	where GoodsID=@GoodsID and CurrencyTypeID=''
	order by FromDate desc,FromTime desc ,a.SerialNo desc ,a.RowNo desc


	return @Amount
END
GO
