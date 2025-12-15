USE TS_ShirinVatanKarkhaneh_1_1404
GO
SET ANSI_NULLS, QUOTED_IDENTIFIER ON
GO
-- =========== TS-QC:OK ========================
-- Author        : Hadi Sadeghi
-- Create date   : 90/05/13
-- Viewed By	 : Majid Mohammadi
-- Last Modified : 
-- Description   : 
-- =============================================
CREATE PROCEDURE [acc].[SpVchPln_TaskOrder]
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
	
	Declare @WageCostAcntCode	Varchar(20)
	Declare @StoreID			Varchar(20)
	Declare @ProducerAcntCode			Varchar(20)
	Declare @ProductID			Varchar(20)
	Declare @strRecDesc			NVarChar(1000)
	Declare @strRecDescDtl		NVarChar(1000)
	Declare @strMsgText			NVarChar(2044)
	Declare @DescDtl			NVarChar(1000)
	Declare @FormulaNo			INT
	
	
	--------------------------------------------------------------------------------------------------------
	SELECT  @ProducerAcntCode=ProducerAcntCode,@ProductID=ProductID,@FormulaNo = FormulaNo
	FROM pln.tblTaskOrderHdr
	WHERE ProcessID=@intSourceProcessID AND
		  ProcessNo=@intSourceProcessNo AND
		  FiscalYear=@intSourceFiscalYear AND
		  SerialNo=@intSourceSerialNo 

	SELECT @StoreID=StoreID
	FROM inv.tblStorageDocsHdr
	WHERE BaseProcessID=@intSourceProcessID AND
		  BaseProcessNo=@intSourceProcessNo AND
		  BaseFiscalYear=@intSourceFiscalYear AND
		  BaseSerialNo=@intSourceSerialNo AND
		  ProcessID=72	
		  
   SELECT @WageCostAcntCode=WageCostAcntCode	
   FROM inv.tblStores 
   WHERE StoreID = @StoreID

	IF @WageCostAcntCode=''
		BEGIN
			--کد هزینه دستمزد در تولید خالی است
			SET @strMsgText=TS.pub.funGetMessages(16013,@LanguageID)
			Raiserror (@strMsgText,16,1)
			Return
		END
	
	Declare @GoodsQuantity			Float
	Declare @FormulaProductCount	Float
	Declare @Wage					Float
	Declare @GoodsName				NVarChar(1000)
	SET  @Wage = 0
	SET  @FormulaProductCount = 0
	
	SELECT TOP 1 @FormulaProductCount =GoodsQuantity , @Wage = WageAmount from prd.tblProducersWageDtl
	where GoodsID = @ProductID AND ProducerAcntCode = @ProducerAcntCode
	order by SerialNo  DESC

	IF @Wage = 0
		SELECT @FormulaProductCount = ProductCount, @Wage = Wage1
		FROM  prd.tblFormulasOverLoadHdr
		WHERE ProductID = @ProductID AND SerialNo = @FormulaNo 
			And (OverLoadProduct=1 or (OverLoadProduct=0 and OverLoadDecomposition=0))
	
	IF @Wage=0  OR @Wage IS NULL
	BEGIN
		--دستمزد برای این کالا تعریف نشده است
		SET @strMsgText='دستمزد برای این کالا تعریف نشده است'
		Raiserror (@strMsgText,16,1)
		Return
	END
	
	SET @strRecDesc=' توليد '  + LTRIM(RTRIM(STR(@intSourceFiscalYear))) + '/' + LTRIM(RTRIM(STR(@intSourceSerialNo))) 
	
	 
	SELECT	TOP 1 @GoodsQuantity = AcceptableCount,@GoodsName = pub.funGetGoodsName(@ProductID,@LanguageID)
	FROM pln.tblTaskOrderDtl
	WHERE ProcessID=@intSourceProcessID AND
		  ProcessNo=@intSourceProcessNo AND
		  FiscalYear=@intSourceFiscalYear AND
		  SerialNo=@intSourceSerialNo 
	ORDER BY RowNo	DESC 


	SET @strRecDescDtl = @strRecDesc + ' - ' + @GoodsName + ' - ' + ' به تعداد ' + LTRIM(RTRIM(STR(@GoodsQuantity))) + ' ' + ' - ' + ' با نرخ ' + LTRIM(RTRIM(STR(ROUND(@Wage/@FormulaProductCount,2))))
	
	SET @intMaxDocRowNo = @intMaxDocRowNo + 1
	SET @intMaxRowNo = @intMaxRowNo + 1
					
	INSERT INTO acc.tblVoucherDtl 
			(SerialNo,SourceProcessID,SourceProcessNo,SourceFiscalYear,SourceSerialNo,DocDate,IsAutoDoc,SessionNo,VchKind,RowNo,DocRowNo,
				AcntCode,Debit,Credit,RecDesc,RecDesc2,SourceDocType) 
	VALUES	(@intVchNo,@intSourceProcessID,@intSourceProcessNo,@intSourceFiscalYear,@intSourceSerialNo,@strVchDate ,1,@SessionNo ,1,@intMaxRowNo ,@intMaxDocRowNo,
			 @WageCostAcntCode,ROUND(@GoodsQuantity * @Wage / @FormulaProductCount,0),0,TS.pub.funChangeFarsiStrings(pub.funReverseForCrystal(@strRecDescDtl)),'',0)	

	-----
	SET @intMaxDocRowNo = @intMaxDocRowNo + 1
	SET @intMaxRowNo = @intMaxRowNo + 1

	INSERT INTO acc.tblVoucherDtl
			(SerialNo,SourceProcessID,SourceProcessNo,SourceFiscalYear,SourceSerialNo,DocDate,IsAutoDoc,SessionNo,VchKind,RowNo,DocRowNo,
				AcntCode,Debit,Credit,RecDesc,RecDesc2,SourceDocType) 
	VALUES	(@intVchNo,@intSourceProcessID,@intSourceProcessNo,@intSourceFiscalYear,@intSourceSerialNo,@strVchDate ,1,@SessionNo ,1,@intMaxRowNo ,@intMaxDocRowNo,
			 @ProducerAcntCode,0,ROUND(@GoodsQuantity * @Wage / @FormulaProductCount,0),TS.pub.funChangeFarsiStrings(pub.funReverseForCrystal(@strRecDescDtl)),'',0 )	
	 
	
END

GO
