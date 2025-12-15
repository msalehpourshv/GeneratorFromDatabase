USE TS_ShirinVatanKarkhaneh_1_1404
GO
SET ANSI_NULLS, QUOTED_IDENTIFIER ON
GO
-- =========== TS-QC:UPDATED ====================
-- Author		 : TakroSystem\ZiA
-- Create date   : 1392/12/14
-- Viewed By	 : 
-- Last Modified : 1392/12/17
-- Last Modifier : TakroSystem\ZiA
-- Description   : گزارش دریافتها و پرداختها
-- =============================================
Create PROCEDURE [trs].[RptTrs_PayRecDocs]
	@ProcessNo			Int = 1,
	@DocDateFr			Char(10) = Null,
	@DocDateTo			Char(10) = Null,
	@DebitCode1			Int = 0, -- بدهکار
	@DebitCode2			Int = 0,
	@DebitCode3			Int = 0,
	@DebitCode4			Int = 0,
	@CreditCode1		Int = 0, -- بستانکار
	@CreditCode2		Int = 0,
	@CreditCode3		Int = 0,
	@CreditCode4		Int = 0,
	@VisitorCode1		Int = 0, -- بازاریاب
	@VisitorCode2		Int = 0, 
	@VisitorCode3		Int = 0, 
	@VisitorCode4		Int = 0, 
	@CollectorCode1		Int = 0, -- کد تحصیلدار
	@CollectorCode2		Int = 0, 
	@CollectorCode3		Int = 0, 
	@CollectorCode4		Int = 0, 
	@BankCode			Int = 0, 
	@UsanceDateFr		Char(10) = Null, -- از تاریخ سررسید
	@UsanceDateTo		Char(10) = Null, -- تا تاریخ سررسید
	@AmountFr			BigInt = Null,      -- از مبلغ 
	@AmountTo			BigInt = Null,      -- تا مبلغ 
	@DescMask			NVarChar(100)= Null, -- قسمتی از شرح
	@RepOptions			NVarChar(100) = '1000111', -- آرایه بیتی
	@RepInfo			NVarChar(100) = '1@1@1'
WITH ENCRYPTION
As
DECLARE @StrSelect	NVarChar(max)
DECLARE @StrSelect1	NVarChar(max)
DECLARE @StrSelect2	NVarChar(max)
DECLARE @StrFrom	NVarChar(max)
DECLARE @StrWhere	NVarChar(max)
DECLARE @StrWhereD	NVarChar(max)
DECLARE @StrWhereC	NVarChar(max)
DECLARE @StrWhereP	NVarChar(max)

DECLARE @StrDEBT	NVarChar(max)
DECLARE @StrCRDT	NVarChar(max)

DECLARE @LangID		Char(1)
DECLARE @SessionNo  VarChar(10)
DECLARE @ReportID   VarChar(10)

DECLARE @year		Char(4)
DECLARE @UseNotRemains	bit
DECLARE @ShowPettyCash	bit

DECLARE @Part1Start	Int;
DECLARE @Part2Start	Int;
DECLARE @Part3Start	Int;
DECLARE @Part4Start	Int;
DECLARE @Part1Len	Int;
DECLARE @Part2Len	Int;
DECLARE @Part3Len	Int;
DECLARE @Part4Len	Int;

Begin -- ======================= S T A R T   C O D E =========================================
	
	--SET @LangID = pub.funGetCurrentLanguageID();

	-- Init -----------------------------------------------------------------------------------
	Set NoCount On;

	If (@RepInfo	Is Null)		SET @RepInfo    = '1@1@1@0@1'
	IF (@BankCode	Is Null)		SET @BankCode	= 0
	If (@ProcessNo  Is Null)		SET @ProcessNo  = 1
	IF (@DebitCode1 Is Null)		SET @DebitCode1 = 0
	IF (@DebitCode2 Is Null)		SET @DebitCode2 = 0
	IF (@DebitCode3 Is Null)		SET @DebitCode3 = 0
	IF (@DebitCode4 Is Null)		SET @DebitCode4 = 0

	IF (@CreditCode1 Is Null)		SET @CreditCode1 = 0
	IF (@CreditCode2 Is Null)		SET @CreditCode2 = 0
	IF (@CreditCode3 Is Null)		SET @CreditCode3 = 0
	IF (@CreditCode4 Is Null)		SET @CreditCode4 = 0

	IF (@VisitorCode1 Is Null)		SET @VisitorCode1 = 0
	IF (@VisitorCode2 Is Null)		SET @VisitorCode2 = 0
	IF (@VisitorCode3 Is Null)		SET @VisitorCode3 = 0
	IF (@VisitorCode4 Is Null)		SET @VisitorCode4 = 0

	IF (@CollectorCode1 Is Null)	SET @CollectorCode1 = 0
	IF (@CollectorCode2 Is Null)	SET @CollectorCode2 = 0
	IF (@CollectorCode3 Is Null)	SET @CollectorCode3 = 0
	IF (@CollectorCode4 Is Null)	SET @CollectorCode4 = 0
	
	if (@DocDateFr is null) set @DocDateFr = '0000/00/00'
	if (@DocDateTo is null) set @DocDateTo = '9999/99/99'

	SET @LangID = pub.funSplitString(@RepInfo, '@', 1);
	SET @SessionNo = pub.funSplitString(@RepInfo, '@', 2);
	SET @ReportID = pub.funSplitString(@RepInfo, '@', 3);

	SET @year = RIGHT(db_name(), 4) 
	
	SET @UseNotRemains = Substring(@RepOptions, 1, 1);

	DECLARE @UserIDEx			VarChar(10);
	DECLARE @StrWhereSession		NVarChar(Max);

	SET @UserIDEx = '-1'
	SET @StrWhereSession=''
	SET @UserIDEx		= pub.funSplitString(@RepInfo, '@', 6);
	SET @ShowPettyCash	= pub.funSplitString(@RepInfo, '@', 7);
	
	SET		@Part1Start = 1;
	SELECT	@Part1Len = Layer1 + Layer2 + Layer3 + Layer4 + Layer5 + Layer6 + Layer7 + Layer8 + Layer9 
	FROM	pub.tblCodeLayer 
	WHERE	(TableName = 'acc.tblAcnt') AND (PartNumber = 1)

	SELECT	@Part2Start = @Part1Start + @Part1Len + 1;
	SELECT	@Part2Len = Layer1 + Layer2 + Layer3 + Layer4 + Layer5 + Layer6 + Layer7 + Layer8 + Layer9 
	FROM	pub.tblCodeLayer 
	WHERE	(TableName = 'acc.tblAcnt') AND (PartNumber = 2)

	SELECT	@Part3Start = @Part2Start + @Part2Len + 1;
	SELECT	@Part3Len = Layer1 + Layer2 + Layer3 + Layer4 + Layer5 + Layer6 + Layer7 + Layer8 + Layer9 
	FROM	pub.tblCodeLayer 
	WHERE	(TableName = 'acc.tblAcnt') AND (PartNumber = 3)

	SELECT	@Part4Start = @Part3Start + @Part3Len + 1;
	SELECT	@Part4Len = Layer1 + Layer2 + Layer3 + Layer4 + Layer5 + Layer6 + Layer7 + Layer8 + Layer9 
	FROM	pub.tblCodeLayer 
	WHERE	(TableName = 'acc.tblAcnt') AND (PartNumber = 4)

IF (@UserIDEx <> '' and @UserIDEx <> '-1')
	begin

		Create Table #tblSessionNo
		(
		SessionNo	Int
		)

		SET @StrSelect = '
		Insert Into #tblSessionNo
		Select * From [' + pub.funGetBranchDBName() + '].[pub].[funSessionNoList2](' + IsNull(Ltrim(@UserIDEx),0) + ')'

		Print @StrSelect;
		Exec sp_executesql @StrSelect;	

		SET @StrWhereSession =  ' (U.SessionNo = H.SessionNo) '		
		 
	end
	
	set @StrDEBT = '(D.ProcessID in (7,12,22,40,48)) or (D.ProcessID in (1,3) and D.PayTypeID in (1,2,3,4,5,7,30,35,38))'
	set @StrCRDT = '(D.ProcessID in (8,27,40,47)   ) or (D.ProcessID in (2,4) and D.PayTypeID in (1,2,3,4,5,7,30,35)) or (D.ProcessID in (5,6) and H.VchNo <> 0)'
	--------------------------------------------------------------------------------------------
	set @StrWhere = '(D.FiscalYear = ' + @year + ') and (D.ProcessNo = ' + LTrim(Str(@ProcessNo)) + ')'
	
	If	(@DebitCode1 > 0)
		SET @StrWhere = @StrWhere + ' AND ' + pub.funGetFilterString(@SessionNo, @ReportID, @DebitCode1, 'D.DebitCode') 
	If	(@DebitCode2 > 0)
		SET @StrWhere = @StrWhere + ' AND ' + pub.funGetFilterString(@SessionNo, @ReportID, @DebitCode2, 'D.DebitCode') 
	If	(@DebitCode3 > 0)
		SET @StrWhere = @StrWhere + ' AND ' + pub.funGetFilterString(@SessionNo, @ReportID, @DebitCode3, 'D.DebitCode') 
	If	(@DebitCode4 > 0)
		SET @StrWhere = @StrWhere + ' AND ' + pub.funGetFilterString(@SessionNo, @ReportID, @DebitCode4, 'D.DebitCode') 

	If	(@CreditCode1 > 0)
		SET @StrWhere = @StrWhere + ' AND ' + pub.funGetFilterString(@SessionNo, @ReportID, @CreditCode1, 'D.CreditCode') 
	If	(@CreditCode2 > 0)
		SET @StrWhere = @StrWhere + ' AND ' + pub.funGetFilterString(@SessionNo, @ReportID, @CreditCode2, 'D.CreditCode') 
	If	(@CreditCode3 > 0)
		SET @StrWhere = @StrWhere + ' AND ' + pub.funGetFilterString(@SessionNo, @ReportID, @CreditCode3, 'D.CreditCode') 
	If	(@CreditCode4 > 0)
		SET @StrWhere = @StrWhere + ' AND ' + pub.funGetFilterString(@SessionNo, @ReportID, @CreditCode4, 'D.CreditCode') 

	If	(@VisitorCode1 > 0)
		SET @StrWhere = @StrWhere + ' AND ' + pub.funGetFilterString(@SessionNo, @ReportID, @VisitorCode1, 'H.VisitorAcntCode') 
	If	(@VisitorCode2 > 0)
		SET @StrWhere = @StrWhere + ' AND ' + pub.funGetFilterString(@SessionNo, @ReportID, @VisitorCode2, 'H.VisitorAcntCode') 
	If	(@VisitorCode3 > 0)
		SET @StrWhere = @StrWhere + ' AND ' + pub.funGetFilterString(@SessionNo, @ReportID, @VisitorCode3, 'H.VisitorAcntCode') 
	If	(@VisitorCode4 > 0)
		SET @StrWhere = @StrWhere + ' AND ' + pub.funGetFilterString(@SessionNo, @ReportID, @VisitorCode4, 'H.VisitorAcntCode') 

	If	(@CollectorCode1 > 0)
		SET @StrWhere = @StrWhere + ' AND ' + pub.funGetFilterString(@SessionNo, @ReportID, @CollectorCode1, 'H.CollectorAcntCode') 
	If	(@CollectorCode2 > 0)
		SET @StrWhere = @StrWhere + ' AND ' + pub.funGetFilterString(@SessionNo, @ReportID, @CollectorCode2, 'H.CollectorAcntCode') 
	If	(@CollectorCode3 > 0)
		SET @StrWhere = @StrWhere + ' AND ' + pub.funGetFilterString(@SessionNo, @ReportID, @CollectorCode3, 'H.CollectorAcntCode') 
	If	(@CollectorCode4 > 0)
		SET @StrWhere = @StrWhere + ' AND ' + pub.funGetFilterString(@SessionNo, @ReportID, @CollectorCode4, 'H.CollectorAcntCode') 

	If	(@DocDateFr Is Not Null)
		SET @StrWhere = @StrWhere + ' AND (D.DocDate>=''' + @DocDateFr + ''')'
	If	(@DocDateTo Is Not Null)
		SET @StrWhere = @StrWhere + ' AND (D.DocDate<=''' + @DocDateTo + ''')'

	If	(@UsanceDateFr Is Not Null)
		SET @StrWhere = @StrWhere + ' AND (D.ChequeDate>=''' + @UsanceDateFr + ''')'
	If	(@UsanceDateTo Is Not Null)
		SET @StrWhere = @StrWhere + ' AND (D.ChequeDate<=''' + @UsanceDateTo + ''')'

	If	(@AmountFr Is Not Null)
		SET @StrWhere = @StrWhere + ' AND (D.Amount>=' + LTrim(Str(@AmountFr)) + ')'
	If	(@AmountTo Is Not Null)
		SET @StrWhere = @StrWhere + ' AND (D.Amount<=' + LTrim(Str(@AmountTo)) + ')'

	If (@DescMask Is Not Null)
		SET @StrWhere = @StrWhere + ' AND (Replace(D.RowDesc, '' '', '''') LIKE N''%' + RTrim(Replace(@DescMask, ' ', '')) + '%'')'

	set @StrWhereD = @StrWhere
	set @StrWhereC = @StrWhere
	
	If	(@BankCode > 0)
		SET @StrWhereD = @StrWhereD + ' AND ' + pub.funGetFilterString(@SessionNo, @ReportID, @BankCode, 'D.DebitCode')
	If	(@BankCode > 0)
		SET @StrWhereC = @StrWhereC + ' AND ' + pub.funGetFilterString(@SessionNo, @ReportID, @BankCode, 'D.CreditCode')
	
	SET @StrWhereC = @StrWhereC + ' AND (D.ProcessID <> 22)'
	SET @StrWhereD = @StrWhereD + ' AND (D.ProcessID <> 27)'
	
	-- S E L E C T -----------------------------------------------------------------------------
	
	create table #tbl_Remains
	(
		BankAcntCode	varchar(20) collate arabic_cs_as not null,
		DebitRemain1	float not null,
		DebitRemain2	float not null,
		DebitRemain3	float not null
	)
	
	Set @StrSelect = '
	insert into #tbl_Remains(BankAcntCode, DebitRemain1, DebitRemain2, DebitRemain3)
	select BankCode, 
			isnull((
				select SUM(Debit-Credit)
				from acc.tblVoucherDtl D
				where (D.VchKind<>0) 
					and (AcntCode=B.AcntCode1) 
					and (D.DocDate < ''' + @DocDateFr + ''')
			),0)
			+isnull((
				select SUM(Debit-Credit)
				from acc.tblVoucherDtl D
				where (D.VchKind<>0) 
					AND (AcntCode=B.AcntCode3) 
					AND (B.AcntCode3<>B.AcntCode1)
					AND (D.DocDate < ''' + @DocDateFr + ''')
			),0) DebitRemain1
			,
			isnull((
				select SUM(Debit-Credit)
				from acc.tblVoucherDtl D
				where (D.VchKind<>0) 
					AND (AcntCode=B.AcntCode2) 
					AND (D.DocDate < ''' + @DocDateFr + ''')
			),0)
			+isnull((
				select SUM(Debit-Credit)
				from acc.tblVoucherDtl D
				where (D.VchKind<>0) 
					AND (AcntCode=B.AcntCode5)  
					AND (B.AcntCode2<>B.AcntCode5)
					AND (D.DocDate < ''' + @DocDateFr + ''')
			),0)  DebitRemain2
			,
			
			
	isnull((
				select SUM(Debit-Credit)
				from acc.tblVoucherDtl D
				where (D.VchKind<>0) 
					AND (AcntCode=B.AcntCode1) 
					AND (D.DocDate<= ''' + @DocDateTo + ''')
			),0)
			+isnull((
				select SUM(Debit-Credit)
				from acc.tblVoucherDtl D
				where (D.VchKind<>0) 
					AND (AcntCode=B.AcntCode3)  
					AND (B.AcntCode3<>B.AcntCode1)
					AND (D.DocDate<= ''' + @DocDateTo + ''')
			),0)
			+
			isnull((
				select SUM(Debit-Credit)
				from acc.tblVoucherDtl D
				where (D.VchKind<>0) 
					AND (AcntCode=B.AcntCode2)  
					AND (B.AcntCode2<>B.AcntCode1)
					AND (D.DocDate<= ''' + @DocDateTo + ''')
			),0)
			+isnull((
				select SUM(Debit-Credit)
				from acc.tblVoucherDtl D
				where (D.VchKind<>0) 
					AND (AcntCode=B.AcntCode5)  
					AND (B.AcntCode5<>B.AcntCode1)
					AND (D.DocDate<= ''' + @DocDateTo + ''')
			),0) DebitRemain3
	
	from trs.tblOurBanks B
	'
	Print @StrSelect
	Exec sp_executesql @StrSelect;

	set @StrWhere = '(1=1)'
	
	if (@UseNotRemains = 0) 
		set @StrWhere = @StrWhere + ' and (X.RemainAffect=1)'

--------------------------------------------------------------------------------------------
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
			SET @StrWhere =  @StrWhere + '  and  (BankCode in (SELECT   CreditCode	FROM  #tblOurBanks    ) 
												or  BankCode in (SELECT   AcntCode	FROM  #tblAcntCode    ) )'

	end 
	
Delete From  #tblAcntCode where AcntCode='' or AcntCode is null
Delete From  #tblOurBanks where CreditCode='' or CreditCode is null


	end

	Set @StrSelect = '
		SELECT	B.BankCode, B.BankName, 
			D.ProcessID, D.ProcessNo, D.FiscalYear, D.SerialNo, D.RowNo, D.DocDate, D.PayTypeID, D.DebitCode, D.CreditCode, D.Amount, D.CurrencyTypeID, D.CurrencyRate, D.ChequeNo, D.ChequeBookFiscalYear, D.ChequeBookID, D.ChequeDate, D.VolumeFiscalYear, D.VolumeRowNo, D.EventNo, D.LocationID, D.BankTypeID, D.BranchCode, D.BranchName, D.BankSnNo, D.AccountNo, D.AccOwnerName, D.LocationID2, D.BankTypeID2, D.BranchCode2, D.BranchName2, D.AccountNo2, D.AccOwnerName2, D.DeliverTo, D.RowDesc, D.DocRowNo, D.IsConfirmed, D.AccountOwnerType, H.BaseSerialNo, H.BaseFiscalYear, D.WithdrawType, D.CurrencyAmount, D.VisitorAcntCode, D.EndDate_PayableTrust, D.SourceSerialNo, D.SourceProcessNo, D.WithAcntCode, D.ID,
			H.DebitCode DebitCodeH, H.CreditCode CreditCodeH, H.VchNo, H.DescHdr, 
			pub.GetCodeName(H.DebitCode, '  + @LangID + ') DebitNameAH,
			pub.GetBankName(H.DebitCode, '  + @LangID + ') DebitNameBH,
			pub.GetCodeName(H.CreditCode, ' + @LangID + ') CreditNameAH,
			pub.GetBankName(H.CreditCode, ' + @LangID + ') CreditNameBH,
			pub.GetCodeName(D.DebitCode, '  + @LangID + ') DebitNameA,
			pub.GetBankName(D.DebitCode, '  + @LangID + ') DebitNameB,
			pub.GetCodeName(D.CreditCode, ' + @LangID + ') CreditNameA,
			pub.GetBankName(D.CreditCode, ' + @LangID + ') CreditNameB,
			pub.GetUserName(H.SessionNo1) AS UserName, LD.LocationName,
			pub.funGetBankTypeName(D.BankTypeID, '  + @LangID + ') DebitBankTypeName,
			pub.funGetBankTypeName(D.BankTypeID2, ' + @LangID + ') CreditBankTypeName,
			T.TypeText PayTypeName, P.ProcessName, 1 As CDType, R.DebitRemain1, R.DebitRemain2, R.DebitRemain3,
			cast(case when (' + @StrDEBT + ') then 1 else 0 end as bit) as RemainAffect
			,cast(Substring(D.CreditCode,' + LTrim(Str(@Part1Start)) + ',' + LTrim(Str(@Part1Len)) + ')  as varchar(20) ) AcntCode1
			,cast(Substring(D.CreditCode,' + LTrim(Str(@Part2Start)) + ',' + LTrim(Str(@Part2Len)) + ') as varchar(20) ) AcntCode2
			,cast(Substring(D.CreditCode,' + LTrim(Str(@Part3Start)) + ',' + LTrim(Str(@Part3Len)) + ') as varchar(20) ) AcntCode3
			,cast(Substring(D.CreditCode,' + LTrim(Str(@Part4Start)) + ',' + LTrim(Str(@Part4Len)) + ') as varchar(20) ) AcntCode4
			,cast(acc.funGetAcntName(	Substring(D.CreditCode,' + LTrim(Str(@Part1Start)) + ',' + LTrim(Str(@Part1Len)) + ') ,	1,	' + LTrim(RTrim(@LangID)) + ' ) as nvarchar(50) )AcntCodeName1
			,cast(acc.funGetAcntName(	Substring(D.CreditCode,' + LTrim(Str(@Part2Start)) + ',' + LTrim(Str(@Part2Len)) + ') ,	2,	' + LTrim(RTrim(@LangID)) + ' ) as nvarchar(50) )AcntCodeName2
			,cast(acc.funGetAcntName(	Substring(D.CreditCode,' + LTrim(Str(@Part3Start)) + ',' + LTrim(Str(@Part3Len)) + ') ,	3,	' + LTrim(RTrim(@LangID)) + ' ) as nvarchar(50) )AcntCodeName3
			,cast(acc.funGetAcntName(	Substring(D.CreditCode,' + LTrim(Str(@Part4Start)) + ',' + LTrim(Str(@Part4Len)) + ') ,	4,	' + LTrim(RTrim(@LangID)) + ' ) as nvarchar(50) )AcntCodeName4
	FROM	trs.tblPayDtl D
	INNER JOIN trs.tblPayHdr		H ON D.ProcessID=H.ProcessID AND D.ProcessNo=H.ProcessNo AND D.FiscalYear=H.FiscalYear AND D.SerialNo=H.SerialNo
	LEFT  JOIN pub.tblLocationsDtl	LD ON D.LocationID2=LD.LocationID AND LD.LanguageID=' + @LangID + '
	LEFT  JOIN pub.tblTypeValues	T on T.TypeID=2 and T.TypeValue=D.PayTypeID
	LEFT  JOIN pub.tblProcess		P on P.ProcessID=D.ProcessID and P.ProcessNo=D.ProcessNo
	INNER JOIN trs.tblOurBanksDtl	B on B.BankCode=D.DebitCode
	INNER JOIN #tbl_Remains			R on R.BankAcntCode=B.BankCode
	'					
	IF (@UserIDEx <> '' and @UserIDEx <> '-1')
		SET @StrSelect = @StrSelect + ' INNER JOIN (Select * From #tblSessionNo) U ON ' + @StrWhereSession			
	
	Set @StrSelect =@StrSelect  +' WHERE	' + @StrWhereD 
Set @StrSelect1 = '	union all 
	SELECT	B.BankCode, B.BankName,
			D.ProcessID, D.ProcessNo, D.FiscalYear, D.SerialNo, D.RowNo, D.DocDate, D.PayTypeID, D.DebitCode, D.CreditCode, D.Amount, D.CurrencyTypeID, D.CurrencyRate, D.ChequeNo, D.ChequeBookFiscalYear, D.ChequeBookID, D.ChequeDate, D.VolumeFiscalYear, D.VolumeRowNo, D.EventNo, D.LocationID, D.BankTypeID, D.BranchCode, D.BranchName, D.BankSnNo, D.AccountNo, D.AccOwnerName, D.LocationID2, D.BankTypeID2, D.BranchCode2, D.BranchName2, D.AccountNo2, D.AccOwnerName2, D.DeliverTo, D.RowDesc, D.DocRowNo, D.IsConfirmed, D.AccountOwnerType, H.BaseSerialNo, H.BaseFiscalYear, D.WithdrawType, D.CurrencyAmount, D.VisitorAcntCode, D.EndDate_PayableTrust, D.SourceSerialNo, D.SourceProcessNo, D.WithAcntCode, D.ID,
			H.DebitCode DebitCodeH, H.CreditCode CreditCodeH, H.VchNo, H.DescHdr, 
			pub.GetCodeName(H.DebitCode, '  + @LangID + ') DebitNameAH,
			pub.GetBankName(H.DebitCode, '  + @LangID + ') DebitNameBH,
			pub.GetCodeName(H.CreditCode, ' + @LangID + ') CreditNameAH,
			pub.GetBankName(H.CreditCode, ' + @LangID + ') CreditNameBH,
			pub.GetCodeName(D.DebitCode, '  + @LangID + ') DebitNameA,
			pub.GetBankName(D.DebitCode, '  + @LangID + ') DebitNameB,
			pub.GetCodeName(D.CreditCode, ' + @LangID + ') CreditNameA,
			pub.GetBankName(D.CreditCode, ' + @LangID + ') CreditNameB,
			pub.GetUserName(H.SessionNo1) AS UserName, LD.LocationName,
			pub.funGetBankTypeName(D.BankTypeID, '  + @LangID + ') DebitBankTypeName,
			pub.funGetBankTypeName(D.BankTypeID2, ' + @LangID + ') CreditBankTypeName,
			T.TypeText PayTypeName, P.ProcessName, 0 As CDType, R.DebitRemain1, R.DebitRemain2, R.DebitRemain3,
			cast(case when (' + @StrCRDT + ') then 1 else 0 end as bit) as RemainAffect
			,cast(Substring(D.DebitCode,' + LTrim(Str(@Part1Start)) + ',' + LTrim(Str(@Part1Len)) + ')  as varchar(20) ) AcntCode1
			,cast(Substring(D.DebitCode,' + LTrim(Str(@Part2Start)) + ',' + LTrim(Str(@Part2Len)) + ') as varchar(20) ) AcntCode2
			,cast(Substring(D.DebitCode,' + LTrim(Str(@Part3Start)) + ',' + LTrim(Str(@Part3Len)) + ') as varchar(20) ) AcntCode3
			,cast(Substring(D.DebitCode,' + LTrim(Str(@Part4Start)) + ',' + LTrim(Str(@Part4Len)) + ') as varchar(20) ) AcntCode4
			,cast(acc.funGetAcntName(	Substring(D.DebitCode,' + LTrim(Str(@Part1Start)) + ',' + LTrim(Str(@Part1Len)) + ') ,	1,	' + LTrim(RTrim(@LangID)) + ' ) as nvarchar(50) )AcntCodeName1
			,cast(acc.funGetAcntName(	Substring(D.DebitCode,' + LTrim(Str(@Part2Start)) + ',' + LTrim(Str(@Part2Len)) + ') ,	2,	' + LTrim(RTrim(@LangID)) + ' ) as nvarchar(50) )AcntCodeName2
			,cast(acc.funGetAcntName(	Substring(D.DebitCode,' + LTrim(Str(@Part3Start)) + ',' + LTrim(Str(@Part3Len)) + ') ,	3,	' + LTrim(RTrim(@LangID)) + ' ) as nvarchar(50) )AcntCodeName3
			,cast(acc.funGetAcntName(	Substring(D.DebitCode,' + LTrim(Str(@Part4Start)) + ',' + LTrim(Str(@Part4Len)) + ') ,	4,	' + LTrim(RTrim(@LangID)) + ' ) as nvarchar(50) )AcntCodeName4
	FROM	trs.tblPayDtl D
	inner join trs.tblPayHdr		H ON D.ProcessID=H.ProcessID AND D.ProcessNo=H.ProcessNo AND D.FiscalYear=H.FiscalYear AND D.SerialNo=H.SerialNo
	left  join pub.tblLocationsDtl	LD ON D.LocationID2=LD.LocationID AND LD.LanguageID=' + @LangID + '
	left  join pub.tblTypeValues	T on T.TypeID=2 and T.TypeValue=D.PayTypeID
	left  join pub.tblProcess		P on P.ProcessID=D.ProcessID and P.ProcessNo=D.ProcessNo
	inner join trs.tblOurBanksDtl	B on B.BankCode=D.CreditCode
	INNER JOIN #tbl_Remains			R on R.BankAcntCode=B.BankCode
	'
	IF (@UserIDEx <> '' and @UserIDEx <> '-1')
		SET @StrSelect1 = @StrSelect1 + ' INNER JOIN (Select * From #tblSessionNo) U ON ' + @StrWhereSession				
Set @StrSelect1 =	@StrSelect1 + '	WHERE	' + @StrWhereC  
	--------------------------------------------------------------------------------------------
	set @StrWhereP=' '
	Set @StrSelect2 = ' '
if @ShowPettyCash='True'
begin
	set @StrWhereP=' 1=1 '
	--------------------------------------------------------------------------------------------
	set @StrWhereP = '(D.FiscalYear = ' + @year + ') and (D.ProcessNo = ' + LTrim(Str(@ProcessNo)) + ')'
	
	If	(@DebitCode1 > 0)
		SET @StrWhereP = @StrWhereP + ' AND ' + pub.funGetFilterString(@SessionNo, @ReportID, @DebitCode1, 'D.CostAcntCode') 
	If	(@DebitCode2 > 0)
		SET @StrWhereP = @StrWhereP + ' AND ' + pub.funGetFilterString(@SessionNo, @ReportID, @DebitCode2, 'D.CostAcntCode') 
	If	(@DebitCode3 > 0)
		SET @StrWhereP = @StrWhereP + ' AND ' + pub.funGetFilterString(@SessionNo, @ReportID, @DebitCode3, 'D.CostAcntCode') 
	If	(@DebitCode4 > 0)
		SET @StrWhereP = @StrWhereP + ' AND ' + pub.funGetFilterString(@SessionNo, @ReportID, @DebitCode4, 'D.CostAcntCode') 

	If	(@CreditCode1 > 0)
		SET @StrWhereP = @StrWhereP + ' AND ' + pub.funGetFilterString(@SessionNo, @ReportID, @CreditCode1, 'BB.AcntCode1') 
	If	(@CreditCode2 > 0)
		SET @StrWhereP = @StrWhereP + ' AND ' + pub.funGetFilterString(@SessionNo, @ReportID, @CreditCode2, 'BB.AcntCode1') 
	If	(@CreditCode3 > 0)
		SET @StrWhereP = @StrWhereP + ' AND ' + pub.funGetFilterString(@SessionNo, @ReportID, @CreditCode3, 'BB.AcntCode1') 
	If	(@CreditCode4 > 0)
		SET @StrWhereP = @StrWhereP + ' AND ' + pub.funGetFilterString(@SessionNo, @ReportID, @CreditCode4, 'BB.AcntCode1') 

	If	(@DocDateFr Is Not Null)
		SET @StrWhereP = @StrWhereP + ' AND (H.DocDate>=''' + @DocDateFr + ''')'
	If	(@DocDateTo Is Not Null)
		SET @StrWhereP = @StrWhereP + ' AND (H.DocDate<=''' + @DocDateTo + ''')'

	If	(@AmountFr Is Not Null)
		SET @StrWhereP = @StrWhereP + ' AND (D.CostAmount>=' + LTrim(Str(@AmountFr)) + ')'
	If	(@AmountTo Is Not Null)
		SET @StrWhereP = @StrWhereP + ' AND (D.CostAmount<=' + LTrim(Str(@AmountTo)) + ')'

	If (@DescMask Is Not Null)
		SET @StrWhereP = @StrWhereP + ' AND (Replace(D.DescDtl, '' '', '''') LIKE N''%' + RTrim(Replace(@DescMask, ' ', '')) + '%'')'
 
 	If	(@BankCode > 0)
		SET @StrWhereP = @StrWhereP + ' AND ' + pub.funGetFilterString(@SessionNo, @ReportID, @BankCode, 'H.OurBankCode')
	If	(@BankCode > 0)
		SET @StrWhereP = @StrWhereP + ' AND ' + pub.funGetFilterString(@SessionNo, @ReportID, @BankCode, 'H.OurBankCode')
	
	Set @StrSelect2 = ' 	union all 
	SELECT	B.BankCode, B.BankName,
			D.ProcessID, D.ProcessNo, D.FiscalYear, D.SerialNo, D.RowNo, H.DocDate, '''' PayTypeID, H.OurBankCode DebitCode, D.CostAcntCode CreditCode, D.CostAmount, 
			D.CurrencyTypeID, D.CurrencyRate, 0 ChequeNo, 0 ChequeBookFiscalYear, 0 ChequeBookID, '''' ChequeDate, 0 VolumeFiscalYear, 0 VolumeRowNo, 0 EventNo, 
			'''' LocationID, BB.BankTypeID, BB.BranchCode, B.BranchName, 0 BankSnNo, '''' AccountNo, '''' AccOwnerName, '''' LocationID2, '''' BankTypeID2, '''' BranchCode2, 
			'''' BranchName2, '''' AccountNo2, '''' AccOwnerName2, '''' DeliverTo, D.DescDtl, D.DocRowNo, 0 IsConfirmed, '''' AccountOwnerType, 0 BaseSerialNo, 0 BaseFiscalYear, 
			'''' WithdrawType, D.CurrencyAmount, '''' VisitorAcntCode, '''' EndDate_PayableTrust, D.SourceSerialNo, D.SourceProcessNo, '''' WithAcntCode, 0 ID,
			H.OurBankCode DebitCodeH, D.CostAcntCode CreditCodeH, H.VchNo, H.DescHdr, 
			pub.GetCodeName(H.OurBankCode, '  + @LangID + ') DebitNameAH,
			pub.GetBankName(H.OurBankCode, '  + @LangID + ') DebitNameBH,
			pub.GetCodeName(H.OurBankCode, ' + @LangID + ') CreditNameAH,
			pub.GetBankName(H.OurBankCode, ' + @LangID + ') CreditNameBH,
			pub.GetCodeName(D.CostAcntCode, '  + @LangID + ') DebitNameA,
			pub.GetBankName(D.CostAcntCode, '  + @LangID + ') DebitNameB,
			pub.GetCodeName(D.CostAcntCode, ' + @LangID + ') CreditNameA,
			pub.GetBankName(D.CostAcntCode, ' + @LangID + ') CreditNameB,
			pub.GetUserName(0) AS UserName, '''' LocationName,
			pub.funGetBankTypeName(BB.BankTypeID, ' + @LangID + ') DebitBankTypeName,
			pub.funGetBankTypeName(BB.BankTypeID, ' + @LangID + ') CreditBankTypeName,
			'''' PayTypeName, P.ProcessName, 0 As CDType, R.DebitRemain1, R.DebitRemain2, R.DebitRemain3,
			cast(case when (1=1) then 1 else 0 end as bit) as RemainAffect
			,cast(Substring(D.CostAcntCode,' + LTrim(Str(@Part1Start)) + ',' + LTrim(Str(@Part1Len)) + ')  as varchar(20) ) AcntCode1
			,cast(Substring(D.CostAcntCode,' + LTrim(Str(@Part2Start)) + ',' + LTrim(Str(@Part2Len)) + ') as varchar(20) ) AcntCode2
			,cast(Substring(D.CostAcntCode,' + LTrim(Str(@Part3Start)) + ',' + LTrim(Str(@Part3Len)) + ') as varchar(20) ) AcntCode3
			,cast(Substring(D.CostAcntCode,' + LTrim(Str(@Part4Start)) + ',' + LTrim(Str(@Part4Len)) + ') as varchar(20) ) AcntCode4
			,cast(acc.funGetAcntName(	Substring(D.CostAcntCode,' + LTrim(Str(@Part1Start)) + ',' + LTrim(Str(@Part1Len)) + ') ,	1,	' + LTrim(RTrim(@LangID)) + ' ) as nvarchar(50) )AcntCodeName1
			,cast(acc.funGetAcntName(	Substring(D.CostAcntCode,' + LTrim(Str(@Part2Start)) + ',' + LTrim(Str(@Part2Len)) + ') ,	2,	' + LTrim(RTrim(@LangID)) + ' ) as nvarchar(50) )AcntCodeName2
			,cast(acc.funGetAcntName(	Substring(D.CostAcntCode,' + LTrim(Str(@Part3Start)) + ',' + LTrim(Str(@Part3Len)) + ') ,	3,	' + LTrim(RTrim(@LangID)) + ' ) as nvarchar(50) )AcntCodeName3
			,cast(acc.funGetAcntName(	Substring(D.CostAcntCode,' + LTrim(Str(@Part4Start)) + ',' + LTrim(Str(@Part4Len)) + ') ,	4,	' + LTrim(RTrim(@LangID)) + ' ) as nvarchar(50) )AcntCodeName4
				
	FROM	trs.tblPettyCashDtl D
				inner join trs.tblPettyCashHdr	H ON D.ProcessID=H.ProcessID AND D.ProcessNo=H.ProcessNo AND D.FiscalYear=H.FiscalYear AND D.SerialNo=H.SerialNo
				left  join pub.tblProcess		P on P.ProcessID=D.ProcessID and P.ProcessNo=D.ProcessNo
				inner join trs.tblOurBanksDtl	B on B.BankCode=H.OurBankCode
				inner join trs.tblOurBanks		BB on BB.BankCode=H.OurBankCode
				INNER JOIN #tbl_Remains			R on R.BankAcntCode=B.BankCode'

				IF (@UserIDEx <> '' and @UserIDEx <> '-1')
		SET @StrSelect2 = @StrSelect2 + ' INNER JOIN (Select * From #tblSessionNo) U ON ' + @StrWhereSession

	SET @StrSelect2 = @StrSelect2 +' WHERE	' + @StrWhereP +' '
end 

	Print @StrSelect;
	Print @StrSelect1;
	Print @StrSelect2;
	Set @StrSelect=@StrSelect+@StrSelect1+@StrSelect2;

	Set @StrSelect ='	select * from	('+	@StrSelect + ' ) X	where ' + @StrWhere + '	ORDER BY X.BankCode, X.DocDate, X.SerialNo, X.DocRowNo '
	
	Exec sp_executesql @StrSelect;

END
GO
