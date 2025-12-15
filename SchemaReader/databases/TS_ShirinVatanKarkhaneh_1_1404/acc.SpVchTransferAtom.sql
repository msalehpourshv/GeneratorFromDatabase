USE TS_ShirinVatanKarkhaneh_1_1404
GO
SET ANSI_NULLS, QUOTED_IDENTIFIER ON
GO
-- =========== TS-QC:OK ========================
-- Author        : Hadi Sadeghi
-- Create date   : 86/07/04
-- Viewed By	 : Majid Mohammadi
-- Last Modified : 86/11/23
-- Description   : 
-- =============================================
Create PROCEDURE [acc].[SpVchTransferAtom]
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
	
	Declare @strMsgText			NVarChar(2044)
	Declare @TransferStockAcntCode		Varchar(20)
	Declare @StoreID			Varchar(20)
	Declare @AtomAcntCode		Varchar(20)
	
	Declare @SumTransferAtom	Float
	Declare @AtomAmount			Float
	Declare @GoodsQuantity		Float
	Declare @AtomDesc			NVarChar(1000)
	Declare @strRecDesc			NVarChar(1000)
	Declare @strFiscalSerial	NVarChar(70)
	Declare @DescDtl			NVarChar(1000)
	Declare	@intTmpMaxRowNo		Int
	Declare @intTmpMaxDocRowNo	Int
	Declare @HasVAT				bit
	Declare @BuyTaxOverWorthAcntCode	Varchar(20)
	Declare @BuyTollOverWorthAcntCode	Varchar(20)

	Declare @TaxOverWorthCost	Float
	Declare @TollOverWorthCost	Float
	Declare @TaxP				Float
	Declare @TollP				Float 
	
	--------------------------------------------------------------------------------------------------------
	SET @SumTransferAtom = 0
	
	SELECT	@StoreID=StoreID
	FROM inv.tblStorageDocsHdr
	WHERE ProcessID=@intSourceProcessID AND
		  ProcessNo=@intSourceProcessNo AND
		  FiscalYear=@intSourceFiscalYear AND
		  SerialNo=@intSourceSerialNo 

    SELECT @TransferStockAcntCode=TransferStockAcntCode
    FROM inv.tblStores 
    WHERE StoreID = @StoreID

	IF not (@TransferStockAcntCode is null or @TransferStockAcntCode='')
		BEGIN
		
	-----
	SET @intMaxDocRowNo = @intMaxDocRowNo + 1
	SET @intMaxRowNo = @intMaxRowNo + 1
	
	SET	@intTmpMaxRowNo = @intMaxRowNo 
	SET	@intTmpMaxDocRowNo = @intMaxDocRowNo 

	SET @strFiscalSerial = LTRIM(RTRIM(STR(@intSourceFiscalYear))) + '/' + LTRIM(RTRIM(STR(@intSourceSerialNo))) 
	
	Declare	Cursor_TransferAtom CURSOR For 
	SELECT	AtomAcntCode,AtomAmount,GoodsQuantity,AtomDesc,HasVAT
	FROM inv.tblStorageDocsAtom
	WHERE ProcessID=@intSourceProcessID AND
		  ProcessNo=@intSourceProcessNo AND
		  FiscalYear=@intSourceFiscalYear AND
		  SerialNo=@intSourceSerialNo 

	-----
	Open  Cursor_TransferAtom; 

	Fetch NEXT From Cursor_TransferAtom Into @AtomAcntCode,@AtomAmount,@GoodsQuantity,@AtomDesc,@HasVAT

	While (@@Fetch_Status = 0)
		BEGIN
		
			SET @strRecDesc=' سربار انتقال '  + @strFiscalSerial 
			SET @strRecDesc= @strRecDesc + '  ' + @AtomDesc
			SET @intMaxDocRowNo = @intMaxDocRowNo + 1
			SET @intMaxRowNo = @intMaxRowNo + 1

			SET @SumTransferAtom = @SumTransferAtom +	ROUND(@AtomAmount * @GoodsQuantity,0)
			
			INSERT INTO acc.tblVoucherDtl
					(SerialNo,SourceProcessID,SourceProcessNo,SourceFiscalYear,SourceSerialNo,DocDate,IsAutoDoc,SessionNo,VchKind,RowNo,DocRowNo,
					 AcntCode,Debit,Credit,RecDesc,RecDesc2,SourceDocType) 
			VALUES	(@intVchNo,@intSourceProcessID,@intSourceProcessNo,@intSourceFiscalYear,@intSourceSerialNo,@strVchDate ,1,@SessionNo ,1,@intMaxRowNo ,@intMaxDocRowNo,
					 @AtomAcntCode,0,ROUND(@AtomAmount * @GoodsQuantity,0),TS.pub.funChangeFarsiStrings(pub.funReverseForCrystal(@strRecDesc)),'',0 )	
----------مالیات و عوارض سربار----------------------------------------------------------------------------------------------
		
			SELECT @TaxP=SettingValue from pub.tblSettings where SettingKey ='TaxOverWorthPercent'
			SELECT @TollP=SettingValue from pub.tblSettings where SettingKey ='TollOverWorthPercent'
			
			set @TaxOverWorthCost=0
			set @TollOverWorthCost=0

			if @HasVAT='True'
				begin
					set @TaxOverWorthCost=@AtomAmount*@GoodsQuantity*@TaxP/100
					set @TollOverWorthCost=@AtomAmount*@GoodsQuantity*@TollP/100
				end 
		
			SELECT @BuyTaxOverWorthAcntCode = BuyTaxOverWorthAcntCode,
				   @BuyTollOverWorthAcntCode = BuyTollOverWorthAcntCode
			FROM inv.tblStores 
			WHERE StoreID = @StoreID

-----
			IF @BuyTaxOverWorthAcntCode <> '' AND @TaxOverWorthCost <> 0	
			BEGIN

				SET @strRecDesc=' مالیات بر ارزش افزوده سربار انتقال ' +@strFiscalSerial  + '  ' + @AtomDesc

				SET @intMaxDocRowNo = @intMaxDocRowNo + 1
				SET @intMaxRowNo = @intMaxRowNo + 1

				INSERT INTO acc.tblVoucherDtl
						(SerialNo,SourceProcessID,SourceProcessNo,SourceFiscalYear,SourceSerialNo,DocDate,IsAutoDoc,SessionNo,VchKind,RowNo,DocRowNo,
							AcntCode,Debit,Credit,RecDesc,RecDesc2,SourceDocType) 
				VALUES	(@intVchNo,@intSourceProcessID,@intSourceProcessNo,@intSourceFiscalYear,@intSourceSerialNo,@strVchDate ,1,@SessionNo ,1,@intMaxRowNo ,@intMaxDocRowNo,
							@BuyTaxOverWorthAcntCode,ROUND(@TaxOverWorthCost,0),0,TS.pub.funChangeFarsiStrings(pub.funReverseForCrystal(@strRecDesc)),'',0 )	
	
						-----
						SET @intMaxDocRowNo = @intMaxDocRowNo + 1
						SET @intMaxRowNo = @intMaxRowNo + 1

						INSERT INTO acc.tblVoucherDtl
								(SerialNo,SourceProcessID,SourceProcessNo,SourceFiscalYear,SourceSerialNo,DocDate,IsAutoDoc,SessionNo,VchKind,RowNo,DocRowNo,
									AcntCode,Debit,Credit,RecDesc,RecDesc2,SourceDocType) 
						VALUES	(@intVchNo,@intSourceProcessID,@intSourceProcessNo,@intSourceFiscalYear,@intSourceSerialNo,@strVchDate ,1,@SessionNo ,1,@intMaxRowNo ,@intMaxDocRowNo,
									@AtomAcntCode,0,ROUND(@TaxOverWorthCost,0),TS.pub.funChangeFarsiStrings(pub.funReverseForCrystal(@strRecDesc)),'',0)	
			END
			IF @BuyTollOverWorthAcntCode <> '' AND  @TollOverWorthCost <> 0	
			BEGIN

				SET @strRecDesc=' عوارض بر ارزش افزوده سربار انتقال ' +@strFiscalSerial  + '  ' + @AtomDesc

				SET @intMaxDocRowNo = @intMaxDocRowNo + 1
				SET @intMaxRowNo = @intMaxRowNo + 1

				INSERT INTO acc.tblVoucherDtl
						(SerialNo,SourceProcessID,SourceProcessNo,SourceFiscalYear,SourceSerialNo,DocDate,IsAutoDoc,SessionNo,VchKind,RowNo,DocRowNo,
							AcntCode,Debit,Credit,RecDesc,RecDesc2,SourceDocType) 
				VALUES	(@intVchNo,@intSourceProcessID,@intSourceProcessNo,@intSourceFiscalYear,@intSourceSerialNo,@strVchDate ,1,@SessionNo ,1,@intMaxRowNo ,@intMaxDocRowNo,
							@BuyTaxOverWorthAcntCode,ROUND(@TollOverWorthCost,0),0,TS.pub.funChangeFarsiStrings(pub.funReverseForCrystal(@strRecDesc)),'',0 )	
	
						-----
						SET @intMaxDocRowNo = @intMaxDocRowNo + 1
						SET @intMaxRowNo = @intMaxRowNo + 1

						INSERT INTO acc.tblVoucherDtl
								(SerialNo,SourceProcessID,SourceProcessNo,SourceFiscalYear,SourceSerialNo,DocDate,IsAutoDoc,SessionNo,VchKind,RowNo,DocRowNo,
									AcntCode,Debit,Credit,RecDesc,RecDesc2,SourceDocType) 
						VALUES	(@intVchNo,@intSourceProcessID,@intSourceProcessNo,@intSourceFiscalYear,@intSourceSerialNo,@strVchDate ,1,@SessionNo ,1,@intMaxRowNo ,@intMaxDocRowNo,
									@AtomAcntCode,0,ROUND(@TollOverWorthCost,0),TS.pub.funChangeFarsiStrings(pub.funReverseForCrystal(@strRecDesc)),'',0)	
			END
----------مالیات و عوارض سربار----------------------------------------------------------------------------------------------


			Fetch NEXT From Cursor_TransferAtom Into @AtomAcntCode,@AtomAmount,@GoodsQuantity,@AtomDesc,@HasVAT
			
		END

	Close Cursor_TransferAtom;
	Deallocate Cursor_TransferAtom;
	 		
	IF @SumTransferAtom IS NULL OR @SumTransferAtom = 0
		BEGIN
			IF (SELECT COUNT(*) FROM acc.tblVoucherDtl WHERE SerialNo = @intVchNo ) = 0
				BEGIN
					DELETE FROM acc.tblVoucherHdr WHERE SerialNo = @intVchNo
				END	
				
			UPDATE 	inv.tblStorageDocsHdr 
			SET VchNo = 0
			WHERE ProcessID = @intSourceProcessID AND
				  ProcessNo = @intSourceProcessNo AND
				  FiscalYear = @intSourceFiscalYear AND 
				  SerialNo =  @intSourceSerialNo
		END
	ELSE
		BEGIN
		SET @strRecDesc=' جمع سربار انتقال '  + @strFiscalSerial 
			INSERT INTO acc.tblVoucherDtl
					(SerialNo,SourceProcessID,SourceProcessNo,SourceFiscalYear,SourceSerialNo,DocDate,IsAutoDoc,SessionNo,VchKind,RowNo,DocRowNo,
						AcntCode,Debit,Credit,RecDesc,RecDesc2,SourceDocType,IsShowDetail) 
			VALUES	(@intVchNo,@intSourceProcessID,@intSourceProcessNo,@intSourceFiscalYear,@intSourceSerialNo,@strVchDate ,1,@SessionNo ,1,@intTmpMaxRowNo ,@intTmpMaxDocRowNo ,
						@TransferStockAcntCode,@SumTransferAtom,0,TS.pub.funChangeFarsiStrings(pub.funReverseForCrystal(@strRecDesc)),'',0 ,'True')	
		END	
		END	
	else
	begin	
	
	--Close Cursor_StoreID;
	--Deallocate Cursor_StoreID;
	--return 
	Declare	Cursor_StoreID CURSOR For 
	SELECT	Distinct StoreID
	FROM inv.tblStorageDocsDtl
	WHERE ProcessID=@intSourceProcessID AND
		  ProcessNo=@intSourceProcessNo AND
		  FiscalYear=@intSourceFiscalYear AND
		  SerialNo=@intSourceSerialNo 

	-----
	Open  Cursor_StoreID; 

	Fetch NEXT From Cursor_StoreID Into @StoreID

	While (@@Fetch_Status = 0)
		BEGIN
		-----------------------------------------------------------------------------------------------------------
		
			SELECT @TransferStockAcntCode=TransferStockAcntCode
			FROM inv.tblStores 
			WHERE StoreID = @StoreID

			IF @TransferStockAcntCode is null or @TransferStockAcntCode=''
				begin	-- کد حسابداری واسطه انتقالی بین دو انبار خالی است
						SET @strMsgText=TS.pub.funGetMessages(11044,@LanguageID)
						Close Cursor_StoreID;
						Deallocate Cursor_StoreID;
						Set @strMsgText=@strMsgText + ' انبار '  +  @StoreID 
						Raiserror (@strMsgText,16,1)
						Return
				END
			-----
					set @SumTransferAtom=0
					
					SET @intMaxDocRowNo = @intMaxDocRowNo + 1
					SET @intMaxRowNo = @intMaxRowNo + 1
					
					SET	@intTmpMaxRowNo = @intMaxRowNo 
					SET	@intTmpMaxDocRowNo = @intMaxDocRowNo 

					SET @strFiscalSerial = LTRIM(RTRIM(STR(@intSourceFiscalYear))) + '/' + LTRIM(RTRIM(STR(@intSourceSerialNo))) 
					
					Declare	Cursor_TransferAtom CURSOR For 
					SELECT	AtomAcntCode,AtomAmount,GoodsQuantity,AtomDesc
					FROM inv.tblStorageDocsAtom
					WHERE ProcessID=@intSourceProcessID AND
						  ProcessNo=@intSourceProcessNo AND
						  FiscalYear=@intSourceFiscalYear AND
						  SerialNo=@intSourceSerialNo AND
						  DocRowNo in(SELECT	DocRowNo
									FROM inv.tblStorageDocsDtl
									WHERE ProcessID=@intSourceProcessID AND
										  ProcessNo=@intSourceProcessNo AND
										  FiscalYear=@intSourceFiscalYear AND
										  SerialNo=@intSourceSerialNo AND 
										  StoreID=@StoreID )
					-----
					Open  Cursor_TransferAtom; 

					Fetch NEXT From Cursor_TransferAtom Into @AtomAcntCode,@AtomAmount,@GoodsQuantity,@AtomDesc

					While (@@Fetch_Status = 0)
						BEGIN
						
							SET @strRecDesc=' سربار انتقال '  + @strFiscalSerial 
							SET @strRecDesc= @strRecDesc + '  ' + @AtomDesc
							SET @intMaxDocRowNo = @intMaxDocRowNo + 1
							SET @intMaxRowNo = @intMaxRowNo + 1

							SET @SumTransferAtom = @SumTransferAtom +	ROUND(@AtomAmount * @GoodsQuantity,0)
							
							INSERT INTO acc.tblVoucherDtl
									(SerialNo,SourceProcessID,SourceProcessNo,SourceFiscalYear,SourceSerialNo,DocDate,IsAutoDoc,SessionNo,VchKind,RowNo,DocRowNo,
									 AcntCode,Debit,Credit,RecDesc,RecDesc2,SourceDocType) 
							VALUES	(@intVchNo,@intSourceProcessID,@intSourceProcessNo,@intSourceFiscalYear,@intSourceSerialNo,@strVchDate ,1,@SessionNo ,1,@intMaxRowNo ,@intMaxDocRowNo,
									 @AtomAcntCode,0,ROUND(@AtomAmount * @GoodsQuantity,0),TS.pub.funChangeFarsiStrings(pub.funReverseForCrystal(@strRecDesc)),'',0 )	

							Fetch NEXT From Cursor_TransferAtom Into @AtomAcntCode,@AtomAmount,@GoodsQuantity,@AtomDesc
							
						END

					Close Cursor_TransferAtom;
					Deallocate Cursor_TransferAtom;
					 		
					IF @SumTransferAtom IS NULL OR @SumTransferAtom = 0
						BEGIN
							IF (SELECT COUNT(*) FROM acc.tblVoucherDtl WHERE SerialNo = @intVchNo ) = 0
								BEGIN
									DELETE FROM acc.tblVoucherHdr WHERE SerialNo = @intVchNo
								END	
								
							UPDATE 	inv.tblStorageDocsHdr 
							SET VchNo = 0
							WHERE ProcessID = @intSourceProcessID AND
								  ProcessNo = @intSourceProcessNo AND
								  FiscalYear = @intSourceFiscalYear AND 
								  SerialNo =  @intSourceSerialNo
						END
					ELSE
						BEGIN
						SET @strRecDesc=' جمع سربار انتقال '  + @strFiscalSerial 
							INSERT INTO acc.tblVoucherDtl
									(SerialNo,SourceProcessID,SourceProcessNo,SourceFiscalYear,SourceSerialNo,DocDate,IsAutoDoc,SessionNo,VchKind,RowNo,DocRowNo,
										AcntCode,Debit,Credit,RecDesc,RecDesc2,SourceDocType,IsShowDetail) 
							VALUES	(@intVchNo,@intSourceProcessID,@intSourceProcessNo,@intSourceFiscalYear,@intSourceSerialNo,@strVchDate ,1,@SessionNo ,1,@intTmpMaxRowNo ,@intTmpMaxDocRowNo ,
										@TransferStockAcntCode,@SumTransferAtom,0,TS.pub.funChangeFarsiStrings(pub.funReverseForCrystal(@strRecDesc)),'',0 ,'True')	

					
						END	
						
		-----------------------------------------------------------------------------------------------------------
			Fetch NEXT From Cursor_StoreID Into @StoreID
			
		END

	Close Cursor_StoreID;
	Deallocate Cursor_StoreID;

	end
END
GO
