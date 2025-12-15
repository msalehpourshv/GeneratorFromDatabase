USE TS_ShirinVatanKarkhaneh_1_1404
GO
SET ANSI_NULLS, QUOTED_IDENTIFIER ON
GO
CREATE FUNCTION [cmr].[funFrmCMRIsRowLocked] 
(
 @ProcessID		TinyInt,
 @ProcessNo		TinyInt,
 @FiscalYear	Smallint,
 @SerialNo		Int,
 @DocRowNo		Int,
 @DocStep		Int
)
RETURNS Bit
WITH ENCRYPTION
AS
BEGIN

Declare @IntCount		int
Declare @TempDocStep	int

SET @IntCount =0
IF @ProcessID= 150 
BEGIN
	IF @DocStep = 1
	BEGIN
		SELECT @TempDocStep =DocStep
		FROM cmr.tblCMRDtl 
		WHERE ProcessID=@ProcessID AND
			  ProcessNo=@ProcessNo AND 
			  FiscalYear=@FiscalYear AND
			  SerialNo=@SerialNo AND 
			  DocRowNo=@DocRowNo 

		IF @TempDocStep=2
			RETURN 1

		SELECT @IntCount =Count(*)
		FROM cmr.tblCMRDtl 
		WHERE BaseProcessID=@ProcessID AND
			  BaseProcessNo=@ProcessNo AND 
			  BaseFiscalYear=@FiscalYear AND
			  BaseSerialNo=@SerialNo AND 
			  BaseDocRowNo=@DocRowNo 
		 
		IF @IntCount >0
			RETURN 1
	END
	ELSE
	BEGIN
		SELECT @IntCount =Count(*)
        FROM cmr.tblCMRDtl 
        WHERE ProcessID=155 AND 
			  BaseProcessID=@ProcessID AND
			  BaseProcessNo=@ProcessNo AND 
			  BaseFiscalYear=@FiscalYear AND
			  BaseSerialNo=@SerialNo AND 
			  BaseDocRowNo=@DocRowNo

		IF @IntCount >0
		RETURN 1

	END
END

RETURN 0
END





GO
