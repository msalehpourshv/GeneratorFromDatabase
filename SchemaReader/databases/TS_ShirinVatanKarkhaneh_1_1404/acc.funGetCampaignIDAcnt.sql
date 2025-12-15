USE TS_ShirinVatanKarkhaneh_1_1404
GO
SET ANSI_NULLS, QUOTED_IDENTIFIER ON
GO
-- =========== TS-QC:UPDATED ====================
-- Author		 : jafari
-- Create date   : 1404/02/17
-- Viewed By	 : 
-- Last Modified : 
-- Last Modifier : 
-- Description	 : 
-- ==============================================
Create FUNCTION acc.funGetCampaignIDAcnt
(
	@FullCode	VarChar(20),
	@PartNumber int

)
RETURNS NVarChar(250)
WITH ENCRYPTION
AS
BEGIN
	DECLARE @Result AS VarChar(20);
	DECLARE @Start	AS int;
	DECLARE @Len	AS int;
	

	select @Start= acc.funGetAcntLayerStartandLen(@PartNumber,1)
	select @Len= acc.funGetAcntLayerStartandLen(@PartNumber,2)	

	SELECT	@Result = isnull(CampaignID,'')
	FROM	acc.tblAcnt
	WHERE	AcntCode = Substring(@FullCode, @Start, @Len) AND PartNumber = @PartNumber
	if @Result<>''
		RETURN isnull(@Result,'')

	RETURN isnull(@Result,'')
END
GO
