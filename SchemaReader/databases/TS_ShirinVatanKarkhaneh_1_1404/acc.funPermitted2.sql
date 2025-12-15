USE TS_ShirinVatanKarkhaneh_1_1404
GO
SET ANSI_NULLS, QUOTED_IDENTIFIER ON
GO
-- =============================================
-- Author:		Ahamdnejad Hossein
-- Create date: 2008/02/13
-- Description:	
-- چک می کند که آیا کاربر جاری به کد داده شده مجوز دسترسی (مشاهده) دارد یا نه؟
-- =============================================
CREATE FUNCTION [acc].[funPermitted2]
(
	@UserID AS Int, 
	@Code AS VarChar(20), 
	@Part AS TinyInt
)
RETURNS Bit
WITH ENCRYPTION
AS
BEGIN
	If (@Code = '')	Return 1;

	Declare @Count AS Int=0
	Declare @Result AS Bit
			
	SELECT	TOP 1 @Count = PartNumber
	FROM	acc.tblAcntRng
	WHERE	((UserID = @UserID) or (UserID = -1)) and
			(PartNumber = @Part) and 
			(AllowCodeView = 0) and
			(AccessAllCode = 0) and			
			(left(@Code, LEN(ToCode)) >= FromCode) AND 
			(left(@Code, LEN(ToCode)) <= ToCode) 
			
	If (@Count > 0)
		Set @Result = 0
	Else
		Set @Result = 1

	RETURN @Result
END
GO
