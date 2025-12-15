USE TS_ShirinVatanKarkhaneh_1_1404
GO
SET ANSI_NULLS, QUOTED_IDENTIFIER ON
GO
-- =========== TS-QC:NOTOK ========================
-- Author        : Hadi Sadeghi
-- Create date   : 86/12/04
-- Viewed By	 : 
-- Last Modified : 
-- Description   : 
-- =============================================
Create FUNCTION [cmr].[FunGetBaseOrderGoods]
(
	@AcntCode Varchar(20),
	@DocDate  char(10),
	@DocStep1 Tinyint,
	@DocStep2 Tinyint,
	@SerialNo int=NULL,
	@FiscalYear SmallInt=NULL
)
RETURNS TABLE 
WITH ENCRYPTION
AS
RETURN 
(


select * from cmr.FunCmrGoodsQtyRemain(160,0,@SerialNo,@FiscalYear,0,0,0,0,0,0)
Where (@AcntCode IS NULL   OR AcntCode = @AcntCode) 
AND  DocDate <= @DocDate 
AND (DocStep = @DocStep1 OR DocStep = @DocStep2) 
and ConfirmQuantity > 0
)
GO
