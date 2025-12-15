USE TS_ShirinVatanKarkhaneh_1_1404
GO
SET ANSI_NULLS, QUOTED_IDENTIFIER ON
GO
Create FUNCTION [acc].[FunGetAcntCodeForRemain]
(
	@AcntCode AS VarChar(20)
	
)
RETURNS Varchar(20)
WITH ENCRYPTION
AS
BEGIN

DECLARE @Result AS Varchar(20)
Declare @Part1Start	TinyInt;
Declare @Part1Len	TinyInt;

Declare @Part2Start	TinyInt;
Declare @Part2Len	TinyInt;

Declare @Part3Start	TinyInt;
Declare @Part3Len	TinyInt;

Declare @Part4Start	TinyInt;
Declare @Part4Len	TinyInt;



		-------- LAYERS LEN CLAUSE -----------------------------------------------------------------------
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

	-----------------------------
	
	Declare @CustomerPartNo AS Tinyint
	SET @CustomerPartNo = 0
	
	SELECT @CustomerPartNo = SettingValue
	FROM pub.tblSettings
	WHERE SettingKey = 'AcntPartNumberForRemainCalculation'

	Declare @CustomerPartStart	TinyInt;
	Declare @CustomePartLen		TinyInt;
		
	---- CALC LEN ----
	If (@CustomerPartNo=1)
	begin
		set @CustomerPartStart  = @Part1Start
		set @CustomePartLen		= @Part1Len		
	end	
	Else If (@CustomerPartNo=2)
	begin
		set @CustomerPartStart  = @Part2Start
		set @CustomePartLen		= @Part2Len
	end
	Else If (@CustomerPartNo=3)
	begin
		set @CustomerPartStart  = @Part3Start
		set @CustomePartLen		= @Part3Len
	end
	Else If (@CustomerPartNo=4)
	begin
		set @CustomerPartStart  = @Part4Start
		set @CustomePartLen		= @Part4Len
	end
	set @Result=Substring(@AcntCode,@CustomerPartStart,@CustomePartLen)
	
	
RETURN isnull(@Result,'')

END
GO
