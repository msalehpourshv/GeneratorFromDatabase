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
-- [trs].[spAutoReceiptDtl] 1,1399,34,1,'1399/12/30','123456789','22  500001',50000,65431,'sdf'
Create PROCEDURE [trs].[spAutoReceiptDtl]
@ProcessNo		as Tinyint,
@FiscalYear		as Smallint,
@SerialNo		as Int,
@RowNo			as Int,
@DocDate		as CHAR(10),
@AccountNo		as Varchar(30),
@CustomerCode	as VARCHAR(20),
@Amount			as VARCHAR(20),
@ChequeNo		as Bigint,
@RowDesc		as NVARCHAR(500)

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
		(ProcessID,ProcessNo,FiscalYear,SerialNo,DocDate,ChequeDate,PayTypeID,DebitCode,CreditCode,
		 Amount,ChequeNo,LocationID,BankTypeID,BranchCode,BranchName,AccOwnerName,RowDesc)
	values
		(1,@ProcessNo,@FiscalYear,@SerialNo,@DocDate,@DocDate,3,@BankCode,@CustomerCode,
		@Amount,@ChequeNo,@LocationID,@BankTypeID,@BranchCode,@BranchName,@AccountOwnerName,@RowDesc)	
		
END TRY
BEGIN CATCH

	Set @StrErrorMessage = ERROR_MESSAGE() 
	raiserror (@StrErrorMessage, 16, 1)

END CATCH

END	

GO
