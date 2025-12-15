USE TS_ShirinVatanKarkhaneh_1_1404
GO
SET ANSI_NULLS, QUOTED_IDENTIFIER ON
GO
--EXEC [prs].[spFrmAdvancesRequestDtlListSelect] 0, 0, ''
CREATE PROCEDURE [prs].[spFrmAdvancesRequestDtlListSelect]
	@ProcessID		Smallint = 311,
	@ProcessNo		TinyInt = Null,
	@PersonnelID	TinyInt = Null

WITH ENCRYPTION
AS
BEGIN
SET NOCOUNT ON;

	DECLARE @LanguageID TinyInt;
	DECLARE @ReturnProcessID int

	SET @LanguageID = pub.funGetCurrentLanguageID();
	SET @ProcessID = 311

	SELECT T.*,
		   prs.funGetShabaAccountNumber(T.PersonnelID,[prs].[funGetAccountNo](T.PersonnelID)) ShabaAccountNumber,
		   prs.funGetPersonnelName(T.PersonnelID, @LanguageID) PersonnelName
	FROM 
	(
	Select ARD.SerialNo, AR.DocDate, ARD.DocRowNo, ARD.PersonnelID, ARD.Amount,
		   [prs].[funGetAccountNo](ARD.PersonnelID) AS AccountNo
	From prs.tblAdvancesRequestHdr AR
	Inner Join prs.tblAdvancesRequestDtl ARD ON AR.SerialNo = ARD.SerialNo
	EXCEPT
	Select D.BaseSerialNo, D.BaseDocDate, D.BaseDocRowNo, D.PersonnelID, D.Amount,
		   D.AccountNo
	From prs.tblAdvancesHdr A 
	Inner Join prs.tblAdvancesDtl D ON A.SerialNo = D.SerialNo	
	) T
	Where (@PersonnelID Is Null OR @PersonnelID = '') OR T.PersonnelID = @PersonnelID

END
GO
