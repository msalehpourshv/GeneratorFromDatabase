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
CREATE PROCEDURE [acc].[sp_api_AsmanRasa_IsHistoryExists]

@SourceCodeFieldValue  As Nvarchar(50),
@OrderId As Nvarchar(50),
@StateId As Nvarchar(50),
@HistoryId As Nvarchar(50)



WITH ENCRYPTION
 AS
BEGIN

DECLARE @StrErrorMessage As Nvarchar(1024)
DECLARE @StrSelect As Nvarchar(1024)
BEGIN TRY

--if(@StateId=4 or @StateId=64 or @StateId=54 or @StateId=52 )
--begin

--	if(select count(*) from inv.tblStorageDocsHdr
--	where TransferSerialNo=@SourceCodeFieldValue)>0
--		SELECT 1 AS IsExist
--	else
--		SELECT 0 AS IsExist
--end

--else
--begin
	--اگر کد وب سایت و دیتابیس  کاملا یکی باشد خارج شود
	IF(SELECT COUNT(*) FROM  acc.tblVoucherDtl 
	WHERE SourceCodeFieldValue=@SourceCodeFieldValue)>0
	BEGIN
		
		SELECT 1 AS IsExist
	END
	
	--اگر کد سفارش و هیستوری وجود داشته باشد خارج شود	
	IF(SELECT count(*)
		FROM acc.tblVoucherDtl
		where  [pub].[funSplitString](SourceCodeFieldValue,'_',1)=@OrderId AND
			   [pub].[funSplitString](SourceCodeFieldValue,'_',1)+'_'+[pub].[funSplitString](SourceCodeFieldValue,'_',2)=@OrderId+'_'+@HistoryId)>0
	BEGIN
		SELECT 1 AS IsExist
	END
	
	ELSE
		SELECT 0 AS IsExist


	--اگر سفارش وجود داشته باشد و کد هیستوری یکسان نباشد وضعیت آن را برسی میکنیم که یک سفارش دوبار در یک وضعیت نباشد
	IF(SELECT COUNT(*) FROM acc.tblVoucherDtl
	WHERE  [pub].[funSplitString](SourceCodeFieldValue,'_',1)=@OrderId AND 
		   [pub].[funSplitString](SourceCodeFieldValue,'_',3)=@StateId )>0
	BEGIN
		SELECT 1 AS IsExist
	END

--end

			
END TRY
BEGIN CATCH

	Set @StrErrorMessage = ERROR_MESSAGE() 
	raiserror (@StrErrorMessage, 16, 1)

END CATCH

END	

GO
