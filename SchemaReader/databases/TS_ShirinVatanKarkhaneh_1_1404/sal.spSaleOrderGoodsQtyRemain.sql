USE TS_ShirinVatanKarkhaneh_1_1404
GO
SET ANSI_NULLS, QUOTED_IDENTIFIER ON
GO
-- =========== TS-QC:NOTOK ========================
-- Author        : jafari
-- Create date   : 97/10/27
-- Viewed By	 : 
-- Last Modified : 
-- Description   : 
-- =============================================
--drop  FUNCTION cmr.FunCmrGoodsQty
Create Procedure sal.spSaleOrderGoodsQtyRemain
(
	@ProcessID int
	,@ProcessNo  int
	,@FiscalYear  int
	,@SerialNo  int
)

WITH ENCRYPTION            
as
begin
if @ProcessID  is null  set @ProcessID  =0
if @ProcessNo  is null  set @ProcessNo  =0
if @FiscalYear  is null  set @FiscalYear  =0
if @SerialNo  is null  set @SerialNo  =0

------------------------------------------------------------------
DECLARE @SalRet_RetToSalOdr AS BIT
	SET @SalRet_RetToSalOdr = 'False'

	SELECT @SalRet_RetToSalOdr = SettingValue
	FROM pub.tblSettings
	WHERE SettingKey = 'SalRet_RetToSalOdr' 
	--آیا مقدار سفارش با برگشت از فروش افزایش یابد؟
--	select @SalRet_RetToSalOdr
-------------------------------------------------------------------
		
	Select Orders.ProcessID ,Orders.ProcessNo ,Orders.FiscalYear ,Orders.SerialNo ,Orders.DocRowNo,Orders.RowNo
		 ,Orders.GoodsID,Orders.SubUnitID,Orders.DocStep
		 , isnull( Orders.GoodsQuantity,0)Qty ,isnull( Rtn.GoodsQuantity ,0) CancelQty 
		 , (isnull( Orders.GoodsQuantity,0)  -isnull( Rtn.GoodsQuantity ,0) 
		  -isnull( SaleOrder.GoodsQuantity ,0)+isnull( SaleOrder_Ret.GoodsQuantity ,0)) GoodsQuantity  
		 ,Orders.DocDate ,Orders.AcntCode
		 ,Orders.BaseProcessID	,Orders.BaseProcessNo	,Orders.BaseFiscalYear	,Orders.BaseSerialNo	,Orders.BaseDocRowNo
	From   (-----  سفارشات استفاده شده در فروش
			select  distinct Orders.ProcessID ,Orders.ProcessNo ,Orders.FiscalYear ,Orders.SerialNo ,Orders.DocRowNo,Orders.RowNo
		           ,Orders.GoodsID,Orders.SubUnitID,Orders.DocStep ,Orders.GoodsQuantity ,Orders.DocDate ,Orders.AcntCode
				   ,Orders.BaseProcessID	,Orders.BaseProcessNo	,Orders.BaseFiscalYear	,Orders.BaseSerialNo	,Orders.BaseDocRowNo  
			From  sal.tblSaleOrderDtl Orders
			inner join inv.tblStorageDocsDtl Sale
			On Orders.ProcessID=Sale.BaseProcessID AND Orders.ProcessNo=Sale.BaseProcessNo AND
				Orders.FiscalYear=Sale.BaseFiscalYear AND Orders.SerialNo=Sale.BaseSerialNo AND
				Orders.DocRowNo =Sale.BaseDocRowNo 	
			where 		
			Sale.ProcessID=@ProcessID AND Sale.ProcessNo=@ProcessNo AND
				Sale.FiscalYear=  @FiscalYear AND Sale.SerialNo=@SerialNo
		) Orders
	LEFT JOIN 
	(-----سفارشات برگشتی
		Select	BaseProcessID , BaseProcessNo , BaseFiscalYear , BaseSerialNo , BaseDocRowNo 
		,isnull( SUM( GoodsQuantity  ),0)  GoodsQuantity
		From  sal.tblSaleOrderDtl
	
		Group BY BaseProcessID , BaseProcessNo , BaseFiscalYear , BaseSerialNo, 
				BaseDocRowNo
	) Rtn
	ON	Orders.ProcessID = Rtn.BaseProcessID 
		AND Orders.ProcessNo = Rtn.BaseProcessNo 
		AND Orders.FiscalYear = Rtn.BaseFiscalYear 
		AND Orders.SerialNo = Rtn.BaseSerialNo 
		AND Orders.DocRowNo = Rtn.BaseDocRowNo
 LEFT JOIN 
	 (---سفارشات فروش شده و با تنظیمات فروش های برگشتی در تعداد سفارش اضافه شود
		select Sale.BaseProcessID,Sale.BaseProcessNo,Sale.BaseFiscalYear,Sale.BaseSerialNo,Sale.BaseDocRowNo,Sale.GoodsID
		,isnull(Sum( Sale.GoodsQuantity),0)  GoodsQuantity
		 from inv.tblStorageDocsDtl Sale
		 WHERE Sale.ProcessID=90
		 Group by  Sale.BaseProcessID,Sale.BaseProcessNo,Sale.BaseFiscalYear,Sale.BaseSerialNo,Sale.BaseDocRowNo,Sale.GoodsID
	 ) SaleOrder On Orders.ProcessID=SaleOrder.BaseProcessID AND Orders.ProcessNo=SaleOrder.BaseProcessNo AND
				   Orders.FiscalYear=SaleOrder.BaseFiscalYear AND Orders.SerialNo=SaleOrder.BaseSerialNo AND
				   Orders.DocRowNo =SaleOrder.BaseDocRowNo AND Orders.GoodsID =SaleOrder.GoodsID 		
 LEFT JOIN 
	 (---سفارشات فروش شده و با تنظیمات فروش های برگشتی در تعداد سفارش اضافه شود
		select Sale.BaseProcessID,Sale.BaseProcessNo,Sale.BaseFiscalYear,Sale.BaseSerialNo,Sale.BaseDocRowNo,Sale.GoodsID
		,(case when @SalRet_RetToSalOdr='True' then isnull(Sum( Rtn.GoodsQuantity),0) else 0 end) GoodsQuantity
		 FROM inv.tblStorageDocsDtl Sale
		 Left JOIN inv.tblStorageDocsDtl Rtn
		 on Sale.ProcessID = Rtn.BaseProcessID 
		AND Sale.ProcessNo = Rtn.BaseProcessNo 
		AND Sale.FiscalYear = Rtn.BaseFiscalYear 
		AND Sale.SerialNo = Rtn.BaseSerialNo 
		AND Sale.DocRowNo = Rtn.BaseDocRowNo
		AND Sale.GoodsID = Rtn.GoodsID
		where Sale.ProcessID=90 AND Sale.BaseProcessID=180 AND 
		      Rtn.ProcessID=100 AND Rtn.BaseProcessID=90 
		 Group by  Sale.BaseProcessID,Sale.BaseProcessNo,Sale.BaseFiscalYear,Sale.BaseSerialNo,Sale.BaseDocRowNo,Sale.GoodsID
	 ) SaleOrder_Ret On Orders.ProcessID=SaleOrder_Ret.BaseProcessID AND Orders.ProcessNo=SaleOrder_Ret.BaseProcessNo AND
				   Orders.FiscalYear=SaleOrder_Ret.BaseFiscalYear AND Orders.SerialNo=SaleOrder_Ret.BaseSerialNo AND
				   Orders.DocRowNo =SaleOrder_Ret.BaseDocRowNo AND Orders.GoodsID =SaleOrder_Ret.GoodsID 
	Where Orders.ProcessID = 180	

end
GO
