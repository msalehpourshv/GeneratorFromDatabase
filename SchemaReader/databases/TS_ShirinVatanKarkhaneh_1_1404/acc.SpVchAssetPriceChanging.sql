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
Create  PROCEDURE [acc].[SpVchAssetPriceChanging]
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
	Declare @ObverseAcntCode	Varchar(20)
	Declare @TmpAcntCode		Varchar(20)
	Declare @ChangeAmount			Float
	Declare @AssetTitle			NVarChar(1000)
	Declare @GoodsUnit			NVarChar(1000)
	Declare @AssetPlaque		NVarChar(1000)
	Declare @strRecDesc2		NVarChar(1000)
	

	--------------------------------------------------------------------------------------------------------
	Declare	curAssetRenovation CURSOR For 
	SELECT	ObverseAcntCode,AssetAcntCode,ChangeAmount,AssetTitle,pub.funGetGoodsUnitName(GoodsID,@LanguageID) AS GoodsUnit,AssetPlaque
	FROM ast.tblAssetsDtl
	WHERE ProcessID=@intSourceProcessID AND
		  ProcessNo=@intSourceProcessNo AND
		  FiscalYear=@intSourceFiscalYear AND
		  SerialNo=@intSourceSerialNo 

	----- سطر به سطر به حساب مشتری میرود
	Open  curAssetRenovation; 

	Fetch NEXT From curAssetRenovation Into @ObverseAcntCode,@AssetAcntCode,@ChangeAmount,@AssetTitle,@GoodsUnit,@AssetPlaque

	While (@@Fetch_Status = 0)
		BEGIN
			IF @ChangeAmount <> 0
				BEGIN
					IF @ChangeAmount < 0
						BEGIN
							SET @TmpAcntCode = @ObverseAcntCode
							SET @ObverseAcntCode = @AssetAcntCode
							SET @AssetAcntCode = @TmpAcntCode
							SET @strRecDesc2 = '  کاهش قیمت اموال ' + LTRIM(RTRIM(STR(@intSourceFiscalYear))) + '/' + LTRIM(RTRIM(STR(@intSourceSerialNo)))  + ' - ' + @AssetTitle + ' - به شماره پلاک  ' + @AssetPlaque
						END
					ELSE
							SET @strRecDesc2 = ' افزایش قیمت اموال ' + LTRIM(RTRIM(STR(@intSourceFiscalYear))) + '/' + LTRIM(RTRIM(STR(@intSourceSerialNo)))  + ' - ' + @AssetTitle + ' - به شماره پلاک  ' + @AssetPlaque
						
							
					SET @intMaxDocRowNo = @intMaxDocRowNo + 1
					SET @intMaxRowNo = @intMaxRowNo + 1

					INSERT INTO acc.tblVoucherDtl
							(SerialNo,SourceProcessID,SourceProcessNo,SourceFiscalYear,SourceSerialNo,DocDate,IsAutoDoc,SessionNo,VchKind,RowNo,DocRowNo,
								AcntCode,Debit,Credit,RecDesc,RecDesc2,SourceDocType) 
					VALUES	(@intVchNo,@intSourceProcessID,@intSourceProcessNo,@intSourceFiscalYear,@intSourceSerialNo,@strVchDate ,1,@SessionNo ,1,@intMaxRowNo ,@intMaxDocRowNo,
							 @AssetAcntCode,ABS(@ChangeAmount),0,TS.pub.funChangeFarsiStrings(pub.funReverseForCrystal(@strRecDesc2)),'' ,0)

					SET @intMaxDocRowNo = @intMaxDocRowNo + 1
					SET @intMaxRowNo = @intMaxRowNo + 1
		
					INSERT INTO acc.tblVoucherDtl
							(SerialNo,SourceProcessID,SourceProcessNo,SourceFiscalYear,SourceSerialNo,DocDate,IsAutoDoc,SessionNo,VchKind,RowNo,DocRowNo,
							 AcntCode,Debit,Credit,RecDesc,RecDesc2,SourceDocType) 
					VALUES	(@intVchNo,@intSourceProcessID,@intSourceProcessNo,@intSourceFiscalYear,@intSourceSerialNo,@strVchDate ,1,@SessionNo ,1,@intMaxRowNo ,@intMaxDocRowNo,
							 @ObverseAcntCode,0,ABS(@ChangeAmount),TS.pub.funChangeFarsiStrings(pub.funReverseForCrystal(@strRecDesc2)),'',0 )	
							 
				END

			Fetch NEXT From curAssetRenovation Into @ObverseAcntCode,@AssetAcntCode,@ChangeAmount,@AssetTitle,@GoodsUnit,@AssetPlaque
		END

	Close curAssetRenovation;
	Deallocate curAssetRenovation; 



	Declare @ChangeAmountTaxOverWorthAcntCode Varchar(20)
	Declare @ChangeAmountTollOverWorthAcntCode Varchar(20)
	Declare @strMsgText			NVarChar(2044)
	Declare @TollOverWorthCost	Float
	Declare @TaxOverWorthCost	Float
		
		
	SELECT @ChangeAmountTaxOverWorthAcntCode = SettingValue
	FROM   pub.tblSettings
	WHERE SettingKey = 'BuyTaxOverWorthAcntCode_Asset' 
		
	SELECT @ChangeAmountTollOverWorthAcntCode = SettingValue
	FROM   pub.tblSettings
	WHERE SettingKey = 'BuyTollOverWorthAcntCode_Asset' 
	
	
	SELECT	@TaxOverWorthCost=TaxOverWorthCost,@TollOverWorthCost=TollOverWorthCost
	FROM ast.tblAssetsHdr
	WHERE ProcessID=@intSourceProcessID AND
		  ProcessNo=@intSourceProcessNo AND
		  FiscalYear=@intSourceFiscalYear AND
		  SerialNo=@intSourceSerialNo 
		  
 
IF @TaxOverWorthCost>0 or @TollOverWorthCost>0

	begin
 
		IF @TaxOverWorthCost>0
			begin
		
			SET @strRecDesc2=' مالیات بر ارزش افزوده تغییر قیمت' + LTRIM(RTRIM(STR(@intSourceFiscalYear))) + '/' + LTRIM(RTRIM(STR(@intSourceSerialNo)))
	
			SET @intMaxDocRowNo = @intMaxDocRowNo + 1
			SET @intMaxRowNo = @intMaxRowNo + 1

	 	 	INSERT INTO acc.tblVoucherDtl
	 		 (SerialNo,SourceProcessID,SourceProcessNo,SourceFiscalYear,SourceSerialNo,DocDate,IsAutoDoc
	 		   ,SessionNo,VchKind,RowNo,DocRowNo
	 		   ,AcntCode,Debit,Credit,RecDesc
	 	       ,RecDesc2,SourceDocType) 
	 		VALUES	(@intVchNo,@intSourceProcessID,@intSourceProcessNo,@intSourceFiscalYear,@intSourceSerialNo
	 		         ,@strVchDate ,1,@SessionNo ,1,@intMaxRowNo ,@intMaxDocRowNo
	 			     ,@ChangeAmountTaxOverWorthAcntCode,@TaxOverWorthCost,0
	 			     ,TS.pub.funChangeFarsiStrings(pub.funReverseForCrystal(@strRecDesc2)),'',0 ) 	
		end 
	IF  @TollOverWorthCost>0
			begin
			
			SET @strRecDesc2=' عوارض بر ارزش افزوده تغییر قیمت' + LTRIM(RTRIM(STR(@intSourceFiscalYear))) + '/' + LTRIM(RTRIM(STR(@intSourceSerialNo)))

			SET @intMaxDocRowNo = @intMaxDocRowNo + 1
			SET @intMaxRowNo = @intMaxRowNo + 1

			INSERT INTO acc.tblVoucherDtl
					(SerialNo,SourceProcessID,SourceProcessNo,SourceFiscalYear,SourceSerialNo,DocDate,IsAutoDoc,SessionNo,VchKind,RowNo,DocRowNo,
						AcntCode,Debit,Credit,RecDesc,RecDesc2,SourceDocType) 
			VALUES	(@intVchNo,@intSourceProcessID,@intSourceProcessNo,@intSourceFiscalYear,@intSourceSerialNo,@strVchDate ,1,@SessionNo ,1,@intMaxRowNo ,@intMaxDocRowNo,
						@ChangeAmountTollOverWorthAcntCode,@TollOverWorthCost,0,TS.pub.funChangeFarsiStrings(pub.funReverseForCrystal(@strRecDesc2)),'',0 )	
		end
		SET @strRecDesc2=' مالیات و عوارض  بر ارزش افزوده تغییر قیمت' + LTRIM(RTRIM(STR(@intSourceFiscalYear))) + '/' + LTRIM(RTRIM(STR(@intSourceSerialNo)))
	SET @intMaxDocRowNo = @intMaxDocRowNo + 1
		SET @intMaxRowNo = @intMaxRowNo + 1

		INSERT INTO acc.tblVoucherDtl
				(SerialNo,SourceProcessID,SourceProcessNo,SourceFiscalYear,SourceSerialNo,DocDate,IsAutoDoc,SessionNo,VchKind,RowNo,DocRowNo,
					AcntCode,Debit,Credit,RecDesc,RecDesc2,SourceDocType) 
		VALUES	(@intVchNo,@intSourceProcessID,@intSourceProcessNo,@intSourceFiscalYear,@intSourceSerialNo,@strVchDate ,1,@SessionNo ,1,@intMaxRowNo ,@intMaxDocRowNo,
					@ObverseAcntCode,0,@TaxOverWorthCost+@TollOverWorthCost,TS.pub.funChangeFarsiStrings(pub.funReverseForCrystal(@strRecDesc2)),'',0 )	
	end

				
END
 
GO
