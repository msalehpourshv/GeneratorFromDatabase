USE TS_ShirinVatanKarkhaneh_1_1404
GO
SET ANSI_NULLS, QUOTED_IDENTIFIER ON
GO
CREATE FUNCTION [trs].[funGetPayMaxEventNo] 
(
	@VolumeFiscalYear  Smallint ,
	@VolumeRowNo       Int,
    @PayTypeID         TinyInt
)
RETURNS Varchar(10)
WITH ENCRYPTION
AS
BEGIN
	DECLARE @MaxEventNo Varchar(10)
	SET @MaxEventNo = '0-0-0'
	IF @PayTypeID=16 
		BEGIN
			SELECT TOP 1 @MaxEventNo=LTRIM(STR(IsNull(ProcessID,0))) + '-' +  LTRIM(STR(IsNull(EventNo,0))) + '-1' 
			From trs.tblPayDtl
			Where VolumeFiscalYear = @VolumeFiscalYear AND 
				  VolumeRowNo = @VolumeRowNo AND
				  PayTypeID =16
			ORDER BY EventNo Desc
		END
    ELSE IF @PayTypeID=18
		BEGIN
			SELECT TOP 1 @MaxEventNo=LTRIM(STR(IsNull(ProcessID,0))) + '-' +  LTRIM(STR(IsNull(EventNo,0))) + '-1' 
			From trs.tblPayDtl
			Where VolumeFiscalYear = @VolumeFiscalYear AND 
				  VolumeRowNo = @VolumeRowNo AND
				  PayTypeID =18
			ORDER BY EventNo Desc
		END
    ELSE IF @PayTypeID=6 OR @PayTypeID=26
		BEGIN
			SELECT TOP 1 @MaxEventNo=LTRIM(STR(IsNull(ProcessID,0))) + '-' +  LTRIM(STR(IsNull(EventNo,0))) + '-' + 
				  LTRIM(STR((SELECT COUNT(*) From trs.tblPayDtl
				   Where VolumeFiscalYear = @VolumeFiscalYear AND 
						 VolumeRowNo = @VolumeRowNo AND
						 PayTypeID in (6,26) AND 
						 ProcessID IN (13,18,24))))
			From trs.tblPayDtl
			Where VolumeFiscalYear = @VolumeFiscalYear AND 
				  VolumeRowNo = @VolumeRowNo AND
				  PayTypeID in (6,26)
			ORDER BY EventNo Desc 
		END
    ELSE
		BEGIN
			SELECT TOP 1 @MaxEventNo=LTRIM(STR(IsNull(ProcessID,0))) + '-' +  LTRIM(STR(IsNull(EventNo,0))) + '-' + 
				  LTRIM(STR((SELECT COUNT(*) From trs.tblPayDtl
				   Where VolumeFiscalYear = @VolumeFiscalYear AND 
						 VolumeRowNo = @VolumeRowNo AND
						 PayTypeID in (7,8,28) AND 
						 ProcessID IN (28) )))
			From trs.tblPayDtl
			Where VolumeFiscalYear = @VolumeFiscalYear AND 
				  VolumeRowNo = @VolumeRowNo AND
				  PayTypeID in (7,8,28)
			ORDER BY EventNo Desc
		END    

	-- Return the result of the function
	RETURN @MaxEventNo

END
GO
