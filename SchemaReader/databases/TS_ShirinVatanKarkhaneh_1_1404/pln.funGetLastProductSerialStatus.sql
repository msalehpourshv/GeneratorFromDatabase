USE TS_ShirinVatanKarkhaneh_1_1404
GO
SET ANSI_NULLS, QUOTED_IDENTIFIER ON
GO
CREATE FUNCTION [pln].[funGetLastProductSerialStatus] 
(
	@ProductSerialID INT
)
RETURNS NVARCHAR(200)
WITH ENCRYPTION
AS

BEGIN

	DECLARE @Remain  FLOAT

	SET  @Remain = 0

	SELECT TOP 1 @Remain = ISNULL(S.SerialStatusName,'')
	From pln.tblProductSerialStatus P
	INNER JOIN pln.tblSerialStatus S
	ON P.SerialStatusID=S.SerialStatusID
	Where	ProductSerialID=@ProductSerialID
	order by DocDate desc ,DocTime desc
	
	RETURN @Remain
END
GO
