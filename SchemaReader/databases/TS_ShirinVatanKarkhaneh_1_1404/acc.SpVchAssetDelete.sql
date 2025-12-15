USE TS_ShirinVatanKarkhaneh_1_1404
GO
SET ANSI_NULLS, QUOTED_IDENTIFIER ON
GO
-- =========== TS-QC:NOTOK ========================
-- Author        : Hadi Sadeghi
-- Create date   : 87/10/03
-- Viewed By	 : 
-- Last Modified : 
-- Description   : 
-- =============================================
Create PROCEDURE [acc].[SpVchAssetDelete]
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
	Declare  @IncomeInSale		Varchar(20)
	Declare  @CostInSale		Varchar(20)
	
	Declare @CostAmount			Float
	Declare @OtherCosts			Float
	Declare @OtherCost			Float
	Declare @OtherIncome		Float
	Declare @SumCostAmount		Float
	Declare @DepreciationAmount Float
	
	Declare @AssetTitle			NVarChar(1000)
	Declare @AssetPlaque		NVarChar(1000)
	Declare @strRecDesc			NVarChar(1000)
	Declare @strRecDesc2		NVarChar(1000)
	Declare	@intTmpMaxRowNo		Int
	Declare	@intTmpMaxDocRowNo	Int
	DECLARE @EventNo			Int
	--------------------------------------------------------------------------------------------------------

	SELECT	@ObverseAcntCode=ObverseAcntCode,@OtherCostAcntCode=OtherCostAcntCode,
			@OtherIncomeAcntCode=OtherIncomeAcntCode,@OtherCost=OtherCost,@OtherIncome=OtherIncome
	FROM ast.tblAssetsHdr
	WHERE ProcessID=@intSourceProcessID AND
		  ProcessNo=@intSourceProcessNo AND
		  FiscalYear=@intSourceFiscalYear AND
		  SerialNo=@intSourceSerialNo 
		
	IF @ObverseAcntCode='' AND (@OtherCost <> 0 or @OtherIncome <> 0 )
		BEGIN
			SET @strMsgText=' کد حسابداری حساب هزينه اسقاط خالی است'
			Raiserror (@strMsgText,16,1,@AstGroupID)
			Return
		END		
		
	IF @OtherCostAcntCode='' AND @OtherCost <> 0
		BEGIN
			SET @strMsgText=' کد حسابداری سایر هزینه های خالی است'
			Raiserror (@strMsgText,16,1,@AstGroupID)
			Return
		END

	IF @OtherIncomeAcntCode='' AND @OtherIncome <> 0
		BEGIN
			SET @strMsgText=' کد حسابداری سایر درآمدها خالی است'
			Raiserror (@strMsgText,16,1,@AstGroupID)
			Return
		END
			
	IF @OtherCostAcntCode <> '' AND @OtherCost <> 0
		BEGIN
			SET @intMaxDocRowNo = @intMaxDocRowNo + 1
			SET @intMaxRowNo = @intMaxRowNo + 1

			SET @strRecDesc2 = ' حذف یا اسقاط اموال ' + LTRIM(RTRIM(STR(@intSourceFiscalYear))) + '/' + LTRIM(RTRIM(STR(@intSourceSerialNo))) + ' سایر هزینه ها'

			INSERT INTO acc.tblVoucherDtl
					(SerialNo,SourceProcessID,SourceProcessNo,SourceFiscalYear,SourceSerialNo,DocDate,IsAutoDoc,SessionNo,VchKind,RowNo,DocRowNo,
						AcntCode,Debit,Credit,RecDesc,RecDesc2,SourceDocType) 
			VALUES	(@intVchNo,@intSourceProcessID,@intSourceProcessNo,@intSourceFiscalYear,@intSourceSerialNo,@strVchDate ,1,@SessionNo ,1,@intMaxRowNo ,@intMaxDocRowNo,
					 @OtherCostAcntCode,@OtherCost,0,TS.pub.funChangeFarsiStrings(pub.funReverseForCrystal(@strRecDesc2)),'' ,0)

		END

	IF @OtherIncomeAcntCode <> '' AND @OtherIncome <> 0
		BEGIN
			SET @intMaxDocRowNo = @intMaxDocRowNo + 1
			SET @intMaxRowNo = @intMaxRowNo + 1

			SET @strRecDesc2 = ' حذف یا اسقاط اموال ' + LTRIM(RTRIM(STR(@intSourceFiscalYear))) + '/' + LTRIM(RTRIM(STR(@intSourceSerialNo))) + ' سایر درآمدها'
			
			INSERT INTO acc.tblVoucherDtl
					(SerialNo,SourceProcessID,SourceProcessNo,SourceFiscalYear,SourceSerialNo,DocDate,IsAutoDoc,SessionNo,VchKind,RowNo,DocRowNo,
					 AcntCode,Debit,Credit,RecDesc,RecDesc2,SourceDocType) 
			VALUES	(@intVchNo,@intSourceProcessID,@intSourceProcessNo,@intSourceFiscalYear,@intSourceSerialNo,@strVchDate ,1,@SessionNo ,1,@intMaxRowNo ,@intMaxDocRowNo,
					 @OtherIncomeAcntCode,0,@OtherIncome,TS.pub.funChangeFarsiStrings(pub.funReverseForCrystal(@strRecDesc2)),'',0 )	
		END

	SET @strRecDesc2 = ' حذف یا اسقاط اموال ' + LTRIM(RTRIM(STR(@intSourceFiscalYear))) + '/' + LTRIM(RTRIM(STR(@intSourceSerialNo))) 

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

	Declare	CurDelete CURSOR For 
	SELECT	OtherCosts,AssetTitle,AssetPlaque,AstGroupID,EventNo
	FROM ast.tblAssetsDtl 
	WHERE ProcessID=@intSourceProcessID AND
		  ProcessNo=@intSourceProcessNo AND
		  FiscalYear=@intSourceFiscalYear AND
		  SerialNo=@intSourceSerialNo 

	----- سطر به سطر به حساب مشتری میرود
	Open  CurDelete; 

	Fetch NEXT From CurDelete Into @OtherCosts,@AssetTitle,@AssetPlaque,@AstGroupID,@EventNo

	While (@@Fetch_Status = 0)
		BEGIN
					
				SELECT TOP 1 @DepreciationAcntCode=DepreciationAcntCode,@DepreciationAmount=DepreciationAmount,
							 @AssetAcntCode=AssetAcntCode,@CostAmount=CostAmount
				FROM  ast.tblAssetsDtl			 
				WHERE AssetPlaque = @AssetPlaque AND EventNo < @EventNo
				ORDER BY EventNo Desc
				
				IF @DepreciationAcntCode = ''
					SELECT @DepreciationAcntCode = DepreciationAcntCode 
					FROM ast.tblAstGroups
					WHERE AstGroupID = @AstGroupID	
					
				Declare @Ast_MargeAcntCodeWithAssetAcntCode as bit

				Select @Ast_MargeAcntCodeWithAssetAcntCode=SettingValue From pub.tblSettings
				where SettingKey='Ast_MargeAcntCodeWithAssetAcntCode'

				if @Ast_MargeAcntCodeWithAssetAcntCode=1
				 select @DepreciationAcntCode=acc.funMergAcntCode(@DepreciationAcntCode,@AssetAcntCode)
			
				SET @strRecDesc = ' حذف یا اسقاط اموال ' + LTRIM(RTRIM(STR(@intSourceFiscalYear))) + '/' + LTRIM(RTRIM(STR(@intSourceSerialNo)))  + ' - ' + @AssetTitle + ' - به شماره پلاک  ' + @AssetPlaque
				
				SET @intMaxDocRowNo = @intMaxDocRowNo + 1
				SET @intMaxRowNo = @intMaxRowNo + 1
	
				IF @DepreciationAcntCode=''
					BEGIN
						Close CurDelete;
						Deallocate CurDelete; 
						SET @strMsgText='کداستهلاک انباشته در گروه دارایی خالی است'
						Raiserror (@strMsgText,16,1,@AstGroupID)
						Return
					END

				INSERT INTO acc.tblVoucherDtl
						(SerialNo,SourceProcessID,SourceProcessNo,SourceFiscalYear,SourceSerialNo,DocDate,IsAutoDoc,SessionNo,VchKind,RowNo,DocRowNo,
						 AcntCode,Debit,Credit,RecDesc,RecDesc2,SourceDocType) 
				VALUES	(@intVchNo,@intSourceProcessID,@intSourceProcessNo,@intSourceFiscalYear,@intSourceSerialNo,@strVchDate ,1,@SessionNo ,1,@intMaxRowNo ,@intMaxDocRowNo,
						 @DepreciationAcntCode,@DepreciationAmount,0,TS.pub.funChangeFarsiStrings(pub.funReverseForCrystal(@strRecDesc)),'',0 )	
				---------
				SET @intMaxDocRowNo = @intMaxDocRowNo + 1
				SET @intMaxRowNo = @intMaxRowNo + 1

				IF @AssetAcntCode=''
					BEGIN
						Close CurDelete;
						Deallocate CurDelete; 
						SET @strMsgText=' معین گروه دارایی در گروه دارایی خالی است'
						Raiserror (@strMsgText,16,1,@AstGroupID)
						Return
					END
				INSERT INTO acc.tblVoucherDtl
						(SerialNo,SourceProcessID,SourceProcessNo,SourceFiscalYear,SourceSerialNo,DocDate,IsAutoDoc,SessionNo,VchKind,RowNo,DocRowNo,
						 AcntCode,Debit,Credit,RecDesc,RecDesc2,SourceDocType) 
				VALUES	(@intVchNo,@intSourceProcessID,@intSourceProcessNo,@intSourceFiscalYear,@intSourceSerialNo,@strVchDate ,1,@SessionNo ,1,@intMaxRowNo ,@intMaxDocRowNo,
						 @AssetAcntCode,0,@CostAmount,TS.pub.funChangeFarsiStrings(pub.funReverseForCrystal(@strRecDesc)),'',0 )	

				---------
				SET @CostInSale = ''

				SELECT   @CostInSale =  CostInSale
				FROM         ast.tblAssetsDtl
				WHERE     (AstGroupID = @AstGroupID) AND (AssetPlaque = @AssetPlaque) AND (ProcessID = 485)
				
				IF @CostInSale=''
				BEGIN
					SELECT @CostInSale = CostInSale 
					FROM ast.tblAstGroups
					WHERE AstGroupID = @AstGroupID
				end 
			
				IF @CostInSale=''
					BEGIN
						
						Close CurDelete;
						Deallocate CurDelete; 

						--کد حسابداری هزینه حاصل از فروش در گروه دارائی %s خالی است
						SET @strMsgText=TS.pub.funGetMessages(19009,@LanguageID)
						Raiserror (@strMsgText,16,1,@AstGroupID)
						Return
					END
					
				SET @intMaxDocRowNo = @intMaxDocRowNo + 1
				SET @intMaxRowNo = @intMaxRowNo + 1

	
				INSERT INTO acc.tblVoucherDtl
						(SerialNo,SourceProcessID,SourceProcessNo,SourceFiscalYear,SourceSerialNo,DocDate,IsAutoDoc,SessionNo,VchKind,RowNo,DocRowNo,
						 AcntCode,Debit,Credit,RecDesc,RecDesc2,SourceDocType) 
				VALUES	(@intVchNo,@intSourceProcessID,@intSourceProcessNo,@intSourceFiscalYear,@intSourceSerialNo,@strVchDate ,1,@SessionNo ,1,@intMaxRowNo ,@intMaxDocRowNo,
						 @CostInSale,@CostAmount- @DepreciationAmount,0 ,TS.pub.funChangeFarsiStrings(pub.funReverseForCrystal(@strRecDesc)),'',0 )	


			Fetch NEXT From CurDelete Into @OtherCosts,@AssetTitle,@AssetPlaque,@AstGroupID,@EventNo
			
		END

	Close CurDelete;
	Deallocate CurDelete; 

	exec 	acc.SpBalanceVoucher @intVchNo,@CostInSale ,@intSourceProcessID	,
	@intSourceProcessNo	,
	@intSourceFiscalYear	,
	@intSourceSerialNo	

END
GO
