USE TS_ShirinVatanKarkhaneh_1_1404
GO
SET ANSI_NULLS, QUOTED_IDENTIFIER ON
GO
-- =========== TS-QC:UPDATED ====================
-- Author		 : TakroSystem\Ahmadnejad
-- Create Date   : 1388/10/02
-- Viewed By	 : 
-- Last Modified : 
-- Last Modifier : 
-- Description	 : لیست قراردادها
-- ==============================================
CREATE Function [sal].[funContractTypeName]
(
	@TypeID	Int
)
RETURNS NVarChar(50)
WITH ENCRYPTION
AS
BEGIN

	DECLARE @TypeName NVarChar(50)
	
	IF (@TypeID = 1) 
		SET @TypeName = N'گروه کالا'
	ELSE
		SET @TypeName = N'کالا'

	RETURN @TypeName
END
GO
