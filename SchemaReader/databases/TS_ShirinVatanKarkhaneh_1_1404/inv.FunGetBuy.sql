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
CREATE FUNCTION [inv].[FunGetBuy]
(
@AcntCode Varchar(20),
@DocDate  char(10),
@BaseFiscalYear SMALLINT
)
RETURNS TABLE 
WITH ENCRYPTION
AS
RETURN 
(
	Select	BaseProcessID , BaseProcessNo , BaseFiscalYear , BaseSerialNo , 
			BaseDocRowNo , Sum(GoodsQuantity) ConfirmQuantity
	From inv.tblStorageDocsDtl 
	Where ProcessID = 90  AND BaseSerialNo>0 AND BaseFiscalYear = @BaseFiscalYear 
	Group BY BaseProcessID , BaseProcessNo , BaseFiscalYear , 
			 BaseSerialNo , BaseDocRowNo

)


GO
