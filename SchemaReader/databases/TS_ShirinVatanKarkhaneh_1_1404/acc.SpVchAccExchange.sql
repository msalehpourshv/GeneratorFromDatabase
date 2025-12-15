USE TS_ShirinVatanKarkhaneh_1_1404
GO
SET ANSI_NULLS, QUOTED_IDENTIFIER ON
GO
-- =========== TS-QC:NOTOK ========================
-- Author        : Hadi Sadeghi
-- Create date   : 92/02/09
-- Viewed By	 : 
-- Last Modified : 
-- Description   : 
-- =============================================
CREATE PROCEDURE [acc].[SpVchAccExchange]
	@intVchNo				Int,
	@intDocStep				TinyInt,
    @strVchDate				Char(10),
	@intSourceProcessID		SMALLINT,
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
	
	Declare @DocDesc			NVarChar(max)
	Declare @strRecDesc			NVarChar(1000)
	Declare @strFiscalSerial	VarChar(20)
	Declare @AcntCode			Varchar(20)
	Declare @ExchangeAcntCode	Varchar(20)
	Declare @CurrencyTypeID		Varchar(20)
	Declare @ExchangeAmount		BIGINT
	Declare @SumExchangeAmount	BIGINT
	DECLARE @SaleOrderAcntCode	VARCHAR(20)

	--------------------------------------------------------------------------------------------------------
	--------------------------------------------------------------------------------------------------------
	SELECT @ExchangeAcntCode = ExchangeAcntCode,
		   @CurrencyTypeID = CurrencyTypeID, 
		   @DocDesc = DocDesc
	FROM acc.tblAccExchangeHdr
	WHERE ProcessID = @intSourceProcessID 
	  AND ProcessNo = @intSourceProcessNo 
	  AND FiscalYear = @intSourceFiscalYear 
	  AND SerialNo = @intSourceSerialNo 

	--------------------------------------------------------------------------------------------------------
	SET @strFiscalSerial = LTRIM(RTRIM(STR(@intSourceFiscalYear))) + '/' + LTRIM(RTRIM(STR(@intSourceSerialNo)))

	SET @strRecDesc = N' تسعیر ارز به شماره برگه ' + @strFiscalSerial 
	------------------------------------------------ ÓÝÇÑÔ ÝÑæÔ --------------------------------------------------------
	
	SELECT @SumExchangeAmount = SUM(ExchangeAmount)
	FROM  acc.tblAccExchangeDtl
	WHERE ProcessID = @intSourceProcessID 
	  AND ProcessNo = @intSourceProcessNo 
	  AND FiscalYear = @intSourceFiscalYear 
	  AND SerialNo = @intSourceSerialNo
		   
	SET @intMaxDocRowNo = @intMaxDocRowNo + 1
	SET @intMaxRowNo = @intMaxRowNo + 1
	
	IF @SumExchangeAmount > 0
		INSERT INTO acc.tblVoucherDtl
				(SerialNo,SourceProcessID,SourceProcessNo,SourceFiscalYear,SourceSerialNo,
				 DocDate,IsAutoDoc,SessionNo,VchKind,RowNo,
				 DocRowNo,AcntCode,Debit,Credit,RecDesc,
				 RecDesc2,SourceDocType,CurrencyAmount,CurrencyTypeID)
		VALUES	(@intVchNo,@intSourceProcessID,@intSourceProcessNo,@intSourceFiscalYear,@intSourceSerialNo,
				 @strVchDate ,1,@SessionNo ,1,@intMaxRowNo ,
				 @intMaxDocRowNo, @ExchangeAcntCode, 0, ROUND(@SumExchangeAmount,0),TS.pub.funChangeFarsiStrings(pub.funReverseForCrystal(@strRecDesc)),
				 TS.pub.funChangeFarsiStrings(pub.funReverseForCrystal(@DocDesc)),0,0,@CurrencyTypeID )	
	ELSE IF @SumExchangeAmount < 0
		INSERT INTO acc.tblVoucherDtl
				(SerialNo,SourceProcessID,SourceProcessNo,SourceFiscalYear,SourceSerialNo,
				 DocDate,IsAutoDoc,SessionNo,VchKind,RowNo,
				 DocRowNo,AcntCode,Debit,Credit,RecDesc,
				 RecDesc2,SourceDocType,CurrencyAmount,CurrencyTypeID)
		VALUES	(@intVchNo,@intSourceProcessID,@intSourceProcessNo,@intSourceFiscalYear,@intSourceSerialNo,
				 @strVchDate ,1,@SessionNo ,1,@intMaxRowNo ,
				 @intMaxDocRowNo, @ExchangeAcntCode,ROUND(@SumExchangeAmount * (-1),0) ,0,TS.pub.funChangeFarsiStrings(pub.funReverseForCrystal(@strRecDesc)),
				 TS.pub.funChangeFarsiStrings(pub.funReverseForCrystal(@DocDesc)),0,0,@CurrencyTypeID )	
	
	--------------------------------------------------------------------------------------------------------
	DECLARE	Cursor_Exchange CURSOR For 
	SELECT	AcntCode,ExchangeAmount
	FROM  acc.tblAccExchangeDtl
	WHERE ProcessID=@intSourceProcessID AND
		  ProcessNo=@intSourceProcessNo AND
		  FiscalYear=@intSourceFiscalYear AND
		  SerialNo=@intSourceSerialNo 

	Open  Cursor_Exchange; 

	Fetch NEXT From Cursor_Exchange Into @AcntCode,@ExchangeAmount

	While (@@Fetch_Status = 0)
		BEGIN
			SET @intMaxDocRowNo = @intMaxDocRowNo + 1
			SET @intMaxRowNo = @intMaxRowNo + 1
				
			IF @ExchangeAmount > 0
				INSERT INTO acc.tblVoucherDtl
						(SerialNo,SourceProcessID,SourceProcessNo,SourceFiscalYear,SourceSerialNo,
						DocDate,IsAutoDoc,SessionNo,VchKind,RowNo,
						DocRowNo, AcntCode,Debit,Credit,RecDesc,
						RecDesc2,SourceDocType,CurrencyAmount,CurrencyTypeID)
				VALUES	(@intVchNo,@intSourceProcessID,@intSourceProcessNo,@intSourceFiscalYear,@intSourceSerialNo,
						 @strVchDate ,1,@SessionNo ,1,@intMaxRowNo ,
						 @intMaxDocRowNo, @AcntCode,ROUND(@ExchangeAmount,0) ,0,TS.pub.funChangeFarsiStrings(pub.funReverseForCrystal(@strRecDesc)),
						 TS.pub.funChangeFarsiStrings(pub.funReverseForCrystal(@DocDesc)),0,0,@CurrencyTypeID )	
			ELSE IF @ExchangeAmount < 0
				INSERT INTO acc.tblVoucherDtl
						(SerialNo,SourceProcessID,SourceProcessNo,SourceFiscalYear,SourceSerialNo,
						 DocDate,IsAutoDoc,SessionNo,VchKind,RowNo,
						 DocRowNo, AcntCode,Debit,Credit,RecDesc,
						 RecDesc2,SourceDocType,CurrencyAmount,CurrencyTypeID)
				VALUES	(@intVchNo,@intSourceProcessID,@intSourceProcessNo,@intSourceFiscalYear,@intSourceSerialNo,
						 @strVchDate ,1,@SessionNo ,1,@intMaxRowNo ,
						 @intMaxDocRowNo, @AcntCode ,0,ROUND(@ExchangeAmount * (-1),0),TS.pub.funChangeFarsiStrings(pub.funReverseForCrystal(@strRecDesc)),
						 TS.pub.funChangeFarsiStrings(pub.funReverseForCrystal(@DocDesc)),0,0,@CurrencyTypeID )	

			Fetch NEXT From Cursor_Exchange Into @AcntCode,@ExchangeAmount
		END
		
		Close Cursor_Exchange;
		Deallocate Cursor_Exchange; 			
END
GO
