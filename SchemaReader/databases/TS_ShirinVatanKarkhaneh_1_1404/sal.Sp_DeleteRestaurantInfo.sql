USE TS_ShirinVatanKarkhaneh_1_1404
GO
SET ANSI_NULLS, QUOTED_IDENTIFIER ON
GO
--=========== TS-QC:NOTOK ========================
--Author        : Mahdi Mostafavi
--Create date   : 1404/01/09
--Viewed By	 : 
--Last Modified : 
--Description   : 
--================================================

Create PROCEDURE [sal].[Sp_DeleteRestaurantInfo]
 @intVchNo		 Int,
 @intVchNoValue  Int,
 @intSourceProcessID  Int,
 @intSourceProcessNo  Int,
 @intSourceFiscalYear Int,
 @intSourceSerialNo	  Int,
 @charTPCanceledDate  Char(10)

WITH ENCRYPTION
AS
BEGIN
	SET NOCOUNT ON;
	DECLARE @MaxSerialNo as int
	 
	 SELECT D.* 
	 INTO ##tblStorageDocsDtl
	 FROM inv.tblStorageDocsDtl D
	 INNER JOIN inv.tblStorageDocsHdr H ON H.ProcessID = D.ProcessID 
									   AND H.ProcessNo = D.ProcessNo 
									   AND H.FiscalYear = D.FiscalYear 
									   AND H.SerialNo = D.SerialNo
	 WHERE H.ProcessID = 90 
	   AND H.ProcessNo = 11 
	   AND H.FiscalYear = @intSourceFiscalYear
	   AND H.SourceSerialNo = @intSourceSerialNo
	
	 SELECT * 
	 INTO ##tblStorageDocsHdr
	 FROM inv.tblStorageDocsHdr 
	 WHERE ProcessID = 90 
	   AND ProcessNo = 11
	   AND FiscalYear = @intSourceFiscalYear
	   AND SourceSerialNo = @intSourceSerialNo
	 
	 SELECT @MaxSerialNo = IsNull(max(SerialNo),0) + 1
	 FROM inv.tblStorageDocsHdr 
	 WHERE ProcessID = 90 
	   AND ProcessNo = 2
	   AND FiscalYear = @intSourceFiscalYear
	
	 UPDATE ##tblStorageDocsDtl
	 SET ProcessNo = 2,
	 SerialNo = @MaxSerialNo
	
	 UPDATE ##tblStorageDocsHdr
	 SET ProcessNo = 2,
	 SerialNo = @MaxSerialNo
	
	 UPDATE inv.tblStorageDocsHdr
	 SET TPPriceBeforDiscount = Price,
	     TPPriceAfterDiscount = Price - (TotalLineDiscount+Discount+Discount2+Discount3),
	     TotalLineDiscount = 0,
	     Discount = 0,
	     Discount2 = 0,
	     Discount3 = 0,
	     Amount = 0,
	     TransportationCost = 0,
	     PackingCost = 0,
	     TaxCost = 0,
	     VisitorCost = 0,
	     EarnestMoney = 0,
	     EarnestMoneyPercent = 0,
	     Price = 0,
	     TaxOverWorthCost = 0,
	     TransportationIncome = 0,
	     OtherCostAcntCode = 0,
	     OtherIncomeAcntCode = 0,
	     OtherCost = 0,
	     OtherIncome = 0,
	     AfterSaleDiscount = 0,
	     TollOverWorthCost = 0,
	     DistributeAmount = 0,
	     FixCost = 0,
	     CashAmount = 0,
	     ChequeAmount = 0,
	     CCDiscount = 0,
	     DiscountTaxOverWorth = 0,
	     ComssionCostPrice = 0,
	     BasculePrice = 0,
	     LaborPrice = 0,
	     TransportPrice = 0,
	     BankAmnt = 0,
	     AwardAmnt = 0,
	     BankAmnt2 = 0,
	     CashAmnt = 0,
	     CreditCardDiscount = 0,
	     AutoDiscont2 = 0,
	     AutoDiscont = 0,
	     PayTypeCashAmount = 0,
		 TPCanceled = 1,
	     TPEdited = 1,
	     SendTaxTollState = 0,
		 TPCanceledDate = @charTPCanceledDate
	 WHERE ProcessID = 90
	   AND ProcessNo = 11
	   AND FiscalYear = @intSourceFiscalYear
	   AND SourceSerialNo = @intSourceSerialNo
	 
	 Delete inv.tblStorageDocsDtl
	 FROM inv.tblStorageDocsDtl D
	 INNER JOIN inv.tblStorageDocsHdr H ON H.ProcessID = D.ProcessID 
									   AND H.ProcessNo = D.ProcessNo 
									   AND H.FiscalYear = D.FiscalYear 
									   AND H.SerialNo = D.SerialNo
	 WHERE D.ProcessID = 90 
	   AND D.ProcessNo = 11
	   AND D.FiscalYear = @intSourceFiscalYear
	   AND H.SourceSerialNo = @intSourceSerialNo
	
	 INSERT INTO inv.tblStorageDocsHdr
	 SELECT *
	 FROM ##tblStorageDocsHdr
	
	 INSERT INTO inv.tblStorageDocsDtl
	 SELECT *
	 FROM ##tblStorageDocsDtl
	
	 UPDATE sal.tblRestaurantSaleHdr
	 Set TPCanceledDate = @charTPCanceledDate
	 WHERE ProcessID = @intSourceProcessID
	   AND ProcessNo = @intSourceProcessNo
	   AND FiscalYear = @intSourceFiscalYear
	   AND SerialNo = @intSourceSerialNo
	   AND (TPCanceledDate <> '' OR TPCanceledDate <> @charTPCanceledDate)
	
	 DROP TABLE ##tblStorageDocsDtl
	 DROP TABLE ##tblStorageDocsHdr
	
	 DECLARE @VchNo int 
	 DECLARE @DocStep int  
	 DECLARE @VchDate varchar(10)  
	 DECLARE @ProcessID Smallint  
	 DECLARE @ProcessNo tinyint  
	 DECLARE @FiscalYear Smallint  
	 DECLARE @SerialNo int  
	   
	 DECLARE aa_curs cursor for   
	    SELECT DocStep,VchNo,VchDate,ProcessID,ProcessNo,FiscalYear,SerialNo  
	    FROM inv.tblStorageDocsHdr
	    WHERE ProcessID = 90 
		  AND ProcessNo = 2 
		  AND FiscalYear = @intSourceFiscalYear 
		  AND SerialNo = @MaxSerialNo 
	   
	 open aa_curs  
	   
	 FETCH NEXT FROM aa_curs into @DocStep,@VchNo,@VchDate,@ProcessID,@ProcessNo,@FiscalYear,@SerialNo  
	   
	 WHILE @@FETCH_STATUS = 0  
	 BEGIN  
	   
	 	IF @VchNo <> 0 AND @ProcessID <> 0 AND @SerialNo <> 0
	 	DELETE FROM acc.tblVoucherDtl 
	 	WHERE SourceProcessID = @ProcessID  
		  AND SourceProcessNo = @ProcessNo
		  AND SourceFiscalYear= @FiscalYear
		  AND SourceSerialNo  = @SerialNo
	 
	 	IF @VchNo <> 0   
	 	   EXEC [acc].[SpVch_CreateDoc]   
	 			@intVchNo			= @VchNo,  
	 			@intDocStep		    = 0,  
	 			@strVchDate			= @VchDate, 
	 			@strOldVchDate		= @VchDate,  
	 			@intSourceProcessID	= @ProcessID,  
	 			@intSourceProcessNo	= @ProcessNo,  
	 			@intSourceFiscalYear= @FiscalYear,  
	 			@intSourceSerialNo	= @SerialNo,  
	 			@strHdrTblName		= 'inv.tblStorageDocsHdr',  
	 			@strVchNoFieldName	= 'VchNo',  
	 			@VoucherCreateMetod = 2 ,  
	 			@DocFormType        = 2 ,  
	            @SelectedUserVchNoType = 1 , 
	 			@intOldVchNo = @VchNo 
	   
	 	FETCH NEXT FROM aa_curs into @DocStep,@VchNo,@VchDate,@ProcessID,@ProcessNo,@FiscalYear,@SerialNo  
	   
	 END   
	   
	 close aa_curs  
	 deallocate aa_curs 
    BEGIN TRANSACTION
    BEGIN TRY 
	 IF @intVchNoValue > 0
	 BEGIN
			EXEC [acc].[SpVch_DeleteDoc] @intVchNoValue, @intSourceProcessID, @intSourceProcessNo ,@intSourceFiscalYear, @intSourceSerialNo,''
		 
			UPDATE sal.tblRestaurantSaleHdr
			SET VchNo =0
			WHERE ProcessID = @intSourceProcessID
			And ProcessNo = @intSourceProcessNo
			And FiscalYear = @intSourceFiscalYear
			And SerialNo = @intSourceSerialNo
	 END
	COMMIT TRANSACTION
	END TRY
	BEGIN CATCH
	Declare @StrErrorMessage As Nvarchar(1024)
	Set @StrErrorMessage = ERROR_MESSAGE() 
	raiserror (@StrErrorMessage, 16, 1)
	ROLLBACK TRANSACTION
	RETURN 0
	END CATCH
END										
GO
