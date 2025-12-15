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
CREATE PROCEDURE [acc].[SpVchLoanToOtherReceipts_BRN]
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
	Declare @SumInstallmentFine		Bigint
	Declare @BankAcntCode	Varchar(20)
	Declare @PayableLoanAcntCode	Varchar(20)
	Declare @LoanAcntCode	Varchar(2000)
	Declare @CostAcntCode	Varchar(20)
	Declare @FineAcntCode	Varchar(20)

	Declare @LoanHdrDesc	Varchar(20)
	Declare @strMsgText	    NVarchar(2044)
	DECLARE @strSourceProcessNo NVARCHAR(100)
	IF  @intSourceProcessNo< 2
		SET @strSourceProcessNo = ''
	ELSE
		SET @strSourceProcessNo = LTRIM(RTRIM(STR(@intSourceProcessNo)))
	
	-------------------------------------------------------------------------------------------------------
	Declare @strRecDesc NVarChar(500)
	SET @strRecDesc = ' برگ دریافت قسط وام ' + @strSourceProcessNo +  ' شعبه ' + @StrSourceCodeFieldValue + ' شماره' + LTRIM(RTRIM(STR(@intSourceFiscalYear))) + '/' + 
					  LTRIM(RTRIM(STR(@intSourceSerialNo))) + ' - ' + @strVchDate

	-----
	SELECT	@PayableLoanAcntCode=PayableLoanAcntCode,@LoanAcntCode=LoanAcntCode
	FROM trs.tblLoanHdr a,
	   (SELECT BaseFiscalYear,BaseSerialNo
		FROM trs.tblLoanHdr
		WHERE	ProcessID=@intSourceProcessID AND
				ProcessNo=@intSourceProcessNo AND
				FiscalYear=@intSourceFiscalYear AND
				SerialNo=@intSourceSerialNo ) b
	WHERE	a.FiscalYear=b.BaseFiscalYear AND a.SerialNo=b.BaseSerialNo AND 
			a.ProcessID= 47 AND a.ProcessNo= @intSourceProcessNo

    IF @LoanAcntCode = ''
		BEGIN
			--کد حسابداری وامهای دریافتنی خالی است
			SET @strMsgText=TS.pub.funGetMessages(11032,@LanguageID)
			Raiserror (@strMsgText,16,1)
			Return
		END
		
	-----
	SELECT	@BankAcntCode=BankAcntCode,@FineAcntCode=FineAcntCode,
			@CostAcntCode=CostAcntCode,@LoanHdrDesc=LoanHdrDesc
	FROM trs.tblLoanHdr
	WHERE ProcessID=@intSourceProcessID AND
		  ProcessNo=@intSourceProcessNo AND
		  FiscalYear=@intSourceFiscalYear AND
		  SerialNo=@intSourceSerialNo 

	-----
	SELECT	@SumInstallmentAmount=SUM(InstallmentAmount),@SumInstallmentCost=SUM(InstallmentCost),
			@SumInstallmentFine=SUM(InstallmentFine)
	FROM trs.tblLoanDtl
	WHERE ProcessID=@intSourceProcessID AND
		  ProcessNo=@intSourceProcessNo AND
		  FiscalYear=@intSourceFiscalYear AND
		  SerialNo=@intSourceSerialNo 

	-----
	IF @PayableLoanAcntCode <> '' -- سود دریافتنی
		BEGIN

			SET @intMaxDocRowNo = @intMaxDocRowNo + 1
			SET @intMaxRowNo = @intMaxRowNo + 1

			INSERT INTO acc.tblVoucherDtl
					(SerialNo,SourceProcessID,SourceProcessNo,SourceFiscalYear,SourceSerialNo,DocDate,IsAutoDoc,SessionNo,VchKind,RowNo,DocRowNo,
						AcntCode,Debit,Credit,RecDesc,RecDesc2,SourceDocType,SourceCodeFieldValue) 
			VALUES	(@intVchNo,@intSourceProcessID,@intSourceProcessNo,@intSourceFiscalYear,@intSourceSerialNo,@strVchDate ,1,@SessionNo ,1,@intMaxRowNo ,@intMaxDocRowNo,
						@PayableLoanAcntCode,@SumInstallmentCost,0,TS.pub.funChangeFarsiStrings(pub.funReverseForCrystal(@strRecDesc)),'',8,@StrSourceCodeFieldValue )	

			SET @intMaxDocRowNo = @intMaxDocRowNo + 1
			SET @intMaxRowNo = @intMaxRowNo + 1

			INSERT INTO acc.tblVoucherDtl
					(SerialNo,SourceProcessID,SourceProcessNo,SourceFiscalYear,SourceSerialNo,DocDate,IsAutoDoc,SessionNo,VchKind,RowNo,DocRowNo,
						AcntCode,Debit,Credit,RecDesc,RecDesc2,SourceDocType,SourceCodeFieldValue) 
			VALUES	(@intVchNo,@intSourceProcessID,@intSourceProcessNo,@intSourceFiscalYear,@intSourceSerialNo,@strVchDate ,1,@SessionNo ,1,@intMaxRowNo ,@intMaxDocRowNo,
						@CostAcntCode,0,@SumInstallmentCost,TS.pub.funChangeFarsiStrings(pub.funReverseForCrystal(@strRecDesc)),'',8,@StrSourceCodeFieldValue )	

		END

	-----
	SET @intMaxDocRowNo = @intMaxDocRowNo + 1
	SET @intMaxRowNo = @intMaxRowNo + 1

	INSERT INTO acc.tblVoucherDtl
			(SerialNo,SourceProcessID,SourceProcessNo,SourceFiscalYear,SourceSerialNo,DocDate,IsAutoDoc,SessionNo,VchKind,RowNo,DocRowNo,
				AcntCode,Debit,Credit,RecDesc,RecDesc2,SourceDocType,SourceCodeFieldValue) 
	VALUES	(@intVchNo,@intSourceProcessID,@intSourceProcessNo,@intSourceFiscalYear,@intSourceSerialNo,@strVchDate ,1,@SessionNo ,1,@intMaxRowNo ,@intMaxDocRowNo,
			 @BankAcntCode,@SumInstallmentAmount+@SumInstallmentCost+@SumInstallmentFine,0,TS.pub.funChangeFarsiStrings(pub.funReverseForCrystal(@strRecDesc)),'',8,@StrSourceCodeFieldValue )	

	-----
	IF @SumInstallmentFine <> 0
		BEGIN
			SET @intMaxDocRowNo = @intMaxDocRowNo + 1
			SET @intMaxRowNo = @intMaxRowNo + 1

			INSERT INTO acc.tblVoucherDtl
					(SerialNo,SourceProcessID,SourceProcessNo,SourceFiscalYear,SourceSerialNo,DocDate,IsAutoDoc,SessionNo,VchKind,RowNo,DocRowNo,
						AcntCode,Debit,Credit,RecDesc,RecDesc2,SourceDocType,SourceCodeFieldValue) 
			VALUES	(@intVchNo,@intSourceProcessID,@intSourceProcessNo,@intSourceFiscalYear,@intSourceSerialNo,@strVchDate ,1,@SessionNo ,1,@intMaxRowNo ,@intMaxDocRowNo,
						@FineAcntCode,0,@SumInstallmentFine,TS.pub.funChangeFarsiStrings(pub.funReverseForCrystal(@strRecDesc)),'',8,@StrSourceCodeFieldValue )	
		END


	-----
	SET @intMaxDocRowNo = @intMaxDocRowNo + 1
	SET @intMaxRowNo = @intMaxRowNo + 1

	INSERT INTO acc.tblVoucherDtl
			(SerialNo,SourceProcessID,SourceProcessNo,SourceFiscalYear,SourceSerialNo,DocDate,IsAutoDoc,SessionNo,VchKind,RowNo,DocRowNo,
				AcntCode,Debit,Credit,RecDesc,RecDesc2,SourceDocType,SourceCodeFieldValue) 
	VALUES	(@intVchNo,@intSourceProcessID,@intSourceProcessNo,@intSourceFiscalYear,@intSourceSerialNo,@strVchDate ,1,@SessionNo ,1,@intMaxRowNo ,@intMaxDocRowNo,
			 @LoanAcntCode,0,@SumInstallmentAmount+@SumInstallmentCost,TS.pub.funChangeFarsiStrings(pub.funReverseForCrystal(@strRecDesc)),@LoanHdrDesc,8,@StrSourceCodeFieldValue )

END
GO
