USE TS_ShirinVatanKarkhaneh_1_1404
GO
SET ANSI_NULLS, QUOTED_IDENTIFIER ON
GO
Create FUNCTION [inv].[funGetBatchName]
(
	@BatchCode VarChar(20), 
	@LanguageID AS TinyInt
)
	RETURNS NVarChar(100) 
WITH ENCRYPTION
AS

Begin -- ====================================================

	--SET @LanguageID = pub.funGetCurrentLanguageID();

	Declare @StrResult AS NVarChar(100)
	set  @StrResult=''

	Select @StrResult = BatchName
	From   inv.tblBatchDtl
	Where  BatchNo = @BatchCode AND LanguageID = @LanguageID

	Return @StrResult

END



GO
