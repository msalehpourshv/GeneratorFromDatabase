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
Create PROCEDURE [acc].[SpVchAssetRenovation]
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
	Declare @CostAcntCode		Varchar(20)
	Declare @RenovationTypeID	INT
	Declare @SetupAmount		Float
	Declare @AssetTitle			NVarChar(1000)
	Declare @GoodsUnit			NVarChar(1000)
	Declare @AssetPlaque		NVarChar(1000)
	Declare @strRecDesc2		NVarChar(1000)
	Declare @strDescDtl		NVarChar(1000)
	Declare @TaxOverWorthCost	Float
	Declare @TollOverWorthCost	Float

	Declare @BuyTaxOverWorthAcntCode Varchar(20)
	Declare @BuyTollOverWorthAcntCode Varchar(20)
	Declare @strMsgText			NVarChar(2044)

	
	SELECT @BuyTaxOverWorthAcntCode = SettingValue
	FROM   pub.tblSettings
	WHERE SettingKey = 'BuyTaxOverWorthAcntCode_Asset' 
		
	SELECT @BuyTollOverWorthAcntCode = SettingValue
	FROM   pub.tblSettings
	WHERE SettingKey = 'BuyTollOverWorthAcntCode_Asset' 
	
	
	SELECT	@TaxOverWorthCost=TaxOverWorthCost,@TollOverWorthCost=TollOverWorthCost
	FROM ast.tblAssetsHdr
	WHERE ProcessID=@intSourceProcessID AND
		  ProcessNo=@intSourceProcessNo AND
		  FiscalYear=@intSourceFiscalYear AND
		  SerialNo=@intSourceSerialNo 
		  
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
			
	--------------------------------------------------------------------------------------------------------
	Declare	curAssetRenovation CURSOR For 
	SELECT	ObverseAcntCode,AssetAcntCode, case when  SetupAmount=0 then ChangeAmount else SetupAmount end as SetupAmount,AssetTitle,pub.funGetGoodsUnitName(GoodsID,@LanguageID) AS GoodsUnit,AssetPlaque,CostAcntCode,RenovationTypeID
	,DescDtl
	FROM ast.tblAssetsDtl
	WHERE ProcessID=@intSourceProcessID AND
		  ProcessNo=@intSourceProcessNo AND
		  FiscalYear=@intSourceFiscalYear AND
		  SerialNo=@intSourceSerialNo 

	----- سطر به سطر به حساب مشتری میرود
	Open  curAssetRenovation; 

	Fetch NEXT From curAssetRenovation Into @ObverseAcntCode,@AssetAcntCode,@SetupAmount,@AssetTitle,@GoodsUnit,@AssetPlaque,@CostAcntCode,@RenovationTypeID,@strDescDtl

	While (@@Fetch_Status = 0)
		BEGIN
			IF @SetupAmount <> 0
				BEGIN
					SET @strRecDesc2 = ' تعمیرات دارایی ' + LTRIM(RTRIM(STR(@intSourceFiscalYear))) + '/' + LTRIM(RTRIM(STR(@intSourceSerialNo)))  + ' - ' + @AssetTitle + ' - به شماره پلاک  ' + @AssetPlaque +'  '+ @strDescDtl
							
					SET @intMaxDocRowNo = @intMaxDocRowNo + 1
					SET @intMaxRowNo = @intMaxRowNo + 1
	
					IF @RenovationTypeID= 3
						INSERT INTO acc.tblVoucherDtl
								(SerialNo,SourceProcessID,SourceProcessNo,SourceFiscalYear,SourceSerialNo,DocDate,IsAutoDoc,SessionNo,VchKind,RowNo,DocRowNo,
									AcntCode,Debit,Credit,RecDesc,RecDesc2,SourceDocType) 
						VALUES	(@intVchNo,@intSourceProcessID,@intSourceProcessNo,@intSourceFiscalYear,@intSourceSerialNo,@strVchDate ,1,@SessionNo ,1,@intMaxRowNo ,@intMaxDocRowNo,
								 @CostAcntCode,@SetupAmount,0,TS.pub.funChangeFarsiStrings(pub.funReverseForCrystal(@strRecDesc2)),'' ,0)
					ELSE	
						INSERT INTO acc.tblVoucherDtl
								(SerialNo,SourceProcessID,SourceProcessNo,SourceFiscalYear,SourceSerialNo,DocDate,IsAutoDoc,SessionNo,VchKind,RowNo,DocRowNo,
									AcntCode,Debit,Credit,RecDesc,RecDesc2,SourceDocType) 
						VALUES	(@intVchNo,@intSourceProcessID,@intSourceProcessNo,@intSourceFiscalYear,@intSourceSerialNo,@strVchDate ,1,@SessionNo ,1,@intMaxRowNo ,@intMaxDocRowNo,
								 @AssetAcntCode,@SetupAmount,0,TS.pub.funChangeFarsiStrings(pub.funReverseForCrystal(@strRecDesc2)),'' ,0)

					SET @intMaxDocRowNo = @intMaxDocRowNo + 1
					SET @intMaxRowNo = @intMaxRowNo + 1
		
					INSERT INTO acc.tblVoucherDtl
							(SerialNo,SourceProcessID,SourceProcessNo,SourceFiscalYear,SourceSerialNo,DocDate,IsAutoDoc,SessionNo,VchKind,RowNo,DocRowNo,
							 AcntCode,Debit,Credit,RecDesc,RecDesc2,SourceDocType) 
					VALUES	(@intVchNo,@intSourceProcessID,@intSourceProcessNo,@intSourceFiscalYear,@intSourceSerialNo,@strVchDate ,1,@SessionNo ,1,@intMaxRowNo ,@intMaxDocRowNo,
							 @ObverseAcntCode,0,@SetupAmount,TS.pub.funChangeFarsiStrings(pub.funReverseForCrystal(@strRecDesc2)),'',0 )	

				END

			Fetch NEXT From curAssetRenovation Into @ObverseAcntCode,@AssetAcntCode,@SetupAmount,@AssetTitle,@GoodsUnit,@AssetPlaque,@CostAcntCode,@RenovationTypeID,@strDescDtl
		END
		
	Close curAssetRenovation;
	Deallocate curAssetRenovation; 


	IF @TaxOverWorthCost>0 or @TollOverWorthCost>0

	begin

		IF @TaxOverWorthCost>0
			begin
		
			SET @strRecDesc2=' مالیات بر ارزش افزوده تعمیرات دارایی' + LTRIM(RTRIM(STR(@intSourceFiscalYear))) + '/' + LTRIM(RTRIM(STR(@intSourceSerialNo)))
	
			SET @intMaxDocRowNo = @intMaxDocRowNo + 1
			SET @intMaxRowNo = @intMaxRowNo + 1

			INSERT INTO acc.tblVoucherDtl
				(SerialNo,SourceProcessID,SourceProcessNo,SourceFiscalYear,SourceSerialNo,DocDate,IsAutoDoc,SessionNo,VchKind,RowNo,DocRowNo,
					AcntCode,Debit,Credit,RecDesc,RecDesc2,SourceDocType) 
			VALUES	(@intVchNo,@intSourceProcessID,@intSourceProcessNo,@intSourceFiscalYear,@intSourceSerialNo,@strVchDate ,1,@SessionNo ,1,@intMaxRowNo ,@intMaxDocRowNo,
					@BuyTaxOverWorthAcntCode,@TaxOverWorthCost,0,TS.pub.funChangeFarsiStrings(pub.funReverseForCrystal(@strRecDesc2)),'',0 )	
		end 
		IF  @TollOverWorthCost>0
			begin
			
			SET @strRecDesc2=' عوارض بر ارزش افزوده تعمیرات دارایی' + LTRIM(RTRIM(STR(@intSourceFiscalYear))) + '/' + LTRIM(RTRIM(STR(@intSourceSerialNo)))

			SET @intMaxDocRowNo = @intMaxDocRowNo + 1
			SET @intMaxRowNo = @intMaxRowNo + 1

			INSERT INTO acc.tblVoucherDtl
					(SerialNo,SourceProcessID,SourceProcessNo,SourceFiscalYear,SourceSerialNo,DocDate,IsAutoDoc,SessionNo,VchKind,RowNo,DocRowNo,
						AcntCode,Debit,Credit,RecDesc,RecDesc2,SourceDocType) 
			VALUES	(@intVchNo,@intSourceProcessID,@intSourceProcessNo,@intSourceFiscalYear,@intSourceSerialNo,@strVchDate ,1,@SessionNo ,1,@intMaxRowNo ,@intMaxDocRowNo,
						@BuyTollOverWorthAcntCode,@TollOverWorthCost,0,TS.pub.funChangeFarsiStrings(pub.funReverseForCrystal(@strRecDesc2)),'',0 )	
		end
		SET @strRecDesc2=' مالیات و عوارض  بر ارزش افزوده تعمیرات دارایی' + LTRIM(RTRIM(STR(@intSourceFiscalYear))) + '/' + LTRIM(RTRIM(STR(@intSourceSerialNo)))

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
