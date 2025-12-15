USE TS_ShirinVatanKarkhaneh_1_1404
GO
SET ANSI_NULLS, QUOTED_IDENTIFIER ON
GO
-- =========== TS-QC:UPDATED ====================
-- Author		 : TakroSystem\Ahmadnejad
-- Create date   : 1389/03/10
-- Viewed By	 : 
-- Last Modified : 
-- Last Modifier : 
-- Description   : Dynamic Reports Columns
-- ==============================================
CREATE PROCEDURE [rpt].[SpDynaRepColumns]
	@ReportID	Int = 1
WITH ENCRYPTION
AS 
DECLARE @ReportType AS Int
Begin --============== S T A R T  C O D E ===================================================

	SET NOCOUNT ON;

	CREATE TABLE #tblCols
	(
		ColumnID	int, 
		CustomText	nvarchar(50), 
		HasSummary	bit, 
		HeaderFont	varchar(50),  
		HeaderForeColor	int, 
		HeaderBackColor	int, 
		DetailFont	varchar(50), 
		DetailForeColor	int, 
		DetailBackColor	int
	)

	SELECT ColumnID, CustomText, HasSummary, HeaderFont, HeaderForeColor, HeaderBackColor, DetailFont, DetailForeColor, DetailBackColor
	FROM rpt.tblDRepCols
	WHERE ReportID = @ReportID
End
GO
