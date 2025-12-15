USE TS_ShirinVatanKarkhaneh_1_1404
GO
SET ANSI_NULLS, QUOTED_IDENTIFIER ON
GO
-- =========== TS-QC:UPDATED ====================
-- Author		 : TakroSystem\jafari
-- Creation Date : 1397/06/11
-- Viewed By	 : 
-- Last Modified : 
-- Last Modifier : 
-- Description	 : ثبت تطبیق اتوماتیک
-- ==============================================
Create procedure acc.SpAccMatch
@ExtraParams nvarchar(1000)
WITH ENCRYPTION
as
begin

declare @ProcessID int 
declare @ProcessNo int
declare @FiscalYear int 
declare @SerialNo int
declare @DocRowNo int
declare @AcntCode	varchar(20)
declare @BaseProcessID int
declare @BaseProcessNo int 
declare @BaseFiscalYear int 
declare @BaseSerialNo int
declare @BaseDocRowNo int
declare @DocDate	char(10) 
declare @Debit	decimal(28,9)
declare @Credit	decimal(28,9)
declare @Amount	decimal(28,9)
declare @BaseID1	int
declare @BaseID2	int
declare @ID1		int
declare @ID1v		int
declare @ID2		int
declare @ID2v		int
declare @EventNo	int
declare @VisitorAcntCode	varchar(20)
declare @VisitorAcntCode1	varchar(20)
declare @VisitorAcntCode2	varchar(20)
declare @RecDesc nvarchar(1000)
Declare @PPFS1 char(18)
Declare @PPFS2 char(18)
declare @Type int 
declare @SerialNo1 int
declare @SerialNo2 int
SET @AcntCode		    = LTrim(pub.funSplitString(@ExtraParams, '@', 1)); 
SET @BaseProcessID	    = LTrim(pub.funSplitString(@ExtraParams, '@', 2)); 
SET @BaseProcessNo	    = LTrim(pub.funSplitString(@ExtraParams, '@', 3)); 
SET @BaseFiscalYear	    = LTrim(pub.funSplitString(@ExtraParams, '@', 4)); 
SET @BaseSerialNo	    = LTrim(pub.funSplitString(@ExtraParams, '@', 5)); 
SET @ProcessID		    = LTrim(pub.funSplitString(@ExtraParams, '@', 6)); 
SET @ProcessNo		    = LTrim(pub.funSplitString(@ExtraParams, '@', 7)); 
SET @FiscalYear		    = LTrim(pub.funSplitString(@ExtraParams, '@', 8)); 
SET @SerialNo		    = LTrim(pub.funSplitString(@ExtraParams, '@', 9)); 
SET @Type				= LTrim(pub.funSplitString(@ExtraParams, '@', 10)); 
SET @VisitorAcntCode	= LTrim(pub.funSplitString(@ExtraParams, '@', 11)); 

set @PPFS1= right('00000'+LTRIM (rtrim( cast(@BaseProcessID as char(20)))) , 4) +right('00000'+LTRIM (rtrim( cast(@BaseProcessNo as char(20)))) , 2)
			+right('00000'+LTRIM (rtrim( cast(@BaseFiscalYear as char(20)))) , 4) +right('00000000'+LTRIM (rtrim( cast(@BaseSerialNo as char(20)))) , 8)
			
set @PPFS2= right('00000'+LTRIM (rtrim( cast(@ProcessID as char(20)))) , 4) +right('00000'+LTRIM (rtrim( cast(@ProcessNo as char(20)))) , 2) 
			+right('00000'+LTRIM (rtrim( cast(@FiscalYear as char(20)))) , 4) +right('00000000'+LTRIM (rtrim( cast(@SerialNo as char(20)))) , 8) 
		
----------- بروز رسانی جمع فاکتور هایی که با جمع قابل پرداخت یکسان است
if @BaseProcessID= 90 or @BaseProcessID=100 or @ProcessID=90 or @ProcessID=100
	update inv.tblStorageDocsHdr
	set Price=b.Amount- SidePriceSum
	from inv.tblStorageDocsHdr a 
	inner join inv.vwStorageDocsHdr b
	on a.ProcessID=b.ProcessID and  a.ProcessNo=b.ProcessNo and  a.FiscalYear=b.FiscalYear and  a.SerialNo=b.SerialNo
	WHERE   (a.ProcessID = @BaseProcessID or a.ProcessID = @ProcessID)
		and (a.ProcessNo = @BaseProcessNo or a.ProcessNo = @ProcessNo)
		and (a.FiscalYear = @BaseFiscalYear or a.FiscalYear = @FiscalYear)
		and (a.SerialNo = @BaseSerialNo or a.SerialNo = @SerialNo)
		and a.Amount=a.Price
		and b.SidePriceSum<>0

----  حذف تطبیق های قبلی براساس بیس ها
delete from acc.tblAccState
where AcntCode = @AcntCode and ((PPFS1=@PPFS1 and PPFS2=@PPFS2) or (PPFS1=@PPFS2 and PPFS2=@PPFS1))

exec acc.UpdatetblVoucher2AccState @ExtraParams
 
-----------------------------------------------------------------------------------------
---  برای قابل اصلاح و حذف بودن سطر هایی که قبلا تفکیک شده اند
update acc.tblVoucher2AccState
Set ActiveHalf=0
where AcntCode=@AcntCode and (PPFS1=@PPFS1 or PPFS1=@PPFS2)		 	
	
-----------------------------------------------------------------------------------------
-- ایجاد جدول میانی جهت تطبیق
select * into #tblDebit  
from acc.tblVoucher2AccState
where AcntCode = @AcntCode and  (VisitorAcntCode = @VisitorAcntCode or VisitorAcntCode='' )and (PPFS1=@PPFS1 or PPFS1=@PPFS2) and Credit=0 
order by SourceProcessID Desc, SourceProcessNo, SourceFiscalYear, SourceSerialNo, SourceDocRowNo, BaseID Desc, Amount	 
					
select * into #tblCredit  
from acc.tblVoucher2AccState
where  AcntCode=@AcntCode and  (VisitorAcntCode = @VisitorAcntCode  or VisitorAcntCode='' )and (PPFS1=@PPFS1 or PPFS1=@PPFS2) and Debit=0 
order by SourceProcessID Desc, SourceProcessNo, SourceFiscalYear, SourceSerialNo, SourceDocRowNo, BaseID Desc, Amount	 
	
---- order by Amount توضیح
-- برای مرتب سازی براساس مبالغ کمتر میباشد تا اول تطبیق بیابند مانند عوارض مالات و تخفیف
		 			 
-----------------------------------------------------------------------------------------
-- شروع تطبیق
 
 --select * from #tblDebit
 --select * from #tblCredit
 --return 
set @RecDesc='تطبیق اتوماتیک'
set @EventNo=0
		
while (select count(*) from #tblDebit)>0 and (select count(*) from #tblCredit)>0
begin
	set  @EventNo=@EventNo+1
	
	select top 1 @Debit=Amount, @BaseID1=BaseID, @ID1=ID1 , @ID1v=ID 
			,@BaseProcessID=SourceProcessID, @BaseProcessNo=SourceProcessNo, 
			@BaseFiscalYear=SourceFiscalYear, @BaseSerialNo=SourceSerialNo,@BaseDocRowNo =SourceDocRowNo
			,@VisitorAcntCode1=isnull(VisitorAcntCode,'')
			,@SerialNo1 =SerialNo 
	from #tblDebit
	
	select top 1 @Credit=Amount,@BaseID2=BaseID,@ID2=ID1,@ID2v=ID,@DocDate=DocDate
			,@ProcessID=SourceProcessID, @ProcessNo=SourceProcessNo, 
			@FiscalYear=SourceFiscalYear, @SerialNo=SourceSerialNo , @DocRowNo=SourceDocRowNo
			,@VisitorAcntCode2=isnull(VisitorAcntCode,'')
			,@SerialNo2 =SerialNo
	from #tblCredit
	
	if @Debit>@Credit
		set @Amount	=@Credit
	else
		set @Amount	=@Debit
		
	if @VisitorAcntCode1 <>'' 
		set @VisitorAcntCode =@VisitorAcntCode1
	else if @VisitorAcntCode2 <>'' 
		set @VisitorAcntCode =@VisitorAcntCode2
	else 
		set @VisitorAcntCode =''

	insert into acc.tblAccState 
		( AcntCode,SourceProcessID1, SourceProcessNo1, SourceFiscalYear1, SourceSerialNo1,SourceDocRowNo1, BaseID1 
        , SourceProcessID2, SourceProcessNo2, SourceFiscalYear2,SourceSerialNo2,SourceDocRowNo2, BaseID2 
        , DocDate, EventNo, Amount, RecDesc, VisitorAcntCode,ID1,ID2,VisitorAcntCode1,VisitorAcntCode2,SerialNo1,SerialNo2)  
	select @AcntCode  ,@BaseProcessID, @BaseProcessNo, @BaseFiscalYear, @BaseSerialNo,@BaseDocRowNo, @BaseID1 
		,@ProcessID, @ProcessNo, @FiscalYear,@SerialNo,@DocRowNo, @BaseID2 
		,@DocDate, @EventNo, @Amount, @RecDesc, @VisitorAcntCode,@ID1,@ID2	,@VisitorAcntCode1,@VisitorAcntCode2,@SerialNo1,@SerialNo2
		--select @ID1,@ID1v,@ID2,@ID2v
		 
    if  @Debit>@Credit
    begin
		Update #tblDebit 
		set Amount=Amount-@Amount 
		where ID=@ID1v

		delete from #tblCredit 
		where ID=@ID2v		
	end

	else if  @Credit>@Debit
	begin	
		delete from #tblDebit 
		where ID=@ID1v

		Update #tblCredit 
		set Amount=Amount-@Amount	 
		where ID=@ID2v
	end

	else if  @Credit=@Debit
	 begin 
		delete from #tblDebit where ID=@ID1v
		delete from #tblCredit where ID=@ID2v
	 end 
	 
end 

--------------------بروز رسانی نهایی جدول میانی---------------------------------------------------------------------------------------------------

exec acc.UpdatetblVoucher2AccState @ExtraParams
	
end
GO
