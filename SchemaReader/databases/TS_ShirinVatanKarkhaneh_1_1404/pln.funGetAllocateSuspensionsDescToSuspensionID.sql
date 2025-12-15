USE TS_ShirinVatanKarkhaneh_1_1404
GO
SET ANSI_NULLS, QUOTED_IDENTIFIER ON
GO

Create FUNCTION [pln].[funGetAllocateSuspensionsDescToSuspensionID]
(	
	@SuspensionID varchar(20)
)
RETURNS TABLE 
WITH ENCRYPTION            
AS

RETURN 
(
SELECT DISTINCT D.SuspensionDescID
FROM pln.tblAllocateSuspensionsDescToSuspensionsHdr H
INNER JOIN pln.tblAllocateSuspensionsDescToSuspensionsDtl D ON H.SuspensionID = D.SuspensionID
WHERE H.SuspensionID = @SuspensionID
)
GO
