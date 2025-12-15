USE TS_ShirinVatanKarkhaneh_1_1404
GO
SET ANSI_NULLS, QUOTED_IDENTIFIER ON
GO
-- =========== TS-QC:UPDATED ====================
-- Author		 : TakroSystem\Sadeghi
-- Create date   : 1391/03/18
-- Viewed By	 : 
-- Last Modified : 
-- Last Modifier : 
-- Description	 : 
-- ==============================================
CREATE FUNCTION [sal].[funDistributionReturn_Count]
(
	@AcntCode	VarChar(20)
)
RETURNS NVarChar(250)
WITH ENCRYPTION
AS
BEGIN
	DECLARE @Result AS BIGINT
	
	SELECT @Result = COUNT(*) 
	FROM  (	
	SELECT tsdd.BaseProcessID,tsdd.BaseProcessNo,tsdd.BaseFiscalYear,tsdd.BaseSerialNo,DocDate,AcntCode	
	FROM inv.tblStorageDocsDtl tsdd
	WHERE tsdd.ProcessID=100 AND tsdd.AcntCode=@AcntCode 
	GROUP BY tsdd.BaseProcessID,tsdd.BaseProcessNo,tsdd.BaseFiscalYear,tsdd.BaseSerialNo,DocDate,tsdd.AcntCode
	EXCEPT
   (SELECT tsdd.BaseProcessID,tsdd.BaseProcessNo,tsdd.BaseFiscalYear,tsdd.BaseSerialNo,DocDate,AcntCode	
	FROM inv.tblStorageDocsDtl tsdd
	WHERE tsdd.ProcessID=100 AND tsdd.AcntCode=@AcntCode 
	GROUP BY tsdd.BaseProcessID,tsdd.BaseProcessNo,tsdd.BaseFiscalYear,tsdd.BaseSerialNo,DocDate,tsdd.AcntCode
	EXCEPT 
	SELECT ProcessID,ProcessNo,FiscalYear,SerialNo,DocDate,AcntCode
	FROM inv.tblStorageDocsDtl 
	WHERE ProcessID=90 AND AcntCode=@AcntCode 
	GROUP BY ProcessID,ProcessNo,FiscalYear,SerialNo,DocDate,AcntCode)
	)b

	RETURN @Result
	
END
GO
