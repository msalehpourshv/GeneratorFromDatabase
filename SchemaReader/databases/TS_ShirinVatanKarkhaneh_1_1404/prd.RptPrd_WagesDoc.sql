USE TS_ShirinVatanKarkhaneh_1_1404
GO
SET ANSI_NULLS, QUOTED_IDENTIFIER ON
GO
-- =========== TS-QC:UPDATED ====================
-- Author		 : TakroSystem\Zia
-- Create date   : 1390/08/30
-- Viewed By	 : 
-- Last Modified : 1390/08/30
-- Last Modifier : TakroSystem\Zia
-- Description	 : 
-- =============================================
CREATE PROCEDURE [prd].[RptPrd_WagesDoc]
	@ProcessID	int = 89,
	@AcntCode	varchar(20) = null,
	@SerialNo	int = 1,
	@RepInfo	varchar(10) = '1@1@1'
WITH ENCRYPTION
AS
DECLARE	@LangID			Int;
DECLARE	@SessionNo		Int; 
DECLARE	@ReportID		Int; 
Begin
	
	SET NOCOUNT ON;

	SET @LangID = pub.funGetCurrentLanguageID();
	
	SELECT	H.*, D.RowNo, D.DocRowNo, D.GoodsID, [pub].[funGetGoodsName](D.GoodsID, @LangID) As GoodsName, 
			D.GoodsQuantity, D.WageAmount, [pub].[funGetGoodsUnitName] (D.GoodsID, @LangID) As UnitName, 
			pub.GetUserName(H.SessionNo) AS UserName, pub.GetCodeName(H.ProducerAcntCode, 1) ProducerAcntName,
			D.EnterKind
	FROM	prd.tblProducersWageDtl D 
	INNER JOIN prd.tblProducersWageHdr H ON H.ProcessID = D.ProcessID And H.ProducerAcntCode = D.ProducerAcntCode AND H.SerialNo = D.SerialNo
	INNER JOIN inv.tblGoodsDtl GD ON GD.GoodsID = D.GoodsID
	WHERE 	D.ProducerAcntCode = @AcntCode AND D.SerialNo = @SerialNo And D.ProcessID = @ProcessID

END
GO
