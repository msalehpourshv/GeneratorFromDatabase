USE TS_ShirinVatanKarkhaneh_1_1404
GO
SET ANSI_NULLS, QUOTED_IDENTIFIER ON
GO
-- =========== TS-QC:OK ========================
-- Author        : Hadi Sadeghi
-- Create date   : 90/06/02
-- Viewed By	 : 
-- Last Modified : 
-- Description   : 
-- =============================================

CREATE  PROCEDURE [acc].[SpVoucherRcdID]
	@intVchNo	INT,
	@RecID		BigInt
	WITH ENCRYPTION
AS
BEGIN
	SET NOCOUNT ON;
	
	DECLARE @TempRecID bigInt
	SET @TempRecID = 0
	
	SELECT @TempRecID= RecID
	FROM acc.tblVoucherHdr
    WHERE SerialNo=@intVchNo

	IF @TempRecID = 0
		SET @TempRecID = @RecID
	
	UPDATE acc.tblVoucherHdr
	SET RecID = @TempRecID
	WHERE SerialNo=@intVchNo
		
	SELECT 	@TempRecID RecID
		
END
GO
