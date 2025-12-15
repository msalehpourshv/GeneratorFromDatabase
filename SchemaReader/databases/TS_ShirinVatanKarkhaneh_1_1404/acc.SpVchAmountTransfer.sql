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
Create PROCEDURE [acc].[SpVchAmountTransfer]
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
	Declare @Amount		Bigint
	Declare @RowDesc	Nvarchar(100)	
	Declare @DebitCode	Varchar(20)
	Declare @CreditCode	Varchar(20)
	Declare @ChequeNo	Bigint
	Declare @ChequeDate	Char(10)
	Declare @AcntCode2	Varchar(20)
	Declare @strRecDesc NVarChar(1000)
	Declare @intRowCount INT
	Declare @CurrencyAmount	Float
	Declare @DocRowNo INT	
	Declare @CurrencyRate	Float
	DECLARE @AcntName   NVarchar(1000)
	DECLARE @AtomAcntCode Varchar(20)
	Declare @CurrencyTypeID	VarChar(20)
	DECLARE @AtomAmount FLOAT 
	DECLARE @AtomDesc   Nvarchar(2000)	
	Declare @CurrencyAmountAtom	Float
	DECLARE @DiscountAmount Int
	DECLARE @VolumeFiscalYear Int
	DECLARE @VolumeRowNo Int
	DECLARE @BaseID Int
	DECLARE @BankCodeReplaceWithCustomerCodeInReceive BIT
	Declare @start int 
	Declare @CurrencyRateHdr	Float
	Declare @CurrencyTypeIDHdr	VarChar(20)
	DECLARE @Has2CurrencyInPay BIT
	DECLARE @CurrencyAmountTmp			Float
	DECLARE @CurrencyTypeIDTmp			VarChar(20)
	DECLARE @CurrencyRateTmp			Float
	Declare @CurrencyTypeIDDtl	 VarChar(20)
	Declare @CurrencyRateDtl	Float			
	DECLARE @trs_CurrencyTypeInRow BIT;

	SELECT @trs_CurrencyTypeInRow = SettingValue FROM pub.tblSettings WHERE SettingKey = 'trs_CurrencyTypeInRow'

	SET @Has2CurrencyInPay = 'False'
	SELECT   @Has2CurrencyInPay=SettingValue 	FROM pub.tblSettings 	WHERE SettingKey = 'Has2CurrencyInPay'	
		
	SET @BankCodeReplaceWithCustomerCodeInReceive = 'False'

	SELECT   @BankCodeReplaceWithCustomerCodeInReceive=SettingValue
	FROM pub.tblSettings 
	WHERE SettingKey = 'BankCodeReplaceWithCustomerCodeInReceive'	
	
	SELECT	@CurrencyRateHdr=CurrencyRate,@CurrencyTypeIDHdr=CurrencyTypeID,
			@CurrencyRate=CurrencyRate,@CurrencyTypeID=CurrencyTypeID,
			@DiscountAmount=DiscountAmount
	FROM trs.tblPayHdr
	WHERE ProcessID=@intSourceProcessID AND
		  ProcessNo=@intSourceProcessNo AND
		  FiscalYear=@intSourceFiscalYear AND
		  SerialNo=@intSourceSerialNo 	

	IF @Has2CurrencyInPay='True' and @CurrencyRateHdr=0  And @CurrencyTypeIDHdr<>''
		BEGIN
				set @strMsgText='نرخ ارز اصلی خالی است'
				Raiserror (@strMsgText,16,1)
				Return
		END	

	SELECT	@intRowCount=Count(PayTypeID)
	FROM trs.tblPayDtl RD
	WHERE RD.ProcessID=@intSourceProcessID AND
		  RD.ProcessNo=@intSourceProcessNo AND
		  RD.FiscalYear=@intSourceFiscalYear AND
		  RD.SerialNo=@intSourceSerialNo 

	IF @BankCodeReplaceWithCustomerCodeInReceive='True'
		BEGIN
			SET @start = [acc].[FunGetAcntInfoForRemain](2)
		END
--------------------------------------------------------------------------------------------------------
	Declare	Cursor_PayDtl CURSOR For 
	SELECT	RD.CurrencyRate,RD.CurrencyTypeID,PayTypeID,Amount,RowDesc,VolumeFiscalYear,VolumeRowNo,DebitCode,CreditCode,ChequeNo,ChequeDate,CurrencyAmount,DocRowNo,ID
	FROM trs.tblPayDtl RD
	WHERE RD.ProcessID=@intSourceProcessID AND
		  RD.ProcessNo=@intSourceProcessNo AND
		  RD.FiscalYear=@intSourceFiscalYear AND
		  RD.SerialNo=@intSourceSerialNo 

	Open  Cursor_PayDtl; 

	Fetch NEXT From Cursor_PayDtl Into  @CurrencyRateDtl,@CurrencyTypeIDDtl,@PayTypeID,@Amount,@RowDesc,@VolumeFiscalYear,@VolumeRowNo,@DebitCode,@CreditCode,@ChequeNo,@ChequeDate,@CurrencyAmount,@DocRowNo,@BaseID

	While (@@Fetch_Status = 0)
		BEGIN
			
			SET @strRecDesc = ' برگ انتقال شماره' + LTRIM(RTRIM(STR(@intSourceFiscalYear))) + '/' + LTRIM(RTRIM(STR(@intSourceSerialNo)))
			IF @PayTypeID=1
				BEGIN
					SET @strRecDesc = @strRecDesc + ' صندوق '
					SELECT @AcntCode2=AcntCode1 ,@BankState=BankState
					FROM trs.tblOurBanks
					WHERE BankCode=@DebitCode
				END	
			IF @PayTypeID=2
				BEGIN
					SET @strRecDesc = @strRecDesc + ' حواله '
					SELECT @AcntCode2=AcntCode1 ,@BankState=BankState
					FROM trs.tblOurBanks
					WHERE BankCode=@DebitCode
				END	
			IF @PayTypeID=6 OR @PayTypeID=26 
				BEGIN
					SET @strRecDesc = @strRecDesc + ' چک به شماره ' + LTRIM(RTRIM(STR(@ChequeNo))) + ' به سررسید ' + @ChequeDate
					SELECT @AcntCode2=AcntCode2 ,@BankState=BankState
					FROM trs.tblOurBanks
					WHERE BankCode=@DebitCode
				END	
			IF @PayTypeID=30 or @PayTypeID=7
				BEGIN
					SET @strRecDesc = @strRecDesc + ' انتقال بين بانک ها به شماره ' + LTRIM(RTRIM(STR(@ChequeNo))) + ' به تاريخ ' + @ChequeDate
					SELECT @AcntCode2=AcntCode1 ,@BankState=BankState
					FROM trs.tblOurBanks
					WHERE BankCode=@DebitCode
				END	
			-------------
			SET @intMaxDocRowNo = @intMaxDocRowNo + 1
			SET @intMaxRowNo = @intMaxRowNo + 1

			IF @AcntCode2 IS NULL SET @AcntCode2=''

			--IF @PayTypeID<>30 AND @BankState=3
			--	BEGIN
			--		Close Cursor_PayDtl;
			--		Deallocate Cursor_PayDtl; 
			--		-- نوع کد در تعاریف صندوق عوض شده است
			--		SET @strMsgText=TS.pub.funGetMessages(11036,@LanguageID)
			--		Raiserror (@strMsgText,16,1)
			--		Return
			--	END 

			IF @BankState=1 
				BEGIN
					IF @AcntCode2=''
						BEGIN
							Close Cursor_PayDtl;
							Deallocate Cursor_PayDtl; 
							--كد اسناد دریافتنی تجاری خالی است
							SET @strMsgText=TS.pub.funGetMessages(11022,@LanguageID)	
							Raiserror (@strMsgText,16,1)
							Return
						END
				END
			ELSE IF @BankState=2
				BEGIN
					IF @AcntCode2=''
						BEGIN
							Close Cursor_PayDtl;
							Deallocate Cursor_PayDtl; 
							--كد اسناد دریافتنی تجاری خالی است
							SET @strMsgText=TS.pub.funGetMessages(11022,@LanguageID)
							Raiserror (@strMsgText,16,1)
							Return
						END
				END
			ELSE IF @BankState=3
				BEGIN
					IF @AcntCode2=''
						BEGIN
							Close Cursor_PayDtl;
							Deallocate Cursor_PayDtl; 
							--'کد حسابداری موجودی بانک خالی است'
							SET @strMsgText=TS.pub.funGetMessages(11025,@LanguageID)
							Raiserror (@strMsgText,16,1)
							Return
						END
				END

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

				IF LEN(@CustomerCode)>@start
					SET @AcntCode2 = LEFT(pub.funPadRight(@AcntCode2,' ',@start-1),@start-1) + SUBSTRING(@CustomerCode,@start,20)
			END		
	
				
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
							set @CurrencyAmountAtom =0

							IF @CurrencyRate <> 0 
								SET @CurrencyAmountAtom = ROUND(@AtomAmount,0) / @CurrencyRate
						
						IF [acc].[funIsCurrencyAcntCode] (@AtomAcntCode) = 'True'
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
									(SerialNo,SourceProcessID,SourceProcessNo,SourceFiscalYear,SourceSerialNo,SourceDocRowNo,DocDate,IsAutoDoc,SessionNo,VchKind,RowNo,DocRowNo,
										AcntCode,Debit,Credit,RecDesc,RecDesc2,SourceDocType,CurrencyAmount,CurrencyTypeID,BaseID ) 
							VALUES	(@intVchNo,@intSourceProcessID,@intSourceProcessNo,@intSourceFiscalYear,@intSourceSerialNo,@DocRowNo,@strVchDate ,1,@SessionNo ,1,@intMaxRowNo,@intMaxDocRowNo,
										@AtomAcntCode,@AtomAmount,0,TS.pub.funChangeFarsiStrings(pub.funReverseForCrystal(@AcntName)),@AtomDesc,0,@CurrencyAmountAtom,@CurrencyTypeIDTmp,@BaseID)

							Fetch NEXT From Cursor_PayAtom Into @AtomAcntCode,@AtomAmount,@AtomDesc
						END
			
					Close Cursor_PayAtom;
					Deallocate Cursor_PayAtom; 
			
				END
			
			ELSE
			
				BEGIN
						
					IF [acc].[funIsCurrencyAcntCode] (@AcntCode2) = 'True'
						Begin
							Set @CurrencyRateTmp	= @CurrencyRate
							Set @CurrencyAmountTmp  = @CurrencyAmount
							Set @CurrencyTypeIDTmp  = @CurrencyTypeID
							if @trs_CurrencyTypeInRow='True'
							begin
								Set @CurrencyRateTmp	= @CurrencyRateDtl
								Set @CurrencyTypeIDTmp  = @CurrencyTypeIDDtl
							end
						End
					Else
						Begin
							Set @CurrencyRateTmp	= 0
							Set @CurrencyAmountTmp  = 0
							Set @CurrencyTypeIDTmp  = ''
						End

						INSERT INTO acc.tblVoucherDtl
								(SerialNo,SourceProcessID,SourceProcessNo,SourceFiscalYear,SourceSerialNo,SourceDocRowNo,DocDate,IsAutoDoc,SessionNo,VchKind,RowNo,DocRowNo,
									AcntCode,Debit,Credit,RecDesc,RecDesc2,SourceDocType,CurrencyAmount,CurrencyTypeID,BaseID) 
						VALUES	(@intVchNo,@intSourceProcessID,@intSourceProcessNo,@intSourceFiscalYear,@intSourceSerialNo,@DocRowNo,@strVchDate ,1,@SessionNo ,1,@intMaxRowNo ,@intMaxDocRowNo,
									@AcntCode2,@Amount,0,TS.pub.funChangeFarsiStrings(pub.funReverseForCrystal(@strRecDesc)),TS.pub.funChangeFarsiStrings(@RowDesc),0,@CurrencyAmountTmp,@CurrencyTypeIDTmp,@BaseID )			
			end 
		------------------------------------------------------------------------------------------------------------------------------
			IF @Has2CurrencyInPay= 'True'  And @CurrencyTypeIDHdr<>''  and @CurrencyTypeIDTmp<>@CurrencyTypeIDHdr
			Begin
				SET @intMaxDocRowNo = @intMaxDocRowNo +1
				SET @intMaxRowNo = @intMaxRowNo + 1
											
				IF [acc].[funIsCurrencyAcntCode] (@AcntCode2) = 'True'
				Begin
					Set @CurrencyRateTmp	= @CurrencyRate
					Set @CurrencyAmountTmp  = @CurrencyAmount
					Set @CurrencyTypeIDTmp  = @CurrencyTypeID 
					if @trs_CurrencyTypeInRow='True'
					begin
						Set @CurrencyRateTmp	= @CurrencyRateDtl
						Set @CurrencyTypeIDTmp  = @CurrencyTypeIDDtl
					end
				End
				Else
				Begin
					Set @CurrencyRateTmp	= 0
					Set @CurrencyAmountTmp  = 0
					Set @CurrencyTypeIDTmp  = ''
				End
				
				INSERT INTO acc.tblVoucherDtl
					(SerialNo,SourceProcessID,SourceProcessNo,SourceFiscalYear,SourceSerialNo,SourceDocRowNo,DocDate,IsAutoDoc,SessionNo,VchKind,RowNo,DocRowNo,
					AcntCode,Debit,Credit,RecDesc,RecDesc2,SourceDocType,CurrencyAmount,CurrencyTypeID ,BaseID) 
				VALUES	
					(@intVchNo,@intSourceProcessID,@intSourceProcessNo,@intSourceFiscalYear,@intSourceSerialNo,@DocRowNo,@strVchDate ,1,@SessionNo ,1,@intMaxRowNo,@intMaxDocRowNo,
					@AcntCode2,0,@Amount,TS.pub.funChangeFarsiStrings(pub.funReverseForCrystal(@strRecDesc)),TS.pub.funChangeFarsiStrings(pub.funReverseForCrystal(@RowDesc)),0,@CurrencyAmountTmp,@CurrencyTypeIDTmp,@BaseID)			
							 
				SET @intMaxDocRowNo = @intMaxDocRowNo + 1
				SET @intMaxRowNo = @intMaxRowNo + 1

				Set @CurrencyAmountTmp=@Amount/ @CurrencyRateHdr
				Set @CurrencyTypeIDTmp=@CurrencyTypeIDHdr

				INSERT INTO acc.tblVoucherDtl
					(SerialNo,SourceProcessID,SourceProcessNo,SourceFiscalYear,SourceSerialNo,SourceDocRowNo,DocDate,IsAutoDoc,SessionNo,VchKind,RowNo,DocRowNo,
					AcntCode,Debit,Credit,RecDesc,RecDesc2,SourceDocType,CurrencyAmount,CurrencyTypeID ,BaseID) 
				VALUES	
					(@intVchNo,@intSourceProcessID,@intSourceProcessNo,@intSourceFiscalYear,@intSourceSerialNo,@DocRowNo,@strVchDate ,1,@SessionNo ,1,@intMaxRowNo,@intMaxDocRowNo,
					@AcntCode2,@Amount,0,TS.pub.funChangeFarsiStrings(pub.funReverseForCrystal(@strRecDesc)),TS.pub.funChangeFarsiStrings(pub.funReverseForCrystal(@RowDesc)),0,@CurrencyAmountTmp,@CurrencyTypeIDTmp,@BaseID)			

	 		End
-------------------------------------------------------------------------------------------------------------------------------				1
	
			-------------
	
			IF @PayTypeID=1
				BEGIN
					SELECT @AcntCode2=AcntCode1 ,@BankState=BankState
					FROM trs.tblOurBanks
					WHERE BankCode=@CreditCode
				END	
			IF @PayTypeID=2
				BEGIN
					SELECT @AcntCode2=AcntCode1 ,@BankState=BankState
					FROM trs.tblOurBanks
					WHERE BankCode=@CreditCode
				END	
			IF @PayTypeID=6 OR @PayTypeID=26 
				BEGIN
					SELECT @AcntCode2=AcntCode2 ,@BankState=BankState
					FROM trs.tblOurBanks
					WHERE BankCode=@CreditCode
				END	
			IF @PayTypeID=30 or @PayTypeID=7
				BEGIN
					SELECT @AcntCode2=AcntCode1 ,@BankState=BankState
					FROM trs.tblOurBanks
					WHERE BankCode=@CreditCode
				END	
			--SELECT @AcntCode2=AcntCode2 ,@BankState=BankState
			--FROM trs.tblOurBanks
			--WHERE BankCode=@CreditCode

			IF @AcntCode2 IS NULL SET @AcntCode2=''

			--IF @PayTypeID<>30 AND @BankState=3
			--	BEGIN
			--		Close Cursor_PayDtl;
			--		Deallocate Cursor_PayDtl; 				
			--		-- نوع کد در تعاریف صندوق عوض شده است
			--		SET @strMsgText=TS.pub.funGetMessages(11036,@LanguageID)
			--		Raiserror (@strMsgText,16,1)
			--		Return
			--	END 

			IF @BankState=1 
				BEGIN
					IF @AcntCode2=''
						BEGIN
							Close Cursor_PayDtl;
							Deallocate Cursor_PayDtl; 
					        --كد اسناد دریافتنی تجاری خالی است
							SET @strMsgText=TS.pub.funGetMessages(11022,@LanguageID)
							Raiserror (@strMsgText,16,1)
							Return
						END
				END
			ELSE IF @BankState=2
				BEGIN
					IF @AcntCode2=''
						BEGIN
							Close Cursor_PayDtl;
							Deallocate Cursor_PayDtl; 
						    --كد اسناد دریافتنی تجاری خالی است
							SET @strMsgText=TS.pub.funGetMessages(11022,@LanguageID)
							Raiserror (@strMsgText,16,1)
							Return
						END
				END
			ELSE IF @BankState=3
				BEGIN
					IF @AcntCode2=''
						BEGIN
							Close Cursor_PayDtl;
							Deallocate Cursor_PayDtl; 
							--کد حسابداری موجودی بانک خالی است
							SET @strMsgText=TS.pub.funGetMessages(11025,@LanguageID)
							Raiserror (@strMsgText,16,1)
							Return
						END
				END
				
	

				IF @BankCodeReplaceWithCustomerCodeInReceive='True' AND (@PayTypeID =6 OR @PayTypeID =16  OR @PayTypeID =26)
					BEGIN
						DECLARE @CustomerCode1 varchar(20)
						SELECT Top 1 @CustomerCode1 = CreditCode
						FROM	trs.tblPayDtl
						WHERE	ProcessID IN (1,10) AND 
								PayTypeID IN (6,16,26) AND 
								VolumeFiscalYear = @VolumeFiscalYear AND 
								VolumeRowNo = @VolumeRowNo
						ORDER By EventNo ASC

						IF LEN(@CustomerCode1)>@start
							SET @AcntCode2 = LEFT(pub.funPadRight(@AcntCode2,' ',@start-1),@start-1) + SUBSTRING(@CustomerCode1,@start,20)
					END	
		
				IF [acc].[funIsCurrencyAcntCode] (@AcntCode2) = 'True'
						Begin
							Set @CurrencyRateTmp	= @CurrencyRate
							Set @CurrencyAmountTmp  = @CurrencyAmount
							Set @CurrencyTypeIDTmp  = @CurrencyTypeID 
							if @trs_CurrencyTypeInRow='True'
							begin
								Set @CurrencyRateTmp	= @CurrencyRateDtl
								Set @CurrencyTypeIDTmp  = @CurrencyTypeIDDtl
							end
						End
						Else
						Begin
							Set @CurrencyRateTmp	= 0
							Set @CurrencyAmountTmp  = 0
							Set @CurrencyTypeIDTmp  = ''
						End
						
					INSERT INTO acc.tblVoucherDtl
						(SerialNo,SourceProcessID,SourceProcessNo,SourceFiscalYear,SourceSerialNo,SourceDocRowNo,DocDate,IsAutoDoc,SessionNo,VchKind,RowNo,DocRowNo,
							AcntCode,Debit,Credit,RecDesc,RecDesc2,SourceDocType,CurrencyAmount,CurrencyTypeID,BaseID) 
					VALUES	(@intVchNo,@intSourceProcessID,@intSourceProcessNo,@intSourceFiscalYear,@intSourceSerialNo,@DocRowNo,@strVchDate ,1,@SessionNo ,1,@intMaxRowNo+@intRowCount ,@intMaxDocRowNo+@intRowCount,
							@AcntCode2,0,@Amount,TS.pub.funChangeFarsiStrings(pub.funReverseForCrystal(@strRecDesc)),TS.pub.funChangeFarsiStrings(@RowDesc) ,0,@CurrencyAmountTmp,@CurrencyTypeIDTmp,@BaseID)			
					
			Fetch NEXT From Cursor_PayDtl Into  @CurrencyRateDtl,@CurrencyTypeIDDtl,@PayTypeID,@Amount,@RowDesc,@VolumeFiscalYear,@VolumeRowNo,@DebitCode,@CreditCode,@ChequeNo,@ChequeDate,@CurrencyAmount,@DocRowNo,@BaseID
		END
	Close Cursor_PayDtl;
	Deallocate Cursor_PayDtl; 
END
GO
