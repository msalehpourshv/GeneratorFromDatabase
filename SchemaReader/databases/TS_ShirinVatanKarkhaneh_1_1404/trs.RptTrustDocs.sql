USE TS_ShirinVatanKarkhaneh_1_1404
GO
SET ANSI_NULLS, QUOTED_IDENTIFIER ON
GO
-- =========== TS-QC:UPDATED ====================
-- Author		 : TakroSystem\Ahmadnejad
-- Create date   : 1388/01/17
-- Viewed By	 : 
-- Last Modified : 1393/02/31
-- Last Modifier : TakroSystem\Hamid
-- Description	 : <Trust Docs>
-- ----------------------------------------------
-- گزارش اسناد امانی
-- ==============================================
Create  PROCEDURE [trs].[RptTrustDocs]
	@RecProcessID		TinyInt,  -- پرداخت یا دریافت 
	@RetProcessID		TinyInt,  -- استرداد
	@ProcessNo			TinyInt = 1,
	@FiscalYearFr		Int = Null,
	@SerialNoFr			Int = Null,
	@FiscalYearTo		Int = Null,
	@SerialNoTo			Int = Null,
	@DebitCodeFr		VarChar(20) = Null, 
	@DebitCodeTo		VarChar(20) = Null, 
	@CreditCodeFr		VarChar(20) = Null,
	@CreditCodeTo		VarChar(20) = Null,
	@DocDateFr			VarChar(10) = Null,
	@DocDateTo			VarChar(10) = Null,
	@UsanceDateFr		VarChar(10) = Null, -- تاریخ سررسید از
	@UsanceDateTo		VarChar(10) = Null, -- تاریخ سررسید تا
	@VolumeYearFr		Int = Null,			-- شماره ردیف دفتر از
	@VolumeRowFr		Int = Null,			-- شماره ردیف دفتر از
	@VolumeYearTo		Int = Null,			-- شماره ردیف دفتر تا
	@VolumeRowTo		Int = Null,			-- شماره ردیف دفتر تا
	@ChequeNoFr			VarChar(20) = Null, -- شماره چک از
	@ChequeNoTo			VarChar(20) = Null, -- شماره چک تا
	@AmountFr			BigInt = Null, -- مبلغ از
	@AmountTo			BigInt = Null, -- مبلغ تا
	@RemainOnly			Bit = 1, -- استرداد نشده ها
	@SortFields			NVarChar(300) = Null,
	@LanguageID			TinyInt = 1,
	@ExtraParams		NVarChar(200) = Null
WITH ENCRYPTION
As
DECLARE @StrSelect		NVarChar(4000);
DECLARE @StrSelectSub	NVarChar(4000);
DECLARE @StrSelectSub2	NVarChar(4000);
DECLARE @StrProcessNo	VarChar(3)
DECLARE @LangID			VarChar(3)

DECLARE @RecivablePromissoryNote	VarChar(20);
DECLARE @PayablePromissoryNote	    VarChar(20);

BEGIN   

	SET NOCOUNT ON;

	-- Init
	--SET @LangID = Str(pub.funGetCurrentLanguageID());
	If (@LanguageID Is Null)	SET @LanguageID = 1
	If (@RemainOnly Is Null)	SET	@RemainOnly = 1	-- وصول نشده ها
	If (@SortFields Is Null)	SET @SortFields = 'ProcessID'

	If (@FiscalYearFr Is Null)	SET @SerialNoFr	= Null;
	If (@FiscalYearTo Is Null)	SET @SerialNoTo	= Null;

	If (@SerialNoFr	Is Null)	SET @FiscalYearFr = Null;
	If (@SerialNoTo	Is Null)	SET @FiscalYearTo = Null;

	If (@VolumeYearFr Is Null)	SET @VolumeRowFr = Null;
	If (@VolumeYearTo Is Null)	SET @VolumeRowTo = Null;

	If (@VolumeRowFr Is Null)	SET @VolumeYearFr = Null;
	If (@VolumeRowTo Is Null)	SET @VolumeYearTo = Null;

	SET @StrSelect		= ''
	SET @StrSelectSub	= ''
	SET @LangID			= Cast(@LanguageID AS VarChar(3));
	SET @StrProcessNo	= LTrim(Str(@ProcessNo))

	SET @RecivablePromissoryNote = pub.funSplitString(@ExtraParams, '@', 1);
	SET @PayablePromissoryNote = pub.funSplitString(@ExtraParams, '@', 2);
	
	/* ========= Create Sub String Query Section =============== */

	SET @StrSelectSub = '	
		SELECT	VolumeFiscalYear, VolumeRowNo
		FROM	trs.tblPayDtl
		WHERE	ProcessID = ' + Str(@RecProcessID) + ' AND ProcessNo = ' + Str(@StrProcessNo)

	If (@RemainOnly = 1)
		SET @StrSelectSub = @StrSelectSub + '	
		EXCEPT  
		SELECT	VolumeFiscalYear, VolumeRowNo
		FROM	trs.tblPayDtl
		WHERE	ProcessID = ' + Str(@RetProcessID) + ' AND ProcessNo = ' + Str(@StrProcessNo)

	/* ================================================= */

	If (@RemainOnly = 1)
	SET @StrSelectSub2='INNER JOIN ( ' + @StrSelectSub + ' ) AS V ON V.VolumeFiscalYear = PD.VolumeFiscalYear AND V.VolumeRowNo = PD.VolumeRowNo '
	else
	SET @StrSelectSub2=''
	
	/* ======= Create Main String Query Section ======== */

	SET @StrSelect = '
		SELECT	   PD.*, BD.BankTypeName, 
				pub.GetCodeName(PD.DebitCode, ' + @LangID + ') AS DebitName, 
				pub.GetCodeName(PD.CreditCode, ' + @LangID + ') AS CreditName,
				CASE WHEN (SELECT Count(*) FROM trs.tblPayDtl WHERE VolumeFiscalYear = PD.VolumeFiscalYear AND VolumeRowNo = PD.VolumeRowNo AND ProcessID = ' + Str(@RetProcessID) + ') > 0 THEN 1 ELSE 0 END AS IsReturned
		FROM	trs.tblPayDtl AS PD 
		'+ @StrSelectSub2 +'
				
				LEFT JOIN trs.tblBankTypesDtl AS BD ON PD.BankTypeID = BD.BankTypeID AND BD.LanguageID = ' + @LangID + '
		WHERE   PD.ProcessID = ' + Str(@RecProcessID) + ' AND PD.ProcessNo = ' + @StrProcessNo
	
  if @RecivablePromissoryNote <> '0'
		  SET @StrSelect = @StrSelect+'AND PD.PayTypeID in ( ' + @RecivablePromissoryNote  +' ) '
		
   if @PayablePromissoryNote <> '0'
		  SET @StrSelect = @StrSelect+' AND PD.PayTypeID in ( ' + @PayablePromissoryNote  +' ) '

	If (@FiscalYearFr Is Not Null)
		SET @StrSelect = @StrSelect + ' AND (PD.FiscalYear > ' + LTrim(Str(@FiscalYearFr)) + ' OR
		(PD.FiscalYear = ' + LTrim(Str(@FiscalYearFr)) + ' AND PD.SerialNo >= ' + LTrim(Str(@SerialNoFr)) + ')) '

	If (@FiscalYearTo Is Not Null)
		SET @StrSelect = @StrSelect + ' AND (PD.FiscalYear < ' + LTrim(Str(@FiscalYearTo)) + ' OR
		(PD.FiscalYear = ' + LTrim(Str(@FiscalYearTo)) + ' AND PD.SerialNo <= ' + LTrim(Str(@SerialNoTo)) + ')) '

	If (@VolumeYearFr Is Not Null)
		SET @StrSelect = @StrSelect + ' AND (PD.VolumeFiscalYear > ' + LTrim(Str(@VolumeYearFr)) + ' OR
		(PD.VolumeFiscalYear = ' + LTrim(Str(@VolumeYearFr)) + ' AND PD.VolumeRowNo >= ' + LTrim(Str(@VolumeRowFr)) + ')) '

	If (@VolumeYearTo Is Not Null)
		SET @StrSelect = @StrSelect + ' AND (PD.VolumeFiscalYear < ' + LTrim(Str(@VolumeYearTo)) + ' OR
		(PD.VolumeFiscalYear = ' + LTrim(Str(@VolumeYearTo)) + ' AND PD.VolumeRowNo <= ' + LTrim(Str(@VolumeRowTo)) + ')) '

	If (@CreditCodeFr Is Not Null)
		SET @StrSelect = @StrSelect + ' AND RTrim(PD.CreditCode) like ''' + LTrim(@CreditCodeFr) + '%'''
	If (@CreditCodeTo Is Not Null)
		SET @StrSelect = @StrSelect + ' AND RTrim(PD.CreditCode) like ''' + LTrim(@CreditCodeTo) + '%'''

	If	(@DebitCodeFr Is Not Null)
		SET @StrSelect = @StrSelect + ' AND RTrim(PD.DebitCode) like ''' + LTrim(@DebitCodeFr) + '%'''
	If	(@DebitCodeTo Is Not Null)
		SET @StrSelect = @StrSelect + ' AND RTrim(PD.DebitCode) like ''' + LTrim(@DebitCodeTo) + '%'''

	If (Not @DocDateFr Is Null)
		Set @StrSelect = @StrSelect + ' AND RTrim(PD.DocDate) >= ''' + RTrim(@DocDateFr) + ''''
	If (Not @DocDateTo Is Null)
		Set @StrSelect = @StrSelect + ' AND RTrim(PD.DocDate) <= ''' + RTrim(@DocDateTo) + ''''

	If (Not @UsanceDateFr Is Null)
		Set @StrSelect = @StrSelect + ' AND RTrim(PD.ChequeDate) >= ''' + RTrim(@UsanceDateFr) + ''''
	If (Not @UsanceDateTo Is Null)
		Set @StrSelect = @StrSelect + ' AND RTrim(PD.ChequeDate) <= ''' + RTrim(@UsanceDateTo) + ''''

	If (Not @ChequeNoFr Is Null)
		Set @StrSelect = @StrSelect + ' AND (PD.ChequeNo >= ''' + LTrim(@ChequeNoFr) + ''')'
	If (Not @ChequeNoTo Is Null)
		Set @StrSelect = @StrSelect + ' AND (PD.ChequeNo <= ''' + LTrim(@ChequeNoTo) + ''')'

	If (Not @AmountFr Is Null)
		Set @StrSelect = @StrSelect + ' AND PD.Amount >= ' + LTrim(Str(@AmountFr,25))
	If (Not @AmountTo Is Null)
		Set @StrSelect = @StrSelect + ' AND PD.Amount <= ' + LTrim(Str(@AmountTo,25))
		
	--If (@RecivablePromissoryNote <> '0')
	--	Set @StrSelect = @StrSelect + ' AND PD.PayTypeID = 31'

	SET @StrSelect = @StrSelect + ' ORDER BY ' + @SortFields

	Print @StrSelect
	Exec sp_executesql @StrSelect;
End
GO
