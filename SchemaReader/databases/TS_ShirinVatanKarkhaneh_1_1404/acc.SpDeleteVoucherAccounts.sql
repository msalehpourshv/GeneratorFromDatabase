USE TS_ShirinVatanKarkhaneh_1_1404
GO
SET ANSI_NULLS, QUOTED_IDENTIFIER ON
GO
-- =========== TS-QC:UPDATED ====================
-- Author		 : Ahmadnejad
-- Create date   : 86/05/08
-- Viewed By	 : 
-- Last Modified : 86/08/22
-- Description: < حذف یک سند حسابداری >	
-- =============================================
CREATE PROCEDURE [acc].[SpDeleteVoucherAccounts] 
	@SerialNo VarChar(10) = Null -- شماره سریال سند برای حذف
	WITH ENCRYPTION
AS
DECLARE @StrTemp		NVarChar(500)
DECLARE @IntReturnCode	Int
DECLARE @Lock			Int
Begin -- =============== S T A R T  C O D E ==========================
	SET NOCOUNT ON;

	SELECT	@IntReturnCode = DocRegisterState, @Lock = DocRegisterState
	FROM	acc.tblVoucherHdr
	WHERE	SerialNo = @SerialNo

	If @Lock > 1 
	Begin
		-- This Voucher Is Locked --
		Return -10;
	End

	If (@IntReturnCode > 1) -- Can Not Delete --
		RETURN 0 - @IntReturnCode;

	BEGIN TRANSACTION;
	BEGIN TRY
		DELETE
		FROM	acc.tblVoucherDtl
		WHERE	SerialNo = @SerialNo

		DELETE
		FROM	acc.tblVoucherHdr
		WHERE	SerialNo = @SerialNo

		COMMIT TRANSACTION;
		PRINT 'Successed!'
		RETURN 0;
	END TRY

	BEGIN CATCH
		ROLLBACK TRANSACTION;
		PRINT 'Faild!'
		PRINT Error_Message()
		RETURN -15;
	END CATCH

END
GO
