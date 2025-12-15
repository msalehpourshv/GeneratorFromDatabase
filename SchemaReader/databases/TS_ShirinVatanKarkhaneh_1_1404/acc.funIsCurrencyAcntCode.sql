USE TS_ShirinVatanKarkhaneh_1_1404
GO
SET ANSI_NULLS, QUOTED_IDENTIFIER ON
GO
CREATE FUNCTION [acc].[funIsCurrencyAcntCode]
(
	@AcntCode AS VarChar(20)
)
RETURNS Bit
WITH ENCRYPTION
AS
BEGIN
	DECLARE @IsCurrency AS BIT
	DECLARE @Part1Len INT
	
	SET @IsCurrency = 'FALSE'
	
	SELECT	@Part1Len = Layer1 + Layer2 + Layer3 + Layer4 + Layer5 + Layer6 + Layer7 + Layer8 + Layer9 
	FROM	pub.tblCodeLayer 
	WHERE	(TableName = 'acc.tblAcnt') AND (PartNumber = 1)
		
	SELECT @IsCurrency=IsCurrency FROM acc.tblAcnt
	WHERE  PartNumber=1 AND AcntCode = RTRIM(SUBSTRING(@AcntCode,1,@Part1Len))
	
	RETURN @IsCurrency
	
END
GO
