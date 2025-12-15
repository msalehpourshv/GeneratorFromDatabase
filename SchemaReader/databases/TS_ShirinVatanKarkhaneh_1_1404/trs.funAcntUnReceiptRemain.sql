USE TS_ShirinVatanKarkhaneh_1_1404
GO
SET ANSI_NULLS, QUOTED_IDENTIFIER ON
GO
-- =========== TS-QC:UPDATED ====================
-- Author		 : TakroSystem\Ahmadnejad
-- Create date   : 1388/02/02
-- Viewed By	 : 
-- Last Modified : 
-- Last Modifier : 
-- Description	 : 
-- ==============================================
CREATE FUNCTION [trs].[funAcntUnReceiptRemain]
(
	@FullAcntCode	AS VarChar(20),
	@ProcessNo		AS TinyInt = 1
)
RETURNS float 
WITH ENCRYPTION
As
Begin 

	DECLARE @Result AS float

	SET @Result = 0

	RETURN @Result 
End
GO
