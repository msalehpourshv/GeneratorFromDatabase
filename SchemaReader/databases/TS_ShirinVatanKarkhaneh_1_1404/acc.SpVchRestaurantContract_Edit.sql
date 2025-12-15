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
create  PROCEDURE [acc].[SpVchRestaurantContract_Edit]
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
	set @intSourceProcessID=182
	
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
	Declare @BanquetOwnerName		NVarChar(500)
	
	Declare @SalonAmount			Float
	Declare @TaxAmount				Float
	Declare @DiscountAmount			Float
	Declare @ServiceAmount			Float
	Declare @RestuarantAmount		Float

	Declare @SalonAmount0			Float
	Declare @TaxAmount0				Float
	Declare @DiscountAmount0		Float
	Declare @ServiceAmount0			Float
	Declare @RestuarantAmount0		Float
	
	--------------------------------------------------------------------------------------------------------
	-----

DELETE FROM acc.tblVoucherDtl
	WHERE SourceProcessID=@intSourceProcessID
	and SourceProcessNo=@intSourceProcessNo
	and SourceFiscalYear=@intSourceFiscalYear
	and SourceSerialNo=@intSourceSerialNo
	and SourceCodeFieldValue=@StrSourceCodeFieldValue

-- اطلاعات فعلی

SELECT @SalonAmount = SalonAmount,@TaxAmount = TaxAmount,@ServiceAmount = ServiceAmount,@BanquetOwnerName=BanquetOwnerName,
       @RestuarantAmount = RestuarantAmount,@BanquetOwnerAcntCode = BanquetOwnerAcntCode,@BranchID = BranchID,
       @DiscountAmount=DiscountAmount
FROM sal.tblRestaurantContractHdr
WHERE ProcessID = @intSourceProcessID and SerialNo = @intSourceSerialNo and FiscalYear=@intSourceFiscalYear

-- اطلاعات برگ اصلی
SELECT @SalonAmount0 = SalonAmount,@TaxAmount0 = TaxAmount,
	@ServiceAmount0 = ServiceAmount,
    @RestuarantAmount0 = RestuarantAmount,
    @BranchID = BranchID,
    @DiscountAmount0=DiscountAmount
FROM sal.tblRestaurantContractHdr
WHERE ProcessID = 183 and SerialNo = @intSourceSerialNo and FiscalYear=@intSourceFiscalYear


 --select * from inv.tblStores
SELECT @SalonAcntCode = SalonAcntCode 
	  ,@TaxAcntCode = (select SaleTaxOverWorthAcntCode from inv.tblStores B where B.StoreID=A.StoreID2)  ,
	   @ServiceAcntCode=ServiceAcntCode,
	  @SaleAcntCode = (select SaleAcntCode from inv.tblStores B where B.StoreID=A.StoreID2)  ,
	  @DiscountSaleAcntCode=(select SaleDiscountAcntCode from inv.tblStores B where B.StoreID=A.StoreID2)  
 FROM sal.tblBranches A
 where BranchID=@BranchID
 
	-----

--################################################
	
if @SalonAmount0 <> @SalonAmount
	begin
		SET @intMaxDocRowNo = @intMaxDocRowNo + 1
		SET @intMaxRowNo = @intMaxRowNo + 1
		SET @strRecDesc2 =  N' از بابت درآمد سالن '
		SET @strRecDesc = N' سند قرارداد فروش سالن و رستوران برگه  ' 
		+  LTRIM(RTRIM(STR(@intSourceFiscalYear))) + 
		'/'+ LTRIM(RTRIM(STR(@intSourceSerialNo)))+ @strRecDesc2 
	end
	
	-- اگر مبلغ سالن زیاد شده است
if @SalonAmount0 < @SalonAmount
 begin
 
	INSERT INTO acc.tblVoucherDtl
			(SerialNo,SourceProcessID,SourceProcessNo,SourceFiscalYear,SourceSerialNo,SourceCodeFieldValue,DocDate,IsAutoDoc,SessionNo,VchKind,RowNo,DocRowNo,
				AcntCode,Debit,Credit,RecDesc,RecDesc2,SourceDocType) 
	VALUES	(@intVchNo,@intSourceProcessID,@intSourceProcessNo,@intSourceFiscalYear,@intSourceSerialNo,@StrSourceCodeFieldValue,@strVchDate ,1,@SessionNo ,1,@intMaxRowNo ,@intMaxDocRowNo,
			 @SalonAcntCode,0,@SalonAmount-@SalonAmount0,TS.pub.funChangeFarsiStrings(pub.funReverseForCrystal(@strRecDesc)),'',0 )	

    SET @intMaxDocRowNo = @intMaxDocRowNo + 1
	SET @intMaxRowNo = @intMaxRowNo + 1
	SET @strRecDesc2 =  N' از بابت اصلاحیه پرداخت مشتری ' +' - '+ @BanquetOwnerName
	SET @strRecDesc = N' سند اصلاحیه قرارداد فروش سالن و رستوران برگه  ' 
	+  LTRIM(RTRIM(STR(@intSourceFiscalYear))) +
	'/'+ LTRIM(RTRIM(STR(@intSourceSerialNo)))+ @strRecDesc2 

	INSERT INTO acc.tblVoucherDtl
			(SerialNo,SourceProcessID,SourceProcessNo,SourceFiscalYear,SourceSerialNo,SourceCodeFieldValue,DocDate,IsAutoDoc,SessionNo,VchKind,RowNo,DocRowNo,
				AcntCode,Debit,Credit,RecDesc,RecDesc2,SourceDocType) 
	VALUES	(@intVchNo,@intSourceProcessID,@intSourceProcessNo,@intSourceFiscalYear,
	@intSourceSerialNo,@StrSourceCodeFieldValue,@strVchDate ,1,@SessionNo ,1,@intMaxRowNo ,@intMaxDocRowNo,
			 @BanquetOwnerAcntCode,@SalonAmount-@SalonAmount0  ,0,
			 TS.pub.funChangeFarsiStrings(pub.funReverseForCrystal(@strRecDesc)),
			 TS.pub.funChangeFarsiStrings(pub.funReverseForCrystal(@strRecDesc)),0 )	
			 
 end
	-- اگر مبلغ سالن کم شده است
if @SalonAmount0 > @SalonAmount
 begin
	INSERT INTO acc.tblVoucherDtl
			(SerialNo,SourceProcessID,SourceProcessNo,SourceFiscalYear,SourceSerialNo,SourceCodeFieldValue,DocDate,IsAutoDoc,SessionNo,VchKind,RowNo,DocRowNo,
				AcntCode,Debit,Credit,RecDesc,RecDesc2,SourceDocType) 
	VALUES	(@intVchNo,@intSourceProcessID,@intSourceProcessNo,@intSourceFiscalYear,@intSourceSerialNo,@StrSourceCodeFieldValue,@strVchDate ,1,@SessionNo ,1,@intMaxRowNo ,@intMaxDocRowNo,
			 @SalonAcntCode,@SalonAmount0 - @SalonAmount,0,TS.pub.funChangeFarsiStrings(pub.funReverseForCrystal(@strRecDesc)),'',0 )	


	SET @intMaxDocRowNo = @intMaxDocRowNo + 1
	SET @intMaxRowNo = @intMaxRowNo + 1
	SET @strRecDesc2 =  N' از بابت اصلاحیه پرداخت مشتری ' +' - '+ @BanquetOwnerName
	SET @strRecDesc = N' سند اصلاحیه قرارداد فروش سالن و رستوران برگه  ' 
	+  LTRIM(RTRIM(STR(@intSourceFiscalYear))) +
	'/'+ LTRIM(RTRIM(STR(@intSourceSerialNo)))+ @strRecDesc2 

	INSERT INTO acc.tblVoucherDtl
			(SerialNo,SourceProcessID,SourceProcessNo,SourceFiscalYear,SourceSerialNo,SourceCodeFieldValue,DocDate,IsAutoDoc,SessionNo,VchKind,RowNo,DocRowNo,
				AcntCode,Debit,Credit,RecDesc,RecDesc2,SourceDocType) 
	VALUES	(@intVchNo,@intSourceProcessID,@intSourceProcessNo,@intSourceFiscalYear,
	@intSourceSerialNo,@StrSourceCodeFieldValue,@strVchDate ,1,@SessionNo ,1,@intMaxRowNo ,@intMaxDocRowNo,
			 @BanquetOwnerAcntCode,0,@SalonAmount0-@SalonAmount ,
			 TS.pub.funChangeFarsiStrings(pub.funReverseForCrystal(@strRecDesc)),
			 TS.pub.funChangeFarsiStrings(pub.funReverseForCrystal(@strRecDesc)),0 )

end
-- @SalonAcntCode			Varchar(20)
-- @SalonAmount			Float

--########################################################


if @TaxAmount0 <> @TaxAmount
 begin
	SET @intMaxDocRowNo = @intMaxDocRowNo + 1
	SET @intMaxRowNo = @intMaxRowNo + 1
	SET @strRecDesc2 =  N' از بابت اصلاحیه مالیات '
	SET @strRecDesc = N' سند اصلحیه قرارداد فروش سالن و رستوران برگه  ' 
	+  LTRIM(RTRIM(STR(@intSourceFiscalYear))) +
	'/'+ LTRIM(RTRIM(STR(@intSourceSerialNo)))+ @strRecDesc2 
 end
	-- اگر مبلغ مالیات زیاد شده است
if @TaxAmount0 < @TaxAmount
	
 begin

	INSERT INTO acc.tblVoucherDtl
			(SerialNo,SourceProcessID,SourceProcessNo,SourceFiscalYear,SourceSerialNo,SourceCodeFieldValue,DocDate,IsAutoDoc,SessionNo,VchKind,RowNo,DocRowNo,
				AcntCode,Debit,Credit,RecDesc,RecDesc2,SourceDocType) 
	VALUES	(@intVchNo,@intSourceProcessID,@intSourceProcessNo,@intSourceFiscalYear,@intSourceSerialNo,@StrSourceCodeFieldValue,@strVchDate ,1,@SessionNo ,1,@intMaxRowNo ,@intMaxDocRowNo,
			 @TaxAcntCode,0,@TaxAmount-@TaxAmount0,TS.pub.funChangeFarsiStrings(pub.funReverseForCrystal(@strRecDesc)),'',0 )	
	
	SET @intMaxDocRowNo = @intMaxDocRowNo + 1
	SET @intMaxRowNo = @intMaxRowNo + 1
	SET @strRecDesc2 =  N' از بابت اصلاحیه پرداخت مشتری ' +' - '+ @BanquetOwnerName
	SET @strRecDesc = N' سند اصلاحیه قرارداد فروش سالن و رستوران برگه  '
	 +  LTRIM(RTRIM(STR(@intSourceFiscalYear))) +
	 '/'+ LTRIM(RTRIM(STR(@intSourceSerialNo)))+ @strRecDesc2 

	INSERT INTO acc.tblVoucherDtl
			(SerialNo,SourceProcessID,SourceProcessNo,SourceFiscalYear,SourceSerialNo,SourceCodeFieldValue,DocDate,IsAutoDoc,SessionNo,VchKind,RowNo,DocRowNo,
				AcntCode,Debit,Credit,RecDesc,RecDesc2,SourceDocType) 
	VALUES	(@intVchNo,@intSourceProcessID,@intSourceProcessNo,@intSourceFiscalYear,
	@intSourceSerialNo,@StrSourceCodeFieldValue,@strVchDate ,1,@SessionNo ,1,@intMaxRowNo ,@intMaxDocRowNo,
			 @BanquetOwnerAcntCode,@TaxAmount-@TaxAmount0,0,
			 TS.pub.funChangeFarsiStrings(pub.funReverseForCrystal(@strRecDesc)),
			 TS.pub.funChangeFarsiStrings(pub.funReverseForCrystal(@strRecDesc)),0 )
end

-- اگر مبلغ مالیات کم شده است
if @TaxAmount0 > @TaxAmount
 begin
 
	INSERT INTO acc.tblVoucherDtl
			(SerialNo,SourceProcessID,SourceProcessNo,SourceFiscalYear,SourceSerialNo,SourceCodeFieldValue,DocDate,IsAutoDoc,SessionNo,VchKind,RowNo,DocRowNo,
				AcntCode,Debit,Credit,RecDesc,RecDesc2,SourceDocType) 
	VALUES	(@intVchNo,@intSourceProcessID,@intSourceProcessNo,@intSourceFiscalYear,@intSourceSerialNo,@StrSourceCodeFieldValue,@strVchDate ,1,@SessionNo ,1,@intMaxRowNo ,@intMaxDocRowNo,
			 @TaxAcntCode,@TaxAmount0-@TaxAmount,0,TS.pub.funChangeFarsiStrings(pub.funReverseForCrystal(@strRecDesc)),'',0 )	
	
	SET @intMaxDocRowNo = @intMaxDocRowNo + 1
	SET @intMaxRowNo = @intMaxRowNo + 1
	SET @strRecDesc2 =  N' از بابت اصلاحیه پرداخت مشتری ' +' - '+ @BanquetOwnerName
	SET @strRecDesc = N' سند اصلاحیه قرارداد فروش سالن و رستوران برگه  '
	 +  LTRIM(RTRIM(STR(@intSourceFiscalYear))) +
	 '/'+ LTRIM(RTRIM(STR(@intSourceSerialNo)))+ @strRecDesc2 

	INSERT INTO acc.tblVoucherDtl
			(SerialNo,SourceProcessID,SourceProcessNo,SourceFiscalYear,SourceSerialNo,SourceCodeFieldValue,DocDate,IsAutoDoc,SessionNo,VchKind,RowNo,DocRowNo,
				AcntCode,Debit,Credit,RecDesc,RecDesc2,SourceDocType) 
	VALUES	(@intVchNo,@intSourceProcessID,@intSourceProcessNo,@intSourceFiscalYear,
	@intSourceSerialNo,@StrSourceCodeFieldValue,@strVchDate ,1,@SessionNo ,1,@intMaxRowNo ,@intMaxDocRowNo,
			 @BanquetOwnerAcntCode,0,@TaxAmount0-@TaxAmount,
			 TS.pub.funChangeFarsiStrings(pub.funReverseForCrystal(@strRecDesc)),
			 TS.pub.funChangeFarsiStrings(pub.funReverseForCrystal(@strRecDesc)),0 )
 end	 
--	 @TaxAcntCode			Varchar(20)
--   @TaxAmount				Float

--########################################################


IF @DiscountAmount0 <> @DiscountAmount
 begin
	SET @intMaxDocRowNo = @intMaxDocRowNo + 1
	SET @intMaxRowNo = @intMaxRowNo + 1
	SET @strRecDesc2 =  N'از بابت تخفیفات فروش '
	SET @strRecDesc = N' سند قرارداد فروش سالن و رستوران برگه  ' 
	+  LTRIM(RTRIM(STR(@intSourceFiscalYear))) +
	'/'+ LTRIM(RTRIM(STR(@intSourceSerialNo)))+ @strRecDesc2 
 end
	
-- اگر مبلغ تخفیف کم شده است
IF @DiscountAmount0>@DiscountAmount
 begin
 
	INSERT INTO acc.tblVoucherDtl
			(SerialNo,SourceProcessID,SourceProcessNo,SourceFiscalYear,SourceSerialNo,SourceCodeFieldValue,DocDate,IsAutoDoc,SessionNo,VchKind,RowNo,DocRowNo,
				AcntCode,Debit,Credit,RecDesc,RecDesc2,SourceDocType) 
	VALUES	(@intVchNo,@intSourceProcessID,@intSourceProcessNo,@intSourceFiscalYear
		    ,@intSourceSerialNo,@StrSourceCodeFieldValue,@strVchDate ,1,@SessionNo ,1,@intMaxRowNo ,@intMaxDocRowNo,
			 @DiscountSaleAcntCode,0,@DiscountAmount0-@DiscountAmount,TS.pub.funChangeFarsiStrings(pub.funReverseForCrystal(@strRecDesc)),'',0 )	

	SET @intMaxDocRowNo = @intMaxDocRowNo + 1
	SET @intMaxRowNo = @intMaxRowNo + 1
	SET @strRecDesc2 =  N' از بابت اصلاحیه پرداخت مشتری ' +' - '+ @BanquetOwnerName
	SET @strRecDesc = N' سند اصلاحیه قرارداد فروش سالن و رستوران برگه  '
	 +  LTRIM(RTRIM(STR(@intSourceFiscalYear))) +
	 '/'+ LTRIM(RTRIM(STR(@intSourceSerialNo)))+ @strRecDesc2 

	INSERT INTO acc.tblVoucherDtl
			(SerialNo,SourceProcessID,SourceProcessNo,SourceFiscalYear,SourceSerialNo,SourceCodeFieldValue,DocDate,IsAutoDoc,SessionNo,VchKind,RowNo,DocRowNo,
				AcntCode,Debit,Credit,RecDesc,RecDesc2,SourceDocType) 
	VALUES	(@intVchNo,@intSourceProcessID,@intSourceProcessNo,@intSourceFiscalYear,
	@intSourceSerialNo,@StrSourceCodeFieldValue,@strVchDate ,1,@SessionNo ,1,@intMaxRowNo ,@intMaxDocRowNo,
			 @BanquetOwnerAcntCode,@DiscountAmount0-@DiscountAmount,0,
			 TS.pub.funChangeFarsiStrings(pub.funReverseForCrystal(@strRecDesc)),
			 TS.pub.funChangeFarsiStrings(pub.funReverseForCrystal(@strRecDesc)),0 )
 end
 
 -- اگر مبلغ تخفیف زیاد شده است
IF @DiscountAmount0<@DiscountAmount
 begin
  
	INSERT INTO acc.tblVoucherDtl
			(SerialNo,SourceProcessID,SourceProcessNo,SourceFiscalYear,SourceSerialNo,SourceCodeFieldValue,DocDate,IsAutoDoc,SessionNo,VchKind,RowNo,DocRowNo,
				AcntCode,Debit,Credit,RecDesc,RecDesc2,SourceDocType) 
	VALUES	(@intVchNo,@intSourceProcessID,@intSourceProcessNo,@intSourceFiscalYear
		    ,@intSourceSerialNo,@StrSourceCodeFieldValue,@strVchDate ,1,@SessionNo ,1,@intMaxRowNo ,@intMaxDocRowNo,
			 @DiscountSaleAcntCode,@DiscountAmount-@DiscountAmount0,0,TS.pub.funChangeFarsiStrings(pub.funReverseForCrystal(@strRecDesc)),'',0 )	

	SET @intMaxDocRowNo = @intMaxDocRowNo + 1
	SET @intMaxRowNo = @intMaxRowNo + 1
	SET @strRecDesc2 =  N' از بابت اصلاحیه پرداخت مشتری ' +' - '+ @BanquetOwnerName
	SET @strRecDesc = N' سند اصلاحیه قرارداد فروش سالن و رستوران برگه  '
	 +  LTRIM(RTRIM(STR(@intSourceFiscalYear))) + 
	 '/'+ LTRIM(RTRIM(STR(@intSourceSerialNo)))+@strRecDesc2 

	INSERT INTO acc.tblVoucherDtl
			(SerialNo,SourceProcessID,SourceProcessNo,SourceFiscalYear,SourceSerialNo,SourceCodeFieldValue,DocDate,IsAutoDoc,SessionNo,VchKind,RowNo,DocRowNo,
				AcntCode,Debit,Credit,RecDesc,RecDesc2,SourceDocType) 
	VALUES	(@intVchNo,@intSourceProcessID,@intSourceProcessNo,@intSourceFiscalYear,
	@intSourceSerialNo,@StrSourceCodeFieldValue,@strVchDate ,1,@SessionNo ,1,@intMaxRowNo ,@intMaxDocRowNo,
			 @BanquetOwnerAcntCode,0,@DiscountAmount-@DiscountAmount0, 
			 TS.pub.funChangeFarsiStrings(pub.funReverseForCrystal(@strRecDesc)),
			 TS.pub.funChangeFarsiStrings(pub.funReverseForCrystal(@strRecDesc)),0 )
 end
 
----	 @DiscountSaleAcntCode			Varchar(20)
----   @DiscountAmount				Float
----########################################################

IF @ServiceAmount0<>@ServiceAmount
begin
	SET @intMaxDocRowNo = @intMaxDocRowNo + 1
	SET @intMaxRowNo = @intMaxRowNo + 1
	SET @strRecDesc2 =  N' از بابت  اصلاحیه سرویس '
	SET @strRecDesc = N' سند قرارداد فروش سالن و رستوران برگه  '
	 +  LTRIM(RTRIM(STR(@intSourceFiscalYear))) +
	 '/'+ LTRIM(RTRIM(STR(@intSourceSerialNo)))+ @strRecDesc2 
end

-- اگر حق سرویس زیاد شده است
IF @ServiceAmount0<@ServiceAmount
begin
	INSERT INTO acc.tblVoucherDtl
			(SerialNo,SourceProcessID,SourceProcessNo,SourceFiscalYear,SourceSerialNo,SourceCodeFieldValue,DocDate,IsAutoDoc,SessionNo,VchKind,RowNo,DocRowNo,
				AcntCode,Debit,Credit,RecDesc,RecDesc2,SourceDocType) 
	VALUES	(@intVchNo,@intSourceProcessID,@intSourceProcessNo,@intSourceFiscalYear,
		    @intSourceSerialNo,@StrSourceCodeFieldValue,@strVchDate ,1,@SessionNo ,1,@intMaxRowNo ,@intMaxDocRowNo,
			 @ServiceAcntCode,0,@ServiceAmount-@ServiceAmount0,TS.pub.funChangeFarsiStrings(pub.funReverseForCrystal(@strRecDesc)),'',0 )	

    SET @intMaxDocRowNo = @intMaxDocRowNo + 1
	SET @intMaxRowNo = @intMaxRowNo + 1
	SET @strRecDesc2 =  N' از بابت اصلاحیه پرداخت مشتری ' +' - '+ @BanquetOwnerName
	SET @strRecDesc = N' سند اصلاحیه قرارداد فروش سالن و رستوران برگه  '
	 +  LTRIM(RTRIM(STR(@intSourceFiscalYear))) +
	 '/'+ LTRIM(RTRIM(STR(@intSourceSerialNo)))+ @strRecDesc2 

	INSERT INTO acc.tblVoucherDtl
			(SerialNo,SourceProcessID,SourceProcessNo,SourceFiscalYear,SourceSerialNo,SourceCodeFieldValue,DocDate,IsAutoDoc,SessionNo,VchKind,RowNo,DocRowNo,
				AcntCode,Debit,Credit,RecDesc,RecDesc2,SourceDocType) 
	VALUES	(@intVchNo,@intSourceProcessID,@intSourceProcessNo,@intSourceFiscalYear,
	@intSourceSerialNo,@StrSourceCodeFieldValue,@strVchDate ,1,@SessionNo ,1,@intMaxRowNo ,@intMaxDocRowNo,
			 @BanquetOwnerAcntCode,@ServiceAmount-@ServiceAmount0,0, 
			 TS.pub.funChangeFarsiStrings(pub.funReverseForCrystal(@strRecDesc)),
			 TS.pub.funChangeFarsiStrings(pub.funReverseForCrystal(@strRecDesc)),0 )
 end
 
 -- اگر حق سرویس کم شده است
IF @ServiceAmount0>@ServiceAmount
begin
	INSERT INTO acc.tblVoucherDtl
			(SerialNo,SourceProcessID,SourceProcessNo,SourceFiscalYear,SourceSerialNo,SourceCodeFieldValue,DocDate,IsAutoDoc,SessionNo,VchKind,RowNo,DocRowNo,
				AcntCode,Debit,Credit,RecDesc,RecDesc2,SourceDocType) 
	VALUES	(@intVchNo,@intSourceProcessID,@intSourceProcessNo,@intSourceFiscalYear,
		    @intSourceSerialNo,@StrSourceCodeFieldValue,@strVchDate ,1,@SessionNo ,1,@intMaxRowNo ,@intMaxDocRowNo,
			 @ServiceAcntCode,@ServiceAmount0-@ServiceAmount,0,TS.pub.funChangeFarsiStrings(pub.funReverseForCrystal(@strRecDesc)),'',0 )	

    SET @intMaxDocRowNo = @intMaxDocRowNo + 1
	SET @intMaxRowNo = @intMaxRowNo + 1
	SET @strRecDesc2 =  N' از بابت اصلاحیه پرداخت مشتری ' +' - '+ @BanquetOwnerName
	SET @strRecDesc = N' سند اصلاحیه قرارداد فروش سالن و رستوران برگه  ' 
	+  LTRIM(RTRIM(STR(@intSourceFiscalYear))) +
	'/'+ LTRIM(RTRIM(STR(@intSourceSerialNo)))+ @strRecDesc2 

	INSERT INTO acc.tblVoucherDtl
			(SerialNo,SourceProcessID,SourceProcessNo,SourceFiscalYear,SourceSerialNo,SourceCodeFieldValue,DocDate,IsAutoDoc,SessionNo,VchKind,RowNo,DocRowNo,
				AcntCode,Debit,Credit,RecDesc,RecDesc2,SourceDocType) 
	VALUES	(@intVchNo,@intSourceProcessID,@intSourceProcessNo,@intSourceFiscalYear,
	@intSourceSerialNo,@StrSourceCodeFieldValue,@strVchDate ,1,@SessionNo ,1,@intMaxRowNo ,@intMaxDocRowNo,
			 @BanquetOwnerAcntCode,0,@ServiceAmount0-@ServiceAmount,
			 TS.pub.funChangeFarsiStrings(pub.funReverseForCrystal(@strRecDesc)),
			 TS.pub.funChangeFarsiStrings(pub.funReverseForCrystal(@strRecDesc)),0 )
 end
--	 @ServiceAcntCode		Varchar(20)
--	 @ServiceAmount			Float

--########################################################


if @RestuarantAmount0<>@RestuarantAmount
begin
	SET @intMaxDocRowNo = @intMaxDocRowNo + 1
	SET @intMaxRowNo = @intMaxRowNo + 1
	SET @strRecDesc2 =  N' از بابت اصلاحیه فروش غذا '
	SET @strRecDesc = ' سند فروش  ' +  LTRIM(RTRIM(STR(@intSourceFiscalYear))) +
	'/'+ LTRIM(RTRIM(STR(@intSourceSerialNo)))+ @strRecDesc2
end


-- اگر جمع رستوران زیاد شده است
if @RestuarantAmount0<@RestuarantAmount
begin
	INSERT INTO acc.tblVoucherDtl
			(SerialNo,SourceProcessID,SourceProcessNo,SourceFiscalYear,SourceSerialNo,SourceCodeFieldValue,DocDate,IsAutoDoc,SessionNo,VchKind,RowNo,DocRowNo,
				AcntCode,Debit,Credit,RecDesc,RecDesc2,SourceDocType) 
	VALUES	(@intVchNo,@intSourceProcessID,@intSourceProcessNo,@intSourceFiscalYear,@intSourceSerialNo,@StrSourceCodeFieldValue,@strVchDate ,1,@SessionNo ,1,@intMaxRowNo ,@intMaxDocRowNo,
			 @SaleAcntCode,0,@RestuarantAmount-@RestuarantAmount0,TS.pub.funChangeFarsiStrings(pub.funReverseForCrystal(@strRecDesc)),'',0 )	

    SET @intMaxDocRowNo = @intMaxDocRowNo + 1
	SET @intMaxRowNo = @intMaxRowNo + 1
	SET @strRecDesc2 =  N' از بابت اصلاحیه پرداخت مشتری ' +' - '+ @BanquetOwnerName
	SET @strRecDesc = N' سند اصلاحیه قرارداد فروش سالن و رستوران برگه  ' 
	+  LTRIM(RTRIM(STR(@intSourceFiscalYear))) + 
	'/'+ LTRIM(RTRIM(STR(@intSourceSerialNo)))+@strRecDesc2 

	INSERT INTO acc.tblVoucherDtl
			(SerialNo,SourceProcessID,SourceProcessNo,SourceFiscalYear,SourceSerialNo,SourceCodeFieldValue,DocDate,IsAutoDoc,SessionNo,VchKind,RowNo,DocRowNo,
				AcntCode,Debit,Credit,RecDesc,RecDesc2,SourceDocType) 
	VALUES	(@intVchNo,@intSourceProcessID,@intSourceProcessNo,@intSourceFiscalYear,
	@intSourceSerialNo,@StrSourceCodeFieldValue,@strVchDate ,1,@SessionNo ,1,@intMaxRowNo ,@intMaxDocRowNo,
			 @BanquetOwnerAcntCode,@RestuarantAmount-@RestuarantAmount0,0, 
			 TS.pub.funChangeFarsiStrings(pub.funReverseForCrystal(@strRecDesc)),
			 TS.pub.funChangeFarsiStrings(pub.funReverseForCrystal(@strRecDesc)),0 )
end

-- اگر جمع رستوران کم شده است
if @RestuarantAmount0>@RestuarantAmount
begin
	INSERT INTO acc.tblVoucherDtl
			(SerialNo,SourceProcessID,SourceProcessNo,SourceFiscalYear,SourceSerialNo,SourceCodeFieldValue,DocDate,IsAutoDoc,SessionNo,VchKind,RowNo,DocRowNo,
				AcntCode,Debit,Credit,RecDesc,RecDesc2,SourceDocType) 
	VALUES	(@intVchNo,@intSourceProcessID,@intSourceProcessNo,@intSourceFiscalYear,@intSourceSerialNo,@StrSourceCodeFieldValue,@strVchDate ,1,@SessionNo ,1,@intMaxRowNo ,@intMaxDocRowNo,
			 @SaleAcntCode,@RestuarantAmount0-@RestuarantAmount,0,TS.pub.funChangeFarsiStrings(pub.funReverseForCrystal(@strRecDesc)),'',0 )	

    SET @intMaxDocRowNo = @intMaxDocRowNo + 1
	SET @intMaxRowNo = @intMaxRowNo + 1
	SET @strRecDesc2 =  N' از بابت اصلاحیه پرداخت مشتری ' +' - '+ @BanquetOwnerName
	SET @strRecDesc = N' سند اصلاحیه قرارداد فروش سالن و رستوران برگه  '
	 +  LTRIM(RTRIM(STR(@intSourceFiscalYear))) + 
	 '/'+ LTRIM(RTRIM(STR(@intSourceSerialNo)))+@strRecDesc2 

	INSERT INTO acc.tblVoucherDtl
			(SerialNo,SourceProcessID,SourceProcessNo,SourceFiscalYear,SourceSerialNo,SourceCodeFieldValue,DocDate,IsAutoDoc,SessionNo,VchKind,RowNo,DocRowNo,
				AcntCode,Debit,Credit,RecDesc,RecDesc2,SourceDocType) 
	VALUES	(@intVchNo,@intSourceProcessID,@intSourceProcessNo,@intSourceFiscalYear,
	@intSourceSerialNo,@StrSourceCodeFieldValue,@strVchDate ,1,@SessionNo ,1,@intMaxRowNo ,@intMaxDocRowNo,
			 @BanquetOwnerAcntCode,0,@RestuarantAmount0-@RestuarantAmount, 
			 TS.pub.funChangeFarsiStrings(pub.funReverseForCrystal(@strRecDesc)),
			 TS.pub.funChangeFarsiStrings(pub.funReverseForCrystal(@strRecDesc)),0 )
end


--	 @SaleAcntCode			Varchar(20)
--	 @RestuarantAmount		Float

--########################################################

END
GO
