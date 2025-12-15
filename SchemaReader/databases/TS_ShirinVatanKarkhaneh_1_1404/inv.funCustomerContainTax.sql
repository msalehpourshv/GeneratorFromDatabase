USE TS_ShirinVatanKarkhaneh_1_1404
GO
SET ANSI_NULLS, QUOTED_IDENTIFIER ON
GO
CREATE FUNCTION [inv].[funCustomerContainTax]
(
	@AcntCode	Varchar(20)
)

RETURNS BIT
WITH ENCRYPTION
AS
BEGIN
	--========================
	Declare @CustomerPartNo			Tinyint
	DECLARE @CustomerPartStart		Int;
	DECLARE @CustomerPartLayerLen	Int;

	DECLARE @Part1Start		Int;
	DECLARE @Part1End		Int;
	DECLARE @Part2Start		Int;
	DECLARE @Part2End		Int;
	DECLARE @Part3Start		Int;
	DECLARE @Part3End		Int;
	DECLARE @Part4Start		Int;
	DECLARE @Part4End		Int;
	
	DECLARE @Part1Len		TinyInt;
	DECLARE @Part2Len		TinyInt;
	DECLARE @Part3Len		TinyInt;
	DECLARE @Part4Len		TinyInt;
	
	DECLARE @LayerLen		int;

	--========================
	If @Part1Start Is Null SET @Part1Start = 0
	If @Part2Start Is Null SET @Part2Start = 0
	If @Part3Start Is Null SET @Part3Start = 0
	If @Part4Start Is Null SET @Part4Start = 0

	--========================
	SET		@Part1Start = 1;
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
			
	--========================
	SET @CustomerPartNo = 0
	
	SELECT @CustomerPartNo = SettingValue
	FROM pub.tblSettings
	WHERE SettingKey = 'AcntPartNumberForRemainCalculation'
	
	/** ====== Prepare SELECT Section ============= ***/
	if @CustomerPartNo = 1
	Begin
		Set @CustomerPartStart	  = @Part1Start
		Set @CustomerPartLayerLen = @Part1Len
	End
	Else if @CustomerPartNo = 2
	Begin
		Set @CustomerPartStart	  = @Part2Start
		Set @CustomerPartLayerLen = @Part2Len
	End
	Else if @CustomerPartNo = 3
	Begin
		Set @CustomerPartStart    = @Part3Start
		Set @CustomerPartLayerLen = @Part3Len
	End
	Else if @CustomerPartNo = 4
	Begin
		Set @CustomerPartStart    = @Part4Start
		Set @CustomerPartLayerLen = @Part4Len
	End
		
	--========================
	DECLARE @Result Bit;
	SET @Result = 0;

	--========================
	Select @Result = ContainTax 
	From acc.tblAcnt
	Where AcntCode = SUBSTRING(@AcntCode, @CustomerPartStart, @CustomerPartLayerLen)

	RETURN @Result

END
GO
