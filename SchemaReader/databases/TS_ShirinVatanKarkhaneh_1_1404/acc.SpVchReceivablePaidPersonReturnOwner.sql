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
Create PROCEDURE [acc].[SpVchReceivablePaidPersonReturnOwner]
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
	Declare @Amount			float
	Declare @RowDescHdr		Nvarchar(1000)	
	Declare @RowDesc		Nvarchar(1000)	
	Declare @CreditCode		Varchar(20)
	Declare @DebitCode		Varchar(20)
	Declare @ChequeNo		Bigint
	Declare @ChequeDate		Char(10)
	Declare @AcntCode3		Varchar(20)
	Declare @VisitorAcntCode	Varchar(20)	
	Declare @strRecDesc		NVarChar(1000)
	Declare @VolumeFiscalYear	SmallInt
	Declare @VolumeRowNo	INT	
	DECLARE @strSourceProcessNo NVARCHAR(100)
	DECLARE @BaseID Int
	DECLARE @strAcntName nvarchar(200)
	DECLARE @AtomAcntCode Varchar(20)
	DECLARE @AtomAmount FLOAT 
	DECLARE @AtomDesc   Nvarchar(2000)	

	set @strAcntName=''

	IF  @intSourceProcessNo< 2
		SET @strSourceProcessNo = ''
	ELSE
		SET @strSourceProcessNo = LTRIM(RTRIM(STR(@intSourceProcessNo)))

	--------------------------------------------------------------------------------------------------------
	---- جایگزینی کد حسابداری معین و یا بقیه با کد موجود در تنظیمات
	--DECLARE @RecDebAcntCodeRet varchar(30)
	--SET @RecDebAcntCodeRet = ''
	
	--SELECT @RecDebAcntCodeRet= SettingValue
	--FROM pub.tblSettings
	--WHERE SettingKey = 'RecDebAcntCodeRet'
	
	---- 
	--DECLARE @RecCrdAcntCodeRet varchar(30)
	--SET @RecCrdAcntCodeRet = ''
	
	--SELECT @RecCrdAcntCodeRet= SettingValue
	--FROM pub.tblSettings
	--WHERE SettingKey = 'RecCrdAcntCodeRet'
	
	DECLARE @SaveRowDescHdr bit
	SET @SaveRowDescHdr = 0
	
	SELECT @SaveRowDescHdr= SettingValue
	FROM pub.tblSettings
	WHERE SettingKey = 'trsSaveRecDescHdrInVoucher'
	

SELECT	@RowDescHdr=DescHdr
	FROM trs.tblPayHdr 
	WHERE ProcessID=@intSourceProcessID AND
		  ProcessNo=@intSourceProcessNo AND
		  FiscalYear=@intSourceFiscalYear AND
		  SerialNo=@intSourceSerialNo 


	-----
	Declare	Cursor_PayDtl CURSOR For 
	SELECT	PayTypeID,Amount,RowDesc,ChequeNo,ChequeDate,VolumeFiscalYear,VolumeRowNo,DebitCode,CreditCode,ID,VisitorAcntCode
	FROM trs.tblPayDtl 
	WHERE ProcessID=@intSourceProcessID AND
		  ProcessNo=@intSourceProcessNo AND
		  FiscalYear=@intSourceFiscalYear AND
		  SerialNo=@intSourceSerialNo 
	order by DocRowNo


	Open  Cursor_PayDtl; 

	Fetch NEXT From Cursor_PayDtl Into @PayTypeID,@Amount,@RowDesc,@ChequeNo,@ChequeDate,@VolumeFiscalYear,@VolumeRowNo,@DebitCode,@CreditCode,@BaseID,@VisitorAcntCode

	While (@@Fetch_Status = 0)
		BEGIN


	Select @strAcntName =  [pub].GetCodeName(@DebitCode, @LanguageID)

if (@SaveRowDescHdr=1)
set @RowDesc=@RowDescHdr+'--'+@RowDesc
			---------------------------------------------------
			SET @strRecDesc = ' استرداد چكهاي واگذار شده به اشخاص به صاحب چک (' + @strAcntName + ')' + @strSourceProcessNo + ' شماره ' + LTRIM(RTRIM(STR(@intSourceFiscalYear))) + '/' + LTRIM(RTRIM(STR(@intSourceSerialNo))) +
							  ' به شماره چک ' + LTRIM(RTRIM(STR(@ChequeNo,30))) + ' به سررسید ' + @ChequeDate

			---- جایگزینی کد حسابداری معین و یا بقیه با کد موجود در تنظیمات
			--IF  LEN(@RecDebAcntCodeRet)>0
			--	SET @DebitCode = [pub].[funReplaceCode] (@DebitCode,@RecDebAcntCodeRet)

			---------------------------------------------------
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
					SET @intMaxDocRowNo = @intMaxDocRowNo + 1
					SET @intMaxRowNo = @intMaxRowNo + 1

					INSERT INTO acc.tblVoucherDtl
							(SerialNo,SourceProcessID,SourceProcessNo,SourceFiscalYear,SourceSerialNo,DocDate,IsAutoDoc,SessionNo,VchKind,RowNo,DocRowNo,
								AcntCode,Debit,Credit,RecDesc,RecDesc2,SourceDocType,BaseID,VisitorAcntCode) 
					VALUES	(@intVchNo,@intSourceProcessID,@intSourceProcessNo,@intSourceFiscalYear,@intSourceSerialNo,@strVchDate ,1,@SessionNo ,1,@intMaxRowNo ,@intMaxDocRowNo,
								@DebitCode,@Amount,0,TS.pub.funChangeFarsiStrings(pub.funReverseForCrystal(@strRecDesc)),@RowDesc,0 ,@BaseID,@VisitorAcntCode)	
				END
	
			---- جایگزینی کد حسابداری معین و یا بقیه با کد موجود در تنظیمات
			--IF  LEN(@RecCrdAcntCodeRet)>0
			--	SET @CreditCode = [pub].[funReplaceCode] (@CreditCode,@RecCrdAcntCodeRet)

			---------------------------------------------------
			SET @intMaxDocRowNo = @intMaxDocRowNo + 1
			SET @intMaxRowNo = @intMaxRowNo + 1

			INSERT INTO acc.tblVoucherDtl
					(SerialNo,SourceProcessID,SourceProcessNo,SourceFiscalYear,SourceSerialNo,DocDate,IsAutoDoc,SessionNo,VchKind,RowNo,DocRowNo,
						AcntCode,Debit,Credit,RecDesc,RecDesc2,SourceDocType,BaseID,VisitorAcntCode) 
			VALUES	(@intVchNo,@intSourceProcessID,@intSourceProcessNo,@intSourceFiscalYear,@intSourceSerialNo,@strVchDate ,1,@SessionNo ,1,@intMaxRowNo ,@intMaxDocRowNo,
						@CreditCode,0,@Amount,TS.pub.funChangeFarsiStrings(pub.funReverseForCrystal(@strRecDesc)),@RowDesc,0 ,@BaseID,@VisitorAcntCode)			
			
			---------------------------------------------------	
			Fetch NEXT From Cursor_PayDtl Into @PayTypeID,@Amount,@RowDesc,@ChequeNo,@ChequeDate,@VolumeFiscalYear,@VolumeRowNo,@DebitCode,@CreditCode,@BaseID,@VisitorAcntCode

		END

	Close Cursor_PayDtl;
	Deallocate Cursor_PayDtl;  


END

GO
