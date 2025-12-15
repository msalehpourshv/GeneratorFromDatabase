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
Create PROCEDURE [trs].[spFrmPayReceiptRecivableReceiptSave] 
  @ProcessID	tinyint,
  @ProcessNo	tinyint,
  @FiscalYear	smallint,
  @SerialNo     int,
  @BankCode		varchar(20)=null,
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
Declare @ChequeNo			VarChar(20)
Declare @LastAmount			BigInt
Declare @LastChequeDate		Char(10)
Declare @LastChequeNo		VarChar(20)
Declare @ChequeCryptNo		VarChar(20)
Declare @DebitCode			VarChar(20)
Declare @DocDate			Char(10)
Declare @MaxDocDate			Char(10)
Declare @VolumeRowNo		Int
Declare @VolumeFiscalYear	SmallInt
Declare @MaxEventNo     	Int
Declare @RowNo           	Int

	------------------------------
	SET @strMsgText = ''

	------------------------------
	Declare	Cursor_Rec CURSOR For 
	SELECT EventNo,Amount,ChequeDate,ChequeNo,VolumeFiscalYear,VolumeRowNo,RowNo,DocDate,ChequeCryptNo
	FROM trs.tblPayDtl D
	WHERE  ProcessID=@ProcessID AND
		   ProcessNo=@ProcessNo AND
		   FiscalYear=@FiscalYear AND
		   SerialNo=@SerialNo AND 
		   (LTRIM(RTRIM(str(D.VolumeFiscalYear)))+ '#' +LTRIM(RTRIM(str(D.VolumeRowNo)))) NOT IN (SELECT LTRIM(RTRIM(str(V.VolumeFiscalYear)))+ '#' +LTRIM(RTRIM(str(V.VolumeRowNo))) FROM #tblVolumeNo V)
	ORDER BY D.DocRowNo
	------------------------------
	Open  Cursor_Rec; 

	Fetch NEXT From Cursor_Rec Into @EventNo,@Amount,@ChequeDate,@ChequeNo,@VolumeFiscalYear,@VolumeRowNo,@RowNo,@DocDate,@ChequeCryptNo

	While (@@Fetch_Status = 0)
	BEGIN
	IF @EventNo = 0
			BEGIN
				IF @VolumeFiscalYear <> @FiscalYear 
					BEGIN
						BEGIN TRY
							DECLARE @str Nvarchar(4000)

							SET @str = 'INSERT INTO trs.tblPayHdr 
								SELECT A.* FROM ' + LEFT(db_name(), Len(db_name()) - 4) + LTRIM(STR(@VolumeFiscalYear)) + '.trs.tblPayHdr A
								INNER JOIN 
								(SELECT H.ProcessID,H.ProcessNo,H.FiscalYear,H.SerialNo FROM ' + LEFT(db_name(), Len(db_name()) - 4) + LTRIM(STR(@VolumeFiscalYear)) + '.trs.tblPayHdr H
								 INNER JOIN ' + LEFT(db_name(), Len(db_name()) - 4) +  LTRIM(STR(@VolumeFiscalYear)) + '.trs.tblPayDtl D
								 ON  H.ProcessID = D.ProcessID AND H.ProcessNo =D.ProcessNo AND H.FiscalYear=D.FiscalYear AND H.SerialNo = D.SerialNo 
								 AND D.ProcessID <= 24 AND VolumeFiscalYear = ' + LTRIM(STR(@VolumeFiscalYear)) + ' AND VolumeRowNo =' + LTRIM(STR(@VolumeRowNo)) + '
								 EXCEPT 
								 SELECT H.ProcessID,H.ProcessNo,H.FiscalYear,H.SerialNo FROM trs.tblPayHdr H
								 INNER JOIN  trs.tblPayDtl D
								 ON  H.ProcessID = D.ProcessID AND H.ProcessNo =D.ProcessNo AND H.FiscalYear=D.FiscalYear AND H.SerialNo = D.SerialNo 
								 AND D.ProcessID <= 24 AND VolumeFiscalYear =  ' + LTRIM(STR(@VolumeFiscalYear)) + ' AND VolumeRowNo =' + LTRIM(STR(@VolumeRowNo)) + ' ) B
								 ON A.ProcessID=B.ProcessID AND A.ProcessNo=B.ProcessNo AND A.FiscalYear=B.FiscalYear AND A.SerialNo=B.SerialNo; '

							SET @str = @str + 'INSERT INTO trs.tblPayDtl
							            (ProcessID, ProcessNo, FiscalYear, SerialNo, RowNo, DocDate, PayTypeID, DebitCode, CreditCode, Amount, CurrencyTypeID, CurrencyRate, ChequeNo, 
										ChequeBookFiscalYear, ChequeBookID, ChequeDate, VolumeFiscalYear, VolumeRowNo, EventNo, LocationID, BankTypeID, BranchCode, BranchName, BankSnNo,
										AccountNo, AccOwnerName, LocationID2, BankTypeID2, BranchCode2, BranchName2, AccountNo2, AccOwnerName2, DeliverTo, RowDesc, DocRowNo, IsConfirmed, 
										AccountOwnerType, BaseSerialNo, BaseFiscalYear, WithdrawType, CurrencyAmount, VisitorAcntCode, EndDate_PayableTrust, SourceSerialNo, SourceProcessNo,
										WithAcntCode,ChequeCryptNo)
								SELECT A.ProcessID, A.ProcessNo, A.FiscalYear, A.SerialNo, A.RowNo, A.DocDate, A.PayTypeID, A.DebitCode, 
									   A.CreditCode, A.Amount, A.CurrencyTypeID, A.CurrencyRate, A.ChequeNo, A.ChequeBookFiscalYear, 
									   A.ChequeBookID, A.ChequeDate, A.VolumeFiscalYear, A.VolumeRowNo, A.EventNo, A.LocationID, A.BankTypeID, 
									   A.BranchCode, A.BranchName, A.BankSnNo, A.AccountNo, A.AccOwnerName, A.LocationID2, A.BankTypeID2, 
									   A.BranchCode2, A.BranchName2, A.AccountNo2, A.AccOwnerName2, A.DeliverTo, A.RowDesc, A.DocRowNo, 
									   A.IsConfirmed, A.AccountOwnerType, A.BaseSerialNo, A.BaseFiscalYear, A.WithdrawType, A.CurrencyAmount, 
									   A.VisitorAcntCode, A.EndDate_PayableTrust, A.SourceSerialNo, A.SourceProcessNo, A.WithAcntCode, A.ChequeCryptNo 
								FROM ' + LEFT(db_name(), Len(db_name()) - 4) + LTRIM(STR(@VolumeFiscalYear)) + '.trs.tblPayDtl A
								INNER JOIN 
								(SELECT ProcessID,ProcessNo,FiscalYear,SerialNo,VolumeFiscalYear,VolumeRowNo 
								 FROM ' + LEFT(db_name(), Len(db_name()) - 4) + LTRIM(STR(@VolumeFiscalYear)) + '.trs.tblPayDtl
								 WHERE PayTypeID in (6,26) AND ProcessNo=' + LTRIM(STR(@ProcessNo)) + '  AND ProcessID <= 24 AND VolumeFiscalYear = ' + LTRIM(STR(@VolumeFiscalYear)) + 'AND VolumeRowNo =' + LTRIM(STR(@VolumeRowNo)) + '
 								 EXCEPT 
								 SELECT ProcessID,ProcessNo,FiscalYear,SerialNo,VolumeFiscalYear,VolumeRowNo FROM trs.tblPayDtl
								 WHERE PayTypeID in (6,26) AND ProcessNo=' + LTRIM(STR(@ProcessNo)) + '  AND ProcessID <= 24 AND VolumeFiscalYear = ' + LTRIM(STR(@VolumeFiscalYear)) + 'AND VolumeRowNo =' + LTRIM(STR(@VolumeRowNo)) + ' 
								 ) B
								 ON A.ProcessID=B.ProcessID AND A.ProcessNo=B.ProcessNo AND A.FiscalYear=B.FiscalYear AND A.SerialNo=B.SerialNo'
							Exec sp_executesql @str;
						END TRY
						BEGIN CATCH
							PRINT ERROR_MESSAGE() 
						END CATCH
					END
				------------------------------
				SELECT @MaxEventNo=ISNULL(MAX(EventNo),0)
				FROM trs.tblPayDtl 
				WHERE VolumeFiscalYear=@VolumeFiscalYear AND  
					  VolumeRowNo=@VolumeRowNo AND 
					  PayTypeID IN (6,26)

				IF @MaxEventNo = 0
					BEGIN
						Close Cursor_Rec;
						Deallocate Cursor_Rec;
						--شماره چک  %s حذف شده است
						SET @strMsgText=TS.pub.funGetMessages(12042,@LanguageID)
						Raiserror (@strMsgText,16,1,@ChequeNo) 
						Return
					END

				SELECT @MaxDocDate = DocDate
				FROM trs.tblPayDtl 
				WHERE VolumeFiscalYear=@VolumeFiscalYear AND  
					  VolumeRowNo=@VolumeRowNo AND 
					  EventNo = @MaxEventNo AND
					  PayTypeID IN (6,26)
					  
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
				SELECT @LastProcessID=ProcessID,@LastAmount=Amount,@LastChequeDate=ChequeDate,@LastChequeNo=ChequeNo,@DebitCode=DebitCode, @ChequeCryptNo = ChequeCryptNo
				FROM trs.tblPayDtl 
				WHERE VolumeFiscalYear=@VolumeFiscalYear AND  
					VolumeRowNo=@VolumeRowNo AND 
					PayTypeID IN (6,26) AND
					EventNo=@MaxEventNo 

				IF @BankCode IS NOT null AND @BankCode <> '' AND @DebitCode <> @BankCode
					--شماره چک  %s در صندوق موجود نيست
					SET @strMsgText=TS.pub.funGetMessages(12043,@LanguageID)
				
				------------------------------
				IF (@ProcessID=12 AND @BankCode = '' ) AND
					NOT (@LastProcessID=13 OR @LastProcessID=18 OR @LastProcessID=24)
						SET @strMsgText=N'آخرین وضعیت شماره چک '+@LastChequeNo+' برگشتی نیست'

				ELSE IF (@ProcessID=12 OR @ProcessID=13 OR @ProcessID=21)AND @BankCode <> '' AND
					NOT (@LastProcessID=1 OR @LastProcessID=10 OR @LastProcessID=17 OR @LastProcessID=23 OR @LastProcessID=40)

						--شماره چک  %s در صندوق موجود نیست
						SET @strMsgText=TS.pub.funGetMessages(12043,@LanguageID)

				ELSE IF (@ProcessID=17 OR @ProcessID=18) AND
					NOT (@LastProcessID=2)

						--شماره چک  %s به شخص موردنظر واگذار نشده است
						SET @strMsgText=TS.pub.funGetMessages(12044,@LanguageID)

				ELSE IF (@ProcessID=22 OR @ProcessID=23 OR @ProcessID=24) AND
					NOT (@LastProcessID=20 OR @LastProcessID=21 )

						--شماره چک  %s به بانک موردنظر واگذار نشده است 
						SET @strMsgText=TS.pub.funGetMessages(12045,@LanguageID)

				------------------------------
				ELSE IF @LastAmount <> @Amount
					--مبلغ شماره چک  %s فرق کرده است
					SET @strMsgText=TS.pub.funGetMessages(12046,@LanguageID)

				------------------------------
				ELSE IF @LastChequeNo <> @ChequeNo
					--شماره چک  %s فرق کرده است
					SET @strMsgText=TS.pub.funGetMessages(12047,@LanguageID)

				------------------------------
				ELSE IF (@LastChequeDate<>@ChequeDate)
					--تاریخ شماره چک %s فرق کرده است
					SET @strMsgText=TS.pub.funGetMessages(12048,@LanguageID)

				------------------------------
				IF @strMsgText <> ''
					BEGIN
						Close Cursor_Rec;
						Deallocate Cursor_Rec;
						Raiserror (@strMsgText,16,1,@ChequeNo)
						Return
					END 

				------------------------------
				Declare @TempDebitCode Varchar(20)
				Declare @TempCreditCode Varchar(20)

				IF @ProcessID = 12 and @BankCode='' 
					SELECT TOP 1 @TempDebitCode=DebitCode --[trs].[funGetChequeOwner] (@VolumeFiscalYear,@VolumeRowNo,PayTypeID)
					FROM trs.tblPayDtl 
					WHERE VolumeFiscalYear=@VolumeFiscalYear AND  
						  VolumeRowNo=@VolumeRowNo AND 
						  PayTypeID IN (6,26)
					ORDER BY EventNo Desc

				else IF @ProcessID = 12 OR @ProcessID = 13 
					SELECT TOP 1 @TempDebitCode=DebitCode
					FROM trs.tblPayDtl 
					WHERE VolumeFiscalYear=@VolumeFiscalYear AND  
						  VolumeRowNo=@VolumeRowNo AND 
						  PayTypeID IN (6,26)
					ORDER BY EventNo Desc

				IF @ProcessID = 13 OR @ProcessID = 18 OR @ProcessID = 24 -- برگشت چک صاحب چک
					SELECT @TempCreditCode=CreditCode
					FROM trs.tblPayDtl
					WHERE	ProcessID IN (1,10) AND
							VolumeFiscalYear=@VolumeFiscalYear AND
							VolumeRowNo=@VolumeRowNo

				------------------------------
				IF @ProcessID = 13 
					UPDATE trs.tblPayDtl 
					SET EventNo=@MaxEventNo+1 --,DebitCode=@TempCreditCode,CreditCode=@TempDebitCode
					WHERE  ProcessID=@ProcessID AND
						   ProcessNo=@ProcessNo AND
						   FiscalYear=@FiscalYear AND
						   SerialNo=@SerialNo AND 
						   RowNo=@RowNo

				ELSE IF @ProcessID = 12 
					UPDATE trs.tblPayDtl SET EventNo=@MaxEventNo+1,CreditCode=@TempDebitCode
					WHERE  ProcessID=@ProcessID AND
						   ProcessNo=@ProcessNo AND
						   FiscalYear=@FiscalYear AND
						   SerialNo=@SerialNo AND 
						   RowNo=@RowNo

				ELSE IF @ProcessID = 18 OR @ProcessID = 24
					UPDATE trs.tblPayDtl SET EventNo=@MaxEventNo+1 --,DebitCode=@TempCreditCode
					WHERE  ProcessID=@ProcessID AND
						   ProcessNo=@ProcessNo AND
						   FiscalYear=@FiscalYear AND
						   SerialNo=@SerialNo AND 
						   RowNo=@RowNo

				ELSE 
					UPDATE trs.tblPayDtl SET EventNo=@MaxEventNo+1 
					WHERE  ProcessID=@ProcessID AND
						   ProcessNo=@ProcessNo AND
						   FiscalYear=@FiscalYear AND
						   SerialNo=@SerialNo AND 
						   RowNo=@RowNo
		End
		ELSE
			BEGIN
				SELECT @MaxDocDate = DocDate
				FROM trs.tblPayDtl 
				WHERE VolumeFiscalYear=@VolumeFiscalYear AND  
						VolumeRowNo=@VolumeRowNo AND 
						EventNo = @EventNo-1 AND
						PayTypeID IN (6,26)
					  
				IF @MaxDocDate > @DocDate
					BEGIN
						Close Cursor_Rec;
						Deallocate Cursor_Rec;
						--تاریخ جاری از تاریخ آخرین حالت چک کوچکتر است
						SET @strMsgText=TS.pub.funGetMessages(12080,@LanguageID)
						Raiserror (@strMsgText,16,1) 
						Return
					END
				
				SET @MaxDocDate = ''
				SELECT @MaxDocDate = MIN(DocDate)
				FROM trs.tblPayDtl 
				WHERE VolumeFiscalYear=@VolumeFiscalYear AND  
						VolumeRowNo=@VolumeRowNo AND 
						EventNo > @EventNo AND
						PayTypeID IN (6,26)

				IF @MaxDocDate < @DocDate
					BEGIN
						Close Cursor_Rec;
						Deallocate Cursor_Rec;
						--تاریخ جاری از تاریخ گردش بعدی  کوچکتر است
						SET @strMsgText='تاریخ جاری از تاریخ گردش بعدی چک به شماره ردیف دفتر ' + LTRIM(STR(@VolumeRowNo)) + ' بزرگتر است '
						Raiserror (@strMsgText,16,1) 
						Return
					END

				SELECT @MaxEventNo=ISNULL(MAX(EventNo),0)
				FROM trs.tblPayDtl 
				WHERE VolumeFiscalYear=@VolumeFiscalYear AND  
					  VolumeRowNo=@VolumeRowNo AND 
					  PayTypeID IN (6,26) AND 
					  not( ProcessID =@ProcessID	AND 
						 ProcessNo=@ProcessNo	AND
						 FiscalYear=@FiscalYear AND
						 SerialNo=@SerialNo)
				IF @MaxEventNo = 0
					BEGIN
						Close Cursor_Rec;
						Deallocate Cursor_Rec;
						--شماره چک  %s حذف شده است
						SET @strMsgText=TS.pub.funGetMessages(12042,@LanguageID)
						Raiserror (@strMsgText,16,1,@ChequeNo) 
						Return
					END

				SELECT @LastProcessID=ProcessID,@LastAmount=Amount,@LastChequeDate=ChequeDate,@LastChequeNo=ChequeNo,@DebitCode=DebitCode, @ChequeCryptNo = ChequeCryptNo
				FROM trs.tblPayDtl 
				WHERE VolumeFiscalYear=@VolumeFiscalYear AND  
					VolumeRowNo=@VolumeRowNo AND 
					PayTypeID IN (6,26) AND
					EventNo=@MaxEventNo AND 
					not( ProcessID =@ProcessID	AND 
						 ProcessNo=@ProcessNo	AND
						 FiscalYear=@FiscalYear AND
						 SerialNo=@SerialNo)

				IF @BankCode IS NOT null AND @BankCode <> '' AND @DebitCode <> @BankCode
					--شماره چک  %s در صندوق موجود نيست
					SET @strMsgText=TS.pub.funGetMessages(12043,@LanguageID)

				------------------------------
				IF @strMsgText <> ''
					BEGIN
						Close Cursor_Rec;
						Deallocate Cursor_Rec;
						Raiserror (@strMsgText,16,1,@ChequeNo)
						Return
					END 
			END			
	
			------------------------------
			Fetch NEXT From Cursor_Rec Into @EventNo,@Amount,@ChequeDate,@ChequeNo,@VolumeFiscalYear,@VolumeRowNo,@RowNo,@DocDate, @ChequeCryptNo

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
