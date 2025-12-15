USE TS_ShirinVatanKarkhaneh_1_1404
GO
SET ANSI_NULLS, QUOTED_IDENTIFIER ON
GO
-- =========== TS-QC:UPDATED ====================
-- Author		 : TakroSystem\Hadi SaDeghi
-- Create date   : 1401/04/21
-- Viewed By	 : 
-- Last Modified : 
-- Last Modifier : 
-- Description	 : ریز درخواست مساعده پرسنل
-- ==============================================
Create PROCEDURE [prs].[RptAdvancesRequestDtl]
	@SerialNo		Int = 5,
	@PersonnelID	VARCHAR(20)= '01008',
	@RepInfo		Nvarchar(100) = Null
WITH ENCRYPTION
AS


Begin --============== S T A R T  C O D E =======================================

	SET NOCOUNT ON;

	SELECT H.SerialNo,PersonnelID,DocDate,Amount,AccountNo 
	FROM prs.tblAdvancesRequestDtl D 
	INNER JOIN prs.tblAdvancesRequestHdr H ON D.SerialNo = H.SerialNo
	where PersonnelID=@PersonnelID AND H.SerialNo<@SerialNo
	
END
GO
