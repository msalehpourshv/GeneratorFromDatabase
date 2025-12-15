USE TS_ShirinVatanKarkhaneh_1_1404
GO
SET ANSI_NULLS, QUOTED_IDENTIFIER ON
GO
CREATE FUNCTION [pub].[funGetCurrencyRate] 
(
	@CurrencyTypeID VarChar(20),
	@DocDate Char(10),
	@DocTime Char(5)
)
RETURNS Float
WITH ENCRYPTION
AS

BEGIN

	-- Declare the return variable here
	DECLARE @CurrencyRate  Float
	DECLARE @IsDefault  bit

	Set @CurrencyRate = 0
	Set @IsDefault = 0

	SELECT @IsDefault=IsDefault
	FROM pub.tblCurrencyTypes
	WHERE CurrencyTypeID = @CurrencyTypeID

	IF (@IsDefault=1)	
		set @CurrencyRate=1
	ELSE
		SELECT TOP 1 @CurrencyRate = CurrencyRate
		From pub.tblCurrencyRatesDtl
		Where CurrencyTypeID = @CurrencyTypeID AND ( @DocDate IS Null OR DocDate <= @DocDate) AND ( @DocTime IS Null OR DocTime <= @DocTime)
		ORDER BY DocDate Desc,DocTime Desc

	-- Return the result of the function
	RETURN @CurrencyRate

END

GO
