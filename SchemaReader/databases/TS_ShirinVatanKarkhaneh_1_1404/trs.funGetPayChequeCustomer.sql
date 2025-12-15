USE TS_ShirinVatanKarkhaneh_1_1404
GO
SET ANSI_NULLS, QUOTED_IDENTIFIER ON
GO
CREATE FUNCTION [trs].[funGetPayChequeCustomer] 
(
	@VolumeFiscalYear	SmallInt,
	@VolumeRowNo		Int
)
RETURNS VarChar(20)
WITH ENCRYPTION
AS

BEGIN -- ============== S T A R T  C O D E =====================================

	Declare @Result AS VarChar(20)

	SELECT Top 1 @Result = DebitCode
	FROM	trs.tblPayDtl
	WHERE	ProcessID IN (2,25) AND 
			PayTypeID IN (7,8,28) AND 
			VolumeFiscalYear = @VolumeFiscalYear AND 
			VolumeRowNo = @VolumeRowNo
	ORDER By EventNo ASC

	Return @Result
END





























GO
