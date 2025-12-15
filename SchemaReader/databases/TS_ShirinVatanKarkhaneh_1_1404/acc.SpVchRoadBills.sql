USE TS_ShirinVatanKarkhaneh_1_1404
GO
SET ANSI_NULLS, QUOTED_IDENTIFIER ON
GO
-- =========== TS-QC:OK ========================
-- Author        : Hadi Sadeghi
-- Create date   : 89/11/24
-- Viewed By	 : 
-- Last Modified : 
-- Description   : 
-- =============================================
CREATE PROCEDURE [acc].[SpVchRoadBills]
	@intVchNo				Int,
	@intDocStep				TinyInt,
    @strVchDate				Char(10),
	@intSourceProcessID		SmallInt,
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
	
	Declare @strMsgText				NVarChar(2044)

	Declare @ServiceID				Varchar(20)
	Declare @AcntCode				Varchar(20)
	Declare @PayanehAmount			Varchar(20)
	Declare @TaxOverWorthAcntCode	Varchar(20)
	Declare @TollOverWorthAcntCode	Varchar(20)
	Declare @strDescDtl				NVarChar(1000)
	Declare @strDescDtlRow			NVarChar(1000)
	Declare @ProcessName			NVarChar(1000)
	Declare @strDescHdr				NVarChar(1000)
	Declare @ServiceAmount			Float
	Declare @ServiceQuantity		Float
	Declare @Commission				Float
	Declare @InsuranceAmont			Float
	Declare @TollOverWorthCost		Float
	Declare @Carfare				Float
	Declare @AfterReceipt			BIT
	
	DECLARE @TrnCommissionAcntCode		Varchar(20),
			@DriverID					Varchar(20),
			@DriverAcntCode				Varchar(20),
			@strDesc					NVarChar(1000),
			@strRecDesc					NVarChar(1000),
			@CustomerAcntCodeFrom		Varchar(20),
			@VehicleID					Varchar(20),
		    @TrnInsuranceAcntCode		Varchar(20),
		    @TrnFullInsuranceAcntCode	Varchar(20),
		    @TrnTerminalOrderAcntCode	Varchar(20),
		    @TrnTerminalPercentAcntCode	Varchar(20),
		    @TrnSocietyAcntCode			Varchar(20),
			@SumAmount					Float,
		    @TrnSocietyPrice			Float,
		    @TrnFullInsurancePrice		Float,
		    @TerminalOrderPay			Float,
    		@intTmpMaxRowNo				Int,
    		@intTmpMaxDocRowNo			Int
	--------------------------------------------------------------------------------------------------------
	SET @SumAmount = 0
	SET @TrnFullInsurancePrice = 0
	SET @TrnSocietyPrice = 0
	
	-------------------------
	SELECT @TrnCommissionAcntCode = SettingValue
	FROM pub.tblSettings
	WHERE SettingKey = 'TrnCommissionAcntCode'

	SELECT @TrnInsuranceAcntCode = SettingValue
	FROM pub.tblSettings
	WHERE SettingKey = 'TrnInsuranceAcntCode'

	SELECT @TrnFullInsuranceAcntCode = SettingValue
	FROM pub.tblSettings
	WHERE SettingKey = 'TrnFullInsuranceAcntCode'
	
	SELECT @TrnFullInsurancePrice = SettingValue
	FROM pub.tblSettings
	WHERE SettingKey = 'TrnFullInsurancePrice'
	
	SELECT @TrnTerminalOrderAcntCode = SettingValue
	FROM pub.tblSettings
	WHERE SettingKey = 'TrnTerminalOrderAcntCode'

	SELECT @TrnTerminalPercentAcntCode = SettingValue
	FROM pub.tblSettings
	WHERE SettingKey = 'TrnTerminalPercentAcntCode'

	SELECT @TrnSocietyAcntCode = SettingValue
	FROM pub.tblSettings
	WHERE SettingKey = 'TrnSocietyAcntCode'

	SELECT @TrnSocietyPrice = SettingValue
	FROM pub.tblSettings
	WHERE SettingKey = 'TrnSocietyPrice'

	-----
	SELECT @CustomerAcntCodeFrom = CustomerAcntCodeFrom, @VehicleID=VehicleID , @Commission = Commission , @DriverID=DriverID,
	       @PayanehAmount=PayanehAmount, @InsuranceAmont=InsuranceAmont , @AfterReceipt = AfterReceipt, @Carfare = Carfare 
	FROM trn.tblRoadBillsHdr
	WHERE SerialNo = @intSourceSerialNo AND 
		  ProcessID = @intSourceProcessID 
	
	SELECT @TerminalOrderPay=TerminalOrderPay 
	FROM  trn.tblVehicles 
	WHERE VehicleID = @VehicleID

	SELECT @DriverAcntCode = DriverAcntCode
	FROM  pub.tblDrivers 
	WHERE DriverID = @DriverID
	
	SET @strDesc = 'سند بارنامه ' + LTRIM(RTRIM(STR(@intSourceFiscalYear))) + '/' + LTRIM(RTRIM(STR(@intSourceSerialNo))) 

	
	SET	@intTmpMaxRowNo = @intMaxRowNo + 1
	SET	@intTmpMaxDocRowNo = @intMaxDocRowNo + 1
	-----
	SET @intMaxDocRowNo = @intMaxDocRowNo + 3
	SET @intMaxRowNo = @intMaxRowNo + 3

	IF @TrnSocietyPrice > 0 
		BEGIN
			-----
			SET @intMaxDocRowNo = @intMaxDocRowNo + 1
			SET @intMaxRowNo = @intMaxRowNo + 1

			SET @SumAmount = @SumAmount + @TrnSocietyPrice
			SET @strRecDesc = @strDesc + ' انجمن صنفی شرکتهای حمل و نقل '

			INSERT INTO acc.tblVoucherDtl
					(SerialNo,SourceProcessID,SourceProcessNo,SourceFiscalYear,SourceSerialNo,DocDate,IsAutoDoc,SessionNo,VchKind,RowNo,DocRowNo,
						AcntCode,Debit,Credit,RecDesc,RecDesc2,SourceDocType) 
			VALUES	(@intVchNo,@intSourceProcessID,@intSourceProcessNo,@intSourceFiscalYear,@intSourceSerialNo,@strVchDate ,1,@SessionNo ,1,@intMaxRowNo ,@intMaxDocRowNo,
					 @TrnSocietyAcntCode,0,@TrnSocietyPrice,TS.pub.funChangeFarsiStrings(pub.funReverseForCrystal(@strRecDesc)),'',0 )
		END		 
		
	SET @intMaxDocRowNo = @intMaxDocRowNo + 1
	SET @intMaxRowNo = @intMaxRowNo + 1

	SET @SumAmount = @SumAmount + @TerminalOrderPay

	SET @strRecDesc = @strDesc + ' برگ نوبت '

	INSERT INTO acc.tblVoucherDtl
			(SerialNo,SourceProcessID,SourceProcessNo,SourceFiscalYear,SourceSerialNo,DocDate,IsAutoDoc,SessionNo,VchKind,RowNo,DocRowNo,
				AcntCode,Debit,Credit,RecDesc,RecDesc2,SourceDocType) 
	VALUES	(@intVchNo,@intSourceProcessID,@intSourceProcessNo,@intSourceFiscalYear,@intSourceSerialNo,@strVchDate ,1,@SessionNo ,1,@intMaxRowNo ,@intMaxDocRowNo,
			 @TrnTerminalOrderAcntCode,0,@TerminalOrderPay,TS.pub.funChangeFarsiStrings(pub.funReverseForCrystal(@strRecDesc)),'',0 )

	SET @intMaxDocRowNo = @intMaxDocRowNo + 1
	SET @intMaxRowNo = @intMaxRowNo + 1

	SET @SumAmount = @SumAmount + @InsuranceAmont

	SET @strRecDesc = @strDesc + ' حق بیمه کالا '

	INSERT INTO acc.tblVoucherDtl
			(SerialNo,SourceProcessID,SourceProcessNo,SourceFiscalYear,SourceSerialNo,DocDate,IsAutoDoc,SessionNo,VchKind,RowNo,DocRowNo,
				AcntCode,Debit,Credit,RecDesc,RecDesc2,SourceDocType) 
	VALUES	(@intVchNo,@intSourceProcessID,@intSourceProcessNo,@intSourceFiscalYear,@intSourceSerialNo,@strVchDate ,1,@SessionNo ,1,@intMaxRowNo ,@intMaxDocRowNo,
			 @TrnInsuranceAcntCode,0,@InsuranceAmont,TS.pub.funChangeFarsiStrings(pub.funReverseForCrystal(@strRecDesc)),'',0 )

	SET @intMaxDocRowNo = @intMaxDocRowNo + 1
	SET @intMaxRowNo = @intMaxRowNo + 1

	SET @SumAmount = @SumAmount + @PayanehAmount

	SET @strRecDesc = @strDesc + ' درصد پایانه '

	INSERT INTO acc.tblVoucherDtl
			(SerialNo,SourceProcessID,SourceProcessNo,SourceFiscalYear,SourceSerialNo,DocDate,IsAutoDoc,SessionNo,VchKind,RowNo,DocRowNo,
				AcntCode,Debit,Credit,RecDesc,RecDesc2,SourceDocType) 
	VALUES	(@intVchNo,@intSourceProcessID,@intSourceProcessNo,@intSourceFiscalYear,@intSourceSerialNo,@strVchDate ,1,@SessionNo ,1,@intMaxRowNo ,@intMaxDocRowNo,
			 @TrnTerminalPercentAcntCode,0,@PayanehAmount,TS.pub.funChangeFarsiStrings(pub.funReverseForCrystal(@strRecDesc)),'',0 )

	SET @intMaxDocRowNo = @intMaxDocRowNo + 1
	SET @intMaxRowNo = @intMaxRowNo + 1

	SET @SumAmount = @SumAmount + @TrnFullInsurancePrice
	
	SET @strRecDesc = @strDesc + ' بیمه تکمیلی '

	INSERT INTO acc.tblVoucherDtl
			(SerialNo,SourceProcessID,SourceProcessNo,SourceFiscalYear,SourceSerialNo,DocDate,IsAutoDoc,SessionNo,VchKind,RowNo,DocRowNo,
				AcntCode,Debit,Credit,RecDesc,RecDesc2,SourceDocType) 
	VALUES	(@intVchNo,@intSourceProcessID,@intSourceProcessNo,@intSourceFiscalYear,@intSourceSerialNo,@strVchDate ,1,@SessionNo ,1,@intMaxRowNo ,@intMaxDocRowNo,
			 @TrnFullInsuranceAcntCode ,0,@TrnFullInsurancePrice ,TS.pub.funChangeFarsiStrings(pub.funReverseForCrystal(@strRecDesc)),'',0 )

--if @Commission - @SumAmount>0
--begin
	SET @intMaxDocRowNo = @intMaxDocRowNo + 1
	SET @intMaxRowNo = @intMaxRowNo + 1

	SET @SumAmount = @SumAmount + @Commission
	
	SET @strRecDesc = @strDesc + ' درآمد کمیسیون '

	INSERT INTO acc.tblVoucherDtl
			(SerialNo,SourceProcessID,SourceProcessNo,SourceFiscalYear,SourceSerialNo,DocDate,IsAutoDoc,SessionNo,VchKind,RowNo,DocRowNo,
				AcntCode,Debit,Credit,RecDesc,RecDesc2,SourceDocType) 
	VALUES	(@intVchNo,@intSourceProcessID,@intSourceProcessNo,@intSourceFiscalYear,@intSourceSerialNo,@strVchDate ,1,@SessionNo ,1,@intMaxRowNo ,@intMaxDocRowNo,
			 @TrnCommissionAcntCode,0,@Commission   ,TS.pub.funChangeFarsiStrings(pub.funReverseForCrystal(@strRecDesc)),'',0 )
--end 

IF @AfterReceipt = 'False'
	BEGIN

		SET @strRecDesc = @strDesc + ' کل کرایه '

		INSERT INTO acc.tblVoucherDtl
				(SerialNo,SourceProcessID,SourceProcessNo,SourceFiscalYear,SourceSerialNo,DocDate,IsAutoDoc,SessionNo,VchKind,RowNo,DocRowNo,
					AcntCode,Debit,Credit,RecDesc,RecDesc2,SourceDocType) 
		VALUES	(@intVchNo,@intSourceProcessID,@intSourceProcessNo,@intSourceFiscalYear,@intSourceSerialNo,@strVchDate ,1,@SessionNo ,1,@intTmpMaxRowNo ,@intTmpMaxDocRowNo,
				 @CustomerAcntCodeFrom,@Carfare ,0 ,TS.pub.funChangeFarsiStrings(pub.funReverseForCrystal(@strRecDesc)),'',0 )
				 

		SET @intMaxDocRowNo = @intMaxDocRowNo + 1
		SET @intMaxRowNo = @intMaxRowNo + 1

		SET @strRecDesc = @strDesc + ' راننده '

		INSERT INTO acc.tblVoucherDtl
				(SerialNo,SourceProcessID,SourceProcessNo,SourceFiscalYear,SourceSerialNo,DocDate,IsAutoDoc,SessionNo,VchKind,RowNo,DocRowNo,
					AcntCode,Debit,Credit,RecDesc,RecDesc2,SourceDocType) 
		VALUES	(@intVchNo,@intSourceProcessID,@intSourceProcessNo,@intSourceFiscalYear,@intSourceSerialNo,@strVchDate ,1,@SessionNo ,1,@intTmpMaxRowNo +1 ,@intTmpMaxDocRowNo+1,
				 @DriverAcntCode ,0,@Carfare - @SumAmount ,TS.pub.funChangeFarsiStrings(pub.funReverseForCrystal(@strRecDesc)),'',0 )

	END
ELSE
	BEGIN
	
		SET @intMaxDocRowNo = @intMaxDocRowNo + 1
		SET @intMaxRowNo = @intMaxRowNo + 1

		SET @strRecDesc = @strDesc + 'پسکرایه - راننده '

		INSERT INTO acc.tblVoucherDtl
				(SerialNo,SourceProcessID,SourceProcessNo,SourceFiscalYear,SourceSerialNo,DocDate,IsAutoDoc,SessionNo,VchKind,RowNo,DocRowNo,
					AcntCode,Debit,Credit,RecDesc,RecDesc2,SourceDocType) 
		VALUES	(@intVchNo,@intSourceProcessID,@intSourceProcessNo,@intSourceFiscalYear,@intSourceSerialNo,@strVchDate ,1,@SessionNo ,1,@intTmpMaxRowNo ,@intTmpMaxDocRowNo,
				 @DriverAcntCode ,@Carfare  ,0,TS.pub.funChangeFarsiStrings(pub.funReverseForCrystal(@strRecDesc)),'',0 )

		--SET @strRecDesc = @strDesc + ' کل کرایه '

		--INSERT INTO acc.tblVoucherDtl
		--		(SerialNo,SourceProcessID,SourceProcessNo,SourceFiscalYear,SourceSerialNo,DocDate,IsAutoDoc,SessionNo,VchKind,RowNo,DocRowNo,
		--			AcntCode,Debit,Credit,RecDesc,RecDesc2,SourceDocType) 
		--VALUES	(@intVchNo,@intSourceProcessID,@intSourceProcessNo,@intSourceFiscalYear,@intSourceSerialNo,@strVchDate ,1,@SessionNo ,1,@intTmpMaxRowNo+2 ,@intTmpMaxDocRowNo+2,
		--		 @CustomerAcntCodeFrom,0 ,@Carfare ,TS.pub.funChangeFarsiStrings(pub.funReverseForCrystal(@strRecDesc)),'',0 )

		SET @intMaxDocRowNo = @intMaxDocRowNo + 1
		SET @intMaxRowNo = @intMaxRowNo + 1

		SET @strRecDesc = @strDesc + 'پسکرایه - راننده '
		
		INSERT INTO acc.tblVoucherDtl
				(SerialNo,SourceProcessID,SourceProcessNo,SourceFiscalYear,SourceSerialNo,DocDate,IsAutoDoc,SessionNo,VchKind,RowNo,DocRowNo,
					AcntCode,Debit,Credit,RecDesc,RecDesc2,SourceDocType) 
		VALUES	(@intVchNo,@intSourceProcessID,@intSourceProcessNo,@intSourceFiscalYear,@intSourceSerialNo,@strVchDate ,1,@SessionNo ,1,@intTmpMaxRowNo +1 ,@intTmpMaxDocRowNo +1,
				 @DriverAcntCode ,0,@Carfare - @SumAmount ,TS.pub.funChangeFarsiStrings(pub.funReverseForCrystal(@strRecDesc)),'',0 )

	END
			

END

GO
