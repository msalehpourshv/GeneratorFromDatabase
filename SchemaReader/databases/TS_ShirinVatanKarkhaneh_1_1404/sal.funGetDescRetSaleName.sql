USE TS_ShirinVatanKarkhaneh_1_1404
GO
SET ANSI_NULLS, QUOTED_IDENTIFIER ON
GO
CREATE FUNCTION [sal].[funGetDescRetSaleName] 
(
	@DescRetSaleID	Char(20) ,
	@LanguageID	TinyInt
)
RETURNS NVarChar(50)
WITH ENCRYPTION
AS

BEGIN

	-- Declare the return variable here
	DECLARE @DescRetSaleName NVarChar(50)

	Set @DescRetSaleName = N'-'

	SELECT @DescRetSaleName = DescRetSaleName
	From  sal.tblDescRetSaleDtl
	Where LanguageID = @LanguageID AND DescRetSaleID = @DescRetSaleID 

	-- Return the result of the function
	RETURN @DescRetSaleName 

END
GO
