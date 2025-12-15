USE TS_ShirinVatanKarkhaneh_1_1404
GO
SET ANSI_NULLS, QUOTED_IDENTIFIER ON
GO
CREATE FUNCTION [inv].[funLockStatus]
(
	-- Add the parameters for the function here
	@ProcessID		Smallint,
	@ProcessNo		Tinyint,
	@FiscalYear		Smallint,
	@SerialNo		Int,
	@DocRowNo		Int,
	@DocStep		Tinyint
)
RETURNS Bit
WITH ENCRYPTION
AS
BEGIN
	-- Declare the return variable here
	DECLARE @Result Int
	SET @Result =0

	IF @ProcessID = 55 OR @ProcessID =90 OR @ProcessID =110	
		BEGIN
			IF @DocStep=1
				BEGIN
					Select @Result = Count(*) 
					From inv.tblStorageDocsDtl
					Where	ProcessID = @ProcessID AND ProcessNo = @ProcessNo AND FiscalYear = @FiscalYear AND 
							SerialNo = @SerialNo AND DocRowNo = @DocRowNo AND DocStep>1

					IF @Result = 0
						Return 0
					ELSE
						Return 1
				END
			ELSE
				BEGIN
					Select @Result = Count(*) 
					From inv.tblStorageDocsDtl
					Where	BaseProcessID = @ProcessID AND BaseProcessNo = @ProcessNo AND 
							BaseFiscalYear = @FiscalYear AND BaseSerialNo = @SerialNo AND BaseDocRowNo = @DocRowNo

					IF @Result = 0
						Return 0
					ELSE
						Return 1
				END
		END

	-- Return the result of the function
	RETURN @Result

END
GO
