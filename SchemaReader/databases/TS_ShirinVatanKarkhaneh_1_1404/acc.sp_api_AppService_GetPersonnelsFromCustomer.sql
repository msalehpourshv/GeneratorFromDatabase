USE TS_ShirinVatanKarkhaneh_1_1404
GO
SET ANSI_NULLS, QUOTED_IDENTIFIER ON
GO
-- =========== TS-QC:NOTOK ========================
-- Author        : Alian Pour
-- Create date   : 1400/11/06
-- Viewed By	 : 
-- Last Modified : 1403/03/26 - r.moayed
-- Description   : 
-- =============================================
CREATE PROCEDURE acc.sp_api_AppService_GetPersonnelsFromCustomer

@MaxResultCount as nvarchar(50),
@Skip as nvarchar(50),
@Filter as nvarchar(max),
@AcntCustomerCode as nvarchar(200),
@AcntLen as nvarchar(20)

WITH ENCRYPTION
 AS
BEGIN
	DECLARE @StrErrorMessage NVARCHAR(MAX)
	DECLARE @strQuery NVARCHAR(MAX)
	Declare @CustomerPartNo AS Tinyint
	DECLARE @PartXLen	Int

BEGIN TRY

	set @strQuery='
	SELECT  BirthDate,Mobile,Tel,FirstName,LastName,AcntName,A.AcntCode,Email,Address1 as Address,NationalIdentity,AcntComment,EconomicalCode,
         NationalIdentity,CompanyRegisterNo,Address2,Tel,Fax 
	FROM  acc.tblAcnt A
	inner join acc.tblAcntDtl AD on A.AcntCode=AD.AcntCode and A.PartNumber=AD.PartNumber
	WHERE 1=1'

	IF(@Filter<>'')
		SET @strQuery=@strQuery + ' and  (AD.FirstName LIKE N''%'+@Filter+'%'' OR AD.LastName LIKE N''%'+@Filter+'%'' OR 
									AD.AcntName LIKE N''%'+@Filter+'%'' OR  A.AcntCode LIKE N''%'+@Filter+'%'' OR Mobile LIKE N''%'+@Filter+'%'') '

	SET @CustomerPartNo = 1
	
	SELECT @CustomerPartNo = SettingValue
	FROM pub.tblSettings
	WHERE SettingKey = 'AcntPartNumberForRemainCalculation'

	PRINT @CustomerPartNo


	SET @strQuery=@strQuery +
	' and len(A.AcntCode)='+@AcntLen+ ' and A.PartNumber=' + str(@CustomerPartNo) +'
  ORDER BY A.AcntCode
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
