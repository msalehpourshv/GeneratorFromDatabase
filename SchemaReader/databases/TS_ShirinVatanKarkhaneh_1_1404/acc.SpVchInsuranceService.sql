USE TS_ShirinVatanKarkhaneh_1_1404
GO
SET ANSI_NULLS, QUOTED_IDENTIFIER ON
GO
-- =========== TS-QC:OK ========================
-- Author        : Hadi Sadeghi
-- Create date   : 91/02/17
-- Viewed By	 : 
-- Last Modified : 
-- Description   : 
-- =============================================
Create PROCEDURE [acc].[SpVchInsuranceService]
	@intVchNo				Int,
	@intDocStep				TinyInt,
    @strVchDate				Char(10),
	@intSourceProcessID		smallint,
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
	---

	Declare @strMsgText	NVarChar(2044),
		    @DescHdr NVARCHAR(2000),
		    @strRecDesc NVARCHAR(1000),
		    @strRecDesc2 NVARCHAR(1000),
		    @DocDate char(4),
		    @AcntCodeVisitor  VARCHAR(20), 
		    @AcntCode  VARCHAR(20), @ServiceID  VARCHAR(20), @Price float, @Fine float , @PriceAfterTax float, @Tax float, @Toll float, @Health float,
		    @WageMain float, @ExportMain float, @WageVisitor float, @ExportVisitor float
	Declare @strFiscalSerial		NVarChar(70)
	
  declare  @InsuranceHealthPercent float=0,
    @InsuranceTollPercent float=0,
    @InsuranceTaxPercent float=0,
    @InsuranceMainAcntCodeDebit  VARCHAR(20),
    @InsuranceMainAcntCodeCredit  VARCHAR(20),
    @InsuranceBankCode  VARCHAR(20),
    
    @InsuranceTaxAll   VARCHAR(20),
    @InsuranceVisitor   VARCHAR(20),
    @InsuranceTax   VARCHAR(20),
    @InsuranceToll   VARCHAR(20),
    @InsuranceHealth   VARCHAR(20),
    @InsuranceIncome   VARCHAR(20)   ,
    @InsuranceCashCode  VARCHAR(20)   ,
    @InsuranceTaxCenterPercent   VARCHAR(20)   ,
    @InsuranceTaxCenter   VARCHAR(20)   ,
  @InsurancePriceLittle  VARCHAR(20)   ,
  	@Total int=0,
    @Payment int=0,
    @Instalment int=0,
	@VisitorPay int=0
	 
	SELECT @InsuranceTaxCenterPercent=SettingValue
	FROM pub.tblSettings
	WHERE SettingKey = 'InsuranceTaxCenterPercent'
	 
	SELECT @InsuranceTaxCenter=SettingValue
	FROM pub.tblSettings
	WHERE SettingKey = 'InsuranceTaxCenter'
	
	SELECT @InsuranceMainAcntCodeDebit=SettingValue
	FROM pub.tblSettings
	WHERE SettingKey = 'InsuranceMainAcntCodeDebit'

	SELECT @InsuranceTaxAll=SettingValue
	FROM pub.tblSettings
	WHERE SettingKey = 'InsuranceTaxAll'

	SELECT @InsuranceVisitor=SettingValue
	FROM pub.tblSettings
	WHERE SettingKey = 'InsuranceVisitor'

	SELECT @InsuranceTax=SettingValue
	FROM pub.tblSettings
	WHERE SettingKey = 'InsuranceTax'	

	SELECT @InsuranceToll=SettingValue
	FROM pub.tblSettings
	WHERE SettingKey = 'InsuranceToll'

	SELECT @InsuranceHealth=SettingValue
	FROM pub.tblSettings
	WHERE SettingKey = 'InsuranceHealth'
	
	SELECT @InsuranceIncome=SettingValue
	FROM pub.tblSettings
	WHERE SettingKey = 'InsuranceIncome'

	SELECT @InsuranceCashCode=SettingValue
	FROM pub.tblSettings
	WHERE SettingKey = 'InsuranceCashCode'		

	SELECT @InsuranceMainAcntCodeCredit=SettingValue
	FROM pub.tblSettings
	WHERE SettingKey = 'InsuranceMainAcntCodeCredit'
	
	SELECT @InsurancePriceLittle=SettingValue
	FROM pub.tblSettings
	WHERE SettingKey = 'InsurancePriceLittle'
	
	
-----------------------------------------------------------------------------------------------

	SET @strFiscalSerial = LTRIM(RTRIM(STR(@intSourceFiscalYear))) + '/' + LTRIM(RTRIM(STR(@intSourceSerialNo))) 

	SELECT	 @AcntCode = AcntCode, @DocDate = DocDate, @DescHdr= DescHdr, @AcntCodeVisitor=AcntCodeVisitor ,
			 @Total =Total, @Payment =Payment, @Instalment=Instalment,@InsuranceBankCode = BankCode
	FROM trs.tblInsuranceServiceHdr I
	WHERE ProcessID=@intSourceProcessID AND
		  ProcessNo=@intSourceProcessNo AND
		  FiscalYear=@intSourceFiscalYear AND
		  SerialNo=@intSourceSerialNo 
			  

	SELECT @InsuranceVisitor = @InsuranceVisitor + SUBSTRING(@AcntCodeVisitor,LEN(@InsuranceVisitor)+1,LEN(@AcntCodeVisitor) - LEN(@InsuranceVisitor))
	SELECT @InsuranceIncome = @InsuranceIncome + SUBSTRING(@AcntCode,LEN(@InsuranceIncome)+1,LEN(@AcntCode) - LEN(@InsuranceIncome))
	
	--SELECT @InsuranceTax = @InsuranceTax + SUBSTRING(@AcntCode,LEN(@InsuranceTax)+1,LEN(@AcntCode) - LEN(@InsuranceTax))
	--SELECT @InsuranceToll = @InsuranceToll + SUBSTRING(@AcntCode,LEN(@InsuranceToll)+1,LEN(@AcntCode) - LEN(@InsuranceToll))
	--SELECT @InsuranceHealth = @InsuranceHealth + SUBSTRING(@AcntCode,LEN(@InsuranceHealth)+1,LEN(@AcntCode) - LEN(@InsuranceHealth))
		
	
	SELECT @InsuranceBankCode = AcntCode1 from trs.tblOurBanks 
	where BankCode = @InsuranceBankCode
			  
	SET @strRecDesc = 'محاسبه صدور بیمه به شماره برگه  ' + ISNULL(@strFiscalSerial,'') 
	Declare	curBuy CURSOR For 
		SELECT	  ServiceID, Price, Fine, PriceAfterTax, Tax, Toll, Health, WageMain, ExportMain, WageVisitor, ExportVisitor
		FROM trs.tblInsuranceServiceDtl I
		WHERE ProcessID=@intSourceProcessID AND
			  ProcessNo=@intSourceProcessNo AND
			  FiscalYear=@intSourceFiscalYear AND
			  SerialNo=@intSourceSerialNo 
	
		--- فاکتور خرید سطر به سطر به حساب مشتری میرود

		Open curBuy;
			
		Fetch NEXT From curBuy Into  @ServiceID, @Price, @Fine, @PriceAfterTax, @Tax, @Toll, @Health, @WageMain, @ExportMain, @WageVisitor, @ExportVisitor
	
		While (@@Fetch_Status = 0)
			BEGIN
				IF @Price <> 0
					BEGIN
								
-----------------------------------------------Debit------------------------------------------------							SET @intMaxDocRowNo = @intMaxDocRowNo + 1
						SET @intMaxDocRowNo = @intMaxDocRowNo + 1
						SET @intMaxRowNo = @intMaxRowNo + 1
						
						SET @strRecDesc2 = @strRecDesc + ' مبلغ قبل از مالیات'
						
						INSERT INTO acc.tblVoucherDtl
								(SerialNo,SourceProcessID,SourceProcessNo,SourceFiscalYear,SourceSerialNo,DocDate,IsAutoDoc,SessionNo,VchKind,RowNo,DocRowNo,
								 AcntCode,Debit,Credit,RecDesc,RecDesc2,SourceDocType,CurrencyAmount,CurrencyTypeID) 
						VALUES	(@intVchNo,@intSourceProcessID,@intSourceProcessNo,@intSourceFiscalYear,@intSourceSerialNo,@strVchDate ,1,@SessionNo ,1,@intMaxRowNo ,@intMaxDocRowNo,
								 @AcntCode,@PriceAfterTax,0,TS.pub.funChangeFarsiStrings(pub.funReverseForCrystal(@strRecDesc2)),TS.pub.funChangeFarsiStrings(@DescHdr),0,0,'')	
								 
						SET @intMaxDocRowNo = @intMaxDocRowNo + 1
						SET @intMaxRowNo = @intMaxRowNo + 1
						
						SET @strRecDesc2 = @strRecDesc + ' مبلغ مالیات بر ارزش افزوده'
						
						INSERT INTO acc.tblVoucherDtl
								(SerialNo,SourceProcessID,SourceProcessNo,SourceFiscalYear,SourceSerialNo,DocDate,IsAutoDoc,SessionNo,VchKind,RowNo,DocRowNo,
								 AcntCode,Debit,Credit,RecDesc,RecDesc2,SourceDocType,CurrencyAmount,CurrencyTypeID) 
						VALUES	(@intVchNo,@intSourceProcessID,@intSourceProcessNo,@intSourceFiscalYear,@intSourceSerialNo,@strVchDate ,1,@SessionNo ,1,@intMaxRowNo ,@intMaxDocRowNo,
								 @AcntCode,@Tax,0,TS.pub.funChangeFarsiStrings(pub.funReverseForCrystal(@strRecDesc2)),TS.pub.funChangeFarsiStrings(@DescHdr),0,0,'')	
								 
						SET @intMaxDocRowNo = @intMaxDocRowNo + 1
						SET @intMaxRowNo = @intMaxRowNo + 1
						
						SET @strRecDesc2 = @strRecDesc + ' مبلغ عوارض ارزش افزوده'
						
						INSERT INTO acc.tblVoucherDtl
								(SerialNo,SourceProcessID,SourceProcessNo,SourceFiscalYear,SourceSerialNo,DocDate,IsAutoDoc,SessionNo,VchKind,RowNo,DocRowNo,
								 AcntCode,Debit,Credit,RecDesc,RecDesc2,SourceDocType,CurrencyAmount,CurrencyTypeID) 
						VALUES	(@intVchNo,@intSourceProcessID,@intSourceProcessNo,@intSourceFiscalYear,@intSourceSerialNo,@strVchDate ,1,@SessionNo ,1,@intMaxRowNo ,@intMaxDocRowNo,
								 @AcntCode,@Toll,0,TS.pub.funChangeFarsiStrings(pub.funReverseForCrystal(@strRecDesc2)),TS.pub.funChangeFarsiStrings(@DescHdr),0,0,'')	
						
								 
						SET @intMaxDocRowNo = @intMaxDocRowNo + 1
						SET @intMaxRowNo = @intMaxRowNo + 1
						
						SET @strRecDesc2 = @strRecDesc + ' مبلغ سلامت'
						
						INSERT INTO acc.tblVoucherDtl
								(SerialNo,SourceProcessID,SourceProcessNo,SourceFiscalYear,SourceSerialNo,DocDate,IsAutoDoc,SessionNo,VchKind,RowNo,DocRowNo,
								 AcntCode,Debit,Credit,RecDesc,RecDesc2,SourceDocType,CurrencyAmount,CurrencyTypeID) 
						VALUES	(@intVchNo,@intSourceProcessID,@intSourceProcessNo,@intSourceFiscalYear,@intSourceSerialNo,@strVchDate ,1,@SessionNo ,1,@intMaxRowNo ,@intMaxDocRowNo,
								 @AcntCode,@Health,0,TS.pub.funChangeFarsiStrings(pub.funReverseForCrystal(@strRecDesc2)),TS.pub.funChangeFarsiStrings(@DescHdr),0,0,'')	

						SET @intMaxDocRowNo = @intMaxDocRowNo + 1
						SET @intMaxRowNo = @intMaxRowNo + 1
						
						SET @strRecDesc2 = @strRecDesc + ' مبلغ جریمه'
						
						INSERT INTO acc.tblVoucherDtl
								(SerialNo,SourceProcessID,SourceProcessNo,SourceFiscalYear,SourceSerialNo,DocDate,IsAutoDoc,SessionNo,VchKind,RowNo,DocRowNo,
								 AcntCode,Debit,Credit,RecDesc,RecDesc2,SourceDocType,CurrencyAmount,CurrencyTypeID) 
						VALUES	(@intVchNo,@intSourceProcessID,@intSourceProcessNo,@intSourceFiscalYear,@intSourceSerialNo,@strVchDate ,1,@SessionNo ,1,@intMaxRowNo ,@intMaxDocRowNo,
								 @AcntCode,@Fine,0,TS.pub.funChangeFarsiStrings(pub.funReverseForCrystal(@strRecDesc2)),TS.pub.funChangeFarsiStrings(@DescHdr),0,0,'')	


						SET @intMaxDocRowNo = @intMaxDocRowNo + 1
						SET @intMaxRowNo = @intMaxRowNo + 1
						
						SET @strRecDesc2 = @strRecDesc + ' کار مزد بیمه مرکزی'
						
						INSERT INTO acc.tblVoucherDtl
								(SerialNo,SourceProcessID,SourceProcessNo,SourceFiscalYear,SourceSerialNo,DocDate,IsAutoDoc,SessionNo,VchKind,RowNo,DocRowNo,
								 AcntCode,Debit,Credit,RecDesc,RecDesc2,SourceDocType,CurrencyAmount,CurrencyTypeID) 
						VALUES	(@intVchNo,@intSourceProcessID,@intSourceProcessNo,@intSourceFiscalYear,@intSourceSerialNo,@strVchDate ,1,@SessionNo ,1,@intMaxRowNo ,@intMaxDocRowNo,
								 @InsuranceMainAcntCodeDebit,(@PriceAfterTax*(@WageMain+@ExportMain)/100),0,TS.pub.funChangeFarsiStrings(pub.funReverseForCrystal(@strRecDesc2)),TS.pub.funChangeFarsiStrings(@DescHdr),0,0,'')	
					set @VisitorPay=(@PriceAfterTax*@WageMain*@WageVisitor)/10000 +(@PriceAfterTax*@ExportMain*@ExportVisitor)/10000

						SET @intMaxDocRowNo = @intMaxDocRowNo + 1
						SET @intMaxRowNo = @intMaxRowNo + 1
						
						SET @strRecDesc2 = @strRecDesc + ' کار مزد مالیات بیمه مرکزی'
						
						INSERT INTO acc.tblVoucherDtl
								(SerialNo,SourceProcessID,SourceProcessNo,SourceFiscalYear,SourceSerialNo,DocDate,IsAutoDoc,SessionNo,VchKind,RowNo,DocRowNo,
								 AcntCode,Debit,Credit,RecDesc,RecDesc2,SourceDocType,CurrencyAmount,CurrencyTypeID) 
						VALUES	(@intVchNo,@intSourceProcessID,@intSourceProcessNo,@intSourceFiscalYear,@intSourceSerialNo,@strVchDate ,1,@SessionNo ,1,@intMaxRowNo ,@intMaxDocRowNo,
								 @InsuranceMainAcntCodeDebit,(@PriceAfterTax*(@WageMain+@ExportMain)/10000)*@InsuranceTaxCenterPercent,0,TS.pub.funChangeFarsiStrings(pub.funReverseForCrystal(@strRecDesc2)),TS.pub.funChangeFarsiStrings(@DescHdr),0,0,'')	


						SET @intMaxDocRowNo = @intMaxDocRowNo + 1
						SET @intMaxRowNo = @intMaxRowNo + 1
						
						SET @strRecDesc2 = @strRecDesc + ' پیش پرداخت مالیات بر ارزش افزوده '
						
						INSERT INTO acc.tblVoucherDtl
								(SerialNo,SourceProcessID,SourceProcessNo,SourceFiscalYear,SourceSerialNo,DocDate,IsAutoDoc,SessionNo,VchKind,RowNo,DocRowNo,
								 AcntCode,Debit,Credit,RecDesc,RecDesc2,SourceDocType,CurrencyAmount,CurrencyTypeID) 
						VALUES	(@intVchNo,@intSourceProcessID,@intSourceProcessNo,@intSourceFiscalYear,@intSourceSerialNo,@strVchDate ,1,@SessionNo ,1,@intMaxRowNo ,@intMaxDocRowNo,
								 @InsuranceTaxAll,@Tax+@Toll+@Health,0,TS.pub.funChangeFarsiStrings(pub.funReverseForCrystal(@strRecDesc2)),TS.pub.funChangeFarsiStrings(@DescHdr),0,0,'')	

						IF @AcntCodeVisitor <>''
						BEGIN
							SET @intMaxDocRowNo = @intMaxDocRowNo + 1
							SET @intMaxRowNo = @intMaxRowNo + 1
							
							SET @strRecDesc2 = @strRecDesc + ' هزینه پورسانت'
							
							INSERT INTO acc.tblVoucherDtl
									(SerialNo,SourceProcessID,SourceProcessNo,SourceFiscalYear,SourceSerialNo,DocDate,IsAutoDoc,SessionNo,VchKind,RowNo,DocRowNo,
									 AcntCode,Debit,Credit,RecDesc,RecDesc2,SourceDocType,CurrencyAmount,CurrencyTypeID) 
							VALUES	(@intVchNo,@intSourceProcessID,@intSourceProcessNo,@intSourceFiscalYear,@intSourceSerialNo,@strVchDate ,1,@SessionNo ,1,@intMaxRowNo ,@intMaxDocRowNo,
									 @InsuranceVisitor,@VisitorPay,0,TS.pub.funChangeFarsiStrings(pub.funReverseForCrystal(@strRecDesc2)),TS.pub.funChangeFarsiStrings(@DescHdr),0,0,'')	

						END	     
---------------------------------------------------Credit------------------------------------------------	

						SET @intMaxDocRowNo = @intMaxDocRowNo + 1
						SET @intMaxRowNo = @intMaxRowNo + 1
						
						SET @strRecDesc2 = @strRecDesc + '  مبلغ مالیات بر ارزش افزوده'
						
						INSERT INTO acc.tblVoucherDtl
								(SerialNo,SourceProcessID,SourceProcessNo,SourceFiscalYear,SourceSerialNo,DocDate,IsAutoDoc,SessionNo,VchKind,RowNo,DocRowNo,
								 AcntCode,Debit,Credit,RecDesc,RecDesc2,SourceDocType,CurrencyAmount,CurrencyTypeID) 
						VALUES	(@intVchNo,@intSourceProcessID,@intSourceProcessNo,@intSourceFiscalYear,@intSourceSerialNo,@strVchDate ,1,@SessionNo ,1,@intMaxRowNo ,@intMaxDocRowNo,
								 @InsuranceTax,0,@Tax,TS.pub.funChangeFarsiStrings(pub.funReverseForCrystal(@strRecDesc2)),TS.pub.funChangeFarsiStrings(@DescHdr),0,0,'')	


						SET @intMaxDocRowNo = @intMaxDocRowNo + 1
						SET @intMaxRowNo = @intMaxRowNo + 1
						
						SET @strRecDesc2 = @strRecDesc + ' مبلغ عوارض ارزش افزوده'
						
						INSERT INTO acc.tblVoucherDtl
								(SerialNo,SourceProcessID,SourceProcessNo,SourceFiscalYear,SourceSerialNo,DocDate,IsAutoDoc,SessionNo,VchKind,RowNo,DocRowNo,
								 AcntCode,Debit,Credit,RecDesc,RecDesc2,SourceDocType,CurrencyAmount,CurrencyTypeID) 
						VALUES	(@intVchNo,@intSourceProcessID,@intSourceProcessNo,@intSourceFiscalYear,@intSourceSerialNo,@strVchDate ,1,@SessionNo ,1,@intMaxRowNo ,@intMaxDocRowNo,
								 @InsuranceToll,0,@Toll,TS.pub.funChangeFarsiStrings(pub.funReverseForCrystal(@strRecDesc2)),TS.pub.funChangeFarsiStrings(@DescHdr),0,0,'')	


						SET @intMaxDocRowNo = @intMaxDocRowNo + 1
						SET @intMaxRowNo = @intMaxRowNo + 1
						
						SET @strRecDesc2 = @strRecDesc + ' مبلغ سلامت'
						
						INSERT INTO acc.tblVoucherDtl
								(SerialNo,SourceProcessID,SourceProcessNo,SourceFiscalYear,SourceSerialNo,DocDate,IsAutoDoc,SessionNo,VchKind,RowNo,DocRowNo,
								 AcntCode,Debit,Credit,RecDesc,RecDesc2,SourceDocType,CurrencyAmount,CurrencyTypeID) 
						VALUES	(@intVchNo,@intSourceProcessID,@intSourceProcessNo,@intSourceFiscalYear,@intSourceSerialNo,@strVchDate ,1,@SessionNo ,1,@intMaxRowNo ,@intMaxDocRowNo,
								 @InsuranceHealth,0,@Health,TS.pub.funChangeFarsiStrings(pub.funReverseForCrystal(@strRecDesc2)),TS.pub.funChangeFarsiStrings(@DescHdr),0,0,'')	

					SET @intMaxDocRowNo = @intMaxDocRowNo + 1
						SET @intMaxRowNo = @intMaxRowNo + 1
						
						SET @strRecDesc2 = @strRecDesc + 'حسابهای پرداختنی بازاریاب'
						
						INSERT INTO acc.tblVoucherDtl
								(SerialNo,SourceProcessID,SourceProcessNo,SourceFiscalYear,SourceSerialNo,DocDate,IsAutoDoc,SessionNo,VchKind,RowNo,DocRowNo,
								 AcntCode,Debit,Credit,RecDesc,RecDesc2,SourceDocType,CurrencyAmount,CurrencyTypeID) 
						VALUES	(@intVchNo,@intSourceProcessID,@intSourceProcessNo,@intSourceFiscalYear,@intSourceSerialNo,@strVchDate ,1,@SessionNo ,1,@intMaxRowNo ,@intMaxDocRowNo,
								 @AcntCodeVisitor,0,@VisitorPay,TS.pub.funChangeFarsiStrings(pub.funReverseForCrystal(@strRecDesc2)),TS.pub.funChangeFarsiStrings(@DescHdr),0,0,'')				

						SET @intMaxDocRowNo = @intMaxDocRowNo + 1
						SET @intMaxRowNo = @intMaxRowNo + 1
						
						SET @strRecDesc2 = @strRecDesc + 'درآمد'
						
						INSERT INTO acc.tblVoucherDtl
								(SerialNo,SourceProcessID,SourceProcessNo,SourceFiscalYear,SourceSerialNo,DocDate,IsAutoDoc,SessionNo,VchKind,RowNo,DocRowNo,
								 AcntCode,Debit,Credit,RecDesc,RecDesc2,SourceDocType,CurrencyAmount,CurrencyTypeID) 
						VALUES	(@intVchNo,@intSourceProcessID,@intSourceProcessNo,@intSourceFiscalYear,@intSourceSerialNo,@strVchDate ,1,@SessionNo ,1,@intMaxRowNo ,@intMaxDocRowNo,
								 @InsuranceIncome,0,(@PriceAfterTax*(@WageMain+@ExportMain)/100),TS.pub.funChangeFarsiStrings(pub.funReverseForCrystal(@strRecDesc2)),TS.pub.funChangeFarsiStrings(@DescHdr),0,0,'')	

				 	
						SET @intMaxDocRowNo = @intMaxDocRowNo + 1
						SET @intMaxRowNo = @intMaxRowNo + 1
						
						SET @strRecDesc2 = @strRecDesc + ' کار مزد مالیات بیمه مرکزی'
						
						INSERT INTO acc.tblVoucherDtl
								(SerialNo,SourceProcessID,SourceProcessNo,SourceFiscalYear,SourceSerialNo,DocDate,IsAutoDoc,SessionNo,VchKind,RowNo,DocRowNo,
								 AcntCode,Debit,Credit,RecDesc,RecDesc2,SourceDocType,CurrencyAmount,CurrencyTypeID) 
						VALUES	(@intVchNo,@intSourceProcessID,@intSourceProcessNo,@intSourceFiscalYear,@intSourceSerialNo,@strVchDate ,1,@SessionNo ,1,@intMaxRowNo ,@intMaxDocRowNo,
								@InsuranceTaxCenter ,0,(@PriceAfterTax*(@WageMain+@ExportMain)/10000)*@InsuranceTaxCenterPercent,TS.pub.funChangeFarsiStrings(pub.funReverseForCrystal(@strRecDesc2)),TS.pub.funChangeFarsiStrings(@DescHdr),0,0,'')	

					END
			
					Fetch NEXT From curBuy Into  @ServiceID, @Price, @Fine, @PriceAfterTax, @Tax, @Toll, @Health, @WageMain, @ExportMain, @WageVisitor, @ExportVisitor
	
				END
	
		Close curBuy;
		Deallocate curBuy; 	
		
		SET @intMaxDocRowNo = @intMaxDocRowNo + 1
		SET @intMaxRowNo = @intMaxRowNo + 1
		
		SET @strRecDesc2 = @strRecDesc + 'بانک'
		
		INSERT INTO acc.tblVoucherDtl
				(SerialNo,SourceProcessID,SourceProcessNo,SourceFiscalYear,SourceSerialNo,DocDate,IsAutoDoc,SessionNo,VchKind,RowNo,DocRowNo,
				 AcntCode,Debit,Credit,RecDesc,RecDesc2,SourceDocType,CurrencyAmount,CurrencyTypeID) 
		VALUES	(@intVchNo,@intSourceProcessID,@intSourceProcessNo,@intSourceFiscalYear,@intSourceSerialNo,@strVchDate ,1,@SessionNo ,1,@intMaxRowNo ,@intMaxDocRowNo,
				 @InsuranceBankCode,0,@Total,TS.pub.funChangeFarsiStrings(pub.funReverseForCrystal(@strRecDesc2)),TS.pub.funChangeFarsiStrings(@DescHdr),0,0,'')	


		SET @intMaxDocRowNo = @intMaxDocRowNo + 1
		SET @intMaxRowNo = @intMaxRowNo + 1
		
		SET @strRecDesc2 = @strRecDesc + 'صندوق'
		
		INSERT INTO acc.tblVoucherDtl
				(SerialNo,SourceProcessID,SourceProcessNo,SourceFiscalYear,SourceSerialNo,DocDate,IsAutoDoc,SessionNo,VchKind,RowNo,DocRowNo,
				 AcntCode,Debit,Credit,RecDesc,RecDesc2,SourceDocType,CurrencyAmount,CurrencyTypeID) 
		VALUES	(@intVchNo,@intSourceProcessID,@intSourceProcessNo,@intSourceFiscalYear,@intSourceSerialNo,@strVchDate ,1,@SessionNo ,1,@intMaxRowNo ,@intMaxDocRowNo,
				 @InsuranceCashCode,0,@Payment,TS.pub.funChangeFarsiStrings(pub.funReverseForCrystal(@strRecDesc2)),TS.pub.funChangeFarsiStrings(@DescHdr),0,0,'')	



		SET @intMaxDocRowNo = @intMaxDocRowNo + 1
		SET @intMaxRowNo = @intMaxRowNo + 1
		
		SET @strRecDesc2 = @strRecDesc + 'حساب پرداختنی بیمه مرکزی'
		
		INSERT INTO acc.tblVoucherDtl
				(SerialNo,SourceProcessID,SourceProcessNo,SourceFiscalYear,SourceSerialNo,DocDate,IsAutoDoc,SessionNo,VchKind,RowNo,DocRowNo,
				 AcntCode,Debit,Credit,RecDesc,RecDesc2,SourceDocType,CurrencyAmount,CurrencyTypeID) 
		VALUES	(@intVchNo,@intSourceProcessID,@intSourceProcessNo,@intSourceFiscalYear,@intSourceSerialNo,@strVchDate ,1,@SessionNo ,1,@intMaxRowNo ,@intMaxDocRowNo,
				 @InsuranceMainAcntCodeCredit,0,@Instalment,TS.pub.funChangeFarsiStrings(pub.funReverseForCrystal(@strRecDesc2)),TS.pub.funChangeFarsiStrings(@DescHdr),0,0,'')	




declare @Remain as bigint
SELECT @Remain = ISNULL(SUM(Credit-Debit),0)
from acc.tblVoucherDtl
where SourceProcessID=@intSourceProcessID and SourceProcessNo=@intSourceProcessNo 
and SourceFiscalYear=@intSourceFiscalYear and SourceSerialNo=@intSourceSerialNo

if @Remain >0
begin 
		SET @intMaxDocRowNo = @intMaxDocRowNo + 1
		SET @intMaxRowNo = @intMaxRowNo + 1
		
		SET @strRecDesc2 = @strRecDesc + 'حساب پول خرد  درصد ها'
		
		INSERT INTO acc.tblVoucherDtl
				(SerialNo,SourceProcessID,SourceProcessNo,SourceFiscalYear,SourceSerialNo,DocDate,IsAutoDoc,SessionNo,VchKind,RowNo,DocRowNo,
				 AcntCode,Debit,Credit,RecDesc,RecDesc2,SourceDocType,CurrencyAmount,CurrencyTypeID) 
		VALUES	(@intVchNo,@intSourceProcessID,@intSourceProcessNo,@intSourceFiscalYear,@intSourceSerialNo,@strVchDate ,1,@SessionNo ,1,@intMaxRowNo ,@intMaxDocRowNo,
				 @InsurancePriceLittle,@Remain,0,TS.pub.funChangeFarsiStrings(pub.funReverseForCrystal(@strRecDesc2)),TS.pub.funChangeFarsiStrings(@DescHdr),0,0,'')	

end
else
begin
		SET @intMaxDocRowNo = @intMaxDocRowNo + 1
		SET @intMaxRowNo = @intMaxRowNo + 1
		
	SET @strRecDesc2 = @strRecDesc + 'حساب پول خرد  درصد ها'	
		INSERT INTO acc.tblVoucherDtl
				(SerialNo,SourceProcessID,SourceProcessNo,SourceFiscalYear,SourceSerialNo,DocDate,IsAutoDoc,SessionNo,VchKind,RowNo,DocRowNo,
				 AcntCode,Debit,Credit,RecDesc,RecDesc2,SourceDocType,CurrencyAmount,CurrencyTypeID) 
		VALUES	(@intVchNo,@intSourceProcessID,@intSourceProcessNo,@intSourceFiscalYear,@intSourceSerialNo,@strVchDate ,1,@SessionNo ,1,@intMaxRowNo ,@intMaxDocRowNo,
				 @InsurancePriceLittle,0,abs(@Remain),TS.pub.funChangeFarsiStrings(pub.funReverseForCrystal(@strRecDesc2)),TS.pub.funChangeFarsiStrings(@DescHdr),0,0,'')	

end



END
GO
