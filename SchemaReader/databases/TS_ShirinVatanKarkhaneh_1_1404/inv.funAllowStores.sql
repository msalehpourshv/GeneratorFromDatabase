USE TS_ShirinVatanKarkhaneh_1_1404
GO
SET ANSI_NULLS, QUOTED_IDENTIFIER ON
GO
--use TS_ArmanGholdasht_1_1396
-- =============================================
-- Author:		jafari
-- Create date: 1396/03/17
-- Description:	
-- اجازه دسترسی به کد 
-- =============================================
Create FUNCTION [inv].[funAllowStores] 
(
	@UserID AS Int, 
	@UserIsAdmin	BIT,
	@StorID AS VarChar(20)
)
RETURNS Bit
WITH ENCRYPTION
AS
BEGIN

Declare @LimitState1	SmallInt;
Declare @Part1Start	TinyInt;
Declare @Part1Len	TinyInt;


	If (@StorID = '')
		Return 1
	
	Declare @Result AS Bit
	
If @UserIsAdmin = 1
	Begin
		SET	@LimitState1 = 1
	End
	Else
	Begin
		SELECT	TOP 1 @LimitState1 = AccessAllCode
		FROM	inv.tblStoresRng
		WHERE	(UserID = @UserID) 

		SET @LimitState1 = IsNull(@LimitState1, -1);
	End

	-------- LAYERS LEN CLAUSE -----------------------------------------------------------------------
	SELECT	@Part1Start = 1;
	SELECT	@Part1Len = Layer1 + Layer2 + Layer3 + Layer4 + Layer5 + Layer6 + Layer7 + Layer8 + Layer9 
	FROM	pub.tblCodeLayer 
	WHERE	(TableName = 'inv.tblStores') AND (PartNumber = 1)
Declare @StorIDPart Varchar(20)

	set @StorIDPart =Substring(@StorID, @Part1Start, @Part1Len) 
Select @Result=  case when 
 (@UserIsAdmin = 1 OR @LimitState1 = -1 
 OR @StorIDPart 
 IN (Select @StorIDPart From inv.tblStores 
 Where (@LimitState1 = 1 OR 

 (
( SELECT	IsNull(COUNT(*), 0)
	FROM	  inv.tblStoresRng
	WHERE	(UserID = @UserID) AND (AllowCodeView = 1) AND
			(LEFT(@StorIDPart, LEN(ToCode)) >= FromCode) AND 
			(LEFT(@StorIDPart, LEN(ToCode)) <= ToCode) )>=1)
 ))) 


then 1 else 0 end 

RETURN @Result
END
GO
