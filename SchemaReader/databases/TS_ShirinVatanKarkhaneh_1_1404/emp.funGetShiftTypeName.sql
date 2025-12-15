USE TS_ShirinVatanKarkhaneh_1_1404
GO
SET ANSI_NULLS, QUOTED_IDENTIFIER ON
GO
CREATE FUNCTION emp.funGetShiftTypeName
(
	@ShiftTypeID varchar(20) ,
	@LanguageID TinyInt
)
RETURNS NVarChar(50)
WITH ENCRYPTION
AS

BEGIN

	DECLARE @ShiftTypeName NVarChar(200)

	Set @ShiftTypeName = N'-'

	SELECT @ShiftTypeName = ShiftTypeName
	From emp.tblShiftTypesDtl
	Where ShiftTypeID=@ShiftTypeID

	RETURN @ShiftTypeName 

END
GO
