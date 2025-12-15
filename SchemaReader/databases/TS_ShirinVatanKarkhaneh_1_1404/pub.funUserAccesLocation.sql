USE TS_ShirinVatanKarkhaneh_1_1404
GO
SET ANSI_NULLS, QUOTED_IDENTIFIER ON
GO
CREATE FUNCTION [pub].[funUserAccesLocation] 
(
	@Code Varchar(20),
	@UserID Char(10)
)
RETURNS BIT
WITH ENCRYPTION
AS

BEGIN

	DECLARE @Result  BIT

	SET  @Result = 'False'

	SELECT @Result = CASE COUNT(*) WHEN 0 THEN 'False' ELSE 'True' END 
	FROM pub.tblLocationsRng R
	WHERE R.UserID = @UserID AND 
		(((R.AllowCodeView = 1) AND 
		(LEFT(@Code,LEN(ToCode)) <= ToCode AND 
		 LEFT(@Code,LEN(ToCode)) >= FromCode)) OR AccessAllCode ='True')  

	RETURN @Result
END
GO
