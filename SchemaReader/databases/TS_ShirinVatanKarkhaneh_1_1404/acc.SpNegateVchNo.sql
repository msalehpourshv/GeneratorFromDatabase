USE TS_ShirinVatanKarkhaneh_1_1404
GO
SET ANSI_NULLS, QUOTED_IDENTIFIER ON
GO
-- =========== TS-QC:OK ========================
-- Author        : Hadi Sadeghi
-- Create date   : 91/11/28
-- Viewed By	 : 
-- Last Modified : 
-- Description   : 
-- =============================================

CREATE  PROCEDURE [acc].[SpNegateVchNo]
	@intSerialNo	INT
	WITH ENCRYPTION
AS
BEGIN
	
	IF (SELECT COUNT(*) FROM acc.tblVoucherHdr 
	    WHERE SerialNo >= @intSerialNo) = 0
		BEGIN

			UPDATE acc.tblVoucherSerials
			SET VchNo = VchNo - 1
			WHERE VchNo > @intSerialNo
		END	
	ELSE
		BEGIN
			Declare @strErr As Nvarchar(1024)
			Set @strErr = N'��� �� ��� ����� ���� ���� ��� ���'
			raiserror (@strErr, 16, 1)
		END	
END
GO
