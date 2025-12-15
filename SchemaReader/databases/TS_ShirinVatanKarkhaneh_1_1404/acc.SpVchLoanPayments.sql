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
Create PROCEDURE [acc].[SpVchLoanPayments]
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
	Declare @SumInstallmentFine		Bigint
	Declare @PrepaymenAmount		Bigint
	Declare @HeseAmount				Bigint
	
	Declare @Prepayment		Varchar(20)
	Declare @BankAcntCode	Varchar(20)
	Declare @PayableLoanAcntCode	Varchar(20)
	Declare @LoanAcntCode	Varchar(20)
	Declare @CostAcntCode	Varchar(20)
	Declare @FineAcntCode	Varchar(20)
	Declare @LoanSavedCost varchar(20)

	Declare @LoanHdrDesc	Varchar(2000)
	Declare @strMsgText	    NVarchar(2044)
	Declare @strRecDesc NVarChar(500)
	DECLARE @strSourceProcessNo NVARCHAR(100)

	IF  @intSourceProcessNo< 2
		SET @strSourceProcessNo = ''
	ELSE
		SET @strSourceProcessNo = LTRIM(RTRIM(STR(@intSourceProcessNo)))
	SET @HeseAmount = 0
	-------------------------------------------------------------------------------------------------------
	SELECT @LoanSavedCost=SettingValue from pub.tblSettings where SettingKey ='LoanSavedCost'
	SET @strRecDesc = ' برگ پرداخت قسط وام ' + @strSourceProcessNo + ' شماره' + LTRIM(RTRIM(STR(@intSourceFiscalYear))) + '/' + 
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
			a.ProcessID= 7 AND a.ProcessNo= @intSourceProcessNo

    IF @LoanAcntCode = ''  or @LoanAcntCode is null
		BEGIN
			--کد حسابداری وامهای پرداختنی خالی است
			SET @strMsgText=TS.pub.funGetMessages(11032,@LanguageID)
			Raiserror (@strMsgText,16,1)
			Return
		END
		
	-----
	SELECT	@BankAcntCode=BankAcntCode,@FineAcntCode=FineAcntCode,
			@CostAcntCode=CostAcntCode,@LoanHdrDesc=LoanHdrDesc,
			@PrepaymenAmount=PrepaymenAmount,@Prepayment=Prepayment
	FROM trs.tblLoanHdr
	WHERE ProcessID=@intSourceProcessID AND
		  ProcessNo=@intSourceProcessNo AND
		  FiscalYear=@intSourceFiscalYear AND
		  SerialNo=@intSourceSerialNo 

	IF @Prepayment='' AND @PrepaymenAmount<>0
	BEGIN			
		SET @strMsgText=N'کد حسابداری بخشودگی خالی است'
		Raiserror (@strMsgText,16,1)
		Return
	END
	-----
	SELECT	@SumInstallmentAmount=SUM(InstallmentAmount),@SumInstallmentCost=SUM(InstallmentCost),
			@SumInstallmentFine=SUM(InstallmentFine)
	FROM trs.tblLoanDtl
	WHERE ProcessID=@intSourceProcessID AND
		  ProcessNo=@intSourceProcessNo AND
		  FiscalYear=@intSourceFiscalYear AND
		  SerialNo=@intSourceSerialNo 

		  	-----

	SELECT	TOP 1 @HeseAmount=HeseAmount
	FROM trs.tblLoanDtl a,
	   (SELECT BaseFiscalYear,BaseSerialNo,InstallmentNo
		FROM trs.tblLoanDtl
		WHERE	ProcessID=@intSourceProcessID AND
				ProcessNo=@intSourceProcessNo AND
				FiscalYear=@intSourceFiscalYear AND
				SerialNo=@intSourceSerialNo ) b
	WHERE	a.FiscalYear=b.BaseFiscalYear AND a.SerialNo=b.BaseSerialNo AND a.InstallmentNo=b.InstallmentNo AND
			a.ProcessID= 7 AND a.ProcessNo= @intSourceProcessNo AND
		    a.HeseYear=@intSourceFiscalYear-1 AND
		    a.HeseAmount<>0


	IF @LoanSavedCost='' AND @HeseAmount<>0
	BEGIN
		Close Cursor_PayDtl;
		Deallocate Cursor_PayDtl; 				
		SET @strMsgText=N'کد حسابداری حصه ذخیره وام در تنظیمت خالی است'
		Raiserror (@strMsgText,16,1)
		Return
	END
	-----
	IF @PayableLoanAcntCode <> '' -- سود پرداختنی
		BEGIN
			SET @intMaxDocRowNo = @intMaxDocRowNo + 1
			SET @intMaxRowNo = @intMaxRowNo + 1

			INSERT INTO acc.tblVoucherDtl
					(SerialNo,SourceProcessID,SourceProcessNo,SourceFiscalYear,SourceSerialNo,DocDate,IsAutoDoc,SessionNo,VchKind,RowNo,DocRowNo,
						AcntCode,Debit,Credit,RecDesc,RecDesc2,SourceDocType) 
			VALUES	(@intVchNo,@intSourceProcessID,@intSourceProcessNo,@intSourceFiscalYear,@intSourceSerialNo,@strVchDate ,1,@SessionNo ,1,@intMaxRowNo ,@intMaxDocRowNo,
						@CostAcntCode,@SumInstallmentCost-@HeseAmount,0,TS.pub.funChangeFarsiStrings(pub.funReverseForCrystal(@strRecDesc)),'',0 )	

			IF 	@HeseAmount <>'0'
			BEGIN
				SET @intMaxDocRowNo = @intMaxDocRowNo + 1
				SET @intMaxRowNo = @intMaxRowNo + 1

				SET @LoanSavedCost = @LoanSavedCost + SUBSTRING(@LoanAcntCode,LEN(@LoanSavedCost)+1,20)  

				INSERT INTO acc.tblVoucherDtl
						(SerialNo,SourceProcessID,SourceProcessNo,SourceFiscalYear,SourceSerialNo,DocDate,IsAutoDoc,SessionNo,VchKind,RowNo,DocRowNo,
							AcntCode,Debit,Credit,RecDesc,RecDesc2,SourceDocType) 
				VALUES	(@intVchNo,@intSourceProcessID,@intSourceProcessNo,@intSourceFiscalYear,@intSourceSerialNo,@strVchDate ,1,@SessionNo ,1,@intMaxRowNo ,@intMaxDocRowNo,
							@LoanSavedCost,@HeseAmount,0,TS.pub.funChangeFarsiStrings(pub.funReverseForCrystal(@strRecDesc)),'',0 )	
			END

			SET @intMaxDocRowNo = @intMaxDocRowNo + 1
			SET @intMaxRowNo = @intMaxRowNo + 1

			INSERT INTO acc.tblVoucherDtl
					(SerialNo,SourceProcessID,SourceProcessNo,SourceFiscalYear,SourceSerialNo,DocDate,IsAutoDoc,SessionNo,VchKind,RowNo,DocRowNo,
						AcntCode,Debit,Credit,RecDesc,RecDesc2,SourceDocType) 
			VALUES	(@intVchNo,@intSourceProcessID,@intSourceProcessNo,@intSourceFiscalYear,@intSourceSerialNo,@strVchDate ,1,@SessionNo ,1,@intMaxRowNo ,@intMaxDocRowNo,
						@PayableLoanAcntCode,0,@SumInstallmentCost,TS.pub.funChangeFarsiStrings(pub.funReverseForCrystal(@strRecDesc)),'',0 )	

		END

	-----
	IF @SumInstallmentFine <> 0
		BEGIN
			SET @intMaxDocRowNo = @intMaxDocRowNo + 1
			SET @intMaxRowNo = @intMaxRowNo + 1

			INSERT INTO acc.tblVoucherDtl
					(SerialNo,SourceProcessID,SourceProcessNo,SourceFiscalYear,SourceSerialNo,DocDate,IsAutoDoc,SessionNo,VchKind,RowNo,DocRowNo,
						AcntCode,Debit,Credit,RecDesc,RecDesc2,SourceDocType) 
			VALUES	(@intVchNo,@intSourceProcessID,@intSourceProcessNo,@intSourceFiscalYear,@intSourceSerialNo,@strVchDate ,1,@SessionNo ,1,@intMaxRowNo ,@intMaxDocRowNo,
						@FineAcntCode,@SumInstallmentFine,0,TS.pub.funChangeFarsiStrings(pub.funReverseForCrystal(@strRecDesc)),'',0 )	
		END


	-----
	SET @intMaxDocRowNo = @intMaxDocRowNo + 1
	SET @intMaxRowNo = @intMaxRowNo + 1

	INSERT INTO acc.tblVoucherDtl
			(SerialNo,SourceProcessID,SourceProcessNo,SourceFiscalYear,SourceSerialNo,DocDate,IsAutoDoc,SessionNo,VchKind,RowNo,DocRowNo,
				AcntCode,Debit,Credit,RecDesc,RecDesc2,SourceDocType) 
	VALUES	(@intVchNo,@intSourceProcessID,@intSourceProcessNo,@intSourceFiscalYear,@intSourceSerialNo,@strVchDate ,1,@SessionNo ,1,@intMaxRowNo ,@intMaxDocRowNo,
			 @LoanAcntCode,@SumInstallmentAmount+@SumInstallmentCost,0,TS.pub.funChangeFarsiStrings(pub.funReverseForCrystal(@strRecDesc)),@LoanHdrDesc,0 )


	-----
	SET @intMaxDocRowNo = @intMaxDocRowNo + 1
	SET @intMaxRowNo = @intMaxRowNo + 1

	INSERT INTO acc.tblVoucherDtl
			(SerialNo,SourceProcessID,SourceProcessNo,SourceFiscalYear,SourceSerialNo,DocDate,IsAutoDoc,SessionNo,VchKind,RowNo,DocRowNo,
				AcntCode,Debit,Credit,RecDesc,RecDesc2,SourceDocType) 
	VALUES	(@intVchNo,@intSourceProcessID,@intSourceProcessNo,@intSourceFiscalYear,@intSourceSerialNo,@strVchDate ,1,@SessionNo ,1,@intMaxRowNo ,@intMaxDocRowNo,
			 @BankAcntCode,0,@SumInstallmentAmount+@SumInstallmentCost+@SumInstallmentFine-@PrepaymenAmount,TS.pub.funChangeFarsiStrings(pub.funReverseForCrystal(@strRecDesc)),'',0 )	

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
