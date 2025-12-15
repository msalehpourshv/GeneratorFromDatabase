USE TS_ShirinVatanKarkhaneh_1_1404
GO
SET ANSI_NULLS, QUOTED_IDENTIFIER ON
GO
-- =========== TS-QC:NOTOK ========================
-- Author        : Alian Pour
-- Create date   : 1400/06/03
-- Viewed By	 : 
-- Last Modified : 
-- Description   : 
-- =============================================

Create PROCEDURE [trs].[sp_api_Tasnim_AutoReceiptDtl]
@ProcessNo		as Tinyint,
@FiscalYear		as Int,
@SerialNo		as Int,
@RowNo			as Int,
@DocDate		as CHAR(10),
@AccountNo		as Varchar(30),
@Amount			as VARCHAR(20),
@ChequeNo		as Bigint,
@RowDesc		as NVARCHAR(500),
@CustomerCode as NVARCHAR(20)
WITH ENCRYPTION
 AS
BEGIN

Declare @StrErrorMessage As Nvarchar(1024)
Declare @DebitCode		As VARCHAR(20)
Declare @BankCode		As VARCHAR(20)
Declare @BankTypeID		As VARCHAR(20)
Declare @LocationID		As VARCHAR(20)
Declare @BranchCode		As VARCHAR(20)
Declare @BranchName		As NVARCHAR(100)
Declare @AccountOwnerName	As VARCHAR(100)

BEGIN TRY

if(@SerialNo>0)
begin

IF @CustomerCode=''
	BEGIN
		Set @StrErrorMessage = N'لطفا کد حساب را مقداردهی کنید'
		raiserror (@StrErrorMessage, 16, 1)
	END	

	SET @BankCode=''
	
	SELECT @BankCode=BankCode,@BankTypeID=BankTypeID,@LocationID=LocationID,@BranchCode=BranchCode
	FROM trs.tblOurBanks
	where BankAccountNo=@AccountNo
	
	IF @BankCode=''
	BEGIN
		Set @StrErrorMessage = N'حساب بانکی برایش در سیستم خزانه داری بانکی معرفی نشده است'
		raiserror (@StrErrorMessage, 16, 1)
	END	
	

	SELECT @BranchName=BranchName,@AccountOwnerName=AccountOwnerName
	FROM trs.tblOurBanksDtl
	where BankCode=@BankCode
	
	
	INSERT INTO trs.tblPayDtl
		(ProcessID,ProcessNo,FiscalYear,SerialNo,RowNo,DocRowNo,DocDate,ChequeDate,PayTypeID,DebitCode,CreditCode,
		 Amount,ChequeNo,LocationID,BankTypeID,BranchCode,BranchName,AccOwnerName,RowDesc)
	values
		(1,@ProcessNo,@FiscalYear,@SerialNo,@RowNo,@RowNo,@DocDate,@DocDate,3,@BankCode,@CustomerCode,
		@Amount,@ChequeNo,@LocationID,@BankTypeID,@BranchCode,@BranchName,@AccountOwnerName,@RowDesc)	
end
END TRY
BEGIN CATCH

	Set @StrErrorMessage = ERROR_MESSAGE() 
	raiserror (@StrErrorMessage, 16, 1)

END CATCH

END	

GO
