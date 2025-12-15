USE TS_ShirinVatanKarkhaneh_1_1404
GO
SET ANSI_NULLS, QUOTED_IDENTIFIER ON
GO
-- =========== TS-QC:OK ========================
-- Author        : Hadi Sadeghi
-- Create date   : 86/07/04
-- Viewed By	 : Majid Mohammadi
-- Last Modified : 86/11/23
-- Description   : 
-- =============================================
Create PROCEDURE [acc].[SpVchReceivableTrust]
	@intVchNo				Int,
	@intDocStep				TinyInt,
    @strVchDate				Char(10),
	@intSourceProcessID		TinyInt,
	@intSourceProcessNo		TinyInt,
	@intSourceFiscalYear	SmallInt,
	@intSourceSerialNo		Int,
	@intMaxRowNo			Int,
	@intMaxDocRowNo			Int,
	@SessionNo				Int,
	@LanguageID				TinyInt
	WITH ENCRYPTION
AS

BEGIN

	-----
	Declare @strMsgText	 NVarChar(2044)
	Declare @PayTypeID	Tinyint
	Declare @Amount		float
	Declare @RowDesc	Nvarchar(1000)	
	Declare @CreditCode	Varchar(20)
	Declare @ChequeNo	Bigint
	Declare @ChequeDate	Char(10)
	Declare @AcntCode4	Varchar(20)
	Declare @strRecDesc NVarChar(1000)
	Declare @CurrencyAmount	Float
	DECLARE @strSourceProcessNo NVARCHAR(100)
	DECLARE @DocRowNo   Int
	DECLARE @AtomAcntCode Varchar(20)
	Declare @CurrencyTypeID	VarChar(20)
	DECLARE @AtomAmount FLOAT 
	DECLARE @AtomDesc   Nvarchar(2000)	
	Declare @CurrencyAmountAtom	Float
	Declare @CurrencyRate	Float
	DECLARE @AcntDiscount  Varchar(20)
	DECLARE  @DiscountAmount float
	DECLARE @AcntName   NVarchar(1000)
	DECLARE @BaseID Int
			
	DECLARE @CurrencyRateTmp			Float
	DECLARE @CurrencyAmountTmp			Float
	DECLARE @CurrencyTypeIDTmp			VarChar(20)
			
	SET @CurrencyRate = 0
	SET @CurrencyAmountAtom = 0
	SET @CurrencyAmount = 0
	SET @CurrencyTypeID = ''
	SET @CurrencyRateTmp = 0
	SET @CurrencyAmountTmp = 0
	SET @CurrencyTypeIDTmp = ''
	
	IF  @intSourceProcessNo< 2
		SET @strSourceProcessNo = ''
	ELSE
		SET @strSourceProcessNo = LTRIM(RTRIM(STR(@intSourceProcessNo)))

	-----
	SELECT	@CurrencyRate=CurrencyRate,@CurrencyTypeID=CurrencyTypeID
	FROM trs.tblPayHdr
	WHERE ProcessID=@intSourceProcessID AND
		  ProcessNo=@intSourceProcessNo AND
		  FiscalYear=@intSourceFiscalYear AND
		  SerialNo=@intSourceSerialNo 

	--------------------------------------------------------------------------------------------------------
	Declare	Cursor_PayDtl CURSOR For 
	SELECT	PayTypeID,Amount,RowDesc,ChequeNo,ChequeDate,CreditCode,AcntCode4,CurrencyAmount,DocRowNo,RD.ID
	FROM	trs.tblPayDtl RD,trs.tblOurBanks OB
	WHERE	RD.DebitCode=OB.BankCode AND
			RD.ProcessID=@intSourceProcessID AND
			RD.ProcessNo=@intSourceProcessNo AND
			RD.FiscalYear=@intSourceFiscalYear AND
			RD.SerialNo=@intSourceSerialNo 
	order by RD.DocRowNo

	Open  Cursor_PayDtl; 

	Fetch NEXT From Cursor_PayDtl Into @PayTypeID,@Amount,@RowDesc,@ChequeNo,@ChequeDate,@CreditCode,@AcntCode4,@CurrencyAmount,	@DocRowNo   ,@BaseID

	While (@@Fetch_Status = 0)
		BEGIN
			------------------------------------------------
			IF @PayTypeID=16
			BEGIN
							
				SET @strRecDesc = ' اسناد امانی دیگران نزد ما ' + @strSourceProcessNo + ' شماره' + LTRIM(RTRIM(STR(@intSourceFiscalYear))) + '/' + LTRIM(RTRIM(STR(@intSourceSerialNo))) +
							  ' به شماره چک ' + LTRIM(RTRIM(STR(@ChequeNo,30))) + ' به سررسید ' + @ChequeDate
			END
			
			IF @PayTypeID=31
			BEGIN
							
				SET @strRecDesc = ' اسناد امانی دیگران نزد ما ' + @strSourceProcessNo + ' شماره' + LTRIM(RTRIM(STR(@intSourceFiscalYear))) + '/' + LTRIM(RTRIM(STR(@intSourceSerialNo))) +
							  ' به شماره سفته ' + LTRIM(RTRIM(STR(@ChequeNo,30))) + ' به سررسید ' + @ChequeDate
			END

			IF @PayTypeID=34
			BEGIN
							
				SET @strRecDesc = ' اسناد امانی دیگران نزد ما ' + @strSourceProcessNo + ' شماره' + LTRIM(RTRIM(STR(@intSourceFiscalYear))) + '/' + LTRIM(RTRIM(STR(@intSourceSerialNo))) +
							  ' به شماره ضمانتنامه ' + LTRIM(RTRIM(STR(@ChequeNo,30))) + ' به سررسید ' + @ChequeDate
			END

			------------------------------------------------
			IF @AcntCode4=''
				BEGIN
					Close Cursor_PayDtl;
					Deallocate Cursor_PayDtl; 
					--کد اسناد امانی دیگران نزد ما خالی است
					SET @strMsgText=TS.pub.funGetMessages(11015,@LanguageID)
					Raiserror (@strMsgText,16,1)
					Return
				END

			-----
			DECLARE @FillReceivableTrustAcntCodeFromDebit  VARCHAR(50)
			SET @FillReceivableTrustAcntCodeFromDebit = 'False'
			
			SELECT @FillReceivableTrustAcntCodeFromDebit = SettingValue 
			FROM pub.tblSettings 
			WHERE SettingKey = 'FillReceivableTrustAcntCodeFromDebit'
			
			
			IF @FillReceivableTrustAcntCodeFromDebit='True' AND LEN(@CreditCode)>LEN(@AcntCode4)
				BEGIN
					SET @AcntCode4 = @AcntCode4 + SUBSTRING(@CreditCode,LEN(RTRIM(@AcntCode4))+1,LEN(@CreditCode)- LEN(RTRIM(@AcntCode4))+1)
				END
			------------------------------------------------
			SET @intMaxDocRowNo = @intMaxDocRowNo + 1
			SET @intMaxRowNo = @intMaxRowNo + 1

			IF [acc].[funIsCurrencyAcntCode] (@AcntCode4) = 'True'
			Begin
				Set @CurrencyRateTmp	= @CurrencyRate
				Set @CurrencyAmountTmp  = @CurrencyAmount
				Set @CurrencyTypeIDTmp  = @CurrencyTypeID
			End
			Else
			Begin
				Set @CurrencyRateTmp	= 0
				Set @CurrencyAmountTmp  = 0
				Set @CurrencyTypeIDTmp  = ''
			End
	
			INSERT INTO acc.tblVoucherDtl
					(SerialNo,SourceProcessID,SourceProcessNo,SourceFiscalYear,SourceSerialNo,DocDate,IsAutoDoc,SessionNo,VchKind,RowNo,DocRowNo,
						AcntCode,Debit,Credit,RecDesc,RecDesc2,SourceDocType,CurrencyAmount,CurrencyTypeID,BaseID) 
			VALUES	(@intVchNo,@intSourceProcessID,@intSourceProcessNo,@intSourceFiscalYear,@intSourceSerialNo,@strVchDate ,1,@SessionNo ,1,@intMaxRowNo ,@intMaxDocRowNo,
						@AcntCode4,@Amount,0,TS.pub.funChangeFarsiStrings(pub.funReverseForCrystal(@strRecDesc)),@RowDesc,0,@CurrencyAmountTmp,@CurrencyTypeIDTmp,@BaseID)			


			IF (SELECT COUNT(*) 
				FROM trs.tblPayAtm 
				WHERE ProcessID  = @intSourceProcessID AND 
					  ProcessNo  = @intSourceProcessNo AND 
					  FiscalYear = @intSourceFiscalYear AND 
					  SerialNo   = @intSourceSerialNo AND 
					  DocRowNo   = @DocRowNo) >0
				BEGIN
					Declare	Cursor_PayAtom CURSOR For 
					SELECT	AtomAcntCode, AtomAmount, AtomDesc
					FROM trs.tblPayAtm 
					WHERE ProcessID	= @intSourceProcessID AND
						  ProcessNo	= @intSourceProcessNo AND
						  FiscalYear= @intSourceFiscalYear AND
						  SerialNo	= @intSourceSerialNo AND
						  DocRowNo   = @DocRowNo	

					Open  Cursor_PayAtom; 

					Fetch NEXT From Cursor_PayAtom Into @AtomAcntCode,@AtomAmount,@AtomDesc

					While (@@Fetch_Status = 0)
						BEGIN

							SET @AcntName = @strRecDesc + ' از '  + pub.GetCodeName(@AtomAcntCode,@LanguageID)

							SET @intMaxDocRowNo = @intMaxDocRowNo + 1
							SET @intMaxRowNo = @intMaxRowNo + 1
							
							IF @CurrencyRate <> 0 	
								SET @CurrencyAmountAtom = ROUND(@AtomAmount,0) / @CurrencyRate
								
							IF [acc].[funIsCurrencyAcntCode] (@AtomAcntCode) = 'True'
							Begin
								Set @CurrencyRateTmp	= @CurrencyRate
								Set @CurrencyAmountTmp  = @CurrencyAmountAtom
								Set @CurrencyTypeIDTmp  = @CurrencyTypeID
							End
							Else
							Begin
								Set @CurrencyRateTmp	= 0
								Set @CurrencyAmountTmp  = 0
								Set @CurrencyTypeIDTmp  = ''
							End
							
							INSERT INTO acc.tblVoucherDtl
									(SerialNo,SourceProcessID,SourceProcessNo,SourceFiscalYear,SourceSerialNo,DocDate,IsAutoDoc,SessionNo,VchKind,RowNo,DocRowNo,
										AcntCode,Debit,Credit,RecDesc,RecDesc2,SourceDocType,CurrencyAmount,CurrencyTypeID ,BaseID) 
							VALUES	(@intVchNo,@intSourceProcessID,@intSourceProcessNo,@intSourceFiscalYear,@intSourceSerialNo,@strVchDate ,1,@SessionNo ,1,@intMaxRowNo,@intMaxDocRowNo,
										@AtomAcntCode,0,@AtomAmount,TS.pub.funChangeFarsiStrings(pub.funReverseForCrystal(@AcntName)),@AtomDesc,0,@CurrencyAmountTmp,@CurrencyTypeIDTmp,@BaseID)			

							Fetch NEXT From Cursor_PayAtom Into @AtomAcntCode,@AtomAmount,@AtomDesc
						END
			
					Close Cursor_PayAtom;
					Deallocate Cursor_PayAtom; 
			
				END
		
			ELSE
			
			BEGIN
				
			SET @intMaxDocRowNo = @intMaxDocRowNo + 1
			SET @intMaxRowNo = @intMaxRowNo + 1

			IF [acc].[funIsCurrencyAcntCode] (@CreditCode) = 'True'
			Begin
				Set @CurrencyRateTmp	= @CurrencyRate
				Set @CurrencyAmountTmp  = @CurrencyAmount
				Set @CurrencyTypeIDTmp  = @CurrencyTypeID
			End
			Else
			Begin
				Set @CurrencyRateTmp	= 0
				Set @CurrencyAmountTmp  = 0
				Set @CurrencyTypeIDTmp  = ''
			End
								
			INSERT INTO acc.tblVoucherDtl
					(SerialNo,SourceProcessID,SourceProcessNo,SourceFiscalYear,SourceSerialNo,DocDate,IsAutoDoc,SessionNo,VchKind,RowNo,DocRowNo,
						AcntCode,Debit,Credit,RecDesc,RecDesc2,SourceDocType,CurrencyAmount,CurrencyTypeID ,BaseID) 
			VALUES	(@intVchNo,@intSourceProcessID,@intSourceProcessNo,@intSourceFiscalYear,@intSourceSerialNo,@strVchDate ,1,@SessionNo ,1,@intMaxRowNo ,@intMaxDocRowNo,
						@CreditCode,0,@Amount,TS.pub.funChangeFarsiStrings(pub.funReverseForCrystal(@strRecDesc)),@RowDesc,0,@CurrencyAmountTmp,@CurrencyTypeIDTmp,@BaseID)	
							
			END

		Fetch NEXT From Cursor_PayDtl Into @PayTypeID,@Amount,@RowDesc,@ChequeNo,@ChequeDate,@CreditCode,@AcntCode4,@CurrencyAmount,@DocRowNo   ,@BaseID

		END 
				

	Close Cursor_PayDtl;
	Deallocate Cursor_PayDtl; 

END
GO
