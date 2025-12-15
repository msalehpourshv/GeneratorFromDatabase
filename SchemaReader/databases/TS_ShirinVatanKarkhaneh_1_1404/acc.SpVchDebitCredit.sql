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
Create PROCEDURE [acc].[SpVchDebitCredit]
	@intVchNo				Int,
	@intDocStep				Int,
    @strVchDate				Char(10),
	@intSourceProcessID		Int,
	@intSourceProcessNo		Int,
	@intSourceFiscalYear	Int,
	@intSourceSerialNo		Int,
	@intMaxRowNo			Int,
	@intMaxDocRowNo			Int,
	@SessionNo				Int,
	@LanguageID				TinyInt
	WITH ENCRYPTION
AS

BEGIN

	DECLARE @AcntCode			Varchar(20)
	DECLARE @Credit				Bigint
	DECLARE @Debit				Bigint
	DECLARE @DescDtl			NVarChar(1000)
	DECLARE @CurrencyRateTmp	Float
	DECLARE @CurrencyAmountTmp	Float
	DECLARE @CurrencyTypeIDTmp	VarChar(20)
	DECLARE @CurrencyAmount		Float
	DECLARE @CurrencyAmountAtom	Float
	DECLARE @CurrencyRate		Float
	DECLARE @CurrencyTypeID		VarChar(20)
	DECLARE @ProcessTitle		NVarChar(1000)

	-----
	SET @CurrencyRate = 0
	SET @CurrencyAmountAtom = 0
	SET @CurrencyAmount = 0
	SET @CurrencyTypeID = ''
	SET @CurrencyRateTmp = 0
	SET @CurrencyAmountTmp = 0
	SET @CurrencyTypeIDTmp = ''
	SET @ProcessTitle = ''
	
	IF @intSourceProcessNo = 1
		SELECT  @ProcessTitle = ISNULL(SettingValue, '1') FROM pub.tblSettings WHERE SettingKey = 'DebitCreditDeclaration1Title'
	ELSE
		SELECT  @ProcessTitle = ISNULL(SettingValue, '2') FROM pub.tblSettings WHERE SettingKey = 'DebitCreditDeclaration2Title'
	
	IF @ProcessTitle = ''
	BEGIN
		IF @intSourceProcessNo = 1
			SET @ProcessTitle = '1'
		ELSE
			SET @ProcessTitle = '2'
	END
	-------
	--SELECT	@CurrencyRate=CurrencyRate,@CurrencyTypeID =CurrencyTypeID 
	--FROM acc.tblDebitCreditDeclarationHdr
	--WHERE ProcessID=@intSourceProcessID AND
	--	  ProcessNo=@intSourceProcessNo AND
	--	  FiscalYear=@intSourceFiscalYear AND
	--	  SerialNo=@intSourceSerialNo 
	
	--------------------------------------------------------------------------------------------------------
	DECLARE	Cursor_DebitCredit CURSOR For 
	SELECT AcntCode, DescDtl, Debit, Credit, CurrencyTypeID, CurrencyAmount
	FROM acc.tblDebitCreditDeclarationDtl RD
	WHERE RD.ProcessID=@intSourceProcessID AND
		  RD.ProcessNo=@intSourceProcessNo AND
		  RD.FiscalYear=@intSourceFiscalYear AND
		  RD.SerialNo=@intSourceSerialNo 

	Open  Cursor_DebitCredit; 

	Fetch NEXT From Cursor_DebitCredit Into @AcntCode, @DescDtl, @Debit, @Credit, @CurrencyTypeID, @CurrencyAmount

	While (@@Fetch_Status = 0)
		BEGIN
			
			IF @Debit <> 0 OR @Credit <> 0
				BEGIN
				
					SET @intMaxDocRowNo = @intMaxDocRowNo + 1
					SET @intMaxRowNo = @intMaxRowNo + 1
					
					IF [acc].[funIsCurrencyAcntCode] (@AcntCode) = 'True'
					BEGIN
						SET @CurrencyRateTmp	= @CurrencyRate
						SET @CurrencyAmountTmp  = @CurrencyAmount
						SET @CurrencyTypeIDTmp  = @CurrencyTypeID
					END
					ELSE
					BEGIN
						SET @CurrencyRateTmp	= 0
						SET @CurrencyAmountTmp  = 0
						SET @CurrencyTypeIDTmp  = ''
					END
										
					INSERT INTO acc.tblVoucherDtl
							(SerialNo,SourceProcessID,SourceProcessNo,SourceFiscalYear,SourceSerialNo,DocDate,IsAutoDoc,SessionNo,VchKind,RowNo,DocRowNo,
							 AcntCode,Debit,Credit,RecDesc,RecDesc2,SourceDocType,CurrencyAmount,CurrencyTypeID ) 
					VALUES	(@intVchNo,@intSourceProcessID,@intSourceProcessNo,@intSourceFiscalYear,@intSourceSerialNo,@strVchDate ,1,@SessionNo ,1,@intMaxRowNo ,@intMaxDocRowNo,
							 @AcntCode,@Debit,@Credit, 
							 N'شماره برگه اعلامیه بدهکار و بستانکار ' + @ProcessTitle  + ' ' + LTrim(RTrim(Str(@intSourceFiscalYear))) + '/' + LTrim(RTrim(Str(@intSourceSerialNo))) + ' - ' + @DescDtl, 
							 '', 0, @CurrencyAmountTmp, @CurrencyTypeIDTmp)			

				END

			Fetch NEXT From Cursor_DebitCredit Into @AcntCode, @DescDtl, @Debit, @Credit, @CurrencyTypeID, @CurrencyAmount
		
		END

	Close Cursor_DebitCredit;
	Deallocate Cursor_DebitCredit; 

END
GO
