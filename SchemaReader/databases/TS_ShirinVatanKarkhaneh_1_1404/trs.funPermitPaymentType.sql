USE TS_ShirinVatanKarkhaneh_1_1404
GO
SET ANSI_NULLS, QUOTED_IDENTIFIER ON
GO
-- =============================================
-- Author:		jafari
-- Create date: 96/06/13
-- Description:	
-- چک می کند که آیا کاربر جاری به کد داده شده مجوز دسترسی (مشاهده) دارد یا نه؟
-- =============================================
Create FUNCTION [trs].[funPermitPaymentType] 
(
	@UserID AS Int, 
	@Code AS VarChar(20)
	
)

RETURNS Bit
WITH ENCRYPTION
AS
BEGIN
	If (@Code = '')	Return 1;

	Declare @Count AS Int
	Declare @Result AS Bit
	set @Count=0
	set @Result=0
	SELECT	@Count = IsNull(Count(*), 0)
	FROM	trs.tblPaymentTypeRng
	WHERE	((UserID = @UserID) or (UserID = -1)) and
			((AllowCodeView = 1) and
			((left(@Code, LEN(ToCode)) >= FromCode) AND 
			(left(@Code, LEN(ToCode)) <= ToCode) ))

	If (@Count > 0)
		Set @Result =1
	Else
		Set @Result = 0

	RETURN @Result
END




GO
