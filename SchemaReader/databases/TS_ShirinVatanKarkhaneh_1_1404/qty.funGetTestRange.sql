USE TS_ShirinVatanKarkhaneh_1_1404
GO
SET ANSI_NULLS, QUOTED_IDENTIFIER ON
GO
CREATE FUNCTION [qty].[funGetTestRange] 
(
	@ExaminationID VarChar(20),
	@TestID VarChar(20)
)
RETURNS NVarChar(250)
WITH ENCRYPTION
AS

BEGIN

	Declare @type AS TinyInt 
	Declare @Result AS NVarChar(250)

	Set @Result = ''

	SELECT	@type = ResultType
	FROM	qty.tblTests
	WHERE 	TestID = @TestID
		
	IF @type = 1 
		SELECT	@Result = case fltStandardRageFrom  when 0 then '             '   else N'از '  + Str(fltStandardRageFrom,10,2) end + 
						  case fltStandardRageTo	when 0 then '              '  else N' تا ' + Str(fltStandardRageTo,10,2) end
		FROM	qty.tblExaminTestsDtl
		WHERE   ExaminationID = @ExaminationID AND TestID = @TestID
		

	ELSE IF @type = 2
		SELECT	@Result = strStandardRage
		FROM	qty.tblExaminTestsDtl
		WHERE   ExaminationID = @ExaminationID AND TestID = @TestID

	RETURN @Result 
	
END
GO
