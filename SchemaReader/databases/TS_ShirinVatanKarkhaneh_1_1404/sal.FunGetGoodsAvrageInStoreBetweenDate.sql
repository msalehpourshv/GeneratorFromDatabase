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

Create FUNCTION [sal].[FunGetGoodsAvrageInStoreBetweenDate]
(
	@GoodsID VarChar(20),
	@FromDate char(10),
	@ToDate char(10)	
	)
	RETURNS int 
WITH ENCRYPTION
AS

Begin -- ====================================================



----Set @GoodsID=
--Declare @GoodsID varchar(20)='240030395'--'270020005'
--Declare @FromDate char(10)='1395/03/01'
--Declare @ToDate char(10)='1395/03/31'
Declare @BaseDate char(10)=''
Declare @AvgDay int

Declare @DocDate varchar(10)=''
Declare @Counter1 Float=0
Declare @Counter2 Float=0
Declare @Counter11 Float=0
Declare @GoodsQuantity Float=0
Declare @SumDays Float=0

--تعداد فروش در بازه زمانی
select @Counter1= isnull(sum(GoodsQuantity),0)  from  inv.tblStorageDocsDtl d
where GoodsID=@GoodsID and DocDate>=@FromDate and DocDate<=@ToDate
and ProcessID in (90)
	set @Counter11=@Counter1
	
	--print @Counter1
	
-- موجودی در انتهای بازه  فعلی
select @Counter2= isnull(sum(GoodsQuantity*EnterKind),0) from  inv.tblStorageDocsDtl d
where GoodsID=@GoodsID AND  DocDate<=@ToDate

--select  @Counter
--pub.funFarsiDateDiff('Day','1395/01/01','1395/02/01')

	set @SumDays=0

declare  AvgSalDate cursor for   
	select  GoodsQuantity ,DocDate , pub.funFarsiDateDiff('Day',@FromDate,DocDate)  DocDate2 from  inv.tblStorageDocsDtl d
	where GoodsID=@GoodsID and ProcessID in (90) AND  DocDate between @FromDate and @ToDate
	order by DocDate Desc

open AvgSalDate  
  
FETCH NEXT FROM AvgSalDate into @GoodsQuantity,@DocDate,@AvgDay
  
WHILE @@FETCH_STATUS = 0  
BEGIN 

	set @SumDays=@SumDays+(@AvgDay*@GoodsQuantity)
	
--print  @GoodsQuantity,@DocDate,@AvgDay,@SumDays
	
	FETCH NEXT FROM AvgSalDate into @GoodsQuantity,@DocDate,@AvgDay
  
END    
close AvgSalDate  
deallocate AvgSalDate 

 if (@Counter1<>0)
	set @AvgDay= @SumDays/@Counter1
	else
	set @AvgDay= 0
	
	set  @BaseDate = pub.funFarsiDateAddDays('Day', @FromDate,@AvgDay )


--select @BaseDate,@Counter1,@Counter2

set @SumDays=0
declare  ExpDate cursor for   
	select  GoodsQuantity ,DocDate , pub.funFarsiDateDiff('Day',DocDate,@BaseDate)  DocDate2 from  inv.tblStorageDocsDtl d
	where GoodsID=@GoodsID and ProcessID in (50,55,125) AND DocDate<=@ToDate
	order by DocDate Desc

open ExpDate  
  
FETCH NEXT FROM ExpDate into @GoodsQuantity,@DocDate,@AvgDay
  
WHILE @@FETCH_STATUS = 0  and @Counter1>0
BEGIN 
--select @Counter,@GoodsQuantity,@ExpireDate,@AvgDay,@SumDays
------------------------------------------------
if (@Counter2=0)
begin
--select  @GoodsQuantity,@DocDate,@AvgDay
set @Counter1=@Counter1- @GoodsQuantity

	if (@Counter1>=0)
	set @SumDays=@SumDays+(@AvgDay*@GoodsQuantity)
	else
	begin
			set @Counter1=@Counter1+ @GoodsQuantity
			set @SumDays=@SumDays+(@AvgDay*@Counter1)
			set @Counter1=0
	end 

end 
------------------------------------------------
if (@Counter2>0)
set @Counter2=@Counter2-@GoodsQuantity
------------------------------------------------
if (@Counter2<0)
begin

	set @Counter1=@Counter1- abs(@Counter2)

	if (@Counter1>=0)
		set @SumDays=@SumDays+(@AvgDay*abs(@Counter2))
	else
		begin
			set @Counter1=@Counter1+ abs(@Counter2)
			set @SumDays=@SumDays+(@AvgDay*@Counter1)
		end 
	set @Counter2=0
end 
------------------------------------------------


	FETCH NEXT FROM ExpDate into @GoodsQuantity,@DocDate,@AvgDay
  
END   
  
close ExpDate  
deallocate ExpDate 
 
----select @Counter,@GoodsQuantity,@ExpireDate,@AvgDay,@SumDays,@Counter2
 if (@Counter11<>0)
	set @Counter11=@SumDays/@Counter11
	else
	set @Counter11=0

--select @Counter11
Return  @Counter11
	
	
	
END -- ======================================================
GO
