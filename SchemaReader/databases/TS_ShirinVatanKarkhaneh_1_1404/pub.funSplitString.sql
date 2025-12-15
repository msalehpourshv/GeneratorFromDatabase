USE TS_ShirinVatanKarkhaneh_1_1404
GO
SET ANSI_NULLS, QUOTED_IDENTIFIER ON
GO
-- =========== TS-QC:UPDATED ====================
-- Author		 : TakroSystem\Zia
-- Create date   : ??
-- Viewed By	 : 
-- Last Modified : 1389/10/13
-- Last Modifier : TakroSystem\Zia
-- Description	 : 
-- ===============================================
CREATE FUNCTION [pub].[funSplitString] 
(
	@StrInput NVarChar(Max),
	@ChrDelimiter NChar(1),
	@IntIndex	TinyInt -- 1 Based
)
RETURNS NVarChar(Max)
WITH ENCRYPTION
AS

BEGIN
	Declare	@left	NVarChar(Max);
	Declare	@right	NVarChar(Max);
	Declare	@IntPos	int;
	Declare	@idx	int;

	set @idx = 0;
	
	While (@idx < @IntIndex)
	Begin
		Set @IntPos = CharIndex(@ChrDelimiter, @StrInput);

		If (@IntPos = 0) -- not found
		Begin
			if (@idx = @IntIndex - 1)
				set @left = @StrInput;
			else
				set @left = '';

			set @right = '';
			Break;
		End

		set @left  = SubString(@StrInput, 1, @IntPos - 1);
		
		if (LEN(@StrInput) > @IntPos)
			set @right = SubString(@StrInput, @IntPos + 1, Len(@StrInput) - @IntPos);
		else
			set @right = '';

		Set @StrInput = @right;
		Set @idx = @idx + 1;
	End

	Return @left;
END
GO
