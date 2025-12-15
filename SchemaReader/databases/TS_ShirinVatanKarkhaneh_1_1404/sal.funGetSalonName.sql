USE TS_ShirinVatanKarkhaneh_1_1404
GO
SET ANSI_NULLS, QUOTED_IDENTIFIER ON
GO
--===================================
--Aoutor: Nogrepasand
--Date:1391/09/01
--===================================

CREATE FUNCTION [sal].[funGetSalonName]
 
(
	@TablelID	Char(20) ,
	@FirstLayerLenght	INT ,
	@LanguageID	TinyInt
)
RETURNS NVarChar(50)
WITH ENCRYPTION
AS

BEGIN

	-- Declare the return variable here
	DECLARE @SalonName NVarChar(50)

	Set @SalonName = N'-'

	SELECT @SalonName = RTRIM(TableName) 
	From  sal.tblTablesDtl
	Where LanguageID = @LanguageID AND  TableID =SUBSTRING(@TablelID,1, @FirstLayerLenght)  AND LEN(TableID)=@FirstLayerLenght

	-- Return the result of the function
	RETURN @SalonName 

END
GO
