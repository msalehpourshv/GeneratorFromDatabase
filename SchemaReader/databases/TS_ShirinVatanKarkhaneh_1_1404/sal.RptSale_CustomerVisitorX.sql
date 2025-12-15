USE TS_ShirinVatanKarkhaneh_1_1404
GO
SET ANSI_NULLS, QUOTED_IDENTIFIER ON
GO
-- =========== TS-QC:UPDATED ====================
-- Author		 : TakroSystem\Zia
-- Creation Date : 1391/02/05
-- Viewed By	 : 
-- Last Modified : 
-- Last Modifier : TakroSystem\Zia
-- Description   : مشتریان و ویزیتورها و مانده حساب
-- ==============================================
Create PROCEDURE [sal].[RptSale_CustomerVisitorX]
	@ProcessID		Int = 90,
	@ProcessNo		Int = 10,
	@SalDateFr		char(10) = Null,
	@SalDateTo		char(10) = Null,
	@RemDateTo		char(10) = Null,
	@SelectedAcnt1	Int = 0, 
	@SelectedAcnt2	Int = 0, 
	@SelectedAcnt3	Int = 0, 
	@SelectedAcnt4	Int = 0, 
	@SelectedVisitor1	Int = 0, 
	@SelectedVisitor2	Int = 0, 
	@SelectedVisitor3	Int = 0, 
	@SelectedVisitor4	Int = 0, 
	@RemainFr		float = -1,
	@RemainTo		float = -1,
	@RepOptions		VarChar(20) = '200', -- bit array options
	@SortFields		NVarChar(100) = Null,   -- Order By Field List
	@RepInfo		NVarChar(100) = '1@1@1' -- bit array options
WITH ENCRYPTION
AS 
---- Declarations ---------------
DECLARE @StrSelect	NVarChar(max);
--DECLARE @StrFrom	NVarChar(1000);
DECLARE @StrWhereS	NVarChar(max);
DECLARE @StrWhereA	NVarChar(max);
DECLARE @StrWhereP	NVarChar(max);
DECLARE @StrWhereX	NVarChar(max);
DECLARE @StrWhereR	NVarChar(max);
DECLARE @StrWhereI	NVarChar(max);

DECLARE @StrPrice	NVarChar(100);
declare	@RemainPart int;
declare	@AccRemain	bit;
declare	@ZeroRemain	bit;

DECLARE	@LangID		Char(1);
DECLARE	@SessionNo	Int; -- برای حالت کدهای انتخابی
DECLARE	@ReportID	Int; -- برای حالت کدهای انتخابی

DECLARE @Part1Start	Int;
DECLARE @Part2Start	Int;
DECLARE @Part3Start	Int;
DECLARE @Part4Start	Int;
DECLARE @Part1Len	Int;
DECLARE @Part2Len	Int;
DECLARE @Part3Len	Int;
DECLARE @Part4Len	Int;

DECLARE @PartStart	int;
DECLARE @PartLen	int;

DECLARE @StrRemain		varchar(500);
DECLARE @StrPartStart	varchar(2);
DECLARE @StrPartLen		varchar(2);

BEGIN --============== S T A R T  C O D E ===================================================

	SET NOCOUNT ON;

	-- Init Variables ---------------------------------------------------------
	IF (@RepOptions Is Null)	SET @RepOptions = '20';

	IF (@SelectedAcnt1 Is Null)	SET @SelectedAcnt1 = 0;
	IF (@SelectedAcnt2 Is Null)	SET @SelectedAcnt2 = 0;
	IF (@SelectedAcnt3 Is Null)	SET @SelectedAcnt3 = 0;
	IF (@SelectedAcnt4 Is Null)	SET @SelectedAcnt4 = 0;
	IF (@SelectedVisitor1 Is Null)	SET @SelectedVisitor1 = 0;
	IF (@SelectedVisitor2 Is Null)	SET @SelectedVisitor2 = 0;
	IF (@SelectedVisitor3 Is Null)	SET @SelectedVisitor3 = 0;
	IF (@SelectedVisitor4 Is Null)	SET @SelectedVisitor4 = 0;

	SET @LangID		= pub.funSplitString(@RepInfo, '@', 1);
	SET @SessionNo	= pub.funSplitString(@RepInfo, '@', 2);
	SET @ReportID	= pub.funSplitString(@RepInfo, '@', 3);
	
	SET @RemainPart	= Substring(@RepOptions, 1, 1);
	SET @AccRemain  = Substring(@RepOptions, 2, 1);
	SET @ZeroRemain = Substring(@RepOptions, 3, 1);
	
	exec [acc].[SpAcc_PartInfo] @RemainPart, @PartStart out, @PartLen out
	
	set @StrPartStart = @PartStart
	set @StrPartLen = @PartLen
		
	create table #tbl_Acnt
	(
		AcntCode varchar(20) collate arabic_cs_as not null
	);
	
	create table #tbl_Visitors
	(
		AcntCode	varchar(20) collate arabic_cs_as not null,
		VisitorCode varchar(20) collate arabic_cs_as null
	);
	
	create table #tbl_AcntRemain
	(
		AcntCode	varchar(20) collate arabic_cs_as not null,
		DebitRemain float not null
	);
	-- ------------------------------------------------------------------------
	-- Where Clause -----------------------------------------------------------
	Set @StrWhereS = '(D.ProcessID  in (90,100)) and (D.AcntCode<>'''')'
	Set @StrWhereA = '(D.VchKind>0)'
	Set @StrWhereP = '(HI.ProcessID in (1,10))'
	set @StrWhereI = '(1=1)'
	
	If (@ProcessNo Is Not Null) and (@ProcessNo > 0)
		SET @StrWhereS = @StrWhereS + ' AND (D.ProcessNo=' + LTrim(Str(@ProcessNo)) + ')'
		
	IF (@SalDateFr Is Not Null)
		SET @StrWhereS = @StrWhereS + ' AND (D.DocDate>=''' + @SalDateFr + ''')'
	IF (@SalDateTo Is Not Null)
		SET @StrWhereS = @StrWhereS + ' AND (D.DocDate<=''' + @SalDateTo + ''')'

	If (@SelectedVisitor1 > 0)
		SET @StrWhereS = @StrWhereS + ' AND ' + pub.funGetFilterString(@SessionNo, @ReportID, @SelectedVisitor1, 'D.VisitorAcntCode')
	If (@SelectedVisitor2 > 0)
		SET @StrWhereS = @StrWhereS + ' AND ' + pub.funGetFilterString(@SessionNo, @ReportID, @SelectedVisitor2, 'D.VisitorAcntCode')
	If (@SelectedVisitor3 > 0)
		SET @StrWhereS = @StrWhereS + ' AND ' + pub.funGetFilterString(@SessionNo, @ReportID, @SelectedVisitor3, 'D.VisitorAcntCode')
	If (@SelectedVisitor4 > 0)
		SET @StrWhereS = @StrWhereS + ' AND ' + pub.funGetFilterString(@SessionNo, @ReportID, @SelectedVisitor4, 'D.VisitorAcntCode')

	If (@SelectedVisitor1 > 0)
		SET @StrWhereI = @StrWhereI + ' AND ' + pub.funGetFilterString(@SessionNo, @ReportID, @SelectedVisitor1, 'I.VisitorAcntCode')
	If (@SelectedVisitor2 > 0)
		SET @StrWhereI = @StrWhereI + ' AND ' + pub.funGetFilterString(@SessionNo, @ReportID, @SelectedVisitor2, 'I.VisitorAcntCode')
	If (@SelectedVisitor3 > 0)
		SET @StrWhereI = @StrWhereI + ' AND ' + pub.funGetFilterString(@SessionNo, @ReportID, @SelectedVisitor3, 'I.VisitorAcntCode')
	If (@SelectedVisitor4 > 0)
		SET @StrWhereI = @StrWhereI + ' AND ' + pub.funGetFilterString(@SessionNo, @ReportID, @SelectedVisitor4, 'I.VisitorAcntCode')

	set @StrWhereX = ''
	
	If (@SelectedAcnt1 > 0)
		SET @StrWhereX = @StrWhereX + ' AND ' + pub.funGetFilterString(@SessionNo, @ReportID, @SelectedAcnt1, 'D.AcntCode')
	If (@SelectedAcnt2 > 0)
		SET @StrWhereX = @StrWhereX + ' AND ' + pub.funGetFilterString(@SessionNo, @ReportID, @SelectedAcnt2, 'D.AcntCode')
	If (@SelectedAcnt3 > 0)
		SET @StrWhereX = @StrWhereX + ' AND ' + pub.funGetFilterString(@SessionNo, @ReportID, @SelectedAcnt3, 'D.AcntCode')
	If (@SelectedAcnt4 > 0)
		SET @StrWhereX = @StrWhereX + ' AND ' + pub.funGetFilterString(@SessionNo, @ReportID, @SelectedAcnt4, 'D.AcntCode')

	set @StrWhereS = @StrWhereS + @StrWhereX
	set @StrWhereA = @StrWhereA + @StrWhereX

	if (@RemDateTo is not null) 
	begin
		set @StrWhereP = @StrWhereP + ' and (D.DocDate<=''' + @RemDateTo + ''')'
		set @StrWhereA = @StrWhereA + ' and (D.DocDate<=''' + @RemDateTo + ''')'
	end;
	---------------------------------------------------------
	-- Select Clause ----------------------------------------
	declare @AcntD nvarchar(500);
	declare @AcntI nvarchar(500);

	set @AcntI = 'Substring(I.AcntCode,' + @StrPartStart + ',' + @StrPartLen + ')'
	set @AcntD = 'Substring(D.AcntCode,' + @StrPartStart + ',' + @StrPartLen + ')'
	
	SET @StrSelect = '
	insert into #tbl_Acnt
	select distinct ' + @AcntD + ' AcntCode
	from inv.tblStorageDocsHdr D
	where ' + @StrWhereS 

	print @StrSelect;
	Exec sp_executesql @StrSelect;
	
	SET @StrSelect = '
	insert into #tbl_Visitors(AcntCode, VisitorCode)
	select A.AcntCode,ISNULL(I.VisitorAcntCode ,'''') VisitorCode
	FROM #tbl_Acnt A INNER JOIN (
	select AcntCode,VisitorAcntCode from (
	select ROW_NUMBER()over(partition by ' + @AcntI + ' order by DocDate desc, SerialNo desc) R,AcntCode,VisitorAcntCode 
	from inv.tblStorageDocsHdr I
	where (ProcessID IN (90,100)) AND ' + @StrWhereI + '
	) a
	where R=1 ) I
	ON ' + @AcntI + '=A.AcntCode'

	print @StrSelect;
	Exec sp_executesql @StrSelect;
	
	SET @StrSelect = '
	insert into #tbl_AcntRemain(AcntCode, DebitRemain)
	select A.AcntCode,ISNULL(DebitRemain,0)
	from #tbl_Acnt A 
	LEFT JOIN (
		select ' + @AcntD + ' AcntCode,isnull(Sum(D.Debit-D.Credit),0) DebitRemain
	from acc.tblVoucherDtl D
	where  ' + @StrWhereA + '
	group by ' + @AcntD + ' ) B
	ON A.AcntCode=B.AcntCode'
	print @StrSelect;
	Exec sp_executesql @StrSelect;

	---------------------------------------------
	declare @SalDate as varchar(100)
	set @SalDate=' and  1=1 '
	IF (@SalDateTo Is Not Null)
		SET @SalDate = @SalDate + ' AND (DocDate<=''' + @SalDateTo + ''')' 

	SET @StrSelect = '
	SELECT	T.AcntCode, sum(InvoiceAmount) SaleAmount, sum(PaymentAmount) PayAmount,
			V.VisitorCode, pub.GetCodeName(V.VisitorCode, 1) VisitorName, R.DebitRemain, LastSaleDate
	FROM
	(
		select cast(' + @AcntD + ' as varchar(20)) AcntCode, 
				isnull((
					select sum(GoodsQuantity * GoodsPrice * EnterKind * (-1)) 
					from inv.tblStorageDocsDtl DI
					where D.ProcessID=DI.ProcessID and D.ProcessNo=DI.ProcessNo and D.FiscalYear=DI.FiscalYear and D.SerialNo=DI.SerialNo
				),0) + D.SidePriceSum InvoiceAmount,
				isnull((
					select sum(DI.Amount) 
					from trs.tblPayDtl DI
						inner join trs.tblPayHdr HI on HI.ProcessID=DI.ProcessID and HI.ProcessNo=DI.ProcessNo and HI.FiscalYear=DI.FiscalYear and HI.SerialNo=DI.SerialNo
					where HI.BaseProcessID=D.ProcessID and HI.BaseProcessNo=D.ProcessNo and HI.BaseFiscalYear=D.FiscalYear and HI.BaseSerialNo=D.SerialNo and ' + @StrWhereP + '
				),0) PaymentAmount
		from inv.vwStorageDocsHdr D
		where ' + @StrWhereS + '
	) T 
	Left JOIN (select AcntCode,LastSaleDate 
				from (
					select ROW_NUMBER()over(partition by ' + @AcntD + ' order by DocDate desc) R,' + @AcntD + ' AcntCode,DocDate LastSaleDate
					from inv.tblStorageDocsHdr D
					where ProcessID IN (90) '+  @SalDate  +'
				) a
				where R=1
		  )L
	ON L.AcntCode=T.AcntCode			
	LEFT JOIN #tbl_Visitors  V on V.AcntCode = T.AcntCode
	LEFT JOIN #tbl_AcntRemain R on R.AcntCode = T.AcntCode
	GROUP BY T.AcntCode, V.VisitorCode, R.DebitRemain,LastSaleDate '

	Print @StrSelect
	
	if (@AccRemain=1)
		set @StrRemain = 'DebitRemain'
	else
		set @StrRemain = 'SaleAmount-PayAmount'
	
	set @StrWhereR = '(1=1)';
	
	if (@RemainFr <> -1) or (@RemainTo <> -1) 
	begin
		if (@RemainFr <> -1) 
			set @StrWhereR = @StrWhereR + ' and (' + @StrRemain + '>=' + str(@RemainFr) + ')'
		if (@RemainTo <> -1) 
			set @StrWhereR = @StrWhereR + ' and (' + @StrRemain + '<=' + str(@RemainTo) + ')'
	end
	
	if (@ZeroRemain=0)
		SET @StrWhereR = @StrWhereR + ' and (round(' + @StrRemain + ',3)<>0)'
		
	SET @StrSelect = '
	select	X.*, AH.VisitPathID1, AH.VisitPathID2, AH.VisitPathID3, AH.VisitPathID4,
			V1.VisitPathName VisitPathName1, V2.VisitPathName VisitPathName2,
			V3.VisitPathName VisitPathName3, V4.VisitPathName VisitPathName4,
			AD.OrganzationName, AD.AcntName, LD.LocationName AcntCity,
			(AD.Address1 + '' '' + AD.Address2) AcntAddr, AH.Tel, AH.Mobile, AH.NationalIDNumber
	from	(' + @StrSelect + ') X
			left join acc.tblAcnt    AH on AH.AcntCode = X.AcntCode and AH.PartNumber = ' + STR(@RemainPart) + '
			left join acc.tblAcntDtl AD on AD.AcntCode = X.AcntCode and AD.PartNumber = ' + STR(@RemainPart) + '
			left join pub.tblLocationsDtl LD on LD.LocationID = AH.LocationID
			left join acc.tblVisitPathDtl V1 on V1.VisitPathID = AH.VisitPathID1 and V1.PartNumber = 1
			left join acc.tblVisitPathDtl V2 on V2.VisitPathID = AH.VisitPathID2 and V2.PartNumber = 2
			left join acc.tblVisitPathDtl V3 on V3.VisitPathID = AH.VisitPathID3 and V3.PartNumber = 3
			left join acc.tblVisitPathDtl V4 on V4.VisitPathID = AH.VisitPathID4 and V4.PartNumber = 4 
	where ' + @StrWhereR
	------------------------------------------------------------
	-- Sort Clause ---------------------------------------------
	If (@SortFields Is Not Null) AND (@SortFields <> '') 
		SET @StrSelect = @StrSelect + '
	order by ' + @SortFields
	------------------------------------------------------------
	-- Run -----------------------------------------------------
	Print @StrSelect;
	Exec sp_executesql @StrSelect;
	------------------------------------------------------------
END
GO
