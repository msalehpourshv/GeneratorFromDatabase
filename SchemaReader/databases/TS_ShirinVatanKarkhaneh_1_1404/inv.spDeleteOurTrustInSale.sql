USE TS_ShirinVatanKarkhaneh_1_1404
GO
SET ANSI_NULLS, QUOTED_IDENTIFIER ON
GO
-- =========== TS-QC:OK ========================
-- Author        : Hadi Sadeghi
-- Create date   : 98/02/21
-- Viewed By	 : 
-- Last Modified : 
-- Description   : 
-- =============================================
Create PROCEDURE [inv].[spDeleteOurTrustInSale]
	@ProcessID		  tinyint,
	@ProcessNo		  tinyint,
	@FiscalYear       SmallInt=NULL,
	@SerialNo       SmallInt=NULL
WITH ENCRYPTION
AS

BEGIN

	
	delete FROM inv.tblStorageDocsHdr
	WHERE ((@ProcessID = 90 AND ProcessID=130) OR  
	       (@ProcessID = 100 AND ProcessID=135))  AND
		  BaseDistributionProcessID=@ProcessID AND
		  BaseDistributionProcessNo=@ProcessNo AND  
		  BaseDistributionFiscalYear=@FiscalYear AND  
		  BaseDistributionSerialNo=@SerialNo   
			  
END
GO
