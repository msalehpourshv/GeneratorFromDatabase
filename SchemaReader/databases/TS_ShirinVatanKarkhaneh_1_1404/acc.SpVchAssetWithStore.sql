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
Create PROCEDURE [acc].[SpVchAssetWithStore]
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
	Declare @AssetAcntCode		Varchar(20)
	Declare @SetupAmountAcntCode		Varchar(20)
    Declare @OtherCostsAcntCode		Varchar(20)
	Declare @ObverseAcntCode	Varchar(20)
	Declare @CostAmount			Float
	Declare @SetupAmount		Float
	Declare @OtherCosts			Float
	
	Declare @SumCostAmount			Float
	Declare @AssetTitle			NVarChar(1000)
	Declare @GoodsUnit			NVarChar(1000)
	Declare @AssetPlaque		NVarChar(1000)
	Declare @strRecDesc2		NVarChar(1000)
	Declare	@intTmpMaxRowNo		Int
	Declare	@intTmpMaxDocRowNo	Int
	
	-----
	SET @SumCostAmount = 0
	SET @intMaxDocRowNo = @intMaxDocRowNo + 1
	SET @intMaxRowNo = @intMaxRowNo + 1

	SET @intTmpMaxDocRowNo = @intMaxDocRowNo
	SET @intTmpMaxRowNo = @intMaxRowNo
	

--------------------------------------------------------------------------------------------------------
Declare @OtherAcntCode_Asset		Varchar(20)

select @OtherAcntCode_Asset=SettingValue from pub.tblSettings
where SettingKey='OtherAcntCode_Asset'

	IF @OtherAcntCode_Asset = 'True' 
	begin
	
		Declare	curSale CURSOR For 
		SELECT	AssetAcntCode,CostAmount-SetupAmount- OtherCosts,AssetTitle,pub.funGetGoodsUnitName(GoodsID,@LanguageID) AS GoodsUnit,AssetPlaque,   SetupAmount, OtherCosts,SetupAmountAcntCode,OtherCostsAcntCode		
		FROM ast.tblAssetsDtl
		WHERE ProcessID=@intSourceProcessID AND
			  ProcessNo=@intSourceProcessNo AND
			  FiscalYear=@intSourceFiscalYear AND
			  SerialNo=@intSourceSerialNo 

		SELECT	@ObverseAcntCode=ObverseAcntCode
		FROM ast.tblAssetsHdr
		WHERE ProcessID=@intSourceProcessID AND
			  ProcessNo=@intSourceProcessNo AND
			  FiscalYear=@intSourceFiscalYear AND
			  SerialNo=@intSourceSerialNo 
			  
		----- سطر به سطر به حساب مشتری میرود
		Open  curSale; 

		Fetch NEXT From curSale Into @AssetAcntCode,@CostAmount,@AssetTitle,@GoodsUnit,@AssetPlaque,   @SetupAmount, @OtherCosts,@SetupAmountAcntCode,@OtherCostsAcntCode

		While (@@Fetch_Status = 0)
			BEGIN
				IF @CostAmount <> 0
					BEGIN
						SET @strRecDesc2 = ' هزینه خرید دارایی از طریق انبار ' + LTRIM(RTRIM(STR(@intSourceFiscalYear))) + '/' + LTRIM(RTRIM(STR(@intSourceSerialNo)))  + ' - ' + @AssetTitle + ' - به شماره پلاک  ' + @AssetPlaque
								
						SET @intMaxDocRowNo = @intMaxDocRowNo + 1
						SET @intMaxRowNo = @intMaxRowNo + 1
			
						INSERT INTO acc.tblVoucherDtl
								(SerialNo,SourceProcessID,SourceProcessNo,SourceFiscalYear,SourceSerialNo,DocDate,IsAutoDoc,SessionNo,VchKind,RowNo,DocRowNo,
								 AcntCode,Debit,Credit,RecDesc,RecDesc2,SourceDocType) 
						VALUES	(@intVchNo,@intSourceProcessID,@intSourceProcessNo,@intSourceFiscalYear,@intSourceSerialNo,@strVchDate ,1,@SessionNo ,1,@intMaxRowNo ,@intMaxDocRowNo,
								 @AssetAcntCode,@CostAmount,0,TS.pub.funChangeFarsiStrings(pub.funReverseForCrystal(@strRecDesc2)),'',0 )	
						SET @strRecDesc2 = ' هزینه نصب و راه اندازی دارایی از طریق انبار ' + LTRIM(RTRIM(STR(@intSourceFiscalYear))) + '/' + LTRIM(RTRIM(STR(@intSourceSerialNo)))  + ' - ' + @AssetTitle + ' - به شماره پلاک  ' + @AssetPlaque
								
						SET @intMaxDocRowNo = @intMaxDocRowNo + 1
						SET @intMaxRowNo = @intMaxRowNo + 1
			
						INSERT INTO acc.tblVoucherDtl
								(SerialNo,SourceProcessID,SourceProcessNo,SourceFiscalYear,SourceSerialNo,DocDate,IsAutoDoc,SessionNo,VchKind,RowNo,DocRowNo,
								 AcntCode,Debit,Credit,RecDesc,RecDesc2,SourceDocType) 
						VALUES	(@intVchNo,@intSourceProcessID,@intSourceProcessNo,@intSourceFiscalYear,@intSourceSerialNo,@strVchDate ,1,@SessionNo ,1,@intMaxRowNo ,@intMaxDocRowNo,
								 @SetupAmountAcntCode,@SetupAmount,0,TS.pub.funChangeFarsiStrings(pub.funReverseForCrystal(@strRecDesc2)),'',0 )	

SET @strRecDesc2 = ' سایر هزینه ها دارایی از طریق انبار ' + LTRIM(RTRIM(STR(@intSourceFiscalYear))) + '/' + LTRIM(RTRIM(STR(@intSourceSerialNo)))  + ' - ' + @AssetTitle + ' - به شماره پلاک  ' + @AssetPlaque
								
						SET @intMaxDocRowNo = @intMaxDocRowNo + 1
						SET @intMaxRowNo = @intMaxRowNo + 1
			
						INSERT INTO acc.tblVoucherDtl
								(SerialNo,SourceProcessID,SourceProcessNo,SourceFiscalYear,SourceSerialNo,DocDate,IsAutoDoc,SessionNo,VchKind,RowNo,DocRowNo,
								 AcntCode,Debit,Credit,RecDesc,RecDesc2,SourceDocType) 
						VALUES	(@intVchNo,@intSourceProcessID,@intSourceProcessNo,@intSourceFiscalYear,@intSourceSerialNo,@strVchDate ,1,@SessionNo ,1,@intMaxRowNo ,@intMaxDocRowNo,
								 @OtherCostsAcntCode,@OtherCosts,0,TS.pub.funChangeFarsiStrings(pub.funReverseForCrystal(@strRecDesc2)),'',0 )	


						SET @SumCostAmount = @SumCostAmount + @CostAmount+@SetupAmount+@OtherCosts
					END

				Fetch NEXT From curSale Into @AssetAcntCode,@CostAmount,@AssetTitle,@GoodsUnit,@AssetPlaque,   @SetupAmount, @OtherCosts,@SetupAmountAcntCode,@OtherCostsAcntCode
			END

		Close curSale;
		Deallocate curSale; 




	end 
	else
	begin
		
		Declare	curSale CURSOR For 
		SELECT	AssetAcntCode,CostAmount,AssetTitle,pub.funGetGoodsUnitName(GoodsID,@LanguageID) AS GoodsUnit,AssetPlaque
		FROM ast.tblAssetsDtl
		WHERE ProcessID=@intSourceProcessID AND
			  ProcessNo=@intSourceProcessNo AND
			  FiscalYear=@intSourceFiscalYear AND
			  SerialNo=@intSourceSerialNo 

		SELECT	@ObverseAcntCode=ObverseAcntCode
		FROM ast.tblAssetsHdr
		WHERE ProcessID=@intSourceProcessID AND
			  ProcessNo=@intSourceProcessNo AND
			  FiscalYear=@intSourceFiscalYear AND
			  SerialNo=@intSourceSerialNo 
			  
		----- سطر به سطر به حساب مشتری میرود
		Open  curSale; 

		Fetch NEXT From curSale Into @AssetAcntCode,@CostAmount,@AssetTitle,@GoodsUnit,@AssetPlaque

		While (@@Fetch_Status = 0)
			BEGIN
				IF @CostAmount <> 0
					BEGIN
						SET @strRecDesc2 = ' خرید دارایی از طریق انبار ' + LTRIM(RTRIM(STR(@intSourceFiscalYear))) + '/' + LTRIM(RTRIM(STR(@intSourceSerialNo)))  + ' - ' + @AssetTitle + ' - به شماره پلاک  ' + @AssetPlaque
								
						SET @intMaxDocRowNo = @intMaxDocRowNo + 1
						SET @intMaxRowNo = @intMaxRowNo + 1
			
						INSERT INTO acc.tblVoucherDtl
								(SerialNo,SourceProcessID,SourceProcessNo,SourceFiscalYear,SourceSerialNo,DocDate,IsAutoDoc,SessionNo,VchKind,RowNo,DocRowNo,
								 AcntCode,Debit,Credit,RecDesc,RecDesc2,SourceDocType) 
						VALUES	(@intVchNo,@intSourceProcessID,@intSourceProcessNo,@intSourceFiscalYear,@intSourceSerialNo,@strVchDate ,1,@SessionNo ,1,@intMaxRowNo ,@intMaxDocRowNo,
								 @AssetAcntCode,@CostAmount,0,TS.pub.funChangeFarsiStrings(pub.funReverseForCrystal(@strRecDesc2)),'',0 )	

						SET @SumCostAmount = @SumCostAmount + @CostAmount
					END

				Fetch NEXT From curSale Into @AssetAcntCode,@CostAmount,@AssetTitle,@GoodsUnit,@AssetPlaque
			END

		Close curSale;
		Deallocate curSale; 

end


	SET @strRecDesc2 = ' خرید دارایی از طریق انبار ' + LTRIM(RTRIM(STR(@intSourceFiscalYear))) + '/' + LTRIM(RTRIM(STR(@intSourceSerialNo)))

	INSERT INTO acc.tblVoucherDtl
			(SerialNo,SourceProcessID,SourceProcessNo,SourceFiscalYear,SourceSerialNo,DocDate,IsAutoDoc,SessionNo,VchKind,RowNo,DocRowNo,
				AcntCode,Debit,Credit,RecDesc,RecDesc2,SourceDocType) 
	VALUES	(@intVchNo,@intSourceProcessID,@intSourceProcessNo,@intSourceFiscalYear,@intSourceSerialNo,@strVchDate ,1,@SessionNo ,1,@intTmpMaxRowNo ,@intTmpMaxDocRowNo,
			 @ObverseAcntCode,0,@SumCostAmount,TS.pub.funChangeFarsiStrings(pub.funReverseForCrystal(@strRecDesc2)),'',0)
				
END
GO
