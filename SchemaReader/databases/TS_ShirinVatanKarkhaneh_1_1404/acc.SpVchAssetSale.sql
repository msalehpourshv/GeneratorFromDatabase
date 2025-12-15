USE TS_ShirinVatanKarkhaneh_1_1404
GO
SET ANSI_NULLS, QUOTED_IDENTIFIER ON
GO
-- =========== TS-QC:NOTOK ========================
-- Author        : Hadi Sadeghi
-- Create date   : 89/12/27
-- Viewed By	 : 
-- Last Modified : 
-- Description   : 
-- =============================================
CREATE PROCEDURE [acc].[SpVchAssetSale]
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
	Declare @strMsgText			NVarChar(2044)
	Declare @AssetAcntCode		Varchar(20)
	Declare @ObverseAcntCode	Varchar(20)
	Declare @OtherCostAcntCode	Varchar(20)
	Declare @OtherIncomeAcntCode Varchar(20)
	Declare @AstGroupID			Varchar(20)
	Declare @DepreciationAcntCode Varchar(20)
	Declare @IncomeInSale		Varchar(20)
	Declare @CostInSale			Varchar(20)
	Declare @SaleTaxOverWorthAcntCode Varchar(20)
	Declare @SaleTollOverWorthAcntCode Varchar(20)
	
	Declare @CostAmount			Float
	Declare @OtherCosts			Float
	Declare @OtherCost			Float
	Declare @OtherIncome		Float
	Declare @SumCostAmount		Float
	Declare @DepreciationAmount Float
	Declare @TaxOverWorthCost	Float
	Declare @TollOverWorthCost	Float
	
	Declare @AssetTitle			NVarChar(1000)
	Declare @AssetPlaque		NVarChar(1000)
	Declare @strRecDesc			NVarChar(1000)
	Declare @strRecDesc2		NVarChar(1000)
	Declare	@intTmpMaxRowNo		Int
	Declare	@intTmpMaxDocRowNo	Int
	DECLARE @EventNo			Int
	
	DECLARE @AssetTaxOverWorthView BIT
	-----
	SET @SumCostAmount = 0
	SET @intMaxDocRowNo = @intMaxDocRowNo + 1
	SET @intMaxRowNo = @intMaxRowNo + 1

	SET @intTmpMaxDocRowNo = @intMaxDocRowNo
	SET @intTmpMaxRowNo = @intMaxRowNo

	SELECT @AssetTaxOverWorthView = SettingValue
	FROM pub.tblSettings
	WHERE SettingKey = 'AssetTaxOverWorthView' 
	
	--------------------------------------------------------------------------------------------------------
	SELECT	@ObverseAcntCode=ObverseAcntCode,@OtherCostAcntCode=OtherCostAcntCode,
			@OtherIncomeAcntCode=OtherIncomeAcntCode,@OtherCost=OtherCost,@OtherIncome=OtherIncome,
			@TaxOverWorthCost=TaxOverWorthCost,@TollOverWorthCost=TollOverWorthCost
	FROM ast.tblAssetsHdr
	WHERE ProcessID=@intSourceProcessID AND
		  ProcessNo=@intSourceProcessNo AND
		  FiscalYear=@intSourceFiscalYear AND
		  SerialNo=@intSourceSerialNo 
	
	SELECT @SaleTaxOverWorthAcntCode = SettingValue
	FROM   pub.tblSettings
	WHERE SettingKey = 'saleTaxOverWorthAcntCode_Asset' 
		
	SELECT @SaleTollOverWorthAcntCode = SettingValue
	FROM   pub.tblSettings
	WHERE SettingKey = 'saleTollOverWorthAcntCode_Asset' 
	
	IF @SaleTaxOverWorthAcntCode='' AND @TaxOverWorthCost <>0
		BEGIN
			--کد مالیات بر ارزش افزوده در فروش خالی است
			SET @strMsgText=TS.pub.funGetMessages(11039,@LanguageID)
			Raiserror (@strMsgText,16,1)
			Return
		END

	IF @SaleTollOverWorthAcntCode='' AND @TollOverWorthCost <>0
		BEGIN
			--کد عوارض بر ارزش افزوده در فروش خالی است
			SET @strMsgText=TS.pub.funGetMessages(11043,@LanguageID)
			Raiserror (@strMsgText,16,1)
			Return
		END		
		
	------------------------
	IF @OtherCostAcntCode <> '' AND @OtherCost <> 0
		BEGIN
			SET @intMaxDocRowNo = @intMaxDocRowNo + 1
			SET @intMaxRowNo = @intMaxRowNo + 1

			SET @strRecDesc2 = ' فروش دارایی ' + LTRIM(RTRIM(STR(@intSourceFiscalYear))) + '/' + LTRIM(RTRIM(STR(@intSourceSerialNo))) + ' سایر هزینه ها'

			INSERT INTO acc.tblVoucherDtl
					(SerialNo,SourceProcessID,SourceProcessNo,SourceFiscalYear,SourceSerialNo,DocDate,IsAutoDoc,SessionNo,VchKind,RowNo,DocRowNo,
						AcntCode,Debit,Credit,RecDesc,RecDesc2,SourceDocType) 
			VALUES	(@intVchNo,@intSourceProcessID,@intSourceProcessNo,@intSourceFiscalYear,@intSourceSerialNo,@strVchDate ,1,@SessionNo ,1,@intMaxRowNo ,@intMaxDocRowNo,
					 @OtherCostAcntCode,@OtherCost,0,TS.pub.funChangeFarsiStrings(pub.funReverseForCrystal(@strRecDesc2)),'' ,0)

		END

	------------------------
	IF @OtherIncomeAcntCode <> '' AND @OtherIncome <> 0
		BEGIN
			SET @intMaxDocRowNo = @intMaxDocRowNo + 1
			SET @intMaxRowNo = @intMaxRowNo + 1

			SET @strRecDesc2 = ' فروش دارایی ' + LTRIM(RTRIM(STR(@intSourceFiscalYear))) + '/' + LTRIM(RTRIM(STR(@intSourceSerialNo))) + ' سایر درآمدها'
			
			INSERT INTO acc.tblVoucherDtl
					(SerialNo,SourceProcessID,SourceProcessNo,SourceFiscalYear,SourceSerialNo,DocDate,IsAutoDoc,SessionNo,VchKind,RowNo,DocRowNo,
					 AcntCode,Debit,Credit,RecDesc,RecDesc2,SourceDocType) 
			VALUES	(@intVchNo,@intSourceProcessID,@intSourceProcessNo,@intSourceFiscalYear,@intSourceSerialNo,@strVchDate ,1,@SessionNo ,1,@intMaxRowNo ,@intMaxDocRowNo,
					 @OtherIncomeAcntCode,0,@OtherIncome,TS.pub.funChangeFarsiStrings(pub.funReverseForCrystal(@strRecDesc2)),'',0 )	
		END
		
	------------------------
	SET @strRecDesc2 = ' فروش دارایی ' + LTRIM(RTRIM(STR(@intSourceFiscalYear))) + '/' + LTRIM(RTRIM(STR(@intSourceSerialNo))) 

	IF @AssetTaxOverWorthView = 'False'
		SET @OtherIncome = @OtherIncome + @TaxOverWorthCost + @TollOverWorthCost
	IF @OtherIncome > @OtherCost
		BEGIN
			SET @intMaxDocRowNo = @intMaxDocRowNo + 1
			SET @intMaxRowNo = @intMaxRowNo + 1

			INSERT INTO acc.tblVoucherDtl
					(SerialNo,SourceProcessID,SourceProcessNo,SourceFiscalYear,SourceSerialNo,DocDate,IsAutoDoc,SessionNo,VchKind,RowNo,DocRowNo,
					 AcntCode,Debit,Credit,RecDesc,RecDesc2,SourceDocType) 
			VALUES	(@intVchNo,@intSourceProcessID,@intSourceProcessNo,@intSourceFiscalYear,@intSourceSerialNo,@strVchDate ,1,@SessionNo ,1,@intMaxRowNo ,@intMaxDocRowNo,
					 @ObverseAcntCode,@OtherIncome - @OtherCost,0,TS.pub.funChangeFarsiStrings(pub.funReverseForCrystal(@strRecDesc2)),'',0 )	

		END
		
	------------------------
	ELSE IF @OtherIncome < @OtherCost
		BEGIN
			SET @intMaxDocRowNo = @intMaxDocRowNo + 1
			SET @intMaxRowNo = @intMaxRowNo + 1

			INSERT INTO acc.tblVoucherDtl
					(SerialNo,SourceProcessID,SourceProcessNo,SourceFiscalYear,SourceSerialNo,DocDate,IsAutoDoc,SessionNo,VchKind,RowNo,DocRowNo,
					 AcntCode,Debit,Credit,RecDesc,RecDesc2,SourceDocType) 
			VALUES	(@intVchNo,@intSourceProcessID,@intSourceProcessNo,@intSourceFiscalYear,@intSourceSerialNo,@strVchDate ,1,@SessionNo ,1,@intMaxRowNo ,@intMaxDocRowNo,
					 @ObverseAcntCode,0,@OtherCost - @OtherIncome,TS.pub.funChangeFarsiStrings(pub.funReverseForCrystal(@strRecDesc2)),'',0 )	

		END		
--------------------------------------------------------------------------------------------------------

	Declare	curSale CURSOR For 
	SELECT	OtherCosts,AssetTitle,AssetPlaque,AstGroupID,EventNo
	FROM ast.tblAssetsDtl 
	WHERE ProcessID=@intSourceProcessID AND
		  ProcessNo=@intSourceProcessNo AND
		  FiscalYear=@intSourceFiscalYear AND
		  SerialNo=@intSourceSerialNo 

	----- سطر به سطر به حساب مشتری میرود
	Open  curSale; 

	Fetch NEXT From curSale Into @OtherCosts,@AssetTitle,@AssetPlaque,@AstGroupID,@EventNo

	While (@@Fetch_Status = 0)
		BEGIN
					
				SELECT TOP 1 @DepreciationAcntCode=DepreciationAcntCode,@DepreciationAmount=DepreciationAmount,
							 @AssetAcntCode=AssetAcntCode,@CostAmount=CostAmount
				FROM  ast.tblAssetsDtl			 
				WHERE AssetPlaque = @AssetPlaque AND(DocDate< @strVchDate OR (DocDate= @strVchDate AND EventNo < @EventNo))
				ORDER BY DocDate Desc,EventNo Desc
				
				IF @DepreciationAcntCode = ''
					SELECT @DepreciationAcntCode = DepreciationAcntCode 
					FROM ast.tblAstGroups
					WHERE AstGroupID = @AstGroupID	
				
					Declare @Ast_MargeAcntCodeWithAssetAcntCode as bit

				Select @Ast_MargeAcntCodeWithAssetAcntCode=SettingValue From pub.tblSettings
				where SettingKey='Ast_MargeAcntCodeWithAssetAcntCode'

				if @Ast_MargeAcntCodeWithAssetAcntCode=1
				 select @DepreciationAcntCode=acc.funMergAcntCode(@DepreciationAcntCode,@AssetAcntCode)
			
			
				SET @strRecDesc = ' فروش دارایی ' + LTRIM(RTRIM(STR(@intSourceFiscalYear))) + '/' + LTRIM(RTRIM(STR(@intSourceSerialNo)))  + ' - ' + @AssetTitle + ' - به شماره پلاک  ' + @AssetPlaque
				
				SET @intMaxDocRowNo = @intMaxDocRowNo + 1
				SET @intMaxRowNo = @intMaxRowNo + 1
	
				INSERT INTO acc.tblVoucherDtl
						(SerialNo,SourceProcessID,SourceProcessNo,SourceFiscalYear,SourceSerialNo,DocDate,IsAutoDoc,SessionNo,VchKind,RowNo,DocRowNo,
						 AcntCode,Debit,Credit,RecDesc,RecDesc2,SourceDocType) 
				VALUES	(@intVchNo,@intSourceProcessID,@intSourceProcessNo,@intSourceFiscalYear,@intSourceSerialNo,@strVchDate ,1,@SessionNo ,1,@intMaxRowNo ,@intMaxDocRowNo,
						 @ObverseAcntCode,@OtherCosts,0,TS.pub.funChangeFarsiStrings(pub.funReverseForCrystal(@strRecDesc)),'',0 )	

				IF @DepreciationAmount>0 and @DepreciationAcntCode=''
					BEGIN
						--کد مالیات بر ارزش افزوده در فروش خالی است
						SET @strMsgText=TS.pub.funGetMessages(11039,@LanguageID)
						Raiserror (@strMsgText,16,1)
						Return
					END
					
				IF @DepreciationAmount>0
				BEGIN
					SET @intMaxDocRowNo = @intMaxDocRowNo + 1
					SET @intMaxRowNo = @intMaxRowNo + 1
		
					INSERT INTO acc.tblVoucherDtl
							(SerialNo,SourceProcessID,SourceProcessNo,SourceFiscalYear,SourceSerialNo,DocDate,IsAutoDoc,SessionNo,VchKind,RowNo,DocRowNo,
							 AcntCode,Debit,Credit,RecDesc,RecDesc2,SourceDocType) 
					VALUES	(@intVchNo,@intSourceProcessID,@intSourceProcessNo,@intSourceFiscalYear,@intSourceSerialNo,@strVchDate ,1,@SessionNo ,1,@intMaxRowNo ,@intMaxDocRowNo,
							 @DepreciationAcntCode,@DepreciationAmount,0,TS.pub.funChangeFarsiStrings(pub.funReverseForCrystal(@strRecDesc)),'',0 )	
				END
							
				---------
				SET @intMaxDocRowNo = @intMaxDocRowNo + 1
				SET @intMaxRowNo = @intMaxRowNo + 1
	
				INSERT INTO acc.tblVoucherDtl
						(SerialNo,SourceProcessID,SourceProcessNo,SourceFiscalYear,SourceSerialNo,DocDate,IsAutoDoc,SessionNo,VchKind,RowNo,DocRowNo,
						 AcntCode,Debit,Credit,RecDesc,RecDesc2,SourceDocType) 
				VALUES	(@intVchNo,@intSourceProcessID,@intSourceProcessNo,@intSourceFiscalYear,@intSourceSerialNo,@strVchDate ,1,@SessionNo ,1,@intMaxRowNo ,@intMaxDocRowNo,
						 @AssetAcntCode,0,@CostAmount,TS.pub.funChangeFarsiStrings(pub.funReverseForCrystal(@strRecDesc)),'',0 )	

				---------
				SET @intMaxDocRowNo = @intMaxDocRowNo + 1
				SET @intMaxRowNo = @intMaxRowNo + 1

				IF @OtherCosts + @DepreciationAmount- @CostAmount >0
					BEGIN
						SET @IncomeInSale = ''
						
						SELECT @IncomeInSale = IncomeInSale 
						FROM ast.tblAstGroups
						WHERE AstGroupID = @AstGroupID
						
						IF @IncomeInSale=''
							BEGIN
								Close curSale;
								Deallocate curSale; 
								--کد حسابداری درآمد حاصل از فروش در گروه دارائی %s خالی است
								SET @strMsgText=TS.pub.funGetMessages(19008,@LanguageID)
								Raiserror (@strMsgText,16,1,@AstGroupID)
								Return
							END
							
						INSERT INTO acc.tblVoucherDtl
								(SerialNo,SourceProcessID,SourceProcessNo,SourceFiscalYear,SourceSerialNo,DocDate,IsAutoDoc,SessionNo,VchKind,RowNo,DocRowNo,
								 AcntCode,Debit,Credit,RecDesc,RecDesc2,SourceDocType) 
						VALUES	(@intVchNo,@intSourceProcessID,@intSourceProcessNo,@intSourceFiscalYear,@intSourceSerialNo,@strVchDate ,1,@SessionNo ,1,@intMaxRowNo ,@intMaxDocRowNo,
								 @IncomeInSale,0,@OtherCosts + @DepreciationAmount- @CostAmount,TS.pub.funChangeFarsiStrings(pub.funReverseForCrystal(@strRecDesc)),'',0 )	
					END

				ELSE

					BEGIN
						
						SET @CostInSale = ''
						
						SELECT @CostInSale = CostInSale 
						FROM ast.tblAstGroups
						WHERE AstGroupID = @AstGroupID
						
						IF @CostInSale=''
							BEGIN
								Close curSale;
								Deallocate curSale; 
								--کد حسابداری هزینه حاصل از فروش در گروه دارائی %s خالی است
								SET @strMsgText=TS.pub.funGetMessages(19009,@LanguageID)
								Raiserror (@strMsgText,16,1,@AstGroupID)
								Return
							END
							
						INSERT INTO acc.tblVoucherDtl
								(SerialNo,SourceProcessID,SourceProcessNo,SourceFiscalYear,SourceSerialNo,DocDate,IsAutoDoc,SessionNo,VchKind,RowNo,DocRowNo,
								 AcntCode,Debit,Credit,RecDesc,RecDesc2,SourceDocType) 
						VALUES	(@intVchNo,@intSourceProcessID,@intSourceProcessNo,@intSourceFiscalYear,@intSourceSerialNo,@strVchDate ,1,@SessionNo ,1,@intMaxRowNo ,@intMaxDocRowNo,
								 @CostInSale,@CostAmount-(@OtherCosts + @DepreciationAmount),0 ,TS.pub.funChangeFarsiStrings(pub.funReverseForCrystal(@strRecDesc)),'',0 )	
					END
	
			Fetch NEXT From curSale Into @OtherCosts,@AssetTitle,@AssetPlaque,@AstGroupID,@EventNo
			
		END

	Close curSale;
	Deallocate curSale; 

	-----------------------------------------------مالیات بر ارزش افزوده--------------------------------------------
	IF @SaleTaxOverWorthAcntCode <> '' AND @TaxOverWorthCost <> 0
		BEGIN
			--------------------------------------------------------------------------------------------------------
			DECLARE @strRecDescTaxOverWorth VARCHAR(1000) 
			SET @strRecDescTaxOverWorth = ' مالیات بر ارزش افزوده فروش دارایی ' 
			
			SET @intMaxDocRowNo = @intMaxDocRowNo + 1
			SET @intMaxRowNo = @intMaxRowNo + 1

			IF @AssetTaxOverWorthView = 'True'
				INSERT INTO acc.tblVoucherDtl
						(SerialNo,SourceProcessID,SourceProcessNo,SourceFiscalYear,SourceSerialNo,DocDate,IsAutoDoc,SessionNo,VchKind,RowNo,DocRowNo,
							AcntCode,Debit,Credit,RecDesc,RecDesc2,SourceDocType,CurrencyAmount,CurrencyTypeID) 
				VALUES	(@intVchNo,@intSourceProcessID,@intSourceProcessNo,@intSourceFiscalYear,@intSourceSerialNo,@strVchDate ,1,@SessionNo ,1,@intMaxRowNo ,@intMaxDocRowNo,
							@ObverseAcntCode,ROUND(@TaxOverWorthCost,0) ,0 ,TS.pub.funChangeFarsiStrings(pub.funReverseForCrystal(@strRecDescTaxOverWorth)),'',0,0,'')
		
			--------------------------------------------------------------------------------------------------------
			SET @intMaxDocRowNo = @intMaxDocRowNo + 1
			SET @intMaxRowNo = @intMaxRowNo + 1

			INSERT INTO acc.tblVoucherDtl
					(SerialNo,SourceProcessID,SourceProcessNo,SourceFiscalYear,SourceSerialNo,DocDate,IsAutoDoc,SessionNo,VchKind,RowNo,DocRowNo,
						AcntCode,Debit,Credit,RecDesc,RecDesc2,SourceDocType,CurrencyAmount,CurrencyTypeID) 
			VALUES	(@intVchNo,@intSourceProcessID,@intSourceProcessNo,@intSourceFiscalYear,@intSourceSerialNo,@strVchDate ,1,@SessionNo ,1,@intMaxRowNo ,@intMaxDocRowNo,
						@SaleTaxOverWorthAcntCode,0,ROUND(@TaxOverWorthCost,0),TS.pub.funChangeFarsiStrings(pub.funReverseForCrystal(@strRecDescTaxOverWorth)),'',0,0,'')
		END

	-----------------------------------------------عوارض بر ارزش افزوده--------------------------------------------
	IF @SaleTollOverWorthAcntCode <> '' AND @TollOverWorthCost <> 0
		BEGIN
			--------------------------------------------------------------------------------------------------------
			DECLARE @strRecDescTollOverWorth VARCHAR(1000) 
			SET @strRecDescTollOverWorth = ' عوارض بر ارزش افزوده فروش دارایی ' 
			
			SET @intMaxDocRowNo = @intMaxDocRowNo + 1
			SET @intMaxRowNo = @intMaxRowNo + 1

			IF @AssetTaxOverWorthView = 'True'
				INSERT INTO acc.tblVoucherDtl
						(SerialNo,SourceProcessID,SourceProcessNo,SourceFiscalYear,SourceSerialNo,DocDate,IsAutoDoc,SessionNo,VchKind,RowNo,DocRowNo,
							AcntCode,Debit,Credit,RecDesc,RecDesc2,SourceDocType,CurrencyAmount,CurrencyTypeID) 
				VALUES	(@intVchNo,@intSourceProcessID,@intSourceProcessNo,@intSourceFiscalYear,@intSourceSerialNo,@strVchDate ,1,@SessionNo ,1,@intMaxRowNo ,@intMaxDocRowNo,
							@ObverseAcntCode,ROUND(@TollOverWorthCost,0) ,0 ,TS.pub.funChangeFarsiStrings(pub.funReverseForCrystal(@strRecDescTollOverWorth)),'',0,0,'')
		
			--------------------------------------------------------------------------------------------------------
			SET @intMaxDocRowNo = @intMaxDocRowNo + 1
			SET @intMaxRowNo = @intMaxRowNo + 1

			INSERT INTO acc.tblVoucherDtl
					(SerialNo,SourceProcessID,SourceProcessNo,SourceFiscalYear,SourceSerialNo,DocDate,IsAutoDoc,SessionNo,VchKind,RowNo,DocRowNo,
						AcntCode,Debit,Credit,RecDesc,RecDesc2,SourceDocType,CurrencyAmount) 
			VALUES	(@intVchNo,@intSourceProcessID,@intSourceProcessNo,@intSourceFiscalYear,@intSourceSerialNo,@strVchDate ,1,@SessionNo ,1,@intMaxRowNo ,@intMaxDocRowNo,
						@SaleTollOverWorthAcntCode,0,ROUND(@TollOverWorthCost,0),TS.pub.funChangeFarsiStrings(pub.funReverseForCrystal(@strRecDescTollOverWorth)),'',0,0)
		END
				
END
GO
