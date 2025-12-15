USE TS_ShirinVatanKarkhaneh_1_1404
GO
SET ANSI_NULLS, QUOTED_IDENTIFIER ON
GO
-- =========== TS-QC:NOTOK ========================
-- Author        : Jafari
-- Create date   : 99/12/23
-- Viewed By	 : 
-- Last Modified : 
-- Description   : 
-- =============================================
Create PROCEDURE pln.SPLoanReview 
@CallType Int, 
@ExtraParams		NVarChar(Max) = ''
WITH ENCRYPTION
AS
begin

DECLARE @StrSelect		NVarChar(max)
DECLARE @StrWhere		NVarChar(2000)

DECLARE @SerialNoFR			int
DECLARE @SerialNoTO			int
DECLARE @FiscalYearFR		int
DECLARE @FiscalYearTO		int

DECLARE 
@FromDate as varchar(10),
@ToDate as varchar(10),
@LoanNo as varchar(20),
@LoanName NVarChar(200),
@Interest  as Float,
@PenaltyRate  as Float, 
@ProcessNo as int
Declare @Part as tinyint=1
select @Part=[acc].[FunGetAcntInfoForRemain](1)

if @CallType=1
	begin
		SET @FiscalYearFR	= LTrim(pub.funSplitString(@ExtraParams, '@', 1)); 
		SET @SerialNoFR		= LTrim(pub.funSplitString(@ExtraParams, '@', 2)); 
		SET @FiscalYearTO	= LTrim(pub.funSplitString(@ExtraParams, '@', 3)); 
		SET @SerialNoTO		= LTrim(pub.funSplitString(@ExtraParams, '@', 4)); 

		SET @FromDate		= LTrim(pub.funSplitString(@ExtraParams, '@', 5)); 		
		SET @ToDate			= LTrim(pub.funSplitString(@ExtraParams, '@', 6)); 

		SET @LoanNo			= LTrim(pub.funSplitString(@ExtraParams, '@', 7)); 
		SET @LoanName		= LTrim(pub.funSplitString(@ExtraParams, '@', 8)); 
		SET @Interest		= LTrim(pub.funSplitString(@ExtraParams, '@', 9)); 
		SET @PenaltyRate	= LTrim(pub.funSplitString(@ExtraParams, '@', 10));
		 
		SET @ProcessNo		= LTrim(pub.funSplitString(@ExtraParams, '@', 11)); 

		
		set @StrWhere = ' 1=1 '

		if @FiscalYearFR>0
			set @StrWhere =@StrWhere+ ' AND h.FiscalYear>=' +str(@FiscalYearFR)
		if @SerialNoFR>0
			set @StrWhere = @StrWhere+' AND h.SerialNo  >=' +str(@SerialNoFR)
		if @FiscalYearTO>0
			set @StrWhere =@StrWhere+ ' AND h.FiscalYear<=' +str(@FiscalYearTO)
		if @SerialNoTO>0
			set @StrWhere = @StrWhere+' AND h.SerialNo	<=' +str(@SerialNoTO)
	
	
		if @FromDate<>''
			set @StrWhere =@StrWhere+ ' AND h.DocDate >=''' +@FromDate+''''

		if @ToDate<>''
			set @StrWhere =@StrWhere+ ' AND h.DocDate <=''' +@ToDate+''''
			
		if @LoanNo>0
			set @StrWhere = @StrWhere+' AND h.LoanNo  =''' +@LoanNo + ''''
	
		if @LoanName>0
			set @StrWhere = @StrWhere+' AND h.LoanName  like ''%' + @LoanName  + '%'''
	
		if @Interest>0
			set @StrWhere = @StrWhere+' AND h.Interest  =' +str(@Interest)
	 
		if @PenaltyRate>0
			set @StrWhere = @StrWhere+' AND h.PenaltyRate  =' +str(@PenaltyRate)
	

		
DECLARE @db_0000   nvarchar(50)
DECLARE @FiscalYear int
DECLARE @StartDate 			char(10)
set @db_0000 = Substring(db_name(), 1, Len(db_name()) - 4) + '0000'
set @FiscalYear = right(db_name(),4) 

	BEGIN TRY
		DROP TABLE #tblFiscalYears
	END TRY
	BEGIN CATCH
	END CATCH

	CREATE TABLE #tblFiscalYears
	(
	StartDate 			char(10)
	)
		
set @StrSelect = ' insert into #tblFiscalYears select StartDate from '+@db_0000+'.pub.tblFiscalYears where FiscalYear='+str(@FiscalYear)+ ''


	print @StrSelect
	Exec sp_executesql @StrSelect;

select Top 1 @StartDate=StartDate from #tblFiscalYears

------حذف برگه های اضافی------------------------------------------------------------------------
delete from trs.tblLoanHdr 
from trs.tblLoanHdr a
inner join (
			select ProcessID,	ProcessNo	,FiscalYear	,SerialNo FROM trs.tblLoanHdr 
			except 
			select ProcessID,	ProcessNo	,FiscalYear	,SerialNo FROM trs.tblLoanDtl  
			)b 
		on a.ProcessID=b.ProcessID and 	a.ProcessNo=b.ProcessNo		and  a.FiscalYear=b.FiscalYear	and a.SerialNo=b.SerialNo
		where a.FiscalYear<>@FiscalYear


set @StrSelect = ' 
SELECT FiscalYear,SerialNo,LoanNo	,BankName	,Interest,	LoanHdrDesc	,DocDate,	InstallmentAmount	,InstallmentDate	,InstallmentCount
,	InstallmentAmount1,	InstallmentCost1, InstallmentAmount1+InstallmentCost1 Sum1
,	InstallmentAmount2	,InstallmentCost2	, InstallmentAmount2+InstallmentCost2 Sum2
,	InstallmentAmount3,	InstallmentCost3	, InstallmentAmount3+InstallmentCost3 Sum3
,InstallmentAmount1+InstallmentAmount2-InstallmentAmount3 InstallmentAmount4
,InstallmentCost1+InstallmentCost2-InstallmentCost3 InstallmentCost4
,InstallmentAmount1+InstallmentAmount2-InstallmentAmount3 +InstallmentCost1+InstallmentCost2-InstallmentCost3 Sum4
  from (		
SELECT h.FiscalYear,h.SerialNo,LoanNo	--LoanName	,	PenaltyRate	
,pub.GetCodeName(BankAcntCode,1) BankName
,Interest, LoanHdrDesc, DocDate 
,isnull((	Select top 1 InstallmentAmount from trs.tblLoanDtl d where h.ProcessID=d.ProcessID and h.ProcessNo=d.ProcessNo
		and h.FiscalYear=d.FiscalYear
		and h.SerialNo=d.SerialNo
	),0) InstallmentAmount
,isnull((	Select top 1 InstallmentDate from trs.tblLoanDtl d where h.ProcessID=d.ProcessID and h.ProcessNo=d.ProcessNo
		and h.FiscalYear=d.FiscalYear
		and h.SerialNo=d.SerialNo
	),'''') InstallmentDate
,isnull((Select Count(*) from trs.tblLoanDtl d where h.ProcessID=d.ProcessID and h.ProcessNo=d.ProcessNo
	and h.FiscalYear=d.FiscalYear
	and h.SerialNo=d.SerialNo
	) ,0) InstallmentCount

,isnull( (SELECT  Sum(InstallmentAmount)InstallmentAmount FROM trs.tblLoanDtl D WHERE D.SerialNo=h.SerialNo And D.ProcessID = h.ProcessID And D.ProcessNo=h.ProcessNo AND D.FiscalYear=h.FiscalYear AND FiscalYear<>'+str(@FiscalYear)+ '),0)InstallmentAmount1
,isnull( (SELECT  Sum(InstallmentCost)InstallmentCost FROM trs.tblLoanDtl D WHERE D.SerialNo=h.SerialNo And D.ProcessID = h.ProcessID And D.ProcessNo=h.ProcessNo AND D.FiscalYear=h.FiscalYear AND FiscalYear<>'+str(@FiscalYear)+ '),0)InstallmentCost1

,isnull( (SELECT  Sum(InstallmentAmount)InstallmentAmount FROM trs.tblLoanDtl D WHERE D.SerialNo=h.SerialNo And D.ProcessID = h.ProcessID And D.ProcessNo=h.ProcessNo AND D.FiscalYear=h.FiscalYear AND FiscalYear='+str(@FiscalYear)+ '),0)InstallmentAmount2
,isnull( (SELECT  Sum(InstallmentCost)InstallmentCost FROM trs.tblLoanDtl D WHERE D.SerialNo=h.SerialNo And D.ProcessID = h.ProcessID And D.ProcessNo=h.ProcessNo AND D.FiscalYear=h.FiscalYear AND FiscalYear='+str(@FiscalYear)+ '),0)InstallmentCost2

,isnull( (SELECT  Sum(InstallmentAmount)InstallmentAmount FROM trs.tblLoanDtl D WHERE D.BaseSerialNo=h.SerialNo And D.BaseProcessID = h.ProcessID And D.BaseProcessNo=h.ProcessNo AND D.BaseFiscalYear=h.FiscalYear ),0)InstallmentAmount3
,isnull((SELECT  Sum(InstallmentCost)InstallmentCost FROM trs.tblLoanDtl D WHERE D.BaseSerialNo=h.SerialNo And D.BaseProcessID = h.ProcessID And D.BaseProcessNo=h.ProcessNo AND D.BaseFiscalYear=h.FiscalYear ),0)InstallmentCost3

FROM trs.tblLoanHdr h 
where  ' + @StrWhere +'
and  ProcessID = 7 And ProcessNo='+str(@ProcessNo)+' )a  '

	print @StrSelect
	Exec sp_executesql @StrSelect;
	 
end 
end 
GO
