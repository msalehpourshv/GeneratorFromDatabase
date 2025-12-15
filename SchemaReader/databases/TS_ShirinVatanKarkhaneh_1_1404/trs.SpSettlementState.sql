USE TS_ShirinVatanKarkhaneh_1_1404
GO
SET ANSI_NULLS, QUOTED_IDENTIFIER ON
GO
-- =========== TS-QC:UPDATED ====================
-- Author		 : Jafari	
-- Create date   : 1398/05/14
-- Viewed By	 : 
-- Last Modified : 
-- Last Modifier : 
-- Description	 : گزارش فروش
-- ==============================================
Create PROCEDURE trs.SpSettlementState
	@ExtraParams		NVarChar(Max) = '',
	@RepOptions			VarChar(20) = '111' ,-- bit array	
	@RepInfo			NVarChar(100) = '1@1@1'
WITH ENCRYPTION
AS
---- Declarations ---------------
DECLARE @StrSelect			NVarChar(max);
DECLARE @StrJoins			NVarChar(max);
DECLARE @StrWhere			NVarChar(max);
DECLARE	@LangID		Char(1);
DECLARE	@SessionNo	Int; 
DECLARE	@ReportID	Int;
DECLARE	@UserID		Int;
DECLARE	@UserIsAdmin bit;

SET @LangID		= pub.funSplitString(@RepInfo, '@', 1);
SET @SessionNo	= pub.funSplitString(@RepInfo, '@', 2);
SET @ReportID	= pub.funSplitString(@RepInfo, '@', 3);
SET @StrSelect	= ''
SET @StrJoins	= ''
SET @StrWhere	= ''
	----------------------------------------------------
DECLARE @StartLayerIndex TINYINT;
DECLARE @AcntPartNumber	 TINYINT;
DECLARE @LayerLen		 TINYINT;
DECLARE @SerialNoFrom	INT;
DECLARE @SerialNoTo		INT;
DECLARE @FiscalYear		INT;
DECLARE @StoreID		INT;
DECLARE @GoodsID		INT;
DECLARE @AcntCode1		INT;
DECLARE @AcntCode2		INT;
DECLARE @AcntCode3		INT;
DECLARE @AcntCode4		INT;
DECLARE @Visitor1		INT;
DECLARE @Visitor2		INT;
DECLARE @Visitor3		INT;
DECLARE @Visitor4		INT;
DECLARE @SaleTypeID		INT;
DECLARE @DocDateF		CHAR(10);
DECLARE @DocDateT		CHAR(10);
DECLARE @DocDateSaleF	CHAR(10);
DECLARE @DocDateSaleT	CHAR(10);
DECLARE @CollectorID	VARCHAR(20)
DECLARE @CashID			VARCHAR(20)
DECLARE @CashID2		VARCHAR(20)
DECLARE @BankID			VARCHAR(20)
DECLARE @Remain			INT
DECLARE @strPay2trs		VARCHAR(10)
DECLARE @SaleSerialNoF	 INT;
DECLARE @SaleSerialNoT	 INT;
DECLARE @DstSerialNoF	 INT;
DECLARE @DstSerialNoT	 INT;
DECLARE @IsOfficialValue INT;
DECLARE @Start			 VARCHAR(2);
DECLARE @LEN			 VARCHAR(2);
DECLARE	@BeforeYearDB	 VARCHAR(200)='';
DECLARE @StrBefoerYear	 NVARCHAR(max);

SET @SerialNoFrom		= LTrim(pub.funSplitString(@ExtraParams, '@', 1)); 
SET @SerialNoTo			= LTrim(pub.funSplitString(@ExtraParams, '@', 2)); 
SET @FiscalYear			= LTrim(pub.funSplitString(@ExtraParams, '@', 3)); 
SET @StoreID			= LTrim(pub.funSplitString(@ExtraParams, '@', 4));
SET @GoodsID			= LTrim(pub.funSplitString(@ExtraParams, '@', 5)); 
SET @AcntCode1			= LTrim(pub.funSplitString(@ExtraParams, '@', 6)); 
SET @AcntCode2			= LTrim(pub.funSplitString(@ExtraParams, '@', 7)); 
SET @AcntCode3			= LTrim(pub.funSplitString(@ExtraParams, '@', 8)); 
SET @AcntCode4			= LTrim(pub.funSplitString(@ExtraParams, '@', 9)); 
SET @Visitor1			= LTrim(pub.funSplitString(@ExtraParams, '@', 10)); 
SET @Visitor2			= LTrim(pub.funSplitString(@ExtraParams, '@', 11)); 
SET @Visitor3			= LTrim(pub.funSplitString(@ExtraParams, '@', 12)); 
SET @Visitor4			= LTrim(pub.funSplitString(@ExtraParams, '@', 13)); 
SET @SaleTypeID			= LTrim(pub.funSplitString(@ExtraParams, '@', 14)); 
SET @DocDateF			= LTrim(pub.funSplitString(@ExtraParams, '@', 15)); 
SET @DocDateT			= LTrim(pub.funSplitString(@ExtraParams, '@', 16)); 
SET @CollectorID		= LTrim(pub.funSplitString(@ExtraParams, '@', 17)); 
SET @CashID				= LTrim(pub.funSplitString(@ExtraParams, '@', 18)); 
SET @CashID2			= LTrim(pub.funSplitString(@ExtraParams, '@', 19)); 
SET @BankID				= LTrim(pub.funSplitString(@ExtraParams, '@', 20)); 
SET @Remain				= LTrim(pub.funSplitString(@ExtraParams, '@', 21)); 
SET @SaleSerialNoF		= LTrim(pub.funSplitString(@ExtraParams, '@', 22)); 
SET @SaleSerialNoT		= LTrim(pub.funSplitString(@ExtraParams, '@', 23)); 
SET @DocDateSaleF		= LTrim(pub.funSplitString(@ExtraParams, '@', 24)); 
SET @DocDateSaleT		= LTrim(pub.funSplitString(@ExtraParams, '@', 25)); 
SET @DstSerialNoF		= LTrim(pub.funSplitString(@ExtraParams, '@', 26)); 
SET @DstSerialNoT		= LTrim(pub.funSplitString(@ExtraParams, '@', 27)); 
SET @strPay2trs			= LTrim(pub.funSplitString(@ExtraParams, '@', 28)); 
SET @IsOfficialValue	= LTrim(pub.funSplitString(@ExtraParams, '@', 29)); 
SET @Start				= LTrim(pub.funSplitString(@ExtraParams, '@', 30)); 
SET @LEN				= LTrim(pub.funSplitString(@ExtraParams, '@', 31)); 
SET @BeforeYearDB		= LTrim(pub.funSplitString(@ExtraParams, '@', 32)); 
 
DECLARE @PriceDecimalsToForms AS Int

	SET	@PriceDecimalsToForms = 3
	SELECT @PriceDecimalsToForms=SettingValue
	FROM pub.tblSettings
	WHERE SettingKey = 'PriceDecimalsToForms'

SET @StrWhere=''
IF @SerialNoFrom>0
	SET @StrWhere+=' AND D.SerialNo>= '+ STR(@SerialNoFrom)
IF @SerialNoFrom>0
	SET @StrWhere+=' AND D.SerialNo<= '+ STR(@SerialNoTo)
IF (@StoreID > 0)
	SET @StrWhere +=  ' AND ' + pub.funGetFilterString(@SessionNo, @ReportID, @StoreID, 'S.StoreID')
IF (@AcntCode1 > 0)
	SET @StrWhere +=  ' AND ' + pub.funGetFilterString(@SessionNo, @ReportID, @AcntCode1, 'S.AcntCode')
IF (@AcntCode2 > 0)
	SET @StrWhere +=  ' AND ' + pub.funGetFilterString(@SessionNo, @ReportID, @AcntCode2, 'S.AcntCode')
IF (@AcntCode3 > 0)
	SET @StrWhere +=  ' AND ' + pub.funGetFilterString(@SessionNo, @ReportID, @AcntCode3, 'S.AcntCode')
IF (@AcntCode4 > 0)
	SET @StrWhere +=  ' AND ' + pub.funGetFilterString(@SessionNo, @ReportID, @AcntCode4, 'S.AcntCode')
IF (@Visitor1 > 0)
	SET @StrWhere +=  ' AND ' + pub.funGetFilterString(@SessionNo, @ReportID, @Visitor1, 'S.VisitorAcntCode')
IF (@Visitor2 > 0)
	SET @StrWhere +=  ' AND ' + pub.funGetFilterString(@SessionNo, @ReportID, @Visitor2, 'S.VisitorAcntCode')
IF (@Visitor3 > 0)
	SET @StrWhere +=  ' AND ' + pub.funGetFilterString(@SessionNo, @ReportID, @Visitor3, 'S.VisitorAcntCode')
IF (@Visitor4 > 0)
	SET @StrWhere +=  ' AND ' + pub.funGetFilterString(@SessionNo, @ReportID, @Visitor4, 'S.VisitorAcntCode')
IF (@SaleTypeID> 0)
	SET @StrWhere +=  ' AND ' + pub.funGetFilterString(@SessionNo, @ReportID, @SaleTypeID, 'S.SaleTypeID')
IF (@DocDateF <> '')
	SET @StrWhere +=  ' AND H.DocDate >='''+ @DocDateF+''''
IF (@DocDateT <> '')
	SET @StrWhere +=  ' AND H.DocDate <='''+ @DocDateT+''''
IF (@DocDateSaleF <> '')
	SET @StrWhere +=  ' AND S.DocDate >='''+ @DocDateSaleF+''''
IF (@DocDateSaleT <> '')
	SET @StrWhere +=  ' AND S.DocDate <='''+ @DocDateSaleT+''''
IF (@CollectorID <> '')
	SET @StrWhere +=  ' AND H.CollectorID ='''+ @CollectorID+''''
IF (@CashID <> '')
	SET @StrWhere +=  ' AND H.CashID ='''+ @CashID+''''
IF (@CashID2 <> '')
	SET @StrWhere +=  ' AND H.CashID2 ='''+ @CashID2+''''
IF (@BankID <> '')
	SET @StrWhere +=  ' AND H.BankID ='''+ @BankID+''''
IF (@SaleTypeID> 0)
	SET @StrWhere +=  ' AND ' + pub.funGetFilterString(@SessionNo, @ReportID, @SaleTypeID, 'S.SaleTypeID')
IF @SaleSerialNoF>0
	SET @StrWhere+=' AND D.BaseSaleSerialNo>= '+ STR(@SaleSerialNoF)
IF @SaleSerialNoT>0
	SET @StrWhere+=' AND D.BaseSaleSerialNo<= '+ STR(@SaleSerialNoT)
IF @DstSerialNoF>0
	SET @StrWhere+=' AND D.BaseDstSerialNo>= '+ STR(@DstSerialNoF)
IF @DstSerialNoT>0
	SET @StrWhere+=' AND D.BaseDstSerialNo<= '+ STR(@DstSerialNoT)
IF @IsOfficialValue = 2
	Set @StrWhere += ' AND S.IsOfficial = 0 '
IF @IsOfficialValue = 3
	Set @StrWhere += ' AND S.IsOfficial = 1 '
IF @IsOfficialValue <> 2 and @IsOfficialValue <> 3
	Set @StrWhere += ''

IF @BeforeYearDB<>''
	SET @StrBefoerYear =
		'UNION
		 SELECT SUBSTRING(s.AcntCode,'+ @Start +','+ @LEN +') AcntCode,MAX(DocDate) DocDate
		 FROM ' + @BeforeYearDB + '.inv.tblStorageDocsDtl s  WITH (NOLOCK) 
		 where ProcessID=90 
		 group by SUBSTRING(s.AcntCode,'+ @Start +','+ @LEN +') '
ELSE
	SET @StrBefoerYear = ''
	
SELECT @StartLayerIndex = SettingValue FROM pub.tblSettings	WHERE SettingKey = 'StartLayerIndex'	
SELECT @AcntPartNumber	= SettingValue FROM pub.tblSettings WHERE SettingKey='AcntPartNumberForRemainCalculation'
SELECT @LayerLen		= SettingValue FROM pub.tblSettings WHERE SettingKey='LayerLen'
	
IF (@StartLayerIndex Is Null)					SET @StartLayerIndex = Null;
IF (@LayerLen Is Null)							SET @LayerLen = 1;
IF (@AcntPartNumber Is Null)					SET @AcntPartNumber = 1;
If (@strPay2trs Is Null) or (@strPay2trs = '')	SET @strPay2trs = ' in (0,1)'

BEGIN TRY
	DROP TABLE #tblSet
END TRY
BEGIN CATCH
END CATCH

SELECT SUBSTRING(CustomerAcntCode,Cast(@Start as int),Cast(@LEN as int)) PAcntCode ,* INTO #tblSet FROM trs.tblSettlementDtl

	--select @StrWhereIN
SET @StrSelect='
SELECT *,(TotalPriceSale + ExtraPrices) - (SaleRetPrice + SaleRetPrice2 + CashPrice + DraftPrice + DepositPrice + ChequePrice + Discount+DiscountAmount) Remain
FROM
(
	  SELECT D.ProcessID,
			 D.ProcessNo,
			 D.FiscalYear,
			 D.SerialNo,--ltrim(str(D.FiscalYear ))+''/''+ltrim(str(D.SerialNo)) SerialNo, 
			 D.DocRowNo,D.BaseDstSerialNo,--ltrim(str(D.BaseDstFiscalYear ))+''/''+ltrim(str(D.BaseDstSerialNo)) BaseDstSerialNo,
			 D.BaseSaleSerialNo,--ltrim(str(D.BaseSaleFiscalYear ))+''/''+ltrim(str(D.BaseSaleSerialNo)) BaseSaleSerialNo,
			 H.DocDate,
			 CustomerAcntCode, 
			 pub.GetCodeName(D.CustomerAcntCode,1) AS CustomerAcntName,
			 (SELECT MaxDebitRemain 
			  FROM acc.tblAcnt  WITH (NOLOCK) 
			  WHERE PartNumber = '+ LTrim(RTrim(str(@AcntPartNumber))) +' AND AcntCode = SUBSTRING(D.CustomerAcntCode,'+ LTrim(RTrim(str(@StartLayerIndex))) +','+ LTrim(RTrim(str(@LayerLen)))+')) MaxDebitRemain,
			 CASE WHEN S.VchNo = 0 THEN 0 ELSE ISNULL(S.Amount,0) END TotalPriceSale,
			 (SELECT ISNULL(SUM(a),0) a 
			  FROM (Select (SELECT CASE WHEN VchNo=0 THEN 0 
										ELSE Amount END Price 
										FROM inv.tblStorageDocsHdr a WITH (NOLOCK) 
										WHERE a.ProcessID = b.ProcessID AND a.ProcessNo = b.ProcessNo AND a.FiscalYear = b.FiscalYear AND a.SerialNo = b.SerialNo ) a	
							FROM trs.tblSettlementRetInvoice as b  WITH (NOLOCK) 
							WHERE D.BaseSaleProcessID = b.SaleProcessID AND D.BaseSaleProcessNo = b.SaleProcessNo AND D.BaseSaleFiscalYear = b.SaleFiscalYear AND D.BaseSaleSerialNo = b.SaleSerialNo AND b.SettlementID = D.SerialNo AND b.BaseType = 1)  aa) SaleRetPrice,
			 (SELECT ISNULL(SUM(a),0) a 
			  FROM (SELECT (SELECT CASE WHEN VchNo=0 THEN 0 
								   ELSE Amount END Price 
								   FROM inv.tblStorageDocsHdr a WITH (NOLOCK) 
								   WHERE a.ProcessID = b.ProcessID AND a.ProcessNo = b.ProcessNo AND a.FiscalYear = b.FiscalYear AND a.SerialNo = b.SerialNo ) a	
							 FROM trs.tblSettlementRetInvoice as b WITH (NOLOCK) 
							 WHERE D.BaseSaleProcessID = b.SaleProcessID AND D.BaseSaleProcessNo = b.SaleProcessNo AND D.BaseSaleFiscalYear = b.SaleFiscalYear AND D.BaseSaleSerialNo = b.SaleSerialNo AND b.SettlementID = D.SerialNo  and b.BaseType = 2) aa) SaleRetPrice2,
			 DiscountAmount,
			 CashPrice,
			 DraftPrice,
			 ChequePrice,
			 DepositPrice,  
			 S.AfterSaleDiscount Discount, 
			 round(S.AfterSaleDiscount / S.Amount * 100,'+ LTrim(RTrim(str(@PriceDecimalsToForms))) +') DiscountPercentage,
			 D.ExtraPrices, 
			 CASE WHEN S.IsOfficial = 1 THEN '+'''رسمی'''+' 
			      ELSE '+'''غیررسمی'''+' 
				  END AS IsOfficial,
			 --[acc].[funAccountRemain](D.CustomerAcntCode,H.DocDate) as CustomerDebitRemain,
			 S.VisitorAcntCode, 
			 pub.GetCodeName(S.VisitorAcntCode,1) AS VisitorName,
			 F.NationalIdentity,
			 F.NationalIDNumber,
			 sal.GetPayOffTypeName(S.PayOffTypeID,1) PayOffTypeName,
			 --inv.funGetRemainInvoice (D.ProcessID,D.ProcessNo,D.FiscalYear,D.SerialNo) RemainInvoice, 
			 --H.CollectorID,
			 --H.CashID,
			 --H.CashID2,
			 --H.BankID,
			 --StoreID,
			 --SaleTypeID,
			 --D.*
			  F.VisitPathID1,
			  ISNULL(VP1.VisitPathName,'''') as VisitPathName1,
			  F.VisitPathID2,
			  ISNULL(VP2.VisitPathName,'''') as VisitPathName2,
			  F.VisitPathID3,
			  ISNULL(VP3.VisitPathName,'''') as VisitPathName3,
			  F.VisitPathID4,
			  ISNULL(VP4.VisitPathName,'''') as VisitPathName4,
			  ISNULL(b.DocDate,''1300/01/01'') LastSaleDate,
			  ISNULL(SH.DocDate,'''') as SaleOrderDate,
			  ISNULL(C.DocDate,'''') as SaleDate
	FROM #tblSet AS D'
Set @StrJoins = ' 
	INNER JOIN trs.tblSettlementHdr H  WITH (NOLOCK)  ON H.ProcessID = D.ProcessID AND H.ProcessNo = D.ProcessNo AND H.FiscalYear = D.FiscalYear AND H.SerialNo = D.SerialNo  
	INNER JOIN inv.tblStorageDocsHdr S  WITH (NOLOCK)  ON S.ProcessID = D.BaseSaleProcessID AND S.ProcessNo = D.BaseSaleProcessNo AND S.FiscalYear = D.BaseSaleFiscalYear AND S.SerialNo = D.BaseSaleSerialNo
	OUTER APPLY acc.funGetCodeInfo(D.CustomerAcntCode) AS F
	LEFT JOIN acc.tblVisitPathDtl VP1  WITH (NOLOCK) ON VP1.VisitPathID = F.VisitPathID1 AND VP1.PartNumber = 1
	LEFT JOIN acc.tblVisitPathDtl VP2  WITH (NOLOCK) ON VP2.VisitPathID = F.VisitPathID2 AND VP2.PartNumber = 2
	LEFT JOIN acc.tblVisitPathDtl VP3  WITH (NOLOCK) ON VP3.VisitPathID = F.VisitPathID3 AND VP3.PartNumber = 3
	LEFT JOIN acc.tblVisitPathDtl VP4  WITH (NOLOCK) ON VP4.VisitPathID = F.VisitPathID4 AND VP4.PartNumber = 4
	LEFT JOIN sal.tblSaleOrderHdr SH   WITH (NOLOCK) ON S.BaseProcessID = SH.ProcessID AND S.BaseProcessNo = SH.ProcessNo AND S.BaseFiscalYear = SH.FiscalYear AND S.BaseSerialNo = SH.SerialNo
	LEFT JOIN 
		(SELECT AcntCode,MAX(DocDate) DocDate
		 FROM (
			 SELECT SUBSTRING(s.AcntCode,'+ LTrim(RTrim(@Start)) +','+ LTrim(RTrim(@LEN)) +') AcntCode,MAX(DocDate) DocDate 
			 FROM inv.tblStorageDocsDtl s  WITH (NOLOCK) 
			 WHERE ProcessID=90 
			 GROUP BY SUBSTRING(s.AcntCode,'+LTrim(RTrim(@Start)) +','+ LTrim(RTrim(@LEN)) +') 
			 ' + @StrBefoerYear + '
		     ) b GROUP BY AcntCode
		)b ON PAcntCode = b.AcntCode
	LEFT JOIN (SELECT ProcessID,ProcessNo,FiscalYear,SerialNo,DocDate      
			   FROM inv.tblStorageDocsHdr WITH (NOLOCK) 
			   WHERE ProcessID = 90
				   )C ON C.ProcessID= D.BaseSaleProcessID
				   AND C.ProcessNo = D.BaseSaleProcessNo
				   AND C.FiscalYear = D.BaseSaleFiscalYear
				   AND C.SerialNo = D.BaseSaleSerialNo
	WHERE S.Amount <> 0 AND S.ProcessID = 90 AND Pay2trs '+ @strPay2trs +  @StrWhere +'
) D  '
SET @StrSelect = @StrSelect + @StrJoins

IF @Remain<>0
	SET  @StrSelect+=' WHERE ((TotalPriceSale + ExtraPrices) - (SaleRetPrice + SaleRetPrice2 + CashPrice + DraftPrice + DepositPrice + ChequePrice + AfterSaleDiscount+DiscountAmount)) >' +str(@Remain) 
SET   @StrSelect+=' ORDER BY D.ProcessID,D.ProcessNo,D.FiscalYear,D.SerialNo , D.DocRowNo '

	PRINT @StrSelect	
	EXEC sp_executesql @StrSelect; 
GO
