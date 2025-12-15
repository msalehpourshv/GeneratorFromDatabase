USE TS_ShirinVatanKarkhaneh_1_1404
GO
SET ANSI_NULLS, QUOTED_IDENTIFIER ON
GO
CREATE FUNCTION [acc].[funAccountRemain] 
(
	@AcntCode Varchar(20),
	@DocDate Char(10)
)
RETURNS Float
WITH ENCRYPTION
AS

BEGIN

	DECLARE @Remain  FLOAT

	SET  @Remain = 0

	SELECT @Remain = ISNULL(Sum(Debit-Credit),0)
	From acc.tblVoucherDtl
	Where	AcntCode=@AcntCode  AND 
			DocDate<=@DocDate 
	
	RETURN @Remain
END
GO
