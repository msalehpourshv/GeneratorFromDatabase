USE TS_ShirinVatanKarkhaneh_1_1404
GO
SET ANSI_NULLS, QUOTED_IDENTIFIER ON
GO
-- =========== TS-QC:UPDATED ====================
-- Author		 : TakroSystem\Zia
-- Create date   : 1389/05/25
-- Viewed By	 : 
-- Last Modified : 1393/04/11
-- Last Modifier : TakroSystem\Hamid
-- Description   : 
-- =================================================================
Create PROCEDURE [pub].[RptCustomerCreditInfo2]
	@AcntCode1	int = 0,
	@AcntCode2	int = 0,
	@AcntCode3	int = 0,
	@AcntCode4	int = 0,
	@RepOptions	NVarChar(200) = '111',
	@RepInfo	NVarChar(100) = '1@1@1' -- bit array options
WITH ENCRYPTION
AS
DECLARE @StrSelect	NVarChar(2000)
DECLARE @StrFrom	NVarChar(2000)
DECLARE @StrWhere	NVarChar(2000)

DECLARE	@LangID		Char(1);
DECLARE	@SessionNo	Int;
DECLARE	@ReportID	Int;

DECLARE	@PrevYear	char(4);
DECLARE	@PrevDB	varchar(40);
DECLARE	@AcntCode	varchar(20);
BEGIN
	SET NOCOUNT ON;

	-- I N I T ------------------------------------------------------------
	IF (@RepInfo		Is Null)	SET @RepInfo = '1@1@1';
	IF (@RepOptions		Is Null)	SET @RepOptions = '1'

	if (@AcntCode1 Is Null)		set @AcntCode1 = 0;
	if (@AcntCode2 Is Null)		set @AcntCode2 = 0;
	if (@AcntCode3 Is Null)		set @AcntCode3 = 0;
	if (@AcntCode4 Is Null)		set @AcntCode4 = 0;

	SET @LangID		= pub.funSplitString(@RepInfo, '@', 1);
	SET @SessionNo	= pub.funSplitString(@RepInfo, '@', 2);
	SET @ReportID	= pub.funSplitString(@RepInfo, '@', 3);

	select @PrevYear= substring(db_name(),len(db_name()) - 3, 4) - 1;
	select @PrevDB	= substring(db_name(),1,len(db_name()) - 4) + ltrim(str(@PrevYear))

	begin try
		drop table #tblResult2
	end try
	begin catch
	end catch

	create table #tblResult2
	(
		AcntCode			varchar(20) collate arabic_cs_as,
		RemainFr			float,
		Purchase			float,
		CheqPaid			float,
		CheqRcpt			float,
		CheqCurr			float,
		CheqRetr			float,
		CashBill			float,
		SalePric			float,
		SaleRetr			float,
		SaleRetP			float,
		SaleDisc			float,
		SaleInvc			float,
		IvcAvgFn			char(10) null,
		IvcAvgRe			char(10) null,
		RecAvgFn			char(10) null,
		RemainTo			float,
		Customer			nvarchar(100) null,
		Comapny				nvarchar(100) null,
		City1				nvarchar(100) null,
		City2				nvarchar(100) null,
		City3				nvarchar(100) null,
		City4				nvarchar(100) null,
		Address				nvarchar(200) null,
		Tel					nvarchar(100) null,
		Mobile				nvarchar(100) null,
		Fax					nvarchar(100) null,
		Email				nvarchar(100) null,
		VisitorName			nvarchar(100) null,
		YearNo				int null,
		MaxDebitRemain		float,
		MaxReceivableRemain	float,
		ComplementCredit	float,
		AccountRemain		float,
		ManagerView         varchar(500) ,
		VisitorView         varchar(500) 			
	)
	------------------------------------------------------------------------

	insert into #tblResult2(AcntCode,RemainFr,Purchase,CheqPaid,CheqRcpt,CheqCurr,CheqRetr,CashBill,SalePric,
							SaleRetr,SaleRetP,SaleDisc,SaleInvc,IvcAvgFn,IvcAvgRe,RecAvgFn,RemainTo,
							MaxDebitRemain,MaxReceivableRemain,ComplementCredit,AccountRemain,ManagerView,VisitorView)
	exec [pub].[RptCustomerCreditInfo] @AcntCode1, @AcntCode2, @AcntCode3, @AcntCode4, @RepOptions, @RepInfo

	update #tblResult2
	set YearNo = substring(db_name(),len(db_name()) - 3, 4)

	begin try
		set @StrSelect = '
		delete from [' + @PrevDB + '].rpt.tblFilters
		where (SessionNo = ' + LTrim(Str(@SessionNo)) + ') and (ReportID = ' + LTrim(Str(@ReportID)) + ')
		
		insert into [' + @PrevDB + '].rpt.tblFilters
		select *
		from rpt.tblFilters
		where (SessionNo = ' + LTrim(Str(@SessionNo)) + ') and (ReportID = ' + LTrim(Str(@ReportID)) + ')
			
		insert into #tblResult2 (AcntCode,RemainFr,Purchase,CheqPaid,CheqRcpt,CheqCurr,CheqRetr,CashBill,SalePric,
		                         SaleRetr,SaleRetP,SaleDisc,SaleInvc,IvcAvgFn,IvcAvgRe,RecAvgFn,RemainTo,
		                         MaxDebitRemain,MaxReceivableRemain,ComplementCredit,AccountRemain,ManagerView,VisitorView)
		exec [' + @PrevDB + '].[pub].[RptCustomerCreditInfo] ' + LTrim(Str(@AcntCode1)) + ', ' + LTrim(Str(@AcntCode2)) + ', ' + LTrim(Str(@AcntCode3)) + ', ' + LTrim(Str(@AcntCode4)) + ', ''' + @RepOptions + ''', ''' + @RepInfo + ''' '
	
		print @StrSelect;
		exec sp_executesql @StrSelect

		update #tblResult2
		set YearNo = substring(db_name(),len(db_name()) - 3, 4) - 1
		where YearNo is null
	end try
	begin catch
		print ERROR_MESSAGE() 
	end catch
	------------------------------------------------------------------------
	declare crs_Result cursor for 
		select AcntCode
		from #tblResult2
	open crs_Result 

	fetch next from crs_Result into @AcntCode

	while (@@fetch_status = 0)
	begin
		update #tblResult2
		set Customer = F.AcntName, Comapny = F.OrganzationName, Address = F.Address1, Tel = F.Tel, Mobile = F.Mobile, Fax = F.Fax, Email = F.Email, City1 = L.LocationName
		from acc.funGetCodeInfo(@AcntCode) AS F 
				left join pub.tblLocationsDtl L on F.LocationID = L.LocationID
		where (#tblResult2.AcntCode = @AcntCode)
		
		fetch next from crs_Result into @AcntCode
	end

	close crs_Result;
	deallocate crs_Result;

	update #tblResult2
	set VisitorName = pub.GetCodeName(
		isnull(	(select top 1 VisitorAcntCode
				from sal.tblVisitorsCustomersDtl
				where CustomerAcntCode = #tblResult2.AcntCode
				order by RowNo desc) , '') , 1)
	------------------------------------------------------------------------
	SELECT     a.AcntCode, a.RemainFr, a.Purchase, a.CheqPaid, a.CheqRcpt, a.CheqCurr, a.CheqRetr, a.CashBill, a.SalePric, a.SaleRetr, a.SaleRetP, a.SaleDisc, a.SaleInvc, 
                      a.IvcAvgFn, a.IvcAvgRe, a.RecAvgFn, a.RemainTo, a.Customer, a.Comapny, a.City1, a.City2, a.City3, a.City4, a.Address, a.Tel, a.Mobile, a.Fax, a.Email, a.VisitorName, 
                      a.YearNo, a.MaxDebitRemain, a.MaxReceivableRemain, a.ComplementCredit, a.AccountRemain, a.ManagerView, a.VisitorView,  b.PartNumber, 
                      b.CodeClosed, b.AcntType, b.AcntState, b.AcntMsgForce, b.Acnt2Force, b.Acnt3Force, b.Acnt4Force, b.LocationID,  b.OtherTels, 
                      b.ZipCode, b.EconomicalCode,   b.MaxDaysAfterExpiration, b.RecID, b.SessionNo, b.PersonnelNo, 
                      b.IDNo, b.InitialGrad, b.CompanyRegisterNo,  b.NationalIDNumber, b.MaxReturnCheque, b.MemberCode, b.MemberDate,  
                      b.InternetAddress, b.CustomerKindID, b.Sequence, b.FatherName, b.OwnershipType, b.ReagentName, b.SMSMobile, b.AccountNumber, b.ShabaAccountNumber, 
                      b.IsCurrency, b.CompleteDate, b.PersonType, b.Zone, b.PossessionType, b.SalesRoomSituation, b.SalesRoomClass, b.PortalCount, b.GPSPoint, b.BirthDate, 
                      b.VisitPathID1, b.VisitPathID2, b.VisitPathID3, b.VisitPathID4, b.ParticularDate1, b.ParticularDate2, b.ParticularDate3, b.ParticularDate4, b.BankAcountNo, b.ShabaNo, 
                      b.TransporterID, b.NationalIdentity, b.FineExemption, b.FineDelayPercent, b.SaleCustomerType, b.BuyCustomerType,  b.MinSalePrice, 
                      b.MaxSalePrice, b.FreeDocDays, b.OutStandChequeCount, b.OutStandChequePrice, b.ReturnChequeCount, b.OpenAccInvoiceCount, b.CampaignID, b.VerifyCode, 
                      b.SaleTypeID, b.SaleCash, b.ContainTax, b.Gender, b.MaxReturnChequeDays
FROM      #tblResult2  AS a Left JOIN
                      acc.tblAcnt AS b ON SUBSTRING(a.AcntCode, acc.FunGetAcntInfoForRemain(2), acc.FunGetAcntInfoForRemain(3)) = b.AcntCode
					  and b.PartNumber=acc.FunGetAcntInfoForRemain(1)


	order by a.AcntCode, a.YearNo 
END
GO
