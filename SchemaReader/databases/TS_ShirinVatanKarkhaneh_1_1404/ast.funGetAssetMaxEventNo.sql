USE TS_ShirinVatanKarkhaneh_1_1404
GO
SET ANSI_NULLS, QUOTED_IDENTIFIER ON
GO
Create FUNCTION [ast].[funGetAssetMaxEventNo] 
(
	@AssetPlaque	  Varchar(20) 
)
RETURNS Varchar(15)
WITH ENCRYPTION
AS
BEGIN
	-- Declare the return variable here
	DECLARE @MaxEventNo Varchar(15)
	SET @MaxEventNo = '0-0'

	--SELECT @MaxEventNo=IsNull(Max(EventNo),0)
	SELECT TOP 1 @MaxEventNo=LTRIM(STR(IsNull(ProcessID,0))) + '-' +  LTRIM(STR(IsNull(EventNo,0))) 
	From ast.tblAssetsDtl
	Where AssetPlaque = @AssetPlaque 
	ORDER BY Case when ProcessID in (450,455,460) Then PurchaseDate else DocDate end   Desc ,EventNo Desc

	RETURN @MaxEventNo

END
GO
