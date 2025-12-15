USE TS_ShirinVatanKarkhaneh_1_1404
GO
SET ANSI_NULLS, QUOTED_IDENTIFIER ON
GO
-- =========== TS-QC:NOTOK ========================
-- Author        : Alian Pour
-- Create date   : 1400/11/06
-- Viewed By	 : 
-- Last Modified : 
-- Description   : 
-- =============================================
create PROCEDURE prs.sp_api_AppService_PersonnelsInfo

@Skip AS  nvarchar(50),
@PersonnelID AS  nvarchar(50),
@MaxResultCount AS  nvarchar(50)


WITH ENCRYPTION
 AS
BEGIN
	DECLARE @StrErrorMessage NVARCHAR(MAX)
	DECLARE @strQuery  NVARCHAR(Max)
	
BEGIN TRY

	SET @strQuery=
		' SELECT PD.PersonnelID,FirstName,LastName,PD.Description,PD.Address,P.BirthDate,P.Email,P.EmployeeNumber,P.Gender,P.Mobile,P.NationalIDNumber,P.Tel,P.ZipCode,DH.AcntSalary
		  FROM prs.tblPersonnelsDtl PD
		  INNER JOIN prs.tblPersonnels P ON P.PersonnelID=PD.PersonnelID
		  INNER JOIN prs.tblDecreeHdr DH ON PD.PersonnelID=DH.PersonnelID '


	IF(@PersonnelID<>'')
		SET @strQuery=@strQuery+' WHERE PD.PersonnelID='''+@PersonnelID+''''

	SET @strQuery=@strQuery +
		' ORDER BY PD.PersonnelID
		  OFFSET '+ @Skip+'  Rows 
		  FETCH NEXT '+ @MaxResultCount+'  Rows ONLY '

PRINT @strQuery
EXEC sp_executesql @strQuery

END TRY
BEGIN CATCH


	Set @StrErrorMessage = ERROR_MESSAGE() 
	raiserror (@StrErrorMessage, 16, 1)

END CATCH

END	
GO
