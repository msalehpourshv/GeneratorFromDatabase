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
-- Description	 :  لیست کدهای انتخابی جدید + Parented
-- ==============================================
CREATE PROCEDURE [pub].[SpSlcCodesEx]
		@CodeTable	VarChar(50),
		@CodeField	VarChar(50),
		@NameField	VarChar(50),
		@PartNo		VarChar(3),
		@LevelLens	VarChar(100),
		@UserID   VarChar(3),
		@AccessAllCodes bit,
		@RngTable nVarChar(200),
		@CloseCodes bit=1,
		@CodeTableHdr	VarChar(50)=null
WITH ENCRYPTION
AS 
DECLARE @StrSelect	NVarChar(4000);
DECLARE @StrLen		VarChar(2);
DECLARE @Idx		Int;
DECLARE @IdxLevel	Int;
DECLARE @LevelCount	Int;
DECLARE @IntLen		Int;

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
        SELECT DISTINCT (' + @CodeField + ')
        FROM ' + @CodeTable+ ' H ';
        
SET @StrSelect = @StrSelect + ' WHERE 1 = 1 ';

IF (@CloseCodes =0)
		
		SET @StrSelect = @StrSelect + ' And ' + @CodeField + ' Not In (Select ' + @CodeField + ' From '+ @CodeTableHdr+' Where CodeClosed = ''True'')';

	IF (@PartNo > 0)
		begin 
			SET @StrSelect = @StrSelect + ' And PartNumber = ' + @PartNo;
	
			 if (@AccessAllCodes=0)
					begin
					 SET @StrSelect = @StrSelect +' AND  
						((SELECT COUNT(*) FROM '+ @RngTable +' AS R 		             
						  WHERE R.UserID = '+  @UserID +' AND R.PartNumber = ' + @PartNo + ' AND (AllowCodeView = 1) 
						  AND (LEFT(H.' + @CodeField + ', LEN(FromCode)) >= FromCode) 
						  AND (LEFT(H.' + @CodeField + ', LEN(ToCode)) <= ToCode)) > 0)'
					end
		end
	else
		begin
			if (@AccessAllCodes=0)
				begin
					SET @StrSelect = @StrSelect +' AND   
					((SELECT COUNT(*)  FROM   '+ @RngTable +' AS R 	             
					WHERE R.UserID ='+  @UserID +'  AND (AllowCodeView = 1) 
					AND (LEFT(H.'+@CodeField+', LEN(FromCode)) >= FromCode) 
					AND (LEFT(H.'+@CodeField+', LEN(ToCode)) <= ToCode)) > 0)'
				end
		end
	PRINT @StrSelect;
	EXEC sp_executesql @StrSelect;
	
	--select * from #tblCodes
    -- find parent code for any code & add it to list
	SET @IdxLevel = 1;

	WHILE (@IdxLevel < @LevelCount)
	BEGIN
		SELECT	@IntLen = [Len]
		FROM	@tblLevels
		WHERE	ID = @IdxLevel

		INSERT INTO #tblCodes
		SELECT DISTINCT SUBSTRING(Code,1,@IntLen)
		FROM #tblCodes
		EXCEPT 
		SELECT Code
		FROM #tblCodes

		SET @IdxLevel = @IdxLevel + 1
	END

	----------------------

    IF (@PartNo > 0) -- AcntCode
	BEGIN
        SET @StrSelect = '
            SELECT Code AS ' + @CodeField + ', acc.funGetAcntName(Code, ' + @PartNo + ', 1) AS ' + @NameField + ',LEN(Code) LN
            FROM #tblCodes '                   
	END
    Else
	BEGIN
        SET @StrSelect = '
            SELECT DISTINCT T.Code AS ' + @CodeField + ', C.' + @NameField + '
            FROM 
            ( 
                SELECT Code
                FROM #tblCodes
            ) T INNER JOIN ' + @CodeTable + ' C ON C.' + @CodeField + ' = T.Code '
			if @CodeTable='inv.tblGoodsDtl'
				    SET @StrSelect = @StrSelect + ' where   PartNumber = 1 ';

    END

  SET @StrSelect = @StrSelect+' ORDER BY ' + @CodeField
	PRINT @StrSelect;
	EXEC sp_executesql @StrSelect;
END
GO
