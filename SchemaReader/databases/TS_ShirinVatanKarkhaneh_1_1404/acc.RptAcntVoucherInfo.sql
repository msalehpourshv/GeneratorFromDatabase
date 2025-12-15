USE TS_ShirinVatanKarkhaneh_1_1404
GO
SET ANSI_NULLS, QUOTED_IDENTIFIER ON
GO
-- =========== TS-QC:UPDATED ====================
-- Author		 : TakroSystem\H Sadeghi
-- Create date   : 1399/07/07
-- Viewed By	 : 
-- Last Modified : 
-- Description	 : گزارش تاريخ آخرين گردش و آخرين خريد
-- =============================================
Create PROCEDURE acc.RptAcntVoucherInfo
	@FromAcntCode		varchar(20)='',
	@ToAcntCode			varchar(20)='',
	@CurrentDate        varchar(10)='1399/07/01',
	@ToDate				varchar(10)='1399/07/01',
	@UsedFilter			char(1)='1',-- 1-Used 2-not_used 3-All
	@RemainPart			char(1)=2,
	@Start				INT=8,
	@LEN				INT=5,
	@UserIsAdmin		Bit='True',
	@UserID				varchar(5)=5,
	@BeforeYearDB		VARCHAR(200)='',
	@Before2YearDB		VARCHAR(200)=''
WITH ENCRYPTION
AS
BEGIN

	DECLARE @StrSelect1	NVarChar(max);
	DECLARE @StrSelect2	NVarChar(max);
	DECLARE @StrWhere	NVarChar(max);
	DECLARE @StrBefoerYear	NVarChar(max);
	DECLARE @StrBefoerYear_Voucher	NVarChar(max);
	DECLARE	@AcntCode	varchar(20);
	DECLARE	@RemainTo	float;
	DECLARE	@ord		int;
	DECLARE	@prc		float;
	DECLARE	@dat		char(10);
	DECLARE	@LayerLen	int;
	DECLARE	@StartLayerIndex	int;
	DECLARE	@AcntPartNumber	int;
	DECLARE	@Today	char(10);

	SELECT @Today = left(pub.funFarsiDate(GetDate()), 10);

	SELECT @AcntPartNumber = SettingValue
	FROM pub.tblSettings
	WHERE SettingKey = 'AcntPartNumberForRemainCalculation'

	SELECT @LayerLen = SettingValue
	FROM pub.tblSettings
	WHERE SettingKey = 'LayerLen'
	
	SELECT @StartLayerIndex = SettingValue
	FROM pub.tblSettings
	WHERE SettingKey = 'StartLayerIndex'
	
	SET @StrWhere = ''
	SET @StrBefoerYear = ''
	SET @StrBefoerYear_Voucher = ''

	CREATE TABLE #tblResult1
	(
		AcntCode			VARCHAR(20) collate arabic_cs_as,
		RemainFr			FLOAT,
		Purchase			FLOAT,
		CheqPaid			FLOAT,
		CheqRcpt			FLOAT,
		CheqCurr			FLOAT,
		CheqRetr			FLOAT,
		CashBill			FLOAT,
		SalePric			FLOAT,
		SaleRetr			FLOAT,
		SaleRetP			FLOAT,
		SaleDisc			FLOAT,
		SaleInvc			FLOAT,
		IvcAvgFn			CHAR(10) null,
		IvcAvgRe			CHAR(10) null,
		RecAvgFn			CHAR(10) null,
		RemainTo			FLOAT,
		MaxDebitRemain		FLOAT,
		MaxReceivableRemain	FLOAT,
		ComplementCredit	FLOAT,
		AccountRemain		FLOAT,
		ManagerView         VARCHAR(500) ,
		VisitorView         VARCHAR(500) 		

	);

	CREATE TABLE #tblAcnt1
	(
		AcntCode	VARCHAR(20) collate arabic_cs_as
	);

	SET @StrSelect1 = 
		' INSERT INTO #tblAcnt1 ' +
		' SELECT DISTINCT SUBSTRING(AcntCode,'+ LTrim(RTrim(Str(@Start))) +','+ LTrim(RTrim(Str(@LEN))) +') AcntCode ' + 
		' FROM acc.tblVoucherDtl D ' + 
		' WHERE (1=1) '

	IF (@FromAcntCode <>'')	
		SET @StrSelect1 = @StrSelect1 + ' AND (SubString(D.AcntCode,'+ LTrim(RTrim(Str(@Start))) +','+ LTrim(RTrim(Str(LEN(@FromAcntCode)))) + ') >= '''+ltrim(rtrim(@FromAcntCode))+''' )'  

	IF (@ToAcntCode <>'')
		SET @StrSelect1 = @StrSelect1 + ' AND (SubString(D.AcntCode,'+ LTrim(RTrim(Str(@Start))) +','+ LTrim(RTrim(Str(LEN(@ToAcntCode)))) + ') <= '''+ltrim(rtrim(@ToAcntCode))+''' )'

	PRINT @StrSelect1;
	EXEC sp_executesql @StrSelect1;

	INSERT INTO #tblResult1
	SELECT AcntCode,0,0,0,0,0,0,0,0,0,0,0,0,'','','',0,0,0,0,0,'',''
	FROM #tblAcnt1;
	
	--RemainFr, RemainTo, AccountRemain
	WITH AggregatesI AS (
		 SELECT SUBSTRING(D.AcntCode, @Start , @LEN) AS Code,
				SUM(CASE WHEN D.VchKind = 2 THEN D.Debit - D.Credit ELSE 0 END) AS SumRemainFr,
				SUM(CASE WHEN D.VchKind > 3 AND D.VchKind < 4 THEN D.Debit - D.Credit ELSE 0 END) AS SumRemainTo,
				SUM(CASE WHEN D.VchKind NOT IN (3,4) THEN D.Debit ELSE 0 END) AS SumDebit,
				SUM(CASE WHEN D.VchKind NOT IN (3,4) THEN D.Credit ELSE 0 END) AS SumCredit
		 FROM acc.tblVoucherDtl D
		 GROUP BY SUBSTRING(D.AcntCode, @Start , @LEN)
		 )
	UPDATE R
	SET RemainFr = ISNULL(A.SumRemainFr,0),
		RemainTo = ISNULL(A.SumRemainTo,0),
		AccountRemain = ISNULL(A.SumDebit - A.SumCredit,0)
	FROM #tblResult1 R
	INNER JOIN AggregatesI A ON A.Code = R.AcntCode;
	
	--Buy, SaleInvoice
	SELECT ProcessID, AcntCode, SUM(SidePriceSum + GoodsPrice) PayableAmount
	INTO #tbl_X_Group
	FROM
	(
		SELECT H.ProcessID, H.AcntCode, H.SidePriceSum,
			ISNULL((
				SELECT SUM(D.GoodsPrice*D.GoodsQuantity)
				FROM inv.tblStorageDocsDtl D 
				WHERE H.ProcessID = D.ProcessID 
				  AND H.ProcessNo = D.ProcessNo 
				  AND H.FiscalYear = D.FiscalYear 
				  AND H.SerialNo = D.SerialNo
			),0) GoodsPrice
		FROM inv.vwStorageDocsHdr H 
		WHERE (H.ProcessID in (55, 90)) 
		  AND (SUBSTRING(AcntCode, @Start , @LEN) <> '')
	) M
	GROUP BY ProcessID, AcntCode;

	WITH AggregatesII AS (
		 SELECT SUBSTRING(G.AcntCode, @Start , @LEN) AS Code,
				SUM(CASE WHEN G.ProcessID = 55 THEN G.PayableAmount ELSE 0 END) AS SumPurchase,
				SUM(CASE WHEN G.ProcessID = 90 THEN G.PayableAmount ELSE 0 END) AS TopSaleInvc
		 FROM #tbl_X_Group G
		 GROUP BY SUBSTRING(G.AcntCode, @Start , @LEN)
		 )
	UPDATE R
	SET Purchase = ISNULL(A.SumPurchase,0),
		SaleInvc = ISNULL(A.TopSaleInvc,0)
	FROM #tblResult1 R
	INNER JOIN AggregatesII A ON A.Code = R.AcntCode;

	--Cheques Paid, Cheques Return, CashBill, RecAvgFn
	SELECT SUBSTRING(D.CreditCode, @Start , @LEN) AS Code,
		   SUM(CASE WHEN D.EventNo = 1 AND D.ProcessID IN (1,10) AND D.PayTypeID IN (6,26) 
		   			THEN Amount ELSE 0 END) AS SumCheqPaid,
		   CheqRetrAgg.SumCheqRetr,
		   SUM(CASE WHEN D.ProcessID = 1 AND D.PayTypeID IN (1,2,3,4,35)
		   			THEN Amount ELSE 0 END) AS SumCashBill,
		   SUM(CASE WHEN D.ProcessID IN (1,10) AND D.PayTypeID IN (6,26)
		   			THEN Amount + pub.funFarsiDateDiff('Day', @Today, ChequeDate)
		   			ELSE 0 END) AS RawRecAvgIn,
		   SUM(CASE WHEN D.EventNo = 1 AND D.ProcessID IN (1,10) AND D.PayTypeID IN (6,26)
		   			THEN Amount ELSE 0 END) AS CheqPaidBase,
		   0 RecAvgOffset
	INTO #TempAggregatesIII
	FROM trs.tblPayDtl D
	OUTER APPLY (SELECT SUM(Amount) AS SumCheqRetr
				 FROM trs.tblPayDtl X
				 WHERE X.ProcessID IN (13,18,24)
				   AND X.PayTypeID IN (6,26)
				   AND X.EventNo = D.EventNo
				   AND X.ProcessID IN (1,10)
				   AND X.PayTypeID = D.PayTypeID
				   AND X.VolumeFiscalYear = D.VolumeFiscalYear
				   AND X.VolumeRowNo = D.VolumeRowNo) CheqRetrAgg
	GROUP BY SUBSTRING(D.CreditCode, @Start , @LEN), CheqRetrAgg.SumCheqRetr;

	UPDATE #TempAggregatesIII
	   SET RecAvgOffset = CASE WHEN CheqPaidBase > 0 THEN RawRecAvgIn / NULLIF(CheqPaidBase,0) ELSE 0 END;

	UPDATE R
	SET CheqPaid = ISNULL(A.SumCheqPaid,0),
		CheqRetr = ISNULL(A.SumCheqRetr,0),
		CashBill = ISNULL(A.SumCashBill,0),
		RecAvgFn = CASE WHEN A.RecAvgOffset IS NOT NULL
						THEN pub.funFarsiDateAddDays('Day', @Today, A.RecAvgOffset)
						ELSE '' END
	FROM #tblResult1 R
	INNER JOIN #TempAggregatesIII A ON A.Code = R.AcntCode;

	DROP TABLE #TempAggregatesIII


	-- Cheques Not Receipt
	UPDATE #tblResult1
	SET CheqCurr = [trs].[funReceivableDocs_UnReceipt_Sum_Modified](R.AcntCode, 1, @Today,@Start,@LEN)
	FROM #tblResult1 R;

	UPDATE #tblResult1 SET CheqRcpt=CheqPaid-CheqCurr;
	
	--SalePric, SaleRetr
	WITH AggregatesIV AS (
		 SELECT SUBSTRING(D.AcntCode, @Start , @LEN) AS Code,
				SUM(CASE WHEN D.ProcessID = 90 THEN D.GoodsPrice * D.GoodsQuantity ELSE 0 END) AS SumSalePric,
				SUM(CASE WHEN D.ProcessID = 100 THEN D.GoodsPrice * D.GoodsQuantity ELSE 0 END) AS SumSaleRetr
		 FROM inv.tblStorageDocsDtl D 
		 GROUP BY SUBSTRING(D.AcntCode, @Start , @LEN)
		 )
	UPDATE R
	SET SalePric = ISNULL(A.SumSalePric,0),
		SaleRetr = ISNULL(A.SumSaleRetr,0)
	FROM #tblResult1 R
	INNER JOIN AggregatesIV A ON A.Code = R.AcntCode;

	
	-- Sale Ret Percent
	UPDATE #tblResult1
	SET SaleRetP = (SaleRetr  * 100) / SaleInvc
	WHERE (SaleInvc > 0)

	-- Sale Discount
	UPDATE #tblResult1
	SET SaleDisc = 
	(
		SELECT ISNULL(SUM(Discount+Discount2+Discount3+TotalLineDiscount), 0)
		FROM inv.tblStorageDocsHdr
		WHERE (ProcessID = 90) 
		  AND (SUBSTRING(AcntCode, @Start , @LEN) = #tblResult1.AcntCode)
	)

	-- Invoices Average
	UPDATE #tblResult1
	SET IvcAvgFn =
 		pub.funFarsiDateAddDays('Day', @Today,
		(
			SELECT ISNULL(SUM((T.PriceDtl+T.SidePriceSum) * pub.funFarsiDateDiff('Day', @Today, T.DocDate) ), 0)
			FROM (SELECT H.DocDate,
						 H.SidePriceSum,
						 H.ProcessID,
						 H.ProcessNo,
						 H.FiscalYear,
						 H.SerialNo,
						(SELECT SUM(D.GoodsQuantity*D.GoodsPrice) 
						 FROM inv.tblStorageDocsDtl D 
						 WHERE D.ProcessID = H.ProcessID 
						   AND D.ProcessNo = H.ProcessNo 
						   AND D.FiscalYear = H.FiscalYear 
						   AND D.SerialNo = H.SerialNo
						) PriceDtl
				FROM inv.vwStorageDocsHdr H
				WHERE (H.ProcessID=90) 
				  AND (SUBSTRING(H.AcntCode, @Start , @LEN)=#tblResult1.AcntCode)
			) T
		) / SaleInvc
		)
	WHERE (SaleInvc > 0)

	-- MaxDebitRemain, MaxReceivableRemain, ComplementCredit
	UPDATE #tblResult1
	SET IvcAvgRe = '';

	WITH AggregatesV AS (
		 SELECT SUBSTRING(AC.AcntCode, @Start , @LEN) AS Code,
				MAX(MaxDebitRemain) AS MaxDebitRemain,
				MAX(MaxReceivableRemain) AS MaxReceivableRemain,
				MAX(ComplementCredit) AS ComplementCredit
		 FROM acc.tblAcnt AC
		 GROUP BY SUBSTRING(AC.AcntCode, @Start , @LEN)
		 )
	UPDATE R
	SET MaxDebitRemain = ISNULL(A.MaxDebitRemain,0),
		MaxReceivableRemain = ISNULL(A.MaxReceivableRemain,0),
		ComplementCredit = ISNULL(A.ComplementCredit,0)
	FROM #tblResult1 R
	INNER JOIN AggregatesV A ON A.Code = R.AcntCode;

	--ManagerView, VisitorView
	WITH AggregatesVI AS (
		 SELECT SUBSTRING(AC.AcntCode, @Start , @LEN) AS Code,
				MAX(ISNULL(ManagerView,'')) AS ManagerView,
				MAX(ISNULL(VisitorView,'')) AS VisitorView
		 FROM acc.tblAcntDtl AC
		 WHERE PartNumber = @AcntPartNumber
		 GROUP BY SUBSTRING(AC.AcntCode, @Start , @LEN)
		 )
	UPDATE R
	SET ManagerView = ISNULL(A.ManagerView,0),
		VisitorView = ISNULL(A.VisitorView,0)
	FROM #tblResult1 R
	INNER JOIN AggregatesVI A ON A.Code = R.AcntCode;
			
	-------------------------------------------------
	DECLARE @sumPrc FLOAT
	DECLARE @sumDay BIGINT
	
	SET @sumDay = 0
	SET @sumPrc = 0
	
	DECLARE csr_rem CURSOR FOR
		SELECT AcntCode, RemainTo
		FROM #tblResult1
		WHERE (RemainTo > 0)
		
	OPEN csr_rem 
	FETCH NEXT FROM csr_rem into @AcntCode, @RemainTo
	
	WHILE (@@FETCH_STATUS = 0)
	BEGIN
		DECLARE csr_ivc CURSOR FOR
			SELECT  ROW_NUMBER() OVER (ORDER BY H.DocDate, H.SerialNo) row,
					H.DocDate, H.SidePriceSum+(
						SELECT SUM(D.GoodsQuantity*D.GoodsPrice) 
						FROM inv.tblStorageDocsDtl D 
						WHERE D.ProcessID=H.ProcessID and D.ProcessNo=H.ProcessNo and D.FiscalYear=H.FiscalYear and D.SerialNo=H.SerialNo
					) PriceDtl
			FROM inv.vwStorageDocsHdr H
			WHERE (H.ProcessID=90) and (SUBSTRING(H.AcntCode, @Start , @LEN)=@AcntCode)
			ORDER BY 1 DESC
		
		OPEN csr_ivc 
		FETCH NEXT FROM csr_ivc INTO @ord, @dat, @prc
		
		WHILE (@@FETCH_STATUS = 0)
		BEGIN
			IF (@RemainTo <= 0) BREAK;
			
			SET @sumPrc = @sumPrc + @prc
			SET @sumDay = @sumDay + @prc*(pub.funFarsiDateDiff('Day', @Today, @dat))

			SET @RemainTo = @RemainTo - @prc
			FETCH NEXT FROM csr_ivc INTO @ord, @dat, @prc
		END;

		CLOSE csr_ivc  
		DEALLOCATE csr_ivc 

		IF (@sumPrc > 0)
		BEGIN
			UPDATE #tblResult1
			SET IvcAvgRe = pub.funFarsiDateAddDays('Day', @Today, round(@sumDay/@sumPrc, 0))
			WHERE AcntCode = @AcntCode
		END
				
		FETCH NEXT FROM csr_rem INTO @AcntCode, @RemainTo
	END

	CLOSE csr_rem 
	DEALLOCATE csr_rem 


	IF @BeforeYearDB<>''
	BEGIN
		SET @StrBefoerYear=
			'UNION
			 SELECT SUBSTRING(s.AcntCode,'+ LTrim(RTrim(Str(@Start))) +','+ LTrim(RTrim(Str(@LEN))) +') AcntCode,MAX(DocDate) DocDate
			 FROM ' + @BeforeYearDB + '.inv.tblStorageDocsDtl s 
			 WHERE ProcessID=90 
			 GROUP BY SUBSTRING(s.AcntCode,'+ LTrim(RTrim(Str(@Start))) +','+ LTrim(RTrim(Str(@LEN))) +') '

		SET @StrBefoerYear_Voucher=
			'UNION
			 SELECT SUBSTRING(s.AcntCode,'+ LTrim(RTrim(Str(@Start))) +','+ LTrim(RTrim(Str(@LEN))) +') AcntCode,MAX(DocDate) DocDate
			 FROM ' + @BeforeYearDB + '.acc.tblVoucherDtl s 
			 GROUP BY SUBSTRING(s.AcntCode,'+ LTrim(RTrim(Str(@Start))) +','+ LTrim(RTrim(Str(@LEN))) +') '

	END
	IF @Before2YearDB<>''
	BEGIN
		SET @StrBefoerYear= @StrBefoerYear +
			'UNION
			 SELECT SUBSTRING(s.AcntCode,'+ LTrim(RTrim(Str(@Start))) +','+ LTrim(RTrim(Str(@LEN))) +') AcntCode,MAX(DocDate) MaxDate
			 FROM ' + @Before2YearDB + '.inv.tblStorageDocsDtl s 
			 WHERE ProcessID=90 
			 GROUP BY SUBSTRING(s.AcntCode,'+ LTrim(RTrim(Str(@Start))) +','+ LTrim(RTrim(Str(@LEN))) +') '

		SET @StrBefoerYear_Voucher= @StrBefoerYear_Voucher+
			'UNION
			 SELECT SUBSTRING(s.AcntCode,'+ LTrim(RTrim(Str(@Start))) +','+ LTrim(RTrim(Str(@LEN))) +') AcntCode,MAX(DocDate) MaxDate
			 FROM ' + @Before2YearDB + '.acc.tblVoucherDtl s 
			 GROUP BY SUBSTRING(s.AcntCode,'+ LTrim(RTrim(Str(@Start))) +','+ LTrim(RTrim(Str(@LEN))) +') '			 
	END
			 	
	IF (@FromAcntCode <> '')
		SET @StrWhere = @StrWhere + ' AND (SubString(a.AcntCode,1,' + ltrim(rtrim(str(len(@FromAcntCode)))) + ') >= '''+ltrim(rtrim(@FromAcntCode))+''' )'   
	IF (@ToAcntCode <> '')
		SET @StrWhere = @StrWhere + ' AND (SubString(a.AcntCode,1,' + ltrim(rtrim(str(len(@ToAcntCode))))+ ') <= '''+ltrim(rtrim(@ToAcntCode))+''' )'

	IF @UsedFilter <>'3'
	BEGIN
		BEGIN TRY
			Drop Table   ##ACCCode
		END TRY
		BEGIN CATCH
		END CATCH

		SELECT DISTINCT SUBSTRING(AcntCode, @Start, @LEN ) AcntCode INTO ##ACCCode FROM acc.tblVoucherDtl
	END
	
	IF @UsedFilter = '1'
		SET @StrWhere = @StrWhere + ' AND (a.AcntCode in (SELECT * FROM ##ACCCode)  )'
	IF @UsedFilter = '2'
		SET @StrWhere = @StrWhere + ' AND (a.AcntCode not in (SELECT * FROM ##ACCCode)  )'
	
	IF (@ToDate <>'')
		SET @StrWhere = @StrWhere + ' AND (b.DocDate IS NULL or b.DocDate<'''+ @ToDate +''')'

	IF @UserIsAdmin='False'
		SET @StrWhere = @StrWhere + ' AND acc.funPermitted(' + @UserID + ', a.AcntCode,' + @RemainPart + ') = 1 '		
		

	SET @StrSelect1 ='
	SELECT a.AcntCode,
		   a.AcntName,
		   ISNULL(d.MaxDate,''1300/01/01'') MaxDate,
		   ISNULL(b.DocDate,''1300/01/01'') LastSaleDate,
		   ISNULL(SumDebit,'''') SumDebit,
	       pub.funFarsiDateDiff(''Day'',CASE WHEN b.DocDate is null or b.DocDate = '''' THEN ''1300/01/01'' ELSE b.DocDate END ,''' + @CurrentDate + ''') DIFF,
	       pub.funFarsiDateDiff(''Day'',CASE WHEN d.MaxDate is null or d.MaxDate = '''' THEN ''1300/01/01'' ELSE d.MaxDate END ,''' + @CurrentDate + ''') VoucherDIFF,
		   ac.InsertDate,
		   isnull(a.Address1,'''') Address1,
		   isnull(ac.VisitPathID1,'''') VisitPathID1, 
		   isnull(ac.VisitPathID2,'''') VisitPathID2, 
		   isnull(ac.VisitPathID3,'''') VisitPathID3, 
		   isnull(ac.VisitPathID4,'''') VisitPathID4,
		   isnull(ac.PersonType,'''') PersonType,
		   CASE WHEN ac.PersonType=0 THEN '''' WHEN ac.PersonType=1 THEN ''حقیقی'' WHEN ac.PersonType=2 THEN ''حقوقی'' WHEN ac.PersonType=3 THEN ''مشارکت مدنی'' WHEN ac.PersonType=4 THEN ''اتباع غیر ایرانی'' WHEN ac.PersonType=5 THEN ''مصرف کننده نهایی'' END PersonTypeName,
		   isnull(ac.Mobile,'''') Mobile,
		   isnull(ac.Tel,'''') Tel,
		   isnull(ac.NationalIDNumber,'''') NationalIDNumber,
		   isnull(ac.NationalIdentity,'''') NationalIdentity,
		   isnull([pub].[funGetLocationName](ac.LocationID,1),'''') LocationName, 
		   isnull(ac.EconomicalCode,'''') EconomicalCode,
		   isnull(VP1.VisitPathName,'''') as VisitPathName1,
		   isnull(VP2.VisitPathName,'''') as VisitPathName2,
		   isnull(VP3.VisitPathName,'''') as VisitPathName3,
		   isnull(VP4.VisitPathName,'''') as VisitPathName4,
		   R.RemainFr,
		   R.Purchase,
		   R.CheqPaid,
		   R.CheqRcpt,
		   R.CheqCurr,
		   R.CheqRetr,
		   R.CashBill,
		   R.SalePric,
		   R.SaleRetr,
		   R.SaleRetP,
		   R.SaleDisc,
		   R.SaleInvc,
		   R.IvcAvgFn,
		   R.IvcAvgRe,
		   R.RecAvgFn,
		   R.RemainTo,
		   ISNULL(R.MaxDebitRemain, 0) MaxDebitRemain,
		   ISNULL(R.MaxReceivableRemain, 0) MaxReceivableRemain,
		   ISNULL(R.ComplementCredit, 0) ComplementCredit,
		   R.AccountRemain,
		   ISNULL(R.ManagerView, '''') ManagerView,
		   ISNULL(R.VisitorView, '''') VisitorView,
		   CASE WHEN ac.CodeClosed = 0 THEN ''فعال'' ELSE ''مسدود'' END CodeClosed, 
		   ac.OtherTels,
		   ac.ZipCode,   
		   ac.MaxDaysAfterExpiration, 
		   ac.PersonnelNo,
		   ac.IDNo, 
		   ac.InitialGrad, 
		   ac.CompanyRegisterNo,  
		   ac.MaxReturnCheque, 
		   ac.MemberCode, 
		   ac.MemberDate,
		   ac.InternetAddress, 
		   [sal].[funGetCustomerKindName] (ac.CustomerKindID,1) CustomerKindName,
		   ac.FatherName, 
		   ac.ReagentName, 
		   ac.SMSMobile, 
		   ac.AccountNumber, 
		   ac.ShabaAccountNumber,
		   CASE WHEN ac.IsCurrency = 1 THEN ''ارزی'' ELSE ''ریالی'' END IsCurrency, 
		   ac.CompleteDate, 
		   ac.Zone, 
		   CASE WHEN ac.PossessionType = 1 THEN ''مالک'' WHEN ac.PossessionType = 2 THEN ''استیجاری'' WHEN ac.PossessionType = 3 THEN ''سرقفلی'' ELSE ''نعیین‌نشده'' END PossessionType, 
		   CASE WHEN ac.SalesRoomSituation = 1 THEN ''میدان'' WHEN ac.SalesRoomSituation = 2 THEN ''خیابان اصلی'' WHEN ac.SalesRoomSituation = 3 THEN ''بورس'' WHEN ac.SalesRoomSituation = 4 THEN ''خیابان فرعی'' ELSE ''نعیین‌نشده'' END SalesRoomSituation, 
		   acc.funGetSalesRoomClassName (ac.SalesRoomClass, 1) SalesRoomClassName, 
		   ac.PortalCount, 
		   ac.GPSPoint, 
		   ac.BirthDate,
		   ac.ParticularDate1, 
		   ac.ParticularDate2, 
		   ac.ParticularDate3, 
		   ac.ParticularDate4, 
		   ac.BankAcountNo, 
		   ac.ShabaNo,
		   ac.TransporterID, 
		   ac.FineExemption, 
		   ac.FineDelayPercent, 
		   ac.SaleCustomerType, 
		   ac.BuyCustomerType,  
		   ac.MinSalePrice,
		   ac.MaxSalePrice, 
		   ac.FreeDocDays, 
		   ac.OutStandChequeCount, 
		   ac.OutStandChequePrice, 
		   ac.ReturnChequeCount, 
		   ac.OpenAccInvoiceCount, 
		   acc.funGetCampaignName (ac.CampaignID, 1) CampaignName,
		   ac.VerifyCode,
		   [sal].[funGetSaleTypeName] (ac.SaleTypeID, 1) SaleTypeName,'  
	SET @StrSelect2 = '
		   ac.SaleCash, 
		   CASE WHEN ac.ContainTax = 1 THEN ''مشمول'' ELSE ''عدم مشمولیت'' END ContainTax, 
		   CASE WHEN ac.Gender = 1 THEN ''مذکر'' WHEN ac.Gender = 2 THEN ''مونث'' ELSE ''تعیین نشده'' END Gender, 
		   ac.MaxReturnChequeDays
	FROM acc.tblAcntDtl a
	INNER JOIN #tblResult1 R ON a.AcntCode = R.AcntCode
	INNER JOIN acc.tblAcnt ac ON ac.AcntCode = a.AcntCode 
							 AND ac.PartNumber = a.PartNumber
	LEFT JOIN acc.tblVisitPathDtl VP1 ON VP1.VisitPathID = ac.VisitPathID1 AND VP1.PartNumber = 1
	LEFT JOIN acc.tblVisitPathDtl VP2 ON VP2.VisitPathID = ac.VisitPathID2 AND VP2.PartNumber = 2
	LEFT JOIN acc.tblVisitPathDtl VP3 ON VP3.VisitPathID = ac.VisitPathID3 AND VP3.PartNumber = 3
	LEFT JOIN acc.tblVisitPathDtl VP4 ON VP4.VisitPathID = ac.VisitPathID4 AND VP4.PartNumber = 4
	LEFT JOIN (SELECT AcntCode, MAX(DocDate) DocDate
			   FROM (SELECT SUBSTRING(s.AcntCode,'+ LTrim(RTrim(Str(@Start))) +','+ LTrim(RTrim(Str(@LEN))) +') AcntCode,MAX(DocDate)  DocDate 
			   		 FROM inv.tblStorageDocsDtl s 
			   		 WHERE ProcessID=90 
			   		 GROUP BY SUBSTRING(s.AcntCode,'+ LTrim(RTrim(Str(@Start))) +','+ LTrim(RTrim(Str(@LEN))) +') 
			   		 ' + @StrBefoerYear + ' ) b
			   GROUP BY AcntCode ) b ON a.AcntCode = b.AcntCode
	LEFT JOIN (SELECT SUBSTRING(a.AcntCode,'+ LTrim(RTrim(Str(@Start))) +','+ LTrim(RTrim(Str(@LEN))) +') AcntCode, SUM(Debit-Credit) SumDebit 
			   FROM acc.tblVoucherDtl a
			   INNER JOIN acc.tblAcnt b ON b.PartNumber = 1 
									   AND b.AcntCode = SUBSTRING(a.AcntCode,1,6) 
									   AND b.AcntType NOT IN (91, 92) AND a.VchKind <> 0 
			   GROUP BY SUBSTRING(a.AcntCode,'+ LTrim(RTrim(Str(@Start))) +','+ LTrim(RTrim(Str(@LEN))) +')
			   HAVING SUM(Debit-Credit)>0 ) c ON a.AcntCode = c.AcntCode
	LEFT JOIN (SELECT AcntCode, MAX(DocDate) MaxDate
			   FROM (SELECT SUBSTRING(s.AcntCode,'+ LTrim(RTrim(Str(@Start))) +','+ LTrim(RTrim(Str(@LEN))) +') AcntCode, MAX(DocDate) DocDate 
					 FROM acc.tblVoucherDtl s 
					 GROUP BY SUBSTRING(s.AcntCode,'+ LTrim(RTrim(Str(@Start))) +','+ LTrim(RTrim(Str(@LEN))) +') 
			   ' + @StrBefoerYear_Voucher + ' ) b
			   GROUP BY AcntCode ) d ON a.AcntCode = d.AcntCode
	WHERE a.PartNumber = ' + @RemainPart + ' 
	' + @StrWhere + '
	ORDER BY ISNULL(b.DocDate,''1300/01/01'') desc'

	PRINT @StrSelect1
	PRINT @StrSelect2
	
	SET @StrSelect1 = @StrSelect1 + @StrSelect2
	Exec sp_executesql @StrSelect1;

END
GO
