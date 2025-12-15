USE TS_ShirinVatanKarkhaneh_1_1404
GO
SET ANSI_NULLS, QUOTED_IDENTIFIER ON
GO
-- =============================================
-- Author:		Hadi Sadeghi
-- Create date: 2016/09/20
-- Description:	
-- چک می کند که آیا کاربر جاری به کد داده شده مجوز دسترسی (مشاهده) دارد یا نه؟
-- =============================================
CREATE FUNCTION [srv].[funServiceKindPermitted] 
(
	@UserID AS Int, 
	@Code AS VarChar(20)
)
RETURNS Bit
WITH ENCRYPTION
AS
BEGIN
	
	If (@Code = '')
		Return 1

	Declare @Count AS Int=0
	Declare @Result AS Bit
			
	SELECT	TOP 1 @Count = UserID
	FROM	srv.tblServiceKindRng
	WHERE	(UserID = @UserID)  AND (AllowCodeView = 1) AND
			(LEFT(@Code, LEN(ToCode)) >= FromCode) AND 
			(LEFT(@Code, LEN(ToCode)) <= ToCode) 
			
	If (@Count > 0)
		Set @Result = 1
	Else
		Set @Result = 0

	RETURN @Result
END
GO
