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
CREATE FUNCTION [inv].[funGoodsUserPriceValidation]
(
	@GoodsID	VarChar(20),
	@UserPriceID Int
)
RETURNS	BIT
	
WITH ENCRYPTION
AS 
BEGIN

	DECLARE	@HasUserPrice as BIT
	
	SET @HasUserPrice = 'False'
	
	DECLARE @UnitPart TINYINT
	SET @UnitPart  = 1

	SELECT @UnitPart = SettingValue from pub.tblSettings where SettingKey = 'UnitPart'

	IF @UnitPart IS NULL or @UnitPart = 0
		SET @UnitPart = 1
		
	SELECT TOP 1 @HasUserPrice = 'True' 
	FROM inv.tblGoods G
	Inner Join inv.tblGoodsUserPrice U ON G.GoodsID = U.GoodsID
	WHERE  G.PartNumber = @UnitPart AND G.GoodsID = @GoodsID And U.ID = @UserPriceID
	
	RETURN @HasUserPrice

END
GO
