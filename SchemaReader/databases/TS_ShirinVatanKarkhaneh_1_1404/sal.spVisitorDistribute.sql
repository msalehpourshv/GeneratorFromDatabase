USE TS_ShirinVatanKarkhaneh_1_1404
GO
SET ANSI_NULLS, QUOTED_IDENTIFIER ON
GO

-- =========== TS-QC:UPDATED ====================
-- Author		 : TakroSystem\Jafari
-- Create date   : 1396/11/21
-- Viewed By	 : 
-- Last Modified : 
-- Last Modifier : 
-- Description   :
-- =================================================================
Create PROCEDURE [sal].[spVisitorDistribute]
	@ExtraParams		NVarChar(Max) = ''
WITH ENCRYPTION
AS
DECLARE @StrSelect	NVarChar(Max)
--DECLARE @StrFrom	NVarChar(2000)
--DECLARE @StrWhere	NVarChar(2000)
--DECLARE 
--@AcntCode1	varchar(20),
--@AcntCode2	varchar(20),
--@AcntCode3	varchar(20),
--@AcntCode4	varchar(20)
	
DECLARE	@LangID		Char(1);
--DECLARE	@SessionNo	Int;
--DECLARE	@ReportID	Int;
DECLARE	@RemainTo	float;
--DECLARE	@RemainVar	float;
DECLARE	@ord		int;
DECLARE	@LayerLen	int;
DECLARE	@StartLayer	int;
DECLARE	@AcntPartNumber	int;
DECLARE	@prc		float;
DECLARE	@dat		char(10);

DECLARE	@Today	char(10);

BEGIN

SET NOCOUNT ON;


DECLARE	@SerialNo	Int ;
Declare @PartNumber	TINYINT;

	
SET @SerialNo			   = LTrim(pub.funSplitString(@ExtraParams, '@', 1)); 
SET @LangID			       = LTrim(pub.funSplitString(@ExtraParams, '@',2));
select @PartNumber = SettingValue From pub.tblSettings Where SettingKey='AcntPartNumberForRemainCalculation'


 
SELECT F.SerialNo, F.RowNo, F.DocRowNo, F.DocDate, F.SessionNo, F.CustomerAcntCode, AD.AcntCode, AD.LanguageID, AD.PartNumber,  
                      AD.AcntComment, AD.FirstName, AD.LastName, AD.OrganzationName, AD.Address1, AD.Address2, AD.GradDesc, AD.DistributionPoint, AD.AsnafID, AD.TableauText, 
                      AD.SensiblePoint, AD.PlaceOldName, AD.CustomerFamous, AD.ParticularDateText1, AD.ParticularDateText2, AD.ParticularDateText3, AD.ParticularDateText4, 
                      AD.ManagerView, AD.VisitorView, A.CodeClosed, A.AcntType, A.AcntState, A.AcntMsgForce, A.Acnt2Force, A.Acnt3Force,
                       A.Acnt4Force, A.LocationID, A.Tel, A.Fax, A.OtherTels, A.ZipCode, A.EconomicalCode, A.MaxDebitRemain, A.MaxReceivableRemain, A.MaxDaysAfterExpiration, 
                      A.RecID,  A.PersonnelNo, A.IDNo, A.InitialGrad, A.CompanyRegisterNo, A.Mobile, A.NationalIDNumber, A.MaxReturnCheque, A.MemberCode, 
                      A.MemberDate, A.Email, A.InternetAddress, A.CustomerKindID, A.Sequence, A.FatherName, A.OwnershipType, A.ReagentName, A.SMSMobile, A.AccountNumber, 
                      A.ShabaAccountNumber, A.IsCurrency, A.CompleteDate, A.PersonType, A.Zone, A.PossessionType, A.SalesRoomSituation, A.SalesRoomClass, A.PortalCount, 
                      A.GPSPoint, A.BirthDate, A.VisitPathID1, A.VisitPathID2, A.VisitPathID3, A.VisitPathID4, A.ParticularDate1, A.ParticularDate2, A.ParticularDate3, A.ParticularDate4, 
                      A.BankAcountNo, A.ShabaNo, A.TransporterID, A.NationalIdentity, A.FineExemption, A.FineDelayPercent, A.SaleCustomerType, A.BuyCustomerType, 
                      A.ComplementCredit, A.MinSalePrice, A.MaxSalePrice, A.FreeDocDays, A.OutStandChequeCount, A.OutStandChequePrice, A.ReturnChequeCount, 
                      A.OpenAccInvoiceCount, A.CampaignID, A.VerifyCode, A.SaleTypeID, A.SaleCash, A.ContainTax, A.Gender, A.MaxReturnChequeDays, ISNULL(A.Tel, ' - ') 
                      + ' - ' + ISNULL(A.Mobile, ' - ') AS TelMobile, acc.funGetAcntName(F.CustomerAcntCode, 1, 1) AS AcntName
	,F.DocDate IvcAvgRe				,
	A.MaxDebitRemain RemainTo				
into #tblSelect
FROM sal.tblVisitorDistributeDtl F
 Left Join acc.tblAcntDtl AD ON AD.AcntCode = F.CustomerAcntCode   
 LEFT OUTER JOIN acc.tblAcnt AS A ON A.AcntCode = F.CustomerAcntCode
 WHERE 1=0
 ORDER BY DocRowNo
  

--select @PartNumber,@LangID,@SerialNo
set @StrSelect='
insert into   #tblSelect
SELECT F.SerialNo, F.RowNo, F.DocRowNo, F.DocDate, F.SessionNo, F.CustomerAcntCode, AD.AcntCode, AD.LanguageID, AD.PartNumber,  
AD.AcntComment, AD.FirstName, AD.LastName, AD.OrganzationName, AD.Address1, AD.Address2, AD.GradDesc, AD.DistributionPoint, AD.AsnafID, AD.TableauText, 
AD.SensiblePoint, AD.PlaceOldName, AD.CustomerFamous, AD.ParticularDateText1, AD.ParticularDateText2, AD.ParticularDateText3, AD.ParticularDateText4, 
AD.ManagerView, AD.VisitorView, A.CodeClosed, A.AcntType, A.AcntState, A.AcntMsgForce, A.Acnt2Force, A.Acnt3Force,
A.Acnt4Force, A.LocationID, A.Tel, A.Fax, A.OtherTels, A.ZipCode, A.EconomicalCode, A.MaxDebitRemain, A.MaxReceivableRemain, A.MaxDaysAfterExpiration, 
A.RecID,  A.PersonnelNo, A.IDNo, A.InitialGrad, A.CompanyRegisterNo, A.Mobile, A.NationalIDNumber, A.MaxReturnCheque, A.MemberCode, 
A.MemberDate, A.Email, A.InternetAddress, A.CustomerKindID, A.Sequence, A.FatherName, A.OwnershipType, A.ReagentName, A.SMSMobile, A.AccountNumber, 
A.ShabaAccountNumber, A.IsCurrency, A.CompleteDate, A.PersonType, A.Zone, A.PossessionType, A.SalesRoomSituation, A.SalesRoomClass, A.PortalCount, 
A.GPSPoint, A.BirthDate, A.VisitPathID1, A.VisitPathID2, A.VisitPathID3, A.VisitPathID4, A.ParticularDate1, A.ParticularDate2, A.ParticularDate3, A.ParticularDate4, 
A.BankAcountNo, A.ShabaNo, A.TransporterID, A.NationalIdentity, A.FineExemption, A.FineDelayPercent, A.SaleCustomerType, A.BuyCustomerType, 
A.ComplementCredit, A.MinSalePrice, A.MaxSalePrice, A.FreeDocDays, A.OutStandChequeCount, A.OutStandChequePrice, A.ReturnChequeCount, 
A.OpenAccInvoiceCount, A.CampaignID, A.VerifyCode, A.SaleTypeID, A.SaleCash, A.ContainTax, A.Gender, A.MaxReturnChequeDays
, ISNULL(A.Tel,'' - '') + '' - '' + ISNULL(A.Mobile,'' - '') as TelMobile
, acc.funGetAcntName(F.CustomerAcntCode,'+str(@PartNumber)+','+str(@LangID)+' ) As AcntName 
,'''' IvcAvgRe
, 0 RemainTo	
FROM sal.tblVisitorDistributeDtl F
 Left Join acc.tblAcntDtl AD ON AD.AcntCode = F.CustomerAcntCode   
 LEFT OUTER JOIN acc.tblAcnt AS A ON A.AcntCode = F.CustomerAcntCode
  WHERE F.SerialNo='+str(@SerialNo)+' ORDER BY DocRowNo'

print @StrSelect;
	exec sp_executesql @StrSelect;
	

--select * from #tblSelect

	SELECT @AcntPartNumber = SettingValue
	FROM pub.tblSettings
	WHERE SettingKey = 'AcntPartNumberForRemainCalculation'


 select @StartLayer=  [acc].[FunGetAcntInfoForRemain](2)
 select @LayerLen	= [acc].[FunGetAcntInfoForRemain](3)
		
--select @StartLayer	 ,@LayerLen


	create table #tblAcnt1
	(
		AcntCode	varchar(20) collate arabic_cs_as
	);
	
	---- enlist acnt codes -------------
	--set @StrWhere = '(AcntCode <> '''')';
	--set @StrWhere = @StrWhere + ' AND substring (D.AcntCode,'+ str(@StartLayer)+', ' + STR (@LayerLen) + ')='''+ @AcntCode1 +''''
	
	
	--select  @AcntCode1,@AcntCode2,@AcntCode3,@AcntCode4
	
	set @StrSelect = 
		' INSERT INTO #tblAcnt1 
		 SELECT DISTINCT D.AcntCode 
		 FROM acc.tblVoucherDtl D inner join #tblSelect t
		 on  substring (D.AcntCode,'+ str(@StartLayer)+', ' + STR (@LayerLen) + ')=t.AcntCode'
		 
	print @StrSelect;
	exec sp_executesql @StrSelect;
	
	
		create table #tblResult1
	(
		AcntCode				varchar(20) collate arabic_cs_as,
		IvcAvgRe				char(10) null,
		RemainTo				float,
	);


		-----------------------------------
		
	Insert Into #tblResult1
	Select AcntCode, '', 0
	From #tblAcnt1


	
	-- Remain To
	update #tblResult1
	set RemainTo = 
	(
		select IsNull(Sum(Debit-Credit), 0)
		from acc.tblVoucherDtl D
		where AcntCode = #tblResult1.AcntCode and (D.VchKind <> 3) and (D.VchKind <> 4) -- finish docs
	)
	
	
	
	-------------------------------------------------
	declare @sumPrc float
	declare @sumDay bigint
	DECLARE @AcntCode    varchar(20) 
	SELECT @Today	= left(pub.funFarsiDate(GetDate()), 10);

	set @sumDay = 0
	set @sumPrc = 0
	
	declare csr_rem cursor for
		select AcntCode, RemainTo
		from #tblResult1
		where (RemainTo > 0)
		
	open csr_rem 
	fetch next from csr_rem into @AcntCode, @RemainTo
	
	while (@@FETCH_STATUS = 0)
	begin
		declare csr_ivc cursor for
			select  ROW_NUMBER() over (order by H.DocDate, H.SerialNo) row,
					H.DocDate, H.SidePriceSum+(
						select sum(D.GoodsQuantity*D.GoodsPrice) 
						from inv.tblStorageDocsDtl D 
						where D.ProcessID=H.ProcessID and D.ProcessNo=H.ProcessNo and D.FiscalYear=H.FiscalYear and D.SerialNo=H.SerialNo
					) PriceDtl
			from inv.vwStorageDocsHdr H
			where (H.ProcessID=90) and (H.AcntCode=@AcntCode)
			order by 1 desc
		
		open csr_ivc 
		fetch next from csr_ivc into @ord, @dat, @prc
		
		while (@@FETCH_STATUS = 0)
		begin
			if (@RemainTo <= 0) break;
			
			set @sumPrc = @sumPrc + @prc
			set @sumDay = @sumDay + @prc*(pub.funFarsiDateDiff('Day', @Today, @dat))

			set @RemainTo = @RemainTo - @prc
			fetch next from csr_ivc into @ord, @dat, @prc
		end;

		close csr_ivc  
		deallocate csr_ivc 

		if (@sumPrc > 0)
		begin
			update #tblResult1
			set IvcAvgRe = pub.funFarsiDateAddDays('Day', @Today, round(@sumDay/@sumPrc, 0))
			where AcntCode = @AcntCode
		end
				
		fetch next from csr_rem into @AcntCode, @RemainTo
	end

	close csr_rem 
	deallocate csr_rem 
	
	
	
	update #tblSelect
	set RemainTo = isnull(b.RemainTo  ,0)
	,IvcAvgRe = isnull(b.IvcAvgRe ,'')
	
	from #tblSelect a inner join #tblResult1 b 
	on substring (b.AcntCode,@StartLayer,@LayerLen)=a.AcntCode 
	
	

	
	--update #tblSelect
	--set IvcAvgRe = 
	--(
	--	select IsNull(IvcAvgRe, '')
	--	from #tblResult1 D
	--	where substring (D.AcntCode,@StartLayer,@LayerLen)=#tblSelect.AcntCode 
	--)
	
	
	
	
--	select IsNull(IvcAvgRe, '') 		from #tblResult1 D
	
	--select * from #tblResult1
	select * from #tblSelect order by DocRowNo
	
	
	END
GO
