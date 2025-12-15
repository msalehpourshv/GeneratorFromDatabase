USE TS_ShirinVatanKarkhaneh_1_1404
GO
SET ANSI_NULLS, QUOTED_IDENTIFIER ON
GO
-- =============================================
-- Author:H.Sadeghi
-- Create date: 1400/07/07
-- Description:	
-- چک می کند که آیا کاربر جاری به کد داده شده پرسنل مجوز دسترسی (مشاهده) دارد یا نه؟
-- =============================================

CREATE FUNCTION [prs].[funPersonnelPermitted] 
(
	@UserID AS Int, 
	@Code AS VarChar(20)
)
RETURNS Bit
WITH ENCRYPTION
AS
BEGIN
	
	If @Code = ''
		Return 1

	Declare @Count AS Int=0
	Declare @Result AS Bit
			
	SELECT	TOP 1 @Count = UserID
	FROM	prs.tblPersonnelsRng
	WHERE	(UserID = @UserID) AND (AllowCodeView = 1 OR AccessAllCode=1) AND
			(LEFT(@Code, LEN(ToCode)) >= FromCode) AND 
			(LEFT(@Code, LEN(ToCode)) <= ToCode) 
			
	If (@Count > 0)
		Set @Result = 1
	Else
		Set @Result = 0

	RETURN @Result
END
GO
