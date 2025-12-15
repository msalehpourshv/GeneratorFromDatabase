USE TS_ShirinVatanKarkhaneh_1_1404
GO
SET ANSI_NULLS, QUOTED_IDENTIFIER ON
GO
-- =========== TS-QC:UPDATED ====================
-- Author		 : TakroSystem\Ahmadnejad
-- Create date   : 1388/03/05
-- Viewed By	 : 
-- Last Modified : 
-- Last Modifier : 
-- Description	 : Filter Select Result By Permission
-- ===============================================
CREATE PROCEDURE [pub].[SpFilterByPermission]
	@TableName		VarChar(50),
	@FieldName		VarChar(50),
	@RngTableName	VarChar(50),
	@UserID			Int
WITH ENCRYPTION	
AS
DECLARE @StrSql	NVarChar(2000)

DECLARE @Part1Start	TinyInt;
DECLARE @Part2Start TinyInt;
DECLARE @Part3Start	TinyInt;
DECLARE @Part4Start	TinyInt;
DECLARE @Part1Len	TinyInt;
DECLARE @Part2Len	TinyInt;
DECLARE @Part3Len	TinyInt;
DECLARE @Part4Len	TinyInt;
DECLARE @IncludePart Bit;
Begin

	IF (@RngTableName = 'acc.tblAcnt')
		SET @IncludePart = 1;
	ELSE
		SET @IncludePart = 0

	SELECT	@Part1Start = 1;
	SELECT	@Part1Len = Layer1 + Layer2 + Layer3 + Layer4 + Layer5 + Layer6 + Layer7 + Layer8 + Layer9 
	FROM	pub.tblCodeLayer 
	WHERE	(TableName = @RngTableName) AND (PartNumber = 1)

	IF (@IncludePart = 1)
	BEGIN
		SELECT	@Part2Start = @Part1Start + @Part1Len + 1;
		SELECT	@Part2Len = Layer1 + Layer2 + Layer3 + Layer4 + Layer5 + Layer6 + Layer7 + Layer8 + Layer9 
		FROM	pub.tblCodeLayer 
		WHERE	(TableName = @RngTableName) AND (PartNumber = 2)

		SELECT	@Part3Start = @Part2Start + @Part2Len + 1;
		SELECT	@Part3Len = Layer1 + Layer2 + Layer3 + Layer4 + Layer5 + Layer6 + Layer7 + Layer8 + Layer9 
		FROM	pub.tblCodeLayer 
		WHERE	(TableName = @RngTableName) AND (PartNumber = 3)

		SELECT	@Part4Start = @Part3Start + @Part3Len + 1;
		SELECT	@Part4Len = Layer1 + Layer2 + Layer3 + Layer4 + Layer5 + Layer6 + Layer7 + Layer8 + Layer9 
		FROM	pub.tblCodeLayer 
		WHERE	(TableName = @RngTableName) AND (PartNumber = 4)
	END
	ELSE
	BEGIN
		SET @Part2Start = 0;
		SET @Part3Start = 0;
		SET @Part4Start = 0;

		SET @Part2Len = 0;
		SET @Part3Len = 0;
		SET @Part4Len = 0;
	END;

	SET @RngTableName = @RngTableName + 'Rng'

	SET @StrSql = '
		DELETE 
		FROM  ' + @TableName  + '
		WHERE 
		(
			SELECT	COUNT(*) 
			FROM	' + @RngTableName + ' R 
			WHERE	UserID = ' + LTrim(Str(@UserID)) + ' AND ' +
					CASE WHEN (@IncludePart = 1) THEN '(R.PartNumber = 1) AND ' ELSE '' END + '
					R.AccessAllCode = 1 OR
					(	
						R.AllowCodeView = 1 AND 
						Substring(' + @FieldName + ', ' + Str(@Part1Start) + ', LEN(R.FromCode)) >= R.FromCode AND
						Substring(' + @FieldName + ', ' + Str(@Part1Start) + ', LEN(R.ToCode  )) <= R.ToCode
					)
		) = 0 '
	PRINT @StrSql;
	EXEC sp_executesql @StrSql;

	IF (@IncludePart = 1)
	BEGIN
		IF (@Part2Len > 0)	
		BEGIN
			SET @StrSql = '
				DELETE 
				FROM  ' + @TableName  + '
				WHERE 
				(
					SELECT	COUNT(*) 
					FROM	' + @RngTableName + ' R 
					WHERE	UserID = ' + LTrim(Str(@UserID)) + ' AND R.PartNumber = 2 AND
							R.AccessAllCode = 1 OR
							(	
								AllowCodeView = 1 AND 
								Substring(' + @FieldName + ', ' + Str(@Part2Start) + ', LEN(FromCode)) >= FromCode AND
								Substring(' + @FieldName + ', ' + Str(@Part2Start) + ', LEN(ToCode  )) <= ToCode
							)
				) = 0 '
			PRINT @StrSql;
			EXEC sp_executesql @StrSql;
		END

		IF (@Part3Len > 0)	
		BEGIN
			SET @StrSql = '
				DELETE 
				FROM  ' + @TableName  + '
				WHERE 
				(
					SELECT	COUNT(*) 
					FROM	' + @RngTableName + ' R 
					WHERE	UserID = ' + LTrim(Str(@UserID)) + ' AND R.PartNumber = 3 AND
							R.AccessAllCode = 1 OR
							(	
								AllowCodeView = 1 AND 
								Substring(' + @FieldName + ', ' + Str(@Part3Start) + ', LEN(FromCode)) >= FromCode AND
								Substring(' + @FieldName + ', ' + Str(@Part3Start) + ', LEN(ToCode  )) <= ToCode
							)
				) = 0 '
			PRINT @StrSql;
			EXEC sp_executesql @StrSql;
		END;

		IF (@Part4Len > 0)	
		BEGIN
			SET @StrSql = '
				DELETE 
				FROM  ' + @TableName  + '
				WHERE 
				(
					SELECT	COUNT(*) 
					FROM	' + @RngTableName + ' R 
					WHERE	UserID = ' + LTrim(Str(@UserID)) + ' AND R.PartNumber = 3 AND
							R.AccessAllCode = 1 OR
							(	
								AllowCodeView = 1 AND 
								Substring(' + @FieldName + ', ' + Str(@Part4Start) + ', LEN(FromCode)) >= FromCode AND
								Substring(' + @FieldName + ', ' + Str(@Part4Start) + ', LEN(ToCode  )) <= ToCode
							)
				) = 0 '
			PRINT @StrSql;
			EXEC sp_executesql @StrSql;
		END;
	END;

	SET @StrSql = '
		SELECT	*
		FROM	' + @TableName;

	EXEC sp_executesql @StrSql;
End
GO
