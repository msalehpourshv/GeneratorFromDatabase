USE TS_ShirinVatanKarkhaneh_1_1404
GO
SET ANSI_NULLS, QUOTED_IDENTIFIER ON
GO
-- =========== TS-QC:UPDATED ====================
-- Author		 : TakroSystem\Ahmadnejad
-- Create Date   : 1387/10/26
-- Viewed By	 : 
-- Last ModIFied : 
-- Last ModIFier : 
-- Description	 : لیست کدهای انتخابی
-- ==============================================
CREATE PROCEDURE [pub].[SpSlcCodes]
	@CodeTable	VarChar(50),
	@MainTable	VarChar(50),
	@CodeField	VarChar(50),
	@NameField	VarChar(50),
	@LevelLens	VarChar(100),
	@IsAcntCode Bit = 0
	WITH ENCRYPTION
AS 
DECLARE @LanguageID VarChar(3);
DECLARE @StrSelect	NVarChar(4000);
DECLARE @StrCode	VarChar(20);
DECLARE @StrNewCode	VarChar(20);
DECLARE @StrLen		VarChar(2);
DECLARE @Idx		Int;
DECLARE @IdxLevel	Int;
DECLARE @LevelCount	Int;
DECLARE @IntLen		Int;
DECLARE @IdxRow		Int;
DECLARE @RowCount	Int;

BEGIN 
	--============== S T A R T  C O D E =======================================

	SET NOCOUNT ON;

	---- Init ------------------------------------------
	DECLARE @tblLevels AS TABLE 
	(
		ID		TinyInt,
		[Len]	TinyInt
	);
	CREATE TABLE #tblCodes
	(
		Code VarChar(20) COLLATE Arabic_CS_AS
	);
	SET @LanguageID = Cast(pub.funGetCurrentLanguageID() AS VarChar(3));
	SET @LevelCount = 20
	----------------------------------------------------

	SET @Idx = 1;

	While (@Idx <= @LevelCount)
	BEGIN
		SET @StrLen = pub.funSplitString(@LevelLens, ',', @Idx)

		INSERT INTO @tblLevels(ID, [Len])
		VALUES (@Idx, CAST(@StrLen AS TinyInt))

		SET @Idx = @Idx + 1
	END

	-- Collect Codes
    SET @StrSelect = '
		INSERT INTO #tblCodes(Code)
        SELECT DISTINCT ' + @CodeField + '
        FROM ' + @MainTable  

	PRINT @StrSelect;
	EXEC sp_executesql @StrSelect;

    -- find parent code for any code & add it to list
	SET @IdxLevel = 1;

	WHILE (@IdxLevel < @LevelCount)
	BEGIN
	
		SELECT	@IntLen = [Len]
		FROM	@tblLevels
		WHERE	ID = @IdxLevel

        IF (@IntLen = 0)
		Begin
			SET @IdxLevel = @IdxLevel + 1
            CONTINUE
		End

		SELECT @RowCount = COUNT(*)
		FROM #tblCodes

		DECLARE CSR CURSOR FOR
			SELECT *
			FROM #tblCodes

		OPEN CSR
		FETCH NEXT FROM CSR INTO @StrCode

		SET @IdxRow = 1
		
		WHILE (@IdxRow <= @RowCount)
		BEGIN
			SET @StrCode = LTrim(RTrim(@StrCode))

			IF (LEN(@StrCode) > @IntLen)
			BEGIN
				-- generate parent 
				SET @StrNewCode = Substring(@StrCode, 1, @IntLen)

				-- add to same table (IF not duplicate)
				IF (SELECT COUNT(*) FROM #tblCodes WHERE Code = @StrNewCode) = 0
					INSERT INTO #tblCodes
					VALUES (@StrNewCode)
			END
		
			FETCH NEXT FROM CSR INTO @StrCode
			SET @IdxRow = @IdxRow + 1
		END

		CLOSE CSR
		DEALLOCATE CSR

		SET @IdxLevel = @IdxLevel + 1
	END

	--------------------

    IF (@IsAcntCode = 1) 
	BEGIN
        SET @StrSelect = '
            SELECT Code AS ' + @CodeField + ', pub.GetCodeName(Code, ' + @LanguageID + ') AS ' + @NameField + '
            FROM #tblCodes
            ORDER BY ' + @CodeField
	END
    Else
	BEGIN
        SET @StrSelect = '
            SELECT T.Code AS ' + @CodeField + ', C.' + @NameField + '
            FROM 
            ( 
                SELECT Code
                FROM #tblCodes
            ) T INNER JOIN ' + @CodeTable + ' C ON C.' + @CodeField + ' = T.Code
            WHERE (C.LanguageID = ' + @LanguageID + ')
            ORDER BY ' + @CodeField
    END

--	PRINT @StrSelect;
	EXEC sp_executesql @StrSelect;
END
GO
