USE TS_ShirinVatanKarkhaneh_1_1404
GO
SET ANSI_NULLS, QUOTED_IDENTIFIER ON
GO
-- =========== TS-QC:NOTOK ========================
-- Author        :Elaheh AlianPour
-- Create date   : 1400/11/25
-- Viewed By	 : 
-- Last Modified : 
-- Description   : 
-- =============================================
CREATE PROCEDURE [acc].[sp_api_AsmanRasa_IsCreatePackingProcess]

@SourceCodeFieldValue  As Nvarchar(50),
@OrderId As Nvarchar(50),
@StateId As Nvarchar(50)

WITH ENCRYPTION
 AS
BEGIN

DECLARE @StrErrorMessage As Nvarchar(1024)
DECLARE @StrSelect As Nvarchar(1024)
BEGIN TRY

	--اگر کد وب سایت و دیتابیس  کاملا یکی باشد خارج شود
	IF(SELECT COUNT(*) FROM  acc.tblVoucherDtl 
	WHERE SUBSTRING(SourceCodeFieldValue,1,LEN(@OrderId))=@OrderId  AND [pub].[funSplitString](SourceCodeFieldValue,'_',3)=@StateId)>0
	BEGIN
		
		SELECT 1 AS IsExist
	END

	IF(SELECT COUNT(*)
		FROM acc.tblVoucherDtl
		where  SUBSTRING(SourceCodeFieldValue,1,LEN(@OrderId))=@OrderId AND
			   (([pub].[funSplitString](SourceCodeFieldValue,'_',3)>=78 AND [pub].[funSplitString](SourceCodeFieldValue,'_',3)<=115)or [pub].[funSplitString](SourceCodeFieldValue,'_',3)=121)
	   )>0

	BEGIN
		SELECT 1 AS IsExist
	END
	
	ELSE
		SELECT 0 AS IsExist
			
END TRY
BEGIN CATCH

	Set @StrErrorMessage = ERROR_MESSAGE() 
	raiserror (@StrErrorMessage, 16, 1)

END CATCH

END	

GO
