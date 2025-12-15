USE TS_ShirinVatanKarkhaneh_1_1404
GO
SET ANSI_NULLS, QUOTED_IDENTIFIER ON
GO

-- =========== TS-QC:NOTOK ========================
-- Author        : Alian Pour
-- Create date   : 1400/08/28
-- Viewed By	 : 
-- Last Modified : 
-- Description   : 
-- =============================================
Create PROCEDURE [inv].[sp_api_TakroSystem_CheckTPHistoriesWithStorageDocsHdr]

WITH ENCRYPTION
 AS
BEGIN
	DECLARE  @DBName AS VARCHAR(200)
	DECLARE  @DBName0000 AS VARCHAR(200)
	DECLARE  @StrErrorMessage AS VARCHAR(MAX)=''

	DECLARE  @StrQueryFTPHistory  AS NVARCHAR(MAX)
	DECLARE  @StrQuery  AS NVARCHAR(MAX)

	DECLARE  @TPHistoryCount  AS NVARCHAR(MAX)
	DECLARE  @StorageCount  AS NVARCHAR(MAX)
	DECLARE  @FiscalYear as NVARCHAR(50)
BEGIN TRY
		
	SELECT @DBName= db_name()
	
	SELECT @DBName0000= SUBSTRING (db_name() ,1,len(db_name() )-4) +'0000'
	
	SELECT @FiscalYear= substring (db_name() ,LEN(db_name())-3,len(db_name() ))
	
	set @StrQueryFTPHistory='
	if not exists(
			select * from INFORMATION_SCHEMA.TABLES
			where TABLE_SCHEMA=''pub'' and TABLE_NAME=''tblTPHistoriesFY'')
	begin

		RAISERROR (''your Program update  is wrong , the Table TPHistoriesFY IS not Exists'', 16, 1)

	end'
	PRINT @StrQueryFTPHistory
	EXEC sp_executesql @StrQueryFTPHistory

	
	set @StrQueryFTPHistory=
	'IF((SELECT COUNT(*) FROM  '+ @DBName0000 +'.pub.tblTPHistories WHERE Status=3 AND FiscalYear='+@FiscalYear+') <
	    (SELECT COUNT(*) FROM  '+ @DBName     +'.pub.tblTPHistoriesFY WHERE Status=3 AND FiscalYear='+@FiscalYear+'))
	BEGIN
		
		RAISERROR (''اطلاعات  فاکتور های سال مالی با اطلاعات تاریخچه یکسان نیست لطفا با پشتیبانی تماس حاصل نمایید در غیر این صورت در ارسال صورتحساب ها دچار مشکل خواهید شد'', 16, 1)
	END 
	'
	
	PRINT @StrQueryFTPHistory
	EXEC sp_executesql @StrQueryFTPHistory
--*******************************************************************************************************************

	SET @TPHistoryCount='SELECT COUNT(*) FROM  '+@DBName0000+'.pub.tblTPHistories WHERE Status=3'
	SET @StorageCount='( SELECT COUNT(*) FROM  '+db_name()+'.inv.tblStorageDocsHdr WHERE SendTaxTollState=3)'
	
	set @StrQuery='
	IF( '+@TPHistoryCount+' ) < '+@StorageCount+ '
	BEGIN
		SELECT 0 AS Match
	END
	ELSE
		SELECT 1 AS Match '

	PRINT @StrQuery
	EXEC sp_executesql @StrQuery



END TRY
BEGIN CATCH

	Set @StrErrorMessage = ERROR_MESSAGE() 
	raiserror (@StrErrorMessage, 16, 1)

END CATCH

END	
GO
