USE TS_ShirinVatanKarkhaneh_1_1404
GO
SET ANSI_NULLS, QUOTED_IDENTIFIER ON
GO
-- =========== TS-QC:OK ========================
-- Author        : Hadi Sadeghi
-- Create date   :
-- Viewed By	 : 
-- Last Modified : 
-- Description   : 
-- =============================================
CREATE PROCEDURE [acc].[SpVchSaleStocks]
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
	
	Declare @strMsgText				NVarChar(2044)

	Declare @BrokerageID			Varchar(20)
	Declare @BrokerageName			Nvarchar(500)
	Declare @StocksSymbolID			Varchar(20)
	Declare @StocksSymbolName		NVarchar(500)
	Declare @BrokerAcntCode			Varchar(20)
	Declare @StocksSymbolAcntCode	Varchar(20)
	Declare @CostIncomeAcntCode		Varchar(20)
	Declare @StocksQuantity			Float
	Declare @StocksPrice			Float
	Declare @StocksAmount			Float
	Declare @BrokerWage				Float
 	Declare @strRecDesc				NVarChar(1000)
 	Declare @strRecDesc1			NVarChar(1000)
	DECLARE @StrSelect				NVarChar(4000);

	declare @db_0000 as varchar(300)= Substring(db_name(), 1, Len(db_name()) - 4) + '0000'

	CREATE TABLE #tbl_StocksSale
	(
		BrokerageID			varchar(20),
		BrokerageName		Nvarchar(500),
		StocksSymbolID		Nvarchar(20),
		StocksSymbolName	Nvarchar(500),
		StocksQuantity		float,
		StocksPrice			float,
		BrokerWage			float,
	    StocksAmount		Float,
		BrokerAcntCode		varchar(20),
		StocksSymbolAcntCode	varchar(20),
		CostIncomeAcntCode	varchar(20),
	);

		SET @StrSelect = '
		INSERT INTO #tbl_StocksSale
		SELECT	S.BrokerageID,BD.BrokerageName,S.StocksSymbolID,SSD.StocksSymbolName,StocksQuantity,StocksPrice,BrokerWage,StocksAmount,B.BrokerAcntCode,SS.StocksSymbolAcntCode,SS.CostIncomeAcntCode
		FROM ' + @db_0000 + '.[brs].[tblStocksDtl] S
		INNER JOIN ' + @db_0000 + '.[brs].[tblBrokerage] B ON S.BrokerageID=B.BrokerageID
		INNER JOIN ' + @db_0000 + '.[brs].[tblBrokerageDtl] BD ON S.BrokerageID=BD.BrokerageID AND BD.LanguageID=1
		INNER JOIN ' + @db_0000 + '.[brs].[tblStocksSymbol]  SS ON S.StocksSymbolID=SS.StocksSymbolID
		INNER JOIN ' + @db_0000 + '.[brs].[tblStocksSymbolDtl]  SSD ON S.StocksSymbolID=SSD.StocksSymbolID AND SSD.LanguageID=1
		WHERE ProcessID=' + str(@intSourceProcessID) + ' AND
			  ProcessNo=' + str(@intSourceProcessNo) + ' AND
			  FiscalYear=' + str(@intSourceFiscalYear)+ ' AND
			  SerialNo=' + str(@intSourceSerialNo) 

	EXEC sp_executesql @StrSelect;

	--------------------------------------------------------------------------------------------------------
	SET @strRecDesc = 'سند فروش سهام ' + LTRIM(RTRIM(STR(@intSourceFiscalYear))) + '/' + LTRIM(RTRIM(STR(@intSourceSerialNo))) 
	
		Declare	curAdvance CURSOR For 
		SELECT	*
		FROM #tbl_StocksSale
	
		Open  curAdvance; 
			
		Fetch NEXT From curAdvance Into @BrokerageID, @BrokerageName,@StocksSymbolID,@StocksSymbolName,@StocksQuantity,@StocksPrice,@BrokerWage,@StocksAmount,@BrokerAcntCode,@StocksSymbolAcntCode,@CostIncomeAcntCode
	
		While (@@Fetch_Status = 0)
		
			BEGIN
			
				IF @StocksPrice <> 0
					BEGIN

						IF @BrokerAcntCode = ''
							BEGIN
								
								Close curAdvance;
								Deallocate curAdvance; 	
								
								--کد حساب کارگزاری خالی است
								SET @strMsgText=N'کد حساب کارگزاری خالی است'
								Raiserror (@strMsgText,16,1)
								Return

							END

						IF @StocksSymbolAcntCode = ''
							BEGIN
								
								Close curAdvance;
								Deallocate curAdvance; 	
								
								--کد حساب کارگزاری خالی است
								SET @strMsgText=N'کد حساب موجودی سهام ' + @StocksSymbolID + ' خالی است'
								Raiserror (@strMsgText,16,1)
								Return

							END

						IF @CostIncomeAcntCode = ''
							BEGIN
								
								Close curAdvance;
								Deallocate curAdvance; 	
								
								--کد حساب کارگزاری خالی است
								SET @strMsgText=N'کد حساب درآمد/هزینه سهام ' + @StocksSymbolID + ' خالی است'
								Raiserror (@strMsgText,16,1)
								Return


							END

						set @strRecDesc1 = @strRecDesc + ' کارگزاری ' + @BrokerageName + ' نماد ' + @StocksSymbolName + ' به تعداد ' + LTRIM(RTRIM(str(@StocksQuantity)))
						SET @intMaxDocRowNo = @intMaxDocRowNo + 1
						SET @intMaxRowNo = @intMaxRowNo + 1
			
						INSERT INTO acc.tblVoucherDtl
								(SerialNo,SourceProcessID,SourceProcessNo,SourceFiscalYear,SourceSerialNo,DocDate,IsAutoDoc,SessionNo,VchKind,RowNo,DocRowNo,
								 AcntCode,Debit,Credit,RecDesc,RecDesc2,SourceDocType) 
						VALUES	(@intVchNo,@intSourceProcessID,@intSourceProcessNo,@intSourceFiscalYear,@intSourceSerialNo,@strVchDate ,1,@SessionNo ,1,@intMaxRowNo ,@intMaxDocRowNo,
								 @BrokerAcntCode,ROUND((@StocksQuantity*@StocksPrice)-@BrokerWage,0),0,TS.pub.funChangeFarsiStrings(pub.funReverseForCrystal(@strRecDesc1)),'',0)	


						SET @intMaxDocRowNo = @intMaxDocRowNo + 1
						SET @intMaxRowNo = @intMaxRowNo + 1

						INSERT INTO acc.tblVoucherDtl
								(SerialNo,SourceProcessID,SourceProcessNo,SourceFiscalYear,SourceSerialNo,DocDate,IsAutoDoc,SessionNo,VchKind,RowNo,DocRowNo,
									AcntCode,Debit,Credit,RecDesc,RecDesc2,SourceDocType) 
						VALUES	(@intVchNo,@intSourceProcessID,@intSourceProcessNo,@intSourceFiscalYear,@intSourceSerialNo,@strVchDate ,1,@SessionNo ,1,@intMaxRowNo ,@intMaxDocRowNo,
								 @StocksSymbolAcntCode,0,ROUND(@StocksQuantity*@StocksAmount,0),TS.pub.funChangeFarsiStrings(pub.funReverseForCrystal(@strRecDesc1)),'',0 )	


						SET @intMaxDocRowNo = @intMaxDocRowNo + 1
						SET @intMaxRowNo = @intMaxRowNo + 1
						
						declare @Price float = ROUND((@StocksQuantity*@StocksPrice)-@BrokerWage,0)-ROUND(@StocksQuantity*@StocksAmount,0)

						IF @Price >0
						BEGIN
							set @strRecDesc1 = 'درآمد' + @strRecDesc1 

							INSERT INTO acc.tblVoucherDtl
									(SerialNo,SourceProcessID,SourceProcessNo,SourceFiscalYear,SourceSerialNo,DocDate,IsAutoDoc,SessionNo,VchKind,RowNo,DocRowNo,
										AcntCode,Debit,Credit,RecDesc,RecDesc2,SourceDocType) 
							VALUES	(@intVchNo,@intSourceProcessID,@intSourceProcessNo,@intSourceFiscalYear,@intSourceSerialNo,@strVchDate ,1,@SessionNo ,1,@intMaxRowNo ,@intMaxDocRowNo,
									 @CostIncomeAcntCode,0,@Price,TS.pub.funChangeFarsiStrings(pub.funReverseForCrystal(@strRecDesc1)),'',0 )	
						END
						ELSE IF @Price <0
						BEGIN
							set @strRecDesc1 = ' هزینه '  + @strRecDesc1 

							INSERT INTO acc.tblVoucherDtl
									(SerialNo,SourceProcessID,SourceProcessNo,SourceFiscalYear,SourceSerialNo,DocDate,IsAutoDoc,SessionNo,VchKind,RowNo,DocRowNo,
										AcntCode,Debit,Credit,RecDesc,RecDesc2,SourceDocType) 
							VALUES	(@intVchNo,@intSourceProcessID,@intSourceProcessNo,@intSourceFiscalYear,@intSourceSerialNo,@strVchDate ,1,@SessionNo ,1,@intMaxRowNo ,@intMaxDocRowNo,
									 @CostIncomeAcntCode,ABS(@Price),0,TS.pub.funChangeFarsiStrings(pub.funReverseForCrystal(@strRecDesc1)),'',0 )	
						END

					END
	
				Fetch NEXT From curAdvance Into @BrokerageID, @BrokerageName,@StocksSymbolID,@StocksSymbolName,@StocksQuantity,@StocksPrice,@BrokerWage,@StocksAmount,@BrokerAcntCode,@StocksSymbolAcntCode,@CostIncomeAcntCode
			END
	
		Close curAdvance;
		Deallocate curAdvance; 	


END
GO
