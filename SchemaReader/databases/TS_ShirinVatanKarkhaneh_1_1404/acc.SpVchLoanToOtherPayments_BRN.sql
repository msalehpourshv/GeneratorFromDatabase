USE TS_ShirinVatanKarkhaneh_1_1404
GO
SET ANSI_NULLS, QUOTED_IDENTIFIER ON
GO
-- =========== TS-QC:OK ========================
-- Author        : Hadi Sadeghi
-- Create date   : 89/01/12
-- Viewed By	 : 
-- Last Modified : 
-- Description   : 
-- =============================================
CREATE PROCEDURE [acc].[SpVchLoanToOtherPayments_BRN]
	@intVchNo				Int,
	@intDocStep				TinyInt,
    @strVchDate				Char(10),
	@intSourceProcessID		TinyInt,
	@intSourceProcessNo		TinyInt,
	@intSourceFiscalYear	SmallInt,
	@intSourceSerialNo		Int,
	@StrSourceCodeFieldName VARCHAR(200),
	@StrSourceCodeFieldValue VARCHAR(200),
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
	Declare @BankAcntCode			Varchar(20)
	Declare @PayableLoanAcntCode	Varchar(20)
	Declare @LoanAcntCode	Varchar(20)
	Declare @LoanHdrDesc	Varchar(2000)
	Declare @strRecDesc		NVarChar(500)
	DECLARE @strSourceProcessNo NVARCHAR(100)
	IF  @intSourceProcessNo< 2
		SET @strSourceProcessNo = ''
	ELSE
		SET @strSourceProcessNo = LTRIM(RTRIM(STR(@intSourceProcessNo)))

	--------------------------------------------------------------------------------------------------------
	SET @strRecDesc='پرداخت وام ' + @strSourceProcessNo + ' شعبه ' + @StrSourceCodeFieldValue + ' شماره برگه ' + LTRIM(RTRIM(STR(@intSourceFiscalYear))) + '/' + LTRIM(RTRIM(STR(@intSourceSerialNo))) +
					' - ' + @strVchDate

	-----
	SELECT	@SumInstallmentAmount=SUM(InstallmentAmount),@SumInstallmentCost=SUM(InstallmentCost)
	FROM trs.tblLoanDtl
	WHERE ProcessID=@intSourceProcessID AND
		  ProcessNo=@intSourceProcessNo AND
		  FiscalYear=@intSourceFiscalYear AND
		  SerialNo=@intSourceSerialNo 

	-----
	SELECT	@BankAcntCode=BankAcntCode,@PayableLoanAcntCode=PayableLoanAcntCode,
			@LoanAcntCode=LoanAcntCode,@LoanHdrDesc=LoanHdrDesc
	FROM trs.tblLoanHdr
	WHERE ProcessID=@intSourceProcessID AND
		  ProcessNo=@intSourceProcessNo AND
		  FiscalYear=@intSourceFiscalYear AND
		  SerialNo=@intSourceSerialNo 

	-----
	SET @intMaxDocRowNo = @intMaxDocRowNo + 1
	SET @intMaxRowNo = @intMaxRowNo + 1

	INSERT INTO acc.tblVoucherDtl
			(SerialNo,SourceProcessID,SourceProcessNo,SourceFiscalYear,SourceSerialNo,DocDate,IsAutoDoc,SessionNo,VchKind,RowNo,DocRowNo,
				AcntCode,Debit,Credit,RecDesc,RecDesc2,SourceDocType,SourceCodeFieldValue) 
	VALUES	(@intVchNo,@intSourceProcessID,@intSourceProcessNo,@intSourceFiscalYear,@intSourceSerialNo,@strVchDate ,1,@SessionNo ,1,@intMaxRowNo ,@intMaxDocRowNo,
			 @LoanAcntCode,@SumInstallmentAmount+@SumInstallmentCost,0,TS.pub.funChangeFarsiStrings(pub.funReverseForCrystal(@strRecDesc)),@LoanHdrDesc,8,@StrSourceCodeFieldValue)	

	-----
	SET @intMaxDocRowNo = @intMaxDocRowNo + 1
	SET @intMaxRowNo = @intMaxRowNo + 1

	INSERT INTO acc.tblVoucherDtl
			(SerialNo,SourceProcessID,SourceProcessNo,SourceFiscalYear,SourceSerialNo,DocDate,IsAutoDoc,SessionNo,VchKind,RowNo,DocRowNo,
				AcntCode,Debit,Credit,RecDesc,RecDesc2,SourceDocType,SourceCodeFieldValue) 
	VALUES	(@intVchNo,@intSourceProcessID,@intSourceProcessNo,@intSourceFiscalYear,@intSourceSerialNo,@strVchDate ,1,@SessionNo ,1,@intMaxRowNo ,@intMaxDocRowNo,
				@BankAcntCode,0,@SumInstallmentAmount,TS.pub.funChangeFarsiStrings(pub.funReverseForCrystal(@strRecDesc)),'',8,@StrSourceCodeFieldValue )	

	-----
	SET @intMaxDocRowNo = @intMaxDocRowNo + 1
	SET @intMaxRowNo = @intMaxRowNo + 1

	INSERT INTO acc.tblVoucherDtl
			(SerialNo,SourceProcessID,SourceProcessNo,SourceFiscalYear,SourceSerialNo,DocDate,IsAutoDoc,SessionNo,VchKind,RowNo,DocRowNo,
				AcntCode,Debit,Credit,RecDesc,RecDesc2,SourceDocType,SourceCodeFieldValue) 
	VALUES	(@intVchNo,@intSourceProcessID,@intSourceProcessNo,@intSourceFiscalYear,@intSourceSerialNo,@strVchDate ,1,@SessionNo ,1,@intMaxRowNo ,@intMaxDocRowNo,
			 @PayableLoanAcntCode,0,@SumInstallmentCost,TS.pub.funChangeFarsiStrings(pub.funReverseForCrystal(@strRecDesc)),'',8 ,@StrSourceCodeFieldValue)	

END
GO
