USE TS_ShirinVatanKarkhaneh_1_1404
GO
SET ANSI_NULLS, QUOTED_IDENTIFIER ON
GO
Create Function [inv].[funGetBaskulProcess]  (
 @StrIn		NVARchar(max)
 )
RETURNS varchar(50)
WITH ENCRYPTION
AS
Begin -- === S T A R T ===========================================

	Declare @Result AS varchar(50)
	

	SELECT	@Result = cast(@StrIn as varchar(50))
	 
	Return @Result
End   -- === E N D ===============================================
GO
