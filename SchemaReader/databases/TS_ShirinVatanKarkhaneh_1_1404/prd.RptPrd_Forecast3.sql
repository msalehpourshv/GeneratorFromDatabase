USE TS_ShirinVatanKarkhaneh_1_1404
GO
SET ANSI_NULLS, QUOTED_IDENTIFIER ON
GO
-- =========== TS-QC:UPDATED ====================
-- Author		 : TakroSystem\Ahmadnejad
-- Create date   : 1390/11/12
-- Viewed By	 : 
-- Last Modified : 1390/11/12
-- Last Modifier : 
-- Description   : 
-- =================================================================
CREATE PROCEDURE [prd].[RptPrd_Forecast3]
(
	@ProductID	Varchar(20),
	@SerialNo	int = 0,
	@RepInfo	NVarChar(100) = '1@1@1',
	@RepOptions	VarChar(10) = ''
)
WITH ENCRYPTION
AS
Declare @StrSelect	NVarChar(4000);
Declare @StrFrom	NVarChar(4000);
Declare @StrWhere	NVarChar(4000);

DECLARE	@LangID		Char(1);
DECLARE	@SessionNo	Int; 
DECLARE	@ReportID	Int; 
BEGIN
	-- Init -------------------------------------------------------------------
	IF (@RepInfo	Is Null)	SET @RepInfo = '1@1@1'
	IF (@RepOptions	Is Null)	SET @RepOptions = '0'

	SET @LangID		= pub.funSplitString(@RepInfo, '@', 1);
	SET @SessionNo	= pub.funSplitString(@RepInfo, '@', 2);
	SET @ReportID	= pub.funSplitString(@RepInfo, '@', 3);

	select H.ExtraPercent, H.ProductCount,D.*
	from   prd.tblPrdAmountForecastWagesDtl D
		INNER JOIN prd.tblPrdAmountForecastHdr H ON H.ProductID = D.ProductID and D.SerialNo = H.SerialNo
	where D.ProductID = @ProductID and D.SerialNo = @SerialNo
END
GO
