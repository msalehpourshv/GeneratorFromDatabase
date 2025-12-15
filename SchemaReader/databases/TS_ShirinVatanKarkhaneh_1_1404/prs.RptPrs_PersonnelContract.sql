USE TS_ShirinVatanKarkhaneh_1_1404
GO
SET ANSI_NULLS, QUOTED_IDENTIFIER ON
GO
-- =========== TS-QC:UPDATED ====================
-- Author		 : TakroSystem\Ahmadnejad
-- Creation date : 1387/11/07
-- Viewed By	 : 
-- Last Modified : 1388/06/03
-- Last Modifier : TakroSystem\Ahmadnejad
-- Description	 : 
-- ==============================================
CREATE PROCEDURE [prs].[RptPrs_PersonnelContract]
	@PersonnelID	VarChar(20) = Null,
	@SerialNo		int = 0,
	@RepOptions		VarChar(20) = '',
	@RepInfo		NVarChar(100) = '1@1@1'
WITH ENCRYPTION
AS 
DECLARE @StrSelect	NVarChar(max);
DECLARE @StrFrom	NVarChar(max);
DECLARE @StrWhere	NVarChar(max);

DECLARE	@LangID		Char(1);
DECLARE	@SessionNo	Int; 
DECLARE	@ReportID	Int; 
Begin 
	--============== S T A R T  C O D E =======================================

	SET NOCOUNT ON;

	---- Init ------------------------------------------
	IF (@RepInfo	Is Null)	SET @RepInfo = '1@1@1'

	SET @LangID		= pub.funSplitString(@RepInfo, '@', 1);
	SET @SessionNo	= pub.funSplitString(@RepInfo, '@', 2);
	SET @ReportID	= pub.funSplitString(@RepInfo, '@', 3);
	----------------------------------------------------

	select	DH.*, PD.Address, SD.StudyName,PD.FirstName, PD.LastName, PD.FatherName, PH.StudyID,
			PH.IDNumber, PH.BirthDate,PH.MaritalStatus, PH.Sons, PH.Daughters, PH.MilitaryStatus
	from	[prs].[vwDecrees] DH
				left join prs.tblPersonnelsDtl PD on PD.PersonnelID=DH.PersonnelID
				left join prs.tblPersonnels PH on PH.PersonnelID=DH.PersonnelID
				left join prs.tblStudiesDtl SD on SD.StudyID=PH.StudyID
	where	DH.PersonnelID=@PersonnelID and DH.SerialNo=@SerialNo

End
GO
