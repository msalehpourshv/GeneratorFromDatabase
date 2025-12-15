USE TS_ShirinVatanKarkhaneh_1_1404
GO
SET ANSI_NULLS, QUOTED_IDENTIFIER ON
GO
-- =========== TS-QC:UPDATED ====================
-- Author        : TakroSystem\Sadeghi
-- Create date   : 1392/01/17
-- Viewed By	 : 
-- Last Modified : 
-- Description   : 
-- =============================================
CREATE PROCEDURE [inv].[SpUpdateBaseDocRowNo]
	@DocRowNo	INT = 0,
	@ProcessNo		TinyInt = 0,
	@FiscalYear		SmallInt = 0,
	@SerialNo		Int = 0,
	@Code			NVarChar(500) = NULL,
	@DocDate		Char(10) = NULL
WITH ENCRYPTION
AS 

Begin 
	DECLARE @VolumeRowNo float
	
	if (SELECT COUNT(*) 
	    frOM inv.tblStorageDocsDtl
		WHERE ProcessID = 100 AND 
		   BaseProcessID=90 AND 
		   BaseProcessNo=@ProcessNo AND
		   BaseFiscalYear=@FiscalYear AND
		   BaseSerialNo=@SerialNo AND
		   GoodsID=@Code 
	   ) > 0
	BEGIN

		SELECT @VolumeRowNo = ISNULL(MAX(VolumeRowNo),0) 
		FROM inv.tblStorageDocsDtl 
		WHERE DocDate=@DocDate

		UPDATE inv.tblStorageDocsDtl 
		SET BaseDocRowNo=@DocRowNo
		WHERE ProcessID = 100 AND 
			   BaseProcessID=90 AND 
			   BaseProcessNo=@ProcessNo AND
			   BaseFiscalYear=@FiscalYear AND
			   BaseSerialNo=@SerialNo AND
			   GoodsID=@Code 

		UPDATE inv.tblStorageDocsDtl 
		SET VolumeRowNo = @VolumeRowNo + 1
		WHERE ProcessID = 100 AND 
			   BaseProcessID=90 AND 
			   BaseProcessNo=@ProcessNo AND
			   BaseFiscalYear=@FiscalYear AND
			   BaseSerialNo=@SerialNo AND
			   GoodsID=@Code AND
			   DocDate=@DocDate
	END
END
GO
