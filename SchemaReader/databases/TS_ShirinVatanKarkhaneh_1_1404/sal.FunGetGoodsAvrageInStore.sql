USE TS_ShirinVatanKarkhaneh_1_1404
GO
SET ANSI_NULLS, QUOTED_IDENTIFIER ON
GO
-- =========== TS-QC:UPDATED ====================
-- Author		 : TakroSystem\Jafari
-- Create date   : 1395
-- Viewed By	 : 
-- Last Modified : 1395/05/18
-- Last Modifier : 
-- Description   : <GoodsAvrageInStore>
-- ==============================================

Create FUNCTION [sal].[FunGetGoodsAvrageInStore]
(
	@GoodsID VarChar(20),
	@BaseDate char(10)
	)
	RETURNS float 
WITH ENCRYPTION
AS

Begin -- ====================================================



--Set @GoodsID=
--Declare @GoodsID varchar(20)='270020005'
--Declare @BaseDate char(10)='1395/05/25'
Declare @AvgDay int

Declare @ExpireDate varchar(10)=''
Declare @ExpireDateEnd varchar(10)=''
Declare @Counter Float=0
Declare @Counter2 Float=0
Declare @GoodsQuantity Float=0
Declare @SumQty Float=0
Declare @SumDays Float=0


select @Counter= isnull(sum(GoodsQuantity*EnterKind),0) from  inv.tblStorageDocsDtl d
where GoodsID=@GoodsID
set @Counter2=@Counter
--select  @Counter
--pub.funFarsiDateDiff('Day','1395/01/01','1395/02/01')

declare  ExpDate cursor for   
	select  GoodsQuantity ,DocDate , pub.funFarsiDateDiff('Day',DocDate,@BaseDate)  DocDate2 from  inv.tblStorageDocsDtl d
	where GoodsID=@GoodsID and EnterKind=1
	order by DocDate Desc

open ExpDate  
  
FETCH NEXT FROM ExpDate into @GoodsQuantity,@ExpireDate,@AvgDay
  
WHILE @@FETCH_STATUS = 0  and @Counter>0
BEGIN 
--select @Counter,@GoodsQuantity,@ExpireDate,@AvgDay,@SumDays

set @Counter=@Counter-@GoodsQuantity
if (@Counter>@GoodsQuantity)
set @SumDays=@SumDays+(@AvgDay*@GoodsQuantity)
else
set @SumDays=@SumDays+(@AvgDay*(@Counter+@GoodsQuantity))


set @ExpireDateEnd=@ExpireDate

	FETCH NEXT FROM ExpDate into @GoodsQuantity,@ExpireDate,@AvgDay
  
END   
  
close ExpDate  
deallocate ExpDate 
 
--select @Counter,@GoodsQuantity,@ExpireDate,@AvgDay,@SumDays,@Counter2
 if (@Counter2<>0)
	set @Counter2=@SumDays/@Counter2

	Return  @Counter2
	
	
	
END -- ======================================================
GO
