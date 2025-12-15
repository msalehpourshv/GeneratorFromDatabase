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
Create  PROCEDURE [acc].[SpVchReceivablePaidBankReturnOwner]
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
	Declare @BankState	Tinyint
	Declare @Amount		float
	Declare @RowDesc	Nvarchar(1000)	
	Declare @ReceivablePaidBankRetOwnerDesc	Nvarchar(1000)	
	Declare @CreditCode	Varchar(20)
	Declare @DebitCode	Varchar(20)
	Declare @ChequeNo	Bigint
	Declare @ChequeDate	Char(10)
	Declare @AcntCode3	Varchar(20)
	Declare @VisitorAcntCode	Varchar(20)	
	Declare @strRecDesc NVarChar(1000)
	Declare @VolumeFiscalYear	SmallInt
	Declare @VolumeRowNo	INT	
	DECLARE @strSourceProcessNo NVARCHAR(100)
	DECLARE @BaseID Int
	DECLARE @strAcntName nvarchar(200)
	DECLARE @AtomAcntCode Varchar(20)
	DECLARE @AtomAmount FLOAT 
	DECLARE @AtomDesc   Nvarchar(2000)
	DECLARE @BankCodeReplaceWithCustomerCodeInReceive BIT
	DECLARE @trs_BnkCodRepWithCustCodeInRcvDoNotForBankAction BIT
	Declare @start int 

	SET @BankCodeReplaceWithCustomerCodeInReceive = 'False'
	
	SELECT   @BankCodeReplaceWithCustomerCodeInReceive=SettingValue FROM pub.tblSettings WHERE SettingKey = 'BankCodeReplaceWithCustomerCodeInReceive'	
	SELECT   @trs_BnkCodRepWithCustCodeInRcvDoNotForBankAction=SettingValue FROM pub.tblSettings WHERE SettingKey = 'trs_BnkCodRepWithCustCodeInRcvDoNotForBankAction'	

	if @trs_BnkCodRepWithCustCodeInRcvDoNotForBankAction='True'
		SET @BankCodeReplaceWithCustomerCodeInReceive = 'False'

	set @strAcntName=''		

	IF  @intSourceProcessNo< 2
		SET @strSourceProcessNo = ''
	ELSE
		SET @strSourceProcessNo = LTRIM(RTRIM(STR(@intSourceProcessNo)))

	--------------------------------------------------------------------------------------------------------

	SELECT @ReceivablePaidBankRetOwnerDesc= SettingValue
	FROM pub.tblSettings
	WHERE SettingKey = 'ReceivablePaidBankRetOwnerDesc'

	IF @ReceivablePaidBankRetOwnerDesc IS NULL  OR @ReceivablePaidBankRetOwnerDesc = ''
		SET @ReceivablePaidBankRetOwnerDesc = ' استرداد چكهاي واگذار شده به بانك به صاحب چک '
	-----
	Declare	Cursor_PayDtl CURSOR For 
	SELECT	PayTypeID,Amount,RowDesc,ChequeNo,ChequeDate,VolumeFiscalYear,VolumeRowNo,BankState,DebitCode,CreditCode, ID,VisitorAcntCode
	FROM	trs.tblPayDtl RD,trs.tblOurBanks OB
	WHERE	RD.CreditCode=OB.BankCode			AND
			RD.ProcessID=@intSourceProcessID	AND
			RD.ProcessNo=@intSourceProcessNo	AND
			RD.FiscalYear=@intSourceFiscalYear	AND
			RD.SerialNo=@intSourceSerialNo 
	order by RD.DocRowNo

	Open  Cursor_PayDtl; 

	Fetch NEXT From Cursor_PayDtl Into @PayTypeID,@Amount,@RowDesc,@ChequeNo,@ChequeDate,@VolumeFiscalYear,@VolumeRowNo,@BankState,@DebitCode,@CreditCode,@BaseID,@VisitorAcntCode

	While (@@Fetch_Status = 0)
		BEGIN
		
			IF @DebitCode='' 
			BEGIN
				SET @strMsgText= 'کد طرف حساب در شماره چک ' + LTRIM(RTRIM(STR(@ChequeNo,30))) + ' خالی است'
				Close Cursor_PayDtl;
				Deallocate Cursor_PayDtl; 
				Raiserror (@strMsgText,16,1)
				Return
			END
			Select @strAcntName =  [pub].GetCodeName(@DebitCode, @LanguageID)
			---------------------------------------------------
			
			SET @strRecDesc = @ReceivablePaidBankRetOwnerDesc + '(' + @strAcntName + ')' + @strSourceProcessNo + ' شماره ' + LTRIM(RTRIM(STR(@intSourceFiscalYear))) + '/' + LTRIM(RTRIM(STR(@intSourceSerialNo))) +
							  ' به شماره چک ' + LTRIM(RTRIM(STR(@ChequeNo,30))) + ' به سررسید ' + @ChequeDate

			---------------------------------------------------
			SELECT @AcntCode3=AcntCode3
			FROM trs.tblOurBanks 
			WHERE BankCode=@CreditCode

			IF @AcntCode3=''
				--كد حسابداري اسناد در جریان وصول  خالی است
				SET @strMsgText=TS.pub.funGetMessages(11014,@LanguageID)

			---------------------------------------------------
			IF @strMsgText<>''
				BEGIN
					Close Cursor_PayDtl;
					Deallocate Cursor_PayDtl; 
					Raiserror (@strMsgText,16,1)
					Return
				END

			---- جایگزینی کد حسابداری معین و یا بقیه با کد موجود در تنظیمات
			--IF  LEN(@RecDebAcntCodeRet)>0
			--	SET @DebitCode = [pub].[funReplaceCode] (@DebitCode,@RecDebAcntCodeRet)
				
			---------------------------------------------------
						IF (SELECT COUNT(*) 
				FROM trs.tblPayAtm pa
				inner join trs.tblPayDtl rd
				on pa.ProcessID = rd.ProcessID
				AND pa.ProcessNo = rd.ProcessNo
				AND pa.FiscalYear = rd.FiscalYear
				AND pa.SerialNo = rd.SerialNo
				AND pa.DocRowNo = rd.DocRowNo
				WHERE rd.ProcessID  in (1,10) AND 
					  rd.ProcessNo  = @intSourceProcessNo AND 
					  rd.FiscalYear = @intSourceFiscalYear AND 
					  VolumeFiscalYear = @VolumeFiscalYear AND 
					  VolumeRowNo   = @VolumeRowNo ) >0
				BEGIN
					Declare	Cursor_PayAtom CURSOR For 
					SELECT	AtomAcntCode, AtomAmount, AtomDesc
					FROM trs.tblPayAtm pa
					inner join trs.tblPayDtl rd
					on pa.ProcessID = rd.ProcessID
					AND pa.ProcessNo = rd.ProcessNo
					AND pa.FiscalYear = rd.FiscalYear
					AND pa.SerialNo = rd.SerialNo
					AND pa.DocRowNo = rd.DocRowNo
					WHERE rd.ProcessID  in (1,10) AND 
						  rd.ProcessNo  = @intSourceProcessNo AND 
						  rd.FiscalYear = @intSourceFiscalYear AND 
						  VolumeFiscalYear = @VolumeFiscalYear AND 
						  VolumeRowNo   = @VolumeRowNo	

					Open  Cursor_PayAtom; 

					Fetch NEXT From Cursor_PayAtom Into @AtomAcntCode,@AtomAmount,@AtomDesc

					While (@@Fetch_Status = 0)
						BEGIN

							SET @intMaxDocRowNo = @intMaxDocRowNo + 1
							SET @intMaxRowNo = @intMaxRowNo + 1

							INSERT INTO acc.tblVoucherDtl
									(SerialNo,SourceProcessID,SourceProcessNo,SourceFiscalYear,SourceSerialNo,DocDate,IsAutoDoc,SessionNo,VchKind,RowNo,DocRowNo,
										AcntCode,Debit,Credit,RecDesc,RecDesc2,SourceDocType,BaseID,VisitorAcntCode ) 
							VALUES	(@intVchNo,@intSourceProcessID,@intSourceProcessNo,@intSourceFiscalYear,@intSourceSerialNo,@strVchDate ,1,@SessionNo ,1,@intMaxRowNo ,@intMaxDocRowNo,
										@AtomAcntCode,@AtomAmount,0,TS.pub.funChangeFarsiStrings(pub.funReverseForCrystal(@strRecDesc)),TS.pub.funChangeFarsiStrings(pub.funReverseForCrystal(@RowDesc + '  ' +  @AtomDesc )),0,@BaseID ,@VisitorAcntCode)

							Fetch NEXT From Cursor_PayAtom Into @AtomAcntCode,@AtomAmount,@AtomDesc
						END
			
					Close Cursor_PayAtom;
					Deallocate Cursor_PayAtom; 
			
				END
			
			ELSE
			
				BEGIN
					SET @intMaxDocRowNo = @intMaxDocRowNo + 1
					SET @intMaxRowNo = @intMaxRowNo + 1

					INSERT INTO acc.tblVoucherDtl
							(SerialNo,SourceProcessID,SourceProcessNo,SourceFiscalYear,SourceSerialNo,DocDate,IsAutoDoc,SessionNo,VchKind,RowNo,DocRowNo,
								AcntCode,Debit,Credit,RecDesc,RecDesc2,SourceDocType,BaseID,VisitorAcntCode) 
					VALUES	(@intVchNo,@intSourceProcessID,@intSourceProcessNo,@intSourceFiscalYear,@intSourceSerialNo,@strVchDate ,1,@SessionNo ,1,@intMaxRowNo ,@intMaxDocRowNo,
								@DebitCode,@Amount,0,TS.pub.funChangeFarsiStrings(pub.funReverseForCrystal(@strRecDesc)),@RowDesc,0 ,@BaseID,@VisitorAcntCode)	
				END
			---------------------------------------------------
			IF @BankCodeReplaceWithCustomerCodeInReceive='True' AND (@PayTypeID =6 OR @PayTypeID =16  OR @PayTypeID =26)
			BEGIN
				DECLARE @CustomerCode varchar(20)
				SELECT Top 1 @CustomerCode = CreditCode
				FROM	trs.tblPayDtl
				WHERE	ProcessID IN (1,10) AND 
						PayTypeID IN (6,16,26) AND 
						VolumeFiscalYear = @VolumeFiscalYear AND 
						VolumeRowNo = @VolumeRowNo
				ORDER By EventNo ASC

				SET @start = [acc].[FunGetAcntInfoForRemain](2)
				IF LEN(@CustomerCode)>@start
				BEGIN
					SET @AcntCode3 =  LEFT(pub.funPadRight(@AcntCode3,' ',@start-1),@start-1) + SUBSTRING(@CustomerCode,@start,20)
				END
			END

			SET @intMaxDocRowNo = @intMaxDocRowNo + 1
			SET @intMaxRowNo = @intMaxRowNo + 1

			INSERT INTO acc.tblVoucherDtl
					(SerialNo,SourceProcessID,SourceProcessNo,SourceFiscalYear,SourceSerialNo,DocDate,IsAutoDoc,SessionNo,VchKind,RowNo,DocRowNo,
						AcntCode,Debit,Credit,RecDesc,RecDesc2,SourceDocType,BaseID,VisitorAcntCode) 
			VALUES	(@intVchNo,@intSourceProcessID,@intSourceProcessNo,@intSourceFiscalYear,@intSourceSerialNo,@strVchDate ,1,@SessionNo ,1,@intMaxRowNo ,@intMaxDocRowNo,
						@AcntCode3,0,@Amount,TS.pub.funChangeFarsiStrings(pub.funReverseForCrystal(@strRecDesc)),@RowDesc,0 ,@BaseID,@VisitorAcntCode)			
			
			---------------------------------------------------	
			Fetch NEXT From Cursor_PayDtl Into @PayTypeID,@Amount,@RowDesc,@ChequeNo,@ChequeDate,@VolumeFiscalYear,@VolumeRowNo,@BankState,@DebitCode,@CreditCode,@BaseID,@VisitorAcntCode

		END

	Close Cursor_PayDtl;
	Deallocate Cursor_PayDtl;  

END
GO
