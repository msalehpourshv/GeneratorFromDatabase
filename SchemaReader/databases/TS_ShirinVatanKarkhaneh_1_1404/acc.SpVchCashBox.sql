USE TS_ShirinVatanKarkhaneh_1_1404
GO
SET ANSI_NULLS, QUOTED_IDENTIFIER ON
GO
-- =========== TS-QC:OK ========================
-- Author        : Hadi Sadeghi
-- Create date   : 92/09/04
-- Viewed By	 : 
-- Last Modified : 93/02/08
-- Description   : 
-- =============================================
create PROCEDURE [acc].[SpVchCashBox]
	@intVchNo				Int,
	@intDocStep				TinyInt,
    @strVchDate				Char(10),
	@intSourceProcessID		SmallInt,
	@intSourceProcessNo		TinyInt,
	@intSourceFiscalYear	SmallInt,
	@intSourceSerialNo		Int,
	@StrSourceCodeFieldValue VARCHAR(500),
	@StrSourceCodeFieldName VARCHAR(500),
	@intMaxRowNo			Int,
	@intMaxDocRowNo			Int,
	@SessionNo				Int,
	@LanguageID				TINYINT
	WITH ENCRYPTION
AS

BEGIN
	-----
	
	Declare @SaleAcntCode			Varchar(20)
	Declare @SaleDiscountAcntCode	Varchar(20)
	Declare @USerID					Varchar(20)
	Declare @RowNo					Varchar(20)
	Declare @DocDate				char(10)
	Declare @strRecDesc				NVarChar(1000)
	Declare @strRecDesc2			NVarChar(100)
	Declare @DiscountResonDesc		NVarChar(1000)
	Declare @Price					Float
	Declare @DiscountAmount			Float
	Declare @PayedAmount			Float
	Declare @ReciptionSerialNo		int
	Declare @ReciptionFiscalYear	int
	Declare	@intTmpMaxRowNo			Int
	Declare @intTmpMaxDocRowNo		Int
	Declare @PhrSaleAcntCode		Varchar(20)
	Declare @ReciptionSerialNoA		INT
	Declare @ReciptionFiscalYearA	INT
	Declare @EventNo				INT
	Declare @PayTypeID				INT
	Declare @DocRowNo				INT
	Declare @AtomRowNo				INT
	Declare @ProficiencyCost		float
	Declare @InformaticCost			float
	Declare @BoxingCost				float
	Declare @PlusCost				float
	Declare @ProficiencyCostAcntCode		varchar(20)
	Declare @InformaticCostAcntCode			varchar(20)
	Declare @BoxingCostAcntCode				varchar(20)
	Declare @PlusCostAcntCode				varchar(20)
		
	select @ProficiencyCostAcntCode=SettingValue
	from pub.tblSettings where SettingKey='PhrProfCostAcntCode'
	
		
	select @InformaticCostAcntCode=SettingValue
	from pub.tblSettings where SettingKey='PhrInformaticCostAcntCode'
	
	select @BoxingCostAcntCode=SettingValue
	from pub.tblSettings where SettingKey='PhrBoxingCostAcntCode'
	
	select @PlusCostAcntCode=SettingValue
	from pub.tblSettings where SettingKey='PhrOtherCostAcntCode'
	
	
	SET @ReciptionFiscalYearA = pub.funSplitString(@StrSourceCodeFieldValue, '@', 1) 
	SET @ReciptionSerialNoA = pub.funSplitString(@StrSourceCodeFieldValue, '@', 2) 
	SET @EventNo = pub.funSplitString(@StrSourceCodeFieldValue, '@', 3) 

	-----
	SET @Price = 0
	
	SET @intMaxDocRowNo = @intMaxDocRowNo + 1
	SET @intMaxRowNo = @intMaxRowNo + 1

	SET	@intTmpMaxRowNo = @intMaxRowNo 
	SET	@intTmpMaxDocRowNo = @intMaxDocRowNo 

	
		Declare	curAfterSale CURSOR For 
			SELECT A.AcntCode,A.PayedAmount,A.ReciptionSerialNo,
			A.ReciptionFiscalYear,A.PayTypeID,A.DocRowNo,A.AtomRowNo,
			R.ProficiencyCost,R.InformaticCost,R.BoxingCost,R.PlusCost,
			A.BankReceiptNo
			FROM  phr.tblCashBoxDtl D
			INNER JOIN phr.tblCashBoxAtm A 
			ON D.SerialNo=A.SerialNo AND D.DocRowNo=A.DocRowNo AND
			 D.DocDate=A.DocDate AND D.UserID=A.UserID
			 inner join phr.tblReciptionHdr R
			 on R.SerialNo=D.ReciptionSerialNo 
			 AND R.FiscalYear=D.ReciptionFiscalYear
			WHERE A.SerialNo = @intSourceSerialNo AND 
			A.ReciptionFiscalYear = @ReciptionFiscalYearA AND 
			A.ReciptionSerialNo = @ReciptionSerialNoA AND D.EventNo = @EventNo
				  
      			   
      	 Open  curAfterSale; 
			
		Fetch NEXT From curAfterSale Into @SaleAcntCode,@PayedAmount,
		@ReciptionSerialNoA,@ReciptionFiscalYearA,@PayTypeID,
		@DocRowNo,@AtomRowNo,@ProficiencyCost,@InformaticCost,
		@BoxingCost,@PlusCost,@strRecDesc2
	
	 			
		While (@@Fetch_Status = 0)
		
			BEGIN
				SET @strRecDesc = N' برگه پذيرش ' + LTRIM(RTRIM(STR(@ReciptionSerialNoA))) 
				--IF @SaleAcntCode = '' 
				--BEGIN  
					SELECT @SaleAcntCode = SaleAcntCode
					FROM inv.tblStores
					WHERE  StoreID = (SELECT TOP 1 StoreID 
					                  FROM phr.tblReciptionHdr 
					                  WHERE FiscalYear = @ReciptionFiscalYearA  AND 
											SerialNo = @ReciptionSerialNoA )
					
					IF @SaleAcntCode = ''
					BEGIN
						
						Close curAfterSale;
						Deallocate curAfterSale; 	
						Raiserror (N'کد حسابداري  فروش در انبار خالي است',16,1)
						Return
					END
					
				
											
				SELECT @SaleDiscountAcntCode = SaleDiscountAcntCode 
				FROM inv.tblStores
				WHERE  StoreID = (SELECT TOP 1 StoreID 
				                  FROM phr.tblReciptionHdr 
				                  WHERE FiscalYear = @ReciptionFiscalYearA  AND 
										SerialNo = @ReciptionSerialNoA )
								
				SELECT  @DiscountAmount=Discount,@DiscountResonDesc = DiscountReason
				FROM phr.tblReciptionHdr 
				WHERE FiscalYear = @ReciptionFiscalYearA  AND 
					  SerialNo = @ReciptionSerialNoA
				
				--if @PayTypeID=1
				--	SELECT @PhrSaleAcntCode = PhrSaleAcntCode		  
				--	  FROM phr.tblReciptionHdr 
				--	  WHERE FiscalYear = @ReciptionFiscalYearA  AND 
				--	  SerialNo = @ReciptionSerialNoA
				--else
					SELECT @PhrSaleAcntCode =  AcntCode		  
					  FROM phr.tblCashBoxAtm
					  WHERE ReciptionFiscalYear = @ReciptionFiscalYearA  AND 
					  ReciptionSerialNo = @ReciptionSerialNoA AND 
					  DocRowNo = @DocRowNo AND 
					  AtomRowNo = @AtomRowNo
				
					
					
				IF @PhrSaleAcntCode = ''
					BEGIN
						
						Close curAfterSale;
						Deallocate curAfterSale; 	
						Raiserror (N'کد حسابداري  فروش در برگه پذيرش خالي است',16,1)
						Return
					END
										
				IF @DiscountAmount <> 0 AND @SaleDiscountAcntCode = ''
					BEGIN
						
						Close curAfterSale;
						Deallocate curAfterSale; 	
						Raiserror (N'کد حسابداري تخفيفات فروش در تعريف انبار خالي است',16,1)
						Return
					END
				if 	@SaleDiscountAcntCode is null
				begin
				print 1
				end
				
				IF @DiscountAmount <> 0
				BEGIN
					SET @intMaxDocRowNo = @intMaxDocRowNo + 1
					SET @intMaxRowNo = @intMaxRowNo + 1
		
					INSERT INTO acc.tblVoucherDtl
							(SerialNo,SourceProcessID,SourceProcessNo,SourceFiscalYear,SourceSerialNo,DocDate,IsAutoDoc,SessionNo,VchKind,RowNo,DocRowNo,
							 AcntCode,Debit,Credit,RecDesc,RecDesc2,SourceDocType,SourceCodeFieldValue) 
					VALUES	(@intVchNo,@intSourceProcessID,@intSourceProcessNo,@intSourceFiscalYear,@intSourceSerialNo,@strVchDate ,1,@SessionNo ,1,@intMaxRowNo ,@intMaxDocRowNo,
							 @SaleDiscountAcntCode,@DiscountAmount,0,TS.pub.funChangeFarsiStrings(pub.funReverseForCrystal(@strRecDesc)),@strRecDesc2,0,@StrSourceCodeFieldValue)

					SET @intMaxDocRowNo = @intMaxDocRowNo + 1
					SET @intMaxRowNo = @intMaxRowNo + 1
					
					INSERT INTO acc.tblVoucherDtl
							(SerialNo,SourceProcessID,SourceProcessNo,SourceFiscalYear,SourceSerialNo,DocDate,IsAutoDoc,SessionNo,VchKind,RowNo,DocRowNo,
							 AcntCode,Debit,Credit,RecDesc,RecDesc2,SourceDocType,SourceCodeFieldValue) 
					VALUES	(@intVchNo,@intSourceProcessID,@intSourceProcessNo,@intSourceFiscalYear,@intSourceSerialNo,@strVchDate ,1,@SessionNo ,1,@intMaxRowNo ,@intMaxDocRowNo,
							 @SaleAcntCode,0,@DiscountAmount,TS.pub.funChangeFarsiStrings(pub.funReverseForCrystal(@strRecDesc)),@strRecDesc2,0,@StrSourceCodeFieldValue)
							 	
				END
				

				IF @PayedAmount <> 0
				BEGIN
					
				if @EventNo=1
					begin
						SET @PayedAmount=@PayedAmount-@ProficiencyCost
						-@InformaticCost-@BoxingCost-@PlusCost
					
					if @PayedAmount<0
						set @PayedAmount=0
								
					SET @intMaxDocRowNo = @intMaxDocRowNo + 1
					SET @intMaxRowNo = @intMaxRowNo + 1
					
					SET @Price = @PayedAmount
					
					IF @PayedAmount>0
						INSERT INTO acc.tblVoucherDtl
								(SerialNo,SourceProcessID,SourceProcessNo,SourceFiscalYear,SourceSerialNo,DocDate,IsAutoDoc,SessionNo,VchKind,RowNo,DocRowNo,
								 AcntCode,Debit,Credit,RecDesc,RecDesc2,SourceDocType,SourceCodeFieldValue) 
						VALUES	(@intVchNo,@intSourceProcessID,@intSourceProcessNo,@intSourceFiscalYear,@intSourceSerialNo,@strVchDate ,1,@SessionNo ,1,@intMaxRowNo ,@intMaxDocRowNo,
								 @SaleAcntCode,0,@PayedAmount,TS.pub.funChangeFarsiStrings(pub.funReverseForCrystal(@strRecDesc)),@strRecDesc2,0,@StrSourceCodeFieldValue)
					ELSE	
						INSERT INTO acc.tblVoucherDtl
								(SerialNo,SourceProcessID,SourceProcessNo,SourceFiscalYear,SourceSerialNo,DocDate,IsAutoDoc,SessionNo,VchKind,RowNo,DocRowNo,
								 AcntCode,Debit,Credit,RecDesc,RecDesc2,SourceDocType,SourceCodeFieldValue) 
						VALUES	(@intVchNo,@intSourceProcessID,@intSourceProcessNo,@intSourceFiscalYear,@intSourceSerialNo,@strVchDate ,1,@SessionNo ,1,@intMaxRowNo ,@intMaxDocRowNo,
								 @SaleAcntCode,-1*@PayedAmount,0,TS.pub.funChangeFarsiStrings(pub.funReverseForCrystal(@strRecDesc)),@strRecDesc2,0,@StrSourceCodeFieldValue)
									 	
				END
			
			if @EventNo>1
							
						
				begin
					IF @PayedAmount<0
					begin
					
					SET @intMaxDocRowNo = @intMaxDocRowNo + 1
					SET @intMaxRowNo = @intMaxRowNo + 1
					
						INSERT INTO acc.tblVoucherDtl
								(SerialNo,SourceProcessID,SourceProcessNo,SourceFiscalYear,SourceSerialNo,DocDate,IsAutoDoc,SessionNo,VchKind,RowNo,DocRowNo,
								 AcntCode,Debit,Credit,RecDesc,RecDesc2,SourceDocType,SourceCodeFieldValue) 
						VALUES	(@intVchNo,@intSourceProcessID,@intSourceProcessNo,@intSourceFiscalYear,@intSourceSerialNo,@strVchDate ,1,@SessionNo ,1,@intMaxRowNo ,@intMaxDocRowNo,
								 @SaleAcntCode,-1*@PayedAmount,0,TS.pub.funChangeFarsiStrings(pub.funReverseForCrystal(@strRecDesc)),@strRecDesc2,0,@StrSourceCodeFieldValue)
						
					SET @intMaxDocRowNo = @intMaxDocRowNo + 1
					SET @intMaxRowNo = @intMaxRowNo + 1
				
					INSERT INTO acc.tblVoucherDtl
								(SerialNo,SourceProcessID,SourceProcessNo,SourceFiscalYear,SourceSerialNo,DocDate,IsAutoDoc,SessionNo,VchKind,RowNo,DocRowNo,
								 AcntCode,Debit,Credit,RecDesc,RecDesc2,SourceDocType,SourceCodeFieldValue) 
						VALUES	(@intVchNo,@intSourceProcessID,@intSourceProcessNo,@intSourceFiscalYear,@intSourceSerialNo,@strVchDate ,1,@SessionNo ,1,@intMaxRowNo ,@intMaxDocRowNo,
								 @PhrSaleAcntCode,0,-1*@PayedAmount,TS.pub.funChangeFarsiStrings(pub.funReverseForCrystal(@strRecDesc)),@strRecDesc2,0,@StrSourceCodeFieldValue)
									 
					end
				end
				
					
			END
				
			SET @intMaxDocRowNo = @intMaxDocRowNo + 1
			SET @intMaxRowNo = @intMaxRowNo + 1
			
			IF @Price>0
			
				INSERT INTO acc.tblVoucherDtl
						(SerialNo,SourceProcessID,SourceProcessNo,SourceFiscalYear,SourceSerialNo,DocDate,IsAutoDoc,SessionNo,VchKind,RowNo,DocRowNo,
						 AcntCode,Debit,Credit,RecDesc,RecDesc2,SourceDocType,SourceCodeFieldValue) 
				VALUES	(@intVchNo,@intSourceProcessID,@intSourceProcessNo,@intSourceFiscalYear,@intSourceSerialNo,@strVchDate ,1,@SessionNo ,1,@intMaxRowNo ,@intMaxDocRowNo,
						 @PhrSaleAcntCode,@Price,0,TS.pub.funChangeFarsiStrings(pub.funReverseForCrystal(@strRecDesc)),@strRecDesc2,0,@StrSourceCodeFieldValue)	
			ELSE
				INSERT INTO acc.tblVoucherDtl
						(SerialNo,SourceProcessID,SourceProcessNo,SourceFiscalYear,SourceSerialNo,DocDate,IsAutoDoc,SessionNo,VchKind,RowNo,DocRowNo,
						 AcntCode,Debit,Credit,RecDesc,RecDesc2,SourceDocType,SourceCodeFieldValue) 
				VALUES	(@intVchNo,@intSourceProcessID,@intSourceProcessNo,@intSourceFiscalYear,@intSourceSerialNo,@strVchDate ,1,@SessionNo ,1,@intMaxRowNo ,@intMaxDocRowNo,
						 @PhrSaleAcntCode,0,-1*@Price,TS.pub.funChangeFarsiStrings(pub.funReverseForCrystal(@strRecDesc)),@strRecDesc2,0,@StrSourceCodeFieldValue)	
		
		
		
		
				Fetch NEXT From curAfterSale Into @SaleAcntCode,@PayedAmount,
				@ReciptionSerialNoA,@ReciptionFiscalYearA,@PayTypeID,
				@DocRowNo,@AtomRowNo,@ProficiencyCost,@InformaticCost,
				@BoxingCost,@PlusCost,@strRecDesc2
	
			END
		
		
	
	
  if @EventNo=1 --ProfCost,PlusCost,InfoCost,BoxCost
	
	BEGIN
	
		if @ProficiencyCost<>0
			begin
		
			IF @ProficiencyCostAcntCode = ''
					BEGIN
						
						Close curAfterSale;
						Deallocate curAfterSale; 	
						Raiserror (N'کد حسابداري  حق فنی خالي است',16,1)
						Return
					END
					
			SET @intMaxDocRowNo = @intMaxDocRowNo + 1
			SET @intMaxRowNo = @intMaxRowNo + 1
		
			INSERT INTO acc.tblVoucherDtl
							(SerialNo,SourceProcessID,SourceProcessNo,SourceFiscalYear,SourceSerialNo,DocDate,IsAutoDoc,SessionNo,VchKind,RowNo,DocRowNo,
							 AcntCode,Debit,Credit,RecDesc,RecDesc2,SourceDocType,SourceCodeFieldValue) 
					VALUES	(@intVchNo,@intSourceProcessID,@intSourceProcessNo,@intSourceFiscalYear,@intSourceSerialNo,@strVchDate ,1,@SessionNo ,1,@intMaxRowNo ,@intMaxDocRowNo,
							 @PhrSaleAcntCode,@ProficiencyCost,0,TS.pub.funChangeFarsiStrings(pub.funReverseForCrystal(@strRecDesc)),@strRecDesc2,0,@StrSourceCodeFieldValue)	
			
			SET @intMaxDocRowNo = @intMaxDocRowNo + 1
			SET @intMaxRowNo = @intMaxRowNo + 1
						
			INSERT INTO acc.tblVoucherDtl
							(SerialNo,SourceProcessID,SourceProcessNo,SourceFiscalYear,SourceSerialNo,DocDate,IsAutoDoc,SessionNo,VchKind,RowNo,DocRowNo,
							 AcntCode,Debit,Credit,RecDesc,RecDesc2,SourceDocType,SourceCodeFieldValue) 
					VALUES	(@intVchNo,@intSourceProcessID,@intSourceProcessNo,@intSourceFiscalYear,@intSourceSerialNo,@strVchDate ,1,@SessionNo ,1,@intMaxRowNo ,@intMaxDocRowNo,
							 @ProficiencyCostAcntCode,0,@ProficiencyCost,TS.pub.funChangeFarsiStrings(pub.funReverseForCrystal(@strRecDesc)),@strRecDesc2,0,@StrSourceCodeFieldValue)	
				
		end		 
	
	if @PlusCost<>0
		begin
		
		IF @PlusCostAcntCode = ''
					BEGIN
						
						Close curAfterSale;
						Deallocate curAfterSale; 	
						Raiserror (N'کد حسابداري  اضافات خالي است',16,1)
						Return
					END
					
			SET @intMaxDocRowNo = @intMaxDocRowNo + 1
			SET @intMaxRowNo = @intMaxRowNo + 1
		
			INSERT INTO acc.tblVoucherDtl
							(SerialNo,SourceProcessID,SourceProcessNo,SourceFiscalYear,SourceSerialNo,DocDate,IsAutoDoc,SessionNo,VchKind,RowNo,DocRowNo,
							 AcntCode,Debit,Credit,RecDesc,RecDesc2,SourceDocType,SourceCodeFieldValue) 
					VALUES	(@intVchNo,@intSourceProcessID,@intSourceProcessNo,@intSourceFiscalYear,@intSourceSerialNo,@strVchDate ,1,@SessionNo ,1,@intMaxRowNo ,@intMaxDocRowNo,
							 @PhrSaleAcntCode,@PlusCost,0,TS.pub.funChangeFarsiStrings(pub.funReverseForCrystal(@strRecDesc)),@strRecDesc2,0,@StrSourceCodeFieldValue)	
			
			SET @intMaxDocRowNo = @intMaxDocRowNo + 1
			SET @intMaxRowNo = @intMaxRowNo + 1
				
			INSERT INTO acc.tblVoucherDtl
							(SerialNo,SourceProcessID,SourceProcessNo,SourceFiscalYear,SourceSerialNo,DocDate,IsAutoDoc,SessionNo,VchKind,RowNo,DocRowNo,
							 AcntCode,Debit,Credit,RecDesc,RecDesc2,SourceDocType,SourceCodeFieldValue) 
					VALUES	(@intVchNo,@intSourceProcessID,@intSourceProcessNo,@intSourceFiscalYear,@intSourceSerialNo,@strVchDate ,1,@SessionNo ,1,@intMaxRowNo ,@intMaxDocRowNo,
							 @PlusCostAcntCode,0,@PlusCost,TS.pub.funChangeFarsiStrings(pub.funReverseForCrystal(@strRecDesc)),@strRecDesc2,0,@StrSourceCodeFieldValue)	
				
		end		 
		
		if @InformaticCost<>0
	
		begin
			IF @InformaticCostAcntCode = ''
					BEGIN
						
						Close curAfterSale;
						Deallocate curAfterSale; 	
						Raiserror (N'کد حسابداري  خدمات رایانه ای خالي است',16,1)
						Return
					END
					
			SET @intMaxDocRowNo = @intMaxDocRowNo + 1
			SET @intMaxRowNo = @intMaxRowNo + 1
		
			INSERT INTO acc.tblVoucherDtl
							(SerialNo,SourceProcessID,SourceProcessNo,SourceFiscalYear,SourceSerialNo,DocDate,IsAutoDoc,SessionNo,VchKind,RowNo,DocRowNo,
							 AcntCode,Debit,Credit,RecDesc,RecDesc2,SourceDocType,SourceCodeFieldValue) 
					VALUES	(@intVchNo,@intSourceProcessID,@intSourceProcessNo,@intSourceFiscalYear,@intSourceSerialNo,@strVchDate ,1,@SessionNo ,1,@intMaxRowNo ,@intMaxDocRowNo,
							 @PhrSaleAcntCode,@InformaticCost,0,TS.pub.funChangeFarsiStrings(pub.funReverseForCrystal(@strRecDesc)),@strRecDesc2,0,@StrSourceCodeFieldValue)	
			
			SET @intMaxDocRowNo = @intMaxDocRowNo + 1
			SET @intMaxRowNo = @intMaxRowNo + 1
				
			INSERT INTO acc.tblVoucherDtl
							(SerialNo,SourceProcessID,SourceProcessNo,SourceFiscalYear,SourceSerialNo,DocDate,IsAutoDoc,SessionNo,VchKind,RowNo,DocRowNo,
							 AcntCode,Debit,Credit,RecDesc,RecDesc2,SourceDocType,SourceCodeFieldValue) 
					VALUES	(@intVchNo,@intSourceProcessID,@intSourceProcessNo,@intSourceFiscalYear,@intSourceSerialNo,@strVchDate ,1,@SessionNo ,1,@intMaxRowNo ,@intMaxDocRowNo,
							 @InformaticCostAcntCode,0,@InformaticCost,TS.pub.funChangeFarsiStrings(pub.funReverseForCrystal(@strRecDesc)),@strRecDesc2,0,@StrSourceCodeFieldValue)	
				
		end		 
		
	if @BoxingCost<>0
	
		begin
			IF @BoxingCostAcntCode = ''
					BEGIN
						
						Close curAfterSale;
						Deallocate curAfterSale; 	
						Raiserror (N'کد حسابداري بسته بندی مجدد خالي است',16,1)
						Return
					END
					
		SET @intMaxDocRowNo = @intMaxDocRowNo + 1
		SET @intMaxRowNo = @intMaxRowNo + 1
		
			INSERT INTO acc.tblVoucherDtl
							(SerialNo,SourceProcessID,SourceProcessNo,SourceFiscalYear,SourceSerialNo,DocDate,IsAutoDoc,SessionNo,VchKind,RowNo,DocRowNo,
							 AcntCode,Debit,Credit,RecDesc,RecDesc2,SourceDocType,SourceCodeFieldValue) 
					VALUES	(@intVchNo,@intSourceProcessID,@intSourceProcessNo,@intSourceFiscalYear,@intSourceSerialNo,@strVchDate ,1,@SessionNo ,1,@intMaxRowNo ,@intMaxDocRowNo,
							 @PhrSaleAcntCode,@BoxingCost,0,TS.pub.funChangeFarsiStrings(pub.funReverseForCrystal(@strRecDesc)),@strRecDesc2,0,@StrSourceCodeFieldValue)	
			
			SET @intMaxDocRowNo = @intMaxDocRowNo + 1
			SET @intMaxRowNo = @intMaxRowNo + 1	
			
			INSERT INTO acc.tblVoucherDtl
							(SerialNo,SourceProcessID,SourceProcessNo,SourceFiscalYear,SourceSerialNo,DocDate,IsAutoDoc,SessionNo,VchKind,RowNo,DocRowNo,
							 AcntCode,Debit,Credit,RecDesc,RecDesc2,SourceDocType,SourceCodeFieldValue) 
					VALUES	(@intVchNo,@intSourceProcessID,@intSourceProcessNo,@intSourceFiscalYear,@intSourceSerialNo,@strVchDate ,1,@SessionNo ,1,@intMaxRowNo ,@intMaxDocRowNo,
							 @BoxingCostAcntCode,0,@BoxingCost,TS.pub.funChangeFarsiStrings(pub.funReverseForCrystal(@strRecDesc)),@strRecDesc2,0,@StrSourceCodeFieldValue)	
				
		end		 
	
	END -- END of ProfCost,PlusCost,InfoCost,BoxCost
	
		Close curAfterSale;
		Deallocate curAfterSale; 	
		
			
END
GO
