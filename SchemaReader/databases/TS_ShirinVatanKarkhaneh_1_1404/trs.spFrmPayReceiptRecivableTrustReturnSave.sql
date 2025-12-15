USE TS_ShirinVatanKarkhaneh_1_1404
GO
SET ANSI_NULLS, QUOTED_IDENTIFIER ON
GO
-- =========== TS-QC:OK ========================
-- Author        : Hadi Sadeghi
-- Create date   : 86/07/04
-- Viewed By	 : Majid Mohammadi
-- Last Modified : 86/11/23
-- Description   : Control Receipt Saving
-- =============================================
Create PROCEDURE [trs].[spFrmPayReceiptRecivableTrustReturnSave] 
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
Declare @ProcessIDTemp		Tinyint
Declare @EventNo			Int
Declare @Amount		        BigInt
Declare @ChequeDate			Char(10)
Declare @DocDate			Char(10)
Declare @MaxDocDate			Char(10)
Declare @ChequeNo			VarChar(20)
Declare @LastAmount		BigInt
Declare @LastChequeDate	Char(10)
Declare @LastChequeNo	VarChar(20)
Declare @rr		            NVarChar(500)
Declare @SumAcntCode		float
Declare @VolumeRowNo		Int
Declare @VolumeFiscalYear	SmallInt
Declare @MaxEventNo     	Int
Declare @RowNo           	Int
Declare @CreditCode			varchar(20)
Declare @DebitCode			varchar(20)

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
						ProcessNo=@ProcessNo AND 
						EventNo = @EventNo-1 AND
						PayTypeID IN (16,31,34)

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

				------------------------------
				SELECT @MaxEventNo=ISNULL(MAX(EventNo),0)
				FROM trs.tblPayDtl 
				WHERE VolumeFiscalYear=@VolumeFiscalYear AND  
					VolumeRowNo=@VolumeRowNo AND 
					ProcessNo=@ProcessNo AND 
					PayTypeID IN (16,31,34)

				IF @MaxEventNo = 0
				   BEGIN
				   		Close Cursor_Rec;
						Deallocate Cursor_Rec; 
						--شماره چک  %s حذف شده است
						SET @strMsgText=TS.pub.funGetMessages(12049,@LanguageID)
						Raiserror (@strMsgText,16,1,@ChequeNo) 
						Return
				   END

				SELECT @MaxDocDate = DocDate
				FROM trs.tblPayDtl 
				WHERE VolumeFiscalYear=@VolumeFiscalYear AND  
					  VolumeRowNo=@VolumeRowNo AND 
					  ProcessNo=@ProcessNo AND 
					  EventNo = @MaxEventNo AND 
					  PayTypeID IN (16,31,34)
					  
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
				SELECT @ProcessIDTemp=ProcessID,@LastAmount=Amount,@LastChequeDate=ChequeDate,@LastChequeNo=ChequeNo
				FROM trs.tblPayDtl 
				WHERE VolumeFiscalYear=@VolumeFiscalYear AND  
					VolumeRowNo=@VolumeRowNo AND 
					ProcessNo=@ProcessNo AND 
					PayTypeID IN (16,31,34) AND
					EventNo=@MaxEventNo 

				------------------------------
				IF @ProcessIDTemp = 32
					--شماره چک  %s قبلا استرداد شده است
					SET @strMsgText=TS.pub.funGetMessages(12050,@LanguageID)

				ELSE IF @LastAmount <> @Amount
					--مبلغ شماره چک  %s فرق کرده است
					SET @strMsgText=TS.pub.funGetMessages(12051,@LanguageID)

				ELSE IF @LastChequeNo <> @ChequeNo
					--شماره چک  %s فرق کرده است
					SET @strMsgText=TS.pub.funGetMessages(12052,@LanguageID)

				ELSE IF @LastChequeDate <> @ChequeDate
					--تاریخ شماره چک %s فرق کرده است
					SET @strMsgText=TS.pub.funGetMessages(12053,@LanguageID)

				------------------------------
				IF @strMsgText <> ''
					BEGIN
						Close Cursor_Rec;
						Deallocate Cursor_Rec; 
						Raiserror (@strMsgText,16,1,@ChequeNo)
						Return
					END 

				SELECT TOP 1 @CreditCode=CreditCode,@DebitCode=DebitCode  
				FROM trs.tblPayDtl 
				WHERE ProcessID =31 AND
					  VolumeFiscalYear=@VolumeFiscalYear AND  
					  ProcessNo=@ProcessNo AND 
					  VolumeRowNo=@VolumeRowNo AND 
					  PayTypeID IN (16,31,34)
				ORDER BY EventNo
 
				------------------------------
				UPDATE trs.tblPayDtl SET EventNo=@MaxEventNo+1 ,CreditCode=@DebitCode ,DebitCode=@CreditCode
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

	SELECT RowNo,VolumeFiscalYear,VolumeRowNo,EventNo
	FROM trs.tblPayDtl 
	WHERE ProcessID=@ProcessID AND
		  ProcessNo=@ProcessNo AND
		  FiscalYear=@FiscalYear AND
		  SerialNo=@SerialNo 
	ORDER BY DocRowNo

END
GO
