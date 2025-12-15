USE TS_ShirinVatanKarkhaneh_1_1404
GO
SET ANSI_NULLS, QUOTED_IDENTIFIER ON
GO
-- =========== TS-QC:NOTOK ========================
-- Author        : Hadi Sadeghi
-- Create date   : 87/10/03
-- Viewed By	 : jafari
-- Last Modified : 93/11/15 
-- Description   : 
-- =============================================
Create PROCEDURE [acc].[SpVchAssetPrimary]
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
    Declare @SetupAmountAcntCode		Varchar(20)
    Declare @OtherCostsAcntCode		Varchar(20)

	Declare @ObverseAcntCode	Varchar(20)
	Declare @AstGroupID			Varchar(20)
	Declare @DepreciationAcntCode Varchar(20)
	
	Declare @CostAmount			Float
	Declare @SetupAmount		Float
	Declare @OtherCosts			Float
	
	Declare @SumCostAmount		Float
	Declare @SumDepreciationAmount		Float
	Declare @DepreciationAmount Float
	
	Declare @AssetTitle			NVarChar(1000)
	Declare @GoodsUnit			NVarChar(1000)
	Declare @AssetPlaque		NVarChar(1000)
	Declare @strRecDesc2		NVarChar(1000)
	Declare @Ast_MargeAcntCodeWithAssetAcntCode as bit
	
	-----
	SET @SumCostAmount = 0
	SET @SumDepreciationAmount = 0

--------------------------------------------------------------------------------------------------------
	Declare @OtherAcntCode_Asset		Varchar(20)

select @OtherAcntCode_Asset=SettingValue from pub.tblSettings
where SettingKey='OtherAcntCode_Asset'

	IF @OtherAcntCode_Asset = 'True' 
	begin
	
	   
	
	Declare	curSale CURSOR For 
	SELECT	AssetAcntCode,CostAmount-SetupAmount- OtherCosts ,AssetTitle,pub.funGetGoodsUnitName(GoodsID,@LanguageID) AS GoodsUnit,AssetPlaque,AstGroupID,DepreciationAmount,   SetupAmount, OtherCosts,SetupAmountAcntCode,OtherCostsAcntCode		
	FROM ast.tblAssetsDtl
	WHERE ProcessID=@intSourceProcessID AND
		  ProcessNo=@intSourceProcessNo AND
		  FiscalYear=@intSourceFiscalYear AND
		  SerialNo=@intSourceSerialNo 

	----- سطر به سطر به حساب مشتری میرود
	Open  curSale; 

	Fetch NEXT From curSale Into @AssetAcntCode,@CostAmount,@AssetTitle,@GoodsUnit,@AssetPlaque,@AstGroupID,@DepreciationAmount,   @SetupAmount, @OtherCosts,@SetupAmountAcntCode,@OtherCostsAcntCode

	While (@@Fetch_Status = 0)
		BEGIN
			IF @CostAmount <> 0
				BEGIN
					
					SELECT @DepreciationAcntCode = DepreciationAcntCode 
					FROM ast.tblAstGroups
					WHERE AstGroupID = @AstGroupID						
			
					IF @DepreciationAcntCode=''
						BEGIN
							Close curSale;
							Deallocate curSale; 
							--کد حسابداری استهلاک انباشته در گروه دارائی %s خالی است
							SET @strMsgText=TS.pub.funGetMessages(19007,@LanguageID)
							Raiserror (@strMsgText,16,1,@AstGroupID)
							Return
						END
					
				SET @Ast_MargeAcntCodeWithAssetAcntCode = 'False'

				Select @Ast_MargeAcntCodeWithAssetAcntCode=SettingValue From pub.tblSettings
				where SettingKey='Ast_MargeAcntCodeWithAssetAcntCode'

				if @Ast_MargeAcntCodeWithAssetAcntCode=1
				 select @DepreciationAcntCode=acc.funMergAcntCode(@DepreciationAcntCode,@AssetAcntCode)
			

					SET @strRecDesc2 = ' استقرار اول دوره دارایی هزینه خرید ' + LTRIM(RTRIM(STR(@intSourceFiscalYear))) + '/' + LTRIM(RTRIM(STR(@intSourceSerialNo)))  + ' - ' + @AssetTitle + ' - به شماره پلاک  ' + @AssetPlaque
							
					SET @intMaxDocRowNo = @intMaxDocRowNo + 1
					SET @intMaxRowNo = @intMaxRowNo + 1
		
					INSERT INTO acc.tblVoucherDtl
							(SerialNo,SourceProcessID,SourceProcessNo,SourceFiscalYear,SourceSerialNo,DocDate,IsAutoDoc,SessionNo,VchKind,RowNo,DocRowNo,
							 AcntCode,Debit,Credit,RecDesc,RecDesc2,SourceDocType) 
					VALUES	(@intVchNo,@intSourceProcessID,@intSourceProcessNo,@intSourceFiscalYear,@intSourceSerialNo,@strVchDate ,1,@SessionNo ,2,@intMaxRowNo ,@intMaxDocRowNo,
							 @AssetAcntCode,@CostAmount,0,TS.pub.funChangeFarsiStrings(pub.funReverseForCrystal(@strRecDesc2)),'',0 )	

					SET @strRecDesc2 = ' استقرار اول دوره دارایی هزینه نصب و راه اندازی ' + LTRIM(RTRIM(STR(@intSourceFiscalYear))) + '/' + LTRIM(RTRIM(STR(@intSourceSerialNo)))  + ' - ' + @AssetTitle + ' - به شماره پلاک  ' + @AssetPlaque
							
					SET @intMaxDocRowNo = @intMaxDocRowNo + 1
					SET @intMaxRowNo = @intMaxRowNo + 1
		
					INSERT INTO acc.tblVoucherDtl
							(SerialNo,SourceProcessID,SourceProcessNo,SourceFiscalYear,SourceSerialNo,DocDate,IsAutoDoc,SessionNo,VchKind,RowNo,DocRowNo,
							 AcntCode,Debit,Credit,RecDesc,RecDesc2,SourceDocType) 
					VALUES	(@intVchNo,@intSourceProcessID,@intSourceProcessNo,@intSourceFiscalYear,@intSourceSerialNo,@strVchDate ,1,@SessionNo ,2,@intMaxRowNo ,@intMaxDocRowNo,
							 @SetupAmountAcntCode,@SetupAmount,0,TS.pub.funChangeFarsiStrings(pub.funReverseForCrystal(@strRecDesc2)),'',0 )	

					SET @strRecDesc2 = ' استقرار اول دوره دارایی سایر هزینه ها ' + LTRIM(RTRIM(STR(@intSourceFiscalYear))) + '/' + LTRIM(RTRIM(STR(@intSourceSerialNo)))  + ' - ' + @AssetTitle + ' - به شماره پلاک  ' + @AssetPlaque
							
					SET @intMaxDocRowNo = @intMaxDocRowNo + 1
					SET @intMaxRowNo = @intMaxRowNo + 1
		
					INSERT INTO acc.tblVoucherDtl
							(SerialNo,SourceProcessID,SourceProcessNo,SourceFiscalYear,SourceSerialNo,DocDate,IsAutoDoc,SessionNo,VchKind,RowNo,DocRowNo,
							 AcntCode,Debit,Credit,RecDesc,RecDesc2,SourceDocType) 
					VALUES	(@intVchNo,@intSourceProcessID,@intSourceProcessNo,@intSourceFiscalYear,@intSourceSerialNo,@strVchDate ,1,@SessionNo ,2,@intMaxRowNo ,@intMaxDocRowNo,
							 @OtherCostsAcntCode,@OtherCosts,0,TS.pub.funChangeFarsiStrings(pub.funReverseForCrystal(@strRecDesc2)),'',0 )	

					SET @SumCostAmount = @SumCostAmount + @CostAmount  +@SetupAmount+@OtherCosts  --- @DepreciationAmount)
					SET @SumDepreciationAmount = @SumDepreciationAmount + @DepreciationAmount --- @DepreciationAmount)
					
					SET @strRecDesc2 = ' استهلاک انباشته برای' +  @strRecDesc2 
					
					SET @intMaxDocRowNo = @intMaxDocRowNo + 1
					SET @intMaxRowNo = @intMaxRowNo + 1
		
					INSERT INTO acc.tblVoucherDtl
							(SerialNo,SourceProcessID,SourceProcessNo,SourceFiscalYear,SourceSerialNo,DocDate,IsAutoDoc,SessionNo,VchKind,RowNo,DocRowNo,
							 AcntCode,Debit,Credit,RecDesc,RecDesc2,SourceDocType) 
					VALUES	(@intVchNo,@intSourceProcessID,@intSourceProcessNo,@intSourceFiscalYear,@intSourceSerialNo,@strVchDate ,1,@SessionNo ,2,@intMaxRowNo ,@intMaxDocRowNo,
							 @DepreciationAcntCode,0,@DepreciationAmount,TS.pub.funChangeFarsiStrings(pub.funReverseForCrystal(@strRecDesc2)),'',0 )	

				END

			Fetch NEXT From curSale Into @AssetAcntCode,@CostAmount,@AssetTitle,@GoodsUnit,@AssetPlaque,@AstGroupID,@DepreciationAmount,   @SetupAmount, @OtherCosts,@SetupAmountAcntCode,@OtherCostsAcntCode
		END

	Close curSale;
	Deallocate curSale; 
	end
	else
	begin
	
		
		Declare	curSale CURSOR For 
		SELECT	AssetAcntCode,CostAmount,AssetTitle,pub.funGetGoodsUnitName(GoodsID,@LanguageID) AS GoodsUnit,AssetPlaque,AstGroupID,DepreciationAmount
		FROM ast.tblAssetsDtl
		WHERE ProcessID=@intSourceProcessID AND
			  ProcessNo=@intSourceProcessNo AND
			  FiscalYear=@intSourceFiscalYear AND
			  SerialNo=@intSourceSerialNo 

		----- سطر به سطر به حساب مشتری میرود
		Open  curSale; 

		Fetch NEXT From curSale Into @AssetAcntCode,@CostAmount,@AssetTitle,@GoodsUnit,@AssetPlaque,@AstGroupID,@DepreciationAmount

		While (@@Fetch_Status = 0)
			BEGIN
				IF @CostAmount <> 0
					BEGIN
						
						SELECT @DepreciationAcntCode = DepreciationAcntCode 
						FROM ast.tblAstGroups
						WHERE AstGroupID = @AstGroupID
						
						IF @DepreciationAcntCode=''
							BEGIN
								Close curSale;
								Deallocate curSale; 
								--کد حسابداری استهلاک انباشته در گروه دارائی %s خالی است
								SET @strMsgText=TS.pub.funGetMessages(19007,@LanguageID)
								Raiserror (@strMsgText,16,1,@AstGroupID)
								Return
							END

						SET @Ast_MargeAcntCodeWithAssetAcntCode = 'False'
				
						Select @Ast_MargeAcntCodeWithAssetAcntCode=SettingValue From pub.tblSettings
						where SettingKey='Ast_MargeAcntCodeWithAssetAcntCode'

						if @Ast_MargeAcntCodeWithAssetAcntCode=1
							select @DepreciationAcntCode=acc.funMergAcntCode(@DepreciationAcntCode,@AssetAcntCode)
			
						SET @strRecDesc2 = ' استقرار اول دوره دارایی ' + LTRIM(RTRIM(STR(@intSourceFiscalYear))) + '/' + LTRIM(RTRIM(STR(@intSourceSerialNo)))  + ' - ' + @AssetTitle + ' - به شماره پلاک  ' + @AssetPlaque
								
						SET @intMaxDocRowNo = @intMaxDocRowNo + 1
						SET @intMaxRowNo = @intMaxRowNo + 1
			
						INSERT INTO acc.tblVoucherDtl
								(SerialNo,SourceProcessID,SourceProcessNo,SourceFiscalYear,SourceSerialNo,DocDate,IsAutoDoc,SessionNo,VchKind,RowNo,DocRowNo,
								 AcntCode,Debit,Credit,RecDesc,RecDesc2,SourceDocType) 
						VALUES	(@intVchNo,@intSourceProcessID,@intSourceProcessNo,@intSourceFiscalYear,@intSourceSerialNo,@strVchDate ,1,@SessionNo ,2,@intMaxRowNo ,@intMaxDocRowNo,
								 @AssetAcntCode,@CostAmount,0,TS.pub.funChangeFarsiStrings(pub.funReverseForCrystal(@strRecDesc2)),'',0 )	

						SET @SumCostAmount = @SumCostAmount + @CostAmount --- @DepreciationAmount)
						SET @SumDepreciationAmount = @SumDepreciationAmount + @DepreciationAmount --- @DepreciationAmount)
						
						SET @strRecDesc2 = ' استهلاک انباشته برای' +  @strRecDesc2 
						
						SET @intMaxDocRowNo = @intMaxDocRowNo + 1
						SET @intMaxRowNo = @intMaxRowNo + 1
			
						INSERT INTO acc.tblVoucherDtl
								(SerialNo,SourceProcessID,SourceProcessNo,SourceFiscalYear,SourceSerialNo,DocDate,IsAutoDoc,SessionNo,VchKind,RowNo,DocRowNo,
								 AcntCode,Debit,Credit,RecDesc,RecDesc2,SourceDocType) 
						VALUES	(@intVchNo,@intSourceProcessID,@intSourceProcessNo,@intSourceFiscalYear,@intSourceSerialNo,@strVchDate ,1,@SessionNo ,2,@intMaxRowNo ,@intMaxDocRowNo,
								 @DepreciationAcntCode,0,@DepreciationAmount,TS.pub.funChangeFarsiStrings(pub.funReverseForCrystal(@strRecDesc2)),'',0 )	

					END

				Fetch NEXT From curSale Into @AssetAcntCode,@CostAmount,@AssetTitle,@GoodsUnit,@AssetPlaque,@AstGroupID,@DepreciationAmount
			END

		Close curSale;
		Deallocate curSale; 
		
	end
	

	SELECT	@ObverseAcntCode=ObverseAcntCode
	FROM ast.tblAssetsHdr
	WHERE ProcessID=@intSourceProcessID AND
		  ProcessNo=@intSourceProcessNo AND
		  FiscalYear=@intSourceFiscalYear AND
		  SerialNo=@intSourceSerialNo 

	SET @intMaxDocRowNo = @intMaxDocRowNo + 1
	SET @intMaxRowNo = @intMaxRowNo + 1
	
	SET @strRecDesc2 = 'استهلاک انباشته اول دوره دارایی ' + LTRIM(RTRIM(STR(@intSourceFiscalYear))) + '/' + LTRIM(RTRIM(STR(@intSourceSerialNo)))

	INSERT INTO acc.tblVoucherDtl
			(SerialNo,SourceProcessID,SourceProcessNo,SourceFiscalYear,SourceSerialNo,DocDate,IsAutoDoc,SessionNo,VchKind,RowNo,DocRowNo,
				AcntCode,Debit,Credit,RecDesc,RecDesc2,SourceDocType) 
	VALUES	(@intVchNo,@intSourceProcessID,@intSourceProcessNo,@intSourceFiscalYear,@intSourceSerialNo,@strVchDate ,1,@SessionNo ,2,@intMaxRowNo ,@intMaxDocRowNo,
			 @ObverseAcntCode,@SumDepreciationAmount,0,TS.pub.funChangeFarsiStrings(pub.funReverseForCrystal(@strRecDesc2)),'' ,0)

	SET @intMaxDocRowNo = @intMaxDocRowNo + 1
	SET @intMaxRowNo = @intMaxRowNo + 1
					
	SET @strRecDesc2 = 'قيمت تمام شده اول دوره دارایی ' + LTRIM(RTRIM(STR(@intSourceFiscalYear))) + '/' + LTRIM(RTRIM(STR(@intSourceSerialNo)))
	
	INSERT INTO acc.tblVoucherDtl
			(SerialNo,SourceProcessID,SourceProcessNo,SourceFiscalYear,SourceSerialNo,DocDate,IsAutoDoc,SessionNo,VchKind,RowNo,DocRowNo,
				AcntCode,Debit,Credit,RecDesc,RecDesc2,SourceDocType) 
	VALUES	(@intVchNo,@intSourceProcessID,@intSourceProcessNo,@intSourceFiscalYear,@intSourceSerialNo,@strVchDate ,1,@SessionNo ,2,@intMaxRowNo ,@intMaxDocRowNo,
			 @ObverseAcntCode,0,@SumCostAmount,TS.pub.funChangeFarsiStrings(pub.funReverseForCrystal(@strRecDesc2)),'' ,0)
				
END
GO
