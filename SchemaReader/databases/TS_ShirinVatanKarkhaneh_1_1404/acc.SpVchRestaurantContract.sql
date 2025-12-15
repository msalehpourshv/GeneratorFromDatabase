USE TS_ShirinVatanKarkhaneh_1_1404
GO
SET ANSI_NULLS, QUOTED_IDENTIFIER ON
GO
-- =========== TS-QC:OK ========================
-- Author        : Hadi Sadeghi
-- Create date   : 87/06/21
-- Viewed By	 : REZA NP
-- Last Modified : 
-- Description   : 
-- =============================================
Create  PROCEDURE [acc].[SpVchRestaurantContract]
	@intVchNo				Int,
	@intDocStep				TinyInt,
    @strVchDate				Char(10),
	@intSourceProcessID		SmallInt,
	@intSourceProcessNo		TinyInt,
	@intSourceFiscalYear	SmallInt,
	@intSourceSerialNo		Int,
	@StrSourceCodeFieldValue VARCHAR(100),
	@intMaxRowNo			Int,
	@intMaxDocRowNo			Int,
	@SessionNo				Int,
	@LanguageID				TinyInt
	WITH ENCRYPTION
AS

BEGIN
	-----

	Declare @strMsgText				NVarChar(2044)
	Declare @BranchID				Varchar(20)
	Declare @BanquetOwnerAcntCode	Varchar(20)
	Declare @SalonAcntCode			Varchar(20)
	Declare @TaxAcntCode			Varchar(20)
	Declare @ServiceAcntCode		Varchar(20)
	Declare @SaleAcntCode			Varchar(20)
	Declare @DiscountSaleAcntCode	Varchar(20)
	Declare @strRecDesc				NVarChar(1000)
	Declare @strRecDesc2			NVarChar(1000)
	Declare @SumAdvance				Float
	Declare @SalonAmount			Float
	Declare @CancelDate			char(10)
	Declare @DocDate			char(10)
	Declare @TaxAmount				Float
	Declare @DiscountAmount			Float
	Declare @ServiceAmount			Float
	Declare @RestuarantAmount		Float
	Declare @BanquetOwnerName		NVarChar(500)
	Declare @IsCancel				bit
	Declare @EarnedAmount  float
	--------------------------------------------------------------------------------------------------------
	-----
	SET @SumAdvance = 0


 
--select * from inv.tblStores

SELECT @SalonAmount = SalonAmount,@TaxAmount = TaxAmount,@ServiceAmount = ServiceAmount,@BanquetOwnerName=BanquetOwnerName,
       @RestuarantAmount = RestuarantAmount,@BanquetOwnerAcntCode = BanquetOwnerAcntCode,@BranchID = BranchID,
       @DiscountAmount=DiscountAmount,@IsCancel=CancelContract,@CancelDate=CancelDate,@EarnedAmount  =EarnedAmount  
FROM sal.tblRestaurantContractHdr
WHERE ProcessID = @intSourceProcessID and SerialNo = @intSourceSerialNo


SELECT top 1 @DocDate=PartyDate
FROM sal.tblRestaurantContractDtl3
WHERE ProcessID = @intSourceProcessID and SerialNo = @intSourceSerialNo


SELECT @SalonAcntCode = SalonAcntCode 
	  ,@TaxAcntCode = (select SaleTaxOverWorthAcntCode from inv.tblStores B where B.StoreID=A.StoreID2)  ,
	   @ServiceAcntCode=ServiceAcntCode,
	  @SaleAcntCode = (select SaleAcntCode from inv.tblStores B where B.StoreID=A.StoreID2)  ,
	  @DiscountSaleAcntCode=(select SaleDiscountAcntCode from inv.tblStores B where B.StoreID=A.StoreID2)  
 FROM sal.tblBranches A
  where BranchID=@BranchID
 
	-----
	
SET @intMaxDocRowNo = @intMaxDocRowNo + 1
	SET @intMaxRowNo = @intMaxRowNo + 1
	SET @strRecDesc2 =  N' از بابت پرداخت مشتری ' +' - '+ @BanquetOwnerName
	SET @strRecDesc = N' سند قرارداد فروش سالن و رستوران برگه  ' +  LTRIM(RTRIM(STR(@intSourceFiscalYear)))+
	'/'+ LTRIM(RTRIM(STR(@intSourceSerialNo)))+@strRecDesc2  

	INSERT INTO acc.tblVoucherDtl
			(SerialNo,SourceProcessID,SourceProcessNo,SourceFiscalYear,SourceSerialNo,SourceCodeFieldValue,DocDate,IsAutoDoc,SessionNo,VchKind,RowNo,DocRowNo,
				AcntCode,Debit,Credit,RecDesc,RecDesc2,SourceDocType) 
	VALUES	(@intVchNo,@intSourceProcessID,@intSourceProcessNo,@intSourceFiscalYear,
	@intSourceSerialNo,@StrSourceCodeFieldValue,@strVchDate ,1,@SessionNo ,1,@intMaxRowNo ,@intMaxDocRowNo,
			 @BanquetOwnerAcntCode,@SalonAmount+@TaxAmount+@ServiceAmount+@RestuarantAmount-@DiscountAmount,0,
			 TS.pub.funChangeFarsiStrings(pub.funReverseForCrystal(@strRecDesc)),
			 TS.pub.funChangeFarsiStrings(pub.funReverseForCrystal(@strRecDesc)),0 )	



SET @intMaxDocRowNo = @intMaxDocRowNo + 1
	SET @intMaxRowNo = @intMaxRowNo + 1
	SET @strRecDesc2 =  N'از بابت تخفیفات فروش '
	SET @strRecDesc = N' سند قرارداد فروش سالن و رستوران برگه  ' +  LTRIM(RTRIM(STR(@intSourceFiscalYear))) +
	'/'+ LTRIM(RTRIM(STR(@intSourceSerialNo)))+ @strRecDesc2 

	INSERT INTO acc.tblVoucherDtl
			(SerialNo,SourceProcessID,SourceProcessNo,SourceFiscalYear,SourceSerialNo,SourceCodeFieldValue,DocDate,IsAutoDoc,SessionNo,VchKind,RowNo,DocRowNo,
				AcntCode,Debit,Credit,RecDesc,RecDesc2,SourceDocType) 
	VALUES	(@intVchNo,@intSourceProcessID,@intSourceProcessNo,@intSourceFiscalYear,@intSourceSerialNo,@StrSourceCodeFieldValue,@strVchDate ,1,@SessionNo ,1,@intMaxRowNo ,@intMaxDocRowNo,
			 @DiscountSaleAcntCode,@DiscountAmount,0,TS.pub.funChangeFarsiStrings(pub.funReverseForCrystal(@strRecDesc)),'',0 )	
		
	
	SET @intMaxDocRowNo = @intMaxDocRowNo + 1
	SET @intMaxRowNo = @intMaxRowNo + 1
	SET @strRecDesc2 =  N' از بابت درآمد سالن '
	SET @strRecDesc = N' سند قرارداد فروش سالن و رستوران برگه  ' +  LTRIM(RTRIM(STR(@intSourceFiscalYear))) +
	'/'+ LTRIM(RTRIM(STR(@intSourceSerialNo)))+ @strRecDesc2 
	INSERT INTO acc.tblVoucherDtl
			(SerialNo,SourceProcessID,SourceProcessNo,SourceFiscalYear,SourceSerialNo,SourceCodeFieldValue,DocDate,IsAutoDoc,SessionNo,VchKind,RowNo,DocRowNo,
				AcntCode,Debit,Credit,RecDesc,RecDesc2,SourceDocType) 
	VALUES	(@intVchNo,@intSourceProcessID,@intSourceProcessNo,@intSourceFiscalYear,@intSourceSerialNo,@StrSourceCodeFieldValue,@strVchDate ,1,@SessionNo ,1,@intMaxRowNo ,@intMaxDocRowNo,
			 @SalonAcntCode,0,@SalonAmount,TS.pub.funChangeFarsiStrings(pub.funReverseForCrystal(@strRecDesc)),'',0 )	

	-- @SalonAcntCode			Varchar(20)
	-- @SalonAmount			Float

	SET @intMaxDocRowNo = @intMaxDocRowNo + 1
	SET @intMaxRowNo = @intMaxRowNo + 1
	SET @strRecDesc2 =  N' از بابت مالیات '
	SET @strRecDesc = N' سند قرارداد فروش سالن و رستوران برگه  ' +  LTRIM(RTRIM(STR(@intSourceFiscalYear))) +
	'/'+ LTRIM(RTRIM(STR(@intSourceSerialNo)))+ @strRecDesc2 

	INSERT INTO acc.tblVoucherDtl
			(SerialNo,SourceProcessID,SourceProcessNo,SourceFiscalYear,SourceSerialNo,SourceCodeFieldValue,DocDate,IsAutoDoc,SessionNo,VchKind,RowNo,DocRowNo,
				AcntCode,Debit,Credit,RecDesc,RecDesc2,SourceDocType) 
	VALUES	(@intVchNo,@intSourceProcessID,@intSourceProcessNo,@intSourceFiscalYear,@intSourceSerialNo,@StrSourceCodeFieldValue,@strVchDate ,1,@SessionNo ,1,@intMaxRowNo ,@intMaxDocRowNo,
			 @TaxAcntCode,0,@TaxAmount,TS.pub.funChangeFarsiStrings(pub.funReverseForCrystal(@strRecDesc)),'',0 )	
	
--	 @TaxAcntCode			Varchar(20)
--   @TaxAmount				Float

--	 @DiscountSaleAcntCode			Varchar(20)
--   @DiscountAmount				Float



	SET @intMaxDocRowNo = @intMaxDocRowNo + 1
	SET @intMaxRowNo = @intMaxRowNo + 1
	SET @strRecDesc2 =  N' از بابت سرویس '
	SET @strRecDesc = N' سند قرارداد فروش سالن و رستوران برگه  ' + LTRIM(RTRIM(STR(@intSourceFiscalYear)))+
	'/'+ LTRIM(RTRIM(STR(@intSourceSerialNo))) + @strRecDesc2 

	INSERT INTO acc.tblVoucherDtl
			(SerialNo,SourceProcessID,SourceProcessNo,SourceFiscalYear,SourceSerialNo,SourceCodeFieldValue,DocDate,IsAutoDoc,SessionNo,VchKind,RowNo,DocRowNo,
				AcntCode,Debit,Credit,RecDesc,RecDesc2,SourceDocType) 
	VALUES	(@intVchNo,@intSourceProcessID,@intSourceProcessNo,@intSourceFiscalYear,@intSourceSerialNo,@StrSourceCodeFieldValue,@strVchDate ,1,@SessionNo ,1,@intMaxRowNo ,@intMaxDocRowNo,
			 @ServiceAcntCode,0,@ServiceAmount,TS.pub.funChangeFarsiStrings(pub.funReverseForCrystal(@strRecDesc)),'',0 )	

--	 @ServiceAcntCode		Varchar(20)
--	 @ServiceAmount			Float

SET @intMaxDocRowNo = @intMaxDocRowNo + 1
	SET @intMaxRowNo = @intMaxRowNo + 1
	SET @strRecDesc2 =  N' از بابت فروش غذا '
	SET @strRecDesc = ' سند فروش  ' +  LTRIM(RTRIM(STR(@intSourceFiscalYear))) +
	 '/'+ LTRIM(RTRIM(STR(@intSourceSerialNo)))+@strRecDesc2

	INSERT INTO acc.tblVoucherDtl
			(SerialNo,SourceProcessID,SourceProcessNo,SourceFiscalYear,SourceSerialNo,SourceCodeFieldValue,DocDate,IsAutoDoc,SessionNo,VchKind,RowNo,DocRowNo,
				AcntCode,Debit,Credit,RecDesc,RecDesc2,SourceDocType) 
	VALUES	(@intVchNo,@intSourceProcessID,@intSourceProcessNo,@intSourceFiscalYear,@intSourceSerialNo,@StrSourceCodeFieldValue,@strVchDate ,1,@SessionNo ,1,@intMaxRowNo ,@intMaxDocRowNo,
			 @SaleAcntCode,0,@RestuarantAmount,TS.pub.funChangeFarsiStrings(pub.funReverseForCrystal(@strRecDesc)),'',0 )	



--	 @SaleAcntCode			Varchar(20)
--	 @RestuarantAmount		Float


if @IsCancel=1
	begin
	Declare @CancelDays  int
	Declare @CancelPercent  Float
	
	set @CancelDays= pub.funFarsiDateDiff('Day',@CancelDate,@DocDate)  
	print  @CancelDays 
	if @CancelDays <=0
		Set @CancelPercent =0
	else
			Select @CancelPercent  =CancelPercent   from sal.tblCancelContractDtl
					where  @CancelDays>=FromDay and @CancelDays<=ToDay
	
	
	if (@CancelPercent<=0 or @CancelPercent is null)
	set @CancelPercent=0
	print @CancelPercent
	
		
	set @CancelPercent=100-@CancelPercent
		--SET @intMaxDocRowNo = @intMaxDocRowNo + 1
		--SET @intMaxRowNo = @intMaxRowNo + 1
		--SET @strRecDesc2 =  N' از بابت لفو قرارداد ' +' - '+ @BanquetOwnerName
		--SET @strRecDesc = N' سند قرارداد فروش سالن و رستوران برگه  ' +  LTRIM(RTRIM(STR(@intSourceFiscalYear)))+
		--'/'+ LTRIM(RTRIM(STR(@intSourceSerialNo)))+@strRecDesc2  

		--INSERT INTO acc.tblVoucherDtl
		--		(SerialNo,SourceProcessID,SourceProcessNo,SourceFiscalYear,SourceSerialNo,SourceCodeFieldValue,DocDate,IsAutoDoc,SessionNo,VchKind,RowNo,DocRowNo,
		--			AcntCode,Debit,Credit,RecDesc,RecDesc2,SourceDocType) 
		--VALUES	(@intVchNo,@intSourceProcessID,@intSourceProcessNo,@intSourceFiscalYear,
		--@intSourceSerialNo,@StrSourceCodeFieldValue,@strVchDate ,1,@SessionNo ,1,@intMaxRowNo ,@intMaxDocRowNo,
		--		 @BanquetOwnerAcntCode,0,@SalonAmount+@TaxAmount+@ServiceAmount+@RestuarantAmount-@DiscountAmount,
		--		 TS.pub.funChangeFarsiStrings(pub.funReverseForCrystal(@strRecDesc)),
		--		 TS.pub.funChangeFarsiStrings(pub.funReverseForCrystal(@strRecDesc)),0 )	
		
		
		
		
		
		
		
		
	SET @intMaxDocRowNo = @intMaxDocRowNo + 1
	SET @intMaxRowNo = @intMaxRowNo + 1
	SET @strRecDesc2 =  N' از بابت لفو قرارداد درآمد سالن '
	SET @strRecDesc = N' سند قرارداد فروش سالن و رستوران برگه  ' +  LTRIM(RTRIM(STR(@intSourceFiscalYear))) +
	'/'+ LTRIM(RTRIM(STR(@intSourceSerialNo)))+ @strRecDesc2 
	INSERT INTO acc.tblVoucherDtl
			(SerialNo,SourceProcessID,SourceProcessNo,SourceFiscalYear,SourceSerialNo,SourceCodeFieldValue,DocDate,IsAutoDoc,SessionNo,VchKind,RowNo,DocRowNo,
				AcntCode,Debit,Credit,RecDesc,RecDesc2,SourceDocType) 
	VALUES	(@intVchNo,@intSourceProcessID,@intSourceProcessNo,@intSourceFiscalYear,@intSourceSerialNo,@StrSourceCodeFieldValue,@strVchDate ,1,@SessionNo ,1,@intMaxRowNo ,@intMaxDocRowNo,
			 @SalonAcntCode,@SalonAmount* @CancelPercent/100,0,TS.pub.funChangeFarsiStrings(pub.funReverseForCrystal(@strRecDesc)),'',0 )	

	-- @SalonAcntCode			Varchar(20)
	-- @SalonAmount			Float

	SET @intMaxDocRowNo = @intMaxDocRowNo + 1
	SET @intMaxRowNo = @intMaxRowNo + 1
	SET @strRecDesc2 =  N' از بابت لفو قرارداد مالیات '
	SET @strRecDesc = N' سند قرارداد فروش سالن و رستوران برگه  ' +  LTRIM(RTRIM(STR(@intSourceFiscalYear))) +
	'/'+ LTRIM(RTRIM(STR(@intSourceSerialNo)))+ @strRecDesc2 

	INSERT INTO acc.tblVoucherDtl
			(SerialNo,SourceProcessID,SourceProcessNo,SourceFiscalYear,SourceSerialNo,SourceCodeFieldValue,DocDate,IsAutoDoc,SessionNo,VchKind,RowNo,DocRowNo,
				AcntCode,Debit,Credit,RecDesc,RecDesc2,SourceDocType) 
	VALUES	(@intVchNo,@intSourceProcessID,@intSourceProcessNo,@intSourceFiscalYear,@intSourceSerialNo,@StrSourceCodeFieldValue,@strVchDate ,1,@SessionNo ,1,@intMaxRowNo ,@intMaxDocRowNo,
			 @TaxAcntCode,@TaxAmount* @CancelPercent/100,0,TS.pub.funChangeFarsiStrings(pub.funReverseForCrystal(@strRecDesc)),'',0 )	
	
--	 @TaxAcntCode			Varchar(20)
--   @TaxAmount				Float

SET @intMaxDocRowNo = @intMaxDocRowNo + 1
	SET @intMaxRowNo = @intMaxRowNo + 1
	SET @strRecDesc2 =  N'از بابت لفو قرارداد تخفیفات فروش '
	SET @strRecDesc = N' سند قرارداد فروش سالن و رستوران برگه  ' +  LTRIM(RTRIM(STR(@intSourceFiscalYear))) +
	'/'+ LTRIM(RTRIM(STR(@intSourceSerialNo)))+ @strRecDesc2 

	INSERT INTO acc.tblVoucherDtl
			(SerialNo,SourceProcessID,SourceProcessNo,SourceFiscalYear,SourceSerialNo,SourceCodeFieldValue,DocDate,IsAutoDoc,SessionNo,VchKind,RowNo,DocRowNo,
				AcntCode,Debit,Credit,RecDesc,RecDesc2,SourceDocType) 
	VALUES	(@intVchNo,@intSourceProcessID,@intSourceProcessNo,@intSourceFiscalYear,@intSourceSerialNo,@StrSourceCodeFieldValue,@strVchDate ,1,@SessionNo ,1,@intMaxRowNo ,@intMaxDocRowNo,
			 @DiscountSaleAcntCode,0,@DiscountAmount* @CancelPercent/100,TS.pub.funChangeFarsiStrings(pub.funReverseForCrystal(@strRecDesc)),'',0 )	
	
--	 @DiscountSaleAcntCode			Varchar(20)
--   @DiscountAmount				Float



	SET @intMaxDocRowNo = @intMaxDocRowNo + 1
	SET @intMaxRowNo = @intMaxRowNo + 1
	SET @strRecDesc2 =  N' از بابت لفو قرارداد سرویس '
	SET @strRecDesc = N' سند قرارداد فروش سالن و رستوران برگه  ' + LTRIM(RTRIM(STR(@intSourceFiscalYear)))+
	'/'+ LTRIM(RTRIM(STR(@intSourceSerialNo))) + @strRecDesc2 

	INSERT INTO acc.tblVoucherDtl
			(SerialNo,SourceProcessID,SourceProcessNo,SourceFiscalYear,SourceSerialNo,SourceCodeFieldValue,DocDate,IsAutoDoc,SessionNo,VchKind,RowNo,DocRowNo,
				AcntCode,Debit,Credit,RecDesc,RecDesc2,SourceDocType) 
	VALUES	(@intVchNo,@intSourceProcessID,@intSourceProcessNo,@intSourceFiscalYear,@intSourceSerialNo,@StrSourceCodeFieldValue,@strVchDate ,1,@SessionNo ,1,@intMaxRowNo ,@intMaxDocRowNo,
			 @ServiceAcntCode,@ServiceAmount* @CancelPercent/100,0,TS.pub.funChangeFarsiStrings(pub.funReverseForCrystal(@strRecDesc)),'',0 )	

--	 @ServiceAcntCode		Varchar(20)
--	 @ServiceAmount			Float

SET @intMaxDocRowNo = @intMaxDocRowNo + 1
	SET @intMaxRowNo = @intMaxRowNo + 1
	SET @strRecDesc2 =  N' از بابت لفو قرارداد فروش غذا '
	SET @strRecDesc = ' سند فروش  ' +  LTRIM(RTRIM(STR(@intSourceFiscalYear))) +
	 '/'+ LTRIM(RTRIM(STR(@intSourceSerialNo)))+@strRecDesc2

	INSERT INTO acc.tblVoucherDtl
			(SerialNo,SourceProcessID,SourceProcessNo,SourceFiscalYear,SourceSerialNo,SourceCodeFieldValue,DocDate,IsAutoDoc,SessionNo,VchKind,RowNo,DocRowNo,
				AcntCode,Debit,Credit,RecDesc,RecDesc2,SourceDocType) 
	VALUES	(@intVchNo,@intSourceProcessID,@intSourceProcessNo,@intSourceFiscalYear,@intSourceSerialNo,@StrSourceCodeFieldValue,@strVchDate ,1,@SessionNo ,1,@intMaxRowNo ,@intMaxDocRowNo,
			 @SaleAcntCode,@RestuarantAmount* @CancelPercent/100,0,TS.pub.funChangeFarsiStrings(pub.funReverseForCrystal(@strRecDesc)),'',0 )	



--	 @SaleAcntCode			Varchar(20)
--	 @RestuarantAmount		Float


SET @intMaxDocRowNo = @intMaxDocRowNo + 1
	SET @intMaxRowNo = @intMaxRowNo + 1
	SET @strRecDesc2 =  N' از بابت لفو قرارداد پرداخت مشتری ' +' - '+ @BanquetOwnerName
	SET @strRecDesc = N' سند قرارداد فروش سالن و رستوران برگه  ' +  LTRIM(RTRIM(STR(@intSourceFiscalYear)))+
	'/'+ LTRIM(RTRIM(STR(@intSourceSerialNo)))+@strRecDesc2  

	INSERT INTO acc.tblVoucherDtl
			(SerialNo,SourceProcessID,SourceProcessNo,SourceFiscalYear,SourceSerialNo,SourceCodeFieldValue,DocDate,IsAutoDoc,SessionNo,VchKind,RowNo,DocRowNo,
				AcntCode,Debit,Credit,RecDesc,RecDesc2,SourceDocType) 
	VALUES	(@intVchNo,@intSourceProcessID,@intSourceProcessNo,@intSourceFiscalYear,
	@intSourceSerialNo,@StrSourceCodeFieldValue,@strVchDate ,1,@SessionNo ,1,@intMaxRowNo ,@intMaxDocRowNo,
			 @BanquetOwnerAcntCode,0,(@SalonAmount+@TaxAmount+@ServiceAmount+@RestuarantAmount-@DiscountAmount)* @CancelPercent/100,
			 TS.pub.funChangeFarsiStrings(pub.funReverseForCrystal(@strRecDesc)),
			 TS.pub.funChangeFarsiStrings(pub.funReverseForCrystal(@strRecDesc)),0 )	



set @CancelPercent=(@SalonAmount+@TaxAmount+@ServiceAmount+@RestuarantAmount-@DiscountAmount)-((@SalonAmount+@TaxAmount+@ServiceAmount+@RestuarantAmount-@DiscountAmount)* @CancelPercent/100)

update sal.tblRestaurantContractHdr
set RemainAmount=@CancelPercent-@EarnedAmount
WHERE ProcessID = @intSourceProcessID and SerialNo = @intSourceSerialNo


	END
-- @SalonAmount+TaxAmount+@ServiceAmount+@RestuarantAmount-@DiscountAmount
-- @BanquetOwnerAcntCode	Varchar(20)


END
GO
