USE TS_ShirinVatanKarkhaneh_1_1404
GO
SET ANSI_NULLS, QUOTED_IDENTIFIER ON
GO
Create FUNCTION inv.funGetContainerName
(
	@ContainerID VarChar(20), 
	@LanguageID AS TinyInt
)
	RETURNS NVarChar(100) 
WITH ENCRYPTION
AS

Begin -- ====================================================

	--SET @LanguageID = pub.funGetCurrentLanguageID();

	Declare @StrResult AS NVarChar(100)
	set  @StrResult=''

	Select @StrResult = ContainerName
	From   inv.tblContainerDtl
	Where  ContainerID = @ContainerID AND LanguageID = @LanguageID

	Return @StrResult

END



GO
