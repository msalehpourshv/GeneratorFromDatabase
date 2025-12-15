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
Create  PROCEDURE [acc].[SpVchReceivablePaidBankReceipt]
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
	Declare @strMsgText		NVarChar(2044)
	Declare @PayTypeID		Tinyint
	Declare @BankState		Tinyint
	Declare @Amount			float
	Declare @RowDesc		Nvarchar(1000)	
	Declare @ChequeNo		Bigint
	Declare @ChequeDate		Char(10)
	Declare @AcntCode1		Varchar(20)
	Declare @AcntCode3		Varchar(20)
	Declare @strRecDesc		NVarChar(1000)
	Declare @VolumeFiscalYear	SmallInt
	Declare @VolumeRowNo	INT	
	Declare @RowNo			INT
	DECLARE @strSourceProcessNo NVARCHAR(100)
	DECLARE @BaseID Int
	DECLARE @BankCodeReplaceWithCustomerCodeInReceive BIT
	DECLARE @trs_BnkCodRepWithCustCodeInRcvDoNotForBankAction BIT

	Declare @start int 
	SELECT   @BankCodeReplaceWithCustomerCodeInReceive=SettingValue FROM pub.tblSettings WHERE SettingKey = 'BankCodeReplaceWithCustomerCodeInReceive'	
	SELECT   @trs_BnkCodRepWithCustCodeInRcvDoNotForBankAction=SettingValue FROM pub.tblSettings WHERE SettingKey = 'trs_BnkCodRepWithCustCodeInRcvDoNotForBankAction'	

	if @trs_BnkCodRepWithCustCodeInRcvDoNotForBankAction='True'
		SET @BankCodeReplaceWithCustomerCodeInReceive = 'False'

	IF  @intSourceProcessNo< 2
		SET @strSourceProcessNo = ''
	ELSE
		SET @strSourceProcessNo = LTRIM(RTRIM(STR(@intSourceProcessNo)))

	--------------------------------------------------------------------------------------------------------
	Declare	Cursor_PayDtl CURSOR For 
	SELECT	PayTypeID,Amount,RowDesc,ChequeNo,ChequeDate,AcntCode1,AcntCode3,VolumeFiscalYear,VolumeRowNo,RowNo,BankState,RD.ID
	FROM	trs.tblPayDtl RD,trs.tblOurBanks OB
	WHERE	RD.DebitCode	= OB.BankCode			AND
			RD.ProcessID	= @intSourceProcessID	AND
			RD.ProcessNo	= @intSourceProcessNo	AND
			RD.FiscalYear	= @intSourceFiscalYear	AND
			RD.SerialNo		= @intSourceSerialNo 
	order by RD.DocRowNo

	Open  Cursor_PayDtl; 

	Fetch NEXT From Cursor_PayDtl Into @PayTypeID,@Amount,@RowDesc,@ChequeNo,@ChequeDate,@AcntCode1,@AcntCode3,@VolumeFiscalYear,@VolumeRowNo,@RowNo,@BankState,@BaseID 

	While (@@Fetch_Status = 0)
		BEGIN

			IF @BankState <> 3
				BEGIN
					Close Cursor_PayDtl;
					Deallocate Cursor_PayDtl; 
					-- نوع کد در تعاریف بانک عوض شده است
					SET @strMsgText=TS.pub.funGetMessages(11033,@LanguageID)
					Raiserror (@strMsgText,16,1)
					Return
				END

			IF @AcntCode1=''
				BEGIN
					Close Cursor_PayDtl;
					Deallocate Cursor_PayDtl; 
					--کد موجودی بانک خالی است
					SET @strMsgText=TS.pub.funGetMessages(11009,@LanguageID)
					Raiserror (@strMsgText,16,1)
					Return
				END

			IF @AcntCode3=''
				BEGIN
					Close Cursor_PayDtl;
					Deallocate Cursor_PayDtl; 
					--کد اسناد در جریان وصول خالی است
					SET @strMsgText=TS.pub.funGetMessages(11027,@LanguageID)
					Raiserror (@strMsgText,16,1)
					Return
				END

			DECLARE @StrDesc Nvarchar(1000)

			SET @strRecDesc = ' وصول چکهای واگذار شده به بانکها ' + @strSourceProcessNo + ' شماره ' + LTRIM(RTRIM(STR(@intSourceFiscalYear))) + '/' + LTRIM(RTRIM(STR(@intSourceSerialNo))) +
							  ' به شماره دفتر ' + LTRIM(RTRIM(STR(@VolumeFiscalYear))) + '/' + LTRIM(RTRIM(STR(@VolumeRowNo))) + ' چک به شماره ' + LTRIM(RTRIM(STR(@ChequeNo,30))) + ' به سررسید ' + @ChequeDate

			
			SET @intMaxDocRowNo = @intMaxDocRowNo + 1
			SET @intMaxRowNo = @intMaxRowNo + 1

			INSERT INTO acc.tblVoucherDtl
					(SerialNo,SourceProcessID,SourceProcessNo,SourceFiscalYear,SourceSerialNo,DocDate,IsAutoDoc,SessionNo,VchKind,RowNo,DocRowNo,
						AcntCode,Debit,Credit,RecDesc,RecDesc2,SourceDocType,BaseID ) 
			VALUES	(@intVchNo,@intSourceProcessID,@intSourceProcessNo,@intSourceFiscalYear,@intSourceSerialNo,@strVchDate ,1,@SessionNo ,1,@intMaxRowNo ,@intMaxDocRowNo,
						@AcntCode1,@Amount,0,TS.pub.funChangeFarsiStrings(pub.funReverseForCrystal(@strRecDesc)),@RowDesc,0 ,@BaseID )			

			-----	
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
					SET @AcntCode3 = LEFT( pub.funPadRight(@AcntCode3,' ',@start-1),@start-1) + SUBSTRING(@CustomerCode,@start,20)
				END
			END
			SET @intMaxDocRowNo = @intMaxDocRowNo + 1
			SET @intMaxRowNo = @intMaxRowNo + 1

			INSERT INTO acc.tblVoucherDtl
					(SerialNo,SourceProcessID,SourceProcessNo,SourceFiscalYear,SourceSerialNo,DocDate,IsAutoDoc,SessionNo,VchKind,RowNo,DocRowNo,
						AcntCode,Debit,Credit,RecDesc,RecDesc2,SourceDocType,BaseID ) 
			VALUES	(@intVchNo,@intSourceProcessID,@intSourceProcessNo,@intSourceFiscalYear,@intSourceSerialNo,@strVchDate ,1,@SessionNo ,1,@intMaxRowNo ,@intMaxDocRowNo,
						@AcntCode3,0,@Amount,TS.pub.funChangeFarsiStrings(pub.funReverseForCrystal(@strRecDesc)),@RowDesc,0,@BaseID )			

			Fetch NEXT From Cursor_PayDtl Into @PayTypeID,@Amount,@RowDesc,@ChequeNo,@ChequeDate,@AcntCode1,@AcntCode3,@VolumeFiscalYear,@VolumeRowNo,@RowNo,@BankState,@BaseID 

		END

	Close Cursor_PayDtl;
	Deallocate Cursor_PayDtl; 

END
GO
