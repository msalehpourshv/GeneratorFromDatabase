USE TS_ShirinVatanKarkhaneh_1_1404
GO
SET ANSI_NULLS, QUOTED_IDENTIFIER ON
GO
-- =============================================
-- Author:		jafari
-- Create date: 1396/03/17
-- Description:	
-- اجازه دسترسی به کد 
-- =============================================
Create FUNCTION [acc].[funAllowAcntCode] 
(
	@UserID AS Int, 
	 @UserIsAdmin	BIT,
	@AcntCode AS VarChar(20), 
	@Part AS TinyInt
)
RETURNS Bit
WITH ENCRYPTION
AS
BEGIN

Declare @LimitState1	SmallInt;
Declare @LimitState2	SmallInt;
Declare @LimitState3	SmallInt;
Declare @LimitState4	SmallInt;
Declare @Part1Start	TinyInt;
Declare @Part1Len	TinyInt;

Declare @Part2Start	TinyInt;
Declare @Part2Len	TinyInt;

Declare @Part3Start	TinyInt;
Declare @Part3Len	TinyInt;

Declare @Part4Start	TinyInt;
Declare @Part4Len	TinyInt;


	If (@AcntCode = '')
		Return 1

	
	Declare @Result AS Bit
	
If @UserIsAdmin = 1
	Begin
		SET	@LimitState1 = 1
		SET	@LimitState2 = 1
		SET	@LimitState3 = 1
		SET	@LimitState4 = 1
	End
	Else
	Begin
		SELECT	TOP 1 @LimitState1 = AccessAllCode
		FROM	acc.tblAcntRng
		WHERE	(UserID = @UserID) AND (PartNumber = 1)

		SET @LimitState1 = IsNull(@LimitState1, -1);

		SELECT	TOP 1 @LimitState2 = AccessAllCode
		FROM	acc.tblAcntRng
		WHERE	(UserID = @UserID) AND (PartNumber = 2)

		SET @LimitState2 = IsNull(@LimitState2, -1);

		SELECT	TOP 1 @LimitState3 = AccessAllCode
		FROM	acc.tblAcntRng
		WHERE	(UserID = @UserID) AND (PartNumber = 3)

		SET @LimitState3 = IsNull(@LimitState3, -1);

		SELECT	TOP 1 @LimitState4 = AccessAllCode
		FROM	acc.tblAcntRng
		WHERE	(UserID = @UserID) AND (PartNumber = 4)

		SET @LimitState4 = IsNull(@LimitState4, -1);
	End

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

	
Select @Result=  case when 
( (@UserIsAdmin = 1 OR @LimitState1 = -1 OR Substring(@AcntCode, @Part1Start, @Part1Len) IN (Select Substring(@AcntCode, @Part1Start, @Part1Len) From acc.tblAcnt Where PartNumber = 1 And (@LimitState1 = 1 OR (acc.funPermitted(@UserID, Substring(@AcntCode, @Part1Start, @Part1Len), 1) = 1)))) AND
(@UserIsAdmin = 1 OR @LimitState2 = -1 OR Substring(@AcntCode, @Part2Start, @Part2Len) IN 
(Select Substring(@AcntCode, @Part2Start, @Part2Len) From acc.tblAcnt Where PartNumber = 2 And (@LimitState2 = 1 OR (acc.funPermitted(@UserID, Substring(@AcntCode, @Part2Start, @Part2Len), 2) = 1)))) AND
(@UserIsAdmin = 1 OR @LimitState3 = -1 OR Substring(@AcntCode, @Part3Start, @Part3Len) IN 
(Select Substring(@AcntCode, @Part3Start, @Part3Len) From acc.tblAcnt Where PartNumber = 3 And (@LimitState3 = 1 OR (acc.funPermitted(@UserID, Substring(@AcntCode, @Part3Start, @Part3Len), 3) = 1)))) AND
(@UserIsAdmin = 1 OR @LimitState4 = -1 OR Substring(@AcntCode, @Part4Start, @Part4Len) 
IN (Select  Substring(@AcntCode, @Part4Start, @Part4Len) From acc.tblAcnt Where PartNumber = 4 And (@LimitState4 = 1 OR (acc.funPermitted(@UserID,  Substring(@AcntCode, @Part4Start, @Part4Len), 4) = 1)))))

then 1 else 0 end 

RETURN @Result
END
GO
