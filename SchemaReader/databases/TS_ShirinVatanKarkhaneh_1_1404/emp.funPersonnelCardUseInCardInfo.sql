USE TS_ShirinVatanKarkhaneh_1_1404
GO
SET ANSI_NULLS, QUOTED_IDENTIFIER ON
GO

CREATE FUNCTION [emp].[funPersonnelCardUseInCardInfo]
(
	@StrCardNumber VarChar(20)
)
	RETURNS  Bit
WITH ENCRYPTION
AS
BEGIN
	Declare @ReturnValue Bit	
	Declare @CardCount Tinyint

    Set @ReturnValue = 'False'
    Set @CardCount = 0

	Select	@CardCount = Count(CardNumber)
	From	emp.tblCardReadersInfo
	Where	CardNumber = @StrCardNumber

	IF @CardCount > 0 
		Set @ReturnValue = 'True'

	Return @ReturnValue;
END 
GO
