USE TS_ShirinVatanKarkhaneh_1_1404
GO
SET ANSI_NULLS, QUOTED_IDENTIFIER ON
GO
-- =========== TS-QC:UPDATED ====================
-- Author		 : Jafari
-- Create date   : 1402/12/14
-- Viewed By	 : 
-- Last Modified : 
-- Last Modifier : 
-- ----------------------------------------------
-- Description	 : تابعی برای بدست آوردن تعداد دوباره کاری مرحله بعدی
-- ==============================================
Create FUNCTION pln.funNextStepNeedRepeat
(
	@SerialNo int ,
	@ProduceStepID int  
)
RETURNS int
WITH ENCRYPTION
AS
BEGIN
declare @NextProduceStepID int =0
declare @NeedRepeatCount int =0

select top 1 @NextProduceStepID= ProduceStepID FROM pln.tblTaskOrderHdr A 
INNER JOIN pln.tblProduceStepDtl AS H ON H.ProductID = A.ProductID AND H.SerialNo = A.ProduceStepSerialNo 
where A.SerialNo=@SerialNo
and ProduceStepID>@ProduceStepID
order by ProduceStepID
 

 select @NeedRepeatCount=Sum(UnacceptableCount) from pln.tblTaskOrderDtl 
where SerialNo=@SerialNo
and ProduceStepID=@NextProduceStepID
and NeedRepeat=1
  
  
		Return  isnull(@NeedRepeatCount,0)
end 
 
GO
