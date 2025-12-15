USE TS_ShirinVatanKarkhaneh_1_1404
GO
SET ANSI_NULLS, QUOTED_IDENTIFIER ON
GO
-- =========== TS-QC:NOTOK ========================
-- Author        : Hadi Sadeghi
-- Create date   : 86/11/29
-- Viewed By	 : 
-- Last Modified : 
-- Description   : 
-- =============================================
CREATE FUNCTION [inv].[funGetLastGoodsAmount] 
(
	@GoodsID Varchar(20),
	@DocDate char(10),
	@VolumeRowNo FLOAT
)
RETURNS Float
WITH ENCRYPTION
AS

BEGIN

	-- Declare the return variable here
	DECLARE @GoodsAmount Float

	SET @GoodsAmount = 0

	SELECT TOP 1 @GoodsAmount = GoodsAmount
	From inv.tblStorageDocsDtl
	Where GoodsID=@GoodsID AND 
		(DocDate<@DocDate OR (DocDate = @DocDate AND (@VolumeRowNo=0 OR VolumeRowNo < @VolumeRowNo))) AND 
		GoodsAmount>0
	ORDER BY DocDate  DESC ,VolumeRowNo DESC

	-- Return the result of the function
	RETURN @GoodsAmount

END






GO
