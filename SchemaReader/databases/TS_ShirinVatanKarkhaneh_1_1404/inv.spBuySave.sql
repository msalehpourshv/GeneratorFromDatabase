USE TS_ShirinVatanKarkhaneh_1_1404
GO
SET ANSI_NULLS, QUOTED_IDENTIFIER ON
GO
-- =============================================
-- Author:		Hadi Sadeghi
-- Create date: 86/11/06
-- Description:	Control Receipt 
-- =============================================
CREATE PROCEDURE [inv].[spBuySave] 
 @ProcessID		tinyint,
 @ProcessNo		tinyint,
 @FiscalYear	smallint,
 @SerialNo		int
 WITH ENCRYPTION
 AS

BEGIN
SET NOCOUNT ON;

	SELECT Amount 
	FROM inv.tblStorageDocsHdr
	WHERE	ProcessID=@ProcessID	AND
			ProcessNo=@ProcessNo	AND
			FiscalYear=@FiscalYear	AND
			SerialNo=@SerialNo

END






















































GO
