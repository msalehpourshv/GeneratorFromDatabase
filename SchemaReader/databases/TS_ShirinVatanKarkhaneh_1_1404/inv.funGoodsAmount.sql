USE TS_ShirinVatanKarkhaneh_1_1404
GO
SET ANSI_NULLS, QUOTED_IDENTIFIER ON
GO
CREATE FUNCTION [inv].[funGoodsAmount] 
(
	@Date AS Char(10)
)
RETURNS varchar(15)
WITH ENCRYPTION
AS
BEGIN
	Declare @Month tinyint

	IF @Date Is Null
		RETURN 'GoodsAmount12'

	IF LTrim(@Date)=''
		RETURN 'GoodsAmount12'
	
	SET @Month =SUBSTRING(@Date,6,2)
	
	RETURN 'GoodsAmount' + CAST(@Month as VARchar(2))

end
GO
