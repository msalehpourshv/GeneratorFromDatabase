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

CREATE  PROCEDURE [acc].[SpVoucherRecordState]
	@intVchNo				Int
	WITH ENCRYPTION
AS
BEGIN
	SET NOCOUNT ON;

	IF ((SELECT TOP 1 SerialNo 
	     FROM acc.tblVoucherDtl
         WHERE SerialNo=@intVchNo) IS NULL)

				select 3 RecordState
		
		ELSE
				select 2 RecordState

END
GO
