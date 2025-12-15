USE TS_ShirinVatanKarkhaneh_1_1404
GO
SET ANSI_NULLS, QUOTED_IDENTIFIER ON
GO

CREATE FUNCTION [pub].[funPadRight] 
(
	@StrInput NVarChar(50),
	@ChrDelimiter NChar(1),
	@TotalWidth	TinyInt 
)
RETURNS NVarChar(50)
WITH ENCRYPTION
AS

BEGIN
	
	IF 	LEN(@StrInput) >= @TotalWidth
		RETURN @StrInput
	ELSE
		BEGIN
		DECLARE @i int
		SET @i = LEN(@StrInput)
		While (	@i < @TotalWidth)
			Begin
				SET @i = @i + 1
				SET @StrInput = @StrInput + @ChrDelimiter
			End
		END
	Return @StrInput;
END









GO
