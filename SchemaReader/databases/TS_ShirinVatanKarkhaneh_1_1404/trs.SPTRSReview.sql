USE TS_ShirinVatanKarkhaneh_1_1404
GO
SET ANSI_NULLS, QUOTED_IDENTIFIER ON
GO
-- =========== TS-QC:NOTOK ========================
-- Author        : Jafari
-- Create date   : 1404/06/16
-- Viewed By	 : 
-- Last Modified : 
-- Description   : گزارش مروری بایت دریافتی و پرداختی ها
-- =============================================
Create PROCEDURE trs.SPTRSReview
	@TrsType as Int,
	@ProcessNo as Int,
	@FromDate as varchar(10),
	@ToDate as varchar(10),
	@DebitCode as varchar(20),
	@CreditCode as varchar(20),
	@ChequeNo  as bigint,
	@ChequeNoNew  as bigint,
	@VolumeFiscalYear  as int,
	@VolumeRowNo  as int, 
	@ExtraParams		NVarChar(Max) = ''

WITH ENCRYPTION
AS
begin

	DECLARE @Stert			int=0
	DECLARE @Count			int=0

	SET @Stert			    = LTrim(pub.funSplitString(@ExtraParams, '@', 1)); 
	SET @Count			    = LTrim(pub.funSplitString(@ExtraParams, '@', 2)); 

	update trs.tblPayDtl
	set NationalIDNumber=''
	where NationalIDNumber='0'

	DECLARE @StrSelect		NVarChar(Max);
	DECLARE @StrWhere		NVarChar(Max);

	if ISnull(@FromDate ,'')=''
		Set @FromDate='1300/01/01'
	if ISnull(@ToDate ,'')=''
		Set @ToDate='1999/12/30'

	set @StrWhere=' 1=1'
	set @StrWhere=@StrWhere+'	And D.DocDate>='''+@FromDate+''''
	set @StrWhere=@StrWhere+'	And D.DocDate<='''+@ToDate+''''	
	
	if ISnull(@ProcessNo ,0)<>0
		set @StrWhere=@StrWhere+'	And D.ProcessNo='+Str(@ProcessNo)+''
	if ISnull(@ChequeNo ,0)<>0
		set @StrWhere=@StrWhere+'	And D.ChequeNo='+Str(@ChequeNo)+''
	if ISnull(@VolumeFiscalYear ,0)<>0
		set @StrWhere=@StrWhere+'	And D.VolumeFiscalYear='+Str(@VolumeFiscalYear)+''
	if ISnull(@VolumeRowNo ,0)<>0
		set @StrWhere=@StrWhere+'	And D.VolumeRowNo='+Str(@VolumeRowNo)+''
	if ISnull(@ChequeNoNew ,'')<>''
		set @StrWhere=@StrWhere+'	And D.ChequeNoNew='''+@ChequeNoNew+''''
	if ISnull(@DebitCode ,'')<>'' or ISnull(@CreditCode ,'')<>'' 
		set @StrWhere=@StrWhere+'	And (D.DebitCode='''+@DebitCode+''' Or  D.CreditCode='''+@CreditCode+''''

if @TrsType=0
begin

CREATE TABLE #tblPayTypeID
	(
		PayTypeID Varchar(21)collate arabic_cs_as null,
		PayTypeName Varchar(200)collate arabic_cs_as null
	)
insert into  #tblPayTypeID
	select  1,'نقد'
	Union all select   2, 'حواله'
	Union all select   3, 'فيش نقدی'
	Union all select   4, 'حواله بانکی'
	Union all select   5, 'برداشت از حساب'
	Union all select   6, 'دريافتي تجاري'
	Union all select   7, 'چک روز'
	Union all select   8 ,'پرداختي تجاري'
	Union all select   16, 'دريافتي اماني'
	Union all select   18, 'پرداختي اماني'
	Union all select   26, 'دريافتي غير تجاري'
	Union all select   28, 'پرداختي غير تجاري'
	Union all select   30, 'انتقال بانک به بانک'
	Union all select   31, 'سفته اماني دريافتي  '
	Union all select   32, 'سفته اماني پرداختي  '
	Union all select   33, 'ضمانتنامه هاي بانکي - پرداختني'
	Union all select   34, 'ضمانتنامه هاي بانکي - دريافتني'
	Union all select   35, 'کارت خوان'
	Union all select   36, 'کارت هديه'
	Union all select   37, 'بن کارت'
	Union all select   38, 'واريز اينترنتي'

	CREATE TABLE #tblAcntCode
	(
		AcntCode Varchar(21)collate arabic_cs_as null
	)
		
	CREATE TABLE #tblOurBank
	(
		BankCode Varchar(21)collate arabic_cs_as null
	)
	
	Insert into #tblAcntCode (AcntCode)  
	Select Distinct AcntCode  from (
			Select Distinct DebitCode AcntCode from trs.tblPayDtl	 
				where ProcessID in (2,3,4,12,13,18,24,25,32,33) And DocDate>=@FromDate And DocDate<=@ToDate

			Union all
			Select Distinct CreditCode AcntCode from trs.tblPayDtl
				where ProcessID in (1,3,4,10,17,18,28,31,34) And DocDate>=@FromDate And DocDate<=@ToDate 
		)a where AcntCode<>''

	Insert into #tblAcntCode (AcntCode)  
	select Distinct D.CreditCode
  from trs.tblPayHdr H
	inner join trs.tblPayDtl D	ON  H.ProcessID=D.ProcessID AND H.ProcessNo=D.ProcessNo AND H.FiscalYear=D.FiscalYear AND H.SerialNo=D.SerialNo 
	where D.CreditCode<>'' and H.CreditCode=''	and D.ProcessID=12
		 
	Insert into #tblOurBank (BankCode)  	
	Select Distinct AcntCode  from (
			Select Distinct DebitCode AcntCode from trs.tblPayDtl
				where DocDate>=@FromDate And DocDate<=@ToDate 
			Union all
			Select Distinct CreditCode AcntCode from trs.tblPayDtl	 
				where DocDate>=@FromDate And DocDate<=@ToDate 
		)a where AcntCode<>''
			and AcntCode not in (Select Distinct AcntCode  from #tblAcntCode )

select  D.ProcessID , ProcessName,  D.ProcessNo ,  D.FiscalYear ,  D.SerialNo ,  D.RowNo ,  D.DocDate ,  D.PayTypeID ,RowDesc PayTypeName,  D.DebitCode 
		,  D.CreditCode ,  D.Amount, H.BehalfID , BehalfName, H.DescHdr, H.DescHdr2,H.VisitorAcntCode,  H.AcntDiscount
		, H.DiscountAmount,  D.VolumeFiscalYear,D.VolumeRowNo, ChequeNo,ChequeNoNew,ChequeCryptNo,NationalIDNumber,ChequeDate,RowDesc 
		, D.BankTypeID,BankTypeName, D.LocationID,LocationName,BranchCode,BranchName
		,AccountNo	,AccOwnerName
		,D.CreditCode AcntCodeCredit ,D.CreditCode OurBanksCredit 
		,D.CreditCode AcntCodeDebit ,D.CreditCode OurBanksDebit 
		,ChequeBookFiscalYear	,ChequeBookID, CurrencyAmount	,D.CurrencyRate,D.CurrencyTypeID,RowDesc CurrencyTypeName
		,  RegChequeNoNewIN RegChequeNoNew
		
		into #tblPay
	from trs.tblPayHdr H
	inner join  trs.tblPayDtl D	ON  H.ProcessID=D.ProcessID AND H.ProcessNo=D.ProcessNo AND H.FiscalYear=D.FiscalYear AND H.SerialNo=D.SerialNo 
	left Join  trs.tblBehalfDtl b on H.BehalfID=b.BehalfID AND b.LanguageID=1
	left Join  trs.tblBankTypesDtl bt on D.BankTypeID=bt.BankTypeID AND bt.LanguageID=1
	left Join  pub.tblLocationsDtl l on D.LocationID=l.LocationID AND l.LanguageID=1
	Left Join pub.tblProcess P ON H.ProcessID=P.ProcessID and H.ProcessNo=P.ProcessNo 
	Where 1=0
	
	set @StrSelect =' insert into #tblPay
	select  D.ProcessID , ProcessName, D.ProcessNo , D.FiscalYear , D.SerialNo , D.RowNo , D.DocDate , D.PayTypeID , PayTypeName, D.DebitCode 
		, D.CreditCode , D.Amount, H.BehalfID , BehalfName, H.DescHdr, H.DescHdr2, H.VisitorAcntCode, H.AcntDiscount
		, H.DiscountAmount, D.VolumeFiscalYear, D.VolumeRowNo, ChequeNo, ChequeNoNew, ChequeCryptNo, NationalIDNumber, ChequeDate, RowDesc 
		, D.BankTypeID, BankTypeName, D.LocationID, LocationName, BranchCode, BranchName , AccountNo ,AccOwnerName
		, isnull(ACredit.AcntCode, '''') AcntCodeCredit ,isnull(BCredit.BankCode, '''') OurBanksCredit 
		, isnull(ADebit.AcntCode, '''') AcntCodeDebit ,isnull(BDebit.BankCode, '''') OurBanksDebit 
		, ChequeBookFiscalYear	,ChequeBookID, CurrencyAmount	,D.CurrencyRate,D.CurrencyTypeID, isnull(CurrencyTypeName, '''')
		, Case when RegChequeNoNewIN=1 then RegChequeNoNewIN else RegChequeNoNewOut end RegChequeNoNew
	from trs.tblPayHdr H
	inner join trs.tblPayDtl D	ON  H.ProcessID=D.ProcessID AND H.ProcessNo=D.ProcessNo AND H.FiscalYear=D.FiscalYear AND H.SerialNo=D.SerialNo 
	left join pub.tblCurrencyTypesDtl c on c.CurrencyTypeID=D.CurrencyTypeID  AND c.LanguageID=1
	left Join trs.tblBehalfDtl b on H.BehalfID=b.BehalfID AND b.LanguageID=1
	left Join trs.tblBankTypesDtl bt on D.BankTypeID=bt.BankTypeID AND bt.LanguageID=1
	left Join pub.tblLocationsDtl l on D.LocationID=l.LocationID AND l.LanguageID=1
	Left Join pub.tblProcess P ON H.ProcessID=P.ProcessID and H.ProcessNo=P.ProcessNo 
	left Join #tblPayTypeID p on D.PayTypeID=p.PayTypeID
	left Join #tblAcntCode ACredit on D.CreditCode =ACredit.AcntCode
	left Join #tblAcntCode ADebit on D.DebitCode=ADebit.AcntCode
	left Join #tblOurBank BCredit on D.CreditCode =BCredit.BankCode 
	left Join #tblOurBank BDebit on D.DebitCode=BDebit.BankCode
	WHERE 	'+@StrWhere+' And 	D.ProcessID<>41
	ORDER BY DocDate, FiscalYear,SerialNo,ProcessID,ProcessNo,VolumeRowNo
	Offset '+str(@Stert)+' Rows Fetch Next '+str(@Count)+' Rows only '
  
	print   @StrSelect;             
	EXEC sp_executesql @StrSelect;
	
	select a.ProcessID	,a.ProcessName	,a.ProcessNo	,a.FiscalYear	,a.SerialNo	,a.RowNo	,a.DocDate	,a.PayTypeID	,a.PayTypeName	
		,REPLACE(a.DebitCode,' ',' ') DebitCode	,REPLACE(a.CreditCode,' ',' ') CreditCode	,a.Amount	,a.BehalfID	,a.BehalfName	,a.DescHdr	
		,a.DescHdr2	,REPLACE(a.VisitorAcntCode,' ',' ') VisitorAcntCode	,a.AcntDiscount	,a.DiscountAmount	,a.VolumeFiscalYear	,a.VolumeRowNo	
		,a.ChequeNo	,a.ChequeNoNew	,a.ChequeCryptNo	,a.NationalIDNumber	,a.ChequeDate	,a.RowDesc	,a.BankTypeID	,a.BankTypeName	
		,a.LocationID,a.LocationName	,a.BranchCode	,a.BranchName	,a.AccountNo	,a.AccOwnerName  ,REPLACE(a.AcntCodeCredit,' ',' ') AcntCodeCredit	
		,REPLACE(a.OurBanksCredit,' ',' ')   OurBanksCredit	,REPLACE(a.AcntCodeDebit,' ',' ') AcntCodeDebit	,REPLACE(a.OurBanksDebit,' ',' ') OurBanksDebit	
		,a.ChequeBookFiscalYear	,a.ChequeBookID	,a.CurrencyAmount ,a.CurrencyRate	,a.CurrencyTypeID	,a.CurrencyTypeName	,a.RegChequeNoNew	
		,REPLACE(a.AcntPayChequeOwner	,' ',' ')  AcntPayChequeOwner	,a.LastState	,isnull(b.ProcessName, '') LastStateName 
		, Isnull(pub.GetCodeName(VisitorAcntCode,1), '') VisitorName ,pub.GetCodeName(AcntPayChequeOwner,1) PayChequeOwnerName		
		,Isnull(Case when isnull(AcntCodeCredit, '') =''  then trs.GetOurBankName(OurBanksCredit,1) else pub.GetCodeName(AcntCodeCredit,1)  end  , '') CreditCodeName
		,Isnull(Case when isnull(AcntCodeDebit, '') =''  then trs.GetOurBankName(OurBanksDebit ,1) else pub.GetCodeName(AcntCodeDebit ,1)  end  , '') DebitCodeName
	 From 
		(	select a.*,Isnull(trs.funGetChequeOwner(VolumeFiscalYear,VolumeRowNo, PayTypeID),'') AcntPayChequeOwner
					 ,Isnull(trs.funGetChequeLastState(	VolumeFiscalYear,VolumeRowNo, PayTypeID,Amount,ChequeNo,ChequeDate	),0)LastState
			 from  #tblPay a
		)a
	Left join pub.tblProcess  b
	on a.LastState =b.ProcessID and b.ProcessNo=1
	Order by DocDate, FiscalYear,SerialNo,ProcessID,ProcessNo

end


if @TrsType=1
begin	

	set @StrSelect ='
	select  Count(*)
	from trs.tblPayHdr H
	inner join trs.tblPayDtl D	ON  H.ProcessID=D.ProcessID AND H.ProcessNo=D.ProcessNo AND H.FiscalYear=D.FiscalYear AND H.SerialNo=D.SerialNo 
	WHERE 	'+@StrWhere+' And 	D.ProcessID<>41
	'
  
	print   @StrSelect;             
	EXEC sp_executesql @StrSelect;

end	
end

GO
