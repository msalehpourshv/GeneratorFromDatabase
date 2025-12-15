USE TS_ShirinVatanKarkhaneh_1_1404
GO
SET ANSI_NULLS, QUOTED_IDENTIFIER ON
GO
-- =========== TS-QC:NOTOK =====================
-- Author        : Hadi Sadeghi
-- Create date   : 86/12/22
-- Viewed By	 : 
-- Last Modified : 1393/08/04 - Hamid
-- Description   : 
-- =============================================
Create PROCEDURE [sal].[RptSale_SaleSettlement]
	@FiscalYear		Int = 95,
	@SerialNo		int = 2,
	@DocDateFr		Char(10) = Null,
	@DocDateTo		Char(10) = Null,
	@AcntCodeFr		Varchar(20) = Null,
	@AcntCodeTo		Varchar(20) = Null,
	@StoreID		Varchar(20) = Null,
	@RepOptions		VarChar(20) = '111', -- bit array
	@RepInfo		NVarChar(100) = '1@1@1',
	@ExtraParams	NVarChar(200) = ''
	
WITH ENCRYPTION
AS
BEGIN
SET NOCOUNT ON;

DECLARE @StrSelect1			NVarChar(Max);
DECLARE @StrSelect2  		NVarChar(Max);
DECLARE @StrWhere   		NVarChar(Max);
DECLARE @StrWhere2   		NVarChar(Max);
DECLARE @StartLayerIndex	TINYINT;

DECLARE @LangID		Char(1);
DECLARE @SessionNo	VarChar(10);
DECLARE @ReportID	VarChar(10);

	-- I N I T ----------------------------------------------------------------
	IF (@RepInfo	Is Null)	SET @RepInfo    = '1@1@1';

	IF (@FiscalYear Is Null)		SET @SerialNo = Null;
	IF (@SerialNo	Is Null)		SET @FiscalYear = Null;
	
	SET	@LangID		= pub.funSplitString(@RepInfo, '@', 1);
	SET @SessionNo	= pub.funSplitString(@RepInfo, '@', 2);
	SET @ReportID	= pub.funSplitString(@RepInfo, '@', 3);
	
	--SET @IsDetailed	= Substring(@RepOptions, 1, 1);
	--SET @HasSerial	= LTrim(pub.funSplitString(@ExtraParams, '@', 1));
	
	-- ==========
	DECLARE @UnitPart TINYINT

	SET @UnitPart  = 1

	SELECT @UnitPart = SettingValue from pub.tblSettings where SettingKey = 'UnitPart'

	DECLARE @UseRetPriceForCalcDiscountPrcntInSettlement int
	SET @UseRetPriceForCalcDiscountPrcntInSettlement=0
	SELECT @UseRetPriceForCalcDiscountPrcntInSettlement = 1 
	FROM pub.tblSettings 
	WHERE SettingKey = 'UseRetPriceForCalcDiscountPrcntInSettlement' AND Upper (SettingValue) = 'TRUE'

	IF @UnitPart IS NULL or @UnitPart = 0
		SET @UnitPart = 1

	DECLARE @str_Goods  tinyint,
			@str_GoodsSum tinyint

	SELECT @str_Goods = ISNULL(SUM (Layer1+Layer2+Layer3+Layer4+Layer5+Layer6+Layer7+Layer8+Layer9),0)
	FROM pub.tblCodeLayer 
	WHERE TableName='inv.tblGoods' AND PartNumber<@UnitPart

	SELECT @str_GoodsSum = Layer1+Layer2+Layer3+Layer4+Layer5+Layer6+Layer7+Layer8+Layer9
	FROM pub.tblCodeLayer 
	WHERE TableName= 'inv.tblGoods' AND PartNumber=@UnitPart

	-- ==========
	SELECT @StartLayerIndex = SettingValue
	FROM pub.tblSettings
	WHERE SettingKey = 'StartLayerIndex'	

	DECLARE @trs_CalcChequeAvrageWithInvoiceDate bit
	SET @trs_CalcChequeAvrageWithInvoiceDate  = 0
	SELECT @trs_CalcChequeAvrageWithInvoiceDate = SettingValue FROM pub.tblSettings WHERE SettingKey = 'trs_CalcChequeAvrageWithInvoiceDate'

	-- ========== Where
	SET @StrWhere = '1 = 1'
	SET @StrWhere2 = ' WHERE 1 = 1'
	
	IF (@FiscalYear Is Not Null) And (@FiscalYear <> 0)
	BEGIN
		SET @StrWhere = @StrWhere + ' AND (H.FiscalYear = ' + LTrim(Str(@FiscalYear)) + ')' 
		SET @StrWhere2 = @StrWhere2 + ' AND (D.FiscalYear = ' + LTrim(Str(@FiscalYear)) + ')' 
	END
		
	IF (@SerialNo Is Not Null) And (@SerialNo <> 0)
	BEGIN
		SET @StrWhere = @StrWhere + ' AND (H.SerialNo = ' + LTrim(Str(@SerialNo)) + ')' 
		SET @StrWhere2 = @StrWhere2 + ' AND (D.SerialNo = ' + LTrim(Str(@SerialNo)) + ')' 
	END

	IF (@AcntCodeFr Is Not Null) And (Len(Ltrim(@AcntCodeFr)) <> 0)
	BEGIN
		SET @StrWhere = @StrWhere + ' AND SUBSTRING(D.CustomerAcntCode,' + LTRIM(STR(@StartLayerIndex)) + ',' + LTRIM(STR(LEN(@AcntCodeFr))) + ')>=LEFT(''' + LTrim(RTrim(@AcntCodeFr)) + ''',' + LTRIM(STR(LEN(@AcntCodeFr))) + ')  '
		SET @StrWhere2 = @StrWhere2 + ' AND SUBSTRING(D.CustomerAcntCode,' + LTRIM(STR(@StartLayerIndex)) + ',' + LTRIM(STR(LEN(@AcntCodeFr))) + ')>=LEFT(''' + LTrim(RTrim(@AcntCodeFr)) + ''',' + LTRIM(STR(LEN(@AcntCodeFr))) + ')  '
	END
	IF (@AcntCodeTo Is Not Null) AND (Len(LTrim(@AcntCodeTo)) <> 0)
	BEGIN	
		SET @StrWhere =  @StrWhere + ' AND SUBSTRING(D.CustomerAcntCode,' + LTRIM(STR(@StartLayerIndex)) + ',' + LTRIM(STR(LEN(@AcntCodeTo))) + ')<=LEFT(''' + LTrim(RTrim(@AcntCodeTo)) + ''',' + LTRIM(STR(LEN(@AcntCodeTo))) + ')  '
		SET @StrWhere2 =  @StrWhere2 + ' AND SUBSTRING(D.CustomerAcntCode,' + LTRIM(STR(@StartLayerIndex)) + ',' + LTRIM(STR(LEN(@AcntCodeTo))) + ')<=LEFT(''' + LTrim(RTrim(@AcntCodeTo)) + ''',' + LTRIM(STR(LEN(@AcntCodeTo))) + ')  '
	END
	IF (@DocDateFr Is Not Null) And (Len(Ltrim(@DocDateFr)) <> 0)
				SET @StrWhere = @StrWhere + ' AND LEFT(H.DocDate,' + LTRIM(STR(LEN(@DocDateFr))) + ')>=''' + LTrim(RTrim(@DocDateFr)) + '''  '
		
	IF (@DocDateTo Is Not Null) AND (Len(LTrim(@DocDateTo)) <> 0)
		SET @StrWhere =  @StrWhere + ' AND LEFT(H.DocDate,' + LTRIM(STR(LEN(@DocDateTo))) + ')<=''' + LTrim(RTrim(@DocDateTo)) + '''  '
	
	IF @StoreID Is Not Null And @StoreID <> ''
	SET @StrWhere =  @StrWhere + ' AND H.StoreID = ''' + LTRIM(STR(LEN(@StoreID))) + ''''
	
	SET @StrSelect1 = '	
	Update trs.tblSettlementDtl
	SET CashPrice = ISNULL(Amount,0) FROM trs.tblSettlementDtl D 
	LEFT JOIN (
				SELECT SUM(Amount)Amount,
					   ProcessID,
					   ProcessNo,
					   FiscalYear,
					   SerialNo,
					   PayTypeID 
				FROM trs.tblPayDtl 
				WHERE PayTypeID = 1
				GROUP BY ProcessID, ProcessNo, FiscalYear, SerialNo, PayTypeID
				) P ON D.BasePayProcessID = P.ProcessID 
	AND D.BasePayProcessNo = P.ProcessNo 
	AND D.BasePayFiscalYear = P.FiscalYear 
	AND D.BasePaySerialNo = P.SerialNo	
	  '+ @StrWhere2
	-- ===========================				
	Print @StrSelect1
	Exec sp_executesql @StrSelect1;	
	
	SET @StrSelect1 = '
	UPDATE trs.tblSettlementDtl
	SET ChequePrice = ISNULL(Amount,0) FROM trs.tblSettlementDtl D 
	LEFT JOIN (
				SELECT SUM(Amount)Amount,
					   ProcessID,
					   ProcessNo,
					   FiscalYear,
					   SerialNo,
					   PayTypeID 
				FROM trs.tblPayDtl 
				WHERE PayTypeID = 6
				GROUP BY ProcessID, ProcessNo, FiscalYear, SerialNo, PayTypeID
				) P ON D.BasePayProcessID = P.ProcessID 
	AND	D.BasePayProcessNo = P.ProcessNo 
	AND D.BasePayFiscalYear = P.FiscalYear 
	AND D.BasePaySerialNo = P.SerialNo	
	 '+ @StrWhere2
	-- ===========================				
	Print @StrSelect1
	Exec sp_executesql @StrSelect1;	
	
	SET @StrSelect1 = '
	UPDATE trs.tblSettlementDtl
	SET DraftPrice = ISNULL(Amount,0) 
	FROM trs.tblSettlementDtl D 
	LEFT JOIN (
				SELECT SUM(Amount)Amount,
					   ProcessID,
					   ProcessNo,
					   FiscalYear,
					   SerialNo,
					   PayTypeID 
				FROM trs.tblPayDtl 
				WHERE PayTypeID = 35
				Group by ProcessID, ProcessNo, FiscalYear, SerialNo, PayTypeID
				) P ON D.BasePayProcessID = P.ProcessID 
	AND D.BasePayProcessNo = P.ProcessNo 
	AND D.BasePayFiscalYear = P.FiscalYear 
	AND D.BasePaySerialNo = P.SerialNo	
	 '+ @StrWhere2
	-- ===========================				
	Print @StrSelect1
	Exec sp_executesql @StrSelect1;	
	
	SET @StrSelect1 = '
	UPDATE trs.tblSettlementDtl
	SET DepositPrice = ISNULL(Amount,0) 
	FROM trs.tblSettlementDtl D 
	LEFT JOIN (
				SELECT SUM(Amount)Amount,
					   ProcessID,
					   ProcessNo,
					   FiscalYear,
					   SerialNo,
					   PayTypeID 
				FROM trs.tblPayDtl 
				WHERE PayTypeID = 3
				GROUP BY ProcessID, ProcessNo, FiscalYear, SerialNo, PayTypeID
				) P ON D.BasePayProcessID = P.ProcessID 
	AND D.BasePayProcessNo = P.ProcessNo 
	AND D.BasePayFiscalYear = P.FiscalYear 
	AND D.BasePaySerialNo = P.SerialNo	
	 '+ @StrWhere2
	-- ===========================				
	Print @StrSelect1
	Exec sp_executesql @StrSelect1;		   
	 
	DECLARE @PercentDecimals AS Int
	
	SELECT  @PercentDecimals = SettingValue
	FROM pub.tblSettings
	WHERE SettingKey = 'PercentDecimals'
	--=======================================
	SET @StrSelect1 = '
	SELECT *,
		   FLOOR(CASE WHEN (CashPrice + DraftPrice + DepositPrice + ChequePrice) = 0 THEN 0 ELSE
				(ChequePrice * CASE WHEN ChequeDate is Null THEN 0 ELSE 
	 			CASE WHEN '+ str(@trs_CalcChequeAvrageWithInvoiceDate)+' = 0 THEN pub.funFarsiDateDiff(''Day'', DocDate, ChequeDate) ELSE
				pub.funFarsiDateDiff(''Day'', SaleDocDate, ChequeDate) END  
		   END) / (CashPrice + DraftPrice + DepositPrice + ChequePrice) END ) ChequeAvrage, 
		   CASE WHEN SaleAmount - RetAmount = 0 THEN 0 ELSE
		   Round(CASE WHEN ' + str(@UseRetPriceForCalcDiscountPrcntInSettlement) + ' = 0 THEN Discount * 100 / (SaleAmount) ELSE 
				Discount * 100 / (SaleAmount - RetAmount) END , '+ LTRIM(RTrim(str(@PercentDecimals))) +') END DiscountPercent,
			(SELECT ReceiptOperatorName FROM sal.tblReceiptOperatorDtl b WHERE a.CollectorID = b.ReceiptOperatorID AND LanguageID = 1) ReceiptOperatorName,
			(SELECT BankName FROM trs.tblOurBanksDtl b WHERE a.CashID = b.BankCode AND LanguageID = 1) CashName,
			(SELECT BankName FROM trs.tblOurBanksDtl b WHERE a.CashID2 = b.BankCode AND LanguageID = 1) CashName2,
			(SELECT BankName FROM trs.tblOurBanksDtl b WHERE a.BankID = b.BankCode AND LanguageID = 1) BankName
	FROM (
		  Select H.*, 
				 D.BaseDstProcessID, 
				 D.BaseDstProcessNo, 
				 D.BaseDstFiscalYear, 
				 D.BaseDstSerialNo,
				 D.DocRowNo,
				 D.BaseSaleProcessID, 
				 D.BaseSaleProcessNo, 
				 D.BaseSaleFiscalYear, 
				 D.BaseSaleSerialNo,
				 D.CustomerAcntCode, 
				 pub.GetCodeName(D.CustomerAcntCode,' + LTrim(RTrim(@LangID)) + ') AS CustomerAcntName,
				 [acc].[funAccountRemain](D.CustomerAcntCode,H.DocDate) as CustomerAcntRemain, 
				 (SELECT AfterSaleDiscount FROM inv.tblStorageDocsHdr H WHERE H.ProcessID = D.BaseSaleProcessID AND H.ProcessNo = D.BaseSaleProcessNo AND H.FiscalYear = D.BaseSaleFiscalYear AND H.SerialNo = D.BaseSaleSerialNo) Discount, 
				 D.ExtraPrices, 
				 D.CashPrice, 
				 D.DraftPrice,
				 D.DepositPrice, 
				 D.ChequePrice,
				 D.DiscountAmount,
				 (SELECT ISNULL(SUM(Price), 0)
				  FROM (
						SELECT CASE WHEN VchNo = 0 THEN 0 ELSE ISNULL(Amount + AfterSaleDiscount,0) END Price,
							   ProcessID,
							   ProcessNo,
							   FiscalYear,
							   SerialNo 
						FROM inv.tblStorageDocsHdr
						) a	
				  WHERE (ProcessID = D.BaseSaleProcessID) 
					AND (ProcessNo = D.BaseSaleProcessNo) 
					AND (FiscalYear = D.BaseSaleFiscalYear) 
					AND (SerialNo = D.BaseSaleSerialNo)
				  ) SaleAmount,
				  (SELECT ISNULL(SUM(a),0) a 
				   FROM'
	SET @StrSelect2 = '	    
				   (
				    SELECT (SELECT CASE WHEN VchNo = 0 THEN 0 ELSE Amount END Price 
							FROM inv.tblStorageDocsHdr a
							WHERE a.ProcessID = b.ProcessID 
							  AND a.ProcessNo = b.ProcessNo 
							  AND a.FiscalYear = b.FiscalYear 
							  AND a.SerialNo = b.SerialNo) a	
                    FROM trs.tblSettlementRetInvoice as b 
                    WHERE D.BaseSaleProcessID = b.SaleProcessID 
					  AND D.BaseSaleProcessNo = b.SaleProcessNo 
					  AND D.BaseSaleFiscalYear = b.SaleFiscalYear 
					  AND D.BaseSaleSerialNo = b.SaleSerialNo
					  AND b.SettlementID = D.SerialNo  
					  AND b.BaseType = 1
					  )aa
					  ) RetAmount,
					(Select ISNULL(SUM(a),0) a 
					 FROM (
							SELECT (
									SELECT CASE WHEN VchNo = 0 THEN 0 ELSE Amount END Price 
									FROM inv.tblStorageDocsHdr a
									WHERE a.ProcessID = b.ProcessID 
									  AND a.ProcessNo = b.ProcessNo 
									  AND a.FiscalYear = b.FiscalYear 
									  AND a.SerialNo = b.SerialNo 
									) a	
							FROM trs.tblSettlementRetInvoice as b 
							WHERE D.BaseSaleProcessID = b.SaleProcessID 
							  AND D.BaseSaleProcessNo = b.SaleProcessNo 
							  AND D.BaseSaleFiscalYear = b.SaleFiscalYear 
							  AND D.BaseSaleSerialNo = b.SaleSerialNo
							  AND b.SettlementID = D.SerialNo 
							  AND b.BaseType = 2
							  )aa
							  ) RetAmount2, 
					 (SELECT TOP 1 ChequeDate 
					  FROM trs.tblPayDtl p 
					  WHERE p.ProcessID = D.BasePayProcessID 
					    AND p.ProcessNo = D.BasePayProcessNo 
						AND	p.FiscalYear = D.BasePayFiscalYear 
						AND p.SerialNo = D.BasePaySerialNo 
						AND p.Amount = D.ChequePrice
					  ) as ChequeDate,
					  (SELECT DocDate 
					   FROM inv.tblStorageDocsHdr H 
					   WHERE H.ProcessID = D.BaseSaleProcessID 
					     AND H.ProcessNo = D.BaseSaleProcessNo 
						 AND H.FiscalYear = D.BaseSaleFiscalYear 
						 AND H.SerialNo = D.BaseSaleSerialNo) SaleDocDate
			FROM trs.tblSettlementHdr H
			INNER JOIN trs.tblSettlementDtl D ON H.ProcessID = D.ProcessID 
											 AND H.ProcessNo = D.ProcessNo 
											 AND H.FiscalYear = D.FiscalYear 
											 AND H.SerialNo = D.SerialNo
			WHERE ' + @StrWhere+ '     ) a  
			ORDER BY DocRowNo'
	-- ===========================			
	SET @StrSelect1 = @StrSelect1 + @StrSelect2	
	Print @StrSelect1
	Exec sp_executesql @StrSelect1;	

END
GO
