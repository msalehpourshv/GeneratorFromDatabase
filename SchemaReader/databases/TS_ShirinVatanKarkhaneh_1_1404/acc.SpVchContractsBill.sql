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
CREATE PROCEDURE [acc].[SpVchContractsBill]
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
	-----

	Declare @strMsgText	NVarChar(2044),
			@ProjectNo Int, 
			@BillType TINYINT, 
			@TaskMasterAmount BIGINT, 
			@InsuranceDetract BIGINT, 
			@WellDoingtDetract BIGINT, 
			@TaxDetract BIGINT, 
			@TollDetract BIGINT, 
			@PrepaymentDetract BIGINT, 
			@TraineeDetract BIGINT,
			@OtherDetract BIGINT,
			@RecivedAmount BIGINT,
			@TaxOverWorthIncrement BIGINT, 
			@TollOverWorthIncrement BIGINT, 
			@TotalAmount BIGINT, 
			@DocDesc NVARCHAR(500),
			@ReciveAcntCode VARCHAR(20),
			@OtherIncrement BIGINT,
			@SumAmount BIGINT,
			@CustomerAcntCode  VARCHAR(20),
			@InsuranceAcntCode  VARCHAR(20),
			@TaxAcntCode  VARCHAR(20),
			@PrepaymentAcntCode VARCHAR(20),
			@WellDoingAcntCode VARCHAR(20),
			@IncomeAcntCode VARCHAR(20),
		    @TaxOverWorthAcntCode VARCHAR(20),
		    @TollOverWorthAcntCode VARCHAR(20),
		    @OtherIncrementAcntCode VARCHAR(20),
		    @strRecDesc NVARCHAR(500),
		    @strRecDesc2 NVARCHAR(500),
		    @SelectedMonth nvarchar(20),
		    @ProjectName nvarchar(200),
		    @DocDate char(4)
	--------------------------------------------------------------------------------------------------------

	SELECT	@ProjectNo=ProjectNo, @BillType=BillType, @TaskMasterAmount=TaskMasterAmount,@InsuranceDetract=InsuranceDetract, 
			@WellDoingtDetract=WellDoingtDetract, @TaxDetract=TaxDetract, @TollDetract=TollDetract, 
			@PrepaymentDetract=PrepaymentDetract, @TraineeDetract=TraineeDetract, @OtherDetract=OtherDetract, 
			@TaxOverWorthIncrement=TaxOverWorthIncrement, @TollOverWorthIncrement=TollOverWorthIncrement,@TotalAmount=TotalAmount, @DocDesc=DocDesc,
			@ReciveAcntCode=ReciveAcntCode, @OtherIncrement=OtherIncrement,@RecivedAmount=RecivedAmount,
			@SelectedMonth=[pub].[funGetTypeText](10,SelectedMonth,1) ,@DocDate=substring(DocDate,1,4)
	FROM cnt.tblContractsBillHdr
	WHERE SerialNo=@intSourceSerialNo 

    SELECT @CustomerAcntCode=CustomerAcntCode,@InsuranceAcntCode=InsuranceAcntCode,@TaxAcntCode=TaxAcntCode,
		   @PrepaymentAcntCode=PrepaymentAcntCode,@WellDoingAcntCode=WellDoingAcntCode,@IncomeAcntCode=IncomeAcntCode,
		   @TaxOverWorthAcntCode=TaxOverWorthAcntCode,@TollOverWorthAcntCode=TollOverWorthAcntCode,@OtherIncrementAcntCode=OtherIncrementAcntCode,
		   @ProjectName=ProjectName
    FROM acc.tblContratctsHdr
    WHERE SerialNo= @ProjectNo



	
		SET @strRecDesc=' صورت وضعيت برگه' + LTRIM(RTRIM(STR(@intSourceSerialNo))) + ' - ' + @SelectedMonth + ' ' + @DocDate + ' - ' + @ProjectName
		set @SumAmount = 0
	

		SET @intMaxDocRowNo = @intMaxDocRowNo + 1
		SET @intMaxRowNo = @intMaxRowNo + 1
		
		INSERT INTO acc.tblVoucherDtl
				(SerialNo,SourceProcessID,SourceProcessNo,SourceFiscalYear,SourceSerialNo,DocDate,IsAutoDoc,SessionNo,VchKind,RowNo,DocRowNo,
				 AcntCode,Debit,Credit,RecDesc,RecDesc2,SourceDocType,CurrencyAmount) 
		VALUES	(@intVchNo,@intSourceProcessID,@intSourceProcessNo,@intSourceFiscalYear,@intSourceSerialNo,@strVchDate ,1,@SessionNo ,1,@intMaxRowNo ,@intMaxDocRowNo,
				@ReciveAcntCode ,@RecivedAmount,0,TS.pub.funChangeFarsiStrings(pub.funReverseForCrystal(@strRecDesc)),TS.pub.funChangeFarsiStrings(pub.funReverseForCrystal(@DocDesc)),0,0)	

		SET @intMaxDocRowNo = @intMaxDocRowNo + 1
		SET @intMaxRowNo = @intMaxRowNo + 1
		
		INSERT INTO acc.tblVoucherDtl
				(SerialNo,SourceProcessID,SourceProcessNo,SourceFiscalYear,SourceSerialNo,DocDate,IsAutoDoc,SessionNo,VchKind,RowNo,DocRowNo,
				 AcntCode,Debit,Credit,RecDesc,RecDesc2,SourceDocType,CurrencyAmount) 
		VALUES	(@intVchNo,@intSourceProcessID,@intSourceProcessNo,@intSourceFiscalYear,@intSourceSerialNo,@strVchDate ,1,@SessionNo ,1,@intMaxRowNo ,@intMaxDocRowNo,
				 @CustomerAcntCode,@TotalAmount-@RecivedAmount,0,TS.pub.funChangeFarsiStrings(pub.funReverseForCrystal(@strRecDesc)),TS.pub.funChangeFarsiStrings(pub.funReverseForCrystal(@DocDesc)),0,0)
				 	
		IF @InsuranceAcntCode<>'' AND @InsuranceDetract>0
		BEGIN
			SET @strRecDesc2=@strRecDesc + ' - کسورات بیمه '
			
			SET @intMaxDocRowNo = @intMaxDocRowNo + 1
			SET @intMaxRowNo = @intMaxRowNo + 1
			set @SumAmount = @SumAmount + @InsuranceDetract
			INSERT INTO acc.tblVoucherDtl
					(SerialNo,SourceProcessID,SourceProcessNo,SourceFiscalYear,SourceSerialNo,DocDate,IsAutoDoc,SessionNo,VchKind,RowNo,DocRowNo,
					 AcntCode,Debit,Credit,RecDesc,RecDesc2,SourceDocType,CurrencyAmount) 
			VALUES	(@intVchNo,@intSourceProcessID,@intSourceProcessNo,@intSourceFiscalYear,@intSourceSerialNo,@strVchDate ,1,@SessionNo ,1,@intMaxRowNo ,@intMaxDocRowNo,
					@InsuranceAcntCode,@InsuranceDetract,0,TS.pub.funChangeFarsiStrings(pub.funReverseForCrystal(@strRecDesc2)),TS.pub.funChangeFarsiStrings(pub.funReverseForCrystal(@DocDesc)),0,0)	
		END
		
		IF @TaxAcntCode<>'' AND @TaxDetract>0
		BEGIN
			SET @strRecDesc2=@strRecDesc + ' - کسورات مالیات '
			SET @intMaxDocRowNo = @intMaxDocRowNo + 1
			SET @intMaxRowNo = @intMaxRowNo + 1
			set @SumAmount = @SumAmount + @TaxDetract
			
			INSERT INTO acc.tblVoucherDtl
					(SerialNo,SourceProcessID,SourceProcessNo,SourceFiscalYear,SourceSerialNo,DocDate,IsAutoDoc,SessionNo,VchKind,RowNo,DocRowNo,
					 AcntCode,Debit,Credit,RecDesc,RecDesc2,SourceDocType,CurrencyAmount) 
			VALUES	(@intVchNo,@intSourceProcessID,@intSourceProcessNo,@intSourceFiscalYear,@intSourceSerialNo,@strVchDate ,1,@SessionNo ,1,@intMaxRowNo ,@intMaxDocRowNo,
					@TaxAcntCode,@TaxDetract,0,TS.pub.funChangeFarsiStrings(pub.funReverseForCrystal(@strRecDesc2)),TS.pub.funChangeFarsiStrings(pub.funReverseForCrystal(@DocDesc)),0,0)	
		END
		
		IF @PrepaymentAcntCode<>'' AND @PrepaymentDetract>0
		BEGIN
			SET @strRecDesc2=@strRecDesc + ' - کسورات پیش پرداخت '
			SET @intMaxDocRowNo = @intMaxDocRowNo + 1
			SET @intMaxRowNo = @intMaxRowNo + 1
			set @SumAmount = @SumAmount + @PrepaymentDetract
			
			INSERT INTO acc.tblVoucherDtl
					(SerialNo,SourceProcessID,SourceProcessNo,SourceFiscalYear,SourceSerialNo,DocDate,IsAutoDoc,SessionNo,VchKind,RowNo,DocRowNo,
					 AcntCode,Debit,Credit,RecDesc,RecDesc2,SourceDocType,CurrencyAmount) 
			VALUES	(@intVchNo,@intSourceProcessID,@intSourceProcessNo,@intSourceFiscalYear,@intSourceSerialNo,@strVchDate ,1,@SessionNo ,1,@intMaxRowNo ,@intMaxDocRowNo,
					@PrepaymentAcntCode,@PrepaymentDetract,0,TS.pub.funChangeFarsiStrings(pub.funReverseForCrystal(@strRecDesc2)),TS.pub.funChangeFarsiStrings(pub.funReverseForCrystal(@DocDesc)),0,0)	
		END
		
		IF @WellDoingAcntCode<>'' AND @WellDoingtDetract>0
		BEGIN
			SET @strRecDesc2=@strRecDesc + ' - کسورات حسن انجام کار '
			SET @intMaxDocRowNo = @intMaxDocRowNo + 1
			SET @intMaxRowNo = @intMaxRowNo + 1
			
			set @SumAmount = @SumAmount + @WellDoingtDetract
			
			INSERT INTO acc.tblVoucherDtl
					(SerialNo,SourceProcessID,SourceProcessNo,SourceFiscalYear,SourceSerialNo,DocDate,IsAutoDoc,SessionNo,VchKind,RowNo,DocRowNo,
					 AcntCode,Debit,Credit,RecDesc,RecDesc2,SourceDocType,CurrencyAmount) 
			VALUES	(@intVchNo,@intSourceProcessID,@intSourceProcessNo,@intSourceFiscalYear,@intSourceSerialNo,@strVchDate ,1,@SessionNo ,1,@intMaxRowNo ,@intMaxDocRowNo,
					@WellDoingAcntCode,@WellDoingtDetract,0,TS.pub.funChangeFarsiStrings(pub.funReverseForCrystal(@strRecDesc2)),TS.pub.funChangeFarsiStrings(pub.funReverseForCrystal(@DocDesc)),0,0)	
		END
		
		IF @TaxOverWorthAcntCode<>'' AND @TaxOverWorthIncrement>0
		BEGIN
			SET @strRecDesc2=@strRecDesc + ' - مالیات بر ارزش افزوده  '
			SET @intMaxDocRowNo = @intMaxDocRowNo + 1
			SET @intMaxRowNo = @intMaxRowNo + 1
			
			INSERT INTO acc.tblVoucherDtl
					(SerialNo,SourceProcessID,SourceProcessNo,SourceFiscalYear,SourceSerialNo,DocDate,IsAutoDoc,SessionNo,VchKind,RowNo,DocRowNo,
					 AcntCode,Debit,Credit,RecDesc,RecDesc2,SourceDocType,CurrencyAmount) 
			VALUES	(@intVchNo,@intSourceProcessID,@intSourceProcessNo,@intSourceFiscalYear,@intSourceSerialNo,@strVchDate ,1,@SessionNo ,1,@intMaxRowNo ,@intMaxDocRowNo,
					@TaxOverWorthAcntCode,0,@TaxOverWorthIncrement,TS.pub.funChangeFarsiStrings(pub.funReverseForCrystal(@strRecDesc2)),TS.pub.funChangeFarsiStrings(pub.funReverseForCrystal(@DocDesc)),0,0)	
			set @SumAmount = @SumAmount - @TaxOverWorthIncrement
		END

		IF @TollOverWorthAcntCode<>'' AND @TollOverWorthIncrement>0
		BEGIN
			SET @strRecDesc2=@strRecDesc + ' - عوارض بر ارزش افزوده  '
			SET @intMaxDocRowNo = @intMaxDocRowNo + 1
			SET @intMaxRowNo = @intMaxRowNo + 1
			
			INSERT INTO acc.tblVoucherDtl
					(SerialNo,SourceProcessID,SourceProcessNo,SourceFiscalYear,SourceSerialNo,DocDate,IsAutoDoc,SessionNo,VchKind,RowNo,DocRowNo,
					 AcntCode,Debit,Credit,RecDesc,RecDesc2,SourceDocType,CurrencyAmount) 
			VALUES	(@intVchNo,@intSourceProcessID,@intSourceProcessNo,@intSourceFiscalYear,@intSourceSerialNo,@strVchDate ,1,@SessionNo ,1,@intMaxRowNo ,@intMaxDocRowNo,
					@TollOverWorthAcntCode,0,@TollOverWorthIncrement,TS.pub.funChangeFarsiStrings(pub.funReverseForCrystal(@strRecDesc2)),TS.pub.funChangeFarsiStrings(pub.funReverseForCrystal(@DocDesc)),0,0)	
			set @SumAmount = @SumAmount - @TollOverWorthIncrement
		END	
				
		IF @OtherIncrementAcntCode<>'' AND @OtherIncrement>0
		BEGIN
			SET @strRecDesc2=@strRecDesc + ' - سایر اضافات  '
			SET @intMaxDocRowNo = @intMaxDocRowNo + 1
			SET @intMaxRowNo = @intMaxRowNo + 1
			set @SumAmount = @SumAmount - @OtherIncrement
			
			INSERT INTO acc.tblVoucherDtl
					(SerialNo,SourceProcessID,SourceProcessNo,SourceFiscalYear,SourceSerialNo,DocDate,IsAutoDoc,SessionNo,VchKind,RowNo,DocRowNo,
					 AcntCode,Debit,Credit,RecDesc,RecDesc2,SourceDocType,CurrencyAmount) 
			VALUES	(@intVchNo,@intSourceProcessID,@intSourceProcessNo,@intSourceFiscalYear,@intSourceSerialNo,@strVchDate ,1,@SessionNo ,1,@intMaxRowNo ,@intMaxDocRowNo,
					@OtherIncrementAcntCode,0,@OtherIncrement,TS.pub.funChangeFarsiStrings(pub.funReverseForCrystal(@strRecDesc2)),TS.pub.funChangeFarsiStrings(pub.funReverseForCrystal(@DocDesc)),0,0)	
		END	
		
			SET @intMaxDocRowNo = @intMaxDocRowNo + 1
			SET @intMaxRowNo = @intMaxRowNo + 1
			
			INSERT INTO acc.tblVoucherDtl
					(SerialNo,SourceProcessID,SourceProcessNo,SourceFiscalYear,SourceSerialNo,DocDate,IsAutoDoc,SessionNo,VchKind,RowNo,DocRowNo,
					 AcntCode,Debit,Credit,RecDesc,RecDesc2,SourceDocType,CurrencyAmount) 
			VALUES	(@intVchNo,@intSourceProcessID,@intSourceProcessNo,@intSourceFiscalYear,@intSourceSerialNo,@strVchDate ,1,@SessionNo ,1,@intMaxRowNo ,@intMaxDocRowNo,
					@IncomeAcntCode,0,@TotalAmount+@SumAmount,TS.pub.funChangeFarsiStrings(pub.funReverseForCrystal(@strRecDesc)),TS.pub.funChangeFarsiStrings(pub.funReverseForCrystal(@DocDesc)),0,0)	
END
GO
