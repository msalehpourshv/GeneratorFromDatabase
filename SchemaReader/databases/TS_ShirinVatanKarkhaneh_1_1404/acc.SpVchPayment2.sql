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
Create PROCEDURE [acc].[SpVchPayment2]
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
	@LanguageID				TinyInt,
	@VchKind				TinyInt = 1
	WITH ENCRYPTION
AS

BEGIN
	-----
	Declare @strMsgText	 NVarChar(2044)
	Declare @PayTypeID	Tinyint
	Declare @Amount		float
	Declare @RowDesc	Nvarchar(1000)	
	Declare @DebitCode	Varchar(20)
	Declare @CreditCode	Varchar(20)
	Declare @AccountNo	Varchar(20)
	Declare @ChequeNo	Bigint
	Declare @ChequeDate	Char(10)
	Declare @strRecDesc NVarChar(1000)
	DECLARE @DocRowNo   Int
	DECLARE @AtomAcntCode Varchar(20)
	Declare @CurrencyTypeID	VarChar(20)
	Declare @CurrencyTypeIDDtl	VarChar(20)
	DECLARE @AtomAmount FLOAT 
	Declare @AtomCurrencyAmount	Float
	Declare @CurrencyAmount	Float
	Declare @CurrencyAmountAtom	Float
	Declare @CurrencyRate	Float
	Declare @CurrencyRateDtl	Float
	DECLARE @AtomDesc   Nvarchar(2000)	
	Declare @AcntName NVarChar(1000)
	DECLARE @strSourceProcessNo NVARCHAR(100)
	DECLARE @BaseID Int
	DECLARE @VisitorAcntCode Varchar(20)		
	Declare @CurrencyRateTmp			Float
	Declare @CurrencyAmountTmp			Float
	Declare @CurrencyTypeIDTmp			VarChar(20)
	
	IF  @intSourceProcessNo< 2
		SET @strSourceProcessNo = ''
	ELSE
		SET @strSourceProcessNo = LTRIM(RTRIM(STR(@intSourceProcessNo)))

	-----
	SET @CurrencyRate = 0
	SET @CurrencyRateDtl = 0
	SET @CurrencyAmountAtom = 0
	SET @CurrencyAmount = 0
	SET @CurrencyTypeID = ''
	SET @CurrencyTypeIDDtl = ''
	
	SET @CurrencyRateTmp = 0
	SET @CurrencyAmountTmp = 0
	SET @CurrencyTypeIDTmp = ''
	DECLARE @trs_CurrencyTypeInRow BIT;

	SELECT @trs_CurrencyTypeInRow = SettingValue
	FROM pub.tblSettings 
	WHERE SettingKey = 'trs_CurrencyTypeInRow'
	-----
	SELECT	@VisitorAcntCode=isnull(VisitorAcntCode,''),@CurrencyRate=CurrencyRate,@CurrencyTypeID=CurrencyTypeID
	FROM trs.tblPayHdr
	WHERE ProcessID=@intSourceProcessID AND
		  ProcessNo=@intSourceProcessNo AND
		  FiscalYear=@intSourceFiscalYear AND
		  SerialNo=@intSourceSerialNo 
		  
	--------------------------------------------------------------------------------------------------------
	Declare	Cursor_PayDtl CURSOR For 
	SELECT	RD.CurrencyRate,RD.CurrencyTypeID,PayTypeID,Amount,RowDesc,DebitCode,CreditCode,ChequeNo,ChequeDate,AccountNo,DocRowNo,CurrencyAmount,ID
	FROM trs.tblPayDtl RD
	WHERE RD.ProcessID=@intSourceProcessID AND
		  RD.ProcessNo=@intSourceProcessNo AND
		  RD.FiscalYear=@intSourceFiscalYear AND
		  RD.SerialNo=@intSourceSerialNo 
	order by RD.DocRowNo

	Open  Cursor_PayDtl; 

	Fetch NEXT From Cursor_PayDtl Into @CurrencyRateDtl,@CurrencyTypeIDDtl,@PayTypeID,@Amount,@RowDesc,@DebitCode,@CreditCode,@ChequeNo,@ChequeDate,@AccountNo,@DocRowNo,@CurrencyAmount,@BaseID

	While (@@Fetch_Status = 0)
		BEGIN
			
			SET @strRecDesc = ' برگ پرداخت ' + @strSourceProcessNo + ' شماره' + LTRIM(RTRIM(STR(@intSourceFiscalYear))) + '/' + LTRIM(RTRIM(STR(@intSourceSerialNo)))

			IF @PayTypeID=1
				SET @strRecDesc = @strRecDesc + ' نقد '
			ELSE IF @PayTypeID=2
				SET @strRecDesc = @strRecDesc + ' حواله '
			ELSE IF @PayTypeID=3
				SET @strRecDesc = @strRecDesc + ' فیش شماره ' + LTRIM(RTRIM(STR(@ChequeNo,30))) + ' مورخه' + @ChequeDate
			ELSE IF @PayTypeID=4
				SET @strRecDesc = @strRecDesc + ' حواله شماره '  + LTRIM(RTRIM(STR(@ChequeNo,30))) + ' مورخه' + @ChequeDate
			ELSE IF @PayTypeID=5
                SET @strRecDesc = @strRecDesc + ' برداشت از حساب با مدرک شماره  ' + @AccountNo + ' مورخه' + @ChequeDate

			---------------
			SET @AcntName = @strRecDesc
			SET @AcntName = @AcntName + ' از '  + pub.GetCodeName(@CreditCode,@LanguageID)

			IF (SELECT COUNT(*) 
				FROM trs.tblPayAtm 
				WHERE ProcessID  = @intSourceProcessID AND 
					  ProcessNo  = @intSourceProcessNo AND 
					  FiscalYear = @intSourceFiscalYear AND 
					  SerialNo   = @intSourceSerialNo AND 
					  DocRowNo   = @DocRowNo) >0
				BEGIN
					Declare	Cursor_PayAtom CURSOR For 
					SELECT	AtomAcntCode, AtomAmount, AtomCurrencyAmount,AtomDesc
					FROM trs.tblPayAtm 
					WHERE ProcessID	= @intSourceProcessID AND
						  ProcessNo	= @intSourceProcessNo AND
						  FiscalYear= @intSourceFiscalYear AND
						  SerialNo	= @intSourceSerialNo AND
						  DocRowNo   = @DocRowNo	

					Open  Cursor_PayAtom; 

					Fetch NEXT From Cursor_PayAtom Into @AtomAcntCode,@AtomAmount,@AtomCurrencyAmount,@AtomDesc

					While (@@Fetch_Status = 0)
						BEGIN

							SET @intMaxDocRowNo = @intMaxDocRowNo + 1
							SET @intMaxRowNo = @intMaxRowNo + 1
							
							
							IF [acc].[funIsCurrencyAcntCode] (@AtomAcntCode) = 'True'
							Begin
								Set @CurrencyRateTmp	= @CurrencyRate
								Set @CurrencyAmountTmp  = @AtomCurrencyAmount
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
								IF @CurrencyRate <> 0
								SET @CurrencyAmountAtom = ROUND(@AtomAmount,0) / @CurrencyRateTmp
							
							INSERT INTO acc.tblVoucherDtl
									(SerialNo,SourceProcessID,SourceProcessNo,SourceFiscalYear,SourceSerialNo,SourceDocRowNo,DocDate,IsAutoDoc,SessionNo,VchKind,RowNo,DocRowNo,
										AcntCode,Debit,Credit,RecDesc,RecDesc2,SourceDocType,CurrencyAmount,CurrencyTypeID,BaseID,VisitorAcntCode) 
							VALUES	(@intVchNo,@intSourceProcessID,@intSourceProcessNo,@intSourceFiscalYear,@intSourceSerialNo,@DocRowNo,@strVchDate ,1,@SessionNo ,@VchKind,@intMaxRowNo,@intMaxDocRowNo,
										@AtomAcntCode,@AtomAmount,0,TS.pub.funChangeFarsiStrings(pub.funReverseForCrystal(@AcntName)),@AtomDesc,0 ,@CurrencyAmountTmp,@CurrencyTypeIDTmp,@BaseID,@VisitorAcntCode)			

							Fetch NEXT From Cursor_PayAtom Into @AtomAcntCode,@AtomAmount,@AtomCurrencyAmount,@AtomDesc
						END
					Close Cursor_PayAtom;
					Deallocate Cursor_PayAtom; 
				END

			ELSE

				BEGIN
					SET @intMaxDocRowNo = @intMaxDocRowNo + 1
					SET @intMaxRowNo = @intMaxRowNo + 1

					IF [acc].[funIsCurrencyAcntCode] (@DebitCode) = 'True'
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
								AcntCode,Debit,Credit,RecDesc,RecDesc2,SourceDocType,CurrencyAmount,CurrencyTypeID,BaseID,VisitorAcntCode) 
					VALUES	(@intVchNo,@intSourceProcessID,@intSourceProcessNo,@intSourceFiscalYear,@intSourceSerialNo,@DocRowNo,@strVchDate ,1,@SessionNo ,@VchKind,@intMaxRowNo ,@intMaxDocRowNo,
								@DebitCode,@Amount,0,TS.pub.funChangeFarsiStrings(pub.funReverseForCrystal(@AcntName)),@RowDesc,0,@CurrencyAmountTmp,@CurrencyTypeIDTmp,@BaseID,@VisitorAcntCode)			
				END
				
			-------------
			SET @intMaxDocRowNo = @intMaxDocRowNo + 1
			SET @intMaxRowNo = @intMaxRowNo + 1

			SET @AcntName = @strRecDesc
			SET @AcntName = @AcntName + ' به '  + pub.GetCodeName(@DebitCode,@LanguageID)

			IF [acc].[funIsCurrencyAcntCode] (@CreditCode) = 'True'
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
						AcntCode,Debit,Credit,RecDesc,RecDesc2,SourceDocType,CurrencyAmount,CurrencyTypeID,BaseID,VisitorAcntCode) 
			VALUES	(@intVchNo,@intSourceProcessID,@intSourceProcessNo,@intSourceFiscalYear,@intSourceSerialNo,@DocRowNo,@strVchDate ,1,@SessionNo ,@VchKind,@intMaxRowNo,@intMaxDocRowNo,
						@CreditCode,0,@Amount,TS.pub.funChangeFarsiStrings(pub.funReverseForCrystal(@AcntName)),@RowDesc,0,@CurrencyAmountTmp,@CurrencyTypeIDTmp,@BaseID,@VisitorAcntCode)			

			Fetch NEXT From Cursor_PayDtl Into @CurrencyRateDtl,@CurrencyTypeIDDtl,@PayTypeID,@Amount,@RowDesc,@DebitCode,@CreditCode,@ChequeNo,@ChequeDate,@AccountNo,@DocRowNo,@CurrencyAmount,@BaseID
		
		END

	Close Cursor_PayDtl;
	Deallocate Cursor_PayDtl; 

END
GO
