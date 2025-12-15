USE TS_ShirinVatanKarkhaneh_1_1404
GO
SET ANSI_NULLS, QUOTED_IDENTIFIER ON
GO
-- =========== TS-QC:UPDATED ====================
-- Author		 : TakroSystem\Ahmadnejad
-- Create date   : 1386/02/27
-- Viewed By	 : 
-- Last Modified : 1392/04/18
-- Last Modifier : TakroSystem\Zia
-- Description	 : <Payable Documents Report>
-- ----------------------------------------------
-- گزارش مروری بابت پرداختی ها - آمار
-- ==============================================
CREATE PROCEDURE [trs].[SpBehalfPaymentReviewStatistics] 
(	@LanguageID char(1),
	@FromDate char(10),
	@ToDate char(10),	
	@ProcessNo nvarchar(100),
	@Behalf nvarchar(max),
	@FiscalYear char(4) 
)  WITH ENCRYPTION        
AS 
BEGIN

DECLARE @Trs1 bit 
DECLARE @Trs2 bit

set @Trs1=substring(@ProcessNo , 1,1)
set @Trs2=substring(@ProcessNo , 2,1)

DECLARE @StrQuery nvarchar(max)=''
DECLARE @StrQueryCash nvarchar(max)=''
DECLARE @StrQueryCheque nvarchar(max)=''
DECLARE @StrWhere nvarchar(max)=''





SET @StrWhere=@StrWhere+'AND (PH.FiscalYear ='+@FiscalYear+') AND (BD.LanguageID = '+ @LanguageID +') '
SET @StrWhere=@StrWhere + 'AND (PH.DocDate >='''+@FromDate+''') AND (PH.DocDate <='''+@ToDate +''') '


if(@Trs1=1 and @Trs2 =1) 
SET @StrWhere=@StrWhere+' AND (PH.ProcessNo in (1,2))'

if(@Trs1=1 and @Trs2 =0) 
SET @StrWhere=@StrWhere+' AND (PH.ProcessNo in (1))'

if(@Trs1=0 and @Trs2 =1) 
SET @StrWhere=@StrWhere+' AND (PH.ProcessNo in (2))'

if(@Trs1=0 and @Trs2 =0) 
SET @StrWhere=@StrWhere+' AND (PH.ProcessNo in (1,2))'

if(@Behalf<>'' or @Behalf is not null)
SET @StrWhere=@StrWhere+@Behalf 




SET @StrQueryCash='SELECT        BD.BehalfID, BD.BehalfName, SUM(PD.Amount) AS AmountCash, 0 AS AmountCheque , 0 as HeadCheque , ( CEILING( Sum( PD.Amount * DATEDIFF(day,  pub.funChangeDate_PersianToGergorian(PD.DocDate), pub.funChangeDate_PersianToGergorian(PD.DocDate)))/(Sum(PD.Amount)))) as HeadCash
FROM            trs.tblPayHdr AS PH INNER JOIN
                         trs.tblPayDtl AS PD ON PH.FiscalYear = PD.FiscalYear AND PH.ProcessID = PD.ProcessID AND PH.SerialNo = PD.SerialNo AND 
                         PH.ProcessNo = PD.ProcessNo INNER JOIN
                         trs.tblBehalfDtl AS BD ON BD.BehalfID = PH.BehalfID  
					WHERE	 (PH.ProcessID IN (2, 4)) AND (PD.PayTypeID IN (1, 2, 3, 4, 5, 30, 35, 36, 37))'


SET  @StrQueryCash= @StrQueryCash +@StrWhere
SET  @StrQueryCash=@StrQueryCash+' GROUP BY BD.BehalfID, BD.BehalfName'


set @StrQueryCheque=' SELECT        BD.BehalfID, BD.BehalfName, 0 AS EXPR1, SUM(PD.Amount) AS AmountCheque  , (CEILING( Sum( PD.Amount * DATEDIFF(day,  pub.funChangeDate_PersianToGergorian(PD.DocDate), pub.funChangeDate_PersianToGergorian(PD.ChequeDate)))/(Sum(PD.Amount)))) as HeadCheque , 0 as HeadCash
                     FROM            trs.tblPayHdr AS PH INNER JOIN
                     trs.tblPayDtl AS PD ON PH.FiscalYear = PD.FiscalYear AND PH.ProcessID = PD.ProcessID AND PH.SerialNo = PD.SerialNo AND 
                     PH.ProcessNo = PD.ProcessNo INNER JOIN
                     trs.tblBehalfDtl AS BD ON BD.BehalfID = PH.BehalfID
					 WHERE  (PH.ProcessID IN (4, 4)) AND (PD.PayTypeID IN (8, 28, 7))'


SET @StrQueryCheque=@StrQueryCheque+@StrWhere


SET @StrQueryCheque=@StrQueryCheque+' GROUP BY BD.BehalfID, BD.BehalfName'

SET @StrQuery=' SELECT BehalfID,BehalfName,AmountCash,AmountCheque, (AmountCash+AmountCheque) as Amount , HeadCheque , HeadCash    from(
select  BehalfID ,BehalfName , Sum(AmountCash) As AmountCash ,  Sum(AmountCheque) as AmountCheque ,Sum( HeadCheque )HeadCheque , sum( HeadCash)  HeadCash  from ('

SET @StrQuery=@StrQuery+@StrQueryCash + ' UNION all '+@StrQueryCheque +' )as A
group by BehalfID, BehalfName 
)B'

--select @StrQuery

PRINT @StrQuery

EXECUTE sp_executesql @StrQuery





END
GO
