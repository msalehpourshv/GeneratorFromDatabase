USE TS_ShirinVatanKarkhaneh_1_1404
GO
SET ANSI_NULLS, QUOTED_IDENTIFIER ON
GO
-- =========== TS-QC:NOTOK ========================
-- Author        : jafari
-- Create date   : 1402/07/30
-- Viewed By	 : 
-- Last Modified : 
-- Description   : 
-- =============================================
Create PROCEDURE inv.sp_UpdateIsConfirmedStorageDocs
@ProcessID  int,
@ProcessNo	int,
@FiscalYear int,
@SerialNo	int
WITH ENCRYPTION
 AS
BEGIN
	DECLARE @StrErrorMessage NVARCHAR(MAX)

BEGIN TRY
	if (Select count(*)  from inv.tblStorageDocsHdr  a where  a.ProcessID = @ProcessID AND a.ProcessNo=@ProcessNo and a.FiscalYear=@FiscalYear   and a.SerialNo=@SerialNo and IsConfirmedManual=1 )=0
	update inv.tblStorageDocsHdr 
		set IsConfirmed= case when  a.Amount-a.AfterSaleDiscount<=(isnull(b.Amount,0)+isnull(c.Amount,0)+isnull(d.Amount,0) ) then 1 else 0 end                             
    from inv.tblStorageDocsHdr a
    left join 
	( select Sum(Amount-AfterSaleDiscount) Amount , H.BaseProcessID,H.BaseProcessNo,H.BaseFiscalYear,H.BaseSerialNo 
		from inv.tblStorageDocsHdr H
		where H.BaseProcessID=90
		group by H.BaseProcessID,H.BaseProcessNo,H.BaseFiscalYear,H.BaseSerialNo
	)  b 
	on a.ProcessID=b.BaseProcessID And a.ProcessNo=b.BaseProcessNo And a.FiscalYear=b.BaseFiscalYear And a.SerialNo=b.BaseSerialNo
	left join 
	( select   Sum (Amount)Amount , BaseProcessID,BaseProcessNo,BaseFiscalYear,BaseSerialNo 
		from
		(  --  در صورتی که دریافت چندتا باشد و یکی چند سرطی باشد تخفیف هدر تکرار نشود
		select Sum (Amount)+(H.DiscountAmount) Amount , H.BaseProcessID,H.BaseProcessNo,H.BaseFiscalYear,H.BaseSerialNo 
				from trs.tblPayHdr H
				inner join trs.tblPayDtl D
				on (D.ProcessID=H.ProcessID) And (D.ProcessNo=H.ProcessNo) And (D.FiscalYear=H.FiscalYear) And (D.SerialNo=H.SerialNo)
				where H.BaseProcessID=90  
				group by H.DiscountAmount,H.BaseProcessID,H.BaseProcessNo,H.BaseFiscalYear,H.BaseSerialNo
		) H
				group by  BaseProcessID,BaseProcessNo,BaseFiscalYear,BaseSerialNo
	)  c 
	on a.ProcessID=c.BaseProcessID And a.ProcessNo=c.BaseProcessNo And a.FiscalYear=c.BaseFiscalYear And a.SerialNo=c.BaseSerialNo
	left join 
	(  Select  b.SaleProcessID ,b.SaleProcessNo ,b.SaleFiscalYear ,b.SaleSerialNo,Sum (Amount) Amount 
		From 
			(Select    b.SaleProcessID ,b.SaleProcessNo ,b.SaleFiscalYear ,b.SaleSerialNo,
				(Select  Case when VchNo=0 then 0  else Amount end  Price from  inv.tblStorageDocsHdr a where a.ProcessID=b.ProcessID and a.ProcessNo=b.ProcessNo and a.FiscalYear=b.FiscalYear and a.SerialNo=b.SerialNo )  Amount	
			from trs.tblSettlementRetInvoice as b 
			where  b.BaseType=2)  b
		group by b.SaleProcessID ,b.SaleProcessNo ,b.SaleFiscalYear ,b.SaleSerialNo
	) d 
	on a.ProcessID=d.SaleProcessID And a.ProcessNo=d.SaleProcessNo And a.FiscalYear=d.SaleFiscalYear And a.SerialNo=d.SaleSerialNo
	where  a.ProcessID = @ProcessID AND a.ProcessNo=@ProcessNo and a.FiscalYear=@FiscalYear   and a.SerialNo=@SerialNo 
  
END TRY
BEGIN CATCH

	Set @StrErrorMessage = ERROR_MESSAGE() 
	raiserror (@StrErrorMessage, 16, 1)

END CATCH

END	
GO
