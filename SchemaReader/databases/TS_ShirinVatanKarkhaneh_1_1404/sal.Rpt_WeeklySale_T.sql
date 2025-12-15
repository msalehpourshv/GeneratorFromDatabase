USE TS_ShirinVatanKarkhaneh_1_1404
GO
SET ANSI_NULLS, QUOTED_IDENTIFIER ON
GO
-- =========== TS-QC:UPDATED ====================
-- Author		 : TakroSystem  \ Nogrehpasand
-- Create date   : 1393/10/11
-- Viewed By	 : 
-- Last Modified : 
-- Last Modifier : 
-- Description	 :    
-- =============================================
create PROCEDURE [sal].[Rpt_WeeklySale_T] --2 
	@FDate varchar(10)='1393/07/23',
	@TDate varchar(10)='1393/07/29',
	@SelectedGoods	int = 0,
	@SelectedStore	int = 0,
	@SelectedAcnt1	int = 0,
	@SelectedAcnt2	int = 0,
	@SelectedAcnt3	int = 0,
	@SelectedAcnt4	int = 0,
	@SelectedVisitor1	int = 0,
	@SelectedVisitor2	int = 0,
	@SelectedVisitor3	int = 0,
	@SelectedVisitor4	int = 0,
	@AcntCode			varchar(20) ='111301',
	@RepOption nvarchar(500)='',
	@RepInfo NVarChar(100) = '1@1@1'
	 
WITH ENCRYPTION
AS

DECLARE @StrSelect		NVarChar(max);

DECLARE @StrWhere0      As Nvarchar(max);
DECLARE @StrWhere00      As Nvarchar(max);
DECLARE @StrWhere000      As Nvarchar(max);
DECLARE @StrWhere1      As Nvarchar(max);
DECLARE @StrWhere2      As Nvarchar(max);
DECLARE @StrWhere3      As Nvarchar(max);
DECLARE @StrWhere4      As Nvarchar(max);

set @StrWhere0=' D.DocDate>='''+ @FDate +''' AND D.DocDate<='''+@TDate+''' '
set @StrWhere00=' D.DocDate<'''+ @FDate +''' AND D.DocDate>'''+@TDate+''' '
set @StrWhere000=' h.DocDate>='''+ @FDate +''' AND h.DocDate<='''+@TDate+''' '
set @StrWhere1=' AND 1=1 '
set @StrWhere2=' AND 1=1 '
set @StrWhere3=' AND 1=1 '
set @StrWhere4=' AND 1=1 '

DECLARE	@LangID			Char(1);
DECLARE	@SessionNo		Int; -- برای حالت کدهای انتخابی
DECLARE	@ReportID		Int; -- برای حالت کدهای انتخابی
DECLARE	@Remain		 As Nvarchar(max);  
DECLARE	@IsnotSaleRanain		char;

BEGIN 
	-- ============================ S T A R T =====================================================

	-- Init --------------------------
	SET NOCOUNT ON;
	 
SET @LangID		= pub.funSplitString(@RepInfo, '@', 1);
SET @SessionNo	= pub.funSplitString(@RepInfo, '@', 2);
SET @ReportID	= pub.funSplitString(@RepInfo, '@', 3);
SET @IsnotSaleRanain= subString(@RepOption,1,1);


IF (@SelectedGoods Is Null)		SET @SelectedGoods = 0;
IF (@SelectedStore Is Null)		SET @SelectedStore = 0;
IF (@SelectedAcnt1 Is Null)		SET @SelectedAcnt1 = 0;
IF (@SelectedAcnt2 Is Null)		SET @SelectedAcnt2 = 0;
IF (@SelectedAcnt3 Is Null)		SET @SelectedAcnt3 = 0;
IF (@SelectedAcnt4 Is Null)		SET @SelectedAcnt4 = 0;
IF (@SelectedVisitor1 Is Null)	SET @SelectedVisitor1 = 0;
IF (@SelectedVisitor2 Is Null)	SET @SelectedVisitor2 = 0;
IF (@SelectedVisitor3 Is Null)	SET @SelectedVisitor3 = 0;
IF (@SelectedVisitor4 Is Null)	SET @SelectedVisitor4 = 0;
	
	If (@SelectedStore > 0)
		SET @StrWhere1 = @StrWhere1 + ' AND ' + pub.funGetFilterString(@SessionNo, @ReportID, @SelectedStore, 'D.StoreID')
	
	If (@SelectedGoods > 0)
		SET @StrWhere1 = @StrWhere1 + ' AND ' + pub.funGetFilterString(@SessionNo, @ReportID, @SelectedGoods, 'D.GoodsID')

	If (@SelectedAcnt1 > 0)
		SET @StrWhere2 = @StrWhere2 + ' AND ' + pub.funGetFilterString(@SessionNo, @ReportID, @SelectedAcnt1, 'D.AcntCode')
	If (@SelectedAcnt2 > 0)
		SET @StrWhere2 = @StrWhere2 + ' AND ' + pub.funGetFilterString(@SessionNo, @ReportID, @SelectedAcnt2, 'D.AcntCode')
	If (@SelectedAcnt3 > 0)
		SET @StrWhere2 = @StrWhere2 + ' AND ' + pub.funGetFilterString(@SessionNo, @ReportID, @SelectedAcnt3, 'D.AcntCode')
	If (@SelectedAcnt4 > 0)
		SET @StrWhere2 = @StrWhere2 + ' AND ' + pub.funGetFilterString(@SessionNo, @ReportID, @SelectedAcnt4, 'D.AcntCode')
	
	If (@SelectedAcnt1 > 0)
		SET @StrWhere4 = @StrWhere4 + ' AND ' + pub.funGetFilterString(@SessionNo, @ReportID, @SelectedAcnt1, 'D.CreditCode')
	If (@SelectedAcnt2 > 0)
		SET @StrWhere4 = @StrWhere4 + ' AND ' + pub.funGetFilterString(@SessionNo, @ReportID, @SelectedAcnt2, 'D.CreditCode')
	If (@SelectedAcnt3 > 0)
		SET @StrWhere4 = @StrWhere4 + ' AND ' + pub.funGetFilterString(@SessionNo, @ReportID, @SelectedAcnt3, 'D.CreditCode')
	If (@SelectedAcnt4 > 0)
		SET @StrWhere4 = @StrWhere4 + ' AND ' + pub.funGetFilterString(@SessionNo, @ReportID, @SelectedAcnt4, 'D.CreditCode')

	If (@SelectedVisitor1 > 0)
		SET @StrWhere3 = @StrWhere3 + ' AND ' + pub.funGetFilterString(@SessionNo, @ReportID, @SelectedVisitor1, 'D.VisitorAcntCode')
	If (@SelectedVisitor2 > 0)
		SET @StrWhere3 = @StrWhere3 + ' AND ' + pub.funGetFilterString(@SessionNo, @ReportID, @SelectedVisitor2, 'D.VisitorAcntCode')
	If (@SelectedVisitor3 > 0)
		SET @StrWhere3 = @StrWhere3 + ' AND ' + pub.funGetFilterString(@SessionNo, @ReportID, @SelectedVisitor3, 'D.VisitorAcntCode')
	If (@SelectedVisitor4 > 0)
		SET @StrWhere3 = @StrWhere3 + ' AND ' + pub.funGetFilterString(@SessionNo, @ReportID, @SelectedVisitor4, 'D.VisitorAcntCode')
	
	if @IsnotSaleRanain='1'
		set @Remain='(
		SELECT isnull(SUM(Debit-Credit),0)
		from acc.tblVoucherDtl D
		WHERE AcntCode like '''+ @AcntCode +'%''	
		AND  SourceProcessID in (90,100,1) and D.DocDate<'''+ @FDate +'''
		)'
	else
		set @Remain='(
		SELECT isnull(SUM(Debit-Credit),0)
		from acc.tblVoucherDtl D
		WHERE AcntCode like '''+ @AcntCode +'%''	
		AND  D.DocDate<'''+ @FDate +'''
		)'
																												  
set @StrSelect='
select '+ @Remain +' Remain
,
(
SELECT isnull(SUM(GoodsPrice*GoodsQuantity),0)
from inv.tblStorageDocsDtl D
where ProcessID = 90 
AND '+ @StrWhere0 +  @StrWhere1 + @StrWhere2 +@StrWhere3+'
) Sale
,
(
SELECT isnull(SUM(Discount+Discount2+Discount3+TotalLineDiscount),0)
from inv.tblStorageDocsHdr D
where ProcessID = 90  
AND '+@StrWhere0+  @StrWhere1 + @StrWhere2 +@StrWhere3+'
)Discount
,
(
select SUM(ad.Price) 
from sal.tblAfterSaleBillHdr h
inner join sal.tblAfterSaleBillDtl ad
on h.ProcessID=ad.ProcessID
and h.SerialNo=ad.SerialNo
inner join inv.tblStorageDocsHdr D
on ad.BaseProcessID=D.ProcessID
and ad.BaseProcessNo=D.ProcessNo
and ad.BaseFiscalYear=D.FiscalYear
and ad.BaseSerialNo=D.SerialNo
where ad.ProcessID=212 
AND ' + @StrWhere000 + @StrWhere1 + @StrWhere2 +'
)DistDiscount
,
(
SELECT isnull(SUM(D.GoodsPrice*D.GoodsQuantity),0)
from inv.tblStorageDocsDtl D
inner join (SELECT *
		from inv.tblStorageDocsDtl D
		where ProcessID = 90  
		AND '+@StrWhere00+') S
ON D.BaseProcessID=S.ProcessID	AND D.BaseProcessNo=S.ProcessNo AND
D.BaseFiscalYear=S.FiscalYear AND D.BaseSerialNo=S.SerialNo 

where D.ProcessID = 100 
AND '+ @StrWhere0+  @StrWhere1 + @StrWhere2 +@StrWhere3+'
)ReturnBase,
(
SELECT isnull(SUM(D.GoodsPrice*D.GoodsQuantity),0) 
from inv.tblStorageDocsDtl D
where D.ProcessID = 100 
AND '+@StrWhere0 +  @StrWhere1 + @StrWhere2 +@StrWhere3+'
)ReturnNotBase
,(
select isnull(SUM(D.Amount),0) from trs.tblPayHdr H
inner join trs.tblPayDtl D
ON H.ProcessID=D.ProcessID and H.ProcessNo=D.ProcessNo
 and H.FiscalYear=D.FiscalYear and H.SerialNo=D.SerialNo
INNER JOIN
(
SELECT * FROM inv.tblStorageDocsHdr D
where ProcessID = 90 
AND '+@StrWhere0+@StrWhere1+@StrWhere2 +@StrWhere3+'
) S
ON H.BaseProcessID=S.ProcessID	AND H.BaseProcessNo=S.ProcessNo AND
H.BaseFiscalYear=S.FiscalYear AND H.BaseSerialNo=S.SerialNo
where H.ProcessID=1 AND D.PayTypeID IN (6,26) 
AND '+@StrWhere0+ '
)PayCheque
,(
select isnull(SUM(D.Amount),0) from  trs.tblPayDtl D        
where D.ProcessID=1 AND D.PayTypeID IN (6,26) 
AND '+@StrWhere0 + @StrWhere4 +@StrWhere3+'
)PayNotBaseCheque
,(
select isnull(SUM(D.Amount),0) from trs.tblPayHdr H
inner join trs.tblPayDtl D
ON H.ProcessID=D.ProcessID and H.ProcessNo=D.ProcessNo
 and H.FiscalYear=D.FiscalYear and H.SerialNo=D.SerialNo
INNER JOIN
(
SELECT * FROM inv.tblStorageDocsHdr D
where ProcessID = 90 AND '+ @StrWhere0 +@StrWhere1+@StrWhere2 +@StrWhere3+'
) S
ON H.BaseProcessID=S.ProcessID	AND H.BaseProcessNo=S.ProcessNo AND
H.BaseFiscalYear=S.FiscalYear AND H.BaseSerialNo=S.SerialNo
where D.ProcessID=1  AND D.PayTypeID NOT IN (6,26) 
AND '+@StrWhere0 + '
)PayCash
,(
select isnull(SUM(D.Amount),0) from  trs.tblPayDtl D        
where D.ProcessID=1 AND D.PayTypeID NOT IN (6,26) 
AND '+@StrWhere0 + @StrWhere4 +@StrWhere3+'
)PayNotBaseCash'

print @StrSelect;
exec sp_executesql @StrSelect;

end
GO
