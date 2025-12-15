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
Create PROCEDURE [acc].[SpVchAssetReNew]
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

	Declare	curSale CURSOR For 
	SELECT	OtherCosts,AssetTitle,AssetPlaque,AstGroupID,EventNo,CostInSale
	FROM ast.tblAssetsDtl 
	WHERE ProcessID=@intSourceProcessID AND
		  ProcessNo=@intSourceProcessNo AND
		  FiscalYear=@intSourceFiscalYear AND
		  SerialNo=@intSourceSerialNo 
		  order by DocDate desc , EventNo desc

	----- سطر به سطر به حساب مشتری میرود
	Open  curSale; 

	Fetch NEXT From curSale Into @OtherCosts,@AssetTitle,@AssetPlaque,@AstGroupID,@EventNo,@CostInSale

	While (@@Fetch_Status = 0)
		BEGIN
					
				SELECT TOP 1 @DepreciationAcntCode=DepreciationAcntCode,@DepreciationAmount=DepreciationAmount,
							 @AssetAcntCode=AssetAcntCode
				FROM  ast.tblAssetsDtl			 
				WHERE AssetPlaque = @AssetPlaque AND EventNo <= @EventNo
				order by DocDate desc , EventNo desc				
				
				SELECT TOP 1 @CostAmount=CostAmount
				FROM  ast.tblAssetsDtl			 
				WHERE AssetPlaque = @AssetPlaque AND EventNo = @EventNo
				order by DocDate desc , EventNo desc

				IF @DepreciationAcntCode = ''
					SELECT @DepreciationAcntCode = DepreciationAcntCode 
					FROM ast.tblAstGroups
					WHERE AstGroupID = @AstGroupID	
			
					Declare @Ast_MargeAcntCodeWithAssetAcntCode as bit

				Select @Ast_MargeAcntCodeWithAssetAcntCode=SettingValue From pub.tblSettings
				where SettingKey='Ast_MargeAcntCodeWithAssetAcntCode'

				if @Ast_MargeAcntCodeWithAssetAcntCode=1
				 select @DepreciationAcntCode=acc.funMergAcntCode(@DepreciationAcntCode,@AssetAcntCode)			
				
				IF @CostInSale = ''
					SELECT @CostInSale = AdvantageAcntCode 
					FROM ast.tblAstGroups
					WHERE AstGroupID = @AstGroupID	
				
				
				SET @strRecDesc = ' تجدید ارزیابی اموال' + LTRIM(RTRIM(STR(@intSourceFiscalYear))) + '/' + LTRIM(RTRIM(STR(@intSourceSerialNo)))  + ' - ' + @AssetTitle + ' - به شماره پلاک  ' + @AssetPlaque
							
				SET @intMaxDocRowNo = @intMaxDocRowNo + 1
				SET @intMaxRowNo = @intMaxRowNo + 1
					
				INSERT INTO acc.tblVoucherDtl
						(SerialNo,SourceProcessID,SourceProcessNo,SourceFiscalYear,SourceSerialNo,DocDate,IsAutoDoc,SessionNo,VchKind,RowNo,DocRowNo,
						 AcntCode,Debit,Credit,RecDesc,RecDesc2,SourceDocType) 
				VALUES	(@intVchNo,@intSourceProcessID,@intSourceProcessNo,@intSourceFiscalYear,@intSourceSerialNo,@strVchDate ,1,@SessionNo ,1,@intMaxRowNo ,@intMaxDocRowNo,
						 @AssetAcntCode,@CostAmount,0,TS.pub.funChangeFarsiStrings(pub.funReverseForCrystal(@strRecDesc)),'',0 )	
			
				SET @intMaxDocRowNo = @intMaxDocRowNo + 1
				SET @intMaxRowNo = @intMaxRowNo + 1
			
				
				INSERT INTO acc.tblVoucherDtl
						(SerialNo,SourceProcessID,SourceProcessNo,SourceFiscalYear,SourceSerialNo,DocDate,IsAutoDoc,SessionNo,VchKind,RowNo,DocRowNo,
						 AcntCode,Debit,Credit,RecDesc,RecDesc2,SourceDocType) 
				VALUES	(@intVchNo,@intSourceProcessID,@intSourceProcessNo,@intSourceFiscalYear,@intSourceSerialNo,@strVchDate ,1,@SessionNo ,1,@intMaxRowNo ,@intMaxDocRowNo,
						 @CostInSale,0,@CostAmount,TS.pub.funChangeFarsiStrings(pub.funReverseForCrystal(@strRecDesc)),'',0 )				 
			
			Fetch NEXT From curSale Into @OtherCosts,@AssetTitle,@AssetPlaque,@AstGroupID,@EventNo,@CostInSale
			
		END

	Close curSale;
	Deallocate curSale; 

				
END
GO
