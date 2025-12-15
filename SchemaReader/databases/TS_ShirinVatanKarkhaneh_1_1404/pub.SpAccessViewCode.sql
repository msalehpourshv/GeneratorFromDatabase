USE TS_ShirinVatanKarkhaneh_1_1404
GO
SET ANSI_NULLS, QUOTED_IDENTIFIER ON
GO
-- =========== TS-QC:OK ========================
-- Author        : Hadi Sadeghi
-- Create date   : 1387/02/17
-- Viewed By	 : 
-- Last Modified : 
-- Description   : 
-- ============================================
CREATE PROCEDURE [pub].[SpAccessViewCode] 
(@StrCode				VarChar(20),
 @StrTableName			NVarChar(50),
 @UserID				Int,
 @Acnt1CurrentLayerSum	Tinyint)
 WITH ENCRYPTION
As 

	DECLARE @SQLString NVarChar(4000);

	SET @SQLString= 
		  N'SELECT COUNT(UserID) 
			FROM ' + @StrTableName + 'Rng R
			WHERE (R.UserID =' + ltrim(str(@UserID)) + ') AND 
				  (R.AllowCodeView = 1) AND '

	SET @SQLString= @SQLString + 
		N'(LEFT(''' + @StrCode + ''',LEN(ToCode)) <= 
		   LEFT(ToCode, LEN(ToCode))) AND 
		   LEFT(''' + @StrCode + ''',LEN(FromCode)) >= 
		   LEFT(FromCode, LEN(FromCode))'

	PRINT @SQLString
	EXECUTE sp_executesql @SQLString
GO
