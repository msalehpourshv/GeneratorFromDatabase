USE TS_ShirinVatanKarkhaneh_1_1404
GO
SET ANSI_NULLS, QUOTED_IDENTIFIER ON
GO
-- =========== TS-QC:NOTOK ====================
-- Author		 : Hadi Sadeghi
-- Create date   : 86/03/26
-- Viewed By	 : 
-- Last Modified : 
-- Description	 : 
-- ==============================================

CREATE PROCEDURE [trs].[SpBankVoidChequesControl]
	@BankCode VarChar(20),
	@LanguageID Tinyint
WITH ENCRYPTION
AS
BEGIN
	SET NOCOUNT ON;

	Declare @ChequeNo		BigInt
	Declare @RowNo		    INT
	Declare @ChequeBookID	smallint
	Declare @strMsgText	    NVarchar(2044)
	declare @StrChequeNo VARCHAR(100)

	Declare	Cursor_Cheques CURSOR For 
    SELECT ChequeNo,DocRowNo,ChequeBookID
    FROM trs.tblBankVoidChequesDtl
    WHERE  BankCode=@BankCode

	Open  Cursor_Cheques; 
	Fetch NEXT From Cursor_Cheques Into @ChequeNo, @RowNo,@ChequeBookID
	While (@@Fetch_Status = 0)
	BEGIN
		SET @StrChequeNo = @ChequeNo
		IF ( SELECT count(*)
				FROM trs.tblBankChequesDtl
				WHERE BankCode=@BankCode AND 
					  FromChequeNo<= @ChequeNo  AND
					  ToChequeNo>= @ChequeNo )=0
			BEGIN
				Close Cursor_Cheques;
				Deallocate Cursor_Cheques; 
				--چكي به شماره %s در سطر %d وجود ندارد
				SET @strMsgText=TS.pub.funGetMessages(12072,@LanguageID)
				Raiserror (@strMsgText,16,1,@StrChequeNo,@RowNo)
				Return

			END
			ELSE
			BEGIN
				Declare @ProcessID  tinyint
				SELECT TOP 1 isnull(ProcessID ,27)
				FROM trs.tblPayDtl 
				WHERE ChequeBookID =@ChequeBookID  AND
					  ProcessID= 3 AND
					  PayTypeID in (7,8,28) AND
					  ChequeNo= @ChequeNo
				ORDER BY EventNo DESC
					IF @@rowcount>0
						BEGIN
							IF @ProcessID <>27
								BEGIN
									Close Cursor_Cheques;
									Deallocate Cursor_Cheques; 
									--چكي به شماره %s در سطر %d قابل برگشت نیست
									SET @strMsgText=TS.pub.funGetMessages(12073,@LanguageID)
									Raiserror (@strMsgText,16,1,@StrChequeNo,@RowNo)
									Return
								END
						END
					end

		Fetch NEXT From Cursor_Cheques Into  @ChequeNo, @RowNo,@ChequeBookID
	End
	Close Cursor_Cheques;
	Deallocate Cursor_Cheques; 
END
GO
