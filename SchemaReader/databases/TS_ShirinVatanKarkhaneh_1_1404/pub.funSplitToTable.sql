USE TS_ShirinVatanKarkhaneh_1_1404
GO
SET ANSI_NULLS, QUOTED_IDENTIFIER ON
GO
-- =========== TS-QC:UPDATED ====================
-- Author		 : TakroSystem\Hadi Sadeghi
-- Create date   : 1401/05/30
-- Viewed By	 : 
-- Last Modified : 
-- Last Modifier : 
-- Description	 : 
-- ===============================================
Create FUNCTION [pub].[funSplitToTable] 
(
	@StrInput NVarChar(Max) ,
	@ChrDelimiter NChar(1)
) RETURNS @tblTempGoods TABLE 
(
	[Name] [NVarChar](50)
) 
WITH ENCRYPTION
AS

BEGIN

	Declare	@IntPos	int;

	While (0 < LEN(@StrInput))
	Begin
		Set @IntPos = CharIndex(@ChrDelimiter, @StrInput);

		IF @IntPos > 0
			insert into @tblTempGoods SELECT    SubString(@StrInput, 1, @IntPos - 1);
		ELSE
		begin
			insert into @tblTempGoods SELECT   @StrInput;
			RETURN
		end
		if (LEN(@StrInput) > @IntPos)
			select @StrInput = SubString(@StrInput, @IntPos + 1, Len(@StrInput) - @IntPos);
		ELSE
			SET @StrInput =''

	End

	Return 
END
GO
