USE TS_ShirinVatanKarkhaneh_1_1404
GO
SET ANSI_NULLS, QUOTED_IDENTIFIER ON
GO
-- =========== TS-QC:UPDATED ====================
-- Author		 : TakroSystem\Jafari
-- Create date   : 1389/02/12
-- Viewed By	 : 
-- Last Modified : 1394/08/20
-- Last Modifier :
-- ----------------------------------------------
-- Description	 : < گزارش مانده های مشتریان ویزیتورها>
-- ==============================================
Create PROCEDURE [acc].[RptAcc_AccountStatus]
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
	@RepOptions			VarChar(10) = '111', -- bit array options
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

	-----------------  ایجاد و تکمیل جدول میانی کلی
	exec acc.UpdateAlltblVoucher2AccState 
	----------------------------------------------

	set @StrWhere = ' 1=1 '
	if (@SelectedAcnt1 > 0)
		set @StrWhere = @StrWhere + ' AND ' + pub.funGetFilterString(@SessionNo, @ReportID, @SelectedAcnt1, 'D.AcntCode')
	if (@SelectedAcnt2 > 0)
		set @StrWhere = @StrWhere + ' AND ' + pub.funGetFilterString(@SessionNo, @ReportID, @SelectedAcnt2, 'D.AcntCode')
	if (@SelectedAcnt3 > 0)
		set @StrWhere = @StrWhere + ' AND ' + pub.funGetFilterString(@SessionNo, @ReportID, @SelectedAcnt3, 'D.AcntCode')
	if (@SelectedAcnt4 > 0)
		set @StrWhere = @StrWhere + ' AND ' + pub.funGetFilterString(@SessionNo, @ReportID, @SelectedAcnt4, 'D.AcntCode')
		
		
	if (@DocDateFr Is Not Null)
		if (@DatoFilterSale=0)
			set @StrWhere = @StrWhere + ' AND D.DocDate >= ''' + @DocDateFr + ''''
		else
			set @StrWhere = @StrWhere + ' AND (( D.SourceProcessID<>90) or ( D.SourceProcessID=90 and  D.DocDate >= ''' + @DocDateFr + ''' ))'
	if (@DocDateTo Is Not Null)
		if (@DatoFilterSale=0)
			set @StrWhere = @StrWhere + ' AND D.DocDate <= ''' + @DocDateTo + ''''
		else
			set @StrWhere = @StrWhere + ' AND (( D.SourceProcessID<>90) or (D.SourceProcessID=90 and D.DocDate <= ''' + @DocDateTo + '''))'
	


	-- Visitor --
	if (@SelectedVisitor1 > 0)
		set @StrWhereVisitor = @StrWhereVisitor + ' AND (' + pub.funGetFilterString(@SessionNo, @ReportID, @SelectedVisitor1, 'D.VisitorAcntCode') + ')'	
	if (@SelectedVisitor2 > 0)
		set @StrWhereVisitor = @StrWhereVisitor + ' AND (' + pub.funGetFilterString(@SessionNo, @ReportID, @SelectedVisitor2, 'D.VisitorAcntCode') + ')'
	if (@SelectedVisitor3 > 0)
		set @StrWhereVisitor = @StrWhereVisitor + ' AND (' + pub.funGetFilterString(@SessionNo, @ReportID, @SelectedVisitor3, 'D.VisitorAcntCode') + ')'
	if (@SelectedVisitor4 > 0)
		set @StrWhereVisitor = @StrWhereVisitor + ' AND (' + pub.funGetFilterString(@SessionNo, @ReportID, @SelectedVisitor4, 'D.VisitorAcntCode') + ')'

create table #tblAccState
	(
ID int, 
SerialNo int, 
DocRowNo int, 
RecDesc  nvarchar(4000), 
SourceProcessID int ,
SourceProcessNo int ,
SourceFiscalYear int ,
SourceSerialNo int ,
BaseID int ,
AcntCode Varchar(20)  COLLATE Arabic_CS_AS,
Debit float ,
Credit float , 
DocDate char(10),
Amount float , 
VisitorAcntCode Varchar(20)  COLLATE Arabic_CS_AS,
ID1 int,
Types int,
AcntName nVarchar(Max),
VisitorName nVarchar(Max),
Tel  nvarchar(50), 
Address1  nvarchar(4000), 
Address2  nvarchar(4000),
Mobile  nvarchar(50)

	);

create table #tblPayAllAccState
	(
AcntCode Varchar(20)  COLLATE Arabic_CS_AS ,
VisitorAcntCode Varchar(20)  COLLATE Arabic_CS_AS,
Tel  nvarchar(50), 
Address1  nvarchar(4000), 
Address2  nvarchar(4000),
Mobile  nvarchar(50)
	);

--insert into  #tblAccState
----exec acc.SpAcc_AccState '',8
--select  ID, SerialNo, DocRowNo, RecDesc, SourceProcessID, SourceProcessNo, SourceFiscalYear, SourceSerialNo,SourceDocRowNo, BaseID, AcntCode, Debit, Credit, DocDate, 
--                      Amount, VisitorAcntCode, ID1,CASE WHEN Debit>0 THEN 1 ELSE 2 END as Types,'' AcntName,'' VisitorName
--from acc.tblVoucher2AccState  a


--select * into #tblAccState1  from  #tblAccState where 1=0

	set @StrSelect =  '	insert into #tblAccState
	select  ID, SerialNo, DocRowNo, RecDesc, SourceProcessID, SourceProcessNo, SourceFiscalYear, SourceSerialNo, BaseID, AcntCode, Debit, Credit, DocDate, 
                      Amount, VisitorAcntCode, ID1,CASE WHEN Debit>0 THEN 1 ELSE 2 END as Types,'''' AcntName,'''' VisitorName, F.Tel, F.Address1, F.Address2, F.Mobile
      from acc.tblVoucher2AccState  D 
	  OUTER APPLY acc.funGetCodeInfo(D.AcntCode) F '
	if (@StrWhereVisitor <>'')
		set @StrSelect =  @StrSelect +'WHERE (' + @StrWhere+'  and 1=1 '+ @StrWhereVisitor+') or  (' + @StrWhere+'  and 1=1 and VisitorAcntCode='''') '
	else
		set @StrSelect =  @StrSelect +'WHERE ' + @StrWhere
		
	Print @StrSelect;	
	Exec sp_executesql @StrSelect;

---------اعمال فیلتر بالا-----------------
-- delete  from #tblAccState
-- insert into #tblAccState
-- select * from #tblAccState1
-------------------------------------------
--delete FROM #tblAccState
--WHERE AcntCode not In(select AcntCode  From  #tblAccState1 )

--delete FROM #tblAccState
--WHERE VisitorAcntCode not In ((select VisitorAcntCode  From  #tblAccState1)) And VisitorAcntCode<>''

--select * from  #tblAccState 
--select * from  #tblAccState1 

if (select Count(*) from acc.tblAcnt where HasAccState=1)>0
begin
	Declare @len as int
	set  @len =acc.funGetAcntLayerStartandLen(1,2)
	 Delete From #tblAccState 
	 where SubString (AcntCode,1,@len) not in (select AcntCode from acc.tblAcnt where HasAccState=1)
end

Insert into #tblPayAllAccState 
select Distinct AcntCode ,VisitorAcntCode,Tel,Address1,Address2, Mobile From #tblAccState 

update #tblPayAllAccState Set VisitorAcntCode=''
where VisitorAcntCode is null

--select * into tblAccState From #tblAccState
--select * into  tblAccState1 From #tblAccState1
--select *  into tblPayAllAccState  from #tblPayAllAccState 

set @StrSelect =  'Select  AcntCode,	VisitorAcntCode,abs(Amount) as Amount ,Case when Amount<0  then N''بس''  else N''بد'' end as StateName   ,DebitVisitor,	DebitCust	,CreditVisitor	,CreditCust,	AcntName	,VisitorName, Tel, Address1, Address2, Mobile
from ( Select *,(SELECT Sum(Debit-Credit ) FROM	acc.tblVoucherDtl v WHERE   (VchKind <> 0) and (VchKind not in (3,4)) and v.AcntCode=P.AcntCode) as Amount 
from ( Select *,
(select isnull(SUM(Amount),0) From #tblAccState a where Types=1 and a.AcntCode=P.AcntCode and a.VisitorAcntCode=P.VisitorAcntCode) as DebitVisitor,
(select isnull(SUM(Amount),0) From #tblAccState a where Types=1 and a.AcntCode=P.AcntCode and a.VisitorAcntCode<>P.VisitorAcntCode) as DebitCust,
(select isnull(SUM(Amount),0) From #tblAccState a where Types=2 and a.AcntCode=P.AcntCode and a.VisitorAcntCode=P.VisitorAcntCode) as CreditVisitor,
(select isnull(SUM(Amount),0) From #tblAccState a where Types=2 and a.AcntCode=P.AcntCode and a.VisitorAcntCode<>P.VisitorAcntCode) as CreditCust,
pub.GetCodeName(P.AcntCode, '+@LangID+')as AcntName, 
pub.GetCodeName(P.VisitorAcntCode, '+@LangID+')as VisitorName
From #tblPayAllAccState P)
P)
P
Where 1=1	'
	
if (@ShowZero=0)
 set @StrSelect = @StrSelect + ' And   not(CreditVisitor=DebitVisitor and CreditCust=DebitCust)' 
	
if (@ShowNoVisitorAccount=0)
 set @StrSelect = @StrSelect + ' And  P.VisitorAcntCode<>'''' ' 
	
if (@ShowAmountZero=0)
 set @StrSelect = @StrSelect + ' And  P.Amount<>0 ' 

if (@Amount>0)
	 set @StrSelect = @StrSelect + ' And Amount>'+ str(@Amount)
	 
if (@ShowDebits>0)
	 set @StrSelect = @StrSelect + ' And (CreditVisitor +CreditCust)-(DebitVisitor+DebitCust)<0'
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
		set @StrSelect = @StrSelect + '  order by AcntCode' 
	else
		set @StrSelect = @StrSelect + '  order by AcntName' 
	
	Print @StrSelect;	
	Exec sp_executesql @StrSelect;
	
	END
GO
