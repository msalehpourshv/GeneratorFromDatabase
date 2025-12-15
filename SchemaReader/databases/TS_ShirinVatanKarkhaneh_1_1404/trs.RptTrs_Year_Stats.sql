USE TS_ShirinVatanKarkhaneh_1_1404
GO
SET ANSI_NULLS, QUOTED_IDENTIFIER ON
GO
-- =========== TS-QC:UPDATED ====================
-- Author		 : TakroSystem\Ahmadnejad
-- Create date   : 1386/04/18
-- Viewed By	 : 
-- Last Modified : 1392/01/07
-- Description	 : <Treasury Documents Chart>
-- ----------------------------------------------
-- نمودار و گزارش سالیانه اسناد پرداختنی - در جریان وصول - دریافتنی
-- ==============================================
CREATE PROCEDURE [trs].[RptTrs_Year_Stats]
	@ProcessNo		int = 1,
	@CurrentYear	Char(4), -- 4 Digits FiscalYear--
	@RepOptions		VarChar(10) = '1', -- bit array options
	@RepInfo		NVarChar(100) = '1@1@1'
WITH ENCRYPTION
As
DECLARE @NotPassedOnly	Bit
DECLARE @StrSelectPrim 	NVarChar(2000);
DECLARE @StrSelect		NVarChar(4000);
DECLARE @StrStatePay   	NVarChar(100);
DECLARE @StrStateRec   	NVarChar(100);
DECLARE @StrStateBnk   	NVarChar(100);

DECLARE @StrPayPayment	VarChar(2);
DECLARE @StrPayReceipt	VarChar(2);
DECLARE @StrPayReturn	VarChar(2);

DECLARE @StrRecPrimRec			VarChar(2);
DECLARE @StrRecReceive			VarChar(2);

DECLARE @StrRecPaidBnkPrim		VarChar(2);
DECLARE @StrRecPaidBnk			VarChar(2);
DECLARE @StrRecPaidBnkRetCsh	VarChar(2);
DECLARE @StrRecPaidBnkRetOwn	VarChar(2);

DECLARE @StrRecPaidPsn			VarChar(2);
DECLARE @StrRecPaidPsnRetCsh	VarChar(2);
DECLARE @StrRecPaidPsnRetOwn	VarChar(2);
Begin

	SET NOCOUNT ON;

	--  init Variables  --
	SET @StrPayPayment	= ' 2' 	   /*     اسناد پرداختنی - پرداخت  */
	SET @StrPayReceipt	= '27'	   /*       اسناد پرداختنی - وصول  */
	SET @StrPayReturn	= '28'	   /*      اسناد پرداختنی - برگشت  */

	SET @StrRecPrimRec	= '10'     /* (اسناد دریافتنی - دریافت (اول دوره  */
	SET @StrRecReceive	= ' 1'      /*           اسناد دریافتنی - دریافت   */
	
	SET @StrRecPaidPsn		 = ' 2' /*   اسناد دریافتنی - واگذاری به اشخاص   */
	SET @StrRecPaidPsnRetCsh = '17' /*   اسناد دریافتنی - برگشت واگذاری به اشخاص به صندوق  */
	SET @StrRecPaidPsnRetOwn = '18' /*   اسناد دریافتنی - برگشت واگذاری به اشخاص به مالکش  */

	SET @StrRecPaidBnkPrim	 = '20' /*      (اسناد دریافتنی - واگذاری به بانکها (اول دوره  */
	SET @StrRecPaidBnk		 = '21' /*                 اسناد دریافتنی - واگذاری به بانکها  */
	SET @StrRecPaidBnkRetCsh = '23' /*  اسناد دریافتنی - برگشت واگذاری به بانکها به صندوق  */
	SET @StrRecPaidBnkRetOwn = '24' /*  اسناد دریافتنی - برگشت واگذاری به بانکها به مالکش  */
	
	SET @NotPassedOnly	= Substring(@RepOptions, 1, 1);
	--SET @xxxxxxxxx	= Substring(@RepOptions, 2, 1); -- used

	CREATE TABLE #tbl_RptTreasury_Year_Statistics_Days (Days Char(10) Collate Arabic_CS_AS)

	-- Set Primary Query to Create Days --
	DECLARE @idx1 Int
	DECLARE @idx2 Int
	-- Fill Table Variable With Year Days --
	SET @idx1 = 1

	While @idx1 <= 12
	Begin
		Set @idx2 = 1

		While @idx2 <= 31
		Begin
			Insert Into #tbl_RptTreasury_Year_Statistics_Days
			Values (	Case When Len(LTrim(Str(@idx1))) < 2 Then '0' Else '' End + Ltrim(Str(@idx1)) + '/' + 
						Case When Len(LTrim(Str(@idx2))) < 2 Then '0' Else '' End + LTrim(Str(@idx2)))	
			Set @idx2 = @idx2 + 1
		End

		Set @idx1 = @idx1 + 1
	End;
	-- ===============================================================
	-- == SELECT =====================================================
	-- ===============================================================
	If @NotPassedOnly = 1
		SET @StrStatePay = @StrPayPayment + ',25'
	Else
		SET @StrStatePay = @StrPayPayment + ', ' + @StrPayReceipt + ', ' + @StrPayReturn + ',25'

	If @NotPassedOnly = 1
		SET @StrStateRec = '40,' + @StrRecReceive + ', ' + @StrRecPrimRec + ', ' + @StrRecPaidPsnRetCsh + ', ' + @StrRecPaidBnkRetCsh
	Else				 
		SET @StrStateRec = ''

	SET @StrStateBnk = @StrRecPaidBnkPrim + ',' + @StrRecPaidBnk 

	create table #tbl_RptTreasury_Year_Statistics
	(
		DocYear int not null,
		DocDate char(5) Collate Arabic_CS_AS not null,
		PayableAmount float not null,
		ReceivableAmount float not null,
		InReceiptAmount float not null,
		LoanAmount float not null
	);

	SET @StrSelect = '
	----------------------------- Paid ---------------------------------------------
	insert into #tbl_RptTreasury_Year_Statistics
	SELECT	Left(PD.ChequeDate, 4) DocYear, 
			RIGHT(PD.ChequeDate, 5) DocDate,
            PD.Amount PayableAmount, 
			0 AS ReceivableAmount, 
			0 AS InReceiptAmount,
			0 as LoanAmoun
	FROM	trs.tblPayDtl AS PD
			INNER JOIN
			( 
				SELECT	VolumeFiscalYear, VolumeRowNo, Max(EventNo) AS EventNo
				FROM	trs.tblPayDtl
				WHERE	PayTypeID IN(8, 28) 
				GROUP BY VolumeFiscalYear, VolumeRowNo
			) AS VOL ON VOL.VolumeFiscalYear = PD.VolumeFiscalYear AND VOL.VolumeRowNo = PD.VolumeRowNo AND VOL.EventNo = PD.EventNo
	WHERE PD.PayTypeID IN(8, 28) 
		AND PD.ProcessNo = ' + LTRIM(STR(@ProcessNo)) + '
		AND PD.ProcessID IN (' + @StrStatePay + ')'

	print @StrSelect;
	Exec sp_executesql @StrSelect;

	SET @StrSelect = '
	----------------------------- Loan ---------------------------------------------
	insert	into #tbl_RptTreasury_Year_Statistics
	SELECT	Left(D.InstallmentDate, 4) DocYear, 
			RIGHT(D.InstallmentDate, 5) DocDate,
            0 as PayableAmount, 
			0 AS ReceivableAmount, 
			0 AS InReceiptAmount,
			D.InstallmentAmount + D.InstallmentCost as LoanAmoun
	FROM	trs.tblLoanDtl AS D 
		INNER JOIN 
		(
			SELECT	D.ProcessNo, D.FiscalYear, D.SerialNo, D.InstallmentNo 
			FROM	trs.tblLoanDtl D 
						inner join trs.tblLoanHdr H on H.FiscalYear= D.FiscalYear AND H.ProcessNo = D.ProcessNo AND H.SerialNo = D.SerialNo AND H.ProcessID = D.ProcessID
			WHERE	D.ProcessID = 7
			EXCEPT
			SELECT	D.BaseProcessNo, D.BaseFiscalYear, D.BaseSerialNo, D.InstallmentNo 
			FROM	trs.tblLoanDtl D  
						inner join trs.tblLoanHdr H on H.FiscalYear= D.FiscalYear AND H.ProcessNo = D.ProcessNo AND H.SerialNo = D.SerialNo AND H.ProcessID = D.ProcessID
			WHERE	D.ProcessID = 8
		) AS T ON   D.ProcessID = 7 AND D.ProcessNo = T.ProcessNo AND D.FiscalYear = T.FiscalYear AND D.SerialNo = T.SerialNo AND D.InstallmentNo = T.InstallmentNo
	WHERE D.ProcessNo = ' + LTRIM(STR(@ProcessNo))
	
	print @StrSelect;
	Exec sp_executesql @StrSelect;

	SET @StrSelect = '
	--------------------------- Received -------------------------------------------
	insert into #tbl_RptTreasury_Year_Statistics
	SELECT	Left(PD.ChequeDate, 4) DocYear, 
			RIGHT(PD.ChequeDate, 5) DocDate, 
			0 AS PayableAmount, 
			PD.Amount AS ReceivableAmount, 
			0 AS InReceiptAmount,
			0 as LoanAmount
	FROM	trs.tblPayDtl AS PD
		INNER JOIN
		( 
			SELECT	VolumeFiscalYear, VolumeRowNo, Max(EventNo) AS EventNo
			FROM	trs.tblPayDtl
			WHERE	PayTypeID IN (6, 26)
			GROUP BY VolumeFiscalYear, VolumeRowNo
		) AS VOL ON VOL.VolumeFiscalYear = PD.VolumeFiscalYear AND VOL.VolumeRowNo = PD.VolumeRowNo AND VOL.EventNo = PD.EventNo
	WHERE PD.PayTypeID IN (6, 26) 
		AND PD.ProcessNo = ' + LTRIM(STR(@ProcessNo))

	If (@StrStateRec <> '')
		SET @StrSelect = @StrSelect + '	AND PD.ProcessID IN (' + @StrStateRec + ')'
	Else
		SET @StrSelect = @StrSelect + '	AND PD.ProcessID NOT IN (' + @StrStateBnk + ')'

	print @StrSelect;
	Exec sp_executesql @StrSelect;

	SET @StrSelect = '
	--------------------------- InReceipt -------------------------------------------
	insert into #tbl_RptTreasury_Year_Statistics
	SELECT	Left(PD.ChequeDate, 4) DocYear, 
			RIGHT(PD.ChequeDate, 5) DocDate, 
			0 AS PayableAmount, 
			0 AS ReceivableAmount, 
			PD.Amount AS InReceiptAmount,
			0 as LoanAmount
	FROM	trs.tblPayDtl AS PD
		INNER JOIN
		( 
			SELECT	VolumeFiscalYear, VolumeRowNo, Max(EventNo) AS EventNo
			FROM	trs.tblPayDtl
			WHERE	PayTypeID IN (6, 26)
			GROUP BY VolumeFiscalYear, VolumeRowNo
		) AS VOL ON VOL.VolumeFiscalYear = PD.VolumeFiscalYear AND VOL.VolumeRowNo = PD.VolumeRowNo AND VOL.EventNo = PD.EventNo
	WHERE PD.PayTypeID IN (6, 26) 
		AND PD.ProcessNo = ' + LTRIM(STR(@ProcessNo)) + '
		AND PD.ProcessID IN (' + @StrStateBnk + ')'

	print @StrSelect;
	Exec sp_executesql @StrSelect;

	SELECT	T.DocYear, T.DocDate, 
			SUM(T.PayableAmount) PayableAmount, 
			SUM(T.ReceivableAmount) ReceivableAmount, 
			SUM(T.InReceiptAmount) InReceiptAmount,
			SUM(T.LoanAmount) LoanAmount
	FROM
	(
		select *
		from #tbl_RptTreasury_Year_Statistics
		UNION all
		-------------------------------- Days ------------------------------------------
		SELECT str(@CurrentYear), Days, 0, 0, 0, 0
		FROM #tbl_RptTreasury_Year_Statistics_Days
	) T 
	GROUP BY T.DocYear, T.DocDate
	ORDER BY T.DocYear, T.DocDate
End
GO
