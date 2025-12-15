USE TS_ShirinVatanKarkhaneh_1_1404
GO
SET ANSI_NULLS, QUOTED_IDENTIFIER ON
GO
--EXEC [prs].[spFrmAdvancesRequestLoadConfirmDoc] 0, 0, 2
CREATE PROCEDURE [prs].[spFrmAdvancesRequestLoadConfirmDoc]
	@ProcessID		Smallint = 311,
	@ProcessNo		TinyInt = Null,
	@SerialNo		Int = Null

WITH ENCRYPTION
AS
BEGIN
SET NOCOUNT ON;

	DECLARE @LanguageID TinyInt;
	DECLARE @ConfirmCount TinyInt;
	DECLARE @ReturnProcessID Smallint

	SET @LanguageID = pub.funGetCurrentLanguageID();
	SET @ProcessID = 311
	SET @ConfirmCount=0

	SELECT @ConfirmCount = SettingValue
	FROM pub.tblSettings
	WHERE SettingKey = 'ConfirmCountInPersonnelAdvanceRequest'

	SELECT T.*, prs.funGetPersonnelName(T.PersonnelID, @LanguageID) PersonnelName
	FROM 
	(
	Select ARD.SerialNo, AR.DocDate, ARD.DocRowNo, ARD.PersonnelID, ARD.Amount,
		   [prs].[funGetShabaAccountNumber](ARD.PersonnelID,[prs].[funGetAccountNo](ARD.PersonnelID)) ShabaAccountNumber,
		   [prs].[funGetAccountNo](ARD.PersonnelID) AS AccountNo
	From prs.tblAdvancesRequestHdr AR
	Inner Join prs.tblAdvancesRequestDtl ARD ON AR.SerialNo = ARD.SerialNo
	where (@ConfirmCount=0 OR
		   (@ConfirmCount=1 AND SgnSN1>0) OR
		   (@ConfirmCount=2 AND SgnSN1>0 AND SgnSN2>0) OR
		   (@ConfirmCount=3 AND SgnSN1>0 AND SgnSN2>0 AND SgnSN3>0 ) OR
		   (@ConfirmCount=4 AND SgnSN1>0 AND SgnSN2>0 AND SgnSN3>0 AND SgnSN4>0) OR
		   (@ConfirmCount=5 AND SgnSN1>0 AND SgnSN2>0 AND SgnSN3>0 AND SgnSN4>0 AND SgnSN5>0))

	EXCEPT
	Select D.BaseSerialNo, D.BaseDocDate, D.BaseDocRowNo, D.PersonnelID, D.Amount, '' ShabaAccountNumber,
		   D.AccountNo
	From prs.tblAdvancesHdr A 
	Inner Join prs.tblAdvancesDtl D ON A.SerialNo = D.SerialNo	
	) T
	Where T.SerialNo = @SerialNo

END
GO
