USE TS_ShirinVatanKarkhaneh_1_1404
GO
SET ANSI_NULLS, QUOTED_IDENTIFIER ON
GO

CREATE FUNCTION [pub].[funReplaceCode] 
(
	@StrBaseCode VarChar(30),
	@StrReplaceCode VarChar(30)
)
RETURNS VarChar(30)
WITH ENCRYPTION
AS

BEGIN
	DECLARE @Result VarChar(30)
	DECLARE @i tinyint 
	SET @i = 1
	SET @StrBaseCode = [pub].[funPadRight](@StrBaseCode,' ',30)
	SET @StrReplaceCode = [pub].[funPadRight](@StrReplaceCode,' ',30)
	SET @Result = ''

	While (	@i <= 30)
		Begin
			IF SUBSTRING(@StrReplaceCode,@i,1) <> ' ' AND SUBSTRING(@StrReplaceCode,@i,1) <> SUBSTRING(@StrBaseCode,@i,1)
				Set @Result = @Result + SUBSTRING(@StrReplaceCode,@i,1)
			ELSE
				Set @Result = @Result + SUBSTRING(@StrBaseCode,@i,1)

			SET @i = @i + 1
		End

	
	Return LTRIM(RTRIM(@Result));
END









GO
