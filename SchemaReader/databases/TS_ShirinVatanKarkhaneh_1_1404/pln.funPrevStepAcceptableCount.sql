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
-- Description	 : تابعی برای بدست آوردن تعداد منطبق مرحله قبلی
-- ==============================================
Create FUNCTION pln.funPrevStepAcceptableCount
(
	@SerialNo int ,
	@ProduceStepID int,
	@FiscalYear int 
)
RETURNS int
WITH ENCRYPTION
AS
BEGIN
declare @PrevProduceStepID int =0
declare @NeedRepeatCount int =0

select top 1 @PrevProduceStepID=isnull(ProduceStepID,0) 
FROM pln.tblTaskOrderHdr a
INNER JOIN pln.tblProduceStepDtl AS H ON H.ProductID = a.ProductID AND H.SerialNo = a.ProduceStepSerialNo 
where a.SerialNo=@SerialNo
and ProduceStepID<@ProduceStepID
order by ProduceStepID Desc
 
 if isnull(@PrevProduceStepID,0)=0
	 select @NeedRepeatCount=OrderCount	FROM pln.tblTaskOrderHdr a	where SerialNo=@SerialNo
else
	select @NeedRepeatCount=Sum(AcceptableCount) from pln.tblTaskOrderDtl where SerialNo=@SerialNo and ProduceStepID=@PrevProduceStepID  and TotalTime>0 and FiscalYear=@FiscalYear and NeedStop=0

Return  isnull(@NeedRepeatCount,0)
end 
 
GO
