USE TS_ShirinVatanKarkhaneh_1_1404
GO
SET ANSI_NULLS, QUOTED_IDENTIFIER ON
GO
 -- =========== TS-QC:OK ========================
 -- Author        : Hadi Sadeghi
 -- Create date   : 99/10/07
 -- Viewed By	 : 
 -- Last Modified : 
 -- Description   : 
 -- =============================================
 
 Create PROCEDURE [acc].[SpVchDispatch]
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

 	Declare @Receiver				Tinyint
 	Declare @Len					Tinyint
 	Declare @BaseSerialNo			INT
 	Declare @AcntPartNo				char(1)
 	Declare @CustomerCode			Varchar(20)
 	Declare @CustomerAcntCode		Varchar(20)
 	Declare @TransportationKindID	Varchar(20)
 	Declare @TrnDispatchCustomer	Varchar(20)
 	Declare @TrnDispatchDriver		Varchar(20)
 	Declare @TrnDispatchCommision	Varchar(20)
 	Declare @DriverCommision		Varchar(20)
 	Declare @TrnDispatchDriverCommision	Varchar(20)
 	Declare @TrnDriverPurcantCostAcntCode	Varchar(20)
 	Declare @DriverID				Varchar(20)
 	Declare @CommissionCode			Varchar(20)
 	Declare @GoodsID				Varchar(20)
 	Declare @VehicleID				Varchar(20)
 	Declare @RefrigeratorID			Varchar(20)
 	Declare @DriverAcntCode			Varchar(20)
 	Declare @IncomeAcntCode			Varchar(20)
 	Declare @ExtraIncomeAcntCode	Varchar(20)
 	Declare @TrnTaxOverWorthAcntCode	Varchar(20)
 	Declare @TrnTollOverWorthAcntCode	Varchar(20)
 	Declare @TrnTaxDebitAcntCodeInDispatch Varchar(20)
 	Declare @TrnMachineCostAcntCode Varchar(20)
 	Declare @DriverCreditAcntCode Varchar(20)
 	Declare @VehicleAcntCode		Varchar(20)
 	Declare @SourceLocationName		NVarChar(100)
 	Declare @DestinationLocationName NVarChar(100)
 	Declare @CustomerName			NVarChar(100)
 	Declare @WaybillNo				NVarChar(30)
 	Declare @TransportationKindName	NVarChar(1000)
 	Declare @GoodsName				NVarChar(1000)
 	Declare @DocDesc				NVarChar(1000)
 	Declare @strRecDesc				NVarChar(1000)
 	Declare @CommissionPrice		Float
 	Declare @ApprovedRate			Float
 	Declare @RealRate				Float
 	Declare @DriverRate				Float
 	Declare @Quantity				Float
 	Declare @DriverCommission		Float
 	Declare @CommissionPercent		Float
	Declare @TaxOverWorthCost		Float
	Declare @TollOverWorthCost		Float
	Declare @Gasoline				Float
	Declare @TotalGasoline			Float
	Declare @Contract				Bit

	SET @TrnTaxDebitAcntCodeInDispatch = ''

	SELECT @AcntPartNo = SettingValue FROM pub.tblSettings WHERE SettingKey = 'AcntPartNumberForRemainCalculation'
	SELECT @TrnDispatchCustomer = SettingValue FROM pub.tblSettings WHERE SettingKey = 'TrnDispatchCustomer'
	SELECT @TrnDispatchDriver = SettingValue FROM pub.tblSettings WHERE SettingKey = 'TrnDispatchDriver'
	SELECT @TrnDispatchCommision = SettingValue FROM pub.tblSettings WHERE SettingKey = 'TrnDispatchCommision'
	SELECT @TrnDispatchDriverCommision = SettingValue FROM pub.tblSettings WHERE SettingKey = 'TrnDispatchDriverCommision'
	SELECT @TrnDriverPurcantCostAcntCode = SettingValue FROM pub.tblSettings WHERE SettingKey = 'TrnDriverPurcantCostAcntCode'
	SELECT @TrnTaxOverWorthAcntCode = SettingValue FROM pub.tblSettings WHERE SettingKey = 'TrnTaxOverWorthAcntCode'
	SELECT @TrnTollOverWorthAcntCode = SettingValue FROM pub.tblSettings WHERE SettingKey = 'TrnTollOverWorthAcntCode'
	SELECT @TrnTaxDebitAcntCodeInDispatch = SettingValue FROM pub.tblSettings WHERE SettingKey = 'TrnTaxDebitAcntCodeInDispatch'
	SELECT @TrnMachineCostAcntCode = SettingValue FROM pub.tblSettings WHERE SettingKey = 'TrnMachineCostAcntCode'

 	SELECT @BaseSerialNo=BaseSerialNo , @CustomerCode=CustomerCode , @DriverID=DriverID, @CommissionCode=CommissionCode, 
 		   @GoodsID=GoodsID , @VehicleID=VehicleID,@RefrigeratorID=RefrigeratorID,@WaybillNo=WaybillNo,@DocDesc=DocDesc,@CommissionPrice=CommissionPrice,
 	       @ApprovedRate=ApprovedRate,@RealRate=RealRate,@DriverRate=DriverRate,@Receiver=Receiver,@DriverCommission=DriverCommission,
 	       @TransportationKindID=TransportationKindID,@Quantity=Quantity,
 	       @SourceLocationName = pub.funGetLocationName(SourceLocationID,1),
 	       @DestinationLocationName = pub.funGetLocationName(DestinationLocationID,1),
		   @TaxOverWorthCost=TaxOverWorthCost,@TollOverWorthCost=TollOverWorthCost,@Contract=[Contract],
		   @Gasoline=Gasoline,@TotalGasoline=TotalGasoline
 	FROM trn.tblDispatchHdr
 	WHERE SerialNo = @intSourceSerialNo AND 
 		  ProcessID = @intSourceProcessID 

 	SET @strRecDesc = 'سند برگه حکم اعزام ' + LTRIM(RTRIM(STR(@intSourceSerialNo))) 
 	
 	SET @CustomerName = rtrim(ltrim(acc.funGetAcntName(@CustomerCode,@AcntPartNo, @LanguageID)))
 	
 	SELECT @Len = (Layer1+Layer2+Layer3+Layer4+Layer5+Layer6+Layer7+Layer8+Layer9) FROM pub.tblCodeLayer where TableName='acc.tblAcnt' and PartNumber=1
 	select @GoodsName = rtrim(ltrim(pub.funGetGoodsName(@GoodsID,@LanguageID)))
 	
 	SELECT @VehicleAcntCode=AcntCode FROM trn.tblVehicles where VehicleID=@VehicleID
 	SELECT @DriverAcntCode=DriverAcntCode,@DriverCommision=DriverCommision,@DriverCreditAcntCode=DriverCreditAcntCode FROM pub.tblDrivers where DriverID=@DriverID
	SELECT @TransportationKindName=TransportationKindName FROM trn.tblTransportationKindDtl WHERE TransportationKindID=@TransportationKindID AND LanguageID=1
	SELECT @IncomeAcntCode = IncomeAcntCode,@ExtraIncomeAcntCode = ExtraIncomeAcntCode,@CommissionPercent=CommissionPercent FROM trn.tblTransportationKind WHERE TransportationKindID=@TransportationKindID

	IF @IncomeAcntCode = ''
	BEGIN
		--
		SET @strMsgText=N'حساب درآمد در تعریف نوع حمل خالی است'
		Raiserror (@strMsgText,16,1)
		Return
	END

	IF @ExtraIncomeAcntCode = ''
	BEGIN
		--
		SET @strMsgText=N'حساب درآمد تفاوت نرخ مصوب در تعریف نوع حمل خالی است'
		Raiserror (@strMsgText,16,1)
		Return
	END

 	PRINT @TrnDispatchDriver
	IF LEN(@VehicleAcntCode)>@Len+2
 		SET @TrnMachineCostAcntCode = SUBSTRING(@TrnMachineCostAcntCode ,1,@Len) + ' ' + SUBSTRING(@VehicleAcntCode,@Len+2,20)
 	
 	IF @Receiver=1
 		SET @CustomerAcntCode = SUBSTRING(@TrnDispatchDriver ,1,@Len) + ' ' + SUBSTRING(@DriverAcntCode,@Len+2,20)
 	ELSE IF @Receiver = 2
 		SET @CustomerAcntCode = SUBSTRING(@TrnDispatchCustomer ,1,@Len) + ' ' + @CustomerCode
 	ELSE IF @Receiver = 3
 		SET @CustomerAcntCode = SUBSTRING(@TrnDispatchCommision ,1,@Len) + ' ' + @CommissionCode

	SET  @CommissionCode = SUBSTRING(@TrnDispatchCommision ,1,@Len) + ' ' + @CommissionCode	
 
 	IF @TrnTaxDebitAcntCodeInDispatch = '' OR @Contract='True'
		SET @TrnTaxDebitAcntCodeInDispatch = @CustomerAcntCode

	IF @IncomeAcntCode  <> '' AND @CustomerAcntCode	<> '' AND @RealRate <> 0 
		BEGIN

			DECLARE @strRecDescC VARCHAR(1000) 
			SET @strRecDescC =@strRecDesc + ' - ' + @TransportationKindName  + ' - ' + LTRIM(RTRIM(STR(@Quantity))) + ' - ' + @GoodsName
				----------------------------------------------------------------------------------------------------------
			SET @intMaxDocRowNo = @intMaxDocRowNo + 1
			SET @intMaxRowNo = @intMaxRowNo + 1

			
			INSERT INTO acc.tblVoucherDtl
					(SerialNo,SourceProcessID,SourceProcessNo,SourceFiscalYear,SourceSerialNo,DocDate,IsAutoDoc,SessionNo,VchKind,RowNo,DocRowNo,
						AcntCode,Debit,Credit,RecDesc,RecDesc2,SourceDocType,CurrencyAmount,CurrencyTypeID) 
			VALUES	(@intVchNo,@intSourceProcessID,@intSourceProcessNo,@intSourceFiscalYear,@intSourceSerialNo,@strVchDate ,1,@SessionNo ,1,@intMaxRowNo ,@intMaxDocRowNo,
					 @CustomerAcntCode,ROUND(@RealRate,0) ,0 ,TS.pub.funChangeFarsiStrings(pub.funReverseForCrystal(@strRecDesc)),'',0,0,'')
						
			--------------------------------------------------------------------------------------------------------
			SET @intMaxDocRowNo = @intMaxDocRowNo + 1
			SET @intMaxRowNo = @intMaxRowNo + 1
			IF @RealRate-@ApprovedRate>0
				INSERT INTO acc.tblVoucherDtl
						(SerialNo,SourceProcessID,SourceProcessNo,SourceFiscalYear,SourceSerialNo,DocDate,IsAutoDoc,SessionNo,VchKind,RowNo,DocRowNo,
						AcntCode,Debit,Credit,RecDesc,RecDesc2,SourceDocType,CurrencyAmount) 
				VALUES	(@intVchNo,@intSourceProcessID,@intSourceProcessNo,@intSourceFiscalYear,@intSourceSerialNo,@strVchDate ,1,@SessionNo ,1,@intMaxRowNo ,@intMaxDocRowNo,
						 @ExtraIncomeAcntCode,0,ROUND(@RealRate-@ApprovedRate,0),TS.pub.funChangeFarsiStrings(pub.funReverseForCrystal(@strRecDescC)),'',0,0)
			ELSE
				INSERT INTO acc.tblVoucherDtl
						(SerialNo,SourceProcessID,SourceProcessNo,SourceFiscalYear,SourceSerialNo,DocDate,IsAutoDoc,SessionNo,VchKind,RowNo,DocRowNo,
						AcntCode,Debit,Credit,RecDesc,RecDesc2,SourceDocType,CurrencyAmount) 
				VALUES	(@intVchNo,@intSourceProcessID,@intSourceProcessNo,@intSourceFiscalYear,@intSourceSerialNo,@strVchDate ,1,@SessionNo ,1,@intMaxRowNo ,@intMaxDocRowNo,
						 @ExtraIncomeAcntCode,ROUND(@ApprovedRate-@RealRate,0),0,TS.pub.funChangeFarsiStrings(pub.funReverseForCrystal(@strRecDescC)),'',0,0)

			IF @ApprovedRate > 0 
			BEGIN
				SET @intMaxDocRowNo = @intMaxDocRowNo + 1
				SET @intMaxRowNo = @intMaxRowNo + 1

				INSERT INTO acc.tblVoucherDtl
						(SerialNo,SourceProcessID,SourceProcessNo,SourceFiscalYear,SourceSerialNo,DocDate,IsAutoDoc,SessionNo,VchKind,RowNo,DocRowNo,
							AcntCode,Debit,Credit,RecDesc,RecDesc2,SourceDocType,CurrencyAmount) 
				VALUES	(@intVchNo,@intSourceProcessID,@intSourceProcessNo,@intSourceFiscalYear,@intSourceSerialNo,@strVchDate ,1,@SessionNo ,1,@intMaxRowNo ,@intMaxDocRowNo,
						 @IncomeAcntCode,0,ROUND(@ApprovedRate,0),TS.pub.funChangeFarsiStrings(pub.funReverseForCrystal(@strRecDescC)),'',0,0)
			END
		END

	IF @TrnTaxOverWorthAcntCode <> '' AND @TaxOverWorthCost <> 0
		BEGIN
			--------------------------------------------------------------------------------------------------------
			DECLARE @strRecDescTaxOverWorth VARCHAR(1000) 
			SET @strRecDescTaxOverWorth = ' مالیات بر ارزش افزوده حکم اعزام ' + LTRIM(RTRIM(STR(@intSourceSerialNo))) 
			
			SET @intMaxDocRowNo = @intMaxDocRowNo + 1
			SET @intMaxRowNo = @intMaxRowNo + 1

			INSERT INTO acc.tblVoucherDtl
					(SerialNo,SourceProcessID,SourceProcessNo,SourceFiscalYear,SourceSerialNo,DocDate,IsAutoDoc,SessionNo,VchKind,RowNo,DocRowNo,
						AcntCode,Debit,Credit,RecDesc,RecDesc2,SourceDocType,CurrencyAmount,CurrencyTypeID,BaseID) 
			VALUES	(@intVchNo,@intSourceProcessID,@intSourceProcessNo,@intSourceFiscalYear,@intSourceSerialNo,@strVchDate ,1,@SessionNo ,1,@intMaxRowNo ,@intMaxDocRowNo,
						@TrnTaxDebitAcntCodeInDispatch,ROUND(@TaxOverWorthCost,0) ,0 ,TS.pub.funChangeFarsiStrings(pub.funReverseForCrystal(@strRecDescTaxOverWorth)),'',0,0,'',2)
			--------------------------------------------------------------------------------------------------------
			SET @intMaxDocRowNo = @intMaxDocRowNo + 1
			SET @intMaxRowNo = @intMaxRowNo + 1

			INSERT INTO acc.tblVoucherDtl
					(SerialNo,SourceProcessID,SourceProcessNo,SourceFiscalYear,SourceSerialNo,DocDate,IsAutoDoc,SessionNo,VchKind,RowNo,DocRowNo,
						AcntCode,Debit,Credit,RecDesc,RecDesc2,SourceDocType,CurrencyAmount,CurrencyTypeID,BaseID) 
			VALUES	(@intVchNo,@intSourceProcessID,@intSourceProcessNo,@intSourceFiscalYear,@intSourceSerialNo,@strVchDate ,1,@SessionNo ,1,@intMaxRowNo ,@intMaxDocRowNo,
						@TrnTaxOverWorthAcntCode,0,ROUND(@TaxOverWorthCost,0),TS.pub.funChangeFarsiStrings(pub.funReverseForCrystal(@strRecDescTaxOverWorth)),'',0,0,'',2)
			
		END

		----------------------------------------------عوارض بر ارزش افزوده--------------------------------------------
		IF @TrnTollOverWorthAcntCode <> '' AND @TollOverWorthCost <> 0
			BEGIN
				--------------------------------------------------------------------------------------------------------
				DECLARE @strRecDescTollOverWorth VARCHAR(1000) 
				SET @strRecDescTollOverWorth = ' عوارض بر ارزش افزوده حکم اعزام ' + LTRIM(RTRIM(STR(@intSourceSerialNo))) 
				
				SET @intMaxDocRowNo = @intMaxDocRowNo + 1
				SET @intMaxRowNo = @intMaxRowNo + 1


				INSERT INTO acc.tblVoucherDtl
						(SerialNo,SourceProcessID,SourceProcessNo,SourceFiscalYear,SourceSerialNo,DocDate,IsAutoDoc,SessionNo,VchKind,RowNo,DocRowNo,
							AcntCode,Debit,Credit,RecDesc,RecDesc2,SourceDocType,CurrencyAmount,CurrencyTypeID,BaseID) 
				VALUES	(@intVchNo,@intSourceProcessID,@intSourceProcessNo,@intSourceFiscalYear,@intSourceSerialNo,@strVchDate ,1,@SessionNo ,1,@intMaxRowNo ,@intMaxDocRowNo,
							@TrnTaxDebitAcntCodeInDispatch,ROUND(@TollOverWorthCost,0) ,0 ,TS.pub.funChangeFarsiStrings(pub.funReverseForCrystal(@strRecDescTollOverWorth)),'',0,0,'',3)
			
				--------------------------------------------------------------------------------------------------------
				SET @intMaxDocRowNo = @intMaxDocRowNo + 1
				SET @intMaxRowNo = @intMaxRowNo + 1

				INSERT INTO acc.tblVoucherDtl
						(SerialNo,SourceProcessID,SourceProcessNo,SourceFiscalYear,SourceSerialNo,DocDate,IsAutoDoc,SessionNo,VchKind,RowNo,DocRowNo,
							AcntCode,Debit,Credit,RecDesc,RecDesc2,SourceDocType,CurrencyAmount,BaseID) 
				VALUES	(@intVchNo,@intSourceProcessID,@intSourceProcessNo,@intSourceFiscalYear,@intSourceSerialNo,@strVchDate ,1,@SessionNo ,1,@intMaxRowNo ,@intMaxDocRowNo,
							@TrnTollOverWorthAcntCode,0,ROUND(@TollOverWorthCost,0),TS.pub.funChangeFarsiStrings(pub.funReverseForCrystal(@strRecDescTollOverWorth)),'',0,0,3)
			END

		IF ((@Receiver <> 2 AND @CustomerAcntCode  <> '') OR (@Receiver = 2 AND @IncomeAcntCode<>'') ) AND @CommissionCode	<> '' AND @CommissionPrice <> 0 
			BEGIN

				DECLARE @strRecDescCC VARCHAR(1000) 
				SET @strRecDescCC =@strRecDesc + 'پورسانت حق العمل کار- از  ' + @SourceLocationName + ' به ' + @DestinationLocationName + ' - ' + @TransportationKindName  + ' - ' + LTRIM(RTRIM(STR(@Quantity))) + ' - ' + @GoodsName
						----------------------------------------------------------------------------------------------------------
				SET @intMaxDocRowNo = @intMaxDocRowNo + 1
				SET @intMaxRowNo = @intMaxRowNo + 1

				IF @Receiver = 2
					INSERT INTO acc.tblVoucherDtl
							(SerialNo,SourceProcessID,SourceProcessNo,SourceFiscalYear,SourceSerialNo,DocDate,IsAutoDoc,SessionNo,VchKind,RowNo,DocRowNo,
								AcntCode,Debit,Credit,RecDesc,RecDesc2,SourceDocType,CurrencyAmount,CurrencyTypeID) 
					VALUES	(@intVchNo,@intSourceProcessID,@intSourceProcessNo,@intSourceFiscalYear,@intSourceSerialNo,@strVchDate ,1,@SessionNo ,1,@intMaxRowNo ,@intMaxDocRowNo,
							 @IncomeAcntCode,ROUND(@CommissionPrice,0) ,0 ,TS.pub.funChangeFarsiStrings(pub.funReverseForCrystal(@strRecDescCC)),'',0,0,'')

				ELSe
					INSERT INTO acc.tblVoucherDtl
							(SerialNo,SourceProcessID,SourceProcessNo,SourceFiscalYear,SourceSerialNo,DocDate,IsAutoDoc,SessionNo,VchKind,RowNo,DocRowNo,
								AcntCode,Debit,Credit,RecDesc,RecDesc2,SourceDocType,CurrencyAmount,CurrencyTypeID) 
					VALUES	(@intVchNo,@intSourceProcessID,@intSourceProcessNo,@intSourceFiscalYear,@intSourceSerialNo,@strVchDate ,1,@SessionNo ,1,@intMaxRowNo ,@intMaxDocRowNo,
							 @CustomerAcntCode,ROUND(@CommissionPrice,0) ,0 ,TS.pub.funChangeFarsiStrings(pub.funReverseForCrystal(@strRecDescCC)),'',0,0,'')
						
				--------------------------------------------------------------------------------------------------------
				SET @intMaxDocRowNo = @intMaxDocRowNo + 1
				SET @intMaxRowNo = @intMaxRowNo + 1

				INSERT INTO acc.tblVoucherDtl
						(SerialNo,SourceProcessID,SourceProcessNo,SourceFiscalYear,SourceSerialNo,DocDate,IsAutoDoc,SessionNo,VchKind,RowNo,DocRowNo,
							AcntCode,Debit,Credit,RecDesc,RecDesc2,SourceDocType,CurrencyAmount) 
				VALUES	(@intVchNo,@intSourceProcessID,@intSourceProcessNo,@intSourceFiscalYear,@intSourceSerialNo,@strVchDate ,1,@SessionNo ,1,@intMaxRowNo ,@intMaxDocRowNo,
						 @CommissionCode,0,ROUND(@CommissionPrice,0),TS.pub.funChangeFarsiStrings(pub.funReverseForCrystal(@strRecDescCC)),'',0,0)

			END
		
	IF @TrnDriverPurcantCostAcntCode  <> '' AND @DriverAcntCode	<> '' AND @DriverRate <> 0  
	BEGIN

		DECLARE @strRecDescD VARCHAR(1000) 
		SET @strRecDescD =@strRecDesc + 'پورسانت - از ' + @SourceLocationName + ' به ' + @DestinationLocationName + ' - ' + @TransportationKindName  + ' - ' + LTRIM(RTRIM(STR(@Quantity))) + ' - ' + @GoodsName
			----------------------------------------------------------------------------------------------------------
		SET @intMaxDocRowNo = @intMaxDocRowNo + 1
		SET @intMaxRowNo = @intMaxRowNo + 1

			
		INSERT INTO acc.tblVoucherDtl
				(SerialNo,SourceProcessID,SourceProcessNo,SourceFiscalYear,SourceSerialNo,DocDate,IsAutoDoc,SessionNo,VchKind,RowNo,DocRowNo,
					AcntCode,Debit,Credit,RecDesc,RecDesc2,SourceDocType,CurrencyAmount,CurrencyTypeID) 
		VALUES	(@intVchNo,@intSourceProcessID,@intSourceProcessNo,@intSourceFiscalYear,@intSourceSerialNo,@strVchDate ,1,@SessionNo ,1,@intMaxRowNo ,@intMaxDocRowNo,
					@TrnDriverPurcantCostAcntCode,ROUND(@DriverRate,0) ,0 ,TS.pub.funChangeFarsiStrings(pub.funReverseForCrystal(@strRecDescD)),'',0,0,'')
						
		--------------------------------------------------------------------------------------------------------
		SET @intMaxDocRowNo = @intMaxDocRowNo + 1
		SET @intMaxRowNo = @intMaxRowNo + 1

		INSERT INTO acc.tblVoucherDtl
				(SerialNo,SourceProcessID,SourceProcessNo,SourceFiscalYear,SourceSerialNo,DocDate,IsAutoDoc,SessionNo,VchKind,RowNo,DocRowNo,
					AcntCode,Debit,Credit,RecDesc,RecDesc2,SourceDocType,CurrencyAmount) 
		VALUES	(@intVchNo,@intSourceProcessID,@intSourceProcessNo,@intSourceFiscalYear,@intSourceSerialNo,@strVchDate ,1,@SessionNo ,1,@intMaxRowNo ,@intMaxDocRowNo,
					@DriverAcntCode,0,ROUND(@DriverRate,0),TS.pub.funChangeFarsiStrings(pub.funReverseForCrystal(@strRecDescD)),'',0,0)

	END


	IF @TrnDispatchDriverCommision  <> '' AND @DriverCommision	<> '' AND @RealRate <> 0  AND @DriverCommission<>0
	BEGIN

		DECLARE @strRecDescV VARCHAR(1000) 
		SET @strRecDescV =@strRecDesc + 'کمیسیون راننده - از ' + @SourceLocationName + ' به ' + @DestinationLocationName + ' - ' + @TransportationKindName  + ' - ' + LTRIM(RTRIM(STR(@Quantity))) + ' - ' + @GoodsName
			----------------------------------------------------------------------------------------------------------
		SET @intMaxDocRowNo = @intMaxDocRowNo + 1
		SET @intMaxRowNo = @intMaxRowNo + 1

			
		INSERT INTO acc.tblVoucherDtl
				(SerialNo,SourceProcessID,SourceProcessNo,SourceFiscalYear,SourceSerialNo,DocDate,IsAutoDoc,SessionNo,VchKind,RowNo,DocRowNo,
					AcntCode,Debit,Credit,RecDesc,RecDesc2,SourceDocType,CurrencyAmount,CurrencyTypeID) 
		VALUES	(@intVchNo,@intSourceProcessID,@intSourceProcessNo,@intSourceFiscalYear,@intSourceSerialNo,@strVchDate ,1,@SessionNo ,1,@intMaxRowNo ,@intMaxDocRowNo,
					@TrnDispatchDriverCommision,ROUND(@DriverCommission,0) ,0 ,TS.pub.funChangeFarsiStrings(pub.funReverseForCrystal(@strRecDescV)),'',0,0,'')
						
		--------------------------------------------------------------------------------------------------------
		SET @intMaxDocRowNo = @intMaxDocRowNo + 1
		SET @intMaxRowNo = @intMaxRowNo + 1

		INSERT INTO acc.tblVoucherDtl
				(SerialNo,SourceProcessID,SourceProcessNo,SourceFiscalYear,SourceSerialNo,DocDate,IsAutoDoc,SessionNo,VchKind,RowNo,DocRowNo,
					AcntCode,Debit,Credit,RecDesc,RecDesc2,SourceDocType,CurrencyAmount) 
		VALUES	(@intVchNo,@intSourceProcessID,@intSourceProcessNo,@intSourceFiscalYear,@intSourceSerialNo,@strVchDate ,1,@SessionNo ,1,@intMaxRowNo ,@intMaxDocRowNo,
					@DriverCommision,0,ROUND(@DriverCommission,0),TS.pub.funChangeFarsiStrings(pub.funReverseForCrystal(@strRecDescV)),'',0,0)

	END
	
	IF @DriverCreditAcntCode  <> '' AND @TrnMachineCostAcntCode	<> '' AND @TotalGasoline > 0  
	BEGIN

		DECLARE @strRecDescGasoline VARCHAR(1000) 
		SET @strRecDescGasoline =@strRecDesc + 'هزینه گازوئیل - از ' + @SourceLocationName + ' به ' + @DestinationLocationName + ' - ' + @TransportationKindName  + ' - ' + LTRIM(RTRIM(STR(@Quantity))) + ' - ' + @GoodsName
			----------------------------------------------------------------------------------------------------------
		SET @intMaxDocRowNo = @intMaxDocRowNo + 1
		SET @intMaxRowNo = @intMaxRowNo + 1

			
		INSERT INTO acc.tblVoucherDtl
				(SerialNo,SourceProcessID,SourceProcessNo,SourceFiscalYear,SourceSerialNo,DocDate,IsAutoDoc,SessionNo,VchKind,RowNo,DocRowNo,
					AcntCode,Debit,Credit,RecDesc,RecDesc2,SourceDocType,CurrencyAmount,CurrencyTypeID) 
		VALUES	(@intVchNo,@intSourceProcessID,@intSourceProcessNo,@intSourceFiscalYear,@intSourceSerialNo,@strVchDate ,1,@SessionNo ,1,@intMaxRowNo ,@intMaxDocRowNo,
					@TrnMachineCostAcntCode,ROUND(@TotalGasoline,0) ,0 ,TS.pub.funChangeFarsiStrings(pub.funReverseForCrystal(@strRecDescGasoline)),'',0,0,'')
						
		--------------------------------------------------------------------------------------------------------
		SET @intMaxDocRowNo = @intMaxDocRowNo + 1
		SET @intMaxRowNo = @intMaxRowNo + 1

		INSERT INTO acc.tblVoucherDtl
				(SerialNo,SourceProcessID,SourceProcessNo,SourceFiscalYear,SourceSerialNo,DocDate,IsAutoDoc,SessionNo,VchKind,RowNo,DocRowNo,
					AcntCode,Debit,Credit,RecDesc,RecDesc2,SourceDocType,CurrencyAmount) 
		VALUES	(@intVchNo,@intSourceProcessID,@intSourceProcessNo,@intSourceFiscalYear,@intSourceSerialNo,@strVchDate ,1,@SessionNo ,1,@intMaxRowNo ,@intMaxDocRowNo,
					@DriverCreditAcntCode,0,ROUND(@TotalGasoline,0),TS.pub.funChangeFarsiStrings(pub.funReverseForCrystal(@strRecDescGasoline)),'',0,0)

	END
	
 END
 
GO
