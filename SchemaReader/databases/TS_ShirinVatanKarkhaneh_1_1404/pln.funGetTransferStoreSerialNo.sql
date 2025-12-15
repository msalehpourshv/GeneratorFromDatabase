USE TS_ShirinVatanKarkhaneh_1_1404
GO
SET ANSI_NULLS, QUOTED_IDENTIFIER ON
GO
-- =========== TS-QC:UPDATED ====================
-- Author		 : TakroSystem\jafari
-- Creation Date : 1401-01-20
-- Viewed By	 : 
-- Last Modified : 
-- Last Modifier : 
-- Description	 : شماره انتقال بین انبار یراساس سفارش تولید
-- ==============================================

Create FUNCTION pln.funGetTransferStoreSerialNo
(
@ProcessID int=0 ,
@ProcessNo int =0,
@FiscalYear int =0,
@SerialNo int=0
)
RETURNS VarChar(20)
WITH ENCRYPTION
AS

BEGIN
	Declare @ReturnSerialNo int
	Declare @ReturnFiscalyear int


	select  top 1  @ReturnFiscalyear=  isnull(FiscalYear,0)  ,@ReturnSerialNo= isnull(SerialNo,0) from inv.tblStorageDocsDtl s2 
		where s2.BaseProcessID=@ProcessID and s2.BaseProcessNo =@ProcessNo and s2.BaseFiscalYear=@FiscalYear and s2.BaseSerialNo=@SerialNo
			and ((s2.DocStep>=2 and s2.ProcessID=120) or s2.ProcessID=125)

	if isnull(@ReturnSerialNo,0)>0 
		 RETURN    ltrim(str(isnull(@ReturnFiscalyear,0))) +'/'+  ltrim(str(isnull(@ReturnSerialNo,0)))

	select  top 1  @ReturnFiscalyear= isnull(s2.FiscalYear,0), @ReturnSerialNo= isnull(s2.SerialNo,0) from inv.tblStorageDocsDtl s2 
	inner join  inv.tblStoresRequestsDtl r 
	 on r.ProcessID=s2.BaseProcessID and r.ProcessNo=s2.BaseProcessNo and r.FiscalYear=s2.BaseFiscalYear and r.SerialNo=s2.BaseSerialNo   and r.DocRowNo=s2.BaseDocRowNo

		where r.BaseProcessID=@ProcessID and r.BaseProcessNo =@ProcessNo and r.BaseFiscalYear=@FiscalYear and r.BaseSerialNo=@SerialNo
			and ((s2.DocStep>=2 and s2.ProcessID=120) or s2.ProcessID=125)
 
  RETURN    ltrim(str(isnull(@ReturnFiscalyear,0))) +'/'+  ltrim(str(isnull(@ReturnSerialNo,0)))

	  
END
GO
