USE TS_ShirinVatanKarkhaneh_1_1404
GO
SET ANSI_NULLS, QUOTED_IDENTIFIER ON
GO
-- =========== TS-QC:NOTOK ========================
-- Author        : Hadi Sadeghi
-- Create date   : 87/07/04
-- Viewed By	 : 
-- Last Modified : 
-- Description   : 
-- =============================================
CREATE PROCEDURE [acc].[SpVchInventoryModification]
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
	
	Declare @strMsgText				NVarChar(2044)
	Declare @StockAcntCode			Varchar(20)
	Declare @StoreID				Varchar(20)
	Declare @AcntCode				Varchar(20)
	Declare @InventoryModificationAcntCode		Varchar(20)
	Declare @Amount					Float
	Declare @strRecDesc				NVarChar(1000)
	Declare @strRecDesc2			NVarChar(1000)
	Declare @strFiscalSerial		VarChar(20)
	Declare @GodossName				NVarChar(1000)
	Declare @DescDtl				NVarChar(1000)
	Declare @CurrencyRate			Float
	Declare @CurrencyAmount			Float
	Declare @CurrencyTypeID			VarChar(20)
	Declare @DocDate				VarChar(20)
	Declare @EnterKind				Int
	
	SET @CurrencyRate = 0 	
	SET @CurrencyAmount = 0 
	SET @CurrencyTypeID = ''

	--------------------------------------------------------------------------------------------------------

	-----
	SET @strFiscalSerial = LTRIM(RTRIM(STR(@intSourceFiscalYear))) + '/' + LTRIM(RTRIM(STR(@intSourceSerialNo))) 
	SET @strRecDesc=' اصلاح قیمت اقلام انبار برگه ' + LTRIM(RTRIM(STR(@intSourceFiscalYear))) + '/' + LTRIM(RTRIM(STR(@intSourceSerialNo))) 
	


	Declare	curInvVch CURSOR For 
SELECT	AcntCode,StoreID,GoodsPrice, [pub].[funGetGoodsName](GoodsID,1),DocDate,EnterKind
	FROM inv.tblStorageDocsDtl
	WHERE ProcessID=@intSourceProcessID AND
		  ProcessNo=@intSourceProcessNo AND
		  FiscalYear=@intSourceFiscalYear AND
		  SerialNo=@intSourceSerialNo 
		
		Open  curInvVch; 
	
		Fetch NEXT From curInvVch Into @AcntCode,@StoreID,@Amount,@GodossName,@DocDate,@EnterKind
	
		While (@@Fetch_Status = 0)
		BEGIN
			IF @Amount <> 0
				BEGIN
				    SELECT @InventoryModificationAcntCode=InventoryModificationAcntCode
					FROM inv.tblStores 
					WHERE StoreID = @StoreID

					IF @InventoryModificationAcntCode=''
						BEGIN
							
							SET @strMsgText=N'کد واسط اصلاح قیمت اقلام انبار ' + @StoreID + ' خالی است'
							Raiserror (@strMsgText,16,1)
							Return
						END

			-----
					IF @EnterKind = -1
					BEGIN

						SET @strRecDesc2= @strRecDesc + ' کاهش قیمت کالای ' + @GodossName + ' به تاریخ ' + @DocDate
						SET @intMaxDocRowNo = @intMaxDocRowNo + 1
						SET @intMaxRowNo = @intMaxRowNo + 1
	
						IF @CurrencyRate <> 0 	
							SET @CurrencyAmount = ROUND(@Amount,0) / @CurrencyRate
						
						INSERT INTO acc.tblVoucherDtl
								(SerialNo,SourceProcessID,SourceProcessNo,SourceFiscalYear,SourceSerialNo,DocDate,IsAutoDoc,SessionNo,VchKind,RowNo,DocRowNo,
									AcntCode,Debit,Credit,RecDesc,RecDesc2,SourceDocType,CurrencyAmount,CurrencyTypeID) 
						VALUES	(@intVchNo,@intSourceProcessID,@intSourceProcessNo,@intSourceFiscalYear,@intSourceSerialNo,@strVchDate ,1,@SessionNo ,1,@intMaxRowNo ,@intMaxDocRowNo,
									@AcntCode,ROUND(@Amount,0),0,TS.pub.funChangeFarsiStrings(pub.funReverseForCrystal(@strRecDesc2)),'',0,@CurrencyAmount ,@CurrencyTypeID)	

						-----
						SET @intMaxDocRowNo = @intMaxDocRowNo + 1
						SET @intMaxRowNo = @intMaxRowNo + 1
							
						INSERT INTO acc.tblVoucherDtl
								(SerialNo,SourceProcessID,SourceProcessNo,SourceFiscalYear,SourceSerialNo,DocDate,IsAutoDoc,SessionNo,VchKind,RowNo,DocRowNo,
									AcntCode,Debit,Credit,RecDesc,RecDesc2,SourceDocType,CurrencyAmount,CurrencyTypeID) 
						VALUES	(@intVchNo,@intSourceProcessID,@intSourceProcessNo,@intSourceFiscalYear,@intSourceSerialNo,@strVchDate ,1,@SessionNo ,1,@intMaxRowNo ,@intMaxDocRowNo,
									@InventoryModificationAcntCode,0,ROUND(@Amount,0),TS.pub.funChangeFarsiStrings(pub.funReverseForCrystal(@strRecDesc2)),'',0,@CurrencyAmount ,@CurrencyTypeID)	
			
					END
					ELSE
					BEGIN
						SET @strRecDesc2= @strRecDesc + ' افزایش قیمت کالای ' + @GodossName + ' به تاریخ ' + @DocDate
						SET @intMaxDocRowNo = @intMaxDocRowNo + 1
						SET @intMaxRowNo = @intMaxRowNo + 1
	
						IF @CurrencyRate <> 0 	
							SET @CurrencyAmount = ROUND(@Amount,0) / @CurrencyRate
						
						INSERT INTO acc.tblVoucherDtl
								(SerialNo,SourceProcessID,SourceProcessNo,SourceFiscalYear,SourceSerialNo,DocDate,IsAutoDoc,SessionNo,VchKind,RowNo,DocRowNo,
									AcntCode,Debit,Credit,RecDesc,RecDesc2,SourceDocType,CurrencyAmount,CurrencyTypeID) 
						VALUES	(@intVchNo,@intSourceProcessID,@intSourceProcessNo,@intSourceFiscalYear,@intSourceSerialNo,@strVchDate ,1,@SessionNo ,1,@intMaxRowNo ,@intMaxDocRowNo,
									@InventoryModificationAcntCode,ROUND(@Amount,0),0,TS.pub.funChangeFarsiStrings(pub.funReverseForCrystal(@strRecDesc2)),'',0,@CurrencyAmount ,@CurrencyTypeID)	

						-----
						SET @intMaxDocRowNo = @intMaxDocRowNo + 1
						SET @intMaxRowNo = @intMaxRowNo + 1
							
						INSERT INTO acc.tblVoucherDtl
								(SerialNo,SourceProcessID,SourceProcessNo,SourceFiscalYear,SourceSerialNo,DocDate,IsAutoDoc,SessionNo,VchKind,RowNo,DocRowNo,
									AcntCode,Debit,Credit,RecDesc,RecDesc2,SourceDocType,CurrencyAmount,CurrencyTypeID) 
						VALUES	(@intVchNo,@intSourceProcessID,@intSourceProcessNo,@intSourceFiscalYear,@intSourceSerialNo,@strVchDate ,1,@SessionNo ,1,@intMaxRowNo ,@intMaxDocRowNo,
									@AcntCode,0,ROUND(@Amount,0),TS.pub.funChangeFarsiStrings(pub.funReverseForCrystal(@strRecDesc2)),'',0,@CurrencyAmount ,@CurrencyTypeID)	

			
					END			

				END
			Fetch NEXT From curInvVch Into @AcntCode,@StoreID,@Amount,@GodossName,@DocDate,@EnterKind
		END

		Close curInvVch;
		Deallocate curInvVch; 

END
GO
