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

CREATE PROCEDURE [trs].[sp_api_AsmanRasa_GetBankCode]
@BankName		as Varchar(30)

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

	

	IF (SELECT count(*)	FROM trs.tblOurBanks
	where BankAccountNo=@BankName and AcntCode1 is not null and AcntCode1<>'')=0
	BEGIN
		Set @StrErrorMessage = N'برای شماره حساب '+@BankName+'حساب بانکی  در سیستم خزانه داری بانکی معرفی نشده است'
		raiserror (@StrErrorMessage, 16, 1)
	END
	
	SELECT isnull(AcntCode1 ,'') as BankCode
	FROM trs.tblOurBanks
	where BankAccountNo=@BankName

END TRY
BEGIN CATCH

	Set @StrErrorMessage = ERROR_MESSAGE() 
	raiserror (@StrErrorMessage, 16, 1)

END CATCH

END	

GO
