USE TS_ShirinVatanKarkhaneh_1_1404
GO
SET ANSI_NULLS, QUOTED_IDENTIFIER ON
GO
-- =========== TS-QC:UPDATED ====================
-- Author		 : TakroSystem\Ahmadnejad
-- Create date   : 1386/02/27
-- Viewed By	 : 
-- Last Modified : 1392/04/18
-- Last Modifier : TakroSystem\Zia
-- Description	 : <Payable Documents Report>
-- ----------------------------------------------
-- گزارش اسناد پرداختنی
-- ==============================================
Create PROCEDURE [trs].[RptPayableDocs]
	@ProcessNo		Int = 1,
	@FiscalYearFr	Int = Null,
	@SerialNoFr		Int = Null,
	@FiscalYearTo	Int = Null,
	@SerialNoTo		Int = Null,
	@DebitCode1		Int = 0, -- بدهکار
	@DebitCode2		Int = 0,
	@DebitCode3		Int = 0,
	@DebitCode4		Int = 0,
	@CreditCode1	Int = 0, -- بستانکار
	@CreditCode2	Int = 0,
	@CreditCode3	Int = 0,
	@CreditCode4	Int = 0,
	@DocDateFr		Char(10) = Null, -- از تاریخ پرداخت
	@DocDateTo		Char(10) = Null, -- تا تاریخ پرداخت
	@UsanceDateFr	Char(10) = Null, -- از تاریخ سررسید
	@UsanceDateTo	Char(10) = Null, -- تا تاریخ سررسید
	@ChequeNoFr		VarChar(20) = Null, -- از شماره چک
	@ChequeNoTo		VarChar(20) = Null, -- تا شماره چک
	@VolumeYearFr	Int = Null, -- شماره ردیف دفتر
	@VolumeRowFr	Int = Null, 
	@VolumeYearTo	Int = Null,
	@VolumeRowTo	Int = Null,
	@AmountFr		BigInt = Null, -- مبلغ پرداختی
	@AmountTo		BigInt = Null,
	@VchNoFr		int = Null, -- شماره عطف
	@VchNoTo		int = Null,
	@SortFields		NVarChar(100) = Null,
	@RepOptions		VarChar(10) = '100000',  -- bit array options
	@RepInfo		NVarChar(100) = '1@1@1'
WITH ENCRYPTION
As
Declare @StrSelect		NVarChar(max);
Declare @StrWhere		NVarChar(max);
Declare @StrWhere2		NVarChar(max);

Declare @ShowUnreceipt	bit; -- وصول نشده ها
Declare @ShowReceipt	bit; -- وصول شده ها
Declare @ShowReturned	bit; -- برگشتی ها
Declare @ShowDailyChq	bit;
Declare @ShowPayDirections	int;
Declare @PayDirectionsSerial	int;

declare @IsTrade		char;
declare @UseCurrency	bit;

Declare @StrPrefix		NVarChar(10)
Declare @StrPID			NVarChar(20)
Declare @StrTID			NVarChar(20)
Declare @BaseDate		NVarChar(10)
DECLARE @StrBaseDate	nVarchar(20)
DECLARE	@TrsCalcAvgByDocDate bit;

DECLARE @LangID				Char(1)
DECLARE @SessionNo			VarChar(10)
DECLARE @ReportID			VarChar(10)
Declare @ReceiptlDateFrom	Char(10)
Declare @ReceiptlDateTo		Char(10)
Declare @ReturnDateFrom		Char(10)
Declare @ReturnDateTo		Char(10)
DECLARE @ChequeNoFrNew		VarChar(20) ;
DECLARE @ChequeNoToNew		VarChar(20) ;
DECLARE @ShowChqNoNew		int;
DECLARE	@ChequeIsDigital	bit;

Begin   
	SET NoCount On;
	
	-- Init
	If (@RepInfo	Is Null)	SET @RepInfo    = '1@1@1'
	IF (@RepOptions	Is Null)	SET @RepOptions = '1100'
	If (@ProcessNo  Is Null)	SET @ProcessNo  = 1
	If (@SortFields Is Null)	SET @SortFields = 'ChequeState'

	If (@FiscalYearFr Is Null)	SET @SerialNoFr	= Null;
	If (@FiscalYearTo Is Null)	SET @SerialNoTo	= Null;
	If (@SerialNoFr	Is Null)	SET @FiscalYearFr = Null;
	If (@SerialNoTo	Is Null)	SET @FiscalYearTo = Null;

	If (@VolumeYearFr Is Null)	SET @VolumeRowFr = Null;
	If (@VolumeYearTo Is Null)	SET @VolumeRowTo = Null;
	If (@VolumeRowFr Is Null)	SET @VolumeYearFr = Null;
	If (@VolumeRowTo Is Null)	SET @VolumeYearTo = Null;

	IF (@DebitCode1 Is Null)	SET @DebitCode1 = 0
	IF (@DebitCode2 Is Null)	SET @DebitCode2 = 0
	IF (@DebitCode3 Is Null)	SET @DebitCode3 = 0
	IF (@DebitCode4 Is Null)	SET @DebitCode4 = 0

	IF (@CreditCode1 Is Null)	SET @CreditCode1 = 0
	IF (@CreditCode2 Is Null)	SET @CreditCode2 = 0
	IF (@CreditCode3 Is Null)	SET @CreditCode3 = 0
	IF (@CreditCode4 Is Null)	SET @CreditCode4 = 0
	
	SET @ShowUnreceipt	= Substring(@RepOptions, 1, 1) -- وصول نشده ها
	SET @ShowReceipt	= Substring(@RepOptions, 2, 1) -- وصول شده ها
	SET @ShowReturned	= Substring(@RepOptions, 3, 1) -- برگشتی ها
	SET @ShowDailyChq	= Substring(@RepOptions, 4, 1) -- چک روز
	SET @IsTrade		= Substring(@RepOptions, 5, 1) -- تجاری غیر تجاری
	SET @UseCurrency	= Substring(@RepOptions, 6, 1) -- نمایش مبالغ ارزی
	
	if (@ShowDailyChq = 1)
		set @StrTID = '7,8,28'
	else
		set @StrTID = '8,28'

	if (@IsTrade='1' and @ShowDailyChq = 1)
		set @StrTID = '7,8'
	else if (@IsTrade='1' and @ShowDailyChq = 0)
		set @StrTID = '8'


	if  (@IsTrade='2' and @ShowDailyChq = 1)
		set @StrTID = '7,28'
	else if (@IsTrade='2' and @ShowDailyChq = 0)
		set @StrTID = '28'


	SELECT @BaseDate = LEFT([pub].[funFarsiDate](GetDate()), 10)
	
	SET	@LangID		= pub.funSplitString(@RepInfo, '@', 1);
	SET @SessionNo	= pub.funSplitString(@RepInfo, '@', 2);
	SET @ReportID	= pub.funSplitString(@RepInfo, '@', 3);

	SET @ShowPayDirections	= pub.funSplitString(@RepInfo, '@', 6);
	SET @PayDirectionsSerial= pub.funSplitString(@RepInfo, '@', 7);
	SET @ReceiptlDateFrom	= pub.funSplitString(@RepInfo, '@', 8);
	SET  @ReceiptlDateTo	= pub.funSplitString(@RepInfo, '@', 9);
	SET @ReturnDateFrom		= pub.funSplitString(@RepInfo, '@', 10);
	SET @ReturnDateTo		= pub.funSplitString(@RepInfo, '@', 11);
	SET @ChequeNoFrNew		= pub.funSplitString(@RepInfo, '@', 12);
	SET @ChequeNoToNew		= pub.funSplitString(@RepInfo, '@', 13);
	SET @ShowChqNoNew		= pub.funSplitString(@RepInfo, '@', 14);
	Set @ChequeIsDigital	= pub.funSplitString(@RepInfo, '@', 15);


set @ReceiptlDateFrom=LTRIM(rtrim(@ReceiptlDateFrom))
set @ReceiptlDateTo=LTRIM(rtrim(@ReceiptlDateTo))
set @ReturnDateFrom=LTRIM(rtrim(@ReturnDateFrom))
set @ReturnDateTo=LTRIM(rtrim(@ReturnDateTo))

--Select  @ReceiptlDateFrom		,@ReceiptlDateTo		,@ReturnDateFrom		,@ReturnDateTo		
--select @ShowPayDirections,@PayDirectionsSerial

	SET @StrSelect = '';
	SET @StrWhere2 = ''
	SET @StrPID = '0'

	select @TrsCalcAvgByDocDate = isnull(SettingValue, 0)
	from pub.tblSettings
	where SettingKey = 'TrsCalcAvgByDocDate'

	if (@TrsCalcAvgByDocDate = 1)
		set @StrBaseDate = 'D.DocDate'
	else
		set @StrBaseDate = '''' + @BaseDate + ''''

	----------------------------------------------------------------------------------------
	If (@ShowUnreceipt = 1)
		set @StrPID	= @StrPID + ',2,25'
	If (@ShowReceipt = 1) 
		set @StrPID	= @StrPID + ',27'
	If (@ShowReturned = 1)
		set @StrPID	= @StrPID + ',28'
	if (@ShowDailyChq = 1)
		set @StrPID	= @StrPID + ',40'

	set @StrPrefix = 'D'	
		
	set @StrWhere = '(D.ProcessID in (2,25)) '
	if (@ShowDailyChq = 1)
		set @StrWhere = '(D.ProcessID in (2,25,40)) '

	set @StrWhere =@StrWhere + '
		AND (D.EventNo=1)
		AND (D.PayTypeID in (' + @StrTID + '))
		AND (D.LastProcessID in (' + @StrPID + ') or (D.LastProcessID=2 and D.PayTypeID=7))'

	if @ProcessNo<>0
			set @StrWhere =@StrWhere +  ' AND (D.ProcessNo=' + ltrim(STR(@ProcessNo)) + ')'
			
	If	(@DebitCode1 > 0)
		SET @StrWhere = @StrWhere + ' AND ' + pub.funGetFilterString(@SessionNo, @ReportID, @DebitCode1, @StrPrefix + '.DebitCode') 
	If	(@DebitCode2 > 0)
		SET @StrWhere = @StrWhere + ' AND ' + pub.funGetFilterString(@SessionNo, @ReportID, @DebitCode2, @StrPrefix + '.DebitCode') 
	If	(@DebitCode3 > 0)
		SET @StrWhere = @StrWhere + ' AND ' + pub.funGetFilterString(@SessionNo, @ReportID, @DebitCode3, @StrPrefix + '.DebitCode') 
	If	(@DebitCode4 > 0)
		SET @StrWhere = @StrWhere + ' AND ' + pub.funGetFilterString(@SessionNo, @ReportID, @DebitCode4, @StrPrefix + '.DebitCode') 

	If	(@CreditCode1 > 0)
		SET @StrWhere = @StrWhere + ' AND ' + pub.funGetFilterString(@SessionNo, @ReportID, @CreditCode1, @StrPrefix + '.CreditCode') 
	If	(@CreditCode2 > 0)
		SET @StrWhere = @StrWhere + ' AND ' + pub.funGetFilterString(@SessionNo, @ReportID, @CreditCode2, @StrPrefix + '.CreditCode') 
	If	(@CreditCode3 > 0)
		SET @StrWhere = @StrWhere + ' AND ' + pub.funGetFilterString(@SessionNo, @ReportID, @CreditCode3, @StrPrefix + '.CreditCode') 
	If	(@CreditCode4 > 0)
		SET @StrWhere = @StrWhere + ' AND ' + pub.funGetFilterString(@SessionNo, @ReportID, @CreditCode4, @StrPrefix + '.CreditCode') 

	If	(@DocDateFr Is Not Null)
	Begin
		SET @StrWhere = @StrWhere + ' AND (' + @StrPrefix + '.DocDate >= ''' + @DocDateFr + ''')'
		SET @StrWhere2 = @StrWhere2 + ' AND (DocDate >= ''' + @DocDateFr + ''')'
	End
	If	(@DocDateTo Is Not Null)
	Begin
		SET @StrWhere = @StrWhere + ' AND (' + @StrPrefix + '.DocDate <= ''' + @DocDateTo + ''')'
		SET @StrWhere2 = @StrWhere2 + ' AND (DocDate <= ''' + @DocDateTo + ''')'
	End

	If	(@UsanceDateFr Is Not Null)
		SET @StrWhere = @StrWhere + ' AND (D.ChequeDate >= ''' + @UsanceDateFr + ''')'
	If	(@UsanceDateTo Is Not Null)
		SET @StrWhere = @StrWhere + ' AND (D.ChequeDate <= ''' + @UsanceDateTo + ''')'

	If	(@ChequeNoFr Is Not Null)
		SET @StrWhere = @StrWhere + ' AND (D.ChequeNo >= ''' + LTrim(@ChequeNoFr) + ''')'
	If	(@ChequeNoTo Is Not Null)
		SET @StrWhere = @StrWhere + ' AND (D.ChequeNo <= ''' + LTrim(@ChequeNoTo) + ''')'
		
	IF (@ChequeNoFrNew Is Not Null and @ChequeNoFrNew<>'') 
		SET @StrWhere = @StrWhere + ' AND (D.ChequeNoNew >= ''' + @ChequeNoFrNew + ''')'
	IF (@ChequeNoToNew Is Not Null and @ChequeNoToNew<>'')
		SET @StrWhere = @StrWhere + ' AND (D.ChequeNoNew <= ''' + @ChequeNoToNew + ''')'
	IF @ShowChqNoNew =1
		SET @StrWhere = @StrWhere + ' AND (D.ChequeNoNew = '''')'
	IF @ShowChqNoNew =2
		SET @StrWhere = @StrWhere + ' AND (D.ChequeNoNew <> '''')'

	If (@FiscalYearFr Is Not Null)
		SET @StrWhere = @StrWhere + ' AND (D.FiscalYear > ' + LTrim(Str(@FiscalYearFr)) + ' OR (D.FiscalYear = ' + LTrim(Str(@FiscalYearFr)) + ' AND D.SerialNo >= ' + LTrim(Str(@SerialNoFr)) + ')) '

	If (@FiscalYearTo Is Not Null)
		SET @StrWhere = @StrWhere + ' AND (D.FiscalYear < ' + LTrim(Str(@FiscalYearTo)) + ' OR (D.FiscalYear = ' + LTrim(Str(@FiscalYearTo)) + ' AND D.SerialNo <= ' + LTrim(Str(@SerialNoTo)) + ')) '

	If (@VolumeYearFr Is Not Null)
		SET @StrWhere = @StrWhere + ' AND (D.VolumeFiscalYear > ' + LTrim(Str(@VolumeYearFr)) + ' OR (D.VolumeFiscalYear = ' + LTrim(Str(@VolumeYearFr)) + ' AND D.VolumeRowNo >= ' + LTrim(Str(@VolumeRowFr)) + ')) '

	If (@VolumeYearTo Is Not Null)
		SET @StrWhere = @StrWhere + ' AND (D.VolumeFiscalYear < ' + LTrim(Str(@VolumeYearTo)) + ' OR (D.VolumeFiscalYear = ' + LTrim(Str(@VolumeYearTo)) + ' AND D.VolumeRowNo <= ' + LTrim(Str(@VolumeRowTo)) + ')) '

	If	(@AmountFr Is Not Null)
		SET @StrWhere = @StrWhere + ' AND (D.Amount >= ' + LTrim(Rtrim(Str(@AmountFr,20))) + ')'
	If	(@AmountTo Is Not Null)
		SET @StrWhere = @StrWhere + ' AND (D.Amount <= ' + LTrim(RTrim(Str(@AmountTo,20))) + ')'	

	If	(@VchNoFr Is Not Null)
		SET @StrWhere = @StrWhere + ' AND (H.VchNo >= ' + LTrim(Str(@VchNoFr)) + ')'
	If	(@VchNoTo Is Not Null)
		SET @StrWhere = @StrWhere + ' AND (H.VchNo <= ' + LTrim(Str(@VchNoTo)) + ')'
		
	If	(@ReceiptlDateFrom Is Not Null and @ReceiptlDateFrom<>'')
		SET @StrWhere = @StrWhere + ' AND (D.ReceiptDate >= ''' + @ReceiptlDateFrom + ''')'
	If	(@ReceiptlDateTo Is Not Null and @ReceiptlDateTo<>'')
		SET @StrWhere = @StrWhere + ' AND (D.ReceiptDate <= ''' + @ReceiptlDateTo + ''')'
	
	If	(@ReturnDateFrom Is Not Null and @ReturnDateFrom<>'')
		SET @StrWhere = @StrWhere + ' AND (D.ReturnDate >= ''' + @ReturnDateFrom + ''')'
	If	(@ReturnDateTo Is Not Null and @ReturnDateTo<>'')
		SET @StrWhere = @StrWhere + ' AND (D.ReturnDate <= ''' + @ReturnDateTo + ''')'

	If	(@ChequeIsDigital = 1)
		SET @StrWhere = @StrWhere + ' AND D.ChequeIsDigital = 1'
	If	(@ChequeIsDigital = 0)
		SET @StrWhere = @StrWhere + ' '		

--Select  @ReceiptlDateFrom		,@ReceiptlDateTo		,@ReturnDateFrom		,@ReturnDateTo		
	/* ================================================= */

if (@ShowPayDirections=1)
		SET @StrWhere = @StrWhere + ' AND (H.BaseProcessID = 41)'
		
if (@ShowPayDirections=2)
		SET @StrWhere = @StrWhere + ' AND (H.BaseProcessID <> 41)'
		
 if (@PayDirectionsSerial<>0)
		SET @StrWhere = @StrWhere + ' AND (H.BaseSerialNo  =' + Str(@PayDirectionsSerial) + ')'
 
declare @Result1 as varchar(max)
SET @Result1= ''
exec [pub].[funGetColumnsWithoutXColumns] 
@SchemaName='trs',@tableName='tblPayDtl',
				@ColumnsName='Amount' ,
				@CompressTableName='D'
				,@Result=@Result1 output
		set @Result1=str(@UseCurrency) +' UseCurrency,case when H.CurrencyRate=0 or H.CurrencyRate=1 or ' + CAST (@UseCurrency as varchar(20)) + '=0 then '''' else isnull((SELECT C.CurrencyTypeName From  pub.tblCurrencyTypesDtl AS C Where H.CurrencyTypeID = C.CurrencyTypeID),'''') end CurrencyTypeName,H.CurrencyRate CurrencyRateH,H.CurrencyTypeID CurrencyTypeIDH,'+@Result1
				
if (@UseCurrency=1)				
		set @Result1='case when H.CurrencyRate=0 then 0 Else  D.Amount/H.CurrencyRate end Amount,'		+@Result1
		else
		set @Result1='D.Amount,'		+@Result1
		
		
---------------------------------------------------------------------------------------------------
		Declare @DonotFilterAcc2Trs AS bit
	SET @DonotFilterAcc2Trs = 0
	SELECT @DonotFilterAcc2Trs = SettingValue
	FROM pub.tblSettings
	WHERE SettingKey = 'DonotFilterAcc2Trs'
		
if @DonotFilterAcc2Trs=0 	
begin

	DECLARE	@UserID		Int;
	DECLARE	@UserIsAdmin bit;

	SET @UserID				 = pub.funSplitString(@RepInfo, '@', 4);
	SET @UserIsAdmin		 = pub.funSplitString(@RepInfo, '@', 5);


	BEGIN TRY
		DROP TABLE #tblAcntCode
		DROP TABLE #tblOurBanks
	END TRY
	BEGIN CATCH
	END CATCH
	 CREATE TABLE #tblAcntCode
	(
	AcntCode 			Varchar(20)collate arabic_cs_as null
	)
	 CREATE TABLE #tblOurBanks
	(
		CreditCode 			Varchar(20)collate arabic_cs_as null
	)
	if (@UserIsAdmin = 0)
	begin
			Insert into  #tblOurBanks (CreditCode) SELECT  Distinct CreditCode	FROM       trs.tblPayDtl
			exec pub.SpFilterByPermission2 '#tblOurBanks', 'CreditCode', 'trs.tblOurBanks', @UserID; 
			Insert into  #tblAcntCode (AcntCode) SELECT  Distinct CreditCode	FROM       trs.tblPayDtl
			exec pub.SpFilterByPermission2 '#tblAcntCode', 'AcntCode', 'acc.tblAcnt', @UserID; 
			SET @StrWhere =  @StrWhere + '  and  ( D.CreditCode in (SELECT   CreditCode	FROM  #tblOurBanks    ) 
												or   D.CreditCode in (SELECT   AcntCode	FROM  #tblAcntCode    ) )'
	end 
	
Delete From  #tblAcntCode where AcntCode='' or AcntCode is null
Delete From  #tblOurBanks where CreditCode='' or CreditCode is null

end
------------------------------------------------------------------------------------------------------

--select @Result1		
	/* ======= Create Main String Query Section ======== */
	SET @StrSelect = '
	SELECT	D.*, BH.AcntCode2, BH.BankCode, BD.BankName, BD.BankAddress, 
			case when LTRIM(D.ChequeDate) = '''' THEN 0 ELSE pub.funFarsiDateDiff(''Day'', ' + @StrBaseDate + ', D.ChequeDate) END AS DateDuration,
			pub.GetCodeName(D.VisitorAcntCode,' + @LangID + ') AS VisitorAcntCodeName,
			pub.GetCodeName(D.DebitCode, '  + @LangID + ') AS DebitName, 
			pub.GetCodeName(D.CreditCode, ' + @LangID + ') AS CreditName,
			pub.GetBankName(D.DebitCode, '  + @LangID + ') AS DebitNameB, 
			pub.GetBankName(D.CreditCode, ' + @LangID + ') AS CreditNameB,
			BT.BankTypeName, LD.LocationName, D.LastProcessID AS ChequeState
			
	FROM	(
				SELECT   ' + @Result1 + ', LST.ProcessID as LastProcessID, 
					LST.DebitCode as LastDebitCode,
					LST.CreditCode as LastCreditCode
					,isnull((Select DocDate from  trs.tblPayDtl d1 Where d1.ProcessID=27 and  d1.VolumeFiscalYear=D.VolumeFiscalYear and  d1.VolumeRowNo=D.VolumeRowNo ),'''') as ReceiptDate
					,isnull((Select DocDate from  trs.tblPayDtl d1 Where d1.ProcessID=28 and  d1.VolumeFiscalYear=D.VolumeFiscalYear and  d1.VolumeRowNo=D.VolumeRowNo ),'''') as ReturnDate
			
				FROM trs.tblPayDtl D
				INNER JOIN trs.tblPayHdr H on  D.ProcessID=H.ProcessID and  D.ProcessNo=H.ProcessNo and D.FiscalYear=H.FiscalYear and  D.SerialNo=H.SerialNo
				LEFT JOIN (
							Select PDI.*
							From trs.tblPayDtl PDI
							Inner Join
								(
									SELECT VolumeFiscalYear, VolumeRowNo, Max(EventNo) AS EventNo
									FROM trs.tblPayDtl
									WHERE PayTypeID In (7,8,28)' + @StrWhere2 + '				
									GROUP BY VolumeFiscalYear, VolumeRowNo
								) VL on VL.VolumeFiscalYear=PDI.VolumeFiscalYear and VL.VolumeRowNo=PDI.VolumeRowNo and VL.EventNo=PDI.EventNo
							Where PayTypeID In (7,8,28)
					
						  ) LST ON LST.ProcessNo=D.ProcessNo and LST.PayTypeID=D.PayTypeID and [LST].VolumeFiscalYear=D.VolumeFiscalYear and [LST].VolumeRowNo=D.VolumeRowNo --and [LST].EventNo=D.EventNo
			) D
			LEFT  JOIN trs.tblPayHdr H ON H.ProcessID=D.ProcessID and H.ProcessNo=D.ProcessNo and H.FiscalYear=D.FiscalYear and H.SerialNo=D.SerialNo
			LEFT  JOIN trs.tblOurBanks BH ON BH.BankCode = D.CreditCode  
			LEFT  JOIN trs.tblOurBanksDtl BD ON BH.BankCode = BD.BankCode 
			LEFT  JOIN pub.tblLocationsDtl LD ON LD.LocationID = D.LocationID AND LD.LanguageID = ' + @LangID + '
			LEFT  JOIN trs.tblBankTypesDtl BT ON D.BankTypeID = BT.BankTypeID AND BT.LanguageID = ' + @LangID + '
	WHERE ' + @StrWhere + '
	ORDER BY ' + @SortFields

	Print @StrSelect
	Exec sp_executesql @StrSelect;
END
GO
