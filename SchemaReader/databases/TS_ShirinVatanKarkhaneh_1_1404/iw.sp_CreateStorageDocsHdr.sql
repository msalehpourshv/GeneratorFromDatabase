USE TS_ShirinVatanKarkhaneh_1_1404
GO
SET ANSI_NULLS, QUOTED_IDENTIFIER ON
GO
-- =============================================
-- Author        : jafari
-- Create date   : 1403/10/20
-- Viewed By	 : 
-- Last Modified : 
-- Description   : 
-- =============================================
Create PROCEDURE iw.sp_CreateStorageDocsHdr
	@ProcessID			as int,
	@ProcessNo			as int,
	@FiscalYear			as int,
	@DocStep			as int,
	@SaleTypeID			as nvarchar(20),
	@DocDate			as nvarchar(10),
	@DocTime			as nvarchar(10),
	@DocDesc			as nvarchar(2000),
	@AcntCode			as nvarchar(20),
	@StoreID			as nvarchar(20),
	@Amount				as float ,
	@Price				as float ,
	@DiscountPercent	as float ,
	@Discount			as float ,
	@Discount2			as float ,
	@TotalLineDiscount	as float ,
	@TaxOverWorthCost	as float ,
	@TollOverWorthCost	as float ,
	@TransportationIncome as float ,
	@TransferSerialNo	as nvarchar(20),
	@VisitorAcntCode	as nvarchar(20),	
	@ExtraParams		NVarChar(Max)
WITH ENCRYPTION
AS
BEGIN
	DECLARE @MaxSerialNo		int
	DECLARE @Boolean			bit
	DECLARE @AcntCodePart1		nvarchar(20)
	Declare @StrErrorMessage	Nvarchar(1024)
BEGIN TRY

	-- check sale type ==============================================================================================================


	IF (SELECT Count(*) FROM sal.tblSaleTypes where SaleTypeID=@SaleTypeID) = 0
	BEGIN
		Set @StrErrorMessage = N'نوع فروش تعریف نشده است'
		raiserror (@StrErrorMessage, 16, 1)
	END	

	-- check store id ==============================================================================================================

	IF (SELECT Count(*) FROM inv.tblStores where StoreID=@StoreID) = 0
	BEGIN
		Set @StrErrorMessage =  N'انبار تعریف نشده است'
		raiserror (@StrErrorMessage, 16, 1)
	END	
	
	if @TransferSerialNo<> 0  and (select count(*) from inv.tblStorageDocsHdr where ProcessID=@ProcessID AND ProcessNo=@ProcessNo AND FiscalYear=@FiscalYear and TransferSerialNo=@TransferSerialNo)<>0
	begin
		SELECT ProcessID, ProcessNo, FiscalYear, SerialNo, DocDate, DocTime, DocStep, DocDesc, 
			StoreID, AcntCode, SaleTypeID, Discount, TaxOverWorthCost, TollOverWorthCost,TransportationIncome Price, Amount, TotalLineDiscount,TransferSerialNo,VisitorAcntCode
		FROM inv.tblStorageDocsHdr 
		WHERE ProcessID=@ProcessID
			AND ProcessNo=@ProcessNo
			AND FiscalYear=@FiscalYear
			AND TransferSerialNo=@TransferSerialNo
			return 
	end

	-- init ==============================================================================================================

	SELECT @MaxSerialNo = isnull(MAX(SerialNo), 0)
	FROM inv.tblStorageDocsHdr 
	WHERE ProcessID=@ProcessID
	  AND ProcessNo=@ProcessNo
	  AND FiscalYear=@FiscalYear
			
	SET @MaxSerialNo = @MaxSerialNo + 1

	-- save ==============================================================================================================

	INSERT INTO inv.tblStorageDocsHdr(
		ProcessID, ProcessNo, FiscalYear, SerialNo, DocDate, DocTime, DocStep, DocDesc, 
		StoreID, AcntCode, SaleTypeID, Discount, TaxOverWorthCost, TollOverWorthCost,TransportationIncome, Price, Amount, TotalLineDiscount,TransferSerialNo,VisitorAcntCode)
	SELECT @ProcessID, @ProcessNo, @FiscalYear, @MaxSerialNo, @DocDate, @DocTime, @DocStep, @DocDesc,
		@StoreID, @AcntCode, @SaleTypeID, @Discount, @TaxOverWorthCost, @TollOverWorthCost,@TransportationIncome, @Price, @Amount, @TotalLineDiscount,@TransferSerialNo,@VisitorAcntCode

    ------------------------------------------------------------------------------------------------------------------------------------------

	SELECT ProcessID, ProcessNo, FiscalYear, SerialNo, DocDate, DocTime, DocStep, DocDesc, 
		StoreID, AcntCode, SaleTypeID, Discount, TaxOverWorthCost, TollOverWorthCost, TransportationIncome,Price, Amount, TotalLineDiscount,TransferSerialNo,VisitorAcntCode
	FROM inv.tblStorageDocsHdr 
	WHERE ProcessID=@ProcessID
		AND ProcessNo=@ProcessNo
		AND FiscalYear=@FiscalYear
		and SerialNo=@MaxSerialNo  

END TRY
BEGIN CATCH

	Set @StrErrorMessage = ERROR_MESSAGE() 
	raiserror (@StrErrorMessage, 16, 1)

END CATCH

END	
 
GO
