USE TS_ShirinVatanKarkhaneh_1_1404
GO
SET ANSI_NULLS, QUOTED_IDENTIFIER ON
GO
-- =========== TS-QC:NOTOK =====================
-- Author        : Hadi Sadeghi
-- Create date   : 90/03/05 
-- Viewed By	 : 
-- Last Modified : 
-- Description   : 
-- =============================================
--[sal].[SpSmsDocs_Sale] '2','1','7','8', ' ProcessID = 90 ','True'
CREATE PROCEDURE [sal].[SpSmsDocs_Sale] 
	@PartNumber		CHAR(2),
	@LanguageID		CHAR(2),
	@StartAcnt		CHAR(2),
	@LenAcnt		CHAR(2),
	@strWhere		Nvarchar(4000),
	@NotSend		BIT='False'
	
	
WITH ENCRYPTION
 AS
BEGIN
SET NOCOUNT ON;

DECLARE @StrSelect	NVarChar(4000);

	SET @StrSelect = '
		SELECT DISTINCT A.SMSMobile,Total,H.ProcessID,H.ProcessNo,H.FiscalYear,H.SerialNo,SUBSTRING(H.AcntCode, ' + @StartAcnt + ' , ' + @LenAcnt + ' )AcntCode,H.DocDate,
		TotalPrice-Discount-Discount2-Discount3-DiscountDtl-EarnestMoney-TransportationCost+TransportationIncome-OtherCost-FixCost+OtherIncome+PackingCost+TaxCost+TaxOverWorthCost+TollOverWorthCost AS PureAmount,
		[acc].[funGetAcntName](SUBSTRING(H.AcntCode, ' + @StartAcnt + ' , ' + @LenAcnt + ' ), ' + @PartNumber + ' , ' + @LanguageID + ')AcntName,H.DocDesc,[pub].[funGetSaleTypesName](SaleTypeID,' + @LanguageID + ') SaleTypeName
		FROM inv.tblStorageDocsHdr H
		INNER Join 
			(SELECT ProcessID,ProcessNo,FiscalYear,SerialNo,SUM(GoodsQuantity * GoodsPrice) TotalPrice,SUM(DiscountDtl) DiscountDtl 
			 FROM inv.tblStorageDocsDtl
			 WHERE ' + @strWhere + '
			 GROUP BY ProcessID,ProcessNo,FiscalYear,SerialNo) D
		ON H.ProcessID= D.ProcessID AND H.ProcessNo = D.ProcessNo AND H.FiscalYear = D.FiscalYear AND H.SerialNo=D.SerialNo
		INNER JOIN acc.tblAcnt A ON A.AcntCode=SUBSTRING(H.AcntCode, ' + @StartAcnt + ' , ' + @LenAcnt + ' ) AND A.PartNumber =  ' + @PartNumber + ' 
		INNER JOIN (SELECT SUBSTRING(AcntCode, ' + @StartAcnt + ' , ' + @LenAcnt + ' ) AcntCode,SUM(Debit-Credit) Total 
					FROM acc.tblVoucherDtl  
					Group BY SUBSTRING(AcntCode,  ' +@StartAcnt + ' , ' +@LenAcnt + ' ) 
					--HAVING SUM(Debit-Credit) > 0
					 ) V
		ON V.AcntCode=SUBSTRING(H.AcntCode, ' + @StartAcnt + ' , ' + @LenAcnt + ' )'     

	IF 	@NotSend = 'True'	
		SET @StrSelect = @StrSelect + 'INNER JOIN sms.tblSmsDocsDtl S ON NOT(H.ProcessID = S.BaseProcessID AND H.ProcessNo = S.BaseProcessNo AND H.FiscalYear = S.BaseFiscalYear AND H.SerialNo = S.BaseSerialNo) '
	PRINT @StrSelect
	EXEC sp_executesql @StrSelect;
		
END	    
GO
