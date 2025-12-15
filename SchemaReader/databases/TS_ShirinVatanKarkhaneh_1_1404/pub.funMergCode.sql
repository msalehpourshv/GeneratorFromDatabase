USE TS_ShirinVatanKarkhaneh_1_1404
GO
SET ANSI_NULLS, QUOTED_IDENTIFIER ON
GO
CREATE FUNCTION [pub].[funMergCode]
(
	@S	VARCHAR(30), 
	@T	VARCHAR(30) 
)
RETURNS NVarChar(50)
WITH ENCRYPTION
AS

BEGIN
	
	DECLARE @Ret VARchar(20)
	DECLARE @Counter INT

	SET @Counter =1
	SET @Ret = ''

	WHILE @Counter<=LEN(@S)
	BEGIN
		IF SUBSTRING(@S,@Counter,1)=' ' 
			SET @Ret = @Ret + SUBSTRING(@T,@Counter,1)
		ELSE 
			SET @Ret = @Ret + SUBSTRING(@S,@Counter,1)
				
		SET @Counter = @Counter + 1	

		IF @Counter > LEN(@T)
			BEGIN
				SET @Ret = @Ret + SUBSTRING(@S,@Counter,20)
				SET @Counter=LEN(@S)+1
			END
	END

	IF LEN(@S) < LEN(@T)
		SET @Ret = @Ret + SUBSTRING(@T,@Counter,20)

	RETURN @Ret
END
GO
