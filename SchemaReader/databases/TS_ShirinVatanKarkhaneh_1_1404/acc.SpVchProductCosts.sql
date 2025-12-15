USE TS_ShirinVatanKarkhaneh_1_1404
GO
SET ANSI_NULLS, QUOTED_IDENTIFIER ON
GO
-- =========== TS-QC:NotOK ========================
-- Author        : Hadi Sadeghi
-- Create date   : 90/02/12
-- Viewed By	 : 
-- Last Modified : 
-- Description   : 
-- =============================================
CREATE PROCEDURE [acc].[SpVchProductCosts]
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
	@LanguageID				TinyInt
	WITH ENCRYPTION
AS

BEGIN
	-----
	
	Declare @GoodsInProductionAcntCode	Varchar(20)
	Declare @DtlAcntCode			Varchar(20)
	Declare @SumPrice				Float


	Declare @GoodsQuantity			Float
	Declare @strRecDesc				NVarChar(1000)
	Declare @DocDesc				NVarChar(1000)
	Declare @GoodsPrice				Float
	Declare	@intTmpMaxRowNo			Int
	Declare @intTmpMaxDocRowNo		Int
	
	--------------------------------------------------------------------------------------------------------
	SET @SumPrice = 0

	SELECT	@GoodsInProductionAcntCode=GoodsInProductionAcntCode,@DocDesc=DocDesc
	FROM prd.tblProductCostsHdr
	WHERE ProcessID=@intSourceProcessID AND
		  ProcessNo=@intSourceProcessNo AND
		  FiscalYear=@intSourceFiscalYear AND
		  SerialNo=@intSourceSerialNo 

	SET @strRecDesc = ' هزینه تولید شماره' + LTRIM(RTRIM(STR(@intSourceSerialNo)))  

	-----
	SET @intMaxDocRowNo = @intMaxDocRowNo + 1
	SET @intMaxRowNo = @intMaxRowNo + 1
	
	SET	@intTmpMaxRowNo = @intMaxRowNo 
	SET	@intTmpMaxDocRowNo = @intMaxDocRowNo 
	
	Declare	curProductCosts CURSOR For 
	SELECT	AcntCode,Amount,Quantity
	FROM prd.tblProductCostsDtl
	WHERE ProcessID=@intSourceProcessID AND
		  ProcessNo=@intSourceProcessNo AND
		  FiscalYear=@intSourceFiscalYear AND
		  SerialNo=@intSourceSerialNo 

	Open curProductCosts;
		
	Fetch NEXT From curProductCosts Into @DtlAcntCode,@GoodsPrice,@GoodsQuantity

	While (@@Fetch_Status = 0)
		BEGIN
							
			SET @intMaxDocRowNo = @intMaxDocRowNo + 1
			SET @intMaxRowNo = @intMaxRowNo + 1
			
			SET @SumPrice = @SumPrice + ROUND(@GoodsPrice * @GoodsQuantity,0)
		
			INSERT INTO acc.tblVoucherDtl
					(SerialNo,SourceProcessID,SourceProcessNo,SourceFiscalYear,SourceSerialNo,DocDate,IsAutoDoc,SessionNo,VchKind,RowNo,DocRowNo,
					 AcntCode,Debit,Credit,RecDesc,RecDesc2,SourceDocType,CurrencyAmount) 
			VALUES	(@intVchNo,@intSourceProcessID,@intSourceProcessNo,@intSourceFiscalYear,@intSourceSerialNo,@strVchDate ,1,@SessionNo ,1,@intMaxRowNo ,@intMaxDocRowNo,
					 @DtlAcntCode,0,ROUND(@GoodsPrice * @GoodsQuantity,0),TS.pub.funChangeFarsiStrings(pub.funReverseForCrystal(@strRecDesc)),TS.pub.funChangeFarsiStrings(pub.funReverseForCrystal(@DocDesc)),0,0)	

			Fetch NEXT From curProductCosts Into @DtlAcntCode,@GoodsPrice,@GoodsQuantity
		END

	Close curProductCosts;
	Deallocate curProductCosts; 	


	INSERT INTO acc.tblVoucherDtl
			(SerialNo,SourceProcessID,SourceProcessNo,SourceFiscalYear,SourceSerialNo,DocDate,IsAutoDoc,SessionNo,VchKind,RowNo,DocRowNo,
			 AcntCode,Debit,Credit,RecDesc,RecDesc2,SourceDocType,CurrencyAmount) 
	VALUES	(@intVchNo,@intSourceProcessID,@intSourceProcessNo,@intSourceFiscalYear,@intSourceSerialNo,@strVchDate ,1,@SessionNo ,1,@intTmpMaxRowNo ,@intTmpMaxDocRowNo,
			 @GoodsInProductionAcntCode,@SumPrice,0,TS.pub.funChangeFarsiStrings(pub.funReverseForCrystal(@strRecDesc)),TS.pub.funChangeFarsiStrings(pub.funReverseForCrystal(@DocDesc)),0,0)	
			 
END
GO
