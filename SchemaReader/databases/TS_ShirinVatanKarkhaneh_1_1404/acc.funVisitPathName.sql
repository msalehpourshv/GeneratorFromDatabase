USE TS_ShirinVatanKarkhaneh_1_1404
GO
SET ANSI_NULLS, QUOTED_IDENTIFIER ON
GO
-- =========== TS-QC:UPDATED ====================
-- Author		 : jafari	
-- Create date   : 1401/09/05
-- Viewed By	 : 
-- Last Modified : 
-- Last Modifier : 
-- Description	 : path Name
-- ==============================================
CREATE FUNCTION acc.funVisitPathName
(
	@VisitPathID		 VarChar(20),
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
	where VisitPathID= @VisitPathID 
		AND PartNumber = @PartNumber 
		AND LanguageID = @LanguageID		   
	
	RETURN @VisitPathName
END
GO
