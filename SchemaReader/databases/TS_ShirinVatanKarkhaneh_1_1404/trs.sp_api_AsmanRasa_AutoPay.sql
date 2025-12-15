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

CREATE PROCEDURE [trs].[sp_api_AsmanRasa_AutoPay]
@Amount AS FLOAT,
@DocDate AS NVARCHAR(10),
@FiscalYear AS NVARCHAR(20),
@DebitCode AS NVARCHAR(200),
@CreditCode  AS NVARCHAR(200),
@TransferSerialNo AS NVARCHAR(200)


WITH ENCRYPTION
 AS
BEGIN

DECLARE @StrErrorMessage As Nvarchar(1024)
DECLARE @MaxSerialNo As Nvarchar(50)
DECLARE @OrderId AS  Nvarchar(50)
DECLARE @HistoryId AS  Nvarchar(50)
BEGIN TRY

	SET @OrderId= [pub].[funSplitString](@TransferSerialNo,'_',1)
	SET @HistoryId= [pub].[funSplitString](@TransferSerialNo,'_',2)
	
	IF(SELECT COUNT(*) FROM trs.tblPayHdr
		WHERE [pub].[funSplitString](TransferSerialNo,'_',1)=@OrderId AND
			  [pub].[funSplitString](TransferSerialNo,'_',2)=@HistoryId)=0
	BEGIN

		IF(SELECT COUNT(*) FROM trs.tblPayHdr
			WHERE DocDate=@DocDate AND TransferSerialNo<>'')>0
		BEGIN
		
			SELECT TOP(1) @MaxSerialNo =  SerialNo FROM trs.tblPayHdr
			WHERE DocDate=@DocDate AND TransferSerialNo<>''

			INSERT INTO trs.tblPayDtl
				( ProcessID,ProcessNo,FiscalYear,SerialNo,DebitCode,CreditCode,DocDate,Amount,PayTypeID, DocRowNo ,RowNo,
				  CurrencyRate , BaseSerialNo , BaseFiscalYear )
	
			VALUES (1, 1, @FiscalYear, @MaxSerialNo, @DebitCode , @CreditCode , @DocDate, @Amount , 6 , 1 , 1 ,
			        0 , 0 , 0)

			EXEC  acc.SpVch_CreateDoc 0,0,@DocDate,@DocDate,1,1,@FiscalYear,@MaxSerialNo,'trs.tblPayHdr','VchNo',2,2,1,0

		END

		ELSE
		BEGIN
			SELECT @MaxSerialNo = MAX(SerialNo) FROM trs.tblPayHdr
			
			SET @MaxSerialNo=@MaxSerialNo+1

			INSERT INTO trs.tblPayHdr
				( ProcessID,ProcessNo,FiscalYear,SerialNo,DebitCode,DocDate,
				  CurrencyRate , RecID , BaseSerialNo , BaseFiscalYear , BaseProcessID , BaseProcessNo,DescHdr )
	
			VALUES (1, 1, @FiscalYear, @MaxSerialNo, @DebitCode , @DocDate,
				    0 , 0 , 0 , 0 , 0 , 0,'Api')

			INSERT INTO trs.tblPayDtl
				( ProcessID,ProcessNo,FiscalYear,SerialNo,DebitCode,CreditCode,DocDate,Amount,PayTypeID, DocRowNo ,RowNo,
				  CurrencyRate , BaseSerialNo , BaseFiscalYear )
	
			VALUES (1, 1, @FiscalYear, @MaxSerialNo, @DebitCode , @CreditCode , @DocDate, @Amount , 6 , 1 , 1 ,
			        0 , 0 , 0)

			EXEC  acc.SpVch_CreateDoc 0,0,@DocDate,@DocDate,1,1,@FiscalYear,@MaxSerialNo,'trs.tblPayHdr','VchNo',2,2,1,0

		END

	END

END TRY
BEGIN CATCH

	Set @StrErrorMessage = ERROR_MESSAGE() 
	raiserror (@StrErrorMessage, 16, 1)

END CATCH

END	

GO
