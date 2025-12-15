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
Create  PROCEDURE [acc].[SpVchReceivablePaidBank]
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
	Declare @strMsgText NVarChar(2044)
	Declare @PayTypeID	Tinyint
	Declare @BankState	Tinyint
	Declare @Amount		float
	Declare @RowDesc	Nvarchar(1000)	
	Declare @DebitCode	Varchar(20)
	Declare @ChequeNo	Bigint
	Declare @ChequeDate	Char(10)
	Declare @AcntCode2	Varchar(20)
	Declare @AcntCode3	Varchar(20)
	Declare @AcntCode5	Varchar(20)
    Declare @intSum		float
	Declare @strRecDesc NVarChar(1000)
	Declare @DescHdr	NVarChar(1000)
	DECLARE @strSourceProcessNo NVARCHAR(100)
	DECLARE @BaseID Int
	DECLARE @VolumeFiscalYear Int
	DECLARE @VolumeRowNo Int
	DECLARE @BankCodeReplaceWithCustomerCodeInReceive BIT
	DECLARE @trs_BnkCodRepWithCustCodeInRcvDoNotForBankAction BIT
	Declare @start int 

	SET @BankCodeReplaceWithCustomerCodeInReceive = 'False'

	SELECT   @BankCodeReplaceWithCustomerCodeInReceive=SettingValue FROM pub.tblSettings WHERE SettingKey = 'BankCodeReplaceWithCustomerCodeInReceive'	
	SELECT   @trs_BnkCodRepWithCustCodeInRcvDoNotForBankAction=SettingValue FROM pub.tblSettings WHERE SettingKey = 'trs_BnkCodRepWithCustCodeInRcvDoNotForBankAction'	

	IF  @intSourceProcessNo< 2
		SET @strSourceProcessNo = ''
	ELSE
		SET @strSourceProcessNo = LTRIM(RTRIM(STR(@intSourceProcessNo)))

	--------------------------------------------------------------------------------------------------------
	DECLARE @CurrentDate DATETIME
	SET @CurrentDate = GETDATE()

	SET @strRecDesc = ' واگذاری چک اشخاص به بانک ' + @strSourceProcessNo + ' شماره ' + LTRIM(RTRIM(STR(@intSourceFiscalYear))) + '/' + LTRIM(RTRIM(STR(@intSourceSerialNo)))
	
	SET @intSum=0

	----------------------
	SELECT	@intSum=SUM(Amount)
	FROM trs.tblPayDtl RD,trs.tblOurBanks OB
	WHERE RD.CreditCode=OB.BankCode AND
		  RD.ProcessID=@intSourceProcessID AND
		  RD.ProcessNo=@intSourceProcessNo AND
		  RD.FiscalYear=@intSourceFiscalYear AND
		  RD.SerialNo=@intSourceSerialNo 

	SELECT	@AcntCode3=AcntCode3, @BankState=BankState ,@DescHdr=DescHdr
	FROM trs.tblOurBanks A ,
		(SELECT DebitCode ,DescHdr
		 FROM	trs.tblPayHdr
		 WHERE	ProcessID=@intSourceProcessID AND
				ProcessNo=@intSourceProcessNo AND
				FiscalYear=@intSourceFiscalYear AND
				SerialNo=@intSourceSerialNo ) B
	WHERE DebitCode=BankCode


	IF @BankState <> 3
		BEGIN
			-- نوع کد در تعاریف بانک عوض شده است
			SET @strMsgText=TS.pub.funGetMessages(11033,@LanguageID)
			Raiserror (@strMsgText,16,1)
			Return
		END

	IF @AcntCode3=''
		BEGIN
			--كد حسابداري اسناد در جریان وصول خالی است
			SET @strMsgText=TS.pub.funGetMessages(11027,@LanguageID)
			Raiserror (@strMsgText,16,1)
			Return
		END
	IF @BankCodeReplaceWithCustomerCodeInReceive='False' 
	BEGIN
		SET @intMaxDocRowNo = @intMaxDocRowNo + 1
		SET @intMaxRowNo = @intMaxRowNo + 1

		INSERT INTO acc.tblVoucherDtl
				(SerialNo,SourceProcessID,SourceProcessNo,SourceFiscalYear,SourceSerialNo,DocDate,IsAutoDoc,SessionNo,VchKind,RowNo,DocRowNo,
					AcntCode,Debit,Credit,RecDesc,RecDesc2,SourceDocType) 
		VALUES	(@intVchNo,@intSourceProcessID,@intSourceProcessNo,@intSourceFiscalYear,@intSourceSerialNo,@strVchDate ,1,@SessionNo ,1,@intMaxRowNo ,@intMaxDocRowNo,
					@AcntCode3,@intSum,0,TS.pub.funChangeFarsiStrings(pub.funReverseForCrystal(@strRecDesc)),@DescHdr,0 )	
	END
	-----
	Declare	Cursor_PayDtl CURSOR For 
	SELECT	PayTypeID,Amount,RowDesc,RD.VolumeFiscalYear,RD.VolumeRowNo,ChequeNo,ChequeDate,AcntCode2,AcntCode5,OB.BankState, RD.ID
	FROM	trs.tblPayDtl RD,trs.tblOurBanks OB
	WHERE	RD.CreditCode=OB.BankCode AND
			RD.ProcessID=@intSourceProcessID AND
			RD.ProcessNo=@intSourceProcessNo AND
			RD.FiscalYear=@intSourceFiscalYear AND
			RD.SerialNo=@intSourceSerialNo 
	order by RD.DocRowNo

	Open  Cursor_PayDtl; 

	Fetch NEXT From Cursor_PayDtl Into @PayTypeID,@Amount,@RowDesc,@VolumeFiscalYear,@VolumeRowNo,@ChequeNo,@ChequeDate,@AcntCode2,@AcntCode5,@BankState,@BaseID 

	While (@@Fetch_Status = 0)
		BEGIN

			IF @BankState <> 1 AND @BankState <> 2
				BEGIN
					Close Cursor_PayDtl;
					Deallocate Cursor_PayDtl; 
					-- نوع کد در تعاریف صندوق عوض شده است
					SET @strMsgText=TS.pub.funGetMessages(11036,@LanguageID)
					Raiserror (@strMsgText,16,1)
					Return
				END

			IF @PayTypeID=6 AND @AcntCode2=''
				BEGIN
					Close Cursor_PayDtl;
					Deallocate Cursor_PayDtl; 
					--كد حسابداري اسناد دریافتنی تجاری خالی است
					SET @strMsgText=TS.pub.funGetMessages(11011,@LanguageID)
					Raiserror (@strMsgText,16,1)
					Return
				END

			IF @PayTypeID=26 AND @AcntCode5=''
				BEGIN
					Close Cursor_PayDtl;
					Deallocate Cursor_PayDtl; 
					--كد حسابداري اسناد دریافتنی غیر تجاری خالی است
					SET @strMsgText=TS.pub.funGetMessages(11024,@LanguageID)
					Raiserror (@strMsgText,16,1)
					Return
				END

			DECLARE @StrDesc Nvarchar(200)
			DECLARE @CreditCode    Nvarchar(20)



			IF @PayTypeID=6
				SET @CreditCode=@AcntCode2
			ELSE IF @PayTypeID=26
				SET @CreditCode=@AcntCode5

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
					
					SET @CreditCode = LEFT(pub.funPadRight(@CreditCode,' ',@start-1),@start-1) + SUBSTRING(@CustomerCode,@start,20)
					if @trs_BnkCodRepWithCustCodeInRcvDoNotForBankAction='False'
						SET @AcntCode3 =  LEFT(pub.funPadRight(@AcntCode3,' ',@start-1),@start-1) + SUBSTRING(@CustomerCode,@start,20)
				END
				ELSE
				BEGIN
					SET @CreditCode = LEFT(pub.funPadRight(@CreditCode,' ',@start-1),@start-1) 
					if @trs_BnkCodRepWithCustCodeInRcvDoNotForBankAction='False'
						SET @AcntCode3 =  LEFT(pub.funPadRight(@AcntCode3,' ',@start-1),@start-1) 
				END
			END
			
			IF @BankCodeReplaceWithCustomerCodeInReceive='True' 
			BEGIN
				SET @intMaxDocRowNo = @intMaxDocRowNo + 1
				SET @intMaxRowNo = @intMaxRowNo + 1

				INSERT INTO acc.tblVoucherDtl
						(SerialNo,SourceProcessID,SourceProcessNo,SourceFiscalYear,SourceSerialNo,DocDate,IsAutoDoc,SessionNo,VchKind,RowNo,DocRowNo,
							AcntCode,Debit,Credit,RecDesc,RecDesc2,SourceDocType) 
				VALUES	(@intVchNo,@intSourceProcessID,@intSourceProcessNo,@intSourceFiscalYear,@intSourceSerialNo,@strVchDate ,1,@SessionNo ,1,@intMaxRowNo ,@intMaxDocRowNo,
							@AcntCode3,@Amount,0,TS.pub.funChangeFarsiStrings(pub.funReverseForCrystal(@strRecDesc)),@DescHdr,0 )	
			END


			SET @intMaxDocRowNo = @intMaxDocRowNo + 1
			SET @intMaxRowNo = @intMaxRowNo + 1
			SET @StrDesc=@strRecDesc + ' چک به شماره ' + LTRIM(RTRIM(STR(@ChequeNo,30))) + ' به سررسید ' + @ChequeDate

			INSERT INTO acc.tblVoucherDtl
					(SerialNo,SourceProcessID,SourceProcessNo,SourceFiscalYear,SourceSerialNo,DocDate,IsAutoDoc,SessionNo,VchKind,RowNo,DocRowNo,
						AcntCode,Debit,Credit,RecDesc,RecDesc2,SourceDocType,BaseID ) 
			VALUES	(@intVchNo,@intSourceProcessID,@intSourceProcessNo,@intSourceFiscalYear,@intSourceSerialNo,@strVchDate ,1,@SessionNo ,1,@intMaxRowNo ,@intMaxDocRowNo,
						@CreditCode,0,@Amount,TS.pub.funChangeFarsiStrings(pub.funReverseForCrystal(@StrDesc)),@RowDesc,0 ,@BaseID )			

			Fetch NEXT From Cursor_PayDtl Into @PayTypeID,@Amount,@RowDesc,@VolumeFiscalYear,@VolumeRowNo,@ChequeNo,@ChequeDate,@AcntCode2,@AcntCode5,@BankState,@BaseID 
		END

	Close Cursor_PayDtl;
	Deallocate Cursor_PayDtl; 
		
END

GO
