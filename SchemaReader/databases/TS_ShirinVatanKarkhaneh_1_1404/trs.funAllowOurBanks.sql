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
Create FUNCTION [trs].[funAllowOurBanks] 
(	@UserID AS Int, 
	@UserIsAdmin	BIT,
	@BankCode AS VarChar(20)
)
RETURNS Bit
WITH ENCRYPTION
AS
BEGIN

Declare @LimitState1	SmallInt;
Declare @Part1Start	TinyInt;
Declare @Part1Len	TinyInt;


	If (@BankCode = '')
		Return 1
	
	Declare @Result AS Bit
	
If @UserIsAdmin = 1
	Begin
		SET	@LimitState1 = 1
	End
	Else
	Begin
		SELECT	TOP 1 @LimitState1 = AccessAllCode
		FROM	trs.tblOurBanksRng
		WHERE	(UserID = @UserID) 

		SET @LimitState1 = IsNull(@LimitState1, -1);
	End

	-------- LAYERS LEN CLAUSE -----------------------------------------------------------------------
	SELECT	@Part1Start = 1;
	SELECT	@Part1Len = Layer1 + Layer2 + Layer3 + Layer4 + Layer5 + Layer6 + Layer7 + Layer8 + Layer9 
	FROM	pub.tblCodeLayer 
	WHERE	(TableName = 'trs.tblOurBanks') AND (PartNumber = 1)
Declare @BankCodePart Varchar(20)

	set @BankCodePart =Substring(@BankCode, @Part1Start, @Part1Len) 
Select @Result=  case when 
 (@UserIsAdmin = 1 OR @LimitState1 = -1 
 OR @BankCodePart 
 IN (Select @BankCodePart From trs.tblOurBanks
 Where (@LimitState1 = 1 OR 
 (	(SELECT	IsNull(COUNT(*), 0)
	FROM	  trs.tblOurBanksRng
	WHERE	(UserID = @UserID) AND (AllowCodeView = 1) AND
			(LEFT(@BankCodePart, LEN(ToCode)) >= FromCode) AND 
			(LEFT(@BankCodePart, LEN(ToCode)) <= ToCode)) >= 1)
 
 ))) 


then 1 else 0 end 

RETURN @Result
END
GO
