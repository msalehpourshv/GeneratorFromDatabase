USE TS_ShirinVatanKarkhaneh_1_1404
GO
SET ANSI_NULLS, QUOTED_IDENTIFIER ON
GO
-- =========== TS-QC:NOTOK ========================
-- Author        : Alianpour
-- Create date   : 1400/12/08
-- Viewed By	 : 
-- Last Modified : 
-- Description   : 
-- =============================================
CREATE PROCEDURE inv.sp_api_AsmanRasa_AutoBatch--

@DocDate AS NVARCHAR(10),
@OrderId AS Nvarchar(200)

WITH ENCRYPTION
 AS
BEGIN

DECLARE @StrErrorMessage As Nvarchar(1024)

BEGIN TRY
if(SUBSTRING(@DocDate,1,4)>='1401')
begin
	IF (SELECT COUNT(*) FROM inv.tblBatch WHERE BatchNo=@OrderId)=0
	BEGIN
		INSERT INTO inv.tblBatch
		(BatchNo,BatchDate,BaseFiscalYear,BaseProcessID,BaseProcessNo,BaseSerialNo,BatchCount,CodeClosed,
		 EndProduction,ExpireDate,OrderAcntCode,ProductionLineID,RecID,RelatedGoodsID,SessionNo,ShiftID,TransferSerialNo)
	
		VALUES (@OrderId ,@DocDate,0,0,0,0,0,0,
				0,'','','',0,'',0,'','Api')

		INSERT INTO inv.tblBatchDtl (BatchNo,BatchName,LanguageID)
	
		VALUES (@OrderId,@OrderId,1)
	END
end
END TRY
BEGIN CATCH


	Set @StrErrorMessage = ERROR_MESSAGE() 
	raiserror (@StrErrorMessage, 16, 1)

END CATCH

END	

GO
