USE TS_ShirinVatanKarkhaneh_1_1404
GO
SET ANSI_NULLS, QUOTED_IDENTIFIER ON
GO
-- =========== TS-QC:NOTOK =====================
-- Author        : TakroSystem\Hadi sadeghi
-- Create date   : 1396/09/30
-- Viewed By	 : 
-- Last Modified : 
-- Last Modifier : 
-- Description   : 
-- =============================================
CREATE FUNCTION [inv].[funGoodsHasBatch]
(
	@GoodsID VarChar(20)
)
RETURNS	BIT
	
WITH ENCRYPTION
AS 
Begin

	DECLARE	@HasBatchNo as BIT
	
	SET @HasBatchNo = 'False'
	
	DECLARE @UnitPart TINYINT
	SET @UnitPart  = 1

	SELECT @UnitPart = SettingValue from pub.tblSettings where SettingKey = 'UnitPart'

	IF @UnitPart IS NULL or @UnitPart = 0
		SET @UnitPart = 1
		
	SELECT @HasBatchNo = HasBatchNo 
	FROM inv.tblGoods
	WHERE  PartNumber=@UnitPart AND GoodsID=@GoodsID
	
	RETURN @HasBatchNo
End
GO
