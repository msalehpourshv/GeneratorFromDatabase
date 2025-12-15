USE TS_ShirinVatanKarkhaneh_1_1404
GO
SET ANSI_NULLS, QUOTED_IDENTIFIER ON
GO
--=========== TS-QC:NOTOK ========================
--Author        : Mahdi Mostafavi
--Create date   : 1403/10/10
--Viewed By	 : 
--Last Modified : 
--Description   : 
--================================================
Create PROCEDURE [prd].[spResturanSalesUpdateFields]
	  @SerialNo AS INT,
	  @FiscalYear AS INT,
	  @TaxISDtl as bit
      
WITH ENCRYPTION
AS
BEGIN

DECLARE @StrSelect	 NVarChar(max)
SET @StrSelect = '
		UPDATE inv.tblStorageDocsHdr
		SET DocDate = b.DocDate
		FROM inv.tblStorageDocsHdr a 
		LEFT JOIN sal.tblRestaurantSaleHdr b
			   ON a.SourceSerialNo=b.SerialNo 
			  AND a.BRN=b.BranchID
		WHERE a.ProcessID = 90 
		  AND a.ProcessNo = 11 
		  AND a.DocDate <> b.DocDate 
		  AND b.SerialNo = ' + ltrim(rtrim(str(@SerialNo)))
	
	PRINT @StrSelect
	EXEC sp_executesql @StrSelect;

	IF @@ROWCOUNT > 0
		UPDATE inv.tblStorageDocsHdr
		SET SendTaxTollState = 0,
		TPEdited = 1
		FROM inv.tblStorageDocsHdr a 
		LEFT JOIN sal.tblRestaurantSaleHdr b
			   ON a.SourceSerialNo=b.SerialNo 
			  AND a.BRN=b.BranchID
		WHERE a.ProcessID = 90 
		  AND a.ProcessNo = 11 
		  AND ((a.SendTaxTollState = 3 AND a.TPEdited = 0) OR (a.SendTaxTollState = 3 AND a.TPCanceled = 0))
		  AND b.SerialNo = @SerialNo

	SET @StrSelect = '
	UPDATE inv.tblStorageDocsDtl
	SET DocDate = b.DocDate,
		GoodsPrice = IsNull(b.Price,0),
		TaxOverWorthCostDtl = IsNull(b.TaxOverWorthCostDtl,0),
		DiscountDtl = IsNull(b.DiscountDtl,0)
	FROM inv.tblStorageDocsDtl c
	LEFT JOIN inv.tblStorageDocsHdr a
			ON a.ProcessID = c.ProcessID 
		   AND a.ProcessNo = c.ProcessNo 
		   AND a.FiscalYear = c.FiscalYear 
		   AND a.SerialNo = c.SerialNo
	LEFT JOIN sal.tblRestaurantSaleDtl b
			ON a.SourceSerialNo = b.SerialNo 
		   AND a.BRN = b.BranchID 
		   AND c.DocRowNo = b.DocRowNo 
		   AND c.GoodsID = b.GoodsID 
		   AND c.GoodsQuantity = b.Qty
	WHERE a.ProcessID = 90 
	  AND a.ProcessNo = 11 
	  AND b.SerialNo = ' + ltrim(rtrim(str(@SerialNo))) + '
	  AND (a.DocDate <> b.DocDate 
	   OR c.GoodsPrice <> b.Price 
	   OR c.TaxOverWorthCostDtl <> b.TaxOverWorthCostDtl 
	   OR c.DiscountDtl <> b.DiscountDtl)'

	Print @StrSelect
	Exec sp_executesql @StrSelect;

	IF @@ROWCOUNT > 0
		UPDATE inv.tblStorageDocsHdr
		SET SendTaxTollState = 0,
		TPEdited = 1
		FROM inv.tblStorageDocsHdr a 
		LEFT JOIN sal.tblRestaurantSaleHdr b
			   ON a.SourceSerialNo=b.SerialNo 
			  AND a.BRN=b.BranchID
		WHERE a.ProcessID = 90 
		  AND a.ProcessNo = 11 
		  AND ((a.SendTaxTollState = 3 AND a.TPEdited = 0) OR (a.SendTaxTollState = 3 AND a.TPCanceled = 0))
		  AND b.SerialNo = @SerialNo
	
	SET @StrSelect = '
	UPDATE inv.tblStorageDocsDtl
	SET IsReward = 1
	FROM inv.tblStorageDocsDtl c
	LEFT JOIN inv.tblStorageDocsHdr a
			ON a.ProcessID = c.ProcessID 
		   AND a.ProcessNo = c.ProcessNo 
		   AND a.FiscalYear = c.FiscalYear 
		   AND a.SerialNo = c.SerialNo
	LEFT JOIN sal.tblRestaurantSaleDtl b
			ON a.SourceSerialNo = b.SerialNo 
		   AND a.BRN = b.BranchID 
		   AND c.DocRowNo = b.DocRowNo 
		   AND c.GoodsID = b.GoodsID 
		   AND c.GoodsQuantity = b.Qty
	WHERE a.ProcessID = 90 
	  AND a.ProcessNo = 11 
	  AND b.SerialNo = ' + ltrim(rtrim(str(@SerialNo))) + '
	  AND (c.GoodsQuantity*c.GoodsPrice)+c.TaxOverWorthCostDtl+c.TollOverWorthCostDtl-c.DiscountDtl = 0'
	Print @StrSelect
	Exec sp_executesql @StrSelect;

	
	SET @StrSelect = '
	UPDATE inv.tblStorageDocsHdr
	SET Price = IsNull(D.TPrice,0), 
		Amount= isNull(D.TPrice,0), 
		TotalLineDiscount = IsNull(DiscountDtl,0),
		TaxOverWorthCost = ' + case when @TaxISDtl ='True' THEN 'IsNull(TaxOverWorthCostDtl,0)' ELSE 'TaxOverWorthCost' END + ',
		TollOverWorthCost =' + case when @TaxISDtl ='True' THEN 'IsNull(TollOverWorthCostDtl,0)' ELSE 'TollOverWorthCost' END + ' 
	FROM inv.tblStorageDocsHdr H
		LEFT JOIN (SELECT c.ProcessID,
						  c.ProcessNo,
						  c.FiscalYear,
						  c.SerialNo,
						  b.SerialNo BaseSerialNo,
						  SUM(GoodsQuantity*GoodsPrice) TPrice,
						  SUM(c.DiscountDtl) DiscountDtl,
						  SUM(c.TaxOverWorthCostDtl) TaxOverWorthCostDtl,
						  SUM(c.TollOverWorthCostDtl) TollOverWorthCostDtl
					FROM inv.tblStorageDocsDtl c
					LEFT JOIN inv.tblStorageDocsHdr a
						   ON a.ProcessID = c.ProcessID 
						   AND a.ProcessNo = c.ProcessNo 
						   AND a.FiscalYear = c.FiscalYear 
						   AND a.SerialNo = c.SerialNo
					LEFT JOIN sal.tblRestaurantSaleDtl b
						ON a.SourceSerialNo = b.SerialNo 
						AND	a.BRN = b.BranchID 
						AND c.DocRowNo = b.DocRowNo 
						AND c.GoodsID = b.GoodsID 
						AND c.GoodsQuantity = b.Qty
					WHERE c.ProcessID=90 
					  AND c.ProcessNo=11 
					  AND b.FiscalYear = ' + ltrim(rtrim(str(@FiscalYear))) + '
					  AND b.SerialNo = ' + ltrim(rtrim(str(@SerialNo))) + '
					GROUP BY c.ProcessID,c.ProcessNo,c.FiscalYear,c.SerialNo, b.SerialNo) D
		ON H.ProcessID=D.ProcessID 
		AND H.ProcessNo = D.ProcessNo 
		AND H.FiscalYear = D.FiscalYear 
		AND H.SerialNo = D.SerialNo
	WHERE H.ProcessID = 90 
	AND H.ProcessNo = 11 
	AND H.FiscalYear = ' + ltrim(rtrim(str(@FiscalYear))) + ' 
	AND D.BaseSerialNo = ' + ltrim(rtrim(str(@SerialNo)))
	
	Print @StrSelect
	Exec sp_executesql @StrSelect;
	SELECT @@ROWCOUNT

	IF @@ROWCOUNT > 0
		UPDATE inv.tblStorageDocsHdr
		SET SendTaxTollState = 0,
		TPEdited = 1
		FROM inv.tblStorageDocsHdr a 
		LEFT JOIN sal.tblRestaurantSaleHdr b
			   ON a.SourceSerialNo=b.SerialNo 
			  AND a.BRN=b.BranchID
		WHERE a.ProcessID = 90 
		  AND a.ProcessNo = 11 
		  AND ((a.SendTaxTollState = 3 AND a.TPEdited = 0) OR (a.SendTaxTollState = 3 AND a.TPCanceled = 0))
		  AND b.SerialNo = @SerialNo

	SET @StrSelect = '
	UPDATE inv.tblStorageDocsHdr
	   SET Amount = isNull(Price-
					[Discount]-[Discount2]-[TotalLineDiscount]-[AfterSaleDiscount]-
					[OtherCost]-[TransportationCost]+[PackingCost]+[TaxCost]-[FixCost]+
					[OtherIncome]+[TransportationIncome]+
					CASE WHEN DiscountTaxOverWorth = 1 THEN 0 ELSE [TaxOverWorthCost]+[TollOverWorthCost] END +[IAToll]-[DistributeAmount],0)
	WHERE ProcessID = 90 
	AND ProcessNo = 11 
	AND FiscalYear = ' + ltrim(rtrim(str(@FiscalYear))) +' 
	AND SourceSerialNo = ' + ltrim(rtrim(str(@SerialNo))) 
	
	Print @StrSelect
	Exec sp_executesql @StrSelect;
	SELECT @@ROWCOUNT

	IF @@ROWCOUNT > 0
		UPDATE inv.tblStorageDocsHdr
		SET SendTaxTollState = 0,
		TPEdited = 1
		FROM inv.tblStorageDocsHdr a 
		LEFT JOIN sal.tblRestaurantSaleHdr b
			   ON a.SourceSerialNo=b.SerialNo 
			  AND a.BRN=b.BranchID
		WHERE a.ProcessID = 90 
		  AND a.ProcessNo = 11 
		  AND ((a.SendTaxTollState = 3 AND a.TPEdited = 0) OR (a.SendTaxTollState = 3 AND a.TPCanceled = 0))
		  AND b.SerialNo = @SerialNo

END
GO
