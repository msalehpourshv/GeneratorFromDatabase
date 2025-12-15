USE TS_ShirinVatanKarkhaneh_1_1404
GO
SET ANSI_NULLS, QUOTED_IDENTIFIER ON
GO
-- =========== TS-QC:UPDATED ====================
-- Author		 : Sadeghi
-- Create date   : 920110
-- Viewed By	 : 
-- Last Modified : 
-- Last Modifier : TakroSystem\Sadeghi
-- Description	 : 
-- ==============================================
CREATE PROCEDURE [acc].[SpCopyAcntCode]
(@AcntCode VARCHAR(20)='',
 @CurrentPart  TINYINT=2,
 @TargetPart  Tinyint=3
)
WITH ENCRYPTION
AS
BEGIN
	
	SELECT * INTO #tblH1 FROM acc.tblAcnt 
	WHERE AcntCode=@AcntCode AND PartNumber=@CurrentPart
	 
	SELECT * INTO #tblD1 FROM acc.tblAcntDtl
	WHERE AcntCode=@AcntCode AND PartNumber=@CurrentPart
		
		
	DELETE FROM acc.tblAcnt
	WHERE AcntCode=@AcntCode AND PartNumber=@TargetPart

	UPDATE #tblH1
	SET PartNumber=@TargetPart

	UPDATE #tblD1
	SET PartNumber=@TargetPart
	
	INSERT INTO acc.tblAcnt
	SELECT * FROM #tblH1
			
	INSERT INTO acc.tblAcntDtl
	SELECT * FROM #tblD1

	DROP TABLE #tblH1
	DROP TABLE #tblD1

END
GO
