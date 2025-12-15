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
Create PROCEDURE [acc].[SpVchReceivableReturn]
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
	Declare @Amount		float
	Declare @RowDesc	Nvarchar(1000)	
	Declare @DebitCode	Varchar(20)
	Declare @CreditCode	Varchar(20)
	Declare @ChequeNo	Bigint
	Declare @ChequeDate	Char(10)
	Declare @AcntCode2	Varchar(20)
	Declare @AcntCode5	Varchar(20)
	Declare @VisitorAcntCode	Varchar(20)	
	Declare @strRecDesc NVarChar(1000)
	Declare @VolumeFiscalYear	SmallInt
	Declare @VolumeRowNo	INT	
	DECLARE @strSourceProcessNo NVARCHAR(100)
	DECLARE @AtomAcntCode Varchar(20)
	DECLARE @AtomAmount FLOAT 
	DECLARE @AtomDesc   Nvarchar(2000)	
	Declare @BaseID Int
	DECLARE @BankCodeReplaceWithCustomerCodeInReceive BIT
	Declare @start int 
	DECLARE @strAcntName				NVarChar(500)
	DECLARE @trs_AcntNameInVoucherDesc  BIT
	SELECT @trs_AcntNameInVoucherDesc = SettingValue FROM pub.tblSettings WHERE SettingKey = 'trs_AcntNameInVoucherDesc'

	SET @BankCodeReplaceWithCustomerCodeInReceive = 'False'
	SELECT   @BankCodeReplaceWithCustomerCodeInReceive=SettingValue
	FROM pub.tblSettings 
	WHERE SettingKey = 'BankCodeReplaceWithCustomerCodeInReceive'	
	
	IF  @intSourceProcessNo< 2
		SET @strSourceProcessNo = ''
	ELSE
		SET @strSourceProcessNo = LTRIM(RTRIM(STR(@intSourceProcessNo)))


	--------------------------------------------------------------------------------------------------------
	Declare	Cursor_PayDtl CURSOR For 
	SELECT	RD.PayTypeID,RD.Amount,RD.RowDesc,RD.ChequeNo,RD.ChequeDate,RD.DebitCode,AcntCode2,AcntCode5,VolumeFiscalYear,VolumeRowNo,RD.ID,RD.VisitorAcntCode
	FROM	trs.tblPayDtl RD,trs.tblOurBanks OB,trs.tblPayHdr RH
	WHERE	RD.ProcessID = RH.ProcessID AND 
			RD.ProcessNo = RH.ProcessNo AND 
			RD.FiscalYear = RH.FiscalYear AND 
			RD.SerialNo = RH.SerialNo AND 
			RH.CreditCode=OB.BankCode AND
			RD.ProcessID=@intSourceProcessID AND
			RD.ProcessNo=@intSourceProcessNo AND
			RD.FiscalYear=@intSourceFiscalYear AND
			RD.SerialNo=@intSourceSerialNo 
	order by RD.DocRowNo

	Open  Cursor_PayDtl; 

	Fetch NEXT From Cursor_PayDtl Into @PayTypeID,@Amount,@RowDesc,@ChequeNo,@ChequeDate,@DebitCode,@AcntCode2,@AcntCode5,@VolumeFiscalYear,@VolumeRowNo,@BaseID ,@VisitorAcntCode

	While (@@Fetch_Status = 0)
		BEGIN

			IF @trs_AcntNameInVoucherDesc = 'True'
				Select @strAcntName = ' از ' + [pub].GetCodeName(@DebitCode, @LanguageID)
			ELSE
				SET @strAcntName = ''

			SET @strRecDesc = ' برگشت سند دریافتی ' + @strSourceProcessNo + ' شماره' + LTRIM(RTRIM(STR(@intSourceFiscalYear))) + '/' + LTRIM(RTRIM(STR(@intSourceSerialNo))) +
							  ' به شماره چک ' + LTRIM(RTRIM(STR(@ChequeNo,30))) + ' به سررسید ' + @ChequeDate

			---------------------------------------------------
			Declare @TempPayTypeID AS TinyInt
			SELECT @TempPayTypeID=PayTypeID
			FROM trs.tblPayDtl
			WHERE	ProcessID IN (1,10) AND
					VolumeFiscalYear=@VolumeFiscalYear AND
					VolumeRowNo=@VolumeRowNo

			IF @TempPayTypeID=6
				BEGIN
					SET @CreditCode=@AcntCode2
					IF @CreditCode=''
						--كد اسناد دریافتنی تجاری خالی است
						SET @strMsgText=TS.pub.funGetMessages(11018,@LanguageID)
				END
			ELSE
				BEGIN
					SET @CreditCode=@AcntCode5
					IF @CreditCode=''
						--كد اسناد دریافتنی غیر تجاری خالی است
						SET @strMsgText=TS.pub.funGetMessages(11024,@LanguageID)
				END


			---------------------------------------------------
			IF @strMsgText<>''
				BEGIN
					Close Cursor_PayDtl;
					Deallocate Cursor_PayDtl;
					Raiserror (@strMsgText,16,1)
					Return
				END

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
					  rd.FiscalYear = @VolumeFiscalYear AND 
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
						  rd.FiscalYear = @VolumeFiscalYear AND 
						  VolumeFiscalYear = @VolumeFiscalYear AND 
						  VolumeRowNo   = @VolumeRowNo	

					Open  Cursor_PayAtom; 

					Fetch NEXT From Cursor_PayAtom Into @AtomAcntCode,@AtomAmount,@AtomDesc

					While (@@Fetch_Status = 0)
						BEGIN

							---------------------------------
						declare @RecDebAcntCodeRet	as varchar(20)
						if @intSourceProcessID=13
						begin
								SELECT @RecDebAcntCodeRet = SettingValue
								FROM pub.tblSettings
								WHERE SettingKey = 'RecDebAcntCodeRet'
												
							set @AtomAcntCode= [pub].[funReplaceCode] (@AtomAcntCode,@RecDebAcntCodeRet)
						end
							---------------------------------
						
							SET @intMaxDocRowNo = @intMaxDocRowNo + 1
							SET @intMaxRowNo = @intMaxRowNo + 1
							if  charindex (@strAcntName,@strRecDesc)=0
								SET @strRecDesc = @strRecDesc + @strAcntName	

							INSERT INTO acc.tblVoucherDtl
									(SerialNo,SourceProcessID,SourceProcessNo,SourceFiscalYear,SourceSerialNo,DocDate,IsAutoDoc,SessionNo,VchKind,RowNo,DocRowNo,
										AcntCode,Debit,Credit,RecDesc,RecDesc2,SourceDocType,BaseID ,VisitorAcntCode) 
							VALUES	(@intVchNo,@intSourceProcessID,@intSourceProcessNo,@intSourceFiscalYear,@intSourceSerialNo,@strVchDate ,1,@SessionNo ,1,@intMaxRowNo ,@intMaxDocRowNo,
										@AtomAcntCode,@AtomAmount,0,TS.pub.funChangeFarsiStrings(pub.funReverseForCrystal(@strRecDesc)),TS.pub.funChangeFarsiStrings(pub.funReverseForCrystal(@RowDesc + '  ' +  @AtomDesc )),0,@BaseID ,@VisitorAcntCode)

							Fetch NEXT From Cursor_PayAtom Into @AtomAcntCode,@AtomAmount,@AtomDesc
						END
			
					Close Cursor_PayAtom;
					Deallocate Cursor_PayAtom; 
			
				END
			
			ELSE
			
				BEGIN
			
					---------------------------------------------------
					SET @intMaxDocRowNo = @intMaxDocRowNo + 1
					SET @intMaxRowNo = @intMaxRowNo + 1

					if  charindex (@strAcntName,@strRecDesc)=0
						SET @strRecDesc = @strRecDesc + @strAcntName	
					INSERT INTO acc.tblVoucherDtl
							(SerialNo,SourceProcessID,SourceProcessNo,SourceFiscalYear,SourceSerialNo,DocDate,IsAutoDoc,SessionNo,VchKind,RowNo,DocRowNo,
								AcntCode,Debit,Credit,RecDesc,RecDesc2,SourceDocType,BaseID,VisitorAcntCode ) 
					VALUES	(@intVchNo,@intSourceProcessID,@intSourceProcessNo,@intSourceFiscalYear,@intSourceSerialNo,@strVchDate ,1,@SessionNo ,1,@intMaxRowNo ,@intMaxDocRowNo,
								@DebitCode,@Amount,0,TS.pub.funChangeFarsiStrings(pub.funReverseForCrystal(@strRecDesc)),@RowDesc,0 ,@BaseID,@VisitorAcntCode )

				END

			---------------------------------------------------
			SET @intMaxDocRowNo = @intMaxDocRowNo + 1
			SET @intMaxRowNo = @intMaxRowNo + 1

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
					SET @CreditCode = LEFT(pub.funPadRight(@CreditCode,' ',@start-1),@start-1) + SUBSTRING(@CustomerCode,@start,20)
			END
			if  charindex (@strAcntName,@strRecDesc)=0
				SET @strRecDesc = @strRecDesc + @strAcntName	

			INSERT INTO acc.tblVoucherDtl
					(SerialNo,SourceProcessID,SourceProcessNo,SourceFiscalYear,SourceSerialNo,DocDate,IsAutoDoc,SessionNo,VchKind,RowNo,DocRowNo,
						AcntCode,Debit,Credit,RecDesc,RecDesc2,SourceDocType,BaseID,VisitorAcntCode ) 
			VALUES	(@intVchNo,@intSourceProcessID,@intSourceProcessNo,@intSourceFiscalYear,@intSourceSerialNo,@strVchDate ,1,@SessionNo ,1,@intMaxRowNo ,@intMaxDocRowNo,
						@CreditCode,0,@Amount,TS.pub.funChangeFarsiStrings(pub.funReverseForCrystal(@strRecDesc)),@RowDesc,0 ,@BaseID,@VisitorAcntCode )			

			---------------------------------------------------
			Fetch NEXT From Cursor_PayDtl Into @PayTypeID,@Amount,@RowDesc,@ChequeNo,@ChequeDate,@DebitCode,@AcntCode2,@AcntCode5,@VolumeFiscalYear,@VolumeRowNo,@BaseID ,@VisitorAcntCode

		END

	Close Cursor_PayDtl;
	Deallocate Cursor_PayDtl; 

END
GO
