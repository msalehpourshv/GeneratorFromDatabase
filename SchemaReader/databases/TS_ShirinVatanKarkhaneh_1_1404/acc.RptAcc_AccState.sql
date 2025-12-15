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
Create PROCEDURE [acc].[RptAcc_AccState]
	@SelectedAcnt1		int = 0,
	@SelectedAcnt2		int = 0,
	@SelectedAcnt3		int = 0,
	@SelectedAcnt4		int = 0,
	@SelectedVisitor1	int = 0, 
	@SelectedVisitor2	int = 0, 
	@SelectedVisitor3	int = 0, 
	@SelectedVisitor4	int = 0,
	@HDocDateFr			Char(10) = Null,
	@HDocDateTo			Char(10) = Null,
	@SettlementDateFr			Char(10) = Null,
	@SettlementDateTo			Char(10) = Null,
	@PDocDateFr			Char(10) = Null,
	@PDocDateTo			Char(10) = Null,
	@ChequeDateFr			Char(10) = Null,
	@ChequeDateTo			Char(10) = Null,
	@ExtraOptions			VarChar(1000) = '111', -- bit array options
	@RepOptions			VarChar(10) = '111', -- bit array options
	@RepInfo			NVarChar(100) = '1@1@1' -- bit array options
WITH ENCRYPTION
AS

Declare @StrSelect1	NVarChar(max);
Declare @StrSelect2	NVarChar(max);
Declare @StrWhere	NVarChar(max);



Declare @SortByName		Bit; -- مرتب بر اساس اسامی حسابها باشد یا کد حسابها؟
Declare @UseDateFilter	Bit; 
Declare @WithVisitor	bit;
Declare @WithBase	bit;
Declare @ShowZero	bit;
Declare @ShowNoVisitorAccount bit;
Declare @ShowAmountZero bit;
Declare @DatoFilterSale bit;

Declare @AcntCode Varchar(20);

DECLARE	@LangID			Char(1);
DECLARE	@SessionNo		Int; -- برای حالت کدهای انتخابی
DECLARE	@ReportID		Int; -- برای حالت کدهای انتخابی
DECLARE	@Amount		Int; 
DECLARE	@Pays		Int; 
DECLARE	@DaysFrom		Int; 
DECLARE	@DaysTo		Int; 

Declare @StrWhereAcc	NVarChar(max);

Declare @StrWherePay	NVarChar(max);

Declare @StrWhereSale	NVarChar(max);

BEGIN -- ============================ S T A R T =====================================================

	set @LangID		= pub.funSplitString(@RepInfo, '@', 1);
	set @SessionNo	= pub.funSplitString(@RepInfo, '@', 2);
	set @ReportID	= pub.funSplitString(@RepInfo, '@', 3);
	
	
	SET @Amount		 = LTrim(pub.funSplitString(@ExtraOptions, '@', 1)); 
	SET @DaysFrom		 = LTrim(pub.funSplitString(@ExtraOptions, '@', 2)); 
	SET @DaysTo		 = LTrim(pub.funSplitString(@ExtraOptions, '@', 3)); 
	SET @Pays		 = LTrim(pub.funSplitString(@ExtraOptions, '@', 4)); 
		
	
	if (@SelectedAcnt1	Is Null)	set @SelectedAcnt1 = 0
	if (@SelectedAcnt2	Is Null)	set @SelectedAcnt2 = 0
	if (@SelectedAcnt3	Is Null)	set @SelectedAcnt3 = 0
	if (@SelectedAcnt4	Is Null)	set @SelectedAcnt4 = 0
	if (@SelectedVisitor1 Is Null)	set @SelectedVisitor1 = 0;
	if (@SelectedVisitor2 Is Null)	set @SelectedVisitor2 = 0;
	if (@SelectedVisitor3 Is Null)	set @SelectedVisitor3 = 0;
	if (@SelectedVisitor4 Is Null)	set @SelectedVisitor4 = 0;
	
	SET @SortByName		= Substring(@RepOptions, 1, 1)
	SET @WithVisitor	= Substring(@RepOptions, 2, 1)
	

	
	set @StrWhere = ' Where 1=1 '
	set @StrWhereAcc = ' Where 1=1 '
	set @StrWherePay = ' Where 1=1 '
	set @StrWhereSale = ' Where 1=1 '
	
	
	------@StrWhere----------------------------------------------------------------------------------------
	
	if (@SelectedAcnt1 > 0)
		set @StrWhere = @StrWhere + ' AND ' + pub.funGetFilterString(@SessionNo, @ReportID, @SelectedAcnt1, 'AcntCode')
	if (@SelectedAcnt2 > 0)
		set @StrWhere = @StrWhere + ' AND ' + pub.funGetFilterString(@SessionNo, @ReportID, @SelectedAcnt2, 'AcntCode')
	if (@SelectedAcnt3 > 0)
		set @StrWhere = @StrWhere + ' AND ' + pub.funGetFilterString(@SessionNo, @ReportID, @SelectedAcnt3, 'AcntCode')
	if (@SelectedAcnt4 > 0)
		set @StrWhere = @StrWhere + ' AND ' + pub.funGetFilterString(@SessionNo, @ReportID, @SelectedAcnt4, 'AcntCode')
				
	if (@HDocDateFr Is Not Null)
			set @StrWhere = @StrWhere + ' AND HDocDate >= ''' + @HDocDateFr + ''''
	if (@HDocDateTo Is Not Null)
			set @StrWhere = @StrWhere + ' AND HDocDate <= ''' + @HDocDateTo + ''''
	
		

if (@SettlementDateFr Is Not Null)
			set @StrWhere = @StrWhere + ' AND SettlementDate >= ''' + @SettlementDateFr + ''''
	if (@SettlementDateTo Is Not Null)
			set @StrWhere = @StrWhere + ' AND SettlementDate <= ''' + @SettlementDateTo + ''''
	
	if (@PDocDateFr Is Not Null)
			set @StrWhere = @StrWhere + ' AND PDocDate >= ''' + @PDocDateFr + ''''
	if (@PDocDateTo Is Not Null)
			set @StrWhere = @StrWhere + ' AND PDocDate <= ''' + @PDocDateTo + ''''
			
	if (@ChequeDateFr Is Not Null)
			set @StrWhere = @StrWhere + ' AND ChequeDate >= ''' + @ChequeDateFr + ''''
	if (@ChequeDateTo Is Not Null)
			set @StrWhere = @StrWhere + ' AND ChequeDate <= ''' + @ChequeDateTo + ''''

	if (@WithVisitor =0)
			set @StrWhere = @StrWhere + ' AND VisitorAcntCode <> '''''
	
	

	-- Visitor --
	if (@WithVisitor =0)
	begin
	
	if (@SelectedVisitor1 > 0)
		set @StrWhere = @StrWhere + ' AND (' + pub.funGetFilterString(@SessionNo, @ReportID, @SelectedVisitor1, 'VisitorAcntCode') + ')'	
	if (@SelectedVisitor2 > 0)
		set @StrWhere = @StrWhere + ' AND (' + pub.funGetFilterString(@SessionNo, @ReportID, @SelectedVisitor2, 'VisitorAcntCode') + ')'
	if (@SelectedVisitor3 > 0)
		set @StrWhere = @StrWhere + ' AND (' + pub.funGetFilterString(@SessionNo, @ReportID, @SelectedVisitor3, 'VisitorAcntCode') + ')'
	if (@SelectedVisitor4 > 0)
		set @StrWhere = @StrWhere + ' AND (' + pub.funGetFilterString(@SessionNo, @ReportID, @SelectedVisitor4, 'VisitorAcntCode') + ')'
	end
	-- Visitor --
	if (@WithVisitor =1)
	begin
	
	if (@SelectedVisitor1 > 0)
		set @StrWhere = @StrWhere + ' AND (' + pub.funGetFilterString(@SessionNo, @ReportID, @SelectedVisitor1, 'VisitorAcntCode') + '  or VisitorAcntCode = '''' )'	
	if (@SelectedVisitor2 > 0)
		set @StrWhere = @StrWhere + ' AND (' + pub.funGetFilterString(@SessionNo, @ReportID, @SelectedVisitor2, 'VisitorAcntCode') + '   or VisitorAcntCode = '''' )'
	if (@SelectedVisitor3 > 0)
		set @StrWhere = @StrWhere + ' AND (' + pub.funGetFilterString(@SessionNo, @ReportID, @SelectedVisitor3, 'VisitorAcntCode') + '  or VisitorAcntCode = '''' )'
	if (@SelectedVisitor4 > 0)
		set @StrWhere = @StrWhere + ' AND (' + pub.funGetFilterString(@SessionNo, @ReportID, @SelectedVisitor4, 'VisitorAcntCode') + '  or VisitorAcntCode = '''' )'
	end
		
	------@StrWhere----------------------------------------------------------------------------------------	          
	------@StrWhereAcc----------------------------------------------------------------------------------------	          
	
	if (@SelectedAcnt1 > 0)
		set @StrWhereAcc = @StrWhereAcc + ' AND ' + pub.funGetFilterString(@SessionNo, @ReportID, @SelectedAcnt1, 'AcntCode')
	if (@SelectedAcnt2 > 0)
		set @StrWhereAcc = @StrWhereAcc + ' AND ' + pub.funGetFilterString(@SessionNo, @ReportID, @SelectedAcnt2, 'AcntCode')
	if (@SelectedAcnt3 > 0)
		set @StrWhereAcc = @StrWhereAcc + ' AND ' + pub.funGetFilterString(@SessionNo, @ReportID, @SelectedAcnt3, 'AcntCode')
	if (@SelectedAcnt4 > 0)
		set @StrWhereAcc = @StrWhereAcc + ' AND ' + pub.funGetFilterString(@SessionNo, @ReportID, @SelectedAcnt4, 'AcntCode')
				
		set @StrWhereAcc = @StrWhereAcc + ' AND  Amount>'+ str(@Pays)
	
	
	------@StrWhereAcc----------------------------------------------------------------------------------------	          
	------@@StrWhereSale----------------------------------------------------------------------------------------	          
	set @StrWhereSale=@StrWhereAcc
				
	if (@HDocDateFr Is Not Null)
			set @StrWhereSale = @StrWhereSale + ' AND DocDate >= ''' + @HDocDateFr + ''''
	if (@HDocDateTo Is Not Null)
			set @StrWhereSale = @StrWhereSale + ' AND DocDate <= ''' + @HDocDateTo + ''''
	
	if (@WithVisitor =0)
			set @StrWhereSale = @StrWhereSale + ' AND VisitorAcntCode <> '''''
	
	

	-- Visitor --
	if (@WithVisitor =0)
	begin
	
	if (@SelectedVisitor1 > 0)
		set @StrWhereSale = @StrWhereSale + ' AND (' + pub.funGetFilterString(@SessionNo, @ReportID, @SelectedVisitor1, 'VisitorAcntCode') + ')'	
	if (@SelectedVisitor2 > 0)
		set @StrWhereSale = @StrWhereSale + ' AND (' + pub.funGetFilterString(@SessionNo, @ReportID, @SelectedVisitor2, 'VisitorAcntCode') + ')'
	if (@SelectedVisitor3 > 0)
		set @StrWhereSale = @StrWhereSale + ' AND (' + pub.funGetFilterString(@SessionNo, @ReportID, @SelectedVisitor3, 'VisitorAcntCode') + ')'
	if (@SelectedVisitor4 > 0)
		set @StrWhereSale = @StrWhereSale + ' AND (' + pub.funGetFilterString(@SessionNo, @ReportID, @SelectedVisitor4, 'VisitorAcntCode') + ')'
	end
	-- Visitor --
	if (@WithVisitor =1)
	begin
	
	if (@SelectedVisitor1 > 0)
		set @StrWhereSale = @StrWhereSale + ' AND (' + pub.funGetFilterString(@SessionNo, @ReportID, @SelectedVisitor1, 'VisitorAcntCode') + '  or VisitorAcntCode = '''' )'	
	if (@SelectedVisitor2 > 0)
		set @StrWhereSale = @StrWhereSale + ' AND (' + pub.funGetFilterString(@SessionNo, @ReportID, @SelectedVisitor2, 'VisitorAcntCode') + '   or VisitorAcntCode = '''' )'
	if (@SelectedVisitor3 > 0)
		set @StrWhereSale = @StrWhereSale + ' AND (' + pub.funGetFilterString(@SessionNo, @ReportID, @SelectedVisitor3, 'VisitorAcntCode') + '  or VisitorAcntCode = '''' )'
	if (@SelectedVisitor4 > 0)
		set @StrWhereSale = @StrWhereSale + ' AND (' + pub.funGetFilterString(@SessionNo, @ReportID, @SelectedVisitor4, 'VisitorAcntCode') + '  or VisitorAcntCode = '''' )'
	end
	
	------@@StrWhereSale----------------------------------------------------------------------------------------	          
	------@@StrWherePay----------------------------------------------------------------------------------------	          
	
		
	
	if (@PDocDateFr Is Not Null)
			set @StrWherePay = @StrWherePay + ' AND DocDate >= ''' + @PDocDateFr + ''''
	if (@PDocDateTo Is Not Null)
			set @StrWherePay = @StrWherePay + ' AND DocDate <= ''' + @PDocDateTo + ''''
			
	if (@ChequeDateFr Is Not Null)
			set @StrWherePay = @StrWherePay + ' AND ChequeDate >= ''' + @ChequeDateFr + ''''
	if (@ChequeDateTo Is Not Null)
			set @StrWherePay = @StrWherePay + ' AND ChequeDate <= ''' + @ChequeDateTo + ''''

		
	------@@StrWherePay----------------------------------------------------------------------------------------	          
	
		          update   acc.tblAccState 
		          set  VisitorAcntCode   = isnull(d.VisitorAcntCode ,'')  from acc.tblAccState V2 LEFT OUTER JOIN
                      inv.tblStorageDocsHdr AS d ON V2.SourceProcessID1 = d.ProcessID AND V2.SourceProcessNo1 = d.ProcessNo AND V2.SourceFiscalYear1 = d.FiscalYear AND 
                      V2.SourceSerialNo1 = d.SerialNo AND V2.AcntCode = d.AcntCode
                      where  SourceProcessID1 =SourceProcessID2 AND SourceProcessNo1=SourceProcessNo2 and SourceFiscalYear1 =SourceFiscalYear2
                      and  SourceSerialNo1= SourceSerialNo2
           
	
set @StrSelect1 = '
select  *,DATEDIFF(day, [pub].[funChangeDate_PersianToGergorian] (SettlementDate ), [pub].[funChangeDate_PersianToGergorian](ChequeDate  ) ) Days
,pub.GetCodeName(AcntCode, '+@LangID+')as AcntName
,pub.GetCodeName(VisitorAcntCode, '+@LangID+')as VisitorName
from (select  S.AcntCode, S.VisitorAcntCode, H.SerialNo HSerialNo,H.DocDate HDocDate, Case When  H.SettlementDate='''' then H.DocDate else  H.SettlementDate end SettlementDate,H.Price
,P.SerialNo PSerialNo,P.DocDate PDocDate,S.Amount , case when P.ChequeDate='''' then P.DocDate else P.ChequeDate end ChequeDate 
,(Select Sum(Amount)  From acc.tblAccState a 
Where a.AcntCode=S.AcntCode and a.SourceSerialNo1 =S.SourceSerialNo1 and a.SourceDocRowNo1 =S.SourceDocRowNo1 and a.SourceProcessID1=S.SourceProcessID1 and a.SourceProcessNo1=S.SourceProcessNo1 and a.SourceFiscalYear1=S.SourceFiscalYear1
GROUP by AcntCode,SourceSerialNo1 
) SumAmount From 
(Select * FROM acc.tblAccState  '+ @StrWhereAcc +' ) S
inner join (  Select *  from  inv.tblStorageDocsHdr '+ @StrWhereSale +')H  
On H.SerialNo =S.SourceSerialNo1 and H.ProcessID=S.SourceProcessID1 and H.ProcessNo=S.SourceProcessNo1 and H.FiscalYear=S.SourceFiscalYear1
and H.AcntCode=S.AcntCode
inner join (Select P.*  from trs.tblPayDtl P inner join  acc .tblVoucherDtl V
			on P.ProcessID=V.SourceProcessID And P.ProcessNo=V.SourceProcessNo And P.FiscalYear=V.SourceFiscalYear And P.SerialNo=V.SourceSerialNo
			And P.DocRowNo=V.SourceDocRowNo And  P.CreditCode=V.AcntCode '+ @StrWherePay +') P 
On P.SerialNo =S.SourceSerialNo2 and P.ProcessID=S.SourceProcessID2 and P.ProcessNo=S.SourceProcessNo2 and P.FiscalYear=S.SourceFiscalYear2
and P.CreditCode=S.AcntCode  AND  P.DocRowNo =S.SourceDocRowNo2 
union all
  select  S.AcntCode, S.VisitorAcntCode, H.SerialNo HSerialNo,H.DocDate HDocDate, Case When  H.SettlementDate='''' then H.DocDate else  H.SettlementDate end SettlementDate,H.Price
,P.SerialNo PSerialNo,P.DocDate PDocDate,S.Amount , Case When  P.SettlementDate='''' then P.DocDate else  P.SettlementDate end ChequeDate 
,(Select Sum(Amount)  From acc.tblAccState a 
Where a.AcntCode=S.AcntCode and a.SourceSerialNo1 =S.SourceSerialNo1 and a.SourceDocRowNo1 =S.SourceDocRowNo1 and a.SourceProcessID1=S.SourceProcessID1 and a.SourceProcessNo1=S.SourceProcessNo1 and a.SourceFiscalYear1=S.SourceFiscalYear1
GROUP by AcntCode,SourceSerialNo1 
) SumAmount
From (Select * FROM acc.tblAccState  '+ @StrWhereAcc +' )   S
inner join (  Select *  from  inv.tblStorageDocsHdr '+ @StrWhereSale +')H  
On H.SerialNo =S.SourceSerialNo1 and H.ProcessID=S.SourceProcessID1 and H.ProcessNo=S.SourceProcessNo1 and H.FiscalYear=S.SourceFiscalYear1
and H.AcntCode=S.AcntCode
inner join (  Select * from  inv.tblStorageDocsHdr '+ @StrWhereSale +') P 
On P.SerialNo =S.SourceSerialNo2 and P.ProcessID=S.SourceProcessID2 and P.ProcessNo=S.SourceProcessNo2 and P.FiscalYear=S.SourceFiscalYear2
and P.AcntCode=S.AcntCode
) D '+@StrWhere
if @DaysFrom<>0
set @StrSelect1  =@StrSelect1+' and DATEDIFF(day, [pub].[funChangeDate_PersianToGergorian] (SettlementDate ), [pub].[funChangeDate_PersianToGergorian](ChequeDate  ) )>=' + str(@DaysFrom)
if @DaysTo<>0
set @StrSelect1  =@StrSelect1+ ' and DATEDIFF(day, [pub].[funChangeDate_PersianToGergorian] (SettlementDate ), [pub].[funChangeDate_PersianToGergorian](ChequeDate  ) )<=' + str(@DaysTo)

	print   @StrSelect1;
		print +@StrWhere
	Exec sp_executesql  @StrSelect1;


	END
GO
