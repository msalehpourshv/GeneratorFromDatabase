USE TS_ShirinVatanKarkhaneh_1_1404
GO
SET ANSI_NULLS, QUOTED_IDENTIFIER ON
GO
 -- =========== TS-QC:OK ========================
 -- Author        : Hadi Sadeghi
 -- Create date   : 87/06/21
 -- Viewed By	 : 
 -- Last Modified : 
 -- Description   : 
 -- =============================================
 Create PROCEDURE [acc].[SpVchServices]
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
 	Declare @AcntCodeHdr			Varchar(20)
 	Declare @AcntCodeHdrName		Varchar(100)
 	Declare @AcntCode1				Varchar(20)
 	Declare @AcntCode2				Varchar(20)
 	Declare @AcntCode3				Varchar(20)
 	Declare @AcntCode4				Varchar(20)
 	Declare @DiscountAcntCode		Varchar(20)
 	Declare @TaxOverWorthAcntCode	Varchar(20)
 	Declare @TollOverWorthAcntCode	Varchar(20)
 	Declare @VisitorAcntCode		Varchar(20)
 	declare @VisitorCostAcntCode	VARCHAR(20)
 	Declare @strRecDesc				NVarChar(1000)
 	Declare @strDescDtl				NVarChar(1000)
 	Declare @strDescDtlRow			NVarChar(1000)
 	Declare @ProcessName			NVarChar(1000)
 	Declare @strDescHdr				NVarChar(1000)
 	Declare @ServiceAmount			Float
 	Declare @ServiceQuantity		Float
 	Declare @SumAmount				Float
 	Declare @SumAmountVisitor		Float
 	Declare @SumAtomAmount			Float
 	Declare @ServiceDiscount		Float
 	Declare @TaxOverWorthCost		Float
 	Declare @TollOverWorthCost		FLOAT
 	Declare @DiscountDtl			FLOAT
 	Declare @VisitorPercent			FLOAT
 	Declare @TaskTax				Float
 	Declare @VisitorCost			Bigint
 	Declare @DocRowNo				INT
 	Declare @TaskTaxAcntCode		VARCHAR(30)
 	
 	DECLARE @AtomAcntCode			Varchar(20)
 	DECLARE @AtomAmount				FLOAT 
 	DECLARE @AtomDesc				Nvarchar(2000)	
 	DECLARE @ServiceAcntCompletWithCustomerCode		BIT
	DECLARE @UsedPriceDecimalsToFormsInVch			BIT
	DECLARE @PriceDecimalsToForms					tinyint
	DECLARE @trs_ShowDtlServicePriceInCustomAccount BIT
	Declare @CurrencyTypeID			VarChar(20)
	Declare @CurrencyRate			Float
	Declare @CurrencyAmount			Float
	Declare @CurrencyRateTmp			Float
	Declare @CurrencyAmountTmp			Float
	Declare @CurrencyTypeIDTmp			VarChar(20)
	SET @CurrencyTypeID = ''
	SET @CurrencyRate = 0 	
	SET @CurrencyAmount = 0
	SET @CurrencyRateTmp = 0
	SET @CurrencyAmountTmp = 0
	SET @CurrencyTypeIDTmp = ''

 	--------------------------------------------------------------------------------------------------------
 	SET @SumAmount = 0
 	SET @SumAmountVisitor = 0
 	SET @TaskTax = 0
 	-----
 	SET @ProcessName = ''
 	set @strDescHdr = ''
 	set @AcntCode1 = ''
 	set @AcntCode2 = ''
 	set @AcntCode3 = ''
 	set @AcntCode4 = ''
 	set @VisitorCostAcntCode = ''
 	set @ServiceAcntCompletWithCustomerCode = 'False'

	SET @PriceDecimalsToForms = 0

	SET @UsedPriceDecimalsToFormsInVch='False'

	select @UsedPriceDecimalsToFormsInVch=SettingValue from pub.tblSettings where SettingKey='UsedPriceDecimalsToFormsInVch'
	select @trs_ShowDtlServicePriceInCustomAccount=SettingValue from pub.tblSettings where SettingKey='trs_ShowDtlServicePriceInCustomAccount'

	set @trs_ShowDtlServicePriceInCustomAccount=isnull(@trs_ShowDtlServicePriceInCustomAccount, 'false')
	IF @UsedPriceDecimalsToFormsInVch='True'
		SELECT @PriceDecimalsToForms=SettingValue from pub.tblSettings where SettingKey='PriceDecimalsToForms'

 	-----
	SELECT @VisitorCostAcntCode = SettingValue
	FROM pub.tblSettings
	WHERE SettingKey = 'ServiceVisitorCostAcntCode'
	-----
	SELECT @ServiceAcntCompletWithCustomerCode = SettingValue
	FROM pub.tblSettings
	WHERE SettingKey = 'ServiceAcntCompletWithCustomerCode'

 	-----
 	SELECT @ProcessName = ProcessName FROM pub.tblProcess WHERE ProcessID = @intSourceProcessID AND ProcessNo = @intSourceProcessNo
 	-----
 	SELECT @AcntCodeHdr=AcntCode , @ServiceDiscount=ServiceDiscount , @DiscountAcntCode=DiscountAcntCode, @TaxOverWorthCost=TaxOverWorthCost , 
 	       @TollOverWorthCost=TollOverWorthCost , @TaxOverWorthAcntCode=TaxOverWorthAcntCode,@TollOverWorthAcntCode=TollOverWorthAcntCode,@strDescHdr=DescHdr,
 	       @VisitorAcntCode=VisitorAcntCode,@VisitorPercent=VisitorPercent,@TaskTax=TaskTax,@TaskTaxAcntCode=TaskTaxAcntCode
		   ,@CurrencyRate=CurrencyRate,@CurrencyTypeID=CurrencyTypeID
 	FROM acc.tblServicesHdr
 	WHERE SerialNo = @intSourceSerialNo AND 
 		  ProcessID = @intSourceProcessID AND 
 		  ProcessNo = @intSourceProcessNo AND 
 		  FiscalYear = @intSourceFiscalYear
 	
 	SET @AcntCodeHdrName = rtrim(ltrim(pub.GetCodeName(@AcntCodeHdr, @LanguageID)))
 	SET @strRecDesc = 'فاکتور ' + @ProcessName + LTRIM(RTRIM(STR(@intSourceFiscalYear))) + '/' + LTRIM(RTRIM(STR(@intSourceSerialNo))) 
	                    + '  مشتری ' + @AcntCodeHdrName 
     	
 	Declare	curService CURSOR For 
 	SELECT	ServiceID,ServiceAmount,ServiceQuantity,DescDtl,DocRowNo,DiscountDtl
 	FROM acc.tblServicesDtl
 	WHERE SerialNo = @intSourceSerialNo AND 
 		  ProcessID = @intSourceProcessID AND 
 		  ProcessNo = @intSourceProcessNo AND 
 		  FiscalYear = @intSourceFiscalYear
 
 	Open  curService; 
 		
 	Fetch NEXT From curService Into @ServiceID,@ServiceAmount,@ServiceQuantity,@strDescDtl,@DocRowNo,@DiscountDtl
 
 	While (@@Fetch_Status = 0)
 	
 		BEGIN
 		
 			SET @AcntCode1 = ''
 			SET @AcntCode2 = ''
 			SET @AcntCode3 = ''
 			SET @AcntCode4 = ''
 			SET @strDescDtlRow = @strRecDesc + ' - '  + acc.funGetServiceName(@ServiceID,1)--+ @AcntCodeHdrName + ' - '
 			SET @strDescDtlRow = TS.pub.funChangeFarsiStrings(pub.funReverseForCrystal(@strDescDtlRow))
 			SET @strDescDtl = @strDescHdr + ' - ' + @strDescDtl 
 			
 			SET @SumAtomAmount = 0
 			SET @ServiceDiscount = @ServiceDiscount + @DiscountDtl
 			
 			IF (SELECT COUNT(*) 
 				FROM acc.tblServicesAtm 
 				WHERE ProcessID  = @intSourceProcessID AND 
 					  ProcessNo  = @intSourceProcessNo AND 
 					  FiscalYear = @intSourceFiscalYear AND 
 					  SerialNo   = @intSourceSerialNo AND 
 					  DocRowNo   = @DocRowNo) >0
 				BEGIN
 					Declare	curServicesAtom CURSOR For 
 					SELECT	AcntCode, Amount, AtomDesc
 					FROM acc.tblServicesAtm 
 					WHERE ProcessID	= @intSourceProcessID AND
 						  ProcessNo	= @intSourceProcessNo AND
 						  FiscalYear= @intSourceFiscalYear AND
 						  SerialNo	= @intSourceSerialNo AND
 						  DocRowNo   = @DocRowNo	
 
 					Open  curServicesAtom; 
 
 					Fetch NEXT From curServicesAtom Into @AtomAcntCode,@AtomAmount,@AtomDesc
 
 					While (@@Fetch_Status = 0)
 						BEGIN
 
 							SET @SumAtomAmount = @SumAtomAmount + @AtomAmount
 					
							IF @CurrencyRate <> 0 	
								SET @CurrencyAmount = ROUND(@AtomAmount,@PriceDecimalsToForms) / @CurrencyRate
		
							IF [acc].[funIsCurrencyAcntCode] (@AtomAcntCode) = 'True'
							Begin
								Set @CurrencyRateTmp	= @CurrencyRate
								Set @CurrencyAmountTmp  = @CurrencyAmount
								Set @CurrencyTypeIDTmp  = @CurrencyTypeID
							End
							Else
							Begin
								Set @CurrencyRateTmp	= 0
								Set @CurrencyAmountTmp  = 0
								Set @CurrencyTypeIDTmp  = ''
							End
									
 							SET @intMaxDocRowNo = @intMaxDocRowNo + 1
 							SET @intMaxRowNo = @intMaxRowNo + 1
 							
 							INSERT INTO acc.tblVoucherDtl
 									(SerialNo,SourceProcessID,SourceProcessNo,SourceFiscalYear,SourceSerialNo,DocDate,IsAutoDoc,SessionNo,VchKind,RowNo,DocRowNo,
 										AcntCode,Debit,Credit,RecDesc,RecDesc2,SourceDocType,CurrencyAmount,CurrencyTypeID,VisitorAcntCode) 
 							VALUES	(@intVchNo,@intSourceProcessID,@intSourceProcessNo,@intSourceFiscalYear,@intSourceSerialNo,@strVchDate ,1,@SessionNo ,1,@intMaxRowNo,@intMaxDocRowNo,
 									 @AtomAcntCode,0,@AtomAmount,@strDescDtlRow,@AtomDesc,0,@CurrencyAmountTmp,@CurrencyTypeIDTmp ,@VisitorAcntCode)			
 
 							Fetch NEXT From curServicesAtom Into @AtomAcntCode,@AtomAmount,@AtomDesc
 						END
 					Close curServicesAtom;
 					Deallocate curServicesAtom; 
 				END
 			
 			DECLARE @Srv1 VARCHAR(20)
 			DECLARE @Srv2 VARCHAR(20)
 			DECLARE @Srv3 VARCHAR(20)
 			DECLARE @Srv4 VARCHAR(20)
 			
		IF (select COUNT(*) from pub.tblCodeLayer where TableName='acc.tblServiceCoding' and Layer1>0) > 1
		BEGIN
 				
			SELECT @Srv1=[pub].[funSplitString](@ServiceID,' ',1)
			SELECT @Srv2=[pub].[funSplitString](@ServiceID,' ',2)
			SELECT @Srv3=[pub].[funSplitString](@ServiceID,' ',3)
			SELECT @Srv4=[pub].[funSplitString](@ServiceID,' ',4)
 
			SELECT @AcntCode1 = AcntCode 
			FROM acc.tblServiceCoding
			WHERE ServiceID = @Srv1
			  AND PartNumber=1
 
			SELECT @AcntCode2 = AcntCode 
			FROM acc.tblServiceCoding
			WHERE ServiceID = @Srv2
			  AND PartNumber=2
 			  
			SELECT @AcntCode3 = AcntCode 
			FROM acc.tblServiceCoding
			WHERE ServiceID = @Srv3
			  AND PartNumber=3
 			  
			SELECT @AcntCode4 = AcntCode 
			FROM acc.tblServiceCoding
			WHERE ServiceID = @Srv4
			  AND PartNumber=4			
 			
			SELECT @AcntCode1 = [pub].[funMergCode]([pub].[funMergCode]([pub].[funMergCode](@AcntCode1,@AcntCode2),@AcntCode3),@AcntCode4)	
 		END
 		ELSE
 		begin 
 			SELECT @AcntCode1 = AcntCode 
			FROM acc.tblServiceCoding
			WHERE ServiceID = @ServiceID
			  AND PartNumber=1
 		end
 		
 			IF @AcntCode1=''
 				BEGIN
 					--کد حسابداري خدمات %s خالي است
 					SET @strMsgText=TS.pub.funGetMessages(12083,@LanguageID)
 					Raiserror (@strMsgText,16,1,@ServiceID)
 					Return
 				END

			IF @ServiceAcntCompletWithCustomerCode = 'True' 				
 				SELECT @AcntCode1 = [pub].[funMergCode](@AcntCode1,@AcntCodeHdr)

 			SET @SumAmount = @SumAmount + (@ServiceAmount * @ServiceQuantity)
 			SET @SumAmountVisitor = @SumAmountVisitor + (@ServiceAmount * @ServiceQuantity)
 		
 		 
 			IF @SumAtomAmount > @ServiceAmount * @ServiceQuantity
			begin

				IF @CurrencyRate <> 0 	
					SET @CurrencyAmount = ROUND(@SumAtomAmount - (@ServiceAmount * @ServiceQuantity),@PriceDecimalsToForms) / @CurrencyRate
		
				IF [acc].[funIsCurrencyAcntCode] (@AcntCode1) = 'True'
				Begin
					Set @CurrencyRateTmp	= @CurrencyRate
					Set @CurrencyAmountTmp  = @CurrencyAmount
					Set @CurrencyTypeIDTmp  = @CurrencyTypeID
				End
				Else
				Begin
					Set @CurrencyRateTmp	= 0
					Set @CurrencyAmountTmp  = 0
					Set @CurrencyTypeIDTmp  = ''
				End
				SET @intMaxDocRowNo = @intMaxDocRowNo + 1
				SET @intMaxRowNo = @intMaxRowNo + 1
 							
 				INSERT INTO acc.tblVoucherDtl
 						(SerialNo,SourceProcessID,SourceProcessNo,SourceFiscalYear,SourceSerialNo,DocDate,IsAutoDoc,SessionNo,VchKind,RowNo,DocRowNo,
 						 AcntCode,Debit,Credit,RecDesc,RecDesc2,SourceDocType,CurrencyAmount,CurrencyTypeID,VisitorAcntCode) 
 				VALUES	(@intVchNo,@intSourceProcessID,@intSourceProcessNo,@intSourceFiscalYear,@intSourceSerialNo,@strVchDate ,1,@SessionNo ,1,@intMaxRowNo ,@intMaxDocRowNo,
 						 @AcntCode1,ROUND(@SumAtomAmount - (@ServiceAmount * @ServiceQuantity),@PriceDecimalsToForms),0,@strDescDtlRow,@strDescDtl,0,@CurrencyAmountTmp,@CurrencyTypeIDTmp,@VisitorAcntCode )
 
				 IF @trs_ShowDtlServicePriceInCustomAccount='True'
 					begin 				  	
						
						IF @CurrencyRate <> 0 	
							SET @CurrencyAmount = ROUND(@SumAtomAmount - (@ServiceAmount * @ServiceQuantity),@PriceDecimalsToForms) / @CurrencyRate
		
						IF [acc].[funIsCurrencyAcntCode] (@AcntCodeHdr) = 'True'
						Begin
							Set @CurrencyRateTmp	= @CurrencyRate
							Set @CurrencyAmountTmp  = @CurrencyAmount
							Set @CurrencyTypeIDTmp  = @CurrencyTypeID
						End
						Else
						Begin
							Set @CurrencyRateTmp	= 0
							Set @CurrencyAmountTmp  = 0
							Set @CurrencyTypeIDTmp  = ''
						End
						SET @intMaxDocRowNo = @intMaxDocRowNo + 1
						SET @intMaxRowNo = @intMaxRowNo + 1

						INSERT INTO acc.tblVoucherDtl
							(SerialNo,SourceProcessID,SourceProcessNo,SourceFiscalYear,SourceSerialNo,DocDate,IsAutoDoc,SessionNo,VchKind,RowNo,DocRowNo,
								AcntCode,Debit,Credit,RecDesc,RecDesc2,SourceDocType,CurrencyAmount,CurrencyTypeID,VisitorAcntCode) 
						VALUES	(@intVchNo,@intSourceProcessID,@intSourceProcessNo,@intSourceFiscalYear,@intSourceSerialNo,@strVchDate ,1,@SessionNo ,1,@intMaxRowNo ,@intMaxDocRowNo,
							@AcntCodeHdr,0,ROUND(@SumAtomAmount - (@ServiceAmount * @ServiceQuantity),@PriceDecimalsToForms),@strDescDtlRow,@strDescDtl,0 ,@CurrencyAmountTmp,@CurrencyTypeIDTmp,@VisitorAcntCode)	
 
 					end	 
 			end
			ELSE IF @SumAtomAmount < @ServiceAmount * @ServiceQuantity
			begin

				 IF @trs_ShowDtlServicePriceInCustomAccount='True'
 					begin 				  	
						
						IF @CurrencyRate <> 0 	
							SET @CurrencyAmount = ROUND((@ServiceAmount * @ServiceQuantity)-@SumAtomAmount,@PriceDecimalsToForms) / @CurrencyRate
		
						IF [acc].[funIsCurrencyAcntCode] (@AcntCodeHdr) = 'True'
						Begin
							Set @CurrencyRateTmp	= @CurrencyRate
							Set @CurrencyAmountTmp  = @CurrencyAmount
							Set @CurrencyTypeIDTmp  = @CurrencyTypeID
						End
						Else
						Begin
							Set @CurrencyRateTmp	= 0
							Set @CurrencyAmountTmp  = 0
							Set @CurrencyTypeIDTmp  = ''
						End
						SET @intMaxDocRowNo = @intMaxDocRowNo + 1
						SET @intMaxRowNo = @intMaxRowNo + 1
					    INSERT INTO acc.tblVoucherDtl
						    (SerialNo,SourceProcessID,SourceProcessNo,SourceFiscalYear,SourceSerialNo,DocDate,IsAutoDoc,SessionNo,VchKind,RowNo,DocRowNo,
 						     AcntCode,Debit,Credit,RecDesc,RecDesc2,SourceDocType,CurrencyAmount,CurrencyTypeID,VisitorAcntCode) 
 					    VALUES	(@intVchNo,@intSourceProcessID,@intSourceProcessNo,@intSourceFiscalYear,@intSourceSerialNo,@strVchDate ,1,@SessionNo ,1,@intMaxRowNo ,@intMaxDocRowNo,
 						     @AcntCodeHdr,ROUND((@ServiceAmount * @ServiceQuantity)-@SumAtomAmount,@PriceDecimalsToForms),0,@strDescDtlRow,@strDescDtl,0,@CurrencyAmountTmp,@CurrencyTypeIDTmp,@VisitorAcntCode )	 
					end	 
				IF @CurrencyRate <> 0 	
					SET @CurrencyAmount = ROUND((@ServiceAmount * @ServiceQuantity)-@SumAtomAmount,@PriceDecimalsToForms) / @CurrencyRate
		
				IF [acc].[funIsCurrencyAcntCode] (@AcntCode1) = 'True'
				Begin
					Set @CurrencyRateTmp	= @CurrencyRate
					Set @CurrencyAmountTmp  = @CurrencyAmount
					Set @CurrencyTypeIDTmp  = @CurrencyTypeID
				End
				Else
				Begin
					Set @CurrencyRateTmp	= 0
					Set @CurrencyAmountTmp  = 0
					Set @CurrencyTypeIDTmp  = ''
				End
 				SET @intMaxDocRowNo = @intMaxDocRowNo + 1
				SET @intMaxRowNo = @intMaxRowNo + 1
 				INSERT INTO acc.tblVoucherDtl
 						(SerialNo,SourceProcessID,SourceProcessNo,SourceFiscalYear,SourceSerialNo,DocDate,IsAutoDoc,SessionNo,VchKind,RowNo,DocRowNo,
 						 AcntCode,Debit,Credit,RecDesc,RecDesc2,SourceDocType,CurrencyAmount,CurrencyTypeID,VisitorAcntCode) 
 				VALUES	(@intVchNo,@intSourceProcessID,@intSourceProcessNo,@intSourceFiscalYear,@intSourceSerialNo,@strVchDate ,1,@SessionNo ,1,@intMaxRowNo ,@intMaxDocRowNo,
 						 @AcntCode1,0,ROUND((@ServiceAmount * @ServiceQuantity)-@SumAtomAmount,@PriceDecimalsToForms),@strDescDtlRow,@strDescDtl,0 ,@CurrencyAmountTmp,@CurrencyTypeIDTmp,@VisitorAcntCode)	

			end
	
 							
 			Fetch NEXT From curService Into @ServiceID,@ServiceAmount,@ServiceQuantity,@strDescDtl,@DocRowNo,@DiscountDtl
 
 		END
 
 	Close curService;
 	Deallocate curService; 	
 
 	-------- 
 
	SET @SumAmount = @SumAmount - @TaskTax 	
	
	
	IF @trs_ShowDtlServicePriceInCustomAccount='False'
 	begin
 				
		IF @CurrencyRate <> 0 	
			SET @CurrencyAmount = ROUND(@SumAmount,@PriceDecimalsToForms) / @CurrencyRate
		
		IF [acc].[funIsCurrencyAcntCode] (@AcntCodeHdr) = 'True'
		Begin
			Set @CurrencyRateTmp	= @CurrencyRate
			Set @CurrencyAmountTmp  = @CurrencyAmount
			Set @CurrencyTypeIDTmp  = @CurrencyTypeID
		End
		Else
		Begin
			Set @CurrencyRateTmp	= 0
			Set @CurrencyAmountTmp  = 0
			Set @CurrencyTypeIDTmp  = ''
		End
		SET @intMaxDocRowNo = @intMaxDocRowNo + 1
		SET @intMaxRowNo = @intMaxRowNo + 1
 	    INSERT INTO acc.tblVoucherDtl
 			    (SerialNo,SourceProcessID,SourceProcessNo,SourceFiscalYear,SourceSerialNo,DocDate,IsAutoDoc,SessionNo,VchKind,RowNo,DocRowNo,
 				    AcntCode,Debit,Credit,RecDesc,RecDesc2,SourceDocType,IsShowDetail,CurrencyAmount,CurrencyTypeID,VisitorAcntCode) 
 	    VALUES	(@intVchNo,@intSourceProcessID,@intSourceProcessNo,@intSourceFiscalYear,@intSourceSerialNo,@strVchDate ,1,@SessionNo ,1,@intMaxRowNo ,@intMaxDocRowNo,
 			     @AcntCodeHdr,ROUND(@SumAmount,@PriceDecimalsToForms),0,TS.pub.funChangeFarsiStrings(pub.funReverseForCrystal(@strRecDesc)),@strDescHdr,0,'True' ,@CurrencyAmountTmp,@CurrencyTypeIDTmp,@VisitorAcntCode)
			
 	end 		 
 			 	
 	IF @TaskTax > 0 AND @TaskTaxAcntCode <> ''
 	BEGIN
 	 	
 		SET @strRecDesc =   'مالیات تکلیفی فاکتور خدماتی '+ @ProcessName + LTRIM(RTRIM(STR(@intSourceFiscalYear))) + '/' + LTRIM(RTRIM(STR(@intSourceSerialNo))) 
	 		
		IF @CurrencyRate <> 0 	
			SET @CurrencyAmount = ROUND(@TaskTax,@PriceDecimalsToForms) / @CurrencyRate
		
		IF [acc].[funIsCurrencyAcntCode] (@TaskTaxAcntCode) = 'True'
		Begin
			Set @CurrencyRateTmp	= @CurrencyRate
			Set @CurrencyAmountTmp  = @CurrencyAmount
			Set @CurrencyTypeIDTmp  = @CurrencyTypeID
		End
		Else
		Begin
			Set @CurrencyRateTmp	= 0
			Set @CurrencyAmountTmp  = 0
			Set @CurrencyTypeIDTmp  = ''
		End		
		SET @intMaxDocRowNo = @intMaxDocRowNo + 1
		SET @intMaxRowNo = @intMaxRowNo + 1
 		INSERT INTO acc.tblVoucherDtl
 				(SerialNo,SourceProcessID,SourceProcessNo,SourceFiscalYear,SourceSerialNo,DocDate,IsAutoDoc,SessionNo,VchKind,RowNo,DocRowNo,
 					AcntCode,Debit,Credit,RecDesc,RecDesc2,SourceDocType,IsShowDetail,CurrencyAmount,CurrencyTypeID,VisitorAcntCode) 
 		VALUES	(@intVchNo,@intSourceProcessID,@intSourceProcessNo,@intSourceFiscalYear,@intSourceSerialNo,@strVchDate ,1,@SessionNo ,1,@intMaxRowNo ,@intMaxDocRowNo,
 				 @TaskTaxAcntCode,ROUND(@TaskTax,@PriceDecimalsToForms),0,TS.pub.funChangeFarsiStrings(pub.funReverseForCrystal(@strRecDesc)),@strDescHdr,0,'True' ,@CurrencyAmountTmp,@CurrencyTypeIDTmp,@VisitorAcntCode)
 	END
 	
 	IF @ServiceDiscount > 0 AND @DiscountAcntCode <> ''
 		BEGIN
 		
 			SET @strRecDesc =   'تخفیف فاکتور خدماتی '+ @ProcessName + LTRIM(RTRIM(STR(@intSourceFiscalYear))) + '/' + LTRIM(RTRIM(STR(@intSourceSerialNo))) 
 		
			SET @SumAmountVisitor = @SumAmountVisitor - @ServiceDiscount
 		
			IF @CurrencyRate <> 0 	
				SET @CurrencyAmount = ROUND(@ServiceDiscount,@PriceDecimalsToForms) / @CurrencyRate
		
			IF [acc].[funIsCurrencyAcntCode] (@DiscountAcntCode) = 'True'
			Begin
				Set @CurrencyRateTmp	= @CurrencyRate
				Set @CurrencyAmountTmp  = @CurrencyAmount
				Set @CurrencyTypeIDTmp  = @CurrencyTypeID
			End
			Else
			Begin
				Set @CurrencyRateTmp	= 0
				Set @CurrencyAmountTmp  = 0
				Set @CurrencyTypeIDTmp  = ''
			End
			SET @intMaxDocRowNo = @intMaxDocRowNo + 1
			SET @intMaxRowNo = @intMaxRowNo + 1
 			INSERT INTO acc.tblVoucherDtl
 					(SerialNo,SourceProcessID,SourceProcessNo,SourceFiscalYear,SourceSerialNo,DocDate,IsAutoDoc,SessionNo,VchKind,RowNo,DocRowNo,
 						AcntCode,Debit,Credit,RecDesc,RecDesc2,SourceDocType,CurrencyAmount,CurrencyTypeID,VisitorAcntCode) 
 			VALUES	(@intVchNo,@intSourceProcessID,@intSourceProcessNo,@intSourceFiscalYear,@intSourceSerialNo,@strVchDate ,1,@SessionNo ,1,@intMaxRowNo ,@intMaxDocRowNo,
 					 @DiscountAcntCode,ROUND(@ServiceDiscount,@PriceDecimalsToForms),0,TS.pub.funChangeFarsiStrings(pub.funReverseForCrystal(@strRecDesc)),@strDescHdr,0 ,@CurrencyAmountTmp,@CurrencyTypeIDTmp,@VisitorAcntCode )
 		 			
			IF @CurrencyRate <> 0 	
				SET @CurrencyAmount = ROUND(@ServiceDiscount,@PriceDecimalsToForms) / @CurrencyRate
		
			IF [acc].[funIsCurrencyAcntCode] (@AcntCodeHdr) = 'True'
			Begin
				Set @CurrencyRateTmp	= @CurrencyRate
				Set @CurrencyAmountTmp  = @CurrencyAmount
				Set @CurrencyTypeIDTmp  = @CurrencyTypeID
			End
			Else
			Begin
				Set @CurrencyRateTmp	= 0
				Set @CurrencyAmountTmp  = 0
				Set @CurrencyTypeIDTmp  = ''
			End
			SET @intMaxDocRowNo = @intMaxDocRowNo + 1
			SET @intMaxRowNo = @intMaxRowNo + 1
 			INSERT INTO acc.tblVoucherDtl
 					(SerialNo,SourceProcessID,SourceProcessNo,SourceFiscalYear,SourceSerialNo,DocDate,IsAutoDoc,SessionNo,VchKind,RowNo,DocRowNo,
 						AcntCode,Debit,Credit,RecDesc,RecDesc2,SourceDocType,CurrencyAmount,CurrencyTypeID,VisitorAcntCode) 
 			VALUES	(@intVchNo,@intSourceProcessID,@intSourceProcessNo,@intSourceFiscalYear,@intSourceSerialNo,@strVchDate ,1,@SessionNo ,1,@intMaxRowNo ,@intMaxDocRowNo,
 					 @AcntCodeHdr,0,ROUND(@ServiceDiscount,@PriceDecimalsToForms),TS.pub.funChangeFarsiStrings(pub.funReverseForCrystal(@strRecDesc)),@strDescHdr,0 ,@CurrencyAmountTmp,@CurrencyTypeIDTmp,@VisitorAcntCode)
 		
 		END
 
 	IF @TaxOverWorthCost <> 0 AND @TaxOverWorthAcntCode <>''
 		BEGIN 
 		
			 IF @CurrencyRate <> 0 	
				SET @CurrencyAmount = ROUND(@TaxOverWorthCost,@PriceDecimalsToForms) / @CurrencyRate
		
			IF [acc].[funIsCurrencyAcntCode] (@AcntCodeHdr) = 'True'
			Begin
				Set @CurrencyRateTmp	= @CurrencyRate
				Set @CurrencyAmountTmp  = @CurrencyAmount
				Set @CurrencyTypeIDTmp  = @CurrencyTypeID
			End
			Else
			Begin
				Set @CurrencyRateTmp	= 0
				Set @CurrencyAmountTmp  = 0
				Set @CurrencyTypeIDTmp  = ''
			End

 			SET @strRecDesc =   'مالیات بر ارزش افزوده فاکتور خدماتی ' + @ProcessName + LTRIM(RTRIM(STR(@intSourceFiscalYear))) + '/' + LTRIM(RTRIM(STR(@intSourceSerialNo))) 
 		
 			SET @intMaxDocRowNo = @intMaxDocRowNo + 1
 			SET @intMaxRowNo = @intMaxRowNo + 1
 
 			INSERT INTO acc.tblVoucherDtl
 					(SerialNo,SourceProcessID,SourceProcessNo,SourceFiscalYear,SourceSerialNo,DocDate,IsAutoDoc,SessionNo,VchKind,RowNo,DocRowNo,
 						AcntCode,Debit,Credit,RecDesc,RecDesc2,SourceDocType,CurrencyAmount,CurrencyTypeID,VisitorAcntCode) 
 			VALUES	(@intVchNo,@intSourceProcessID,@intSourceProcessNo,@intSourceFiscalYear,@intSourceSerialNo,@strVchDate ,1,@SessionNo ,1,@intMaxRowNo ,@intMaxDocRowNo,
 					 @AcntCodeHdr,ROUND(@TaxOverWorthCost,@PriceDecimalsToForms),0,TS.pub.funChangeFarsiStrings(pub.funReverseForCrystal(@strRecDesc)),@strDescHdr,0,@CurrencyAmountTmp,@CurrencyTypeIDTmp ,@VisitorAcntCode)
 		
 			
 			 IF @CurrencyRate <> 0 	
					SET @CurrencyAmount = ROUND(@TaxOverWorthCost,@PriceDecimalsToForms) / @CurrencyRate
		
			IF [acc].[funIsCurrencyAcntCode] (@TaxOverWorthAcntCode) = 'True'
			Begin
				Set @CurrencyRateTmp	= @CurrencyRate
				Set @CurrencyAmountTmp  = @CurrencyAmount
				Set @CurrencyTypeIDTmp  = @CurrencyTypeID
			End
			Else
			Begin
				Set @CurrencyRateTmp	= 0
				Set @CurrencyAmountTmp  = 0
				Set @CurrencyTypeIDTmp  = ''
			End
			SET @intMaxDocRowNo = @intMaxDocRowNo + 1
 			SET @intMaxRowNo = @intMaxRowNo + 1
 			INSERT INTO acc.tblVoucherDtl
 					(SerialNo,SourceProcessID,SourceProcessNo,SourceFiscalYear,SourceSerialNo,DocDate,IsAutoDoc,SessionNo,VchKind,RowNo,DocRowNo,
 						AcntCode,Debit,Credit,RecDesc,RecDesc2,SourceDocType,CurrencyAmount,CurrencyTypeID,VisitorAcntCode) 
 			VALUES	(@intVchNo,@intSourceProcessID,@intSourceProcessNo,@intSourceFiscalYear,@intSourceSerialNo,@strVchDate ,1,@SessionNo ,1,@intMaxRowNo ,@intMaxDocRowNo,
 					 @TaxOverWorthAcntCode,0,ROUND(@TaxOverWorthCost,@PriceDecimalsToForms),TS.pub.funChangeFarsiStrings(pub.funReverseForCrystal(@strRecDesc)),@strDescHdr,0,@CurrencyAmountTmp,@CurrencyTypeIDTmp ,@VisitorAcntCode)
 		
 		END
 
 	IF @TollOverWorthCost <> 0 AND @TollOverWorthAcntCode <>''
 		BEGIN 
 		
			IF @CurrencyRate <> 0 	
				SET @CurrencyAmount = ROUND(@TollOverWorthCost,@PriceDecimalsToForms) / @CurrencyRate
		
			IF [acc].[funIsCurrencyAcntCode] (@AcntCodeHdr) = 'True'
			Begin
				Set @CurrencyRateTmp	= @CurrencyRate
				Set @CurrencyAmountTmp  = @CurrencyAmount
				Set @CurrencyTypeIDTmp  = @CurrencyTypeID
			End
			Else
			Begin
				Set @CurrencyRateTmp	= 0
				Set @CurrencyAmountTmp  = 0
				Set @CurrencyTypeIDTmp  = ''
			End
 			SET @strRecDesc =   'عوارض بر ارزش افزوده فاکتور خدماتی ' + @ProcessName + LTRIM(RTRIM(STR(@intSourceFiscalYear))) + '/' + LTRIM(RTRIM(STR(@intSourceSerialNo))) 
 		
 			SET @intMaxDocRowNo = @intMaxDocRowNo + 1
 			SET @intMaxRowNo = @intMaxRowNo + 1
 
 			INSERT INTO acc.tblVoucherDtl
 					(SerialNo,SourceProcessID,SourceProcessNo,SourceFiscalYear,SourceSerialNo,DocDate,IsAutoDoc,SessionNo,VchKind,RowNo,DocRowNo,
 						AcntCode,Debit,Credit,RecDesc,RecDesc2,SourceDocType,CurrencyAmount,CurrencyTypeID,VisitorAcntCode) 
 			VALUES	(@intVchNo,@intSourceProcessID,@intSourceProcessNo,@intSourceFiscalYear,@intSourceSerialNo,@strVchDate ,1,@SessionNo ,1,@intMaxRowNo ,@intMaxDocRowNo,
 					 @AcntCodeHdr,@TollOverWorthCost,0,TS.pub.funChangeFarsiStrings(pub.funReverseForCrystal(@strRecDesc)),@strDescHdr,0,@CurrencyAmountTmp,@CurrencyTypeIDTmp ,@VisitorAcntCode)
 		
 			
 
			IF @CurrencyRate <> 0 	
				SET @CurrencyAmount = ROUND(@TollOverWorthCost,@PriceDecimalsToForms) / @CurrencyRate
		
			IF [acc].[funIsCurrencyAcntCode] (@TollOverWorthAcntCode) = 'True'
			Begin
				Set @CurrencyRateTmp	= @CurrencyRate
				Set @CurrencyAmountTmp  = @CurrencyAmount
				Set @CurrencyTypeIDTmp  = @CurrencyTypeID
			End
			Else
			Begin
				Set @CurrencyRateTmp	= 0
				Set @CurrencyAmountTmp  = 0
				Set @CurrencyTypeIDTmp  = ''
			End
			SET @intMaxDocRowNo = @intMaxDocRowNo + 1
 			SET @intMaxRowNo = @intMaxRowNo + 1
 			INSERT INTO acc.tblVoucherDtl
 					(SerialNo,SourceProcessID,SourceProcessNo,SourceFiscalYear,SourceSerialNo,DocDate,IsAutoDoc,SessionNo,VchKind,RowNo,DocRowNo,
 						AcntCode,Debit,Credit,RecDesc,RecDesc2,SourceDocType,CurrencyAmount,CurrencyTypeID,VisitorAcntCode) 
 			VALUES	(@intVchNo,@intSourceProcessID,@intSourceProcessNo,@intSourceFiscalYear,@intSourceSerialNo,@strVchDate ,1,@SessionNo ,1,@intMaxRowNo ,@intMaxDocRowNo,
 					 @TollOverWorthAcntCode,0,ROUND(@TollOverWorthCost,@PriceDecimalsToForms),TS.pub.funChangeFarsiStrings(pub.funReverseForCrystal(@strRecDesc)),@strDescHdr,0,@CurrencyAmountTmp,@CurrencyTypeIDTmp,@VisitorAcntCode)
 		
 		END

		----------------------------------------------- بازاریاب --------------------------------------------
		IF @VisitorAcntCode	<> '' AND @VisitorCostAcntCode	<> '' AND @VisitorPercent <> 0 
			BEGIN

				SET @VisitorCost = (@SumAmountVisitor * @VisitorPercent) / 100

				----------------------------------------------------------------------------------------------------------
				DECLARE @strRecDescVisitor VARCHAR(1000) 
				SET @strRecDescVisitor = ' هزینه بازاریاب خدمات '  + @ProcessName + LTRIM(RTRIM(STR(@intSourceFiscalYear))) + '/' + LTRIM(RTRIM(STR(@intSourceSerialNo)))
				
				

				IF @CurrencyRate <> 0 	
					SET @CurrencyAmount = ROUND(@VisitorCost,@PriceDecimalsToForms) / @CurrencyRate
		
				IF [acc].[funIsCurrencyAcntCode] (@VisitorCostAcntCode) = 'True'
				Begin
					Set @CurrencyRateTmp	= @CurrencyRate
					Set @CurrencyAmountTmp  = @CurrencyAmount
					Set @CurrencyTypeIDTmp  = @CurrencyTypeID
				End
				Else
				Begin
					Set @CurrencyRateTmp	= 0
					Set @CurrencyAmountTmp  = 0
					Set @CurrencyTypeIDTmp  = ''
				End
				SET @intMaxDocRowNo = @intMaxDocRowNo + 1
				SET @intMaxRowNo = @intMaxRowNo + 1
				INSERT INTO acc.tblVoucherDtl
						(SerialNo,SourceProcessID,SourceProcessNo,SourceFiscalYear,SourceSerialNo,DocDate,IsAutoDoc,SessionNo,VchKind,RowNo,DocRowNo,
							AcntCode,Debit,Credit,RecDesc,RecDesc2,SourceDocType,CurrencyAmount,CurrencyTypeID,VisitorAcntCode) 
				VALUES	(@intVchNo,@intSourceProcessID,@intSourceProcessNo,@intSourceFiscalYear,@intSourceSerialNo,@strVchDate ,1,@SessionNo ,1,@intMaxRowNo ,@intMaxDocRowNo,
							@VisitorCostAcntCode,ROUND(@VisitorCost,0) ,0 ,TS.pub.funChangeFarsiStrings(pub.funReverseForCrystal(@strRecDescVisitor)),'',0,@CurrencyAmountTmp,@CurrencyTypeIDTmp,@VisitorAcntCode)
							
				--------------------------------------------------------------------------------------------------------

				IF @CurrencyRate <> 0 	
						SET @CurrencyAmount = ROUND(@VisitorCost,@PriceDecimalsToForms) / @CurrencyRate
		
				IF [acc].[funIsCurrencyAcntCode] (@VisitorCostAcntCode) = 'True'
				Begin
					Set @CurrencyRateTmp	= @CurrencyRate
					Set @CurrencyAmountTmp  = @CurrencyAmount
					Set @CurrencyTypeIDTmp  = @CurrencyTypeID
				End
				Else
				Begin
					Set @CurrencyRateTmp	= 0
					Set @CurrencyAmountTmp  = 0
					Set @CurrencyTypeIDTmp  = ''
				End
				SET @intMaxDocRowNo = @intMaxDocRowNo + 1
				SET @intMaxRowNo = @intMaxRowNo + 1
				INSERT INTO acc.tblVoucherDtl
						(SerialNo,SourceProcessID,SourceProcessNo,SourceFiscalYear,SourceSerialNo,DocDate,IsAutoDoc,SessionNo,VchKind,RowNo,DocRowNo,
							AcntCode,Debit,Credit,RecDesc,RecDesc2,SourceDocType,CurrencyAmount,CurrencyTypeID,VisitorAcntCode) 
				VALUES	(@intVchNo,@intSourceProcessID,@intSourceProcessNo,@intSourceFiscalYear,@intSourceSerialNo,@strVchDate ,1,@SessionNo ,1,@intMaxRowNo ,@intMaxDocRowNo,
							@VisitorAcntCode,0,ROUND(@VisitorCost,0),TS.pub.funChangeFarsiStrings(pub.funReverseForCrystal(@strRecDescVisitor)),'',0,@CurrencyAmountTmp,@CurrencyTypeIDTmp,@VisitorAcntCode)

			END
 END
 
GO
