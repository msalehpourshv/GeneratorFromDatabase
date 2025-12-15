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
CREATE FUNCTION acc.funGetAcntVisitPathID1
(
	@AcntCode		 VarChar(20),
	@StartLayerIndex int,
	@LayerLen		 int,
	@PartNumber		 int
)
RETURNS NVarChar(250)
WITH ENCRYPTION
AS
BEGIN
	DECLARE @VisitPathID AS VarChar(20);
	
	SET @VisitPathID = '-'

	SELECT @VisitPathID=VisitPathID1 
	FROM acc.tblAcnt
	WHERE PartNumber = @PartNumber AND AcntCode=RTRIM(SUBSTRING(@AcntCode,@StartLayerIndex ,@LayerLen))
		 
	RETURN @VisitPathID
END
GO
