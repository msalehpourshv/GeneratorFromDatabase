USE TS_ShirinVatanKarkhaneh_1_1404
GO
SET ANSI_NULLS, QUOTED_IDENTIFIER ON
GO
CREATE FUNCTION [trs].[funGetChequeState] 
(
	@ProcessNo			TinyInt, 
	@VolumeFiscalYear	SmallInt, 
	@VolumeRowNo		Int,
	@ToDate				VarChar(10) = Null 
)
RETURNS TinyInt
WITH ENCRYPTION
AS

BEGIN

	Declare @Result TinyInt

	IF @ToDate Is Not Null
		BEGIN
			SELECT Top 1 @Result =  ProcessID	
			FROM	 trs.tblPayDtl
			WHERE	 PayTypeID IN (6,26) AND ProcessNo = @ProcessNo AND 
					 VolumeFiscalYear = @VolumeFiscalYear AND 
					 VolumeRowNo = @VolumeRowNo AND 
					 DocDate <= @ToDate
			ORDER  BY EventNo DESC
		END
	Else
		BEGIN
			SELECT Top 1 @Result =  ProcessID	
			FROM	 trs.tblPayDtl
			WHERE	 PayTypeID IN (6,26) AND ProcessNo = @ProcessNo AND 
					 VolumeFiscalYear = @VolumeFiscalYear AND 
					 VolumeRowNo = @VolumeRowNo
			ORDER  BY EventNo DESC
		END

	RETURN @Result
END





















GO
