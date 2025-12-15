USE TS_ShirinVatanKarkhaneh_1_1404
GO
SET ANSI_NULLS, QUOTED_IDENTIFIER ON
GO
-- =========== TS-QC:NOTOK ========================
-- Author        : Hadi Sadeghi
-- Create date   : 1400/02/222
-- Viewed By	 : 
-- Last Modified : 
-- Description   : 
-- =============================================
--[trs].[spAutoReceiptHdr] 1,1399,'1399/12/30','0001','21312'
create PROCEDURE [trs].[sp_api_saymandigital_AutoReceiptHdr]
@ProcessNo		as tinyint,
@FiscalYear		as Int,
@DocDate		as CHAR(10),
@DescHdr		as NVARCHAR(600),
@TransferSerialNo as nvarchar(100),
@AccountNo		as Varchar(30)

WITH ENCRYPTION
 AS
BEGIN

Declare @StrErrorMessage As Nvarchar(1024)
Declare @maxSerialNo	AS int
Declare @BankCode		As VARCHAR(20)
Declare @BankTypeID		As VARCHAR(20)
Declare @LocationID		As VARCHAR(20)
Declare @BranchCode		As VARCHAR(20)

BEGIN TRY
if(select count (*) from trs.tblPayHdr where TransferSerialNo=@TransferSerialNo and ProcessID=1)=0
begin
	SELECT @BankCode=BankCode,@BankTypeID=BankTypeID,@LocationID=LocationID,@BranchCode=BranchCode
	FROM trs.tblOurBanks
	where BankAccountNo=@AccountNo
	
	IF @BankCode=''
	BEGIN
		Set @StrErrorMessage = N' حساب بانکی برای '+@TransferSerialNo+'  در سیستم خزانه داری بانکی معرفی نشده است '
		raiserror (@StrErrorMessage, 16, 1)
	END	
	
	If SUBSTRING(@BankCode,1,2)='21'
	BEGIN
		set @ProcessNo=2
	END
				
	SELECT @maxSerialNo = isnull(MAX(SerialNo),0)
	FROM trs.tblPayHdr 
	WHERE ProcessID=1
	  AND ProcessNo=@ProcessNo
	  AND FiscalYear=@FiscalYear
			 
	SET @maxSerialNo = @maxSerialNo +1
	
	INSERT INTO trs.tblPayHdr
		(ProcessID,ProcessNo,FiscalYear,SerialNo,DebitCode,DocDate,VchDate,DescHdr,TransferSerialNo)
	values
		(1,@ProcessNo,@FiscalYear,@maxSerialNo,@BankCode,@DocDate,@DocDate,@DescHdr,@TransferSerialNo)	
		
	SELECT 	@maxSerialNo SerialNo,@ProcessNo proccessNo
end
else
	SELECT 	0 SerialNo,@ProcessNo proccessNo

END TRY
BEGIN CATCH

	Set @StrErrorMessage = ERROR_MESSAGE() 
	raiserror (@StrErrorMessage, 16, 1)

END CATCH

END	

GO
