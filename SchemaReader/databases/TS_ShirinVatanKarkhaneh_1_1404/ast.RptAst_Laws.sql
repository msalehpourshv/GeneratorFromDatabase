USE TS_ShirinVatanKarkhaneh_1_1404
GO
SET ANSI_NULLS, QUOTED_IDENTIFIER ON
GO
-- =========== TS-QC:UPDATED ====================
-- Author		 : TakroSystem\Ahmadnejad
-- Creation Date : 1387/09/25
-- Viewed By	 : 
-- Last Modifier : 
-- Last Modified : 
-- Description   : <گزارش قوانین>
-- =================================================================
CREATE PROCEDURE [ast].[RptAst_Laws]
	@SerialNoFr		Int,
	@SerialNoTo		Int
	WITH ENCRYPTION
AS
DECLARE @LanguageID TinyInt
BEGIN

	SET NOCOUNT ON;
	SET @LanguageID = pub.funGetCurrentLanguageID();
	
	-- WHERE SECTION --------------------------------
	SELECT	D.*, L.LawGroupName
	FROM	ast.tblLawsDtl D 
				INNER JOIN ast.tblLawGroupsDtl L ON L.LawGroupID = D.LawGroupID AND L.LanguageID = @LanguageID
	WHERE	D.SerialNo >= @SerialNoFr AND D.SerialNo <= @SerialNoTo
	ORDER BY D.SerialNo, D.RowNo
END
GO
