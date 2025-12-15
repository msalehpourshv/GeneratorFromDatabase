USE TS_ShirinVatanKarkhaneh_1_1404
GO
SET ANSI_NULLS, QUOTED_IDENTIFIER ON
GO
-- =========== TS-QC:NOTOK ========================
-- Author        : Alian Pour
-- Create date   : 1400/10/13
-- Viewed By	 : 
-- Last Modified : 
-- Description   : 
-- =============================================
CREATE PROCEDURE [sal].[sp_api_Brango_GetCustomerInfo]
@AcntMobileNumber AS NVARCHAR(50),
@Skip As  NVARCHAR(50),
@MaxResultCount As  NVARCHAR(50)


WITH ENCRYPTION
 AS
BEGIN
	DECLARE @StrQuery  NVARCHAR(MAX)
	DECLARE @StrErrorMessage NVARCHAR(MAX)

BEGIN TRY

	SET @StrQuery ='SELECT c.CustomerInfoID,BirthDate,MobileNumber,PhoneNumber, 
					customer.FirstName as FirstName,customer.LastName as LastName 

				  FROM lyl.tblCustomerInfo  c 

				  Left Join lyl.tblCustomerInfoDtl customer on c.CustomerInfoID=customer.CustomerInfoID 
				  '
	
	IF(@AcntMobileNumber<>'')
	BEGIN
		set @StrQuery= @StrQuery + 'Where MobileNumber = '''+@AcntMobileNumber+'''' 

		set @StrQuery= @StrQuery + 'or c.CustomerInfoID = '''+@AcntMobileNumber+'''' 
	END

    SET @StrQuery = @StrQuery +
		' ORDER BY CustomerInfoID DESC
		  OFFSET '+ @Skip+'  Rows 
		  FETCH NEXT '+@MaxResultCount+' Rows ONLY'

 PRINT @StrQuery
 EXEC sp_executesql @StrQuery
END TRY
BEGIN CATCH


	Set @StrErrorMessage = ERROR_MESSAGE() 
	raiserror (@StrErrorMessage, 16, 1)

END CATCH

END	
GO
