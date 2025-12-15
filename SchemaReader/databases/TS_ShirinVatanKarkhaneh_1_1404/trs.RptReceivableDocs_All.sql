USE TS_ShirinVatanKarkhaneh_1_1404
GO
SET ANSI_NULLS, QUOTED_IDENTIFIER ON
GO
 -- =========== TS-QC:UPDATED ====================
-- Author		 : TakroSystem\Ahmadnejad
-- Create date   : 1386/03/12
-- Viewed By	 : 
-- Last Modified : 1388/12/16
-- Last Modifier : TakroSystem\Ahmadnejad
-- Description	 : <Receivable Documents Report>
-- ----------------------------------------------
-- گزارش اسناد دریافتنی - کلیه چکها
-- ==============================================
Create  PROCEDURE [trs].[RptReceivableDocs_All]
	@ProcessID			Int = 1,  -- Not Used
	@ProcessNo			Int = 1,
	@FiscalYearFr		Int = Null,
	@SerialNoFr			Int = Null,
	@FiscalYearTo		Int = Null,
	@SerialNoTo			Int = Null,
	@DebitCode1			Int = 0, -- بدهکار
	@DebitCode2	     	Int = 0,
	@DebitCode3		    Int = 0,
	@DebitCode4	    	Int = 0,
	@CreditCode1		Int = 0, -- بستانکار
	@CreditCode2		Int = 0,
	@CreditCode3		Int = 0,
	@CreditCode4		Int = 0,
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
	@AmountFr			VarChar(20) = Null, -- مبلغ از // dont use bigint
	@AmountTo			VarChar(20) = Null, -- مبلغ تا // dont use bigint
	@VchNoFr			int = Null, -- شماره عطف
	@VchNoTo			int = Null,
	@CityName			NVarChar(50) = Null,
	@BankName			NVarChar(50) = Null,
	@BranchCode			NVarChar(20) = Null,
	@BranchName			NVarChar(20) = Null, -- Not Used -- تجاری یا غیر تجاری
	@AccountNo			NVarChar(20) = Null, -- شماره حساب بانکی
	@AccountOwnerName	NVarChar(50) = Null,
	@AccountOwnerType	Bit = Null,  -- نوع صاحب حساب
	@SortFields			NVarChar(100) = Null, -- لیست فیلدها برای مرتب سازی
	@RepInfo			NVarChar(Max) = '1@1@1'
WITH ENCRYPTION
As
DECLARE @StrWhere		NVarChar(max);
DECLARE @StrWhere2		NVarChar(max);
DECLARE @StrSelect		NVarChar(max);
DECLARE @ExtraOptions			VarChar(1000) ;
declare @UseCurrency	bit;
declare @ShowChqNoNew	int;

set @ExtraOptions=@SortFields
	SET @SortFields		 = LTrim(pub.funSplitString(@ExtraOptions, '@', 1)); 
	SET @UseCurrency	= LTrim(pub.funSplitString(@ExtraOptions, '@', 2)); 
	SET @ShowChqNoNew	= LTrim(pub.funSplitString(@ExtraOptions, '@', 3)); 


DECLARE @StrPayTypeID	Varchar(10)
DECLARE @BaseDate		NVarChar(10)
DECLARE @StrBaseDate	nVarchar(20)
DECLARE	@TrsCalcAvgByDocDate bit;

DECLARE @LangID			Char(1)
DECLARE @SessionNo		VarChar(10)
DECLARE @ReportID		VarChar(10)

DECLARE @VisitorAcnt1 int
DECLARE @VisitorAcnt2 int
DECLARE @VisitorAcnt3 int
declare @CheqState as nvarchar(50)=''
Declare @LastDebitCode1 as int
Declare @LastDebitCode2 as int
Declare @LastDebitCode3 as int
Declare @LastDebitCode4 as int
 
DECLARE @StrAcntWhere	NVarChar(4000);
DECLARE @CampaignID				int;
DECLARE @VisitPathID1			int;
DECLARE @VisitPathID2			int;
DECLARE @VisitPathID3			int;
DECLARE @VisitPathID4			int;
DECLARE @SalesRoomClass			int;
DECLARE @ChequeNoFrNew			VarChar(20) ;
DECLARE @ChequeNoToNew			VarChar(20) ;
DECLARE @ChequeIsDigital		Bit ;
BEGIN   

	SET NOCOUNT ON;

	-- Init Variables -----------------------------------------------


	If (@RepInfo	Is Null)	SET @RepInfo    = '1@1@1'
	If (@ProcessNo  Is Null)	SET @ProcessNo  = 1
	If (@SortFields Is Null)	SET @SortFields = 'FiscalYear, SerialNo'

	IF (@FiscalYearFr Is Null)	SET @SerialNoFr	= Null;
	IF (@FiscalYearTo Is Null)	SET @SerialNoTo	= Null;

	IF (@SerialNoFr	Is Null)	SET @FiscalYearFr = Null;
	IF (@SerialNoTo	Is Null)	SET @FiscalYearTo = Null;

	IF (@VolumeYearFr Is Null)	SET @VolumeRowFr = Null;
	IF (@VolumeYearTo Is Null)	SET @VolumeRowTo = Null;

	IF (@VolumeRowFr Is Null)	SET @VolumeYearFr = Null;
	IF (@VolumeRowTo Is Null)	SET @VolumeYearTo = Null;

	IF (@DebitCode1 Is Null)	SET @DebitCode1 = 0;
	IF (@DebitCode2 Is Null)	SET @DebitCode2 = 0;
	IF (@DebitCode3 Is Null)	SET @DebitCode3 = 0;
	IF (@DebitCode4 Is Null)	SET @DebitCode4 = 0;

	

	IF (@CreditCode1 Is Null)	SET @CreditCode1 = 0;
	IF (@CreditCode2 Is Null)	SET @CreditCode2 = 0;
	IF (@CreditCode3 Is Null)	SET @CreditCode3 = 0;
	IF (@CreditCode4 Is Null)	SET @CreditCode4 = 0;

	SET @VisitorAcnt1=0
	SET @VisitorAcnt2=0
	SET @VisitorAcnt3=0
	SET	@LangID		= pub.funSplitString(@RepInfo, '@', 1);
	SET @SessionNo	= pub.funSplitString(@RepInfo, '@', 2);
	SET @ReportID	= pub.funSplitString(@RepInfo, '@', 3);
	SET @CheqState  =  pub.funSplitString(@RepInfo, '@', 6);
	SET @LastDebitCode1   =  pub.funSplitString(@RepInfo, '@', 8);
	SET @LastDebitCode2   =  pub.funSplitString(@RepInfo, '@', 9);
	SET @LastDebitCode3   =  pub.funSplitString(@RepInfo, '@', 10);
	SET @LastDebitCode4   =  pub.funSplitString(@RepInfo, '@', 11);
	SET @CampaignID		  = pub.funSplitString(@RepInfo, '@', 12);
	SET @VisitPathID1	  = pub.funSplitString(@RepInfo, '@', 13);
	SET @VisitPathID2	  = pub.funSplitString(@RepInfo, '@', 14);
	SET @VisitPathID3	  = pub.funSplitString(@RepInfo, '@', 15);
	SET @VisitPathID4	  = pub.funSplitString(@RepInfo, '@', 16);
	SET @SalesRoomClass	  = pub.funSplitString(@RepInfo, '@', 17);
	SET @ChequeNoFrNew	  = pub.funSplitString(@RepInfo, '@', 18);
	SET @ChequeNoToNew	  = pub.funSplitString(@RepInfo, '@', 19);
	Set @ChequeIsDigital  = pub.funSplitString(@RepInfo, '@', 20);

print @LastDebitCode4

	if @BranchName='1'
		SET @StrPayTypeID = '6'  -- اسناد دریافتنی تجاری
	else if @BranchName='2'
		SET @StrPayTypeID = '26' --غیرتجاری  اسناد دریافتنی
	
	if @BranchName='0'
		SET @StrPayTypeID = '6,26'  -- اسناد دریافتنی 
		
		
	SELECT @BaseDate = LEFT([pub].[funFarsiDate](GetDate()), 10)
	
	select @TrsCalcAvgByDocDate = isnull(SettingValue, 0)
	from pub.tblSettings
	where SettingKey = 'TrsCalcAvgByDocDate'

	if (@TrsCalcAvgByDocDate = 1)
		set @StrBaseDate = 'D.DocDate'
	else
		set @StrBaseDate = '''' + @BaseDate + ''''

	-- WHERE Section -------------------------------------------------------------------------------------------

	SET @StrWhere = ' (D.PayTypeID IN (' + @StrPayTypeID + ')) 
	AND (D.VolumeRowNo > 0) 
		AND (D.EventNo = 1) '

	if @ProcessNo<>0
	SET @StrWhere = @StrWhere + ' and (D.ProcessNo = ' + LTRim(Str(@ProcessNo)) + ')' 
		
	IF (@AccountOwnerType IS Not Null)
		SET @StrWhere = @StrWhere + ' AND D.AccountOwnerType = ' + Str(@AccountOwnerType)
	IF (@AccountOwnerName IS Not Null)
		SET @StrWhere = @StrWhere + ' AND D.AccOwnerName like N''%' + @AccountOwnerName + '%''' 

	IF (@FiscalYearFr Is Not Null)
		SET @StrWhere = @StrWhere + ' AND (D.FiscalYear > ' + LTrim(Str(@FiscalYearFr)) + ' OR (D.FiscalYear = ' + LTrim(Str(@FiscalYearFr)) + ' AND D.SerialNo >= ' + LTrim(Str(@SerialNoFr)) + ')) '
	IF (@FiscalYearTo Is Not Null)
		SET @StrWhere = @StrWhere + ' AND (D.FiscalYear < ' + LTrim(Str(@FiscalYearTo)) + ' OR (D.FiscalYear = ' + LTrim(Str(@FiscalYearTo)) + ' AND D.SerialNo <= ' + LTrim(Str(@SerialNoTo)) + ')) '

	IF (@VolumeYearFr Is Not Null)
		SET @StrWhere = @StrWhere + ' AND (D.VolumeFiscalYear > ' + LTrim(Str(@VolumeYearFr)) + ' OR (D.VolumeFiscalYear = ' + LTrim(Str(@VolumeYearFr)) + ' AND D.VolumeRowNo >= ' + LTrim(Str(@VolumeRowFr)) + ')) '
	IF (@VolumeYearTo Is Not Null)
		SET @StrWhere = @StrWhere + ' AND (D.VolumeFiscalYear < ' + LTrim(Str(@VolumeYearTo)) + ' OR (D.VolumeFiscalYear = ' + LTrim(Str(@VolumeYearTo)) + ' AND D.VolumeRowNo <= ' + LTrim(Str(@VolumeRowTo)) + ')) '


		set @VisitorAcnt1=@DebitCode2
		set @VisitorAcnt2=@DebitCode3
		set @VisitorAcnt3=@DebitCode4

	IF (@VisitorAcnt1 > 0)
		SET @StrWhere = @StrWhere + ' AND ' + pub.funGetFilterString(@SessionNo, @ReportID, @VisitorAcnt1, 'D.VisitorAcntCode')
	IF (@VisitorAcnt2 > 0)
		SET @StrWhere = @StrWhere + ' AND ' + pub.funGetFilterString(@SessionNo, @ReportID, @VisitorAcnt2, 'D.VisitorAcntCode')
	IF (@VisitorAcnt3 > 0)
		SET @StrWhere = @StrWhere + ' AND ' + pub.funGetFilterString(@SessionNo, @ReportID, @VisitorAcnt3, 'D.VisitorAcntCode')


		IF	(@CreditCode1 > 0)
		SET @StrWhere = @StrWhere + ' AND ' + pub.funGetFilterString(@SessionNo, @ReportID, @CreditCode1, 'D.CreditCode') 
	IF	(@CreditCode2 > 0)
		SET @StrWhere = @StrWhere + ' AND ' + pub.funGetFilterString(@SessionNo, @ReportID, @CreditCode2, 'D.CreditCode') 
	IF	(@CreditCode3 > 0)
		SET @StrWhere = @StrWhere + ' AND ' + pub.funGetFilterString(@SessionNo, @ReportID, @CreditCode3, 'D.CreditCode') 
	IF	(@CreditCode4 > 0)
		SET @StrWhere = @StrWhere + ' AND ' + pub.funGetFilterString(@SessionNo, @ReportID, @CreditCode4, 'D.CreditCode') 


	
	IF (@DocDateFr Is Not Null)
		SET @StrWhere = @StrWhere + ' AND (D.DocDate >= ''' + @DocDateFr + ''')'
	IF (@DocDateTo Is Not Null)
		SET @StrWhere = @StrWhere + ' AND (D.DocDate <= ''' + @DocDateTo + ''')'

	IF (@UsanceDateFr Is Not Null)
		SET @StrWhere = @StrWhere + ' AND (D.ChequeDate >= ''' + @UsanceDateFr + ''')'
	IF (@UsanceDateTo Is Not Null)
		SET @StrWhere = @StrWhere + ' AND (D.ChequeDate <= ''' + @UsanceDateTo + ''')'


Declare @NewChequeNo as Varchar(500)

set @NewChequeNo =' ( 0=1 ' 
	IF (@ChequeNoFr Is Not Null)
		SET @NewChequeNo = @NewChequeNo+ ' or (RTrim(LTrim(D.ChequeNo)) Like N''%' + LTrim(@ChequeNoFr) + '%'')  '

	IF (@ChequeNoTo Is Not Null)
		SET @NewChequeNo = @NewChequeNo + '  or (RTrim(LTrim(D.ChequeNo)) Like N''%' + LTrim(@ChequeNoTo) + '%'')'

set @NewChequeNo =@NewChequeNo  +' ) ' 

	IF (@ChequeNoFr Is Not Null)
		SET @StrWhere = @StrWhere + ' AND ((D.ChequeNo >= ''' + @ChequeNoFr + ''') or ' + @NewChequeNo + ')  '

	IF (@ChequeNoTo Is Not Null)
		SET @StrWhere = @StrWhere + ' AND ((D.ChequeNo <= ''' + @ChequeNoTo + ''') or ' + @NewChequeNo + ') '

	IF (@ChequeNoFrNew Is Not Null and @ChequeNoFrNew<>'') 
		SET @StrWhere = @StrWhere + ' AND (D.ChequeNoNew >= ''' + @ChequeNoFrNew + ''')'
	IF (@ChequeNoToNew Is Not Null and @ChequeNoToNew<>'')
		SET @StrWhere = @StrWhere + ' AND (D.ChequeNoNew <= ''' + @ChequeNoToNew + ''')'
	IF @ShowChqNoNew =1
		SET @StrWhere = @StrWhere + ' AND (D.ChequeNoNew = '''')'
	IF @ShowChqNoNew =2
		SET @StrWhere = @StrWhere + ' AND (D.ChequeNoNew <> '''')'

	IF @ChequeIsDigital =1
		SET @StrWhere = @StrWhere + ' AND (D.ChequeIsDigital = 1)'
	IF @ChequeIsDigital =0
		SET @StrWhere = @StrWhere + ' '


	IF (@AmountFr Is Not Null)
		SET @StrWhere = @StrWhere + ' AND D.Amount >= ' + @AmountFr
	IF (@AmountTo Is Not Null)
		SET @StrWhere = @StrWhere + ' AND D.Amount <= ' + @AmountTo

	If	(@VchNoFr Is Not Null)
		SET @StrWhere = @StrWhere + ' AND (H.VchNo >= ' + LTrim(Str(@VchNoFr)) + ')'
	If	(@VchNoTo Is Not Null)
		SET @StrWhere = @StrWhere + ' AND (H.VchNo <= ' + LTrim(Str(@VchNoTo)) + ')'

	IF (@CityName Is Not Null)
		SET @StrWhere = @StrWhere + ' AND RTrim(LTrim(LD.LocationName)) Like N''%' + LTrim(@CityName) + '%'''
	IF (@BankName Is Not Null)
		SET @StrWhere = @StrWhere + ' AND RTrim(LTrim(BT.BankTypeName)) Like N''%' + LTrim(@BankName) + '%'''
	IF (@BranchCode Is Not Null)
		SET @StrWhere = @StrWhere + ' AND RTrim(LTrim(D.BranchCode)) = ''' + LTrim(@BranchCode) + ''''
	IF (@AccountNo Is Not Null)
		SET @StrWhere = @StrWhere + ' AND RTrim(LTrim(D.AccountNo)) = ''' + LTrim(@AccountNo) + ''''
	-----------------------------------------------------------------
	--=========================

	Declare @CustomerPartNo			int;
	DECLARE @CustomerPartStart		int;
	DECLARE @CustomerPartLayerLen	int;

		
	select @CustomerPartNo=[acc].[FunGetAcntInfoForRemain](1)
	select @CustomerPartStart=[acc].[FunGetAcntInfoForRemain](2)
	select @CustomerPartLayerLen= [acc].[FunGetAcntInfoForRemain](3)


	set @StrAcntWhere=' '

	If  @CampaignID > 0 
		SET @StrAcntWhere = @StrAcntWhere + ' AND ' + pub.funGetFilterString(@SessionNo, @ReportID, @CampaignID, 'CampaignID') 

	If  @VisitPathID1 > 0 
		SET @StrAcntWhere = @StrAcntWhere + ' AND ' + pub.funGetFilterString(@SessionNo, @ReportID, @VisitPathID1, 'VisitPathID1') 
		
	If  @VisitPathID2 > 0 
		SET @StrAcntWhere = @StrAcntWhere + ' AND ' + pub.funGetFilterString(@SessionNo, @ReportID, @VisitPathID2, 'VisitPathID2') 
		
	If  @VisitPathID3 > 0 
		SET @StrAcntWhere = @StrAcntWhere + ' AND ' + pub.funGetFilterString(@SessionNo, @ReportID, @VisitPathID3, 'VisitPathID3') 
		
	If  @VisitPathID4 > 0 
		SET @StrAcntWhere = @StrAcntWhere + ' AND ' + pub.funGetFilterString(@SessionNo, @ReportID, @VisitPathID4, 'VisitPathID4') 
		
	If @SalesRoomClass > 0 
		SET @StrAcntWhere = @StrAcntWhere + ' AND ' + pub.funGetFilterString(@SessionNo, @ReportID, @SalesRoomClass, 'SalesRoomClass') 
		
	If  @StrAcntWhere <> ''
		SET @StrAcntWhere = '
		INNER JOIN (Select AcntCode AcntC From acc.tblAcnt Where PartNumber = ' + LTrim(RTrim(Str(@CustomerPartNo))) + ' 
		'+  @StrAcntWhere +'
		) a 
		ON Cast(Substring(D.CreditCode , ' + Str(@CustomerPartStart) + ', ' + Str(@CustomerPartLayerLen) + ') AS VarChar(20)) = a.AcntC '
			
	--=========================
	
	set @StrWhere2 =' and  1= 1 '
	if @LastDebitCode1 > 0
		 SET @StrWhere2 = @StrWhere2 + ' AND ' + pub.funGetFilterString(@SessionNo, @ReportID, @LastDebitCode1 , 'LastDebitCode')
	if @LastDebitCode2 > 0
		SET @StrWhere2 = @StrWhere2 + ' AND ' + pub.funGetFilterString(@SessionNo, @ReportID, @LastDebitCode2 , 'LastDebitCode')
	if @LastDebitCode3> 0
		SET @StrWhere2 = @StrWhere2 + ' AND ' + pub.funGetFilterString(@SessionNo, @ReportID, @LastDebitCode3, 'LastDebitCode')
	if @LastDebitCode4 > 0
		SET @StrWhere2 = @StrWhere2 + ' AND ' + pub.funGetFilterString(@SessionNo, @ReportID, @LastDebitCode4 , 'LastDebitCode')
	IF	(@DebitCode1 > 0)
		SET @StrWhere2 = @StrWhere2 + ' AND ' + pub.funGetFilterString(@SessionNo, @ReportID, @DebitCode1, 'LastDebitCode') 
	
	 
	-------------------------------------------------------------------
declare @Result1 as varchar(max)
SET @Result1= ''
exec [pub].[funGetColumnsWithoutXColumns] 
@SchemaName='trs',@tableName='tblPayDtl',
				@ColumnsName='Amount' ,
				@CompressTableName='D'
				,@Result=@Result1 output
				
		set @Result1=str(@UseCurrency) +' UseCurrency,isnull((SELECT C.CurrencyTypeName From  pub.tblCurrencyTypesDtl AS C Where H.CurrencyTypeID = C.CurrencyTypeID),'''') CurrencyTypeName,H.CurrencyRate CurrencyRateH,H.CurrencyTypeID CurrencyTypeIDH,'+@Result1
				
if (@UseCurrency=1)				
		set @Result1='case when H.CurrencyRate=0 then 0 Else  D.Amount/H.CurrencyRate end Amount,'		+@Result1
		else
		set @Result1='D.Amount,'		+@Result1
		
------------------------------------------------------------------------
 select *  into #tblPayDtl from 	trs.tblPayDtl 
--where CreditCode='' and SerialNo=529
Update #tblPayDtl
set CreditCode = isnull((select top 1 AtomAcntCode from trs.tblPayAtm A where   #tblPayDtl.ProcessID = A.ProcessID AND #tblPayDtl.ProcessNo = A.ProcessNo AND #tblPayDtl.FiscalYear = A.FiscalYear AND #tblPayDtl.SerialNo = A.SerialNo AND #tblPayDtl.DocRowNo = A.DocRowNo),'')
where CreditCode=''    
Update #tblPayDtl
set DebitCode = isnull((select top 1 AtomAcntCode from trs.tblPayAtm A where   #tblPayDtl.ProcessID = A.ProcessID AND #tblPayDtl.ProcessNo = A.ProcessNo AND #tblPayDtl.FiscalYear = A.FiscalYear AND #tblPayDtl.SerialNo = A.SerialNo AND #tblPayDtl.DocRowNo = A.DocRowNo),'')
where DebitCode='' 
--- لیست چکهای وصول شده
select *  into  #tblPayDtl3 from 	trs.tblPayDtl 
 where ProcessID in (12,22) and ProcessNo=@ProcessNo
------------------------------------------------------------------------

	SET @StrSelect = 'SELECT * 
	,Case when LastProcessID= 21 or LastProcessID=20 then 
		isnull((select top 1 BankName from trs.tblOurBanksDtl where BankCode=a.LastDebitCode),'''') 
	else
	isnull((select TOP 1 AcntName  from acc.tblAcntDtl  where AcntCode=substring(a.LastDebitCode ,'+str(@CustomerPartStart)+','+str(@CustomerPartLayerLen)+' )),'''') 
	end 	LastDebitCodeName 
	FROM (
		SELECT	' + @Result1 + ', H.VchNo, BT.BankTypeName, LD.LocationName,
				pub.GetCodeName(D.VisitorAcntCode,' + @LangID + ') AS VisitorAcntCodeName,
				isnull(pub.GetCodeName(D.DebitCode,' + @LangID + '),'''') AS DebitNameA,
				isnull(pub.GetBankName(D.DebitCode,' + @LangID + '),'''') AS DebitNameB,
				isnull(pub.GetCodeName(D.CreditCode,' + @LangID + '),'''') AS CreditNameA,
				isnull(pub.GetBankName(D.CreditCode,' + @LangID + '),'''') AS CreditNameB,
				CASE WHEN LTRIM(D.ChequeDate)='''' THEN 0 ELSE pub.funFarsiDateDiff(''Day'',' + @StrBaseDate + ', D.ChequeDate) END AS DateDuration,
				( 
					SELECT TOP 1 D2.ProcessID 
					FROM trs.tblPayDtl D2
					WHERE  (D2.PayTypeID In (' + @StrPayTypeID + ')) 
						AND D2.VolumeFiscalYear = LST.VolumeFiscalYear 
						AND D2.VolumeRowNo = LST.VolumeRowNo 
						AND D2.EventNo = LST.EventNo
				) LastProcessID,
				( 
					SELECT TOP 1 D2.DocDate 
					FROM trs.tblPayDtl D2
					WHERE  (D2.PayTypeID In (' + @StrPayTypeID + ')) 
						AND D2.VolumeFiscalYear = LST.VolumeFiscalYear 
						AND D2.VolumeRowNo = LST.VolumeRowNo 
						AND D2.EventNo = LST.EventNo
				) LastDocDate,
				( 
					SELECT TOP 1 D2.DebitCode
					FROM trs.tblPayDtl D2
					WHERE  (D2.PayTypeID In (' + @StrPayTypeID + ')) 
						AND D2.VolumeFiscalYear = LST.VolumeFiscalYear 
						AND D2.VolumeRowNo = LST.VolumeRowNo 
						AND D2.EventNo = LST.EventNo
				) LastDebitCode,
				isnull(D3.DocDate,'''') as ChequeCashingDate,
				isnull(pub.GetBankName(( 
					SELECT TOP 1 D2.DebitCode
					FROM trs.tblPayDtl D2
					WHERE  (D2.PayTypeID In (' + @StrPayTypeID + ')) 
						AND D2.VolumeFiscalYear = LST.VolumeFiscalYear 
						AND D2.VolumeRowNo = LST.VolumeRowNo 
						AND D2.EventNo = LST.EventNo
				),'+@LangID+'),'''') as HDebitNameA,
				isnull(pub.GetCodeName(( 
					SELECT TOP 1 D2.DebitCode
					FROM trs.tblPayDtl D2
					WHERE  (D2.PayTypeID In (' + @StrPayTypeID + ')) 
						AND D2.VolumeFiscalYear = LST.VolumeFiscalYear 
						AND D2.VolumeRowNo = LST.VolumeRowNo 
						AND D2.EventNo = LST.EventNo
				),'+@LangID+'),'''') as HDebitNameB
		FROM	#tblPayDtl AS D
					INNER JOIN trs.tblPayHdr H ON H.ProcessID = D.ProcessID AND H.ProcessNo = D.ProcessNo AND H.FiscalYear = D.FiscalYear AND H.SerialNo = D.SerialNo
					LEFT  JOIN trs.tblBankTypesDtl BT ON BT.BankTypeID = D.BankTypeID AND BT.LanguageID = ' + @LangID + '
					LEFT  JOIN pub.tblLocationsDtl LD ON LD.LocationID = D.LocationID AND LD.LanguageID = ' + @LangID + '
					LEFT  JOIN trs.vwLastVolumeInfo_Receipt LST ON D.VolumeFiscalYear = LST.VolumeFiscalYear AND D.VolumeRowNo = LST.VolumeRowNo
					LEFT  JOIN  #tblPayDtl3 D3 On  D3.ChequeNo = D.ChequeNo AND D3.ChequeDate=D.ChequeDate
					'+@StrAcntWhere+'
		WHERE	' + @StrWhere + '
		)a
		' + CASE WHEN   @CheqState <>'' THEN +' where LastProcessID in ( '+ @CheqState  +')' ELSE ' where 1=1 '  END 
		+ @StrWhere2 

	/* ---------------------------------------------------------------------------- */
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

	--select @UserID,@UserIsAdmin
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
	
		if @ProcessID =0 
		 begin
			Insert into  #tblOurBanks (CreditCode) SELECT  Distinct CreditCode	FROM       trs.tblPayDtl
			exec pub.SpFilterByPermission2 '#tblOurBanks', 'CreditCode', 'trs.tblOurBanks', @UserID; 
			Insert into  #tblAcntCode (AcntCode) SELECT  Distinct CreditCode	FROM       trs.tblPayDtl
			exec pub.SpFilterByPermission2 '#tblAcntCode', 'AcntCode', 'acc.tblAcnt', @UserID; 
			SET @StrSelect =  @StrSelect + '  and  ( a.CreditCode in (SELECT   CreditCode	FROM  #tblOurBanks    ) 
												or   a.CreditCode in (SELECT   AcntCode	FROM  #tblAcntCode    ) )'
		end 
	 


	end 
	
Delete From  #tblAcntCode where AcntCode='' or AcntCode is null
Delete From  #tblOurBanks where CreditCode='' or CreditCode is null
 
 end 
-- Sort ------------------------------------------------------------------------------------
	SET @StrSelect = @StrSelect + ' 
	ORDER BY  ' + @SortFields


	Print @StrSelect;
	Exec sp_executesql @StrSelect;
End
GO
