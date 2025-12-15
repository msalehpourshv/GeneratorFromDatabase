USE TS_ShirinVatanKarkhaneh_1_1404
GO
SET ANSI_NULLS, QUOTED_IDENTIFIER ON
GO
-- =========== TS-QC:UPDATED ====================
-- Author		 : Ahmadnejad
-- Create date   : 1386/02/19
-- Viewed By	 : 
-- Last Modified : 1392/01/06
-- Description	 : لیست وامها و اقساط
-- ==============================================
Create PROCEDURE [trs].[RptTrs_LoanDocs]
	@ProcessID		Int = 7,
	-- 7 = دریافت وام 
	-- 8 = پرداخت اقساط
	@ProcessNo		Int = 1,
	@FiscalYearFr	Int = Null,
	@SerialNoFr		Int = Null,
	@FiscalYearTo	Int = Null,
	@SerialNoTo		Int = Null,
	@DocDateFr		Char(10) = Null,
	@DocDateTo		Char(10) = Null,
	@SelectedAcnt1	int = 0,
	@SelectedAcnt2	int = 0,
	@SelectedAcnt3	int = 0,
	@SelectedAcnt4	int = 0,
	@DescMask		NVarChar(100) = Null,
	@RepOptions		VarChar(10) = '10000',  -- bit array options
	@RepInfo		NVarChar(100) = '1@1@1'
WITH ENCRYPTION
AS
DECLARE @LangID		Char(1);
DECLARE @SessionNo	VarChar(10);
DECLARE @ReportID	VarChar(10);
DECLARE @BankAcnt1 int;
DECLARE @BankAcnt2 int;
DECLARE @BankAcnt3 int;
DECLARE @BankAcnt4 int;
DECLARE @StrSelect	NVarChar(max);
DECLARE @StrWhere	NVarChar(max);
DECLARE @StrFrom	NVarChar(max);
DECLARE	@Paidoff    BIT;
DECLARE	@NotPaidoff    BIT;
DECLARE	@FiscalYearFrPay	Int ;
DECLARE	@SerialNoFrPay		Int ;
DECLARE	@FiscalYearToPay	Int ;
DECLARE	@SerialNoToPay		Int ;
BEGIN   
	SET NoCount On;
		
	SET @BankAcnt1 = 0
	SET @BankAcnt2 = 0
	SET @BankAcnt3 = 0
	SET @BankAcnt4 = 0

	-- Init --------------------------------------------------
	If (@RepInfo	Is Null)	SET @RepInfo    = '1@1@1'
	IF (@RepOptions	Is Null)	SET @RepOptions = '1100'

	IF (@SelectedAcnt1 Is Null)	SET @SelectedAcnt1 = 0
	IF (@SelectedAcnt2 Is Null)	SET @SelectedAcnt2 = 0
	IF (@SelectedAcnt3 Is Null)	SET @SelectedAcnt3 = 0
	IF (@SelectedAcnt4 Is Null)	SET @SelectedAcnt4 = 0

	IF (@FiscalYearFr Is Null)	SET @SerialNoFr	= Null;
	IF (@FiscalYearTo Is Null)	SET @SerialNoTo	= Null;
	IF (@SerialNoFr	Is Null)	SET @FiscalYearFr = Null;
	IF (@SerialNoTo	Is Null)	SET @FiscalYearTo = Null;
	
	SET	@LangID			 = pub.funSplitString(@RepInfo, '@', 1);
	SET @SessionNo		 = pub.funSplitString(@RepInfo, '@', 2);
	SET @ReportID		 = pub.funSplitString(@RepInfo, '@', 3);
	SET @BankAcnt1		 = pub.funSplitString(@RepInfo, '@', 6);
	SET @BankAcnt2		 = pub.funSplitString(@RepInfo, '@', 7);
	SET @BankAcnt3		 = pub.funSplitString(@RepInfo, '@', 8);
	SET @BankAcnt4		 = pub.funSplitString(@RepInfo, '@', 9);
	SET @FiscalYearFrPay = pub.funSplitString(@RepInfo, '@', 10);
	SET @SerialNoFrPay	 = pub.funSplitString(@RepInfo, '@', 11);
	SET @FiscalYearToPay = pub.funSplitString(@RepInfo, '@', 12);
	SET @SerialNoToPay   = pub.funSplitString(@RepInfo, '@', 13);

	 
	SET @NotPaidoff =  pub.funSplitString(@RepOptions, '@', 1);
	SET @Paidoff	=  pub.funSplitString(@RepOptions, '@', 2);
	-----------------------------------------------------------

	SET @StrWhere = '(H.ProcessID = ' + LTrim(Str(@ProcessID)) + ') AND (H.ProcessNo = ' + LTrim(Str(@ProcessNo)) + ')'
	IF @ProcessID = 7 or @ProcessID = 47 
	BEGIN
		IF (@FiscalYearFr Is Not Null) and @FiscalYearFr<>0
			SET @StrWhere = @StrWhere + ' AND (H.FiscalYear > ' + LTrim(Str(@FiscalYearFr)) + ' OR (H.FiscalYear = ' + LTrim(Str(@FiscalYearFr)) + ' AND H.SerialNo >= ' + LTrim(Str(@SerialNoFr)) + ')) '
		IF (@FiscalYearTo Is Not Null)and @FiscalYearTo<>0
			SET @StrWhere = @StrWhere + ' AND (H.FiscalYear < ' + LTrim(Str(@FiscalYearTo)) + ' OR (H.FiscalYear = ' + LTrim(Str(@FiscalYearTo)) + ' AND H.SerialNo <= ' + LTrim(Str(@SerialNoTo)) + ')) '
	END
	ELSE
	BEGIN
		IF (@FiscalYearFr Is Not Null)and @FiscalYearFr<>0
			SET @StrWhere = @StrWhere + ' AND (H.BaseFiscalYear > ' + LTrim(Str(@FiscalYearFr)) + ' OR (H.BaseFiscalYear = ' + LTrim(Str(@FiscalYearFr)) + ' AND H.BaseSerialNo >= ' + LTrim(Str(@SerialNoFr)) + ')) '
		IF (@FiscalYearTo Is Not Null)and @FiscalYearTo<>0
			SET @StrWhere = @StrWhere + ' AND (H.BaseFiscalYear < ' + LTrim(Str(@FiscalYearTo)) + ' OR (H.BaseFiscalYear = ' + LTrim(Str(@FiscalYearTo)) + ' AND H.BaseSerialNo <= ' + LTrim(Str(@SerialNoTo)) + ')) '
	END
		IF @ProcessID = 8 or @ProcessID = 48
	BEGIN
		IF (@FiscalYearFrPay Is Not Null)and @FiscalYearFrPay<>0
			SET @StrWhere = @StrWhere + ' AND (H.FiscalYear > ' + LTrim(Str(@FiscalYearFrPay)) + ' OR (H.FiscalYear = ' + LTrim(Str(@FiscalYearFrPay)) + ' AND H.SerialNo >= ' + LTrim(Str(@SerialNoFrPay)) + ')) '
		IF (@FiscalYearToPay Is Not Null)and @FiscalYearToPay<>0
			SET @StrWhere = @StrWhere + ' AND (H.FiscalYear < ' + LTrim(Str(@FiscalYearToPay)) + ' OR (H.FiscalYear = ' + LTrim(Str(@FiscalYearToPay)) + ' AND H.SerialNo <= ' + LTrim(Str(@SerialNoToPay)) + ')) '
	END
	
	IF	(@SelectedAcnt1 > 0)
		SET @StrWhere = @StrWhere + ' AND ' + pub.funGetFilterString(@SessionNo, @ReportID, @SelectedAcnt1, 'H.LoanAcntCode') 
	IF	(@SelectedAcnt2 > 0)
		SET @StrWhere = @StrWhere + ' AND ' + pub.funGetFilterString(@SessionNo, @ReportID, @SelectedAcnt2, 'H.LoanAcntCode') 
	IF	(@SelectedAcnt3 > 0)
		SET @StrWhere = @StrWhere + ' AND ' + pub.funGetFilterString(@SessionNo, @ReportID, @SelectedAcnt3, 'H.LoanAcntCode') 
	IF	(@SelectedAcnt4 > 0)
		SET @StrWhere = @StrWhere + ' AND ' + pub.funGetFilterString(@SessionNo, @ReportID, @SelectedAcnt4, 'H.LoanAcntCode') 

		IF	(@BankAcnt1 > 0)
		SET @StrWhere = @StrWhere + ' AND ' + pub.funGetFilterString(@SessionNo, @ReportID, @BankAcnt1, 'H.BankAcntCode') 
		IF	(@BankAcnt2 > 0)
		SET @StrWhere = @StrWhere + ' AND ' + pub.funGetFilterString(@SessionNo, @ReportID, @BankAcnt2, 'H.BankAcntCode') 
		IF	(@BankAcnt3 > 0)
		SET @StrWhere = @StrWhere + ' AND ' + pub.funGetFilterString(@SessionNo, @ReportID, @BankAcnt3, 'H.BankAcntCode') 
		IF	(@BankAcnt4 > 0)
		SET @StrWhere = @StrWhere + ' AND ' + pub.funGetFilterString(@SessionNo, @ReportID, @BankAcnt4, 'H.BankAcntCode') 

	IF (@DocDateFr <> '')
		SET @StrWhere = @StrWhere + ' AND	(H.DocDate >= ''' + @DocDateFr + ''')'
	IF (@DocDateTo <> '')
		SET @StrWhere = @StrWhere + ' AND	(H.DocDate <= ''' + @DocDateTo + ''')'

	IF (@DescMask Is Not Null)
		SET @StrWhere = @StrWhere + ' AND (Replace(H.LoanHdrDesc, '' '', '''') LIKE N''%' + RTrim(Replace(@DescMask, ' ', '')) + '%'')' --OR
	--                                       Replace(H.LoanHdrDesc, '' '', '''') LIKE  ''%' + RTrim(Replace(@DescMask, ' ', '')) + '%'' )'
	SET @StrFrom ='trs.tblLoanHdr'
	IF @Paidoff='1' and  @NotPaidoff='0' -- وام های تسویه شده
	   SET @StrFrom ='(SELECT LH.* 
					   FROM trs.tblLoanHdr LH
					   INNER JOIN (SELECT A.* 
								   FROM (SELECT FiscalYear, ProcessID, ProcessNo, SerialNo, SUM(InstallmentAmount) InstallmentAmountSum 
										 FROM trs.tblLoanDtl 
										 WHERE ProcessID = 7 
										 GROUP BY FiscalYear, ProcessID, ProcessNo, SerialNo) A
								   INNER JOIN (SELECT BaseFiscalYear, BaseProcessID, BaseProcessNo, BaseSerialNo, SUM(InstallmentAmount) InstallmentAmountSum 
											   FROM trs.tblLoanDtl 
											   WHERE ProcessID = 8 
											   GROUP BY BaseFiscalYear, BaseProcessID, BaseProcessNo, BaseSerialNo) B ON B.BaseFiscalYear = A.FiscalYear 
																													 AND B.BaseProcessID = A.ProcessID 
																													 AND B.BaseProcessNo = A.ProcessNo 
																													 AND B.BaseSerialNo = A.SerialNo 
																													 AND B.InstallmentAmountSum >= A.InstallmentAmountSum) DH ON LH.FiscalYear = DH.FiscalYear 
																																											 AND LH.ProcessID = DH.ProcessID 
																																											 AND LH.ProcessNo = DH.ProcessNo 
																																											 AND LH.SerialNo = DH.SerialNo)'
	ELSE IF @Paidoff='0' and  @NotPaidoff='1'  -- وام های تسویه نشده
	SET @StrFrom ='(SELECT * 
					FROM trs.tblLoanHdr 
					WHERE ProcessID = 7
                    
					EXCEPT

                    SELECT LH.* 
					FROM trs.tblLoanHdr LH
                    INNER JOIN (SELECT A.* 
								FROM (SELECT FiscalYear, ProcessID, ProcessNo, SerialNo, SUM(InstallmentAmount) InstallmentAmountSum 
									  FROM trs.tblLoanDtl 
									  WHERE ProcessID = 7 
									  GROUP BY FiscalYear, ProcessID, ProcessNo, SerialNo) A
								INNER JOIN (SELECT BaseFiscalYear, BaseProcessID, BaseProcessNo, BaseSerialNo, SUM(InstallmentAmount) InstallmentAmountSum 
											FROM trs.tblLoanDtl 
											WHERE ProcessID = 8 
											GROUP BY BaseFiscalYear, BaseProcessID, BaseProcessNo, BaseSerialNo) B ON B.BaseFiscalYear = A.FiscalYear 
																												  AND B.BaseProcessID = A.ProcessID 
																												  AND B.BaseProcessNo = A.ProcessNo 
																												  AND B.BaseSerialNo = A.SerialNo 
																												  AND B.InstallmentAmountSum >= A.InstallmentAmountSum) DH ON LH.FiscalYear = DH.FiscalYear 
																																										  AND LH.ProcessID = DH.ProcessID 
																																										  AND LH.ProcessNo = DH.ProcessNo 
																																										  AND LH.SerialNo = DH.SerialNo)'

	SET @StrSelect ='
	SELECT *, 
			pub.GetCodeName(H.LoanAcntCode, 1) LoanAcntName,
		    pub.GetCodeName(H.CostAcntCode, 1) CostAcntName,
		    pub.GetCodeName(H.BankAcntCode, 1) BankAcntName,
		    pub.GetCodeName(H.PayableLoanAcntCode, 1) PayableLoanAcntName 
	FROM (SELECT D.*, 
				 H.DocDate, 
				 H.BankAcntCode, 
				 CASE WHEN H.ProcessID = 7 OR H.ProcessID = 47 THEN H.LoanAcntCode 
					  ELSE CASE WHEN H.ProcessID = 8 THEN (SELECT LoanAcntCode 
														   FROM trs.tblLoanHdr M 
														   WHERE M.ProcessID = 7 
															 AND H.BaseFiscalYear = M.FiscalYear 
															 AND H.BaseSerialNo = M.SerialNo)
								ELSE (SELECT LoanAcntCode 
									  FROM trs.tblLoanHdr M 
									  WHERE M.ProcessID = 47 
									    AND H.BaseFiscalYear = M.FiscalYear 
										AND H.BaseSerialNo = M.SerialNo )
								END 
				 END AS LoanAcntCode,
				 CASE WHEN H.ProcessID = 7 OR H.ProcessID = 47 THEN H.PayableLoanAcntCode 
					  ELSE CASE WHEN H.ProcessID = 8 THEN (SELECT PayableLoanAcntCode 
														   FROM trs.tblLoanHdr M 
														   WHERE M.ProcessID = 7 
														     AND H.BaseFiscalYear = M.FiscalYear 
															 AND H.BaseSerialNo = M.SerialNo)
								ELSE (SELECT PayableLoanAcntCode 
									  FROM trs.tblLoanHdr M 
									  WHERE M.ProcessID = 47 
										AND H.BaseFiscalYear = M.FiscalYear 
									    AND H.BaseSerialNo = M.SerialNo)
								END 
				 END AS PayableLoanAcntCode, 
				 H.CostAcntCode, 
				 H.FineAcntCode, 
				 H.VchNo, 
				 H.LoanHdrDesc
		  FROM ' + @StrFrom + ' H
		  INNER JOIN trs.tblLoanDtl D ON H.ProcessID = D.ProcessID 
									 AND H.ProcessNo = D.ProcessNo 
									 AND H.FiscalYear = D.FiscalYear 
									 AND H.SerialNo = D.SerialNo ) H 
		  WHERE ' + @StrWhere

	PRINT @StrSelect;
	EXEC sp_executesql @StrSelect;
END
GO
