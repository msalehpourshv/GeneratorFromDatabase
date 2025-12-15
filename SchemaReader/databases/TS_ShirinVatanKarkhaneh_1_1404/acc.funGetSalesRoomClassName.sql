USE TS_ShirinVatanKarkhaneh_1_1404
GO
SET ANSI_NULLS, QUOTED_IDENTIFIER ON
GO
-- =========== TS-QC:UPDATED ====================
-- Author		 : Jafari
-- Create date   : 1402/06/20
-- Viewed By	 : 
-- Last Modified : 
-- Last Modifier : 
-- Description	 : 
-- ==============================================
CREATE FUNCTION acc.funGetSalesRoomClassName
(
	@SalesRoomClassID Char(20) ,
	@LanguageID TinyInt
)
RETURNS NVarChar(50)
WITH ENCRYPTION
AS

BEGIN

	-- Declare the return variable here
	DECLARE @SalesRoomClassName NVarChar(50)

	Set @SalesRoomClassName = N'-'

	SELECT @SalesRoomClassName = SalesRoomClassName 
	From  acc.tblSalesRoomClassDtl
	Where LanguageID = @LanguageID AND SalesRoomClassID = @SalesRoomClassID

	-- Return the result of the function
	RETURN @SalesRoomClassName 

END
GO
