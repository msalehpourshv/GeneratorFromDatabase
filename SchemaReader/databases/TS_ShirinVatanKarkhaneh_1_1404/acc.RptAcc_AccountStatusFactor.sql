USE TS_ShirinVatanKarkhaneh_1_1404
GO
SET ANSI_NULLS, QUOTED_IDENTIFIER ON
GO
-- =========== TS-QC:UPDATED ====================
-- Author		 : TakroSystem\Jafari
-- Create date   : 1394/07/30
-- Viewed By	 : 
-- Last Modified : 1394/07/30
-- Last Modifier :
-- ----------------------------------------------
-- Description	 : < گزارش مانده های مشتریان ویزیتورها>
-- ==============================================
Create PROCEDURE [acc].[RptAcc_AccountStatusFactor]
	@SelectedAcnt1		int = 0,
	@SelectedAcnt2		int = 0,
	@SelectedAcnt3		int = 0,
	@SelectedAcnt4		int = 0,
	@SelectedVisitor1	int = 0, 
	@SelectedVisitor2	int = 0, 
	@SelectedVisitor3	int = 0, 
	@SelectedVisitor4	int = 0,
	@DocDateFr			Char(10) = Null,
	@DocDateTo			Char(10) = Null,
	@ExtraOptions			VarChar(1000) = '111', -- bit array options
	@RepOptions			VarChar(100) = '111', -- bit array options
	@RepInfo			NVarChar(100) = '1@1@1' -- bit array options
WITH ENCRYPTION
AS
Declare @StrSelectVoucher	NVarChar(max);
Declare @StrWhereVisitor	NVarChar(4000);
Declare @StrSelect	NVarChar(max);
Declare @StrWhere	NVarChar(4000);
Declare @StrWhereM	NVarChar(4000);

Declare @SortByName		int; -- مرتب بر اساس اسامی حسابها باشد یا کد حسابها؟
Declare @UseDateFilter	Bit; 
Declare @WithVisitor	bit;
Declare @WithBase	bit;
Declare @ShowZero	bit;
Declare @ShowNoVisitorAccount bit;
Declare @ShowAmountZero bit;
Declare @DatoFilterSale bit;
Declare @ShowDebits bit;

Declare @AcntCode Varchar(20);

DECLARE	@LangID			Char(1);
DECLARE	@SessionNo		Int; -- برای حالت کدهای انتخابی
DECLARE	@ReportID		Int; -- برای حالت کدهای انتخابی
DECLARE	@Amount		Int; 
BEGIN -- ============================ S T A R T =====================================================

	set @LangID		= pub.funSplitString(@RepInfo, '@', 1);
	set @SessionNo	= pub.funSplitString(@RepInfo, '@', 2);
	set @ReportID	= pub.funSplitString(@RepInfo, '@', 3);
	
			
	SET @Amount		 = LTrim(pub.funSplitString(@ExtraOptions, '@', 1)); 
	SET @SortByName		 = LTrim(pub.funSplitString(@ExtraOptions, '@', 2)); 
	   
	-----------------  ایجاد و تکمیل جدول میانی کلی
	exec acc.UpdateAlltblVoucher2AccState
		----------------------------------------------

SET @StrWhereVisitor = ''
	
	
	if (@SelectedAcnt1	Is Null)	set @SelectedAcnt1 = 0
	if (@SelectedAcnt2	Is Null)	set @SelectedAcnt2 = 0
	if (@SelectedAcnt3	Is Null)	set @SelectedAcnt3 = 0
	if (@SelectedAcnt4	Is Null)	set @SelectedAcnt4 = 0
	if (@SelectedVisitor1 Is Null)	set @SelectedVisitor1 = 0;
	if (@SelectedVisitor2 Is Null)	set @SelectedVisitor2 = 0;
	if (@SelectedVisitor3 Is Null)	set @SelectedVisitor3 = 0;
	if (@SelectedVisitor4 Is Null)	set @SelectedVisitor4 = 0;

	
	--SET @SortByName		= Substring(@RepOptions, 1, 1)
	SET @UseDateFilter	= Substring(@RepOptions, 2, 1)
	SET @WithVisitor	= Substring(@RepOptions, 3, 1)
	SET @WithBase	= Substring(@RepOptions, 4, 1)
	SET @ShowZero	= Substring(@RepOptions, 5, 1)
	SET @ShowNoVisitorAccount	= Substring(@RepOptions, 6, 1)
	SET @ShowAmountZero	= Substring(@RepOptions, 7, 1)
	SET @DatoFilterSale	= Substring(@RepOptions, 8, 1)
	SET @ShowDebits	= Substring(@RepOptions, 9, 1)
	

	set NOCOUNT ON;

	set @StrWhere = ' 1=1 '
	if (@SelectedAcnt1 > 0)
		set @StrWhere = @StrWhere + ' AND ' + pub.funGetFilterString(@SessionNo, @ReportID, @SelectedAcnt1, 'h.AcntCode')
	if (@SelectedAcnt2 > 0)
		set @StrWhere = @StrWhere + ' AND ' + pub.funGetFilterString(@SessionNo, @ReportID, @SelectedAcnt2, 'h.AcntCode')
	if (@SelectedAcnt3 > 0)
		set @StrWhere = @StrWhere + ' AND ' + pub.funGetFilterString(@SessionNo, @ReportID, @SelectedAcnt3, 'h.AcntCode')
	if (@SelectedAcnt4 > 0)
		set @StrWhere = @StrWhere + ' AND ' + pub.funGetFilterString(@SessionNo, @ReportID, @SelectedAcnt4, 'h.AcntCode')
		
		
	-- Visitor --
	if (@SelectedVisitor1 > 0)
		set @StrWhere = @StrWhere + ' AND (' + pub.funGetFilterString(@SessionNo, @ReportID, @SelectedVisitor1, 'h.VisitorAcntCode') + ')'	
	if (@SelectedVisitor2 > 0)
		set @StrWhere = @StrWhere + ' AND (' + pub.funGetFilterString(@SessionNo, @ReportID, @SelectedVisitor2, 'h.VisitorAcntCode') + ')'
	if (@SelectedVisitor3 > 0)
		set @StrWhere = @StrWhere + ' AND (' + pub.funGetFilterString(@SessionNo, @ReportID, @SelectedVisitor3, 'h.VisitorAcntCode') + ')'
	if (@SelectedVisitor4 > 0)
		set @StrWhere = @StrWhere + ' AND (' + pub.funGetFilterString(@SessionNo, @ReportID, @SelectedVisitor4, 'h.VisitorAcntCode') + ')'
	
	if (@DocDateFr Is Not Null)
			set @StrWhere = @StrWhere + ' AND h.DocDate >= ''' + @DocDateFr + ''''
	if (@DocDateTo Is Not Null)
			set @StrWhere = @StrWhere + ' AND h.DocDate <= ''' + @DocDateTo + ''''
		
	exec acc.SpAcc_AccState  '',4
	--exec acc.SpAcc_AccState  '',5
	--exec acc.SpAcc_AccState  '',6

Declare @PartNumber as int
Declare @Start as int
Declare @Layerlen as int

SELECT    @Layerlen=SettingValue	FROM         pub.tblSettings WHERE     (SettingKey = N'LayerLen')
SELECT     @Start=SettingValue		FROM         pub.tblSettings WHERE     (SettingKey =N'StartLayerIndex')
SELECT     @PartNumber=SettingValue FROM         pub.tblSettings WHERE     (SettingKey = N'AcntPartNumberForRemainCalculation')
				
Declare @DocDate as Char(10)
select @DocDate=pub.funFarsiDate(GetDate())			

set @StrSelect =  '
select a.*,Price2-Amount as Remain ,F.* ,isnull(DebitCreditAcntCode,0)DebitCreditAcntCode, isnull(DebitCreditVisitorAcntCode,0)DebitCreditVisitorAcntCode
from (
	Select h.VisitorAcntCode
		, pub.GetCodeName(h.VisitorAcntCode, 1)as VisitorName
		, h.AcntCode
		, pub.GetCodeName(h.AcntCode, 1)as AcntName
		, RemainAll
		, isnull(   l.LocationName ,'''') as City
		, isnull(   Dr.FirstName	 ,'''') as FirstNameDriver
		, isnull(   Dr.LastName	 ,'''') as LastNameDriver
		, h.SerialNo SourceSerialNo1
		, h.DocDate
		, SumDebit Price2
		, h.Amount Price
		, h.Amount Amount2--
		, h.ProcessID
		, h.ProcessNo 
		, h.FiscalYear
		,isnull(   Mobile  ,'''')  as Mobile
		,h.BaseDistributionSerialNo
		,isnull(SUMAmount, 0)Amount
		,DistributDate 
		--, acc.funAcntDebitRemainFull(h.AcntCode,'''+@DocDate+''' ) AcntDebitRemain
		, pub.funFarsiDateDiff(''Day'', h.DocDate, '''+@DocDate+''') DayPast 
		, 0 AcntDebitRemain
		--, 0 DayPast 

from inv.tblStorageDocsHdr h
inner JOIN 
		(select Sum(Debit) SumDebit ,SourceProcessID ProcessID,SourceProcessNo ProcessNo,SourceFiscalYear FiscalYear,SourceSerialNo SerialNo,AcntCode
		from acc.tblVoucherDtl 
			where  VchKind<>0 and SourceProcessID=90 
		Group by SourceProcessID,SourceProcessNo,SourceFiscalYear,SourceSerialNo,AcntCode ) v
		on  h.ProcessID=v.ProcessID 
			and h.ProcessNo=v.ProcessNo 
			and h.FiscalYear=v.FiscalYear 
			and h.SerialNo=v.SerialNo 
			and v.AcntCode=h.AcntCode
left JOIN 
  sal.tblDistributionsDtl dd
		 on h.ProcessID=dd.BaseSaleProcessID 
					and h.ProcessNo=dd.BaseSaleProcessNo 
					and h.FiscalYear=dd.BaseSaleFiscalYear 
					and h.SerialNo=dd.BaseSaleSerialNo 
left JOIN 
  sal.tblDistributionsHdr dh
		 on dh.ProcessID=dd.ProcessID 
					and dh.SerialNo=dd.SerialNo
left JOIN 
(Select SUM(Amount)	SUMAmount,	SourceProcessID1,SourceProcessNo1,SourceFiscalYear1,SourceSerialNo1,AcntCode
			From   acc.tblAccState 	
				where SourceProcessID1=90
					Group by SourceProcessID1,SourceProcessNo1,SourceFiscalYear1,SourceSerialNo1,AcntCode) acs
			on h.ProcessID=acs.SourceProcessID1 
					and h.ProcessNo=acs.SourceProcessNo1 
					and h.FiscalYear=acs.SourceFiscalYear1 
					and h.SerialNo=acs.SourceSerialNo1 
					and h.AcntCode=acs.AcntCode

left join 
		(Select SUM(Debit)-SUM(Credit)   RemainAll,AcntCode	 
		from acc.tblVoucherDtl d 	 
			where  VchKind<>0 and VchKind<>3	 
		Group by AcntCode) s 
		on s.AcntCode=h.AcntCode
left join  
		acc.tblAcnt a 
		on  a.PartNumber = '+str(@PartNumber)+'  
			AND a.AcntCode = SUBSTRING (h.AcntCode, '+str(@Start)+' ,'+str(@Layerlen)+' ) 
left join 
		pub.tblLocationsDtl l 
		ON a.LocationID = l.LocationID 
left join 
		pub.tblDriversDtl Dr 
		ON h.DriverID = Dr.DriverID 		
where h.ProcessID=90  and '+ @StrWhere +'
)a
OUTER APPLY acc.funGetCodeInfo(a.AcntCode) AS F
left join (
select Sum(Debit-Credit) DebitCreditAcntCode, AcntCode AcntCode2 from acc.tblVoucherDtl
where VchKind=2
group by AcntCode) b on  a.AcntCode=b.AcntCode2
left join (
select Sum(Debit-Credit) DebitCreditVisitorAcntCode, AcntCode AcntCode3, VisitorAcntCode VisitorAcntCode2 from acc.tblVoucherDtl
where VchKind=2
group by AcntCode, VisitorAcntCode) c on  a.AcntCode=c.AcntCode3 and  a.VisitorAcntCode=c.VisitorAcntCode2
where 1=1 '

if (select Count(*) from acc.tblAcnt where HasAccState=1)>0
begin
	Declare @len as int
	set  @len =acc.funGetAcntLayerStartandLen(1,2)
	 set @StrSelect = @StrSelect + ' and  SubString (AcntCode,1,'+str(@len)+') in (select AcntCode from acc.tblAcnt where HasAccState=1)'
end 

if (@ShowZero=0)
	 set @StrSelect = @StrSelect + ' And Price2-Amount<>0 ' 

if (@ShowDebits=1)
	 set @StrSelect = @StrSelect + ' And Price2-Amount>0 ' 
 if (@ShowNoVisitorAccount=0)
 set @StrSelect = @StrSelect + ' And  VisitorAcntCode<>'''' ' 
	
if (@ShowAmountZero=0)
 set @StrSelect = @StrSelect + ' And  RemainAll<>0 ' 
 
if (@Amount>0)
	 set @StrSelect = @StrSelect + ' And ( Price2-Amount>'+ str(@Amount) + ' ) '

	DECLARE	@UserID			Int;
	DECLARE	@UserIsAdmin	bit;

		
	SET @LangID			= pub.funSplitString(@RepInfo, '@', 1);
	SET @SessionNo		= pub.funSplitString(@RepInfo, '@', 2);
	SET @ReportID		= pub.funSplitString(@RepInfo, '@', 3);
	SET @UserID			= pub.funSplitString(@RepInfo, '@', 4);
	SET @UserIsAdmin	= pub.funSplitString(@RepInfo, '@', 5);

	SET @StrWhere = ''

if @UserIsAdmin=0
	begin
	
	SET @UserIsAdmin	= pub.funSplitString(@RepInfo, '@', 5);
	BEGIN TRY
		DROP TABLE #tblAcntCode
		DROP TABLE #tblVisitorAcntCode
	END TRY
	BEGIN CATCH
	END CATCH

	CREATE TABLE #tblAcntCode
	(
	AcntCode 			Varchar(20)collate arabic_cs_as null
	)	
	CREATE TABLE #tblVisitorAcntCode
	(
	VisitorAcntCode 			Varchar(20)collate arabic_cs_as null
	)
	
	Insert into  #tblVisitorAcntCode (VisitorAcntCode)	SELECT Distinct VisitorAcntCode	FROM acc.tblVoucher2AccState
	Insert into  #tblAcntCode (AcntCode)				SELECT Distinct AcntCode		FROM acc.tblVoucher2AccState
	 
		 exec pub.SpFilterByPermission2 '#tblAcntCode', 'AcntCode', 'acc.tblAcnt', @UserID;
		 exec pub.SpFilterByPermission2 '#tblVisitorAcntCode', 'VisitorAcntCode', 'acc.tblAcnt', @UserID;

		SET @StrWhere =  
			' and AcntCode in (SELECT AcntCode FROM  #tblAcntCode ) ' +
			' and VisitorAcntCode in (SELECT VisitorAcntCode FROM  #tblVisitorAcntCode ) ' 
	END		

	set @StrSelect = @StrSelect + @StrWhere

	 if (@SortByName=1)
		set @StrSelect = @StrSelect + '  order by a.AcntCode' 
	 if (@SortByName=2)
		set @StrSelect = @StrSelect + '  order by a.AcntName' 
	if (@SortByName=3)
		set @StrSelect = @StrSelect + '  order by a.DocDate' 
	
	Print @StrSelect;	
	Exec sp_executesql @StrSelect;
	
	
END
GO
