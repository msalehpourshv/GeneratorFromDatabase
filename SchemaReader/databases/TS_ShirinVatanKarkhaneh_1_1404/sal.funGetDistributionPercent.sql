USE TS_ShirinVatanKarkhaneh_1_1404
GO
SET ANSI_NULLS, QUOTED_IDENTIFIER ON
GO
-- =========== TS-QC:UPDATED ====================
-- Author		 : TakroSystem\jafari
-- Create date   : 1401/02/15
-- Viewed By	 : 
-- Last Modified : 
-- Modifier		 : 
-- Description	 :
-- ==============================================
Create FUNCTION [sal].[funGetDistributionPercent]
(
	@GoodsID	varchar(20),
	@Date		varchar(10)
)
returns float
WITH ENCRYPTION
AS
Begin
declare @RetPercent float
	SELECT TOP 1 @RetPercent=DistributionPercent 
	FROM  sal.tblDistributionPercentDtl D
	Inner join [sal].[tblDistributionPercentHdr] H
	On D.SerialNo=H.SerialNo
	where [FromDate]<@Date AND SUBSTRING(@GoodsID,1,LEN(GoodsID))= GoodsID
	ORDER by H.SerialNo Desc,LEN(GoodsID) desc
	return isnull(@RetPercent,0)

End
GO
