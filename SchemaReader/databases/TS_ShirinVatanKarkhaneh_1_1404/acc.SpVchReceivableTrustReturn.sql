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
Create PROCEDURE [acc].[SpVchReceivableTrustReturn]
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
	Declare @HdrDesc	Nvarchar(1000)	
	Declare @RowDesc	Nvarchar(1000)	
	Declare @DebitCode	Varchar(20)
	Declare @ChequeNo	Bigint
	Declare @ChequeDate	Char(10)
	Declare @AcntCode4	Varchar(20)
	Declare @strRecDesc NVarChar(1000)
	DECLARE @strSourceProcessNo NVARCHAR(100)
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
	IF  @intSourceProcessNo< 2
		SET @strSourceProcessNo = ''
	ELSE
		SET @strSourceProcessNo = LTRIM(RTRIM(STR(@intSourceProcessNo)))

	------------

	SELECT	@HdrDesc=DescHdr
	FROM	trs.tblPayHdr RD
	WHERE	RD.ProcessID=@intSourceProcessID	AND
			RD.ProcessNo=@intSourceProcessNo	AND
			RD.FiscalYear=@intSourceFiscalYear	AND
			RD.SerialNo=@intSourceSerialNo 

	--------------------------------------------------------------------------------------------
	Declare	Cursor_PayDtl CURSOR For 
	SELECT	PayTypeID,Amount,RowDesc,ChequeNo,ChequeDate,DebitCode,AcntCode4,RD.ID
	FROM	trs.tblPayDtl RD,trs.tblOurBanks OB
	WHERE	RD.CreditCode=OB.BankCode			AND
			RD.ProcessID=@intSourceProcessID	AND
			RD.ProcessNo=@intSourceProcessNo	AND
			RD.FiscalYear=@intSourceFiscalYear	AND
			RD.SerialNo=@intSourceSerialNo 
	order by RD.DocRowNo

	Open  Cursor_PayDtl; 

	Fetch NEXT From Cursor_PayDtl Into @PayTypeID,@Amount,@RowDesc,@ChequeNo,@ChequeDate,@DebitCode,@AcntCode4, @BaseID 

	While (@@Fetch_Status = 0)
		BEGIN
			------------------------------------------------
			IF @PayTypeID = 16
			SET @strRecDesc = ' استرداد چکهای امانی دیگران نزد ما ' + @strSourceProcessNo + ' شماره' + LTRIM(RTRIM(STR(@intSourceFiscalYear))) + '/' + LTRIM(RTRIM(STR(@intSourceSerialNo))) +
							  ' به شماره چک ' + LTRIM(RTRIM(STR(@ChequeNo,30))) + ' به سررسید ' + @ChequeDate
		
			IF @PayTypeID = 34
			SET @strRecDesc = ' استرداد اسناد امانی دیگران نزد ما ' + @strSourceProcessNo + ' شماره' + LTRIM(RTRIM(STR(@intSourceFiscalYear))) + '/' + LTRIM(RTRIM(STR(@intSourceSerialNo))) +
							  ' به شماره ضمانتنامه ' + LTRIM(RTRIM(STR(@ChequeNo,30))) + ' به سررسید ' + @ChequeDate							  

			IF @PayTypeID = 31
			SET @strRecDesc = ' استرداد اسناد امانی دیگران نزد ما ' + @strSourceProcessNo + ' شماره' + LTRIM(RTRIM(STR(@intSourceFiscalYear))) + '/' + LTRIM(RTRIM(STR(@intSourceSerialNo))) +
							  ' به شماره سفته ' + LTRIM(RTRIM(STR(@ChequeNo,30))) + ' به سررسید ' + @ChequeDate							  

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

	------------------------------------------------
		
		
				DECLARE @FillPayableTrustAcntCodeFromDebit  VARCHAR(50)
			SET @FillPayableTrustAcntCodeFromDebit = 'False'
			
			SELECT @FillPayableTrustAcntCodeFromDebit = SettingValue 
			FROM pub.tblSettings 
			WHERE SettingKey = 'FillPayableTrustAcntCodeFromDebit'
			
			
		------------------------------------------------

					  
			IF (SELECT COUNT(*) 
				FROM trs.tblPayDtl a
				Inner join trs.tblPayAtm b
				on a.ProcessID=b.ProcessID and a.ProcessNo=b.ProcessNo and a.FiscalYear=b.FiscalYear and a.SerialNo=b.SerialNo and a.DocRowNo=b.DocRowNo
				WHERE a.ProcessID  = 31 AND ChequeNo=@ChequeNo AND Amount = @Amount ) >0
				BEGIN
					Declare	Cursor_PayAtom CURSOR For 
					SELECT	AtomAcntCode, AtomAmount, AtomDesc
					FROM trs.tblPayDtl a
					Inner join trs.tblPayAtm b
					on a.ProcessID=b.ProcessID and a.ProcessNo=b.ProcessNo and a.FiscalYear=b.FiscalYear and a.SerialNo=b.SerialNo and a.DocRowNo=b.DocRowNo
					WHERE a.ProcessID  = 31 AND ChequeNo=@ChequeNo AND Amount = @Amount		

					Open  Cursor_PayAtom; 

					Fetch NEXT From Cursor_PayAtom Into @AtomAcntCode,@AtomAmount,@AtomDesc

					While (@@Fetch_Status = 0)
						BEGIN


							SET @AcntName = @strRecDesc + ' به '  + pub.GetCodeName(@AtomAcntCode,@LanguageID)

							SET @intMaxDocRowNo = @intMaxDocRowNo + 1
							SET @intMaxRowNo = @intMaxRowNo + 1
							
							INSERT INTO acc.tblVoucherDtl
									(SerialNo,SourceProcessID,SourceProcessNo,SourceFiscalYear,SourceSerialNo,DocDate,IsAutoDoc,SessionNo,VchKind,RowNo,DocRowNo,
										AcntCode,Debit,Credit,RecDesc,RecDesc2,SourceDocType,CurrencyAmount,CurrencyTypeID , BaseID ) 
							VALUES	(@intVchNo,@intSourceProcessID,@intSourceProcessNo,@intSourceFiscalYear,@intSourceSerialNo,@strVchDate ,1,@SessionNo ,1,@intMaxRowNo,@intMaxDocRowNo,
										@AtomAcntCode,@AtomAmount,0,TS.pub.funChangeFarsiStrings(pub.funReverseForCrystal(@AcntName)),@AtomDesc,0,0 ,'' , @BaseID )			

							Fetch NEXT From Cursor_PayAtom Into @AtomAcntCode,@AtomAmount,@AtomDesc
						END
			
					Close Cursor_PayAtom;
					Deallocate Cursor_PayAtom; 
			
				END
		
			ELSE
			
				BEGIN
				
			SET @intMaxDocRowNo = @intMaxDocRowNo + 1
			SET @intMaxRowNo = @intMaxRowNo + 1
			SET @RowDesc=@HdrDesc +'   ' +@RowDesc
			

			INSERT INTO acc.tblVoucherDtl
					(SerialNo,SourceProcessID,SourceProcessNo,SourceFiscalYear,SourceSerialNo,DocDate,IsAutoDoc,SessionNo,VchKind,RowNo,DocRowNo,
						AcntCode,Debit,Credit,RecDesc,RecDesc2,SourceDocType, BaseID ) 
			VALUES	(@intVchNo,@intSourceProcessID,@intSourceProcessNo,@intSourceFiscalYear,@intSourceSerialNo,@strVchDate ,1,@SessionNo ,1,@intMaxRowNo ,@intMaxDocRowNo,
						@DebitCode,@Amount,0,TS.pub.funChangeFarsiStrings(pub.funReverseForCrystal(@strRecDesc)),@RowDesc,0 , @BaseID )			

						

		
	IF @FillPayableTrustAcntCodeFromDebit='True' AND LEN(@DebitCode)>LEN(@AcntCode4)
				BEGIN
					SET @AcntCode4 = @AcntCode4 + SUBSTRING(@DebitCode,LEN(RTRIM(@AcntCode4))+1,LEN(@DebitCode)- LEN(RTRIM(@AcntCode4))+1)
				END
			------------------------------------------------
			SET @intMaxDocRowNo = @intMaxDocRowNo + 1
			SET @intMaxRowNo = @intMaxRowNo + 1
--select 3,@strRecDesc 
			INSERT INTO acc.tblVoucherDtl
					(SerialNo,SourceProcessID,SourceProcessNo,SourceFiscalYear,SourceSerialNo,DocDate,IsAutoDoc,SessionNo,VchKind,RowNo,DocRowNo,
						AcntCode,Debit,Credit,RecDesc,RecDesc2,SourceDocType, BaseID ) 
			VALUES	(@intVchNo,@intSourceProcessID,@intSourceProcessNo,@intSourceFiscalYear,@intSourceSerialNo,@strVchDate ,1,@SessionNo ,1,@intMaxRowNo ,@intMaxDocRowNo,
						@AcntCode4,0,@Amount,TS.pub.funChangeFarsiStrings(pub.funReverseForCrystal(@strRecDesc)),@RowDesc,0 , @BaseID )	
			
		END
			
			-----
			Fetch NEXT From Cursor_PayDtl Into @PayTypeID,@Amount,@RowDesc,@ChequeNo,@ChequeDate,@DebitCode,@AcntCode4, @BaseID 

		END

	Close Cursor_PayDtl;
	Deallocate Cursor_PayDtl; 

		
			
END
GO
