USE TS_ShirinVatanKarkhaneh_1_1404
GO
SET ANSI_NULLS, QUOTED_IDENTIFIER ON
GO

Create FUNCTION pub.Trim(

	@String Nvarchar(max)
)
RETURNS Nvarchar(max)
WITH ENCRYPTION
AS
BEGIN
return ltrim(RTRIM(isnull(@String,'')))
end
GO
