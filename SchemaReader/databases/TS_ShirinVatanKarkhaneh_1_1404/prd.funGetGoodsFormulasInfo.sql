USE TS_ShirinVatanKarkhaneh_1_1404
GO
SET ANSI_NULLS, QUOTED_IDENTIFIER ON
GO
-- =========== TS-QC:NOTOK ========================
-- Author        : Jafari
-- Create date   : 1402/09/15
-- Viewed By	 : 
-- Last Modified : 
-- Description   : 
-- =============================================
Create Function prd.funGetGoodsFormulasInfo
(  
@CallType int,
@GoodsID Varchar(20),
@StoreID Varchar(20),
@DocDate char(10)
)
RETURNS Float
WITH ENCRYPTION
AS
BEGIN
	
	declare @GoodsQuantity  float;

	set @StoreID=isnull(@StoreID,'')
	set @DocDate=isnull(@DocDate,'')

	if @CallType=1
	begin
		select @GoodsQuantity=isnull( Sum(GoodsQuantity*EnterKind),0)
		from inv.tblStorageDocsDtl
		where (GoodsID = @GoodsID) 	and (@StoreID ='' or StoreID = @StoreID)
			and (@DocDate='' or DocDate<=@DocDate)
	end
	if @CallType=2
	begin
		select @GoodsQuantity= Sum(H.ProductCount) -ISNULL(Sum(GoodsQuantity) , 0)
		from inv.tblStorageDocsHdr H
		 left join inv.tblStorageDocsDtl D
		 on H.ProcessID=D.BaseProcessID and H.ProcessNo =D.BaseProcessNo and H.FiscalYear=D.BaseFiscalYear and H.SerialNo	=D.BaseSerialNo
			and H.ProductID	=D.GoodsID	
		where  H.ProcessID in (70) 	and H.ProductID=@GoodsID	 
	end 
	 
	return isnull(@GoodsQuantity,0)
	  
END
GO
