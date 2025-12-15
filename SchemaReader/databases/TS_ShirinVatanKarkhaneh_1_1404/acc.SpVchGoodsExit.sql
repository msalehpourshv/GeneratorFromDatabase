USE TS_ShirinVatanKarkhaneh_1_1404
GO
SET ANSI_NULLS, QUOTED_IDENTIFIER ON
GO
-- =========== TS-QC:OK ========================
-- Author        : Jafari
-- Create date   : 95/09/23
-- Viewed By	 : 
-- Last Modified : 
-- Description   : 
-- =============================================
--[acc].[SpVch_CreateDoc] @intVchNo=452,@intDocStep=2,@strVchDate='1395/07/14',@strOldVchDate='1395/07/14',@intSourceProcessID=193,@intSourceProcessNo=1,@intSourceFiscalYear=95,@intSourceSerialNo=506,@strHdrTblName='inv.tblStorageDocsHdr',@strVchNoFieldName='VchNo',@VoucherCreateMetod=2 ,@DocFormType=2 ,@SelectedUserVchNoType=1 ,@intOldVchNo=452 ,@UserID=0

Create  PROCEDURE [acc].[SpVchGoodsExit]
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
	Declare @strMsgText	NVarChar(2044)
	--Declare @PayTypeID	Tinyint
	--Declare @BankState	Tinyint
	--Declare @Amount		Bigint
	--Declare @RowDesc	Nvarchar(1000)	
	--Declare @CreditCode	Varchar(20)
	--Declare @DebitCode	Varchar(20)
	--Declare @ChequeNo	Bigint
	--Declare @ChequeDate	Char(10)
	--Declare @AcntCode2	Varchar(20)
	--Declare @AcntCode3	Varchar(20)
	--Declare @AcntCode5	Varchar(20)
	Declare @strRecDesc NVarChar(1000)
	--Declare @VolumeFiscalYear	SmallInt
	--Declare @VolumeRowNo	INT	
	--DECLARE @strSourceProcessNo NVARCHAR(100)
	--DECLARE @BaseID Int
	Declare @SaleAcntCode			Varchar(20)
	Declare @CostCenterAcntCode			Varchar(20)
	Declare @StoreID				Varchar(20)
	Declare @CurrencyRate			Float
	Declare @CurrencyAmount			Float
	DECLARE @UnitPart TINYINT
	Declare @CurrencyTypeID			VarChar(20)		
	Declare	@DtlPrice  FLOAT
	Declare @AcntCode				Varchar(20)
	Declare @TransportationCostAcntCode	Varchar(20)
	Declare @OtherCostAcntCode	Varchar(20)
	Declare @WageRateAcntCode	Varchar(20)
	--Declare @TransportationCost		Float
	DECLARE @str_Goods  tinyint
	DECLARE @str_GoodsSum tinyint
	Declare @strFiscalSerial		VarChar(50)
	Declare @WageRate Float

set @WageRateAcntCode =''

SELECT @WageRateAcntCode = SettingValue from pub.tblSettings where SettingKey = 'inv_WageRateAcntCode'

set @WageRate =0
SELECT @WageRate = SettingValue from pub.tblSettings where SettingKey = 'inv_GoodsExit_WageRate'




SET @strFiscalSerial = LTRIM(RTRIM(STR(@intSourceFiscalYear))) + '/' + LTRIM(RTRIM(STR(@intSourceSerialNo))) 

SET @CurrencyAmount = 0

SET @UnitPart  = 1
SELECT @UnitPart = SettingValue from pub.tblSettings where SettingKey = 'UnitPart'
IF @UnitPart IS NULL or @UnitPart = 0
	SET @UnitPart = 1



select @str_Goods = ISNULL(SUM (Layer1+Layer2+Layer3+Layer4+Layer5+Layer6+Layer7+Layer8+Layer9),0)
from pub.tblCodeLayer 
where TableName='inv.tblGoods' AND PartNumber<@UnitPart

select @str_GoodsSum = Layer1+Layer2+Layer3+Layer4+Layer5+Layer6+Layer7+Layer8+Layer9
from pub.tblCodeLayer 
where TableName= 'inv.tblGoods' AND PartNumber=@UnitPart

		--@StoreID=StoreID,@AcntCode=AcntCode,@AfterSaleDiscount=AfterSaleDiscount,@AfterSaleDesc=AfterSaleDesc ,
		--		@AfterSaleDiscountAcntCode=AfterSaleDiscountAcntCode ,@DescHdr= DocDesc,
		--		@BaseDistributionSerialNo = BaseDistributionSerialNo,@BaseDistributionFiscalYear=BaseDistributionFiscalYear
		--		,
		
		
		SELECT	@CurrencyTypeID=CurrencyTypeID,@CurrencyRate=CurrencyRate,@AcntCode=AcntCode
		,@StoreID=StoreID
		--,@TransportationCostAcntCode=TransportationCostAcntCode			
		FROM inv.tblStorageDocsHdr
		WHERE ProcessID=@intSourceProcessID AND
			  ProcessNo=@intSourceProcessNo AND
			  FiscalYear=@intSourceFiscalYear AND
			  SerialNo=@intSourceSerialNo 
		
		Select @TransportationCostAcntCode=TransportationCostAcntCode,@OtherCostAcntCode=OtherCostAcntCode
		From inv.tblStores Where StoreID=@StoreID
	-----------------------حساب بدهکاری
	SELECT	@DtlPrice=ROUND(SUM(s.GoodsPrice * GoodsQuantity),0)
			FROM inv.tblStorageDocsDtl s
			INNER JOIN inv.tblGoods g
			ON SUBSTRING(s.GoodsID,@str_Goods+1,@str_GoodsSum)=g.GoodsID
			WHERE 
				  ProcessID  = @intSourceProcessID AND
				  ProcessNo  = @intSourceProcessNo AND
				  FiscalYear = @intSourceFiscalYear AND
				  SerialNo   = @intSourceSerialNo
				 and g.PartNumber=@UnitPart 
				  
			group by StoreID
			
					SET @strRecDesc='خروج کالای  ' + @strFiscalSerial
	
					SET @intMaxDocRowNo = @intMaxDocRowNo + 1
					SET @intMaxRowNo = @intMaxRowNo + 1

					IF @CurrencyRate <> 0 	
						SET @CurrencyAmount = ROUND(@DtlPrice,0) / @CurrencyRate
			IF @AcntCode='' 
			BEGIN
				--کد عوارض بر ارزش افزوده در فروش خالی است
				SET @strMsgText='کد حسابداری مشتری خالی است'
				Raiserror (@strMsgText,16,1)
				Return
			END	
							
					INSERT INTO acc.tblVoucherDtl
							(SerialNo,SourceProcessID,SourceProcessNo,SourceFiscalYear,SourceSerialNo,DocDate,IsAutoDoc,SessionNo,VchKind,RowNo,DocRowNo,
								AcntCode,Debit,Credit,RecDesc,RecDesc2,SourceDocType,CurrencyAmount,CurrencyTypeID) 
					VALUES	(@intVchNo,@intSourceProcessID,@intSourceProcessNo,@intSourceFiscalYear,@intSourceSerialNo,@strVchDate ,1,@SessionNo ,1,@intMaxRowNo ,@intMaxDocRowNo,
								@AcntCode,ROUND(@DtlPrice,0) ,0,TS.pub.funChangeFarsiStrings(pub.funReverseForCrystal(@strRecDesc)),'',0,@CurrencyAmount,@CurrencyTypeID)
								
										
			
			--- کالاهای انبار
			
			Declare	curSet CURSOR For 
			SELECT	StoreID,ROUND(SUM(s.GoodsPrice * GoodsQuantity),0)
			FROM inv.tblStorageDocsDtl s
			INNER JOIN inv.tblGoods g
			ON SUBSTRING(s.GoodsID,@str_Goods+1,@str_GoodsSum)=g.GoodsID
			WHERE 
				  ProcessID  = @intSourceProcessID AND
				  ProcessNo  = @intSourceProcessNo AND
				  FiscalYear = @intSourceFiscalYear AND
				  SerialNo   = @intSourceSerialNo
				 and g.IsService='False' AND 
				 g.PartNumber=@UnitPart 
				  
			group by StoreID
			----- فاکتور فروش سطر به سطر به حساب مشتری میرود
			Open  curSet; 
		
			Fetch NEXT From curSet Into @StoreID,@DtlPrice
		
			While (@@Fetch_Status = 0)
				BEGIN
	
					SELECT	@SaleAcntCode=SaleAcntCode
					FROM inv.tblStores 
					WHERE StoreID = @StoreID
					
						SET @strRecDesc='خروج کالای هزینه اقلام '  +@strFiscalSerial
	
				
					SET @intMaxDocRowNo = @intMaxDocRowNo + 1
					SET @intMaxRowNo = @intMaxRowNo + 1

					IF @CurrencyRate <> 0 	
						SET @CurrencyAmount = ROUND(@DtlPrice,0) / @CurrencyRate
							
			IF @SaleAcntCode='' 
			BEGIN
				--کد عوارض بر ارزش افزوده در فروش خالی است
				SET @strMsgText='کد حسابداری فروش خالی است'
				Raiserror (@strMsgText,16,1)
				Return
			END	
			
					INSERT INTO acc.tblVoucherDtl
							(SerialNo,SourceProcessID,SourceProcessNo,SourceFiscalYear,SourceSerialNo,DocDate,IsAutoDoc,SessionNo,VchKind,RowNo,DocRowNo,
								AcntCode,Debit,Credit,RecDesc,RecDesc2,SourceDocType,CurrencyAmount,CurrencyTypeID) 
					VALUES	(@intVchNo,@intSourceProcessID,@intSourceProcessNo,@intSourceFiscalYear,@intSourceSerialNo,@strVchDate ,1,@SessionNo ,1,@intMaxRowNo ,@intMaxDocRowNo,
								@SaleAcntCode,0,ROUND(@DtlPrice,0) ,TS.pub.funChangeFarsiStrings(pub.funReverseForCrystal(@strRecDesc)),'',0,@CurrencyAmount,@CurrencyTypeID)
								
					Fetch NEXT From curSet Into @StoreID,@DtlPrice
				END


	Close curSet;
			Deallocate curSet; 			
-----------------------خدمات
		
			
			Declare	curSet CURSOR For 
			SELECT	StoreID,ROUND(SUM(s.GoodsPrice * GoodsQuantity),0),g.CostCenterAcntCode
			FROM inv.tblStorageDocsDtl s
			INNER JOIN inv.tblGoods g
			ON SUBSTRING(s.GoodsID,@str_Goods+1,@str_GoodsSum)=g.GoodsID
			WHERE 
				  ProcessID  = @intSourceProcessID AND
				  ProcessNo  = @intSourceProcessNo AND
				  FiscalYear = @intSourceFiscalYear AND
				  SerialNo   = @intSourceSerialNo
				 and g.IsService='True' AND 
				 g.PartNumber=@UnitPart 
				  
			group by StoreID,g.CostCenterAcntCode
			----- فاکتور فروش سطر به سطر به حساب مشتری میرود
			Open  curSet; 
		
			Fetch NEXT From curSet Into @StoreID,@DtlPrice,@CostCenterAcntCode
		
			While (@@Fetch_Status = 0)
				BEGIN
	
						SET @strRecDesc='خروج کالای هزینه خدمات  ' +@strFiscalSerial
	
					SET @intMaxDocRowNo = @intMaxDocRowNo + 1
					SET @intMaxRowNo = @intMaxRowNo + 1

					IF @CurrencyRate <> 0 	
						SET @CurrencyAmount = ROUND(@DtlPrice,0) / @CurrencyRate
							
			
		IF @CostCenterAcntCode='' 
			BEGIN
				--کد عوارض بر ارزش افزوده در فروش خالی است
				SET @strMsgText='کد حسابداری خذمات خالی است'
				Raiserror (@strMsgText,16,1)
				Return
			END	

					INSERT INTO acc.tblVoucherDtl
							(SerialNo,SourceProcessID,SourceProcessNo,SourceFiscalYear,SourceSerialNo,DocDate,IsAutoDoc,SessionNo,VchKind,RowNo,DocRowNo,
								AcntCode,Debit,Credit,RecDesc,RecDesc2,SourceDocType,CurrencyAmount,CurrencyTypeID) 
					VALUES	(@intVchNo,@intSourceProcessID,@intSourceProcessNo,@intSourceFiscalYear,@intSourceSerialNo,@strVchDate ,1,@SessionNo ,1,@intMaxRowNo ,@intMaxDocRowNo,
								@CostCenterAcntCode,0,ROUND(@DtlPrice,0) ,TS.pub.funChangeFarsiStrings(pub.funReverseForCrystal(@strRecDesc)),'',0,@CurrencyAmount,@CurrencyTypeID)
								
					Fetch NEXT From curSet Into @StoreID,@DtlPrice,@CostCenterAcntCode
				END


	Close curSet;
			Deallocate curSet; 		

------------------کرایه حمل
--		--@TransportationCost=TransportationCost
--				--SET @strRecDescTransCost = ' هزینه حمل فروش ' + @strTitleSale + @strFiscalSerial
--				SET @strRecDesc = ' كرايه حمل ' +  @strFiscalSerial 
--				--------------------------------------------------------------------------------------------------------

--			SELECT	@DtlPrice=ROUND(SUM(s.Var4),0)
--			FROM inv.tblStorageDocsDtl s
--			INNER JOIN inv.tblGoods g
--			ON SUBSTRING(s.GoodsID,@str_Goods+1,@str_GoodsSum)=g.GoodsID
--			WHERE 
--				  ProcessID  = @intSourceProcessID AND
--				  ProcessNo  = @intSourceProcessNo AND
--				  FiscalYear = @intSourceFiscalYear AND
--				  SerialNo   = @intSourceSerialNo
--				 and g.PartNumber=@UnitPart 
--			group by StoreID
			
--					SET @intMaxDocRowNo = @intMaxDocRowNo + 1
--					SET @intMaxRowNo = @intMaxRowNo + 1

--					IF @CurrencyRate <> 0 	
--						SET @CurrencyAmount = ROUND(@DtlPrice,0) / @CurrencyRate
							
--					INSERT INTO acc.tblVoucherDtl
--							(SerialNo,SourceProcessID,SourceProcessNo,SourceFiscalYear,SourceSerialNo,DocDate,IsAutoDoc,SessionNo,VchKind,RowNo,DocRowNo,
--								AcntCode,Debit,Credit,RecDesc,RecDesc2,SourceDocType,CurrencyAmount,CurrencyTypeID) 
--					VALUES	(@intVchNo,@intSourceProcessID,@intSourceProcessNo,@intSourceFiscalYear,@intSourceSerialNo,@strVchDate ,1,@SessionNo ,1,@intMaxRowNo ,@intMaxDocRowNo,
--								@AcntCode,ROUND(@DtlPrice,0) ,0,TS.pub.funChangeFarsiStrings(pub.funReverseForCrystal(@strRecDesc)),'',0,@CurrencyAmount,@CurrencyTypeID)
								
					
--						SET @intMaxDocRowNo = @intMaxDocRowNo + 1
--					SET @intMaxRowNo = @intMaxRowNo + 1

--					IF @CurrencyRate <> 0 	
--						SET @CurrencyAmount = ROUND(@DtlPrice,0) / @CurrencyRate
--			IF @TransportationCostAcntCode='' 
--			BEGIN
--				--کد عوارض بر ارزش افزوده در فروش خالی است
--				SET @strMsgText='کد حسابداری حمل خالی است'
--				Raiserror (@strMsgText,16,1)
--				Return
--			END	
				
--					INSERT INTO acc.tblVoucherDtl
--							(SerialNo,SourceProcessID,SourceProcessNo,SourceFiscalYear,SourceSerialNo,DocDate,IsAutoDoc,SessionNo,VchKind,RowNo,DocRowNo,
--								AcntCode,Debit,Credit,RecDesc,RecDesc2,SourceDocType,CurrencyAmount,CurrencyTypeID) 
--					VALUES	(@intVchNo,@intSourceProcessID,@intSourceProcessNo,@intSourceFiscalYear,@intSourceSerialNo,@strVchDate ,1,@SessionNo ,1,@intMaxRowNo ,@intMaxDocRowNo,
--								@TransportationCostAcntCode,0,ROUND(@DtlPrice,0) ,TS.pub.funChangeFarsiStrings(pub.funReverseForCrystal(@strRecDesc)),'',0,@CurrencyAmount,@CurrencyTypeID)
										
			
	
---------------  سایر کسورات 


			
			SET @strRecDesc = 'سایر کسورات    '+  @strFiscalSerial 

			--------------------------------------------------------------------------------------------------------
			SELECT	@DtlPrice=ROUND(SUM(s.Var3),0)
			FROM inv.tblStorageDocsDtl s
			INNER JOIN inv.tblGoods g
			ON SUBSTRING(s.GoodsID,@str_Goods+1,@str_GoodsSum)=g.GoodsID
			WHERE 
				  ProcessID  = @intSourceProcessID AND
				  ProcessNo  = @intSourceProcessNo AND
				  FiscalYear = @intSourceFiscalYear AND
				  SerialNo   = @intSourceSerialNo
				 and g.PartNumber=@UnitPart 
			group by StoreID
			
					SET @intMaxDocRowNo = @intMaxDocRowNo + 1
					SET @intMaxRowNo = @intMaxRowNo + 1

					IF @CurrencyRate <> 0 	
						SET @CurrencyAmount = ROUND(@DtlPrice,0) / @CurrencyRate
							
		IF @OtherCostAcntCode='' 
			BEGIN
				--کد عوارض بر ارزش افزوده در فروش خالی است
				SET @strMsgText='کد حسابداری سایر کسورت خالی است'
				Raiserror (@strMsgText,16,1)
				Return
			END
					INSERT INTO acc.tblVoucherDtl
							(SerialNo,SourceProcessID,SourceProcessNo,SourceFiscalYear,SourceSerialNo,DocDate,IsAutoDoc,SessionNo,VchKind,RowNo,DocRowNo,
								AcntCode,Debit,Credit,RecDesc,RecDesc2,SourceDocType,CurrencyAmount,CurrencyTypeID) 
					VALUES	(@intVchNo,@intSourceProcessID,@intSourceProcessNo,@intSourceFiscalYear,@intSourceSerialNo,@strVchDate ,1,@SessionNo ,1,@intMaxRowNo ,@intMaxDocRowNo,
								@OtherCostAcntCode,ROUND(@DtlPrice,0) ,0,TS.pub.funChangeFarsiStrings(pub.funReverseForCrystal(@strRecDesc)),'',0,@CurrencyAmount,@CurrencyTypeID)
								
					
						SET @intMaxDocRowNo = @intMaxDocRowNo + 1
					SET @intMaxRowNo = @intMaxRowNo + 1

					IF @CurrencyRate <> 0 	
						SET @CurrencyAmount = ROUND(@DtlPrice,0) / @CurrencyRate
										
				INSERT INTO acc.tblVoucherDtl
							(SerialNo,SourceProcessID,SourceProcessNo,SourceFiscalYear,SourceSerialNo,DocDate,IsAutoDoc,SessionNo,VchKind,RowNo,DocRowNo,
								AcntCode,Debit,Credit,RecDesc,RecDesc2,SourceDocType,CurrencyAmount,CurrencyTypeID) 
					VALUES	(@intVchNo,@intSourceProcessID,@intSourceProcessNo,@intSourceFiscalYear,@intSourceSerialNo,@strVchDate ,1,@SessionNo ,1,@intMaxRowNo ,@intMaxDocRowNo,
								@AcntCode,0,ROUND(@DtlPrice,0) ,TS.pub.funChangeFarsiStrings(pub.funReverseForCrystal(@strRecDesc)),'',0,@CurrencyAmount,@CurrencyTypeID)
				
			

---------------  مبلغ کارمزد


			
			SET @strRecDesc = 'مبلغ کارمزد    '+  @strFiscalSerial 


 

			--------------------------------------------------------------------------------------------------------
			SELECT	@DtlPrice=ROUND(SUM(s.GoodsPrice * GoodsQuantity),0)*@WageRate
			FROM inv.tblStorageDocsDtl s
			WHERE 
				  ProcessID  = @intSourceProcessID AND
				  ProcessNo  = @intSourceProcessNo AND
				  FiscalYear = @intSourceFiscalYear AND
				  SerialNo   = @intSourceSerialNo
			
			group by StoreID
			
					SET @intMaxDocRowNo = @intMaxDocRowNo + 1
					SET @intMaxRowNo = @intMaxRowNo + 1

					IF @CurrencyRate <> 0 	
						SET @CurrencyAmount = ROUND(@DtlPrice,0) / @CurrencyRate
							
					INSERT INTO acc.tblVoucherDtl
							(SerialNo,SourceProcessID,SourceProcessNo,SourceFiscalYear,SourceSerialNo,DocDate,IsAutoDoc,SessionNo,VchKind,RowNo,DocRowNo,
								AcntCode,Debit,Credit,RecDesc,RecDesc2,SourceDocType,CurrencyAmount,CurrencyTypeID) 
					VALUES	(@intVchNo,@intSourceProcessID,@intSourceProcessNo,@intSourceFiscalYear,@intSourceSerialNo,@strVchDate ,1,@SessionNo ,1,@intMaxRowNo ,@intMaxDocRowNo,
								@AcntCode,ROUND(@DtlPrice,0) ,0,TS.pub.funChangeFarsiStrings(pub.funReverseForCrystal(@strRecDesc)),'',0,@CurrencyAmount,@CurrencyTypeID)
								
					
						SET @intMaxDocRowNo = @intMaxDocRowNo + 1
					SET @intMaxRowNo = @intMaxRowNo + 1

					IF @CurrencyRate <> 0 	
						SET @CurrencyAmount = ROUND(@DtlPrice,0) / @CurrencyRate
										
		IF @WageRateAcntCode='' 
			BEGIN
				--کد عوارض بر ارزش افزوده در فروش خالی است
				SET @strMsgText='کد حسابداری کارمزد  خالی است'
				Raiserror (@strMsgText,16,1)
				Return
			END
					
					INSERT INTO acc.tblVoucherDtl
							(SerialNo,SourceProcessID,SourceProcessNo,SourceFiscalYear,SourceSerialNo,DocDate,IsAutoDoc,SessionNo,VchKind,RowNo,DocRowNo,
								AcntCode,Debit,Credit,RecDesc,RecDesc2,SourceDocType,CurrencyAmount,CurrencyTypeID) 
					VALUES	(@intVchNo,@intSourceProcessID,@intSourceProcessNo,@intSourceFiscalYear,@intSourceSerialNo,@strVchDate ,1,@SessionNo ,1,@intMaxRowNo ,@intMaxDocRowNo,
								@WageRateAcntCode,0,ROUND(@DtlPrice,0) ,TS.pub.funChangeFarsiStrings(pub.funReverseForCrystal(@strRecDesc)),'',0,@CurrencyAmount,@CurrencyTypeID)
										
			
			
END
GO
