USE TS_ShirinVatanKarkhaneh_1_1404
GO
SET ANSI_NULLS, QUOTED_IDENTIFIER ON
GO
-- =========== TS-QC:UPDATED ====================
-- Author		 : TakroSystem/Jafari
-- Create date   : 1401-02-28
-- Viewed By	 : 
-- Last Modified : 
-- Last Modifier : 
-- Description   : مانده رسید موقت کالای خرید نشده
-- =============================================
Create Function inv.funInvTempReceiptRemain 
(  
	@GoodsID	 Varchar(20) = Null,
	@StoreID	 Varchar(20) = Null,
	@FromDate	 Varchar(20) = Null,
	@BatchNo	 Varchar(20) = Null
)
RETURNS float
WITH ENCRYPTION
AS
BEGIN

declare @RetValue  float;
	set	@RetValue = 0.0;

Select  @RetValue=  sum( isnull( D.GoodsQuantity,0) -isnull( buy.GoodsQuantity ,0))  
	From  inv.tblInvTempReceiptHdr  H 
	inner join inv.tblInvTempReceiptDtl  D
		ON	H.ProcessID = D.ProcessID 
		AND H.ProcessNo = D.ProcessNo 
		AND H.FiscalYear = D.FiscalYear 
		AND H.SerialNo = D.SerialNo 
		AND D.ProcessID<>79 
	LEFT JOIN 
	(
		Select	BaseProcessID , BaseProcessNo , BaseFiscalYear , BaseSerialNo , BaseDocRowNo 
		,isnull( SUM( GoodsQuantity  ),0)  GoodsQuantity
		From inv.tblStorageDocsDtl 
		Group BY BaseProcessID , BaseProcessNo , BaseFiscalYear , BaseSerialNo, BaseDocRowNo
	) buy
	ON	D.ProcessID = buy.BaseProcessID 
		AND D.ProcessNo = buy.BaseProcessNo 
		AND D.FiscalYear = buy.BaseFiscalYear 
		AND D.SerialNo = buy.BaseSerialNo 
		AND D.DocRowNo = buy.BaseDocRowNo	
	 WHERE isnull( D.GoodsQuantity,0) -isnull( buy.GoodsQuantity ,0) >0 
	 and H.StoreID=@StoreID 
	 and D.GoodsID=@GoodsID 
	 and (@FromDate='' or H.DocDate<=@FromDate )
	 and (@BatchNo ='' or D.BatchNo=@BatchNo)

	  
	 return @RetValue 
	
END








GO
