USE TS_ShirinVatanKarkhaneh_1_1404
GO
SET ANSI_NULLS, QUOTED_IDENTIFIER ON
GO
-- =========== TS-QC:UPDATED ====================
-- Author		 : TakroSystem\Ahmadnejad
-- Create date   : 1388/02/06
-- Viewed By	 : 
-- Last Modified : 
-- Last Modifier : 
-- Description	 : جزئیات برگ انبار
-- ==============================================
CREATE PROCEDURE [inv].[RptStore_Doc_Atm]
	@ProcessID		Int = 55,
	@ProcessNo		Int = 1,
	@FiscalYear		Int,
	@SerialNo		Int
WITH ENCRYPTION
AS 
DECLARE @LanguageID TinyInt;
Begin --============== S T A R T  C O D E =======================================

	SET NOCOUNT ON;

	-- Init ------------------------------------------
	SET @LanguageID = pub.funGetCurrentLanguageID();

	IF (@ProcessNo Is Null)	SET @ProcessNo = 1;
	--------------------------------------------------

	-- SELECT Clause ----------------------------------------
	SELECT	A.*, [pub].[GetCodeName](A.AtomAcntCode, @LanguageID) AS AtomAcntName
	FROM	inv.tblStorageDocsAtom A
	WHERE 	A.ProcessID = @ProcessID AND A.ProcessNo = @ProcessNo AND
			A.FiscalYear = @FiscalYear AND A.SerialNo = @SerialNo 
	------------------------------------------------------------
End
GO
