USE TS_ShirinVatanKarkhaneh_1_1404
GO
SET ANSI_NULLS, QUOTED_IDENTIFIER ON
GO
-- =========== TS-QC:UPDATED ====================
-- Author		 : TakroSystem\noghrepasand
-- Create date   : 1391/02/19
-- Viewed By	 : 
-- Last Modified : 
-- Last Modifier : 
-- Description	 : 
-- ==============================================
CREATE FUNCTION [acc].[funVisitPathName3]
(
	@AcntCode		 VarChar(20),
	@StartLayerIndex int,
	@LayerLen		 int,
	@PartNumber		 int,
	@LanguageID		 TINYINT
)
RETURNS NVarChar(250)
WITH ENCRYPTION
AS
BEGIN
	DECLARE @VisitPathName AS NVarChar(300);

	SET @VisitPathName = '-'

	SELECT @VisitPathName=VisitPathName 
	FROM acc.tblVisitPathDtl
	where VisitPathID= (SELECT VisitPathID3 
						FROM acc.tblAcnt
						WHERE PartNumber = @PartNumber AND AcntCode=RTRIM(SUBSTRING(@AcntCode,@StartLayerIndex ,@LayerLen))) AND
		  PartNumber = 3 AND 
		  LanguageID = @LanguageID
		   
	
	RETURN @VisitPathName
END
GO
