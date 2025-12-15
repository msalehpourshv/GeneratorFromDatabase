USE TS_ShirinVatanKarkhaneh_1_1404
GO
SET ANSI_NULLS, QUOTED_IDENTIFIER ON
GO
-- =========== TS-QC:UPDATED ====================
-- Author		 : TakroSystem\Ahmadnejad
-- Create date   : 1386/02/30
-- Viewed By	 : 
-- Last Modified : 1393/02/29
-- Description	 : <PayReceipt Documents Report>
-- ----------------------------------------------
-- گزارش برگ دریافت و پرداخت
-- ==============================================
Create PROCEDURE [trs].[RptPayReceiptDoc]
	@ProcessID		Int = 1,
	@ProcessNo		Int = 1,
	@FiscalYear		Int = 1,
	@SerialNo		Int = 1,
	@FiscalYearTo	Int = 100,
	@SerialNoTo		Int = 100,
	@IncludeImage	Bit = 1, -- شامل تصویر سند باشد یا نه؟
	@LanguageID		Int = 1
	
WITH ENCRYPTION
As

DECLARE @StrSelect			NVarChar(4000);
DECLARE @StrFrom			NVarChar(4000);
DECLARE @StrWhere			NVarChar(4000);
DECLARE @StrImage			NVarChar(400);
DECLARE @LangID				Char(1);
DECLARE @db_0000			nvarchar(50)
DECLARE @UserName			NVarChar(4000)
DECLARE @UserFullName		NVarChar(4000)
DECLARE @CompanyName		NVarChar(4000)
DECLARE @NationalCode		NVarChar(4000)
DECLARE @NationalIdentity	NVarChar(4000)
DECLARE @Tel				NVarChar(4000)
DECLARE @Address			NVarChar(4000)
DECLARE @ZipCode			NVarChar(4000)
Declare @ExtraParams		NVarChar(Max)
DECLARE	@SessionNo			Int; 
DECLARE	@ReportID			Int;
DECLARE	@UserID				Int;
DECLARE	@UserIsAdmin		bit;

BEGIN  
	SET NOCOUNT ON;

	-- init -------------------------------------------------------
	if (@SerialNoTo Is Null)	set @SerialNoTo = @SerialNo;
	if (@FiscalYearTo Is Null)	set @FiscalYearTo = @FiscalYear;

	set @LangID = LTrim(Str(@LanguageID))
	set @db_0000 = Substring(db_name(), 1, Len(db_name()) - 4) + '0000'
	
	SET @UserName = ''
	SELECT @UserName = SettingValue
	FROM pub.tblSettings
	WHERE SettingKey = 'Pub_CurrentUserName'	
	
	SELECT @CompanyName = SettingValue	FROM pub.tblSettings WHERE SettingKey = 'CompanyCompanyName'	
	SELECT @NationalCode = SettingValue	FROM pub.tblSettings WHERE SettingKey = 'CompanyNationalCode'	
	SELECT @NationalIdentity = SettingValue	FROM pub.tblSettings WHERE SettingKey = 'CompanyNationalIdentity'	
	SELECT @Tel = SettingValue	FROM pub.tblSettings WHERE SettingKey = 'CompanyTel'	
	SELECT @Address = SettingValue	FROM pub.tblSettings WHERE SettingKey = 'CompanyAddress'	
	SELECT @ZipCode = SettingValue	FROM pub.tblSettings WHERE SettingKey = 'CompanyZipCode'	

	SELECT    @ExtraParams= Params FROM         rpt.tblRptParams where SessionNo=@LanguageID

	set @LanguageID=1			
	SET @LangID			= pub.funSplitString(@ExtraParams, '@', 1);
	SET @SessionNo		= pub.funSplitString(@ExtraParams, '@', 2);
	SET @ReportID		= pub.funSplitString(@ExtraParams, '@', 3);
	SET @UserID			= pub.funSplitString(@ExtraParams, '@', 4);
	SET @UserIsAdmin	= pub.funSplitString(@ExtraParams, '@', 5);

	---------------------------------------------------------------
	-- select -----------------------------------------------------
	Create Table #tbl_PayRecDoc_SNO
	(
		SNO	int
	)
	Create Table #tbl_PayRecDoc_Signatures
	(
		SessionNo	int,
		UserSign	image
	);
	
	insert into #tbl_PayRecDoc_SNO
	select SessionNo
	from trs.tblPayHdr D
	where	(D.ProcessID = @ProcessID) AND (D.ProcessNo = @ProcessNo) AND (D.FiscalYear >= @FiscalYear) AND (D.SerialNo >= @SerialNo) AND (D.FiscalYear <= @FiscalYearTo) AND (D.SerialNo <= @SerialNoTo)
	union
	select SessionNo1
	from trs.tblPayHdr D
	where	(D.ProcessID = @ProcessID) AND (D.ProcessNo = @ProcessNo) AND (D.FiscalYear >= @FiscalYear) AND (D.SerialNo >= @SerialNo) AND (D.FiscalYear <= @FiscalYearTo) AND (D.SerialNo <= @SerialNoTo)
	union
	select SessionNo2
	from trs.tblPayHdr D
	where	(D.ProcessID = @ProcessID) AND (D.ProcessNo = @ProcessNo) AND (D.FiscalYear >= @FiscalYear) AND (D.SerialNo >= @SerialNo) AND (D.FiscalYear <= @FiscalYearTo) AND (D.SerialNo <= @SerialNoTo)
	union
	select SessionNo3
	from trs.tblPayHdr D
	where	(D.ProcessID = @ProcessID) AND (D.ProcessNo = @ProcessNo) AND (D.FiscalYear >= @FiscalYear) AND (D.SerialNo >= @SerialNo) AND (D.FiscalYear <= @FiscalYearTo) AND (D.SerialNo <= @SerialNoTo)
	
	set @StrSelect = '
	Insert Into #tbl_PayRecDoc_Signatures(SessionNo, UserSign)
	Select SN.SessionNo, U.UserSignature
	From ' + ltrim(rtrim(@db_0000)) + '.usr.tblUsers U
	Inner Join ' + ltrim(rtrim(@db_0000)) + '.usr.tblSessions S on S.UserID = U.UserID
	Inner Join ' + ltrim(rtrim(@db_0000)) + '.usr.tblSessionNumbers SN on SN.SessionID = S.SessionID 
	Inner Join #tbl_PayRecDoc_SNO T on T.SNO = SN.SessionNo '
	
	print @StrSelect;
	exec sp_executesql @StrSelect;

	if (@IncludeImage = 0)
	begin
		set @StrImage = 'Cast(Null AS Image)'
	end
	else
		set @StrImage = 'DI.ImageContent';

	begin try
		drop table ##tbl
		drop table ##tb2
	end try
	begin catch
	end catch
	
	select @LangID=isnull(@LangID,1)

	set @StrSelect = '
	SELECT T.*, T.Amount * T.DateDuration AS AmountDuration  
	INTO  ##tbl
	FROM
	(
		SELECT	Case when PD.ProcessID in (1,3,10,31) then PD.DebitCode else PD.CreditCode end BankCode ,PD.FiscalYear, PD.SerialNo, PD.DocRowNo, 
				PD.PayTypeID, PD.Amount, PD.RowDesc, cast ( PD.ChequeNo as Varchar) ChequeNo,PD.ChequeNoNew ,PD.NationalIDNumber ,
				TargetLocationID,[pub].[funGetLocationName] (TargetLocationID,1)TargetLocationName, TargetBankID,
				[pub].[funGetBankTypeName] (TargetBankID, 1) TargetBankName , TargetChequeNoNew,TargetCustomerName,
				PD.ChequeDate, PD.DocDate, ' + @StrImage + ' AS DocImage, PH.BehalfID, BH.BehalfName,
				PD.DebitCode, PD.CreditCode, PD.DebitCode AS DebitCodeHdr, PD.CreditCode AS CreditCodeHdr,
				PD.BranchCode, PD.BranchCode2, PD.BranchName, PD.BranchName2, PH.VisitorAcntCode,
				pub.GetCodeName(PH.VisitorAcntCode,' + @LangID + ') As VisitorAcntName,PD.CurrencyAmount,
				PD.AccountNo, PD.AccountNo2, PD.AccOwnerName, PD.AccOwnerName2, 
				PH.CollectorAcntCode,  PD.CurrencyTypeID, PD.CurrencyRate, PH.VchNo, PH.DescHdr, 
				LD.LocationName, PD.VolumeRowNo, CT.CurrencyTypeName,
				pub.GetCodeName(PD.DebitCode, ' + @LangID + ') AS DebitName, 
				pub.GetCodeName(PD.CreditCode, ' + @LangID + ') AS CreditName,
				pub.GetBankName(PD.DebitCode, ' + @LangID + ') DebitName2,
				pub.GetBankName(PD.CreditCode, ' + @LangID + ') CreditName2,
				acc.funGetAcntFullName(PD.DebitCode) AS DebitFullName, 
				acc.funGetAcntFullName(PD.CreditCode) AS CreditFullName,
				pub.funGetBankTypeName(PD.BankTypeID, ' + @LangID + ') AS DebitBankTypeName,
				pub.funGetBankTypeName(PD.BankTypeID2, ' + @LangID + ') AS CreditBankTypeName,
				pub.[GetUserName](PH.SessionNo) AS UserName,
				pub.[GetUserName](PH.SessionNo1) AS UserName1,
				pub.[GetUserName](PH.SessionNo2) AS UserName2,
				pub.[GetUserName](PH.SessionNo3) AS UserName3,
				(SELECT Count(*) 
				FROM trs.tblPayAtm A 
				WHERE A.ProcessID = PD.ProcessID 
				AND A.ProcessNo = PD.ProcessNo 
				AND A.FiscalYear = PD.FiscalYear 
				AND A.SerialNo = PD.SerialNo 
				AND A.DocRowNo = PD.DocRowNo) AS AtomCount,
				CASE WHEN (PD.ChequeDate <> '''') THEN pub.funFarsiDateDiff(''Day'', PH.DocDate, PD.ChequeDate)	ELSE 0 END AS DateDuration,
				S1.UserSign as UserSignature1,
				S2.UserSign as UserSignature2,
				S3.UserSign as UserSignature3,
				S4.UserSign as UserSignature4,PH.AcntDiscount, PH.DiscountAmount,pub.GetCodeName(PH.AcntDiscount, ' + @LangID + ') AS AcntDiscountName,
				[acc].[funAccountRemain](PD.DebitCode,PD.DocDate) as AccountRemain,
				PH.BaseProcessID, PH.BaseProcessNo, PH.BaseFiscalYear, PH.BaseSerialNo,ChequeCryptNo
		FROM	trs.tblPayDtl AS PD
				INNER JOIN trs.tblPayHdr PH ON PD.ProcessID = PH.ProcessID AND PD.ProcessNo = PH.ProcessNo AND PD.FiscalYear = PH.FiscalYear AND PD.SerialNo = PH.SerialNo
				LEFT  JOIN pub.tblLocationsDtl LD ON PD.LocationID = LD.LocationID AND	LD.LanguageID = ' + @LangID + '
				LEFT  JOIN pub.tblDocsImages DI ON PD.ProcessID = DI.ProcessID AND PD.ProcessNo = DI.ProcessNo AND PD.FiscalYear = DI.FiscalYear AND PD.SerialNo = DI.SerialNo AND PD.RowNo = DI.RowNo
				LEFT  JOIN pub.tblCurrencyTypesDtl CT ON CT.CurrencyTypeID = PD.CurrencyTypeID AND CT.LanguageID = ' + @LangID + '	
				LEFT  JOIN trs.tblBehalfDtl BH ON BH.BehalfID = PH.BehalfID AND BH.LanguageID = ' + @LangID + '	
				left join #tbl_PayRecDoc_Signatures S1 on S1.SessionNo = PH.SessionNo
				left join #tbl_PayRecDoc_Signatures S2 on S2.SessionNo = PH.SessionNo1
				left join #tbl_PayRecDoc_Signatures S3 on S3.SessionNo = PH.SessionNo2
				left join #tbl_PayRecDoc_Signatures S4 on S4.SessionNo = PH.SessionNo3
		WHERE	(PH.ProcessID = ' + LTrim(Str(@ProcessID)) + ') AND (PH.ProcessNo = ' + LTrim(Str(@ProcessNo)) + ') AND 
				(PD.FiscalYear >= ' + LTrim(Str(@FiscalYear)) + ') AND (PD.SerialNo >= ' + LTrim(Str(@SerialNo)) + ') AND
				(PD.FiscalYear <= ' + LTrim(Str(@FiscalYearTo)) + ') AND (PD.SerialNo <= ' + LTrim(Str(@SerialNoTo)) + ')
	) T '
	---------------------------------------------------------------
	-- run --------------------------------------------------------
	print @StrSelect;
	exec sp_executesql @StrSelect;
		---------------------------------------------------------------------------
		--  برای خالی کردن کدهایی که در سطر ثبت شده و متفاوت میباشد
		update ##tbl		set DebitCodeHdr=''
		where SerialNo in (select SerialNo  from  ##tbl Group by SerialNo Having count( distinct DebitCodeHdr)>1 )
		
		update ##tbl		set CreditCodeHdr=''
		where SerialNo in (	select SerialNo  from  ##tbl Group by SerialNo Having count( distinct CreditCodeHdr)>1 )
		---------------------------------------------------------------------------
		
	set @StrSelect = 'Select * Into ##tb2 From ##tbl'
	print @StrSelect;
		exec sp_executesql @StrSelect;		
	
	if @UserIsAdmin=0
	begin
		CREATE TABLE #tblAcntCode
		(
		AcntCode 			Varchar(20)collate arabic_cs_as null
		)	

		CREATE TABLE #tblSerialRowCount
		(
		SerialNo 			int,
		SerialRowCount 			int
		)

		if @ProcessID in (40)
		begin	
			Insert into  #tblAcntCode (AcntCode)				
			SELECT Distinct AcntCode2	FROM  ##tbl t1 
			inner join trs.tblOurBanks t2 on t1.CreditCode=t2.BankCode
			where t1.PayTypeID in (6,26)

			Insert into  #tblAcntCode (AcntCode)				
			SELECT Distinct AcntCode1	FROM  ##tbl t1 
			inner join trs.tblOurBanks t2 on t1.CreditCode=t2.BankCode
			where t1.PayTypeID in (1,2,30)
			
			Insert into  #tblAcntCode (AcntCode)				
			SELECT Distinct AcntCode2	FROM  ##tbl t1 
			inner join trs.tblOurBanks t2 on t1.DebitCode=t2.BankCode
			where t1.PayTypeID  in (6,26)

			Insert into  #tblAcntCode (AcntCode)				
			SELECT Distinct AcntCode1	FROM  ##tbl t1 
			inner join trs.tblOurBanks t2 on t1.DebitCode=t2.BankCode
			where t1.PayTypeID in (1,2,30)
		end 
		else if @ProcessID in (1,3,10,31)
			Insert into  #tblAcntCode (AcntCode)	SELECT Distinct CreditCode	FROM  ##tbl
		else
			Insert into  #tblAcntCode (AcntCode)	SELECT Distinct DebitCode	FROM  ##tbl

		Insert into  #tblSerialRowCount (SerialNo,SerialRowCount)	SELECT SerialNo, Count(*)	FROM  ##tbl group by SerialNo
		
		 exec pub.SpFilterByPermission2 '#tblAcntCode', 'AcntCode', 'acc.tblAcnt', @UserID;
		--حذف ردیف های سند که کاربر دسترسی ندارد
		if @ProcessID in (40)
		begin
				delete  from ##tbl 
				from 	##tbl  t1 
				inner join trs.tblOurBanks t2 on t1.CreditCode=t2.BankCode							
				where AcntCode2 not in ( select AcntCode from #tblAcntCode ) and t1.PayTypeID in (6,26)

				delete  from ##tbl 
				from 	##tbl  t1 
				inner join trs.tblOurBanks t2 on t1.CreditCode=t2.BankCode							
				where AcntCode1 not in ( select AcntCode from #tblAcntCode )  and t1.PayTypeID in (1,2,30)
				
				delete  from ##tbl 
				FROM  ##tbl t1 
				inner join trs.tblOurBanks t2 on t1.DebitCode=t2.BankCode
				where AcntCode2 not in ( select AcntCode from #tblAcntCode ) and t1.PayTypeID  in (6,26)

				delete  from ##tbl 
				FROM  ##tbl t1 
				inner join trs.tblOurBanks t2 on t1.DebitCode=t2.BankCode
				where AcntCode1 not in ( select AcntCode from #tblAcntCode ) and t1.PayTypeID in (1,2,30)
				
		end 
		else if @ProcessID in (1,3,10,31)
			delete  from ##tbl where CreditCode not in ( select AcntCode from #tblAcntCode )
		else
			delete  from ##tbl where DebitCode not in ( select AcntCode from #tblAcntCode )
					
		----حذف اسنادی که کاربری به تعدادی از ردیف های سند دسترسی ندارد
		delete  from ##tbl 
		from ##tbl a 
		inner join (SELECT SerialNo, Count(*)	 SerialRowCount FROM  ##tbl group by SerialNo )b 
		on a.SerialNo=b.SerialNo
		inner join #tblSerialRowCount c
		on b.SerialNo=c.SerialNo and b.SerialRowCount<c.SerialRowCount
	end
							
	set @StrSelect = 'SELECT  (
							SELECT	IsNull(Sum(Debit - Credit),0)
							FROM	acc.tblVoucherDtl M 
							INNER JOIN acc.tblVoucherHdr VH ON VH.SerialNo = M.SerialNo
							WHERE   M.VchKind <> 0 AND VH.DocRegisterState > 0 AND AcntCode = T1.CreditCode AND
								(M.DocDate <= T1.DocDate 
								AND Not (
										M.DocDate = T1.DocDate AND 
										M.SourceProcessID  IN(1) AND 
										M.SourceProcessNo  = ' + LTrim(Str(@ProcessNo)) + ' AND 
										M.SourceFiscalYear = T1.FiscalYear AND 
										M.SourceSerialNo   >= T1.SerialNo
									)
								)
		) Remain,T1.*, T2.SUMAmountDuration, T2.SUMAmount, T2.SUMCurrencyAmount, T2.AvrageDay,
							 ''' + @UserName + ''' PrintUserName, pub.funFarsiDate(GETDATE()) PrintDate
							 ,F.*,BH.*,BD.*,''' + isnull(@CompanyName,'') + ''' CompanyCompanyName,''' + isnull(@NationalCode,'') +''' CompanyNationalCode,
							 ''' + isnull(@NationalIdentity,'') +''' CompanyNationalIdentity,''' + isnull(@Tel,'')+''' CompanyTel,'''+isnull(@Address,'')+''' CompanyAddress,
							 '''+isnull(@ZipCode,'')+''' CompanyZipCode,BHD.BankAccountNo As DebitBankAccountNo
					  FROM ##tbl AS T1 
					  INNER JOIN (SELECT SUM(AmountDuration) AS SUMAmountDuration, 
										 SUM(Amount) AS SUMAmount, SUM(CurrencyAmount) AS SUMCurrencyAmount, 
										CEILING(SUM(AmountDuration)/SUM(Amount)) AS AvrageDay, FiscalYear, SerialNo
								  FROM ##tb2
								  GROUP BY FiscalYear, SerialNo) AS T2 ON T1.FiscalYear = T2.FiscalYear AND 
																	  T1.SerialNo = T2.SerialNo
						OUTER APPLY acc.funGetCodeInfo(T1.DebitCode) AS F
						LEFT JOIN trs.tblOurBanks AS BH ON BH.BankCode = T1.BankCode  
						LEFT JOIN trs.tblOurBanks AS BHD ON BHD.BankCode = T1.DebitCode  
						LEFT JOIN trs.tblOurBanksDtl AS BD ON BH.BankCode = BD.BankCode and BD.LanguageID='+ @LangID +' 
		ORDER BY T1.FiscalYear,T1.SerialNo,T1.DocRowNo
						 '
   	print @StrSelect;
	exec sp_executesql @StrSelect;
                            
END
GO
