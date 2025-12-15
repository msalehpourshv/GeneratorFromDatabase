USE TS_ShirinVatanKarkhaneh_1_1404
GO
SET ANSI_NULLS, QUOTED_IDENTIFIER ON
GO
-- =========== TS-QC:UPDATED ====================
-- Author		 : TakroSystem\Hamid
-- Create date   : 1392/06/07
-- Viewed By	 : 
-- Last Modified : 1392/06/07
-- Last Modifier : TakroSystem\Hamid
-- Description	 : �ѐ ������
-- ==============================================
CREATE PROCEDURE [trs].[RptTrs_PettyDoc]
	@ProcessID		Int = 90,
	@ProcessNo		Int = 1,
	@FiscalYear		Int = Null,
	@SerialNo		Int = Null
WITH ENCRYPTION
AS 
Begin --============== S T A R T  C O D E =======================================

	SET NOCOUNT ON;

	-- Init ------------------------------------------
	--------------------------------------------------

	-- SELECT Clause ----------------------------------------
	SELECT	D.*, pub.GetCodeName(CostAcntCode,1) As CostAcntName
	FROM	trs.tblPettyCashDtl D
	WHERE 	D.ProcessID = @ProcessID AND D.ProcessNo = @ProcessNo AND
			D.FiscalYear = @FiscalYear AND D.SerialNo = @SerialNo
	ORDER BY DocRowNo		
	------------------------------------------------------------
End
GO
