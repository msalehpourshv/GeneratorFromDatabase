USE TS_ShirinVatanKarkhaneh_1_1404
GO
SET ANSI_NULLS, QUOTED_IDENTIFIER ON
GO
-- =========== TS-QC:NOTOK ========================
-- Author        : Alian Pour
-- Create date   : 1400/12/14
-- Viewed By	 : 
-- Last Modified : 
-- Description   : 
-- =============================================
CREATE PROCEDURE [inv].[sp_api_AsmanRasa_CreateSale]

@FiscalYear As NVARCHAR(50) ,
@ProcessNo	As NVARCHAR(50) ,
@SaleTypeID	As NVARCHAR(50) ,
@StoreID As NVARCHAR(50) ,
@Price As NVARCHAR(50) ,
@Amount As NVARCHAR(50) ,
@DocDate As NVARCHAR(50) ,
@DocDesc As NVARCHAR(50) ,
@AcntCode As NVARCHAR(50) ,
@TotalLineDiscount AS FLOAT,
@TransportationIncome AS FLOAT,
@Discount As NVARCHAR(50) ,
@TaxOverWorthCost As NVARCHAR(50) ,
@TollOverWorthCost As NVARCHAR(50) ,
@Batch As NVARCHAR(50) ,
@TransferSerialNo As NVARCHAR(50) ,
@OrderId AS NVARCHAR(50),
@StateId AS NVARCHAR(50)


WITH ENCRYPTION
 AS
BEGIN
	DECLARE @IsReturn as int=0
	Declare @ReturnMaxSerialNo as int=0
	DECLARE @maxSerialNo nvarchar(50)
	DECLARE @GoodsId nvarchar(50)
	DECLARE @StrErrorMessage NVARCHAR(MAX)
	
BEGIN TRY
if(SELECT count(*) FROM inv.tblStorageDocsHdr
WHERE  ProcessID=90 and pub.funSplitString (TransferSerialNo,'_' ,1)=@OrderId and 
 pub.funSplitString (TransferSerialNo,'_' ,3)=@StateId )=0 and SUBSTRING(@DocDate,1,4)>='1401'
begin
	IF(select count(*) from inv.tblStorageDocsHdr where TransferSerialNo=@TransferSerialNo and ProcessID=90)=0
	Begin
		
		IF @AcntCode=''
		BEGIN
			SET @StrErrorMessage = N'کد مشتری را پر کنید'
			raiserror (@StrErrorMessage, 16, 1)
		END

		IF (SELECT COUNT(*) FROM inv.tblStores
		
		WHERE StoreID=@StoreID )=0
		BEGIN
			SET @StrErrorMessage = N'کد انبار '+@StoreID+' صحیح نیست '
			raiserror (@StrErrorMessage, 16, 1)
		END	

		IF (SELECT Count(*) FROM sal.tblSaleTypes
		WHERE SaleTypeID=@SaleTypeID )=0
		BEGIN
			SET @StrErrorMessage = N'کد نوع فروش نامعتبر است'
			raiserror (@StrErrorMessage, 16, 1)
		END	
	
		SELECT @maxSerialNo = isnull(MAX(SerialNo),0)
		FROM inv.tblStorageDocsHdr 
		WHERE ProcessID=90
		  AND ProcessNo=@ProcessNo
		  AND FiscalYear=@FiscalYear

		SET @maxSerialNo = @maxSerialNo +1

		INSERT INTO inv.tblStorageDocsHdr
			(ProcessID, ProcessNo, FiscalYear, SerialNo, DocStep, DocDate,VchDate,	StoreID, AcntCode,
			Amount,Price,TotalLineDiscount,DocDesc,SaleTypeID,
			TaxOverWorthCost, TollOverWorthCost,DocDate2,DocDate3, DocDate4, IsAutoDoc,
			TransportationIncome,TransferSerialNo)
	
		SELECT 90, @ProcessNo, @FiscalYear, @maxSerialNo, 3, @DocDate, @DocDate,@StoreID, @AcntCode,
			@Amount,@Price,@TotalLineDiscount,'Api'+@DocDesc,@SaleTypeID,
			@TaxOverWorthCost, @TollOverWorthCost,@DocDate DocDate2,
			@DocDate DocDate3,@DocDate DocDate4,'True' IsAutoDoc,
			@TransportationIncome,@TransferSerialNo
		
		SET @IsReturn=0

		--IF(SELECT COUNT(*) FROM inv.tblStorageDocsHdr 
		--	WHERE  (SUBSTRING(TransferSerialNo,(LEN(TransferSerialNo)-LEN(@StateId))+1,LEN(@StateId))=@StateId) AND SUBSTRING(TransferSerialNo,1,LEN(@OrderId))=@OrderId )>0
		--BEGIN

			--SELECT @ReturnMaxSerialNo = isnull(MAX(SerialNo),0)
			--FROM inv.tblStorageDocsHdr 
			--WHERE ProcessID=100 AND ProcessNo=@ProcessNo AND FiscalYear=@FiscalYear

			--SET @ReturnMaxSerialNo = @ReturnMaxSerialNo +1
				
			--INSERT INTO inv.tblStorageDocsHdr
			--	(ProcessID, ProcessNo, FiscalYear, SerialNo, DocStep, DocDate,	StoreID, AcntCode,
			--	Amount,Price,TotalLineDiscount,DocDesc,SaleTypeID,
			--	TaxOverWorthCost, TollOverWorthCost,DocDate2,DocDate3, DocDate4, IsAutoDoc,
			--	TransportationIncome,TransferSerialNo)
	
			--SELECT 100, @ProcessNo, @FiscalYear, @ReturnMaxSerialNo, 2, @DocDate, @StoreID, @AcntCode,
			--	@Amount,@Price,@TotalLineDiscount,@DocDesc,@SaleTypeID,
			--	@TaxOverWorthCost, @TollOverWorthCost,@DocDate DocDate2,
			--	@DocDate DocDate3,@DocDate DocDate4,'True' IsAutoDoc,
			--	@TransportationIncome,@TransferSerialNo
				
			--	SET @IsReturn=1
		--END
		
		SELECT @maxSerialNo AS SerialNo,CAST (@IsReturn as nvarchar(50)) as IsReturn,CAST (@ReturnMaxSerialNo as nvarchar(50)) as ReturnMaxSerialNo
	END
	
	SELECT '0' AS SerialNo, '0' AS IsReturn,'0' as ReturnMaxSerialNo
end
	SELECT '0' AS SerialNo, '0' AS IsReturn,'0' as ReturnMaxSerialNo
END TRY
BEGIN CATCH


	Set @StrErrorMessage = ERROR_MESSAGE() 
	raiserror (@StrErrorMessage, 16, 1)

END CATCH

END	
GO
