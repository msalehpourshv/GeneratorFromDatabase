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
Create PROCEDURE [acc].[SpVchPayableReturn]
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
	Declare @DebitCode	Varchar(20)
	Declare @CreditCode	Varchar(20)
	Declare @ChequeNo	Bigint
	Declare @ChequeDate	Char(10)
	Declare @AcntCode2	Varchar(20)
	Declare @AcntCode5	Varchar(20)
	Declare @strRecDesc NVarChar(1000)
	Declare @VolumeFiscalYear	SmallInt
	Declare @VolumeRowNo		INT	
	Declare @RowNo		INT
	DECLARE @BaseID Int
	DECLARE @strSourceProcessNo NVARCHAR(100)
	DECLARE @AtomAcntCode Varchar(20)
	Declare @CurrencyTypeID	VarChar(20)
	Declare @CurrencyRate	Float
	DECLARE @AtomAmount FLOAT 
	DECLARE @AtomDesc   Nvarchar(2000)	
	Declare @CurrencyAmount	Float
	Declare @CurrencyAmountAtom	Float
	DECLARE @AcntName   NVarchar(1000)
	Declare @CurrencyTypeIDTemp	VarChar(20)

	Declare @CurrencyRateTmp			Float
	Declare @CurrencyAmountTmp			Float
	Declare @CurrencyTypeIDTmp			VarChar(20)
	DECLARE @BankCodeReplaceWithCustomerCodeInPayment BIT
	DECLARE @start int 
	--DECLARE @IsAtom BIT
	--SET @IsAtom = 'False'

	IF  @intSourceProcessNo< 2
		SET @strSourceProcessNo = ''
	ELSE
		SET @strSourceProcessNo = LTRIM(RTRIM(STR(@intSourceProcessNo)))
		
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
    ---- جایگزینی کد حسابداری معین و یا بقیه با کد موجود در تنظیمات
	--DECLARE @PayDebAcntCodeRet varchar(30)
	--SET @PayDebAcntCodeRet = ''
	
	--SELECT @PayDebAcntCodeRet= SettingValue
	--FROM pub.tblSettings
	--WHERE SettingKey = 'PayDebAcntCodeRet'
			
	-----
	Declare	Cursor_PayDtl CURSOR For 
	SELECT	PayTypeID,Amount,RowDesc,ChequeNo,ChequeDate,AcntCode2,AcntCode5,VolumeFiscalYear,VolumeRowNo,RowNo,BankState,CreditCode,RD.ID
	FROM trs.tblPayDtl RD,trs.tblOurBanks OB
	WHERE RD.DebitCode=OB.BankCode AND
		  RD.ProcessID=@intSourceProcessID AND
		  RD.ProcessNo=@intSourceProcessNo AND
		  RD.FiscalYear=@intSourceFiscalYear AND
		  RD.SerialNo=@intSourceSerialNo 
	order by RD.DocRowNo

	Open  Cursor_PayDtl; 

	Fetch NEXT From Cursor_PayDtl Into @PayTypeID,@Amount,@RowDesc,@ChequeNo,@ChequeDate,@AcntCode2,@AcntCode5,@VolumeFiscalYear,@VolumeRowNo,@RowNo,@BankState,@DebitCode,@BaseID

	While (@@Fetch_Status = 0)
		BEGIN
			--SEt @IsAtom = 'False'

			IF @BankState <> 3
				BEGIN
					Close Cursor_PayDtl;
					Deallocate Cursor_PayDtl; 
					-- نوع کد در تعاریف بانکها عوض شده است
					SET @strMsgText=TS.pub.funGetMessages(11033,@LanguageID)
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
					SET @CreditCode=@AcntCode2
					IF @CreditCode=''
						BEGIN
							Close Cursor_PayDtl;
							Deallocate Cursor_PayDtl; 						
							--كد حسابداري اسناد پرداختني تجاری خالی است
							SET @strMsgText=TS.pub.funGetMessages(11010,@LanguageID)
							Raiserror (@strMsgText,16,1)
							Return
						END
				END
				
			ELSE
			
				BEGIN
					SET @CreditCode=@AcntCode5
					IF @CreditCode=''
						BEGIN
							Close Cursor_PayDtl;
							Deallocate Cursor_PayDtl;
							--كد حسابداري اسناد پرداختني غیر تجاری خالی است
							SET @strMsgText=TS.pub.funGetMessages(11028,@LanguageID)
							Raiserror (@strMsgText,16,1)
							Return							
						END	
				END


			-----
--			SELECT TOP 1 @DebitCode=DebitCode
--			FROM trs.tblPayDtl RD
--			WHERE RD.VolumeFiscalYear=@VolumeFiscalYear AND
--				  RD.VolumeRowNo=@VolumeRowNo AND
--				  RD.ProcessID=2 
--			ORDER BY RD.EventNo
			
			---- جایگزینی کد حسابداری معین و یا بقیه با کد موجود در تنظیمات
			--IF  LEN(@PayDebAcntCodeRet)>0
			--	SET @DebitCode = [pub].[funReplaceCode] (@DebitCode,@PayDebAcntCodeRet)
				
				SET @strRecDesc = ' استرداد سند پرداختني ' + @strSourceProcessNo + ' شماره ' + LTRIM(RTRIM(STR(@intSourceFiscalYear))) + '/' + LTRIM(RTRIM(STR(@intSourceSerialNo))) +
									  ' به شماره چک ' + LTRIM(RTRIM(STR(@ChequeNo,30))) + ' به سررسید ' + @ChequeDate + ' ' + pub.GetCodeName(@DebitCode,@LanguageID)
			-----
					SET @intMaxDocRowNo = @intMaxDocRowNo + 1
					SET @intMaxRowNo = @intMaxRowNo + 1
					
					
			IF @CurrencyAmount >0
				SET @CurrencyTypeIDTemp = @CurrencyTypeID
			ELSE
				SET @CurrencyTypeIDTemp = ''
				
			IF [acc].[funIsCurrencyAcntCode] (@CreditCode) = 'True'
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
					
				--IF @BankCodeReplaceWithCustomerCodeInPayment='True' AND 
				--   (SELECT COUNT(*) 
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
				--		  VolumeRowNo   = @VolumeRowNo) >0
				--	SEt @IsAtom = 'True'

				IF @BankCodeReplaceWithCustomerCodeInPayment='True' AND 
				  (@PayTypeID =8 OR @PayTypeID =28) 
					
				BEGIN

					SET @start = [acc].[FunGetAcntInfoForRemain](2)
					IF LEN(@DebitCode)>@start
						SET @CreditCode = LEFT(pub.funPadRight(@CreditCode,' ',@start-1),@start-1) + SUBSTRING(@DebitCode,@start,20)
				END
				--IF @IsAtom ='False'
				
				IF @CreditCode =''
				BEGIN				
					Close Cursor_PayDtl;
					Deallocate Cursor_PayDtl; 
					SET @strMsgText='کد طرف حساب خالی است'
					Raiserror (@strMsgText,16,1)
					Return
				END
	

				INSERT INTO acc.tblVoucherDtl
						(SerialNo,SourceProcessID,SourceProcessNo,SourceFiscalYear,SourceSerialNo,DocDate,IsAutoDoc,SessionNo,VchKind,RowNo,DocRowNo,
							AcntCode,Debit,Credit,RecDesc,RecDesc2,SourceDocType,BaseID,CurrencyAmount,CurrencyTypeID) 
				VALUES	(@intVchNo,@intSourceProcessID,@intSourceProcessNo,@intSourceFiscalYear,@intSourceSerialNo,@strVchDate ,1,@SessionNo ,1,@intMaxRowNo ,@intMaxDocRowNo,
							@CreditCode,@Amount,0,TS.pub.funChangeFarsiStrings(pub.funReverseForCrystal(@strRecDesc)),@RowDesc,0 ,@BaseID,@CurrencyAmountTmp,@CurrencyTypeIDTmp)			


					IF (SELECT COUNT(*) 
				FROM trs.tblPayAtm pa
				inner join trs.tblPayDtl rd
				on pa.ProcessID = rd.ProcessID
				AND pa.ProcessNo = rd.ProcessNo
				AND pa.FiscalYear = rd.FiscalYear
				AND pa.SerialNo = rd.SerialNo
				AND pa.DocRowNo = rd.DocRowNo
				WHERE rd.ProcessID  in (2,25) AND 
					  rd.ProcessNo  = @intSourceProcessNo AND 
					  rd.FiscalYear = @intSourceFiscalYear AND 
					  VolumeFiscalYear = @VolumeFiscalYear AND 
					  VolumeRowNo   = @VolumeRowNo ) >0
				BEGIN


	--				IF @BankCodeReplaceWithCustomerCodeInPayment='True'		
	--					BEGIN										
	--						SET @start = [acc].[FunGetAcntInfoForRemain](2)
						
	--						Declare	Cursor_GroupPayAtom CURSOR For 
	--						SELECT	SUBSTRING(AtomAcntCode,@start,20) AtomAcntCode, SUM(AtomAmount) AtomAmount
	--						FROM trs.tblPayAtm pa
	--						inner join trs.tblPayDtl rd
	--						on pa.ProcessID = rd.ProcessID
	--						AND pa.ProcessNo = rd.ProcessNo
	--						AND pa.FiscalYear = rd.FiscalYear
	--						AND pa.SerialNo = rd.SerialNo
	--						AND pa.DocRowNo = rd.DocRowNo
	--						WHERE rd.ProcessID  in (2,25) AND 
	--							  rd.ProcessNo  = @intSourceProcessNo AND 
	--							  rd.FiscalYear = @intSourceFiscalYear AND 
	--							  VolumeFiscalYear = @VolumeFiscalYear AND 
	--							  VolumeRowNo   = @VolumeRowNo	 
	--						GROUP BY SUBSTRING(AtomAcntCode,@start,20)

	--						Open  Cursor_GroupPayAtom; 

	--						Fetch NEXT From Cursor_GroupPayAtom Into @AtomAcntCode,@AtomAmount

	--						While (@@Fetch_Status = 0)
	--							BEGIN
	--							SET @strRecDesc = ' استرداد سند پرداختني ' + @strSourceProcessNo + ' شماره ' + LTRIM(RTRIM(STR(@intSourceFiscalYear))) + '/' + LTRIM(RTRIM(STR(@intSourceSerialNo))) +
	--							' به شماره چک ' + LTRIM(RTRIM(STR(@ChequeNo,30))) + ' به سررسید ' + @ChequeDate + ' ' + pub.GetCodeName(@DebitCode,@LanguageID)
	-------
	--							SET @intMaxDocRowNo = @intMaxDocRowNo + 1
	--							SET @intMaxRowNo = @intMaxRowNo + 1
					
					
	--							IF @CurrencyAmount >0
	--								SET @CurrencyTypeIDTemp = @CurrencyTypeID
	--							ELSE
	--								SET @CurrencyTypeIDTemp = ''
				
	--							IF [acc].[funIsCurrencyAcntCode] (@CreditCode) = 'True'
	--							Begin
	--								Set @CurrencyRateTmp	= @CurrencyRate
	--								Set @CurrencyAmountTmp  = @CurrencyAmount
	--								Set @CurrencyTypeIDTmp  = @CurrencyTypeIDTemp
	--							End
	--							Else
	--							Begin
	--								Set @CurrencyRateTmp	= 0
	--								Set @CurrencyAmountTmp  = 0
	--								Set @CurrencyTypeIDTmp  = ''
	--							End
					
	--							SET @start = [acc].[FunGetAcntInfoForRemain](2)

	--							SET @CreditCode = LEFT(pub.funPadRight(@CreditCode,' ',@start-1),@start-1) + @AtomAcntCode
					
				
	--							INSERT INTO acc.tblVoucherDtl
	--									(SerialNo,SourceProcessID,SourceProcessNo,SourceFiscalYear,SourceSerialNo,DocDate,IsAutoDoc,SessionNo,VchKind,RowNo,DocRowNo,
	--										AcntCode,Debit,Credit,RecDesc,RecDesc2,SourceDocType,BaseID,CurrencyAmount,CurrencyTypeID) 
	--							VALUES	(@intVchNo,@intSourceProcessID,@intSourceProcessNo,@intSourceFiscalYear,@intSourceSerialNo,@strVchDate ,1,@SessionNo ,1,@intMaxRowNo ,@intMaxDocRowNo,
	--										@CreditCode,@AtomAmount,0,TS.pub.funChangeFarsiStrings(pub.funReverseForCrystal(@strRecDesc)),@RowDesc,0 ,@BaseID,@CurrencyAmountTmp,@CurrencyTypeIDTmp)			
							
	--							Fetch NEXT From Cursor_GroupPayAtom Into @AtomAcntCode,@AtomAmount
	--						END
	--						Close Cursor_GroupPayAtom;
	--						Deallocate Cursor_GroupPayAtom; 	
	--					END



					Declare	Cursor_PayAtom CURSOR For 
					SELECT	AtomAcntCode, AtomAmount, AtomDesc
					FROM trs.tblPayAtm pa
					inner join trs.tblPayDtl rd
					on pa.ProcessID = rd.ProcessID
					AND pa.ProcessNo = rd.ProcessNo
					AND pa.FiscalYear = rd.FiscalYear
					AND pa.SerialNo = rd.SerialNo
					AND pa.DocRowNo = rd.DocRowNo
					WHERE rd.ProcessID  in (2,25) AND 
						  rd.ProcessNo  = @intSourceProcessNo AND 
						  rd.FiscalYear = @intSourceFiscalYear AND 
						  VolumeFiscalYear = @VolumeFiscalYear AND 
						  VolumeRowNo   = @VolumeRowNo	

					Open  Cursor_PayAtom; 

					Fetch NEXT From Cursor_PayAtom Into @AtomAcntCode,@AtomAmount,@AtomDesc

					While (@@Fetch_Status = 0)
						BEGIN

							SET @AcntName = @strRecDesc + ' از '  + pub.GetCodeName(@AtomAcntCode,@LanguageID)
						
							IF @CurrencyRate <> 0 	
								SET @CurrencyAmountAtom = ROUND(@AtomAmount,0) / @CurrencyRate
					---------------------------------------------------
							SET @intMaxDocRowNo = @intMaxDocRowNo + 1
							SET @intMaxRowNo = @intMaxRowNo + 1

							INSERT INTO acc.tblVoucherDtl
									(SerialNo,SourceProcessID,SourceProcessNo,SourceFiscalYear,SourceSerialNo,DocDate,IsAutoDoc,SessionNo,VchKind,RowNo,DocRowNo,
										AcntCode,Debit,Credit,RecDesc,RecDesc2,SourceDocType,BaseID ) 
							VALUES	(@intVchNo,@intSourceProcessID,@intSourceProcessNo,@intSourceFiscalYear,@intSourceSerialNo,@strVchDate ,1,@SessionNo ,1,@intMaxRowNo ,@intMaxDocRowNo,
										@AtomAcntCode,0,@AtomAmount,TS.pub.funChangeFarsiStrings(pub.funReverseForCrystal(@strRecDesc)),TS.pub.funChangeFarsiStrings(pub.funReverseForCrystal(@RowDesc)),0,@BaseID )

							Fetch NEXT From Cursor_PayAtom Into @AtomAcntCode,@AtomAmount,@AtomDesc
						END
			
					Close Cursor_PayAtom;
					Deallocate Cursor_PayAtom; 
			
				END
			
			ELSE
			
				BEGIN

				SET @intMaxDocRowNo = @intMaxDocRowNo + 1
				SET @intMaxRowNo = @intMaxRowNo + 1
				
				IF @DebitCode =''
				BEGIN				
					Close Cursor_PayDtl;
					Deallocate Cursor_PayDtl; 
					SET @strMsgText='کد طرف حساب دریافت کننده چک خالی است'
					Raiserror (@strMsgText,16,1)
					Return
				END
	

				INSERT INTO acc.tblVoucherDtl
						(SerialNo,SourceProcessID,SourceProcessNo,SourceFiscalYear,SourceSerialNo,DocDate,IsAutoDoc,SessionNo,VchKind,RowNo,DocRowNo,
							AcntCode,Debit,Credit,RecDesc,RecDesc2,SourceDocType,BaseID,CurrencyAmount,CurrencyTypeID) 
				VALUES	(@intVchNo,@intSourceProcessID,@intSourceProcessNo,@intSourceFiscalYear,@intSourceSerialNo,@strVchDate ,1,@SessionNo ,1,@intMaxRowNo ,@intMaxDocRowNo,
							@DebitCode,0,@Amount,TS.pub.funChangeFarsiStrings(pub.funReverseForCrystal(@strRecDesc)),@RowDesc,0 ,@BaseID,@CurrencyAmountTmp,@CurrencyTypeIDTmp)

			end 

			-----	
			Fetch NEXT From Cursor_PayDtl Into @PayTypeID,@Amount,@RowDesc,@ChequeNo,@ChequeDate,@AcntCode2,@AcntCode5,@VolumeFiscalYear,@VolumeRowNo,@RowNo,@BankState,@DebitCode,@BaseID

		END

	Close Cursor_PayDtl;
	Deallocate Cursor_PayDtl; 

END
GO
