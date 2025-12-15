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
Create PROCEDURE [acc].[SpVchPrd_Receive]
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
 
	Declare @SumWage		Float
	Declare @WageCostAcntCode	Varchar(20)
	Declare @StockAcntCode		Varchar(20)
	Declare @GoodsID			Varchar(20)
	Declare @StoreID			Varchar(20)
	Declare @DStoreID			Varchar(20)
	Declare @AcntCode			Varchar(20)
	Declare @BatchNo			NVarchar(20)
	Declare @BuyTaxOverWorthAcntCode Varchar(20)
	Declare @BuyTollOverWorthAcntCode Varchar(20)
	Declare @strBatchDesc		NVarChar(1000)
	Declare @strRecDesc			NVarChar(1000)
	Declare @strRecDescDtl		NVarChar(1000)
	Declare @strMsgText			NVarChar(2044)
	Declare @DescHdr			NVarChar(1000)
	Declare @DescHdr70			NVarChar(1000)
	Declare @DescDtl			NVarChar(1000)
	Declare @AgreeNo			NVarChar(1000)
	Declare @TaxOverWorthCost	Float
	Declare @TollOverWorthCost	Float
	Declare @FormulaNo		INT
	Declare @BaseSerialNo		INT
	Declare @BaseFiscalYear		Int
	Declare @Prd_TaxAcntCompletWithCustCode bit	
	--------------------------------------------------------------------------------------------------------
	SET @SumWage = 0		
	SET @BaseSerialNo = 0		
	SET @BaseFiscalYear = 0		
	SET @BatchNo = ''		
	SET @strBatchDesc = ''		
	SET @DStoreID = ''	
	set @AgreeNo = ''
	set @DescHdr70 = ''
	-----
	select @Prd_TaxAcntCompletWithCustCode=SettingValue from pub.tblSettings where SettingKey='Prd_TaxAcntCompletWithCustCode'

	SELECT @DescHdr70 = b.DocDesc
	FROM inv.tblStorageDocsHdr a
	inner join inv.tblStorageDocsHdr b
	ON a.BaseProcessID=b.ProcessID AND a.BaseProcessNo=b.ProcessNo AND a.BaseFiscalYear=b.FiscalYear AND a.BaseSerialNo=b.SerialNo
	WHERE a.ProcessID=80 AND b.ProcessID=70 and 
		  a.ProcessNo=@intSourceProcessNo AND
		  a.FiscalYear=@intSourceFiscalYear AND
		  a.SerialNo=@intSourceSerialNo 
	set @DescHdr70=isnull(@DescHdr70,'')

	SELECT @StoreID=StoreID, @AcntCode=AcntCode,@DescHdr = DocDesc,@TaxOverWorthCost=TaxOverWorthCost,@TollOverWorthCost=TollOverWorthCost
		,@BaseSerialNo = BaseSerialNo ,@BaseFiscalYear = BaseFiscalYear, @BatchNo = BatchNo ,@AgreeNo=AgreeNo
	FROM inv.tblStorageDocsHdr
	WHERE ProcessID=@intSourceProcessID AND
		  ProcessNo=@intSourceProcessNo AND
		  FiscalYear=@intSourceFiscalYear AND
		  SerialNo=@intSourceSerialNo 

   SELECT @StockAcntCode=StockAcntCode,@WageCostAcntCode=WageCostAcntCode,
   		  @BuyTaxOverWorthAcntCode = BuyTaxOverWorthAcntCode,
		  @BuyTollOverWorthAcntCode = BuyTollOverWorthAcntCode	
   FROM inv.tblStores 
   WHERE StoreID = @StoreID

   	IF @BaseSerialNo <> 0 AND @BaseFiscalYear <> 0 AND @BatchNo <> ''
		SET @strBatchDesc = N' به شماره قرارد ' + LTRIM(RTRIM(STR(@BaseFiscalYear))) + '/' + LTRIM(RTRIM(STR(@BaseSerialNo))) + ' و شماره بچ ' + LTRIM(RTRIM(@BatchNo))
		
   	DECLARE @PrdWageForOnePoduct AS BIT

	SET @PrdWageForOnePoduct = 'False'
	
	SELECT @PrdWageForOnePoduct = SettingValue
	FROM pub.tblSettings
	WHERE SettingKey = 'PrdWageForOnePoduct' 

   	DECLARE @Overload_PriceInProduct AS BIT
	SET @Overload_PriceInProduct = 'False'

	SELECT @Overload_PriceInProduct = SettingValue
	FROM pub.tblSettings
	WHERE SettingKey = 'Overload_PriceInProduct' 
	
	IF @StockAcntCode='' AND @Overload_PriceInProduct = 'True'
	BEGIN
		--کد موجودی کالا خالی است
		SET @strMsgText=TS.pub.funGetMessages(11001,@LanguageID)
		Raiserror (@strMsgText,16,1)
		Return
	END

	IF @BuyTaxOverWorthAcntCode='' AND @TaxOverWorthCost <>0
		BEGIN
			--کد مالیات بر ارزش افزوده در خرید خالی است
			SET @strMsgText=TS.pub.funGetMessages(11038,@LanguageID)
			Raiserror (@strMsgText,16,1)
			Return
		END
		
	IF @BuyTollOverWorthAcntCode='' AND @TollOverWorthCost <>0
		BEGIN
			--کد عوارض بر ارزش افزوده در خرید خالی است
			SET @strMsgText=TS.pub.funGetMessages(11042,@LanguageID)
			Raiserror (@strMsgText,16,1)
			Return
		END

	SELECT TOP 1	@DescDtl = DescDtl
	FROM inv.tblStorageDocsDtl
	WHERE ProcessID=@intSourceProcessID AND
		  ProcessNo=@intSourceProcessNo AND
		  FiscalYear=@intSourceFiscalYear AND
		  SerialNo=@intSourceSerialNo AND 
		  FormulaProductCount >0
		  

	Declare @GoodsQuantity			Float
	Declare @FormulaProductCount	Float
	Declare @Wage					Float
	Declare @WageRate				int
	Declare @GoodsName				NVarChar(1000)
	Declare @UnitName				NVarChar(1000)


	SET @strRecDesc=' توليد '  + LTRIM(RTRIM(STR(@intSourceFiscalYear))) + '/' + LTRIM(RTRIM(STR(@intSourceSerialNo))) 
	
	Declare	curPrd CURSOR For 
	SELECT	StoreID,Wage,WageRate,GoodsQuantity,GoodsID,pub.funGetGoodsName(GoodsID,@LanguageID) AS GoodsName,inv.funGetUnitName(SubUnitID,@LanguageID) AS UnitName,FormulaProductCount,FormulaNo
	FROM inv.tblStorageDocsDtl
	WHERE ProcessID=@intSourceProcessID AND
		  ProcessNo=@intSourceProcessNo AND
		  FiscalYear=@intSourceFiscalYear AND
		  SerialNo=@intSourceSerialNo 

	
	Open  curPrd; 

	Fetch NEXT From curPrd Into @DStoreID,@Wage,@WageRate,@GoodsQuantity,@GoodsID,@GoodsName,@UnitName,@FormulaProductCount,@FormulaNo

	While (@@Fetch_Status = 0)
		BEGIN
			IF @Wage <>0 
				BEGIN
					IF @StoreID=''
					BEGIN
					   SELECT @WageCostAcntCode=WageCostAcntCode
					   FROM inv.tblStores 
					   WHERE StoreID = @DStoreID

						IF @WageCostAcntCode=''
						BEGIN
							--کد هزینه دستمزد در تولید خالی است
							SET @strMsgText=TS.pub.funGetMessages(16013,@LanguageID)
							Raiserror (@strMsgText,16,1)
							Return
						END
					END

					IF @WageCostAcntCode=''
					BEGIN
						--کد هزینه دستمزد در تولید خالی است
						SET @strMsgText=TS.pub.funGetMessages(16013,@LanguageID)
						Raiserror (@strMsgText,16,1)
						Return
					END

					IF @WageRate = 50 AND @FormulaProductCount=0 and @FormulaNo=0 
						SET @FormulaProductCount =1

					IF @PrdWageForOnePoduct = 'True'
						SET @FormulaProductCount = 1

					SET @strRecDescDtl = @strRecDesc + ' - ' + @GoodsName + ' - ' + ' به تعداد ' +  cast(@GoodsQuantity as varchar(20))  + ' ' + @UnitName + ' ' + ' - ' + ' با نرخ هر ' + @UnitName + ' ' + LTRIM(RTRIM(STR(ROUND(@Wage/@FormulaProductCount,2)))) + @strBatchDesc 
					if @AgreeNo<>''
						SET @strRecDescDtl = @strRecDescDtl + ' به شماره فاکتور ' + @AgreeNo
					
					SET @intMaxDocRowNo = @intMaxDocRowNo + 1
					SET @intMaxRowNo = @intMaxRowNo + 1
									
					INSERT INTO acc.tblVoucherDtl
							(SerialNo,SourceProcessID,SourceProcessNo,SourceFiscalYear,SourceSerialNo,DocDate,IsAutoDoc,SessionNo,VchKind,RowNo,DocRowNo,
								AcntCode,Debit,Credit,RecDesc,RecDesc2,SourceDocType) 
					VALUES	(@intVchNo,@intSourceProcessID,@intSourceProcessNo,@intSourceFiscalYear,@intSourceSerialNo,@strVchDate ,1,@SessionNo ,1,@intMaxRowNo ,@intMaxDocRowNo,
							 @WageCostAcntCode,ROUND(@GoodsQuantity * @Wage / @FormulaProductCount,0),0,TS.pub.funChangeFarsiStrings(pub.funReverseForCrystal(@strRecDescDtl)),TS.pub.funChangeFarsiStrings(pub.funReverseForCrystal(@DescDtl + ' - ' + @DescHdr)),0)	

					-----
					SET @intMaxDocRowNo = @intMaxDocRowNo + 1
					SET @intMaxRowNo = @intMaxRowNo + 1

					INSERT INTO acc.tblVoucherDtl
							(SerialNo,SourceProcessID,SourceProcessNo,SourceFiscalYear,SourceSerialNo,DocDate,IsAutoDoc,SessionNo,VchKind,RowNo,DocRowNo,
								AcntCode,Debit,Credit,RecDesc,RecDesc2,SourceDocType) 
					VALUES	(@intVchNo,@intSourceProcessID,@intSourceProcessNo,@intSourceFiscalYear,@intSourceSerialNo,@strVchDate ,1,@SessionNo ,1,@intMaxRowNo ,@intMaxDocRowNo,
							 @AcntCode,0,ROUND(@GoodsQuantity * @Wage / @FormulaProductCount,0),TS.pub.funChangeFarsiStrings(pub.funReverseForCrystal(@strRecDescDtl)),TS.pub.funChangeFarsiStrings(pub.funReverseForCrystal(@DescDtl + ' - ' + @DescHdr + ' - ' +@DescHdr70 )),0 )	
					 
				END	

				IF @Overload_PriceInProduct='True'
				BEGIN
						DECLARE @OverLoadAcntCode VARCHAR(20)
						DECLARE @OverLoadAmount FLOAT

						Declare	curPrdOL CURSOR For 
						SELECT	OverLoadAcntCode,OverLoadAmount
						FROM prd.tblFormulasOverLoadDtl
						WHERE ProductID=@GoodsID AND
							  SerialNo=@FormulaNo AND 
							  OverLoadAmount > 0 And 
							 (OverLoadProductDtl=1 or (OverLoadProductDtl=0 and OverLoadDecompositionDtl=0))

						Open  curPrdOL; 

						Fetch NEXT From curPrdOL Into @OverLoadAcntCode,@OverLoadAmount

						While (@@Fetch_Status = 0)
						BEGIN
								IF @PrdWageForOnePoduct = 'True'
									SET @FormulaProductCount = 1

								SET @strRecDescDtl = @strRecDesc + ' - ' + @GoodsName + ' - ' + ' به تعداد ' + LTRIM(RTRIM(STR(@GoodsQuantity))) + ' ' + @UnitName + ' ' + ' - ' + ' با سربار هر ' + @UnitName + ' ' + LTRIM(RTRIM(STR(ROUND(@Wage/@OverLoadAmount,2)))) + @strBatchDesc
					
								SET @intMaxDocRowNo = @intMaxDocRowNo + 1
								SET @intMaxRowNo = @intMaxRowNo + 1
								if  @StockAcntCode='' or @StockAcntCode is null 
									SELECT @StockAcntCode=StockAcntCode
									FROM inv.tblStores 
										WHERE StoreID = @DStoreID
   								IF @StockAcntCode='' or  @StockAcntCode is null 
									BEGIN
										--کد موجودی کالا خالی است
										SET @strMsgText=TS.pub.funGetMessages(11001,@LanguageID)
										Raiserror (@strMsgText,16,1)
										Return
									END
					
								INSERT INTO acc.tblVoucherDtl
										(SerialNo,SourceProcessID,SourceProcessNo,SourceFiscalYear,SourceSerialNo,DocDate,IsAutoDoc,SessionNo,VchKind,RowNo,DocRowNo,
											AcntCode,Debit,Credit,RecDesc,RecDesc2,SourceDocType) 
								VALUES	(@intVchNo,@intSourceProcessID,@intSourceProcessNo,@intSourceFiscalYear,@intSourceSerialNo,@strVchDate ,1,@SessionNo ,1,@intMaxRowNo ,@intMaxDocRowNo,
										 @StockAcntCode,ROUND(@GoodsQuantity * @OverLoadAmount / @FormulaProductCount,0),0,TS.pub.funChangeFarsiStrings(pub.funReverseForCrystal(@strRecDescDtl)),TS.pub.funChangeFarsiStrings(pub.funReverseForCrystal(@DescDtl + ' - ' + @DescHdr)),0)	

								-----
								SET @intMaxDocRowNo = @intMaxDocRowNo + 1
								SET @intMaxRowNo = @intMaxRowNo + 1

								INSERT INTO acc.tblVoucherDtl
										(SerialNo,SourceProcessID,SourceProcessNo,SourceFiscalYear,SourceSerialNo,DocDate,IsAutoDoc,SessionNo,VchKind,RowNo,DocRowNo,
											AcntCode,Debit,Credit,RecDesc,RecDesc2,SourceDocType) 
								VALUES	(@intVchNo,@intSourceProcessID,@intSourceProcessNo,@intSourceFiscalYear,@intSourceSerialNo,@strVchDate ,1,@SessionNo ,1,@intMaxRowNo ,@intMaxDocRowNo,
										 @OverLoadAcntCode,0,ROUND(@GoodsQuantity * @OverLoadAmount / @FormulaProductCount,0),TS.pub.funChangeFarsiStrings(pub.funReverseForCrystal(@strRecDescDtl)),TS.pub.funChangeFarsiStrings(pub.funReverseForCrystal(@DescDtl + ' - ' + @DescHdr + ' - ' +@DescHdr70)),0 )	
					 
							Fetch NEXT From curPrdOL Into @OverLoadAcntCode,@OverLoadAmount
						END
								
						close curPrdOL; 
						deallocate curPrdOL;
				END
				
			Fetch NEXT From curPrd Into @DStoreID,@Wage,@WageRate,@GoodsQuantity,@GoodsID,@GoodsName,@UnitName,@FormulaProductCount,@FormulaNo
			
		END	
		
		close curPrd; 
		deallocate curPrd;
		
	-----
	IF @BuyTaxOverWorthAcntCode <> '' AND @TaxOverWorthCost <> 0	
		BEGIN

			SET @strRecDesc=' مالیات بر ارزش افزوده ' + @strRecDesc 

			SET @intMaxDocRowNo = @intMaxDocRowNo + 1
			SET @intMaxRowNo = @intMaxRowNo + 1
		
			IF @Prd_TaxAcntCompletWithCustCode = 'True' 				
 				SELECT @BuyTaxOverWorthAcntCode = [pub].[funMergCode](@BuyTaxOverWorthAcntCode,@AcntCode)
	
			INSERT INTO acc.tblVoucherDtl
					(SerialNo,SourceProcessID,SourceProcessNo,SourceFiscalYear,SourceSerialNo,DocDate,IsAutoDoc,SessionNo,VchKind,RowNo,DocRowNo,
						AcntCode,Debit,Credit,RecDesc,RecDesc2,SourceDocType) 
			VALUES	(@intVchNo,@intSourceProcessID,@intSourceProcessNo,@intSourceFiscalYear,@intSourceSerialNo,@strVchDate ,1,@SessionNo ,1,@intMaxRowNo ,@intMaxDocRowNo,
					 @BuyTaxOverWorthAcntCode,ROUND(@TaxOverWorthCost,0),0,TS.pub.funChangeFarsiStrings(pub.funReverseForCrystal(@strRecDesc)),'',0 )	

			-----
			SET @intMaxDocRowNo = @intMaxDocRowNo + 1
			SET @intMaxRowNo = @intMaxRowNo + 1

			INSERT INTO acc.tblVoucherDtl
					(SerialNo,SourceProcessID,SourceProcessNo,SourceFiscalYear,SourceSerialNo,DocDate,IsAutoDoc,SessionNo,VchKind,RowNo,DocRowNo,
						AcntCode,Debit,Credit,RecDesc,RecDesc2,SourceDocType) 
			VALUES	(@intVchNo,@intSourceProcessID,@intSourceProcessNo,@intSourceFiscalYear,@intSourceSerialNo,@strVchDate ,1,@SessionNo ,1,@intMaxRowNo ,@intMaxDocRowNo,
					 @AcntCode,0,ROUND(@TaxOverWorthCost,0),TS.pub.funChangeFarsiStrings(pub.funReverseForCrystal(@strRecDesc)),TS.pub.funChangeFarsiStrings(pub.funReverseForCrystal(@DescHdr  + ' - ' +@DescHdr70)),0)	
		END
		
	-----
	IF @BuyTollOverWorthAcntCode <> '' AND @TollOverWorthCost <> 0	
		BEGIN

			SET @strRecDesc=' عوارض بر ارزش افزوده ' + @strRecDesc 

			SET @intMaxDocRowNo = @intMaxDocRowNo + 1
			SET @intMaxRowNo = @intMaxRowNo + 1

			IF @Prd_TaxAcntCompletWithCustCode = 'True' 				
 				SELECT @BuyTollOverWorthAcntCode = [pub].[funMergCode](@BuyTollOverWorthAcntCode,@AcntCode)

			INSERT INTO acc.tblVoucherDtl
					(SerialNo,SourceProcessID,SourceProcessNo,SourceFiscalYear,SourceSerialNo,DocDate,IsAutoDoc,SessionNo,VchKind,RowNo,DocRowNo,
						AcntCode,Debit,Credit,RecDesc,RecDesc2,SourceDocType) 
			VALUES	(@intVchNo,@intSourceProcessID,@intSourceProcessNo,@intSourceFiscalYear,@intSourceSerialNo,@strVchDate ,1,@SessionNo ,1,@intMaxRowNo ,@intMaxDocRowNo,
					 @BuyTollOverWorthAcntCode,ROUND(@TollOverWorthCost,0),0,TS.pub.funChangeFarsiStrings(pub.funReverseForCrystal(@strRecDesc)),'',0 )	

			-----
			SET @intMaxDocRowNo = @intMaxDocRowNo + 1
			SET @intMaxRowNo = @intMaxRowNo + 1

			INSERT INTO acc.tblVoucherDtl
					(SerialNo,SourceProcessID,SourceProcessNo,SourceFiscalYear,SourceSerialNo,DocDate,IsAutoDoc,SessionNo,VchKind,RowNo,DocRowNo,
						AcntCode,Debit,Credit,RecDesc,RecDesc2,SourceDocType) 
			VALUES	(@intVchNo,@intSourceProcessID,@intSourceProcessNo,@intSourceFiscalYear,@intSourceSerialNo,@strVchDate ,1,@SessionNo ,1,@intMaxRowNo ,@intMaxDocRowNo,
					 @AcntCode,0,ROUND(@TollOverWorthCost,0),TS.pub.funChangeFarsiStrings(pub.funReverseForCrystal(@strRecDesc)),TS.pub.funChangeFarsiStrings(pub.funReverseForCrystal(@DescHdr + ' - ' +@DescHdr70)),0)	
		END
		
END
GO
