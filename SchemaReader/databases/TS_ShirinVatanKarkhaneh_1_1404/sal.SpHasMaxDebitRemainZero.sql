USE TS_ShirinVatanKarkhaneh_1_1404
GO
SET ANSI_NULLS, QUOTED_IDENTIFIER ON
GO
-- =========== TS-QC:OK ========================
-- Author        : Hadi Sadeghi
-- Create date   : 89/09/02
-- Viewed By	 : 
-- Last Modified : 
-- Description   : 
-- =============================================
CREATE PROCEDURE [sal].[SpHasMaxDebitRemainZero]
	@PartNumber Tinyint,
	@AcntCode VARCHAR(30)
	
	WITH ENCRYPTION
AS
BEGIN

	DECLARE @MaxDebitRemain FLOAT
	SET @MaxDebitRemain = 0

	SELECT @MaxDebitRemain = MaxDebitRemain 
	FROM acc.tblAcnt
	WHERE PartNumber = @PartNumber AND AcntCode = @AcntCode

	IF @MaxDebitRemain > 0
		SELECT 'True'
	ELSE
		SELECT 'False'
END
GO
