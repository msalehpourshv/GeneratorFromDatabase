USE TS_ShirinVatanKarkhaneh_1_1404
GO
SET ANSI_NULLS, QUOTED_IDENTIFIER ON
GO
-- =========== TS-QC:UPDATED ====================
-- Author		 : TakroSystem\Ahmadnejad
-- Create date   : 1386/04/02
-- Viewed By	 : 
-- Last Modified : 
-- Last Modifier : 
-- Description	 : رشته فیلتر مربوط به تاریخ چندگانه
-- ==============================================
CREATE FUNCTION [inv].[funGetDateFilter]
(
	@DateFilter	VarCHar(60),
	@Comparison VarChar(2), -- value: < or <= or > or >=
	@Date1Field	NVarCHar(50),
	@Date2Field	NVarCHar(50),
	@Date3Field	NVarCHar(50),
	@Date4Field	NVarCHar(50)
)
RETURNS NVarChar(500)
WITH ENCRYPTION
AS
BEGIN
	
	DECLARE @StrResult NVarCHar(500)
	DECLARE @StrTemp NVarCHar(50)

	SET @StrResult = ''

	-- Date 1 --
	SET @StrTemp = pub.funSplitString(@DateFilter, '@', 1);

	If (@StrTemp <> '') 
	Begin
		If (@StrResult <> '') SET @StrResult = @StrResult + ' AND '
		SET	@StrResult = @StrResult + '(' + LTrim(RTrim(@Date1Field))+'<>'''' and ' + LTrim(RTrim(@Date1Field)) + @Comparison + '''' + LTRim(RTrim(@StrTemp)) + ''')'
	End
		
	-- Date 2 --
	SET @StrTemp = pub.funSplitString(@DateFilter, '@', 2);

	If (@StrTemp <> '') 
	Begin
		If (@StrResult <> '') SET @StrResult = @StrResult + ' AND '
		SET	@StrResult = @StrResult + '(' + LTrim(RTrim(@Date2Field))+'<>'''' and ' + LTrim(RTrim(@Date2Field)) + @Comparison + '''' + LTRim(RTrim(@StrTemp)) + ''')'
	End

	-- Date 3 --
	SET @StrTemp = pub.funSplitString(@DateFilter, '@', 3);

	If (@StrTemp <> '') 
	Begin
		If (@StrResult <> '') SET @StrResult = @StrResult + ' AND '
		SET	@StrResult = @StrResult + '(' + LTrim(RTrim(@Date3Field))+'<>'''' and ' + LTrim(RTrim(@Date3Field)) + @Comparison + '''' + LTRim(RTrim(@StrTemp)) + ''')'
	End

	-- Date 4 --
	SET @StrTemp = pub.funSplitString(@DateFilter, '@', 4);

	If (@StrTemp <> '') 
	Begin
		If (@StrResult <> '') SET @StrResult = @StrResult + ' AND '
		SET	@StrResult = @StrResult + '(' + LTrim(RTrim(@Date4Field))+'<>'''' and ' + LTrim(RTrim(@Date4Field)) + @Comparison + '''' + LTRim(RTrim(@StrTemp)) + ''')'
	End

	-- for reliable code
	If (@StrResult = '')
		SET @StrResult = '1=1'

	Return '(' + @StrResult + ')'
END
GO
