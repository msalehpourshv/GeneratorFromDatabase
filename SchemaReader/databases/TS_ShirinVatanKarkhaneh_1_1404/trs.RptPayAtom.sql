USE TS_ShirinVatanKarkhaneh_1_1404
GO
SET ANSI_NULLS, QUOTED_IDENTIFIER ON
GO
-- =========== TS-QC:UPDATED ====================
-- Author		 : TakroSystem\Ahmadnejad
-- Create date   : 1388/07/06
-- Viewed By	 : 
-- Last Modified : 
-- Description	 : 
-- ----------------------------------------------
-- ریز سطرهای دریافت و پرداخت
-- ==============================================
CREATE PROCEDURE [trs].[RptPayAtom]
	@ProcessID		Int,
	@ProcessNo		Int,
	@FiscalYear		Int,
	@SerialNo		Int,
	@DocRowNo		Int
WITH ENCRYPTION
As
Begin  
	SELECT *, pub.GetCodeName(AtomAcntCode, 1) AS AtomAcntName
	FROM trs.tblPayAtm
	WHERE ProcessID = @ProcessID AND ProcessNo = @ProcessNo AND FiscalYear = @FiscalYear AND SerialNo = @SerialNo AND DocRowNo = @DocRowNo
End
GO
