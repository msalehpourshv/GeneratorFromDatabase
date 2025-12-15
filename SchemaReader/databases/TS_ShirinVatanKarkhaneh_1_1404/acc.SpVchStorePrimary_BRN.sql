USE TS_ShirinVatanKarkhaneh_1_1404
GO
SET ANSI_NULLS, QUOTED_IDENTIFIER ON
GO
-- =========== TS-QC:NOTOK ========================
-- Author        : Hadi Sadeghi
-- Create date   : 1400/10/06
-- Viewed By	 : 
-- Last Modified : 
-- Description   : 
-- ================================================
Create PROCEDURE [acc].[SpVchStorePrimary_BRN]
	@intVchNo				Int,
	@intDocStep				TinyInt,
    @strVchDate				Char(10),
	@intSourceProcessID		TinyInt,
	@intSourceProcessNo		TinyInt,
	@intSourceFiscalYear	SmallInt,
	@intSourceSerialNo		Int,
	@StrSourceCodeFieldName VARCHAR(200),
	@StrSourceCodeFieldValue VARCHAR(200),
	@intMaxRowNo			Int,
	@intMaxDocRowNo			Int,
	@SessionNo				Int,
	@LanguageID				TinyInt

WITH ENCRYPTION
AS

BEGIN 

Declare @TaxP float , 
		@TollP float ,
		@Tax float , 
		@Toll float ,
		@TaxOverWorthCost float,
		@TollOverWorthCost float,
		@Price Float,
		@TotalPrice Float,
		@DiscountDtl Float,
		@Discount Float
			
Declare @strMsgText	NVarChar(MAX)
Declare @StockAcntCode as varchar(20),
		@SaleDiscountAcntCode as varchar(20),
        @SaleTaxOverWorthAcntCode as varchar(20),
        @SaleTollOverWorthAcntCode as varchar(20),
        @StoreID as varchar(20),
        @BRN as Nvarchar(20),
        @AcntCode  as varchar(20),
        @AcntCode2 as varchar(20),
        @AcntCode3 as varchar(20),
        @AcntCode4 as varchar(20),
        @ExtraField AS NVarchar(200),
        @strRecDesc				NVarChar(1000),
        @strRecDesc2			NVarChar(1000)

DECLARE @DocDate NVARCHAR(10)        
DECLARE @ProcessID   INT,     
		@FiscalYear  INT,
		@intMaxRowNo_AcntCode INT,
		@intMaxDocRowNo_AcntCode INT

SET @intMaxRowNo_AcntCode = @intMaxRowNo
SET	@intMaxDocRowNo_AcntCode=@intMaxDocRowNo

SET @intMaxRowNo = @intMaxRowNo + 3
SET	@intMaxDocRowNo =@intMaxDocRowNo + 3
--====================================================================================================================
	DECLARE @StrSelect NVarChar(4000)
	DECLARE @StrCode NVarChar(4000)
	SET @StrCode=''
	SET @TotalPrice = 0
	SET @TaxOverWorthCost = 0
	SET @TollOverWorthCost = 0
	
	update inv.tblStorageDocsHdr
	set Amount = SD.Am
	from inv.tblStorageDocsHdr SH
	INNER JOIN (SELECT ProcessID,ProcessNo,FiscalYear,SerialNo,SUM(GoodsPrice*GoodsQuantity) Am 
				from inv.tblStorageDocsDtl 
				where ProcessID=50
				group by ProcessID,ProcessNo,FiscalYear,SerialNo) SD
	on SD.ProcessID=SH.ProcessID and
	SD.ProcessNo=SH.ProcessNo and
	SD.FiscalYear=SH.FiscalYear and
	SD.SerialNo=SH.SerialNo
	where Amount=0

	IF @StrSourceCodeFieldName  <> ''
		SET @StrCode = 'SH.' + pub.funSplitString(@StrSourceCodeFieldName, '@', 1) + ' = ''' + pub.funSplitString(@StrSourceCodeFieldValue, '@', 1) + '''' 
	
	IF @StrCode<>'' AND pub.funSplitString(@StrSourceCodeFieldName, '@', 2)<>''
		SET @StrCode = @StrCode + ' AND SH.' + pub.funSplitString(@StrSourceCodeFieldName, '@', 2) + ' = ''' + pub.funSplitString(@StrSourceCodeFieldValue, '@', 2) + '''' 
	
	IF @StrCode<>'' AND pub.funSplitString(@StrSourceCodeFieldName, '@', 3)<>''
		SET @StrCode = @StrCode + ' AND ' + pub.funSplitString(@StrSourceCodeFieldName, '@', 3) + ' = ''' + pub.funSplitString(@StrSourceCodeFieldValue, '@', 3) + '''' 

	IF @StrCode<>'' AND pub.funSplitString(@StrSourceCodeFieldName, '@', 4)<>''
		SET @StrCode = @StrCode + ' AND SH.' + pub.funSplitString(@StrSourceCodeFieldName, '@', 4) + ' = ''' + pub.funSplitString(@StrSourceCodeFieldValue, '@', 4) + '''' 

	IF @StrCode<>'' AND pub.funSplitString(@StrSourceCodeFieldName, '@', 5)<>''
		SET @StrCode = @StrCode + ' AND SH.' + pub.funSplitString(@StrSourceCodeFieldName, '@', 5) + ' = ''' + pub.funSplitString(@StrSourceCodeFieldValue, '@', 5) + '''' 
	
	IF  @StrCode <> ''
		SET @StrCode = ' AND ' + @StrCode 
		
	SET @BRN = 	pub.funSplitString(@StrSourceCodeFieldValue, '@', 1)
			
	DECLARE @NoTaxTollInBrn BIT
	SET @NoTaxTollInBrn = 'False'
	SELECT @NoTaxTollInBrn = SettingValue
	FROM pub.tblSettings
	WHERE SettingKey = 'NoTaxTollInBrn' 

	IF @NoTaxTollInBrn = 'False'
	BEGIN
		SELECT @TaxP=SettingValue from pub.tblSettings where SettingKey ='TaxOverWorthPercentInSale'
		SELECT @TollP=SettingValue from pub.tblSettings where SettingKey ='TollOverWorthPercentInSale'
	END
	ELSE
	BEGIN
		SELECT @TaxP=0
		SELECT @TollP=0
	END

create table #S(	 
	ProcessID int,
	FiscalYear int,
	AcntCode Varchar(20),
	StoreID Varchar(20),
	DocDate char(10),
	BRN Varchar(20),
	ExtraField Varchar(100),
	AcntCode2 Varchar(20),
	AcntCode3 Varchar(20),
	AcntCode4 Varchar(20),
	Price  Float,
	Discount  Float
	); 

declare @db_0000	nvarchar(50);
	
set @db_0000 = Substring(db_name(), 1, Len(db_name()) - 4) + '0000'
	
declare @strQuery nvarchar(MAX)
declare @StrParams nvarchar(100)
declare @PropertyName varchar(50)

SET @StrParams = N'  @PropertyName2 VARCHAR(50) OUTPUT';

SET @strQuery = 'SELECT @PropertyName2=PropertyName from '+ @db_0000 +'.pub.tblGoodsPropertiesAcntCodeHdr WHERE BranchID = ''' + @BRN + ''''
		--PRINT  @strQuery
Exec sp_executesql  @strQuery, @StrParams, @PropertyName OUTPUT;

	IF @PropertyName IS NULL OR @PropertyName = ''
	BEGIN
		Raiserror (N'BranchID is not valid',16,1)
		Return
	END	
		--PRINT  @PropertyName
	set @strQuery = '
		INSERT INTO #S
		SELECT T.ProcessID,T.FiscalYear,T.AcntCode,T.StoreID,T.DocDate,T.BRN,T.' + @PropertyName + ',T.AcntCode2,T.AcntCode3,T.AcntCode4,
			   SUM(GoodsQuantity*GoodsPrice)Price,SUM(DiscountDtl+HDiscount) Discount
		FROM
			(SELECT Case when (SH.Amount+SH.Discount+SH.Discount2+SH.Discount3)=0 then 0 else ((SD.GoodsPrice*SD.GoodsQuantity-SD.DiscountDtl) * (SH.Discount+SH.Discount2+SH.Discount3) / (SH.Amount+SH.Discount+SH.Discount2+SH.Discount3)) end HDiscount,
					SH.ProcessID,SH.FiscalYear,SH.AcntCode,SD.StoreID,SH.DocDate,SH.BRN,SD.GoodsPrice,SD.GoodsQuantity,SD.DiscountDtl,G.' + @PropertyName + ',
					ISNULL(GP.AcntCode2,'''') AcntCode2,ISNULL(GP.AcntCode3,'''') AcntCode3,ISNULL(GP.AcntCode4,'''') AcntCode4
			 FROM inv.tblStorageDocsDtl SD
			 INNER JOIN inv.tblStorageDocsHdr SH
			 on SD.ProcessID=SH.ProcessID and
				SD.ProcessNo=SH.ProcessNo and
				SD.FiscalYear=SH.FiscalYear and
				SD.SerialNo=SH.SerialNo
			 INNER JOIN inv.tblGoods G
			 ON	G.GoodsID=SD.GoodsID
			 LEFT JOIN '+ @db_0000 +'.pub.tblGoodsPropertiesAcntCodeDtl GP
			 ON G.' + @PropertyName + '=GP.PrpValue AND GP.BranchID = ''' + @BRN + '''
			 WHERE SH.Amount>0 AND SH.DocDate=''' + @strVchDate + ''' AND 
			       SH.ProcessID = ' + LTRIM(STR(@intSourceProcessID)) + ' AND 
			       SH.FiscalYear = ' + LTRIM(STR(@intSourceFiscalYear)) + ' AND 
			       SH.DocDate=''' + @strVchDate + ''' AND SH.VchNo=0 
			 ' + @StrCode + '
			 ) T
		GROUP BY T.ProcessID,T.FiscalYear,T.AcntCode,T.StoreID,T.DocDate,T.BRN,T.' + @PropertyName + ',T.AcntCode2,T.AcntCode3,T.AcntCode4'
	--PRINT @strQuery
	Exec sp_executesql @strQuery

	Declare	curInvVch CURSOR For 
		SELECT *,(Price-Discount)* @TaxP/(100+@TaxP+@TollP) Tax,(Price-Discount)*@TollP/(100+@TaxP+@TollP) Toll 
		FROM #S 
		
		Open  curInvVch; 
	
		Fetch NEXT From curInvVch Into @ProcessID,@FiscalYear,@AcntCode,@StoreID,@DocDate,@BRN,@ExtraField,@AcntCode2,@AcntCode3,@AcntCode4,@Price,@Discount,@Tax,@Toll
	
		While (@@Fetch_Status = 0)
		BEGIN
			IF @Price <> 0
				BEGIN
					SELECT	@StockAcntCode=[acc].[funMerg_AcntCode](StockAcntCode,@AcntCode2,@AcntCode3,@AcntCode4),
							@SaleTaxOverWorthAcntCode=SaleTaxOverWorthAcntCode,
							@SaleTollOverWorthAcntCode=SaleTollOverWorthAcntCode,
							@SaleDiscountAcntCode = [acc].[funMerg_AcntCode](SaleDiscountAcntCode,@AcntCode2,@AcntCode3,@AcntCode4)
					FROM inv.tblStores 
					WHERE StoreID = @StoreID
					
						SET @strRecDesc = N' اول دوره شعبه ' + @BRN + ' به تاریخ ' + @DocDate

					SET @TotalPrice = @TotalPrice + @Price - @Discount
					SET @TaxOverWorthCost = @TaxOverWorthCost + @Tax
					SET @TollOverWorthCost = @TollOverWorthCost + @Toll

					--------------------------
						SET @intMaxDocRowNo = @intMaxDocRowNo + 1
						SET @intMaxRowNo = @intMaxRowNo + 1
													
						INSERT INTO acc.tblVoucherDtl
								(SerialNo,SourceProcessID,SourceProcessNo,SourceFiscalYear,SourceSerialNo,DocDate,IsAutoDoc,SessionNo,VchKind,RowNo,DocRowNo,
									AcntCode,Debit,Credit,RecDesc,RecDesc2,SourceDocType,SourceCodeFieldValue) 
						VALUES	(@intVchNo,@intSourceProcessID,@intSourceProcessNo,@intSourceFiscalYear,@intSourceSerialNo,@strVchDate ,1,@SessionNo ,1,@intMaxRowNo ,@intMaxDocRowNo,
									@StockAcntCode,ROUND(@Price- @Tax -@Toll,0),0,TS.pub.funChangeFarsiStrings(pub.funReverseForCrystal(@strRecDesc)),'',8,@StrSourceCodeFieldValue)

				END
			Fetch NEXT From curInvVch Into @ProcessID,@FiscalYear,@AcntCode,@StoreID,@DocDate,@BRN,@ExtraField,@AcntCode2,@AcntCode3,@AcntCode4,@Price,@Discount,@Tax,@Toll
		END

		Close curInvVch;
		Deallocate curInvVch; 

	IF (SELECT COUNT(*) from #S)>0
	BEGIN
			IF @AcntCode = ''
			BEGIN
				Raiserror (N'حساب سرمایه اول دوره خالی است',16,1)
				Return
			END	

		SET @intMaxDocRowNo = @intMaxDocRowNo + 1
		SET @intMaxRowNo = @intMaxRowNo + 1

		INSERT INTO acc.tblVoucherDtl
				(SerialNo,SourceProcessID,SourceProcessNo,SourceFiscalYear,SourceSerialNo,DocDate,IsAutoDoc,SessionNo,VchKind,RowNo,DocRowNo,
					AcntCode,Debit,Credit,RecDesc,RecDesc2,SourceDocType,IsShowDetail,SourceCodeFieldValue) 
		VALUES	(@intVchNo,@intSourceProcessID,@intSourceProcessNo,@intSourceFiscalYear,@intSourceSerialNo,@strVchDate ,1,@SessionNo ,1,@intMaxRowNo ,@intMaxDocRowNo,
				 @AcntCode,0,ROUND(@TotalPrice ,0),TS.pub.funChangeFarsiStrings(pub.funReverseForCrystal(@strRecDesc)), '',8,'True',@StrSourceCodeFieldValue)

		-----------------------------------------------مالیات بر ارزش افزوده--------------------------------------------
		IF @SaleTaxOverWorthAcntCode <> '' AND @TaxOverWorthCost <> 0
			BEGIN
				--------------------------------------------------------------------------------------------------------
			
				SET @intMaxDocRowNo = @intMaxDocRowNo + 1
				SET @intMaxRowNo = @intMaxRowNo + 1

				SET @strRecDesc2 = ' مالیات ' + @strRecDesc 

				INSERT INTO acc.tblVoucherDtl
						(SerialNo,SourceProcessID,SourceProcessNo,SourceFiscalYear,SourceSerialNo,DocDate,IsAutoDoc,SessionNo,VchKind,RowNo,DocRowNo,
							AcntCode,Debit,Credit,RecDesc,RecDesc2,SourceDocType,SourceCodeFieldValue) 
				VALUES	(@intVchNo,@intSourceProcessID,@intSourceProcessNo,@intSourceFiscalYear,@intSourceSerialNo,@strVchDate ,1,@SessionNo ,1,@intMaxRowNo ,@intMaxDocRowNo,
							@SaleTaxOverWorthAcntCode,ROUND(@TaxOverWorthCost,0),0,TS.pub.funChangeFarsiStrings(pub.funReverseForCrystal(@strRecDesc2)),'',8,@StrSourceCodeFieldValue)
				
			END
			
		-----------------------------------------------عوارض بر ارزش افزوده--------------------------------------------
		IF @SaleTollOverWorthAcntCode <> '' AND @TollOverWorthCost <> 0
			BEGIN
				--------------------------------------------------------------------------------------------------------
			
				SET @intMaxDocRowNo = @intMaxDocRowNo + 1
				SET @intMaxRowNo = @intMaxRowNo + 1

				SET @strRecDesc2 = ' عوارض ' + @strRecDesc 

				INSERT INTO acc.tblVoucherDtl
						(SerialNo,SourceProcessID,SourceProcessNo,SourceFiscalYear,SourceSerialNo,DocDate,IsAutoDoc,SessionNo,VchKind,RowNo,DocRowNo,
							AcntCode,Debit,Credit,RecDesc,RecDesc2,SourceDocType,SourceCodeFieldValue) 
				VALUES	(@intVchNo,@intSourceProcessID,@intSourceProcessNo,@intSourceFiscalYear,@intSourceSerialNo,@strVchDate ,1,@SessionNo ,1,@intMaxRowNo ,@intMaxDocRowNo,
							@SaleTollOverWorthAcntCode,ROUND(@TollOverWorthCost,0),0,TS.pub.funChangeFarsiStrings(pub.funReverseForCrystal(@strRecDesc2)),'',8,@StrSourceCodeFieldValue)
				
			END
	END
	
	-----------------------------------------------روند مالیات و ارزش افزوده--------------------------------------------
	DECLARE @RoundAmount  as float
	SET @RoundAmount = 0
	SELECT @RoundAmount = SUM(Debit-Credit) 
	FROM acc.tblVoucherDtl 
	WHERE SerialNo = @intVchNo
		
	IF @RoundAmount <>0
		BEGIN
		--------------------------------------------------------------------------------------------------------
			DECLARE @TaxRoundAcntcode varchar(20)
			SET @TaxRoundAcntcode = ''
			SELECT @TaxRoundAcntcode = SettingValue
			FROM pub.tblSettings
			WHERE SettingKey = 'TaxRoundAcntcode' 
			IF @TaxRoundAcntcode = ''
			BEGIN
				Raiserror (N'حساب رند مالیات و عوارض خالی است',16,1)
				Return
			END	
			
			DECLARE @DescTaxRoundAcntcode Nvarchar(1000)
			SET @DescTaxRoundAcntcode = ''
			SELECT @DescTaxRoundAcntcode = SettingValue
			FROM pub.tblSettings
			WHERE SettingKey = 'DescTaxRoundAcntcode' 

			IF @DescTaxRoundAcntcode = ''
				SET @DescTaxRoundAcntcode =  ' رند مالیات و ارزش افزوده '

			declare @crd float,@dbt float
			IF @RoundAmount > 0
			BEGIN
				SET @dbt=0
				SET @crd= @RoundAmount
			END
			ELSE
			BEGIN
				SET @dbt=-1 * @RoundAmount 
				SET @crd= 0
			END
			
			SET @intMaxDocRowNo = @intMaxDocRowNo + 1
			SET @intMaxRowNo = @intMaxRowNo + 1

			SET @strRecDesc2 = @DescTaxRoundAcntcode + @strRecDesc 

			INSERT INTO acc.tblVoucherDtl
					(SerialNo,SourceProcessID,SourceProcessNo,SourceFiscalYear,SourceSerialNo,DocDate,IsAutoDoc,SessionNo,VchKind,RowNo,DocRowNo,
						AcntCode,Debit,Credit,RecDesc,RecDesc2,SourceDocType,SourceCodeFieldValue) 
			VALUES	(@intVchNo,@intSourceProcessID,@intSourceProcessNo,@intSourceFiscalYear,@intSourceSerialNo,@strVchDate ,1,@SessionNo ,1,@intMaxRowNo ,@intMaxDocRowNo,
						@TaxRoundAcntcode,@dbt,@crd,TS.pub.funChangeFarsiStrings(pub.funReverseForCrystal(@strRecDesc2)),'',8,@StrSourceCodeFieldValue)
				
		END
			
END
GO
