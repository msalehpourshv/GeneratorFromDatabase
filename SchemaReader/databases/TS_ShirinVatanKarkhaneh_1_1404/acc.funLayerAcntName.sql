USE TS_ShirinVatanKarkhaneh_1_1404
GO
SET ANSI_NULLS, QUOTED_IDENTIFIER ON
GO
-- =========== TS-QC:UPDATED ====================
-- Author		 : TakroSystem\Ahmadnejad
-- Create date   : 1389/03/30
-- Viewed By	 : 
-- Last Modified : 
-- Last Modifier : 
-- Description	 : 
-- ==============================================
CREATE FUNCTION [acc].[funLayerAcntName]
(
	@FullCode	VarChar(20),
	@PartNo		int,
	@Layer		int
)
RETURNS NVarChar(250)
WITH ENCRYPTION
AS
BEGIN
	DECLARE @Result AS NVarChar(250);
	DECLARE @Start	AS int;
	DECLARE @Len	AS int;

	DECLARE @Part1Start	AS int;
	DECLARE @Part2Start	AS int;
	DECLARE @Part3Start	AS int;
	DECLARE @Part4Start	AS int;
	DECLARE @Part1Len	AS int;
	DECLARE @Part2Len	AS int;
	DECLARE @Part3Len	AS int;
	DECLARE @Part4Len	AS int;

	SELECT	@Part1Start = 1;
	SELECT	@Part1Len = Layer1 + Layer2 + Layer3 + Layer4 + Layer5 + Layer6 + Layer7 + Layer8 + Layer9 
	FROM	pub.tblCodeLayer 
	WHERE	(TableName = 'acc.tblAcnt') AND (PartNumber = 1)

	SELECT	@Part2Start = @Part1Start + @Part1Len + 1;
	SELECT	@Part2Len = Layer1 + Layer2 + Layer3 + Layer4 + Layer5 + Layer6 + Layer7 + Layer8 + Layer9 
	FROM	pub.tblCodeLayer 
	WHERE	(TableName = 'acc.tblAcnt') AND (PartNumber = 2)

	SELECT	@Part3Start = @Part2Start + @Part2Len + 1;
	SELECT	@Part3Len = Layer1 + Layer2 + Layer3 + Layer4 + Layer5 + Layer6 + Layer7 + Layer8 + Layer9 
	FROM	pub.tblCodeLayer 
	WHERE	(TableName = 'acc.tblAcnt') AND (PartNumber = 3)

	SELECT	@Part4Start = @Part3Start + @Part3Len + 1;
	SELECT	@Part4Len = Layer1 + Layer2 + Layer3 + Layer4 + Layer5 + Layer6 + Layer7 + Layer8 + Layer9 
	FROM	pub.tblCodeLayer 
	WHERE	(TableName = 'acc.tblAcnt') AND (PartNumber = 4)
	-------------------------------------------------------------

	if (@Layer = 1)
		SELECT	@Len = Layer1
		FROM	pub.tblCodeLayer 
		WHERE	(TableName = 'acc.tblAcnt') AND (PartNumber = @PartNo)
	if (@Layer = 2)
		SELECT	@Len = Layer1 + Layer2
		FROM	pub.tblCodeLayer 
		WHERE	(TableName = 'acc.tblAcnt') AND (PartNumber = @PartNo)
	if (@Layer = 3)
		SELECT	@Len = Layer1 + Layer2 + Layer3
		FROM	pub.tblCodeLayer 
		WHERE	(TableName = 'acc.tblAcnt') AND (PartNumber = @PartNo)
	if (@Layer = 4)
		SELECT	@Len = Layer1 + Layer2 + Layer3 + Layer4
		FROM	pub.tblCodeLayer 
		WHERE	(TableName = 'acc.tblAcnt') AND (PartNumber = @PartNo)
	if (@Layer = 5)
		SELECT	@Len = Layer1 + Layer2 + Layer3 + Layer4 + Layer5
		FROM	pub.tblCodeLayer 
		WHERE	(TableName = 'acc.tblAcnt') AND (PartNumber = @PartNo)
	if (@Layer = 6)
		SELECT	@Len = Layer1 + Layer2 + Layer3 + Layer4 + Layer5 + Layer6
		FROM	pub.tblCodeLayer 
		WHERE	(TableName = 'acc.tblAcnt') AND (PartNumber = @PartNo)
	if (@Layer = 7)
		SELECT	@Len = Layer1 + Layer2 + Layer3 + Layer4 + Layer5 + Layer6 + Layer7
		FROM	pub.tblCodeLayer 
		WHERE	(TableName = 'acc.tblAcnt') AND (PartNumber = @PartNo)
	if (@Layer = 8)
		SELECT	@Len = Layer1 + Layer2 + Layer3 + Layer4 + Layer5 + Layer6 + Layer7 + Layer8
		FROM	pub.tblCodeLayer 
		WHERE	(TableName = 'acc.tblAcnt') AND (PartNumber = @PartNo)
	if (@Layer = 9)
		SELECT	@Len = Layer1 + Layer2 + Layer3 + Layer4 + Layer5 + Layer6 + Layer7 + Layer8 + Layer9 
		FROM	pub.tblCodeLayer 
		WHERE	(TableName = 'acc.tblAcnt') AND (PartNumber = @PartNo)

	set @Start	= @Part1Start
	set @Len	= @Len

	if (@PartNo = 2)
		set @Start	= @Part2Start

	if (@PartNo = 3)
		set @Start	= @Part3Start

	if (@PartNo = 4)
		set @Start	= @Part4Start

	SELECT	@Result = AcntName
	FROM	acc.tblAcntDtl
	WHERE	AcntCode = Substring(@FullCode, @Start, @Len) AND PartNumber = @PartNo AND LanguageID = 1

	RETURN @Result
END
GO
