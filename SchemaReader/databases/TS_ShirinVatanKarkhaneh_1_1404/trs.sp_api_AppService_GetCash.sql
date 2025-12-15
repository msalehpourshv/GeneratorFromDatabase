USE TS_ShirinVatanKarkhaneh_1_1404
GO
SET ANSI_NULLS, QUOTED_IDENTIFIER ON
GO
-- =========== TS-QC:NOTOK ========================
-- Author        : Hadi Sadeghi
-- Create date   : 1400/02/22
-- Viewed By	 : 
-- Last Modified : 1401-01-14
-- Description   : Alian
-- =============================================
create PROCEDURE trs.sp_api_AppService_GetCash

WITH ENCRYPTION
 AS
BEGIN
Declare @StrErrorMessage As Nvarchar(1024)
Declare @BranchName		As NVARCHAR(100)
Declare @AccountOwnerName	As VARCHAR(100)
Declare @PayTypeId as tinyint=3
declare @Transfer as nvarchar(100)

BEGIN TRY

	SELECT B.BankCode,BankName FROM trs.tblOurBanks B
	JOIN trs.tblOurBanksDtl D ON B.BankCode=D.BankCode
	WHERE BankState=1
		
END TRY
BEGIN CATCH

	Set @StrErrorMessage = ERROR_MESSAGE() 
	raiserror (@StrErrorMessage, 16, 1)

END CATCH

END	

GO
