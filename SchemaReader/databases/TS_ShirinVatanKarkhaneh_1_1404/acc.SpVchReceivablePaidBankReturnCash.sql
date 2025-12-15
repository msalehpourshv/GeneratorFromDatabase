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
Create  PROCEDURE [acc].[SpVchReceivablePaidBankReturnCash]
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
	Declare @strMsgText	NVarChar(2044)
	Declare @PayTypeID	Tinyint
	Declare @BankState	Tinyint
	Declare @Amount		float
	Declare @RowDesc	Nvarchar(1000)	
	Declare @CreditCode	Varchar(20)
	Declare @DebitCode	Varchar(20)
	Declare @ChequeNo	Bigint
	Declare @ChequeDate	Char(10)
	Declare @AcntCode2	Varchar(20)
	Declare @AcntCode3	Varchar(20)
	Declare @AcntCode5	Varchar(20)
	Declare @strRecDesc NVarChar(1000)
	Declare @VolumeFiscalYear	SmallInt
	Declare @VolumeRowNo	INT	
	DECLARE @strSourceProcessNo NVARCHAR(100)
	DECLARE @BaseID Int
	DECLARE @BankCodeReplaceWithCustomerCodeInReceive BIT
	DECLARE @trs_BnkCodRepWithCustCodeInRcvDoNotForBankAction BIT
	Declare @start int 

	SET @BankCodeReplaceWithCustomerCodeInReceive = 'False'

	SELECT   @BankCodeReplaceWithCustomerCodeInReceive=SettingValue	FROM pub.tblSettings WHERE SettingKey = 'BankCodeReplaceWithCustomerCodeInReceive'
	SELECT   @trs_BnkCodRepWithCustCodeInRcvDoNotForBankAction=SettingValue FROM pub.tblSettings WHERE SettingKey = 'trs_BnkCodRepWithCustCodeInRcvDoNotForBankAction'	

	IF  @intSourceProcessNo< 2
		SET @strSourceProcessNo = ''
	ELSE
		SET @strSourceProcessNo = LTRIM(RTRIM(STR(@intSourceProcessNo)))
	
	--------------------------------------------------------------------------------------------------------
	DECLARE @CurrentDate DATETIME
	SET @CurrentDate = GETDATE()
	
	-----
	Declare	Cursor_PayDtl CURSOR For 
	SELECT	PayTypeID,Amount,RowDesc,ChequeNo,ChequeDate,AcntCode2,AcntCode5,VolumeFiscalYear,VolumeRowNo,BankState,CreditCode,ID
	FROM	trs.tblPayDtl RD,trs.tblOurBanks OB
	WHERE	RD.DebitCode=OB.BankCode			AND
			RD.ProcessID=@intSourceProcessID	AND
			RD.ProcessNo=@intSourceProcessNo	AND
			RD.FiscalYear=@intSourceFiscalYear	AND
			RD.SerialNo=@intSourceSerialNo 
	order by RD.DocRowNo

	Open  Cursor_PayDtl; 

	Fetch NEXT From Cursor_PayDtl Into @PayTypeID,@Amount,@RowDesc,@ChequeNo,@ChequeDate,@AcntCode2,@AcntCode5,@VolumeFiscalYear,@VolumeRowNo,@BankState,@CreditCode,@BaseID

	While (@@Fetch_Status = 0)
		BEGIN
		
			---------------------------------------------------
			SET @strRecDesc = ' استرداد چكهاي واگذار شده به بانك به صندوق ' + @strSourceProcessNo + ' شماره ' + LTRIM(RTRIM(STR(@intSourceFiscalYear))) + '/' + LTRIM(RTRIM(STR(@intSourceSerialNo))) +
							  ' به شماره چک ' + LTRIM(RTRIM(STR(@ChequeNo,30))) + ' به سررسید ' + @ChequeDate

			---------------------------------------------------
			Declare @TempPayTypeID AS TinyInt
			SELECT	@TempPayTypeID=PayTypeID
			FROM	trs.tblPayDtl
			WHERE	ProcessID IN (1,10) AND
					VolumeFiscalYear=@VolumeFiscalYear AND
					VolumeRowNo=@VolumeRowNo

			IF @TempPayTypeID=6
				BEGIN
					SET @DebitCode=@AcntCode2
					IF @DebitCode=''
						--كد اسناد دریافتنی تجاری خالی است
						SET @strMsgText=TS.pub.funGetMessages(11018,@LanguageID)
				END
			ELSE
				BEGIN
					SET @DebitCode=@AcntCode5
					IF @DebitCode=''
						--كد اسناد دریافتنی غیر تجاری خالی است
						SET @strMsgText=TS.pub.funGetMessages(11024,@LanguageID)
				END

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
					SET @DebitCode = LEFT(pub.funPadRight(@DebitCode,' ',@start-1),@start-1) + SUBSTRING(@CustomerCode,@start,20)
					if @trs_BnkCodRepWithCustCodeInRcvDoNotForBankAction='False'
						SET @AcntCode3 = LEFT(pub.funPadRight(@AcntCode3,' ',@start-1),@start-1) + SUBSTRING(@CustomerCode,@start,20)
				END
			END

			SET @intMaxDocRowNo = @intMaxDocRowNo + 1
			SET @intMaxRowNo = @intMaxRowNo + 1

			INSERT INTO acc.tblVoucherDtl
					(SerialNo,SourceProcessID,SourceProcessNo,SourceFiscalYear,SourceSerialNo,DocDate,IsAutoDoc,SessionNo,VchKind,RowNo,DocRowNo,
						AcntCode,Debit,Credit,RecDesc,RecDesc2,SourceDocType,BaseID) 
			VALUES	(@intVchNo,@intSourceProcessID,@intSourceProcessNo,@intSourceFiscalYear,@intSourceSerialNo,@strVchDate ,1,@SessionNo ,1,@intMaxRowNo ,@intMaxDocRowNo,
						@DebitCode,@Amount,0,TS.pub.funChangeFarsiStrings(pub.funReverseForCrystal(@strRecDesc)),@RowDesc,0,@BaseID)	
	
			---------------------------------------------------
			SET @intMaxDocRowNo = @intMaxDocRowNo + 1
			SET @intMaxRowNo = @intMaxRowNo + 1

			INSERT INTO acc.tblVoucherDtl
					(SerialNo,SourceProcessID,SourceProcessNo,SourceFiscalYear,SourceSerialNo,DocDate,IsAutoDoc,SessionNo,VchKind,RowNo,DocRowNo,
						AcntCode,Debit,Credit,RecDesc,RecDesc2,SourceDocType,BaseID) 
			VALUES	(@intVchNo,@intSourceProcessID,@intSourceProcessNo,@intSourceFiscalYear,@intSourceSerialNo,@strVchDate ,1,@SessionNo ,1,@intMaxRowNo ,@intMaxDocRowNo,
						@AcntCode3,0,@Amount,TS.pub.funChangeFarsiStrings(pub.funReverseForCrystal(@strRecDesc)),@RowDesc,0 ,@BaseID)			
			
			-----	
			Fetch NEXT From Cursor_PayDtl Into @PayTypeID,@Amount,@RowDesc,@ChequeNo,@ChequeDate,@AcntCode2,@AcntCode5,@VolumeFiscalYear,@VolumeRowNo,@BankState,@CreditCode,@BaseID

		END

	Close Cursor_PayDtl;
	Deallocate Cursor_PayDtl; 

END

GO
