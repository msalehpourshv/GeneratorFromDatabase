USE TS_ShirinVatanKarkhaneh_1_1404
GO
SET ANSI_NULLS, QUOTED_IDENTIFIER ON
GO
-- =========== TS-QC:OK ========================
-- Author        : Hadi Sadeghi
-- Create date   : 86/07/04
-- Viewed By	 : 
-- Last Modified : 
-- Description   : 
-- =============================================
CREATE function [prd].[funPrdControlSendReciveQty] 
(
 @ProcessID		tinyint,
 @ProcessNo	    tinyint,
 @FiscalYear	smallint,
 @SerialNo      int

)
RETURNS DECIMAL(28,9)
WITH ENCRYPTION
AS
BEGIN

	declare @SendQty float
	declare @ReciveQty float
	
	set @SendQty = 0
	set @ReciveQty = 0
	
	select @ReciveQty=SUM(GoodsQuantity) 
	from inv.tblStorageDocsDtl 
	WHERE BaseProcessID=@ProcessID and BaseProcessNo=@ProcessNo and BaseFiscalYear=@FiscalYear and BaseSerialNo=@SerialNo
	-----محصول و ضایعات--------------------
	select @SendQty = SUM(GoodsQuantity) 
	from inv.tblStorageDocsDtl 
	WHERE ProcessID=@ProcessID and ProcessNo=@ProcessNo and FiscalYear=@FiscalYear and SerialNo=@SerialNo

	return @SendQty - @ReciveQty
END	
GO
