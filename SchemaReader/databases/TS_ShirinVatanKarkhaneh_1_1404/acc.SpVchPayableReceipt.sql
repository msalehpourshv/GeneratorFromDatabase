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
CREATE PROCEDURE [acc].[SpVchPayableReceipt]
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
	Declare @RowDesc	Nvarchar(200)	
	Declare @ChequeNo	Bigint
	Declare @ChequeDate	Char(10)
	Declare @AcntCode1	Varchar(20)
	Declare @AcntCode2	Varchar(20)
	Declare @AcntCode5	Varchar(20)
	Declare @DebitCode	Varchar(20)
	Declare @strRecDesc NVarChar(1000)
	Declare @RowNo		INT
	Declare @VolumeFiscalYear int
	Declare @VolumeRowNo INT
    DECLARE @BaseID Int

	DECLARE @AtomAcntCode Varchar(20)
	DECLARE @AtomAmount FLOAT 
	DECLARE @AtomDesc   Nvarchar(2000)	

	Declare @CurrencyRate	Float
	Declare @CurrencyTypeID	VarChar(20)
	Declare @CurrencyTypeIDTemp	VarChar(20)
	Declare @CurrencyAmount	Float
	
	Declare @CurrencyRateTmp			Float
	Declare @CurrencyAmountTmp			Float
	Declare @CurrencyTypeIDTmp			VarChar(20)
	DECLARE @BankCodeReplaceWithCustomerCodeInPayment BIT
	Declare @start int 
	--DECLARE @IsAtom BIT
		
	DECLARE @strSourceProcessNo NVARCHAR(100)
	IF  @intSourceProcessNo< 2
		SET @strSourceProcessNo = ''
	ELSE
		SET @strSourceProcessNo = LTRIM(RTRIM(STR(@intSourceProcessNo)))
		
	SET @strMsgText = ''

	SET @CurrencyRate = 0
	SET @CurrencyAmount = 0
	SET @CurrencyTypeID = ''
	SET @CurrencyTypeIDTemp = ''
	SET @CurrencyRateTmp = 0
	SET @CurrencyAmountTmp = 0
	SET @CurrencyTypeIDTmp = ''	

		
	SELECT   @BankCodeReplaceWithCustomerCodeInPayment=SettingValue
	FROM pub.tblSettings 
	WHERE SettingKey = 'BankCodeReplaceWithCustomerCodeInPayment'
	--------------------------------------------------------------------------------------------------------
	Declare	Cursor_PayDtl CURSOR For 
	SELECT	PayTypeID,Amount,RowDesc,ChequeNo,ChequeDate,AcntCode1,AcntCode2,AcntCode5,RowNo,BankState,VolumeFiscalYear,VolumeRowNo,RD.ID
	FROM trs.tblPayDtl RD,trs.tblOurBanks OB
	WHERE RD.CreditCode=OB.BankCode AND
		  RD.ProcessID=@intSourceProcessID AND
		  RD.ProcessNo=@intSourceProcessNo AND
		  RD.FiscalYear=@intSourceFiscalYear AND
		  RD.SerialNo=@intSourceSerialNo 
	order by RD.DocRowNo

	Open  Cursor_PayDtl; 

	Fetch NEXT From Cursor_PayDtl Into @PayTypeID,@Amount,@RowDesc,@ChequeNo,@ChequeDate,@AcntCode1,@AcntCode2,@AcntCode5,@RowNo,@BankState,@VolumeFiscalYear,@VolumeRowNo	,@BaseID 

	While (@@Fetch_Status = 0)
		BEGIN
			DECLARE @StrDesc Nvarchar(1000)
			--SET @IsAtom ='False'

			IF @BankState <> 3
				BEGIN
					Close Cursor_PayDtl;
					Deallocate Cursor_PayDtl; 
					-- نوع کد در تعاریف بانکها عوض شده است
					SET @strMsgText=TS.pub.funGetMessages(11033,@LanguageID)
					Raiserror (@strMsgText,16,1)
					Return
				END
				
			IF @AcntCode1=''
				BEGIN
					Close Cursor_PayDtl;
					Deallocate Cursor_PayDtl; 				
					--کد حسابداری موجودی بانک خالی است
					SET @strMsgText=TS.pub.funGetMessages(11009,@LanguageID)
					Raiserror (@strMsgText,16,1)
					Return
				END

			Declare @TempPayTypeID AS TinyInt
			SELECT @TempPayTypeID=a.PayTypeID,@CurrencyRate=b.CurrencyRate,@CurrencyTypeID=b.CurrencyTypeID,@CurrencyAmount=a.CurrencyAmount
			FROM trs.tblPayDtl a
			inner join trs.tblPayHdr b
			on a.ProcessID=b.ProcessID and a.ProcessNo=b.ProcessNo 
			AND a.FiscalYear=b.FiscalYear and a.SerialNo=b.SerialNo
			WHERE	a.PayTypeID IN (7,8,28) AND a.ProcessID IN (2,25) AND
					VolumeFiscalYear=@VolumeFiscalYear AND
					VolumeRowNo=@VolumeRowNo

			IF @TempPayTypeID=8
				BEGIN
					SET @DebitCode=@AcntCode2
					IF @DebitCode=''
						BEGIN
							Close Cursor_PayDtl;
							Deallocate Cursor_PayDtl; 	
							--كد حسابداري اسناد پرداختني تجاری خالی است
							SET @strMsgText=TS.pub.funGetMessages(11010,@LanguageID)
							Raiserror (@strMsgText,16,1)
							RETURN
						END
				END
			ELSE IF @TempPayTypeID = 28
				BEGIN
					SET @DebitCode=@AcntCode5
					IF @DebitCode=''
						BEGIN
							Close Cursor_PayDtl;
							Deallocate Cursor_PayDtl; 							
							--كد حسابداري اسناد پرداختني غیر تجاری خالی است
							SET @strMsgText=TS.pub.funGetMessages(11028,@LanguageID)
							Raiserror (@strMsgText,16,1)
							RETURN
						END
				END
			ELSE
				BEGIN
							declare @ER as NVARCHAR(400)
							SET @ER = N'Err :Paytype is not valid! شماره دفتر :'  + LTRIM(RTRIM(STR(@VolumeFiscalYear))) + '/' +  LTRIM(RTRIM(STR(@VolumeRowNo)))
							Raiserror (@ER,16,1)
					
				END
			-------------

				--IF @BankCodeReplaceWithCustomerCodeInPayment='True' AND 
				--	(SELECT COUNT(*) 
				--	FROM trs.tblPayAtm pa
				--	inner join trs.tblPayDtl rd
				--	on pa.ProcessID = rd.ProcessID
				--	AND pa.ProcessNo = rd.ProcessNo
				--	AND pa.FiscalYear = rd.FiscalYear
				--	AND pa.SerialNo = rd.SerialNo
				--	AND pa.DocRowNo = rd.DocRowNo
				--	WHERE rd.ProcessID  in (2,25) AND 
				--		  rd.ProcessNo  = @intSourceProcessNo AND 
				--		  rd.FiscalYear = @VolumeFiscalYear AND 
				--		  VolumeFiscalYear = @VolumeFiscalYear AND 
				--		  VolumeRowNo   = @VolumeRowNo ) >0
				--BEGIN
				--	SET @IsAtom='True'
				--	SET @start = [acc].[FunGetAcntInfoForRemain](2)

				--	Declare	Cursor_PayAtom CURSOR For 
					
				--	SELECT	SUBSTRING(AtomAcntCode,@start,20) AtomAcntCode, SUM(AtomAmount) AtomAmount
				--	FROM trs.tblPayAtm pa
				--	inner join trs.tblPayDtl rd
				--	on pa.ProcessID = rd.ProcessID
				--	AND pa.ProcessNo = rd.ProcessNo
				--	AND pa.FiscalYear = rd.FiscalYear
				--	AND pa.SerialNo = rd.SerialNo
				--	AND pa.DocRowNo = rd.DocRowNo
				--	WHERE rd.ProcessID  in (2,25) AND 
				--		  rd.ProcessNo  = @intSourceProcessNo AND 
				--		  rd.FiscalYear = @intSourceFiscalYear AND 
				--		  VolumeFiscalYear = @VolumeFiscalYear AND 
				--		  VolumeRowNo   = @VolumeRowNo	
				--	GROUP BY SUBSTRING(AtomAcntCode,@start,20)	  

				--	Open  Cursor_PayAtom; 

				--	Fetch NEXT From Cursor_PayAtom Into @AtomAcntCode,@AtomAmount

				--	While (@@Fetch_Status = 0)
				--		BEGIN
		
				--				SET @strRecDesc = ' وصول اسناد پرداختني ' + @strSourceProcessNo + ' شماره ' + LTRIM(RTRIM(STR(@intSourceFiscalYear))) + '/' + LTRIM(RTRIM(STR(@intSourceSerialNo))) +
				--								  ' به شماره چک ' + LTRIM(RTRIM(STR(@ChequeNo,30))) + ' به سررسید ' + @ChequeDate


				--				-------------
				--				SET @intMaxDocRowNo = @intMaxDocRowNo + 1
				--				SET @intMaxRowNo = @intMaxRowNo + 1

				--				IF @CurrencyAmount > 0
				--					SET @CurrencyTypeIDTemp = @CurrencyTypeID
				--				ELSE
				--					SET @CurrencyTypeIDTemp = ''

				--				IF [acc].[funIsCurrencyAcntCode] (@DebitCode) = 'True'
				--				Begin
				--					Set @CurrencyRateTmp	= @CurrencyRate
				--					Set @CurrencyAmountTmp  = @CurrencyAmount
				--					Set @CurrencyTypeIDTmp  = @CurrencyTypeIDTemp
				--				End	
				--				Else
				--				Begin
				--					Set @CurrencyRateTmp	= 0
				--					Set @CurrencyAmountTmp  = 0
				--					Set @CurrencyTypeIDTmp  = ''
				--				End

				--				SET @DebitCode = LEFT(pub.funPadRight(@DebitCode,' ',@start-1),@start-1) + @AtomAcntCode
						
				--				INSERT INTO acc.tblVoucherDtl 
				--						(SerialNo,SourceProcessID,SourceProcessNo,SourceFiscalYear,SourceSerialNo,DocDate,IsAutoDoc,SessionNo,VchKind,RowNo,DocRowNo,
				--							AcntCode,Debit,Credit,RecDesc,RecDesc2,SourceDocType,BaseID,CurrencyAmount,CurrencyTypeID ) 
				--				VALUES	(@intVchNo,@intSourceProcessID,@intSourceProcessNo,@intSourceFiscalYear,@intSourceSerialNo,@strVchDate ,1,@SessionNo ,1,@intMaxRowNo ,@intMaxDocRowNo,
				--							@DebitCode,@AtomAmount,0,TS.pub.funChangeFarsiStrings(pub.funReverseForCrystal(@strRecDesc)),@RowDesc,0 ,@BaseID,@CurrencyAmountTmp,@CurrencyTypeIDTmp)

				--			Fetch NEXT From Cursor_PayAtom Into @AtomAcntCode,@AtomAmount
				--		END
			
				--	Close Cursor_PayAtom;
				--	Deallocate Cursor_PayAtom; 
				--END


			
			Declare @Code Varchar(20)

			SELECT TOP 1 @Code=DebitCode
			FROM trs.tblPayDtl RD
			WHERE RD.VolumeFiscalYear=@VolumeFiscalYear AND
					RD.VolumeRowNo=@VolumeRowNo AND
					PayTypeID IN (7,8,28) AND RD.ProcessID IN (2,25) 
			ORDER BY RD.EventNo
			--IF @IsAtom ='False'
			--BEGIN
				SET @strRecDesc = ' وصول اسناد پرداختني ' + @strSourceProcessNo + ' شماره ' + LTRIM(RTRIM(STR(@intSourceFiscalYear))) + '/' + LTRIM(RTRIM(STR(@intSourceSerialNo))) +
								  ' به شماره چک ' + LTRIM(RTRIM(STR(@ChequeNo,30))) + ' به سررسید ' + @ChequeDate


				-------------
				SET @intMaxDocRowNo = @intMaxDocRowNo + 1
				SET @intMaxRowNo = @intMaxRowNo + 1

				IF @CurrencyAmount > 0
					SET @CurrencyTypeIDTemp = @CurrencyTypeID
				ELSE
					SET @CurrencyTypeIDTemp = ''

				IF [acc].[funIsCurrencyAcntCode] (@DebitCode) = 'True'
				Begin
					Set @CurrencyRateTmp	= @CurrencyRate
					Set @CurrencyAmountTmp  = @CurrencyAmount
					Set @CurrencyTypeIDTmp  = @CurrencyTypeIDTemp
				End	
				Else
				Begin
					Set @CurrencyRateTmp	= 0
					Set @CurrencyAmountTmp  = 0
					Set @CurrencyTypeIDTmp  = ''
				End

				IF @BankCodeReplaceWithCustomerCodeInPayment='True' AND (@PayTypeID =8 OR @PayTypeID =28)
				BEGIN
					DECLARE @CustomerCode varchar(20)
					SELECT Top 1 @CustomerCode = DebitCode
					FROM	trs.tblPayDtl
					WHERE	ProcessID IN (2,25) AND 
							PayTypeID IN (8,28) AND 
							VolumeFiscalYear = @VolumeFiscalYear AND 
							VolumeRowNo = @VolumeRowNo
					ORDER By EventNo ASC

					SET @start = [acc].[FunGetAcntInfoForRemain](2)
					IF LEN(@CustomerCode)>@start
						SET @DebitCode = LEFT(pub.funPadRight(@DebitCode,' ',@start-1),@start-1) + SUBSTRING(@CustomerCode,@start,20)
				END
			
				INSERT INTO acc.tblVoucherDtl 
						(SerialNo,SourceProcessID,SourceProcessNo,SourceFiscalYear,SourceSerialNo,DocDate,IsAutoDoc,SessionNo,VchKind,RowNo,DocRowNo,
							AcntCode,Debit,Credit,RecDesc,RecDesc2,SourceDocType,BaseID,CurrencyAmount,CurrencyTypeID ) 
				VALUES	(@intVchNo,@intSourceProcessID,@intSourceProcessNo,@intSourceFiscalYear,@intSourceSerialNo,@strVchDate ,1,@SessionNo ,1,@intMaxRowNo ,@intMaxDocRowNo,
							@DebitCode,@Amount,0,TS.pub.funChangeFarsiStrings(pub.funReverseForCrystal(@strRecDesc)),@RowDesc,0 ,@BaseID,@CurrencyAmountTmp,@CurrencyTypeIDTmp)
			--END
			-------------
			SET @strRecDesc = ' وصول اسناد پرداختني ' + @strSourceProcessNo + ' شماره ' + LTRIM(RTRIM(STR(@intSourceFiscalYear))) + '/' + LTRIM(RTRIM(STR(@intSourceSerialNo))) +
							  ' به شماره چک ' + LTRIM(RTRIM(STR(@ChequeNo,30))) + ' به سررسید ' + @ChequeDate + ' ' + pub.GetCodeName(@Code,@LanguageID)

			SET @intMaxDocRowNo = @intMaxDocRowNo + 1
			SET @intMaxRowNo = @intMaxRowNo + 1

			INSERT INTO acc.tblVoucherDtl 
					(SerialNo,SourceProcessID,SourceProcessNo,SourceFiscalYear,SourceSerialNo,DocDate,IsAutoDoc,SessionNo,VchKind,RowNo,DocRowNo,
						AcntCode,Debit,Credit,RecDesc,RecDesc2,SourceDocType,BaseID,CurrencyAmount,CurrencyTypeID ) 
			VALUES	(@intVchNo,@intSourceProcessID,@intSourceProcessNo,@intSourceFiscalYear,@intSourceSerialNo,@strVchDate ,1,@SessionNo ,1,@intMaxRowNo ,@intMaxDocRowNo,
						@AcntCode1,0,@Amount,TS.pub.funChangeFarsiStrings(pub.funReverseForCrystal(@strRecDesc)),@RowDesc,0 ,@BaseID,@CurrencyAmountTmp,@CurrencyTypeIDTmp)
			
			-----	
			Fetch NEXT From Cursor_PayDtl Into @PayTypeID,@Amount,@RowDesc,@ChequeNo,@ChequeDate,@AcntCode1,@AcntCode2,@AcntCode5,@RowNo,@BankState,@VolumeFiscalYear,@VolumeRowNo,@BaseID 

		END

	Close Cursor_PayDtl;
	Deallocate Cursor_PayDtl; 

END
GO
