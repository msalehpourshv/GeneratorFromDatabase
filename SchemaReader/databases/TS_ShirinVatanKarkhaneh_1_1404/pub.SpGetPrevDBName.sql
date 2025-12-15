USE TS_ShirinVatanKarkhaneh_1_1404
GO
SET ANSI_NULLS, QUOTED_IDENTIFIER ON
GO
-- =========== TS-QC:UPDATED ====================
-- Author		 : Ahmadnejad
-- Create date   : 1386/12/18
-- Viewed By	 : 
-- Last Modified : 
-- Description	 : نام پایگاه داده سال مالی قبل را برمی گرداند
-- ==============================================
CREATE PROCEDURE [pub].[SpGetPrevDBName]
	@StrCurrDBName AS VarChar(50),
	@StrPrevDBName AS VarChar(50) OUTPUT
WITH ENCRYPTION
AS 

DECLARE @StrSQL		AS NVarChar(1000);
DECLARE @StrParams	AS NVarChar(1000);

DECLARE	@IntFY		Int
DECLARE	@IntFYPrev	Int;

DECLARE	@IntPos		TinyInt;
DECLARE	@IntPosPrev	TinyInt;

BEGIN

	SET @IntPos = 0;
	SET @IntPosPrev = 1;

	While (1 = 1)
	Begin
		SET @IntPos = CharIndex('_', @StrCurrDBName, @IntPos + 1)

		If (@IntPos = 0)
		Begin
			SET @IntFY = Cast(Substring(@StrCurrDBName, @IntPosPrev + 1, Len(@StrCurrDBName) - @IntPosPrev) AS Int)
			Break
		End

		SET @IntPosPrev = @IntPos;
	End

	SET @StrSQL	= N'
		SELECT	@StrFYPrev = PrevFiscalYear
		FROM	[' + Left(@StrCurrDBName, @IntPosPrev)+ '0000].[pub].[tblFiscalYears]
		WHERE	FiscalYear = ' + LTrim(Str(@IntFY))

	SET @StrParams = N'@StrFYPrev NVarChar(100) OUTPUT';
	EXEC sp_executesql @StrSQL, @StrParams, @IntFYPrev OUTPUT;

	If (@IntFYPrev Is Null)
		SET @StrPrevDBName = ''
	Else
	Begin
		SET @StrPrevDBName = Left(@StrCurrDBName, @IntPosPrev) + LTrim(Str(@IntFYPrev))

		If (SELECT	[name]
			FROM	sys.databases
			WHERE	(state = 0) AND ([name] = @StrPrevDBName)) Is Null	

			SET @StrPrevDBName = ''
	End
END


GO
