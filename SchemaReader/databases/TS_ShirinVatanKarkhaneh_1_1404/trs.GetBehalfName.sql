USE TS_ShirinVatanKarkhaneh_1_1404
GO
SET ANSI_NULLS, QUOTED_IDENTIFIER ON
GO
CREATE FUNCTION [trs].[GetBehalfName]
(
	@BehalfID VarChar(20), 
	@LanguageID AS TinyInt
)
	RETURNS NVarChar(200) 
WITH ENCRYPTION
AS

Begin -- ====================================================


	Declare @StrResult AS NVarChar(200)
	set @StrResult ='-'
	Select @StrResult = BehalfName
	From   trs.tblBehalfDtl
	Where  BehalfID = @BehalfID AND LanguageID = @LanguageID

	Return @StrResult

END -- ======================================================

















GO
