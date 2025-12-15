USE TS_ShirinVatanKarkhaneh_1_1404
GO
SET ANSI_NULLS, QUOTED_IDENTIFIER ON
GO
-- =========== TS-QC:UPDATE ========================
-- Author        : Hadi Sadeghi
-- Create date   : 86/07/04
-- Viewed By	 : Hadi Sadeghi
-- Last Modified : 87/02/14
-- Description   : Control Receipt Saving
-- =============================================
CREATE PROCEDURE [trs].[spFrmPayReceiptPayableReceiptSave] 
  @ProcessID	tinyint,
  @ProcessNo	tinyint,
  @FiscalYear	smallint,
  @SerialNo     int,
  @LanguageID   TinyInt=1
  WITH ENCRYPTION
AS

BEGIN

SET NOCOUNT ON;

Declare @strMsgText			NVarChar(2044)
Declare @LastProcessID		Tinyint
Declare @EventNo			Int
Declare @Amount		        BigInt
Declare @ChequeDate			Char(10)
Declare @DocDate			Char(10)
Declare @MaxDocDate			Char(10)
Declare @ChequeNo			VarChar(20)
Declare @LastAmount			BigInt
Declare @LastChequeDate		Char(10)
Declare @LastChequeNo		VarChar(20)
Declare @VolumeRowNo		Int
Declare @VolumeFiscalYear	SmallInt
Declare @MaxEventNo     	Int
Declare @RowNo           	SmallInt

	------------------------------
	SET @strMsgText = ''

	------------------------------
	Declare	Cursor_Rec CURSOR For 
    SELECT EventNo,Amount,ChequeDate,ChequeNo,VolumeFiscalYear,VolumeRowNo,RowNo,DocDate
    FROM trs.tblPayDtl 
    WHERE  ProcessID=@ProcessID AND
           ProcessNo=@ProcessNo AND
           FiscalYear=@FiscalYear AND
           SerialNo=@SerialNo

	------------------------------
	Open  Cursor_Rec; 

	Fetch NEXT From Cursor_Rec Into @EventNo,@Amount,@ChequeDate,@ChequeNo,@VolumeFiscalYear,@VolumeRowNo,@RowNo,@DocDate

		While (@@Fetch_Status = 0)
		BEGIN

			IF  @EventNo > 0
				BEGIN
					SELECT @MaxDocDate = DocDate
					FROM trs.tblPayDtl 
					WHERE VolumeFiscalYear=@VolumeFiscalYear AND  
						  VolumeRowNo=@VolumeRowNo AND 
						  EventNo = @EventNo-1 AND 
						  PayTypeID IN (7,8,28) 
					  
					IF @MaxDocDate > @DocDate
						BEGIN
							Close Cursor_Rec;
							Deallocate Cursor_Rec;
							--تاریخ جاری از تاریخ آخرین حالت چک کوچکتر است
							SET @strMsgText=TS.pub.funGetMessages(12080,@LanguageID)
							Raiserror (@strMsgText,16,1) 
							Return
						END
				END
			ELSE IF @EventNo = 0
				BEGIN

				-- 1388/01/22 Hadi
			--	IF @VolumeFiscalYear > 0 AND @VolumeFiscalYear < @FiscalYear
			--		BEGIN
					
			--		END
				
				SELECT @MaxEventNo=ISNULL(MAX(EventNo),0)
                FROM trs.tblPayDtl 
                WHERE VolumeFiscalYear=@VolumeFiscalYear AND  
                      VolumeRowNo=@VolumeRowNo AND 
                      PayTypeID IN (7,8,28) 

				------------------------------
				IF @MaxEventNo = 0
					BEGIN
						Close Cursor_Rec;
						Deallocate Cursor_Rec; 
						--شماره چک  %s حذف شده است
						SET @strMsgText=TS.pub.funGetMessages(12023,@LanguageID)
						Raiserror (@strMsgText,16,1,@ChequeNo)
						Return
					END
					
				SELECT @MaxDocDate = DocDate
				FROM trs.tblPayDtl 
				WHERE VolumeFiscalYear=@VolumeFiscalYear AND  
					  VolumeRowNo=@VolumeRowNo AND 
					  EventNo = @MaxEventNo AND 
                      PayTypeID IN (7,8,28) 
					  
				IF @MaxDocDate > @DocDate
					BEGIN
						Close Cursor_Rec;
						Deallocate Cursor_Rec;
						--تاریخ جاری از تاریخ آخرین حالت چک کوچکتر است
						SET @strMsgText=TS.pub.funGetMessages(12080,@LanguageID)
						Raiserror (@strMsgText,16,1) 
						Return
					END
				------------------------------
				SELECT @LastProcessID=ProcessID,@LastAmount=Amount,@LastChequeDate=ChequeDate,@LastChequeNo=ChequeNo
                FROM trs.tblPayDtl 
                WHERE VolumeFiscalYear=@VolumeFiscalYear AND  
                      VolumeRowNo=@VolumeRowNo AND 
                      ProcessID IN (2,25,27,28) AND
                      EventNo=@MaxEventNo 

				------------------------------
				IF @LastProcessID = 27
					--شماره چک  %s قبلا وصول شده است
					SET @strMsgText=TS.pub.funGetMessages(12024,@LanguageID)

				ELSE IF (@LastProcessID=28) 
					--شماره چک  %s قبلا برگشت داده شده است
					SET @strMsgText=TS.pub.funGetMessages(12025,@LanguageID)

				ELSE IF @LastAmount <> @Amount
					--مبلغ شماره چک  %s فرق کرده است
					SET @strMsgText=TS.pub.funGetMessages(12026,@LanguageID)

				ELSE IF (@LastChequeNo<>@ChequeNo)
					--شماره چک  %s فرق کرده است
					SET @strMsgText=TS.pub.funGetMessages(12027,@LanguageID)

				ELSE IF (@LastChequeDate<>@ChequeDate)
					--تاریخ شماره چک %s فرق کرده است
					SET @strMsgText=TS.pub.funGetMessages(12028,@LanguageID)

				------------------------------
				IF @strMsgText <> ''
					BEGIN
						Close Cursor_Rec;
						Deallocate Cursor_Rec; 
						Raiserror (@strMsgText,16,1,@ChequeNo) 
						Return
					END 

				------------------------------
				UPDATE trs.tblPayDtl SET EventNo=@MaxEventNo+1 
				WHERE  ProcessID=@ProcessID AND
					   ProcessNo=@ProcessNo AND
					   FiscalYear=@FiscalYear AND
					   SerialNo=@SerialNo AND 
					   RowNo=@RowNo
			END
			-- 1387/02/14 Hadi
			IF @ProcessID = 28
			BEGIN
				DECLARE @DebitCode varchar(20)
						
				SELECT TOP 1 @DebitCode=DebitCode
				FROM trs.tblPayDtl RD
				WHERE RD.VolumeFiscalYear=@VolumeFiscalYear AND
						RD.VolumeRowNo=@VolumeRowNo AND
						RD.ProcessID IN (2,25) AND PayTypeID IN (7,8,28)
				ORDER BY RD.EventNo

				UPDATE trs.tblPayDtl SET CreditCode=@DebitCode 
				WHERE  ProcessID=@ProcessID AND
						ProcessNo=@ProcessNo AND
						FiscalYear=@FiscalYear AND
						SerialNo=@SerialNo AND 
						RowNo=@RowNo
			END
		Fetch NEXT From Cursor_Rec Into @EventNo,@Amount,@ChequeDate,@ChequeNo,@VolumeFiscalYear,@VolumeRowNo,@RowNo,@DocDate
		End

	------------------------------
	Close Cursor_Rec;
	Deallocate Cursor_Rec; 

	update trs.tblPayDtl
	set ChequeBookID=b.ChequeBookID,ChequeBookFiscalYear=b.FiscalYear
	from trs.tblPayDtl p
	inner join trs.tblBankChequesDtl b
	on p.DebitCode = b.BankCode
	where ProcessID = @ProcessID  AND
		  ProcessNo = @ProcessNo  AND
		  p.FiscalYear= @FiscalYear AND
		  SerialNo  = @SerialNo AND
		  ProcessID in (27,28) AND PayTypeID in (7,8,18,28) AND 
		  ChequeNo>=b.FromChequeNo AND ChequeNo<=b.ToChequeNo AND 
		 (p.ChequeBookFiscalYear <> b.FiscalYear OR p.ChequeBookID<>b.ChequeBookID)
	     
	SELECT RowNo,VolumeFiscalYear,VolumeRowNo,EventNo
	FROM trs.tblPayDtl 
	WHERE ProcessID=@ProcessID AND
		  ProcessNo=@ProcessNo AND
		  FiscalYear=@FiscalYear AND
		  SerialNo=@SerialNo 
	ORDER BY DocRowNo

END
GO
