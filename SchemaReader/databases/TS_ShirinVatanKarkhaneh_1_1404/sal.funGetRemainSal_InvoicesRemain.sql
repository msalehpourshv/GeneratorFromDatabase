USE TS_ShirinVatanKarkhaneh_1_1404
GO
SET ANSI_NULLS, QUOTED_IDENTIFIER ON
GO
Create FUNCTION [sal].[funGetRemainSal_InvoicesRemain]
(
	@ProcessID int=90
	,@ProcessNo  int=1
	,@FiscalYear  int=93
	,@SerialNo  int=1
	
)
RETURNS bigint
WITH ENCRYPTION
AS
BEGIN

Declare @AcntCode varchar(20);  
Declare @VchDate varchar(20);  
select @AcntCode =AcntCode ,@VchDate=DocDate FROM inv.tblStorageDocsHdr 
where ProcessID=@ProcessID and 	ProcessNo  =@ProcessNo and 	FiscalYear =@FiscalYear and 	SerialNo  =@SerialNo  

Declare @Ret bigint

 select @Ret=
 isnull (sum(Remain),0)

from (
	SELECT A.SettlementDate,(PureAmount - ISNULL(SumPayedAmount,0)) Remain
	FROM(
	SELECT H.ProcessID,H.ProcessNo,H.FiscalYear,H.SerialNo,VchDate,H.SaleTypeID,SumGoodsPrice - D.TotalLineDiscount - H.Discount-H.Discount2-H.Discount3-H.TransportationCost+H.TransportationIncome
	+H.PackingCost+H.TaxCost-H.VisitorCost-H.DistributeAmount+H.TaxOverWorthCost+
	H.TollOverWorthCost-H.FixCost -H.OtherCost +H.OtherIncome AS PureAmount
	, case  when H.SettlementDate='' then H.VchDate else H.SettlementDate end  as SettlementDate
	FROM inv.tblStorageDocsHdr H
	INNER JOIN (SELECT	ProcessID,ProcessNo,FiscalYear,SerialNo, SUM(ROUND(GoodsPrice *GoodsQuantity,0))SumGoodsPrice  ,SUM(ROUND(DiscountDtl,0))TotalLineDiscount
				FROM inv.tblStorageDocsDtl
				where ProcessID = @ProcessID
				GROUP BY ProcessID,ProcessNo,FiscalYear,SerialNo) D
	ON H.ProcessID=D.ProcessID AND H.ProcessNo=D.ProcessNo AND H.FiscalYear=D.FiscalYear AND H.SerialNo=D.SerialNo
	WHERE H.VchNo>0
		and   H.ProcessID = @ProcessID and H.ProcessNo=@ProcessNo and H.FiscalYear=@FiscalYear
		and H.SerialNo<=@SerialNo and H.AcntCode=@AcntCode
	) A
	LEFT JOIN pub.tblProcess P 
	ON P.ProcessID = A.ProcessID and P.ProcessNo = A.ProcessNo
	LEFT JOIN (SELECT BaseProcessID,BaseProcessNo,BaseFiscalYear,BaseSerialNo, SUM(PayedAmount)SumPayedAmount
			   FROM trs.tblSaleBillsDtl
			   GROUP BY BaseProcessID,BaseProcessNo,BaseFiscalYear,BaseSerialNo) S 
	ON S.BaseProcessID = A.ProcessID and S.BaseProcessNo = A.ProcessNo AND
	   S.BaseFiscalYear = A.FiscalYear and S.BaseSerialNo = A.SerialNo
	WHERE PureAmount - ISNULL(SumPayedAmount,0)>0 

) a

Return @Ret	

END
GO
