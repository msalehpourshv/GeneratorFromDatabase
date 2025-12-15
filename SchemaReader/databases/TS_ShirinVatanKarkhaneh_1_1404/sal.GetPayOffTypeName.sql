USE TS_ShirinVatanKarkhaneh_1_1404
GO
SET ANSI_NULLS, QUOTED_IDENTIFIER ON
GO
-- =========== TS-QC:UPDATED ====================
-- Author		 : TakroSystem\jafari
-- Create Date   : 1399/08/29
-- Viewed By	 : 
-- Last Modified : 
-- Last Modifier : 
-- Description	 : Returns Name from PayOffType
-- ==============================================
Create FUNCTION sal.GetPayOffTypeName
(
	@PayOffTypeID VarChar(20), 
	@LanguageID AS TinyInt
)
	RETURNS NVarChar(50) 
WITH ENCRYPTION
AS

Begin -- ====================================================

	Declare @PayOffTypeName AS NVarChar(50)
	set @PayOffTypeName = ''
	
	Select @PayOffTypeName = PayOffTypeName
	From   sal.tblPayOffTypesDtl
	Where  PayOffTypeID = @PayOffTypeID AND LanguageID = @LanguageID

	Return isnull(@PayOffTypeName,'')

END -- ======================================================


GO
