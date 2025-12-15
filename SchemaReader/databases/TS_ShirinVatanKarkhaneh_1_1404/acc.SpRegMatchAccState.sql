USE TS_ShirinVatanKarkhaneh_1_1404
GO
SET ANSI_NULLS, QUOTED_IDENTIFIER ON
GO
-- =========== TS-QC:NOTOK ========================
-- Author        : jafari
-- Create date   : 95/08/05
-- Viewed By	 : 
-- Last Modified : 
-- Description   : 
-- ================================================

Create PROCEDURE [acc].[SpRegMatchAccState]
	@ProcessID1		TinyInt,
	@ProcessNo1		TinyInt,
	@FiscalYear1	SmallInt,
	@SerialNo1		Int,
	@ProcessID2		TinyInt,
	@ProcessNo2		TinyInt,
	@FiscalYear2	SmallInt,
	@SerialNo2		Int,
	@AcntCode Varchar(20)
	WITH ENCRYPTION
AS

BEGIN

declare	@DocRowNo1		Int
declare	@DocRowNo2		Int

declare @DocDate1 char(10), 
		@Amount1 float,
		@VisitorAcntCode1 Varchar(20),
		@BaseID1 int,
		@ID1 int,
		@DocDate2 char(10), 
		@Amount2 float,
		@VisitorAcntCode2 Varchar(20),
		@BaseID2 int,
		@ID2 int,
		@Amount float,
		@VisitorAcntCode Varchar(20),
		@EventNo int 



Set @EventNo=0
create table #tblAccState1
	(
ID int, 
SerialNo int, 
DocRowNo int, 
RecDesc  nvarchar(4000), 
SourceProcessID int ,
SourceProcessNo int ,
SourceFiscalYear int ,
SourceSerialNo int ,
SourceDocRowNo int,
BaseID int ,
AcntCode Varchar(20),
Debit float ,
Credit float , 
DocDate char(10),
Amount float , 
VisitorAcntCode Varchar(20),
ID1 int,
Types int,
AcntName nVarchar(Max),
VisitorName nVarchar(Max)

	);

select * into #tblAccState2  from #tblAccState1 
----------------------بروز رسانی جدوال میانی و دریافت اطلاعات تطبیق نشده
--exec acc.SpAcc_AccState @AcntCode,6

insert into  #tblAccState1 --(ID, SerialNo ,DocRowNo , RecDesc  , SourceProcessID ,SourceProcessNo ,SourceFiscalYear ,SourceSerialNo,SourceDocRowNo  ,BaseID  ,AcntCode ,Credit ,DocDate, Amount , VisitorAcntCode,ID1,AcntName,VisitorName )
exec acc.SpAcc_AccState @AcntCode,8

----------------حذف اطلاعات اضافی به غیر از ورودی ها
Delete from  #tblAccState1 where 
not( (SourceProcessID=@ProcessID1 and SourceProcessNo=@ProcessNo1 and SourceFiscalYear=@FiscalYear1 and SourceSerialNo=@SerialNo1 )
or   (SourceProcessID =@ProcessID2 and SourceProcessNo=@ProcessNo2 and SourceFiscalYear=@FiscalYear2 and SourceSerialNo=@SerialNo2 ))

insert into #tblAccState2  
select * from #tblAccState1 where Types=2

delete from #tblAccState1 where Types=2

--select * from #tblAccState1 
--select * from #tblAccState2

-----------------------------تست اطلاعات موجود برای تطبیق
if (select COUNT(*) from #tblAccState1)<=0 or (select COUNT(*) from #tblAccState2)<=0
begin
select 0 Ret
return
end 

------------------دریافت اطلاعات و تطبیق
	select  top 1 @ProcessID1=SourceProcessID,@ProcessNo1= SourceProcessNo,@FiscalYear1= SourceFiscalYear,@SerialNo1= SourceSerialNo,@DocRowNo1= SourceDocRowNo, @DocDate1= DocDate, @Amount1=Amount,@VisitorAcntCode1=VisitorAcntCode,@BaseID1=BaseID,@ID1=ID1 from  #tblAccState1 Order BY BaseID
	select  top 1 @ProcessID2=SourceProcessID,@ProcessNo2= SourceProcessNo,@FiscalYear2= SourceFiscalYear,@SerialNo2= SourceSerialNo,@DocRowNo2= SourceDocRowNo, @DocDate2= DocDate, @Amount2=Amount,@VisitorAcntCode2=VisitorAcntCode,@BaseID2=BaseID,@ID2=ID1 from  #tblAccState2 Order BY BaseID

Set @EventNo=@EventNo+1
set @VisitorAcntCode=@VisitorAcntCode1
if @VisitorAcntCode is null
set @VisitorAcntCode=@VisitorAcntCode2

if @Amount1<@Amount2
set @Amount=@Amount1
else
set @Amount=@Amount2

insert into acc.tblAccState ( AcntCode,SourceProcessID1, SourceProcessNo1, SourceFiscalYear1, SourceSerialNo1,SourceDocRowNo1, BaseID1
, SourceProcessID2, SourceProcessNo2, SourceFiscalYear2,SourceSerialNo2,SourceDocRowNo2, BaseID2
, DocDate, EventNo
, Amount, RecDesc, VisitorAcntCode,ID1,ID2	,VisitorAcntCode1,VisitorAcntCode2)  

select @AcntCode,@ProcessID1,@ProcessNo1,@FiscalYear1,@SerialNo1,@DocRowNo1,@BaseID1,
				 @ProcessID2,@ProcessNo2,@FiscalYear2,@SerialNo2,@DocRowNo2,@BaseID2,
@DocDate1,  @EventNo,@Amount,'تطبیق اتوماتیک',@VisitorAcntCode,@ID1,@ID2,@VisitorAcntCode1,@VisitorAcntCode2
	
Delete from  acc.tblVoucher2AccState where 
( (SourceProcessID=@ProcessID1 and SourceProcessNo=@ProcessNo1 and SourceFiscalYear=@FiscalYear1 and SourceSerialNo=@SerialNo1 )
or   (SourceProcessID =@ProcessID2 and SourceProcessNo=@ProcessNo2 and SourceFiscalYear=@FiscalYear2 and SourceSerialNo=@SerialNo2 ))

Delete from  acc.tblVoucher2AccState where 
( (SourceProcessID=@ProcessID1 and SourceProcessNo=@ProcessNo1 and SourceFiscalYear=@FiscalYear1 and SourceSerialNo=@SerialNo1 )
or   (SourceProcessID =@ProcessID2 and SourceProcessNo=@ProcessNo2 and SourceFiscalYear=@FiscalYear2 and SourceSerialNo=@SerialNo2 ))


select 1 Ret

end 
GO
