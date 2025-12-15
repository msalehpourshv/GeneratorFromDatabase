USE TS_ShirinVatanKarkhaneh_1_1404
GO
SET ANSI_NULLS, QUOTED_IDENTIFIER ON
GO
-- =========== TS-QC:NOTOK ========================
-- Author        : Alian Pour
-- Create date   : 1400/06/11
-- Viewed By	 : 
-- Last Modified : 
-- Description   : 
-- =============================================
create PROCEDURE [trs].[sp_api_AutoReceiptHdr]
@ProcessNo		as tinyint,
@FiscalYear		as Int,
@DocDate		as CHAR(10),
@AcntCode	as varchar(20),
@DescHdr		as NVARCHAR(600),
@TransferSerialNo as nvarchar(100),
@AccountNo		as Varchar(30)

WITH ENCRYPTION
 AS
BEGIN

Declare @StrErrorMessage As Nvarchar(1024)
Declare @maxSerialNo	AS int
DECLARE @CustomerCode as Varchar(30)
Declare @BankCode		As VARCHAR(20)=1120000
Declare @BankTypeID		As VARCHAR(20)
Declare @LocationID		As VARCHAR(20)
Declare @BranchCode		As VARCHAR(20)

BEGIN TRY


if(select COUNT(*) from trs.tblPayHdr where TransferSerialNo = @TransferSerialNo)=0
begin

	SELECT @BankCode=BankCode,@BankTypeID=BankTypeID,@LocationID=LocationID,@BranchCode=BranchCode
	FROM trs.tblOurBanks
	where BankAccountNo=@AccountNo
	
	IF @BankCode=''
	BEGIN
		Set @StrErrorMessage = N'حساب بانکی برایش در سیستم خزانه داری بانکی معرفی نشده است'
		raiserror (@StrErrorMessage, 16, 1)
	END	
	

	IF (SELECT COUNT(*) from acc.tblAcnt where AcntCode=@AcntCode)=0
	BEGIN
		Set @StrErrorMessage = N' کد حسابداری نامعتبر است'
		raiserror (@StrErrorMessage, 16, 1)
	END

	SET @CustomerCode='111301 '+@AcntCode

	SELECT @maxSerialNo = isnull(MAX(SerialNo),0)
	FROM trs.tblPayHdr 
	WHERE ProcessID=1
	  AND ProcessNo=@ProcessNo
	  AND FiscalYear=@FiscalYear
			 
	SET @maxSerialNo = @maxSerialNo +1
	
	INSERT INTO trs.tblPayHdr
		(ProcessID,ProcessNo,FiscalYear,SerialNo,CreditCode,DocDate,VchDate,DescHdr,TransferSerialNo)
	values
		(1,@ProcessNo,@FiscalYear,@maxSerialNo,@CustomerCode,@DocDate,@DocDate,@DescHdr,@TransferSerialNo)	
		
	SELECT 	@maxSerialNo SerialNo,@CustomerCode CustomerCode,@ProcessNo proccessNo
end
else 
	SELECT 	0 SerialNo,'' CustomerCode,@ProcessNo proccessNo
END TRY
BEGIN CATCH

	Set @StrErrorMessage = ERROR_MESSAGE() 
	raiserror (@StrErrorMessage, 16, 1)

END CATCH

END	

GO
