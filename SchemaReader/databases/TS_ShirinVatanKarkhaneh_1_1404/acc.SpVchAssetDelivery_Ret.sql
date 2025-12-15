USE TS_ShirinVatanKarkhaneh_1_1404
GO
SET ANSI_NULLS, QUOTED_IDENTIFIER ON
GO
-- =========== TS-QC:OK ========================
-- Author        : jafari
-- Create date   : 1404/07/02
-- Viewed By	 : 
-- Last Modified : 
-- Description   : 
-- =============================================
Create PROCEDURE [acc].[SpVchAssetDelivery_Ret]
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
	@LanguageID				TinyInt,
	@VchKind				TinyInt = 1
WITH ENCRYPTION
AS
BEGIN
-----
Declare @strBuyTitle				NVarChar(100)
Declare @StockAcntCode				Varchar(20)
Declare @StoreID					Varchar(20)
Declare @AcntCode					Varchar(20)
Declare @DocDate					VarChar(10)
Declare @strRecDesc					NVarChar(1000)
Declare @DescHdr					NVarChar(1000)
Declare @GoodsPrice					Float
Declare @DescDtl					NVarChar(1000)
Declare @GoodsName					NVarChar(1000)
Declare @GoodsUnit					NVarChar(1000)
Declare @strRecDesc2				NVarChar(1000)
Declare	@intTmpMaxRowNo				Int
Declare @intTmpMaxDocRowNo			Int
DECLARE @BaseFiscalYear				Integer		
DECLARE @BaseSerialNo				Integer		
DECLARE @BaseProcessID				Integer		
DECLARE @BaseProcessNo				Integer	
DECLARE @strAcntName				NVarChar(500)

--------------------------------------------------------------------------------------------------------
SET @strBuyTitle = ''

DECLARE @UnitPart TINYINT
SET @UnitPart  = 1

SELECT @UnitPart = SettingValue from pub.tblSettings where SettingKey = 'UnitPart'

IF @UnitPart IS NULL or @UnitPart = 0
	SET @UnitPart = 1

DECLARE @str_Goods  tinyint,
		@str_GoodsSum tinyint
		 
select @str_Goods = ISNULL(SUM (Layer1+Layer2+Layer3+Layer4+Layer5+Layer6+Layer7+Layer8+Layer9),0)
from pub.tblCodeLayer 
where TableName='inv.tblGoods' AND PartNumber<@UnitPart

select @str_GoodsSum = Layer1+Layer2+Layer3+Layer4+Layer5+Layer6+Layer7+Layer8+Layer9
from pub.tblCodeLayer 
where TableName= 'inv.tblGoods' AND PartNumber=@UnitPart

SELECT @strBuyTitle = SettingValue
FROM pub.tblSettings
WHERE SettingKey = 'TitleBuy' + LTRIM(RTRIM(STR(@intSourceProcessNo)))


SELECT	@StoreID=StoreID,@DocDate=DocDate,@DescHdr = DocDesc,		
		@BaseProcessNo = BaseProcessNo,@BaseProcessID = BaseProcessID,@BaseSerialNo = BaseSerialNo
		,@BaseFiscalYear = BaseFiscalYear
FROM inv.tblStorageDocsHdr
WHERE ProcessID=@intSourceProcessID AND
  ProcessNo=@intSourceProcessNo AND
  FiscalYear=@intSourceFiscalYear AND
  SerialNo=@intSourceSerialNo 


	   select Top 1 @AcntCode=ObverseAcntCode
		from ast.tblAssetsHdr a
		INNER JOIN inv.tblStorageDocsDtl s
		on a.ProcessID=s.BaseProcessID
		and a.ProcessNo=s.BaseProcessNo
		and a.FiscalYear=s.BaseFiscalYear
		and a.SerialNo=s.BaseSerialNo
	WHERE 
	s.ProcessID  = @intSourceProcessID AND
	s.ProcessNo  = @intSourceProcessNo AND
	s.FiscalYear = @intSourceFiscalYear AND
	s.SerialNo   = @intSourceSerialNo
	   

SELECT @StockAcntCode=StockAcntCode
FROM inv.tblStores 
WHERE StoreID = @StoreID
 
  
		SET @strAcntName = ''
		--------11111111111111---------------------------------
		SET @strRecDesc = ' برگشت از تحویل دارایی شماره' + @strAcntName
		
		SET @intMaxDocRowNo = @intMaxDocRowNo + 1
		SET @intMaxRowNo = @intMaxRowNo + 1

		SET	@intTmpMaxRowNo = @intMaxRowNo 
		SET	@intTmpMaxDocRowNo = @intMaxDocRowNo 
			
 
		Declare	curStore CURSOR For
			SELECT	s.StoreID, g.StockAcntCode, ROUND(s.GoodsPrice,0) GoodsPrice
			FROM inv.tblStorageDocsDtl s
			INNER JOIN inv.tblStores g ON s.StoreID=g.StoreID
			INNER JOIN inv.tblGoods d ON SUBSTRING(s.GoodsID,@str_Goods+1,@str_GoodsSum)=d.GoodsID AND d.PartNumber=@UnitPart
			WHERE d.IsService='False' AND  ProcessID=@intSourceProcessID AND 
			  ProcessNo=@intSourceProcessNo AND
			  FiscalYear=@intSourceFiscalYear AND
			  SerialNo=@intSourceSerialNo 

		Open curStore;

		Fetch NEXT From curStore Into @StoreID,@StockAcntCode,@GoodsPrice

		While (@@Fetch_Status = 0)
		BEGIN
		-- سربار

		SET @intMaxDocRowNo = @intMaxDocRowNo + 1
		SET @intMaxRowNo = @intMaxRowNo + 1
	
		set  @strRecDesc2 =''
		SET @strRecDesc2 =TS.pub.funChangeFarsiStrings(pub.funReverseForCrystal(@DescHdr))
		
		INSERT INTO acc.tblVoucherDtl
				(SerialNo,SourceProcessID,SourceProcessNo,SourceFiscalYear,SourceSerialNo,DocDate,IsAutoDoc,SessionNo,VchKind,RowNo,DocRowNo,
				 AcntCode,Debit,Credit,RecDesc,RecDesc2,SourceDocType,CurrencyAmount,CurrencyTypeID,VisitorAcntCode) 
		VALUES	(@intVchNo,@intSourceProcessID,@intSourceProcessNo,@intSourceFiscalYear,@intSourceSerialNo,@strVchDate ,1,@SessionNo ,@VchKind,@intMaxRowNo ,@intMaxDocRowNo,
				 @StockAcntCode,ROUND(@GoodsPrice,0),0,TS.pub.funChangeFarsiStrings(pub.funReverseForCrystal(@strRecDesc)),@strRecDesc2,0,0,'','') 	

	 	SET @strRecDesc2 = ' برگشت از تحویل دارایی ' + @strBuyTitle + ' شماره ' + ' - ' + 
			ISNULL(@GoodsName,'') + ' - ' + ISNULL(@GoodsUnit,'') + ' - فی ' + 
			ISNULL(ltrim(rtrim(str(@GoodsPrice))),'') + @strAcntName
			
		SET @intMaxDocRowNo = @intMaxDocRowNo + 1
		SET @intMaxRowNo = @intMaxRowNo + 1
				
		SET @strRecDesc2 = ' برگشت از تحویل دارایی ' + @strBuyTitle + ' شماره' + ISNULL(@GoodsName,'') + ' - ' + ISNULL(@GoodsUnit,'') + ' - فی ' + ISNULL(ltrim(rtrim(str(@GoodsPrice))),'') + @strAcntName
				
		INSERT INTO acc.tblVoucherDtl
				(SerialNo,SourceProcessID,SourceProcessNo,SourceFiscalYear,SourceSerialNo,DocDate,IsAutoDoc,SessionNo,VchKind,RowNo,DocRowNo,
					AcntCode,Debit,Credit,RecDesc,RecDesc2,SourceDocType,CurrencyAmount,CurrencyTypeID,VisitorAcntCode) 
		VALUES	(@intVchNo,@intSourceProcessID,@intSourceProcessNo,@intSourceFiscalYear,@intSourceSerialNo,@strVchDate ,1,@SessionNo ,@VchKind,@intMaxRowNo ,@intMaxDocRowNo,
					@AcntCode,0,ROUND(@GoodsPrice,0),TS.pub.funChangeFarsiStrings(pub.funReverseForCrystal(@strRecDesc2)),TS.pub.funChangeFarsiStrings(pub.funReverseForCrystal(@DescDtl + ' - ' + @DescHdr)),0,0,'','')	
	
		FETCH NEXT From curStore Into @StoreID,@StockAcntCode,@GoodsPrice
		END -- curStore
		Close curStore;
		Deallocate curStore; 
		--?????		
 

	EXEC [acc].[SpBalanceSourceVoucher]
		 @intVchNo,
		 @intSourceProcessID,
		 @intSourceProcessNo,
		 @intSourceFiscalYear,
		 @intSourceSerialNo,
		 @StockAcntCode
	
	--------------------------------------------------------------------------------------------------------
END
GO
