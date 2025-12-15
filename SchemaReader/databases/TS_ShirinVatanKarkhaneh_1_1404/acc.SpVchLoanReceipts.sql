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
CREATE PROCEDURE [acc].[SpVchLoanReceipts]
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
	
	Declare @SumInstallmentAmount	Bigint
	Declare @SumInstallmentCost		Bigint
	Declare @PrepaymenAmount		Bigint
	Declare @Prepayment				Varchar(20)
	Declare @BankAcntCode			Varchar(20)
	Declare @PayableLoanAcntCode	Varchar(20)
	Declare @LoanAcntCode	Varchar(20)
	Declare @LoanHdrDesc	Varchar(2000)
	Declare @LoanNo			NVarChar(200)
	Declare @LoanName		NVarChar(200)
	Declare @strRecDesc		NVarChar(500)
	DECLARE @strSourceProcessNo NVARCHAR(100)
	IF  @intSourceProcessNo< 2
		SET @strSourceProcessNo = ''
	ELSE
		SET @strSourceProcessNo = LTRIM(RTRIM(STR(@intSourceProcessNo)))


	-----
	SELECT	@SumInstallmentAmount=SUM(InstallmentAmount),@SumInstallmentCost=SUM(InstallmentCost)
	FROM trs.tblLoanDtl
	WHERE ProcessID=@intSourceProcessID AND
		  ProcessNo=@intSourceProcessNo AND
		  FiscalYear=@intSourceFiscalYear AND
		  SerialNo=@intSourceSerialNo 

	-----
	SELECT	@BankAcntCode=BankAcntCode,@PayableLoanAcntCode=PayableLoanAcntCode,
			@LoanAcntCode=LoanAcntCode,@LoanHdrDesc=LoanHdrDesc,
			@PrepaymenAmount=PrepaymenAmount,@Prepayment=Prepayment,
			@LoanNo=LoanNo ,@LoanName=LoanName
	FROM trs.tblLoanHdr
	WHERE ProcessID=@intSourceProcessID AND
		  ProcessNo=@intSourceProcessNo AND
		  FiscalYear=@intSourceFiscalYear AND
		  SerialNo=@intSourceSerialNo 

		  				
	IF @Prepayment='' AND @PrepaymenAmount<>0
		BEGIN
			declare @strMsgText Nvarchar(2000) 
			SET @strMsgText=N'کد حسابداری پیش پرداخت خالی است'
			Raiserror (@strMsgText,16,1)
			Return
		END

	--------------------------------------------------------------------------------------------------------
	SET @strRecDesc=' برگ دریافت وام ' + @strSourceProcessNo + ' شماره' + LTRIM(RTRIM(STR(@intSourceFiscalYear))) + '/' + LTRIM(RTRIM(STR(@intSourceSerialNo))) +
					' - ' + @strVchDate
	IF @LoanNo <>''
		SET @strRecDesc = @strRecDesc + ' شماره تسهیلات ' + @LoanNo
	IF @LoanName <>''
		SET @strRecDesc = @strRecDesc + ' نام تسهیلات ' + @LoanName
	-----
	SET @intMaxDocRowNo = @intMaxDocRowNo + 1
	SET @intMaxRowNo = @intMaxRowNo + 1

	INSERT INTO acc.tblVoucherDtl
			(SerialNo,SourceProcessID,SourceProcessNo,SourceFiscalYear,SourceSerialNo,DocDate,IsAutoDoc,SessionNo,VchKind,RowNo,DocRowNo,
				AcntCode,Debit,Credit,RecDesc,RecDesc2,SourceDocType) 
	VALUES	(@intVchNo,@intSourceProcessID,@intSourceProcessNo,@intSourceFiscalYear,@intSourceSerialNo,@strVchDate ,1,@SessionNo ,1,@intMaxRowNo ,@intMaxDocRowNo,
				@BankAcntCode,@SumInstallmentAmount+@PrepaymenAmount,0,TS.pub.funChangeFarsiStrings(pub.funReverseForCrystal(@strRecDesc)),'',0 )	

	-----
	SET @intMaxDocRowNo = @intMaxDocRowNo + 1
	SET @intMaxRowNo = @intMaxRowNo + 1

	INSERT INTO acc.tblVoucherDtl
			(SerialNo,SourceProcessID,SourceProcessNo,SourceFiscalYear,SourceSerialNo,DocDate,IsAutoDoc,SessionNo,VchKind,RowNo,DocRowNo,
				AcntCode,Debit,Credit,RecDesc,RecDesc2,SourceDocType) 
	VALUES	(@intVchNo,@intSourceProcessID,@intSourceProcessNo,@intSourceFiscalYear,@intSourceSerialNo,@strVchDate ,1,@SessionNo ,1,@intMaxRowNo ,@intMaxDocRowNo,
			 @PayableLoanAcntCode,@SumInstallmentCost,0,TS.pub.funChangeFarsiStrings(pub.funReverseForCrystal(@strRecDesc)),'',0 )	

	-----
	SET @intMaxDocRowNo = @intMaxDocRowNo + 1
	SET @intMaxRowNo = @intMaxRowNo + 1

	INSERT INTO acc.tblVoucherDtl
			(SerialNo,SourceProcessID,SourceProcessNo,SourceFiscalYear,SourceSerialNo,DocDate,IsAutoDoc,SessionNo,VchKind,RowNo,DocRowNo,
				AcntCode,Debit,Credit,RecDesc,RecDesc2,SourceDocType) 
	VALUES	(@intVchNo,@intSourceProcessID,@intSourceProcessNo,@intSourceFiscalYear,@intSourceSerialNo,@strVchDate ,1,@SessionNo ,1,@intMaxRowNo ,@intMaxDocRowNo,
			 @LoanAcntCode,0,@SumInstallmentAmount+@SumInstallmentCost,TS.pub.funChangeFarsiStrings(pub.funReverseForCrystal(@strRecDesc)),@LoanHdrDesc,0)	

	-----
	if @Prepayment<>'' and @PrepaymenAmount>0
	BEGIN
		SET @intMaxDocRowNo = @intMaxDocRowNo + 1
		SET @intMaxRowNo = @intMaxRowNo + 1

		INSERT INTO acc.tblVoucherDtl
				(SerialNo,SourceProcessID,SourceProcessNo,SourceFiscalYear,SourceSerialNo,DocDate,IsAutoDoc,SessionNo,VchKind,RowNo,DocRowNo,
					AcntCode,Debit,Credit,RecDesc,RecDesc2,SourceDocType) 
		VALUES	(@intVchNo,@intSourceProcessID,@intSourceProcessNo,@intSourceFiscalYear,@intSourceSerialNo,@strVchDate ,1,@SessionNo ,1,@intMaxRowNo ,@intMaxDocRowNo,
				 @Prepayment,0,@PrepaymenAmount,TS.pub.funChangeFarsiStrings(pub.funReverseForCrystal(@strRecDesc)),@LoanHdrDesc,0)	
	END
		
END

GO
