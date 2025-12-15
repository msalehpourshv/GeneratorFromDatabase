USE TS_ShirinVatanKarkhaneh_1_1404
GO
SET ANSI_NULLS, QUOTED_IDENTIFIER ON
GO
CREATE FUNCTION [pub].[GetStoreName]
(
	@StoreID VarChar(20), 
	@LanguageID AS TinyInt
)
	RETURNS NVarChar(50) 
WITH ENCRYPTION
AS

Begin -- ====================================================

	--SET @LanguageID = pub.funGetCurrentLanguageID();

	Declare @StrResult AS NVarChar(50)
	set @StrResult ='-'
	Select @StrResult = StoreName
	From   inv.tblStoresDtl
	Where  StoreID = @StoreID AND LanguageID = @LanguageID

	Return @StrResult

END -- ======================================================

















GO
