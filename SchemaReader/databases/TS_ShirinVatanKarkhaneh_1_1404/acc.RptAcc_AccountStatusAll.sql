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
Create PROCEDURE [acc].[RptAcc_AccountStatusAll]
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

Declare @SortByName		Bit; -- مرتب بر اساس اسامی حسابها باشد یا کد حسابها؟
Declare @UseDateFilter	Bit; 
Declare @WithVisitor	bit;
Declare @WithBase	bit;
Declare @NotUse	bit;

DECLARE	@LangID			Char(1);
DECLARE	@SessionNo		Int; -- برای حالت کدهای انتخابی
DECLARE	@ReportID		Int; -- برای حالت کدهای انتخابی
BEGIN -- ============================ S T A R T =====================================================

	set @LangID		= pub.funSplitString(@RepInfo, '@', 1);
	set @SessionNo	= pub.funSplitString(@RepInfo, '@', 2);
	set @ReportID	= pub.funSplitString(@RepInfo, '@', 3);
	
		SET @NotUse		 = LTrim(pub.funSplitString(@ExtraOptions, '@', 1)); 

SET @StrWhereVisitor = ''
	
	
	if (@SelectedAcnt1	Is Null)	set @SelectedAcnt1 = 0
	if (@SelectedAcnt2	Is Null)	set @SelectedAcnt2 = 0
	if (@SelectedAcnt3	Is Null)	set @SelectedAcnt3 = 0
	if (@SelectedAcnt4	Is Null)	set @SelectedAcnt4 = 0
	if (@SelectedVisitor1 Is Null)	set @SelectedVisitor1 = 0;
	if (@SelectedVisitor2 Is Null)	set @SelectedVisitor2 = 0;
	if (@SelectedVisitor3 Is Null)	set @SelectedVisitor3 = 0;
	if (@SelectedVisitor4 Is Null)	set @SelectedVisitor4 = 0;
	
	SET @SortByName		= Substring(@RepOptions, 1, 1)
	SET @UseDateFilter	= Substring(@RepOptions, 2, 1)
	SET @WithVisitor	= Substring(@RepOptions, 3, 1)
	SET @WithBase	= Substring(@RepOptions, 4, 1)
	
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

	-- Visitor --
	if (@SelectedVisitor1 > 0)
		set @StrWhere = @StrWhere + ' AND (' + pub.funGetFilterString(@SessionNo, @ReportID, @SelectedVisitor1, 'D.VisitorAcntCode') + ')'
		
	if (@SelectedVisitor2 > 0)
		set @StrWhere = @StrWhere + ' AND (' + pub.funGetFilterString(@SessionNo, @ReportID, @SelectedVisitor2, 'D.VisitorAcntCode') + ')'
	if (@SelectedVisitor3 > 0)
		set @StrWhere = @StrWhere + ' AND (' + pub.funGetFilterString(@SessionNo, @ReportID, @SelectedVisitor3, 'D.VisitorAcntCode') + ')'
	if (@SelectedVisitor4 > 0)
		set @StrWhere = @StrWhere + ' AND (' + pub.funGetFilterString(@SessionNo, @ReportID, @SelectedVisitor4, 'D.VisitorAcntCode') + ')'
	-- Date To --
	if (@DocDateFr Is Not Null)
		set @StrWhere = @StrWhere + ' AND D.DocDate >= ''' + @DocDateFr + ''''
	if (@DocDateTo Is Not Null)
		set @StrWhere = @StrWhere + ' AND D.DocDate <= ''' + @DocDateTo + ''''
	if (select Count(*) from acc.tblAcnt where HasAccState=1)>0
	begin
		Declare @len as int
		set  @len =acc.funGetAcntLayerStartandLen(1,2)
		 set @StrWhere = @StrWhere + ' and  SubString (D.AcntCode,1,'+str(@len)+') in (select AcntCode from acc.tblAcnt where HasAccState=1)'
	end	
	
select SerialNo , DocRowNo , RecDesc  , SourceProcessID ,SourceProcessNo ,SourceFiscalYear  ,SourceSerialNo  ,SourceDocRowNo,
BaseID  ,AcntCode ,Debit , Credit , DocDate ,Debit Amount ,AcntCode VisitorAcntCode 
into #tblPayAll
 FROM          acc.tblVoucherDtl		 where 1=0
  

set @StrSelect =  '	
insert into  #tblPayAll( 
			SerialNo ,DocRowNo , RecDesc  , SourceProcessID ,SourceProcessNo ,SourceFiscalYear ,SourceSerialNo  ,SourceDocRowNo,
							BaseID  ,AcntCode ,Debit,Credit ,DocDate, Amount , VisitorAcntCode)
		SELECT D.* From (
					SELECT     SerialNo, DocRowNo, RecDesc, D.SourceProcessID, D.SourceProcessNo, D.SourceFiscalYear, D.SourceSerialNo,D.SourceDocRowNo,
						 BaseID, AcntCode, Debit,Credit, DocDate, 0 as Amount,VisitorAcntCode
					FROM          acc.tblVoucherDtl D where D.VchKind<>0 ) D'

if (@NotUse=1)
begin
set @StrSelect = @StrSelect+ ' 	inner join 
	(	select SourceProcessID, SourceProcessNo, SourceFiscalYear, SourceSerialNo,SourceDocRowNo FROM          acc.tblVoucherDtl D  where D.VchKind<>0
	except 	
		select SourceProcessID1, SourceProcessNo1, SourceFiscalYear1, SourceSerialNo1,SourceDocRowNo1 from acc.tblAccState	 where  PPFSD1<>PPFSD2
	except 	
		select SourceProcessID2, SourceProcessNo2, SourceFiscalYear2, SourceSerialNo2,SourceDocRowNo2 from acc.tblAccState	 where  PPFSD1<>PPFSD2
	)a	
	on D.SourceProcessID=a.SourceProcessID and  D.SourceProcessNo=a.SourceProcessNo and D.SourceFiscalYear=a.SourceFiscalYear and  D.SourceSerialNo=a.SourceSerialNo and  D.SourceDocRowNo=a.SourceDocRowNo
		 '
		 
		set @StrWhere = @StrWhere + ' AND D.Debit>0  AND D.SourceProcessID in (90,100)' 
end
set @StrSelect = @StrSelect+ '		WHERE ' + @StrWhere 
	Print @StrSelect;	
	Exec sp_executesql @StrSelect;

	set @StrSelect =  'select *
						,pub.GetCodeName(D.AcntCode, ' + str(@LangID)+') as AcntName
						,pub.GetCodeName(D.VisitorAcntCode,  ' + str(@LangID)+')as VisitorName
						from  #tblPayAll D
						order by D.AcntCode,D.VisitorAcntCode,D.Debit,D.Credit'

	Print @StrSelect;	
	Exec sp_executesql @StrSelect;
	
	
END
GO
