USE TS_ShirinVatanKarkhaneh_1_1404
GO
SET ANSI_NULLS, QUOTED_IDENTIFIER ON
GO
CREATE PROCEDURE [inv].[spFrmTransferByStepDelete]
 @ProcessID		tinyint,
 @ProcessNo	    tinyint,
 @FiscalYear	smallint,
 @SerialNo		int
WITH ENCRYPTION
AS

BEGIN

SET NOCOUNT ON;

---------------------------------------------------------------------------------------
DELETE FROM inv.tblStorageDocsSerials
WHERE	ProcessID = 125 AND 
		ProcessNo = @ProcessNo AND 
		FiscalYear = @FiscalYear AND 
		SerialNo = @SerialNo 

DELETE FROM inv.tblStorageDocsAtom
WHERE	ProcessID = 125 AND 
		ProcessNo = @ProcessNo AND 
		FiscalYear = @FiscalYear AND 
		SerialNo = @SerialNo 

DELETE FROM inv.tblStorageDocsDtl 
WHERE	ProcessID = 125 AND 
		ProcessNo = @ProcessNo AND 
		FiscalYear = @FiscalYear AND 
		SerialNo = @SerialNo 

DELETE FROM inv.tblStorageDocsHdr 
WHERE	ProcessID = 125 AND 
		ProcessNo = @ProcessNo AND 
		FiscalYear = @FiscalYear AND 
		SerialNo = @SerialNo 

END

GO
