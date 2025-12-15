USE TS_ShirinVatanKarkhaneh_1_1404
GO
SET ANSI_NULLS, QUOTED_IDENTIFIER ON
GO
-- =========== TS-QC:UPDATED ====================
-- Author		 : HSR ISF
-- Create date   : 1403/03/17 
-- Viewed By	 : 
-- Last Modified : 
-- Description	 : نام پایگاه داده سال مالی بعد را برمی گرداند
-- ==============================================
Create PROCEDURE [pub].[SpGetNextDBName]
	@StrCurrDBName AS VarChar(50),
	@StrNextDBName AS VarChar(50) OUTPUT
WITH ENCRYPTION
AS 

BEGIN

	SET @StrNextDBName = Left(@StrCurrDBName, LEN(@StrCurrDBName)-4) + LTRIM(STR((CAST(RIGHT(@StrCurrDBName,4) as int)+1)))
	print @StrNextDBName
	print @StrNextDBName
	If (SELECT	[name]
		FROM	sys.databases
		WHERE	(state = 0) AND ([name] = @StrNextDBName)) Is Null	

		SET @StrNextDBName = ''
END


GO
