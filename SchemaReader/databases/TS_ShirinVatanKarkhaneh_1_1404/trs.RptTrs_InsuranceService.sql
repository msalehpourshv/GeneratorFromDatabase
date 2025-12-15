USE TS_ShirinVatanKarkhaneh_1_1404
GO
SET ANSI_NULLS, QUOTED_IDENTIFIER ON
GO
-- =========== TS-QC:UPDATED ====================
-- Author		 : jafari
-- Create date   : 1393/12/09
-- Viewed By	 : 
-- Last Modified : 
-- Description	 : لیست محاسبه بیمه 
-- ==============================================
Create PROCEDURE [trs].[RptTrs_InsuranceService]
	@ProcessID		Int = 933,
	@ProcessNo		Int = 1,
	@FiscalYearFr	Int = Null,
	@SerialNoFr		Int = Null,
	@FiscalYearTo	Int = Null,
	@SerialNoTo		Int = Null,
	@CustAcnt1	int = 0,
	@CustAcnt2	int = 0,
	@CustAcnt3	int = 0,
	@CustAcnt4	int = 0,
	@VisitAcnt1	int = 0,
	@VisitAcnt2	int = 0,
	@VisitAcnt3	int = 0,
	@VisitAcnt4	int = 0,
	@ExtraOption		NVarChar(100) = Null,
	@RepOptions		VarChar(10) = '10000',  -- bit array options
	@RepInfo		NVarChar(100) = '1@1@1'
WITH ENCRYPTION
As
DECLARE @LangID		Char(1);
DECLARE @SessionNo	VarChar(10);
DECLARE @ReportID	VarChar(10);
DECLARE @DateFrom	VarChar(10);
DECLARE @DateTo	VarChar(10);
DECLARE @StrSelect	NVarChar(max);
DECLARE @StrWhere	NVarChar(max);
Begin   
	SET NoCount On;


	-- Init --------------------------------------------------
	If (@RepInfo	Is Null)	SET @RepInfo    = '1@1@1'
	IF (@RepOptions	Is Null)	SET @RepOptions = '1100'

	IF (@CustAcnt1 Is Null)	SET @CustAcnt1 = 0
	IF (@CustAcnt2 Is Null)	SET @CustAcnt2 = 0
	IF (@CustAcnt3 Is Null)	SET @CustAcnt3 = 0
	IF (@CustAcnt4 Is Null)	SET @CustAcnt4 = 0


	IF (@VisitAcnt1 Is Null)	SET @CustAcnt1 = 0
	IF (@VisitAcnt2 Is Null)	SET @VisitAcnt2 = 0
	IF (@VisitAcnt3 Is Null)	SET @VisitAcnt3 = 0
	IF (@VisitAcnt4 Is Null)	SET @VisitAcnt4 = 0


	If (@FiscalYearFr Is Null)	SET @SerialNoFr	= Null;
	If (@FiscalYearTo Is Null)	SET @SerialNoTo	= Null;
	If (@SerialNoFr	Is Null)	SET @FiscalYearFr = Null;
	If (@SerialNoTo	Is Null)	SET @FiscalYearTo = Null;
	
	SET	@LangID		= pub.funSplitString(@RepInfo, '@', 1);
	SET @SessionNo	= pub.funSplitString(@RepInfo, '@', 2);
	SET @ReportID	= pub.funSplitString(@RepInfo, '@', 3);
	-----------------------------------------------------------
	SET @DateFrom		 =ltrim(rtrim( pub.funSplitString(@ExtraOption, '@', 2))); 
	SET @DateTo		 =ltrim(rtrim( pub.funSplitString(@ExtraOption, '@', 3))); 


	set @StrWhere = '(H.ProcessID = ' + LTrim(Str(@ProcessID)) + ') and (H.ProcessNo = ' + LTrim(Str(@ProcessNo)) + ')'
	
	If (@DateFrom <>'0')
		Set @StrWhere = @StrWhere + ' AND (H.DocDate >= ''' + @DateFrom + ''')'
If (@DateTo <>'0')
		Set @StrWhere = @StrWhere + ' AND (H.DocDate <= ''' + @DateTo + ''')'


	If (@FiscalYearFr Is Not Null)
		SET @StrWhere = @StrWhere + ' AND (D.FiscalYear > ' + LTrim(Str(@FiscalYearFr)) + ' OR (D.FiscalYear = ' + LTrim(Str(@FiscalYearFr)) + ' AND D.SerialNo >= ' + LTrim(Str(@SerialNoFr)) + ')) '
	If (@FiscalYearTo Is Not Null)
		SET @StrWhere = @StrWhere + ' AND (D.FiscalYear < ' + LTrim(Str(@FiscalYearTo)) + ' OR (D.FiscalYear = ' + LTrim(Str(@FiscalYearTo)) + ' AND D.SerialNo <= ' + LTrim(Str(@SerialNoTo)) + ')) '

	If	(@CustAcnt1 > 0)
		SET @StrWhere = @StrWhere + ' AND ' + pub.funGetFilterString(@SessionNo, @ReportID, @CustAcnt1, 'H.AcntCode') 
	If	(@CustAcnt2 > 0)
		SET @StrWhere = @StrWhere + ' AND ' + pub.funGetFilterString(@SessionNo, @ReportID, @CustAcnt2, 'H.AcntCode') 
	If	(@CustAcnt3 > 0)
		SET @StrWhere = @StrWhere + ' AND ' + pub.funGetFilterString(@SessionNo, @ReportID, @CustAcnt3, 'H.AcntCode') 
	If	(@CustAcnt4 > 0)
		SET @StrWhere = @StrWhere + ' AND ' + pub.funGetFilterString(@SessionNo, @ReportID, @CustAcnt4, 'H.AcntCode') 

		If	(@VisitAcnt1 > 0)
		SET @StrWhere = @StrWhere + ' AND ' + pub.funGetFilterString(@SessionNo, @ReportID, @VisitAcnt1, 'H.AcntCodeVisitor') 
		If	(@VisitAcnt2 > 0)
		SET @StrWhere = @StrWhere + ' AND ' + pub.funGetFilterString(@SessionNo, @ReportID, @VisitAcnt2, 'H.AcntCodeVisitor') 
		If	(@VisitAcnt3 > 0)
		SET @StrWhere = @StrWhere + ' AND ' + pub.funGetFilterString(@SessionNo, @ReportID, @VisitAcnt3, 'H.AcntCodeVisitor') 
		If	(@VisitAcnt4 > 0)
		SET @StrWhere = @StrWhere + ' AND ' + pub.funGetFilterString(@SessionNo, @ReportID, @VisitAcnt4, 'H.AcntCodeVisitor') 

	Set @StrSelect ='
	SELECT	H.* ,D.*
	,		pub.GetCodeName(H.AcntCode, '+@LangID+') AcntName,
		    pub.GetCodeName(H.AcntCodeVisitor, '+@LangID+') VisitorAcntName,
		    pub.GetBankName(H.BankCode, '+@LangID+') BankAcntName
	,
	acc.funGetServiceName(D.ServiceID,'+@LangID+')  ServiceName
	FROM	   trs.tblInsuranceServiceHdr H
				INNER JOIN   trs.tblInsuranceServiceDtl D On H.ProcessID = D.ProcessID AND H.ProcessNo = D.ProcessNo AND H.FiscalYear = D.FiscalYear AND H.SerialNo = D.SerialNo
	WHERE   ' + @StrWhere

	Print @StrSelect;
	Exec sp_executesql @StrSelect;
End
GO
