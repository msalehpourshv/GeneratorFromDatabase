USE TS_ShirinVatanKarkhaneh_1_1404
GO
SET ANSI_NULLS, QUOTED_IDENTIFIER ON
GO
-- =========== TS-QC:UPDATED ====================
-- Author		 : TakroSystem\jafari
-- Create date   : 1396/12/24
-- Viewed By	 : 
-- Last Modified : 
-- Last Modifier : 
-- ----------------------------------------------
-- Description	 : لیست کل چکهای دریافتی
-- ==============================================
Create PROCEDURE [trs].[SpRetChequeFlow]
	@ExtraParams		NVarChar(Max) = ''	,
	@RepInfo			NVarChar(100) = '1@1@1',
	@RepOptions			VarChar(20) = '111' -- bit array	
WITH ENCRYPTION
As
Begin

Declare @StrResult NVarChar(max);
Declare @LanguageID as int;
Declare @BaseDate			Char(10)
Select @BaseDate = LEFT([pub].[funFarsiDate](GetDate()), 10)
Declare @StrWhere	NVarChar(max),
@VolumeFiscalYear1 int,	
@VolumeRowNo1 int,		
@VolumeFiscalYear2 int,
@VolumeRowNo2		int,
@StartDate1			Char(10),
@StartDate2		Char(10)	,
@ChequeDate1	Char(10)	,
@ChequeDate2	Char(10)	,
@DocDate1		Char(10)	,
@DocDate2		Char(10)	,
@FollowAcntCode		varchar(20),
@ReceiptAcntCode	varchar(20),
@DebitAcntCode      varchar(20),
@CallType		int
DECLARE	@LangID		Char(1);
DECLARE	@SessionNo	Int; 
DECLARE	@ReportID	Int;
DECLARE	@UserID		Int;
DECLARE	@UserIsAdmin bit;
DECLARE	@PartNumber	Int;
DECLARE	@ProcessNo int ;


Set @StrWhere	=''
Set @LanguageID=1


SET @VolumeFiscalYear1		 = LTrim(pub.funSplitString(@ExtraParams, '@', 1)); 
SET @VolumeRowNo1			 = LTrim(pub.funSplitString(@ExtraParams, '@', 2)); 
SET @VolumeFiscalYear2       = LTrim(pub.funSplitString(@ExtraParams, '@', 3));
SET @VolumeRowNo2			 = LTrim(pub.funSplitString(@ExtraParams, '@', 4)); 
SET @StartDate1			     = LTrim(pub.funSplitString(@ExtraParams, '@', 5)); 
SET @StartDate2			     = LTrim(pub.funSplitString(@ExtraParams, '@', 6)); 
SET @ChequeDate1			 = LTrim(pub.funSplitString(@ExtraParams, '@', 7)); 
SET @ChequeDate2			 = LTrim(pub.funSplitString(@ExtraParams, '@', 8)); 
SET @DocDate1			     = LTrim(pub.funSplitString(@ExtraParams, '@', 9)); 
SET @DocDate2			     = LTrim(pub.funSplitString(@ExtraParams, '@', 10)); 
SET @FollowAcntCode			 = LTrim(pub.funSplitString(@ExtraParams, '@', 11)); 
SET @ReceiptAcntCode		 = LTrim(pub.funSplitString(@ExtraParams, '@', 12)); 
SET @DebitAcntCode		     = LTrim(pub.funSplitString(@ExtraParams, '@', 13)); 
SET @LangID			    	 = LTrim(pub.funSplitString(@ExtraParams, '@', 14));
SET @SessionNo			     = LTrim(pub.funSplitString(@ExtraParams, '@', 15));
SET @ReportID				 = LTrim(pub.funSplitString(@ExtraParams, '@', 16));
SET @UserID					 = LTrim(pub.funSplitString(@ExtraParams, '@', 17));
SET @UserIsAdmin			 = LTrim(pub.funSplitString(@ExtraParams, '@', 18));
SET @ProcessNo			     = LTrim(pub.funSplitString(@ExtraParams, '@', 19));
SET @CallType			     = LTrim(pub.funSplitString(@ExtraParams, '@', 20));


Select  @PartNumber=SettingValue from  pub.tblSettings where SettingKey ='AcntPartNumberForRemainCalculation'
  


     IF (@ProcessNo >0)	SET @StrWhere = @StrWhere + ' AND a.ProcessNo =' + str(@ProcessNo) + ' '

     IF (@VolumeFiscalYear1 >0)	SET @StrWhere = @StrWhere + ' AND a.VolumeFiscalYear >=' + str(@VolumeFiscalYear1) + ' '
     IF (@VolumeRowNo1 >0)	SET @StrWhere = @StrWhere + ' AND a.VolumeRowNo >=' + str(@VolumeRowNo1) + ' '
	
     IF (@VolumeFiscalYear2 >0)	SET @StrWhere = @StrWhere + ' AND a.VolumeFiscalYear <=' + str(@VolumeFiscalYear2) + ' '
     IF (@VolumeRowNo2 >0)	SET @StrWhere = @StrWhere + ' AND a.VolumeRowNo <=' + str(@VolumeRowNo2) + ' '
     
	
     IF (@StartDate1 Is not Null  and @StartDate1<>'')	SET @StrWhere = @StrWhere + ' AND a.StartDate >=''' + @StartDate1 + ''' '
     IF (@StartDate2  Is not Null  and @StartDate2<>'')	SET @StrWhere = @StrWhere + ' AND a.StartDate <=''' + @StartDate2 + ''' '
	

	 IF (@ChequeDate1  Is not Null  and @ChequeDate1<>'')	SET @StrWhere = @StrWhere + ' AND a.ChequeDate >=''' + @ChequeDate1 + ''' '
     IF (@ChequeDate2  Is not Null  and @ChequeDate2<>'')	SET @StrWhere = @StrWhere + ' AND a.ChequeDate <=''' + @ChequeDate2 + ''' '
	
	 IF (@DocDate1  Is not Null  and @DocDate1<>'')	SET @StrWhere = @StrWhere + ' AND a.DocDate >=''' + @DocDate1 + ''' '
     IF (@DocDate2  Is not Null  and @DocDate2<>'')	SET @StrWhere = @StrWhere + ' AND a.DocDate <=''' + @DocDate2 + ''' '

	 IF (@FollowAcntCode   Is not Null  and @FollowAcntCode<>'')
		SET @StrWhere = @StrWhere + ' AND FollowAcntCode =''' + @FollowAcntCode+  ''''
		
	IF (@ReceiptAcntCode   Is not Null  and @ReceiptAcntCode<>'')
		SET @StrWhere = @StrWhere + ' AND ReceiptAcntCode =''' + @ReceiptAcntCode+  ''''
		
	IF (@DebitAcntCode   Is not Null  and @DebitAcntCode<>'')
		SET @StrWhere = @StrWhere + ' AND substring (DebitAcntCode ,acc.FunGetAcntInfoForRemain(2),acc.FunGetAcntInfoForRemain(3))=''' + @DebitAcntCode +  ''''
		
if @CallType=1
	
	Set @StrResult = 'Select * from (
		select ProcessID,ProcessNo ,FiscalYear, SerialNo, a.VolumeRowNo,a.VolumeFiscalYear,ChequeNo,isnull((Select top 1 DocDate From trs.tblPayDtl c where c.EventNo=1 and a.VolumeFiscalYear=c.VolumeFiscalYear and a.VolumeRowNo=c.VolumeRowNo and c.PayTypeID IN (6, 26) ),'''') StartDate,ChequeDate, DocDate,
				AccountNo, Amount, 
				BranchCode, AccOwnerName, LocationID, BankTypeID, 
				DebitCode DebitAcntCode, CreditCode,-- Vol.FirstCreditCode, 
				[pub].[funGetLockerSessionNo](ProcessID,ProcessNo,FiscalYear,SerialNo,'''',''trs.tblPayHdr'') LockerSessionNo,
			isnull(	CASE WHEN (ProcessID IN (2, 13, 18, 24)) 
					THEN pub.GetCodeName(DebitCode, ' + LTrim(Str(@LanguageID)) + ') 
					ELSE pub.GetBankName(DebitCode, ' + LTRim(Str(@LanguageID)) + ') 
				END ,'''') AS DebitName,
				isnull(CASE WHEN (ProcessID IN (1, 10, 17, 18)) 
					THEN pub.GetCodeName(CreditCode, ' + LTrim(Str(@LanguageID)) + ') 
					ELSE pub.GetBankName(CreditCode, ' + LTRim(Str(@LanguageID)) + ') 
				END ,'''')AS CreditName,
				--pub.GetCodeName(Vol.FirstCreditCode, ' + LTrim(Str(@LanguageID)) + ')  AS FirstCreditName,
				[pub].[funFarsiDateDiff](''Day'', ''' + @BaseDate + ''', ChequeDate) AS DateDuration
	,FollowAcntCode,ReceiptAcntCode,
	isnull(( Select AcntName From acc.tblAcntDtl  d Where  d.AcntCode=a.FollowAcntCode and  LanguageID=' + LTrim(Str(@LanguageID)) + ' and PartNumber ='+STR(@PartNumber)+') ,'''') AS FollowAcntCodeName,
	isnull(( Select AcntName From acc.tblAcntDtl  d Where  d.AcntCode=a.ReceiptAcntCode and  LanguageID=' + LTrim(Str(@LanguageID)) + ' and PartNumber ='+STR(@PartNumber)+' ),'''') AS ReceiptAcntCodeName
	 from trs.tblPayDtl a
inner join (
SELECT	VolumeFiscalYear, VolumeRowNo, Max(EventNo) AS EventNo					
FROM	trs.tblPayDtl AS PD2
WHERE	 PD2.PayTypeID IN (6, 26) 
group by VolumeFiscalYear, VolumeRowNo ) b
on a.VolumeFiscalYear=b.VolumeFiscalYear and a.VolumeRowNo=b.VolumeRowNo and a.EventNo=b.EventNo
where a.ProcessID in (13,18,24)
 ) a Where 1=1 ' + @StrWhere +''
 else
 Set @StrResult = 'Select * from (
		select ProcessID,ProcessNo ,FiscalYear, SerialNo, a.VolumeRowNo,a.VolumeFiscalYear,ChequeNo,isnull((Select top 1 DocDate From trs.tblPayDtl c where c.EventNo=1 and a.VolumeFiscalYear=c.VolumeFiscalYear and a.VolumeRowNo=c.VolumeRowNo and c.PayTypeID IN (6, 26) ),'''') StartDate,ChequeDate, DocDate,
				AccountNo, Amount, 
				BranchCode, AccOwnerName, LocationID, BankTypeID, 
				DebitCode DebitAcntCode, CreditCode,-- Vol.FirstCreditCode, 
				[pub].[funGetLockerSessionNo](ProcessID,ProcessNo,FiscalYear,SerialNo,'''',''trs.tblPayHdr'') LockerSessionNo,
				isnull(CASE WHEN (ProcessID IN (2, 13, 18, 24)) 
					THEN pub.GetCodeName(DebitCode, ' + LTrim(Str(@LanguageID)) + ') 
					ELSE pub.GetBankName(DebitCode, ' + LTRim(Str(@LanguageID)) + ') 
				END ,'''')AS DebitName,
				isnull(CASE WHEN (ProcessID IN (1, 10, 17, 18)) 
					THEN pub.GetCodeName(CreditCode, ' + LTrim(Str(@LanguageID)) + ') 
					ELSE pub.GetBankName(CreditCode, ' + LTRim(Str(@LanguageID)) + ') 
				END ,'''')AS CreditName,
				--pub.GetCodeName(Vol.FirstCreditCode, ' + LTrim(Str(@LanguageID)) + ')  AS FirstCreditName,
				[pub].[funFarsiDateDiff](''Day'', ''' + @BaseDate + ''', case when ChequeDate='''' then ''' + @BaseDate + ''' else ChequeDate end) AS DateDuration
	,FollowAcntCode,ReceiptAcntCode,
	isnull(( Select AcntName From acc.tblAcntDtl  d Where  d.AcntCode=a.FollowAcntCode and  LanguageID=' + LTrim(Str(@LanguageID)) + ' and PartNumber ='+STR(@PartNumber)+') ,'''') AS FollowAcntCodeName,
	isnull(( Select AcntName From acc.tblAcntDtl  d Where  d.AcntCode=a.ReceiptAcntCode and  LanguageID=' + LTrim(Str(@LanguageID)) + ' and PartNumber ='+STR(@PartNumber)+' ),'''') AS ReceiptAcntCodeName
	 from trs.tblPayDtl a
inner join (
SELECT	VolumeFiscalYear, VolumeRowNo, Max(EventNo) AS EventNo					
FROM	trs.tblPayDtl AS PD2
WHERE	 PD2.PayTypeID IN (6, 26) 
group by VolumeFiscalYear, VolumeRowNo ) b
on a.VolumeFiscalYear=b.VolumeFiscalYear and a.VolumeRowNo=b.VolumeRowNo and a.EventNo=b.EventNo
where  str(a.VolumeFiscalYear)+''@''+str(a.VolumeRowNo)  in (select str(VolumeFiscalYear)+''@''+str(VolumeRowNo) from trs.tblPayDtl where ProcessID in (13,18,24) )
and a.ProcessID not in  (13,18,24)
 ) a Where 1=1 
 
 ' + @StrWhere +''
			Print @StrResult;
	Exec sp_executesql @StrResult;
	

end 
GO
